<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Show form allowing edit of collection metadata
  -
  - Attributes:
  -    item        - item to edit
  -    collections - collections the item is in, if any
  -    handle      - item's Handle, if any (String)
  -    dc.types    - MetadataField[] - all metadata fields in the registry
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"
           prefix="c" %>

<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.dspace.app.webui.servlet.admin.EditItemServlet" %>
<%@ page import="org.dspace.content.*" %>

<%@ page import="org.dspace.content.authority.ChoiceAuthorityManager" %>
<%@ page import="org.dspace.content.authority.Choices" %>

<%@ page import="org.dspace.content.authority.MetadataAuthorityManager" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="static org.bouncycastle.asn1.x509.X509ObjectIdentifiers.id" %>
<%@ page import="static com.sun.corba.se.spi.activation.IIOP_CLEAR_TEXT.value" %>
<%@ page import="static com.hp.hpl.jena.sparql.vocabulary.TestManifestX.option" %>
<%@ page import="java.util.Map" %>

<%
    Item item = (Item) request.getAttribute("item");
    String handle = (String) request.getAttribute("handle");
    Collection[] collections = (Collection[]) request.getAttribute("collections");
    MetadataField[] dcTypes = (MetadataField[]) request.getAttribute("dc.types");
    HashMap metadataFields = (HashMap) request.getAttribute("metadataFields");
    request.setAttribute("LanguageSwitch", "hide");

    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Is the logged in user an admin of the item
    Boolean itemAdmin = (Boolean) request.getAttribute("admin_button");
    boolean isItemAdmin = (itemAdmin == null ? false : itemAdmin.booleanValue());

    Boolean admin = (Boolean) request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    Boolean policy = (Boolean) request.getAttribute("policy_button");
    boolean bPolicy = (policy == null ? false : policy.booleanValue());

    Boolean delete = (Boolean) request.getAttribute("delete_button");
    boolean bDelete = (delete == null ? false : delete.booleanValue());

    Boolean createBits = (Boolean) request.getAttribute("create_bitstream_button");
    boolean bCreateBits = (createBits == null ? false : createBits.booleanValue());

    Boolean removeBits = (Boolean) request.getAttribute("remove_bitstream_button");
    boolean bRemoveBits = (removeBits == null ? false : removeBits.booleanValue());

    Boolean ccLicense = (Boolean) request.getAttribute("cclicense_button");
    boolean bccLicense = (ccLicense == null ? false : ccLicense.booleanValue());

    Boolean withdraw = (Boolean) request.getAttribute("withdraw_button");
    boolean bWithdraw = (withdraw == null ? false : withdraw.booleanValue());

    Boolean reinstate = (Boolean) request.getAttribute("reinstate_button");
    boolean bReinstate = (reinstate == null ? false : reinstate.booleanValue());

    Boolean privating = (Boolean) request.getAttribute("privating_button");
    boolean bPrivating = (privating == null ? false : privating.booleanValue());

    Boolean publicize = (Boolean) request.getAttribute("publicize_button");
    boolean bPublicize = (publicize == null ? false : publicize.booleanValue());

    Boolean reOrderBitstreams = (Boolean) request.getAttribute("reorder_bitstreams_button");
    boolean breOrderBitstreams = (reOrderBitstreams != null && reOrderBitstreams);
    String[] dcMetadata = {"dc.contributor.author", "dc.description.abstract", "dc.title", "dc.subject"};
    String[] dcMetadataHeaders = {"dc.contributor.author", "dc.description.abstract", "dc.language.iso", "dc.title", "dc.subject"};



    // owning Collection ID for choice authority calls
    int collectionID = -1;
    if (collections.length > 0)
        collectionID = collections[0].getID();
%>
<%!
    StringBuffer doAuthority(MetadataAuthorityManager mam, ChoiceAuthorityManager cam,
                             PageContext pageContext,
                             String contextPath, String fieldName, String idx,
                             Metadatum dcv, int collectionID) {
        StringBuffer sb = new StringBuffer();
        if (cam.isChoicesConfigured(fieldName)) {
            boolean authority = mam.isAuthorityControlled(fieldName);
            boolean required = authority && mam.isAuthorityRequired(fieldName);

            String fieldNameIdx = "value_" + fieldName + "_" + idx;
            String authorityName = "choice_" + fieldName + "_authority_" + idx;
            String confidenceName = "choice_" + fieldName + "_confidence_" + idx;

            // put up a SELECT element containing all choices
            if ("select".equals(cam.getPresentation(fieldName))) {
                sb.append("<select class=\"form-control\" id=\"").append(fieldNameIdx)
                        .append("\" name=\"").append(fieldNameIdx)
                        .append("\" size=\"1\">");
                Choices cs = cam.getMatches(fieldName, dcv.value, collectionID, 0, 0, null);
                if (cs.defaultSelected < 0)
                    sb.append("<option value=\"").append(dcv.value).append("\" selected>")
                            .append(dcv.value).append("</option>\n");

                for (int i = 0; i < cs.values.length; ++i) {
                    sb.append("<option value=\"").append(cs.values[i].value).append("\"")
                            .append(i == cs.defaultSelected ? " selected>" : ">")
                            .append(cs.values[i].label).append("</option>\n");
                }
                sb.append("</select>\n");
            }

            // use lookup for any other presentation style (i.e "select")
            else {
                String confidenceIndicator = "indicator_" + confidenceName;
                sb.append("<textarea class=\"form-control\" id=\"").append(fieldNameIdx).append("\" name=\"").append(fieldNameIdx)
                        .append("\" rows=\"3\" cols=\"50\">")
                        .append(dcv.value).append("</textarea>\n<br/>\n");

                if (authority) {
                    String confidenceSymbol = Choices.getConfidenceText(dcv.confidence).toLowerCase();
                    sb.append("<span class=\"col-md-1\">")
                            .append("<img id=\"" + confidenceIndicator + "\"  title=\"")
                            .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.authority.confidence.description." + confidenceSymbol))
                            .append("\" class=\"ds-authority-confidence cf-" + confidenceSymbol)
                            .append("\" src=\"").append(contextPath).append("/image/confidence/invisible.gif\" />")
                            .append("</span>");
                    sb.append("<span class=\"col-md-5\">")
                            .append("<input class=\"form-control\" type=\"text\" readonly value=\"")
                            .append(dcv.authority != null ? dcv.authority : "")
                            .append("\" id=\"").append(authorityName)
                            .append("\" onChange=\"javascript: return DSpaceAuthorityOnChange(this, '")
                            .append(confidenceName).append("','").append(confidenceIndicator)
                            .append("');\" name=\"").append(authorityName).append("\" class=\"ds-authority-value ds-authority-visible \"/>")
                            .append("<input type=\"image\" class=\"ds-authority-lock is-locked \" ")
                            .append(" src=\"").append(contextPath).append("/image/confidence/invisible.gif\" ")
                            .append(" onClick=\"javascript: return DSpaceToggleAuthorityLock(this, '").append(authorityName).append("');\" ")
                            .append(" title=\"")
                            .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.edit-item-form.unlock"))
                            .append("\" >")
                            .append("<input type=\"hidden\" value=\"").append(confidenceSymbol).append("\" id=\"").append(confidenceName)
                            .append("\" name=\"").append(confidenceName)
                            .append("\" class=\"ds-authority-confidence-input\"/>")
                            .append("</span>");
                }

                sb.append("<span class=\"col-md-1\">")
                        .append("<button class=\"form-control\" name=\"").append(fieldNameIdx).append("_lookup\" ")
                        .append("onclick=\"javascript: return DSpaceChoiceLookup('")
                        .append(contextPath).append("/tools/lookup.jsp','")
                        .append(fieldName).append("','edit_metadata','")
                        .append(fieldNameIdx).append("','").append(authorityName).append("','")
                        .append(confidenceIndicator).append("',")
                        .append(String.valueOf(collectionID)).append(",")
                        .append("false").append(",false);\"")
                        .append(" title=\"")
                        .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.lookup.lookup"))
                        .append("\"><span class=\"glyphicon glyphicon-search\"></span></button></span>");
            }
        }
        return sb;
    }
%>

<c:set var="dspace.layout.head.last" scope="request">
    <script type="text/javascript" src="<%= request.getContextPath() %>/static/js/scriptaculous/prototype.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/static/js/scriptaculous/builder.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/static/js/scriptaculous/effects.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/static/js/scriptaculous/controls.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/dspace-admin/js/bitstream-ordering.js"></script>
</c:set>

<dspace:layout style="submission" titlekey="jsp.tools.edit-item-form.title"
               navbar="default"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">
    <style>
        .btn-group > .btn, .btn-group-vertical > .btn {
            position: relative;
            float: unset;
        }
        .table-td{
            text-align: justify;
            padding-bottom: 10px;

        }


    </style>

    <%-- <h1>Edit Item</h1> --%>
    <h1><fmt:message key="jsp.tools.edit-item-form.title"/>
        <dspace:popup
                page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.collection-admin\") + \"#editmetadata\"%>"><fmt:message
                key="jsp.morehelp"/></dspace:popup>
    </h1>

    <%-- <p><strong>PLEASE NOTE: These changes are not validated in any way.
    You are responsible for entering the data in the correct format.
    If you are not sure what the format is, please do NOT make changes.</strong></p> --%>
    <p class="alert alert-danger"><strong><fmt:message key="jsp.tools.edit-item-form.note"/></strong></p>

    <div class="row">
        <div class="col-md-9">
            <div class="panel panel-primary">
                <div class="panel-heading"><fmt:message key="jsp.tools.edit-item-form.details"/></div>

                <div class="panel-body">
                    <table class="table">
                        <tr>
                            <td><fmt:message key="jsp.tools.edit-item-form.itemID"/>
                            </td>
                            <td><%= item.getID() %>
                            </td>
                        </tr>

                        <tr>
                            <td><fmt:message key="jsp.tools.edit-item-form.handle"/>
                            </td>
                            <td><%= (handle == null ? "None" : handle) %>
                            </td>
                        </tr>
                        <tr>
                            <td><fmt:message key="jsp.tools.edit-item-form.modified"/>
                            </td>
                            <td><dspace:date
                                    date="<%= new DCDate(item.getLastModified()) %>"/>
                            </td>
                        </tr>


                            <%-- <td class="submitFormLabel">In Collections:</td> --%>
                        <tr>
                            <td><fmt:message key="jsp.tools.edit-item-form.collections"/>
                            </td>
                            <td>
                                <% for (int i = 0; i < collections.length; i++) { %> <%= collections[i].getMetadata("name") %>
                                <br/> <% } %>
                            </td>
                        </tr>
                        <tr>
                                <%-- <td class="submitFormLabel">Item page:</td> --%>
                            <td><fmt:message key="jsp.tools.edit-item-form.itempage"/>
                            </td>
                            <td>
                                <% if (handle == null) { %> <em><fmt:message
                                    key="jsp.tools.edit-item-form.na"/>
                            </em> <% } else {
                                String url = ConfigurationManager.getProperty("dspace.url") + "/handle/" + handle; %>
                                <a target="_blank" href="<%= url %>"><%= url %>
                                </a> <% } %>
                            </td>
                        </tr>


                    </table>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="panel panel-default">
                <div class="panel-heading"><fmt:message key="jsp.actiontools"/></div>
                <div class="panel-body">
                    <%
                        if (!item.isWithdrawn() && bWithdraw) {
                            if (isAdmin) {
                    %>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_WITHDRAW %>"/>
                            <%-- <input type="submit" name="submit" value="Withdraw..."> --%>
                        <input class="btn btn-warning col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.tools.edit-item-form.withdraw-w-confirm.button"/>"/>
                    </form>
                    <%
                        }
                    } else if (item.isWithdrawn() && bReinstate) {
                        if (isAdmin) {
                    %>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                        <input type="hidden" name="action" value="<%= EditItemServlet.REINSTATE %>"/>
                            <%-- <input type="submit" name="submit" value="Reinstate"> --%>
                        <input class="btn btn-warning col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.tools.edit-item-form.reinstate.button"/>"/>
                    </form>
                    <%
                            }
                        }
                    %>
                    <%
                        if (bDelete) {
                    %>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_DELETE %>"/>
                            <%-- <input type="submit" name="submit" value="Delete (Expunge)..."> --%>
                        <input class="btn btn-danger col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.tools.edit-item-form.delete-w-confirm.button"/>"/>
                    </form>
                    <%
                        }
                    %>
                    <%
                        //  if (isItemAdmin)
                        if (isAdmin) {
                    %>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_MOVE_ITEM %>"/>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.tools.edit-item-form.move-item.button"/>"/>
                    </form>
                    <%
                        }
                    %>
                    <%
                        if (item.isDiscoverable() && bPrivating) {
                            if (isAdmin) {
                    %>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_PRIVATING %>"/>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.tools.edit-item-form.privating-w-confirm.button"/>"/>
                    </form>
                    <%
                        }
                    } else if (!item.isDiscoverable() && bPublicize) {
                    %>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                        <input type="hidden" name="action" value="<%= EditItemServlet.PUBLICIZE %>"/>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.tools.edit-item-form.publicize.button"/>"/>
                    </form>
                    <%
                        }
                    %>

                    <%
                        if (bPolicy) {
                            if (isAdmin) {
                    %>
                        <%-- ===========================================================
                         Edit item's policies
                         =========================================================== --%>
                    <form method="post"
                          action="<%= request.getContextPath() %>/tools/authorize">
                        <input type="hidden" name="handle"
                               value="<%= ConfigurationManager.getProperty("handle.prefix") %>"/>
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                            <%-- <input type="submit" name="submit_item_select" value="Edit..."> --%>
                        <input class="btn btn-default col-md-12" type="submit"
                               name="submit_item_select"
                               value="<fmt:message key="jsp.tools.edit-item-form.item" />"/>
                    </form>

                        <%--<form method="post" action="<%= request.getContextPath() %>/tools/authorize">--%>
                        <%--<input type="hidden" name="item_id" value="<%= item.getID() %>"/>--%>
                        <%--&lt;%&ndash; <input type="submit" name="submit_item_select" value="Edit..."> &ndash;%&gt;--%>
                        <%--<input class="btn btn-default col-md-12" type="submit"name="submit_read_policy_anonymous" value="Habilitar ao publico" />"/>--%>
                        <%--</form>--%>
                    <%}%>
                        <%}%>

                    <div class="hidden">
                        <form method="post" action="<%= request.getContextPath() %>/tools/authorize">
                            <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                            <input class="btn btn-default col-md-12" type="submit" name="submit_read_policy_anonymous"
                                   value="Habilitar ao publico"/>
                        </form>
                    </div>


                    <%
                        if (isAdmin) {
                    %>
                        <%-- ===========================================================
                             Curate Item
                             =========================================================== --%>
                    <form method="post"
                          action="<%= request.getContextPath() %>/tools/curate">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
                        <input class="btn btn-default col-md-12" type="submit"
                               name="submit_item_select"
                               value="<fmt:message key="jsp.tools.edit-item-form.form.button.curate"/>"/>
                    </form>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>


    <%if (item.isWithdrawn()) {%>
    <%-- <p align="center"><strong>This item was withdrawn from DSpace</strong></p> --%>
    <p class="alert alert-warning"><fmt:message key="jsp.tools.edit-item-form.msg"/></p>
    <%
        }
    %>
    <form id="edit_metadata" name="edit_metadata" method="post" action="<%=request.getContextPath() %>/tools/edit-item">
        <div class="table-responsive">
            <table class="table" summary="Edit item withdrawn table">
                <tr>
                        <%-- <th class="oddRowOddCol"><strong>Element</strong></th>
                        <th id="t1" class="oddRowEvenCol"><strong>Qualifier</strong></th>
                        <th id="t2" class="oddRowOddCol"><strong>Value</strong></th>
                        <th id="t3" class="oddRowEvenCol"><strong>Language</strong></th> --%>

                    <% if (!isAdmin) {%>
                    <th id="t0" class="table-td oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem.name"/></strong></th>
                    <th id="t3" class="table-td oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem3"/></strong></th>
                    <%} else {%>
                    <th id="t0" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem.name"/></strong></th>
                    <th id="t1" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem0"/></strong></th>
                    <th id="t2" class="oddRowEvenCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem1"/></strong></th>
                    <th id="t3" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem2"/></strong></th>
                    <th id="t4" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem3"/></strong></th>
                    <th id="t5" class="oddRowEvenCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem4"/></strong></th>
                    <%}%>
                </tr>
                <%
                    MetadataAuthorityManager mam = MetadataAuthorityManager.getManager();
                    ChoiceAuthorityManager cam = ChoiceAuthorityManager.getManager();
                    Metadatum[] dcv = item.getMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);
                    String row = "even";

                    // Keep a count of the number of values of each element+qualifier
                    // key is "element" or "element_qualifier" (String)
                    // values are Integers - number of values that element/qualifier so far
                    Map<String, Integer> dcCounter = new HashMap<String, Integer>();

                    for (int i = 0; i < dcv.length; i++) {
                        // Find out how many values with this element/qualifier we've found

                        String key = ChoiceAuthorityManager.makeFieldKey(dcv[i].schema, dcv[i].element, dcv[i].qualifier);

                        Integer count = dcCounter.get(key);
                        if (count == null) {
                            count = new Integer(0);
                        }

                        // Increment counter in map
                        dcCounter.put(key, new Integer(count.intValue() + 1));

                        // We will use two digits to represent the counter number in the parameter names.
                        // This means a string sort can be used to put things in the correct order even
                        // if there are >= 10 values for a particular element/qualifier.  Increase this to
                        // 3 digits if there are ever >= 100 for a single element/qualifer! :)
                        String sequenceNumber = count.toString();
                        String sequenceView = count.toString();

                        while (sequenceNumber.length() < 2) {
                            sequenceNumber = "0" + sequenceNumber;
                        }
//                        while (sequenceView.length() < 2) {
//                            sequenceView = "0" + sequenceView;
//                        }
                 /*       int parseInt = Integer.parseInt(sequenceNumber);
                        parseInt += 1;
                        String sequence = Integer.toString(parseInt);*/

                        String dcName = dcv[i].getField();
                        LocaleSupport.getLocalizedMessage(pageContext, dcName);
                %>
                <tr>

                    <%if (isAdmin) {%>

                    <td headers="t0"
                        class="<%= row %>RowOddCol"><%=LocaleSupport.getLocalizedMessage(pageContext, dcName) + ":"%>
                    </td>
                    <td headers="t0" class="<%= row %>RowOddCol"><%=dcv[i].schema %>
                    </td>
                    <td headers="t1" class="<%= row %>RowEvenCol"><%= dcv[i].element %>&nbsp;&nbsp;</td>
                    <td headers="t2"
                        class="<%= row %>RowOddCol"><%= (dcv[i].qualifier == null ? "" : dcv[i].qualifier) %>
                    </td>

                    <%} else { %>

                    <%for (String value : dcMetadataHeaders) {%>
                    <%if (dcName.equals(value)) {%>
                    <td headers="t0" class="table-td <%=row%>RowOddCol">
                    <%=LocaleSupport.getLocalizedMessage(pageContext, dcName) + ":"%>
                    </td>
                    <%}%>

                    <%}%>
                    <%}%>


                    <td headers="t3" class="table-td <%= row %> RowEvenCol">
                        <%
                            if (cam.isChoicesConfigured(key)) {
                        %>

                        <%= doAuthority(mam, cam, pageContext, request.getContextPath(), key, sequenceNumber, dcv[i], collectionID).toString() %>

                        <% } else { %>

                        <%if (isAdmin) {%>

                        <textarea
                                class="form-control"
                                id="value_<%=key%>_<%= sequenceNumber %>"
                                name="value_<%=key%>_<%=sequenceNumber%>"
                                rows="3" cols="50"> <%= dcv[i].value %>
                            </textarea>

                        <%} else if (isItemAdmin) { %>
                        <%if (dcName.equals("dc.language.iso")) {%>
                        <div id="lang">
                            <select class="form-control" id="value_<%=key%>_<%= sequenceNumber %>"
                                    name="value_<%= key%>_<%=sequenceNumber%>">
                                <optgroup label="Idioma atual:">
                                    <option value="<%=dcv[i].value%>"><%=dcv[i].value%>
                                    </option>
                                </optgroup>
                                <optgroup label="Idiomas:">
                                    <option value="pt_BR">Português (Brasil)</option>
                                    <option value="pt">Português</option>
                                    <option value="en_US">Inglês (Estados Unidos)</option>
                                    <option value="en">Inglês</option>
                                    <option value="es">Espanhol</option>
                                    <option value="de">Alemão</option>
                                    <option value="fr">Francês</option>
                                    <option value="it">Italiano</option>
                                    <option value="ja">Japonês</option>
                                    <option value="zh">Chinês</option>
                                    <option value="outro">(Outro)</option>
                                </optgroup>
                            </select>
                        </div>
                        <%} %>

                        <%for (String value : dcMetadata) {%>
                        <%if (dcName.equals(value)) {%>
                        <textarea
                                class="form-control"
                                id="value_<%=key%>_<%= sequenceNumber %>"
                                name="value_<%= key%>_<%=sequenceNumber%>"
                                rows="3"
                                cols="50">
                                                         <%= dcv[i].value %>
                                                        </textarea>
                        <% } %>
                        <%}%>


                        <textarea
                                class="hide form-control"
                                id="value_<%=key%>_<%= sequenceNumber %>"
                                name="value_<%= key%>_<%=sequenceNumber%>"
                                rows="3"
                                cols="50">
                                                 <%= dcv[i].value %>
                                                </textarea>

                        <% } %>
                        <% } %>

                    </td>


                    <% if (isAdmin) {%>
                    <td headers="t4" class="<%= row %>RowOddCol">
                        <input class="form-control" type="text" name="language_<%= key %>_<%= sequenceNumber %>"
                               value="<%= (dcv[i].language == null ? "" : dcv[i].language.trim()) %>" size="5"/>
                    </td>
                    <% } %>

                    <%if (isAdmin) {%>
                    <td headers="t5" class="<%= row %>RowEvenCol">
                            <%-- <input type="submit" name="submit_remove_<%= key %>_<%= sequenceNumber %>" value="Remove" /> --%>
                        <button class="btn btn-danger" name="submit_remove_<%=key%>_<%= sequenceNumber %>"
                                value="<fmt:message key="jsp.tools.general.remove"/>">
                            <span class="glyphicon glyphicon-trash"></span>
                        </button>
                    </td>
                    <%}%>
                </tr>
                <% row = (row.equals("odd") ? "even" : "odd");
                } %>

                <% if (isAdmin) {%>
                <tr>
                    <td headers="t0" class="<%= row %>RowEvenCol">
                        <strong>
                            Novo Metadado:
                        </strong>
                    </td>
                    <td headers="t1" colspan="3" class="<%= row %>RowEvenCol">
                        <select class="form-control" name="addfield_dctype">
                            <% for (int i = 0; i < dcTypes.length; i++) {
                                Integer fieldID = new Integer(dcTypes[i].getFieldID());
                                String displayName = (String) metadataFields.get(fieldID);
                            %>
                            <option value="<%= fieldID.intValue() %>"><%= displayName %>
                            </option>
                            <% } %>
                        </select>
                    </td>
                    <td headers="t3" class="<%= row %>RowOddCol">
                        <textarea class="form-control" name="addfield_value" rows="3" cols="50"></textarea>
                    </td>

                    <td headers="t4" class="<%= row %>RowEvenCol">
                        <input class="form-control" type="text" name="addfield_language" size="5"/>
                    </td>

                    <td headers="t5" class="<%= row %>RowOddCol">
                            <%-- <input type="submit" name="submit_addfield" value="Add"> --%>
                        <button class="btn btn-default" name="submit_addfield"
                                value="<fmt:message key="jsp.tools.general.add"/>">
                            <span class="glyphicon glyphicon-plus"></span>
                        </button>
                    </td>

                </tr>
                <%} else if (isItemAdmin) {%>
                <tr>
                    <td headers="t0" class="<%= row %>RowEvenCol">
                        <strong>
                            Novo campo de:
                        </strong>
                    </td>
                    <td headers="t1" colspan="3" class="<%= row %>RowEvenCol">
                        <select id="addfield_dctype" class="form-control" name="addfield_dctype">
                            <% for (int i = 0; i < dcTypes.length; i++) {
                                Integer fieldID = new Integer(dcTypes[i].getFieldID());
                                String displayName = (String) metadataFields.get(fieldID);
                            %>
                            <%
                                if (displayName.equals("dc.language.iso")
                                        || displayName.equals("dc.subject")
                                        || displayName.equals("dc.contributor.author")
                                        || displayName.equals("dc.description.abstract")) {
                            %>
                            <option value="<%= fieldID.intValue() %>"><%=LocaleSupport.getLocalizedMessage(pageContext, displayName) %>
                            </option>
                            <%}%>

                            <%}%>
                        </select>

                        <div class="btn-group" id="areaFieldMetadata">

                        </div>

                        <button id="buttonAddField" class="btn btn-success" name="submit_addfield"
                                value="<fmt:message key="jsp.tools.general.add"/>">
                            <span class="glyphicon glyphicon-plus"></span>
                        </button>
                    </td>
                </tr>
                <%}%>
            </table>

        </div>

        <br/>

            <%-- <h2>Bitstreams</h2> --%>
        <h2><fmt:message key="jsp.tools.edit-item-form.heading"/></h2>

            <%-- <p>Note that if the "user format description" field isn't empty, the format will
            always be set to "Unknown", so clear the user format description before changing the
            format field.</p> --%>
        <p class="alert alert-warning"><fmt:message key="jsp.tools.edit-item-form.note3"/></p>
        <div class="table-responsive">
            <table id="bitstream-edit-form-table" class="table" summary="Bitstream data table">
                <tr>
                        <%-- <th class="oddRowEvenCol"><strong>Primary<br>Bitstream</strong></th>
                              <th class="oddRowOddCol"><strong>Name</strong></th>
                              <th class="oddRowEvenCol"><strong>Source</strong></th>
                              <th class="oddRowOddCol"><strong>Description</strong></th>
                              <th class="oddRowEvenCol"><strong>Format</strong></th>
                              <th class="oddRowOddCol"><strong>User&nbsp;Format&nbsp;Description</strong></th> --%>
                    <th id="t10" class="oddRowEvenCol">&nbsp;</th>

                    <th id="t11" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem5"/></strong></th>
                    <th id="t12" class="oddRowEvenCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem7"/></strong></th>

                    <%if (isAdmin) {%>

                    <th id="t13" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem8"/></strong></th>

                    <%} else {%>

                    <th id="t13" class="hide oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem8"/></strong></th>

                    <%}%>

                    <th id="t14" class="oddRowEvenCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem9"/></strong></th>

                    <%if (isAdmin) {%>

                    <th id="t15" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem10"/></strong></th>

                    <%} else {%>

                    <th id="t15" class="hide oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem10"/></strong></th>

                    <%}%>
                    <th id="t16" class="oddRowEvenCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem11"/></strong></th>

                    <th id="t17" class="oddRowOddCol"><strong><fmt:message
                            key="jsp.tools.edit-item-form.elem12"/></strong></th>
                    <th id="t18" class="oddRowEvenCol">&nbsp;</th>
                </tr>
                <%
                    Bundle[] bundles = item.getBundles();
                    row = "even";

                    for (int i = 0; i < bundles.length; i++) {
                        Bitstream[] bitstreams = bundles[i].getBitstreams();
                        for (int j = 0; j < bitstreams.length; j++) {
                            ArrayList<Integer> bitstreamIdOrder = new ArrayList<Integer>();
                            for (Bitstream bitstream : bitstreams) {
                                bitstreamIdOrder.add(bitstream.getID());
                            }

                            // Parameter names will include the bundle and bitstream ID
                            // e.g. "bitstream_14_18_desc" is the description of bitstream 18 in bundle 14
                            String key = bundles[i].getID() + "_" + bitstreams[j].getID();
                            BitstreamFormat bf = bitstreams[j].getFormat();
                %>
                <tr id="<%="row_" + bundles[i].getName() + "_" + bitstreams[j].getID()%>">
                    <td headers="t10" class="<%= row %>RowEvenCol" align="center">
                            <%-- <a target="_blank" href="<%= request.getContextPath() %>/retrieve/<%= bitstreams[j].getID() %>">View</a>&nbsp;<input type="submit" name="submit_delete_bitstream_<%= key %>" value="Remove"> --%>
                        <a class="btn btn-info" target="_blank"
                           href="<%= request.getContextPath() %>/retrieve/<%= bitstreams[j].getID() %>"><fmt:message
                                key="jsp.tools.general.download"/></a>&nbsp;
                    </td>
                    <% if (bundles[i].getName().equals("ORIGINAL")) { %>
                    <td headers="t11" class="<%= row %>RowEvenCol" align="center">
                       <span class="form-control">
                       <input type="radio" name="<%= bundles[i].getID() %>_primary_bitstream_id"
                              value="<%= bitstreams[j].getID() %>"
                               <% if (bundles[i].getPrimaryBitstreamID() == bitstreams[j].getID()) { %>
                              checked="<%="checked" %>"
                               <% } %> /></span>
                    </td>
                    <% } else { %>
                    <td headers="t11"></td>
                    <% } %>
                    <td headers="t12" class="<%= row %>RowOddCol">
                        <%if (!isAdmin) {%>
                        <span  name="bitstream_name_<%=key%>"><%=(bitstreams[j].getName() == null ? "" : Utils.addEntities(bitstreams[j].getName()))%></span>
                        <input class="hide form-control" type="text" name="bitstream_name_<%= key %>" value="<%= (bitstreams[j].getName() == null ? "" : Utils.addEntities(bitstreams[j].getName())) %>"/>
                            <%}else{%>
                        <input class="form-control" type="text" name="bitstream_name_<%= key %>" value="<%= (bitstreams[j].getName() == null ? "" : Utils.addEntities(bitstreams[j].getName())) %>"/>
                        <%}%>
                    </td>
                    <%if (!isAdmin) {%>
                    <td headers="t13" class="hide <%= row %>RowEvenCol">
                        <input class="form-control" type="text" name="bitstream_source_<%= key %>"
                               value="<%= (bitstreams[j].getSource() == null ? "" : bitstreams[j].getSource()) %>"/>
                    </td>
                    <%} else {%>
                    <td headers="t13" class="<%= row %>RowEvenCol">
                        <input class="form-control" type="text" name="bitstream_source_<%= key %>"
                               value="<%= (bitstreams[j].getSource() == null ? "" : bitstreams[j].getSource()) %>"/>
                    </td>
                    <%}%>
                    <td headers="t14" class="<%= row %>RowOddCol">
                        <input class="form-control" type="text" name="bitstream_description_<%= key %>"
                               value="<%= (bitstreams[j].getDescription() == null ? "" : Utils.addEntities(bitstreams[j].getDescription())) %>"/>
                    </td>

                    <%if (!isAdmin) {%>
                    <td headers="t15" class="hide <%= row %>RowEvenCol">
                        <input class="form-control" type="text" name="bitstream_format_id_<%= key %>"
                               value="<%= bf.getID() %>" size="4"/> (<%= Utils.addEntities(bf.getShortDescription()) %>)
                    </td>
                    <%} else {%>
                    <td headers="t15" class="<%= row %>RowEvenCol">
                        <input class="form-control" type="text" name="bitstream_format_id_<%= key %>"
                               value="<%= bf.getID() %>" size="4"/> (<%= Utils.addEntities(bf.getShortDescription()) %>)
                    </td>

                    <%}%>

                    <td headers="t16" class="<%= row %>RowOddCol">
                        <input class="form-control" type="text" name="bitstream_user_format_description_<%= key %>"
                               value="<%= (bitstreams[j].getUserFormatDescription() == null ? "" : Utils.addEntities(bitstreams[j].getUserFormatDescription())) %>"/>
                    </td>
                    <%
                        if (bundles[i].getName().equals("ORIGINAL") && breOrderBitstreams) {
                            //This strings are only used in case the user has javascript disabled
                            String upButtonValue = null;
                            String downButtonValue = null;
                            if (0 != j) {
                                ArrayList<Integer> temp = (ArrayList<Integer>) bitstreamIdOrder.clone();
                                //We don't have the first button, so create a value where the current bitstreamId moves one up
                                Integer tempInt = temp.get(j);
                                temp.set(j, temp.get(j - 1));
                                temp.set(j - 1, tempInt);
                                upButtonValue = StringUtils.join(temp.toArray(new Integer[temp.size()]), ",");
                            }
                            if (j < (bitstreams.length - 1)) {
                                //We don't have the first button, so create a value where the current bitstreamId moves one up
                                ArrayList<Integer> temp = (ArrayList<Integer>) bitstreamIdOrder.clone();
                                Integer tempInt = temp.get(j);
                                temp.set(j, temp.get(j + 1));
                                temp.set(j + 1, tempInt);
                                downButtonValue = StringUtils.join(temp.toArray(new Integer[temp.size()]), ",");
                            }


                    %>
                    <td headers="t17" class="<%= row %>RowEvenCol">
                        <input type="hidden" value="<%=j+1%>" name="order_<%=bitstreams[j].getID()%>">
                        <input type="hidden" value="<%=upButtonValue%>"
                               name="<%=bundles[i].getID()%>_<%=bitstreams[j].getID()%>_up_value">
                        <input type="hidden" value="<%=downButtonValue%>"
                               name="<%=bundles[i].getID()%>_<%=bitstreams[j].getID()%>_down_value">
                        <div>
                            <button class="btn btn-default" name="submit_order_<%=key%>_up"
                                    value="<fmt:message key="jsp.tools.edit-item-form.move-up"/> " <%=j == 0 ? "disabled=\"disabled\"" : ""%>>
                                <span class="glyphicon glyphicon-arrow-up"></span>
                            </button>
                        </div>
                        <div>
                            <button class="btn btn-default" name="submit_order_<%=key%>_down"
                                    value="<fmt:message key="jsp.tools.edit-item-form.move-down"/> " <%=j == (bitstreams.length - 1) ? "disabled=\"disabled\"" : ""%>>
                                <span class="glyphicon glyphicon-arrow-down"></span>
                            </button>
                        </div>
                    </td>

                    <%
                    } else {
                    %>
                    <td>
                        <%=j + 1%>
                    </td>
                    <%
                        }
                    %>
                    <td headers="t18" class="<%= row %>RowEvenCol">

                        <% if (bRemoveBits) {
                            if (isAdmin) {%>

                        <button class="btn btn-danger" name="submit_delete_bitstream_<%= key %>"
                                value="<fmt:message key="jsp.tools.general.remove"/>">
                            <span class="glyphicon glyphicon-trash"></span>
                        </button>


                        <%} else{%>
                        <% if(bitstreams[j].getName().contains("license")){%>

                        <%}else{%>

                        <span id="deleteFileOnEdit" class="ui red button" name="submit_delete_bitstream_<%=key%>"
                                value="<fmt:message key="jsp.tools.general.remove-material"/>">
                            <span>Excluir arquivo</span>
                            <span class="hide" id="nameFileToDelete"><%=(bitstreams[j].getName() == null ? "" : Utils.addEntities(bitstreams[j].getName()))%></span>
                        </span>
                        <%}%>
                        <%}%>
                        <%}%>
                    </td>
                </tr>
                <%
                            row = (row.equals("odd") ? "even" : "odd");
                        }
                    }
                %>
            </table>
        </div>


            <%-- <p align="center"><input type="submit" name="submit_addbitstream" value="Add Bitstream"></p> --%>
        <div class="btn-group col-md-12">
            <%
                if (bCreateBits) {
            %>
            <input class="btn btn-success col-md-2" type="submit" name="submit_addbitstream"
                   value="<fmt:message key="jsp.tools.edit-item-form.addbit.button"/>"/>
            <% }
                if (breOrderBitstreams) {
            %>
            <input class="hidden" type="submit" value="<fmt:message key="jsp.tools.edit-item-form.order-update"/>"
                   name="submit_update_order" style="visibility: hidden;">
            <%
                }

                if (ConfigurationManager.getBooleanProperty("webui.submit.enable-cc") && bccLicense) {
                    String s;
                    Bundle[] ccBundle = item.getBundles("CC-LICENSE");
                    s = ccBundle.length > 0 ? LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.edit-item-form.replacecc.button") : LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.edit-item-form.addcc.button");
            %>
            <input class="btn btn-warning col-md-3" type="submit" name="submit_addcc" value="<%= s  %>"/>
            <input type="hidden" name="handle" value="<%= ConfigurationManager.getProperty("handle.prefix") %>"/>
            <input type="hidden" name="item_id" value="<%= item.getID() %>"/>

            <%
                }
            %>


            <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
            <input type="hidden" name="action" value="<%= EditItemServlet.UPDATE_ITEM %>"/>

                <%-- <input type="submit" name="submit" value="Update" /> --%>
            <input class="btn btn-primary pull-right col-md-3" type="submit" name="submit"
                   value="<fmt:message key="jsp.tools.general.update"/>"/>
                <%-- <input type="submit" name="submit_cancel" value="Cancel" /> --%>
            <input class="btn btn-default pull-right col-md-3" type="submit" name="submit_cancel"
                   value="<fmt:message key="jsp.tools.general.cancel"/>"/>
        </div>

            <div id="deleteFileModal" class="ui mini modal" style="height: max-content; width:max-content;  margin: auto;">
                <div class="ui mini icon header">
                    <i class="trash icon"></i>
                    Deletar arquivo
                </div>
                <div class="content">
                    <p>Você deseja excluir o arquivo:<br/> <p id="fileNameRemove" style="font-weight: 700;"></p></p>
                </div>
                <div class="actions" style="text-align: -webkit-center;">
                    <div class="ui red mini cancel inverted button">
                        <i class="remove icon"></i>
                        Não
                    </div>
                        <button class="ui green mini ok inverted button" type="submit" id="submit_custom_delete" form="edit_metadata" name="submit_delete_">
                            <i class="checkmark icon"></i>
                            Sim
                        </button>
                </div>
            </div>


        <%--<span class="pull-right ui red button" id="testing">Testing</span>--%>
    </form>


    <script>
        jQuery(document).ready(function () {

            // jQuery('#edit_metadata').submit(function(e) {
            //     // e.preventDefault();
            //     var values = jQuery(this).serialize();
            // });

            jQuery("#buttonAddField").attr("disabled", true);
            formatOptions();
            configureModal();







            function configureModal(){
            jQuery("span#deleteFileOnEdit").click(function() {
                var deleteFileNameBitstream = jQuery(this).children('#nameFileToDelete').text();
                var deleteBitstreamsName = jQuery(this).attr('name');


                jQuery('#deleteFileModal').modal('show');
                jQuery("#submit_custom_delete").attr('name',deleteBitstreamsName);
                jQuery("#fileNameRemove").text(deleteFileNameBitstream);
            });
            }




            function disableButton() {
                jQuery('#areaFieldMetadata input, #areaFieldMetadata textarea').on('change', function () {
                    var values;
                    var textArea = jQuery('#areaFieldMetadata textarea').val();
                    var input = jQuery('#areaFieldMetadata input').val();

                    if (textArea != null) {
                        values = textArea.length;
                    } else if (input != null) {
                        values = input.length;
                    }
                    if (values > 0) {
                        jQuery("#buttonAddField").attr("disabled", false);
                    } else {
                        jQuery("#buttonAddField").attr("disabled", true);
                    }
                });
            }

            function formatOptions() {
                formatLangs();

                jQuery('select#addfield_dctype').on('change', function () {
                    var id = this.value;
                    if (id == 3) {
                        jQuery("#areaFieldMetadata").empty();
                        returnInput();
                        disableButton();

                    } else if (id == 27) {
                        jQuery("#areaFieldMetadata").empty();
                        returnTextArea();
                        disableButton();

                    } else if (id == 38) {
                        jQuery("#areaFieldMetadata").empty();
                        returnLanguageSelect();


                    } else if (id == 57) {
                        jQuery("#areaFieldMetadata").empty();
                        returnInput();
                        disableButton();


                    }
                });
            }

            function returnTextArea() {
                jQuery("#areaFieldMetadata").prepend("<textarea class='form-control' name='addfield_value' rows='3' ></textarea>");
                jQuery("#buttonAddField").attr("disabled", true);
            }

            function returnInput() {
                jQuery("#areaFieldMetadata").prepend("<input class='form-control' name='addfield_value'>");
                jQuery("#buttonAddField").attr("disabled", true);
            }

            function returnLanguageSelect() {
                jQuery("#buttonAddField").attr("disabled", false);
                var data = [
                    {
                        languages: [
                            {field: 'Portugues (Brasil)', value: 'pt_BR'},
                            {field: 'Inglês', value: 'en'},
                            {field: 'Inglês (Estados Unidos)', value: 'en_US'},
                            {field: 'Francês', value: 'fr'},
                            {field: 'Chinês', value: 'zh'},
                            {field: 'Espanhol', value: 'es'},
                            {field: 'Alemão', value: 'de'},
                            {field: 'Japonês', value: 'ja'},
                            {field: 'Português (Portugal)', value: 'pt'},
                            {field: 'Italiano', value: 'it'}
                        ]
                    }
                ];
                data.forEach(function (outerObj) {
                    Object.keys(outerObj).forEach(function (key) {
                        jQuery("#areaFieldMetadata").prepend("<select name='addfield_value'></select>");
                        outerObj[key].forEach(function (item) {
                            jQuery("#areaFieldMetadata select").prepend("<option value='" + item.value + "'>" + item.field + "</option>");
                            // console.log(item.field , item.value);
                        });
                    });
                });
            }

            function  formatLangs() {
                jQuery('div#lang select option').each(function(ii, options) {
                    var idiomas = [
                        {"id":"pt_BR","value": "Português (Brasil)"},
                        {"id":"pt","value": "Português"},
                        {"id":"en","value": "Inglês"},
                        {"id":"en_US","value": "Inglês (Estados Unidos)"},
                        {"id":"fr","value": "Francês"},
                        {"id":"zh","value": "Chinês"},
                        {"id":"es","value": "Espanhol"},
                        {"id":"de","value": "Alemão"},
                        {"id":"ja","value": "Japonês"},
                        {"id":"it","value": "Italiano"}
                    ];
                    // var optionsText = jQuery(this).text();
                    var optionsObject = jQuery(this);

                    // console.log(metadadoLangVal);
                    jQuery.each(idiomas, function(i) {
                        // console.log(idiomas[i].id.toLowerCase() === optionsObject.val().toLowerCase(),idiomas[i].id,optionsObject.val());
                        // console.log(metadadoLangVal == idiomas[i].id);
                        if (idiomas[i].id.toLowerCase() === optionsObject.val().toLowerCase()){
                            optionsObject.text(idiomas[i].value);
                        }
                    });
                });
            }

        });
    </script>
</dspace:layout>
