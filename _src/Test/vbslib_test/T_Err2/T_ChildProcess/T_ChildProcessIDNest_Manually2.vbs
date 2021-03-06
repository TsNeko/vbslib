Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		o.Lead = "すべてのテストが済んだら、ChildProcessIDNest_Clean を実行してください。"
		Set o.CommandReplace = Dict(Array(_
			"1","T_ChildProcessIDNest_Level_1",_
			"2","T_ChildProcessIDNest_Level_2",_
			"9","ChildProcessIDNest_Clean" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_ChildProcessIDNest_Level_1] >>> 
'*************************************************************************
Sub  T_ChildProcessIDNest_Level_1( Opt, AppKey )
	Const  state_path = "T_ChildProcessIDNest_Work.txt"
	Set w_=AppKey.NewWritable( Array( state_path, "_out.txt" ) ).Enable()
	Set c = g_VBS_Lib


	'// Test Main : Message
		'// T_ChildProcessIDNest_Sub "3"
		'// T_ChildProcessIDNest_SubSub "31"
	CreateFile  state_path, "3"
	ErrCheck : On Error Resume Next
		r= RunProg( "cscript.exe //nologo  T_ChildProcessIDNest_Sub.vbs /ChildProcess:0", "_out.txt" )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	g_Err2.Clear

	AssertFC  "_out.txt", "T_ChildProcessIDNest_Level_1_ans.txt"
	del  "_out.txt"


	'// Set up
	echo_line
	echo  "/g_debug:1;1 のテスト"
	echo  "T_ChildProcessIDNest_Level_1 とコメントしてある場所でブレークすること"
	Pause

	'// Test Main : Break
		'// T_ChildProcessIDNest_Sub "3"
		'// T_ChildProcessIDNest_SubSub "31"
	CreateFile  state_path, "3"
	r= RunProg( "cscript.exe T_ChildProcessIDNest_Sub.vbs /ChildProcess:0 /g_debug:1;1", "" )
	CheckTestErrLevel  r


	'// Check

	'// Clean
	del  state_path

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ChildProcessIDNest_Level_2] >>> 
'*************************************************************************
Sub  T_ChildProcessIDNest_Level_2( Opt, AppKey )
	Const  state_path = "T_ChildProcessIDNest_Work.txt"
	Set w_=AppKey.NewWritable( Array( state_path, "_out.txt" ) ).Enable()

	'// Test Main : Message
		'// T_ChildProcessIDNest_Sub "4"
		'// T_ChildProcessIDNest_SubSub "41"
		'// T_ChildProcessIDNest_SubSub "42"
		'// T_ChildProcessIDNest_SubSubSub "421"
	CreateFile  state_path, "4"
	ErrCheck : On Error Resume Next
		r= RunProg( "cscript.exe //nologo  T_ChildProcessIDNest_Sub.vbs /ChildProcess:0", "_out.txt" )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	g_Err2.Clear

	AssertFC  "_out.txt", "T_ChildProcessIDNest_Level_2_ans.txt"
	del  "_out.txt"


	'// Set up
	echo_line
	echo  "/g_debug:1;2,1 のテスト"
	echo  "T_ChildProcessIDNest_Level_2 とコメントしてある場所でブレークすること"
	Pause

	'// Test Main : Break
		'// T_ChildProcessIDNest_Sub "4"
		'// T_ChildProcessIDNest_SubSub "41"
		'// T_ChildProcessIDNest_SubSub "42"
		'// T_ChildProcessIDNest_SubSubSub "421"
	CreateFile  state_path, "4"
	r= RunProg( "cscript.exe T_ChildProcessIDNest_Sub.vbs /ChildProcess:0 /g_debug:1;2,1", "" )
	CheckTestErrLevel  r


	'// Check

	'// Clean
	del  state_path

	Pass
End Sub


 
'*************************************************************************
'  <<< [ChildProcessIDNest_Clean] >>> 
'*************************************************************************
Sub  ChildProcessIDNest_Clean( Opt, AppKey )
	Const  state_path = "T_ChildProcessIDNest_Work.txt"
	Set w_=AppKey.NewWritable( state_path ).Enable()
	del  state_path
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


 
