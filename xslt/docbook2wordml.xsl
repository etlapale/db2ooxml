<?xml version="1.0" encoding="utf-8"?>
<!--
 Copyright © 2014  Émilien Tlapale
 Licensed under the Simplified BSD License.
-->
<xsl:stylesheet
    version="1.0"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
    xmlns:atl="http://atelo.org/ns/db2ooxml"
    xmlns:mml="http://www.w3.org/1998/Math/MathML">
  <xsl:output method="xml" indent="no" standalone="yes"/>

  <xsl:param name="paper.type" select="'letter'"/>
  <xsl:param name="page.width">
    <xsl:choose>
      <xsl:when test="atl:ends-with($paper.type,'letter')">9.5in</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a0'">84.1cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a1'">59.4cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a2'">42cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a3'">29.7cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a5'">14.8cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a6'">10.5cm</xsl:when>
      <xsl:otherwise>21cm</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="page.height">
    <xsl:choose>
      <xsl:when test="atl:ends-with($paper.type,'letter')">11in</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a0'">118.9cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a1'">84.1cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a2'">59.4cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a3'">42cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a5'">21cm</xsl:when>
      <xsl:when test="atl:lower-case($paper.type)='a6'">14.8cm</xsl:when>
      <xsl:otherwise>29.7cm</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="page.margin.inner">1in</xsl:param>

  <!-- Internal state parameters -->
  <xsl:param name="revision-deleted" select="false"/>

  <!-- Convert a physical dimension to twips (1/1440 inches). -->
  <xsl:template name="to-twip">
    <xsl:param name="size"/>
    <xsl:variable name="len" select="string-length($size)"/>
    <xsl:choose>
      <xsl:when test="atl:ends-with($size,'in')">
	<xsl:value-of select="1440*substring($size,1,$len - 2)"/>
      </xsl:when>
      <xsl:when test="atl:ends-with($size,'pt')">
	<xsl:value-of select="20*substring($size,1,$len - 2)"/>
      </xsl:when>
      <xsl:when test="atl:ends-with($size,'cm')">
	<xsl:value-of select="567*substring($size,1,$len - 2)"/>
      </xsl:when>
      <xsl:when test="atl:ends-with($size,'mm')">
	<xsl:value-of select="56.7*substring($size,1,$len - 2)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$size"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="to-emu">
    <xsl:param name="size"/>
    <xsl:variable name="emu">
      <xsl:call-template name="to-twip">
	<xsl:with-param name="size" select="$size"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$emu * 635"/>
  </xsl:template>

  <!-- MathML to Office MML converter -->
  <xsl:include href="mml2omml.xsl"/>

  <xsl:template match="/db:article">
    <!-- Compute page dimensions -->
    <xsl:variable name="page-width">
      <xsl:call-template name="to-twip">
	<xsl:with-param name="size" select="$page.width"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="page-height">
      <xsl:call-template name="to-twip">
	<xsl:with-param name="size" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="inner-margin">
      <xsl:call-template name="to-twip">
	<xsl:with-param name="size" select="$page.margin.inner"/>
      </xsl:call-template>
    </xsl:variable>

    <w:document>
      <w:body>
	<!-- Frontmatter -->
        <xsl:apply-templates select="db:info"/>
	<!-- Content -->
        <xsl:apply-templates select="db:section|db:sect1|db:bibliography"/>
	<!-- Section format -->
	<w:sectPr>
	  <w:type w:val="nextPage"/>
	  <w:pgSz w:w="{$page-width}" w:h="{$page-height}"/>
	  <w:pgMar w:left="{$inner-margin}" w:right="{$inner-margin}"
		   w:header="0" w:top="1134" w:footer="1134"
		   w:bottom="1698" w:gutter="0"/>
	  <w:pgNumType w:fmt="decimal"/>
	  <w:formProt w:val="false"/>
	  <w:textDirection w:val="lrTb"/>
	  <w:footerReference w:type="default" r:id="rFooter"/>
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
	<xsl:for-each select="db:personname//text()">
	  <xsl:value-of select="."/>
	</xsl:for-each>
        <!-- <xsl:value-of select="db:personname/db:firstname"/>
	<xsl:text> </xsl:text>
        <xsl:value-of select="db:personname/db:surname"/> -->
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

  <!-- Begin a bookmark for an id-ed element -->
  <xsl:template name="start-bookmark">
    <xsl:if test="@xml:id">
      <w:bookmarkStart w:id="{@xml:id}" w:name="{@xml:id}"/>
    </xsl:if>
  </xsl:template>

  <!-- Finish a bookmark for an id-ed element -->
  <xsl:template name="end-bookmark">
    <xsl:if test="@xml:id">
      <w:bookmarkEnd w:id="{@xml:id}" w:name="{@xml:id}"/>
    </xsl:if>
  </xsl:template>

  <!-- Higher level section -->
  <xsl:template match="db:sect1|db:section[count(ancestor::db:section)=0]">
    <!-- Heading -->
    <w:p>
      <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
      <xsl:call-template name="start-bookmark"/>
      <w:r><w:t>
        <xsl:number level="multiple"
		    count="db:sect1|db:section[count(ancestor::db:section)=0]"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="db:title"/>
      </w:t></w:r>
      <xsl:call-template name="end-bookmark"/>
    </w:p>
    <!-- Content -->
    <xsl:apply-templates select="db:equation|db:figure|db:para|db:section|db:sect2|db:table"/>
  </xsl:template>

  <xsl:template match="db:sect2|db:section[count(ancestor::db:section)=1]">
    <!-- Heading -->
    <w:p>
      <w:pPr><w:pStyle w:val="Heading2"/></w:pPr>
      <xsl:call-template name="start-bookmark"/>
      <w:r><w:t>
        <xsl:number level="multiple"
		    count="db:sect1|db:section[count(ancestor::db:section)=0]"/>
	<xsl:text>.</xsl:text>
        <xsl:number level="multiple"
		    count="db:sect2|db:section[count(ancestor::db:section)=1]"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="db:title"/>
      </w:t></w:r>
      <xsl:call-template name="end-bookmark"/>
    </w:p>
    <!-- Content -->
    <xsl:apply-templates select="db:equation|db:figure|db:para|db:table"/>
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
    <xsl:param name="revision"/>
    <xsl:param name="revisionflag"/>
    <xsl:apply-templates>
      <xsl:with-param name="revision" select="$revision"/>
      <xsl:with-param name="revisionflag" select="$revisionflag"/>
      <xsl:with-param name="font-style" select="'italic'"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="db:bibliomixed/text()">
    <w:r><w:t><xsl:value-of select="."/></w:t></w:r>
  </xsl:template>

  <xsl:template name="base-text">
    <xsl:variable name="txt">
      <xsl:choose>
	<!-- Remove leading spaces on first child -->
	<xsl:when test="position()=1">
	  <xsl:choose>
	    <!-- and trailing spaces if also last child -->
	    <xsl:when test="position()=last()">
	      <xsl:value-of select="atl:strip(atl:single-spaces(.))"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="atl:lstrip(atl:single-spaces(.))"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<!-- Remove trailing spaces on last child -->
	<xsl:when test="position()=last()">
	  <xsl:value-of select="atl:rstrip(atl:single-spaces(.))"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="atl:single-spaces(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Preserve leading and trailing spaces -->
    <xsl:if test="atl:starts-with($txt,' ') or atl:ends-with($txt,' ')">
      <xsl:attribute name="xml:space">preserve</xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$txt"/>
  </xsl:template>

  <xsl:template name="revised-text">
    <xsl:param name="font-style"/>
    <xsl:param name="revtag"/>
    <xsl:param name="revttag"/>
    <xsl:param name="revision"/>

    <xsl:element name="{$revtag}">
      <xsl:if test="$revision/db:date">
	<xsl:attribute name="w:date">
	  <xsl:value-of select="atl:format-date($revision/db:date/text())"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="$revision/db:authorinitials">
	<xsl:attribute name="w:author">
	  <xsl:value-of select="$revision/db:authorinitials"/>
	</xsl:attribute>
      </xsl:if>
      <w:r>
	<xsl:if test="$font-style = 'italic'"><w:rPr><w:i/></w:rPr></xsl:if>
	<xsl:element name="{$revttag}">
	  <xsl:call-template name="base-text"/>
	</xsl:element>
      </w:r>
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:param name="font-style"/>
    <xsl:param name="revision"/>
    <xsl:param name="revisionflag"/>
    <xsl:choose>
      <xsl:when test="$revisionflag='added'">
	<xsl:call-template name="revised-text">
	  <xsl:with-param name="revision" select="$revision"/>
	  <xsl:with-param name="revtag" select="'w:ins'"/>
	  <xsl:with-param name="revttag" select="'w:t'"/>
	  <xsl:with-param name="font-style" select="$font-style"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$revisionflag='deleted'">
	<xsl:call-template name="revised-text">
	  <xsl:with-param name="revision" select="$revision"/>
	  <xsl:with-param name="revtag" select="'w:del'"/>
	  <xsl:with-param name="revttag" select="'w:delText'"/>
	  <xsl:with-param name="font-style" select="$font-style"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<w:r>
	  <xsl:if test="$font-style = 'italic'"><w:rPr><w:i/></w:rPr></xsl:if>
	  <w:t>
	    <xsl:call-template name="base-text"/>
	  </w:t>
	</w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="revision-tag">
    <xsl:param name="font-style"/>
    <!-- Search for matching revision in ancestor revhistory -->
    <xsl:variable name="revision"
		  select="ancestor::*/db:info/db:revhistory/db:revision[db:revnumber/text()=current()/@revision]"/>
    <!-- Change content -->
    <xsl:choose>
      <xsl:when test="@revisionflag='added'">
	<xsl:apply-templates>
	  <xsl:with-param name="revision" select="$revision"/>
	  <xsl:with-param name="revisionflag" select="@revisionflag"/>
	  <xsl:with-param name="font-style" select="$font-style"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@revisionflag='deleted'">
	<xsl:apply-templates>
	  <xsl:with-param name="revision" select="$revision"/>
	  <xsl:with-param name="revisionflag" select="@revisionflag"/>
	  <xsl:with-param name="font-style" select="$font-style"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Optional paragraph division. -->
  <xsl:template match="db:phrase">
    <xsl:param name="font-style"/>
    <xsl:choose>
      <!-- Added phrase -->
      <xsl:when test="@revisionflag='added'">
	<xsl:call-template name="revision-tag">
	  <xsl:with-param name="font-style" select="$font-style"/>
	</xsl:call-template>
      </xsl:when>
      <!-- Deleted phrase -->
      <xsl:when test="@revisionflag='deleted'">
	<xsl:call-template name="revision-tag">
	  <xsl:with-param name="font-style" select="$font-style"/>
	</xsl:call-template>
      </xsl:when>
      <!-- Unhandled phrase revisionflag -->
      <xsl:otherwise>
	<xsl:apply-templates>
	  <xsl:with-param name="font-style" select="$font-style"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="db:citation">
    <xsl:param name="revision"/>
    <xsl:param name="revisionflag"/>
    <w:r><w:t> </w:t></w:r>
    <xsl:apply-templates>
      <xsl:with-param name="revision" select="$revision"/>
      <xsl:with-param name="revisionflag" select="$revisionflag"/>
    </xsl:apply-templates>
    <w:r><w:t> </w:t></w:r>
  </xsl:template>

  <xsl:template match="db:link">
    <xsl:param name="revision"/>
    <xsl:param name="revisionflag"/>
    <w:hyperlink w:anchor="{@linkend}">
      <xsl:apply-templates>
	<xsl:with-param name="revision" select="$revision"/>
	<xsl:with-param name="revisionflag" select="$revisionflag"/>
      </xsl:apply-templates>
    </w:hyperlink>
  </xsl:template>

  <xsl:template name="number-of">
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="name($element)='sect2'">
	<xsl:call-template name="number-of">
	  <xsl:with-param name="element" select="$element/.."/>
	</xsl:call-template>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="1+count($element/preceding-sibling::*[name()=name($element)])"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of
	    select="1+count($element/preceding::*[name()=name($element)])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="db:xref">
    <xsl:param name="revision"/>
    <xsl:param name="revisionflag"/>
    <xsl:variable name="target"
		  select="//*[@xml:id=current()/@linkend]"/>
    <xsl:variable name="number">
      <xsl:choose>
	<xsl:when test="name($target)='sect1' or
			name($target)='sect2'">
	  <xsl:call-template name="number-of">
	    <xsl:with-param name="element" select="$target"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="1+count($target/preceding::*[name()=name($target)])"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <w:hyperlink w:anchor="{@linkend}">
      <w:r>
	<xsl:choose>
	  <xsl:when test="name($target) = 'equation'">
            <w:t>(<xsl:value-of select="$number"/>)</w:t>
	  </xsl:when>
	  <xsl:when test="name($target)='sect1' or name($target)='sect2'">
            <w:t>Section <xsl:value-of select="$number"/></w:t>
	  </xsl:when>
	  <xsl:otherwise>
            <w:t>
	      <xsl:value-of
		  select="atl:upper-case(substring(name($target),1,1))"/>
	      <xsl:value-of
		  select="substring(name($target),2)"/>
	      <xsl:text> </xsl:text>
	      <xsl:value-of select="$number"/>
	    </w:t>
	  </xsl:otherwise>
	</xsl:choose>
      </w:r>
    </w:hyperlink>
  </xsl:template>

  <xsl:template name="equation-content">
    <xsl:choose>
      <xsl:when test="mml:math">
	<m:oMath>
	  <xsl:apply-templates mode="mml"/>
	</m:oMath>
      </xsl:when>
      <xsl:when test="db:mathphrase[@role='latex']">
	<m:oMath>
	  <xsl:apply-templates
	      mode="mml"
	      select="atl:latex2mml(db:mathphrase[@role='latex']/text())"/>
	</m:oMath>
      </xsl:when>
      <xsl:when test="db:mathphrase">
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <w:r><w:rPr><w:b/></w:rPr><w:t>unknown inline equation</w:t></w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="db:inlineequation">
    <xsl:call-template name="equation-content"/>
  </xsl:template>

  <xsl:template match="db:equation">
    <w:p>
      <w:pPr><w:pStyle w:val="Equation"/></w:pPr>
      <xsl:call-template name="equation-content"/>
      <xsl:call-template name="start-bookmark"/>
      <w:r>
	<w:t>(<xsl:number level="any" count="db:equation"/>)</w:t>
      </w:r>
      <xsl:call-template name="end-bookmark"/>
    </w:p>
  </xsl:template>

  <xsl:template match="db:table">
    <w:tbl>
      <w:tblPr>
	<w:tblW w:w="9972" w:type="dxa"/>
      </w:tblPr>
      <xsl:apply-templates select="db:tgroup"/>
    </w:tbl>
    <w:p>
      <w:pPr><w:pStyle w:val="TableCaption"/></w:pPr>
      <w:r>
	<w:rPr><w:b/></w:rPr>
	<w:t xml:space="preserve">
	  <xsl:text>Table </xsl:text>
	  <xsl:number level="multiple" count="db:table"/>
	  <xsl:text> </xsl:text>
	</w:t>
      </w:r>
      <xsl:apply-templates select="db:title"/>
    </w:p>
  </xsl:template>

  <xsl:template match="db:tgroup">
    <xsl:apply-templates select="db:thead|db:tbody"/>
  </xsl:template>

  <xsl:template match="db:thead|db:tbody">
    <xsl:apply-templates select="db:row"/>
  </xsl:template>

  <xsl:template match="db:row">
    <w:tr>
      <xsl:apply-templates select="db:entry"/>
    </w:tr>
  </xsl:template>

  <xsl:template match="db:entry">
    <w:tc><w:p>
      <w:pPr>
	<xsl:choose>
	  <xsl:when test="ancestor::db:thead">
	    <w:pStyle w:val="TableHead"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <w:pStyle w:val="TableCell"/>
	  </xsl:otherwise>
	</xsl:choose>
      </w:pPr>
      <xsl:apply-templates/>
    </w:p></w:tc>
  </xsl:template>

  <xsl:template match="db:figure">
    <xsl:variable name="imgdat" select="db:mediaobject/db:imageobject/db:imagedata[atl:ends-with(@fileref,'.png')]"/>
    <xsl:variable name="wemu">
      <xsl:choose>
	<xsl:when test="$imgdat/@width">
	  <xsl:call-template name="to-emu">
	    <xsl:with-param name="size" select="$imgdat/@width"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="to-emu">
	    <xsl:with-param name="size" select="$page.width"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <w:p>
      <w:pPr>
	<w:jc w:val="center"/>
      </w:pPr>
    <xsl:if test="@xml:id">
      <w:bookmarkStart w:id="{@xml:id}" w:name="{@xml:id}"/>
    </xsl:if>
    <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0">
	<wp:extent cx="{$wemu}">
	  <xsl:attribute name="cy">
	    <xsl:value-of select="atl:emu-height($imgdat/@fileref,$wemu)"/>
	  </xsl:attribute>
	</wp:extent>
	<wp:docPr id="1" name="Picture 1" />
	<a:graphic>
	  <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
	    <pic:pic>
	      <pic:nvPicPr>
		<pic:cNvPr id="0" name="Picture 1" />
		<pic:cNvPicPr />
	      </pic:nvPicPr>
	      <pic:blipFill>
		<a:blip>
		  <xsl:attribute name="r:embed">
		    <xsl:value-of select="atl:media-ref($imgdat/@fileref)"/>
		  </xsl:attribute>
		</a:blip>
		<a:stretch>
		  <a:fillRect />
		</a:stretch>
	      </pic:blipFill>
	      <pic:spPr>
		<a:xfrm>
		  <a:off x="0" y="0" />
		  <a:ext cx="{$wemu}">
		    <xsl:attribute name="cy">
		      <xsl:value-of select="atl:emu-height($imgdat/@fileref,$wemu)"/>
		    </xsl:attribute>
		  </a:ext>
		</a:xfrm>
		<a:prstGeom prst="rect">
		  <a:avLst />
		</a:prstGeom>
	      </pic:spPr>
	    </pic:pic>
	  </a:graphicData>
	</a:graphic>
      </wp:inline>
    </w:drawing>
    </w:r>
    <xsl:if test="@xml:id">
      <w:bookmarkEnd w:id="{@xml:id}" w:name="{@xml:id}"/>
    </xsl:if>
    </w:p>
    <w:p>
      <w:pPr><w:pStyle w:val="FigureCaption"/></w:pPr>
      <w:r>
	<w:rPr><w:b/></w:rPr>
	<w:t xml:space="preserve">
	  <xsl:text>Figure </xsl:text>
	  <xsl:number level="any" count="db:figure"/>
	  <xsl:text> </xsl:text>
	</w:t>
      </w:r>
      <xsl:apply-templates select="db:title"/>
    </w:p>
  </xsl:template>
</xsl:stylesheet>
