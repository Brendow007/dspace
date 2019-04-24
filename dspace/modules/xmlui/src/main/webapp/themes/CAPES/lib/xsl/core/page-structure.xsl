<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:confman="org.dspace.core.ConfigurationManager"
                xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman">

    <xsl:output indent="yes" />

    <!-- Requested Page URI. Some functions may alter behavior of processing 
    depending if URI matches a pattern. Specifically, adding a static page will 
    need to override the DRI, to directly add content. -->
    <xsl:variable name="request-uri"
                  select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']" />
    <!-- The starting point of any XSL processing is matching the root element. 
    In DRI the root element is document, which contains a version attribute and 
    three top level elements: body, options, meta (in that order). This template 
    creates the html document, giving it a head and body. A title and the CSS 
    style reference are placed in the html head, while the body is further split 
    into several divs. The top-level div directly under html body is called "ds-main". 
    It is further subdivided into: "ds-header" - the header div containing title, 
    subtitle, trail and other front matter "ds-body" - the div containing all 
    the content of the page; built from the contents of dri:body "ds-options" 
    - the div with all the navigation and actions; built from the contents of 
    dri:options "ds-footer" - optional footer div, containing misc information 
    The order in which the top level divisions appear may have some impact on 
    the design of CSS and the final appearance of the DSpace page. While the 
    layout of the DRI schema does favor the above div arrangement, nothing is 
    preventing the designer from changing them around or adding new ones by overriding 
    the dri:document template. -->
    <xsl:template match="dri:document">
        <html lang="pt-br">
            <!-- First of all, build the HTML head element -->
            <xsl:call-template name="buildHead" />
            <!-- Then proceed to the body -->

            <body>

            <xsl:choose>
                <xsl:when
                    test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                    <xsl:apply-templates select="dri:body/*" />
                </xsl:when>
                <xsl:otherwise>

                    <!--The header div, complete with title, subtitle and other junk -->
                    <xsl:call-template name="buildHeader" />

                    <!--javascript-disabled warning, will be invisible if javascript is 
                    enabled -->
                    <div class="hide">
                        <div class="notice failure">
                            <xsl:text>JavaScript esta desabilitado no seu navegador. Alguns recursos deste site podem não funcionar sem ele.</xsl:text>
                        </div>
                    </div>

                    <main>
			<xsl:if test="$request-uri = ''">
				<xsl:attribute name="id">mainHome</xsl:attribute>
			</xsl:if>

                        <div class="centraliza">
                            <xsl:call-template name="buildTrail"/>
                            <!-- Goes over the document tag's children elements: body, options, 
                            meta. The body template generates the ds-body div that contains all the content. 
                            The options template generates the ds-options div that contains the navigation 
                            and action options available to the user. The meta element is ignored since 
                            its contents are not processed directly, but instead referenced from the 
                            different points in the document. -->
                            <xsl:apply-templates />
                        </div>
                    </main>


                    <!--ds-content is a groups ds-body and the navigation together and used 
                    to put the clearfix on, center, etc. ds-content-wrapper is necessary for 
                    IE6 to allow it to center the page content -->
                    <!--<div id="ds-content-wrapper"> <div id="ds-content" class="clearfix"> -->
                    <!-- Goes over the document tag's children elements: body, options, 
                    meta. The body template generates the ds-body div that contains all the content. 
                    The options template generates the ds-options div that contains the navigation 
                    and action options available to the user. The meta element is ignored since 
                    its contents are not processed directly, but instead referenced from the 
                    different points in the document. -->
                    <!--<xsl:apply-templates/> </div> </div> -->


                    <!-- The footer div, dropping whatever extra information is needed on 
                    the page. It will most likely be something similar in structure to the currently 
                    given example. -->
                    <xsl:call-template name="buildFooter" />

                </xsl:otherwise>
            </xsl:choose>
            <!-- Javascript at the bottom for fast page loading -->
            <xsl:call-template name="addJavascript" />

            </body>
        </html>
    </xsl:template>


    <!-- The HTML head element contains references to CSS as well as embedded 
    JavaScript code. Most of this information is either user-provided bits of 
    post-processing (as in the case of the JavaScript), or references to stylesheets 
    pulled directly from the pageMeta element. -->
    <xsl:template name="buildHead">
        <div id="barra-brasil">
            <div id="wrapper-barra-brasil">
                <div class="brasil-flag">
                    <a href="http://brasil.gov.br" class="link-barra">
                        <!-- TODO: Verificar porque estes valores nao estao sendo substituidos 
                        na tela de navegacao por Comunidades e Colecoes -->
                        <!-- <i18n:text>xmlui.brazil-bar.brazil</i18n:text> -->
                        BRASIL
                    </a>
                </div>
                <span class="acesso-info">
                    <a href="http://brasil.gov.br/barra#acesso-informacao" class="link-barra">
                        <!-- <i18n:text>xmlui.brazil-bar.information_access</i18n:text> -->
                        Acesso à informação
                    </a>
                </span>
                <ul class="list">
                    <li class="list-item first">
                        <a href="http://brasil.gov.br/barra#participe" class="link-barra">
                            <!-- <i18n:text>xmlui.brazil-bar.join</i18n:text> -->
                            Participe
                        </a>
                    </li>
                    <li class="list-item">
                        <a href="http://www.servicos.gov.br/" class="link-barra">
                            <!-- <i18n:text>xmlui.brazil-bar.services</i18n:text> -->
                            Serviços
                        </a>
                    </li>
                    <li class="list-item">
                        <a href="http://www.planalto.gov.br/legislacao" class="link-barra">
                            <!-- <i18n:text>xmlui.brazil-bar.laws</i18n:text> -->
                            Legislação
                        </a>
                    </li>
                    <li class="list-item last last-item">
                        <a href="http://brasil.gov.br/barra#orgaos-atuacao-canais" class="link-barra">
                            <!-- <i18n:text>xmlui.brazil-bar.channels</i18n:text> -->
                            Canais
                        </a>
                    </li>
                </ul>
            </div>
        </div>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

            <!-- Always force latest IE rendering engine (even in intranet) & Chrome 
            Frame -->
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

            <!-- Mobile Viewport Fix j.mp/mobileviewport & davidbcalhoun.com/2010/viewport-metatag 
            device-width : Occupy full width of the screen in its current orientation 
            initial-scale = 1.0 retains dimensions instead of zooming out if page height 
            > device height maximum-scale = 1.0 retains dimensions instead of zooming 
            in if page width < device width -->
            <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;" />

            <link rel="shortcut icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                    <xsl:text>/images/capes/favicon.ico</xsl:text>
                </xsl:attribute>
            </link>

            <meta name="Generator">
                <xsl:attribute name="content">
                    <xsl:text>DSpace</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                        <xsl:text> </xsl:text>
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']" />
                    </xsl:if>
                </xsl:attribute>
            </meta>
            
             <link rel="stylesheet" type="text/css" title="semcontraste">
                <xsl:attribute name="href">
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                    <xsl:text>/lib/css/estrutura.css</xsl:text>
                </xsl:attribute>
            </link>
                        
            <link rel="alternate stylesheet" type="text/css" title="altocontraste">
                <xsl:attribute name="href">
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                    <xsl:text>/lib/css/estrutura-altocontraste.css</xsl:text>
                </xsl:attribute>
            </link>
            
             <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                    <xsl:text>/lib/js/acessibilidade.js</xsl:text>
                </xsl:attribute>
			&#160;
            </script>
            
            <!-- Add stylesheets -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier" />
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="." />
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <!-- Add syndication feeds -->
            <xsl:for-each
                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
                <link rel="alternate" type="application">
                    <xsl:attribute name="type">
                        <xsl:text>application/</xsl:text>
                        <xsl:value-of select="@qualifier" />
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="." />
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <!-- Add OpenSearch auto-discovery link -->
            <xsl:if
                test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']" />
                        <xsl:text>://</xsl:text>
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']" />
                        <xsl:text>:</xsl:text>
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']" />
                        <xsl:value-of select="$context-path" />
                        <xsl:text>/</xsl:text>
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='autolink']" />
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']" />
                    </xsl:attribute>
                </link>
            </xsl:if>

            <!-- The following javascript removes the default text of empty text areas 
            when they are focused on or submitted -->
            <!-- There is also javascript to disable submitting a form when the 'enter' 
            key is pressed. -->
            <script type="text/javascript">
                //Clear default text of empty text areas on focus
                function tFocus(element)
                {
                if (element.value == '
                <i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>
                '){element.value='';}
                }
                //Clear default text of empty text areas on submit
                function tSubmit(form)
                {
                var defaultedElements = document.getElementsByTagName("textarea");
                for (var i=0; i != defaultedElements.length; i++){
                if (defaultedElements[i].value == '
                <i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>
                '){
                defaultedElements[i].value='';}}
                }
                //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter'
                causes a submission to start over)
                function disableEnterKey(e)
                {
                var key;

                if(window.event)
                key = window.event.keyCode; //Internet Explorer
                else
                key = e.which; //Firefox and Netscape

                if(key == 13) //if "Enter" pressed, then disable!
                return false;
                else
                return true;
                }

                function FnArray()
                {
                this.funcs = new Array;
                }

                FnArray.prototype.add = function(f)
                {
                if( typeof f!= "function" )
                {
                f = new Function(f);
                }
                this.funcs[this.funcs.length] = f;
                };

                FnArray.prototype.execute = function()
                {
                for( var i=0; i
                <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
                this.funcs.length; i++ )
                {
                this.funcs[i]();
                }
                };

                var runAfterJSImports = new FnArray();
            </script>

            <!-- Modernizr enables HTML5 elements & feature detects -->
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                    <xsl:text>/lib/js/modernizr-1.7.min.js</xsl:text>
                </xsl:attribute>
				&#160;
            </script>

            <!-- Add the title in -->
            <xsl:variable name="page_title"
                          select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']" />
            <title>
                <!-- <i18n:text>xmlui.capes.repo_name</i18n:text> -->
                eduCAPES
            </title>

            <!-- Head metadata in item pages -->
            <xsl:if
                test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of
                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                    disable-output-escaping="yes" />
            </xsl:if>

            <!-- Add all Google Scholar Metadata values -->
            <xsl:for-each
                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
                <meta name="{@element}" content="{.}"></meta>
            </xsl:for-each>
        </head>
    </xsl:template>

    <xsl:template name="buildHeader">
        <header>
            <div id="cabecalho">
                <div class="centraliza">
                    <div id="hotkeys-acessibilidade">
                        <ul id="lista-hotkeys">
                            <li>
                                <a accesskey="1" href="#ds-body" id="link-ds-body">
                                    <i18n:text>xmlui.acessibility_keys.go-to-body</i18n:text>&#160;
                                    <!--Ir para conteúdo&#160;-->
                                    <span>1</span>
                                </a>
                            </li>
                            <li>
                                <a accesskey="2" href="#ds-options" id="link-ds-options">
                                    <i18n:text>xmlui.acessibility_keys.go-to-nav-menus</i18n:text>&#160;
                                    <!--Ir para menu&#160;-->
                                    <span>2</span>
                                </a>
                            </li>
                            <li>
                                <!-- <a accesskey="3" href="#ds-search_repository" id="link-ds-search_repository"> -->
                                <a accesskey="3" href="#" id="link-ds-search_repository">
                                    <i18n:text>xmlui.acessibility_keys.go-to-search-field</i18n:text>&#160;
                                    <!--Ir para busca&#160;-->
                                    <span>3</span>
                                </a>
                            </li>
                            <li>
                                <a accesskey="4" href="#menus" id="link-menus">
                                    <i18n:text>xmlui.acessibility_keys.go-to-footer</i18n:text>&#160;
                                    <!--Ir para rodapé&#160;-->
                                    <span>4</span>
                                </a>
                            </li>
                        </ul>
                    </div>
                    <div id="sobre-acessibilidade">
                        <ul>
                            <li>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                        <xsl:text>/page/accessibility</xsl:text>
                                    </xsl:attribute>
                                    <i18n:text>xmlui.acessibility_bar.acessibility</i18n:text>
                                    <!-- ACESSIBILIDADE -->
                                </a>
                            </li>
                            <li>
                                <a id="link_altocontraste" href="#">
                                    <i18n:text>xmlui.acessibility_bar.high_contrast</i18n:text>
                                    <!--ALTO CONTRASTE-->
                                </a>
                            </li>
                            <li>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                        <xsl:text>/community-list</xsl:text>
                                    </xsl:attribute>
                                    <i18n:text>xmlui.acessibility_bar.site_map</i18n:text>
                                    <!--MAPA DO SITE-->
                                </a>
                            </li>
                        </ul>
                    </div>
                    <div id="logo">
                        <a id="ds-header-logo-link" title="Capes">
                            <xsl:attribute name="href">
                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                <xsl:text>/</xsl:text>
                            </xsl:attribute>
                            <span class="mini-titulo">
                                <i18n:text>xmlui.header.mini_title</i18n:text>
                                <!-- Portal -->
                            </span>
                            <h1>
                                <i18n:text>xmlui.header.title</i18n:text>
                                <!-- eduCAPES -->
                            </h1>
                            <span class="descricao">
                                <i18n:text>xmlui.header.description</i18n:text>
                                <!--CAPES-->
                            </span><br/>
                            <span class="descricao"><i18n:text>xmlui.header.beta.version</i18n:text></span>
                        </a>
                    </div>
                    <div id="busca">
                        <form id="ds-search-form" method="post">
                            <xsl:attribute name="action">
                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']" />
                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']" />
                            </xsl:attribute>
                            <label class="hide">Buscar:</label>
                            <input id="ds-search_repository" class="ds-text-field " type="text" placeholder="Buscar no repositório">
                                <xsl:attribute name="name">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']" />
                                </xsl:attribute>
                            </input>
                            <!-- <input class="ds-button-field" name="submit" type="submit" i18n:attr="value" value="xmlui.general.go"> -->
                            <input class="ds-button-field" name="submit" type="submit" value="">
                                <xsl:attribute name="onclick">
                                    <xsl:text>
                                        var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                        if (radio != undefined &amp;&amp; radio.checked)
                                        {
                                        var form = document.getElementById(&quot;ds-search-form&quot;);
                                        form.action=
                                    </xsl:text>
                                    <xsl:text>&quot;</xsl:text>
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']" />
                                    <xsl:text>/handle/&quot; + radio.value + &quot;</xsl:text>
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']" />
                                    <xsl:text>&quot; ; </xsl:text>
                                    <xsl:text>
                                        }
                                    </xsl:text>
                                </xsl:attribute>
                            </input>
                            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container']">
                                <div id="advanced-serch-options">
                                    <label>
                                        <input id="ds-search-form-scope-all" type="radio" name="scope" value="" checked="checked" />
                                        <i18n:text>xmlui.dri2xhtml.structural.search</i18n:text>
                                    </label>
                                    <label>
                                        <input id="ds-search-form-scope-container" type="radio" name="scope">
                                            <xsl:attribute name="value">
                                                <xsl:value-of select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container'],':')" />
                                            </xsl:attribute>
                                        </input>
                                        <xsl:choose>
                                            <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='containerType']/text() = 'type:community'">
                                                <i18n:text>xmlui.dri2xhtml.structural.search-in-community</i18n:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <i18n:text>xmlui.dri2xhtml.structural.search-in-collection</i18n:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </label>
                                </div>
                            </xsl:if>
                        </form>
                        <!-- <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='advancedURL'] != /dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"> -->
                            <!-- The "Advanced search" link, to be perched underneath the search box -->
                            <a class="busca-avancada">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='advancedURL']" />
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.search-advanced</i18n:text>
                            </a>
                        <!-- </xsl:if> -->
                    </div>
                </div>
                <div class="clear"></div>
                <div id="sobre">
                    <div class="centraliza">
                        <xsl:if test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                            <div class="loggedUser">
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='url']"/>
                                    </xsl:attribute>
                                    <i18n:text>xmlui.dri2xhtml.structural.profile</i18n:text>
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                                </a>
                            </div>
                        </xsl:if>    
                        <nav>
                            <h2 class="hide">Serviços</h2>
                            <ul>
                                <xsl:choose>
                                    <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                        <li>
                                            <a>
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='logoutURL']"/>
                                                </xsl:attribute>
                                                <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                            </a>
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li>
                                            <a class="hide">
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='loginURL']"/>
                                                </xsl:attribute>
                                                <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                                            </a>
                                        </li>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <li>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                            <xsl:text>/page/about</xsl:text>
                                        </xsl:attribute>
                                        <i18n:text>xmlui.navigation.menu.about</i18n:text>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                            <xsl:text>/page/search</xsl:text>
                                        </xsl:attribute>
                                        <i18n:text>xmlui.navigation.menu.search</i18n:text>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                            <xsl:text>/page/partners</xsl:text>
                                        </xsl:attribute>
                                        <i18n:text>xmlui.navigation.menu.partners</i18n:text>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                            <xsl:text>/contact</xsl:text>
                                        </xsl:attribute>
                                        <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                                    </a>
                                </li>
                            </ul>
                            <span class="hide">Fim do menu de serviços</span>
                        </nav>
                    </div>
                </div>
            </div>
        </header>
    </xsl:template>

    <!-- The header (distinct from the HTML head element) contains the title, 
    subtitle, login box and various placeholders for header images -->
    <xsl:template name="buildTrail">
        <xsl:choose>
         <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) > 1">
           <div id="ds-trail-wrapper">
                <ul id="ds-trail">
                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail" />
                </ul>
            </div>
         </xsl:when>
         <xsl:otherwise>
             <xsl:if test="starts-with($request-uri, 'page/')">
                <div id="ds-trail-wrapper">
                    <ul id="ds-trail">
                        <li class="ds-trail-link first-link ">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                    <xsl:text>/</xsl:text>
                                </xsl:attribute>
                                <xsl:text>Página inicial</xsl:text>
                            </a>
                        </li>
                        <li class="ds-trail-arrow">
                            <xsl:text>&#62;</xsl:text>
                        </li>
                        <xsl:choose>
                            <xsl:when test="starts-with($request-uri, 'page/submission')">
                                <li class="ds-trail-link last-link">
                                    <xsl:text>Envie seu material</xsl:text>
                                </li>
                            </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/rss')">
                                <li class="ds-trail-link last-link">
                                    <xsl:text>RSS</xsl:text>
                                </li>
                            </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/accessibility')">
                                <li class="ds-trail-link last-link">
                                    <xsl:text>Acessibilidade</xsl:text>
                                </li>
                            </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/faq')">
                                <li class="ds-trail-link last-link">
                                    <xsl:text>Dúvidas Frequentes</xsl:text>
                                </li>
                            </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/about')">
                                <li class="ds-trail-link last-link">
                                    <xsl:text>Sobre</xsl:text>
                                </li>
                            </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/partners')">
                                <li class="ds-trail-link last-link">
                                    <xsl:text>Parceiros</xsl:text>
                                </li>
                            </xsl:when>
                            <xsl:when test="starts-with($request-uri, 'page/search')">
                                <li class="ds-trail-link last-link">
                                    <xsl:text>Busca</xsl:text>
                                </li>
                            </xsl:when>
                        </xsl:choose>
                    </ul>
                </div>
             </xsl:if>
         </xsl:otherwise>
       </xsl:choose>
    </xsl:template>

    <xsl:template match="dri:trail">
        <!--put an arrow between the parts of the trail -->
        <xsl:if test="position()>1">
            <li class="ds-trail-arrow">
                <xsl:text>&#62;</xsl:text>
            </li>
        </xsl:if>
        <li>
            <xsl:attribute name="class">
                <xsl:text>ds-trail-link </xsl:text>
                <xsl:if test="position()=1">
                    <xsl:text>first-link </xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()">
                    <xsl:text>last-link</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <!-- Determine whether we are dealing with a link or plain text trail 
            link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target" />
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template name="cc-license">
        <xsl:param name="metadataURL" />
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL" />
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>

        <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']" />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']" />
        <xsl:variable name="handleUri">
            <xsl:for-each
                select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()" />
                    </xsl:attribute>
                    <xsl:copy-of select="./node()" />
                </a>
                <xsl:if
                    test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if
            test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
            <div about="{$handleUri}" class="clearfix">
                <xsl:attribute name="style">
                    <xsl:text>margin:0em 2em 0em 2em; padding-bottom:0em;</xsl:text>
                </xsl:attribute>
                <a rel="license" href="{$ccLicenseUri}" alt="{$ccLicenseName}"
                   title="{$ccLicenseName}">
                    <xsl:call-template name="cc-logo">
                        <xsl:with-param name="ccLicenseName" select="$ccLicenseName" />
                        <xsl:with-param name="ccLicenseUri" select="$ccLicenseUri" />
                    </xsl:call-template>
                </a>
                <span>
                    <xsl:attribute name="style">
                        <xsl:text>vertical-align:middle; text-indent:0 !important;</xsl:text>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                    <xsl:value-of select="$ccLicenseName" />
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="cc-logo">
        <xsl:param name="ccLicenseName" />
        <xsl:param name="ccLicenseUri" />
        <xsl:variable name="ccLogo">
            <xsl:choose>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by/')">
                    <xsl:value-of select="'cc-by.png'" />
                </xsl:when>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-sa/')">
                    <xsl:value-of select="'cc-by-sa.png'" />
                </xsl:when>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nd/')">
                    <xsl:value-of select="'cc-by-nd.png'" />
                </xsl:when>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc/')">
                    <xsl:value-of select="'cc-by-nc.png'" />
                </xsl:when>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-sa/')">
                    <xsl:value-of select="'cc-by-nc-sa.png'" />
                </xsl:when>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-nd/')">
                    <xsl:value-of select="'cc-by-nc-nd.png'" />
                </xsl:when>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/zero/')">
                    <xsl:value-of select="'cc-zero.png'" />
                </xsl:when>
                <xsl:when
                    test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/mark/')">
                    <xsl:value-of select="'cc-mark.png'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'cc-generic.png'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ccLogoImgSrc">
            <xsl:value-of select="$theme-path" />
            <xsl:text>/images/creativecommons/</xsl:text>
            <xsl:value-of select="$ccLogo" />
        </xsl:variable>
        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="$ccLogoImgSrc" />
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="$ccLicenseName" />
            </xsl:attribute>
            <xsl:attribute name="style">
                <xsl:text>float:left; margin:0em 1em 0em 0em; border:none;</xsl:text>
            </xsl:attribute>
        </img>
    </xsl:template>


    <!-- Like the header, the footer contains various miscellaneous text, links, 
    and image placeholders -->
    <xsl:template name="buildFooter">
        <div class="clear"></div>
        <xsl:if test="$request-uri != ''">
            <div class="centraliza">
                <div class="back-to-top">
                    <a href="#hotkeys-acessibilidade">Voltar para o topo</a>
                </div>
            </div>
        </xsl:if>
        <footer>
            <xsl:if test="$request-uri = ''">
                <xsl:attribute name="id">footerHome</xsl:attribute>
            </xsl:if>
            <!--<div id="atalhos">
            </div>
            <div class="clear"></div>-->
            <div id="menus">
                <div class="centraliza">
                    <div class="area_menus">
                        <div class="grupo_area_menus">
                            <nav>
                                <h2>Serviços</h2>
                                <ul>
                                    <li>
                                        <a href="http://www.capes.gov.br/sala-de-imprensa">Sala de Imprensa</a>
                                    </li>
                                    <li>
                                        <a href="http://www.capes.gov.br/editais-abertos">Editais Abertos</a>
                                    </li>
                                    <li>
                                        <a href="http://www.capes.gov.br/resultados-de-editais">Resultados de Editais</a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                                <xsl:text>/contact</xsl:text>
                                            </xsl:attribute>
                                            Fale Conosco</a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                                <xsl:text>/page/faq</xsl:text>
                                            </xsl:attribute>
                                            Dúvidas Frequentes</a>
                                    </li>
                                </ul>
                            </nav>
                        </div>   
                    </div>
                    <div class="area_menus">
                        <div class="grupo_area_menus">
                            <nav>
                                <h2>Acesse os Sites</h2>
                                <ul>
                                    <li>
                                        <a href="http://feb.ufrgs.br/">FEB</a>
                                    </li>
                                    <li>
                                        <a href="http://www.capes.gov.br/">CAPES</a>
                                    </li>
                                    <li>
                                        <a href="http://portal.mec.gov.br/">MEC</a>
                                    </li>
                                </ul>
                            </nav>
                        </div>   
                    </div>   
                    <div class="area_menus">
                        <div class="grupo_area_menus">
                            <nav>
                                <h2>RSS</h2>
                                <ul>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                                <xsl:text>/page/rss</xsl:text>
                                            </xsl:attribute>
                                            O que é
                                        </a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                                <xsl:text>/feed/atom_1.0/site</xsl:text>
                                            </xsl:attribute>
                                            Assine
                                        </a>
                                    </li>
                                </ul>
                            </nav>
                        </div>   
                    </div> 
                    <div class="area_menus atendimento">
                        <div class="grupo_area_menus">
                            <nav>
                                <h2>Central de Atendimento</h2>
                                <ul>
                                    <li>
                                        <p>0800 616161 - opção 7 - para assuntos da Capes</p>
                                    </li>
                                    <li>
                                        <p>0800 616161 - opção 0 - subopção 1 - Ciência sem fronteiras</p>
                                    </li>
                                    <li>
                                        <p>Segunda a sexta das 8h às 20h</p>
                                    </li>
                                    <li>
                                        <p>Segunda a sexta das 8h às 20h</p>
                                    </li>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                            <xsl:text>/contact</xsl:text>
                                        </xsl:attribute>
                                        Fale conosco
                                    </a>
                                </ul>
                            </nav>
                        </div>   
                    </div>
                </div>    
            </div>
            <div id="logos">
                <div class="centraliza">
                    <a href="http://www.acessoainformacao.gov.br/" class="logo-acesso pull-left"> 
                        <img alt="Acesso a Informação">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                <xsl:text>/themes/</xsl:text>
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                <xsl:text>/images/capes/acesso-a-informacao.png</xsl:text>
                            </xsl:attribute>
                        </img>
                    </a>
                    <a href="http://www.brasil.gov.br/" class="logo-acesso pull-right"> 
                        <img alt="Brasil - Governo Federal">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                <xsl:text>/themes/</xsl:text>
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                <xsl:text>/images/capes/footer_brasil.png</xsl:text>
                            </xsl:attribute>
                        </img>
                    </a>
                </div>
            </div>
            <div id="rodape">
                <p>
                <!-- <i18n:text>xmlui.capes.all_rights_reserved</i18n:text> -->
                <!--© 2016 Capes. Todos os direitos reservados-->
                    <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">
                            <img alt="Licença Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png">
                                    <xsl:attribute name="src">
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                    <xsl:text>/images/capes/creative-commons-88x31.png</xsl:text>
                                    </xsl:attribute>
                            </img>
                    </a>
                    <br />Este repositório está sob a licença <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Atribuição 4.0 Internacional</a>.
                </p>
                <p>Os autores são responsáveis pela escolha e apresentação de seus textos neste site e pelas opiniões expressadas, que não são necessariamente da CAPES e não comprometem essa organização.</p>
                <p>Repositório construído utilizando  <a href="http://www.dspace.org">DSpace</a></p>
                <!-- <i18n:text>xmlui.capes.dspace_repository</i18n:text> <a href="http://www.dspace.org">DSpace</a>-->
            </div>
        </footer>
    </xsl:template>
    
    <!-- The template to handle the dri:body element. It simply creates the 
    ds-body div and applies templates of the body's child elements (which consists 
    entirely of dri:div tags). -->
    <xsl:template match="dri:body">
        
        <div>
            <xsl:choose>
                <xsl:when test="$request-uri = ''">
                    <xsl:attribute name="id">contentHome</xsl:attribute>              
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="id">content</xsl:attribute>              
                </xsl:otherwise>
            </xsl:choose>
    
            <!--<span class="logoEducapes">Logo Educapes</span> -->
            <div id="ds-body">
                <xsl:if
                    test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                    <div id="ds-system-wide-alert">
                        <p>
                            <xsl:copy-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()" />
                        </p>
                    </div>
                </xsl:if>
	
                <!-- Check for the custom pages -->
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/rss')">
                        <div>
                            <h1>RSS</h1>
                            <p>O RSS (Really Simple Syndication) é um formato de distribuição de informações em tempo real pela internet. Por esse sistema, o internauta não precisa abrir o navegador ou fazer busca de notícias, fotos ou vídeos em diferentes sites. Todo o conteúdo desejado vai até você automaticamente por um código de RSS. Basta escolher qual conteúdo quer receber.</p>
                            <p>Há duas formas de usar RSS: diretamente de seu navegador ou por um programa de leitura.</p>
                            <p>Se você preferir acessar a partir do próprio navegador, é preciso copiar e colar o link do RSS na barra de endereço para ser redirecionado para uma tela que lhe dará as opções e instruções de como ler o código. Existem também aplicativos e complementos dos navegadores que fazem esta função.</p>
                            <p>A outra maneira é instalando um leitor de RSS (ou também conhecido RSS Reader) no seu computador. Existem inúmeros programas disponíveis para teste ou download gratuito na internet (como por exemplo o FeedReader). Faça a sua pesquisa e escolha aquele que melhor atenda a sua necessidade.</p>
                        </div>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'page/faq')">
                        <div>
                            <h1>Dúvidas Frequentes</h1>
                            <p>Em construção...</p>
                        </div>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'page/accessibility')">
                        <div>
                            <h1>Acessibilidade</h1>

                            <ul class="actions">
                            </ul>
                            <div class="description">
                                <p>Este site segue as diretrizes do e-MAG (Modelo de Acessibilidade em Governo Eletrônico), conforme as normas do Governo Federal, em obediência ao Decreto 5.296, de 2.12.2004.</p>
                            </div>

                            <p>O termo acessibilidade significa incluir a pessoa com deficiência na participação de atividades como o uso de produtos, serviços e informações. Alguns exemplos são os prédios com rampas de acesso para cadeira de rodas e banheiros adaptados para deficientes.</p>
                            <p>Na internet, acessibilidade refere-se principalmente às recomendações do WCAG (World Content Accessibility Guide) do W3C e no caso do Governo Brasileiro ao e-MAG (Modelo de Acessibilidade em Governo Eletrônico). O e-MAG está alinhado as recomendações internacionais, mas estabelece padrões de comportamento acessível para sites governamentais.</p>
                            <p>Na parte superior do portal existe uma barra de acessibilidade onde se encontra atalhos de navegação padronizados e a opção para alterar o contraste. Essas ferramentas estão disponíveis em todas as páginas do portal.</p>
                            <p>Os atalhos padrões do governo federal são:</p>
                            <ul class="lista-padrao">
                                <li>Teclando-se Alt + 1 em qualquer página do portal, chega-se diretamente ao começo do conteúdo principal da página.</li>
                                <li>Teclando-se Alt + 2 em qualquer página do portal, chega-se diretamente ao início do menu principal.</li>
                                <li>Teclando-se Alt + 3 em qualquer página do portal, chega-se diretamente em sua busca interna.</li>
                                <li>Teclando-se Alt + 4 em qualquer página do portal, chega-se diretamente ao rodapé do site.</li>
                            </ul>
                            <p>Esses atalhos valem para o navegador Chrome, mas existem algumas variações para outros navegadores.</p>
                            <p>Quem prefere utilizar o Internet Explorer é preciso apertar o botão Enter do seu teclado após uma das combinações acima. Portanto, para chegar ao campo de busca de interna é preciso pressionar Alt+3 e depois Enter.</p>
                            <p>No caso do Firefox, em vez de Alt + número, tecle simultaneamente Alt + Shift + número.</p>
                            <p>Sendo Firefox no Mac OS, em vez de Alt + Shift + número, tecle simultaneamente Ctrl + Alt + número.</p>
                            <p>No Opera, as teclas são Shift + Escape + número. Ao teclar apenas Shift + Escape, o usuário encontrará uma janela com todas as alternativas de ACCESSKEY da página.</p>
                            <p>Ao final desse texto, você poderá baixar alguns arquivos que explicam melhor o termo acessibilidade e como deve ser implementado nos sites da Internet.</p>
                            <h2>Leis e decretos sobre acessibilidade:</h2>
                            <ul class="lista-padrao">
                                <li><a title="" href="http://www.planalto.gov.br/ccivil_03/_Ato2004-2006/2004/Decreto/D5296.htm" target="_self">Decreto nº 5.296 de 02 de dezembro de 2004 </a>(link externo)</li>
                                <li><a title="" href="http://www.planalto.gov.br/ccivil_03/_ato2007-2010/2009/decreto/d6949.htm" target="_self">Decreto nº 6.949, de 25 de agosto de 2009</a> (link externo) - Promulga a Convenção Internacional sobre os Direitos das Pessoas com Deficiência e seu Protocolo Facultativo, assinados em Nova York, em 30 de março de 2007 </li>
                                <li><a title="" href="http://www.planalto.gov.br/ccivil_03/_ato2011-2014/2012/Decreto/D7724.htm" target="_self">Decreto nº 7.724, de 16 de Maio de 2012</a> (link externo) - Regulamenta a Lei No 12.527, que dispõe sobre o acesso a informações.</li>
                                <li><a title="" href="http://www.governoeletronico.gov.br/acoes-e-projetos/e-MAG" target="_self">Modelo de Acessibilidade de Governo Eletrônico</a> (link externo) </li>
                                <li><a title="" href="http://www.governoeletronico.gov.br/biblioteca/arquivos/portaria-no-03-de-07-05-2007" target="_self">Portaria nº 03, de 07 de Maio de 2007 - formato .pdf (35,5Kb)</a> (link externo) - Institucionaliza o Modelo de Acessibilidade em Governo Eletrônico – e-MAG </li>
                            </ul>
                            <h2>Dúvidas, sugestões e críticas:</h2>
                            <p>No caso de problemas com a acessibilidade do portal, favor acessar a <a>
                                <xsl:attribute name="href">
                                    <!--<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>-->
                                    <xsl:text>http://mec.cube.callsp.inf.br/auto-atendimento/navegacao-informacoes/#/0</xsl:text>
                                </xsl:attribute>Página de contato</a>.</p>
                            <h2>Dicas, links e recursos úteis: </h2>
                            <ul class="lista-padrao">
                                <li><a title="" href="http://acessibilidadelegal.com/" target="_self">Acessibilidade Legal</a> (link externo)</li>
                                <li><a title="" href="http://acessodigital.net/links.html" target="_self">Acesso Digital</a> (link externo)</li>
                            </ul>
                        </div>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'page/submission')">
                        <div>
                            <h1>Envie seu material</h1>
                            <p>Enviar materiais para o <strong>eduCapes</strong> é fácil: basta você possuir um material do qual seja o dono dos direitos autorais e cadastrar-se em nosso site.</p>
                            <p>São permitidos arquivos de áudio, imagens, textos e vídeos em qualquer tipo de formato digital.</p>
                            <p>Para enviar seu material, siga os seguintes passos:</p>
                            <ol class="lista-numerada">
                                <li>Verifique se você possuí os direitos referentes ao material;</li>
                                <li>Caso seja sua primeira vez, realize o cadastro no site clicando em "Cadastro" no menu "MINHA CONTA";</li>
                                <li>Após finalizar a cadastro, acesse o sistema utilizando seu endereço de e-mail e sua senha;</li>
                                <li>Clique no link "SUBMISSÕES"</li>
                                <li>Clique no link "Iniciar nova submissão" para iniciar o cadastro do material;</li>
                                <li>Preencha os formulários apresentados pelo sistema com os dados referentes ao material;</li>
                                <li>Na etapa de "Upload", selecione o(s) arquivo(s) digital(is) desejado(s) referente(s) ao material que está sendo compartilhado;</li>
                                <li>Verifique se os dados e arquivos cadastrados estão corretos;</li>
                                <li>Leia atentamente os termos de licença e selecione a opção "Eu concedo a licença";</li>
                                <li><strong>Pronto!</strong> Seu material foi enviado para a base do eduCapes.</li>
                            </ol>
                            <p>Após o envio, cada material fica aguardando a verificação de um moderador do repositório, desta forma,
                            o material só será publicado após a aprovação nesta fase de moderação.</p>
                        </div>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'page/about')">
                        <div>
                            <h1>O QUE É O eduCAPES?</h1>
                            <p>  Ciente da expansão do acesso à internet e às novas mídias pelos estudantes, resultado do processo de democratização da informação, cultura e, observando ainda a necessidade de publicizar, compartilhar e disseminar os materiais educacionais produzidos nos cursos ofertados no âmbito do Sistema Universidade Aberta do Brasil - 
                            UAB, a Diretoria de Educação a Distância  DED/CAPES desenvolveu um novo portal educacional online: o <strong>eduCAPES</strong>.</p>
                            <p>  O <strong>eduCAPES</strong> é um portal de objetos educacionais abertos para uso de alunos e professores da educação básica, superior e pós graduação que busquem aprimorar seus conhecimentos.</p>
                            <p>  O <strong>eduCAPES</strong> engloba em seu acervo textos formato PDF, livros didáticos, artigos de pesquisa, teses, dissertações, videoaulas e quaisquer outros materiais de pesquisa e ensino que estejam licenciados de maneira aberta ou sob domínio público.</p>
                            <p>  O portal permite a inclusão de materiais abertos que estejam mapeados em algum esquema de metadados. O sistema suporta nativamente os padrões de metadados Dublin Core. O acesso aos materiais é feito de forma híbrida: pode ser feito por meio de sincronismo, remetendo a repositórios parceiros ou pela ferramenta busca, que retorna materiais hospedados no 
                            próprio portal. A sincronia permite - por exemplo, que novos Objetos de Aprendizagem (OAs) sejam detectados nos repositórios e/ou automaticamente excluídos os que foram removidos.</p>
                            <p>  O <strong>eduCAPES</strong> conta com materiais abertos advindos do Sistema Universidade Aberta do Brasil (UAB) e de parcerias firmadas.</p>
                            <p><strong>Boa pesquisa!</strong></p>
                        </div>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'page/partners')">
                        <div>
                            <h1>Parceiros</h1>
                            <ul class="lista-padrao">
                            <li>Representação do Governo dos Estados Unidos no Brasil (<a href="http://americanenglish.state.gov/">http://americanenglish.state.gov/</a>)</li>
                            <li>Fundação Lemann (<a href="http://www.fundacaolemann.org.br/">http://www.fundacaolemann.org.br/</a>)</li>
                            <li>Instituto Nacional de Pesquisas Espaciais- INPE (<a href="http://www.inpe.br/">http://www.inpe.br/</a>)</li>
                            <li>Sociedade Brasileira de Matemática (<a href="http://www.sbm.org.br">http://www.sbm.org.br</a>)</li>
                            <li>Unesp- Universidade Estadual Paulista (<a href="http://www.unesp.br">http://www.unesp.br</a>)</li>
                            </ul>
                            <h2>Contato</h2>
                            <p>
                            <strong>Formulário de contato:</strong>
                            <a href="http://mec.cube.callsp.inf.br/auto-atendimento/navegacao-informacoes/#/0">Fale Conosco</a>
                            </p>
                            <p>
                            <strong>E-mail:</strong> educapes@capes.gov.br</p>
                        </div>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'page/search')">
                        <div>
                        <h1>COMO FAÇO A MINHA PESQUISA?</h1>
                        <p>  Fazer a busca no portal eduCAPES  é fácil. Pode ser feita tanto pelo menu BUSCAR, quanto pelo menu NAVEGAR.</p>
                        <h2>No Menu BUSCAR:</h2>
                        <p>Para realizar uma busca específica por assunto, autor, data de publicação ou título, selecione o filtro desejado na primeira caixa de seleção</p>
                        <img alt="Menu de seleção por assunto, autor, data de publicação e título">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                <xsl:text>/themes/</xsl:text>
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                <xsl:text>/images/capes/ajuda/buscar_por.png</xsl:text>
                            </xsl:attribute>
                        </img>
                        <p>Na segunda caixa de seleção, escolha a restrição de comparação (igual, contém, diferente, ID, Não contém, sem ID) e depois informe a palavra ou frase na caixa de busca.</p>
                        <p>Clique em BUSCAR para concluir a busca.</p>
                        <img alt="Área de busca">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                <xsl:text>/themes/</xsl:text>
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                <xsl:text>/images/capes/ajuda/area_busca.png</xsl:text>
                            </xsl:attribute>
                        </img>
                        <p>Caso deseje realizar uma busca mais específica, clique em ADICIONAR FILTRO.</p>
                        <h2>No Menu NAVEGAR:</h2>
                        <p>Para realizar uma busca específica, entre no MENU NAVEGAR à esquerda e escolha o modo de busca que desejar, podendo ser por:</p>
                        <ul>
                        <li>ASSUNTO</li>
                        <li>AUTOR</li>
                        <li>DATA DE PUBLICAÇÃO</li>
                        <li>TÍTULO</li>
                        </ul>
                        <img alt="Menu de navegação com as opções assunto, autor, data de publicação e título">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                <xsl:text>/themes/</xsl:text>
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                <xsl:text>/images/capes/ajuda/menu_navegar.png</xsl:text>
                            </xsl:attribute>
                        </img>
                        <p>A busca pode ser feita clicando na primeira letra da palavra que deseja buscar; digitando as três primeiras letras da palavra que deseja buscar.</p>
                        <img alt="Área de navegação">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                <xsl:text>/themes/</xsl:text>
                                <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                <xsl:text>/images/capes/ajuda/navegacao_assunto.png</xsl:text>
                            </xsl:attribute>
                        </img>
                        <p>Clique em BUSCAR para concluir a busca.</p>
                        </div>
                    </xsl:when>
                    <!-- Otherwise use default handling of body -->
                    <xsl:otherwise>
                        <xsl:if test="$request-uri != ''">
                            <xsl:apply-templates />
                        </xsl:if>
                        <xsl:if test="$request-uri = ''">
                            <div class="areaBuscaHome">
                                <div class="logoEducapesHome"><span></span></div>
                                <div class="buscaHome">
                                    <form id="ds-search-form" method="post">
                                        <xsl:attribute name="action">
                                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']" />
                                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']" />
                                        </xsl:attribute>
                                        <label for="ds-search_repository" class="labelHome">Sobre o que você quer aprender?</label>
                                        <input id="ds-search_repository" class="inputTextHome" type="text">
                                            <xsl:attribute name="name">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']" />
                                            </xsl:attribute>
                                        </input>
                                        <input class="ds-button-field" name="submit" type="submit" value="Pesquisar">
                                            <xsl:attribute name="onclick">
                                                <xsl:text>
                                                    var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                                    if (radio != undefined &amp;&amp; radio.checked)
                                                    {
                                                        var form = document.getElementById(&quot;ds-search-form&quot;);
                                                        form.action=
                                                </xsl:text>
                                                <xsl:text>&quot;</xsl:text>
                                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']" />
                                                <xsl:text>/handle/&quot; + radio.value + &quot;</xsl:text>
                                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']" />
                                                <xsl:text>&quot; ; </xsl:text>
                                                <xsl:text>
                                                    }
                                                </xsl:text>
                                            </xsl:attribute>
                                        </input>
                                    </form>
                                </div>
                            </div>
                            <div class="parceiros">
                                <h3>Bases</h3>
                                <div class="area-parceiro">
                                    <img alt="Logo UAB" data-pin-nopin="true">
                                        <xsl:attribute name="src">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                            <xsl:text>/themes/</xsl:text>
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                            <xsl:text>/images/capes/parceiros/logo_uab_parceiros.png</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                    <p>Universidade Aberta do Brasil</p>
                                </div>
                                <div class="area-parceiro">
                                    <img alt="Logo UNESP" data-pin-nopin="true">
                                        <xsl:attribute name="src">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                            <xsl:text>/themes/</xsl:text>
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                            <xsl:text>/images/capes/parceiros/unesp.jpg</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                    <p>Unesp</p>
                                </div>
                                <div class="area-parceiro">
                                    <img alt="Logo Americam English">
                                        <xsl:attribute name="src">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                            <xsl:text>/themes/</xsl:text>
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                            <xsl:text>/images/capes/parceiros/banner-americanEnglish.png</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                    <p>Americam English</p>
                                </div>
                                <div class="area-parceiro">
                                    <img alt="Banco Internacional de Objetos Educacionais">
                                        <xsl:attribute name="src">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                            <xsl:text>/themes/</xsl:text>
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                            <xsl:text>/images/capes/parceiros/bio.jpg</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                    <p>Banco Internacional de Objetos Educacionais</p>
                                </div>
                                <div class="area-parceiro">
                                    <img alt="Banco Internacional de Objetos Educacionais">
                                        <xsl:attribute name="src">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                            <xsl:text>/themes/</xsl:text>
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                            <xsl:text>/images/capes/parceiros/sbm.jpg</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                    <p>Sociedade Brasileira de Matemática</p>
                                </div>
                                <div class="area-parceiro">
                                    <img alt="Logo INPE">
                                        <xsl:attribute name="src">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                            <xsl:text>/themes/</xsl:text>
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                            <xsl:text>/images/capes/parceiros/banner-inpe.png</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                    <p>Instituto Nacional de Pesquisas Espaciais</p>
                                </div>
                                <div class="area-parceiro">
                                    <img alt="Logo Khan Academy">
                                        <xsl:attribute name="src">
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                                            <xsl:text>/themes/</xsl:text>
                                            <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                                            <xsl:text>/images/capes/parceiros/banner-khanAcademy2.png</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                    <p>Khan Academy</p>
                                </div>
                            </div>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>


    <!-- Currently the dri:meta element is not parsed directly. Instead, parts 
    of it are referenced from inside other elements (like reference). The blank 
    template below ends the execution of the meta branch -->
    <xsl:template match="dri:meta">
    </xsl:template>

    <xsl:template name="addJavascript">
        <xsl:variable name="jqueryVersion">
            <xsl:text>1.6.2</xsl:text>
        </xsl:variable>

        <xsl:variable name="protocol">
            <xsl:choose>
                <xsl:when
                    test="starts-with(confman:getProperty('dspace.baseUrl'), 'https://')">
                    <xsl:text>https://</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>http://</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <script type="text/javascript"
                src="{concat($protocol, 'ajax.googleapis.com/ajax/libs/jquery/', $jqueryVersion ,'/jquery.min.js')}">&#160;
        </script>

        <xsl:variable name="localJQuerySrc">
            <xsl:value-of
                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
            <xsl:text>/static/js/jquery-</xsl:text>
            <xsl:value-of select="$jqueryVersion" />
            <xsl:text>.min.js</xsl:text>
        </xsl:variable>

        <script type="text/javascript">
            <xsl:text disable-output-escaping="yes">!window.jQuery &amp;&amp; document.write('&lt;script type="text/javascript" src="</xsl:text>
            <xsl:value-of select="$localJQuerySrc" />
            <xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;\/script&gt;')</xsl:text>
        </script>

        <!-- Add theme javascipt -->
        <xsl:for-each
            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='url']">
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of select="." />
                </xsl:attribute>
				&#160;
            </script>
        </xsl:for-each>

        <xsl:for-each
            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="." />
                </xsl:attribute>
				&#160;
            </script>
        </xsl:for-each>

        <!-- add "shared" javascript from static, path is relative to webapp root -->
        <xsl:for-each
            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
            <!--This is a dirty way of keeping the scriptaculous stuff from choice-support 
            out of our theme without modifying the administrative and submission sitemaps. 
            This is obviously not ideal, but adding those scripts in those sitemaps is 
            far from ideal as well -->
            <xsl:choose>
                <xsl:when test="text() = 'static/js/choice-support.js'">
                    <script type="text/javascript">
                        <xsl:attribute name="src">
                            <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                            <xsl:text>/themes/</xsl:text>
                            <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                            <xsl:text>/lib/js/choice-support.js</xsl:text>
                        </xsl:attribute>
						&#160;
                    </script>
                </xsl:when>
                <xsl:when test="not(starts-with(text(), 'static/js/scriptaculous'))">
                    <script type="text/javascript">
                        <xsl:attribute name="src">
                            <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="." />
                        </xsl:attribute>
						&#160;
                    </script>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <!-- add setup JS code if this is a choices lookup page -->
        <xsl:if test="dri:body/dri:div[@n='lookup']">
            <xsl:call-template name="choiceLookupPopUpSetup" />
        </xsl:if>

        <!--PNG Fix for IE6 -->
        <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7 ]&gt;</xsl:text>
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of
                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
                <xsl:text>/themes/</xsl:text>
                <xsl:value-of
                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
                <xsl:text>/lib/js/DD_belatedPNG_0.0.8a.js?v=1</xsl:text>
            </xsl:attribute>
			&#160;
        </script>
        <script type="text/javascript">
            <xsl:text>DD_belatedPNG.fix('#ds-header-logo');DD_belatedPNG.fix('#ds-footer-logo');$.each($('img[src$=png]'), function() {DD_belatedPNG.fixPng(this);});</xsl:text>
        </script>
        <xsl:text disable-output-escaping="yes">&lt;![endif]--&gt;</xsl:text>


        <script type="text/javascript">
            runAfterJSImports.execute();
        </script>

        <!-- Add a google analytics script if the key is present -->
        <xsl:if
            test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
            <script type="text/javascript">
                <xsl:text>
                    var _gaq = _gaq || [];
                    _gaq.push(['_setAccount', '</xsl:text>
                <xsl:value-of
                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']" />
                <xsl:text>']);
                    _gaq.push(['_trackPageview']);

                    (function() {
                    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                    })();
                </xsl:text>
            </script>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
