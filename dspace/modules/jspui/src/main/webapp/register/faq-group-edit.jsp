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

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.content.FaqGroup" %>


<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="java.util.Locale" %>

<%
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    FaqGroup faqgroup = (FaqGroup) request.getAttribute("faqgroup");
    int groupLimit = (Integer) request.getAttribute("grouplimit");
%>

<dspace:layout locbar="commLink" title="Editando FAQ" navbar="admin">


    <link type="text/css" rel="stylesheet"
          href="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.css"/>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery-1.12.3.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery.dataTables.min.js"></script>

    <style>
        input {
            resize: horizontal;
            width: 200px;
        }

        input:active {
            width: auto;
        }

        input:focus {
            min-width: 200px;
        }

        .form-control {
            width: 80%;
        }
    </style>

    <script>
        $(document).ready(function () {
            $(".remove_author_button").click(function (event) {
                var r = confirm("Tem certeza que deseja excluir este grupo?");
                if (r == true) {
                    var buttonId = $(this).attr('id').substring(7);
                    window.location = "<%= request.getContextPath() %>/faq-group?operation=remove&id=" + buttonId;
                }
            });

            $(".edit_author_button").click(function (event) {
                var buttonId = $(this).attr('id').substring(5);
                window.location = "<%= request.getContextPath() %>/faq-group?operation=detail&id=" + buttonId;
            });
        });
    </script>


    <script type="text/javascript">
        $(document).ready(function () {
            var table = $('#example').DataTable({
                scrollY: "450px",
                scrollX: true,
                scrollCollapse: true,
                paging: true,
                fixedColumns: true
            });
        });
    </script>

    <% if (faqgroup != null) { %>

    <div class="container">
        <form method="post" action="<%= request.getContextPath()%>/faq-group">
            <input type="hidden" name="id" value="<%= faqgroup.getID() %>"/>
            <input type="hidden" name="operation" value="edit"/>

            <div class="form-group">
                <label for="order">Ordenação:</label>
                <select name="order" id="order">
                    <option disabled>ordem atual:</option>
                    <option selected="selected"><%= faqgroup.getGroupOrder()%>
                    </option>
                    <option value="0" disabled>ordenação:</option>
                    <% for (int i = 1; i < groupLimit; i++) {%>
                    <option value="<%=i%>"><%=i%>
                    </option>
                    <%}%>
                </select>




            </div>

            <%--<div class="form-group">--%>
                <%--<label for="order">Ordenação:</label>--%>
                <%--<input type="search" class="form-control" name="order" id="order"--%>
                       <%--value="<%= faqgroup.getGroupOrder()%>"/>--%>
            <%--</div>--%>

            <div class="form-group">
                <label for="name">Nome do Grupo:</label>
                <textarea class="form-control" name="name" id="name"
                          placeholder="Digite o nome do grupo . . ."><%= faqgroup.getGroupName()%></textarea>
            </div>

            <input class="btn btn-default" action="action" type="button" value="Voltar" onclick="history.go(-1);"/>

            <input class="btn btn-primary" type="submit" value="Atualizar"/>
            <input type="button" id="remove_<%=faqgroup.getID()%>" value="Excluir"
                   class="remove_author_button btn btn-danger"/>
        </form>
    </div>


    <% }%>


</dspace:layout>
