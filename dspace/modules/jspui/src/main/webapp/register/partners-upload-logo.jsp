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
    Partners partner = (Partners) request.getAttribute("partner");
%>

<dspace:layout locbar="commLink" title="Parceiros" navbar="admin">


    <div>
        <%if (partner != null) {%>
        <div align="center" class="row-partner">
            <div class="col-75-partner">
                <h3 class="text" align="center"><%=partner.getName()%>
                </h3><br/>
                <div align="center">
                    <a href="#" target="_blank">
                        <img align="th-partner"
                             src="<%= request.getContextPath()%>/image/img/parceiros/<%=partner.getPath()%>"
                             alt="<%=partner.getName()%>"
                             text-align="center"
                             class="img-logo-partner">
                    </a><br/>
                </div>
                <form method="get" action="<%=request.getContextPath()%>/partners">
                    <input class="hidden" name="operation" value="edit">
                    <input class="hidden" name="partner_id" value="<%=partner.getID()%>">
                    <div align="center" class="row-partner">
                        <button class="btn btn-link" type="submit">
                            Editar dados
                            <span class="glyphicon glyphicon-share-alt"></span>
                        </button>
                    </div>

                </form>

            </div>
        </div>
        <br/>


        <%--<div align="center"><h3>Logo:</h3></div>--%>
        <%}%>

        <form enctype="multipart/form-data" method="post" action="<%=request.getContextPath()%>/partners">
            <div align="center">
                    <div align="center" class="fileUpload blue-btn btn width100">
                        <span>Adicionar Logo</span>
                        <input id="file" name="file" type="file" class="uploadlogo" required/>
                    </div>

                <%--<input type="file" multiple id="gallery-photo-add">--%>
                <%--<div class="gallery"></div>--%>
                <br/>

                <input type="hidden" name="operation" value="testestestestestesteste"/>
                <input type="hidden" name="partner_id" value="<%=partner.getID()%>"/>
                <input class="btn btn-primary" type="submit" value="Atualizar"/>

            </div>
        </form>

        <form method="post" action="<%=request.getContextPath()%>/partners">
                <div align="left" class="row-partner">
                    <button class="btn btn-warning" type="submit">
                        <span class="glyphicon glyphicon-arrow-left"></span>
                        Voltar
                    </button>
                </div>
        </form>
    </div>

</dspace:layout>