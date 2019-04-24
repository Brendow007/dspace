<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.harvest.HarvestedCollection" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.lang.StringUtils" %><%--
  Created by IntelliJ IDEA.
  User: brendows
  Date: 29/06/2018
  Time: 16:44
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%
    List<HarvestedCollection> collections = (List<HarvestedCollection>) request.getAttribute("harvestedCollections");
    String msg = (String) request.getAttribute("msg");
%>
<dspace:layout locbar="commLink"
               title="Parceiros"
               navbar="admin">

    <style>
        td {
            /*word-break: break-all;*/
            /*width: 60px;*/
            text-align: -webkit-center;
        }
    </style>
    <script>
        $(function () {

            $("#testbutton").bind("click", function () {
                $.ajax({
                    headers: {
                        // 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    url: "<%=request.getContextPath()%>/manager-repository?JSON",
                    type: "GET",
                    dataType: 'JSON',
                    processData: false,
                    success: function (response) {
                        console.log(response);
                    },
                    error: function (response) {
                        console.log(response);
                    }
                });
            });

            var idcol;

            function edit() {
                $('.edit_collection').bind("click", function () {
                    idcol = $(this).attr('id');
                    console.log(idcol);
                });
            }

            var idcolltest = function returnID() {
                $('#test').bind("click", function () {
                    console.log(idcol);
                    return idcol;
                });
            };


            edit();
            idcolltest();
        })

        // function salvaDados(response) {
        //     $.ajax({
        //         headers: {
        //             'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        //         },
        //         data: {"cpf": cpfId, formData},
        //         url: "/questionario-user",
        //         cache: true,
        //         type: "POST",
        //         dataType: 'JSON',
        //         processData: false,
        //         success: function (response) {
        //             setDataUser(response);
        //         },
        //         error: function (response) {
        //             console.log(response);
        //         }
        //     });
        //
        // }

        $(document).ready(function () {
            var table = $('#example').DataTable({
                scrollY: "400px",
                scrollX: "800px",
                scrollCollapse: true,
                paging: true,
                fixedColumns: true
            });
        });

    </script>
    <div class="repoList" align="center">
        <h3>Gerênciador de Repositórios Externos</h3><br/>
        <table id="example" class="table table-striped table-bordered">
            <div class="col-md-2 alert-info">Conexão:</div>
            <div class="col-md-8">
                <%if (StringUtils.isNotEmpty(msg)) {%>
                <%if (msg.contains("OK")) {%>
                <div class="alert alert-success"><%=msg%>
                </div>
                <%} else {%>
                <div class="alert alert-warning"><%=msg%>
                </div>
                <%}%>
                <%}%>
            </div>

            <thead>
            <tr>
                <th>id</th>
                <th>Ações</th>
                <th>Repositório:</th>
                <th>Nome</th>
                <th>Status:</th>
                <th>Ultima coleta:</th>
                <th>Coleção</th>
                <th>Padrão de metadado</th>
                <th>Tipo coleta:</th>
                <th>Status coleta:</th>
                <th>Status original:</th>
            </tr>
            </thead>


            <% for (HarvestedCollection colObject : collections) {%>
            <tr>

                <td>
                    <%=colObject.getCollectionId()%>
                </td>

                <td>
                    <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-repository">
                        <input type="hidden" name="action" value="harvestCol"/>
                        <input class="hidden" name="col_id" value="<%=colObject.getCollectionId()%>">
                        <button class="btn btn-success" type="submit">Sincronizar</button>
                    </form>
                    <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-repository">
                        <input type="hidden" name="action" value="purgeCol"/>
                        <input class="hidden" name="col_id" value="<%=colObject.getCollectionId()%>">
                        <button class="btn btn-danger" type="submit">Limpar</button>
                    </form>
                    <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-repository">
                        <input type="hidden" name="action" value="pingCol"/>
                        <input class="hidden" name="col_id" value="<%=colObject.getCollectionId()%>">
                        <button class="btn btn-warning" type="submit">Ping</button>
                    </form>
                    <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-repository">
                        <input type="hidden" name="action" value="editCol"/>
                        <input class="hidden" name="col_id" value="<%=colObject.getCollectionId()%>">
                        <button class="btn btn-primary" type="submit">Editar</button>
                    </form>
                </td>

                <td>
                        <%--url request--%>
                    <a href="<%=colObject.getOaiSource()%>" target="_blank"><%=colObject.getOaiSource()%>
                    </a>
                </td>
                <td>
                    <a href="<%=request.getContextPath()+"/handle/"+colObject.getCollection().getHandle()%>"
                       target="_blank"><%=colObject.getCollection().getName()%>
                    </a>
                </td>
                <td>
                    <%
                        String sync = "Sincronizando com: " + colObject.getOaiSource() + " ...";
                        String updated = "Repositório: " + colObject.getOaiSource() + " Sincronizado!";
                        String error = "Erro ao tentar sincronizar com: " + colObject.getOaiSource();
                        String succ = "Ultima sincronização realizada: " + colObject.getOaiSource() + " " + colObject.getHarvestDate();
                    %>
                    <%if (StringUtils.isNotEmpty(colObject.getHarvestMessage())) {%>
                    <%if (colObject.getHarvestMessage().contains("any updates")) {%>
                    <div class="alert-success"><%=updated%>
                    </div>
                    <%} else if (colObject.getHarvestMessage().contains("being harvested")) {%>
                    <div class="alert-info"><%=sync%>
                    </div>
                    <%} else if (colObject.getHarvestMessage().contains("error")) {%>
                    <div class="alert-danger"><%=error%>
                    </div>
                    <%} else if (colObject.getHarvestMessage().contains("while processing")) {%>
                    <div class="alert-danger"><%=error%>
                    </div>
                    <%} else if (colObject.getHarvestMessage().contains("successful")) {%>
                    <div class="alert-success"><%=succ%>
                    </div>
                    <%} else {%>
                    <%=colObject.getHarvestMessage()%>
                    <%}%>
                    <%}%>
                </td>
                <td>
                    <%=colObject.getHarvestDate()%>
                </td>
                <td>
                        <%--set id--%>
                    <%=colObject.getOaiSetId()%>
                </td>

                <td>
                        <%--Config--%>
                    <div class="row">
                        <%=colObject.getHarvestMetadataConfig()%>
                        <select name="metadata_format">
                            <%
                                // Add an entry for each instance of ingestion crosswalks configured for harvesting
                                String metaString = "harvester.oai.metadataformats.";
                                String metadataFormatValue = colObject.getHarvestMetadataConfig();
                                ;
                                Enumeration pe = ConfigurationManager.propertyNames("oai");
                                while (pe.hasMoreElements()) {
                                    String key = (String) pe.nextElement();
                                    if (key.startsWith(metaString)) {
                                        String metadataString = ConfigurationManager.getProperty("oai", key);
                                        String metadataKey = key.substring(metaString.length());
                                        String label = "jsp.tools.edit-collection.form.label21.select." + metadataKey;

                            %>
                            <option value="<%= metadataKey %>"
                                    <% if (metadataKey.equalsIgnoreCase(metadataFormatValue)) { %>
                                    selected="selected"
                                    <% } %> >
                                <fmt:message key="<%=label%>"/>
                            </option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                </td>
                <td>
                        <%--Harvest Type--%>
                    <%=colObject.getHarvestType()%>
                </td>
                <td>
                        <%--Status--%>
                    <%=colObject.getHarvestStatus()%>
                </td>
                <td>
                    <%=colObject.getHarvestMessage()%>
                </td>
                <%}%>
            </tr>
        </table>

    </div>


    <%--<span id="testbutton" class="btn btn-primary">Test</span>--%>


</dspace:layout>