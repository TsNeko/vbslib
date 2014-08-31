Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( "1","T_Translate1", "2","T_Translate_sth",_
			"3","T_TranslateTest", "4","T_TranslateTest_sth", "5","T_Translate_Sample" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Translate1] >>> 
'********************************************************************************
Sub  T_Translate1( Opt, AppKey )
	Set w_=AppKey.NewWritable( "T_Translate_work" ).Enable()

	copy  "T_Translate\*", "T_Translate_work"


	'// １つの翻訳ファイルで、複数のファイルを翻訳する
	Translate  "T_Translate_work\T_Translate_MultiTarget.trans", "JP", "EN"
	AssertFC   "T_Translate_work\T_Translate_MultiTarget1.txt",_
		"T_Translate_ans\T_Translate_MultiTarget1.txt"
	AssertFC   "T_Translate_work\T_Translate_MultiTarget2.c",_
		"T_Translate_ans\T_Translate_MultiTarget2.c"


	'// Translate の基本
	Translate  "T_Translate_work\T_Translate1.trans", "JP", "EN"
	AssertFC   "T_Translate_work\T_Translate1.txt",_
		"T_Translate_ans\T_Translate1.txt"


	'// 逆方向に翻訳する（英和）
	Translate  "T_Translate_work\T_TranslateReverse.trans", "EN", "JP"
	AssertFC   "T_Translate_work\T_TranslateReverse.txt",_
		"T_Translate_ans\T_TranslateReverse.txt"


	'// UTF-8, LF
	Translate  "T_Translate_work\T_TranslateUtf8NoBomLf.trans", "JP", "EN"
	AssertFC   "T_Translate_work\T_TranslateUtf8NoBomLf.txt",_
		"T_Translate_ans\T_TranslateUtf8NoBomLf.txt"


	'// 翻訳ファイルの拡張子が標準ではないとき
	Translate  "T_Translate_work\T_TransXml.xml", "JP", "EN"
	AssertFC   "T_Translate_work\T_TransXml.txt",_
		"T_Translate_ans\T_TransXml.txt"


	'// 翻訳前の語が、別の翻訳前の語の一部であるとき
	Translate  "T_Translate_work\T_ByLength.trans", "JP", "EN"
	AssertFC   "T_Translate_work\T_ByLength.txt",_
		"T_Translate_ans\T_ByLength.txt"


	'// <BaseFolder> tag, BaseFolder option
	Translate    "T_Translate_work\T_BaseFolder.trans", "JP", "EN"

	Set config = new TranslateConfigClass
	config.IsTestOnly = False
	config.BaseFolderPath = "sub2"
	TranslateEx  "T_Translate_work\T_BaseFolder.trans", "JP", "EN", config

	AssertFC _
		"T_Translate_work\sub1\T_BaseFolder.txt",_
		 "T_Translate_ans\sub1\T_BaseFolder.txt"
	AssertFC _
		"T_Translate_work\sub2\T_BaseFolder.txt",_
		 "T_Translate_ans\sub2\T_BaseFolder.txt"


	'// 日本語が残っているとき
	If TryStart(e) Then  On Error Resume Next
		Translate  "T_Translate_work\T_Translate_RemainJP.trans", "JP", "EN"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo  e2.desc
	If InStr( e2.desc, "Not English character" ) = 0 Then  Fail
	If e2.num <> get_ToolsLibConsts().E_NotEnglishChar Then  Fail

	AssertFC   "T_Translate_work\T_Translate_RemainJP.txt",_
		"T_Translate_ans\T_Translate_RemainJP.txt"


	del  "T_Translate_work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Translate_sth] >>> 
'********************************************************************************
Sub  T_Translate_sth( Opt, AppKey )
	Set w_=AppKey.NewWritable( "T_Translate_work" ).Enable()

	copy  "T_Translate\*", "T_Translate_work"


	'// プロンプトの Translate コマンドを動かす
	r = RunProg( "cscript """+ SearchParent( "vbslib Prompt.vbs" ) +""" Translate T_Translate_work\T_Translate1.trans .", "" )
	CheckTestErrLevel  r
	AssertFC   "T_Translate_work\T_Translate1.txt",_
	            "T_Translate_ans\T_Translate1.txt"

	del  "T_Translate_work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TranslateTest] >>> 
'********************************************************************************
Sub  T_TranslateTest( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "in", "out" ) ).Enable()

	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"

	del  "in"
	del  "out"


	'//=== TranslateTest の基本
	If section.Start( "T_TranslateTest_1" ) Then

	'// set up
	For Each name  In Array(_
			 "T_Translate_MultiTarget.trans",_
			 "T_Translate_MultiTarget1.txt",_
			 "T_Translate_MultiTarget2.c" )
		copy  "T_Translate\"+ name, "in"
	Next


	'// Test Main
	TranslateTest  "in\T_Translate_MultiTarget.trans", "JP", "EN", "out"


	'// check
	AssertFC      "out\T_Translate_MultiTarget1.txt",_
		"T_Translate_ans\T_Translate_MultiTarget1.txt"
	AssertFC      "out\T_Translate_MultiTarget2.c",_
		"T_Translate_ans\T_Translate_MultiTarget2.c"

	Assert not fc( "out\T_Translate_MultiTarget1.txt",_
				 "T_Translate\T_Translate_MultiTarget1.txt" )
	Assert not fc( "out\T_Translate_MultiTarget2.c",_
				 "T_Translate\T_Translate_MultiTarget2.c" )

	del  "in"
	del  "out"
	End If : section.End_


	'//=== 日本語が残っているとき
	If section.Start( "T_Translate_RemainJP" ) Then

	'// set up
	For Each name  In Array( "T_Translate_RemainJP.trans",_
	                         "T_Translate_RemainJP.txt" )
		copy  "T_Translate\"+ name, "in"
	Next


	'// Test Main
	If TryStart(e) Then  On Error Resume Next
		TranslateTest  "in\T_Translate_RemainJP.trans", "JP", "EN", "out"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo  e2.desc
	Assert  InStr( e2.desc, "Not English character" ) > 0
	Assert  InStr( e2.desc, "サブ関数" ) > 0
	Assert  e2.num = get_ToolsLibConsts().E_NotEnglishChar


	'// check
	AssertFC      "out\T_Translate_RemainJP.txt",_
		"T_Translate_ans\T_Translate_RemainJP.txt"

	Assert not fc( "out\T_Translate_RemainJP.txt",_
				 "T_Translate\T_Translate_RemainJP.txt" )
	End If : section.End_


	'//=== Linux テキストを翻訳する
	If section.Start( "T_Translate_Linux" ) Then

	'// set up
	For Each name  In Array( "T_Translate_Linux.trans",_
		 "T_Translate_Linux.txt" )
		copy  "T_Translate\"+ name, "in"
	Next

	'// Test Main
	TranslateTest  "in\T_Translate_Linux.trans", "JP", "EN", "out"  '// 翻訳に成功


	'// set up
	Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
	CreateFile  "in\T_Translate_Linux.txt", _
		Replace( ReadFile( "in\T_Translate_Linux.txt" ), "１行", "*１行" )
	cs = Empty

	'// Test Main
	If TryStart(e) Then  On Error Resume Next
		TranslateTest  "in\T_Translate_Linux.trans", "JP", "EN", "out"  '// 翻訳に失敗
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo  e2.desc
	If InStr( e2.desc, "Not English character count is 1" ) = 0 Then  Fail
	If InStr( e2.desc, "line_num=""4""" ) = 0 Then  Fail
	If e2.num <> get_ToolsLibConsts().E_NotEnglishChar Then  Fail
	End If : section.End_


	'// clean
	del  "in"
	del  "out"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TranslateTest_sth] >>> 
'********************************************************************************
Sub  T_TranslateTest_sth( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "in", "out", "T_Translate_RemainJP_log.txt" ) ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_TranslateTest_sth_BaseFolder"

	del  "in"
	del  "out"


	'//=== プロンプトの TranslateTest コマンドを動かす
If section.Start( "T_TranslateTest_sth_1" ) Then

	'// set up
	For Each name  In Array( "T_Translate_MultiTarget.trans",_
			"T_Translate_MultiTarget1.txt", "T_Translate_MultiTarget2.c" )
		copy  "T_Translate\"+ name, "in"
	Next


	'// Test Main
	r = RunProg( "cscript """+ SearchParent( "vbslib Prompt.vbs" ) +_
				 """ TranslateTest  in\T_Translate_MultiTarget.trans  out", "" )
	CheckTestErrLevel  r


	'// check
	AssertFC      "out\T_Translate_MultiTarget1.txt",_
		"T_Translate_ans\T_Translate_MultiTarget1.txt"
	AssertFC      "out\T_Translate_MultiTarget2.c",_
		"T_Translate_ans\T_Translate_MultiTarget2.c"

	Assert not fc( "out\T_Translate_MultiTarget1.txt",_
				 "T_Translate\T_Translate_MultiTarget1.txt" )
	Assert not fc( "out\T_Translate_MultiTarget2.c",_
				 "T_Translate\T_Translate_MultiTarget2.c" )
End If : section.End_


	'//=== 翻訳後を出力しない
If section.Start( "T_TranslateTest_sth_NotOut" ) Then
	r = RunProg( "cscript """+ SearchParent( "vbslib Prompt.vbs" ) +_
				 """ TranslateTest  in\T_Translate_MultiTarget.trans  """"", "" )
	CheckTestErrLevel  r
End If : section.End_


	'//=== BaseFolder option
If section.Start( "T_TranslateTest_sth_BaseFolder" ) Then
	

	'// set up
	For Each name  In Array( "T_BaseFolder.trans", "sub1", "sub2" )
		copy  "T_Translate\"+ name, "in"
	Next


	'// Test Main
	r = RunProg( "cscript //nologo """+ SearchParent( "vbslib Prompt.vbs" ) +_
		""" Translate  in\T_BaseFolder.trans  """"", "" )
	r = RunProg( "cscript //nologo """+ SearchParent( "vbslib Prompt.vbs" ) +_
		""" Translate  in\T_BaseFolder.trans  """"  /BaseFolder:sub2", "" )


	'// Check
	AssertFC _
		"in\sub1\T_BaseFolder.txt",_
		"T_Translate_ans\sub1\T_BaseFolder.txt"
	AssertFC _
		"in\sub2\T_BaseFolder.txt",_
		"T_Translate_ans\sub2\T_BaseFolder.txt"


End If : section.End_


	'//=== 日本語が残っているとき
If section.Start( "T_TranslateTest_sth_RemainJP" ) Then


	'// set up
	For Each name  In Array( "T_Translate_RemainJP.trans",_
			 "T_Translate_RemainJP.txt" )
		copy  "T_Translate\"+ name, "in"
	Next

	'// Test Main
	r = RunProg( "cscript //nologo """+ SearchParent( "vbslib Prompt.vbs" ) +_
		""" TranslateTest  in\T_Translate_RemainJP.trans  out", "T_Translate_RemainJP_log.txt" )

	'// Check
	AssertFC  "T_Translate_RemainJP_log.txt", "T_Translate_RemainJP_ans.txt"

End If : section.End_


	del  "in"
	del  "out"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Translate_Sample] >>> 
'********************************************************************************
Sub  T_Translate_Sample( Opt, AppKey )
	folder = SearchParent( "Samples\Translate" )
	Set w_=AppKey.NewWritable( folder ).Enable()
	Set ds_= new CurDirStack


	'//=== All word will be translated

	'// Set up
	CreateFile  folder +"\sample.txt", _
		"日本語"+ vbCRLF+ "英語"+ vbCRLF

	'// Test Main
	pushd  folder
	RunProg  "cscript Translate.vbs TranslateTest", ""
	popd

	'// Check
	Assert  ReadFile( folder +"\sample.txt" ) = _
		"日本語"+ vbCRLF+ "英語"+ vbCRLF 


	'//=== Not translated word will be remained.

	'// Set up
	CreateFile  folder +"\sample.txt", _
		"日本"+ vbCRLF+ "英語"+ vbCRLF

	'// Test Main
	pushd  folder
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		RunProg  "cscript Translate.vbs TranslateTest", ""

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0
	popd

	'// Check
	Assert  ReadFile( folder +"\sample.txt" ) = _
		"日本"+ vbCRLF+ "英語"+ vbCRLF 


	'//=== Translate

	'// Set up
	CreateFile  folder +"\sample.txt", _
		"日本語"+ vbCRLF+ "英語"+ vbCRLF

	'// Test Main
	pushd  folder
	RunProg  "cscript Translate.vbs Translate y", ""
	popd

	'// Check
	Assert  ReadFile( folder +"\sample.txt" ) = _
		"Japanese"+ vbCRLF+ "English"+ vbCRLF 

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


 
