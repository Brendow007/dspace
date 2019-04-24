<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - User profile editing form.
  -
  - This isn't a full page, just the fields for entering a user's profile.
  -
  - Attributes to pass in:
  -   eperson       - the EPerson to edit the profile for.  Can be null,
  -                   in which case blank fields are displayed.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.Locale"%>


<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="br.com.capes.eperson.Author" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="java.util.List" %>

<%
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    List<Author> authorList = (List<Author>) request.getAttribute("authorList");

%>

<dspace:layout locbar="commLink" title="Cadastro de Submissores" navbar="admin">


        <link rel="stylesheet" href="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.css" type="text/css" />
        <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.js"></script>
        <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery.dataTables.min.js"></script>

 <script>

        $(document).ready(function () {
            $(".remove_author_button").click(function (event) {
                var r = confirm("Realmente deseja remover este registro?");
                if (r == true) {
                    var buttonId = $(this).attr('id').substring(7);
                    window.location = "<%= request.getContextPath() %>/register/manage-authors?operation=remove&id=" + buttonId;
                }
             });

            $(".check_author_button").click(function (event) {
                var buttonId = $(this).attr('id').substring(6);
                window.location = "<%= request.getContextPath() %>/register/manage-authors?operation=check&id=" + buttonId;
             });
        });

 </script>



<script type="text/javascript">
$(document).ready(function() {
    var table = $('#example').DataTable( {
        scrollY:        "450px",
        scrollX:        true,
        scrollCollapse: true,
        paging:         true,
        fixedColumns:   true
    } );
} );
</script>


    <div class="container-fluid">
        <h1 align="center">Submissores Inativos</h1>

<table id="example" class="table table-striped table-bordered" cellspacing="0" width="auto">
            <thead>
                <tr>
                   <th>&nbsp;</th>
                   <th>&nbsp;</th>
                   <th>Nome</th>
                   <th>E-mail</th>
                   <th>Intituição</th>
                   <th>Departamento</th>
                   <th>Situação</th>
                </tr>
            </thead>
            <tbody>
                <% if (authorList.size() > 0) { %>
                <% for (Author author : authorList) {%>
                <tr>
                    <td><input type="button" id="remove_<%= author.getID()%>" value="Remover" class="remove_author_button btn btn-danger"/></td>
                    <td><input type="button" id="check_<%= author.getID()%>" value="Avaliar" class="check_author_button btn btn-success"/></td>
                    <td><%= author.getEPerson().getFullName()%></td>
                    <td><%= author.getEPerson().getEmail()%></td>
                    <td><%= author.getInstitutionName()%></td>
                    <td><%= author.getDepartment()%></td>
                    <td><%= author.getActive() ? "Ativo" : "Inativo"%></td>
                </tr>
                <% } %>
                <% }%>
            </tbody>
        </table>
    </div>

</dspace:layout>
