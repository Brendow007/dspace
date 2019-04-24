<%-- 
    Document   : submission-report
    Created on : 08/01/2017, 13:13:44
    Author     : Guilherme Lemeszenski
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@page import="java.util.List"%>
<%@page import="org.dspace.content.Item"%>
<%@page import="org.dspace.content.Community"%>

<%
    Community[] topCommunities = (Community[]) request.getAttribute("topCommunities");
%>
<dspace:layout titlekey="jsp.report.submission" navbar="admin">

    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.css" type="text/css" />
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery-1.12.3.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/dataTables.bootstrap.min.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery.dataTables.min.js"></script>
    <script type='text/javascript' src="<%= request.getContextPath()%>/static/js/jquery.mask.min.js"></script>


    <script type="text/javascript">
        $(document).ready(function () {
            
            $('.date').mask('00/00/0000');
            $('.date').mask('00/00/0000');
            
            var table = $('#submission-list-table').DataTable({
                serverSide: true,
                ajax: {
                    url: "<%= request.getContextPath()%>/report/submission?operation=search",
                    type: 'POST',
                    "data": function (d) {
                        d.community = $("#community").val();
                        d.title = $("#title").val();
                        d.author = $("#author").val();
                        d.startDate = $("#start-date").val();
                        d.endDate = $("#end-date").val();
                    },
                    dataSrc: 'submission'
                },
                columns: [
                    {data: 'title', render: function (data, type, full, meta) {
                        return '<a href="' + full.uri + '">' + data + '</a>';
                    }},
                    {data: 'author'},
                    {data: 'date'}
                ],
                scrollX: true,
                scrollCollapse: true,
                paging: true,
                ordering: false,
                fixedColumns: true
            });

            $("#button-search").on('click', function () {
                table.search("").draw();
            });

        });
    </script>

    <h2><fmt:message key="jsp.report.submission.page.title"/></h2>
    <br/>

    <div class="panel-default">
        <div class="discovery-query panel-heading">
            <h5><fmt:message key="jsp.report.submission.filter.title"/></h5>
            <form method="POST" action="<%= request.getContextPath()%>/report/submission">
                <input type="hidden" name="operation" value="search"/>
                <label for="community"><fmt:message key="jsp.report.submission.filter.community.field"/></label>
                <select id="community" name="community">
                    <option value="">Todas</option>
                    <%
                        if(topCommunities != null && topCommunities.length > 0){
                            for(Community community : topCommunities){
                    %>
                    <option value="<%= community.getID() %>"><%= community.getName() %></option>
                    <%      }
                    }
                    %>
                </select>
                <br/>
                <label for="title"><fmt:message key="jsp.report.submission.filter.title.field"/></label>
                <input type="text" value="" name="title" id="title" size="50"/>&nbsp;&nbsp;
                <label for="author"><fmt:message key="jsp.report.submission.filter.author.field"/></label>
                <input type="text" value="" name="author" id="author" size="50"/>
                <br/>
                <label for="start-date"><fmt:message key="jsp.report.submission.filter.start_date.field"/></label>
                <input type="text" value="" name="start-date" id="start-date" class="date"/>&nbsp;&nbsp;
                <label for="end-date"><fmt:message key="jsp.report.submission.filter.end_date.field"/></label>
                <input type="text" value="" name="end-date" id="end-date" class="date"/>
                <input type="button" value="Buscar" id="button-search" class="btn btn-primary"/>
            </form>
        </div>
    </div>

    <table id="submission-list-table" class="table table-striped table-bordered" cellspacing="0" width="auto">
        <thead>
        <tr>
            <th><fmt:message key="jsp.report.submission.table.title.column"/></th>
            <th><fmt:message key="jsp.report.submission.table.author.column"/></th>
            <th><fmt:message key="jsp.report.submission.table.date.column"/></th>
        </tr>
        </thead>
    </table>

</dspace:layout>
