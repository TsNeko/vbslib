Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_SyncByShortcut" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SyncByShortcut] >>> 
'********************************************************************************
Sub  T_SyncByShortcut( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_SyncByShortcut_3"

	prompt_exe = SearchParent( "vbslib Prompt.vbs" )
	work = GetFullPath( "T_SyncByShortcut", Empty )
	Set w_=AppKey.NewWritable( work ).Enable()

	'//===========================================================
	If section.Start( "T_SyncByShortcut_2" ) Then

	'// Set up
	unzip  "T_SyncByShortcut.zip", "T_SyncByShortcut", F_AfterDelete

	For Each  t  In DicTable( Array( _
		"ShortCutPath",  "TargetPath",  Empty, _
		"1-A.lnk",   "1\A.txt", _
		"1-B.lnk",   "1\B.txt", _
		"2-s-A.lnk", "2\sub\A.txt", _
		"2-s-B.lnk", "2\sub\B.txt" ) )

		Set shcut = g_sh.CreateShortcut( "T_SyncByShortcut\"+ t("ShortCutPath") )
		shcut.TargetPath = g_sh.CurrentDirectory +"\T_SyncByShortcut\"+ t("TargetPath")
		shcut.Save
		shcut = Empty
	Next

	text = CStr( Now() )
	CreateFile  work +"\1\A.txt", text
	CreateFile  work +"\1\sub\A.txt", text
	CreateFile  work +"\2\B.txt", text


	'// Test Main
	r= RunProg( "cscript //nologo """+ prompt_exe +""" SyncByShortcut  """+ _
		work +"\!SyncByShortcut.xml"" """"", "" )
	CheckTestErrLevel  r

	'// Check
	Assert  ReadFile( work +"\1\B.txt" ) = text
	Assert  ReadFile( work +"\2\A.txt" ) = text
	Assert  ReadFile( work +"\2\sub\A.txt" ) = text

	'// Clean
	del  "T_SyncByShortcut"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_SyncByShortcut_3" ) Then

	For Each  folder_name  In  Array( "1", "2", "3" )

		'// Set up
		unzip  "T_SyncByShortcut.zip", "T_SyncByShortcut", F_AfterDelete

		For Each  t  In DicTable( Array( _
			"ShortCutPath",  "TargetPath",  Empty, _
			"3.lnk",   "1\3.txt" ) )

			Set shcut = g_sh.CreateShortcut( "T_SyncByShortcut\"+ t("ShortCutPath") )
			shcut.TargetPath = g_sh.CurrentDirectory +"\T_SyncByShortcut\"+ t("TargetPath")
			shcut.Save
			shcut = Empty
		Next


		'// Set up
		text = CStr( Now() ) + folder_name
		CreateFile  work +"\"+ folder_name +"\3.txt", text

		'// Test Main
		r= RunProg( "cscript //nologo """+ prompt_exe +""" SyncByShortcut  """+ _
			work +"\!SyncByShortcut3.xml"" """"", "" )
		CheckTestErrLevel  r

		'// Check
		Assert  ReadFile( work +"\1\3.txt" ) = text
		Assert  ReadFile( work +"\2\3.txt" ) = text
		Assert  ReadFile( work +"\3\3.txt" ) = text
	Next

	'// Clean
	del  "T_SyncByShortcut"

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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
