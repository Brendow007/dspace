<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.core.Context"%>
<%@page import="org.dspace.core.ConfigurationManager"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.io.IOException"%>
<%@page import="org.dspace.browse.ItemCountException"%>
<%@page import="org.dspace.authorize.AuthorizeManager"%>
<%@page import="java.util.Map"%>
<%@page import="org.dspace.content.Community"%>
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

<%@ page import="java.util.Locale"%>

<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="br.com.capes.eperson.Author" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.content.Collection" %>

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




<dspace:layout locbar="commLink" title="Detalhe do Submissor">


 <% if (AuthorizeManager.isAdmin(context)) {%>

    <h2 align="center">Dados do Submissor</h2>
    <div class="content">
    <table id="example" class="table-striped table-bordered" cellspacing="0" width="auto">
        <thead>
            <th>Nome</th>
            <th>E-mail</th>
            <th>CPF</th>
            <th>Sigla da Instituição</th>
            <th>Departamento</th>
            <th>Cargo</th>
        </thead>

        <tbody>
            <td><%= Utils.addEntities(firstName) + " " + Utils.addEntities(lastName) %>
            </td>
            <td><%= Utils.addEntities(email)%>
            </td>
            <td><%= Utils.addEntities(cpf)%>
            </td>
            <td><%= Utils.addEntities(institutionShortname)%>
            </td>
            <td><%= Utils.addEntities(department)%>
            </td>
            <td><%= Utils.addEntities(jobTitle)%>
            </td>
        </tbody>

        <thead>
        <tr align="center">
            <th>Telefone</th>
            <th>Celular</th>
            <th>Quantidade de Itens</th>
            <th>Línguagem</th>
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
        </tr>
        </tbody>


        <thead>
        <tr align="center">
            <th>Nome da Instituição</th>
            <th>Sítio da Instituição</th>
            <th>Repositório da Instituição</th>
            <th>AVA Educacional</th>
        </tr>
        </thead>

        <tbody>
        <tr align="center">
            <td><%= Utils.addEntities(institutionName)%></td>

            <td><%= Utils.addEntities(institutionSite)%>
            </td>
            <td><%= Utils.addEntities(institutionRepository)%>
            </td>
            <td><%= Utils.addEntities(institutionAva)%>
            </td>
        </tr>
        </tbody>

    </table>
</div>
	<%} %>
	
	
	</dspace:layout>