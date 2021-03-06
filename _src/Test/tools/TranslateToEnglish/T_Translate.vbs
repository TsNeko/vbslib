Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_Translate1", _
			"2","T_TranslateFolder", _
			"3","T_Translate_getOverwritePaths", _
			"4","T_Translate_getWritable", _
			"5","T_TranslateTest", _
			"6","T_TranslateTestFolder", _
			"7","T_TranslateTest_sth", _
			"8","T_Translate_sth", _
			"9","T_Translate_Sample" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Translate1] >>> 
'********************************************************************************
Sub  T_Translate1( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_out.txt" ) ).Enable()

	RunProg  "cscript //nologo "+ WScript.ScriptName +" T_Translate1_Sub", "_out.txt"

	AssertFC  "_out.txt", "LogAnswer\T_Translate1_ans.txt"
	del  "_out.txt"

	Pass
End Sub

Sub  T_Translate1_Sub( Opt, AppKey )
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
	Translate  "T_Translate_work\Not_jp_to_en\T_TranslateReverse.trans", "EN", "JP"
	AssertFC   "T_Translate_work\Not_jp_to_en\T_TranslateReverse.txt",_
		"T_Translate_ans\Not_jp_to_en\T_TranslateReverse.txt"


	'// UTF-8, LF
	Translate  "T_Translate_work\T_TranslateUtf8NoBomLf.trans", "JP", "EN"
	Assert  IsSameBinaryFile( "T_Translate_work\T_TranslateUtf8NoBomLf.txt",_
		"T_Translate_ans\T_TranslateUtf8NoBomLf.txt", Empty )

	Translate  "T_Translate_work\T_TranslateUtf8NoBomLf2.trans", "JP", "EN"
	Assert  IsSameBinaryFile( "T_Translate_work\T_TranslateUtf8NoBomLf2.xml",_
		"T_Translate_ans\T_TranslateUtf8NoBomLf2.xml", Empty )


	'// 複数行の置き換え
	Translate  "T_Translate_work\T_Translate_MultiLine.trans", "JP", "EN"
	AssertFC   "T_Translate_work\T_Translate_MultiLine.txt",_
		"T_Translate_ans\T_Translate_MultiLine.txt"


	'// 翻訳ファイルの拡張子が標準ではないとき
	Translate  "T_Translate_work\Not_jp_to_en\T_TransXml.xml", "JP", "EN"
	AssertFC   "T_Translate_work\Not_jp_to_en\T_TransXml.txt",_
		"T_Translate_ans\Not_jp_to_en\T_TransXml.txt"


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
	Assert  InStr( e2.desc, "translator_path=" ) > 0
	Assert  e2.num = get_ToolsLibConsts().E_NotEnglishChar

	AssertFC   "T_Translate_work\T_Translate_RemainJP.txt",_
		"T_Translate_ans\T_Translate_RemainJP.txt"


	'// 変換ファイルが無いとき
	If TryStart(e) Then  On Error Resume Next

		Translate  "T_Translate_work\NotFound.trans", "JP", "EN"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo  e2.desc
	Assert  InStr( e2.desc, "NotFound.trans" ) > 0
	Assert  e2.num = E_FileNotExist


	del  "T_Translate_work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TranslateFolder] >>> 
'********************************************************************************
Sub  T_TranslateFolder( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "T_Translate_work", "T_Translate_ans\Not_jp_to_en" ) ).Enable()

	'// Set up
	del  "T_Translate_work"
	copy  "T_Translate\SubFolders\*", "T_Translate_work"

	'// Test Main
	If TryStart(e) Then  On Error Resume Next

		Translate  "T_Translate_work", "JP", "EN"

	If TryEnd Then  On Error GoTo 0
	Assert  e.num = get_ToolsLibConsts().E_NotEnglishChar  or _
		e.num = E_PathNotFound
	e.Clear

	'// Check
	del  "T_Translate_work\*\*.trans"
	Assert  fc( "T_Translate_work", "T_Translate_ans\SubFolders" )

	'// Clean
	del  "T_Translate_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Translate_getOverwritePaths] >>> 
'********************************************************************************
Sub  T_Translate_getOverwritePaths( Opt, AppKey )
	cur = g_sh.CurrentDirectory

	'// Test Main : File
	paths = Translate_getOverwritePaths( "T_Translate\T_Translate1.trans" )

	'// Check
	Assert  IsSameArrayOutOfOrder( paths, Array( _
		cur +"\T_Translate\T_Translate1.txt" ), Empty )


	'// Test Main : Folder
	paths = Translate_getOverwritePaths( "T_Translate\SubFolders" )

	'// Check
	Assert  IsSameArrayOutOfOrder( paths, Array( _
		cur +"\T_Translate\SubFolders\T_Newest_EN.c", _
		cur +"\T_Translate\SubFolders\T_Newest_JP.c", _
		cur +"\T_Translate\SubFolders\T_NotFoundTargetErr.txt", _
		cur +"\T_Translate\SubFolders\sub\T_Newest_Trans.txt" ), Empty )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Translate_getWritable] >>> 
'********************************************************************************
Sub  T_Translate_getWritable( Opt, AppKey )
	cur = g_sh.CurrentDirectory

	'// Test Main : File
	paths = Translate_getWritable( "T_Translate\T_Translate1.trans" )

	'// Check
	Assert  IsSameArrayOutOfOrder( paths, Array( _
		cur +"\T_Translate" ), Empty )


	'// Test Main : Folder
	paths = Translate_getWritable( "T_Translate\SubFolders" )

	'// Check
	Assert  IsSameArrayOutOfOrder( paths, Array( _
		cur +"\T_Translate\SubFolders", _
		cur +"\T_Translate\SubFolders\sub" ), Empty )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TranslateTest] >>> 
'********************************************************************************
Sub  T_TranslateTest( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_out.txt", "_work" ) ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_TranslateTest_Sort"


	'//===========================================================
	If section.Start( "T_TranslateTest_CheckLog" ) Then

	RunProg  "cscript //nologo "+ WScript.ScriptName +" T_TranslateTest_Main", "_out.txt"

	AssertFC  "_out.txt", "LogAnswer\T_TranslateTest_ans.txt"
	del  "_out.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_TranslateTest_Sort" ) Then

	'// set up
	For Each name  In Array(_
			 "T_Sort.trans",_
			 "T_Sort.txt" )
		copy  "T_Translate\"+ name, "_work"
	Next

	'// Test Main
	TranslateTest  "_work\T_Sort.trans", "JP", "EN", "_work\out"

	'// Check
	AssertFC  "_work\T_Sort.trans", "T_Translate\T_Sort_After.trans"

	'// Clean
	del  "_work"

	End If : section.End_


	Pass
End Sub

Sub  T_TranslateTest_Main( Opt, AppKey )
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
	AssertFC  "out\T_Translate_MultiTarget1.txt",_
		"T_Translate_ans\T_Translate_MultiTarget1.txt"
	AssertFC  "out\T_Translate_MultiTarget2.c",_
		"T_Translate_ans\T_Translate_MultiTarget2.c"

	Assert not fc( "out\T_Translate_MultiTarget1.txt",_
		"T_Translate\T_Translate_MultiTarget1.txt" )
	Assert not fc( "out\T_Translate_MultiTarget2.c",_
		"T_Translate\T_Translate_MultiTarget2.c" )

	AssertFC  "in\T_Translate_MultiTarget.trans",_
		"T_Translate_ans\trans\T_Translate_MultiTarget.trans"

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
	Assert  InStr( e2.desc, "translator_path=" ) > 0
	Assert  e2.num = get_ToolsLibConsts().E_NotEnglishChar


	'// check
	AssertFC  "out\T_Translate_RemainJP.txt",_
		"T_Translate_ans\T_Translate_RemainJP.txt"

	Assert not fc( "out\T_Translate_RemainJP.txt",_
				 "T_Translate\T_Translate_RemainJP.txt" )

	AssertFC  "in\T_Translate_RemainJP.trans",_
		"T_Translate_ans\trans\T_Translate_RemainJP.trans"

	End If : section.End_


	'//=== Linux テキストを翻訳する
	If section.Start( "T_Translate_Linux" ) Then

	'// set up
	For Each name  In Array( "T_Translate_Linux.trans",_
		 "T_Translate_Linux.txt" )
		copy  "T_Translate\sub3\"+ name, "in"
	Next

	'// Test Main
	TranslateTest  "in\T_Translate_Linux.trans", "JP", "EN", "out"  '// 翻訳に成功

	'// check
	AssertFC  "in\T_Translate_Linux.trans",_
		"T_Translate_ans\trans\T_Translate_Linux.trans"


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
	If e2.num <> get_ToolsLibConsts().E_NotEnglishChar Then  Fail
	End If : section.End_

	'// check
	AssertFC  "in\T_Translate_Linux.trans",_
		"T_Translate_ans\trans\T_Translate_Linux_Modified.trans"


	'// clean
	del  "in"
	del  "out"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TranslateTestFolder] >>> 
'********************************************************************************
Sub  T_TranslateTestFolder( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_out.txt" ) ).Enable()

	RunProg  "cscript //nologo "+ WScript.ScriptName +" T_TranslateTestFolder_Sub", "_out.txt"

	AssertFC  "_out.txt", "LogAnswer\T_TranslateTestFolder_ans.txt"
	del  "_out.txt"

	Pass
End Sub

Sub  T_TranslateTestFolder_Sub( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "T_Translate_work", "_work" ) ).Enable()


	For Each  out_path  In Array( "", "T_Translate_work" )

		'// Set up
		del  "T_Translate_work"
		del  "_work"
		copy  "T_Translate\SubFolders\*", "_work"


		'// Test Main
		If TryStart(e) Then  On Error Resume Next

			TranslateTest  "_work", "JP", "EN", out_path

		If TryEnd Then  On Error GoTo 0
		Assert  e.num = get_ToolsLibConsts().E_NotEnglishChar  or _
			e.num = E_PathNotFound
		e.Clear


		'// Check
		If out_path = "" Then
			Assert  not exist( "T_Translate_work" )
		Else
			Assert  fc( "T_Translate_work", "T_Translate_ans\SubFolders" )
		End If


		'// Clean
		del  "T_Translate_work"
		del  "_work"
	Next


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
	AssertFC  "T_Translate_RemainJP_log.txt", "LogAnswer\T_Translate_RemainJP_ans.txt"

	'// Clean
	del  "T_Translate_RemainJP_log.txt"
	End If : section.End_


	del  "in"
	del  "out"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Translate_sth] >>> 
'********************************************************************************
Sub  T_Translate_sth( Opt, AppKey )
	Set w_=AppKey.NewWritable( "T_Translate_work" ).Enable()


	'// Case of File

	'// Set up
	del  "T_Translate_work"
	copy  "T_Translate\*", "T_Translate_work"

	'// Test Main
	r = RunProg( "cscript //nologo """+ SearchParent( "vbslib Prompt.vbs" ) + _
		""" Translate T_Translate_work\T_Translate1.trans .", "" )
	CheckTestErrLevel  r

	'// Check
	AssertFC   "T_Translate_work\T_Translate1.txt",_
	            "T_Translate_ans\T_Translate1.txt"

	'// Clean
	del  "T_Translate_work"


	'// Case of Folder

	'// Set up
	del  "T_Translate_work"
	copy  "T_Translate\SubFolders\*", "T_Translate_work"
	del  "T_Translate_work\T_NotFoundTargetErr.trans"

	'// Test Main
	r = RunProg( "cscript //nologo """+ SearchParent( "vbslib Prompt.vbs" ) + _
		""" Translate T_Translate_work .", "" )
	CheckTestErrLevel  r

	'// Check
	del  "T_Translate_work\*\*.trans"
	Assert  fc( "T_Translate_work",_
	            "T_Translate_ans\SubFolders" )

	'// Clean
	del  "T_Translate_work"


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Translate_Sample] >>> 
'********************************************************************************
Sub  T_Translate_Sample( Opt, AppKey )
	Set w_=AppKey.NewWritable( "T_Translate_work" ).Enable()
	Set ds_= new CurDirStack


	'// Set up
	del  "T_Translate_work"
	copy  SearchParent( "Samples\Translate" ) +"\*", "T_Translate_work"

	'// Check
	Assert  ReadFile( "T_Translate_work\sample.txt" ) = _
	            "日本語"+ vbCRLF +"英語"+ vbCRLF


	'// Test Main
	r = RunProg( "cscript //nologo ""T_Translate_work\Translate.vbs""" + _
		" TranslateTest", "" )
	CheckTestErrLevel  r


	r = RunProg( "cscript //nologo ""T_Translate_work\Translate.vbs""" + _
		" Translate y", "" )
	CheckTestErrLevel  r
	Assert  ReadFile( "T_Translate_work\sample.txt" ) = _
	            "Japanese"+ vbCRLF +"English"+ vbCRLF


	r = RunProg( "cscript //nologo ""T_Translate_work\Translate.vbs""" + _
		" RemoveTranslateFile y", "" )
	CheckTestErrLevel  r
	Assert  not exist( "T_Translate_work\Translate.trans" )


	r = RunProg( "cscript //nologo ""T_Translate_work\Translate.vbs""" + _
		" CheckEnglishOnly", "" )
	CheckTestErrLevel  r


	'// Clean
	del  "T_Translate_work"


	'//=== All word will be translated

	'// Set up
	del  "T_Translate_work"
	copy  SearchParent( "Samples\Translate" ) +"\*", "T_Translate_work"

	CreateFile  "T_Translate_work\sample.txt", _
		"日本語"+ vbCRLF+ "英語"+ vbCRLF

	'// Test Main
	pushd  "T_Translate_work"
	RunProg  "cscript Translate.vbs TranslateTest", ""
	popd

	'// Check
	Assert  ReadFile( "T_Translate_work\sample.txt" ) = _
		"日本語"+ vbCRLF+ "英語"+ vbCRLF 


	'//=== Not translated word will be remained.

	'// Set up
	CreateFile  "T_Translate_work\sample.txt", _
		"日本"+ vbCRLF+ "英語"+ vbCRLF

	'// Test Main
	pushd  "T_Translate_work"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		RunProg  "cscript Translate.vbs TranslateTest", ""

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0
	popd

	'// Check
	Assert  ReadFile( "T_Translate_work\sample.txt" ) = _
		"日本"+ vbCRLF+ "英語"+ vbCRLF 


	'//=== Translate

	'// Set up
	CreateFile  "T_Translate_work\sample.txt", _
		"日本語"+ vbCRLF+ "英語"+ vbCRLF

	'// Test Main
	pushd  "T_Translate_work"
	RunProg  "cscript Translate.vbs Translate y", ""
	popd

	'// Check
	Assert  ReadFile( "T_Translate_work\sample.txt" ) = _
		"Japanese"+ vbCRLF+ "English"+ vbCRLF 

	'// Clean
	del  "T_Translate_work"

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


 
