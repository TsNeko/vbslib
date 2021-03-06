'------------------------------------------------------------[FileInScript.xml]
'<MakeCrossOld>
'	<Renames>
'		<!-- <Rename  old=""  new=""/> -->
'	</Renames>
'</MakeCrossOld>
'-----------------------------------------------------------[/FileInScript.xml]

Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_MakeCrossOld_New" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_MakeCrossOld_New
'***********************************************************************
Sub  T_MakeCrossOld_New( Opt, AppKey )
	Set root = LoadXML( new_FilePathForFileInScript( Empty ), Empty )
	Set c = g_VBS_Lib

	ExpandWildcard  "1A*",  c.Folder,  folder,  step_paths : path_1A = step_paths(0)
	ExpandWildcard  "1B*",  c.Folder,  folder,  step_paths : path_1B = step_paths(0)
	ExpandWildcard  "2A*",  c.Folder,  folder,  step_paths : path_2A = step_paths(0)
	ExpandWildcard  "2B*",  c.Folder,  folder,  step_paths : path_2B = step_paths(0)

	Set w_=AppKey.NewWritable( "." ).Enable()


	folder = "Before"
	If not exist( folder ) Then
		copy  path_1A,  folder
		copy  path_1B,  folder
		copy  path_2A,  folder
		copy  path_2B,  folder
	End If

	folder = "BeforeNoTag"
	If not exist( folder ) Then
		copy  path_1A,  folder
		copy  path_1B,  folder
		copy  path_2A,  folder
		copy  path_2B,  folder
	End If


	folder  = "CrossByToolNew"
	folder2 = "CrossByTool"
	If not exist( folder2 )  and  exist( folder ) Then
		move_ren  folder, folder2
	End If


	folder = "CrossByToolNew\"
	del  "CrossByToolNew"
	For Each  t  In DicTable( Array( _
		"OutPath",         "NewPath",  "OldPath",           "NewTxsc",   "OldTxsc", Empty, _
		folder + path_1A,   path_1A,   "Before\"+ path_1A,  "_txsc\1A",  "_txsc\1A_Before", _
		folder + path_1B,   path_1B,   "Before\"+ path_1B,  "_txsc\1B",  "_txsc\1B_Before", _
		folder + path_2A,   path_1A,   "Before\"+ path_2A,  "_txsc\2A",  "_txsc\2A_Before", _
		folder + path_2B,   path_1B,   "Before\"+ path_2B,  "_txsc\2B",  "_txsc\2B_Before" ) )

		MakeCrossedOldSections  t("OutPath"), t("NewPath"), t("OldPath"), _
			folder + t("NewTxsc"),  folder + t("OldTxsc"),  root.selectSingleNode( "./Renames" )
	Next


	folder  = "CrossByToolNew"
	folder2 = "CrossBefore"
	If not exist( folder2 ) Then
		copy_ren  folder, folder2
	End If


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
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
