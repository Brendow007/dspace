<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.harvest.HarvestedCollection" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%--
  Created by IntelliJ IDEA.
  User: brendows
  Date: 29/06/2018
  Time: 16:44
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%
    HarvestedCollection collection = (HarvestedCollection) request.getAttribute("harvestedCol");
    String msg = (String) request.getAttribute("msg");
%>
<dspace:layout locbar="commLink" title="Editando coleção" navbar="admin">

    <%if (collection != null) {%>
    <div class="col-md-10">
        <div align="center">
            <h3><%=collection.getCollection().getName()%></h3>
        </div>
        <div>
            <%=collection.getCollectionId()%>
        </div>
        <div>
            <%=collection.getHarvestStatus()%>
        </div>
        <div>
            <%=collection.getOaiSetId()%>
        </div>
        <div>
            <%if (collection.getHarvestType() == 0) {%>
                <%} else if (collection.getHarvestType() == 1) {%>
                    Metadados.
                <%} else if (collection.getHarvestType() == 2) {%>
                    Metadados e referência de download.
                <%} else if (collection.getHarvestType() == 3) {%>
                    Metadados e Arquivos.
            <%}%>
        </div>
        <div>
            <%=collection.getOaiSource()%>
        </div>
        Profile:
        <div>
             <h4><%=collection.getProfCollection().getName()%></h4>
            <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-profile">
                <input class="hidden" name="identify" value="<%=collection.getProfCollection().getHandle()%>">
                <input type="hidden" name="action" value="editProf"/>
                <button class="btn btn-primary" type="submit">Editar perfil</button>
            </form>
        </div>
    </div>
    <%}%>
</dspace:layout>