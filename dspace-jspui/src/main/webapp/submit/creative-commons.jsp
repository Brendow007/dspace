<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Show the user the Creative Commons license which they may grant or reject
  -
  - Attributes to pass in:
  -    cclicense.exists   - boolean to indicate CC license already exists
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>


<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.license.CreativeCommons" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.license.CCLicense" %>
<%@ page import="java.util.Collection" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

    //get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

    Boolean lExists = (Boolean) request.getAttribute("cclicense.exists");
    boolean licenseExists = (lExists == null ? false : lExists.booleanValue());

    Collection<CCLicense> cclicenses = (Collection<CCLicense>) request.getAttribute("cclicense.licenses");

    String licenseURL = "";
    if (licenseExists)
        licenseURL = CreativeCommons.getLicenseURL(subInfo.getSubmissionItem().getItem());
%>

<dspace:layout style="submission"
               locbar="off"
               navbar="off"
               titlekey="jsp.submit.creative-commons.title"
               nocache="true">
    <style>


        p {

            margin: 0 0 10px;
            line-height: 3em;
            word-break: normal;
            white-space: normal;

        }

        h3 {

            text-align: -webkit-center;

        }
    </style>


    <form name="foo" id="license_form" action="<%= request.getContextPath() %>/submit" method="post"
          onkeydown="return disableEnterKey(event);">

        <jsp:include page="/submit/progressbar.jsp"/>

        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") +\"#license\"%>">
            <fmt:message key="jsp.morehelp"/>
        </dspace:popup> <br/>
        <div class="alert alert-info"><fmt:message key="jsp.submit.show-license.info1"/></div>

            <%-- <h1>Submit: Use a Creative Commons License</h1> --%>
        <h1><fmt:message key="jsp.submit.creative-commons.heading"/></h1>
        <p class="help-block"><fmt:message key="jsp.submit.creative-commons.info1"/></p>

        <div class="row">
            <label class="col-md-2"><fmt:message key="jsp.submit.creative-commons.license"/></label>
            <span class="col-md-8">
                                               <select required name="licenseclass_chooser" id="licenseclass_chooser"
                                                       class="form-control">
                                                                               <option disabled selected value=""><fmt:message
                                                                                       key="jsp.submit.creative-commons.select_change"/></option>

                                                                               <% if (cclicenses != null) {
                                                                                   String licensenames;
                                                                                   for (CCLicense cclicense : cclicenses) {
                                                                                       licensenames = cclicense.getLicenseName(); %>
                                                                                  <% if (cclicense.getLicenseName().equalsIgnoreCase("public domain")) {%>
                                                                                           <% licensenames = "Domínio Público";%>
                                                                                     <%}%>
                                                                                    <option value="<%= cclicense.getLicenseId()%>"><%=licensenames%></option>
                                                                               <% }
                                                                               }%>
												   <option value="webui.Submission.submit.CCLicenseStep.no_license"><fmt:message
                                                           key="jsp.submit.creative-commons.licensed"/></option>

                                               </select>
                               </span>
        </div>
        <% if (licenseExists) { %>
        <div class="row" id="current_creativecommons">
            <label class="col-md-2"><fmt:message key="jsp.submit.creative-commons.license.current"/></label>
            <span class="col-md-8">
                                               <a href="<%=licenseURL %>"><%=licenseURL %></a>
                               </span>
        </div>
        <% } %>
        <div style="display:none;" id="creativecommons_response">
        </div>
        <br/>
            <%-- Hidden fields needed for SubmissionController servlet to know which step is next--%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>

        <input type="hidden" name="cc_license_url" value="<%=licenseURL %>"/>
        <input type="submit" id="submit_grant" name="submit_grant" value="submit_grant" style="display: none;"/>
        <%
            int numButton = 2 + (!SubmissionController.isFirstStep(request, subInfo) ? 1 : 0) + (licenseExists ? 1 : 0);

        %>
        <div class="row col-md-<%= 2*numButton %> pull-right btn-group">
            <% //if not first step, show "Previous" button
                if (!SubmissionController.isFirstStep(request, subInfo)) { %>
            <input class="btn btn-default col-md-<%= 12 / numButton %>" type="submit"
                   name="<%=AbstractProcessingStep.PREVIOUS_BUTTON%>"
                   value="<fmt:message key="jsp.submit.general.previous"/>"/>
            <% } %>

            <input class="btn btn-default col-md-<%= 12 / numButton %>" type="submit"
                   name="<%=AbstractProcessingStep.CANCEL_BUTTON%>"
                   value="<fmt:message key="jsp.submit.general.cancel-or-save.button"/>"/>
            <input class="btn btn-primary col-md-<%= 12 / numButton %>" type="submit"
                   name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.general.next"/>"/>
        </div>
    </form>
    <script type="text/javascript">


        jQuery("#licenseclass_chooser").change(function () {
            var make_id = jQuery(this).find(":selected").val();
            var request = jQuery.ajax({
                type: 'GET',
                url: '<%=request.getContextPath()%>/json/creativecommons?license=' + make_id
            });
            request.done(function (data) {
                jQuery("#creativecommons_response").empty();
                var result = data.result;
                for (var i = 0; i < result.length; i++) {
                    var id = result[i].id;
                    var label = result[i].label;
                    var description = result[i].description;
                    var htmlCC = " <div class='form-group'><span class='help-block' title='" + description + "'>" + label + "&nbsp;<i class='glyphicon glyphicon-info-sign'></i></span>"
                    var typefield = result[i].type;
                    if (typefield == "enum") {
                        jQuery.each(result[i].fieldEnum, function (key, value) {

                            switch (value) {
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
                            htmlCC += "<label class='radio-inline' for='" + id + "-" + key + "'>";
                            htmlCC += "<input placeholder='" + value + "' type='radio' id='" + id + "-" + key + "' name='" + id + "_chooser' value='" + key + "' required/>" + value + "</label>";
                        });
                    }


                    htmlCC += "</div>";
                    jQuery("#creativecommons_response").append(htmlCC);


                    var cclicense = `<pre><div>
         			<h3 id='ccli'>Escolha uma licença Creative Commons</h3>
         			<p align="center" id='text'></p></div></pre>`;


                }

                var publicdomain = "<pre><div> <h3>Atribuição - CC0 1.0 Universal (CC0 1.0) Domínio Público</h3> <p class='cc-text'>A pessoa que associou um trabalho a este resumo dedicou o trabalho ao domínio público, renunciando a todos os seus direitos sob as leis de direito de autor e/ou de direitos conexos referentes ao trabalho, em todo o mundo, na medida permitida por lei. Você pode copiar, modificar, distribuir e executar o trabalho, mesmo para fins comerciais, tudo sem pedir autorização. <br/> A CC0 não afeta, de forma alguma, os direitos de patente ou de marca de qualquer pessoa, nem os direitos que outras pessoas possam ter no trabalho ou no modo como o trabalho é utilizado, tais como direitos de imagem ou de privacidade.\n" +
                    "Desde que nada seja expressamente afirmado em contrário, a pessoa que associou este resumo a um trabalho não fornece quaisquer garantias sobre o mesmo e exonera-se de responsabilidade por quaisquer usos do trabalho, na máxima medida permitida pela lei aplicável.\n" +
                    "Ao utilizar ou citar o trabalho, não deve deixar implícito que existe apoio do autor ou do declarante</p></div></pre>";


                if (make_id == "publicdomain") {


                    $("#creativecommons_response").append(publicdomain);


                } else {


                    $("#creativecommons_response").append("<img id='creative-image' src='./image/capes/acesso-a-informacao.png' />").append(cclicense);


                }

                //esconde opçao
                jQuery("input[type=radio][name='derivatives_chooser'][value='n']").parent().hide();


                // esconde tag de image
                $("#creative-image").hide();

                $("input[name='commercial_chooser'], input[name='derivatives_chooser']").change(function () {

                    var array = $("input[type='radio']");
                    array.splice(-1, 1)

                    //console.log(array);
                    //console.log(array[0].checked);

                    $("#creative-image").show();
                    if (array[0].checked && array[3].checked) {
                        // CC + SA
                        $("#creative-image").attr("src", "./image/capes/cc/c3.png");
                        $("#ccli").html('Atribuição-CompartilhaIgual - CC BY-SA');
                        $("#text").html('<p class="cc-text">Esta licença permite que outros remixem, adaptem e criem a partir do seu trabalho, mesmo para fins comerciais, desde que lhe atribuam o devido crédito e que licenciem as novas criações sob termos idênticos. Esta licença costuma ser comparada com as licenças de software livre e de código aberto "copyleft". Todos os trabalhos novos baseados no seu terão a mesma licença, portanto quaisquer trabalhos derivados também permitirão o uso comercial. Esta é a licença usada pela Wikipédia e é recomendada para materiais que seriam beneficiados com a incorporação de conteúdos da Wikipédia e de outros projetos com licenciamento semelhante.</p>');
                    } else if (!array[0].checked && array[3].checked) {
                        // CC+ SA + N-$
                        $("#creative-image").attr("src", "./image/capes/cc/c6.png");
                        $("#ccli").html('Atribuição-NãoComercial-CompartilhaIgual - CC BY-NC-SA');
                        $("#text").html('<p class="cc-text">Esta licença permite que outros remixem, adaptem e criem a partir do seu trabalho para fins não comerciais, desde que atribuam a você o devido crédito e que licenciem as novas criações sob termos idênticos.</p>');

                    } else if (array[0].checked && !array[3].checked) {
                        // CC
                        $("#creative-image").attr("src", "./image/capes/cc/c1.png");
                        $("#ccli").html('Atribuição - CC BY');
                        $("#text").html('<p class="cc-text">Esta licença permite que outros distribuam, remixem, adaptem e criem a partir do seu trabalho, mesmo para fins comerciais, desde que lhe atribuam o devido crédito pela criação original. É a licença mais flexível de todas as licenças disponíveis. É recomendada para maximizar a disseminação e uso dos materiais licenciados.</p>');
                    } else {
                        // CC + N-$
                        $("#creative-image").attr("src", "./image/capes/cc/c4.png");
                        $("#ccli").html('Atribuição-NãoComercial CC BY-NC');
                        $("#text").html('<p class="cc-text">Esta licença permite que outros remixem, adaptem e criem a partir do seu trabalho para fins não comerciais, e embora os novos trabalhos tenham de lhe atribuir o devido crédito e não possam ser usados para fins comerciais, os usuários não têm de licenciar esses trabalhos derivados sob os mesmos termos.</p>');
                    }
                });

                jQuery("#current_creativecommons").hide();
                jQuery("#creativecommons_response").show();

            });
        });

    </script>


</dspace:layout>

