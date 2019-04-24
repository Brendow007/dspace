<%-- 
    Document   : search
    Created on : 17/09/2016, 15:57:27
    Author     : guilherme
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<dspace:layout locbar="off" title="jsp.layout.navbar-default.sitemap">
    <div>
        <h1>MAPA DO SITE</h1>
        <ul>
            <li>Navegar
                <ul>
                    <li><a href="<%= request.getContextPath() %>/browse?type=subject">Por assunto</a></li>
                    <li><a href="<%= request.getContextPath() %>/browse?type=author">Por autores</a></li>
                    <li><a href="<%= request.getContextPath() %>/browse?type=dateissued">Por data do documento</a></li>
                    <li><a href="<%= request.getContextPath() %>/browse?type=title">Por título</a></li>
                </ul>
            </li>
            <li>Menu Principal
                <ul>
                    <li><a href="<%= request.getContextPath() %>/redirect?action=about">Sobre o eduCapes</a></li>
                    <li><a href="<%= request.getContextPath() %>/redirect?action=search">Como faço minha busca?</a></li>
                    <li><a href="<%= request.getContextPath() %>/redirect?action=submission">Como submeto meu material?</a></li>
                    <li><a href="<%= request.getContextPath() %>/redirect?action=partners">Parceiros</a></li>
                    <li><a href="<%= request.getContextPath() %>/redirect?action=contact">Contato</a></li>
                    <li><a href="<%= request.getContextPath() %>/register/edit-author">Cadastro de autores</a></li>
                </ul>
            </li>
            <li>Serviços
                <ul>
                    <li><a href="http://www.capes.gov.br/sala-de-imprensa">Sala de Imprensa</a></li>
                    <li><a href="http://www.capes.gov.br/editais-abertos">Editais Abertos</a></li>
                    <li><a href="http://www.capes.gov.br/resultados-de-editais">Resultados de Editais</a></li>
                    <li><a href="http://localhost:8080/contact">Fale Conosco</a></li>
                    <li><a href="http://localhost:8080/redirect?action=faq">Dúvidas Frequentes</a></li>
                </ul>
            </li>
            <li>Acesse os Sites
                <ul>
                    <li><a href="http://feb.ufrgs.br/">FEB</a></li>
                    <li><a href="http://www.capes.gov.br/">CAPES</a></li>
                    <li><a href="http://portal.mec.gov.br/">MEC</a></li>
                </ul>
            </li>
            <li>RSS
                <ul>
                    <li><a href="<%= request.getContextPath() %>/redirect?action=rss">O que é </a></li>
                    <li><a href="<%= request.getContextPath() %>/feed/atom_1.0/site">Assine</a></li>
                </ul>
            </li>
            <li><a href="<%= request.getContextPath() %>/redirect?action=contact">Fale Conosco</a></li>
        </ul>
    </div>

</dspace:layout>

