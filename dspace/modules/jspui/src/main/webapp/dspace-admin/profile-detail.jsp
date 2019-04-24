<%@ page import="org.dspace.harvest.MetadataValuesProfile" %>
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

<%
    ProfileHarvestedCollection profile = (ProfileHarvestedCollection) request.getAttribute("profile");
    List<MetadataValuesProfile> valuesProfiles = (List<MetadataValuesProfile>) request.getAttribute("valuesProfile");
%>
<dspace:layout locbar="commLink" title="Editando coleção" navbar="admin">

    <h2>Editando perfil:  <%=profile.getName()%></h2>
<%--    <div class="col-md-2">
        <div class="ui right transition visible" id="msgStatus" style="display: block !important;"><div id="msgDisplay" class="ui green message"><i class="close icon"></i>Transcrição removida com sucesso!</div></div>
    </div>--%>
    <div class="col-md-4">
    <strong>ID:</strong> <%=profile.getID()%><br/>
    <strong>Padrão de metadados:</strong> <%=profile.getStandard().toUpperCase()%><br/>
    <strong>Identifier: </strong><%=profile.getHandle()%>
    <br/>
    <br/>
    </div>
    <%for (MetadataValuesProfile values : valuesProfiles) {%>
    <div class="col-md-4">
        <strong>Transcrição: </strong><%=values.getTypeValues()%><br/>
        <strong>Filtros: </strong> <%=values.getArrayValues()%><br/>
    <form method="POST" action="<%=request.getContextPath()%>/dspace-admin/manager-profile">
        <input class="hidden" name="arrayValues" value="<%=values.getArrayValues()%>">
        <input class="hidden" name="typeValue" value="<%=values.getTypeValues()%>">
        <input class="hidden" name="idValue" value="<%=values.getID()%>">
        <input type="hidden" name="action" value="editValues"/>
        <button class="btn btn-primary" type="submit">Editar transcrição</button>
    </form>
    <form method="POST" action="<%=request.getContextPath()%>/dspace-admin/manager-profile">
        <input class="hidden" name="id" value="<%=values.getID()%>">
        <input class="hidden" name="identify" value="<%=profile.getHandle()%>"/>
        <input type="hidden" name="action" value="deleteTranscription"/>
        <button class="btn btn-danger" type="submit">Deletar</button>
    </form>
    </div>
    <%}%>

<div class="col-md-8">
    <br/>
    <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-profile">
        <input class="hidden" name="identify" value="<%=profile.getHandle()%>"/>
        <input class="hidden" name="action" value="createTranscription"/>
        <button class="ui inverted green button" type="submit">Nova transcrição &nbsp;<i class="ui icon plus"></i></button>
    </form>
    <br/>
    <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-profile">
        <input type="hidden" name="action" value="list"/>
        <button class="btn btn-primary" type="submit"><i class="angle double left icon"></i>&nbsp;Voltar</button>
    </form>
</div>


</dspace:layout>