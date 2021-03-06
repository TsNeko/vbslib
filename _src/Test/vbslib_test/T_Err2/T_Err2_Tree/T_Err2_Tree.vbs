Option Explicit 

Sub  Main( Opt, AppKey )
	Dim  b, t : t = WScript.Arguments.Named.Item("Test")
	If IsEmpty( t ) Then  t = g_Vers("T_Err2")
	If t="T_Err2_Tree1" or t="ALL" Then  b=1 : T_Err2_Tree1
	If t="T_Err2_Tree2" or t="ALL" Then  b=1 : T_Err2_Tree2
	If t="T_Err2_Tree3" or t="ALL" Then  b=1 : T_Err2_Tree3
	If t="T_Err2_Tree4" or t="ALL" Then  b=1 : T_Err2_Tree4
	If t="T_Err2_Tree6" or t="ALL" Then  b=1 : T_Err2_Tree6
	If t="T_Err2_Tree7" or t="ALL" Then  b=1 : T_Err2_Tree7
	If t="T_Err2_TryStartWithErr"  or t="ALL" Then  b=1 : T_Err2_TryStartWithErr
	If t="T_Err2_Tree3_Child1"     or t="ALL" Then  b=1 : T_Err2_Tree3_Child1
	If t="T_Err2_Tree3_Child2"     or t="ALL" Then  b=1 : T_Err2_Tree3_Child2
	If t="T_Err2_Tree3_PassRaise1" or t="ALL" Then  b=1 : T_Err2_Tree3_PassRaise1
	If t="T_Err2_Tree3_PassRaise2" or t="ALL" Then  b=1 : T_Err2_Tree3_PassRaise2
	If t="" Then  b=1 : T_Err2_Tree3  '// is debugging now
	If b <> 1 Then  Error
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree1] >>> 
'- Look at T_Err2_Tree.svg
'********************************************************************************
Sub  T_Err2_Tree1()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree1"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree1_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise

End Sub


Sub  T_Err2_Tree1_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree1_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	Err.Raise  1,, "T_Err2_Tree1_2"  '// break here *********************
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree2] >>> 
'- Look at T_Err2_Tree.svg
'********************************************************************************
Sub  T_Err2_Tree2()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree2"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree2_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise

End Sub


Sub  T_Err2_Tree2_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree2_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If TryStart(e) Then  On Error Resume Next  '// (1,2,0)
		Err.Raise  1,, "T_Err2_Tree2_2"  '// break here *********************
	If TryEnd Then  On Error GoTo 0
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree3] >>> 
'- Look at T_Err2_Tree.svg
'********************************************************************************
Sub  T_Err2_Tree3()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree3 "

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree3_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise

End Sub


Sub  T_Err2_Tree3_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree3_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If TryStart(e) Then  On Error Resume Next  '// (1,2,0)
		T_Err2_Tree3_sub2
	If TryEnd Then  On Error GoTo 0
End Sub


Sub  T_Err2_Tree3_sub2()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,2,1,0)
		T_Err2_Tree3_sub3
	If TryEnd Then  On Error GoTo 0
	Err.Raise  1,, "T_Err2_Tree3_3"  '// break here *********************
End Sub


Sub  T_Err2_Tree3_sub3()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,2,1,1,0)
		Err.Raise  1,, "T_Err2_Tree3_2"
	If TryEnd Then  On Error GoTo 0
	e.Clear
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree4] >>> 
'- Look at T_Err2_Tree.svg
'********************************************************************************
Sub  T_Err2_Tree4()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree4"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree4_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise

End Sub


Sub  T_Err2_Tree4_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree4_1"  '// break here *********************
	If TryEnd Then  On Error GoTo 0
	Err.Raise  1,, "T_Err2_Tree4_2"
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree6] >>> 
'- Look at T_Err2_Tree.svg
'********************************************************************************
Sub  T_Err2_Tree6()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree6"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		Err.Raise  1,, "T_Err2_Tree6_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If TryStart(e) Then  On Error Resume Next  '// (2,0)
		T_Err2_Tree6_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise

End Sub


Sub  T_Err2_Tree6_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (2,1,0)
		Err.Raise  1,, "T_Err2_Tree6_2"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	Err.Raise  1,, "T_Err2_Tree6_3"  '// break here *********************
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree7] >>> 
'- Look at T_Err2_Tree.svg
'********************************************************************************
Sub  T_Err2_Tree7()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree7"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree7_sub1
	If TryEnd Then  On Error GoTo 0
	If TryStart(e) Then  On Error Resume Next  '// (2,0)
		T_Err2_Tree7_sub2
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise

End Sub


Sub  T_Err2_Tree7_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree7_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
End Sub


Sub  T_Err2_Tree7_sub2()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (2,1,0)
		Err.Raise  1,, "T_Err2_Tree7_2"  '// break here *********************
	If TryEnd Then  On Error GoTo 0
End Sub


 
'********************************************************************************
'  <<< [T_Err2_TryStartWithErr] >>> 
'********************************************************************************
Sub  T_Err2_TryStartWithErr()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_TryStartWithErr"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		Err.Raise  1,, "T_Err2_TryStartWithErr_1"  '// break here *********************
	If TryEnd Then  On Error GoTo 0
	If TryStart(e) Then  On Error Resume Next  '// (2,0)
		Err.Raise  1,, "T_Err2_TryStartWithErr_2"
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise

End Sub

 
'********************************************************************************
'  <<< [T_Err2_Tree3_Child1] >>> 
'********************************************************************************
Sub  T_Err2_Tree3_Child1()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree3_Child1"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree3_Child1_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise
End Sub


Sub  T_Err2_Tree3_Child1_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree3_Child1_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If TryStart(e) Then  On Error Resume Next  '// (1,2,0)
		RunProg  "cscript.exe //nologo T_Err2_Tree_sub.vbs T_Err2_Tree3_Child1_sub2", ""
	If TryEnd Then  On Error GoTo 0
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree3_Child2] >>> 
'********************************************************************************
Sub  T_Err2_Tree3_Child2()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree3_Child2"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree3_Child2_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise
End Sub


Sub  T_Err2_Tree3_Child2_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree3_Child2_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If TryStart(e) Then  On Error Resume Next  '// (1,2,0)
		T_Err2_Tree3_Child2_sub2
	If TryEnd Then  On Error GoTo 0
End Sub


Sub  T_Err2_Tree3_Child2_sub2()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,2,1,0)
		RunProg  "cscript.exe //nologo T_Err2_Tree_sub.vbs T_Err2_Tree3_Child2_sub3", ""
	If TryEnd Then  On Error GoTo 0
	Err.Raise  1,, "T_Err2_Tree3_Child2_3"  '// break here *********************
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree3_PassRaise1] >>> 
'********************************************************************************
Sub  T_Err2_Tree3_PassRaise1()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree3_PassRaise1"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree3_PassRaise1_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise
End Sub


Sub  T_Err2_Tree3_PassRaise1_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		Err.Raise  1,, "T_Err2_Tree3_PassRaise1_1"
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If TryStart(e) Then  On Error Resume Next  '// (1,2,0)
		T_Err2_Tree3_PassRaise1_sub2
	If TryEnd Then  On Error GoTo 0
End Sub


Sub  T_Err2_Tree3_PassRaise1_sub2()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,2,1,0)
		RunProg  "cscript.exe //nologo T_Err2_Tree_sub.vbs T_Err2_Tree3_PassRaise1_sub3", ""
	If TryEnd Then  On Error GoTo 0
	Err.Raise  1,, "T_Err2_Tree3_PassRaise1_3"  '// break here *********************
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Tree3_PassRaise2] >>> 
'********************************************************************************
Sub  T_Err2_Tree3_PassRaise2()
	Dim  e  ' as Err2

	EchoTestStart  "T_Err2_Tree3_PassRaise2"

	If TryStart(e) Then  On Error Resume Next  '// (1,0)
		T_Err2_Tree3_PassRaise2_sub1
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  e.Raise
End Sub


Sub  T_Err2_Tree3_PassRaise2_sub1()
	Dim  e  ' as Err2

	If TryStart(e) Then  On Error Resume Next  '// (1,1,0)
		RunProg  "cscript.exe //nologo T_Err2_Tree_sub.vbs T_Err2_Tree3_PassRaise2_sub3", ""
	If TryEnd Then  On Error GoTo 0
	Err.Raise  1,, "T_Err2_Tree3_PassRaise2_3"  '// break here *********************
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

	g_Vers("T_Err2") = Empty  '// Empty or "T_Err2_Tree1" ...
	Dim g_debug_tree, g_debug_process
	Select Case  g_Vers("T_Err2")
		Case "T_Err2_Tree1" : g_debug = 2 : g_debug_tree = Array( 1 )
		Case "T_Err2_Tree2" : g_debug = 2 : g_debug_tree = Array( 1 )
		Case "T_Err2_Tree3" : g_debug = 3 : g_debug_tree = Array( 1, 2 )
		Case "T_Err2_Tree4" : g_debug = 1
		Case "T_Err2_Tree6" : g_debug = 3 : g_debug_tree = Array( 2 )
		Case "T_Err2_Tree7" : g_debug = 2
		Case "T_Err2_TryStartWithErr" : g_debug = 1
		Case "T_Err2_Tree3_Child1" : g_debug = 3 : g_debug_tree = Array( 1, 2 ) : g_debug_process = 1
		Case "T_Err2_Tree3_Child2" : g_debug = 3 : g_debug_tree = Array( 1, 2 )
		Case "T_Err2_Tree3_PassRaise1" : g_debug = 4 : g_debug_tree = Array( 1, 2 )
		Case "T_Err2_Tree3_PassRaise2" : g_debug = 2 : g_debug_tree = Array( 1 )
	End Select

	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 2

	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
