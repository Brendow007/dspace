<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Page that displays the email/password login form
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<dspace:layout style="submission" navbar="default" locbar="off" titlekey="jsp.login.password.title" nocache="true">

    <style>
        .glyphicon-question-sign:before {
            content: "\e085";
            color: white;
            background: transparent;
        }
    </style>
    <div class="row">
        <div class="col-md-12 breadcrumbs">
            <ul>
                <li><a href="index.html">eduCAPES</a></li>
                <li>login</li>
            </ul>
        </div>
    </div>
    <header class="page-header">
        <div class="container">
            <div class="panel-heading">
                <fmt:message key="jsp.login.password.heading"/>

                <span class="pull-right"><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#login\"%>"><fmt:message key="jsp.help"/></dspace:popup></span>
            </div>
        </div>
    </header>



    <div class="panel">
        <dspace:include page="/components/login-form.jsp" />
    </div>

</dspace:layout>
