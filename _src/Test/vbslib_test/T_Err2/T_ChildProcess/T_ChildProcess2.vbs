Option Explicit 

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	include  "T_ChildProcess2_include.vbs"  '// define SampleClass

	EchoTestStart  "T_ChildProcess2_1"

'//-------------------------------- copy from document

	'// サブ・プロセスと送受信するオブジェクトを登録する
	Dim sample : Set sample = new SampleClass  '// has_interface_of InterProcessData
	g_InterProcess.InterProcessDataArray.Add  sample


	'// 登録後でもデータを変更できる
	sample.SampleName = "A" : sample.SampleValue = 1


	'// サブプロセスを起動する
	Dim r : r= RunProg( "cscript.exe T_ChildProcess2_Sub.vbs", "" )
	CheckTestErrLevel  r


	'// サブ・プロセスで変更されたデータを確認する
	If sample.SampleValue <> 2 Then  Fail

'//--------------------------------

	g_InterProcess.InterProcessDataArray.RemoveObject  sample
	sample = Empty


	'// Test of No Application object
	EchoTestStart  "T_ChildProcess2_2"
	r= RunProg( "cscript.exe T_ChildProcess2_Sub.vbs", "" )
	CheckTestErrLevel  r


	'// Test of No XML
	EchoTestStart  "T_ChildProcess2_3"
	r= g_sh.Run( "cscript.exe T_ChildProcess2_Sub.vbs",, True )
	CheckTestErrLevel  r

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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
