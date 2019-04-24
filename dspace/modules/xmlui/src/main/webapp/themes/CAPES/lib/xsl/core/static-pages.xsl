<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
    
    <xsl:output indent="yes" />
    
    <!-- 
    
    <referenceSet type="commonList">
        <reference repositoryID="capes" type="commonListItem" url="http://acervodigital.unesp.br"/>
        <reference repositoryID="capes" type="commonListItem" url="http://edutec.unesp.br"/>
    </referenceSet>
    -->
    
    <xsl:template match="dri:referenceSet[@type = 'commonList']">
        <ul class="commonList">
            <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
        </ul>
    </xsl:template>
    
    <xsl:template match="dri:reference[@type = 'commonListItem']">
        <li>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
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

</xsl:stylesheet>