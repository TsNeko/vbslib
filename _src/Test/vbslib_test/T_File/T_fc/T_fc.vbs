Sub  Main( Opt, AppKey )
    include  SearchParent( "_src\Test\tools\T_SyncFiles\SettingForTest_pre.vbs" )
    include  SearchParent( "_src\Test\tools\T_SyncFiles\SettingForTest.vbs" )

	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
		"1","T_IsSameTextFile",_
		"2","T_IsSameTextFileRegExp",_
		"3","T_IsSameTextFile_StringReplaceSet",_
		"4","T_fc_sth",_
		"5","T_AssertFC",_
		"6","T_GetDiffOneLineCmdLine",_
		"7","T_DiffTag",_
		"8","T_IsSameBinaryFile",_
		"9","T_IsSameFolder",_
		"10","T_IsSameFolder_Echo",_
		"11","T_IsSameFolder_File",_
		"12","T_MD5List",_
		"13","T_MD5Cache",_
		"14","T_OpenForDefragment",_
		"15","T_SearchStringTemplate",_
		"16","T_ReplaceStringTemplate",_
		"17","T_GetLineNumOfTemplateDifference" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_IsSameTextFile
'***********************************************************************
Sub  T_IsSameTextFile( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( Array( "_work", "_tmp.txt" ) ).Enable()


	'//=== Case of option is empty
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


	'//=== Case of c.RightHasPercentFunction or c.ErrorIfNotSame
	Set rep = OpenForReplace( "5.txt", "_tmp.txt" )
	rep.Replace  "%FullPath(.)%", g_sh.CurrentDirectory
	rep.Replace  "%DesktopPath%", g_sh.SpecialFolders( "Desktop" )
	rep.Replace  "%Env(USERPROFILE)%", env( "%USERPROFILE%" )
	rep = Empty


	'// Same
	IsSameTextFile  "_tmp.txt", "OtherFiles\5-Same.txt", c.RightHasPercentFunction or c.ErrorIfNotSame


	'// NotSame
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		IsSameTextFile  "_tmp.txt", "OtherFiles\5-NotSame.txt", c.RightHasPercentFunction or c.ErrorIfNotSame

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	answer_desc = Replace( "<ERROR msg=""Not Same"" file1=""_tmp.txt"" file2=""OtherFiles\5-NotSame.txt"""+ vbCRLF + _
		"line1_num=""4"" line2_num=""4"""+ vbCRLF + _
		"current_folder=""%FullPath(.)%"""+ vbCRLF +_
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


	'// LastMultiLine
	IsSameTextFile  "_tmp.txt", "OtherFiles\5-LastMultiLine.txt", c.RightHasPercentFunction or c.ErrorIfNotSame


	'//=== Case of error - c.RightHasPercentFunction
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		IsSameTextFile_Old  "1_sjis_crlf.txt", Empty, "2_utf8_nobom_crlf.txt", "UTF-8", c.ErrorIfNotSame
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.desc = "<ERROR msg=""Not Same"" file1=""1_sjis_crlf.txt"" file2=""2_utf8_nobom_crlf.txt"" line=""2""/>"


	'//=== Old bug case
	Assert  not IsSameTextFile( "1_sjis_crlf.txt", "OtherFiles\4_sjis_crlf.txt", _
		c.RightHasPercentFunction )


	'// Clean
	del  "_tmp.txt"


	'//=== Test of error message

	'// Set up
	del  "_work"
	CreateFile  "_work\A.txt", "1"+ vbCRLF +"2"+ vbCRLF +"3"+ vbCRLF
	CreateFile  "_work\B.txt", "1"+ vbCRLF +"X"+ vbCRLF +"3"+ vbCRLF

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		IsSameTextFile  "_work\A.txt", "_work\B.txt", c.RightHasPercentFunction or c.ErrorIfNotSame

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "Not Same" ) > 0
	Assert  InStr( e2.desc, "2" ) > 0
	Assert  InStr( e2.desc, "X" ) > 0
	Assert  e2.num <> 0

	'// Clean
	del  "_work"


	'//=== Test of error message

	'// Set up
	del  "_work"
	CreateFile  "_work\A.txt", "1"+ vbCRLF +"2"+ vbCRLF
	CreateFile  "_work\B.txt", "1"+ vbCRLF +"2"+ vbCRLF +"3"+ vbCRLF

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		IsSameTextFile  "_work\A.txt", "_work\B.txt", c.RightHasPercentFunction or c.ErrorIfNotSame

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "file1 の全体は file2 の途中までと同じです" ) > 0
	Assert  e2.num <> 0

	'// Clean
	del  "_work"


	'//=== Test of error message

	'// Set up
	del  "_work"
	CreateFile  "_work\A.txt", "1"+ vbCRLF +"2"+ vbCRLF +"3"+ vbCRLF
	CreateFile  "_work\B.txt", "1"+ vbCRLF +"2"+ vbCRLF

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		IsSameTextFile  "_work\A.txt", "_work\B.txt", c.RightHasPercentFunction or c.ErrorIfNotSame

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "file2 の全体は file1 の途中までと同じです" ) > 0
	Assert  e2.num <> 0

	'// Clean
	del  "_work"


	'//=== Test of error message

	'// Set up
	del  "_work"
	CreateFile  "_work\A.txt", "1"+ vbCRLF +"2"+ vbCRLF
	CreateFile  "_work\B.txt", "1"+ vbCRLF +"%MultiLine%"+ vbCRLF +"3"+ vbCRLF

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		IsSameTextFile  "_work\A.txt", "_work\B.txt", c.RightHasPercentFunction or c.ErrorIfNotSame

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "%MultiLine% の次の行(next_line)が見つかりません" ) > 0
	Assert  InStr( e2.desc, "next_line=""3""" ) > 0
	Assert  e2.num <> 0

	'// Clean
	del  "_work"


	Pass
End Sub


 
'***********************************************************************
'* Function: T_IsSameTextFileRegExp
'***********************************************************************
Sub  T_IsSameTextFileRegExp( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( Array( "3_Replace_out1.txt", "3_Replace_out2.txt" ) ).Enable()


	'//=== same
	'// "3_Replace.txt" を変換した内容と、"3_RegExp.txt" を比較する

	'// set up
	text = ReadFile( "3_Replace.txt" )
	text = Replace( text, "%FullPath(..\file.txt)%", GetFullPath( "..\file.txt", Empty ) )
	text = Replace( text, "%DesktopPath%", g_sh.SpecialFolders( "Desktop" ) )
	text = Replace( text, "%Env(windir)%", env( "%windir%" ) )
	CreateFile  "3_Replace_out1.txt", text

	'// Test Main
	Assert  IsSameTextFile_Old( "3_Replace_out1.txt",  Empty,  "3_RegExp.txt",  Empty, _
		c.RightHasPercentFunction )


	'//=== difference in regexp
	'// 前のテストの続き

	For i=1 To 9
		echo  ">> T_IsSameTextFileRegExp >> "+ CStr( i )

		'// set up
		text = ReadFile( "3_Replace_out1.txt" )
		Select Case  i
			Case  1 : text = Replace( text, "あいう", "わをん" )
			Case  2 : text = Replace( text, "c%dXYe", "c%dXYZe" )  '// in 2nd RegExp
			Case  3 : text = Replace( text, "aあXXあc", "ZあXXあc" )  '// left of RegExp
			Case  4 : text = Replace( text, "abXXあc", "" )  '// Empty Line
			Case  5 : text = Replace( text, "aあXXあc", "aんXXあc" )  '// in RegExp
			Case  6 : text = Replace( text, "aあXXあc", "aあXXあZ" )  '// right of RegExp
			Case  7 : text = Replace( text, GetFullPath( "..\file.txt", Empty ), GetFullPath( "..\xxx", Empty ) )
			Case  8 : text = Replace( text, g_sh.SpecialFolders( "Desktop" ), "%DesktopPath%" )
			Case  9 : text = Replace( text, env( "%windir%" ), "%windir%" )
			Case  Else : Error
		End Select
		CreateFile  "3_Replace_out2.txt", text

		'// Test Main
		Assert  not IsSameTextFile_Old( "3_Replace_out2.txt",  Empty,  "3_RegExp.txt",  Empty, _
			c.RightHasPercentFunction )
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
	answer_desc = "<ERROR msg=""Not Same"" file1=""3_Replace_out2.txt"" file2=""3_RegExp.txt"""+ vbCRLF + _
		"line1_num=""6"" line2_num=""6"""+ vbCRLF + _
		"current_folder="""+ g_sh.CurrentDirectory +""""+ vbCRLF +_
		"line1=""aんXXあc"""+ vbCRLF +_
		"line2=""a%RegExp(あ.*)%c""/>"
	Assert  e2.desc = answer_desc


	'// clean
	del  "3_Replace_out1.txt"
	del  "3_Replace_out2.txt"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_IsSameTextFile_StringReplaceSet
'***********************************************************************
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


 
'***********************************************************************
'* Function: T_fc_sth
'***********************************************************************
Sub  T_fc_sth( Opt, AppKey )
	Set w_= AppKey.NewWritable( "out.txt" ).Enable()

	r = RunProg( "cscript.exe  //nologo """+ SearchParent( "vbslib Prompt.vbs" )+_
		 """ fc 1_sjis_crlf.txt """" 1_euc_lf.txt EUC-JP """" n", "out.txt" )
	CheckTestErrLevel  r

	Assert  fc( "out.txt", "T_fc_sth_ans.txt" )
	del  "out.txt"

	Pass
End Sub

 
'***********************************************************************
'* Function: T_AssertFC
'***********************************************************************
Sub  T_AssertFC( Opt, AppKey )
	g_Vers("AssertFC_Diff") = False

	'// Not Implemented yet

	Pass
End Sub

 
'***********************************************************************
'* Function: T_GetDiffOneLineCmdLine
'***********************************************************************
Sub  T_GetDiffOneLineCmdLine( Opt, AppKey )

	'//===========================================================

	'// Test Main
	Set diff_ = GetDiffOneLineCmdLine( _
		"T_AssertFC\Base.txt(2)", _
		"T_AssertFC\Char2.txt(2)" )

	'// Check
	out = ReadFile( diff_.PathA )
	answer = Replace( "E/r/r/o/r/ /w/a/s/ /r/a/i/s/e/d/./",  "/",  vbCRLF )
	Assert  out = answer

	out = ReadFile( diff_.PathB )
	answer = Replace( "E/r/r/o/r/ /i/s/ /r/a/i/s/e/d/./",  "/",  vbCRLF )
	Assert  out = answer

	'// Test Main
	diff_.Remove

	'// Check
	Assert  not exist( diff_.PathA )
	Assert  not exist( diff_.PathB )


	'//===========================================================

	'// Test Main
	Set diff_ = GetDiffOneLineCmdLine( _
		Array( "Error was raised." ), _
		Array( "Error is raised." ) )

	'// Check
	out = ReadFile( diff_.PathA )
	answer = Replace( "E/r/r/o/r/ /w/a/s/ /r/a/i/s/e/d/./",  "/",  vbCRLF )
	Assert  out = answer

	out = ReadFile( diff_.PathB )
	answer = Replace( "E/r/r/o/r/ /i/s/ /r/a/i/s/e/d/./",  "/",  vbCRLF )
	Assert  out = answer

	'// Test Main
	diff_.Remove

	'// Check
	Assert  not exist( diff_.PathA )
	Assert  not exist( diff_.PathB )

	Pass
End Sub


 
'***********************************************************************
'* Function: T_DiffTag
'***********************************************************************
Sub  T_DiffTag( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_out.txt" ).Enable()
	Set c = g_VBS_Lib

	For Each  t  In DicTable( Array( _
		"Dummy",  "CaseNum", _
		"TextInClipboard", _
			"Text1",  "Text2",  "Text3",  Empty, _
		_
		"=====================================================", _
		21, _
		"1"+ vbCRLF + _
		"<<<<<<< Left.txt"+ vbCRLF + _
		"LLL1"+ vbCRLF + _
		"LLL2"+ vbCRLF + _
		"======="+ vbCRLF + _
		"RRR1"+ vbCRLF + _
		"RRR2"+ vbCRLF + _
		">>>>>>> Right.txt"+ vbCRLF + _
		"2"+ vbCRLF + _
		"3"+ vbCRLF,  _
			_
			"LLL1"+ vbCRLF + _
			"LLL2"+ vbCRLF, _
			_
			"RRR1"+ vbCRLF + _
			"RRR2"+ vbCRLF, _
			_
			Empty, _
		_
		"=====================================================", _
		22, _
		"<<<<<<< Left.txt"+ vbCRLF + _
		"LLL1"+ vbCRLF + _
		"======="+ vbCRLF + _
		"RRR1"+ vbCRLF + _
		">>>>>>> Right.txt"+ vbCRLF, _
			_
			"LLL1"+ vbCRLF, _
			_
			"RRR1"+ vbCRLF, _
			_
			Empty, _
		_
		"=====================================================", _
		23, _
		"<<<<<<< Left.txt"+ vbCRLF + _
		"======="+ vbCRLF + _
		">>>>>>> Right.txt"+ vbCRLF, _
			_
			"", _
			_
			"", _
			_
			Empty, _
		_
		"=====================================================", _
		31, _
		"1"+ vbCRLF + _
		"<<<<<<< Left.txt"+ vbCRLF + _
		"LLL1"+ vbCRLF + _
		"LLL2"+ vbCRLF + _
		"||||||| Base.txt"+ vbCRLF + _
		"BBB1"+ vbCRLF + _
		"BBB2"+ vbCRLF + _
		"======="+ vbCRLF + _
		"RRR1"+ vbCRLF + _
		"RRR2"+ vbCRLF + _
		">>>>>>> Right.txt"+ vbCRLF + _
		"2"+ vbCRLF + _
		"3"+ vbCRLF,  _
			_
			"LLL1"+ vbCRLF + _
			"LLL2"+ vbCRLF, _
			_
			"BBB1"+ vbCRLF + _
			"BBB2"+ vbCRLF, _
			_
			"RRR1"+ vbCRLF + _
			"RRR2"+ vbCRLF, _
		_
		"=====================================================", _
		32, _
		"<<<<<<< Left.txt"+ vbCRLF + _
		"LLL1"+ vbCRLF + _
		"||||||| Base.txt"+ vbCRLF + _
		"BBB1"+ vbCRLF + _
		"======="+ vbCRLF + _
		"RRR1"+ vbCRLF + _
		">>>>>>> Right.txt"+ vbCRLF, _
			_
			"LLL1"+ vbCRLF, _
			_
			"BBB1"+ vbCRLF, _
			_
			"RRR1"+ vbCRLF, _
		_
		"=====================================================", _
		33, _
		"<<<<<<< Left.txt"+ vbCRLF + _
		"||||||| Base.txt"+ vbCRLF + _
		"======="+ vbCRLF + _
		">>>>>>> Right.txt"+ vbCRLF, _
			_
			"", _
			_
			"", _
			_
			""  ) )

		'// Set up
		del  "_out.txt"
		SetTextToClipboard  t("TextInClipboard")


		'// Test Main
		r = RunProg( "cscript.exe  //nologo """+ SearchParent( "vbslib Prompt.vbs" )+_
			 """  DiffTag  /ArgsLog  """"  99  Exit",  "_out.txt" )
		CheckTestErrLevel  r


		'// Check
		founds = grep( """DiffCUI_InCurrentProcess"" ""_out.txt""", c.NotEchoStartCommand )
		parameters = ArrayFromCmdLine( founds(0).LineText )
		If IsEmpty( t("Text3") ) Then
			count = 2
		Else
			count = 3
		End If

		Assert  UBound( parameters ) + 1 = 2 + count

		For i=0 To count - 1
			AssertExist  parameters(2+i)
			out_text = ReadFile( parameters(2+i) )
			answer_text = t( "Text"+ CStr(i+1) )
			Assert  out_text = answer_text
		Next

	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_IsSameBinaryFile
'***********************************************************************
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


 
'***********************************************************************
'* Function: T_IsSameFolder
'***********************************************************************
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


 
'***********************************************************************
'* Function: T_IsSameFolder_Echo
'***********************************************************************
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


 
'***********************************************************************
'* Function: T_IsSameFolder_File
'***********************************************************************
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


 
'***********************************************************************
'* Function: T_MD5List
'***********************************************************************
Sub  T_MD5List( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_work", "_MD5List.txt" ) ).Enable()
	Set section = new SectionTree
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
'//SetStartSectionTree  "T_MD5List_CopyDiff"


	'//===========================================================
	If section.Start( "T_MD5List_Ascii" ) Then

		'// Test Main
		MakeFolderMD5List   "Folders\1",  "_MD5List.txt",  Empty
		CheckFolderMD5List  "Folders\1",  "_MD5List.txt",  Empty
		MakeFolderMD5List   "Folders\1",  "_work\NotSorted_MD5List.txt",  tc.FasterButNotSorted

		'// Check
		AssertFC  "_MD5List.txt", "Folders\MD5List_ans.txt"
		Assert  SortStringLines( ReadFile( "_work\NotSorted_MD5List.txt" ),  True ) = _
			SortStringLines( ReadFile( "_MD5List.txt" ),  True )

		'// Clean
		del  "_MD5List.txt"


		'//=== Test of no _MD5List.txt

		'// Set up
		del  "_work"
		copy  "Folders\1\*", "_work"

		'// Test Main
		MakeFolderMD5List  "_work", "_work\_MD5List.txt", Empty
		MakeFolderMD5List  "_work", "_work\_MD5List.txt", Empty  '// On exist _MD5List.txt

		'// Check
		AssertFC  "_work\_MD5List.txt", "Folders\MD5List_ans.txt"

		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		old_setting = GetVar( "Setting_getDiffCmdLine" )
		SetVar  "Setting_getDiffCmdLine", "ArgsLog"
		If TryStart(e) Then  On Error Resume Next

			CheckFolderMD5List  "Folders\1",  "Folders\MD5List_Part.txt",  Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"
		echo    e2.desc
		Assert  InStr( e2.desc, "202cb962ac59075b964b07152d234b70 txt.txt" ) >= 1
		Assert  InStr( e2.desc, "e3cafd5c08bd342030e4083a7fe6b3fb sub2\bin.bin" ) >= 1
		Assert  e2.num <> 0
		SetVar  "Setting_getDiffCmdLine",  old_setting

		'// Clean
		del  "_work"


		'//=== Test of Prompt

		'// Set up
		del  "_MD5List.txt"
		del  "_work"

		'// Test Main
		RunProg  "cscript //nologo  """+ prompt_vbs +"""  MD5List  Make  Folders\1  _MD5List.txt  n",  ""

		'// Check
		AssertFC  "_MD5List.txt",  "Folders\MD5List_ans.txt"

		'// Test Main
		RunProg  "cscript //nologo  """+ prompt_vbs +"""  MD5List  Check  Folders\1  _MD5List.txt",  "_work\_out.txt"

		'// Check
		AssertFC  "_work\_out.txt",  "Folders\CheckLog_ans.txt"

		'// Clean
		del  "_MD5List.txt"
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5List_Unicode" ) Then

		'// Set up
		del  "_work"
		copy  "Folders\1\*", "_work"
		CreateFile  "_work\あ.txt", "あ"

		'// Test Main
		MakeFolderMD5List   "_work", "_MD5List.txt", Empty
		CheckFolderMD5List  "_work", "_MD5List.txt", Empty
		MakeFolderMD5List   "_work",  "_work\NotSorted_MD5List.txt",  tc.FasterButNotSorted

		'// Check
		AssertFC  "_MD5List.txt", "Folders\MD5ListUnicode_ans.txt"
		Assert  SortStringLines( ReadFile( "_work\NotSorted_MD5List.txt" ),  True ) = _
			SortStringLines( ReadFile( "_MD5List.txt" ),  True )

		'// Clean
		del  "_MD5List.txt"
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5List_Multi_Ascii" ) Then

		'// Set up
		del  "_work"
		copy  "Folders\2",  "_work"
		Set  folders = Dict(Array( "%1%\", "Folders\1", "%2%\", "_work\2" ))

		'// Test Main
		MakeFolderMD5List   folders,  "_MD5List.txt",  Empty
		CheckFolderMD5List  folders,  "_MD5List.txt",  Empty

		'// Check
		AssertFC  "_MD5List.txt", "Folders\MD5ListMulti_ans.txt"

		'// Set up
		del  "_work\2\2\sub3\new.bin"
		del  "_work\2\2\txt.txt"

		'// Test Main
		MakeFolderMD5List   folders,  "_work\TotalMD5List.txt",  tc.IncludeFullSet or tc.FasterButNotSorted

		'// Check
		AssertFC  "_work\TotalMD5List.txt", "Folders\TotalMD5List_ans.txt"

		'// Clean
		del  "_MD5List.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5List_Multi_Unicode" ) Then
		Set  folders = Dict(Array( "%1%\", "_work\1", "%OtherFiles%\", "_work\OtherFiles" ))

		'// Test Main
		del  "_work"
		copy  "Folders\1\*", "_work\1"
		copy  "OtherFiles\*", "_work\OtherFiles"
		CreateFile  "_work\OtherFiles\あ.txt", "あ"

		MakeFolderMD5List   folders, "_MD5List.txt", Empty
		CheckFolderMD5List  folders, "_MD5List.txt", Empty

		'// Check
		AssertFC  "_MD5List.txt", "Folders\MD5ListUnicodeMulti_ans.txt"

		'// Clean
		del  "_MD5List.txt"
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MakeFolderMD5List_TimeStamp_EmptyFolder" ) Then

		'// Set up
		del  "_work"
		copy  "Folders\1", "_work"
		mkdir  "_work\1\Empty"
		CreateFile  "_work\1\Size0.txt", ""

		'// Test Main
		MakeFolderMD5List   "_work\1", "_work\1\_MD5List.txt", tc.TimeStamp
		CheckFolderMD5List  "_work\1", "_work\1\_MD5List.txt", Empty

		'// Set up
		touch  "_work\1\txt.txt"

		'// Test Main
		MakeFolderMD5List   "_work\1", "_work\2\_MD5List.txt", tc.TimeStamp
		CheckFolderMD5List  "_work\1", "_work\2\_MD5List.txt", Empty
		CheckFolderMD5List  "_work\1", "_work\1\_MD5List.txt", Empty

		'// Check
		AssertFC  "_work\1\_MD5List.txt", "Folders\MD5List_TimeAndEmpty_ans.txt"
		Assert  not IsSameTextFile( "_work\2\_MD5List.txt", "_work\1\_MD5List.txt", Empty )

		'// Clean
		del  "_work"


		'//=== Test of Prompt : Stamp

		'// Set up
		del  "_work"
		copy  "Folders\1",  "_work"
		mkdir  "_work\1\Empty"
		CreateFile  "_work\1\Size0.txt", ""

		'// Test Main
		RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Stamp  _work\1  Folders\MD5List_TimeAndEmpty.txt",  ""

		'// Check
		MakeFolderMD5List  "_work\1",  "_work\_MD5List2.txt",  tc.TimeStamp
		AssertFC  "_work\_MD5List2.txt",  "Folders\MD5List_TimeAndEmpty9.txt"

		'// Set up
		Set  file = OpenForReplace( "Folders\MD5List_TimeAndEmpty.txt",  "_work\_MD5List.txt" )
		Assert  InStr( file.Text,  "2016" ) >= 1
		file.Text = Replace( file.Text, "2016", "2015" )
		file = Empty
		Set  file = OpenForReplace( "Folders\MD5List_TimeAndEmpty9.txt",  "_work\_MD5List9.txt" )
		Assert  InStr( file.Text,  "2016" ) >= 1
		file.Text = Replace( file.Text, "2016", "2015" )
		file = Empty

		'// Test Main
		RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Stamp  _work\1  _work\_MD5List.txt",  ""

		'// Check
		MakeFolderMD5List  "_work\1",  "_work\_MD5List2.txt",  tc.TimeStamp
		AssertFC  "_work\_MD5List2.txt",  "_work\_MD5List9.txt"

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MakeFolderMD5List_BasePathIsList" ) Then

		'// Set up
		del  "_work"
		copy  "Folders\1", "_work"
		copy  "Folders\2", "_work"

		'// Test Main
		MakeFolderMD5List   "_work\1",  "_work\2\_MD5List.txt",  tc.TimeStamp  or  tc.BasePathIsList
		CheckFolderMD5List  "_work\1",  "_work\2\_MD5List.txt",  tc.BasePathIsList

		'// Check
		AssertFC  "_work\2\_MD5List.txt",  "Folders\MD5List_BasePathIsList_2_ans.txt"

		'// Test Main
		MakeFolderMD5List   "_work\1",  "_work\_MD5List.txt",  tc.TimeStamp  or  tc.BasePathIsList
		CheckFolderMD5List  "_work\1",  "_work\_MD5List.txt",  tc.BasePathIsList

		'// Check
		AssertFC  "_work\_MD5List.txt",  "Folders\MD5List_BasePathIsList_ans.txt"

		'// Test Main
		MakeFolderMD5List   "_work\1",  "_work\1\_MD5List.txt",  tc.TimeStamp  or  tc.BasePathIsList
		CheckFolderMD5List  Empty,      "_work\1\_MD5List.txt",  Empty

		'// Check
		AssertFC  "_work\1\_MD5List.txt",  "Folders\MD5List_BasePathIsList_1_ans.txt"

		'// Test Main
		MakeFolderMD5List   Empty,  "_work\1\_MD5List.txt",  tc.TimeStamp  or  tc.BasePathIsList
		CheckFolderMD5List  Empty,  "_work\1\_MD5List.txt",  Empty

		'// Check
		AssertFC  "_work\1\_MD5List.txt",  "Folders\MD5List_BasePathIsList_1_ans.txt"

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If g_is_vbslib_for_fast_user Then
	If section.Start( "T_UpdateFolderMD5List" ) Then

		'// Set up
		del  "_work"

		'// Test Main
		UpdateFolderMD5List  "Folders\3_Source",  _
			"Folders\MD5List_3_Destination.txt",  "_work\MD5ListUpdate.txt",  Empty

		'// Check
		SortFolderMD5List  "_work\MD5ListUpdate.txt",   "_work\MD5ListUpdate.txt",  Empty
		AssertFC  "_work\MD5ListUpdate.txt",  "Folders\MD5List_3_Source.txt"

		'// Clean
		del  "_work"

	End If : section.End_
	End If


	'//===========================================================
	If section.Start( "T_GetColumnOfPathInFolderMD5List" ) Then
		with_ = 60    '// column_of_path_with_time_stamp
		without = 34  '// column_of_path_without_time_stamp

		'// Set up
		del  "_work"
		CreateFile  "_work\Empty.txt", ""

		'// Test Main and Check
		For Each  t  In DicTable( Array( _
			"Path",                    "Answer",   Empty, _
			"Folders\MD5List_ans.txt",  without, _
			"OtherFiles\cache1.txt",    with_, _
			"_work\Empty.txt",          0, _
			"_work\NotFound.txt",       Err ) )

			or_ = ( not IsObject( t("Answer") ) )
			If not or_ Then or_ = ( not  t("Answer") is Err )
			If or_ Then
				Assert  GetColumnOfPathInFolderMD5List( t("Path") ) = t("Answer")
			Else
				echo  vbCRLF+"Next is Error Test"
				If TryStart(e) Then  On Error Resume Next

					dummy = GetColumnOfPathInFolderMD5List( t("Path") )

				If TryEnd Then  On Error GoTo 0
				e.CopyAndClear  e2  '//[out] e2
				echo    e2.desc
				Assert  e2.num <> 0
			End If
		Next

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_SortFolderMD5List" ) Then

		'// Set up
		del  "_work"

		For Each  t  In DicTable( Array( _
			"Case",              "Path",              Empty, _
			"WithoutTimeStamp",  "Folders\MD5List_ans.txt", _
			"WithTimeStamp",     "OtherFiles\cache1.txt", _
			"Unicode",           "Folders\MD5ListUnicode_ans.txt" ) )

			CreateFile  "_work\MD5List.txt",  SortStringLines( ReadFile( _
				t("Path") ), False )
				'// MD5 でソートすることで、相対パスをソートしないようにする

			'// Test Main
			SortFolderMD5List  "_work\MD5List.txt",  "_work\MD5List.txt",  Empty

			'// Check
			AssertFC  "_work\MD5List.txt",  t("Path")
		Next

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5List_SearchPrompt" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Search  Folders\MD5List_ans.txt  "+ _
		"6c14da109e294d1e8155be8aa4b1ce8e  Folders\1\sub2\txt.txt  """"", _
		"_work\_out.txt"

	'// Check
	AssertFC  "_work\_out.txt",  "Folders\MD5List_Search_ans.txt"

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If g_is_vbslib_for_fast_user Then
	If section.Start( "T_MD5List_CopyDiff" ) Then

	For Each  is_prompt  In  Array( False, True )

		'// Set up
		del  "_work"

		'// Test Main : Step 1
		If not is_prompt Then
			CopyDiffByMD5List  "Folders\3_Source",  "_work\Diff", _
				"Folders\MD5List_3_Source.txt",  "Folders\MD5List_3_Destination.txt",  c.AfterDelete
		Else
			RunProg  "cscript  """+ prompt_vbs +"""  MD5List  CopyDiff  "+ _
				"""Folders\3_Source""  ""_work\Diff""  " + _
				"""Folders\MD5List_3_Source.txt""  ""Folders\MD5List_3_Destination.txt""",  ""
		End If

		'// Check
		CheckFolderMD5List  "_work\Diff",  "Folders\MD5List_3_Diff.txt",  Empty

		'// Set up
		copy  "Folders\3_Destination\*",  "_work\Destination"

		'// Test Main : Step 2
		If not is_prompt Then
			CopyDiffByMD5List  "_work\Diff",  "_work\Destination", _
				"Folders\MD5List_3_Source.txt",  "Folders\MD5List_3_Destination.txt",  c.AfterDelete
		Else
			RunProg  "cscript  """+ prompt_vbs +"""  MD5List  CopyDiff  "+ _
				"""_work\Diff""  ""_work\Destination""  " + _
				"""Folders\MD5List_3_Source.txt""  ""Folders\MD5List_3_Destination.txt""",  ""
		End If

		'// Check
		CheckFolderMD5List  "_work\Destination",  "Folders\MD5List_3_Source.txt",  Empty


		'// Set up
		del  "_work\NewMD5List.txt"
		del  "_work\Destination"
		copy  "Folders\3_Destination\*",  "_work\Destination"

		'// Test Main : Update MD5List
		If not is_prompt Then
			CopyDiffByMD5List  "Folders\3_Source",  "_work\Destination", _
				"_work\NewMD5List.txt",  "Folders\MD5List_3_Destination.txt",  c.AfterDelete
		Else
			RunProg  "cscript  """+ prompt_vbs +"""  MD5List  CopyDiff  "+ _
				"""Folders\3_Source""  ""_work\Destination""  " + _
				"""_work\NewMD5List.txt""  ""Folders\MD5List_3_Destination.txt""",  ""
		End If

		'// Check
		SortFolderMD5List  "_work\NewMD5List.txt",  "_work\NewMD5List.txt",  Empty

		AssertFC  "_work\NewMD5List.txt",  "Folders\MD5List_3_Source.txt"
		CheckFolderMD5List  "_work\Destination",  "Folders\MD5List_3_Source.txt",  Empty
	Next

	'//==============
	'// Set up
	del  "_work\Destination"
	copy  "Folders\3_Destination\*",  "_work\Destination"

	'// Test Main : Without "AfterDelete"
	CopyDiffByMD5List  "_work\Diff",  "_work\Destination", _
		"Folders\MD5List_3_Source.txt",  "Folders\MD5List_3_Destination.txt",  Empty

	'// Check
	del  "_work\Answer"
	copy  "Folders\3_Destination\*",  "_work\Answer"
	copy  "Folders\3_Source\*",       "_work\Answer"

	Assert  IsSameFolder( "_work\Destination",  "_work\Answer",  c.EchoV_NotSame )

	'// Clean
	del  "_work"

	End If : section.End_
	End If


	'//===========================================================
	If g_is_vbslib_for_fast_user Then
	If section.Start( "T_MD5List_CopyDiffByMD5Lists" ) Then

	'// Set up
	del  "_work"
	copy_ren  "Folders\1",              "_work\1_Source"
	copy_ren  "Folders\1",              "_work\1_Destination"
	copy_ren  "Folders\3_Source",       "_work\3_Source"
	copy_ren  "Folders\3_Destination",  "_work\3_Destination"
	copy      "Folders\CopyDiff.xml",               "_work\All_sync"
	copy      "Folders\MD5List_ans.txt",            "_work\All_sync"
	copy      "Folders\MD5List_3_Source.txt",       "_work\All_sync"
	copy      "Folders\MD5List_3_Destination.txt",  "_work\All_sync"

	'// Test Main
	CopyDiffByMD5Lists  "_work\All_sync\CopyDiff.xml"

	'// Check
	Assert  IsSameFolder( "_work\3_Source",       "Folders\3_Source",  Empty )
	Assert  IsSameFolder( "_work\3_Destination",  "Folders\3_Source",  Empty )

	'// Clean
	del  "_work"

	End If : section.End_
	End If


	'//===========================================================
	If section.Start( "T_MD5List_LargeFile" ) Then

		'// Set up
		del  "_work"
		mkdir  "_work\large"
		RunProg  "fsutil file createnew ""_work\large\a.bin""  1000000000",  ""

		'// Test Main
		MakeFolderMD5List   "_work\large", "_MD5List.txt", Empty
		CheckFolderMD5List  "_work\large", "_MD5List.txt", Empty

		'// Check
		AssertFC  "_MD5List.txt", "Folders\MD5ListLarge_ans.txt"

		If TryStart(e) Then  On Error Resume Next
			hash = ReadBinaryFile( "_work\large\a.bin" ).MD5
		If TryEnd Then  On Error GoTo 0
		Assert  e.num = &h8007000E  '// Few Memory

		'// Clean
		del  "_work"

	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: T_MD5Cache
'***********************************************************************
Sub  T_MD5Cache( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_MD5Cache_Delete"
	Set w_= AppKey.NewWritable( Array( "_work" ) ).Enable()


	'//===========================================================
	If section.Start( "T_MD5Cache_IsSame" ) Then

		'// Set up
		g_FileHashCache.RemoveAll
		Set cache = new MD5CacheClass
		cache.Scan  "Folders\1", Empty, False
		cache.Save  "_work\cache.txt"

		'// Test Main
		Set cache = new_MD5CacheClass( Empty )
		cache.Load  "_work\cache.txt", "Folders\1"
		Set leafs = EnumerateToLeafPathDictionary( "Folders\1" )

		Assert  cache.IsSameHashValuesOfLeafPathDictionary( leafs, "Folders\1" )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5Cache_LoadSave" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	g_FileHashCache.RemoveAll
	Set cache = new_MD5CacheClass( get_MD5CacheConst().TimeStamp )
	cache.Scan  "Folders\1", Empty, False
	cache.Save  "_work\cache.txt"

	Set cache = new MD5CacheClass
	cache.Load  "_work\cache.txt", "Folders\1"
	cache.Save  "_work\cache2.txt"

	'// Check
	AssertFC  "_work\cache.txt", "OtherFiles\cache1_answer.txt"
	AssertFC  "_work\cache2.txt", "_work\cache.txt"

	'// Test Main & Check
	hash = cache.GetHashFromStepPath( "txt.txt" )
	Assert  cache.GetFirstStepPathFromHash( hash ) = "txt.txt"
	Assert  IsEmpty( cache.GetHashFromStepPath( "Unknown" ) )
	Assert  IsEmpty( cache.GetFirstStepPathFromHash( "Unknown" ) )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5Cache_UpdateScanAndSave" ) Then
'//■ TODO: Coding of ***********
'// set TimeStamp option
	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5Cache_Fragment" ) Then

	'// Set up
	del  "_work"
	copy  "Folders\1\*", "_work\copy"
	CreateFile  "_work\copy\new.txt", "new"
	CreateFile  "_work\copy\new2.txt", "new"
	CreateFile  "_work\copy\sub1\txt.txt", "modified"
	del         "_work\copy\sub2\bin.bin"
	copy_ren    "_work\copy\txt.txt", "_work\copy\txt2.txt"

	copy  "_work\copy\*", "_work\copy_back_up"

	g_FileHashCache.RemoveAll


	'// Test Main
	Set copied_cache = new_MD5CacheClass( get_MD5CacheConst().TimeStamp )
	copied_cache.Scan  "Folders\1", Empty, False
	copied_cache.Save  "_work\Folders_1_Hash.txt"

	Set cache = new_MD5CacheClass( get_MD5CacheConst().TimeStamp )
	cache.Scan  "_work\copy", Empty, False
	cache.Save  Empty
	cache.Save  "_work\cache2.txt"

	cache.Fragment  Empty, copied_cache, True

	'// Check
	AssertFC  "_work\copy\_HashCache.txt", "OtherFiles\cache2_answer.txt"
	Assert  not exist( "_work\copy\bin.bin" )
	Assert  not exist( "_work\copy\txt.txt" )
	Assert  not exist( "_work\copy\txt.txt" )
	Assert  not exist( "_work\copy\sub1\bin.bin" )
	Assert      exist( "_work\copy\sub1\txt.txt" )
	Assert  not exist( "_work\copy\sub2\txt.txt" )
	Assert      exist( "_work\copy\new.txt" )

	'// Test Main & Check
	cache.Verify  Empty

	'// Test Main
	cache.Defragment  Empty, copied_cache
	del  "_work\copy\_HashCache.txt"

	'// Check
	Assert  fc( "_work\copy", "_work\copy_back_up" )

	'// Test Main & Check
	cache.Verify  Empty

	'// Set up
	del  "_work\copy\new.txt"
	del  "_work\copy\new2.txt"
	del  "_work\copy\txt2.txt"

	'// Test Main
	cache.SetHashValue  "new.txt", Empty
	cache.SetHashValue  "new2.txt", Empty
	cache.SetHashValue  "sub1\txt.txt", ReadBinaryFile( "Folders\1\sub1\txt.txt" ).MD5
	cache.SetHashValue  "sub2\bin.bin", ReadBinaryFile( "Folders\1\sub2\bin.bin" ).MD5
	cache.SetHashValue  "txt2.txt", Empty
	cache.Defragment  Empty, copied_cache

	'// Check
	Assert  fc( "_work\copy", "Folders\1" )


	'// Set up
	Set rep = StartReplace( "_work\Folders_1_Hash.txt",  "_work\Folders_1_PartHash.txt",  True )
	Do Until rep.r.AtEndOfStream
		SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf
		If InStr( line, "bin.bin" ) >= 1 Then _
			rep.w.WriteLine  line + cr_lf
	Loop
	rep.Finish
	rep = Empty

	'// Test Main
	Set cache = new MD5CacheClass
	cache.Load  "_work\Folders_1_PartHash.txt", "_work\defragmented"
	Set copied_cache = new MD5CacheClass
	copied_cache.Load  "_work\Folders_1_Hash.txt", "_work\copy"
	cache.Defragment  Empty, copied_cache

	cache.TargetPaths = "_work\defragmented2"
	cache.Defragment  Empty, copied_cache

	'// Check
	Set files = ArrayFromWildcard2( "Folders\1\*\bin.bin" )
	For Each  step_path  In  files.FilePaths
		copy_ren  GetFullPath( "Folders\1\"+ step_path, Empty ), _
			GetFullPath( "_work\defragmented_answer\"+ step_path, Empty )
	Next
	Assert  fc( "_work\defragmented",  "_work\defragmented_answer" )
	Assert  fc( "_work\defragmented2", "_work\defragmented_answer" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5Cache_Delete" ) Then

	'// Set up
	del  "_work"
	copy  "Folders\1\*", "_work\copy"
	CreateFile  "_work\copy\new.txt", "new"
	CreateFile  "_work\copy\new2.txt", "new"
	CreateFile  "_work\copy\sub1\txt.txt", "modified"
	del         "_work\copy\sub2\bin.bin"
	copy_ren    "_work\copy\txt.txt", "_work\copy\txt2.txt"

	copy  "_work\copy\*", "_work\copy_back_up"
	copy  "_work\copy\*", "_work\deleting"

	g_FileHashCache.RemoveAll

	Set copied_cache = new MD5CacheClass
	copied_cache.Scan  "Folders\1", Empty, False
	copied_cache.Save  "_work\Folders_1_Hash.txt"

	Set cache = new MD5CacheClass
	cache.Scan  "_work\copy", Empty, False
	cache.Save  Empty

	cache.Fragment  Empty, copied_cache, True

	Set copied_cache = new MD5CacheClass
	Set paths = new PathDictionaryClass
		paths.BasePath = "_work"
		Set paths( "copy" ) = Nothing
		Set paths( "deleting" ) = Nothing
	copied_cache.Scan  paths, Empty, False
	copied_cache.Save  "_work\work_Hash.txt"


	'// Test Main
	copied_cache.Delete  "_work\deleting", Array( cache )


	'// Check
	For Each  key  In  copied_cache.DictionaryFromStepPath.Keys
		Assert  StrCompHeadOf( key, "_work\deleting", Empty ) <> 0
	Next
	For Each  an_array  In  copied_cache.DictionaryFromHash.Items
		For Each  file_attribute  In  an_array.Items
			Assert  StrCompHeadOf( file_attribute.StepPath, "_work\deleting", Empty ) <> 0
		Next
	Next

	copy_ren  "_work\copy\txt2.txt", "_work\copy\txt.txt"
	del  "_work\copy\_HashCache.txt"
	Assert  fc( "_work\copy", "_work\copy_back_up" )


	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MD5Cache_Check" ) Then

	'// Set up
	copy  "Folders\1\*", "_work\all"
	copy  "Folders\1\*", "_work\all\part"
	CreateFile  "_work\all\part\_FullSet.txt", "Test of Skip File"
	Set cache = new MD5CacheClass
	cache.DefaultHashFileName = "_FullSet.txt"
	cache.Scan  "_work\all\part", Empty, False
	del  "_work\all\part"
	cache.Save  "_work\all\part\_FullSet.txt"
	copy  "Folders\1\txt.txt", "_work\all\part"
	cache = Empty

	Set cache = new MD5CacheClass
	cache.Scan  "_work\all", Empty, False
	cache.Save  "_work\all\_HashCache.txt"
	cache = Empty

	base_path = GetFullPath( "_work\all\part", Empty )


	'// Check set up
	text = ReadFile( "_work\all\part\_FullSet.txt" )
	Assert  InStr( text, "txt.txt" ) >= 1

	'// Test Main & Check : "part\bin.bin" is same as "sub1\bin.bin".
	g_FileHashCache.RemoveAll
	Set cache = new MD5CacheClass
	cache.Load  "_work\all\_HashCache.txt", Empty
	cache.CheckFileExistsAnywhereInFileList  "_work\all\part\*\_FullSet.txt"
		'// Check is no error

	'// Set up
	g_FileHashCache.RemoveAll
	del  "_work\all\sub1\txt.txt"
	del  "_work\all\sub2\txt.txt"

	'// Error Handling Test : same file as "sub1\txt.txt" is not exist at anywhere.
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		cache.CheckFileExistsAnywhereInFileList  "_work\all\part\_FullSet.txt"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	path = LoadXML( e2.desc, g_VBS_Lib.StringData ).getAttribute( "file_list" )
	text = ReadFile( path )
	answer = _
		"Not Found Following Files."+ vbCRLF + _
		""+ vbCRLF + _
		"HashFile:  "+ base_path +"\_FullSet.txt" + vbCRLF + _
		""+ vbCRLF + _
		"6c14da109e294d1e8155be8aa4b1ce8e "+ base_path +"\sub1\txt.txt"+ vbCRLF + _
		"e53a0a2978c28872a4505bdb51db06dc "+ base_path +"\sub2\txt.txt"+ vbCRLF
	Assert  text = answer
	Assert  e2.num <> 0

	'// Set up
	g_FileHashCache.RemoveAll
	copy  "Folders\1\*", "_work\all"

	'// Test Main & Check
	del  "_work\all\txt.txt"  '// array(0)
	cache.CheckFileExistsAnywhereInFileList  "_work\all\part\_FullSet.txt"
		'// Check is no error

	'// Test Main & Check
	move  "_work\all\part\txt.txt", "_work\all"  '// array(0) was changed
	cache.CheckFileExistsAnywhereInFileList  "_work\all\part\_FullSet.txt"
		'// Check is no error

	'// Set up
	g_FileHashCache.RemoveAll
	del  "_work\all\txt.txt"

	'// Error Handling Test : same file as "txt.txt" is not exist at anywhere.
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		cache.CheckFileExistsAnywhereInFileList  "_work\all\part\_FullSet.txt"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	path = LoadXML( e2.desc, g_VBS_Lib.StringData ).getAttribute( "file_list" )
	text = ReadFile( path )
	answer = _
		"Not Found Following Files."+ vbCRLF + _
		""+ vbCRLF + _
		"HashFile:  "+ base_path +"\_FullSet.txt" + vbCRLF + _
		""+ vbCRLF + _
		"202cb962ac59075b964b07152d234b70 "+ base_path +"\txt.txt"+ vbCRLF
	Assert  text = answer
	Assert  e2.num <> 0

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_OpenForDefragment
'***********************************************************************
Sub  T_OpenForDefragment( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_OpenForDefragment_PromptSubFolders"
	Set w_= AppKey.NewWritable( Array( "_work",  "Folders\1\Empty" ) ).Enable()
	Set c = g_VBS_Lib
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )


	Set defrag = OpenForDefragment( "Folders\MD5List_ans.txt", Empty )

	'//===========================================================
	If section.Start( "T_OpenForDefragment_1" ) Then

	'// Test Main : GetStepPath
	For Each  t  In DicTable( Array( _
		"Hash",                             "Path",  Empty, _
		"f6933eea499a37a7f9b6f8d675bfb908", "bin.bin", _
		"e3cafd5c08bd342030e4083a7fe6b3fb", "sub2\bin.bin", _
		"a5e064892e90bdbc0f85d8fe14f6828a", "sub1\bin.bin", _
		"00000000000000000000000000000000", Empty, _
		"202cb962ac59075b964b07152d234b70", "txt.txt" ) )

		Assert  defrag.GetStepPath( t("Hash"), Empty ) = t("Path")
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_OpenForDefragment_CopyFolder" ) Then

	For Each  out_path  In  Array( "_work\out", "_work\out2" )

		'// Set up
		del  "_work"
		copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\_FullSet.txt"

		'// Test Main
		defrag.CopyFolder  "Folders\1",  "_work\out",  out_path,  Empty

		'// Check if it is the same as "_work\out\_FullSet.txt"
		copy_ren  "Folders\1\bin.bin",      "_work\answer\bin2.bin"
		copy_ren  "Folders\1\sub1\bin.bin", "_work\answer\sub12\bin2.bin"
		copy_ren  "Folders\1\sub1\txt.txt", "_work\answer\sub12\txt2.txt"
		copy_ren  "Folders\1\txt.txt",      "_work\answer\txt2.txt"
		del  "_work\out\_FullSet.txt"
		Assert  IsSameFolder( out_path,  "_work\answer",  Empty )

		'// Clean
		del  "_work"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_OpenForDefragment_Fragment" ) Then

	'// Set up
	del  "_work"
	copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\_FullSet.txt"
	copy_ren  "Folders\1\sub2\bin.bin",     "_work\out\sub12\bin2.bin"
	copy_ren  "Folders\1\sub2\txt.txt",     "_work\out\txt2.txt"
	SetReadOnlyAttribute  "Folders\1\bin.bin", True


	'// Test Main
	defrag.CopyFolder  "Folders\1",  "_work\out",  "_work\out",  c.NotExistOnly   or  c.ToNotReadOnly


	'// Check
	del  "_work\out\_FullSet.txt"

	CheckFolderMD5List  "_work\out", "Folders\MD5List_Part2_Overwrite.txt", Empty

	Assert IsBitNotSet( g_fs.GetFile( "_work\out\bin2.bin" ).Attributes,  ReadOnly )
		'// bin2.bin のコピー元は、bin.bin


	'// Set up
	copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\_FullSet.txt"


	'// Test Main
	defrag.Fragment  "Folders\1",  "_work\out",  Empty


	'// Check
	del  "_work\out\_FullSet.txt"

	CheckFolderMD5List  "_work\out", "Folders\MD5List_Part2_Fragment.txt", Empty


	'// Clean
	SetReadOnlyAttribute  "Folders\1\bin.bin", False
	del  "_work"

	End If : section.End_


	'//===========================================================
	For Each  case_name  In  Array( "", "_T" )
	If section.Start( "T_OpenForDefragment_CopyFolder_ExistOnly"+ case_name ) Then

	'// Set up
	del  "_work"
	copy_ren  "Folders\MD5List_ans"+ case_name +".txt",  "_work\Source\_FullSet.txt"
	Set defrag_1 = OpenForDefragment( "Folders\MD5List_Part"+ case_name +".txt",  Empty )
	Set defrag_2 = OpenForDefragment( "Folders\MD5List_ans"+  case_name +".txt",  Empty )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		defrag_1.CopyFolder  "Folders\1",  "_work\Source",  "_work\Destiation",  Empty

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	'// Test Main : CopyFolder
	defrag_1.CopyFolder  "Folders\N",  "_work\Source",  "_work\Destiation",  c.ExistOnly
		'// Check point is no error.

	defrag_1.CopyFolder  "Folders\1",  "_work\Source",  "_work\Destiation",  c.ExistOnly
	defrag_2.CopyFolder  "Folders\1",  "_work\Source",  "_work\Destiation",  c.NotExistOnly

	'// Check
	CheckFolderMD5List  "_work\Destiation",  "Folders\MD5List_ans"+ case_name +".txt", Empty

	'// Set up
	del  "_work\Source\bin\bin"
	OpenForReplace( "Folders\MD5List_ans"+ case_name +".txt",  "_work\MD5List.txt" _
		).Replace  "f6933eea499a37a7f9b6f8d675bfb908 bin.bin"+ vbCRLF, _
		""  '// Delete hash value of bin.bin

	Set defrag_3 = OpenForDefragment( "_work\MD5List.txt",  Empty )

	'// Test Main : コピー元がないけど、コピーしないから大丈夫なケース
	defrag_3.CopyFolder  "Folders\1",  "_work\Source",  "_work\Destiation",  c.NotExistOnly

	'// Check
	'// No error

	'// Clean
	defrag_3 = Empty
	del  "_work"

	End If : section.End_
	Next


	'//===========================================================
	If section.Start( "T_OpenForDefragment_CopyCallback" ) Then

	'// Set up
	del  "_work"
	copy_ren  "Folders\MD5List_ans_T.txt",  "_work\Source\_FullSet.txt"  '// With time stamp

	Set defrag = OpenForDefragment( "Folders\MD5List_ans.txt",  Empty )  '// Without time stamp
	Set log_stream = new StringStream
	Set option_ = new OpenForDefragmentOptionClass
	Set option_.CopyOneFileFunction = GetRef( "T_OpenForDefragment_copyCallback" )
	Set option_.Delegate = log_stream


	'// Test Main
	defrag.CopyFolder  "Folders\1",  "_work\Source",  "_work\Destiation",  option_


	'// Check
	log_text = log_stream.ReadAll()
    log_text = SortStringLines( log_text,  True )

	Set d = new LazyDictionaryClass
	d("${s}") = GetFullPath( "Folders\1",  Empty )  '// There are not file body in "_work\Source".
	d("${d}") = GetFullPath( "_work\Destiation",  Empty )
	answer_text = d( _
		"2016-02-20T11:01:04+09:00, ${s}\bin.bin, ${d}\bin.bin"+ vbCRLF + _
		"2016-02-20T11:01:04+09:00, ${s}\sub1\bin.bin, ${d}\sub1\bin.bin"+ vbCRLF + _
		"2016-02-20T11:01:04+09:00, ${s}\sub1\txt.txt, ${d}\sub1\txt.txt"+ vbCRLF + _
		"2016-02-20T11:01:04+09:00, ${s}\sub2\bin.bin, ${d}\sub2\bin.bin"+ vbCRLF + _
		"2016-02-20T11:01:04+09:00, ${s}\sub2\txt.txt, ${d}\sub2\txt.txt"+ vbCRLF + _
		"2016-02-20T11:01:04+09:00, ${s}\txt.txt, ${d}\txt.txt"+ vbCRLF )
    answer_text = SortStringLines( answer_text,  True )

	Assert  log_text = answer_text


	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_OpenForDefragment_SubFolders" ) Then

	For Each  out_path  In  Array( "_work\out", "_work\out2" )

		'// Set up
		del  "_work"
		copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\1\_FullSet.txt"
		copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\2\_FullSet.txt"
		echo  ""

		'// Test Main
		defrag.CopyFolder  "Folders\1",  "_work\out",  out_path,  c.SubFolder

		'// Check
		echo  ""
		copy_ren  "Folders\1\bin.bin",      "_work\answer\bin2.bin"
		copy_ren  "Folders\1\sub1\bin.bin", "_work\answer\sub12\bin2.bin"
		copy_ren  "Folders\1\sub1\txt.txt", "_work\answer\sub12\txt2.txt"
		copy_ren  "Folders\1\txt.txt",      "_work\answer\txt2.txt"
		del  "_work\out\1\_FullSet.txt"
		del  "_work\out\2\_FullSet.txt"
		Assert  IsSameFolder( out_path +"\1",  "_work\answer",  Empty )
		Assert  IsSameFolder( out_path +"\2",  "_work\answer",  Empty )

		'// Set up
		copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\1\_FullSet.txt"
		copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\2\_FullSet.txt"
		copy      "_work\answer\*",  "_work\out\1"
		copy      "_work\answer\*",  "_work\out\2"
		echo  ""

		'// Test Main
		defrag.Fragment  "Folders\1",  "_work\out",  c.SubFolder

		'// Check
		echo  ""
		del  "_work\out\1\_FullSet.txt"
		del  "_work\out\2\_FullSet.txt"
		Assert  IsEmptyFolder( "_work\out\1" )
		Assert  IsEmptyFolder( "_work\out\2" )

		'// Clean
		del  "_work"
	Next

	End If : section.End_


	'//===========================================================

	For Each  is_overwrite  In  Array( False, True, Empty )
	For Each  is_full_set_file  In  Array( False, True )
	If section.Start( "T_OpenForDefragment_Append_"+ GetEchoStr( is_overwrite ) +"_"+ _
			GetEchoStr( is_full_set_file ) ) Then

		'// Set up
		del  "_work"
		copy  "Folders\1\*",    "_work\1"
		copy  "Folders\2\2\*",  "_work\1\2"
		If not is_full_set_file Then _
			del  "_work\1\2\_FullSet.txt"
		copy_ren  "Folders\MD5List_ans.txt",  "_work\MD5List.txt"
		SetReadOnlyAttribute  "_work\MD5List.txt", False

		If IsEmpty( is_overwrite ) Then
			output_path = Empty
		ElseIf is_overwrite Then
			output_path = "_work\MD5List.txt"
		Else
			output_path = "_work\MD5List_1_2.txt"
		End If

		Set defrag = OpenForDefragment( "_work\MD5List.txt",  Empty )

		'// Test Main
		defrag.Append  output_path,  "_work\1",  "_work\1\2",  Empty

		If IsEmpty( output_path ) Then

			'// Check
			Assert  defrag.GetStepPath( "e6d8dd4249d4d5b0fcea92193b02d4e1", Empty ) = "2\sub3\new.bin"

			'// Test Main
			output_path = "_work\MD5List.txt"
			defrag.Save  output_path
		End If

		'// Check
		If not IsEmpty( output_path ) Then
			AssertFC  output_path,  "Folders\MD5List_Append_ans.txt"
			If IsEmpty( output_path )  or  output_path <> "_work\MD5List.txt" Then _
				AssertFC  "_work\MD5List.txt",  "Folders\MD5List_ans.txt"
		End If


		If is_overwrite  and  is_full_set_file Then

			'// Test Case: Run from prompt

			'// Set up
			copy_ren  "Folders\MD5List_ans.txt",  "_work\MD5List.txt"
			Assert  not exist( "_work\1\2\txt.txt" )  '// _FullSet.txt にある

			'// Test Main
			RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Append  _work\1\2  _work\MD5List.txt  _work\1",  ""

			'// Check
			AssertFC  "_work\MD5List.txt",  "Folders\MD5List_Append_ans.txt"


			'// Test Case: Not updated

			'// Set up
			SetReadOnlyAttribute  g_fs.GetFile( "_work\MD5List.txt" ), True

			'// Test Main & Check : No Error
			Set defrag = OpenForDefragment( "_work\MD5List.txt",  Empty )
			defrag.Append  "_work\MD5List.txt",  "_work\1",  "_work\1\2",  Empty

			'// Test Main & Check : No Error
			Set defrag = OpenForDefragment( "_work\MD5List.txt",  Empty )
			defrag.Append  Empty,  "_work\1",  "_work\1\2",  Empty
			defrag.Save  "_work\MD5List.txt"
		End If

		'// Clean
		defrag = Empty
		del  "_work"

	End If : section.End_
	Next
	Next


	'//===========================================================
	For Each  is_unicode_step_1  In  Array( False, True )
	For Each  is_unicode_step_2  In  Array( False, True )
		sub_names = Array( "A", "U" )  '// Ascii or Unicode
		sub_name = sub_names(( is_unicode_step_1 )and 1) + sub_names(( is_unicode_step_2 )and 1)
	If section.Start( "T_OpenForDefragment_AppendUnicode_"+ sub_name ) Then

		'// Set up
		del  "_work"
		copy  "Folders\1\*", "_work\1"
		copy  "Folders\2\2\*",  "_work\1\2"
		If not is_unicode_step_1 Then
			copy_ren  "Folders\MD5List_ans.txt",  "_work\MD5List.txt"
		Else
			CreateFile  "_work\1\あ.txt", "あ"
			copy_ren  "Folders\MD5ListUnicode_ans.txt",  "_work\MD5List.txt"
		End If
		If is_unicode_step_2 Then _
			CreateFile  "_work\1\2\新.txt", "新"
		del  "_work\1\2\_FullSet.txt"

		Set defrag = OpenForDefragment( "_work\MD5List.txt",  Empty )


		'// Test Main
		defrag.Append  "_work\MD5List.txt",  "_work\1",  "_work\1\2",  Empty


		'// Check
		answer = ReadFile( "Folders\MD5List_AppendUnicode_"+ sub_name +"_ans.txt" )
			Assert  InStr( answer, " 2\sub3\new.bin" ) >= 1  '// New MD5 file
			Assert  InStr( answer, " 2\txt.txt" ) = 0        '// Already MD5 exists
		If is_unicode_step_1 Then _
			Assert  InStr( answer, " あ.txt" ) >= 1
		If is_unicode_step_2 Then _
			Assert  InStr( answer, " 2\新.txt" ) >= 1

		Assert  IsSameBinaryFile( "_work\MD5List.txt", _
			"Folders\MD5List_AppendUnicode_"+ sub_name +"_ans.txt",  Empty )

		'// Clean
		defrag = Empty
		del  "_work"

	End If : section.End_
	Next
	Next


	'//===========================================================
	If section.Start( "T_OpenForDefragment_GetExistingStepPath" ) Then

		'// Set up
		Set defrag = OpenForDefragment( "Folders\MD5List_PartDup.txt",  Empty )
		base_path = GetFullPath( "Folders\1", Empty )
		mkdir  "Folders\1\Empty"

		'// Test Main & Check
		For Each  t  In DicTable( Array( _
			"Hash",                             "Path",  Empty, _
			"f6933eea499a37a7f9b6f8d675bfb908", "bin.bin", _
			"11111111111111111111111111111111", Empty, _
			"00000000000000000000000000000000", "Empty", _
			"202cb962ac59075b964b07152d234b70", "txt.txt", _
			"00000000000000000000000000000000", "Empty" ) )

			If IsEmpty( t("Path") ) Then
				Assert  IsEmpty( defrag.GetStepPath( t("Hash"),  base_path ) )
			Else
				Assert  defrag.GetStepPath( t("Hash"),  base_path ) = t("Path")
			End If
		Next

		'// Clean
		del  "Folders\1\Empty"
	End If : section.End_


	'//===========================================================
	If section.Start( "T_OpenForDefragment_ErrorInCopy" ) Then

		'// Case of Not found hash value
		'// Set up
		Set defrag = OpenForDefragment( "Folders\MD5List_ans.txt", Empty )
		del  "_work"
		OpenForReplace( "Folders\MD5List_Part2.txt",  "_work\out\_FullSet.txt" ).Replace _
			"6c14da109e294d1e8155be8aa4b1ce8e sub12\txt2.txt", _
			"55555555555555555555555555555555 sub12\txt2.txt"

		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			defrag.CopyFolder  "Folders\1",  "_work\out",  "_work\out2",  Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"
		echo    e2.desc
		Assert  InStr( e2.desc, "Not found hash value" ) >= 1
		Assert  InStr( e2.desc, "55555555555555555555555555555555" ) >= 1
		Assert  InStr( e2.desc, "sub12\txt2.txt" ) >= 1
		Assert  e2.num <> 0


		'// "_work\out" にファイルがある場合、defrag に該当するハッシュ値がなくてもよい

		'// Set up
		copy_ren  "Folders\1\sub1\txt.txt",  "_work\out\sub12\txt2.txt"

		'// Test Main
		defrag.CopyFolder  "Folders\1",  "_work\out",  "_work\out2",  Empty

		'// Check
		AssertExist  "_work\out2\sub12\txt2.txt"


		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			defrag.CopyFolder  "_work",  "_work\out",  "_work\out2",  Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"
		echo    e2.desc
		Assert  InStr( e2.desc, "Not found the file written in the hash list" ) >= 1
		Assert  InStr( e2.desc, "_work\bin.bin" ) >= 1
		Assert  InStr( e2.desc, "_work\out2\bin2.bin" ) >= 1
		Assert  e2.num <> 0

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If g_is_vbslib_for_fast_user Then
	For Each  is_pre_download  In  Array( False, True )
	If section.Start( "T_OpenForDefragment_Unzip_"+ GetEchoStr( is_pre_download ) ) Then

		'// Set up
		cache_path = GetTempPath( "Fragments" )
		del  "_work"
		del  cache_path
		copy  "Folders\7\*",  "_work"

		'// Test Main
		Set defrag = OpenForDefragment( "_work\MD5List.txt",  Empty )
		If is_pre_download Then _
			defrag.DownloadStart  "_work",  "_work\Source",  "_work\Destination",  Empty
		defrag.CopyFolder  "_work",  "_work\Source",  "_work\Destination",  Empty
		defrag = Empty  '// Close MD5 list file

		'// Check
		Assert  IsSameFolder( "_work\Destination", "Folders\7\DestinationAnswer", Empty )
		AssertExist  cache_path +"\36\36e955c065f66df5facd6226c28fc3b2.7z"
		AssertExist  cache_path +"\36\36e955c065f66df5facd6226c28fc3b2"
		AssertExist  cache_path +"\00\00c19ba1749547fa1fbc88c7beb3feb6.7z"
		AssertExist  cache_path +"\00\00c19ba1749547fa1fbc88c7beb3feb6"

		'// Clean
		del  "_work"
		del  cache_path
	End If : section.End_
	Next
	End If


	'//===========================================================
	If section.Start( "T_OpenForDefragment_Prompt" ) Then

	'// Set up
	del  "_work"
	copy_ren  "Folders\1",                  "_work\Masters"
	copy_ren  "Folders\MD5List_ans.txt",    "_work\Masters\MD5List.txt"
	copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\_FullSet.txt"

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Defragment  _work\out  _work\Masters\MD5List.txt  """"",  ""

	'// Check
	CheckFolderMD5List  "_work\out",  "_work\out\_FullSet.txt",  Empty

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Fragment  _work\out  _work\Masters\MD5List.txt  """"",  ""

	'// Check
	del  "_work\out\_FullSet.txt"
	Assert  IsEmptyFolder( "_work\out" )

	'// Set up
	copy_ren  "Folders\MD5List_Part2.txt",  "_work\out\_FullSet.txt"
	RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Defragment  _work\out  _work\Masters\MD5List.txt  """"",  ""
	del  "_work\out\_FullSet.txt"

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Fragment  _work\out  Make  _work\Masters\MD5List.txt  """"",  ""

	'// Check
	del  "_work\out\_FullSet.txt"
	Assert  IsEmptyFolder( "_work\out" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_OpenForDefragment_PromptSubFolders" ) Then

	'// Set up
	del  "_work"
	copy_ren  "Folders\1",                  "_work\Masters"
	copy_ren  "Folders\MD5List_ans.txt",    "_work\Masters\MD5List.txt"
	copy_ren  "Folders\MD5List_Part2.txt",  "_work\out1\_FullSet.txt"
	copy_ren  "Folders\MD5List_Part2.txt",  "_work\out2\_FullSet.txt"

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Defragment  _work  Nest  _work\Masters\MD5List.txt  """"",  ""

	'// Check
	CheckFolderMD5List  "_work\out1",  "_work\out1\_FullSet.txt",  Empty
	CheckFolderMD5List  "_work\out2",  "_work\out2\_FullSet.txt",  Empty

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  MD5List  Fragment  _work  Nest  _work\Masters\MD5List.txt  """"",  ""

	'// Check
	del  "_work\out1\_FullSet.txt"
	del  "_work\out2\_FullSet.txt"
	Assert  IsEmptyFolder( "_work\out1" )
	Assert  IsEmptyFolder( "_work\out2" )

	'// Clean
	del  "_work"

	End If : section.End_


	'// Check
	For i=0 To UBound( g_Coverage_GetRelativePath )
		Assert  g_Coverage_GetRelativePath(i)
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_OpenForDefragment_copyCallback
'***********************************************************************
Sub  T_OpenForDefragment_copyCallback( in_SourcePath,  in_DestinationPath,  ref_Option )
	AssertD_TypeName  ref_Option,  "OpenForDefragmentOptionClass"
	Set log_stream = ref_Option.Delegate
	time_stamp = ref_Option.CurrentTimeStampInFullSetFile
	If not IsEmpty( time_stamp ) Then _
		time_stamp = time_stamp +", "

	log_stream.WriteLine  time_stamp + _
		GetFullPath( in_SourcePath,  Empty ) +", "+ _
		GetFullPath( in_DestinationPath,  Empty )

	'// For caller
	CreateFile  in_DestinationPath,  ""
End Sub


 
'***********************************************************************
'* Function: T_SearchStringTemplate
'***********************************************************************
Sub  T_SearchStringTemplate( Opt, AppKey )

	g_Vers("ExpandWildcard_Sort") = True


	'// Test Main
	founds = SearchStringTemplate( "TemplateTarget\1_before", "\*\*/", _
		"/***********" +vbCRLF+ _
		"((( ${FunctionName} ))$\{FunctionName}$\\)" +vbCRLF+ _
		"************/" +vbCRLF, _
		Empty )


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


 
'***********************************************************************
'* Function: T_ReplaceStringTemplate
'***********************************************************************
Sub  T_ReplaceStringTemplate( Opt, AppKey )
	Set ds = new CurDirStack
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_ReplaceStringTemplate_11"


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
		3,      "c.txt", "c_keyword.txt", "c_template.txt", "c_template_after.txt", "c_after.txt", _
		11,     "a.txt", "no_keyword.txt","a_template.txt", "a_template_after.txt", "a_after.txt",  _
		_
		91,     "a_not_match.txt", "no_keyword.txt", "a_template.txt", "a_template_after.txt", _
			"a_not_match.txt"  ) )

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


	If section.Start( "T_ReplaceStringTemplate_NoVariable" ) Then

	'// Set up
	del  "_work"
	copy  "TemplateTarget\1_before\*", "_work"

	'// Test Main
	ReplaceStringTemplate  "_work",  "<<< FuncD >>>", _
		"<<< FuncD >>>" +vbCRLF, _
		_
		"((( FuncD )))" +vbCRLF, _
		Empty

	'// Check
	text = ReadFile( "_work\00.c" )
	answer = "/*=========="+ vbCRLF +_
		"((( FuncD )))"+ vbCRLF +_
		"===========*/"+ vbCRLF
	AssertString  text, answer, Empty

	'// Clean
	del  "_work"

	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetLineNumOfTemplateDifference
'***********************************************************************
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

'// vbslib include is provided under 3-clause BSD license.
'// Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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

 
