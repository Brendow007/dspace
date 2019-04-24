    <%--

        The contents of this file are subject to the license and copyright
        detailed in the LICENSE and NOTICE files at the root of the source
        tree and available online at

        http://www.dspace.org/license/

    --%>
        <%--
          - Footer for home page
        --%>

        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

        <%@ page contentType="text/html;charset=UTF-8" %>

        <%@ page import="org.dspace.app.util.Util" %>

            <%
    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
    String dsVersion = Util.getSourceVersion();
    String generator = dsVersion == null ? "DSpace" : "v"+ dsVersion;
%>
        <%-- Right-hand side bar if appropriate --%>
            <%if (sidebar != null) {%>

        <div class="col-md-3 pull-left">  <div class="menu-lateral "><%= sidebar%> </div></div>

            <% }%>
        </div>
        </div>

        <footer>
        <div class="assinaturas col-md-12 text-center">
        <img src="<%=request.getContextPath()%>/image/img/parceiros.png" class="">
        </div>
        <div class="data text-center"><span id="year"></span> <b>CAPES</b> <br><%=dsVersion%></div>
        </footer>

        </div>
        <%--FIM INTERNA--%>
        </div>
        <%--FIM ONPAGE--%>



        </body>
        </html>