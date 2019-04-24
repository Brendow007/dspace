<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        
        <xsl:copy-of select="$SFXLink" />
        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                    <xsl:with-param name="context" select="."/>
                    <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
            </xsl:when>
            <xsl:otherwise>
                <p class="warning">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text>
                </p>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>
        
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemSummaryView-DIM"/>
    </xsl:template>
    
    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
	
        <xsl:variable name="swfPath">
            <xsl:value-of
                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
            <xsl:text>/themes/</xsl:text>
            <xsl:value-of
                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
            <xsl:text>/lib/videojs/video-js.swf</xsl:text>
            <!-- <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/> -->
            <!-- <xsl:text>/lib/videojs/video-js.swf</xsl:text> -->
        </xsl:variable>
                
        <script>
            videojs.options.flash.swf = "<xsl:copy-of select="$swfPath" />";
        </script>
        
        <div class="outstanding-header-lvl3">
            <h2><i18n:text>xmlui.ArtifactBrowser.ItemViewer.head_metadata</i18n:text></h2>
        </div>

        <table class="ds-includeSet-table">
            <tr class="ds-table-row">
                <td>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>:
                    </span>
                </td>
                <td>
                    <h1 class="titleValue">
                        <xsl:choose>
                            <xsl:when test="descendant::text() and (count(dim:field[@element='title'][not(@qualifier)]) &gt; 1)">
                                <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='title'][descendant::text()] and count(dim:field[@element='title'][not(@qualifier)]) = 1">
                                <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </h1>
                </td> 
            </tr>
            <tr class="ds-table-row">
                <td>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text>:
                    </span>
                </td>
                <td>
                    <xsl:choose>
                        <xsl:when test="dim:field[@mdschema='dc' and @element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@mdschema='dc' and @element='contributor'][@qualifier='author']">
                                <span>
                                    <xsl:if test="@authority">
                                        <xsl:attribute name="class">
                                            <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@mdschema='dc' and @element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@mdschema='dc' and @element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@mdschema='dc' and @element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@mdschema='dc' and @element='contributor']">
                            <xsl:for-each select="dim:field[@mdschema='dc' and @element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@mdschema='dc' and @element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td> 
            </tr>
            <xsl:if test="string(normalize-space(dim:field[@element='date' and @qualifier='issued']/child::node()))">
                <tr class="ds-table-row">
                    <td>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date-issued</i18n:text>:
                        </span>
                    </td>
                    <td>
                        <xsl:copy-of select="dim:field[@element='date' and @qualifier='issued']/child::node()"/>
                    </td> 
                </tr>
            </xsl:if>
            <xsl:if test="string(normalize-space(dim:field[@element='identifier' and @qualifier='other']/child::node()))">
                <tr class="ds-table-row">
                    <td>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-identifier-other</i18n:text>:
                        </span>
                    </td>
                    <td>
                        <xsl:copy-of select="dim:field[@element='identifier' and @qualifier='other']/child::node()"/>
                    </td> 
                </tr>
            </xsl:if>
            <xsl:if test="string(normalize-space(dim:field[@element='format' and @qualifier='extent']/child::node()))">
                <tr class="ds-table-row">
                    <td>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-format-extent</i18n:text>:
                        </span>
                    </td>
                    <td>
                        <xsl:copy-of select="dim:field[@element='format' and @qualifier='extent']/child::node()"/>
                    </td> 
                </tr>
            </xsl:if>
            <xsl:if test="string(normalize-space(dim:field[@element='format' and @qualifier='mimetype']/child::node()))">
                <tr class="ds-table-row">
                    <td>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-format-mimetype</i18n:text>:
                        </span>
                    </td>
                    <td>
                        <!-- <xsl:copy-of select="dim:field[@element='format' and @qualifier='mimetype']/child::node()"/> -->
                        <xsl:for-each select="dim:field[@mdschema='dc' and @element='format' and @qualifier='mimetype']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@mdschema='dc' and @element='format' and @qualifier='mimetype']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td> 
                </tr>
            </xsl:if>
            <xsl:if test="string(normalize-space(dim:field[@element='source' and not(@qualifier)]/child::node()))">
                <tr class="ds-table-row">
                    <td>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-source</i18n:text>:
                        </span>
                    </td>
                    <td>
                        <xsl:copy-of select="dim:field[@element='source' and not(@qualifier)]/child::node()"/>
                    </td> 
                </tr>
            </xsl:if>
            <xsl:if test="string(normalize-space(dim:field[@element='type' and not(@qualifier)]/child::node()))">
                <tr class="ds-table-row">
                    <td>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-type</i18n:text>:
                        </span>
                    </td>
                    <td>
                        <!--<xsl:copy-of select="dim:field[@element='type' and not(@qualifier)]/child::node()"/>-->
                        <xsl:for-each select="dim:field[@mdschema='dc' and @element='type']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@mdschema='dc' and @element='type']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td> 
                </tr>
            </xsl:if>
            <xsl:if test="string(normalize-space(dim:field[@element='identifier' and not(@qualifier)]/child::node()))">
                <tr class="ds-table-row">
                    <td>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-identifier</i18n:text>:
                        </span>
                    </td>
                    <td>
                        <xsl:for-each select="dim:field[@mdschema='dc' and @element='identifier' and not(@qualifier)]">
                            <a target="_blank">
                                <xsl:attribute name="href">
                                    <xsl:copy-of select="./node()"/>
                                </xsl:attribute>
                                <xsl:copy-of select="./node()"/>
                            </a>
                            <xsl:if test="count(following-sibling::dim:field[@mdschema='dc' and @element='identifier' and not(@qualifier)]) != 0">&#59;
                            </xsl:if>
                        </xsl:for-each>
                    </td> 
                </tr>
            </xsl:if>
        </table>
        <p class="ds-paragraph item-view-toggle item-view-toggle-bottom">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$ds_item_view_toggle_url"/>
                </xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </p>
        <xsl:apply-templates select="mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>
    </xsl:template>
	
    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <table class="ds-includeSet-table detailtable">
            <xsl:apply-templates mode="itemDetailView-DIM"/>
        </table>
        <span class="Z3988">
            <xsl:attribute name="title">
                <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td class="label-cell">
                <xsl:value-of select="./@mdschema"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="./@element"/>
                <xsl:if test="./@qualifier">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@qualifier"/>
                </xsl:if>
            </td>
            <td>
                <xsl:copy-of select="./node()"/>
                <xsl:if test="./@authority and ./@confidence">
                    <xsl:call-template name="authorityConfidenceIcon">
                        <xsl:with-param name="confidence" select="./@confidence"/>
                    </xsl:call-template>
                </xsl:if>
            </td>
            <td>
                <xsl:value-of select="./@language"/>
            </td>
        </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

    <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        
        <!--<div class="outstanding-header-lvl3">
            <h2>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
            </h2>
        </div>-->
        
        <div class="file-list">
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                        <!--Do not sort any more bitstream order can be changed-->
                        <!--<xsl:sort data-type="number" select="boolean(./@ID=$primaryBitstream)" order="descending" />-->
                        <!--<xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
            
        <div class="file-wrapper clearfix">
            
            <xsl:if test="@MIMETYPE='video/mp4'">
                <div class="video-item">
                    <h3 class="video-item-title"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>: <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/></h3>
                    <br/>
                    <div class="video-player" align="center">
                        <video class="video-js vjs-default-skin" controls="controls" preload="none" width="470" height="320" data-setup="">
                            <source type="video/mp4" >
                                <xsl:attribute name="src">
                                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </source>    
                        </video>
                    </div>
                </div>
            </xsl:if>
            
            <div class="thumbnail-wrapper" style="width: {$thumbnail.maxwidth}px;">
                <a class="image-link">
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <img alt='Ícone do arquivo' src="{concat($theme-path, '/images/mime.png')}" style="height: {$thumbnail.maxheight}px;" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <img>
                            <xsl:attribute name="src">
                                <xsl:value-of select="$context-path"/>
                                <xsl:text>/static/icons/lock24.png</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="alt">xmlui.dri2xhtml.METS-1.0.blocked</xsl:attribute>
                            <xsl:attribute name="attr" namespace="http://apache.org/cocoon/i18n/2.1">alt</xsl:attribute>
                        </img>
                    </xsl:if>
                </a>
            </div>
            
            <!--<xsl:choose>
                <xsl:when test="@MIMETYPE='video/mp4'">
                    <div class="video-item">
                        <p><span><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>:</span> <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/></p>
                        <br/>
                        <div class="video-player" align="center">
                            <video class="video-js vjs-default-skin" controls="controls" preload="none" width="470" height="320" data-setup="">
                                <source type="video/mp4" >
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </source>    
                            </video>
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="thumbnail-wrapper" style="width: {$thumbnail.maxwidth}px;">
                        <a class="image-link">
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                mets:file[@GROUPID=current()/@GROUPID]">
                                    <img alt="Thumbnail">
                                        <xsl:attribute name="src">
                                            <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                            mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                        </xsl:attribute>
                                    </img>
                                </xsl:when>
                                <xsl:otherwise>
                                    <img alt='Ícone do arquivo' src="{concat($theme-path, '/images/mime.png')}" style="height: {$thumbnail.maxheight}px;" />
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                                <img>
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context-path"/>
                                        <xsl:text>/static/icons/lock24.png</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="alt">xmlui.dri2xhtml.METS-1.0.blocked</xsl:attribute>
                                    <xsl:attribute name="attr" namespace="http://apache.org/cocoon/i18n/2.1">alt</xsl:attribute>
                                </img>
                            </xsl:if>
                        </a>
                    </div>
                </xsl:otherwise>
            </xsl:choose> -->
            
            <div class="file-metadata" style="height: {$thumbnail.maxheight}px;">
                <div>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </span>
                    <span>
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 17, 5)"/>
                    </span>
                </div>
                <!-- File size always comes in bytes and thus needs conversion -->
                <div>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </span>
                    <span>
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </div>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
                In the original DSpace, this would get resolved to an application via
                the Bitstream Registry, but we are constrained by the capabilities of METS
                and can't really pass that info through. -->
                <div>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </span>
                    <span>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </span>
                </div>
                <!---->
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                    <div>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </span>
                        <span>
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <!--<xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>-->
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 17, 5)"/>
                        </span>
                    </div>
                </xsl:if>
            </div>
            <div class="file-link" style="height: {$thumbnail.maxheight}px;">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:choose>
                <xsl:when test="not ($rights_context)">
                    <xsl:text>administrators only</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$rights_declaration/*">
                        <xsl:value-of select="rights:UserName"/>
                        <xsl:choose>
                            <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                                <xsl:text> (group)</xsl:text>
                            </xsl:when>
                            <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                                <xsl:text> (individual)</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:if test="position() != last()">, </xsl:if> <!-- TODO fix ending comma -->
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="alt-text">
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-access-rights</i18n:text> 
            <xsl:value-of select="$users"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="(not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')) or not ($rights_context)">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}">
                        <xsl:attribute name="title">
                            <xsl:value-of select="$alt-text"/>
                        </xsl:attribute>
                        <xsl:attribute name="alt">
                            <xsl:value-of select="$alt-text"/>
                        </xsl:attribute>
                    </img>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
