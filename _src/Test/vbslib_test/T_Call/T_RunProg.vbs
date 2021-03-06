Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_RunProg_VBS",_
			"2","T_RunProg_Batch" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_RunProg_VBS] >>> 
'*************************************************************************
Sub  T_RunProg_VBS( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	del  "_out.txt"
	RunProg  "cscript.exe //nologo "+ WScript.ScriptName +" T_RunProg_VBS_Sub", "_out.txt"
	AssertFC  "_out.txt", "T_RunProg_VBS_ans.txt"
	del  "_out.txt"
End Sub


Sub  T_RunProg_VBS_Sub( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	del  "out2a.txt" :  del  "out2b.txt" : del  "out"  : del  "out2d.txt"  : del  "out2e.txt"

	'// Test Main
	RunProg  "cscript.exe //nologo out2.vbs", Empty
	RunProg  "cscript.exe //nologo out2.vbs", ""

	echo  "Start of nul"
	RunProg  "cscript.exe //nologo out2.vbs", "nul"
	echo  "End of nul"

	echo  "Start of NotEchoStartCommand"
	RunProg  "cscript.exe //nologo out2.vbs", g_VBS_Lib.NotEchoStartCommand
	echo  "End of NotEchoStartCommand"

	echo  "Start of EchoOff"
	Set ec = new EchoOff
	RunProg  "cscript.exe //nologo out2.vbs", Empty
	ec = Empty
	echo  "End of EchoOff"

	echo  "Start of EchoOff and redirect"
	Set ec = new EchoOff
	RunProg  "cscript.exe //nologo out2.vbs", "out2e.txt"
	ec = Empty
	echo  "End of EchoOff and redirect"

	RunProg  "cscript.exe //nologo out2.vbs", "out2b.txt"
	RunProg  "cscript.exe //nologo out2.vbs", "out\out2c.txt"
	RunProg  "cscript.exe //nologo out2.vbs", "out2d.txt"
	RunProg  "cscript.exe //nologo out2.vbs", "out2d.txt"

	'// Check
	t = ReadFile( "out2a.txt" ) : If t <> "out2a" Then  Fail
	t = ReadFile( "out2b.txt" ) : If t <> "out2b"+vbCRLF Then  Fail
	t = ReadFile( "out\out2c.txt" ) : If t <> "out2b"+vbCRLF Then  Fail
	t = ReadFile( "out2d.txt" ) : If t <> "out2b"+vbCRLF Then  Fail
	t = ReadFile( "out2e.txt" ) : If t <> "out2b"+vbCRLF Then  Fail

	'// Clean
	del  "out2a.txt" :  del  "out2b.txt" : del  "out"  : del  "out2d.txt"  : del  "out2e.txt"

	'// Test Main and Check : no file
	On Error Resume Next
		RunProg  "cscript //nologo  NotFound.vbs", ""
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 0 Then  Fail
	g_Err2.Clear

	'// Test Main and Check : compile error
	On Error Resume Next
		RunProg  "cscript //nologo  compile_err.vbs", ""
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 0 Then  Fail
	g_Err2.Clear

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_RunProg_Batch] >>> 
'*************************************************************************
Sub  T_RunProg_Batch( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	del  "_out.txt"
	RunProg  "cscript.exe //nologo "+ WScript.ScriptName +" T_RunProg_Batch_Sub", "_out.txt"
	AssertFC  "_out.txt", "T_RunProg_Batch_ans.txt"
	del  "_out.txt"
End Sub


Sub  T_RunProg_Batch_Sub( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	del  "out3.txt"

	'// Test Main
	RunProg  "cmd /C bat1.bat > out3.txt", ""

	'// Check
	t = ReadFile( "out3.txt" ) : If t <> "bat1"+vbCRLF Then  Fail

	'// Clean
	del  "out3.txt"

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


 
