Sub  Main( Opt, AppKey )
	Set w_= AppKey.NewWritable( g_sh.SpecialFolders( "desktop" ) + "\_RepliCmp" ).Enable()
	Set opt = new RepliCmp_Option
	opt.m_EditorPath = Setting_getEditorCmdLine(0)
	opt.m_DiffPath = Setting_getDiffCmdLine(0)

	vbslib_root = "..\.."
	translate_path = vbslib_root +"\_src\_replica\3.Translate"
	echo  "Checking  "+ translate_path
	Assert  g_fs.FolderExists( translate_path )

	folder_en_path = translate_path +"\folder_en"
	echo  "Checking  "+ folder_en_path
	Assert not g_fs.FolderExists( folder_en_path )


	'[Setting]
	'====================================================================
	folders = Array( _
		g_fs.GetAbsolutePathName( vbslib_root +"\_src" ), _
		g_fs.GetAbsolutePathName( vbslib_root +"\samples" ), _
		g_fs.GetAbsolutePathName( vbslib_root +"\scriptlib" ) )

	files = Array( _
		"vbs_inc.vbs", _
		"vbs_inc_sub.vbs", _
		"vbslib.vbs", _
		"TestScript.vbs", _
		"VisualStudio.vbs", _
		"TestPrompt.vbs", _
		"MergeLib.vbs", _
		"Network.vbs", _
		"RepliCmpLib.vbs", _
		"SyncFilesMenuLib.vbs", _
		"System.vbs", _
		"ToolsLib.vbs", _
		"VbsLib4_Include.txt", _
		"VbsLib5_Include.txt", _
		"ShutdownMsgBox.vbs", _
		"PC_setting_default.vbs", _
		"TestPrompt_Setting_default.vbs", _
		"sample_main_prompt.vbs", _
		"sample_main_prompt_close.vbs", _
		"sample_main_window.vbs", _
		"sample_lib.vbs", _
		"zip.vbs", _
		"ConvSymbol.vbs", _
		"CommitCopyLib.vbs", _
		"CopyWithProcessDialog.vbs", _
		"OfficeLib.vbs", _
		"sudo_lib.vbs", _
		"ModuleMixer.vbs", _
		"SettingTemplate.xml", _
		"SettingForTest_pre.vbs", _
		"SettingForTest.vbs", _
		"UpdateFolderMD5List.cs" )
	'====================================================================

	RepliCmp  folders, files, opt
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


 
