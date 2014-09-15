<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
		xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
		xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
		xmlns:atl="http://atelo.org/ns/db2ooxml">
  <xsl:output method="xml" indent="no" standalone="yes"/>

  <xsl:include href="mml2omml.xsl"/>

  <xsl:template match="/db:article">
    <w:document>
      <w:body>
	<!-- Frontmatter -->
        <xsl:apply-templates select="db:info"/>
	<!-- Document sections -->
        <xsl:apply-templates select="db:sect1"/>
	<!-- Backmatter -->
        <xsl:apply-templates select="db:bibliography"/>
	<!-- Section format -->
	<w:sectPr>
	  <w:type w:val="nextPage"/>
	  <w:pgSz w:w="12240" w:h="15840"/>
	  <w:pgMar w:left="1134" w:right="1134"
		   w:header="0" w:top="1134" w:footer="1134"
		   w:bottom="1698" w:gutter="0"/>
	  <w:pgNumType w:fmt="decimal"/>
	  <w:formProt w:val="false"/>
	  <w:textDirection w:val="lrTb"/>
	  <w:footerReference w:type="default" r:id="rId4"/>
	</w:sectPr>
      </w:body>
    </w:document>
  </xsl:template>

  <xsl:template match="db:info">
    <!-- Document title -->
    <w:p>
      <w:pPr><w:pStyle w:val="Title"/></w:pPr>
      <w:r><w:t><xsl:value-of select="db:title"/></w:t></w:r>
    </w:p>
    <!-- Authors -->
    <xsl:apply-templates select="db:author"/>
    <xsl:apply-templates select="db:date"/>
    <!-- Abstract -->
    <xsl:apply-templates select="db:abstract"/>
  </xsl:template>

  <xsl:template match="db:author">
    <w:p>
      <w:pPr><w:pStyle w:val="Author"/></w:pPr>
      <w:r><w:t>
        <xsl:value-of select="db:personname/db:firstname"/>
	<xsl:text> </xsl:text>
        <xsl:value-of select="db:personname/db:surname"/>
      </w:t></w:r>
    </w:p>
  </xsl:template>

  <xsl:template match="db:date">
    <w:p>
      <w:pPr><w:pStyle w:val="Date"/></w:pPr>
      <w:r><w:t><xsl:value-of select="."/></w:t></w:r>
    </w:p>
  </xsl:template>

  <xsl:template match="db:abstract">
    <w:p>
      <w:pPr><w:pStyle w:val="AbstractHeading"/></w:pPr>
      <w:r><w:t>Abstract</w:t></w:r>
    </w:p>
    <xsl:for-each select="db:para">
      <w:p>
	<w:pPr><w:pStyle w:val="AbstractBody"/></w:pPr>
	<xsl:apply-templates/>
      </w:p>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="db:sect1">
    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <xsl:if test="db:title/@xml:id">
	<w:bookmarkStart w:id="{db:title/@xml:id}"
			 w:name="{db:title/@xml:id}"/>
      </xsl:if>
      <w:r><w:t>
	<!-- TODO: we should use numbering properties instead of that -->
        <xsl:number level="multiple" count="db:sect1"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="db:title"/>
      </w:t></w:r>
      <xsl:if test="db:title/@xml:id">
	<w:bookmarkEnd w:id="{db:title/@xml:id}"
		       w:name="{db:title/@xml:id}"/>
      </xsl:if>
    </w:p>
    <xsl:apply-templates select="db:sect2|db:para"/>
  </xsl:template>

  <xsl:template match="db:sect2">
    <w:p>
      <w:pPr><w:pStyle w:val="Heading2"/></w:pPr>
      <xsl:if test="db:title/@xml:id">
	<w:bookmarkStart w:id="{db:title/@xml:id}"
			 w:name="{db:title/@xml:id}"/>
      </xsl:if>
      <w:r><w:t>
	<!-- TODO: we should use numbering properties instead of that -->
        <xsl:number level="multiple" count="db:sect1"/>
	<xsl:text>.</xsl:text>
        <xsl:number level="multiple" count="db:sect2"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="db:title"/>
      </w:t></w:r>
      <xsl:if test="db:title/@xml:id">
	<w:bookmarkEnd w:id="{db:title/@xml:id}"
		       w:name="{db:title/@xml:id}"/>
      </xsl:if>
    </w:p>
    <xsl:apply-templates select="db:para"/>
  </xsl:template>

  <xsl:template match="db:bibliography">
    <w:p>
      <w:pPr><w:pStyle w:val="BibliographyHeading"/></w:pPr>
      <w:r><w:t><xsl:value-of select="db:title"/></w:t></w:r>
    </w:p>
    <xsl:apply-templates select="db:bibliomixed"/>
  </xsl:template>

  <xsl:template match="db:para">
    <w:p>
      <w:pPr><w:pStyle w:val="TextBody"/></w:pPr>
      <xsl:apply-templates/>
    </w:p>
  </xsl:template>

  <xsl:template match="db:bibliomixed">
    <w:p>
      <w:pPr><w:pStyle w:val="BibliographyBody"/></w:pPr>
      <xsl:if test="@xml:id">
	<w:bookmarkStart w:id="{@xml:id}" w:name="{@xml:id}"/>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="@xml:id">
	<w:bookmarkEnd w:id="{@xml:id}" w:name="{@xml:id}"/>
      </xsl:if>
    </w:p>
  </xsl:template>

  <xsl:template match="db:emphasis">
    <w:r>
      <w:rPr>
	<w:i />
      </w:rPr>
      <w:t><xsl:value-of select="normalize-space()"/></w:t>
    </w:r>
  </xsl:template>

  <xsl:template match="db:bibliomixed/text()">
    <w:r><w:t><xsl:value-of select="."/></w:t></w:r>
  </xsl:template>

  <xsl:template match="text()">
    <w:r><w:t>
      <xsl:variable name="txt" select="atl:single-spaces(.)"/>
      <xsl:if test="atl:starts-with($txt,' ') or atl:ends-with($txt,' ')">
	<xsl:attribute name="xml:space">preserve</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$txt"/>
    </w:t></w:r>
  </xsl:template>

  <xsl:template match="db:citation">
    <w:r><w:t> </w:t></w:r>
    <xsl:apply-templates/>
    <w:r><w:t> </w:t></w:r>
  </xsl:template>

  <xsl:template match="db:link">
    <w:hyperlink w:anchor="{@linkend}">
      <xsl:apply-templates/>
    </w:hyperlink>
  </xsl:template>

  <xsl:template match="db:inlineequation">
    <m:oMath>
      <xsl:apply-templates mode="mml"/>
    </m:oMath>
  </xsl:template>

  <xsl:template match="db:equation">
    <w:p>
      <w:pPr><w:pStyle w:val="Equation"/></w:pPr>
      <m:oMath>
	<xsl:apply-templates mode="mml"/>
      </m:oMath>
      <w:r>
	<w:t>(<xsl:number level="multiple" count="db:equation"/>)</w:t>
      </w:r>
    </w:p>
  </xsl:template>

</xsl:stylesheet>
