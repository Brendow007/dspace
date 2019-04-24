<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Default navigation bar
--%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.authorize.AuthorizeManager" %>


<%

    String requestPath = request.getRequestURL().toString();
    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");
    String intranet = ConfigurationManager.getProperty("dspace.intranet");


    // Is the logged in user an admin
    Boolean admin = (Boolean) request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf('?');
    if (c > -1) {
        currentPage = currentPage.substring(0, c);
    }

    // E-mail may have to be truncated
    String navbarEmail = null;

    if (user != null) {
        navbarEmail = user.getEmail();
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
    // get the locale languages
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);

    Context context = UIUtil.obtainContext(request);
    boolean isSystemAdmin = AuthorizeManager.isAdmin(context);

%>


  <!-- Menu scroll - busca hidden -->
        <div class="menu-scroll">
           <div class="logo-menu"><a href="#ancora" class="page-scroll"></a> </div>
                  <ul class="nav navbar-nav">
                    <%if(requestPath.contains("home")){%>
                            <li><a class="page-scroll" href="#tipos-midias" title="Tipos de Mídias">Tipos de Mídias</a></li>
                            <li><a class="page-scroll" href="#cursos-nacionais" title="Cursos Nacionais"> Cursos Nacionais</a></li>
                                <%}else if (requestPath.contains("/search")){%>
                            <li><a class="page-scroll" href="<%=request.getContextPath()%>/" title="Página inicial">Inicio</a></li>
                            <li><a class="page-scroll" href="#resultado-busca" title="Ir para busca">Busca</a></li>
                                <%}else{%>
                            <li><a class="page-scroll" href="<%=request.getContextPath()%>/" title="Página inicial">Inicio</a></li>
                            <li><a class="page-scroll" href="<%=request.getContextPath()%>/simple-search" title="Ir para busca">Busca</a></li>
                    <%}%>
                    <li role="presentation" class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="true"> Sobre o Educapes <span class="caret"></span> </a>
                        <ul class="dropdown-menu">
                                    <li><a href="<%= request.getContextPath()%>/redirect?action=about"><fmt:message key="jsp.sidebar.mainmenu.whatis"/></a></li>
                                    <li><a href="<%= request.getContextPath()%>/redirect?action=search"><fmt:message key="jsp.sidebar.mainmenu.search"/></a></li>
                                    <li><a href="<%= request.getContextPath()%>/redirect?action=submission"><fmt:message key="jsp.sidebar.mainmenu.submit"/></a></li>
                                    <li><a class="page-scroll" href="#nossos-parceiros"><fmt:message key="jsp.sidebar.mainmenu.partners"/></a></li>
                                    <li><a href="<%= request.getContextPath()%>/redirect?action=contact"><fmt:message key="jsp.sidebar.mainmenu.contact"/></a></li>
                                      <% if (!AuthorizeManager.isAdmin(context)){ %>
                                    <li><a href="<%= request.getContextPath()%>/register/edit-author"><fmt:message key="jsp.sidebar.mainmenu.author"/></a></li>
                                     <% } %>
                        </ul>
                </li>
                <%if (user != null) {%>
                        <li role="presentation" class="dropdown" style="width: 153px;">
                        <%--<a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <%= StringUtils.abbreviate(navbarEmail, 20)%><b class="caret"></b></a>--%>
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#" ><%= StringUtils.abbreviate(navbarEmail, 10)%> <span class="caret"></span></a>
                                <%} else { %>
                        <li>
                        <a class="page-scroll login" href="<%=request.getContextPath()%>/password-login" title="Login"><span class="glyphicon glyphicon-user"></span>Login</a>
                                <%}%>
                        <ul class="dropdown-menu">
                        <li><a href="<%= request.getContextPath()%>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a></li>
                        <li><a href="<%= request.getContextPath()%>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a></li>
                        <li><a href="<%= request.getContextPath()%>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a></li>
                                <%if (isAdmin) {%>
                        <li><a href="<%= request.getContextPath()%>/dspace-admin"><fmt:message key="jsp.administer"/></a></li>
                                <%}if (user != null) {%>
                        <li><a href="<%= request.getContextPath()%>/logout"><span class="glyphicon glyphicon-log-out"></span> <fmt:message key="jsp.layout.navbar-default.logout"/></a></li>
                                <%}%>
                        </ul>
                        </li>



        </ul>
        <form method="get" action="<%= request.getContextPath()%>/simple-search">
                  <input type="text" name="query"  size="50" placeholder="Buscar no repositório">
                <button class="button btn" onclick="this.form.searchword.focus();">
                   <span class="glyphicon glyphicon-search"></span>
                </button>
           </form>
        </div>



                <nav class="navbar navbar-default" role="navigation">
                        <div class="container">
                        <div class="col-md-3">
                             <a class="logo page-scroll" rel="home" href="<%=request.getContextPath()%>/" title="">
                                 <h1><img src="<%=request.getContextPath()%>/image/img/logo.png"></h1>
                                    <%if (intranet != null) {%>
                                        <div style="width: 75px;">
                                        <a href="#" class="ui teal left ribbon label">Intranet</a>
                                        </div>
                                    <%}%>
                              </a>
                        </div>
                    <div class="col-md-9">
                        <div class="menu">
                                <div class="navbar-header page-scroll">
                                <div class="bt-responsive visible-xs visible-sm"><a><span>Menu</span></a></div>
                        </div>
                          <div class="collapse navbar-collapse navbar-ex1-collapse">
                                <ul class="nav navbar-nav">
                                <%if(requestPath.contains("home")){%>
                                    <li><a class="page-scroll" href="#tipos-midias" title="Tipos de Mídias">Tipos de Mídias</a></li>
                                    <li><a class="page-scroll" href="#cursos-nacionais" title="Cursos Nacionais"> Cursos Nacionais</a></li>
                                <%}else if (requestPath.contains("/search")){%>
                                    <li><a class="page-scroll" href="<%=request.getContextPath()%>/" title="Página inicial">Inicio</a></li>
                                    <li><a class="page-scroll" href="#resultado-busca" title="Ir para busca">Busca</a></li>
                                <%}else{%>
                                   <li><a class="page-scroll" href="<%=request.getContextPath()%>/" title="Página inicial">Inicio</a></li>
                                   <li><a class="page-scroll" href="<%=request.getContextPath()%>/simple-search" title="Ir para busca">Busca</a></li>
                                <%}%>
                                         <li role="presentation" class="dropdown">
                                                <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="true"> Sobre o Educapes <span class="caret"></span></a>
                                                <ul class="dropdown-menu">
                                                <li><a href="<%=request.getContextPath()%>/redirect?action=about"><fmt:message key="jsp.sidebar.mainmenu.whatis"/></a></li>
                                                <li><a href="<%= request.getContextPath()%>/redirect?action=search"><fmt:message key="jsp.sidebar.mainmenu.search"/></a></li>
                                                <li><a href="<%= request.getContextPath()%>/redirect?action=submission"><fmt:message key="jsp.sidebar.mainmenu.submit"/></a></li>
                                                <li><a class="page-scroll" href="#nossos-parceiros"><fmt:message key="jsp.sidebar.mainmenu.partners"/></a></li>
                                                <li><a href="<%= request.getContextPath()%>/redirect?action=contact"><fmt:message key="jsp.sidebar.mainmenu.contact"/></a></li>
                                                        <% if (!AuthorizeManager.isAdmin(context)){ %>
                                                <li><a href="<%= request.getContextPath()%>/register/edit-author"><fmt:message key="jsp.sidebar.mainmenu.author"/></a></li>
                                                        <% } %>
                                                </ul>
                                          </li>

                                             <%if (user != null) {%>
                                         <li role="presentation" class="dropdown" style="width: 162px;">
                                                <%--<a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <%= StringUtils.abbreviate(navbarEmail, 20)%><b class="caret"></b></a>--%>
                                                <a class="dropdown-toggle" data-toggle="dropdown" href="#" ><%= StringUtils.abbreviate(navbarEmail, 10)%> <span class="caret"></span></a>
                                          <%} else { %>
                                         <li>
                                                 <a class="page-scroll login" href="<%=request.getContextPath()%>/password-login" title="Login"><span class="glyphicon glyphicon-user"></span>Login</a>
                                                        <%}%>
                                             <ul class="dropdown-menu">
                                                <li><a href="<%= request.getContextPath()%>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a></li>
                                                <li><a href="<%= request.getContextPath()%>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a></li>
                                                <li><a href="<%= request.getContextPath()%>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a></li>
                                                 <%if (isAdmin) {%>
                                                <li><a href="<%= request.getContextPath()%>/dspace-admin"><fmt:message key="jsp.administer"/></a></li>
                                                        <%}if (user != null) {%>
                                                <li><a href="<%= request.getContextPath()%>/logout"><span class="glyphicon glyphicon-log-out"></span> <fmt:message key="jsp.layout.navbar-default.logout"/></a></li>
                                                        <%}%>
                                             </ul>
                                        </li>
                                </ul>
                            </div>
                         </div>
                      </div>
                   </div>
                </nav>






   <%-- <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
        <li><a href="<%= request.getContextPath()%>/"> <!--<span class="glyphicon glyphicon-home"></span>--> <fmt:message key="jsp.layout.navbar-default.home"/></a></li>
        <li class="dropdown">

            <% if (user != null) {%>
            <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.sidebar.mainmenu.whatis"/><b class="caret"></b></a>
            <%} else {%>
            <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.sidebar.mainmenu.whatis"/><b class="caret"></b></a>
            <%}%>

            <ul class="dropdown-menu">
                <li><a href="<%= request.getContextPath()%>/redirect?action=about"><fmt:message key="jsp.sidebar.mainmenu.whatis"/></a></li>
                <li><a href="<%= request.getContextPath()%>/redirect?action=search"><fmt:message key="jsp.sidebar.mainmenu.search"/></a></li>
                <li><a href="<%= request.getContextPath()%>/redirect?action=submission"><fmt:message key="jsp.sidebar.mainmenu.submit"/></a></li>
                <li><a href="<%= request.getContextPath()%>/redirect?action=partners"><fmt:message key="jsp.sidebar.mainmenu.partners"/></a></li>
                <li><a href="<%= request.getContextPath()%>/redirect?action=contact"><fmt:message key="jsp.sidebar.mainmenu.contact"/></a></li>
                    <% if (!AuthorizeManager.isAdmin(context)){ %>
                <li><a href="<%= request.getContextPath()%>/register/edit-author"><fmt:message key="jsp.sidebar.mainmenu.author"/></a></li>
                    <% } %>
            </ul>
        </li>

        <li class="dropdown">
            <%if (user != null) {%>
            <a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <%= StringUtils.abbreviate(navbarEmail, 20)%>
                <b class="caret"></b></a>
                <%} else { %>
                 <a href="<%=request.getContextPath()%>/password-login" class="btn">Login</a>
                 &lt;%&ndash;<a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <!--<fmt:message key="jsp.layout.navbar-default.sign"/> --> Conta<b class="caret"></b></a>&ndash;%&gt;
                <%}%>
            <ul class="dropdown-menu">
                <li><a href="<%= request.getContextPath()%>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a></li>
                <li><a href="<%= request.getContextPath()%>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a></li>
                <li><a href="<%= request.getContextPath()%>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a></li>

                <%if (isAdmin) {%>
                <li class="divider"></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin"><fmt:message key="jsp.administer"/></a></li>
                    <%}if (user != null) {%>
                <li><a href="<%= request.getContextPath()%>/logout"><span class="glyphicon glyphicon-log-out"></span> <fmt:message key="jsp.layout.navbar-default.logout"/></a></li>
                    <%}%>
            </ul>
        </li>--%>

<%if(supportedLocales != null && supportedLocales.length > 1){%>

 <%--Multiple language suport--%>
<div>
      <ul>
        <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.layout.navbar-default.language"/><b class="caret"></b></a>
            <ul class="dropdown-menu">
                <%for (int i = supportedLocales.length - 1; i >= 0; i--) {%>
                <li>
                    <a onclick="javascript:document.repost.locale.value = '<%=supportedLocales[i].toString()%>';
                                document.repost.submit();" href="<%= request.getContextPath()%>?locale=<%=supportedLocales[i].toString()%>">
                        <%= supportedLocales[i].getDisplayLanguage(supportedLocales[i])%>
                    </a>
                </li>
                <%}%>
            </ul>
        </li>
    </ul>
</div>
<%}%>




