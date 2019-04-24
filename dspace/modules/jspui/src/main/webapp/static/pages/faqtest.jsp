<%@ page import="java.util.List" %><%--
    Document   : faq
    Created on : 17/07/2016, 15:57:27
    Author     : Brendow
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="org.dspace.content.Faq" %>
<%@ page import="java.util.List" %>
<%@ page import="org.dspace.content.FaqGroup" %>

<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/faq/modernizr.js'></script>
<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/faq/jquery-2.1.1.js'></script>
<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/faq/jquery.mobile.custom.min.js'></script>
<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/faq/main.js'></script>

<link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/faq/css/style.css" type="text/css"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/faq/css/reset.css" type="text/css"/>

<% List<Faq> faqList = (List<Faq>) request.getAttribute("faqlist");%>
<% List<FaqGroup> faqGroup = (List<FaqGroup>) request.getAttribute("faqgroup");%>


<dspace:layout locbar="off" title="Perguntas Frequentes">

    <section class="cd-faq">


        <h3 class="dfaq" align="center">FAQ - Perguntas Frequentes</h3><br/>

        <ul class="cd-faq-categories">


                 <% if (faqGroup != null) { %>
                 <% if (faqGroup.size() > 0) { %>
                 <%for (FaqGroup category:faqGroup){%>
                    <li><a href="#<%=category.getGroupName()%>"><%=category.getGroupName()%></a></li>
                <%}%>
                <%}%>
                <%}%>
        </ul>
                 <div class="cd-faq-items">
                    <% if (faqGroup != null) { %>
                    <% if (faqGroup.size() > 0) { %>
                    <% if (faqList != null) { %>
                    <% if (faqList.size() > 0) { %>
                        <%for (FaqGroup grouplist : faqGroup) {%>
                            <ul id="<%=grouplist.getGroupName()%>" class="cd-faq-group">
                                <li class="cd-faq-title">
                                    <h2><%=grouplist.getGroupName()%></h2>
                                </li>
                                <%for (Faq f : faqList) {%>
                                    <% if (f.getGroupID() == grouplist.getGroupOrder()) {%>
                                        <li>
                                          <a class="cd-faq-trigger" href="#0"><%=f.getQuestion()%></a>
                                            <div class="cd-faq-content">
                                                <p><%=f.getAnswer()%></p>
                                            </div>
                                        </li>
                                    <%}%>
                                <%}%>
                            </ul>
                        <%}%>
                    <%}%>
                    <%}%>
                    <%}%>
                    <%}%>
                </div>
        <a href="#0" class="cd-close-panel">Close</a>
    </section>


</dspace:layout>
