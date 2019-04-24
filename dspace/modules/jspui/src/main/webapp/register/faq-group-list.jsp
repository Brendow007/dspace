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

<%@ page import="org.dspace.content.FaqGroup" %>


<%@ page import="java.util.List" %>

<%
    //    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    List<FaqGroup> grouplist = (List<FaqGroup>) request.getAttribute("grouplist");

%>

<dspace:layout locbar="commLink" title="Cadastro de Grupos" navbar="admin">

    <script>

        $(document).ready(function () {
            $(".remove_author_button").click(function (event) {
                var r = confirm("Realmente deseja remover este grupo?");
                if (r == true) {
                    var buttonId = $(this).attr('id').substring(7);
                    window.location = "<%= request.getContextPath() %>/faq-group?operation=remove&id=" + buttonId;
                }
            });

            $(".detail_author_button").click(function (event) {
                var buttonId = $(this).attr('id').substring(5);
                window.location = "<%= request.getContextPath() %>/faq-group?operation=detail&id=" + buttonId;

            });

            $(".create_author_button").click(function (event) {
                window.location = "<%= request.getContextPath() %>/faq?operation=create";
            });
        });

    </script>


<div align="center">
    <form method="post" action="<%= request.getContextPath()%>/faq-group">
        <input type="hidden" name="operation" value="create"/>
        <button class="btn btn-link" type="submit"><span class="glyphicon glyphicon-plus"></span> Novo grupo</button>
    </form>
</div>
    <div align="right"><a href="<%= request.getContextPath()%>/faq" class="btn btn-link" type="submit">Editar Questões  <span class="glyphicon glyphicon-share-alt"></span></a></div>

    <table id="example" class="table table-responsive" cellspacing="0" width="auto">
        <thead>
        <tr>
            <th>&nbsp;</th>
            <th>Ordem</th>
            <th>Nome</th>
            <th>Ação</th>
        </tr>
        </thead>


        <tbody>

    <%if (grouplist != null) {%>
    <%if (grouplist.size() != 0) {%>
    <%for (FaqGroup group : grouplist) { %>

    <tr>
    <td>&nbsp;</td>
    <td><%=group.getGroupOrder()%></td>
    <td><%=group.getGroupName()%></td>
    <td><input type="button" id="edit_<%=group.getID()%>" value="Editar" class="detail_author_button btn btn-primary"/></td>
    </tr>

    <%}%>
    <%}%>
    <%}%>
    </tbody>
    </table>


</dspace:layout>
