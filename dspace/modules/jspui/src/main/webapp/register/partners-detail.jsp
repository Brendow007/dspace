<%--
  Created by IntelliJ IDEA.
  User: brendows
  Date: 26/03/2018
  Time: 09:13
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="org.dspace.content.Partners" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    Partners partner = (Partners) request.getAttribute("partner");
    int limitGroup = (Integer) request.getAttribute("limitGroup");
    int limitOrder = (Integer) request.getAttribute("limitOrder");

    String statusName = "";

    if (partner.getStatus().equals(true)) {
        statusName = "Habilitado";
    } else {
        statusName = "Desabilitado";
    }


%>

<dspace:layout locbar="commLink" title="Parceiros" navbar="admin">


    <div align="center"><h3>Parceiro</h3></div>


    <%if (partner != null) {%>
    <div>
        <ul>
            <form method="post" action="<%=request.getContextPath()%>/partners">


                <div class="row-partner">
                    <div class="col-25-partner">
                        <label class="label-partner" for="name">Nome</label>
                    </div>
                    <div class="col-75-partner">
                        <input class="input-partner" type="text" id="name" name="name" value="<%=partner.getName()%>"
                               required placeholder="Nome do parceiro..">
                    </div>
                </div>

                <div class="row-partner">
                    <div class="col-25-partner">
                        <label class="label-partner" for="url">Url</label>
                    </div>
                    <div class="col-75-partner">
                        <input class="input-partner" type="url" id="url" name="url" value="<%=partner.getUrl()%>"
                               required placeholder="Url do parceiro..">
                    </div>
                </div>

                <div class="row-partner">
                    <div class="col-25-partner">
                        <label class="label-partner" for="status">Status</label>
                    </div>
                    <div class="col-75-partner">
                        <select id="status" name="status" required>
                            <option selected value="<%=partner.getStatus()%>" disabled>Estado Atual:<%=statusName%>
                            </option>
                            <option value="false">Desabilitar</option>
                            <option value="true">Habilitar</option>
                        </select>
                    </div>
                </div>

                <div class="row-partner">
                    <div class="col-25-partner">
                        <label class="label-partner" for="group">Grupo</label>
                    </div>
                    <div class="col-75-partner">
                        <select id="group" name="group" required>
                            <option value="<%=partner.getGroup()%>">Grupo Atual: <%=partner.getGroup()%>
                            </option>
                            <% for (int i = 0; i < limitGroup; i++) {%>
                            <option value="<%=i+1%>"><%=i+1%>
                            </option>
                            <%}%>
                        </select>
                    </div>
                </div>

                <div class="row-partner">
                    <div class="col-25-partner">
                        <label class="label-partner" for="order">Ordenação</label>
                    </div>
                    <div class="col-75-partner">
                        <select id="order" name="order" required>
                            <option value="<%=partner.getOrderPartner()%>">Ordenação
                                Atual: <%=partner.getOrderPartner()%>
                            </option>
                            <% for (int i = 0; i < limitOrder; i++) {%>
                            <option value="<%=i+1%>"><%=i+1%>
                            </option>
                            <%}%>
                        </select>
                    </div>
                </div>

                <br/>

                <input class="hidden" name="partner_id" value="<%=partner.getID()%>">
                <input class="hidden" name="operation" value="updated">
                <div align="center" class="row-partner">
                    <button class="btn btn-primary" type="submit">
                        Atualizar
                    </button>
                </div>

            </form>


            <div class="col-md-3">
                <a href="<%=partner.getUrl()%>" target="_blank">
                    <img src="<%= request.getContextPath()%>/image/img/parceiros/<%=partner.getPath()%>"
                         alt="<%=partner.getName()%>"
                         text-align="center"
                         class="img-logo-partner">
                </a><br/>

                <form method="get" action="<%=request.getContextPath()%>/partners">
                    <input class="hidden" name="operation" value="edit_logo">
                    <input class="hidden" name="partner_id" value="<%=partner.getID()%>">
                    <div align="left" class="row-partner">
                        <button class="btn btn-link" type="submit">
                            Editar Logo <span class="glyphicon glyphicon-share-alt"></span>
                        </button>
                    </div>
                </form>
                <br/>
                <form method="post" action="<%=request.getContextPath()%>/partners">
                    <div align="left" class="row-partner">
                        <button class="btn btn-warning" type="submit">
                            <span class="glyphicon glyphicon-arrow-left"></span> Voltar
                        </button>
                    </div>
                </form>
            </div>


            <%}%>
        </ul>
    </div>


</dspace:layout>