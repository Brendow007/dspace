<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - HTML header for main home page
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.util.Util" %>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.authorize.AuthorizeManager" %>

<%
    String title = (String) request.getAttribute("dspace.layout.title");
    String navbar = (String) request.getAttribute("dspace.layout.navbar");
    boolean locbar = ((Boolean) request.getAttribute("dspace.layout.locbar")).booleanValue();

    String siteName = ConfigurationManager.getProperty("dspace.name");
    String feedRef = (String) request.getAttribute("dspace.layout.feedref");
    boolean osLink = ConfigurationManager.getBooleanProperty("websvc.opensearch.autolink");
    String osCtx = ConfigurationManager.getProperty("websvc.opensearch.svccontext");
    String osName = ConfigurationManager.getProperty("websvc.opensearch.shortname");
    List parts = (List) request.getAttribute("dspace.layout.linkparts");
    String extraHeadData = (String) request.getAttribute("dspace.layout.head");
    String extraHeadDataLast = (String) request.getAttribute("dspace.layout.head.last");
    String dsVersion = Util.getSourceVersion();
    String generator = dsVersion == null ? "DSpace" : "DSpace " + dsVersion;
    String analyticsKey = ConfigurationManager.getProperty("jspui.google.analytics.key");

    String preferedCss = "capes_sem_contraste.css";
    Cookie[] cookies = request.getCookies();
    if( cookies != null ){
       for (int i = 0; i < cookies.length; i++){
               if(cookies[i].getName().equals("acessibilidade_capes_contraste")){
                       if(cookies[i].getValue().equals("high")){
                               preferedCss = "capes_contraste.css";
                       }
                       break;
               }
       }
    }

    String cssContraste = request.getContextPath() + "/static/css/" + preferedCss;

    // Is the logged in user an admin
    Boolean admin = (Boolean) request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    Context context = UIUtil.obtainContext(request);
    boolean isSystemAdmin = AuthorizeManager.isAdmin(context);

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf('?');
    if (c > -1) {
        currentPage = currentPage.substring(0, c);
    }



    // get the browse indices
    BrowseIndex[] bis = BrowseIndex.getBrowseIndices();
    BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
    String browseCurrent = "";
    if (binfo != null) {
        BrowseIndex bix = binfo.getBrowseIndex();
        // Only highlight the current browse, only if it is a metadata index,
        // or the selected sort option is the default for the index
        if (bix.isMetadataIndex() || bix.getSortOption() == binfo.getSortOption()) {
            if (bix.getName() != null) {
                browseCurrent = bix.getName();
            }
        }
    }
%>




<!DOCTYPE html>
<html>
    <head>

        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
        <!--cache-->
        <meta http-equiv="cache-control" content="max-age=0">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="expires" content="0">
        <meta http-equiv="expires" content="Tue, 01 Jan 2980 1:00:00 GMT">
        <meta http-equiv="pragma" content="no-cache">
        <!--cache-->
        <!-- barra do governo-->
        <%--<meta property="creator.productor" content="http://estruturaorganizacional.dados.gov.br/id/unidade-organizacional/250">--%>
        <%--<link rel="stylesheet" href="http://fonts.googleapis.com/css?family=PT+Sans:400,400italic,700,700italic" type="text/css">--%>
        <%--<link rel="stylesheet" href="styles/bootstrap.css">--%>

        <title><%= siteName%>: <%= title%></title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="Generator" content="<%= generator%>" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="shortcut icon" href="<%= request.getContextPath()%>/favicon.ico" type="image/x-icon"/>
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/jquery-ui-1.10.3.custom/redmond/jquery-ui-1.10.3.custom.css" type="text/css" />
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/bootstrap/bootstrap.css" type="text/css" />
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/app.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/semantic.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/template.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/video-player/videojs/dist/video-js.min.css" type="text/css" />
        <link rel="stylesheet" href="<%= request.getContextPath()%>/featherlight-1.5.0/release/featherlight.min.css" type="text/css"  />
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.css" type="text/css"/>
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/capes.css" type="text/css" />
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/font-awesome.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/scrolling-nav.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/style.css">
        <link rel="stylesheet" href="<%= cssContraste %>" type="text/css" id="cssContraste" />


        <%
            if (!"NONE".equals(feedRef)) {
                for (int i = 0; i < parts.size(); i += 3) {
        %>
        <link rel="alternate" type="application/<%= (String) parts.get(i)%>" title="<%= (String) parts.get(i + 1)%>" href="<%= request.getContextPath()%>/feed/<%= (String) parts.get(i + 2)%>/<%= feedRef%>"/>
        <%
                }
            }

            if (osLink) {
        %>
        <link rel="search" type="application/opensearchdescription+xml" href="<%= request.getContextPath()%>/<%= osCtx%>description.xml" title="<%= osName%>"/>
        <%
            }

            if (extraHeadData != null) {%>
        <%= extraHeadData%>
        <%
            }
        %>

        <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery/jquery-1.10.2.min.js"></script>
        <script type='text/javascript' src='<%= request.getContextPath()%>/static/js/jquery/jquery-ui-1.10.3.custom.min.js'></script>
        <script type='text/javascript' src='<%= request.getContextPath()%>/static/js/bootstrap/bootstrap.min.js'></script>
        <script type='text/javascript' src='<%= request.getContextPath()%>/static/js/holder.js'></script>
        <script type='text/javascript' src='<%= request.getContextPath()%>/static/js/rich-text.js'></script>
        <script type="application/javascript" src="<%= request.getContextPath()%>/static/js/bootstrap-wysiwyg.js"></script>
        <script type="application/javascript" src="<%= request.getContextPath()%>/static/js/external/jquery.hotkeys.js"></script>
        <script type="application/javascript" src="<%=request.getContextPath()%>/static/js/external/google-code-prettify/prettify.js"></script>
        <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/semantic.js"></script>
        <script type="text/javascript" src="<%= request.getContextPath()%>/utils.js"></script>
        <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/choice-support.js"></script>
        <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/jquery.validate.min.js"></script>
        <script type='text/javascript' src="<%= request.getContextPath()%>/static/lib/jquery.raty.js"></script>
        <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/layout/template.js"></script>
        <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.js"></script>
        <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery.dataTables.min.js"></script>
         <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/jquery.easing.min.js"></script>
         <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/scripts.js"></script>
         <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/acessibilidade.js"></script>
        <%if (analyticsKey != null && analyticsKey.length() > 0) {%>
          <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/analytics.js"></script>
        <%}if (extraHeadDataLast != null) {%>
        <%=extraHeadDataLast%>
        <%}%>
          <script src="<%= request.getContextPath()%>/static/js/html5shiv.js"></script>
          <script src="<%= request.getContextPath()%>/static/js/respond.min.js"></script>
    </head>


            <body data-spy="scroll" data-target=".navbar-fixed-top">
            <div id="ancora"></div>

        <div class="onpage">
            <div class="interna">


    <div class="topo">
        <!-- ACESSIBILIDADE -->
            <div class="barra-top ">
                    <div class="container">
                    <div class="atalhos pull-left">
                    <ul>
                      <li><a href="http://www.capes.gov.br/"><img src="<%=request.getContextPath()%>/image/img/logo-barra.png"></a></li>
                      <li><a accesskey="3" href="<%=request.getContextPath()%>/feedback" tabindex="3" title="Fale conosco">Fale conosco</a></li>
                      <li><a accesskey="4" href="<%=request.getContextPath()%>/redirect?action=faq" tabindex="4" title="Dúvidas frequentes">Dúvidas frequentes</a></li>
                      <li><a accesskey="5" href="https://esic.cgu.gov.br/" tabindex="5" title="Serviço de informação ao cidadão - SIC">Serviço de informação ao cidadão - SIC</a></li>
                    </ul>
            </div>
               <div class="pull-right acessibilidade">
                        <ul>
                            <li><a accesskey="7" href="#conteudo" tabindex="3" class="" title="Saiba mais sobre a acessibilidade">Acessibilidade</a></li>
                            <li><a accesskey="8" onclick="window.toggleContrast()" title="Alto contraste[4]">Alto contraste</a></li>
                        </ul>
            </div>
            </div>
            </div>

    
    <div class="container">
        <%if (!navbar.equals("off")) {%>
    <dspace:include page="<%= navbar%>"/>
        <%}else{%>
    <dspace:include page="/layout/navbar-minimal.jsp"/>
        <%}%>
    </div>
    <%-- Location bar --%>








    <%--Buscador--%>

        </div>
    <div class="conteudo">


    <%-- Page location bar --%>
        <%--<%if (request.getAttribute("dspace.layout.sidebar") != null) { %>--%>
            <%if (locbar) {%>
                <div class="container">
                  <dspace:include page="/layout/location-bar.jsp" />
                </div>
            <%}%>
        <%--<%}%>--%>

<div class="container">


<%--fim no footer--%>

