Sub  Main( Opt, AppKey )
	include  "SettingForTest_pre.vbs"
	include  "SettingForTest.vbs"
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_SyncFiles2Folders",_
			"2","T_SyncFiles3Folders",_
			"3","T_SyncFilesMultiStepPathWithLabel",_
			"4","T_SyncFiles2FoldersEdit",_
			"5","T_SyncFiles3FoldersEdit",_
			"6","T_SyncFilesMenuIsSameFolder",_
			"7","T_SyncFilesParent" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SyncFiles2Folders] >>> 
'********************************************************************************
Sub  T_SyncFiles2Folders( Opt, AppKey )

	'// Test Main
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.Lead = "Comparing Base and Update"
	menu.AddRootFolder  0, "Folder0"
	menu.AddRootFolder  1, "Folder1"
	menu.AddFile  "NotSame.txt"
	menu.AddFile  "Only0.txt"
	menu.AddFile  "Only1.txt"
	menu.AddFile  "SameAll.txt"
	menu.AddFile  "NotExist.txt"
	menu.Compare

	SetVar  "Setting_getDiffCmdLine", "ArgsLog"
	set_input  "99."
	menu.OpenSyncMenu

	'// Checking menu contents in Test.vbs

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFiles3Folders] >>> 
'********************************************************************************
Sub  T_SyncFiles3Folders( Opt, AppKey )

	'// Test Main
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.Lead = "Comparing Base, Update1 and Update2"
	menu.AddRootFolder  0, "Folder0"
	menu.AddRootFolder  1, "Folder1"
	menu.AddRootFolder  2, "Folder2"
	menu.AddFile  "NotSame.txt"
	menu.AddFile  "NotSameNo0.txt"
	menu.AddFile  "NotSameNo1.txt"
	menu.AddFile  "NotSameNo2.txt"
	menu.AddFile  "Only0.txt"
	menu.AddFile  "Only1.txt"
	menu.AddFile  "Only2.txt"
	menu.AddFile  "Same01.txt"
	menu.AddFile  "Same01No2.txt"
	menu.AddFile  "Same02.txt"
	menu.AddFile  "Same02No1.txt"
	menu.AddFile  "Same12.txt"
	menu.AddFile  "Same12No0.txt"
	menu.AddFile  "SameAll.txt"
	menu.AddFile  "NotExist.txt"
	menu.Compare

	SetVar  "Setting_getDiffCmdLine", "ArgsLog"
	set_input  "99."
	menu.OpenSyncMenu

	'// Checking menu contents in Test.vbs

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesMultiStepPathWithLabel] >>> 
'********************************************************************************
Sub  T_SyncFilesMultiStepPathWithLabel( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt" ) ).Enable()
	RunProg  "cscript //nologo  "+ WScript.ScriptName +" T_SyncFilesMultiStepPathWithLabel_Sub", "_out.txt"
	AssertFC  "_out.txt", "T_SyncFilesMultiStepPathWithLabel_ans.txt"
	del  "_out.txt"
	Pass
End Sub

Sub  T_SyncFilesMultiStepPathWithLabel_Sub( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( Array( "ArgsLog.txt" ) ).Enable()

	'// Test Main
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.Lead = "Comparing Base, Update1 and Update2"
	menu.AddRootFolder  0, "Folder0"
	menu.AddRootFolder  1, "Folder1"
	menu.AddRootFolder  2, "Folder2"
	menu.AddFile  "NotSame.txt"
	menu.AddFileWithLabel  "This is FileLabel", Array( "Only0.txt", "Same01.txt", "Same02.txt" )
	menu.Compare

	c_LF = g_CUI.m_Auto_KeyEnter

	input_keys =             "1"+c_LF
	input_keys = input_keys +"2"+c_LF
	input_keys = input_keys +"99"+c_LF
	set_input  input_keys

	del  "ArgsLog.txt"
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"
	SetVar  "Setting_getEditorCmdLine", "ArgsLog"
	menu.OpenSyncMenu

	'// Check
	IsSameTextFile  "ArgsLog.txt", "T_SyncFilesMultiStepPathWithLabel_log_ans.txt", _
		c.RightHasPercentFunction or c.ErrorIfNotSame
	del  "ArgsLog.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFiles2FoldersEdit] >>> 
'********************************************************************************
Sub  T_SyncFiles2FoldersEdit( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( "." ).Enable()

	'// Test Main
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.Lead = "Comparing Base and Update"
	menu.AddRootFolder  0, "Folder0"
	menu.AddRootFolder  1, "Folder1"
	menu.AddFile  "NotSame.txt"
	menu.AddFile  "Only0.txt"
	menu.AddFile  "Only1.txt"
	menu.AddFile  "SameAll.txt"
	menu.AddFile  "NotExist.txt"
	menu.Compare

	c_LF = g_CUI.m_Auto_KeyEnter

	input_keys = "1"+c_LF+"1"+c_LF   '// Diff
	input_keys = input_keys +"4"+c_LF   '// TextEditor
	input_keys = input_keys +"6"+c_LF   '// TextEditor no file
	input_keys = input_keys +"99"+c_LF +"99"+c_LF
	set_input  input_keys

	del  "ArgsLog.txt"
	SetVar  "Setting_getDiffCmdLine", "DiffCUI"
	SetVar  "Setting_getEditorCmdLine", "ArgsLog"
	menu.OpenSyncMenu

	'// Check
	IsSameTextFile  "ArgsLog.txt", "T_SyncFiles2FoldersEdit_log_ans.txt", _
		c.RightHasPercentFunction or c.ErrorIfNotSame
	del  "ArgsLog.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFiles3FoldersEdit] >>> 
'********************************************************************************
Sub  T_SyncFiles3FoldersEdit( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( Array( "ArgsLog.txt", "Folder2_work" ) ).Enable()

	'// Set up
	copy  "Folder2\*", "Folder2_work"

	'// Test Main
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.Lead = "Comparing Base, Update1 and Update2"
	menu.AddRootFolder  0, "Folder0"
	menu.AddRootFolder  1, "Folder1"
	menu.AddRootFolder  2, "Folder2_work"
	menu.AddFile  "NotSame.txt"
	menu.AddFile  "NotSameNo0.txt"
	menu.AddFile  "NotSameNo1.txt"
	menu.AddFile  "NotSameNo2.txt"
	menu.AddFile  "Only0.txt"
	menu.AddFile  "Only1.txt"
	menu.AddFile  "Only2.txt"
	menu.AddFile  "Same01.txt"
	menu.AddFile  "Same01No2.txt"
	menu.AddFile  "Same02.txt"
	menu.AddFile  "Same02No1.txt"
	menu.AddFile  "Same12.txt"
	menu.AddFile  "Same12No0.txt"
	menu.AddFile  "SameAll.txt"
	menu.AddFile  "NotExist.txt"
	menu.Compare

	c_LF = g_CUI.m_Auto_KeyEnter

	input_keys = "1"+c_LF+"1"+c_LF+"4"+c_LF+"5"+c_LF   '// Diff
	input_keys = input_keys +"4"+c_LF                  '// TextEditor
	input_keys = input_keys +"46"+c_LF+"y"+c_LF        '// Copy
	input_keys = input_keys +"99"+c_LF +"99"+c_LF      '// Exit
	set_input  input_keys

	del  "ArgsLog.txt"
	SetVar  "Setting_getDiffCmdLine", "DiffCUI"
	SetVar  "Setting_getEditorCmdLine", "ArgsLog"
	menu.OpenSyncMenu

	'// Check
	IsSameTextFile  "ArgsLog.txt", "T_SyncFiles3FoldersEdit_log_ans.txt", c.RightHasPercentFunction or c.ErrorIfNotSame
	IsSameTextFile  "Folder0\NotSame.txt", "Folder2_work\NotSame.txt", c.ErrorIfNotSame
	del  "ArgsLog.txt"

	'// Clean
	del  "Folder2_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesMenuIsSameFolder] >>> 
'********************************************************************************
Sub  T_SyncFilesMenuIsSameFolder( Opt, AppKey )
	Set w_=AppKey.NewWritable( "Folder0_copy" ).Enable()

	'// Set up
	copy  "Folder0\*", "Folder0_Copy"

	'// Test Main (1)
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.Lead = "Comparing Base, Update1 and Update2"
	menu.AddRootFolder  0, "Folder0"
	menu.AddRootFolder  1, "Folder0_Copy"
	menu.AddRootFolder  2, "Folder2"
	menu.AddFile  "NotSame.txt"
	menu.AddFile  "SameAll.txt"
	menu.Compare

	'// Check (1)
	Assert  menu.IsSameFolder( 0, 1 )
	Assert  not menu.IsSameFolder( 0, 2 )
	Assert  not menu.IsSameFolder( 1, 2 )


	'// Test Main (2)
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.Lead = "Comparing Base, Update1 and Update2"
	menu.AddRootFolder  0, "Folder2"
	menu.AddRootFolder  1, "Folder0_Copy"
	menu.AddRootFolder  2, "Folder0"
	menu.AddFile  "NotSame.txt"
	menu.AddFile  "SameAll.txt"
	menu.Compare

	'// Check (2)
	Assert  not menu.IsSameFolder( 0, 1 )
	Assert  not menu.IsSameFolder( 0, 2 )
	Assert  menu.IsSameFolder( 1, 2 )


	'// Clean
	del  "Folder0_copy"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesParent] >>> 
'********************************************************************************
Sub  T_SyncFilesParent( Opt, AppKey )

	'// Test Main
	Set menu = new SyncFilesMenu
	menu.IsCompareTimeStamp = False
	menu.AddRootFolder  0, "Folder0"
	menu.AddRootFolder  1, "T_SyncFilesParent"
	menu.SetParentFolderProxyName  1, "_parent"
	menu.RootFolders(0).Label = "Base"
	menu.RootFolders(1).Label = "FolderA"
	menu.AddFile  "..\Folder0\SameAll.txt"
	menu.Compare

	'// Check
	Assert  menu.IsSameFolder( 0, 1 )

	'// Test Main
	menu.AddFile  "..\Folder0\NotSame.txt"
	menu.Compare

	'// Check
	Assert  not menu.IsSameFolder( 0, 1 )

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

 
