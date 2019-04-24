<%-- 
    Document   : search
    Created on : 17/07/2016, 15:57:27
    Author     : guilherme
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<dspace:layout locbar="off" title="Tutorial de Busca">
    <div class="col-md-12">
        <div class="tutorialBusca">
        <h1 align="center">COMO FAÇO A MINHA PESQUISA?</h1>
               <p> Para fazer uma busca no portal eduCAPES é bem simples. Pode ser realizada pela barra de navegação na
                <a href="<%= request.getContextPath()%>/">página inicial</a> e pela
                <a href="<%= request.getContextPath()%>/simple-search?query=">página de busca</a>.
               </p>

            <h4>Para realizar uma busca é possível utlizar a barra de busca com as seguintes opções de navegação, conforme a imagem abaixo:</h4>
        <h2>Busca principal</h2>

        <img alt="Menu de seleção por assunto, autor, data de publicação e título"
             src="<%= request.getContextPath()%>/image/capes/ajuda/principalSearch.png">
            <h3>Após selecionar uma das opções de navegação você será redirecionado, conforme os exemplos abaixo:</h3>




            <div class="navigateImg">
                <p>Digite o termo que deseja pesquisar no campo de busca e acione o botão <a class="btn btn-primary" href="<%=request.getContextPath()%>/browse?type=subject">IR</a> conforme a imagem abaixo:</p>
                 <img alt="Área de navegação" src="<%= request.getContextPath()%>/image/capes/ajuda/navigateBrowser.png">
            </div>

             <div class="navigateImg">
                 <p>Digite o termo que deseja pesquisar no campo de busca e acione o botão <a class="btn btn-success" href="<%=request.getContextPath()%>/browse?type=title">IR</a> conforme a imagem abaixo:</p>
                 <img alt="Área de navegação" src="<%= request.getContextPath()%>/image/capes/ajuda/navigateFullBrowser.png">
             </div>

            <div class="navigateImg">
            <h1 align="center">FILTROS</h1>
            <p>Para refinar os resultados da busca principal, é possível utilizar as opções de filtro abaixo:</p>
                <img alt="Área de busca" src="<%= request.getContextPath()%>/image/capes/ajuda/filterSearch.png"><br/>
                <p>Ao clicar na opção <strong>"Adicionar filtro"</strong> irá mostrar a caixa de seleção abaixo:</p>
                <img alt="Área de busca" src="<%= request.getContextPath()%>/image/capes/ajuda/filterAdd.png">
                <p>Após inserir o termo de busca e as opções de filtragem desejadas, basta acionar o botão <strong>"Adicionar"</strong></p>
            </div>
         </div>
    </div>
                  <div align="center"><br/>
                  <h3>É possível selecionar filtros prédefinidos na busca, conforme o exemplo abaixo:</h3>
                      <br/></div>
              <div class="navigateImgFilters col-md-10">
                  <img alt="Área de busca" src="<%= request.getContextPath()%>/image/capes/ajuda/filterType.png">
                  <img alt="Área de busca" src="<%= request.getContextPath()%>/image/capes/ajuda/filterLanguage.png">
              </div>

</dspace:layout>
