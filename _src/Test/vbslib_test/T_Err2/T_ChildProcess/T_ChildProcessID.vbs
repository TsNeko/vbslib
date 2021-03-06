Option Explicit 

Dim  g_SampleLib

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	Dim  pr, r, sample, o

	include  "T_ChildProcessID_include.vbs"  '// define SampleClass
	Dim  start_call_id : start_call_id = g_InterProcess.ProcessCallID(0)

	Set sample = new SampleClass
	Set g_SampleLib = new SampleLibClass : g_InterProcess.InterProcessDataArray.Add  g_SampleLib


	'//=== 1st call
	EchoTestStart  "T_ChildProcessID_1"

	Set pr = new_ParentProcess()

	g_InterProcess.InterProcessUserData = "1A"
	Set o = sample
		o.SampleCallID   = g_InterProcess.ProcessCallID(0)
		o.SampleUserData = g_InterProcess.InterProcessUserData
	o = Empty
	pr.m_OutFile.WriteLine  sample.xml

	r= RunProg( "cscript.exe T_ChildProcessID_Sub.vbs", pr )
	CheckTestErrLevel  r

	If g_SampleLib.SampleCallID <> start_call_id + 1 Then  Fail
	If g_SampleLib.SampleUserData <> "1B" Then  Fail
	If g_InterProcess.ProcessCallID(0) <> start_call_id + 1 Then  Fail
	If g_InterProcess.InterProcessUserData <> "1B" Then  Fail


	'//=== 2nd call : pr uses continue
	EchoTestStart  "T_ChildProcessID_2"

	g_InterProcess.InterProcessUserData = "2A"
	With sample
		.SampleCallID   = g_InterProcess.ProcessCallID(0)
		.SampleUserData = g_InterProcess.InterProcessUserData
	End With
	pr.m_OutFile.WriteLine  sample.xml

	r= RunProg( "cscript.exe T_ChildProcessID_Sub.vbs", pr )
	CheckTestErrLevel  r

	If g_SampleLib.SampleCallID <> start_call_id + 2 Then  Fail
	If g_SampleLib.SampleUserData <> "2B" Then  Fail
	If g_InterProcess.ProcessCallID(0) <> start_call_id + 2 Then  Fail
	If g_InterProcess.InterProcessUserData <> "2B" Then  Fail


	'//=== 3rd call : pr is renewed after Class_Terminate(Empty)
	EchoTestStart  "T_ChildProcessID_3"

	pr = Empty
	Set pr = new_ParentProcess()

	g_InterProcess.InterProcessUserData = "3A"
	With sample
		.SampleCallID = g_InterProcess.ProcessCallID(0)
		.SampleUserData = g_InterProcess.InterProcessUserData
	End With
	pr.m_OutFile.WriteLine  sample.xml

	r= RunProg( "cscript.exe T_ChildProcessID_Sub.vbs", pr )
	CheckTestErrLevel  r

	If g_SampleLib.SampleCallID <> start_call_id + 3 Then  Fail
	If g_SampleLib.SampleUserData <> "3B" Then  Fail
	If g_InterProcess.ProcessCallID(0) <> start_call_id + 3 Then  Fail
	If g_InterProcess.InterProcessUserData <> "3B" Then  Fail


	'//=== pr is renewed before Class_Terminate, and Create ParentProcess only
	EchoTestStart  "T_ChildProcessID_4"

	Set pr = new_ParentProcess()
	pr = Empty


	'//=== Disable /ChildProcess
	EchoTestStart  "T_ChildProcessID_5"

	r= RunProg( "cscript.exe T_ChildProcessID_Sub.vbs /ChildProcess:0", "" )
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

 
