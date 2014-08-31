Option Explicit

Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_CopyTagFiles",_
			"2","T_CopyExists" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_CopyTagFiles] >>> 
'********************************************************************************
Sub  T_CopyTagFiles( Opt, AppKey )
	EchoTestStart  "T_CopyTagFiles"
	Dim  c : Set c = g_VBS_Lib
	Dim w_:Set w_=AppKey.NewWritable( "T_Tag_work" ).Enable()

	del      "T_Tag_work"
	copy_ex  "T_Tag_data\*_tag1.*", "T_Tag_work", c.CutTag
	Assert  fc( "T_Tag_work\fo", "T_Tag_ans" )

	del      "T_Tag_work"
	copy_ex  "T_Tag_data\fo\*_tag1.*", "T_Tag_work", c.CutTag
	Assert  fc( "T_Tag_work", "T_Tag_ans" )

	del      "T_Tag_work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CopyExists] >>> 
'********************************************************************************
Sub  T_CopyExists( Opt, AppKey )
	EchoTestStart  "T_CopyExists"
	Dim  c : Set c = g_VBS_Lib
	Dim w_:Set w_=AppKey.NewWritable( "T_Exist_work" ).Enable()

	del      "T_Exist_work"
	copy     "T_Exist_data\*",  "T_Exist_work"
	copy_ex  "T_Tag_data\fo\*", "T_Exist_work", c.ExistOnly
	Assert  fc( "T_Exist_work", "T_Exist_ans" )

	del      "T_Exist_work"
	Pass
End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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

 
