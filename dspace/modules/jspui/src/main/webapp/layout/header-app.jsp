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
    <meta property="creator.productor" content="http://estruturaorganizacional.dados.gov.br/id/unidade-organizacional/250">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=PT+Sans:400,400italic,700,700italic" type="text/css">
    <%--<link rel="stylesheet" href="styles/bootstrap.css">--%>

    <title><%= siteName%>: <%= title%></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="Generator" content="<%= generator%>" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" href="<%= request.getContextPath()%>/favicon.ico" type="image/x-icon"/>
    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/jquery-ui-1.10.3.custom/redmond/jquery-ui-1.10.3.custom.css" type="text/css" />
    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/bootstrap/bootstrap.css" type="text/css" />
    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/app.css">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/template.css">
    <%--<link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/bootstrap/bootstrap-theme.css" type="text/css" />--%>
    <%--<link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/bootstrap/dspace-theme.css" type="text/css" />--%>
    <%--<link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/iconeffectbase.css" type="text/css" />--%>
    <%--<link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/iconeffect.css" type="text/css" />--%>
    <%--<link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/mobilemenu.css" type="text/css" />--%>
    <%--<link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/animate.min.css" type="text/css" />--%>
    <link rel="stylesheet" href="<%= request.getContextPath()%>/video-player/videojs/dist/video-js.min.css" type="text/css" />
    <link rel="stylesheet" href="<%= request.getContextPath()%>/featherlight-1.5.0/release/featherlight.min.css" type="text/css"  />
    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/capes.css" type="text/css" />
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
    <script type="text/javascript" src="<%= request.getContextPath()%>/utils.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/choice-support.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/jquery.validate.min.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/lib/jquery.raty.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/layout/demo.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/layout/template.js"></script>

    <%--Gooogle Analytics recording.--%>
    <%
        if (analyticsKey != null && analyticsKey.length() > 0) {
    %>
    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '<%= analyticsKey%>']);
        _gaq.push(['_trackPageview']);

        (function () {
            var ga = document.createElement('script');
            ga.type = 'text/javascript';
            ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0];
            s.parentNode.insertBefore(ga, s);
        })();
    </script>
    <%
        }
        if (extraHeadDataLast != null) {%>
    <%= extraHeadDataLast%>
    <%
        }
    %>


    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
    <script src="<%= request.getContextPath()%>/static/js/html5shiv.js"></script>
    <script src="<%= request.getContextPath()%>/static/js/respond.min.js"></script>
    <![endif]-->
</head>
<%-- HACK: leftmargin, topmargin: for non-CSS compliant Microsoft IE browser --%>
<%-- HACK: marginwidth, marginheight: for non-CSS compliant Netscape browser --%>
<body class="undernavigation">

<a class="sr-only" href="#content">Skip navigation</a>

<header id="main-header">

    <div id="capes-barra">
        <div class="container">
            <div class="row">
                <div class="col-md-1"><a href="http://www.capes.gov.br" target="_blank"><img src="<%= request.getContextPath()%>/image/img/capesTopo.svg" width="140%" style="padding-top:8px">
                </a></div>
                <div class="col-md-5">
                    <div class="headerMenus"><a href="#" target="_blank" title="Fale conosco">Fale conosco</a></div>
                    <div class="headerMenus"><a href="<%=request.getContextPath()%>/redirect?action=faq" target="_blank" title="Dúvidas frequentes">Dúvidas frequentes</a></div>
                    <div class="headerMenus"><a href="https://esic.cgu.gov.br/" target="_blank" title="Serviço de informação ao cidadão - SIC">Serviço de informação ao cidadão - SIC</a></div>
                </div>
                <div class="col-md-4"></div>
                <div class="col-md-2 pull-right">
                    <a href="#"><img src="<%= request.getContextPath()%>/image/img/fonteMaior.svg" width="18%" alt="Aumentar Fonte" title="Aumentar Fonte" class="pull-right"></a>
                    <a href="#"><img src="<%= request.getContextPath()%>/image/img/fonteOK.svg" width="18%" alt="Restaurar Fonte" title="Restaurar Fonte" class="pull-right"></a>
                    <a href="#"><img src="<%= request.getContextPath()%>/image/img/fonteMenor.svg" width="18%" alt="Diminuir Fonte" title="Diminuir Fonte" class="pull-right"></a>
                    <li class="<% if(preferedCss.equals("capes_contraste.css")){%> hidden<% }%>">
                        <a id="contrastLink" class="contrastLink" href="#"><img src="<%= request.getContextPath()%>/image/img/contraste.svg" width="18%" alt="Alto Contraste" title="Alto Contraste" class="pull-right"></a>
                    </li>
                    <li class="<% if(!preferedCss.equals("capes_contraste.css")){%> hidden<% }%>">
                        <a  id="noContrastLink" class="contrastLink"  href="#"><img src="<%= request.getContextPath()%>/image/img/contraste.svg" width="18%" alt="Alto Contraste" title="Alto Contraste" class="pull-right"></a>
                    </li>
                </div>
            </div>
        </div>
    </div>

    <div class="container">

        <%
            if (!navbar.equals("off")) {
        %>
        <dspace:include page="<%= navbar%>" />
        <%
        } else {
        %>
        <dspace:include page="/layout/navbar-minimal.jsp" />
        <%
            }
        %>

    </div>

</header>



<%--Buscador--%>
<header class="page-header">
    <div class="container">
        <%--<form method="get" action="<%= request.getContextPath()%>/simple-search">--%>
            <%--<div class="row">--%>
                <%--<div class="col-md-12">--%>
                    <%--<h2><fmt:message key="jsp.search.advanced.search2"/></h2>--%>
                <%--</div>--%>
            <%--</div>--%>
            <%--<div class="row">--%>

                <%--<div class="col-md-2">--%>
                    <%--<div class="col-md-12">--%>
                        <%--<ul class="nav navbar-nav dropdownFiltro"><a data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">--%>
                            <%--<li class="dropdown">--%>
                                <%--<button class="btn btn-primary btn-block">Filtrar por <span class="caret"></span></button>--%>
                            <%--</li>--%>
                            <%--<ul class="dropdown-menu">--%>
                                <%--<% if (isSystemAdmin) {%>--%>
                                <%--<li><a href="<%= request.getContextPath()%>/community-list"><fmt:message key="jsp.layout.navbar-default.communities-collections"/></a></li>--%>
                                <%--<% } %>--%>
                                <%--<li class="divider"></li>--%>
                                <%--&lt;%&ndash;<li class="dropdown-header"> <fmt:message key="jsp.layout.navbar-default.browseitemsby"/></li>&ndash;%&gt;--%>
                                <%--<%--%>
                                    <%--String url = "/simple-search?query=&filter_field_1=subject&filter_type_1=equals&filter_value_1=uab";--%>
                                    <%--for (int i = 0; i < bis.length; i++) {--%>
                                        <%--BrowseIndex bix = bis[i];--%>
                                        <%--String key = "browse.menu." + bix.getName();--%>
                                <%--%>--%>
                                <%--<li><a href="<%= request.getContextPath()%>/browse?type=<%= bix.getName()%>"><fmt:message key="<%= key%>"/></a></li>--%>

                                <%--<%--%>
                                    <%--}--%>

                                <%--%><li><a href="<%= request.getContextPath()%>/simple-search?<%=url%>"><fmt:message  key="jsp.search.filter.uab"/></a></li>--%>



                            <%--</ul></a></ul>--%>
                    <%--</div>--%>
                <%--</div>--%>

                <%--<div class="col-md-8">--%>
                    <%--<input type="text" class="form-control" placeholder="<fmt:message key="jsp.layout.navbar-default.search"/>" name="query" id="query" size="50"/>--%>
                <%--</div>--%>
                <%--<div class="col-md-2">--%>
                    <%--<button type="submit" class="btn btn-primary btn-block"><fmt:message key="jsp.home.search1"/> </button>--%>
                <%--</div>--%>
            <%--</div>--%>
        <%--</form>--%>
    </div>
</header>
<%--Buscador--%>






<main id="content" role="main">

    <%-- Location bar --%>
        <%
                if (locbar) {
            %>
    <div class="container">
        <dspace:include page="/layout/location-bar.jsp" />
    </div>
        <%
                }
            %>

    <%-- Page contents --%>
    <div class="container">
            <% if (request.getAttribute("dspace.layout.sidebar") != null) { %>
        <div class="row">
            <div class="col-md-9 pull-right">
                    <% }%>

