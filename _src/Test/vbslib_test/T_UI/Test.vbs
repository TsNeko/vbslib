Option Explicit 

Sub  Main( Opt, AppKey ) : RunTestPrompt AppKey.NewWritable( "." ) : End Sub


Sub  Test_start( tests )
	Dim  r, w_
	Dim  ds_:Set ds_= new CurDirStack
	Dim  e, e2  ' as Err2

	EchoTestStart  "T_EchoCopyStream"
	r = RunProg( "cscript //nologo T_EchoCopyStream.vbs", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputPath_TestOfCheck"
	r = RunProg( "cscript  //nologo  T_InputPath_Target.vbs  T_InputPath_TestOfCheck", "_out.txt" )
	CheckTestErrLevel  r
	AssertFC  "_out.txt", "Files\T_InputPath_Target_ans.txt"

	EchoTestStart  "T_UI_Auto"
	del "T_UI_Auto_out.txt"
	r = RunProg( "cscript //nologo T_UI_Auto.vbs", "" )
	CheckTestErrLevel  r
	r = RunProg( "cscript //nologo T_UI_Auto.vbs", "T_UI_Auto_out.txt" )
	CheckTestErrLevel  r
	If not fc( "T_UI_Auto_out.txt", "T_UI_Auto_ans.txt" ) Then  Fail

	EchoTestStart  "T_UI_AutoTarget"
	del "T_UI_Auto_out.txt"
	r = RunProg( "cscript //nologo T_UI_AutoTarget.vbs /set_input:abcd..", "" )
	CheckTestErrLevel  r
	r = RunProg( "cscript //nologo T_UI_AutoTarget.vbs /set_input:abcd..", "T_UI_Auto_out.txt" )
	CheckTestErrLevel  r
	If not fc( "T_UI_Auto_out.txt", "T_UI_Auto_ans.txt" ) Then  Fail

	EchoTestStart  "T_Open_1"
	r = RunProg( "cscript //nologo T_Open_1.vbs", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputCommand_Param"
	r= RunProg( "cscript.exe //nologo T_InputCommand_Target.vbs FuncB ""T_InputCommand_Target.vbs"" Y", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputCommand_Param"
	r= RunProg( "cscript.exe //nologo T_InputCommand_Target.vbs FuncBx ""T_InputCommand_Target.vbs"" Y", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputCommand_Param_Case"  '// 大文字小文字を区別しないテスト
	r= RunProg( "cscript.exe //nologo T_InputCommand_Target.vbs funcb ""T_InputCommand_Target.vbs"" Y", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputCommand_Param_Case"  '// 大文字小文字を区別しないテスト
	r= RunProg( "cscript.exe //nologo T_InputCommand_Target.vbs funcbx ""T_InputCommand_Target.vbs"" Y", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputCommand_WindowsParam"
	r= RunProg( "cscript.exe //nologo T_InputCommand_Target.vbs FuncW ""\home\user1\file 1.txt:10"" Param2", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputCommand_LinuxParam"
	r= RunProg( "cscript.exe //nologo T_InputCommand_Target.vbs FuncL /Path:""/home/user1/file 1.txt:10"" Param2", "" )
	CheckTestErrLevel  r

	EchoTestStart  "T_InputCommand_ForgetClear"
	If TryStart(e) Then  On Error Resume Next
		r = RunProg( "cscript  //nologo T_InputCommand_Target2.vbs  T_InputCommand_ForgetClear /ChildProcess:0", "out.txt" )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	AssertFC  "out.txt", "T_InputCommand_ForgetClear_ans.txt"
	del  "out.txt"

	EchoTestStart  "T_InputCommand_Pass"
	r = RunProg( "cscript  //nologo T_InputCommand_Target2.vbs  T_InputCommand_Pass  T_InputCommand_Pass", "out.txt" )
	CheckTestErrLevel  r
	AssertFC  "out.txt", "T_InputCommand_Pass_ans.txt"
	del  "out.txt"

	EchoTestStart  "T_InputCommand_Fail"
	If TryStart(e) Then  On Error Resume Next
		r = RunProg( "cscript  //nologo T_InputCommand_Target2.vbs T_InputCommand_Fail", "out.txt" )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  InStr( e2.desc, "Fail" ) > 0
	Assert  InStr( e2.desc, "Pass" ) = 0
	Assert  e2.num = E_TestFail
	AssertFC  "out.txt", "T_InputCommand_Fail_ans.txt"
	del  "out.txt"

	EchoTestStart  "T_InputCommand_NotFound"
	If TryStart(e) Then  On Error Resume Next
		r = RunProg( "cscript  //nologo T_InputCommand_Target2.vbs T_InputCommand_NotFound", "out.txt" )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  InStr( e2.desc, "T_InputCommand_NotFound 関数がありません" ) > 0
	del  "out.txt"

	EchoTestStart  "T_InputPath_WorkFolder_File"
	pushd  "T_Open_Data"
	r = RunProg( "cscript  //nologo  ..\T_InputPath_Target.vbs  T_InputPath_WorkFolder_File", "" )
	popd
	CheckTestErrLevel  r

	EchoTestStart  "T_InputPathArg"
	r = RunProg( "cscript  //nologo  T_InputPathArg.vbs  T_UI_Auto_ans.txt  T_InputCommand_Pass_ans.txt", "" )
	CheckTestErrLevel  r

	r = RunProg( "cscript //nologo T_Clipboard.vbs AllTest", "" )
	CheckTestErrLevel  r

	ManualTest "T_Clipboard_Manually"
	ManualTest "T_EditorDiff_Manually"
	ManualTest "T_InputCommand_Manually"
	ManualTest "T_UI_cscript_Manually"
	ManualTest "T_UI_SubProcess_Manually"
	ManualTest "T_UI_wscript_Manually"
	Pass
End Sub


Sub  Test_clean( tests )
	del "T_UI_Auto_out.txt"
	Pass
End Sub


Sub  Test_current( tests ) : End Sub
Sub  Test_build( tests ) : Pass : End Sub
Sub  Test_setup( tests ) : Pass : End Sub
Sub  Test_check( tests ) : Pass : End Sub


 







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


 
