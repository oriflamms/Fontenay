<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="xml"/>
    <xsl:variable name="documents" select="collection('zones?select=*.xml;recurse=yes')"/>
<!--    <xsl:variable name="edition" select="document('./texts/Fontenay-w.xml')"/>-->
    
    <xsl:template match="/">
        <xsl:variable name="Tk-coord" select="."/>
        <xsl:for-each select="$documents">
            <xsl:variable name="document" select="."/>
            <xsl:variable name="filename">
                <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="result-filename" select="concat('zones-fix/', $filename, '.xml')"/>
            <xsl:result-document href="{$result-filename}">
                <xsl:apply-templates select="$document/TEI">
                    <xsl:with-param select="$Tk-coord" name="Tk-coord"/>
                    <xsl:with-param select="$filename" name="filename"/>
                </xsl:apply-templates>
            </xsl:result-document>
            
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="@* | node()" mode="#all">
        <xsl:param name="Tk-coord"/>
        <xsl:param name="filename"/>
        <xsl:choose>
            <xsl:when test="matches(name(.), '^(part|instant|anchored|default|full|status)$')"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()" mode="#current">
                        <xsl:with-param name="Tk-coord" select="$Tk-coord"></xsl:with-param>
                        <xsl:with-param name="filename" select="$filename"></xsl:with-param>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="revisionDesc">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:element name="change" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="when" select="current-date()"/>
                <xsl:text>Import coordinates from manually corrected Transkribus segmentation</xsl:text>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

   <xsl:template match="zone[@type='line']">
       <xsl:param name="Tk-coord"/>
       <xsl:param name="filename"/>
       <xsl:variable name="imagefile" select="substring-after(substring-before($filename, '-zones'), 'Fontenay_surf_Fontenay-w_')"></xsl:variable>
       <xsl:variable name="numligne" select="count(preceding-sibling::zone[@type='line']) + 1"/>
       <xsl:variable name="matching-column" select="$Tk-coord//TEI/facsimile/surface[graphic/@url=concat($imagefile, '.tif')]/zone[@rendition='TextRegion']"/>
       <xsl:variable name="matching-line" select="$matching-column/zone[@rendition='Line'][position() = $numligne]"/>
       
       
       <xsl:variable name="x">
           <xsl:analyze-string select="$matching-line/@points" regex="\s?([0-9]+),">
               <xsl:matching-substring>
                   <ab xmlns="http://www.tei-c.org/ns/1.0" ><xsl:value-of select="regex-group(1)"/></ab>
               </xsl:matching-substring>
           </xsl:analyze-string>
       </xsl:variable>
       <xsl:variable name="y">
           <xsl:analyze-string select="$matching-line/@points" regex=",([0-9]+)\s?">
               <xsl:matching-substring>
                   <ab xmlns="http://www.tei-c.org/ns/1.0" ><xsl:value-of select="regex-group(1)"/></ab>
               </xsl:matching-substring>
           </xsl:analyze-string>
       </xsl:variable>
       
       
       <zone xmlns="http://www.tei-c.org/ns/1.0" type="line">
           <xsl:attribute name="xml:id" select="@xml:id"/>
           <xsl:attribute name="points" select="$matching-line/@points"/>
           <xsl:attribute name="ulx" select="min($x//ab)"></xsl:attribute>
           <xsl:attribute name="uly" select="min($y//ab)"></xsl:attribute>
           <xsl:attribute name="lrx" select="max($x//ab)"></xsl:attribute>
           <xsl:attribute name="lry" select="max($y//ab)"></xsl:attribute>
           
       <xsl:apply-templates/>
           
       </zone>
   </xsl:template>
   
   
    
</xsl:stylesheet>
