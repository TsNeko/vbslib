


RXML を置き換えてください







<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<HTML lang="ja"><HEAD>
<META http-equiv="content-type" content="text/html; charset=Shift_JIS">
<TITLE>テスト結果 (Config : <xsl:value-of select="/Root/Config"/>)</TITLE>

<STYLE type="text/css">
TABLE { border-collapse: collapse; }
A { text-decoration:none; }


/* Style of Test count */
TR.IntervalHeight  { height: 6px; }
TD.Count  { width: 32px;  padding: 0px 4px;  text-align: right;  font-weight: bold; }
TD.Result, TD.Pass, TD.Fail, TD.Skip, TD.Manual
          { border-width: 1px;  border-style: solid;  border-color: black;  height: 12pt;
            margin: 0px;  padding: 0px; }
TD.Result          { padding: 0px 8px; }
TD.Pass,   #Pass   { color: black;  background-color: #CAFBFF; }
TD.Fail,   #Fail   { color: white;  background-color: red; }
TD.Skip,   #Skip   { color: black;  background-color: #80FF00; }
TD.Manual, #Manual { color: black;  background-color: yellow; }
</STYLE>
</HEAD><BODY>


<H3>テスト結果 (Config : <xsl:value-of select="/Root/Config"/>)</H3>

<P>
<TABLE><TR>
  <TD class="Result" id="Pass">Pass</TD><TD class="Count"><xsl:value-of select="/Root/PassCount"/></TD>
  <TD><TABLE><TR><TD class="Pass"><xsl:attribute name="style">width: <xsl:value-of select="PassLength"/>px;<xsl:attribute></TD></TR></TABLE></TD>
</TR>
<TR class="IntervalHeight"></TR>
<TR>
  <A href="#T_Case1"><TD class="Result" id="Fail">Fail</TD></A><TD class="Count"><xsl:value-of select="/Root/FailCount"/></TD>
  <TD><TABLE><TR><TD class="Pass"><xsl:attribute name="style">width: <xsl:value-of select="FailLength"/>px;<xsl:attribute></TD></TR></TABLE></TD>
</TR>
<TR class="IntervalHeight"></TR>
<TR>
  <TD class="Result" id="Skip">Skip</TD><TD class="Count"><xsl:value-of select="/Root/SkipCount"/></TD>
  <TD><TABLE><TR><TD class="Skip"><xsl:attribute name="style">width: <xsl:value-of select="SkipLength"/>px;<xsl:attribute></TD></TR></TABLE></TD>
</TR>
<TR class="IntervalHeight"></TR>
<TR>
  <A href="#ManualTest"><TD class="Result" id="Manual">Manual</TD></A><TD class="Count"><xsl:value-of select="/Root/ManualCount"/></TD>
  <TD><TABLE><TR><TD class="Manual"><xsl:attribute name="style">width: <xsl:value-of select="ManualLength"/>px;<xsl:attribute></TD></TR></TABLE></TD>
</TR>
</TABLE>
</P>


<TABLE style="height: 10px;"><TR><TD></TD></TR></TABLE>


<H4>自動テストの結果</H4>


<STYLE type="text/css">
/* Style of Auto test result */
TABLE.ResultTable TR TD  { text-align: center; }
TABLE.ResultTable TR TD.RowTitle     { padding: 8px; }
TABLE.ResultTable TR TD.Open         { padding: 0px 16px; }
TABLE.ResultTable TR TD.NextErr      { padding: 4px;  font-size: small; }

TABLE.ResultTable TR TD.PassCase,
TABLE.ResultTable TR TD.FailCase,
TABLE.ResultTable TR TD.SkipCase
  { padding: 0px 8px;  text-align: left; }
TABLE.ResultTable TR TD.FailCase { font-weight: bold;  color: red; }
TABLE.ResultTable TR TD.SkipCase { font-weight: bold;  color: #00C000; }

TABLE.ResultTable TR TD.PassGraph,
TABLE.ResultTable TR TD.FailGraph,
TABLE.ResultTable TR TD.SkipGraph
  { border-width: 1px 0px;  border-style: solid;  border-color: black;  height: 12pt;
    background-color: #CAFBFF; }
TABLE.ResultTable TR TD.FailGraph { border-width: 1px;  background-color: red;  color: white; }
TABLE.ResultTable TR TD.SkipGraph { border-width: 1px;  background-color: #80FF00; }

TABLE.ResultTable TR TD.Description  { text-align: left; }
</STYLE>

<P>
<TABLE class="ResultTable">

<TR>
<TD/>
<TD class="RowTitle"><SPAN style="writing-mode: tb-rl;">build</SPAN></TD>
<TD class="RowTitle"><SPAN style="writing-mode: tb-rl;">setup</SPAN></TD>
<TD class="RowTitle"><SPAN style="writing-mode: tb-rl;">start</SPAN></TD>
<TD class="RowTitle"><SPAN style="writing-mode: tb-rl;">check</SPAN></TD>
<TD class="RowTitle"><SPAN style="writing-mode: tb-rl;">clean</SPAN></TD>
<TD/>
<TD class="RowTitle"><SPAN style="writing-mode: tb-rl;">次の Fail</SPAN></TD>
<TD class="RowTitle">エラー<BR>の場所</TD>
<TD class="RowTitle" style="text-align: left;">結果</TD>
</TR>

<RXML:TEMPLATE href="AutoTestResultTable">
<TR>
<TD class="PassCase"><RXML:VAR href=".TestSymbol"/></TD>
<RXML:VAR href=".AutoTestGraph"/>
<TD class="Open"><A href="&lt;RXML:VAR href=&quot;.ScriptStepPath&quot;/&gt;">[開く]</A></TD>
<RXML:VAR href=".AutoTestNextErr"/>
<TD><RXML:VAR href=".ErrorFunction"/></TD>
<TD class="Description"><RXML:VAR href=".Description"/></TD>
</TR>

<TR class="IntervalHeight"></TR>

</RXML:TEMPLATE>

</TABLE>
</P>


<TABLE style="height: 10px;"><TR><TD></TD></TR></TABLE>


<H4><A name="ManualTest">手動テスト一覧</A></H4>

<P>
<TABLE class="ResultTable">

<TR>
<TD/>
<TD>確認日</TD>
<TD/>
<TD><SPAN style="padding: 8px;  writing-mode: tb-rl;">次の Fail</SPAN></TD>
<TD style="text-align:left;">結果</TD>
</TR>

<RXML:TEMPLATE href="ManualTestResultTable">
<TR class="IntervalHeight"></TR>

<TR>
<TD class="PassCase"><RXML:VAR href=".TestSymbol"/></TD>
<RXML:IF condition=".ManualTest=='Pass'">
<TD class="PassGraph" style="border-width: 1px;">&nbsp; <RXML:VAR href=".PassDate"/> &nbsp;</TD>
</RXML:IF>
<RXML:IF condition=".ManualTest=='Fail'">
<TD class="FailGraph" style="border-width: 1px;">&nbsp; <RXML:VAR href=".PassDate"/> &nbsp;</TD>
</RXML:IF>
<TD class="Open"><A href="&lt;RXML:VAR href=&quot;.ScriptStepPath&quot;/&gt;">[開く]</A></TD>
<RXML:VAR href=".ManualTestNextErr"/>
<TD class="Description"><RXML:VAR href=".Description"/></TD>
</TR>

</RXML:TEMPLATE>
</TABLE>
</P>

<P style="font-size:small;">&nbsp; ※ ManualTest.xml に記述された手動テストの確認日が <RXML:VAR href="FailDate"/> より古いときは Fail 扱いにしています。</P>

<TABLE height="90%" style="position:absolute; margin-top:8px"><TR><TD></TD></TR></TABLE>


</BODY></HTML>
