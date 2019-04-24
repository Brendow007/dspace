/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package br.com.dglsistemas.webui.servlet;

import org.apache.log4j.Logger;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.core.Context;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.content.Community;
import org.dspace.content.DCDate;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.discovery.DiscoverQuery;
import org.dspace.discovery.DiscoverResult;
import org.dspace.discovery.SearchService;
import org.dspace.utils.DSpace;

/**
 * @author Guilherme Lemeszenski
 *
 * @version $Revision$
 */
public class SubmissionReportServlet extends DSpaceServlet {

    private static final String SHOW_FORM_OPERATION = "form";
    private static final String SEARCH_OPERATION = "search";

    private static final String OFFSET = "offset";
    private static final String START = "start";

    private static final String AUTHOR_METADATA = "dc.description.provenance";
    private static final String DATE_ISSUED_METADATA = "dc.date.available";
    private static final String TITLE_METADATA = "dc.title";
    private static final String URI_METADATA = "dc.identifier.uri";

    private SearchService searchService = null;

    @Override
    public void init() throws ServletException {
        DSpace dspace = new DSpace();
        searchService = dspace.getServiceManager().getServiceByName(SearchService.class.getName(), SearchService.class);
    }

    /**
     * Logger
     */
    private static Logger log = Logger.getLogger(SubmissionReportServlet.class);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        Context context = null;
        // set all incoming encoding to UTF-8
        request.setCharacterEncoding("UTF-8");

        // Get the URL from the request immediately, since forwarding
        // loses that information
        UIUtil.storeOriginalURL(request);

        try {
            // Obtain a context - either create one, or get the one created by
            // an authentication filter
            context = UIUtil.obtainContext(request);

            String operation = request.getParameter("operation");
            String draw = request.getParameter("draw");
            String start = request.getParameter("start");
            String length = request.getParameter("length");

            String community = request.getParameter("community");
            String title = request.getParameter("title");
            String author = request.getParameter("author");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");

            try {
                if (startDate != null && !startDate.isEmpty()) {
                    String startDateParts[] = startDate.split("/");
                    startDate = startDateParts[2] + "-" + startDateParts[1] + "-" + startDateParts[0] + "T00:00:00.000Z";
                }

                if (endDate != null && !endDate.isEmpty()) {
                    String endDateParts[] = endDate.split("/");
                    endDate = endDateParts[2] + "-" + endDateParts[1] + "-" + endDateParts[0] + "T00:00:00.000Z";
                }
            } catch (Exception e) {
                log.error(e);
                JSPManager.showJSP(request, response, "/report/submission-report.jsp");
                return;
            }

            if (operation.equals(SEARCH_OPERATION)) {

                request.setCharacterEncoding("UTF-8");
                UIUtil.storeOriginalURL(request);

                try {

                    DiscoverResult result = searchItens(context,
                            draw,
                            start,
                            Integer.parseInt(length),
                            title,
                            author,
                            startDate,
                            endDate,
                            community);

                    List<Item> itens = getItemList(result);

                    response.setContentType("application/json");
                    PrintWriter out = response.getWriter();

                    StringBuilder builder = new StringBuilder();
                    builder.append("{");
                    builder.append("    \"draw\": " + draw + ",");
                    builder.append("    \"recordsTotal\": " + result.getTotalSearchResults() + ",");
                    builder.append("    \"recordsFiltered\": " + result.getTotalSearchResults() + ",");
                    builder.append("    \"submission\": [");

                    for (int i = 0; i < itens.size(); i++) {
                        if (i > 0) {
                            builder.append(",");
                        }

                        DCDate itemAvailableDate = new DCDate(itens.get(i).getMetadata(DATE_ISSUED_METADATA));

                        String auth = itens.get(i).getMetadata(AUTHOR_METADATA);
                        //itens.get(i).getSubmitter();

                        Matcher email = Pattern.compile("[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+").matcher(auth);

                        String compiled = "";

                            while (email.find()) {

                               String force = email.group();

                               compiled =  force.toUpperCase();

                           }

                        builder.append("        {");
                        builder.append("             \"title\": \"" + tratarValor(itens.get(i).getMetadata(TITLE_METADATA)) + "\",");
                        builder.append("             \"author\": \"" + compiled + "\",");
                        builder.append("             \"date\": \"" + UIUtil.displayDate(itemAvailableDate, false, true, request) + "\",");
                        builder.append("             \"uri\": \"" + itens.get(i).getMetadata(URI_METADATA) + "\"");
                        builder.append("        }");
                    }
                    builder.append("    ]");
                    builder.append("}");

                    out.print(builder.toString());
                    out.flush();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

        } catch (Exception e) {
            log.error(e);
            JSPManager.showJSP(request, response, "/report/submission-report.jsp");
            return;

        } finally {
            // Abort the context if it's still valid
            if ((context != null) && context.isValid()) {
                context.abort();
            }
        }

    }

    /**
     *
     */
    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String operation = request.getParameter("operation");

        if (AuthorizeManager.isAdmin(context)) {

            if (operation.equals(SHOW_FORM_OPERATION)) {
                
                Community[] topCommunities = Community.findAllTop(context);
                request.setAttribute("topCommunities", topCommunities);

                JSPManager.showJSP(request, response, "/report/submission-report.jsp");
                return;

            } else {
                JSPManager.showJSP(request, response, "/error/authorize.jsp");
                return;
            }

        }
    }

    //search by metadata

    protected DiscoverResult searchItens(Context context,
            String offset, String start, int maxResults,
            String title, String author, String startDate, String endDate, String community) {

        int startValue = start == null || start.isEmpty() ? 0 : Integer.parseInt(start);

        DiscoverQuery queryArgs = new DiscoverQuery();
        queryArgs.setDSpaceObjectFilter(Constants.ITEM);
        queryArgs.setMaxResults(maxResults);
        queryArgs.setStart(startValue);

        if (offset != null && !offset.isEmpty()) {
            int offsetValue = Integer.parseInt(offset);
            if (offsetValue == -1) {
                offsetValue = 0;
            }
            queryArgs.setFacetOffset(offsetValue);
        }

        if (startDate == null || startDate.isEmpty()) {
            startDate = "*";
        }
        if (endDate == null || endDate.isEmpty()) {
            endDate = "*";
        }

        queryArgs.addFilterQueries("dc.date.available_dt:[" + startDate + " TO " + endDate + "]");

        if (author != null && !author.isEmpty()) {
            queryArgs.addFilterQueries("author:" + author);
        }

        if (title != null && !title.isEmpty()) {
            queryArgs.addFilterQueries("title:" + title);
        }
        
        if (community != null && !community.isEmpty()) {
            queryArgs.addFilterQueries("location.comm:" + community);
        }
        
        queryArgs.addSearchField(AUTHOR_METADATA);
        queryArgs.addSearchField(TITLE_METADATA);
        queryArgs.addSearchField(DATE_ISSUED_METADATA);
        queryArgs.addSearchField(URI_METADATA);

        DiscoverResult queryResults = null;

        try {

            queryResults = searchService.search(context, null, queryArgs);

        } catch (Exception e) {
            e.printStackTrace();
        }

        //return itemList;
        return queryResults;

    }

    protected List<Item> getItemList(DiscoverResult queryResults) {
        List<Item> itemList = new ArrayList<Item>();

        if (queryResults != null && queryResults.getDspaceObjects().size() > 0) {

            for (DSpaceObject row : queryResults.getDspaceObjects()) {
                itemList.add((Item) row);

            }
        }

        return itemList;
    }

    protected String tratarValor(String valor) {
        return valor != null ? valor.replaceAll("\"", "") : null;
    }
}
