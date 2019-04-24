/**
 * The contents of this file are subject to the license and copyright detailed
 * in the LICENSE and NOTICE files at the root of the source tree and available
 * online at
 * <p>
 * http://www.dspace.org/license/
 */

package org.dspace.app.webui.jsptag;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.browse.BrowseException;
import org.dspace.browse.CrossLinks;
import org.dspace.content.*;
import org.dspace.content.authority.MetadataAuthorityManager;
import org.dspace.content.service.ItemService;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.Utils;
import org.dspace.sort.SortOption;
import org.dspace.storage.bitstore.BitstreamStorageManager;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.jstl.fmt.LocaleSupport;
import javax.servlet.jsp.tagext.TagSupport;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.StringTokenizer;

/**
 * Tag for display a list of items
 *
 * @author Robert Tansley
 * @version $Revision$
 */
public class ItemListTag extends TagSupport {

    private static Logger log = Logger.getLogger(ItemListTag.class);

    /**
     * Items to display
     */
    private transient Item[] items;

    /**
     * Row to highlight, -1 for no row
     */
    private int highlightRow = -1;

    /**
     * Column to emphasise - null, "title" or "date"
     */
    private String emphColumn;

    /**
     * Config value of thumbnail view toggle
     */
    private static boolean showThumbs;

    /**
     * Config browse/search width and height
     */
    private static int thumbItemListMaxWidth;

    private static int thumbItemListMaxHeight;

    /**
     * Config browse/search thumbnail link behaviour
     */
    private static boolean linkToBitstream = false;

    /**
     * Config to include an edit link
     */
    private boolean linkToEdit = false;

    /**
     * Config to disable cross links
     */
    private boolean disableCrossLinks = false;

    /**
     * The default fields to be displayed when listing items
     */
    private static final String DEFAULT_LIST_FIELDS;

    /**
     * The default widths for the columns
     */
    private static final String DEFAULT_LIST_WIDTHS;

    /**
     * The default field which is bound to the browse by date
     */
    private static String dateField = "dc.date.issued";

    /**
     * The default field which is bound to the browse by title
     */
    private static String titleField = "dc.title";

    private static String authorField = "dc.contributor.*";

    private int authorLimit = -1;

    private transient SortOption sortOption = null;

    private static final long serialVersionUID = 348762897199116432L;

    static {
        getThumbSettings();

        if (showThumbs) {
            DEFAULT_LIST_FIELDS = "thumbnail, dc.date.issued(date), dc.title, dc.contributor.*";
            DEFAULT_LIST_WIDTHS = "*, 130, 60%, 40%";
        } else {
            DEFAULT_LIST_FIELDS = "dc.date.issued(date), dc.title, dc.contributor.*";
            DEFAULT_LIST_WIDTHS = "130, 60%, 40%";
        }

        // get the date and title fields
        String dateLine = ConfigurationManager.getProperty("webui.browse.index.date");
        if (dateLine != null) {
            dateField = dateLine;
        }

        String titleLine = ConfigurationManager.getProperty("webui.browse.index.title");
        if (titleLine != null) {
            titleField = titleLine;
        }

        String authorLine = ConfigurationManager.getProperty("webui.browse.author-field");
        if (authorLine != null) {
            authorField = authorLine;
        }
    }

    public ItemListTag() {
        super();
    }

    public int doStartTag() throws JspException {
        JspWriter out = pageContext.getOut();
        HttpServletRequest hrq = (HttpServletRequest) pageContext.getRequest();

        boolean emphasiseDate = false;
        boolean emphasiseTitle = false;

        if (emphColumn != null) {
            emphasiseDate = emphColumn.equalsIgnoreCase("date");
            emphasiseTitle = emphColumn.equalsIgnoreCase("title");
        }

        // get the elements to display
        String configLine = null;
        String widthLine = null;

        if (sortOption != null) {
            if (configLine == null) {
                configLine = ConfigurationManager.getProperty("webui.itemlist.sort." + sortOption.getName() + ".columns");
                widthLine = ConfigurationManager.getProperty("webui.itemlist.sort." + sortOption.getName() + ".widths");
            }

            if (configLine == null) {
                configLine = ConfigurationManager.getProperty("webui.itemlist." + sortOption.getName() + ".columns");
                widthLine = ConfigurationManager.getProperty("webui.itemlist." + sortOption.getName() + ".widths");
            }
        }

        if (configLine == null) {
            configLine = ConfigurationManager.getProperty("webui.itemlist.columns");
            widthLine = ConfigurationManager.getProperty("webui.itemlist.widths");
        }

        // Have we read a field configration from dspace.cfg?
        if (configLine != null) {
            // If thumbnails are disabled, strip out any thumbnail column from the configuration
            if (!showThumbs && configLine.contains("thumbnail")) {
                // Ensure we haven't got any nulls
                configLine = configLine == null ? "" : configLine;
                widthLine = widthLine == null ? "" : widthLine;

                // Tokenize the field and width lines
                StringTokenizer llt = new StringTokenizer(configLine, ",");
                StringTokenizer wlt = new StringTokenizer(widthLine, ",");

                StringBuilder newLLine = new StringBuilder();
                StringBuilder newWLine = new StringBuilder();
                while (llt.hasMoreTokens() || wlt.hasMoreTokens()) {
                    String listTok = llt.hasMoreTokens() ? llt.nextToken() : null;
                    String widthTok = wlt.hasMoreTokens() ? wlt.nextToken() : null;

                    // Only use the Field and Width tokens, if the field isn't 'thumbnail'
                    if (listTok == null || !listTok.trim().equals("thumbnail")) {
                        if (listTok != null) {
                            if (newLLine.length() > 0) {
                                newLLine.append(",");
                            }

                            newLLine.append(listTok);
                        }

                        if (widthTok != null) {
                            if (newWLine.length() > 0) {
                                newWLine.append(",");
                            }

                            newWLine.append(widthTok);
                        }
                    }
                }

                // Use the newly built configuration file
                configLine = newLLine.toString();
                widthLine = newWLine.toString();
            }
        } else {
            configLine = DEFAULT_LIST_FIELDS;
            widthLine = DEFAULT_LIST_WIDTHS;
        }

        // Arrays used to hold the information we will require when outputting each row
        String[] fieldArr = configLine == null ? new String[0] : configLine.split("\\s*,\\s*");
        String[] widthArr = widthLine == null ? new String[0] : widthLine.split("\\s*,\\s*");
        boolean isDate[] = new boolean[fieldArr.length];
        boolean emph[] = new boolean[fieldArr.length];
        boolean isAuthor[] = new boolean[fieldArr.length];
        boolean viewFull[] = new boolean[fieldArr.length];
        String[] browseType = new String[fieldArr.length];
        String[] cOddOrEven = new String[fieldArr.length];

        try {
            // Get the interlinking configuration too
            CrossLinks cl = new CrossLinks();

            out.println("<ul class=\"itemList\">");

            for (int colIdx = 0; colIdx < fieldArr.length; colIdx++) {
                String field = fieldArr[colIdx].toLowerCase().trim();
                cOddOrEven[colIdx] = (((colIdx + 1) % 2) == 0 ? "Odd" : "Even");

                // find out if the field is a date
                if (field.indexOf("(date)") > 0) {
                    field = field.replaceAll("\\(date\\)", "");
                    isDate[colIdx] = true;
                }

                // Cache any modifications to field
                fieldArr[colIdx] = field;

                // find out if this is the author column
                if (field.equals(authorField)) {
                    isAuthor[colIdx] = true;
                }

                // find out if this field needs to link out to other browse views
                /*if (cl.hasLink(field))
                {
                    browseType[colIdx] = cl.getLinkType(field);
                    viewFull[colIdx] = BrowseIndex.getBrowseIndex(browseType[colIdx]).isItemIndex();
                }
                */

                // find out if we are emphasising this field
                if (field.equals(emphColumn)) {
                    emph[colIdx] = true;
                } else if ((field.equals(dateField) && emphasiseDate) ||
                        (field.equals(titleField) && emphasiseTitle)) {
                    emph[colIdx] = true;
                }
            }

            // now output each item row
            for (int i = 0; i < items.length; i++) {

                Metadatum[] dcTypeArray = items[i].getMetadata("dc", "type", Item.ANY, Item.ANY);
                String icon = "conteudo-generico";

                if (dcTypeArray != null && dcTypeArray.length > 0) {

                    Metadatum fileType = dcTypeArray[0];

                    if(fileType.value != null){
                    switch (fileType.value) {
                        case "vídeo":
                            icon = "conteudo-video";
                            break;
                        case "áudio":
                            icon = "conteudo-audio";
                            break;
                        case "animação":
                            icon = "conteudo-animated";
                            break;
                        case "apresentação":
                            icon = "conteudo-presentation";
                            break;
                        case "planilha":
                            icon = "conteudo-sheet";
                            break;
                        case "texto":
                            icon = "conteudo-texto";
                            break;
                        case "imagem":
                            icon = "conteudo-imagem";
                            break;
                        case "aplicativo móvel":
                            icon = "conteudo-app";
                            break;
                        case "Software":
                            icon = "conteudo-software";
                            break;
                        case "curso":
                            icon = "conteudo-course";
                            break;
                        case "jogos":
                            icon = "conteudo-game";
                            break;
                        case "ferramentas":
                            icon = "conteudo-tool";
                            break;
                        case "portal":
                            icon = "conteudo-portal";
                            break;
                        case "aula digital":
                            icon = "conteudo-virtual-course";
                            break;
                        case "livro digital":
                            icon = "conteudo-texto";
                            break;
                        case "laboratório":
                            icon = "conteudo-lab";
                            break;
                        case "FUNAG":
                            icon = "conteudo-plataforma-funag";
                            break;
                        case "REMAR":
                            icon = "conteudo-plataforma-remar";
                            break;
                        case "RELLE":
                            icon = "conteudo-plataforma-relle";
                            break;
                        case "VLIBRAS":
                            icon = "conteudo-plataforma-vlibras";
                            break;
                        case "UEMA":
                            icon = "conteudo-plataforma-uema";
                            break;
                        case "POCA":
                            icon = "conteudo-plataforma-poca";
                            break;
                        case "UFRGS":
                            icon = "conteudo-plataforma-ufrgs";
                            break;
                        case "UNICAMP-COURSERA":
                            icon = "conteudo-plataforma-unicamp";
                            break;
                        default:
                            icon = "conteudo-generico";
                    }
                    }else{
//                        icon = "conteudo-generico";
                    }

                }


                if (icon.contains("plataforma")) {
                    out.println("<li><div class=\"thumbnail-wrapper-plataform\"><div class=\"artifact-preview\">");
                    out.println("<a href=\"#\"><span class=\"item-list-platform " + icon + "\"></span></a>");
                    out.println("</div></div><div class=\"artifact-description\">");
                } else {
                    out.println("<li><div class=\"thumbnail-wrapper\">");
                        out.println("<div class=\"artifact-preview\">");
                            out.println("<a href=\"#\"><span class=\"item-list " + icon + "\"></span></a>");
                        out.println("</div>");
                            try {int idc = fieldArr.length + 1;
                                 out.print("<div class=\"evalStars\" headers=\"" + "t" + idc + "\" class=\""  + "Row" + cOddOrEven[cOddOrEven.length - 2] + "Col\" >" + items[i].getItemEvaluationHtml() + "</div>");
                            }catch (SQLException e){e.printStackTrace();}
                    out.println("</div>");
                    out.println("<div class=\"artifact-description\">");
                }



//                else if(items[i].getMetadata("dc.uab.SN") != null) {
//                out.println("<li class=\"hide\"><div class=\"hide thumbnail-wrapper\"><div class=\"hide artifact-preview\">");
//                out.println("<a href=\"#\"><span class=\"item-list " + icon + "\"></span></a>");
//                out.println("</div></div><div class=\"hide artifact-description\">");
//                out.println("<div>"+items[i].getMetadata("dc.uab.SN")+"</div>");
//                }


                String rOddOrEven;
                if (i == highlightRow) {
                    rOddOrEven = "highlight";
                } else {
                    rOddOrEven = ((i & 1) == 1 ? "odd" : "even");
                }

                for (int colIdx = 0; colIdx < fieldArr.length; colIdx++) {
                    String field = fieldArr[colIdx];

                    // get the schema and the element qualifier pair
                    // (Note, the schema is not used for anything yet)
                    // (second note, I hate this bit of code.  There must be
                    // a much more elegant way of doing this.  Tomcat has
                    // some weird problems with variations on this code that
                    // I tried, which is why it has ended up the way it is)
                    StringTokenizer eq = new StringTokenizer(field, ".");

                    String[] tokens = {"", "", ""};
                    int k = 0;
                    while (eq.hasMoreTokens()) {
                        tokens[k] = eq.nextToken().toLowerCase().trim();
                        k++;
                    }
                    String schema = tokens[0];
                    String element = tokens[1];
                    String qualifier = tokens[2];

                    // first get hold of the relevant metadata for this column
                    Metadatum[] metadataArray;
                    if (qualifier.equals("*")) {
                        metadataArray = items[i].getMetadata(schema, element, Item.ANY, Item.ANY);
                    } else if (qualifier.equals("")) {
                        metadataArray = items[i].getMetadata(schema, element, null, Item.ANY);
                    } else {
                        metadataArray = items[i].getMetadata(schema, element, qualifier, Item.ANY);
                    }

                    // save on a null check which would make the code untidy
                    if (metadataArray == null) {
                        metadataArray = new Metadatum[0];
                    }

                    // now prepare the content of the table division
                    String metadata = "";
                    if (field.equals("thumbnail")) {
                        metadata = getThumbMarkup(hrq, items[i]);
                    } else if (field.startsWith("mark_")) {
                        metadata = UIUtil.getMarkingMarkup(hrq, items[i], field);
                    }
                    if (metadataArray.length > 0) {
                        // format the date field correctly
                        if (isDate[colIdx]) {
                            DCDate dd = new DCDate(metadataArray[0].value);
                            metadata = "<div class=\"data\">"+UIUtil.displayDate(dd, false, false, hrq) +"</div>";
                        } // format the title field correctly for withdrawn items (ie. don't link)
                        else if (field.equals(titleField) && items[i].isWithdrawn()) {
                            metadata = Utils.addEntities(metadataArray[0].value);
                        } // format the title field correctly
                        else if (field.equals(titleField)) {

                            if (items[i].getMetadata("dc.plataform") != null) {
                                metadata = "<a target=\"blank\" href=\""
                                        + items[i].getMetadata("dc.identifier")
                                        + "\">" + items[i].getMetadata("dc.title")
                                        + "</a>";
                            } else {
                                metadata = "<a href=\"" + hrq.getContextPath() + "/handle/"
                                        + items[i].getHandle() + "\">"
                                        + Utils.addEntities(metadataArray[0].value)
                                        + "</a>";
                            }
                        } // format all other fields
                        else {
                            // limit the number of records if this is the author field (if
                            // -1, then the limit is the full list)
                            boolean truncated = false;
                            int loopLimit = metadataArray.length;
                            if (isAuthor[colIdx]) {
                                int fieldMax = (authorLimit > 0 ? authorLimit : metadataArray.length);
                                loopLimit = (fieldMax > metadataArray.length ? metadataArray.length : fieldMax);
                                truncated = (fieldMax < metadataArray.length);
                                log.debug("Limiting output of field " + field + " to " + Integer.toString(loopLimit) + " from an original " + Integer.toString(metadataArray.length));
                            }

                            StringBuffer sb = new StringBuffer();
                            for (int j = 0; j < loopLimit; j++) {
                                String startLink = "";
                                String endLink = "";
                                if (!StringUtils.isEmpty(browseType[colIdx]) && !disableCrossLinks) {
                                    String argument;
                                    String value;
                                    if (metadataArray[j].authority != null
                                            && metadataArray[j].confidence >= MetadataAuthorityManager.getManager()
                                            .getMinConfidence(metadataArray[j].schema, metadataArray[j].element, metadataArray[j].qualifier)) {
                                        argument = "authority";
                                        value = metadataArray[j].authority;
                                    } else {
                                        argument = "value";
                                        value = metadataArray[j].value;
                                    }
                                    if (viewFull[colIdx]) {
                                        argument = "vfocus";
                                    }
                                    startLink = "<a href=\"" + hrq.getContextPath() + "/browse?type=" + browseType[colIdx] + "&amp;"
                                            + argument + "=" + URLEncoder.encode(value, "UTF-8");

                                    if (metadataArray[j].language != null) {
                                        startLink = startLink + "&amp;"
                                                + argument + "_lang=" + URLEncoder.encode(metadataArray[j].language, "UTF-8");
                                    }

                                    if ("authority".equals(argument)) {
                                        startLink += "\" class=\"authority " + browseType[colIdx] + "\">";
                                    } else {
                                        startLink = startLink + "\">";
                                    }
                                    endLink = "</a>";
                                }
                                sb.append(startLink);
                                sb.append(Utils.addEntities(metadataArray[j].value));
                                sb.append(endLink);
                                if (j < (loopLimit - 1)) {
                                    sb.append("; ");
                                }
                            }
                            if (truncated) {
                                String etal = LocaleSupport.getLocalizedMessage(pageContext, "itemlist.et-al");
                                sb.append(", ").append(etal);
                            }
                            metadata = sb.toString();
                        }
                    } //In case title has no value, replace it with "undefined" so as the user has something to
                    //click in order to access the item page
                    else if (field.equals(titleField)) {
                        String undefined = LocaleSupport.getLocalizedMessage(pageContext, "itemlist.title.undefined");
                        if (items[i].isWithdrawn()) {
                            metadata = "<span style=\"font-style:italic\">(" + undefined + ")</span>";
                        } // format the title field correctly (as long as the item isn't withdrawn, link to it)
                        else {
                            metadata = "<a href=\"" + hrq.getContextPath() + "/handle/"
                                    + items[i].getHandle() + "\">"
                                    + "<span style=\"font-style:italic\">(" + undefined + ")</span>"
                                    + "</a>";
                        }
                    }

                    // prepare extra special layout requirements for dates
                    String extras = "";
                    if (isDate[colIdx]) {
                        extras = "nowrap=\"nowrap\" ";
                    }

                    String markClass = "";
                    if (field.startsWith("mark_")) {
                        markClass = " " + field + "_tr";
                    }

                    String id = "t" + Integer.toString(colIdx + 1);
                    out.print("<div headers=\"" + id + "\" class=\"" +id + " "
                            + rOddOrEven + "Row" + cOddOrEven[colIdx] + "Col" + markClass + "\" " + extras + ">"
                            + (emph[colIdx] ? "<strong>" : "") + metadata + (emph[colIdx] ? "</strong>" : "")
                            + "</div>");
                }

                if (icon.contains("plataforma")) {

                } else {
           /*         try {
                        int idc = fieldArr.length + 1;
                        out.print("<div headers=\"" + "t" + idc + "\" class=\"" + rOddOrEven + "Row" + cOddOrEven[cOddOrEven.length - 2] + "Col\" >" + items[i].getItemEvaluationHtml() + "</div>");
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }*/
                }

                // Add column for 'edit item' links
                if (linkToEdit) {
                    String id = "t" + Integer.toString(cOddOrEven.length + 1);

                    out.print("<div headers=\"" + id + "\" class=\""
                            + rOddOrEven + "Row" + cOddOrEven[cOddOrEven.length - 2] + "Col\" nowrap>"
                            + "<form method=\"get\" action=\"" + hrq.getContextPath() + "/tools/edit-item\">"
                            + "<input type=\"hidden\" name=\"handle\" value=\"" + items[i].getHandle() + "\" />"
                            + "<input type=\"submit\" value=\"Edit Item\" /></form>"
                            + "</div>");
                }

                out.println("</li>");
            }

            // close the table
            out.println("</ul>");
        } catch (IOException ie) {
            throw new JspException(ie);
        } catch (BrowseException e) {
            throw new JspException(e);
        }

        return SKIP_BODY;
    }

    public int getAuthorLimit() {
        return authorLimit;
    }

    public void setAuthorLimit(int al) {
        authorLimit = al;
    }

    public boolean getLinkToEdit() {
        return linkToEdit;
    }

    public void setLinkToEdit(boolean edit) {
        this.linkToEdit = edit;
    }

    public boolean getDisableCrossLinks() {
        return disableCrossLinks;
    }

    public void setDisableCrossLinks(boolean links) {
        this.disableCrossLinks = links;
    }

    public SortOption getSortOption() {
        return sortOption;
    }

    public void setSortOption(SortOption so) {
        sortOption = so;
    }

    /**
     * Get the items to list
     *
     * @return the items
     */
    public Item[] getItems() {
        return (Item[]) ArrayUtils.clone(items);
    }

    /**
     * Set the items to list
     *
     * @param itemsIn the items
     */
    public void setItems(Item[] itemsIn) {
        items = (Item[]) ArrayUtils.clone(itemsIn);
    }

    /**
     * Get the row to highlight - null or -1 for no row
     *
     * @return the row to highlight
     */
    public String getHighlightrow() {
        return String.valueOf(highlightRow);
    }

    /**
     * Set the row to highlight
     *
     * @param highlightRowIn the row to highlight or -1 for no highlight
     */
    public void setHighlightrow(String highlightRowIn) {
        if ((highlightRowIn == null) || highlightRowIn.equals("")) {
            highlightRow = -1;
        } else {
            try {
                highlightRow = Integer.parseInt(highlightRowIn);
            } catch (NumberFormatException nfe) {
                highlightRow = -1;
            }
        }
    }

    /**
     * Get the column to emphasise - "title", "date" or null
     *
     * @return the column to emphasise
     */
    public String getEmphcolumn() {
        return emphColumn;
    }

    /**
     * Set the column to emphasise - "title", "date" or null
     *
     * @param emphColumnIn column to emphasise
     */
    public void setEmphcolumn(String emphColumnIn) {
        emphColumn = emphColumnIn;
    }

    public void release() {
        highlightRow = -1;
        emphColumn = null;
        items = null;
    }

    /* get the required thumbnail config items */
    private static void getThumbSettings() {
        showThumbs = ConfigurationManager
                .getBooleanProperty("webui.browse.thumbnail.show");

        if (showThumbs) {
            thumbItemListMaxHeight = ConfigurationManager
                    .getIntProperty("webui.browse.thumbnail.maxheight");

            if (thumbItemListMaxHeight == 0) {
                thumbItemListMaxHeight = ConfigurationManager
                        .getIntProperty("thumbnail.maxheight");
            }

            thumbItemListMaxWidth = ConfigurationManager
                    .getIntProperty("webui.browse.thumbnail.maxwidth");

            if (thumbItemListMaxWidth == 0) {
                thumbItemListMaxWidth = ConfigurationManager
                        .getIntProperty("thumbnail.maxwidth");
            }
        }

        String linkBehaviour = ConfigurationManager
                .getProperty("webui.browse.thumbnail.linkbehaviour");

        if ("bitstream".equals(linkBehaviour)) {
            linkToBitstream = true;
        }
    }

    /*
     * Get the (X)HTML width and height attributes. As the browser is being used
     * for scaling, we only scale down otherwise we'll get hideously chunky
     * images. This means the media filter should be run with the maxheight and
     * maxwidth set greater than or equal to the size of the images required in
     * the search/browse
     */
    private String getScalingAttr(HttpServletRequest hrq, Bitstream bitstream)
            throws JspException {
        BufferedImage buf;

        try {
            Context c = UIUtil.obtainContext(hrq);

            InputStream is = BitstreamStorageManager.retrieve(c, bitstream
                    .getID());

            //AuthorizeManager.authorizeAction(bContext, this, Constants.READ);
            // 	read in bitstream's image
            buf = ImageIO.read(is);
            is.close();
        } catch (SQLException sqle) {
            throw new JspException(sqle.getMessage(), sqle);
        } catch (IOException ioe) {
            throw new JspException(ioe.getMessage(), ioe);
        }

        // now get the image dimensions
        float xsize = (float) buf.getWidth(null);
        float ysize = (float) buf.getHeight(null);

        // scale by x first if needed
        if (xsize > (float) thumbItemListMaxWidth) {
            // calculate scaling factor so that xsize * scale = new size (max)
            float scale_factor = (float) thumbItemListMaxWidth / xsize;

            // now reduce x size and y size
            xsize = xsize * scale_factor;
            ysize = ysize * scale_factor;
        }

        // scale by y if needed
        if (ysize > (float) thumbItemListMaxHeight) {
            float scale_factor = (float) thumbItemListMaxHeight / ysize;

            // now reduce x size
            // and y size
            xsize = xsize * scale_factor;
            ysize = ysize * scale_factor;
        }

        StringBuffer sb = new StringBuffer("width=\"").append(xsize).append(
                "\" height=\"").append(ysize).append("\"");

        return sb.toString();
    }

    /* generate the (X)HTML required to show the thumbnail */
    private String getThumbMarkup(HttpServletRequest hrq, Item item)
            throws JspException {
        try {
            Context c = UIUtil.obtainContext(hrq);
            Thumbnail thumbnail = ItemService.getThumbnail(c, item.getID(), linkToBitstream);

            if (thumbnail == null) {
                return "";
            }
            StringBuffer thumbFrag = new StringBuffer();

            if (linkToBitstream) {
                Bitstream original = thumbnail.getOriginal();
                String link = hrq.getContextPath() + "/bitstream/" + item.getHandle() + "/" + original.getSequenceID() + "/"
                        + UIUtil.encodeBitstreamName(original.getName(), Constants.DEFAULT_ENCODING);
                thumbFrag.append("<a target=\"_blank\" href=\"" + link + "\" />");
            } else {
                String link = hrq.getContextPath() + "/handle/" + item.getHandle();
                thumbFrag.append("<a href=\"" + link + "\" />");
            }

            Bitstream thumb = thumbnail.getThumb();
            String img = hrq.getContextPath() + "/retrieve/" + thumb.getID() + "/"
                    + UIUtil.encodeBitstreamName(thumb.getName(), Constants.DEFAULT_ENCODING);
            String alt = thumb.getName();
            String scAttr = getScalingAttr(hrq, thumb);
            thumbFrag.append("<img src=\"")
                    .append(img)
                    .append("\" alt=\"").append(alt).append("\" ")
                    .append(scAttr)
                    .append("/ border=\"0\"></a>");

            return thumbFrag.toString();
        } catch (SQLException sqle) {
            throw new JspException(sqle.getMessage(), sqle);
        } catch (UnsupportedEncodingException e) {
            throw new JspException("Server does not support DSpace's default encoding. ", e);
        }
    }
}
