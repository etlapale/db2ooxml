<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:atl="http://atelo.org/ns/db2ooxml">
  <xsl:output method="xml" indent="no" standalone="yes"/>

  <xsl:template match="/ | @* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="db:equation">
    <xsl:copy>
      <xsl:attribute name="atl:numbered">
        <xsl:number level="any" count="db:equation"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="db:figure">
    <xsl:copy>
      <xsl:attribute name="atl:numbered">
        <xsl:number level="any" count="db:figure"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="db:table">
    <xsl:copy>
      <xsl:attribute name="atl:numbered">
        <xsl:number level="any" count="db:table"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
