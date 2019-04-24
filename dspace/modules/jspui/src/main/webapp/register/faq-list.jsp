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

<%@ page import="org.dspace.content.Faq" %>
<%@ page import="org.dspace.content.FaqGroup" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>

<%
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    List<Faq> faqList = (List<Faq>) request.getAttribute("faqlist");
    List<FaqGroup> groupList = (List<FaqGroup>) request.getAttribute("faqgroup");

%>

<dspace:layout locbar="commLink"
               title="Cadastro de Perguntas"
               navbar="admin">



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

        .table thead > tr > th, .table tbody > tr > th, .table tfoot > tr > th, .table thead > tr > td, .table tbody > tr > td, .table tfoot > tr > td {
            padding: 2px;
            text-align: -webkit-center;
            line-height: 3.428571;
            vertical-align: top;
        }


    </style>

    <script>

        $(document).ready(function () {
            $(".remove_author_button").click(function (event) {
                var r = confirm("Realmente deseja remover este registro?");
                if (r == true) {
                    var buttonId = $(this).attr('id').substring(7);
                    window.location = "<%= request.getContextPath() %>/faq?operation=remove&id=" + buttonId;
                }
            });

            $(".detail_author_button").click(function (event) {
                var buttonId = $(this).attr('id').substring(5);
                window.location = "<%= request.getContextPath() %>/faq?operation=detail&id=" + buttonId;

            });
            $(".create_author_button").click(function (event) {
                window.location = "<%= request.getContextPath() %>/faq?operation=create";
            });
        });

    </script>

    <div class="container-fluid">

        <h2 align="center">FAQ - Perguntas Frequentes </h2>

        <a class="btn btn-link" href="<%= request.getContextPath()%>/faq-group"><span class="glyphicon glyphicon-arrow-left"></span> Editar Grupos</a>

        <table id="example" class="table table-responsive" cellspacing="0" width="auto">
            <thead>
            <tr>
                <th>&nbsp;</th>
                <th>Grupo</th>
                <th>Ordem</th>
                <th>Pergunta</th>
                <th>Ação</th>
            </tr>
            </thead>


            <tbody>
            <% if (faqList != null) { %>
            <% if (faqList.size() > 0) { %>
            <% for (Faq faq : faqList) {%>
            <tr>
                <td>&nbsp;</td>
            <% for (FaqGroup f : groupList) {%>
                <% if (f.getGroupOrder() == faq.getGroupID()) {   %>
                <td><%=f.getGroupName()%></td>
                <%}%>
            <% } %>
                <td><%=faq.getQuestionID()%>
                </td>
                <td><%=faq.getQuestion()%>
                </td>
                <td><input type="button" id="edit_<%=faq.getID()%>" value="Editar"
                           class="detail_author_button btn btn-primary"/></td>
            </tr>
            <% } %>
            <% } %>
            <% }%>
            <div align="center">
                <button type="button" id="create" value="Adicionar Pergunta" class="create_author_button btn btn-link">
                    <span class="glyphicon glyphicon-plus"></span> Nova Pergunta
                </button>
            </div>


            </tbody>

        </table>


    </div>


</dspace:layout>
