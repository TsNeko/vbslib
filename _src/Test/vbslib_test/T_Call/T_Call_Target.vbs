Sub  Main( Opt, AppKey )
	Set w_= AppKey.NewWritable( "." ).Enable()


	'//=== start
	EchoTestStart  "T_Call_start"
	del  "out1.txt"
	start  "cscript.exe out1.vbs /Opt1"
	WaitForFile  "out1.txt"
	del  "out1.txt"


	'//=== [T_WaitForFile]
	CreateFile  "out1.txt", "ABC"
	Assert  WaitForFile( "out1.txt" ) = "ABC"
	Assert  not exist( "out1.txt" )

	CreateFile  "out1.txt", ""
	Assert  WaitForFile( "out1.txt" ) = ""
	Assert  not exist( "out1.txt" )

	CreateFile  "out1.txt", "ABC"+vbCRLF+"DEF"
	Assert  WaitForFile( "out1.txt" ) = "ABC"
	Assert  not exist( "out1.txt" )


	CreateFile  "out1.txt", "<ERROR msg=""error""/>"
	If TryStart(e) Then  On Error Resume Next

		t = "x"
		t = WaitForFile( "out1.txt" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    "Next is Error Test"
	echo    e2.desc
	Assert  e2.desc = "<ERROR msg=""error""/>"
	Assert  e2.num = 1
	Assert  not exist( "out1.txt" )


	CreateFile  "out1.txt", "<?xml version=""1.0"" encoding=""Shift_JIS""?>"+ vbCRLF +"<ERROR num=""3"" msg=""エラー""/>"
	If TryStart(e) Then  On Error Resume Next

		t = "x"
		t = WaitForFile( "out1.txt" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    "Next is Error Test"
	echo    e2.desc
	Assert  e2.desc = "<ERROR num=""3"" msg=""エラー""/>"
	Assert  e2.num = 3
	Assert  not exist( "out1.txt" )


	'//=== call_vbs
	EchoTestStart  "T_Call_call_vbs"
	call_vbs  "call1.vbs", "Func1", ""
	t = call_vbs( "call1.vbs", "Func1", "out4" )
	If t <> "out4!" Then  Fail
	t = call_vbs( "call2.vbs", "Func1", "out5" )
	If t <> "out5#" Then  Fail
	t = call_vbs( "call1.vbs", "Func1", "out6" )
	If t <> "out6!" Then  Fail


	'//=== include
	EchoTestStart  "T_Call_include"
	If IsDefined( "FuncInInclude1" ) Then Fail
	include  "include1.vbs"
	If not IsDefined( "FuncInInclude1" ) Then Fail
	t = FuncInInclude1( "out7" )
	If t <> "out7$" Then  Fail


	'//=== env
	EchoTestStart  "T_Call_env"
	If env( "%windir%" ) = "%windir%" Then Fail
	If env( "%windir%" ) <> g_sh.ExpandEnvironmentStrings( "%windir%" ) Then Fail

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

 
