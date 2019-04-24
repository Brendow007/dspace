<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - UI page for selection of collection.
  -
  - Required attributes:
  -    collections - Array of collection objects to show in the drop-down.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>

<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    
    request.setAttribute("LanguageSwitch", "hide");

    //get collections to choose from
    Collection[] collections =
            (Collection[]) request.getAttribute("collections");

    //check if we need to display the "no collection selected" error
    Boolean noCollection = (Boolean) request.getAttribute("no.collection");
    Boolean acceptTerm = (Boolean) request.getAttribute("accept.term");
    Boolean mustAcceptTerm = (Boolean) request.getAttribute("must.accept.term");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);
%>

<dspace:layout style="submission" locbar="off"
               navbar="off"
               titlekey="jsp.submit.select-collection.title"
               nocache="true">

    <script>
        $(document).ready(function () {
            $('#popup').click(function (event) {
                event.preventDefault();
                $.featherlight($("#popupTerm"));
            });
        });

    </script>

    <h1><fmt:message key="jsp.submit.select-collection.heading"/></h1>
    <%-- <span class="mensagemAjuda">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#choosecollection\"%>"><fmt:message key="jsp.morehelp"/> </dspace:popup>
    </span> --%>

    <% if (collections.length > 0) {
    %>
    <p><fmt:message key="jsp.submit.select-collection.info1"/></p>

    <form action="<%= request.getContextPath() %>/submit" method="post" onkeydown="return disableEnterKey(event);">

        <% if ((noCollection != null && noCollection.booleanValue() == true) || (acceptTerm != null && acceptTerm.booleanValue() == false)) { %>

        <div class="alert alert-warning">

                <%--if no collection was selected, display an error--%>
            <% if ((noCollection != null) && (noCollection.booleanValue() == true)) {%>

            <p><fmt:message key="jsp.submit.select-collection.no-collection"/></p>

            <% } %>

                <%--if no collection was selected, display an error--%>
            <% if ((acceptTerm != null) && (acceptTerm.booleanValue() == false)) {%>

            <p><fmt:message key="jsp.submit.select-collection.accept-term"/></p>

            <%}%>

        </div>
        <%
            }
        %>

        <div class="input-group">
            <label for="tcollection" class="input-group-addon">
                <fmt:message key="jsp.submit.select-collection.collection"/>
            </label>
            <dspace:selectcollection klass="form-control" id="tcollection" collection="-1" name="collection"/>
        </div>

        <br/>

        <% if (mustAcceptTerm != null && mustAcceptTerm) {%>
        <strong> <input type="checkbox" name="acceptTerm" id="acceptTerm" value="true"/>&nbsp;<fmt:message
                key="jsp.submit.accept.educapes.term"><fmt:param><a href="#" id="popup">Termos de uso do
            eduCapes</a></fmt:param> </fmt:message></strong>
        <div class="hidden">
            <div id="popupTerm">

                <dspace:include page="/static/pages/submit-term.jsp"/>


            </div>
        </div>
        <br/>
        <br/>

        <ol>
            <li>
                DECLARO para todos os fins legais, que tenho ciência sobre a autoria e/ou titularidade do material e
                suas concessões, da necessidade de licenciamento Creative Commons (CC-BY, CC-BY-NC, CC-BY-SA ou
                CC-BY-NC-SA) ou similar e do respeito aos direitos autorais do material que estou submetendo ao Portal
                eduCAPES;
            </li>
            <br/>
            <li>
                ASSUMO ampla e total responsabilidade quanto à originalidade, à titularidade e ao conteúdo, citações de
                obras consultadas, referências e outros elementos que fazem parte deste material;
            </li>
            <br/>
            <li>
                DECLARO estar ciente de que responderei as sanções previstas na legislação brasileira, pelo uso indevido
                ou não autorizado de qualquer elemento do material a ser submetido, passível de reclamação autoral (Lei
                de Direito Autoral – Lei nº 9610/98).
            </li>
            <br/>
            <li>Caso tenha dúvidas, consulte o <a target="_blank"
                                                  href="<%= request.getContextPath() %>/redirect?action=submission">manual
                para submissão de materiais</a>.
            </li>
        </ol>
        <br/>
        <%
            }
        %>

            <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>

        <div class="row">
            <div class="col-md-4 pull-right btn-group">
                <input class="btn btn-default col-md-6" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>"
                       value="<fmt:message key="jsp.submit.select-collection.cancel"/>"/>
                <input class="btn btn-primary col-md-6" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>"
                       value="<fmt:message key="jsp.submit.general.next"/>"/>
            </div>
        </div>
    </form>
    <% } else { %>
    <p class="alert alert-warning"><fmt:message key="jsp.submit.select-collection.none-authorized"/></p>
    <% } %>
    <p><fmt:message key="jsp.general.goto"/><br/>
        <a href="<%= request.getContextPath() %>"><fmt:message key="jsp.general.home"/></a><br/>
        <a href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.general.mydspace"/></a>
    </p>
    <script src="<%= request.getContextPath()%>/featherlight-1.5.0/release/featherlight.min.js" type="text/javascript"
            charset="utf-8"></script>
</dspace:layout>
