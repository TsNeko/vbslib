Option Explicit 

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Processes",_
			"2","T_WaitForProcess" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Processes] >>> 
'********************************************************************************
Sub  T_Processes( Opt, AppKey )
	Dim  ps, exe_path, exe_name

	exe_path = g_vbslib_folder +"SleepInfinity\SleepInfinity.exe"
	exe_name = "SleepInfinity.exe"


	'//=========================================
	EchoTestStart  "T_KillProcess"

	'// set up
	start  """"+ exe_path +""""

	'// Test Main
	KillProcess  exe_name

	'// check
	Assert  not EnumProcesses().Exists( exe_name )


	'//=========================================
	EchoTestStart  "T_KillProcess0"

	'// set up
	Assert  not EnumProcesses().Exists( exe_name )

	'// Test Main
	KillProcess  exe_name

	'// check
	Assert  not EnumProcesses().Exists( exe_name )


	'//=========================================
	EchoTestStart  "T_EnumProcesses"

	'// set up
	Assert  not EnumProcesses().Exists( exe_name )
	start  """"+ exe_path +""""

	'// Test Main
	Set ps = EnumProcesses()

	'// check
	Assert  ps.Item( exe_name ).Count = 1
	KillProcess  exe_name
	Assert  not EnumProcesses().Exists( exe_name )


	'//=========================================
	EchoTestStart  "T_EnumProcesses2"
	EchoTestStart  "T_KillProcesses2"

	'// set up
	Assert  not EnumProcesses().Exists( exe_name )

	'// Test Main
	start  """"+ exe_path +""""
	start  """"+ exe_path +""""
	Set ps = EnumProcesses()

	'// check
	Assert  ps.Item( exe_name ).Count = 2

	'// Test Main
	KillProcess  exe_name

	'// check
	Assert  not EnumProcesses().Exists( exe_name )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_WaitForProcess] >>> 
'********************************************************************************
Sub  T_WaitForProcess( Opt, AppKey )
	Dim  text
	Dim w_:Set w_=AppKey.NewWritable( "out.txt" ).Enable()

	'// set up
	del  "out.txt"

	'// Test Main
	start  "T_Process_Sub.exe  SleepedFinish  1000 out.txt 1"
	start  "T_Process_Sub.exe  SleepedFinish  1500 out.txt 2"
	WaitForProcess  "T_Process_Sub.exe"

	'// check
	text = ReadFile( "out.txt" )
	Assert  text = "1"+vbCRLF+"2"+vbCRLF

	'// clean
	del  "out.txt"

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


 
