<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Renders a whole HTML page for displaying item metadata.  Simply includes
  - the relevant item display component in a standard HTML page.
  -
  - Attributes:
  -    display.all - Boolean - if true, display full metadata record
  -    item        - the Item to display
  -    collections - Array of Collections this item appears in.  This must be
  -                  passed in for two reasons: 1) item.getCollections() could
  -                  fail, and we're already committed to JSP display, and
  -                  2) the item might be in the process of being submitted and
  -                  a mapping between the item and collection might not
  -                  appear yet.  If this is omitted, the item display won't
  -                  display any collections.
  -    admin_button - Boolean, show admin 'edit' button
--%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Bundle" %>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.handle.HandleManager" %>
<%@ page import="org.dspace.license.CreativeCommons" %>
<%@page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@page import="org.dspace.versioning.Version" %>
<%@page import="org.dspace.core.Context" %>
<%@page import="org.dspace.app.webui.util.VersionUtil" %>
<%@page import="org.dspace.app.webui.util.UIUtil" %>
<%@page import="org.dspace.authorize.AuthorizeManager" %>
<%@page import="java.util.List" %>
<%@page import="org.dspace.core.Constants" %>
<%@page import="org.dspace.eperson.EPerson" %>
<%@page import="org.dspace.versioning.VersionHistory" %>
<%@page import="br.com.capes.video.VideoUtils" %>


<%

    //Validate if user can edit
    String authmail = "";
    String submittermail = "";
    boolean canEditContent = false;

    // Attributes
    Boolean admin = (Boolean) request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    EPerson user = (EPerson) request.getAttribute("dspace.current.user");
    Boolean displayAllBoolean = (Boolean) request.getAttribute("display.all");
    boolean displayAll = (displayAllBoolean != null && displayAllBoolean.booleanValue());
    Boolean suggest = (Boolean) request.getAttribute("suggest.enable");
    boolean suggestLink = (suggest == null ? false : suggest.booleanValue());
    Item item = (Item) request.getAttribute("item");

    // get email submitter of item submitted
    if (item.getSubmitter() != null) {
        submittermail = item.getSubmitter().getEmail();

    } else {
        submittermail = "";
    }



    Collection[] collections = (Collection[]) request.getAttribute("collections");
    Boolean admin_b = (Boolean) request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    String userd = "" + request.getAttribute("dspace.current.user");
    // get the workspace id if one has been passed
    Integer workspace_id = (Integer) request.getAttribute("workspace_id");

    // get the handle if the item has one yet
    String handle = item.getHandle();

    // CC URL & RDF
    String cc_url = "";
    String cc_rdf = "";
    try{
        cc_url= CreativeCommons.getLicenseURL(item);
        cc_rdf= CreativeCommons.getLicenseRDF(item);
    }catch (Exception e){

    }

    // Full title needs to be put into a string to use as tag argument
    String title = "";
    if (handle == null) {
        title = "Workspace Item";
    } else {
        Metadatum[] titleValue = item.getDC("title", null, Item.ANY);
        if (titleValue.length != 0) {
            title = titleValue[0].value;
        } else {
            title = "Item " + handle;
        }
    }

    //If user auth can edit your item
    if (user != null) {
        authmail = user.getEmail();
    } else {

        authmail = "";
    }

    if (authmail.matches(submittermail)) {

        canEditContent = true;

    }


    Boolean versioningEnabledBool = (Boolean) request.getAttribute("versioning.enabled");
    boolean versioningEnabled = (versioningEnabledBool != null && versioningEnabledBool.booleanValue());
    Boolean hasVersionButtonBool = (Boolean) request.getAttribute("versioning.hasversionbutton");

    Boolean hasVersionHistoryBool = (Boolean) request.getAttribute("versioning.hasversionhistory");
    boolean hasVersionButton = (hasVersionButtonBool != null && hasVersionButtonBool.booleanValue());
    boolean hasVersionHistory = (hasVersionHistoryBool != null && hasVersionHistoryBool.booleanValue());

    Boolean newversionavailableBool = (Boolean) request.getAttribute("versioning.newversionavailable");
    boolean newVersionAvailable = (newversionavailableBool != null && newversionavailableBool.booleanValue());
    Boolean showVersionWorkflowAvailableBool = (Boolean) request.getAttribute("versioning.showversionwfavailable");

    boolean showVersionWorkflowAvailable = (showVersionWorkflowAvailableBool != null && showVersionWorkflowAvailableBool.booleanValue());
    String latestVersionHandle = (String) request.getAttribute("versioning.latestversionhandle");
    String latestVersionURL = (String) request.getAttribute("versioning.latestversionurl");

    VersionHistory history = (VersionHistory) request.getAttribute("versioning.history");
    List<Version> historyVersions = (List<Version>) request.getAttribute("versioning.historyversions");
    Bundle[] thumbs = item.getBundles("THUMBNAIL");

    //String subers = item.getSubmitter().getEmail();

%>

<%@page import="org.dspace.app.webui.servlet.MyDSpaceServlet" %>
<dspace:layout title="<%=title%>">


    <style>
        .table .table-responsive .table-hover{

        }

        .table.itemDisplayTable thead > tr > th,
        .table.itemDisplayTable tbody > tr > th,
        .table.itemDisplayTable tfoot > tr > th,
        .table.itemDisplayTable thead > tr > td,
        .table.itemDisplayTable tbody > tr > td,
        .table.itemDisplayTable tfoot > tr > td {

            padding: 12px;
            line-height: 2.528571;
            vertical-align: middle;
            /*border-top: 10px solid white;*/
            border-bottom: 7px solid white;
            background: #e5e5e5;
        }
        td#dccontributor.metadataFieldValue div{
            overflow: hidden;
            overflow-y: auto;
            max-height: 200px;
        }
        td#dcsubject.metadataFieldValue{
            line-height: 1;
        }

        .table.itemDisplayTable tbody > tr{
            border-left: 7px solid white;
            border-right: 7px solid white;
        }

        .metadataFieldLabel {
            width: 200px;
            height: 25px;
            margin-bottom: 0px;
            color: #444070;
            margin-left: 99px;
        }

        .table.itemDisplayTable tbody tr td.metadataFieldValue a{
            color: #58a987;
        }
        .table.itemDisplayTable tbody tr td.metadataFieldValue a:hover{
            text-decoration: underline;
        }
        .table.itemDisplayTable tbody tr td.metadataFieldValue a.btn{
            color: white;
        }

        .video-0-dimensions {
            width: 640px;
            height: 350px;
        }

        .video-0-dimensions.vjs-fluid {
            /*padding-top: 5.25%;*/
        }

        .video-js .vjs-tech {
            position: relative;
            /* top: 0; */
            /* left: 40px; */
            /* width: 100%; */
            /* height: 100%; */
        }
    </style>


    <script>


        var nameDialog = null;

        function OpenInNewTabWinBrowser(url) {

            var win = window.open(url, '_blank');
            win.focus();
        }

        var configuration = ({
            afterClose: function (event) {
                if (getCookie('capes-download-term-accepted') == 'accepted') {

                    var test = $("#callerUrl").val();

                    OpenInNewTabWinBrowser(test);

//                    window.location = $("#callerUrl").val();


                    setCookie('capes-download-term-accepted', 'undefined', 30);
                }
            }
        });

        function formatDcCreator(){
            var test = $("#dccontributor").html() +  "<br/>" +$("#dccreator").html();
            if($("#dccreator").html() != undefined){
                $("#dccontributor").html(test);
            }
        }

        $(document).ready(function () {
          formatDcCreator();



            $("#itemFilesList").find("a").click(function (event) {
                var downloadChoice = getCookie('capes-download-term-accepted');
                if (downloadChoice == undefined || downloadChoice != 'accepted') {
                    event.preventDefault();
                    $("#callerUrl").val($(this).attr('href'));
                    $.featherlight($("#download-term"), configuration);
                }
            });


            $('#submit-term-option').click(function () {
                if ($("input[name='download-term-option']:checked").val() == 'true') {
                    setCookie('capes-download-term-accepted', 'accepted', 30);
                }

                $.featherlight.current().close();
            });

            $('#submiteva').click(function (event) {
                var vuser = '<%= request.getAttribute("dspace.current.user") %>';
                var vitemid = document.getElementById('item_id').value;


                if (document.getElementById('grade1').checked) {
                    var vgrade = 1;
                } else if (document.getElementById('grade2').checked) {
                    var vgrade = 2;
                } else if (document.getElementById('grade3').checked) {
                    var vgrade = 3;
                } else if (document.getElementById('grade4').checked) {
                    var vgrade = 4;
                } else if (document.getElementById('grade5').checked) {
                    var vgrade = 5;
                } else {
                    alert('Escolha uma nota!');
                }

                $.ajax({
                    url: '<%= request.getContextPath() %>/evaluation-insert',
                    data: {'grade': vgrade, 'item_id': vitemid},
                    success: function (responseText) {
                        $('#response-evaluation').text(responseText);
                    }
                });
            });


            $('#popup').click(function (event) {

                event.preventDefault();


                if (!nameDialog) // First time...
                    nameDialog = $.featherlight($("#popupContact"), {'persist': true});
                else // After that...
                    nameDialog.open();


            });


            $('#send-denun').click(function () {
                if (document.getElementById('msg-d').value == "") {
                    alert("O campo motivo é obrigatório!");
                } else {

                    var vname = document.getElementById('name-d').value;
                    var vemail = document.getElementById('email-d').value;
                    var vmsg = document.getElementById('msg-d').value;
                    var vitemid = document.getElementById('item_id1').value;
                    $.ajax({
                        url: '<%= request.getContextPath() %>/evaluation-insert',
                        data: {'vname': vname, 'vemail': vemail, 'vmsg': vmsg, 'vitemid': vitemid},
                        success: function (responseText) {
                            $('#response-evaluation').text(responseText);
                        }
                    });
                    /*document.getElementById('abc').style.display = "none";*/
                    $.featherlight.current().close();
                    alert("Denuncia enviada com sucesso...");
                }
            });
        });


    </script>

    <div class="wrap">
        <div class="row detalhe-item">

    <div class="hidden">
        <div id="popupContact">
            <input type="hidden" id="item_id1" name="item_id1" value="<%= item.getID() %>"/>
            <h3 align="center"><fmt:message key="jsp.display-item.report.popup.title"/></h3>
            <p class="reportFormTip"><fmt:message key="jsp.display-item.report.popup.hint"/></p>
            <hr>

            <div class="form-group">
                <label for="name-d"><fmt:message key="jsp.display-item.report.popup.field.name"/></label>
                <input class="form-control" id="name-d" name="name-d" placeholder="Nome" type="text"></br>
            </div>

            <div class="form-group">
                <label for="email-d"><fmt:message key="jsp.display-item.report.popup.field.email"/></label>
                <input class="form-control" id="email-d" name="email-d" placeholder="E-mail" type="email"></br>
            </div>

            <textarea rows="5" cols="50" align="center" id="msg-d" name="msg-d"
                      placeholder="Motivo da denuncia..."></textarea></br></br>

            <!--   <input align="center" class="btn btn-lg btn-info" type="button" name="send-denun" id="send-denun" value="Denunciar"/> -->

            <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/captcha.css">
            <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/font-awesome.min.css">
            <link rel="stylesheet" href="<%= request.getContextPath()%>/static/lib/jquery.raty.css">
            <%--<link rel='stylesheet prefetch' href='https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css'>--%>


            <label class="submit__control">

                <h3 align="center"> Você é humano?</h3>

                <div align="center" class="submit__generated">

                </div>

                <i class="fa fa-refresh"></i>

                <span class="submit__error hide">Valor incorreto!</span>

                <span class="submit__error--empty hide">Campo obrigatório, é necessário <br/> responder para prosseguir.</span>

            </label>

            <div align="center">

                <input class="submit overlay" type="button" name="send-denun" id="send-denun" value="Denunciar"/>

            </div>

            <div align="center" class="submit__overlay"></div>
            <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/captcha.js"></script>
        </div>

    </div>


    <%
        boolean isFirstVideo = true;
        int videoCounter = 0;
        for (Bundle bundleAtual : item.getBundles()) {
            for (Bitstream bitstreamAtual : bundleAtual.getBitstreams()) {
                String bitstreamName = bitstreamAtual.getName().trim();
                if (VideoUtils.isBitstreamDisplayable(bitstreamName)) {

                    String thumbnailLink = "";
                    if (thumbs.length > 0) {
                        String tName = bitstreamName + VideoUtils.THUMBNAIL_EXTENSION;
                        Bitstream tb = thumbs[0].getBitstreamByName(tName);

                        if (tb != null) {
                            thumbnailLink = request.getContextPath() + "/retrieve/" + tb.getID() + "/" + UIUtil.encodeBitstreamName(tb.getName(), Constants.DEFAULT_ENCODING);
                        }
                    }

                    if (isFirstVideo) {
    %>
    <section class="video-section" id="video-section">

        <%
            }
            String bsLink = "https://"+request.getServerName() + "/" + "rest";

            if (request.getServerName().contains("localhost")){
                      bsLink = "https://"+ request.getServerName()+":8443/" + "rest";
            }

            if ((handle != null)
                    && (bitstreamAtual.getSequenceID() > 0)) {
//                bsLink = bsLink + "/bitstreams/" + bitstreamAtual.getID() + "/" + bitstreamAtual.getSequenceID() + "/";
                bsLink = bsLink + "/bitstreams/" + bitstreamAtual.getID() + "/";
            } else {
                bsLink = bsLink + "/retrieve/" + bitstreamAtual.getID() + "/";
            }

//            bsLink = bsLink + UIUtil.encodeBitstreamName(bitstreamAtual.getName(), Constants.DEFAULT_ENCODING);
            bsLink = bsLink + "retrieve";
        %>
        <div class="area-video">
            <h6><fmt:message key="jsp.submit.change-file-description.file"/>: <%= bitstreamAtual.getName()%>
            </h6>
            <video id="video-<%= videoCounter%>" class="video-js" controls preload="auto" poster="<%= thumbnailLink%>"
                   data-setup="{}">
                <source src="<%= bsLink%>" type="<%= bitstreamAtual.getFormat().getMIMEType()%>">
                <p class="vjs-no-js">To view this video please enable JavaScript, and consider upgrading to a web
                    browser that
                    <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a></p>
            </video>
        </div>
        <%
                        videoCounter++;
                        isFirstVideo = false;
                    }
                }
            }
        %>

        <%
            if (videoCounter > 0) {
        %>
    </section>
    <%
        }
    %>


    <%
        if (handle != null) {
            if (newVersionAvailable) {
    %>
    <div class="alert alert-warning"><b><fmt:message key="jsp.version.notice.new_version_head"/></b>
        <fmt:message key="jsp.version.notice.new_version_help"/><a
                href="<%=latestVersionURL%>"><%= latestVersionHandle%>
        </a>
    </div>
    <%
        }
    %>

    <%
        if (showVersionWorkflowAvailable) {
    %>
    <div class="alert alert-warning"><b><fmt:message key="jsp.version.notice.workflow_version_head"/></b>
        <fmt:message key="jsp.version.notice.workflow_version_help"/>
    </div>
    <%
        }
    %>


    <%-- <strong>Please use this identifier to cite or link to this item:
    <code><%= HandleManager.getCanonicalForm(handle) %></code></strong>--%>

            <h2><%=title%></h2>
    <div class="link-citacao">
        <fmt:message key="jsp.display-item.identifier"/> <span><%= HandleManager.getCanonicalForm(handle)%></span>
    </div>
    <%
        }

        String displayStyle = (displayAll ? "full" : "");
    %>
    <dspace:item-preview item="<%= item%>"/>

          <dspace:item item="<%= item%>" collections="<%= collections%>" style="<%= displayStyle%>"/>

    <div class="hidden">
        <div id="download-term">
            <dspace:include page="/static/pages/download-term.jsp"/>
            <div>
                <input type="hidden" id="callerUrl" name="callerUrl"
                       value="<%= HandleManager.getCanonicalForm(handle)%>"/>
                <input type="radio" name="download-term-option" value="true"> <fmt:message
                    key="jsp.display-item.download.option.agree"/><br>
                <input type="radio" name="download-term-option" value="false"> <fmt:message
                    key="jsp.display-item.download.option.deny"/><br>
                <button class="btn btn-primary" type="button" id="submit-term-option"><fmt:message
                        key="jsp.display-item.download.button"/></button>
            </div>
        </div>
    </div>
    <div class="acoes">
        <%
            String locationLink = request.getContextPath() + "/handle/" + handle;

            if (displayAll) {
        %>
        <%
            if (workspace_id != null) {
        %>
        <form class="col-md-2" method="post" action="<%= request.getContextPath()%>/view-workspaceitem">
            <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue()%>"/>
            <input class="btn btn-default" type="submit" name="submit_simple"
                   value="<fmt:message key="jsp.display-item.text1"/>"/>
        </form>
        <%
        } else {
        %>
        <a class="registro-item" href="<%=locationLink%>?mode=simple">
            <fmt:message key="jsp.display-item.text1"/>
        </a>
        <%
            }
        %>
        <%
        } else {
        %>
        <%
            if (workspace_id != null) {
        %>
        <form class="col-md-2" method="post" action="<%= request.getContextPath()%>/view-workspaceitem">
            <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue()%>"/>
            <input class="btn btn-default" type="submit" name="submit_full"
                   value="<fmt:message key="jsp.display-item.text2"/>"/>
        </form>
        <%
        } else {
        %>
        <a class="registro-item" href="<%=locationLink%>?mode=full">
            <span class="glyphicon glyphicon-file"></span>
            <fmt:message key="jsp.display-item.text2"/>
        </a>
        <%
                }
            }

            if (workspace_id != null) {
        %>
        <form class="col-md-2" method="post" action="<%= request.getContextPath()%>/workspace">
            <input type="hidden" name="workspace_id" value="<%= workspace_id.intValue()%>"/>
            <input class="btn btn-primary" type="submit" name="submit_open"
                   value="<fmt:message key="jsp.display-item.back_to_workspace"/>"/>
        </form>
        <%
        } else {

            if (suggestLink) {
        %>
        <a class="btn btn-success" href="<%= request.getContextPath()%>/suggest?handle=<%= handle%>"
           target="new_window">
            <fmt:message key="jsp.display-item.suggest"/></a>
        <%
            }
        %>

        <a class="estatisticas" href="<%= request.getContextPath()%>/handle/<%= handle%>/statistics">
            <span class="fa fa-line-chart"></span>
            <fmt:message key="jsp.display-item.display-statistics"/></a>

        <div class="avaliacao">
            <form id=eva1>
                <input type="hidden" id="item_id" name="item_id" value="<%= item.getID() %>"/>
                <p>Avaliação</p>
                <div id="raty2" data-score="<%= item.getItemEvaluation() %>"></div>
                <span class="evalSuccessMsg"><div id="response-evaluation"></div></span>
            </form>
        </div>

        <button id="popup" class="denunciar">Denunciar conteúdo</button>

            <%-- SFX Link --%>
        <%
            if (ConfigurationManager.getProperty("sfx.server.url") != null) {
                String sfximage = ConfigurationManager.getProperty("sfx.server.image_url");
                if (sfximage == null) {
                    sfximage = request.getContextPath() + "/image/sfx-link.gif";
                }
        %>
        <a class="btn btn-default" href="<dspace:sfxlink item="<%= item%>"/>"/><img src="<%= sfximage%>" border="0"
                                                                                    alt="SFX Query"/></a>
        <%
                }
            }
        %>
    </div>
    <br/>
    <%-- Versioning table --%>
    <%
        if (versioningEnabled && hasVersionHistory) {
            boolean item_history_view_admin = ConfigurationManager
                    .getBooleanProperty("versioning", "item.history.view.admin");
            if (!item_history_view_admin || admin_button) {
    %>
    <div id="versionHistory" class="panel panel-info">
        <div class="panel-heading"><fmt:message key="jsp.version.history.head2"/></div>

        <table class="table panel-body">
            <tr>
                <th id="tt1" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column1"/></th>
                <th
                        id="tt2" class="oddRowOddCol"><fmt:message key="jsp.version.history.column2"/></th>
                <th
                        id="tt3" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column3"/></th>
                <th

                        id="tt4" class="oddRowOddCol"><fmt:message key="jsp.version.history.column4"/></th>
                <th
                        id="tt5" class="oddRowEvenCol"><fmt:message key="jsp.version.history.column5"/></th>
            </tr>

            <% for (Version versRow : historyVersions) {

                EPerson versRowPerson = versRow.getEperson();
                String[] identifierPath = VersionUtil.addItemIdentifier(item, versRow);
            %>
            <tr>
                <td headers="tt1" class="oddRowEvenCol"><%= versRow.getVersionNumber()%>
                </td>
                <td headers="tt2" class="oddRowOddCol"><a
                        href="<%= request.getContextPath() + identifierPath[0]%>"><%= identifierPath[1]%>
                </a><%= item.getID() == versRow.getItemID() ? "<span class=\"glyphicon glyphicon-asterisk\"></span>" : ""%>
                </td>
                <td headers="tt3" class="oddRowEvenCol"><% if (admin_button) {%><a
                        href="mailto:<%= versRowPerson.getEmail()%>"><%=versRowPerson.getFullName()%>
                </a><% } else {%><%=versRowPerson.getFullName()%><% }%></td>
                <td headers="tt4" class="oddRowOddCol"><%= versRow.getVersionDate()%>
                </td>
                <td headers="tt5" class="oddRowEvenCol"><%= versRow.getSummary()%>
                </td>
            </tr>

            <% } %>
        </table>
        <div class="panel-footer"><fmt:message key="jsp.version.history.legend"/></div>
    </div>
    <%
            }
        }
    %>
    <!--Test user admin-->
    <%--<%= "Editor: " + authmail%><br/>--%>
    <%--<%= "É super admin?: " + isAdmin%><br/>--%>

    <%--<%="Submissor: " + submittermail %><br/>--%>
    <%--<%="Condição: " + canEditContent%><br/>--%>

    <%-- Create Commons Link --%>
    <%
        if (cc_url != null) {
    %>
    <p class="submitFormHelp alert alert-info"><fmt:message key="jsp.display-item.text3"/>
        <a href="<%= cc_url%>"><fmt:message key="jsp.display-item.license"/></a>
        <a href="<%= cc_url%>"><img src="<%= request.getContextPath()%>/image/cc-somerights.gif" border="0" alt="Creative Commons" style="margin-top: -5px; width: auto;" class="pull-right"/></a>
    </p>
    <!--
    <%= cc_rdf%>
    -->
    <%
    } else {
    %>
    <!--<p class="submitFormHelp alert alert-info"><fmt:message key="jsp.display-item.copyright"/></p>-->
    <%
        }
    %>
    <%
        if (admin_button) // admin edit button
        {%>
    <dspace:sidebar>

        <nav>
            <h2><fmt:message key="jsp.admintools"/></h2>
            <ul>
                <%if (canEditContent || isAdmin) {%>

                <li>
                    <form method="get" action="<%= request.getContextPath()%>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID()%>"/>
                            <%--<input type="submit" name="submit" value="Edit...">--%>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.general.edit.button"/>"/>
                    </form>
                </li>
                <% } %>

                <%if (isAdmin) {%>
                <li>
                    <form method="post" action="<%= request.getContextPath()%>/mydspace">
                        <input type="hidden" name="item_id" value="<%= item.getID()%>"/>
                        <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_EXPORT_ARCHIVE%>"/>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.mydspace.request.export.item"/>"/>
                    </form>
                </li>
                <li>
                    <form method="post" action="<%= request.getContextPath()%>/mydspace">
                        <input type="hidden" name="item_id" value="<%= item.getID()%>"/>
                        <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_MIGRATE_ARCHIVE%>"/>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.mydspace.request.export.migrateitem"/>"/>
                    </form>
                </li>
                <li>
                    <form method="post" action="<%= request.getContextPath()%>/dspace-admin/metadataexport">
                        <input type="hidden" name="handle" value="<%= item.getHandle()%>"/>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.general.metadataexport.button"/>"/>
                    </form>
                </li>
                <% if (hasVersionButton) {%>
                <li>
                    <form method="get" action="<%= request.getContextPath()%>/tools/version">
                        <input type="hidden" name="itemID" value="<%= item.getID()%>"/>
                        <input class="btn btn-default col-md-12" type="submit" name="submit"
                               value="<fmt:message key="jsp.general.version.button"/>"/>
                    </form>
                </li>
                <% } %>
                <% } %>
                <% if (hasVersionHistory) {%>
                <form method="get" action="<%= request.getContextPath()%>/tools/history">
                    <input type="hidden" name="itemID" value="<%= item.getID()%>"/>
                    <input type="hidden" name="versionID"
                           value="<%= history.getVersion(item) != null ? history.getVersion(item).getVersionId() : null%>"/>
                    <input class="btn btn-info col-md-12" type="submit" name="submit"
                           value="<fmt:message key="jsp.general.version.history.button"/>"/>
                </form>
                <% } %>
            </ul>
        </nav>

    </dspace:sidebar>

    <% } else if (canEditContent) {%>
    <dspace:sidebar>
        <ul>
            <li>
                <form method="get" action="<%= request.getContextPath()%>/tools/edit-item">
                    <input type="hidden" name="item_id" value="<%= item.getID()%>"/>
                        <%--<input type="submit" name="submit" value="Edit...">--%>
                    <input class="btn btn-default col-md-12" type="submit" name="submit"
                           value="<fmt:message key="jsp.general.edit.button"/>"/>
                </form>
            </li>
        </ul>

    </dspace:sidebar>

    <% }%>
    <script type='text/javascript' src="<%= request.getContextPath()%>/video-player/videojs/dist/video.min.js"></script>
    <script src="<%= request.getContextPath()%>/featherlight-1.5.0/release/featherlight.min.js" type="text/javascript"
            charset="utf-8"></script>

    <script>
        $.fn.raty.defaults.path = '<%= request.getContextPath()%>/static/lib/images';
        $(function () {
            $('#raty1').raty();

            $('#raty2').raty({
                click: function (score, evt) {


                    var vuser = '<%= request.getAttribute("dspace.current.user") %>';
                    var vitemid = document.getElementById('item_id').value;

                    $.ajax({
                        url: '<%= request.getContextPath() %>/evaluation-insert',
                        data: {'grade': score, 'item_id': vitemid},
                        success: function (responseText) {
                            $('#response-evaluation').text(responseText);
                        }
                    });
                },
                score: function () {
                    return $(this).attr('data-score');
                }
            });

        });

        //        $('#submitBtn').click(function() {
        //            /* when the button in the form, display the entered values in the modal */
        //            $('#lname').text($('#lastname').val());
        //            $('#fname').text($('#firstname').val());
        //        });
        //
        //        $('#submit').click(function(){
        //            /* when the submit button in the modal is clicked, submit the form */
        //            alert('submitting');
        //            $('#formfield').submit();
        ////            $('#').
        //
        //        });
        //
        //        $('#submit').onclick(function(){
        //            /* when the submit button in the modal is clicked, submit the form */
        //            $('#modall').modal.('hide');
        //
        //        });

        //        $('#submit').submit(function(e) {
        //            e.preventDefault();
        //            // Coding
        //            $('#modall').modal('toggle'); //or  $('#IDModal').modal('hide');
        //            return false;
        //        });
    </script>
        </div>
    </div>

</dspace:layout>