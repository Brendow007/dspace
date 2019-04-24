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

<%@ page import="java.util.Locale"%>

<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.Utils" %>

<dspace:layout locbar="commLink" title="Cadastro de Submissores">
    <div class="row">
        <h2>Cadastro realizado com sucesso!</h2>
        <br/>
        <p>
            Seu cadastro foi realizado com sucesso e enviado para a equipe do eduCapes. Caso seja aprovado, você receberá um e-mail
            informando os próximos passos.
        </p>
        <p>Obrigado!</p>
    </div>
    
</dspace:layout>
