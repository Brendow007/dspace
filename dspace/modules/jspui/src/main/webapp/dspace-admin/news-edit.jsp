<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - News Edit Form JSP
  -
  - Attributes:
   --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
           prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.app.webui.servlet.admin.NewsEditServlet" %>
<%@ page import="org.dspace.core.Constants" %>

<%
    String position = (String) request.getAttribute("position");

    //get the existing news
    String news = (String) request.getAttribute("news");
    String image = (String) request.getAttribute("image");

    if (news == null) {
        news = "";
    }
    request.setAttribute("LanguageSwitch", "hide");
%>

<!--Css-->
<link rel="stylesheet" href="<%= request.getContextPath()%>/static/js/external/google-code-prettify/index.css">
<link rel="stylesheet" href="<%= request.getContextPath()%>/static/js/external/google-code-prettify/prettify.css">

<dspace:layout style="submission" titlekey="jsp.dspace-admin.news-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">

    <%-- <h1>News Editor</h1> --%>
    <h1 align="center"><fmt:message key="jsp.dspace-admin.news-edit.heading"/></h1>
    <%-- <p>Add or edit text in the box below to have it appear
    in the <strong><%= positionStr%></strong> of the DSpace home page.</p> --%>
    <form action="<%= request.getContextPath() %>/dspace-admin/news-edit" method="post">
            <%--        <p class="alert alert-info">
                        <% if (position.contains("top")) { %>
                        <fmt:message key="jsp.dspace-admin.news-edit.text.topbox"/>
                        <% } else { %>
                        <fmt:message key="jsp.dspace-admin.news-edit.text.sidebar"/>
                        <% } %>
                    </p>--%>
            <%-- <p>You may format the text using HTML tags, but please note that the HTML will not be validated here.</p> --%>
        <p class="alert alert-warning"><fmt:message key="jsp.dspace-admin.news-edit.text3"/></p>
            <%--<span class="col-md-2"><fmt:message key="jsp.dspace-admin.news-edit.news"/></span>--%>
            <%--  <td class="submitFormLabel">News:</td> --%>
            <%--<span class="col-md-2">--%>
            <%--<select id="selectPublication">--%>
            <%--<option selected value="text">Texto</option>--%>
            <%--<option value="image">Imagem</option>--%>
            <%--<option value="textImg">Texto / Imagem</option>--%>
            <%--</select>--%>
            <%--</span>--%>
            <%--<  type="text" id="news" name="news" value="test"/>--%>
            <%--<textarea class="hidden form-control" id="image" name="image" rows="10" cols="50">--%>
            <%--&lt;%&ndash;<%=image%>&ndash;%&gt;--%>
            <%--</textarea>--%>
            <%--    <div class="col-4" id="image-context">
                    <span id="removeImage" class="btn-link glyphicon glyphicon-trash"></span>
                    <p id="extractedImage"><%=image%></p>
                    <div class="col col-sm-3">
                        <p id="errorSize" class="hide alert alert-danger">Arquivo muito grande!</p>
                    </div>
                    <input id="arquivo" type='file'>
                        &lt;%&ndash;<p id="b64"></p>&ndash;%&gt;
                    <span id="wrapper-img">
                    <img class="news-image" style="max-width: 1200px; max-height: 300px" id="img">
                 </span>
                </div>--%>
        <div class="container">
            <div class="hero-unit">
                <div id="alerts"></div>
                <div class="btn-toolbar" data-role="editor-toolbar" data-target="#editor">
                    <div class="btn-group">
                        <a class="btn dropdown-toggle" data-toggle="dropdown" title="Tipo da fonte"><i
                                class="icon-font"></i><b
                                class="caret"></b></a>
                        <ul class="dropdown-menu">
                        </ul>
                    </div>
                    <div class="btn-group">
                        <a class="btn dropdown-toggle" data-toggle="dropdown" title="Tamanho da fonte"><i
                                class="icon-text-height"></i>&nbsp;<b class="caret"></b></a>
                        <ul class="dropdown-menu">
                            <li><a data-edit="fontSize 5"><font size="5">Grande</font></a></li>
                            <li><a data-edit="fontSize 3"><font size="3">Normal</font></a></li>
                            <li><a data-edit="fontSize 1"><font size="1">Pequena</font></a></li>
                        </ul>
                    </div>
                    <div class="btn-group">
                        <a class="btn" data-edit="bold" title="Negrito (Ctrl/Cmd+B)"><i class="icon-bold"></i></a>
                        <a class="btn" data-edit="italic" title="Italico (Ctrl/Cmd+I)"><i class="icon-italic"></i></a>
                        <a class="btn" data-edit="strikethrough" title="Riscar"><i class="icon-strikethrough"></i></a>
                        <a class="btn" data-edit="underline" title="Sublinhado (Ctrl/Cmd+U)"><i
                                class="icon-underline"></i></a>
                    </div>
                    <div class="btn-group">
                        <a class="btn" data-edit="insertunorderedlist" title="Lista de marcadores"><i
                                class="icon-list-ul"></i></a>
                        <a class="btn" data-edit="insertorderedlist" title="Lista de números"><i
                                class="icon-list-ol"></i></a>
                        <a class="btn" data-edit="outdent" title="Reduzir recuo (Shift+Tab)"><i
                                class="icon-indent-left"></i></a>
                        <a class="btn" data-edit="indent" title="Recuar (Tab)"><i class="icon-indent-right"></i></a>
                    </div>
                    <div class="btn-group">
                        <a class="btn" data-edit="justifyleft" title="Alinhar à esquerda (Ctrl/Cmd+L)"><i
                                class="icon-align-left"></i></a>
                        <a class="btn" data-edit="justifycenter" title="Centralizar (Ctrl/Cmd+E)"><i
                                class="icon-align-center"></i></a>
                        <a class="btn" data-edit="justifyright" title="Alinhar à direita (Ctrl/Cmd+R)"><i
                                class="icon-align-right"></i></a>
                        <a class="btn" data-edit="justifyfull" title="Justificado (Ctrl/Cmd+J)"><i
                                class="icon-align-justify"></i></a>
                    </div>
                    <div class="btn-group">
                        <a class="btn dropdown-toggle" data-toggle="dropdown" title="Hyperlink"><i
                                class="icon-link"></i></a>
                        <div class="dropdown-menu input-append">
                            <input class="span2" placeholder="URL" type="text" data-edit="createLink"/>
                            <button class="btn" type="button">Add</button>
                        </div>
                        <a class="btn" data-edit="unlink" title="Remover Hyperlink"><i class="icon-cut"></i></a>
                    </div>
                    <div class="btn-group">
                        <a class="btn" title="Inserir imagem (ou arrastar e soltar)" id="pictureBtn"><i
                                class="icon-picture"></i></a>
                        <input type="file" data-role="magic-overlay" data-target="#pictureBtn" data-edit="insertImage"/>
                    </div>
                    <div class="btn-group">
                        <a class="btn" data-edit="undo" title="Desfazer (Ctrl/Cmd+Z)"><i class="icon-undo"></i></a>
                        <a class="btn" data-edit="redo" title="Refazer (Ctrl/Cmd+Y)"><i class="icon-repeat"></i></a>
                    </div>
                    <input type="text" data-edit="inserttext" id="voiceBtn" x-webkit-speech=""/>
                </div>
                    <%--editor--%>
                <div id="editor" name="news">
                    <%=news%>
                </div>
            </div>
        </div>
            <%--send form--%>
        <div align="center">
            <textarea class="hide form-control" id="news" name="news" rows="10" cols="50"><%=news%></textarea>
            <input type="hidden" name="position" value='<%=position%>'/>
            <input class="btn btn-primary" type="submit" name="submit_save"
                   value="<fmt:message key="jsp.dspace-admin.general.save"/>"/>
            <input class="btn btn-default" type="submit" name="cancel"
                   value="<fmt:message key="jsp.dspace-admin.general.cancel"/>"/>
        </div>
    </form>


</dspace:layout>
