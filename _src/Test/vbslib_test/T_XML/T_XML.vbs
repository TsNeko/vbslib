Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_LoadXML", _
			"2","T_XmlWrite", _
			"3","T_XmlRead", _
			"4","T_OpenForReplaceXML", _
			"6","T_OpenForAppendXml", _
			"7","T_XPath", _
			"8","T_XmlText", _
			"9","T_XmlAttrDic", _
			"10","T_CompareXml", _
			"11","T_HRefBase", _
			"12","T_XmlSelect", _
			"13","T_XML_ReadCacheClass", _
			"14","T_MultiTextXML", _
			"15","T_LoadXML_PathObject" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_LoadXML] >>> 
'*************************************************************************
Sub  T_LoadXML( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()


	'// Test of LoadXML
	Set root = LoadXML( "sample1.xml", Empty )
	t = root.selectSingleNode( "./Tests/Test" ).getAttribute( "result" )
	If t <> "0" Then  Fail


	'// Test of F_NoRoot
	Set root = LoadXML( "sample2.txt", Empty )
	t = root.selectSingleNode( "./TAG1" ).getAttribute( "attr" )
	If t <> "value1" Then  Fail


	'// Test of F_NoRoot
	Set root = LoadXML( "sample4.txt", Empty )
	t = root.selectSingleNode( "./TAG1" ).getAttribute( "attr" )
	If t <> "value1" Then  Fail


	'// Test of F_NoRoot and F_Str
	t = "ABC <TAG1 attr='value1'/> 123"
	Set root = LoadXML( t, F_Str )
	t = root.selectSingleNode( "./TAG1" ).getAttribute( "attr" )
	If t <> "value1" Then  Fail


	'// Test of F_Str
	t = " <TAG1 attr='value2'/>"
	Set root = LoadXML( t, F_Str )
	t = root.getAttribute( "attr" )
	Assert  t = "value2"


	'// Test of Unicode
	Set root = LoadXML( "sample3_unicode.xml", Empty )
	t = root.selectSingleNode( "./Tests/Test" ).getAttribute( "result" )
	Assert  t = "1"


	'// Test of LoadXML with BOM of UTF-8
	Set root = LoadXML( "sample6_utf8bom.xml", Empty )
	t = root.selectSingleNode( "./Tests/Test" ).getAttribute( "result" )
	Assert  t = "0"

	'// Test of LoadXML with no BOM of UTF-8
	Set root = LoadXML( "sample6_utf8_no_bom.xml", Empty )
	t = root.selectSingleNode( "./Tests/Test" ).getAttribute( "result" )
	Assert  AscW( t ) = &h25A0

	'// Test of LoadXML Shift JIS
	Set root = LoadXML( "sample6_shift_JIS.xml", Empty )
	t = root.selectSingleNode( "./Tests/Test" ).getAttribute( "result" )
	Assert  AscW( t ) = &h25A0

	'// Test of not found
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set root = LoadXML( "not_exist_file.xml", Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_FileNotExist


	'// Test of syntax error message
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set root = LoadXML( "syntax_err.xml", Empty )
			 '//&HC00CE509 // 要求したスペースが見つかりません。

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "syntax_err.xml" ) > 0
	Assert  InStr( e2.desc, "要求したスペース" ) > 0
	Assert  e2.num = 1


	'// Test of character code set
	Set root = LoadXML( "sjis_err.xml", Empty )


	'// Test of character code set
	Set root = LoadXML( "HTML4.html", Empty )
	Assert  root.selectSingleNode( "./BODY/P/text()" ).text = "Text1"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_XmlWrite] >>> 
'*************************************************************************
Sub  T_XmlWrite( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()


	'// Test of XmlWrite xml text (1)
	EchoTestStart  "T_XmlWrite_1"
	Set root = LoadXML( "sample7.xml", Empty )
	is_modify= XmlWrite( root, "./Test1", "あいう" ) :  Assert  not is_modify
	is_modify= XmlWrite( root, "./Test1", "うえお" ) :  Assert  is_modify  '// Modify
	is_modify= XmlWrite( root, "./Test2", "def" )    :  Assert  is_modify  '// Modify multi
	is_modify= XmlWrite( root, "./Test2/S/SS", 1.2 ) :  Assert  is_modify  '// Add nested tag multi
	is_modify= XmlWrite( root, "./Test3", Empty )    :  Assert  is_modify  '// Remove xml tag
	is_modify= XmlWrite( root, "./Test4", "" )       :  Assert  is_modify  '// Remove text
	is_modify= XmlWrite( root, "./Test5/Sub", "A" )  :  Assert  is_modify  '// Modify multi nested
	is_modify= XmlWrite( root, "./Test6/Sub", "A" )  :  Assert  is_modify  '// Add
	XmlWriteEncoding  root, "Shift_JIS"
	root.ownerDocument.save  "out.xml"
	AssertFc  "out.xml", "sample7_ans.xml"
	del  "out.xml"


	'// Test of XmlWrite xml attribute (1)
	EchoTestStart  "T_XmlWriteAttr_1"
	Set root = LoadXML( "sample1.xml", Empty )
	is_modify= XmlWrite( root, "./Tests/Sub/@value", "2" )       : Assert  is_modify  '// Add
	is_modify= XmlWrite( root, "./Tests/Test/Sub/@value", "3" )  : Assert  is_modify  '// Add nested tag and attr multi
	is_modify= XmlWrite( root, "./Tests/Test/Sub/@value2", "4" ) : Assert  is_modify  '// Add attr multi
	is_modify= XmlWrite( root, "./Tests/Test/@result", "4" )     : Assert  is_modify  '// Modify
	is_modify= XmlWrite( root, "./Sub/@value", "5" )             : Assert  is_modify  '// Add
	root.ownerDocument.save  "out.xml"
	AssertFc  "out.xml", "XmlWrite_ans2.xml"
	del  "out.xml"


	'// Test of XmlWrite xml attribute (2)
	EchoTestStart  "T_XmlWriteAttr_2"
	Set root = LoadXML( "sample1.xml", Empty )
	is_modify= XmlWrite( root, "./Tests/Test[@result='0']/@result", "2" )   : Assert      is_modify
	is_modify= XmlWrite( root, "./Tests/Test[@result='1']/@result", "1" )   : Assert  not is_modify
	is_modify= XmlWrite( root, "./Tests/Test[@result='1']/@result", Empty ) : Assert      is_modify
	If not root.selectSingleNode( "./Tests/Test[@result='1']" ) is Nothing Then  Fail
	is_modify= XmlWrite( root, "./Tests/Test[@result='1']/@result", Empty ) : Assert  not is_modify
	is_modify= XmlWrite( root, "./Tests/Test[@result='1']/@result", "3" )   : Assert      is_modify
	If root.selectSingleNode( "./Tests/Test[@result='3']" ) is Nothing Then  Fail
	root.ownerDocument.save  "out.xml"
	AssertFc  "out.xml", "XmlWrite_ans1.xml"
	del  "out.xml"


	'// Test of XmlWrite xml attribute (3) : Error
	EchoTestStart  "T_XmlWriteAttr_3"
	Set root = LoadXML( "sample1.xml", Empty )
	If TryStart(e) Then  On Error Resume Next
		is_modify= XmlWrite( root, "/NotFound/Sub/@value", "2" )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If InStr( e2.desc, "ルート・ノードは変更できません" ) = 0 Then  Fail
	If e2.num <> E_NotFoundSymbol Then  Fail


	'// Test of XmlWrite xmlns attribute
	EchoTestStart  "T_XmlWriteXmlNS"
	Set root = LoadXML( Replace( ReadFile( "sample1.xml" ),_
							 "<X>", "<X xmlns=""http://sample.com/xmlns"">" ), F_Str )
	XmlWrite  root, "./Tests/XMLns1", ""
	root.ownerDocument.save  "out.xml"
	AssertFc  "out.xml", "XmlWrite_NS_ans.xml"
	del  "out.xml"


	'// Test of XmlWrite delete xml element
	EchoTestStart  "T_XmlWriteDelete"
	Set root = LoadXML( "sample1.xml", Empty )
	is_modify= XmlWrite( root, "./Tests/Test[@result='0']/@result", Empty )  : Assert  is_modify  '// delete attribute
	is_modify= XmlWrite( root, "./Tests/Test[@result='1']", Empty )  : Assert  is_modify  '// delete tag
	Assert  root.xml = _
		"<X>"+vbCRLF+_
		"	<Tests>"+vbCRLF+_
		"		<Test/>"+vbCRLF+_
		"	</Tests>"+vbCRLF+_
		"</X>"

	is_modify= XmlWrite( root, "./Tests/Test", Empty )  : Assert  is_modify  '// delete no text tag
	Assert  root.xml = _
		"<X>"+vbCRLF+_
		"	<Tests>"+vbCRLF+_
		"	</Tests>"+vbCRLF+_
		"</X>"

	is_modify= XmlWrite( root, "./Tests", Empty )  : Assert  is_modify
	Assert  root.xml = "<X>"+vbCRLF+"</X>"

	Pass
End Sub

 
'*************************************************************************
'  <<< [T_XmlRead] >>> 
'*************************************************************************
Sub  T_XmlRead( Opt, AppKey )
	Set root = LoadXML( "sample1.xml", Empty ) ' as IXMLDOMElement

	value = XmlRead( root, "./Tests/Test/@result" )
	Assert  value = "0"

	value = XmlRead( root, "/X/Tests/Test/@result" )
	Assert  value = "0"

	value = XmlRead( root.selectSingleNode( "./Tests" ), "/X/Tests/Test/@result" )
	Assert  value = "0"

	value = XmlRead( root, "./Tests/Test/@not_defined" )
	Assert  IsEmpty( value )

	value = XmlRead( root, "./Tests/NotDefined/@result" )
	Assert  IsEmpty( value )


	Set root = LoadXML( "sample7.xml", Empty ) ' as IXMLDOMElement
	value = XmlRead( root, "./Test4" )
	Assert  value = "あいう"

	value = XmlRead( root, "./Test4/text()" )
	Assert  value = "あいう"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_XmlSelect] >>> 
'*************************************************************************
Sub  T_XmlSelect( Opt, AppKey )
	Set w_=AppKey.NewWritable( "out.xml" ).Enable()
	Set section = new SectionTree
'// StartSectionTree  "T_XmlSelect_NewAttr"


	Set root = LoadXML( "sample1.xml", Empty )

	'// Basic case : new node
	If section.Start( "T_XmlSelect_NewNode" ) Then

		'// Test Main
		Set new_tag = XmlSelect( root, "./New" )

		'// Check
		Assert  new_tag.parentNode is root
	End If : section.End_


	'// Basic case : existing node
	If section.Start( "T_XmlSelect_ExistingNode" ) Then
		Set existing_tag = root.selectSingleNode( "./Tests/Test[@result='0']" )

		'// Test Main
		Set tag = XmlSelect( root, "./Tests/Test" )

		'// Check
		Assert  tag  is  existing_tag
	End If : section.End_


	'// TagName が同じで、id が違う兄弟ノード : すでにあるもの
	If section.Start( "T_XmlSelect_ExistAttr" ) Then
		Set existing_tag = root.selectSingleNode( "./Tests/Test[@result='1']" )

		'// Test Main
		Set tag = XmlSelect( root, "./Tests/Test[@result='1']" )

		'// Check
		Assert  tag  is  existing_tag
	End If : section.End_


	'// TagName が同じで、id が違う兄弟ノード : 新しいもの : 内部でテキストノードのインデントが不要なとき
	If section.Start( "T_XmlSelect_NewAttr" ) Then
		Set existing_tag_0 = root.selectSingleNode( "./Tests/Test[@result='0']" )
		Set existing_tag_1 = root.selectSingleNode( "./Tests/Test[@result='1']" )

		'// Test Main
		Set new_tag = XmlSelect( root, "./Tests/Test[@result='2']" )

		'// Check
		Assert  not new_tag  is  existing_tag_0
		Assert  not new_tag  is  existing_tag_1
		Assert  existing_tag_0 is root.selectSingleNode( "./Tests/Test[@result='0']" )
		Assert  existing_tag_1 is root.selectSingleNode( "./Tests/Test[@result='1']" )
		Assert  new_tag        is root.selectSingleNode( "./Tests/Test[@result='2']" )
		Assert  new_tag.parentNode.parentNode  is  root
		Assert  new_tag.getAttribute( "result" ) = "2"
	End If : section.End_


	'// TagName が同じで、id が違う兄弟ノード : 新しいもの : 内部でテキストノードのインデントが必要なとき
	Set new_tag = XmlSelect( root, "./New2[@result='1']" )
	Set new_tag = XmlSelect( root, "./New2[@result='2']" )


	'// 追加したノードのインデント
	root.ownerDocument.save  "out.xml"
	AssertFC  "out.xml", "sample1_selected.xml"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_OpenForReplaceXML] >>> 
'*************************************************************************
Sub  T_OpenForReplaceXML( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()


	'// Test of XmlWrite(1), Same as T_XmlWrite(1)
	For i=1 To 2  '//##################################### Test Point
		Select Case  i
			Case 1
				Set xml = OpenForReplaceXML( "sample1.xml", "out.xml" )
			Case 2
				copy_ren  "sample1.xml", "out.xml"
				Set xml = OpenForReplaceXML( "out.xml", Empty )
		End Select
		xml.Write  "./Tests/Test[@result='0']/@result", "2"
		xml.Write  "./Tests/Test[@result='1']/@result", "1"
		xml.Write  "./Tests/Test[@result='1']/@result", Empty
		xml.Write  "./Tests/Test[@result='1']/@result", Empty
		xml.Write  "./Tests/Test[@result='1']/@result", "3"
		xml = Empty

		AssertFC  "out.xml", "XmlWrite_ans1.xml"
		del  "out.xml"
	Next

	For Each t  In  DicTable(Array( _
			"Case",     "SrcPath",             "AnsPath",             Empty, _
			"Default",  "sample1.xml",         "sample1_replaced.xml", _
			"UTF8_BOM", "sample6_utf8bom.xml", "sample6_utf8bom_replaced.xml", _
			"Unicode",  "sample3_unicode.xml", "sample3_unicode_replaced.xml" ))

	For Each t2  In  DicTable(Array( _
			"Case2",        "DstPath",   "OutPath",    Empty, _
			"DstNormal",    "out.xml",   "out.xml", _
			"DstEmpty",     Empty,       "out.xml", _
			"DstOverWrite", "out.xml",   "out.xml" ))
		Dic_add  t, t2 : t2.RemoveAll

		src_path = t("SrcPath")  '// for src_path will overwrite


		'//=== setup files
		Select Case  t("Case2")

			Case  "DstNormal"
				del  "out.xml"

			Case  "DstEmpty"
				copy_ren  src_path,  "out.xml"
				src_path = "out.xml"

			Case  "DstOverWrite"
				copy_ren  src_path,  "out.xml"

			Case Else : Error
		End Select


		'//=== Do test  '//##################################### Test Point
		Set xml = OpenForReplaceXML( src_path, t("DstPath") )
		xml.Write  "./Tests/Test[@result='1']/@result", "2"
		xml = Empty
		AssertFC  t("OutPath"), t("AnsPath")

	Next
	Next

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_OpenForAppendXml] >>> 
'*************************************************************************
Sub  T_OpenForAppendXml( Opt, AppKey )
	tmp_path = GetTempPath( "T_OpenForAppendXml.xml" )
	Set c = g_VBS_Lib

	'//=== UTF-16, CR+LF
	'// set up
	old_xml = _
		"<?xml version=""1.0"" encoding=""UTF-16""?>"+ vbCRLF +_
		"<Modify>"+ vbCRLF +_
		"<Child1 value=""1""/>"+ vbCRLF +_
		"</Modify>"+ vbCRLF
	add_xml = _
		"<?xml version=""1.0"" encoding=""UTF-16""?>"+ vbCRLF +_
		"<Add>"+ vbCRLF +_
		"<AddChild value=""3""/>"+ vbCRLF +_
		"</Add>"+ vbCRLF
	add2_xml = "<Add2><Line/></Add2>"
	ans_xml = _
		"<?xml version=""1.0"" encoding=""UTF-16""?>"+ vbCRLF +_
		"<Modify>"+ vbCRLF+_
		"<Child1 value=""1""/>"+ vbCRLF+_
		"<Child2 value=""2""/> <!-- by WriteLine -->"+ vbCRLF+_
		"<AddChild value=""3""/>"+ vbCRLF+_
		"<Line/>"+ vbCRLF+_
		"</Modify>"+ vbCRLF

	Set cs = new_TextFileCharSetStack( "UTF-16" )
	CreateFile  tmp_path,  old_xml
	cs = Empty

	'// Test Main
	Set file = OpenForAppendXml( tmp_path, Empty )
	file.WriteLine  "<Child2 value=""2""/> <!-- by WriteLine -->"
	file.WriteXml  add_xml
	file.WriteXml  add2_xml
	file = Empty

	'// check
	xml = ReadFile( tmp_path )
	Assert  xml = ans_xml
	Assert  ReadUnicodeFileBOM( tmp_path ) = c.Unicode


	'//=== UTF-8, LF
	'// set up
	old_xml = Replace( old_xml, vbCRLF, vbLF ) : old_xml = Replace( old_xml, "UTF-16", "UTF-8" )
	add_xml = Replace( add_xml, vbCRLF, vbLF )
	ans_xml = Replace( ans_xml, vbCRLF, vbLF ) : ans_xml = Replace( ans_xml, "UTF-16", "UTF-8" )

	Set cs = new_TextFileCharSetStack( "UTF-8" )
	CreateFile  tmp_path,  old_xml
	cs = Empty

	'// Test Main
	Set file = OpenForAppendXml( tmp_path, Empty )
	file.WriteLine  "<Child2 value=""2""/> <!-- by WriteLine -->"
	file.WriteXml  add_xml
	file.WriteXml  add2_xml
	file = Empty

	'// check
	xml = ReadFile( tmp_path )
	Assert  xml = ans_xml
	Assert  ReadUnicodeFileBOM( tmp_path ) = c.UTF_8



	Pass
End Sub


 
'*************************************************************************
'  <<< [T_XPath] >>> 
'*************************************************************************
Sub  T_XPath( Opt, AppKey )
	Set root = LoadXML( "sample8.xml", Empty ) ' as IXMLDOMElement

	Assert  GetXPath( root, Empty ) = "/Root"

	For Each t  In DicTable(Array(_
			"XPath",                             "ShowAttrs", "NodeNum", "AnsXPath",  Empty,_
			"/Root/Test1",                             Empty,         0,  Empty,_
			"/Root/Test2/@id",                         Empty,         0, "@id",_
			"/Root/Test2[@id='1']/Sub",                Empty,         0,  Empty,_
			"/Root/Test2[@id='1']/Sub",               "attr",         0, "/Root/Test2[@attr='a']/Sub",_
			"/Root/Test2[@id='1']/Sub",   Array("id","attr"),         0, "/Root/Test2[@id='1' and @attr='a']/Sub",_
			"/Root/Test2[@id='2' and @name='a']/Sub",  Empty,         0,  Empty ))

		If IsEmpty( t("AnsXPath") ) Then  t("AnsXPath") = t("XPath")
		i = t("NodeNum")

		Set node = root.selectNodes( t("XPath") )
		Assert  GetXPath( node(i), t("ShowAttrs") ) = t("AnsXPath")

	Next

	Pass
End Sub

 
'*************************************************************************
'  <<< [T_XmlText] >>> 
'*************************************************************************
Sub  T_XmlText( Opt, AppKey )

	Assert  XmlText( "<" ) = "&lt;"
	Assert  XmlText( ">" ) = "&gt;"
	Assert  XmlText( "&" ) = "&amp;"
	Assert  XmlText( "&lt;" ) = "&amp;lt;"

	Assert  XmlAttr( "<""'" ) = "&lt;&quot;'"
	Assert  XmlAttrA( "<""'" ) = "&lt;""&apos;"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_XmlAttrDic] >>> 
'*************************************************************************
Sub  T_XmlAttrDic( Opt, AppKey )

	'//====
	Set root = LoadXML( "<XML attr1='value1' attr2='value2'/>", F_Str )
	Set attr = XmlAttrDic( root )

	Assert  attr.Item( "attr1" ) = "value1"
	Assert  attr.Item( "attr2" ) = "value2"


	'//==== no attr
	Set root = LoadXML( "<XML/>", F_Str )
	Set attr = XmlAttrDic( root )

	Assert  attr.Count = 0


	Pass
End Sub


 
'*************************************************************************
'  <<< [T_CompareXml] >>> 
'*************************************************************************
Sub  T_CompareXml( Opt_, AppKey )

	Set opt = new fc_option
	opt.IsXmlComparedAsBinary = False

	r = fc_ex( "sample1.xml", "sample1.xml", opt )
	Assert  r

	r = fc_ex( "sample1.xml", "sample1_CompareSame.xml", opt )
	Assert  r

	r = fc_ex( "sample1.xml", "sample5.xml", opt )
	Assert  not r

	r = fc_ex( "not_found.xml", "sample5.xml", opt )
	Assert  not r

	r = fc_ex( "sample1.xml", "not_found.xml", opt )
	Assert  not r

	If TryStart(e) Then  On Error Resume Next
		r = fc_ex( ".", ".", opt )
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_TestFail  Then  Fail
	e.Clear


	opt.IsXmlComparedAsBinary = Empty  '// default is True
	r = fc_ex( "sample1.xml", "sample1_CompareSame.xml", opt )
	Assert  not r

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_HRefBase] >>> 
'*************************************************************************
Sub  T_HRefBase( Opt, AppKey )

	Set base = GetHRefBase( "sample8.xml", "Test2" )
	Set x = base.href( "#a" )
	echo  x.xml
	Assert  x.getAttribute( "id" ) = "2"

	Set base = GetHRefBase( "sample1.xml", Array( "Test2" ) )
	Set x = base.href( "sample8.xml#1" )
	echo  x.xml
	Assert  x.getAttribute( "attr" ) = "a"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_XML_ReadCacheClass] >>> 
'*************************************************************************
Sub  T_XML_ReadCacheClass( Opt, AppKey )
	Set files = new XML_ReadCacheClass

	Assert  files( "sample7.xml#/Root/Test4" ) = "あいう"
	Assert  files( "sample7.xml#/Root/Test4/" ) = "あいう"
	Assert  files( "sample1.xml#/X/Tests/Test/@result" ) = "0"
	Assert  files( "sample7.xml#/Root/Test2[@attr1='1']" ) = "abc"


	'//=== Error Handling Test
	For Each  a_URL  In Array( _
			"not_found.xml#/Root/Test1", _
			"sample7.xml#/Root/NotFoundTag", _
			"sample7.xml#/Root/Test2[@attr1='NotFound']" )

		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			x = files( a_URL )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  InStr( e2.desc, a_URL ) > 0
		Assert  e2.num <> 0
	Next

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_MultiTextXML] >>> 
'*************************************************************************
Sub  T_MultiTextXML( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  ""

	Set files = new MultiTextXML_Class

	If section.Start( "T_MultiTextXML_1" ) Then

	text = files.GetText( "Files\T_MultiTextXML_1.xml#1" )
	Assert  text = "abc  def  "+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_2.xml#3" )
	Assert  text = "ABC  DEF  "+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_1.xml#22" )
	Assert  text = "abc"+ vbCRLF +"  def"+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_2.xml#4" )
	Assert  text = "ABC"+ vbCRLF +"  DEF"+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_3.xml#31" )
	Assert  text = "ABC  DEF  "+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_3.xml#32" )
	Assert  text = "  DEF"+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_3.xml#33" )
	Assert  text = "GH"+ vbCRLF +"IJ"+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_3.xml#34" )
	Assert  text = "12"+ vbCRLF +"34"+ vbCRLF

	answer = _
		"<?xml version=""1.0"" encoding=""UTF-8""?><MultiText><Text id=""3""><![CDATA["+ vbCRLF +_
		"ABC  DEF  "+ vbCRLF +_
		"]]></Text><Text id=""4""><![CDATA[ABC"+ vbCRLF +_
		"  DEF"+ vbCRLF +_
		"]]></Text></MultiText>"+ vbCRLF

	text = files.GetText( "Files\T_MultiTextXML_2.xml" )
	Assert  text = answer

	'// Test Main : Read from cache
	text = files.GetText( "Files\T_MultiTextXML_2.xml" )
	Assert  text = answer

	End If : section.End_


	'//=== Error Handling Test
	If section.Start( "T_MultiTextXML_Err1" ) Then
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		text = files.GetText( "Files\NotFound.xml#1" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "NotFound.xml#1" ) > 0
	Assert  e2.num = E_FileNotExist
	End If : section.End_


	'//=== Error Handling Test
	If section.Start( "T_MultiTextXML_Err2" ) Then
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		text = files.GetText( "Files\T_MultiTextXML_2.xml#NotFound" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "T_MultiTextXML_2.xml#NotFound" ) > 0
	Assert  e2.num = E_FileNotExist
	End If : section.End_


	'//=== Test of "IsExist"
	If section.Start( "T_MultiTextXML_IsExist" ) Then
	Assert  not files.IsExist( "Files\NotFound.xml" )
	Assert  not files.IsExist( "Files\NotFound.xml#1" )
	Assert      files.IsExist( "Files\T_MultiTextXML_1.xml" )
	Assert      files.IsExist( "Files\T_MultiTextXML_1.xml#1" )
	Assert  not files.IsExist( "Files\T_MultiTextXML_2.xml#NotFound" )
	End If : section.End_


	Pass
End Sub


 
'*************************************************************************
'  <<< [T_LoadXML_PathObject] >>> 
'*************************************************************************
Sub  T_LoadXML_PathObject( Opt, AppKey )
	text = _
		"<X>"+vbCRLF+_
		"<Tests>"+vbCRLF+_
		"<Test result=""0""/>"+vbCRLF+_
		"<Test result=""1""/>"+vbCRLF+_
		"</Tests>"+vbCRLF+_
		"</X>"+vbCRLF

	Set root = LoadXML( new_FilePathForString( text ), Empty )
	t = root.selectSingleNode( "./Tests/Test" ).getAttribute( "result" )
	If t <> "0" Then  Fail

	Pass
End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_Vers : If IsEmpty( g_Vers ) Then
Set  g_Vers = CreateObject("Scripting.Dictionary") : g_Vers("vbslib") = 99.99
Dim  g_debug, g_debug_params, g_admin, g_vbslib_path, g_CommandPrompt, g_fs, g_sh, g_AppKey
Dim  g_MainPath, g_SrcPath, g_f, g_include_path, g_i, g_debug_tree, g_debug_process, g_is_compile_debug
Dim  g_is64bitWSH
g_SrcPath = WScript.ScriptFullName : g_MainPath = g_SrcPath
SetupVbslibParameters
Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject("WScript.Shell") : g_f = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
For g_i = 20 To 1 Step -1 : If g_fs.FileExists(g_vbslib_path) Then  Exit For
g_vbslib_path = "..\" + g_vbslib_path  : Next
If g_fs.FileExists(g_vbslib_path) Then  g_vbslib_path = g_fs.GetAbsolutePathName( g_vbslib_path )
g_sh.CurrentDirectory = g_f
If g_i=0 Then WScript.Echo "Not found " + g_fs.GetFileName( g_vbslib_path ) +vbCR+vbLF+_
	"Let's download vbslib and Copy scriptlib folder." : Stop : WScript.Quit 1
Set g_f = g_fs.OpenTextFile( g_vbslib_path,,,-2 ): Execute g_f.ReadAll() : g_f = Empty
If ResumePush Then  On Error Resume Next
	CallMainFromVbsLib
ResumePop : On Error GoTo 0
End If
'---------------------------------------------------------------------------------

Sub  SetupDebugTools()
	set_input  ""
	SetBreakByFName  Empty
	SetStartSectionTree  ""
End Sub

Sub  SetupVbslibParameters()
	'--- start of parameters for vbslib include -------------------------------
	g_Vers("vbslib") = 99.99
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
