Sub  Main( Opt, AppKey )

	EchoTestStart  "T_ChildProcess0"



	'// Set up : Count Up "ErrID"
	If TryStart(e) Then  On Error Resume Next
	echo  "ErrID = "& e.ErrID
	Assert  e.ErrID = 0

		Error

	If TryEnd Then  On Error GoTo 0
	e.Clear
	echo  "ErrID = "& e.ErrID
	Assert  e.ErrID = 1


	EchoTestStart  "T_ChildProcess0_Sub"

	r= RunProg( "cscript.exe //nologo T_ChildProcess0_Sub.vbs /ChildProcess:0", "" )
	echo  "error level = "& r

	echo  "ErrID = "& e.ErrID
	Assert  e.ErrID = 1


	EchoTestStart  "T_ChildProcess0_ErrorMessage"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	r = 9999
	If TryStart(e) Then  On Error Resume Next

		r= RunProg( "cscript.exe //nologo T_ChildProcess0_Sub.vbs /Error", "" )
		echo  "error level = "& r

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2

	echo  "ErrID = "& e.ErrID
	Assert  e.ErrID = 2


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	r = 9999
	If TryStart(e) Then  On Error Resume Next

		r= RunProg( "cscript.exe //nologo T_ChildProcess0_Sub.vbs /ChildProcess:0 /Error", "" )
		echo  "error level = "& r

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2

	echo  "ErrID = "& e.ErrID
	Assert  e.ErrID = 3


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	r = 9999
	If TryStart(e) Then  On Error Resume Next

		r= RunProg( "cscript.exe //nologo T_ChildProcess0_NoVbsLib_Sub.vbs", "" )
		echo  "error level = "& r

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	r = 9999
	If TryStart(e) Then  On Error Resume Next

		r= RunProg( "cscript.exe //nologo T_ChildProcess0_NoVbsLibSyntaxError_Sub.vbs", "" )
		echo  "error level = "& r

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2


	r= g_sh.Run( "cscript.exe //nologo T_ChildProcess0_NoVbsLib_Sub.vbs",, True )
	echo  "error level = "& r

	r= g_sh.Run( "cscript.exe //nologo T_ChildProcess0_NoVbsLibSyntaxError_Sub.vbs",, True )
	echo  "error level = "& r


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

 
