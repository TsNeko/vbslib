Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_GetLineCount",_
			"2","T_LineNumFromTextPosition" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_GetLineCount] >>> 
'********************************************************************************
Sub  T_GetLineCount( Opt, AppKey )
	Set c = g_VBS_Lib

	T_GetLineCount_Sub  2, Empty,  "a" +vbCRLF+ "b"
	T_GetLineCount_Sub  0, Empty,  ""
	T_GetLineCount_Sub  1, Empty,  "a"
	T_GetLineCount_Sub  1, Empty,  vbCRLF
	T_GetLineCount_Sub  1, Empty,  "a" +vbCRLF
	T_GetLineCount_Sub  2, Empty,  "a" +vbCRLF+ "b" +vbCRLF
	T_GetLineCount_Sub  2, Empty,  "a" +vbLF+   "b" +vbLF

	'// Case of "c.NoRound"
	T_GetLineCount_Sub  2,   c.NoRound,  "a" +vbCRLF+ "b"
	T_GetLineCount_Sub  0.5, c.NoRound,  ""
	T_GetLineCount_Sub  1,   c.NoRound,  "a"
	T_GetLineCount_Sub  1.5, c.NoRound,  vbCRLF
	T_GetLineCount_Sub  1.5, c.NoRound,  "a" +vbCRLF
	T_GetLineCount_Sub  2.5, c.NoRound,  "a" +vbCRLF+ "b" +vbCRLF

	'// Case of LF
	T_GetLineCount_Sub  2,   c.NoRound,  "a" +vbLF+ "b"
	T_GetLineCount_Sub  2.5, c.NoRound,  "a" +vbLF+ "b" +vbLF

	Pass
End Sub


Sub  T_GetLineCount_Sub( CountAnswer, RoundWay, Text )
	count = GetLineCount( Text, RoundWay )
	Assert  count = CountAnswer
End Sub


 
'********************************************************************************
'  <<< [T_LineNumFromTextPosition] >>> 
'********************************************************************************
Sub  T_LineNumFromTextPosition( Opt, AppKey )
	Set counter = new LineNumFromTextPositionClass
	counter.Text = _
		"a"+ vbCRLF + _
		"bcd"+ vbCRLF + _
		"e"+ vbCRLF + _
		"f"+ vbCRLF + _
		"gih"+ vbCRLF

	Assert  counter.Position = 1
	Assert  counter.LineNum  = 1

	Assert  counter.GetNextLineNum( 1 )  = 1  '// "a"
	Assert  counter.GetNextLineNum( 3 )  = 1  '// vbLF
	Assert  counter.GetNextLineNum( 4 )  = 2  '// "b",  部分文字列が vbLF から始まるとき
	Assert  counter.Position = 4
	Assert  counter.LineNum  = 2
	Assert  counter.GetNextLineNum( 9 )  = 3  '// "e",  部分文字列の最終行は、文字なし
	Assert  counter.GetNextLineNum( 13 ) = 4  '// vbCR, 部分文字列の最終行は、文字あり
	Assert  counter.GetNextLineNum( 19 ) = 5  '// vbLF
	Assert  counter.GetNextLineNum( 20 ) = 6  '// 最後の次
	Assert  counter.Position = 20
	Assert  counter.LineNum  = 6


	counter.Text = _
		"a"+ vbCRLF + _
		"b"+ vbCRLF + _
		"cde"
	Assert  counter.Position = 1
	Assert  counter.LineNum  = 1
	Assert  counter.GetNextLineNum( 4 )  = 2  '// "b"
	Assert  counter.GetNextLineNum( 6 )  = 2  '// vbLF
	Assert  counter.GetNextLineNum( 7 )  = 3  '// "c"
	Assert  counter.GetNextLineNum( 10 ) = 3  '// 最後の次


	Set counter = new LineNumFromTextPositionClass
	counter.Text = _
		"a"+ vbCRLF + _
		"bcd"+ vbCRLF + _
		"e"+ vbCRLF + _
		"f"+ vbCRLF + _
		"gih"+ vbCRLF

	Assert  counter.GetNextLineNum( 4 ) = 2  '// "b"

	counter.ReplaceTextAtHere _
		"bcdX"+ vbCRLF + _
		"e"+ vbCRLF + _
		"f"+ vbCRLF + _
		"gih"+ vbCRLF

	Assert  counter.GetNextLineNum( 12 ) = 3  '// vbLF
	Assert  counter.GetNextLineNum( 13 ) = 4  '// "f"
	Assert  counter.GetNextLineNum( 17 ) = 5  '// "i"
	Assert  counter.GetNextLineNum( 21 ) = 6  '// 最後の次

	Assert  counter.Text = _
		"a"+ vbCRLF + _
		"bcdX"+ vbCRLF + _
		"e"+ vbCRLF + _
		"f"+ vbCRLF + _
		"gih"+ vbCRLF


	'//===========================================================
	'// Case of LF

	Set counter = new LineNumFromTextPositionClass
	counter.Text = _
		"a"+ vbLF + _
		"bcd"+ vbLF + _
		"e"+ vbLF + _
		"fX"+ vbLF + _
		"gih"+ vbLF

	Assert  counter.GetNextLineNum( 1 )  = 1  '// "a"
	Assert  counter.GetNextLineNum( 2 )  = 1  '// vbLF
	Assert  counter.GetNextLineNum( 3 )  = 2  '// "b",  部分文字列が vbLF から始まるとき
	Assert  counter.GetNextLineNum( 7 )  = 3  '// "e",  部分文字列の最終行は、文字なし
	Assert  counter.GetNextLineNum( 10 ) = 4  '// "X",  部分文字列の最終行は、文字あり
	Assert  counter.GetNextLineNum( 15 ) = 5  '// vbLF
	Assert  counter.GetNextLineNum( 16 ) = 6  '// 最後の次


	counter.Text = _
		"a"+ vbLF + _
		"b"+ vbLF + _
		"cde"
	Assert  counter.GetNextLineNum( 3 )  = 2  '// "b"
	Assert  counter.GetNextLineNum( 4 )  = 2  '// vbLF
	Assert  counter.GetNextLineNum( 5 )  = 3  '// "c"
	Assert  counter.GetNextLineNum( 8 )  = 3  '// 最後の次
	Assert  counter.GetLineNum( 3 )      = 2  '// Test of GetLineNum


	Set counter = new LineNumFromTextPositionClass
	counter.Text = _
		"a"+ vbLF + _
		"bcd"+ vbLF + _
		"e"+ vbLF + _
		"f"+ vbLF + _
		"gih"+ vbLF

	Assert  counter.GetNextLineNum( 3 ) = 2  '// "b"

	counter.ReplaceTextAtHere _
		"bcdX"+ vbLF + _
		"e"+ vbLF + _
		"f"+ vbLF + _
		"gih"+ vbLF

	Assert  counter.GetNextLineNum(  9 ) = 3  '// vbLF
	Assert  counter.GetNextLineNum( 10 ) = 4  '// "f"
	Assert  counter.GetNextLineNum( 13 ) = 5  '// "i"
	Assert  counter.GetNextLineNum( 16 ) = 6  '// 最後の次

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


 
