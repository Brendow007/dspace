<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="br.com.capes.eperson.Author" %>
<%@page import="org.apache.commons.lang.StringUtils" %>
<%@page import="org.dspace.app.webui.util.UIUtil" %>
<%@page import="org.dspace.authorize.AuthorizeManager" %>
<%@page import="org.dspace.browse.ItemCountException" %>
<%@page import="org.dspace.content.Collection" %>
<%@page import="org.dspace.content.Community" %>
<%@page import="org.dspace.core.ConfigurationManager" %>
<%@page import="org.dspace.core.Context" %>
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

<%@ page import="org.dspace.core.I18nUtil" %>

<%@ page import="org.dspace.core.Utils" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>


<style>

    td{
     white-space: pre;

    }

</style>
<%
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Author authorForm = (Author) request.getAttribute("author");
    Context context = UIUtil.obtainContext(request);

    Community[] communities = null;
    Map collectionMap = null;
    Map subcommunityMap = null;

    if (AuthorizeManager.isAdmin(context)) {
        communities = (Community[]) request.getAttribute("communities");
        collectionMap = (Map) request.getAttribute("collections.map");
        subcommunityMap = (Map) request.getAttribute("subcommunities.map");
    }


    String operation = "create";
    String authorId = "";
    String firstName = "";
    String lastName = "";
    String email = "";
    String cpf = "";
    String institutionName = "";
    String institutionShortname = "";
    String department = "";
    String jobTitle = "";
    String phone = "";
    String celphone = "";
    String institutionSite = "";
    String institutionRepository = "";
    String institutionAva = "";
    Integer itemCount = null;
    String itemCountString = "";
    String language = "";

    if (authorForm != null) {

        operation = "edit";

        authorId = Integer.toString(authorForm.getID());

        firstName = authorForm.getEPerson().getFirstName();
        if (firstName == null) {
            firstName = "";
        }

        lastName = authorForm.getEPerson().getLastName();
        if (lastName == null) {
            lastName = "";
        }

        email = authorForm.getEPerson().getEmail();
        if (lastName == null) {
            lastName = "";
        }

        cpf = authorForm.getCpf();
        if (cpf == null) {
            cpf = "";
        }

        institutionName = authorForm.getInstitutionName();
        if (institutionName == null) {
            institutionName = "";
        }

        institutionShortname = authorForm.getInstitutionShortName();
        if (institutionShortname == null) {
            institutionShortname = "";
        }

        department = authorForm.getDepartment();
        if (department == null) {
            department = "";
        }

        jobTitle = authorForm.getJobTitle();
        if (jobTitle == null) {
            jobTitle = "";
        }

        celphone = authorForm.getCelphone();
        if (celphone == null) {
            celphone = "";
        }

        phone = authorForm.getEPerson().getMetadata("phone");
        if (phone == null) {
            phone = "";
        }

        institutionSite = authorForm.getInstitutionSite();
        if (institutionSite == null) {
            institutionSite = "";
        }

        institutionRepository = authorForm.getInstitutionRepository();
        if (institutionRepository == null) {
            institutionRepository = "";
        }

        institutionAva = authorForm.getInstitutionAva();
        if (institutionAva == null) {
            institutionAva = "";
        }

        itemCount = authorForm.getItemCount();
        if (itemCount == null) {
            itemCountString = "";
        } else {
            itemCountString = Integer.toString(itemCount);
        }

        language = authorForm.getEPerson().getMetadata("language");
        if (language == null) {
            language = "";
        }
    }

    String educapesCommunityHandle = ConfigurationManager.getProperty("community.educapes.handle");
    String materiaisUabCommunityHandle = ConfigurationManager.getProperty("community.materiaisuab.handle");
%>

<%!
    void showCommunity(Community c, JspWriter out, HttpServletRequest request, Map collectionMap, Map subcommunityMap, boolean checkAllChildren) throws ItemCountException, IOException, SQLException {
        out.println("<li class=\"row-community\">");
        out.println("<span class=\"expandButton\">[+]</span><h4 class=\"media-heading\">"
                + "<input type='checkbox' name='community_id' value='" + c.getID() + "' class='community-checkbox' " + (checkAllChildren ? "checked" : "") + "/>" + c.getMetadata("name"));

        out.println("</h4>");
        if (StringUtils.isNotBlank(c.getMetadata("short_description"))) {
            out.println(c.getMetadata("short_description"));
        }
        // Get the collections in this community
        Collection[] cols = (Collection[]) collectionMap.get(c.getID());
        if (cols != null && cols.length > 0) {
            out.println("<ul style=\"display: none;\">");
            for (int j = 0; j < cols.length; j++) {
                out.println("<li class=\"row-collection\">");
                out.println("<div class=\"media-body\"><h4 class=\"media-heading\"><input type='checkbox' name='collection_id' value='" + cols[j].getID() + "' " + (checkAllChildren ? "checked" : "") + "/>" + cols[j].getMetadata("name"));

                out.println("</h4>");
                if (StringUtils.isNotBlank(cols[j].getMetadata("short_description"))) {
                    out.println(cols[j].getMetadata("short_description"));
                }
                out.println("</div>");
                out.println("</li>");
            }
            out.println("</ul>");
        }

        // Get the sub-communities in this community
        Community[] comms = (Community[]) subcommunityMap.get(c.getID());
        if (comms != null && comms.length > 0) {
            out.println("<ul style=\"display: none;\">");
            for (int k = 0; k < comms.length; k++) {
                showCommunity(comms[k], out, request, collectionMap, subcommunityMap, checkAllChildren);
            }
            out.println("</ul>");
        }
        //out.println("</div>");
        out.println("</li>");
    }
%>

<dspace:layout locbar="commLink" title="Cadastro de Submissor">

    <script>

        function checkboxChanged(element) {

            var isChecked = element.prop("checked");
            var parentLi = element.closest("ul").closest("li");

            if (parentLi.prop("tagName") != undefined) {

                var parentCheckbox = parentLi.find("input:checkbox:first");

                if (isChecked == false && parentCheckbox.prop("checked") == true) {
                    parentCheckbox.prop("checked", false);
                    checkboxChanged(parentLi.find("input:checkbox:first"));
                } else if (isChecked) {

                    var allChildrenEquals = true;

                    element.closest("ul").find("input:checkbox").each(function () {
                        if ($(this).prop("checked") != isChecked) {
                            allChildrenEquals = false;
                        }
                    });

                    if (allChildrenEquals) {
                        parentCheckbox.prop("checked", true);
                        checkboxChanged(parentLi.find("input:checkbox:first"));
                    }
                }

            }

        }

        function checkChildren(element) {
            element.closest("li").find("input:checkbox").prop("checked", element.prop("checked"));
        }

        jQuery.validator.addMethod("cpf", function (value, element) {
            value = value.replace('.', '');
            value = value.replace('.', '');
            cpf = value.replace('-', '');
            while (cpf.length < 11)
                cpf = "0" + cpf;
            var expReg = /^0+$|^1+$|^2+$|^3+$|^4+$|^5+$|^6+$|^7+$|^8+$|^9+$/;
            var a = [];
            var b = new Number;
            var c = 11;
            for (i = 0; i < 11; i++) {
                a[i] = cpf.charAt(i);
                if (i < 9)
                    b += (a[i] * --c);
            }
            if ((x = b % 11) < 2) {
                a[9] = 0
            } else {
                a[9] = 11 - x
            }
            b = 0;
            c = 11;
            for (y = 0; y < 10; y++)
                b += (a[y] * c--);
            if ((x = b % 11) < 2) {
                a[10] = 0;
            } else {
                a[10] = 11 - x;
            }
            if ((cpf.charAt(9) != a[9]) || (cpf.charAt(10) != a[10]) || cpf.match(expReg))
                return false;
            return true;
        }, "Informe um CPF válido."); // Mensagem padrão

        $().ready(function () {

            $(".community-checkbox").change(function () {
                checkChildren($(this));
            });

            $("input:checkbox").change(function () {
                checkboxChanged($(this));
            });


            $("#author-form").validate({
                rules: {
                    first_name: {
                        required: true
                    },
                    last_name: {
                        required: true
                    },
                    email: {
                        required: true,
                        email: true
                    },
                    password: {
                        required: true
                    },
                    password_confirmation: {
                        required: true,
                        equalTo: "#tpassword"
                    },
                    cpf: {
                        required: true,
                        //number: true,
                        //minlenght: 11
                        cpf: true
                    },
                    institution_name: {
                        required: true
                    },
                    institution_shortname: {
                        required: true
                    },
                    department: {
                        required: true
                    },
                    job_function: {
                        required: true
                    },
                    phone: {
                        number: true,
                        rangelength: [10, 10]
                    },
                    celphone: {
                        number: true,
                        rangelength: [11, 11]
                    },
                    institution_site: {
                        url: true
                    },
                    institution_repository: {
                        url: true
                    },
                    institution_ava: {
                        url: true
                    },
                    item_count: {
                        required: true,
                        number: true
                    }
                }, messages: {
                    first_name: "Por favor, digite o primeiro nome",
                    last_name: "Por favor, digite o último nome",
                    email: {
                        required: "Por favor, digite o e-mail",
                        email: "E-mail inválido"
                    },
                    password: "Por favor, digite a senha",
                    password_confirmation: {
                        required: "Por favor, digite a confirmação de senha",
                        equalTo: "Senha e confirmação de senha devem ser iguais"
                    },
                    cpf: {
                        required: "Por favor, digite o CPF",
                        //number: "Utilize apenas número para o CPF",
                        //minlenght: "CPF inválido"
                        cpf: "CPF inválido"
                    },
                    institution_name: "Por favor, digite o nome da instituição",
                    institution_shortname: "Por favor, digite a sigla da instituição",
                    department: "Por favor, digite o departamento",
                    job_function: "Por favor, digite a função",
                    phone: {
                        number: "Telefone inválido. Utilize apenas números",
                        rangelength: "Telefone inválido. Utilize apenas números"
                    },
                    celphone: {
                        number: "Celular inválido. Utilize apenas números",
                        rangelength: "Celular inválido. Utilize apenas números"
                    },
                    institution_site: {
                        url: "URL inválida"
                    },
                    institution_repository: {
                        url: "URL inválida"
                    },
                    institution_ava: {
                        url: "URL inválida"
                    },
                    item_count: {
                        required: "Por favor, digite a quantidade de itens",
                        number: "Valor inválido"
                    }

                }
            });
        });
    </script>


    <% if (AuthorizeManager.isAdmin(context)) {%>

    <h2 align="center">Dados do Submissor</h2>
    <table id="example" class="table-striped table-bordered" cellspacing="0" width="auto">
        <thead>
        <tr>
            <th>Nome</th>
            <th>E-mail</th>
            <th>CPF</th>
            <th>Departamento</th>
            <th>Cargo</th>
        </tr>
        </thead>

        <tbody>
        <tr align="center">
            <td><%= Utils.addEntities(firstName) + " " + Utils.addEntities(lastName) %>
            </td>
            <td><%= Utils.addEntities(email)%>
            </td>
            <td><%= Utils.addEntities(cpf)%>
            </td>
            <td><%= Utils.addEntities(department)%>
            </td>
            <td><%= Utils.addEntities(jobTitle)%>
            </td>
        </tr>
        </tbody>
        <br/>

        <thead>
        <tr align="center">
            <th>Telefone</th>
            <th>Celular</th>
            <th>Quantidade de Itens</th>
            <th>Línguagem</th>
            <th>Nome da Instituição</th>
        </tr>
        </thead>


        <tbody>
        <tr align="center">
            <td><%= Utils.addEntities(phone)%>
            </td>
            <td><%= Utils.addEntities(celphone)%>
            </td>
            <td><%= Utils.addEntities(itemCountString)%>
            </td>
            <td><%= UIUtil.getSessionLocale(request)%>
            </td>
            <td><%= Utils.addEntities(institutionName)%></td>

        </tr>
        </tbody>

        <br/>

        <thead>
        <tr align="center">
            <th>Sigla da Instituição</th>
            <th>Sítio da Instituição</th>
            <th>Repositório da Instituição</th>
            <th>AVA Educacional</th>
        </tr>
        </thead>

        <tbody>
        <tr align="center">
            <td><%= Utils.addEntities(institutionShortname)%></td>
            <td><%= Utils.addEntities(institutionSite)%>
            </td>
            <td><%= Utils.addEntities(institutionRepository)%>
            </td>
            <td><%= Utils.addEntities(institutionAva)%>
            </td>
        </tr>
        </tbody>

    </table>

    <%} else {%>


    <% if (request.getAttribute("errorMessage") != null) {%>
    <div class="alert alert-danger">
        <strong><fmt:message key="jsp.register.profile.error"/></strong>
        <p><%= request.getAttribute("errorMessage")%>
        </p>
    </div>
    <% }%>

    <h2 align="center"><fmt:message key="jsp.register.profile.title"/></h2>
    <br/>

    <form method="POST" action="<%= request.getContextPath()%>/register/edit-author" id="author-form">
        <input type="hidden" name="operation" value="<%= operation %>"/>
        <input type="hidden" name="author_id" value="<%= authorId %>"/>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="first_name"><fmt:message
                    key="jsp.register.profile-form.fname.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="first_name" id="first_name" size="40"
                                         value="<%= Utils.addEntities(firstName)%>"/></div>
        </div>

        <div class="form-group row">
                <%-- <td align="right" class="standard"><label for="tlast_name"><strong>Last name*:</strong></label></td> --%>
            <label class="col-md-2 control-label" for="tlast_name"><fmt:message
                    key="jsp.register.profile-form.lname.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="last_name" id="tlast_name" size="40"
                                         value="<%= Utils.addEntities(lastName)%>"/></div>
        </div>

        <div class="form-group row">
                <%-- <td align="right" class="standard"><label for="tlast_name"><strong>Last name*:</strong></label></td> --%>
            <label class="col-md-2 control-label" for="temail"><fmt:message
                    key="jsp.register.profile-form.email.field"/></label>
            <div class="col-md-6"><input class="form-control" type="email" name="email" id="temail" size="20"
                                         maxlength="64" value="<%= Utils.addEntities(email)%>"/></div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tpassword"><fmt:message
                    key="jsp.register.profile-form.password.field"/></label>
            <div class="col-md-6"><input class="form-control" type="password" name="password" id="tpassword" size="100"
                                         value=""/></div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tpasswordconfirmation"><fmt:message
                    key="jsp.register.profile-form.passwordconfirmation.field"/></label>
            <div class="col-md-6"><input class="form-control" type="password" name="password_confirmation"
                                         id="tpasswordconfirmation" size="100" value=""/></div>
        </div>

        <div class="form-group row">
                <%-- <td align="right" class="standard"><label for="tlast_name"><strong>Last name*:</strong></label></td> --%>
            <label class="col-md-2 control-label" for="tcpf"><fmt:message
                    key="jsp.register.profile-form.cpf.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="cpf" id="tcpf" size="11" maxlength="11"
                                         value="<%= Utils.addEntities(cpf)%>"/></div>
        </div>

        <div class="form-group row">
                <%-- <td align="right" class="standard"><label for="tlast_name"><strong>Last name*:</strong></label></td> --%>
            <label class="col-md-2 control-label" for="tinstitutionname"><fmt:message
                    key="jsp.register.profile-form.institutionname.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="institution_name" id="tinstitutionname"
                                         size="11" maxlength="100" value="<%= Utils.addEntities(institutionName)%>"/>
            </div>
        </div>

        <div class="form-group row">
                <%-- <td align="right" class="standard"><label for="tlast_name"><strong>Last name*:</strong></label></td> --%>
            <label class="col-md-2 control-label" for="tinstitutionshortname"><fmt:message
                    key="jsp.register.profile-form.institutionshortname.field"/></label>
                <%-- <div class="col-md-6"><input class="form-control" type="text" name="institution_shortname" id="tinstitutionshortname" size="20" value="<%= Utils.addEntities(institutionShortname)%>" /></div> --%>
            <div class="col-md-6"><input class="form-control" type="text" name="institution_shortname"
                                         id="tinstitutionshortname" size="11" maxlength="20"
                                         value="<%= Utils.addEntities(institutionShortname)%>"/></div>
        </div>

        <div class="form-group row">
                <%-- <td align="right" class="standard"><label for="tlast_name"><strong>Last name*:</strong></label></td> --%>
            <label class="col-md-2 control-label" for="tdepartment"><fmt:message
                    key="jsp.register.profile-form.department.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="department" id="tdepartment" size="100"
                                         maxlength="100" value="<%= Utils.addEntities(department)%>"/></div>
        </div>

        <div class="form-group row">
                <%-- <td align="right" class="standard"><label for="tlast_name"><strong>Last name*:</strong></label></td> --%>
            <label class="col-md-2 control-label" for="tjobfunction"><fmt:message
                    key="jsp.register.profile-form.jobfunction.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="job_function" id="tjobfunction"
                                         size="100" maxlength="50" value="<%= Utils.addEntities(jobTitle)%>"/></div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tphone"><fmt:message
                    key="jsp.register.profile-form.phone.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="phone" id="tphone" size="40"
                                         maxlength="10" value="<%= Utils.addEntities(phone)%>"/></div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tcelphone"><fmt:message
                    key="jsp.register.profile-form.celphone.field"/></label>
                <%-- <div class="col-md-6"><input class="form-control" type="text" name="celphone" id="tcelphone" size="40" maxlength="32" value="<%= Utils.addEntities(celphone)%>"/></div>--%>
            <div class="col-md-6"><input class="form-control" type="text" name="celphone" id="tcelphone" size="40"
                                         maxlength="11" value="<%= Utils.addEntities(celphone)%>"/></div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tinstitutionsite"><fmt:message
                    key="jsp.register.profile-form.institutionsite.field"/></label>
            <div class="col-md-6"><input class="form-control" type="url" name="institution_site" id="tinstitutionsite"
                                         size="255" maxlength="255" value="<%= Utils.addEntities(institutionSite)%>"/>
            </div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tinstitutionrepository"><fmt:message
                    key="jsp.register.profile-form.institutionrepository.field"/></label>
            <div class="col-md-6"><input class="form-control" type="url" name="institution_repository"
                                         id="tinstitutionrepository" size="255" maxlength="255"
                                         value="<%= Utils.addEntities(institutionRepository)%>"/></div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tinstitutionava"><fmt:message
                    key="jsp.register.profile-form.institutionava.field"/></label>
            <div class="col-md-6"><input class="form-control" type="url" name="institution_ava" id="tinstitutionava"
                                         size="255" maxlength="255" value="<%= Utils.addEntities(institutionAva)%>"/>
            </div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="titemcount"><fmt:message
                    key="jsp.register.profile-form.itemcount.field"/></label>
            <div class="col-md-6"><input class="form-control" type="text" name="item_count" id="titemcount" size="5"
                                         value="<%= Utils.addEntities(itemCountString)%>"/></div>
        </div>

        <div class="form-group row">
            <label class="col-md-2 control-label" for="tlanguage"><strong><fmt:message
                    key="jsp.register.profile-form.language.field"/></strong></label>
            <div class="col-md-8">
                <select class="form-control" name="language" id="tlanguage">
                    <%
                        for (int i = supportedLocales.length - 1; i >= 0; i--) {
                            String lang = supportedLocales[i].toString();
                            String selected = "";

                            if (language.equals("")) {
                                if (lang.equals(I18nUtil.getSupportedLocale(request.getLocale()).getLanguage())) {
                                    selected = "selected=\"selected\"";
                                }
                            } else if (lang.equals(language)) {
                                selected = "selected=\"selected\"";
                            }
                    %>
                    <option <%= selected%>
                            value="<%= lang%>"><%= supportedLocales[i].getDisplayName(UIUtil.getSessionLocale(request))%>
                    </option>
                    <%
                        }
                    %>
                </select>
            </div>
        </div>


        <% if (!AuthorizeManager.isAdmin(context)) {%>

        <div align="center" class="form-group row">
            <br>
            <input class="btn btn-lg btn-primary" type="submit" value="Enviar"/>
            <!--<button class="btn btn-primary" type="submit">Enviar</button>-->
        </div>

        <%}%>
    </form>
    <%}%>


    <% if (AuthorizeManager.isAdmin(context) && authorForm != null) {%>
    <h2>Autorização em coleções</h2>

    <div class="site-community-collection-area">

        <form method="POST" action="<%= request.getContextPath()%>/register/manage-authors">
            <input type="hidden" name="author_id" value="<%= authorForm.getID() %>"/>
            <div class="form-group row">
                <label class="col-md-3 control-label" for="titemcount">Selecione as coleções:</label>
                <div class="col-md-9">
                    <% if (communities != null && communities.length != 0) {%>
                    <ul style="display: block;">
                        <%
                            for (int i = 0; i < communities.length; i++) {
                                if ((educapesCommunityHandle != null && educapesCommunityHandle.equals(communities[i].getHandle()))
                                        || (materiaisUabCommunityHandle != null && materiaisUabCommunityHandle.equals(communities[i].getHandle()))
                                        ) {
                                    boolean checkAllChildren = educapesCommunityHandle.equals(communities[i].getHandle());
                                    showCommunity(communities[i], out, request, collectionMap, subcommunityMap, checkAllChildren);
                                }

                            }
                        %>
                    </ul>
                    <% } %>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-md-3 control-label" for="titemcount">Operação:</label>
                <div class="col-md-9">
                    <input type="radio" name="operation" value="accept" checked="checked"> Aceitar
                    &nbsp;<input type="radio" name="operation" value="refuse"> Rejeitar
                </div>
            </div>

            <div class="form-group row" id="rejection-cause-area">
                <label class="col-md-3 control-label" for="tcause">Motivo da rejeição:</label>
                <div class="col-md-9"><textarea name="cause" rows="4" cols="50"></textarea></div>
            </div>

            <div align="center">
                <input class="btn btn-primary" type="submit" value="Confirmar"/>
            </div>
        </form>
    </div>

    <% }%>

</dspace:layout>