Option Explicit 

Sub  Main( Opt, AppKey ) : RunTestPrompt AppKey.NewWritable( "." ) : End Sub


Sub  Test_current( tests )
	If IsEmpty( tests.CurrentTest.Delegate ) Then
		Dim g : Set g = CreateObject( "Scripting.Dictionary" ) : Set tests.CurrentTest.Delegate = g

		'[Setting]
		'==============================================================================
		g("Tests") = Array( "T_Err2_Tree1", "T_Err2_Tree2", "T_Err2_Tree3", "T_Err2_Tree4", _
			 "T_Err2_Tree6", "T_Err2_Tree7", "T_Err2_TryStartWithErr", "T_Err2_Tree3_Child1", _
			 "T_Err2_Tree3_Child2", "T_Err2_Tree3_PassRaise1", "T_Err2_Tree3_PassRaise2" )
		'==============================================================================
	End If
End Sub


Sub  Test_setup( tests )
	Dim  t
	Dim  g : Set g = tests.CurrentTest.Delegate
	For Each t  In g("Tests")
		ConvertToFullPath  t+"_ans_tmp.txt", t+"_ans.txt"
	Next
	Pass
End Sub


Sub  Test_start( tests )
	Dim  r, f, tname, path, target, dbg1, dbg2, en, ed
	Dim  g : Set g = tests.CurrentTest.Delegate

	If tests.bTargetDebug Then dbg1="//x " : dbg2=" /g_debug:1"  Else dbg1="" :  dbg2=""

	target = "T_Err2_Tree.vbs"
	For Each tname  In g("Tests")
		test_start_err_check  tests, target, tname
	Next

	ManualTest  "T_Err2_Tree_Manually"  '// g_Vers("T_Err2") in T_Err2_Tree.vbs
	Pass
End Sub


Sub  test_start_err_check( tests, target, tname )
	Dim  r, en, ed
	EchoTestStart  tname
	del  tname +"_out.txt"
	On Error Resume Next
		r = RunProg( "cscript //nologo "+target+" /ChildProcess:0 /Test:"+tname, tname +"_out.txt" )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	g_Err2.Clear
	AssertFC  tname +"_out.txt", tname +"_ans.txt"
	del  tname +"_out.txt"
End Sub


Sub  Test_clean( tests )
	Dim  t
	Dim  g : Set g = tests.CurrentTest.Delegate
	For Each t  In g("Tests")
		del  t+"_ans.txt"
	Next
	Pass
End Sub


Sub  Test_build( tests ) : Pass : End Sub
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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
