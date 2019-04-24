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

<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.eperson.Group" %>



<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="static com.hp.hpl.jena.vocabulary.RSS.url" %>
<%@ page import="com.hp.hpl.jena.sparql.function.library.e" %>

<%
    Collection[] collectionList = (Collection[]) request.getAttribute("collectionList");
    Collection educapes = (Collection) request.getAttribute("educapes_collection");
    Collection collection = (Collection) request.getAttribute("collection_undefined");


//    Collection collectionSolo = (Collection) request.getAttribute("cc");
//    EPerson eperson = (EPerson) request.getAttribute("eperson");
//    String test = (String) request.getAttribute("test");

%>

<dspace:layout locbar="commLink" title="Listagem de Coleções" navbar="admin">


    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.css"
          type="text/css"/>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery-1.12.3.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery.dataTables.min.js"></script>

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

    <div class="container-fluid">
            <%--<h1 align="center">Users <%=collectionSolo.getName()%>--%>
            <%--<h3 align="center"><%="COD Projeto:" + test%>--%>
        </h3>

            <%--<%if (collectionSolo.getAdministrators() != null) {%>--%>

            <%--<h3 align="center">collection_submitters: <%=collectionSolo.getSubmitters().getName()%>--%>
        </h3>

            <%--<%}%>--%>

            <%--<%if (collectionSolo.getAdministrators() != null) {%>--%>

            <%--<h3 align="center">collection_administrator <%=collectionSolo.getAdministrators().getName()%>--%>
        </h3>
            <%--<%}%>--%>
            <%--<h1 align="center">Users <%=a.getID()%></h1>--%>


                <% for (EPerson ep:educapes.getSubmitters().getMembers()) {%>
                        <%=ep.getName()%><br/>
               <%}%>
                <h3>DIV</h3>
              <% for (EPerson ep:collection.getSubmitters().getMembers()) {%>
                <%=ep.getEmail()%> + "null"<br/>
               <%}%>

        <table id="example" class="table table-striped table-bordered" cellspacing="0" width="auto">
            <h2 align="center">Lista de Coleções</h2>
            <thead>
            <tr>
                <th>Handle Colletion - link</th>
                <th>Collection - Projeto</th>
                <th>Groups Admin Name - Grupo Coordenador</th>
                <th>Membros</th>
            </tr>
            </thead>

      <%--      <tbody>
            <% if (collectionList != null) { %>
            <% for (Collection c : collectionList) {%>
            <%
                String bsLink = "http://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/handle/" + c.getHandle();
                String nomeProjeto = c.getName();
                String nomeProjetoREGEX = nomeProjeto.replaceAll("[^0-9]+_", " ");
            %>
            <tr>

                <td>
                    <a target="_blank" href="<%=bsLink%>"><%=c.getHandle()%>
                    </a>
                </td>

                <td>
                    <%=c.getName()%>
                    <%if (c.getAdministrators() != null) {%>
                    <%}%>
                </td>

                <td>
                    <%if (c.getSubmitters() != null) {%>
                    <%=c.getSubmitters().getName()%>
                    <%}%>
                </td>

                <td>
                    <%if (c.getAdministrators() != null) {%>
                    <%EPerson[] ep = c.getAdministrators().getMembers();%>
                    <%for (EPerson epList : ep) {%>
                    <%=c.getID() + epList.getName() + " " + c.getName()%>
                    <%} %>
                    <%}%>
                </td>
            </tr>
            <% } %>
            <% } %>
            </tbody>--%>
        </table>

    </div>

    <%--    <div class="container-fluid">
            <h1 align="center">Users</h1>


            <table id="example" class="table table-striped table-bordered" cellspacing="0" width="auto">
                <thead>
                    <tr>
                        <th>E-mail</th>
                    </tr>
                </thead>

                <tbody>
                <% if (epersonList.length > 0) { %>
                <% for (EPerson ep : epersonList) {%>
                    <tr>
                        <td><%=ep.getLastName()%></td>

                    </tr>
                <% } %>
                <% }%>
                </tbody>
            </table>
        </div>--%>

</dspace:layout>
