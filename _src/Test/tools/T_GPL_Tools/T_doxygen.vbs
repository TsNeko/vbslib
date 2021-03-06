Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_doxygen_1", _
			"2","T_doxygen_STH" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_doxygen_1] >>> 
'*************************************************************************
Sub  T_doxygen_1( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_HTML" ).Enable()

	'// Set up
	del  "_HTML"

	'// Test Main
	MakeDocumentBy_doxygen  "Files\src_for_doxygen", "_HTML", Empty

	'// Check
	AssertExist  "_HTML\index.html"

	'// Check : UTF-8 of not ascii character
	Set cs = new_TextFileCharSetStack( "UTF-8" )
	Assert  InStr( ReadFile( "_HTML\_bmp_file2_8c.html" ), "ファイルを読み込みます" ) > 0
	cs = Empty


	'//===========================================================
	'// _HTML フォルダーを削除して再実行したときは、キャッシュ（プロジェクト）をリセットするテスト

	'// Set up
	del  "_HTML"

	'// Test Main
	MakeDocumentBy_doxygen  "Files\src_for_doxygen", "_HTML", Empty

	'// Check
	AssertExist  "_HTML\index.html"


	'// Clean
	del  "_HTML"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_doxygen_STH] >>> 
'*************************************************************************
Sub  T_doxygen_STH( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_HTML" ).Enable()

	'// Set up
	del  "_HTML"
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )

	'// Test Main
	r= RunProg( "cscript """+ prompt_vbs +"""  doxygen  Files\src_for_doxygen  _HTML  """" """"  /silent", "" )
	CheckTestErrLevel  r

	'// Check
	AssertExist  "_HTML\index.html"

	'// Check : UTF-8 of not ascii character
	Set cs = new_TextFileCharSetStack( "UTF-8" )
	Assert  InStr( ReadFile( "_HTML\_bmp_file2_8c.html" ), "ファイルを読み込みます" ) > 0
	cs = Empty

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


 
