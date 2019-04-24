<%--
  Created by IntelliJ IDEA.
  User: brendows
  Date: 26/03/2018
  Time: 09:13
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%String message = (String) request.getAttribute("message");%>


<dspace:layout locbar="commLink" title="Indexador" navbar="admin">


    <div align="center"><h3>Indexador DSpace</h3></div>
    <div align="center">
        <%if (message != null && !message.isEmpty()){%>
        <div align="center" class="alert alert-warning">
            <%="Ação não existentes:: "+message%>
        </div>
        <%}%>

        <form method="post" action="<%=request.getContextPath()%>/dspace-admin/index-manager">
            <input type="hidden" name="action" value="createIndex"/>
            <button class="btn btn-primary" type="submit">
                <span class="glyphicon glyphicon-plus"></span>
                Criar Indice
            </button>
        </form>

        <form method="post" action="<%=request.getContextPath()%>/dspace-admin/index-manager">
            <input type="hidden" name="action" value="cleanIndex"/>
            <button class="btn btn-warning" type="submit">
                <span class="glyphicon glyphicon-trash"></span>
                Limpar Indice
            </button>
        </form>
    </div>


</dspace:layout>