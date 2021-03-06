Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Updater_MainFile",_
			"2","T_Updater_scriptlib",_
			"9","CleanHere" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_Updater_MainFile] >>> 
'*************************************************************************
Sub  T_Updater_MainFile( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "ans", "_out", "vbslib_headers" ) ).Enable()

	'// Set up
	unzip  "ans.zip", "ans", F_AfterDelete
	unzip  "vbslib_headers.zip", "vbslib_headers", F_AfterDelete
	prompt_path = SearchParent( "vbslib Prompt.vbs" )
	del  "_out"
	copy  "vbslib_headers\*", "_out"
	Assert  not exist( "_out\scriptlib" )

	'// Test Main
	RunProg  "cscript //nologo """+ prompt_path +""" ConvertToNewVbsLib  _out", ""

	'// Check
	Assert  fc( "_out", "ans" )

	'// Clean
	del  "_out"
	del  "ans"
	del  "vbslib_headers"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_Updater_scriptlib] >>> 
'*************************************************************************
Sub  T_Updater_scriptlib( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "T_Updater_scriptlib", "_out" ) ).Enable()
	T_Updater_scriptlib_Sub  '// for keeping writable in *_Finally function
	Pass
End Sub
Sub  T_Updater_scriptlib_Sub()
	Set fin = new FinObj : fin.SetFunc "T_Updater_scriptlib_Finally"
	Set section = new SectionTree
'//SetStartSectionTree  "T_Updater_scriptlib_Here"


	If section.Start( "T_Updater_scriptlib_1" ) Then

		'// Set up
		unzip  "T_Updater_scriptlib.zip", "T_Updater_scriptlib", F_AfterDelete
		prompt_path = SearchParent( "vbslib Prompt.vbs" )
		del  "_out"
		copy  "T_Updater_scriptlib\*", "_out"
		del  "_out\* updated answer"

		copy  SearchParent( "scriptlib\vbslib\vbslib_helper.exe" ), _
			"T_Updater_scriptlib\4.01 full updated answer\scriptlib\vbslib"


		'// Test Main
		RunProg  "cscript //nologo """+ prompt_path +""" ConvertToNewVbsLib  _out", ""


		'// Check
		Assert  fc( "_out\4.01 full", "T_Updater_scriptlib\4.01 full updated answer" )
		Assert  fc( "_out\4.01 part", "T_Updater_scriptlib\4.01 part updated answer" )
		Assert  fc( "_out\4.91 full", "T_Updater_scriptlib\4.91 full updated answer" )

		'// Clean
		del  "_out"
		del  "T_Updater_scriptlib"

	End If : section.End_


	If section.Start( "T_Updater_scriptlib_Here" ) Then

		'// Set up
		unzip  "T_Updater_scriptlib.zip", "T_Updater_scriptlib", F_AfterDelete
		prompt_path = SearchParent( "vbslib Prompt.vbs" )
		del  "_out"
		copy  "T_Updater_scriptlib\*", "_out"
		del  "_out\* updated answer"

		copy  SearchParent( "scriptlib\vbslib\vbslib_helper.exe" ), _
			"T_Updater_scriptlib\4.01 full updated answer\scriptlib\vbslib"


		'// Test Main
		RunProg  "cscript //nologo """+ prompt_path +""" ConvertToNewVbsLib  ""_out\4.01 full\scriptlib""", ""
		RunProg  "cscript //nologo """+ prompt_path +""" ConvertToNewVbsLib  ""_out\4.01 part\scriptlib""", ""


		'// Check
		Assert  fc( "_out\4.01 full\scriptlib", "T_Updater_scriptlib\4.01 full updated answer\scriptlib" )
		Assert  fc( "_out\4.01 part\scriptlib", "T_Updater_scriptlib\4.01 part updated answer\scriptlib" )

		'// Clean
		del  "_out"
		del  "T_Updater_scriptlib"

	End If : section.End_

End Sub
 Sub  T_Updater_scriptlib_Finally( Vars )
	en = Err.Number : ed = Err.Description : On Error Resume Next  '// This clears error

	echo_v  "T_Updater_scriptlib フォルダーを削除します。（RunRepliCmp.vbs のため）"
	del  "T_Updater_scriptlib"

	ErrorCheckInTerminate  en : On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
End Sub


 
'*************************************************************************
'  <<< [CleanHere] >>> 
'*************************************************************************
Sub  CleanHere( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "." ) ).Enable()

	del  "_out"
	del  "T_Updater_scriptlib"
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


 
