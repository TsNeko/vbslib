Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
		"1","T_IsSameTextFile",_
		"2","T_IsSameTextFileRegExp",_
		"3","T_IsSameTextFile_StringReplaceSet",_
		"4","T_fc_sth",_
		"5","T_IsSameBinaryFile",_
		"6","T_IsSameFolder",_
		"7","T_IsSameFolder_Echo",_
		"8","T_IsSameFolder_File",_
		"9","T_MD5List",_
		"10","T_SearchStringTemplate",_
		"11","T_ReplaceStringTemplate",_
		"12","T_GetLineNumOfTemplateDifference" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_IsSameTextFile] >>> 
'*************************************************************************
Sub  T_IsSameTextFile( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( "_tmp.txt" ).Enable()

	Assert  IsSameTextFile_Old( "1_sjis_crlf.txt", Empty, "1_euc_lf.txt", "EUC-JP", Empty )
	Assert  IsSameTextFile( "1_sjis_crlf.txt", "1_sjis_lf.txt", Empty )
	Assert  IsSameTextFile_Old( "1_sjis_crlf.txt", Empty, "1_utf8_bom_lf.txt", Empty, Empty )
	Assert  IsSameTextFile_Old( "1_sjis_crlf.txt", Empty, "1_utf8_nobom_crlf.txt", "UTF-8", Empty )
	Assert  IsSameTextFile( "1_sjis_crlf.txt", "1_utf16_crlf.txt", Empty )

	Assert  IsSameTextFile_Old( "1_euc_lf.txt", "EUC-JP", "1_utf8_nobom_crlf.txt", "UTF-8", Empty )

	Assert  not IsSameTextFile( "1_sjis_crlf.txt", "2_sjis_crlf.txt", Empty )
	Assert  not IsSameTextFile_Old( "1_sjis_crlf.txt", Empty, "2_euc_lf.txt", "EUC-JP", Empty )
	Assert  not IsSameTextFile( "1_sjis_crlf.txt", "2_sjis_lf.txt", Empty )
	Assert  not IsSameTextFile( "1_sjis_crlf.txt", "2_utf8_bom_lf.txt", Empty )
	Assert  not IsSameTextFile_Old( "1_sjis_crlf.txt", Empty, "2_utf8_nobom_crlf.txt", "UTF-8", Empty )
	Assert  not IsSameTextFile( "1_sjis_crlf.txt", "2_utf16_crlf.txt", Empty )

	'//=== Old bug case
	Assert  not IsSameTextFile( "1_sjis_crlf.txt", "OtherFiles\4_sjis_crlf.txt", _
		c.RightHasPercentFunction )


	'//=== error test - c.RightHasPercentFunction
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		IsSameTextFile_Old  "1_sjis_crlf.txt", Empty, "2_utf8_nobom_crlf.txt", "UTF-8", c.ErrorIfNotSame
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.desc = "<ERROR msg=""Not Same"" file1=""1_sjis_crlf.txt"" file2=""2_utf8_nobom_crlf.txt"" line=""2""/>"


	'//=== error test - c.RightHasPercentFunction or c.ErrorIfNotSame
	OpenForReplace( "5.txt", "_tmp.txt" ).Replace  "%FullPath(.)%", g_sh.CurrentDirectory


	'// Same
	IsSameTextFile  "_tmp.txt", "OtherFiles\5-Same.txt", c.RightHasPercentFunction or c.ErrorIfNotSame


	'// NotSame
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		IsSameTextFile  "_tmp.txt", "OtherFiles\5-NotSame.txt", c.RightHasPercentFunction or c.ErrorIfNotSame

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	answer_desc = Replace( "<ERROR msg=""Not Same"" file1=""_tmp.txt"" file2=""OtherFiles\5-NotSame.txt"""+_
		" line1_num=""4"" line2_num=""4"" current_folder=""%FullPath(.)%"""+ vbCRLF +_
		"line1=""%FullPath(.)%\FolderA\1.txt"""+ vbCRLF +_
		"line2=""%FullPath(.)%\OtherFiles\FolderA\1.txt"""+ vbCRLF +_
		"line2_source=""%FullPath(FolderA\1.txt)%""/>", _
		"%FullPath(.)%", g_sh.CurrentDirectory )
	Assert  e2.desc = answer_desc


	'// Over
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		IsSameTextFile  "_tmp.txt", "OtherFiles\5-Over.txt", c.RightHasPercentFunction or c.ErrorIfNotSame

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'// Clean
	del  "_tmp.txt"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_IsSameTextFileRegExp] >>> 
'*************************************************************************
Sub  T_IsSameTextFileRegExp( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( Array( "3_Replace_out1.txt", "3_Replace_out2.txt" ) ).Enable()


	'//=== same
	'// set up
	text = ReadFile( "3_Replace.txt" )
	text = Replace( text, "%FullPath(..\file.txt)%", GetFullPath( "..\file.txt", Empty ) )
	text = Replace( text, "%DesktopPath%", g_sh.SpecialFolders( "Desktop" ) )
	text = env( text )
	CreateFile  "3_Replace_out1.txt", text

	'// Test Main
	Assert  IsSameTextFile_Old( "3_Replace_out1.txt", Empty, "3_RegExp.txt", Empty, c.RightHasPercentFunction )


	'//=== difference in regexp
	For i=1 To 7

		'// set up
		text = ReadFile( "3_Replace_out1.txt" )
		Select Case  i
			Case  1 : text = Replace( text, "あいう", "わをん" )
			Case  2 : text = Replace( text, "aあXXあc", "ZあXXあc" )  '// left of RegExp
			Case  3 : text = Replace( text, "aあXXあc", "aんXXあc" )  '// in RegExp
			Case  4 : text = Replace( text, "aあXXあc", "aあXXあZ" )  '// right of RegExp
			Case  5 : text = Replace( text, GetFullPath( "..\file.txt", Empty ), GetFullPath( "..\xxx", Empty ) )
			Case  6 : text = Replace( text, g_sh.SpecialFolders( "Desktop" ), "%DesktopPath%" )
			Case  7 : text = Replace( text, env( "%windir%" ), "%windir%" )
			Case  Else : Error
		End Select
		CreateFile  "3_Replace_out2.txt", text

		'// Test Main
		Assert  not IsSameTextFile_Old( "3_Replace_out2.txt", Empty, "3_RegExp.txt", Empty, c.RightHasPercentFunction )
	Next


	'//=== error test - c.RightHasPercentFunction

	'// set up
	text = ReadFile( "3_Replace_out1.txt" )
	text = Replace( text, "aあXXあc", "aんXXあc" )  '// in RegExp
	CreateFile  "3_Replace_out2.txt", text

	'// Test Main
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		IsSameTextFile_Old  "3_Replace_out2.txt", Empty, "3_RegExp.txt", Empty, _
			c.RightHasPercentFunction  or c.ErrorIfNotSame
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	answer_desc = "<ERROR msg=""Not Same"" file1=""3_Replace_out2.txt"" file2=""3_RegExp.txt"" line1_num=""4"""+_
		" line2_num=""4"" current_folder="""+ g_sh.CurrentDirectory +""""+ vbCRLF +_
		"line1=""aんXXあc"""+ vbCRLF +_
		"line2=""a%RegExp(あ.*)%c""/>"
	Assert  e2.desc = answer_desc


	'// clean
	del  "3_Replace_out1.txt"
	del  "3_Replace_out2.txt"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_IsSameTextFile_StringReplaceSet] >>> 
'*************************************************************************
Sub  T_IsSameTextFile_StringReplaceSet( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()

	'// Set up
	del  "_work"
	CreateFile  "_work\1.txt", "aaa$11$bbb"
	CreateFile  "_work\2.txt", "aaa$22$bbb"
	CreateFile  "_work\3.txt", "aaa$22$ccc"

	Set rep = new StringReplaceSetClass
	rep.ReplaceRange  "$", "$", "$$"


	'// Test Main
	Assert      IsSameTextFile( "_work\1.txt", "_work\2.txt", rep )
	Assert  not IsSameTextFile( "_work\2.txt", "_work\3.txt", rep )

	'// Clean
	del  "_work"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_fc_sth] >>> 
'*************************************************************************
Sub  T_fc_sth( Opt, AppKey )
	Set w_= AppKey.NewWritable( "out.txt" ).Enable()

	r = RunProg( "cscript.exe  //nologo """+ SearchParent( "vbslib Prompt.vbs" )+_
		 """ fc 1_sjis_crlf.txt """" 1_euc_lf.txt EUC-JP """" n", "out.txt" )
	CheckTestErrLevel  r

	Assert  fc( "out.txt", "T_fc_sth_ans.txt" )
	del  "out.txt"

	Pass
End Sub

 
'*************************************************************************
'  <<< [T_IsSameBinaryFile] >>> 
'*************************************************************************
Sub  T_IsSameBinaryFile( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( "_tmp.txt" ).Enable()

	'//====
	'// Test Main
	Assert  not IsSameBinaryFile( "1_sjis_crlf.txt", "NotFound.txt", Empty )
	Assert  not IsSameBinaryFile( "NotFound.txt", "1_sjis_crlf.txt", Empty )
	Assert      IsSameBinaryFile( "NotFound.txt", "NotFound.txt", Empty )

	'//====
	'// Test Main
	Assert  IsSameBinaryFile( "1_sjis_crlf.txt", "1_sjis_crlf.txt", Empty )

	'//====
	'// Test Main : 文字コードの違いのみ
	Assert  not IsSameBinaryFile( "1_sjis_crlf.txt", "1_euc_lf.txt", Empty )


	'//==== [T_IsSameBinaryFile_WriteLock]
	'// Set up
	Set file = OpenForRead( "1_sjis_crlf.txt" )

	'// Test Main
	Assert  IsSameBinaryFile( "1_sjis_crlf.txt", "1_sjis_crlf.txt", Empty )

	'// Clean
	file = Empty


	'//==== [T_IsSameBinaryFile_ReadWriteLock]
	'// Set up
	copy_ren  "1_sjis_crlf.txt", "_tmp.txt"
	Set file = OpenForWrite( "_tmp.txt", c.Append )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Assert  IsSameBinaryFile( "_tmp.txt", "_tmp.txt", Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "_tmp.txt" ) > 0
	Assert  e2.num <> 0

	'// Clean
	file = Empty
	del  "_tmp.txt"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_IsSameFolder] >>> 
'*************************************************************************
Sub  T_IsSameFolder( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	Set c = g_VBS_Lib


If False Then
End If
	'// ...
	T_IsSameFolder_reset
	Assert  IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame )

	For Each  a_or_b  In Array( "A", "B" )

		'// ...
		T_IsSameFolder_reset
		CreateFile  "_work\"+ a_or_b +"\txt.txt", "update"
		Assert  not IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame )
		Assert  not IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame or c.NotSubFolder )

		'// ...
		T_IsSameFolder_reset
		CreateFile  "_work\"+ a_or_b +"\new.txt", "new"
		Assert  not IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame )
		Assert  not IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame or c.NotSubFolder )




		'// ...
		T_IsSameFolder_reset
		CreateFile  "_work\"+ a_or_b +"\sub1\txt.txt", "update"
		Assert  not IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame )
		Assert      IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame or c.NotSubFolder )

		'// ...
		T_IsSameFolder_reset
		CreateFile  "_work\"+ a_or_b +"\sub1\new.txt", "new"
		Assert  not IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame )
		Assert      IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame or c.NotSubFolder )

		'// ...
		T_IsSameFolder_reset
		mkdir  "_work\"+ a_or_b +"\sub1\new"
		Assert  not IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame )
		Assert      IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame or c.NotSubFolder )
	Next


	'// Compare files
	T_IsSameFolder_reset
	Assert      IsSameFolder( "_work\A\sub1\txt.txt", "_work\B\sub1\txt.txt", c.EchoV_NotSame )
	echo  ""
	CreateFile  "_work\A\sub1\txt.txt", "update"
	Assert  not IsSameFolder( "_work\A\sub1\txt.txt", "_work\B\sub1\txt.txt", c.EchoV_NotSame )

	For Each  a_or_b  In Array( "A", "B" )
		T_IsSameFolder_reset
		del    "_work\A\sub1\txt.txt"
		mkdir  "_work\A\sub1\txt.txt"
		Assert  not IsSameFolder( "_work\A\sub1\txt.txt", "_work\B\sub1\txt.txt", c.EchoV_NotSame )
	Next


	'// Zero size file
	T_IsSameFolder_reset
	CreateFile  "_work\A\zero.txt", ""
	CreateFile  "_work\B\zero.txt", ""
	Assert      IsSameFolder( "_work\A", "_work\B", c.EchoV_NotSame )
	Assert      IsSameFolder( "_work\A\zero.txt", "_work\B\zero.txt", c.EchoV_NotSame )


	'// ...
	T_IsSameFolder_reset
	CreateFile  "_work\A\new1.txt", "new"
	CreateFile  "_work\A\new2.txt", "new"
	CreateFile  "_work\A\sub1\new1.txt", "new"
	CreateFile  "_work\B\sub1\new2.txt", "new"
	CreateFile  "_work\B\sub2\new1.txt", "new"
	CreateFile  "_work\A\sub2\new2.txt", "new"
	Assert      IsSameFolder_Old( "_work\A", "_work\B", c.EchoV_NotSame, Array( "new1.txt", "new2.txt" ) )
	Assert      IsSameFolder_Old( "_work\A", "_work\B", c.EchoV_NotSame, Array( ".*.txt" ) )
	Assert  not IsSameFolder_Old( "_work\A", "_work\B", c.EchoV_NotSame, Array( "new1.txt" ) )


	'// Not found a folder
	Assert  not IsSameFolder( "_work\A", "_work\NotFound", c.EchoV_NotSame )
	Assert  not IsSameFolder( "_work\NotFound", "_work\B", c.EchoV_NotSame )

	'// Not found both folder
	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		r = IsSameFolder( "_work\NotFoundA", "_work\NotFoundB", _
			c.EchoV_NotSame or c.ErrorIfNotExistBoth )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'// Clean
	del  "_work"

	Pass
End Sub


Sub  T_IsSameFolder_reset()
	echo  ""
	Set ec = new EchoOff
	del  "_work"
	copy  "Folders\1\*", "_work\A"
	copy  "Folders\1\*", "_work\B"
End Sub


 
'*************************************************************************
'  <<< [T_IsSameFolder_Echo] >>> 
'*************************************************************************
Sub  T_IsSameFolder_Echo( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_out.txt" ).Enable()

	'// Set up
	del  "_out.txt"

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_IsSameFolder", "_out.txt"

	'// Clean
	AssertFC  "_out.txt", "Folders\T_IsSameFolder_Echo.txt"
	del  "_out.txt"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_IsSameFolder_File] >>> 
'*************************************************************************
Sub  T_IsSameFolder_File( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree

	For Each  t  In DicTable( Array( _
		"TestCase",               "ShiftJIS-Path", "UTF-16-Path",      "EUC-JP-Path",  Empty, _
		"T_IsSameFolder_File_1",  "1_sjis_lf.txt", "1_utf16_crlf.txt", "1_euc_lf.txt", _
		"T_IsSameFolder_File_2",  "_work\sjis",    "_work\utf16",      "_work\euc" ) )

	If section.Start( t("TestCase") ) Then

		'// Set up files
		If t("TestCase") = "T_IsSameFolder_File_2" Then
			del  "_work"
			copy_ren  "1_sjis_lf.txt",    "_work\sjis\a.txt"
			copy_ren  "1_utf16_crlf.txt", "_work\utf16\a.txt"
			copy_ren  "1_euc_lf.txt",     "_work\euc\a.txt"
		End If


		'// Set up options
		Set options = new OptionsFor_IsSameFolder_Class
		Set options.IsSameFileFunction = GetRef( "IsSameTextFile" )
		options.IsSameFileFunction_Parameter = Empty

		Assert  not IsSameFolder( t("ShiftJIS-Path"), t("UTF-16-Path"), Empty )

		'// Test Main and Check
		Assert  IsSameFolder( t("ShiftJIS-Path"), t("UTF-16-Path"), options )


		'// Set up
		Set options = new OptionsFor_IsSameFolder_Class
		Set options2_for_text = new OptionsFor_IsSameTextFile_Class
		Set options.IsSameFileFunction_Parameter = options2_for_text

		Set options.IsSameFileFunction = GetRef( "IsSameTextFile" )
		options2_for_text.CharSetA = "EUC-JP"

		'// Test Main and Check
		Assert  IsSameFolder( t("EUC-JP-Path"), t("UTF-16-Path"), options )


		'// Clean
		del  "_work"

	End If : section.End_
	Next

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_MD5List] >>> 
'*************************************************************************
Sub  T_MD5List( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_MD5List.txt", "_work" ) ).Enable()
	Set section = new SectionTree

	If section.Start( "T_MD5List_Ascii" ) Then

		'// Test Main
		MakeFolderMD5List  "Folders\1", "_MD5List.txt"
		CheckFolderMD5List  "Folders\1", "_MD5List.txt", Empty

		'// Check
		AssertFC  "_MD5List.txt", "Folders\MD5List_ans.txt"

		'// Clean
		del  "_MD5List.txt"

	End If : section.End_

	If section.Start( "T_MD5List_Unicode" ) Then

		'// Set up
		copy  "Folders\1\*", "_work"
		CreateFile  "_work\あ.txt", "あ"

		'// Test Main
		MakeFolderMD5List  "_work", "_MD5List.txt"
		CheckFolderMD5List  "_work", "_MD5List.txt", Empty

		'// Check
		AssertFC  "_MD5List.txt", "Folders\MD5ListUnicode_ans.txt"

		'// Clean
		del  "_MD5List.txt"
		del  "_work"

	End If : section.End_

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_SearchStringTemplate] >>> 
'*************************************************************************
Sub  T_SearchStringTemplate( Opt, AppKey )

	g_Vers("ExpandWildcard_Sort") = True


	'// Test Main
	founds = SearchStringTemplate( "TemplateTarget\1_before", "\*\*/", _
		"/***********" +vbCRLF+ _
		"((( ${FunctionName} ))$\{FunctionName}$\\)" +vbCRLF+ _
		"************/" +vbCRLF, Empty )


	'// Check
	i = 0
	Assert  Mid( ReadFile( founds(0)(i).Path ), _
		founds(0)(i).LineText(0), _
		founds(0)(i).LineText(1) - founds(0)(i).LineText(0) ) _
		= _
		"/***********" +vbCRLF+ _
		"((( FuncA ))${FunctionName}$\)" +vbCRLF+ _
		"************/" +vbCRLF


	founds_str = GetEchoStr( founds )  '// set founds( ).LineText
	echo  founds_str

	i = 0
	Assert  founds(0)(i).Path = "TemplateTarget\1_before\1.c"
	Assert  founds(0)(i).LineNum = 1
	Assert  founds(0)(i).LineText = _
		"/***********" +vbCRLF+ _
		"((( FuncA ))${FunctionName}$\)" +vbCRLF+ _
		"************/" +vbCRLF
	i = i + 1

	Assert  founds(0)(i).Path = "TemplateTarget\1_before\2.h"
	Assert  founds(0)(i).LineNum = 1
	Assert  founds(0)(i).LineText = _
		"/***********" +vbCRLF+ _
		"((( FuncA ))${FunctionName}$\)" +vbCRLF+ _
		"************/" +vbCRLF
	i = i + 1

	Assert  founds(0)(i).Path = "TemplateTarget\1_before\2.h"
	Assert  founds(0)(i).LineNum = 5
	Assert  founds(0)(i).LineText = _
		"/***********" +vbCRLF+ _
		"((( FuncB ))${FunctionName}$\)" +vbCRLF+ _
		"************/" +vbCRLF
	i = i + 1

	Assert  founds(0)(i).Path = "TemplateTarget\1_before\2.h"
	Assert  founds(0)(i).LineNum = 18
	Assert  founds(0)(i).LineText = _
		"/***********" +vbCRLF+ _
		"((( FuncE ))${FunctionName}$\)" +vbCRLF+ _
		"************/" +vbCRLF
	i = i + 1

	Assert  founds(0)(i).Path = "TemplateTarget\1_before\sub\1.c"
	Assert  founds(0)(i).LineNum = 1
	Assert  founds(0)(i).LineText = _
		"/***********" +vbCRLF+ _
		"((( FuncA ))${FunctionName}$\)" +vbCRLF+ _
		"************/" +vbCRLF
	i = i + 1

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ReplaceStringTemplate] >>> 
'*************************************************************************
Sub  T_ReplaceStringTemplate( Opt, AppKey )
	Set ds = new CurDirStack
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_ReplaceStringTemplate_3"


	If section.Start( "T_ReplaceStringTemplate" ) Then

	'// Set up
	del  "_work"
	copy  "TemplateTarget\1_before\*", "_work"

	'// Test Main
	ReplaceStringTemplate  "_work",  "\*\*/", _
		"/***********" +vbCRLF+ _
		"((( ${FunctionName} ))$\{FunctionName}$\\)" +vbCRLF+ _
		"************/" +vbCRLF, _
		_
		"/*==========" +vbCRLF+ _
		"<<< ${FunctionName} >>$\{FunctionName}$\\)" +vbCRLF+ _
		"===========*/" +vbCRLF, _
		Empty

	template = _
		"/***********" +vbCRLF+ _
		"[[[ ${FileName} ]]]" +vbCRLF+ _
		"${Comment}" +vbCRLF+ _
		"************/" +vbCRLF
	ReplaceStringTemplate  "_work",  "/\*\*", template, template, Empty

	'// Check
	Assert  fc( "_work", "TemplateTarget\2_after" )

	'// Clean
	del  "_work"

	End If : section.End_


	For Each  t  In DicTable( Array( _
		"Case", "Before", "Keyword",      "BeforeTemplate", "AfterTemplate", "AfterAnswer",  Empty, _
		1,      "a.txt", "a_keyword.txt", "a_template.txt", "a_template_after.txt", "a_after.txt",  _
		2,      "b.txt", "b_keyword.txt", "b_template.txt", "b_template_after.txt", "b_after.txt",  _
		3,      "c.txt", "c_keyword.txt", "c_template.txt", "c_template_after.txt", "c_after.txt"  ) )

		If section.Start( "T_ReplaceStringTemplate_" + CStr( t("Case") ) ) Then


		'// Set up
		del  "_work"
		copy  "TemplateTarget\replace\"+ t("Before"), "_work"

		If t("Case") = 3 Then
			Set option_ = Dict(Array( "${Note1}", "", "${Note2}", "Not Note" ))
		Else
			option_ = Empty
		End If

		'// Test Main
		ReplaceStringTemplate  "_work",  Trim2( ReadFile( "TemplateTarget\replace\"+ t("Keyword") ) ), _
			ReadFile( "TemplateTarget\replace\"+ t("BeforeTemplate") ), _
			ReadFile( "TemplateTarget\replace\"+ t("AfterTemplate") ), _
			option_

		'// Check
		AssertFC  "_work\"+ t("Before"), "TemplateTarget\replace\"+ t("AfterAnswer")

		'// Clean
		del  "_work"


		End If : section.End_
	Next


	Pass
End Sub


 
'*************************************************************************
'  <<< [T_GetLineNumOfTemplateDifference] >>> 
'*************************************************************************
Sub  T_GetLineNumOfTemplateDifference( Opt, AppKey )
	Set ds = new CurDirStack
	pushd  "TemplateTarget\diff"
	ad2 = 2  '// 解析不能による誤差


	For Each  t  In DicTable( Array( _
		"TargetFile",  "LineNumAnswer",  Empty, _
		"1.txt",        1,  _
		"1+1.txt",      1+1,  _
		"1+15.txt",     1+15,  _
		"2.txt",        2,  _
		"2+1.txt",      2+1,  _
		"2+15.txt",     2+15,  _
		"5.txt",        5 +ad2,  _
		"5+1.txt",      5+1 +ad2,  _
		"5+15.txt",     5+15 +ad2,  _
		"6A.txt",       6,  _
		"6A+1.txt",     6+1,  _
		"6A+15.txt",    6+15,  _
		"6B.txt",       6,  _
		"6B+1.txt",     6+1,  _
		"6B+15.txt",    6+15,  _
		"7.txt",        7,  _
		"7+1.txt",      7+1,  _
		"7+15.txt",     7+15,  _
		"8.txt",        8,  _
		"8+1.txt",      8+1,  _
		"8+15.txt",     8+15,  _
		"10.txt",      10,  _
		"10+1.txt",    10+1,  _
		"10+15.txt",   10+15,  _
		"13.txt",      13,  _
		"13+1.txt",    13+1,  _
		"13+15.txt",   13+15,  _
		"0A.txt",       0,  _
		"0B.txt",       0,  _
		"0C.txt",       0  ) )

		line_num = GetLineNumOfTemplateDifference( ReadFile( t("TargetFile") ), _
			"Parameters:", ReadFile( "Template.txt" ) )

		echo  line_num &": "& t("TargetFile")
		Assert  line_num = t("LineNumAnswer")
	Next
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

 
