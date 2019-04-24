<%--
  Created by IntelliJ IDEA.
  User: brendows
  Date: 26/03/2018
  Time: 09:13
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="org.dspace.content.Partners" %>
<%@ page import="java.util.List" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    List<Partners> partnersList = (List<Partners>) request.getAttribute("partnersList");
    int limitGroup = (Integer) request.getAttribute("groupLimit");
%>

<dspace:layout locbar="commLink"
               title="Parceiros"
               navbar="admin">

    <style>


        .table thead > tr > th, .table tbody > tr > th, .table tfoot > tr > th, .table thead > tr > td, .table tbody > tr > td, .table tfoot > tr > td {
            padding: 2px;
            line-height: 2.428571;
        }

        .dataTables_wrapper form-inline dt-bootstrap no-footer {
            background: white !important;

        }
    </style>

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

    <div align="center"><h3>Gerenciador de Parceiros</h3></div>

    <div class="container-partner">
        <form method="post" action="<%=request.getContextPath()%>/partners" enctype="multipart/form-data"
              required="required">
            <div class="row-partner">
                <div class="col-25-partner">
                    <label class="label-partner" for="name">Nome</label>
                </div>
                <div class="col-75-partner">
                    <input class="input-partner" type="text" id="name" name="name" required
                           placeholder="Nome do parceiro..">
                </div>
            </div>

            <div class="row-partner">
                <div class="col-25-partner">
                    <label class="label-partner" for="url">Url</label>
                </div>
                <div class="col-75-partner">
                    <input class="input-partner" type="url" id="url" name="url" required
                           placeholder="Url do parceiro..">
                </div>
            </div>

            <div class="row-partner">
                <div class="col-25-partner">
                    <label class="label-partner" for="status">Status</label>
                </div>
                <div class="col-75-partner">
                    <select id="status" name="status" required>
                        <option value="false">Desabilitado</option>
                        <option value="true">Habilitado</option>
                    </select>
                </div>
            </div>

            <div class="row-partner">
                <div class="col-25-partner">
                    <label class="label-partner" for="group">Grupo</label>
                </div>
                <div class="col-75-partner">
                    <select id="group" name="group" required>
                        <option value="" disabled>Grupos:</option>
                        <% for (int i = 0; i < limitGroup; i++) {%>
                        <option value="<%=i+1%>"><%=i+1%></option>
                        <%}%>
                        <option value="<%=limitGroup+1%>"><%=limitGroup+1%></option>
                    </select>
                </div>
            </div>

            <%--<div class="row-partner">--%>
                <%--<div class="col-25-partner">--%>
                    <%--<label class="label-partner" for="order">Ordenação</label>--%>
                <%--</div>--%>
                <%--<div class="col-75-partner">--%>
                    <%--<select id="order" name="order" required>--%>
                        <%--<option value="1">1</option>--%>
                        <%--<option value="2">2</option>--%>
                        <%--<option value="3">3</option>--%>
                        <%--<option value="4">4</option>--%>
                        <%--<option value="5">5</option>--%>
                    <%--</select>--%>
                <%--</div>--%>
            <%--</div>--%>

            <div class="row-partner">
                <div class="col-25-partner">
                    <label class="label-partner" for="file">Logo</label>
                </div>
                <div class="col-75-partner">
                    <div align="center" class="fileUpload blue-btn btn width100">
                        <span>Adicionar Logo</span>
                        <input id="file" name="file" type="file" class="uploadlogo" required/>
                    </div>
                </div>
            </div>


            <div align="center" class="row-partner">
                <button class="btn btn-link" type="submit">
                    <span class="glyphicon glyphicon-plus"></span>
                    Novo Parceiro
                </button>
            </div>
            <br/>


        </form>
    </div>
    <%if (partnersList != null) {%>
    <%if (partnersList.size() > 0) {%>
    <div class="table-partner">
        <br/>
        <table id="example" class="table-partner table table-striped">
            <thead>
            <tr class="tr-partner">
                <%--<th class="th-partner">id</th>--%>
                <th class="th-partner">Grupo</th>
                <th class="th-partner">Ordenação</th>
                <th class="th-partner">Status</th>
                <th class="th-partner">Nome</th>
                <th class="th-partner">Url</th>
                <th class="th-partner">Arquivo</th>
                <th class="th-partner">Logo</th>
                <th class="th-partner">Ação</th>
            </tr>
            </thead>
            <tbody>
            <%for (Partners partners : partnersList) {%>

            <tr class="tr-partner">
                <%--<td><%if (partners.getID() != 0) {%>--%>
                    <%--<%=partners.getID()%>--%>
                    <%--<%}%>--%>
                <%--</td>--%>
                <td><%if (partners.getGroup() != 0) {%>
                    <%=partners.getGroup()%><%}%>
                </td>
                <td><%if (partners.getOrderPartner() != 0) {%>
                    <%=partners.getOrderPartner()%><%}%>
                </td>
                <td><%if (partners.getStatus() != null) {%>
                    <%if (partners.getStatus().equals(true)) {%>
                    <%="Habilitado"%>
                    <%} else {%>
                    <%="Desabilitado"%>
                    <%}%>
                    <%}%>
                </td>
                <td><%if (partners.getName() != null) {%>
                <%=partners.getName()%>
                <%}%>
                </td>
                <td><%if (partners.getUrl() != null) {%>
                    <%=partners.getUrl()%><%}%>
                </td>
                <td><%if (partners.getPath() != null) {%>
                    <%=partners.getPath()%><%}%>
                </td>
                <td>
                    <div class="col-md-3">
                        <a href="<%=partners.getUrl()%>" target="_blank">
                            <img src="<%= request.getContextPath()%>/image/img/parceiros/<%=partners.getPath()%>"
                                 alt="<%=partners.getName()%>"
                                 text-align="center"
                                 class="img-logo-partner">
                        </a>
                    </div>
                </td>
                <td>
                    <form method="get" action="<%=request.getContextPath()%>/partners">
                        <input class="hidden" name="operation" value="edit">
                        <input class="hidden" name="partner_id" value="<%=partners.getID()%>">
                        <input class="btn-partner btn btn-link" type="submit" name="submit" value="Editar Dados">
                    </form>

                    <form method="get" action="<%=request.getContextPath()%>/partners">
                        <input class="hidden" name="operation" value="edit_logo">
                        <input class="hidden" name="partner_id" value="<%=partners.getID()%>">
                        <input class="btn-partner btn btn-link" type="submit" name="submit" value="Editar logo">
                    </form>

                    <form method="post" action="<%=request.getContextPath()%>/partners">
                        <input class="hidden" name="operation" value="delete">
                        <input class="hidden" name="partner_id" value="<%=partners.getID()%>">
                        <input class="btn-partner btn btn-danger" type="submit" name="submit" value="Deletar">
                    </form>

                </td>
            </tr>


            <%}%>
            </tbody>
        </table>
    </div>
    <%}%>
    <%}%>


</dspace:layout>