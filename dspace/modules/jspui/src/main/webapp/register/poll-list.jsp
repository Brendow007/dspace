

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.Locale"%>


<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.content.Poll" %>
<%@ page import="org.dspace.content.Faq" %>


<%@ page import="org.dspace.core.Utils" %>
<%@ page import="java.util.List" %>


<%
   Locale[] supportedLocales = I18nUtil.getSupportedLocales();
   List<Poll> pollista = (List<Poll>) request.getAttribute("pollList");
%>


<dspace:layout locbar="commLink" title="Lista Enquete" navbar="admin">


    <%--<% if(pollista != null) {%>--%>
    <%--<% for (Poll p : pollista){%>--%>

    <%--<td><%=p.getNote()%></td>--%>
    <%--<td><%=p.getEmail()%></td>--%>

    <%--<% }  %>--%>
    <%--<% }  %>--%>



    <div class="row">
  		 		<h2 align="center">Avaliação do Portal</h2><br>
      </div>
      <html>
        <head>
          <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
          <script type="text/javascript">
            google.charts.load('current', {'packages':['corechart', 'controls']});
            google.charts.setOnLoadCallback(drawStuff);

            function drawStuff() {

              var dashboard = new google.visualization.Dashboard(
                document.getElementById('programmatic_dashboard_div'));

              // We omit "var" so that programmaticSlider is visible to changeRange.
              programmaticSlider = new google.visualization.ControlWrapper({
                'controlType': 'NumberRangeFilter',
                'containerId': 'programmatic_control_div',
                'options': {
                  'filterColumnLabel': 'Donuts eaten',
                  'ui': {'labelStacking': 'horizontal'}
                }
              });

             programmaticChart  = new google.visualization.ChartWrapper({
              'chartType': 'PieChart',
              'containerId': 'programmatic_chart_div',
              'options': {
                'width': 650,
                'height': 500,
                'legend': 'yes',
                'chartArea': {'left': 15, 'top': 15, 'right': 15, 'bottom': 15},
                'pieSliceText': 'value',
              }
            });

            var data = google.visualization.arrayToDataTable([
              ['Name', 'Donuts eaten'],
              ['Nota 1',<%= request.getAttribute("a") %>],
              ['Nota 2',<%= request.getAttribute("b") %> ],
              ['Nota 3',<%= request.getAttribute("c") %> ],
              ['Nota 4',<%= request.getAttribute("d") %>],
              ['Nota 5',<%= request.getAttribute("e") %>],

            ]);

            dashboard.bind(programmaticSlider, programmaticChart);
            dashboard.draw(data);


          }



               </script>
        </head>
        <body>


          <div id="programmatic_dashboard_div" style="border: 1px solid #ccc">
            <table class="table">
              <tr>

                <td>
                  <div id="programmatic_control_div" style="padding-left: 2em; min-width: 250px"></div>
                  <div>
                    <button style="margin: 1em 1em 1em 2em" onclick="changeRange();">
                      Mínima e Maxima
                    </button><br />
                    <button style="margin: 1em 1em 1em 2em" onclick="changeOptions();">
                      Visualizar em 3D
                    </button>
                  </div>
                  <script type="text/javascript">
                    function changeRange() {
                      programmaticSlider.setState({'lowValue':1, 'highValue':5});
                      programmaticSlider.draw();
                    }

                    function changeOptions() {
                      programmaticChart.setOption('is3D', true);
                      programmaticChart.draw();
                    }
                  </script>
                </td>

                <td>
                  <div id="programmatic_chart_div"></div>
                </td>

       		<td>
       		 <ul style="list-style-type:none">
      			<li>
      	 		 </li>
                    <br>
      	 		  <li>
      	 		      <br>
      	 		  </li>

      	 		   <li>
           	   		  <br>
      	   		  </li>

      	   		  	<li>
                      <br>
      	   		    </li>

      	   		  	<li>
                        <br>
    	   			</li>

      	   		  	<li>
                        <br>
     	    	 	</li>

      	   		  	<li>
      	   		  	<br>




      	    	 	</li>

          	 </ul>
       		</td>

              </tr>
            </table>
      	   <strong align="center"><h2> <%= " Total de votos: " + request.getAttribute("total")%><h2><strong>
          </div>
        </body>
      </html>






</dspace:layout>
