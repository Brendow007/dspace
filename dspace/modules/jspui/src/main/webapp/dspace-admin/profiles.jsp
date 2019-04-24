<%@ page import="org.dspace.harvest.ProfileHarvestedCollection" %>
<%@ page import="java.util.List" %>
<%--
  Created by IntelliJ IDEA.
  User: brendows
  Date: 28/02/2019
  Time: 10:34
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<% List<ProfileHarvestedCollection> profiles = (List<ProfileHarvestedCollection>) request.getAttribute("profiles"); %>
<dspace:layout locbar="commLink" title="Editando perfis" navbar="admin">

    <h2 align="center">Perfis de Coleta</h2>
    <%for (ProfileHarvestedCollection profile : profiles) {%>
    <div class="col-md-3">
        <strong>Id:</strong> <%=profile.getID()%><br/>
        <strong>Nome:</strong>   <%=profile.getName()%><br/>
        <strong>Identificador:</strong>   <%=profile.getHandle()%><br/>
        <strong>Padrão de metadado:</strong>     <%=profile.getStandard()%><br/>
        <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-profile">
            <input class="hidden" name="identify" value="<%=profile.getHandle()%>">
            <input type="hidden" name="action" value="editProf"/>
            <button class="btn btn-primary" type="submit">Editar perfil</button>
        </form>
    </div>
  <%}%>


</dspace:layout>