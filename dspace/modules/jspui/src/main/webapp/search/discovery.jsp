<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>

<%--
  - Display the form to refine the simple-search and dispaly the results of the search
  -
  - Attributes to pass in:
  -
  -   scope            - pass in if the scope of the search was a community
  -                      or a collection
  -   scopes 		   - the list of available scopes where limit the search
  -   sortOptions	   - the list of available sort options
  -   availableFilters - the list of filters available to the user
  -
  -   query            - The original query
  -   queryArgs		   - The query configuration parameters (rpp, sort, etc.)
  -   appliedFilters   - The list of applied filters (user input or facet)
  -
  -   search.error     - a flag to say that an error has occurred
  -   spellcheck	   - the suggested spell check query (if any)
  -   qResults		   - the discovery results
  -   items            - the results.  An array of Items, most relevant first
  -   communities      - results, Community[]
  -   collections      - results, Collection[]
  -
  -   admin_button     - If the user is an admin
--%>

<%@page import="com.coverity.security.Escape" %>
<%@page import="org.apache.commons.lang.StringUtils" %>
<%@page import="org.dspace.app.webui.util.UIUtil" %>
<%@page import="org.dspace.browse.ItemCountException" %>
<%@page import="org.dspace.browse.ItemCounter" %>
<%@page import="org.dspace.content.Collection" %>
<%@page import="org.dspace.content.Community" %>
<%@page import="org.dspace.content.DSpaceObject" %>
<%@page import="org.dspace.content.Item" %>
<%@page import="org.dspace.core.Utils" %>
<%@page import="org.dspace.discovery.DiscoverQuery" %>
<%@page import="org.dspace.discovery.DiscoverResult" %>
<%@page import="org.dspace.discovery.DiscoverResult.FacetResult" %>
<%@ page import="org.dspace.discovery.configuration.DiscoverySearchFilter" %>
<%@ page import="org.dspace.discovery.configuration.DiscoverySearchFilterFacet" %>
<%@ page import="org.dspace.sort.SortOption" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.SQLException" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"
           prefix="c" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="java.text.Normalizer" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%

    Community[] communitiees = (Community[]) request.getAttribute("communitiees");
    Map collectionMap = (Map) request.getAttribute("collectioons.map");
    Map subcommunityMap = (Map) request.getAttribute("subcommunitiees.map");
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    // Get the attributes
    DSpaceObject scope = (DSpaceObject) request.getAttribute("scope");
//    String RestAPI = "https://"+request.getServerName() + ":" + 8443 + "/rest";
    String searchScope = scope != null ? scope.getHandle() : "";
    List<DSpaceObject> scopes = (List<DSpaceObject>) request.getAttribute("scopes");
    List<String> sortOptions = (List<String>) request.getAttribute("sortOptions");

    String query = (String) request.getAttribute("query");
    if (query == null) {
        query = "";
    }
    Boolean error_b = (Boolean) request.getAttribute("search.error");
    boolean error = (error_b == null ? false : error_b.booleanValue());

    DiscoverQuery qArgs = (DiscoverQuery) request.getAttribute("queryArgs");
    String sortedBy = qArgs.getSortField();
    String order = qArgs.getSortOrder().toString();
    String ascSelected = (SortOption.ASCENDING.equalsIgnoreCase(order) ? "selected=\"selected\"" : "");
    String descSelected = (SortOption.DESCENDING.equalsIgnoreCase(order) ? "selected=\"selected\"" : "");
    String httpFilters = "";
    String spellCheckQuery = (String) request.getAttribute("spellcheck");
    List<DiscoverySearchFilter> availableFilters = (List<DiscoverySearchFilter>) request.getAttribute("availableFilters");
    List<String[]> appliedFilters = (List<String[]>) request.getAttribute("appliedFilters");
    List<String> appliedFilterQueries = (List<String>) request.getAttribute("appliedFilterQueries");
    if (appliedFilters != null && appliedFilters.size() > 0) {
        int idx = 1;
        for (String[] filter : appliedFilters) {
            httpFilters += "&amp;filter_field_" + idx + "=" + URLEncoder.encode(filter[0], "UTF-8");
            httpFilters += "&amp;filter_type_" + idx + "=" + URLEncoder.encode(filter[1], "UTF-8");
            httpFilters += "&amp;filter_value_" + idx + "=" + URLEncoder.encode(filter[2], "UTF-8");
            idx++;
        }
    }
    int rpp = qArgs.getMaxResults();
    int etAl = ((Integer) request.getAttribute("etal")).intValue();

    String[] options = new String[]{"equals", "contains", "authority", "notequals", "notcontains", "notauthority"};

    // Admin user or not
    Boolean admin_b = (Boolean) request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
%>


<%!void showCommunityy(Community c, JspWriter out, HttpServletRequest request, ItemCounter ic,
                       Map collectionMap, Map subcommunityMap) throws ItemCountException, IOException, SQLException {

String handleCom = "value=\""+c.getHandle()+"\"";
String iCaret = "<i class=\"pull-right icon-caret-right\"></i>";
String LinkCom = "<div class=\"text\""+ "value=\"" + c.getHandle() + "\"" +">" + c.getName() + iCaret + "</div>";

        out.println("<div class=\"item\""+handleCom+">"+ LinkCom  +"</div>");

    Community[] comms = (Community[]) subcommunityMap.get(c.getID());
    Collection[] cols = (Collection[]) collectionMap.get(c.getID());

    // Get the sub-communities in this community
    if (comms != null && comms.length > 0) {
        out.println("<div class=\"menu\">");
        for (int k = 0; k < comms.length; k++) {
            out.println("<div class=\"item\">");
                 showCommunityy(comms[k], out, request, ic, collectionMap, subcommunityMap);
               out.println("</div>");
        }
        out.println("</div>");
    }

    if (cols != null && cols.length > 0) {
    // Get the collections in this community
        out.println("<div class=\"menu\">");

        if (comms != null && comms.length > 0) {
            for (int k = 0; k < comms.length; k++) {
                out.println("<div class=\"item\">");
                showCommunityy(comms[k], out, request, ic, collectionMap, subcommunityMap);
                out.println("</div>");
            }
        }

        for (int j = 0; j < cols.length; j++) {
            out.println("<div class=\"item\" value=\"" + cols[j].getHandle() + "\"" +"><div class=\"text\" value=\"" + cols[j].getHandle() + "\""+">"+ cols[j].getMetadata("name")+"</div></div>");
        }

        out.println("</div>");

    }


}
%>

<c:set var="dspace.layout.head.last" scope="request">
    <style>
        .ui.search.dropdown .menu{
            max-height: unset !important;
        }
    </style>

    <script type="text/javascript">
        var jQ = jQuery.noConflict();
        jQ(document).ready(function () {


            // jQ("div.t3").on('click',function () {
            //     // console.log(jQ(this).html().length);
            //     var reducedHeight = jQ(this).height();
            //     jQ(this).css('height', 'auto');
            //     var fullHeight = jQ(this).height();
            //     jQ(this).height(reducedHeight);
            //     jQ(this).animate({height: fullHeight}, 500);
            // });








           jQ('.ui.multiple.dropdown').dropdown();
            // $('.dropdown').dropdown();
            jQ('[data-toggle="tooltip"]').tooltip();



            filterSearchIcon();
            searchDropdownMenu();
            formataIdiomas();
            readMore();


            jQ("form div.ui.input.focus input#query").on('input' , function () {
                var queryParam = jQ("form div.ui.input.focus input#query").val();
                if (queryParam.length >= 3 && !isEmptyOrSpaces(queryParam)) {
                         // GetSearchFunction(queryParam);
                }
                if(queryParam.length == 0){
                    jQ('li#RestSearchSolr').each(function(index, item){
                        // item.remove();
                    });
                    // jQ('#RestSearchSolr').each(index, item){
                }

           function GetSearchFunction (queryParam) {
                    var restApi = 'https://educapes.des.capes.gov.br/rest/items/search';
                jQ.ajax({
                    dataType: 'json',
                    headers: {
                        Accept: "application/json",
                        "Access-Control-Allow-Origin": "*"
                    },
                    contentType:'application/json',
                    type: 'GET',
                    url: restApi,
                    data: {"q":queryParam,
                           "limit": 20,
                            "expand":"metadata"},
                    success: function (data) {
                        console.log(data);
                        jQ('li#RestSearchSolr').each(function(index, item){
                            item.remove();
                        });
                        var thumb = "<div class=\"thumbnail-wrapper\"><div class=\"artifact-preview\">\n" +
                            "<a href=\"#\"><span class=\"item-list conteudo-texto\"></span></a>\n" +
                            "</div></div>";
                        jQ(data.item).each(function(index, item){
                            var requestContextPath =  "<%=request.getContextPath()%>" + "/handle/";
                            var html ="<li id=\"RestSearchSolr\">"+thumb +
                            "<div  class=\"artifact-description\">"+
                            "<div class=\"evenRowOddCol\"><a target='_blank' href="+ requestContextPath + item.handle + ">"+  item.name    +"</a></div>"+
                            "<div class=\"evenRowEvenCol\">"+ item.handle  +"</div>"+
                            "<div class=\"evenRowEvenCol\">"+  item.metadata.value    +"</div>"+
                            "</li>";
                            jQ('ul.itemList').prepend(html);
                        })
                    },
                    error: function (data) {
                        console.log(data.error);
                    }
                });
            }
        });





            jQ("#spellCheckQuery").click(function () {
                jQ("#query").val(jQ(this).attr('data-spell'));
                jQ("#main-query-submit").click();

            });
            jQ("#filterquery")
                    .autocomplete({
                        source: function (request, response) {
                            jQ.ajax({
                                url: "<%= request.getContextPath()%>/json/discovery/autocomplete?query=<%= URLEncoder.encode(query, "UTF-8")%><%= httpFilters.replaceAll("&amp;", "&")%>",
                                dataType: "json",
                                cache: false,
                                data: {
                                    auto_idx: jQ("#filtername").val(),
                                    auto_query: request.term,
                                    auto_sort: 'count',
                                    auto_type: jQ("#filtertype").val(),
                                    location: '<%= searchScope%>'
                                },
                                success: function (data) {
                                    response(jQ.map(data.autocomplete, function (item) {
                                        var tmp_val = item.authorityKey;
                                        if (tmp_val == null || tmp_val == '') {
                                            tmp_val = item.displayedValue;
                                        }
                                        return {
                                            label: item.displayedValue + " (" + item.count + ")",
                                            value: tmp_val
                                        };
                                    }))
                                }
                            })
                        }
                    });
        });

        function isEmptyOrSpaces(str){
            return str === null || str.match(/^ *$/) !== null;
        }
        //Icon animation logic
        function filterSearchIcon(){
            var filter = jQ("#filterquery").val();
                if(isEmptyOrSpaces(filter)){
                    jQ(".search.icon").hide();
                }else {
                    jQ(".search.icon").show();
                }
              jQ("#filterquery").on('input',function(e){
                     filter = jQ("#filterquery").val();
                        if(isEmptyOrSpaces(filter)){
                            jQ(".search.icon").hide();
                        }else {
                            jQ(".search.icon").show();
                        }
                    });
        }
        function formataIdiomas() {
            var idiomas = [
                {"id":"pt","value": "Português (pt)"},
                {"id":"pt-br","value": "Português (pt-br)"},
                {"id":"pt_BR","value": "Português (pt-br)"},
                {"id":"por_br","value": "Português (pt-br)"},
                {"id":"por","value":"Português (por)"},
                {"id":"spa","value":"Espanhol (spa)"},
                {"id":"es","value":"Espanhol (es)"},
                {"id":"ita","value":"Italiano (ita)"},
                {"id":"it","value":"Italiano (ita)"},
                {"id":"eng","value":"Inglês (eng)"},
                {"id":"en","value":"Inglês (en)"},
                {"id":"en_us","value":"Inglês (en_us)"},
                {"id":"na","value":"Inglês (en)"},
                {"id":"deu","value":"Alemão (deu)"},
                {"id":"de","value":"Alemão (de)"},
                {"id":"fra","value":"Francês (fr)"},
                {"id":"fr","value":"Francês (fr)"},
                {"id":"cat","value":"Catalão (cat)"},
                {"id":"pol","value":"Polonês (pol)"},
                {"id":"pl","value":"Polonês (pl)"},
                {"id":"abk","value":"Abecásio (abk)"},
                {"id":"zho","value":"Chinês (zho)"},
                {"id":"zh","value":"Chinês (zh)"},
                {"id":"jpn","value":"Japonês (jpn)"},
                {"id":"jp","value":"Japonês (jpn)"},
                {"id":"nau","value":"Nauruano (nau)"},
                {"id":"lat","value":"Latim (lat)"},
                {"id":"glg","value":"Galego (glg)"}
            ];

            jQ('p#language').each(function(spanIndex, spanItem) {
                var optionsObject = jQ(this);
                jQ.each(idiomas, function(i) {
                // console.log(idiomas[i].id.toLowerCase() === optionsObject.text().toLowerCase(), idiomas[i].id.toLowerCase(),optionsObject.text().toLowerCase());
                    if (optionsObject.text().toLowerCase().replace(" ","") === idiomas[i].id.toLowerCase()){
                        optionsObject.text(idiomas[i].value);
                    }
                });

            });
        }

        //Validate Filters apply
        function validateFilters() {
            return document.getElementById("filterquery").value.length > 0;
        }
        //Menu logic dropdown Semantic UI
        function searchDropdownMenu(){
            jQ('.ui.search.dropdown').dropdown();
            jQ('div#dropdownBuscador a.text div.item div.text').html(jQ("select#tlocation option").filter(":selected").attr('name'));
            jQ('div#dropdownBuscador.ui.search.selection.dropdown a.text').html(jQ("select#tlocation option").filter(":selected").attr('name'));
            jQ("div#dropdownBuscador input").bind("enterKey",function(e){
                var out = jQ('div.item.active.selected div.item').attr('value');
                if(out === undefined){
                    out = jQ('div.item.active.selected').attr('value');
                    jQ("select#tlocation option").filter(":selected").val(out);
                    // console.log(out);
                }else{
                    jQ("select#tlocation option").filter(":selected").val(out);
                    // console.log(out);
                }
            });

            jQ("div#dropdownBuscador input").keyup(function(e){
                if(e.keyCode == 13)
                {
                    jQ(this).trigger("enterKey");
                }
            });
            jQ('.ui.search.dropdown, #dropdownBuscador').dropdown({
                allowCategorySelection: true,
                message: {
                    count         : '{count} selecionados',
                    maxSelections : 'Máximo de {maxCount} seleções',
                    noResults     : 'Não encontrado.',
                    serverError   : 'Erro de conexão com servidor'
                },
                onChange: function(value, text, $choice){
                    var choices = $choice.attr('value');
                    if (choices != undefined){
                        jQ("select#tlocation option").filter(":selected").val(choices);
                    }
                }
            });
        }

        function readMore(){
            jQ('div.t2').each(function (idx,item) {
                if(jQ(this).html().length > 500){
                    jQ(this).css("height","5em");
                    jQ(this).css("padding","2px");
                    jQ(this).css("overflow","hidden");
                    jQ(this).append("<div align='center'><span class='minusContent glyphicon glyphicon-chevron-up'></span></div>");
                }
            });
            jQ('.minusContent').css("color","green");
            var test;
            jQ('div.t2').on('click',function () {
                test = jQ(this);
            });
            jQ.fn.toggleClick = function (funcArray) {
                return this.click(function () {
                    var elem = jQ(this);
                    var index = elem.data('index') || 0;

                    funcArray[index]();
                    elem.data('index', (index + 1) % funcArray.length);
                });
            };
            jQ('div.t2').toggleClick([

                function () {
                    if(test.html().length > 500){
                        jQ(test).css("height","");
                    }
                },

                function () {
                    if(test.html().length > 500){
                        jQ(test).css("height","5em");
                    }
                }
            ]);
        }


    </script>
</c:set>

<dspace:layout titlekey="jsp.search.title">

    <div class="col-md-9 pull-right">
    <div class="buscas">
            <%-- Controls for a repeat search --%>
            <%--String bsLink = "https://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();--%>
        <div class="discovery-query panel-heading">

            <form action="simple-search" method="get">
                <label for="tlocation">
                    <fmt:message key="jsp.search.results.searchin"/>
                </label>

                <% if (communitiees.length != 0) {%>
                <div class="ui search selection dropdown" id="dropdownBuscador">
                    <a class="text">Todo o repositório</a>
                    <i class="dropdown icon"></i>
                    <div  class="menu">
                        <div class="item">
                            <div class="item" value="/">
                                <div class="text" value="/">Todo o repositório</div>
                            </div>
                        </div>
                    <% for (int i = 0; i < communitiees.length; i++) {
                        out.println("<div  class=\"item\">\n");
                                    showCommunityy(communitiees[i], out, request, ic, collectionMap, subcommunityMap);
                        out.println("</div>");
                                } %>
                      </div>
                </div>
                <% }%>


                <select class="hidden"  name="location" id="tlocation">
                    <%
                        if (scope == null) {
                            // Scope of the search was all of DSpace.  The scope control will list
                            // "all of DSpace" and the communities.
                    %>
                    <option selected="selected" value="/"><fmt:message key="jsp.general.genericScope"/></option>
                    <% } else {
                    %>
                    <option value="/"><fmt:message key="jsp.general.genericScope"/></option>

                    <% }
                        for (DSpaceObject dso : scopes) {
                    %>
                    <option id="<%=dso.getID()%>" name="<%=dso.getName()%>"
                            value="<%= dso.getHandle()%>" <%=dso.getHandle().equals(searchScope) ? "selected=\"selected\"" : ""%>>
                        <%= dso.getName()%>
                    </option>
                    <%

                        }
                    %>

                </select>
                <label for="query"><fmt:message key="jsp.search.results.searchfor"/></label>

                <div class="ui input focus">
                      <input type="text" size="31" id="query" name="query" value="<%= (query == null ? "" : Utils.addEntities(query))%>"/>
                    <input type="submit" id="main-query-submit" class="ir" value="<fmt:message key="jsp.general.go"/>"/>
                </div>

                <%--<div>--%>
                <%--</div>--%>
                <div id="query-mobile-hide" class="hidden" align="center">
                    <button type="submit" class="btn btn-success">
                        <span class="glyphicon glyphicon-search"></span>
                    </button>
                </div>


                <% if (StringUtils.isNotBlank(spellCheckQuery)) {%>
                <p class="lead"><fmt:message key="jsp.search.didyoumean"><fmt:param><a id="spellCheckQuery"
                                                                                       data-spell="<%= Utils.addEntities(spellCheckQuery)%>"
                                                                                       href="#"><%=spellCheckQuery%>
                </a></fmt:param></fmt:message></p>
                <% }%>
                <input type="hidden" value="<%= rpp%>" name="rpp"/>
                <input type="hidden" value="<%= Utils.addEntities(sortedBy)%>" name="sort_by"/>
                <input type="hidden" value="<%= Utils.addEntities(order)%>" name="order"/>
                <% if (appliedFilters.size() > 0) { %>
                <div class="discovery-search-appliedFilters">
                    <label class="descricaoLabel"><fmt:message key="jsp.search.filter.applied"/></label><br/>
                    <%
                        int idx = 1;
                        for (String[] filter : appliedFilters) {
                            boolean found = false;
                    %>
                    <select class="ui search dropdown" id="filter_field_<%=idx%>" name="filter_field_<%=idx%>">
                        <%
                            for (DiscoverySearchFilter searchFilter : availableFilters) {
                                String fkey = "jsp.search.filter." + Escape.uriParam(searchFilter.getIndexFieldName());
                        %>
                        <option value="<%= Utils.addEntities(searchFilter.getIndexFieldName())%>"<%
                            if (filter[0].equals(searchFilter.getIndexFieldName())) {
                        %> selected="selected"<%
                                found = true;
                            }
                        %>><fmt:message key="<%= fkey%>"/></option>
                        <%
                            }
                            if (!found) {
                                String fkey = "jsp.search.filter." + Escape.uriParam(filter[0]);
                        %>
                        <option value="<%= Utils.addEntities(filter[0])%>" selected="selected"><fmt:message
                                key="<%= fkey%>"/></option>
                        <%
                            }
                        %>
                    </select>
                    <select class="ui search dropdown" id="filter_type_<%=idx%>" name="filter_type_<%=idx%>">
                        <%
                            for (String opt : options) {
                                String fkey = "jsp.search.filter.op." + Escape.uriParam(opt);
                        %>
                        <option value="<%= Utils.addEntities(opt)%>"<%= opt.equals(filter[1]) ? " selected=\"selected\"" : ""%>>
                            <fmt:message key="<%= fkey%>"/></option>
                        <%
                            }
                        %>
                    </select>
                    <div class="ui input">

                    <input class="ui-autocomplete-input" type="text" id="filter_value_<%=idx%>" name="filter_value_<%=idx%>"
                           value="<%= Utils.addEntities(filter[2])%>" size="45"/>
                    </div>
                    <input class="btn btn-danger btn-sm remove" type="submit" id="submit_filter_remove_<%=idx%>"
                           name="submit_filter_remove_<%=idx%>" value="X"/>
                    <br/>
                    <br/>
                    <%
                            idx++;
                        }
                    %>
                </div>
                <% }%>
                <div class="botoes">

                <% if (availableFilters.size() > 0) {%>
                <button type="button" class="add-filtro" id="showSearchFilters" href="#filterquery"><fmt:message
                        key="jsp.search.general.add.filter"/></button>

                <% } %>
                <a class="del-filtro" data-toggle="tooltip" data-placement="top" title="" data-original-title="Limpar filtros"
                   href="<%= request.getContextPath() + "/simple-search"%>"><fmt:message
                        key="jsp.search.general.new-search"/></a>
                </div>

            </form>
        </div>
        <% if (availableFilters.size() > 0) {%>
        <div id="searchFilterPanel" class="filtros hidden">

            <div class="col-md-10"><label class="descricaoLabel"><fmt:message key="jsp.search.filter.heading"/></label></div>
            <div class="col-md-10"><label class="descricao"><fmt:message key="jsp.search.filter.hint"/></label></div>
            <form action="simple-search" method="get">
                <input type="hidden" value="<%= Utils.addEntities(searchScope)%>" name="location"/>
                <input type="hidden" value="<%= Utils.addEntities(query)%>" name="query"/>
                <% if (appliedFilterQueries.size() > 0) {
                    int idx = 1;
                    for (String[] filter : appliedFilters) {
                        boolean found = false;
                %>
                <div class="ui input">

                <input class="ui-autocomplete-input" type="hidden" id="filter_field_<%=idx%>" name="filter_field_<%=idx%>"
                       value="<%= Utils.addEntities(filter[0])%>"/>
                <input class="ui-autocomplete-input" type="hidden" id="filter_type_<%=idx%>" name="filter_type_<%=idx%>"
                       value="<%= Utils.addEntities(filter[1])%>"/>
                <input class="ui-autocomplete-input" type="hidden" id="filter_value_<%=idx%>" name="filter_value_<%=idx%>"
                       value="<%= Utils.addEntities(filter[2])%>"/>
                </div>
                <%
                            idx++;
                        }
                    } %>
                <select class="ui search dropdown" id="filtername" name="filtername">
                    <%
                        for (DiscoverySearchFilter searchFilter : availableFilters) {
                            String fkey = "jsp.search.filter." + Escape.uriParam(searchFilter.getIndexFieldName());
                    %>
                    <option value="<%= Utils.addEntities(searchFilter.getIndexFieldName())%>"><fmt:message
                            key="<%= fkey%>"/></option>
                    <%
                        }
                    %>
                </select>
                <select class="ui search dropdown" id="filtertype" name="filtertype">
                    <%
                        for (String opt : options) {
                            String fkey = "jsp.search.filter.op." + Escape.uriParam(opt);
                    %>
                    <option value="<%= Utils.addEntities(opt)%>"><fmt:message key="<%= fkey%>"/></option>
                    <%
                        }
                    %>
                </select>
                <div class="ui icon ui input loading">
                    <input class="ui-autocomplete-input" type="text" id="filterquery" name="filterquery" size="20" required="required"/>
                    <i class="search icon"></i>
                    <input type="hidden" value="<%= rpp%>" name="rpp"/>
                    <input type="hidden" value="<%= Utils.addEntities(sortedBy)%>" name="sort_by"/>
                    <input type="hidden" value="<%= Utils.addEntities(order)%>" name="order"/>
                </div>
                <div class="botoes">
                    <button class="adicionar" type="submit"  onclick="return validateFilters()"><fmt:message key="jsp.search.filter.add"/></button>
                <%--<input class="btn btn-success  btn-sm applay" type="submit" value="<fmt:message key="jsp.search.filter.add"/>" onclick="return validateFilters()"/>--%>
                </div>


                <div align="center" class="col-md-2">
                    <button class="ocultar" type="reset" id="hideSearchFilters" href="#"><fmt:message key="jsp.search.general.hide.filter"/></button>
                </div>
            </form>
        </div>
        <% }%>
    </div>
    <%
        DiscoverResult qResults = (DiscoverResult) request.getAttribute("queryresults");
        Item[] items = (Item[]) request.getAttribute("items");
        Community[] communities = (Community[]) request.getAttribute("communities");
        Collection[] collections = (Collection[]) request.getAttribute("collections");

        if (error) {
    %>
    <p align="center" class="submitFormWarn">
        <fmt:message key="jsp.search.error.discovery"/>
    </p>
    <%
    } else if (qResults != null && qResults.getTotalSearchResults() == 0) {
    %>
    <%-- <p align="center">Search produced no results.</p> --%>
    <p align="center"><fmt:message key="jsp.search.general.noresults"/></p>
    <%
    } else if (qResults != null) {
        long pageTotal = ((Long) request.getAttribute("pagetotal")).longValue();
        long pageCurrent = ((Long) request.getAttribute("pagecurrent")).longValue();
        long pageLast = ((Long) request.getAttribute("pagelast")).longValue();
        long pageFirst = ((Long) request.getAttribute("pagefirst")).longValue();

        // create the URLs accessing the previous and next search result pages
        String baseURL = request.getContextPath()
                + (!searchScope.equals("") ? "/handle/" + searchScope : "")
                + "/simple-search?query="
                + URLEncoder.encode(query, "UTF-8")
                + httpFilters
                + "&amp;sort_by=" + sortedBy
                + "&amp;order=" + order
                + "&amp;rpp=" + rpp
                + "&amp;etal=" + etAl
                + "&amp;start=";

        String nextURL = baseURL;
        String firstURL = baseURL;
        String lastURL = baseURL;

        String prevURL = baseURL
                + (pageCurrent - 2) * qResults.getMaxResults();

        nextURL = nextURL
                + (pageCurrent) * qResults.getMaxResults();

        firstURL = firstURL + "0";
        lastURL = lastURL + (pageTotal - 1) * qResults.getMaxResults();


    %>
    <div class="paginacao">
        <% long lastHint = qResults.getStart() + qResults.getMaxResults() <= qResults.getTotalSearchResults()
                ? qResults.getStart() + qResults.getMaxResults() : qResults.getTotalSearchResults();
        %>
            <%-- <p align="center">Results <//%=qResults.getStart()+1%>-<//%=qResults.getStart()+qResults.getHitHandles().size()%> of --%>
        <div class="paginacao"><fmt:message key="jsp.search.results.results">
            <fmt:param><%=qResults.getStart() + 1%>
            </fmt:param>
            <fmt:param><%=lastHint%>
            </fmt:param>
            <fmt:param><%=qResults.getTotalSearchResults()%>
            </fmt:param>
            <fmt:param><%=(float) qResults.getSearchTime() / 1000%>
            </fmt:param>
        </fmt:message>
            <a id="searchGear" class="pull-right" href="#paginationSearch" data-toggle="tooltip" data-placement="right" title=""
               data-original-title="Ordenar busca">
                <span class="glyphicon glyphicon-cog"></span>
            </a>
        </div>
            <%-- Include a component for modifying sort by, order, results per page, and et-al limit --%>
        <%--<div id="botao">botao</div>--%>
        <div id="paginationSearch" class="discovery-pagination-controls panel-footer hidden">

            <form action="simple-search" method="get">
                <input type="hidden" value="<%= Utils.addEntities(searchScope)%>" name="location"/>
                <input type="hidden" value="<%= Utils.addEntities(query)%>" name="query"/>
                <% if (appliedFilterQueries.size() > 0) {
                    int idx = 1;
                    for (String[] filter : appliedFilters) {
                        boolean found = false;
                %>
                <div class="ui input">

                <input class="ui-autocomplete-input" type="hidden" id="filter_field_<%=idx%>" name="filter_field_<%=idx%>"
                       value="<%= Utils.addEntities(filter[0])%>"/>
                <input class="ui-autocomplete-input" type="hidden" id="filter_type_<%=idx%>" name="filter_type_<%=idx%>"
                       value="<%= Utils.addEntities(filter[1])%>"/>
                <input class="ui-autocomplete-input" type="hidden" id="filter_value_<%=idx%>" name="filter_value_<%=idx%>"
                       value="<%= Utils.addEntities(filter[2])%>"/>
                </div>
                <%
                            idx++;
                        }
                    } %>
                <label for="rpp"><fmt:message key="search.results.perpage"/></label>
                <select class="ui search dropdown" name="rpp">
                    <%
                        for (int i = 5; i <= 100; i += 5) {
                            String selected = (i == rpp ? "selected=\"selected\"" : "");
                    %>
                    <option value="<%= i%>" <%= selected%>><%= i%>
                    </option>
                    <%
                        }
                    %>
                </select>
                &nbsp;|&nbsp;
                <%
                    if (sortOptions.size() > 0) {
                %>
                <label for="sort_by"><fmt:message key="search.results.sort-by"/></label>
                <select class="ui search dropdown" name="sort_by">
                    <option value="score"><fmt:message key="search.sort-by.relevance"/></option>
                    <%
                        for (String sortBy : sortOptions) {
                            String selected = (sortBy.equals(sortedBy) ? "selected=\"selected\"" : "");
                            String mKey = "search.sort-by." + Utils.addEntities(sortBy);
                    %>
                    <option value="<%= Utils.addEntities(sortBy)%>" <%= selected%>><fmt:message
                            key="<%= mKey%>"/></option>
                    <%
                        }
                    %>
                </select>
                <%
                    }
                %>
                <label for="order"><fmt:message key="search.results.order"/></label>


                <select class="ui search dropdown" name="order">
                    <option value="ASC" <%= ascSelected%>><fmt:message key="search.order.asc"/></option>
                    <option value="DESC" <%= descSelected%>><fmt:message key="search.order.desc"/></option>
                </select>
                <label for="etal"><fmt:message key="search.results.etal"/></label>
                <select class="ui search dropdown" name="etal">
                    <%
                        String unlimitedSelect = "";
                        if (etAl < 1) {
                            unlimitedSelect = "selected=\"selected\"";
                        }
                    %>
                    <option value="0" <%= unlimitedSelect%>><fmt:message key="browse.full.etal.unlimited"/></option>
                    <%
                        boolean insertedCurrent = false;
                        for (int i = 0; i <= 50; i += 5) {
                            // for the first one, we want 1 author, not 0
                            if (i == 0) {
                                String sel = (i + 1 == etAl ? "selected=\"selected\"" : "");
                    %>
                    <option value="1" <%= sel%>>1</option>
                    <%
                        }

                        // if the current i is greated than that configured by the user,
                        // insert the one specified in the right place in the list
                        if (i > etAl && !insertedCurrent && etAl > 1) {
                    %>
                    <option value="<%= etAl%>" selected="selected"><%= etAl%>
                    </option>
                    <%
                            insertedCurrent = true;
                        }

                        // determine if the current not-special case is selected
                        String selected = (i == etAl ? "selected=\"selected\"" : "");

                        // do this for all other cases than the first and the current
                        if (i != 0 && i != etAl) {
                    %>
                    <option value="<%= i%>" <%= selected%>><%= i%>
                    </option>
                    <%
                            }
                        }
                    %>
                </select>
                <br/>
                <br/>
                <div align="center">
                    <input align="center" class="btn btn-warning" type="submit" name="submit_search"
                           value="<fmt:message key="search.update" />"/>
                </div>
                <%
                    if (admin_button) {
                %><input type="submit" class="btn btn-warning" name="submit_export_metadata"
                         value="<fmt:message key="jsp.general.metadataexport.button"/>"/><%
                }
            %>
            </form>
        </div>
        <div class="paginacao">
        <ul>
            <%
                if (pageFirst != pageCurrent) {
            %>
            <li class="anterior"><a aria-label="Previous" href="<%= prevURL%>"><span aria-hidden="true">&laquo;</span><%--<fmt:message key="jsp.search.general.previous" />--%>
            </a></li>
            <%
            } else {
            %>
            <li class="disabled hidden"><span aria-hidden="true">&laquo;</span><%--<fmt:message key="jsp.search.general.previous" />--%>
            </li>
            <%
                }

                if (pageFirst != 1) {
            %>
            <li><a href="<%= firstURL%>">1</a></li>
            <li class="disabled"><span>...</span></li>
            <%
                }

                for (long q = pageFirst; q <= pageLast; q++) {
                    String myLink = "<li><a href=\""
                            + baseURL;

                    if (q == pageCurrent) {
                        myLink = "<li class=\"active\"><span>" + q + "</span></li>";
                    } else {
                        myLink = myLink
                                + (q - 1) * qResults.getMaxResults()
                                + "\">"
                                + q
                                + "</a></li>";
                    }
            %>

            <%=myLink%>

            <%
                }

                if (pageTotal > pageLast) {
            %>
            <li class="disabled"><span>...</span></li>
            <li><a href="<%= lastURL%>"><%= pageTotal%>
            </a></li>
            <%
                }
                if (pageTotal > pageCurrent) {
            %>
            <li><a href="<%= nextURL%>"><%--<fmt:message key="jsp.search.general.next" />--%><span
                    aria-hidden="true">»</span></a></li>
            <%
            } else {
            %>
            <li class="disabled hidden"><span><a href="#" aria-label="Next"></a><%--<fmt:message key="jsp.search.general.next" />--%><span
                    aria-hidden="true">»</span></span></li>
            <%
                }
            %>
        </ul>
        </div>
        <!-- give a content to the div -->
    </div>
    <div id="resultado-busca" class="resultado-busca">
        <% if (communities.length > 0) { %>
        <div class="panel panel-info">
            <div class="panel-heading"><fmt:message key="jsp.search.results.comhits"/></div>
            <dspace:communitylist communities="<%= communities %>"/>
        </div>
        <% } %>

        <% if (collections.length > 0) { %>
        <div class="panel panel-info">
            <div class="panel-heading"><fmt:message key="jsp.search.results.colhits"/></div>
            <dspace:collectionlist collections="<%= collections %>"/>
        </div>
        <% } %>
        <% if (items.length > 0) {%>
            <dspace:itemlist items="<%= items%>" authorLimit="<%= etAl%>"/>
        <% } %>
    </div>
    </div>
    <%-- if the result page is enought long... --%>
    <% if ((communities.length + collections.length + items.length) > 10) {%>
    <%-- show again the navigation info/links --%>
    <div class="paginacao">
            <%-- <p align="center">Results <//%=qResults.getStart()+1%>-<//%=qResults.getStart()+qResults.getHitHandles().size()%> of --%>
        <p><fmt:message key="jsp.search.results.results">
            <fmt:param><%=qResults.getStart() + 1%></fmt:param>
            <fmt:param><%=lastHint%>
            </fmt:param>
            <fmt:param><%=qResults.getTotalSearchResults()%>
            </fmt:param>
            <fmt:param><%=(float) qResults.getSearchTime() / 1000%>
            </fmt:param>
        </fmt:message></p>
        <ul class="pagination pull-right">
            <%
                if (pageFirst != pageCurrent) {
            %>
            <li><a href="<%= prevURL%>"><fmt:message key="jsp.search.general.previous"/></a></li>
            <%
            } else {
            %>
            <li class="disabled"><span><fmt:message key="jsp.search.general.previous"/></span></li>
            <%
                }

                if (pageFirst != 1) {
            %>
            <li><a href="<%= firstURL%>">1</a></li>
            <li class="disabled"><span>...</span></li>
            <%
                }

                for (long q = pageFirst; q <= pageLast; q++) {
                    String myLink = "<li><a href=\""
                            + baseURL;

                    if (q == pageCurrent) {
                        myLink = "<li class=\"active\"><span>" + q + "</span></li>";
                    } else {
                        myLink = myLink
                                + (q - 1) * qResults.getMaxResults()
                                + "\">"
                                + q
                                + "</a></li>";
                    }
            %>

            <%= myLink%>

            <%
                }

                if (pageTotal > pageLast) {
            %>
            <li class="disabled"><span>...</span></li>
            <li><a href="<%= lastURL%>"><%= pageTotal%>
            </a></li>
            <%
                }
                if (pageTotal > pageCurrent) {
            %>
            <li><a href="<%= nextURL%>"><fmt:message key="jsp.search.general.next"/></a></li>
            <%
            } else {
            %>
            <li class="disabled hidden"><span><fmt:message key="jsp.search.general.next"/></span></li>
            <%
                }
            %>
        </ul>
        <!-- give a content to the div -->
    </div>

    <% } %>
    <% } %>

    <dspace:sidebar>
        <%
            boolean brefine = false;

            List<DiscoverySearchFilterFacet> facetsConf = (List<DiscoverySearchFilterFacet>) request.getAttribute("facetsConfig");
            Map<String, Boolean> showFacets = new HashMap<String, Boolean>();

            for (DiscoverySearchFilterFacet facetConf : facetsConf) {
                if (qResults != null) {
                    String f = facetConf.getIndexFieldName();
                    List<FacetResult> facet = qResults.getFacetResult(f);
                    if (facet.size() == 0) {
                        facet = qResults.getFacetResult(f + ".year");
                        if (facet.size() == 0) {
                            showFacets.put(f, false);
                            continue;
                        }
                    }
                    boolean showFacet = false;
                    for (FacetResult fvalue : facet) {
                        if (!appliedFilterQueries.contains(f + "::" + fvalue.getFilterType() + "::" + fvalue.getAsFilterQuery())) {
                            showFacet = true;
                            break;
                        }
                    }
                    showFacets.put(f, showFacet);
                    brefine = brefine || showFacet;
                }
            }
            if (brefine) {
        %>


                <h3><fmt:message key="jsp.search.facet.refine"/></h3>
                <!--| Tipo de arquivo-->

            <%
                for (DiscoverySearchFilterFacet facetConf : facetsConf) {
                    String f = facetConf.getIndexFieldName();
                    if (!showFacets.get(f)) {
                        continue;
                    }
                    List<FacetResult> facet = qResults.getFacetResult(f);
                    if (facet.size() == 0) {
                        facet = qResults.getFacetResult(f + ".year");
                    }
                    int limit = facetConf.getFacetLimit() + 1;

                    String fkey = "jsp.search.facet.refine." + f;
            %>

                    <%--Current page--%>
                <%
                    int idx = 1;
                    int currFp = UIUtil.getIntParameter(request, f + "_page");
                    if (currFp < 0) { currFp = 0; }
                %>






        <%--<%=currFp%>--%>
                <ul>
                    <%--Rule open menu--%>
                    <%if(f.equals("language") || f.equals("type")){%>
                          <%if(currFp > 0){%>
                                <li class="dropdown open">
                           <%}else{%> <li class="dropdown">  <%}%>
                    <%}else{%> <li  class="dropdown"> <%}%>


                        <a data-toggle="dropdown" href="#" class="dropdown-toggle">
                            <fmt:message key="<%=fkey%>"/><span class="caret"></span></a>
                        <ul class="dropdown-menu">
                              <%
                                String padronizador = "";
                                String tipo = "";
                                String plataformas = "POCA UEMA UFRGS FUNAG UNICAMP-COURSERA RELLE REMAR VLIBRAS";
                                for (FacetResult fvalue : facet) {
                                    if (idx != limit && !appliedFilterQueries.contains(f + "::" + fvalue.getFilterType() + "::" + fvalue.getAsFilterQuery())) {
                                        String discoveryFileTypeClass = null;
                                        if (f.equals("type")) {
                                            padronizador = Normalizer.normalize(fvalue.getDisplayedValue(), Normalizer.Form.NFD);
                                              tipo = padronizador.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
                                              tipo = tipo.replaceAll(" ","").toLowerCase();
                                                if (plataformas.contains(fvalue.getDisplayedValue())) {
                                                    discoveryFileTypeClass = "central-conteudo dicovery-plataforma-"+tipo;
                                                }else{
                                                    discoveryFileTypeClass = "central-conteudo dicovery-"+tipo;
                                                }
                                        } else if (f.equals("language")){
                                            discoveryFileTypeClass = "central-conteudo discovery-language-"+fvalue.getDisplayedValue().toLowerCase();
                                        }%>
                                   <%if(plataformas.contains(fvalue.getDisplayedValue())){%>
                                       <li class="hide">
                                   <%}else {%>
                            <li>
                                 <%}%>
                                    <%--Images--%>
                            <%--         <a data-toggle="tooltip" data-placement="right"  class="link-central-multimidia <%=f%>" href="<%= request.getContextPath()
                                            + (!searchScope.equals("") ? "/handle/" + searchScope : "")
                                            + "/simple-search?query="
                                            + URLEncoder.encode(query, "UTF-8")
                                            + "&amp;sort_by=" + sortedBy
                                            + "&amp;order=" + order
                                            + "&amp;rpp=" + rpp
                                            + httpFilters
                                            + "&amp;etal=" + etAl
                                            + "&amp;filtername=" + URLEncoder.encode(f, "UTF-8")
                                            + "&amp;filterquery=" + URLEncoder.encode(fvalue.getAsFilterQuery(), "UTF-8")
                                            + "&amp;filtertype=" + URLEncoder.encode(fvalue.getFilterType(), "UTF-8")%>"
                                             title="<fmt:message key="jsp.search.facet.narrow"><fmt:param><%=fvalue.getDisplayedValue()%></fmt:param></fmt:message>">
                                            <% if (discoveryFileTypeClass != null) {%>
                                                <%if (discoveryFileTypeClass.contains("plataforma")){%>
                                                    <div class="bgIconBuscaLegendaNoback">
                                                        <div class="<%=discoveryFileTypeClass%>"></div>
                                                    </div>
                                                    <%}else if(f.equals("language")){%>
                                                    <div class="bgIconBuscaLegendaNoback">
                                                        <div class="<%=discoveryFileTypeClass%>"></div>
                                                    </div>
                                                    <%}else{%>
                                                    <div class="bgIconBuscaLegenda">
                                                        <div class="<%=discoveryFileTypeClass%>"></div>
                                                    </div>
                                                <%}%>
                                            <%}%>
                                        </a>--%>

                                     <a data-toggle="tooltip" data-placement="right"   class="link-central-multimidia <%=f%>" href="<%= request.getContextPath()
                                        + (!searchScope.equals("") ? "/handle/" + searchScope : "")
                                        + "/simple-search?query="
                                        + URLEncoder.encode(query, "UTF-8")
                                        + "&amp;sort_by=" + sortedBy
                                        + "&amp;order=" + order
                                        + "&amp;rpp=" + rpp
                                        + httpFilters
                                        + "&amp;etal=" + etAl
                                        + "&amp;filtername=" + URLEncoder.encode(f, "UTF-8")
                                        + "&amp;filterquery=" + URLEncoder.encode(fvalue.getAsFilterQuery(), "UTF-8")
                                        + "&amp;filtertype=" + URLEncoder.encode(fvalue.getFilterType(), "UTF-8")%>"
                                       title="<fmt:message key="jsp.search.facet.narrow"><fmt:param><%=fvalue.getDisplayedValue()%></fmt:param></fmt:message>">
                                        <% if (discoveryFileTypeClass != null) {%>
                                            <%--<div><%= discoveryFileTypeClass%></div>--%>
                                         <%}%>
                                        <%--<div class="texto-central-multimidia <%=f%>">--%>
                                        <div class="langClass col-md-8 <%=f%>">
                                            <% if (discoveryFileTypeClass != null) {%>
                                            <%if (discoveryFileTypeClass.contains("plataforma")){%>
                                            <div class="bgIconBuscaLegendaNoback">
                                                <div class="<%=discoveryFileTypeClass%>"></div>
                                            </div>
                                            <%}else if(f.equals("language")){%>
                                            <div class="">
                                                <div class="<%=discoveryFileTypeClass%>"></div>
                                            </div>
                                            <%}else{%>
                                            <div class="bgIconBuscaLegenda">
                                                <div class="<%=discoveryFileTypeClass%>"></div>
                                            </div>
                                            <%}%>
                                            <%}%>
                                                <p class="menu-lateral-center" id="<%=f.toLowerCase()%>"><%=StringUtils.abbreviate(fvalue.getDisplayedValue(), 36)%></p>
                                            <% if (discoveryFileTypeClass != null) {%>
                                                <% if (discoveryFileTypeClass.contains("plataforma")) {%>
                                                <%} else {%>
                                            &nbsp<div class="menu-lateral-center"><span class="badge"><%=fvalue.getCount()%></span></div>
                                                <%}%>
                                             <%}%>
                                        </div>
                                     </a>
                            </li>

                            <%idx++;}
                                 if (idx > limit) {
                                      break;
                                 }
                            }
                                if (currFp > 0 || idx == limit) {%>

                                <div class="previousNext col-md-10" style="display: inline-flex; float:right">
                                <% if (currFp > 0) {%>
                            <%--Buttons previous - next--%>
                                <a  id="backpaginationbutton" href="<%= request.getContextPath()
                                    + (!searchScope.equals("") ? "/handle/" + searchScope : "")
                                    + "/simple-search?query="
                                    + URLEncoder.encode(query, "UTF-8")
                                    + "&amp;sort_by=" + sortedBy
                                    + "&amp;order=" + order
                                    + "&amp;rpp=" + rpp
                                    + httpFilters
                                    + "&amp;etal=" + etAl
                                    + "&amp;" + f + "_page=" + (currFp - 1)%>">
                                    <span class="btn-sm btn-primary">
                                     <fmt:message key="jsp.search.facet.refine.previous"/>
                                    </span>
                                </a>
                                        <%}%>
                                        <% if (idx == limit) {%>

                                <a   href="<%= request.getContextPath()
                                    + (!searchScope.equals("") ? "/handle/" + searchScope : "")
                                    + "/simple-search?query="
                                    + URLEncoder.encode(query, "UTF-8")
                                    + "&amp;sort_by=" + sortedBy
                                    + "&amp;order=" + order
                                    + "&amp;rpp=" + rpp
                                    + httpFilters
                                    + "&amp;etal=" + etAl
                                    + "&amp;" + f + "_page=" + (currFp + 1)%>">
                                     <span class="btn-sm btn-primary">
                                         <fmt:message key="jsp.search.facet.refine.next"/>
                                     </span>
                                </a>
                                <%}%>

                                </div>
                            <%}%>
                        </ul>
                    </li>
                </ul>
            <%}%>
        <%}%>
    </dspace:sidebar>

</dspace:layout>

