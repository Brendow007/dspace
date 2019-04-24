<%-- 
    Document   : search
    Created on : 17/07/2016, 15:57:27
    Author     : guilherme/brendow
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<dspace:layout locbar="off" title="jsp.layout.navbar-default.partners">
    <link rel="stylesheet" href="<%= request.getContextPath()%>/static/css/parceiros.css" type="text/css"/>
    <div>
        <h1 align="center">Parceiros</h1>

    </div>
    <br/>


    <style>

        .carousel-inner > .item > img,
        .carousel-inner > .item > a > img {
            width: 450px;
            margin: auto;
            height: 250px;
        }

        .container {
            padding-left: 0% !important;
        }

    </style>
    </head>


    <div class="container">

        <br>

        <div id="myCarousel" class="carousel slide" data-ride="carousel">
            <!-- Indicators -->
            <ol class="carousel-indicators">
                <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
                <!--   <li data-target="#myCarousel" data-slide-to="1"></li>
                  <li data-target="#myCarousel" data-slide-to="2"></li>
                  <li data-target="#myCarousel" data-slide-to="3"></li>
                  <li data-target="#myCarousel" data-slide-to="4"></li>-->
            </ol>

            <!-- Wrapper for slides -->
            <div class="carousel-inner" role="listbox">

                <div class="item">
                    <a href="http://uab.capes.gov.br/" target="_blank"> <img alt="Logo UAB" data-pin-nopin="true"
                                                                             src="<%= request.getContextPath()%>/image/capes/parceiros2/uabs.jpg"
                                                                             width="300" height="300"></a>
                </div>

                <div class="item">
                    <a href="http://www.unesp.br/" target="_blank"> <img alt="Logo UNESP" data-pin-nopin="true"
                                                                         src="<%= request.getContextPath()%>/image/capes/parceiros2/unesp.jpg"
                                                                         alt="Chania" width="300" height="300"></a>
                </div>

                <div class="item">
                    <a href="http://www.sbm.org.br/" target="_blank"> <img alt="Sociedade Brasileira de Matematica"
                                                                           src="<%= request.getContextPath()%>/image/capes/parceiros2/logo_sbm.jpg"
                                                                           width="300" height="300"></a>
                </div>

                <div class="item">
                    <a href="http://objetoseducacionais2.mec.gov.br/" target="_blank"> <img
                            alt="Banco Internacional de Objetos Educacionais"
                            src="<%= request.getContextPath()%>/image/capes/parceiros2/BIOE2.jpg" width="300"
                            height="300"></a>
                </div>

                <div class="item"><a href="http://www.inpe.br/" target="_blank"> <img alt="Logo INPE"
                                                                                      src="<%= request.getContextPath()%>/image/capes/parceiros2/INPE.jpg"
                                                                                      alt="Flower" width="300"
                                                                                      height="300"></a>
                </div>

                <div class="item active">
                    <a href="https://pt.khanacademy.org/" target="_blank"> <img alt="Logo Khan Academy"
                                                                                src="<%= request.getContextPath()%>/image/capes/parceiros2/Khan-Academy-logo.jpg"
                                                                                alt="Flower" width="300"
                                                                                height="300"></a>
                </div>

                <div class="item">
                    <a href="http://americanenglish.state.gov" target="_blank"> <img alt="American English"
                                                                                     src="<%= request.getContextPath()%>/image/capes/parceiros2/AE.png"
                                                                                     alt="Flower" width="300"
                                                                                     height="300"></a>
                </div>

                <div class="item">
                    <a href="http://tvescola.mec.gov.br/tve/home" target="_blank"> <img alt="TV Escola"
                                                                                        src="<%= request.getContextPath()%>/image/capes/parceiros2/tvescola.png"
                                                                                        alt="Flower" width="300"
                                                                                        height="300"></a>
                </div>

            </div>

            <!-- Left and right controls -->
            <a class="left carousel-control" href="#myCarousel" role="button" data-slide="prev">
                <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
                <span class="sr-only">Previous</span>
            </a>
            <a class="right carousel-control" href="#myCarousel" role="button" data-slide="next">
                <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
                <span class="sr-only">Next</span>
            </a>
        </div>
    </div>


</dspace:layout>

