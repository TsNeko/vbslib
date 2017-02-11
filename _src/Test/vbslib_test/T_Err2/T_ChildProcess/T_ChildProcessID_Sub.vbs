Option Explicit 

'//--------------------------------
Dim  g_SampleLib

Sub  InitializeModule_SampleLib  '// vbslib モジュールのグローバル・初期化関数に相当
	'// NewChildProcessOnStart の後で
	new_ObjectFromStream  g_SampleLib, "SampleLibClass", get_ChildProcess()
	If not IsEmpty( g_SampleLib ) Then
		If g_SampleLib.SampleCallID + 1 <> g_InterProcess.ProcessCallID(0) Then  Fail
		If g_SampleLib.SampleUserData <> g_InterProcess.InterProcessUserData Then  Fail

		g_InterProcess.InterProcessDataArray.Add  g_SampleLib
	End If
End Sub
'//--------------------------------


Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	include  "T_ChildProcessID_include.vbs"  '// define SampleClass
	InitializeModule_SampleLib  '// as InitializeModule in vbslib module in this

	Dim  pr, sample

	Set pr = get_ChildProcess()  ' as MainChildProcess
	new_ObjectFromStream  sample, "SampleClass", pr

	If WScript.Arguments.Named.Item("ChildProcess") = "0" Then
		If IsEmpty( sample ) Then  Pass
	End If

	Select Case  sample.SampleCallID + 1

	 Case 1
		If g_SampleLib.SampleCallID <> 0 Then  Fail
		If g_SampleLib.SampleUserData <> "1A" Then  Fail
		If g_InterProcess.ProcessCallID(0) <> 1 Then  Fail
		If g_InterProcess.InterProcessUserData <> "1A" Then  Fail
		g_InterProcess.InterProcessUserData = "1B"
		Pass

	 Case 2
		If g_SampleLib.SampleCallID <> 1 Then  Fail
		If g_SampleLib.SampleUserData <> "2A" Then  Fail
		If g_InterProcess.ProcessCallID(0) <> 2 Then  Fail
		If g_InterProcess.InterProcessUserData <> "2A" Then  Fail
		g_InterProcess.InterProcessUserData = "2B"
		Pass

	 Case 3
		If g_SampleLib.SampleCallID <> 2 Then  Fail
		If g_SampleLib.SampleUserData <> "3A" Then  Fail
		If g_InterProcess.ProcessCallID(0) <> 3 Then  Fail
		If g_InterProcess.InterProcessUserData <> "3A" Then  Fail
		g_InterProcess.InterProcessUserData = "3B"
		Pass

	End Select
	Fail
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

 
