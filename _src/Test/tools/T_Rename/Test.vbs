Sub  Main( Opt, AppKey ) : RunTestPrompt  AppKey.NewWritable( "Work" ) : End Sub


Sub  Test_start( tests )
	Set section = new SectionTree

'//SetStartSectionTree  "T_DeleteTail"


	'//=== ファイル名の最初に追加する
	If section.Start( "T_RenameAdd" ) Then

	'// Set up
	del  "Work"
	copy  "SourceFiles\*", "Work"

	'// Test Main
	'// Case 1. 先頭に "A" を追加
	'// Case 2. Enter のみ入力によって、先頭に "A" を追加
	'// Case 3. "AAXDuplicate" を追加 … 重複エラー … キャンセル
	vbs_path = SearchParent( "vbslib Prompt.vbs" )
	r = RunProg( "cscript //nologo """+ vbs_path +""" Rename 1 Work A y "+_
		""""" """" """" """" "+_
		""""" """" AAXDuplicate """" "+_
		"A n 9", "" )
	CheckTestErrLevel  r

	'// Check
	Assert  fc( "Work", "AnsOfAdd" )

	'// Clean
	del  "Work"

	End If : section.End_


	'//=== ファイル名の先頭を変更する
	If section.Start( "T_RenameHead" ) Then

	'// Set up
	del  "Work"
	copy  "SourceFiles\*", "Work"

	'// Test Main
	'// Case 1. 先頭の "Fi" を "Po" に変更
	'// Case 2. 先頭の "" を "" に変更 … 重複エラー … キャンセル
	'// Case 3. 先頭の "NotFound" を "X" に変更 … 変更なし
	'// Case 4. 先頭の "XDuplicateAA" を削除
	vbs_path = SearchParent( "vbslib Prompt.vbs" )
	r = RunProg( "cscript //nologo """+ vbs_path +""" Rename 2 Work Fi Po y "+_
		""""" """" """" """" y "+_
		"NotFound X y "+_
		""""" """" XDuplicateAA """" y 9", "" )
	CheckTestErrLevel  r

	'// Check
	Assert  fc( "Work", "AnsOfRenameHead" )

	'// Clean
	del  "Work"

	End If : section.End_


	'//=== ファイル名の先頭数文字を削除する
	If section.Start( "T_DeleteHead" ) Then

	'// Set up
	del  "Work"
	copy  "SourceFiles\*", "Work"

	'// Test Main
	'// Case 1. 先頭の2文字を削除
	'// Case 2. 先頭の0文字を削除 … 重複エラー
	'// Case 3. 先頭の1文字を削除 … 重複エラー
	'// Case 4. 先頭の10文字を削除 … 重複エラー
	vbs_path = SearchParent( "vbslib Prompt.vbs" )
	r = RunProg( "cscript //nologo """+ vbs_path +""" Rename 3 Work 2 y "+_
		""""" """" 0 y "+_
		"1 y "+_
		"10 y "+_
		"0 n 9", "" )
	CheckTestErrLevel  r

	'// Check
	Assert  fc( "Work", "AnsOfDeleteHead" )

	'// Clean
	del  "Work"

	End If : section.End_


	'//=== ファイル名の末尾数文字を削除する
	If section.Start( "T_DeleteTail" ) Then

	'// Set up
	del  "Work"
	copy  "SourceFiles2\*", "Work"

	'// Test Main
	'// Case 1. 末尾の1文字を削除
	'// Case 2. 末尾の1文字を削除 … 重複エラー
	'// Case 3. 末尾の10文字を削除 … 重複エラー
	vbs_path = SearchParent( "vbslib Prompt.vbs" )
	r = RunProg( "cscript //nologo """+ vbs_path +""" Rename 4 Work 1 y "+_
		""""" """" 1 y "+_
		"10 y "+_
		"0 n 9", "" )
	CheckTestErrLevel  r

	'// Check
	Assert  fc( "Work", "AnsOfDeleteTail" )

	'// Clean
	del  "Work"

	End If : section.End_

	Pass
End Sub


Sub  Test_current( tests ) : End Sub
Sub  Test_build( tests ) : Pass : End Sub
Sub  Test_setup( tests ) : Pass : End Sub
Sub  Test_check( tests ) : Pass : End Sub
Sub  Test_clean( tests ) : Pass : End Sub


 







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


 
