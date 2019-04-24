<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>

<%@page import="org.dspace.browse.ItemCountException" %>
<%@page import="org.dspace.browse.ItemCounter" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.content.Partners" %>
<%@ page import="org.dspace.core.NewsManager" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.jsp.jstl.core.Config" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.util.Locale" %>

<%@ page contentType="text/html;charset=UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core"
           prefix="c" %>


<%

    Community[] communities = (Community[]) request.getAttribute("communities");
    //List<Partners> partnersList = (List<Partners>) request.getAttribute("partnersList");
    HashMap<Integer, List<Partners>> partnersList = (HashMap<Integer, List<Partners>>) request.getAttribute("partnersList");




    Map collectionMap = (Map) request.getAttribute("collections.map");
    Map subcommunityMap = (Map) request.getAttribute("subcommunities.map");
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);

    boolean feedEnabled = ConfigurationManager.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled) {
        feedData = "ALL:" + ConfigurationManager.getProperty("webui.feed.formats");
    }


%>

<%!
    void showCommunity(Community c, JspWriter out, HttpServletRequest request, ItemCounter ic,
                       Map collectionMap, Map subcommunityMap) throws ItemCountException, IOException {
        String path = request.getContextPath();


        if (c.getName().equals("Cursos Nacionais")) {
            out.println("<li class=\"col-md-2 col-xs-4 col-md-offset-1\">");
            out.println("<a class=\"course\" data-toggle=\"tooltip\"\n" +
                    "data-placement=\"bottom\"\n" +
                    "title=\"Acessar todos os " + c.getName() + "\"\n" +
                    "alt=\"Cursos\" title=\"Acessar Cursos\" href=\"" + request.getContextPath() + "/handle/" + c.getHandle() + "\">");
            out.println("<img class=\"CursoNacionalImg\"  src=\"" + path + "/image/img/icon/course.svg\"" + "\">");
            out.println("</a>");
            if (StringUtils.isNotBlank(c.getName())) {
                out.println("<div class=\"legendaIcon\">" + c.getName() + "</div>");
            }
            out.println("</li>");

        } else {
            out.println("<li class=\"col-md-2 col-xs-4\">");
            if (StringUtils.isNotBlank(c.getMetadata("short_description"))) {

                out.println("<a data-toggle=\"tooltip\"\n" + "data-placement=\"bottom\"\n" + "title=\"Acessar " + c.getMetadata("short_description") + "\"\n" +
                        "alt=\"Cursos\" title=\"Acessar Cursos\" href=\"" + request.getContextPath() + "/handle/" + c.getHandle() + "\">");
            }
            if (c.getName().equalsIgnoreCase("Filosofia")){
            out.println("<img class=\"img-cursos\" src=\"" + path + "/image/img/icon/filosofia.png\"" + "\">");

            } else if(c.getName().equalsIgnoreCase("matemática")){
            out.println("<img class=\"img-cursos\" src=\"" + path + "/image/img/icon/matematica.png\"" + "\">");

            }else if(c.getName().equalsIgnoreCase("Sociologia")){
            out.println("<img class=\"img-cursos\" src=\"" + path + "/image/img/icon/sociologia.png\"" + "\">");

            }else if(c.getName().equalsIgnoreCase("PNAP")){
             out.println("<img class=\"img-cursos\" src=\"" + path + "/image/img/icon/pnap.png\"" + "\">");
            }

            out.println("</a>");
            out.println("<div class=\"legendaIcon\">" + c.getName() + "</div>");
            out.println("<br/>");
            out.println("<br/>");


            out.println("</li>");
        }
        // Get the sub-communities in this community
        Community[] comms = (Community[]) subcommunityMap.get(c.getID());
        if (comms != null && comms.length > 0) {
            for (int k = 0; k < comms.length; k++) {
                showCommunity(comms[k], out, request, ic, collectionMap, subcommunityMap);
            }
        }

    }
%>


<% String link = "simple-search?filtername=type&filterquery=";
    String filterType = "&filtertype=contains";
    String search = "simple-search?query=";
%>


<script type="text/javascript" src="<%= request.getContextPath()%>/static/js/layout/template.js"></script>


<dspace:layout style="home" locbar="off" titlekey="jsp.home.title" feedData="<%=feedData%>">


<div class="conteudo">

    <div class="hide">
        <%@ include file="discovery/static-sidebar-facet.jsp" %>
    </div>

 <%--Static mídia types--%>
        <%-- Dinamic News--%>
    <%--<div class="row">--%>
        <%--<div class="col-md-12">--%>
                <%--Carousel homer--%>


        <section id="tipos-midias">
            <div class="container">
                <h2>Tipos de <strong>Mídias</strong></h2>
                <ul>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Imagens" href="<%=request.getContextPath()%>/<%=link+"imagem"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/imagem.png"><span>Imagem</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Vídeos" href="<%=request.getContextPath()%>/<%=link+"video"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/videos.png"><span>Vídeos</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Aplicativos" href="<%=request.getContextPath()%>/<%=link+"aplicativo"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/aplicativo.png"><span>Aplicativo Móvel</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Livro digital" href="<%=request.getContextPath()%>/<%=search+"livro-digital"%>"><img src="<%=request.getContextPath()%>/image/img/icon/livro.png"><span>Livro Digital</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Animação" href="<%=request.getContextPath()%>/<%=link+"animacao"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/animacao.png"><span>Animação</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Cursos" href="<%=request.getContextPath()%>/<%=search+"aulas e cursos"%>"><img src="<%=request.getContextPath()%>/image/img/icon/aulas.png"><span>Aulas e Cursos Moocs</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Ferramentas" href="<%=request.getContextPath()%>/<%=link+"ferramentas"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/ferramentas.png"><span>Ferramentas</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Jogos" href="<%=request.getContextPath()%>/<%=search+"jogo"%>"><img src="<%=request.getContextPath()%>/image/img/icon/jogo.png"><span>Jogo</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Laboratório" href="<%=request.getContextPath()%>/<%=search+"laboratório"%>"><img src="<%=request.getContextPath()%>/image/img/icon/laboratorio.png"><span>Laboratório</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Mapa" href="<%=request.getContextPath()%>/<%=link+"mapa"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/mapa.png"><span>Mapa</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Áudio" href="<%=request.getContextPath()%>/<%=link+"audio"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/audio.png"><span>Áudio</span></a></li>
                    <li class="col-md-2 col-xs-6"><a data-toggle="tooltip"  data-placement="bottom" title="Filtrar por Portal" href="<%=request.getContextPath()%>/<%=link+"portal"+filterType%>"><img src="<%=request.getContextPath()%>/image/img/icon/portal.png"><span>Portal</span></a></li>
                </ul>
            </div>
        </section>

<%--Dinamic National Courses--%>
        <section id="cursos-nacionais">
            <div class="container">
                <h2>Cursos <strong>Nacionais</strong></h2>
                <ul>
                    <% if (communities.length != 0) {%>
                    <% for (int i = 0; i < communities.length; i++) {%>
                    <% if (communities[i].getName().equalsIgnoreCase("Cursos Nacionais")) {%>
                    <% showCommunity(communities[i], out, request, ic, collectionMap, subcommunityMap);%>
                    <%}%>
                    <%}%>
                    <%}%>
                </ul>
            </div>
        </section>

<%--Dinamic Our Parteners --%>
        <section id="nossos-parceiros">
            <div class="container">
                <h2>Nossos <strong>Parceiros</strong></h2>
                <div id="myCarouse2" data-ride="carousel" class="carousel slide">
                    <div class="carousel-inner">
                        <% for (int i = 0; i < partnersList.size(); i++) {%>
                        <div class="item <%=(i == 0 ? "active" : "")%>">
                            <% for (Partners p : partnersList.get(partnersList.keySet().toArray()[i])) {%>
                            <div class="col-md-<%=(12/partnersList.get(partnersList.keySet().toArray()[i]).size())%>">
                                <a href="<%=p.getUrl()%>" target="_blank">
                                    <img src="<%=request.getContextPath()%>/image/img/parceiros/<%=p.getPath()%>"
                                         alt="<%=p.getName()%>"
                                         text-align="center"
                                         class="img-responsivee"/>
                                </a>
                            </div>
                            <%}%>
                        </div>
                        <%}%>
                    </div>
                    <a href="#myCarouse2" data-slide="prev" class="left carousel-control">
                        <img src="<%=request.getContextPath()%>/image/img/left.png">
                        <span class="sr-only">Previous</span>
                    </a>
                    <a href="#myCarouse2" data-slide="next" class="right carousel-control">
                        <img src="<%=request.getContextPath()%>/image/img/right.png">
                        <span class="sr-only">Next</span>
                    </a>
                </div>
            </div>
        </section>
    </div>


</dspace:layout>
