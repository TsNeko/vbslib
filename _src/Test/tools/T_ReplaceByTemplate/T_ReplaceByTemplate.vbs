Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_ReplaceByTemplate" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_ReplaceByTemplate
'***********************************************************************
Sub  T_ReplaceByTemplate( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set c = g_VBS_Lib
	Set section = new SectionTree
'//SetStartSectionTree  "T_ReplaceByTemplate_VariableLength"


	'//===========================================================
	If section.Start( "T_ReplaceByTemplate_1" ) Then

	'// Set up
	del  "_work"
	copy  "Files\1\1_Before\a.txt", "_work"

	'// Test Main
	Set Me_ = new_ReplaceTemplateClass( "Files\ReplaceTemplateMin.xml" )
	Me_.SetTargetPath  "_work"
	Set w_=AppKey.NewWritable( Me_.TargetFolders.FullPaths ).Enable()
	Me_.RunReplace

	'// Check
	AssertFC  "_work\a.txt", "Files\1\2_After\a.txt"

	'// Clean
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ReplaceByTemplate_2" ) Then

	For Each  target_path  In  Array( _
			"_work", _
			Array( "_work\a.txt", "_work\b.txt" ) )

		'// Set up
		del  "_work"
		copy  "Files\2\1_Before\*", "_work"

		'// Test Main
		Set Me_ = new_ReplaceTemplateClass( "Files\ReplaceTemplate2.xml" )
		Me_.SetTargetPath  target_path
		Set w_=AppKey.NewWritable( Me_.TargetFolders.FullPaths ).Enable()
		Me_.RunReplace

		'// Check
		AssertFC  "_work\a.txt", "Files\2\2_After\a.txt"
		AssertFC  "_work\b.txt", "Files\2\2_After\b.txt"

		'// Clean
		Set w_=AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ReplaceByTemplate_SettingFolder" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_SettingFolder\1_Before\*", "_work"

	'// Test Main
	Set Me_ = new_ReplaceTemplateClass( "Files\T_SettingFolder\Setting" )
	Me_.SetTargetPath  "_work"
	Set w_=AppKey.NewWritable( Me_.TargetFolders.FullPaths ).Enable()
	Me_.RunReplace

	'// Check
	AssertFC  "_work\a.txt", "Files\T_SettingFolder\2_After\a.txt"
	AssertFC  "_work\b.txt", "Files\T_SettingFolder\2_After\b.txt"

	'// Clean
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ReplaceByTemplate_VariableLength" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_VariableLength\1_Before\*", "_work"

	'// Test Main
	Set Me_ = new_ReplaceTemplateClass(  "Files\T_VariableLength\ReplaceTemplate.xml" )
	Me_.SetTargetPath  "_work"
	Set w_=AppKey.NewWritable( Me_.TargetFolders.FullPaths ).Enable()
	Me_.RunReplace

	'// Check
	AssertFC  "_work\a.txt", "Files\T_VariableLength\2_After\a.txt"

	'// Clean
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	End If : section.End_

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


 
