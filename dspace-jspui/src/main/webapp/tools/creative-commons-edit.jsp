<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Show the user a license which they may grant or reject
  -
  - Attributes to pass in:
  -    submission.info  - the SubmissionInfo object
  -    license          - the license text to display
  -    cclicense.exists   - boolean to indicate CC license already exists
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@page import="org.dspace.app.webui.servlet.admin.EditItemServlet"%>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.license.CCLicense" %>
<%@ page import="org.dspace.license.CreativeCommons" %>
<%@ page import="java.util.Collection"%>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
	Item item = (Item) request.getAttribute("item");



	Boolean lExists = (Boolean) request.getAttribute("cclicense.exists");
	boolean licenseExists = (lExists == null ? false : lExists.booleanValue());
	Boolean acceptTerm = (Boolean) request.getAttribute("accept.term");

	Collection<CCLicense> cclicenses = (Collection<CCLicense>) request.getAttribute("cclicense.licenses");

	String licenseURL = "";
	if (licenseExists)
		licenseURL = CreativeCommons.getLicenseURL(item);

%>


<dspace:layout navbar="admin"
               locbar="none"
               parentlink="/dspace-admin"
               parenttitlekey="jsp.administer"
               titlekey="jsp.tools.creative-commons-edit.title" nocache="true">

	<style>

		p {
			margin: 0 0 10px;
			line-height: 3em;
			word-break: normal;
			white-space: normal;
		}

		h3{
			text-align: -webkit-center;
		}

	</style>

	<script>
		$(document).ready(function () {
			$('#popup').click(function (event) {
				event.preventDefault();
				$.featherlight($("#popupTerm"));
			});
		});

	</script>


<table cellspacing="8" cellpadding="24" class="pagecontent">
  <tr>

   <td>
    <h1><fmt:message key="jsp.tools.creative-commons-edit.heading1"/></h1>



				<form name="ccform" id="license_form" action="" method="post">


					<%--<% if ((acceptTerm != null) && (acceptTerm.booleanValue() == false)) {%>--%>
					<% if ((acceptTerm != null) && (acceptTerm.booleanValue() == false)) {%>

					<div class="alert alert-warning">
						<p align="center"><fmt:message key="jsp.submit.select-collection.accept-term-edit"/></p>
					</div>

					<%}%>



					<% if(licenseExists || !licenseExists){ %>

					<strong> <input type="checkbox" name="acceptTerm" required="required" id="acceptTerm" value="true" />&nbsp;<fmt:message key="jsp.submit.accept.educapes.term"><fmt:param><a href="#" id="popup">Termos de uso do eduCapes</a></fmt:param> </fmt:message></strong>
					<div class="hidden">
						<div id="popupTerm">

							<dspace:include page="../static/pages/submit-term.jsp" />


						</div>
					</div>
					<br/>
					<br/>

					<ol>
						<li>
							DECLARO para todos os fins legais, que tenho ciência sobre a autoria e/ou titularidade do material e suas concessões, da necessidade de licenciamento Creative Commons (CC-BY, CC-BY-NC, CC-BY-SA ou CC-BY-NC-SA) ou similar e do respeito aos direitos autorais do material que estou submetendo ao Portal eduCAPES;
						</li><br/>
						<li>
							ASSUMO ampla e total responsabilidade quanto à originalidade, à titularidade e ao conteúdo, citações de obras consultadas, referências e outros elementos que fazem parte deste material;
						</li><br/>
						<li>
							DECLARO estar ciente de que responderei as sanções previstas na legislação brasileira, pelo uso indevido ou não autorizado de qualquer elemento do material a ser submetido, passível de reclamação autoral (Lei de Direito Autoral – Lei nº 9610/98).
						</li><br/>
						<li>Caso tenha dúvidas, consulte o <a target="_blank" href="<%= request.getContextPath() %>/redirect?action=submission">manual para submissão de materiais</a>.</li>
					</ol>
					<br/>
					<%
						}
					%>

					<div class="row">
						<label class="col-md-2"><fmt:message
								key="jsp.submit.creative-commons.license" /></label> <span
							class="col-md-8"> <select name="licenseclass_chooser"
							id="licenseclass_chooser" class="form-control">
								<option
									value="webui.Submission.submit.CCLicenseStep.select_change"><fmt:message
										key="jsp.submit.creative-commons.select_change" /></option>
								<%
									if (cclicenses != null) {
											for (CCLicense cclicense : cclicenses) {
								%>
								<option value="<%=cclicense.getLicenseId()%>"><%=cclicense.getLicenseName()%></option>
								<%
									}
										}
								%>
								<option value="webui.Submission.submit.CCLicenseStep.no_license"><fmt:message
										key="jsp.submit.creative-commons.licensed" /></option>
						</select>
						</span>
					</div>
					<%
						if (licenseExists) {
					%>
					<div class="row" id="current_creativecommons">
						<label class="col-md-2"><fmt:message
								key="jsp.submit.creative-commons.license.current" /></label> <span
							class="col-md-8"> <a href="<%=licenseURL%>"><%=licenseURL%></a>
						</span>
					</div>
					<%
						}
					%>
					<div style="display: none;" id="creativecommons_response"></div>
					<br /> 
					
					<input type="hidden" name="item_id" value='<%=request.getParameter("item_id")%>'/> 
					<input type="hidden" name="cc_license_url" value="<%=licenseURL%>" />
					<input type="hidden" name="action" value="<%= EditItemServlet.UPDATE_CC %>"/>
						<div align="center">
		            <input class="btn btn-default" type="submit" name="submit_cancel_cc" value="<fmt:message key="jsp.tools.general.cancel"/>" />
					<input class="btn btn-primary" type="submit" name="submit_change_cc" value="<fmt:message key="jsp.tools.general.update"/>" />
						</div>
				</form>
			</td>
  </tr>
</table>

    <script type="text/javascript">

jQuery("#licenseclass_chooser").change(function() {
    var make_id = jQuery(this).find(":selected").val();
    var request = jQuery.ajax({
        type: 'GET',
        url: '<%=request.getContextPath()%>/json/creativecommons?license=' + make_id
    });
    request.done(function(data){
    	jQuery("#creativecommons_response").empty();
    	var result = data.result;
        for (var i = 0; i < result.length; i++) {
            var id = result[i].id;            
            var label = result[i].label;
            var description = result[i].description;
            var htmlCC = " <div class='form-group'><span class='help-block' title='"+description+"'>"+label+"&nbsp;<i class='glyphicon glyphicon-info-sign'></i></span>"
            var typefield = result[i].type;
            if(typefield=="enum") {
            	jQuery.each(result[i].fieldEnum, function(key, value) {


					switch(value){
						case "Yes":
							value = "Sim";
							break;
						case "No":
							value = "Não";
							break;
						case "ShareAlike":
							value = "Sim, desde que outros compartilhem igual";
							break;
					}
					//debug
					//console.log(value);


            		htmlCC += "<label class='radio-inline' for='"+id+"-"+key+"'>";
            		htmlCC += "<input placeholder='"+value+"' type='radio' id='"+id+"-"+key+"' name='"+id+"_chooser' value='"+key+"' required/>"+value+ "</label>";
            	});
            }


			htmlCC += "</div>";
			jQuery("#creativecommons_response").append(htmlCC);


			var cclicense = `<pre><div>
         			<h3 id='ccli'>Escolha uma licença Creative Commons</h3>
         			<p align="center" id='text'></p></div></pre>`;


		}

		var publicdomain = "<pre><div> <h3>LICENÇA DE DIREITOS AUTORAIS GRATUITA </h3> <p>Esta licença abrange a possibilidade, entre outras, de publicação, adaptação, transmissão ou emissão, retransmissão, distribuição para circulação nacional ou estrangeira, comunicação ao público, reprodução, divulgação, produção de mídia e audiovisual, inserção em coletânea e base de dados e inclusão da OBRA em biblioteca virtual. A licença autoriza um número indeterminado de publicações, edições e exemplares da OBRA, bem como o acesso a mesma por indeterminadas vezes quando disponibilizada na internet. A presente licença é gratuita. O(s) autor(es) declara(m) que é (são) o(s) único(s) autor(es) e o(s) titular(es) dos direitos autorais e que a OBRA é original. O(s) autor(es) assume(m) ampla e total responsabilidade, quanto à originalidade, à titularidade e ao conteúdo, citações de obras consultadas, referências e outros elementos que fazem parte da OBRA.</p></div></pre>";


		if(make_id == "publicdomain"){


			$("#creativecommons_response").append(publicdomain);


		}else{


			$("#creativecommons_response").append("<img id='creative-image' src='../image/capes/acesso-a-informacao.png' />").append(cclicense);


		}

		//esconde opçao
		jQuery("input[type=radio][name='derivatives_chooser'][value='n']").parent().hide();


		// esconde tag de image
		$("#creative-image").hide();

		$("input[name='commercial_chooser'], input[name='derivatives_chooser']").change(function() {

			var array = $("input[type='radio']");
			array.splice(-1,1)

			//console.log(array);
			//console.log(array[0].checked);

			$("#creative-image").show();
			if(array[0].checked && array[3].checked) {
				// CC + SA
				$("#creative-image").attr("src","../image/capes/cc/c3.png");
				$("#ccli").html('Licença Creative Commons Compartilhada');
				$("#text").html('O licenciante autoriza que outros criem e distribuam trabalhos derivados, mas apenas ao abrigo da mesma licença ou de uma licença compatível.');
			} else if (!array[0].checked && array[3].checked) {
				// CC+ SA + N-$
				$("#creative-image").attr("src","../image/capes/cc/c6.png");
				$("#ccli").html('Licença Creative Commons Não Comercial Compartilhada');
				$("#text").html('Esta licença permite que outros remixem, adaptem e criem a partir do seu trabalho para fins não comerciais, desde que atribuam a você o devido crédito e que licenciem as novas criações sob termos idênticos.');

			}  else if (array[0].checked && !array[3].checked) {
				// CC
				$("#creative-image").attr("src","../image/capes/cc/c1.png");
				$("#ccli").html('Licença Creative Commons');
				$("#text").html('O licenciante autoriza que outros copiem, distribuam, exibam e executem o trabalho, bem como façam e distribuam trabalhos derivados baseados nele.');
			}  else {
				// CC + N-$
				$("#creative-image").attr("src","../image/capes/cc/c4.png");
				$("#ccli").html('Licença Creative Commons Não Comercial');
				$("#text").html('Esta licença permite que outros remixem, adaptem e criem a partir do seu trabalho para fins não comerciais, e embora os novos trabalhos tenham de lhe atribuir o devido crédito e não possam ser usados para fins comerciais, os usuários não têm de licenciar esses trabalhos derivados sob os mesmos termos.');
			}
		});

		jQuery("#current_creativecommons").hide();
		jQuery("#creativecommons_response").show();

	});
});

	</script>



</dspace:layout>

