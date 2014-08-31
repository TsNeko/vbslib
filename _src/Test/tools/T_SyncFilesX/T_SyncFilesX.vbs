Sub  Main( Opt, AppKey )
	include  "SettingForTest_pre.vbs"
	include  "SettingForTest.vbs"

	Set o = new InputCommandOpt
		o.Lead = "SyncFilesX を試す：SyncFilesX_Command (略語：sc)"
		Set o.CommandReplace = Dict(Array(_
			"1", "T_SyncFilesX_1",_
			"2", "T_SyncFilesX_Folder",_
			"3", "T_SyncFilesX_AutoSame",_
			"4", "T_SyncFilesX_CommandLine",_
			"5", "T_SyncFilesX_RootFolders_UI",_
			"6", "T_SyncFilesX_RootFolders",_
			"7", "T_SyncFilesX_Clone",_
			"8", "T_SyncFilesX_FileList" ))
			'// SyncFilesX_Command
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_1] >>> 
'********************************************************************************
Sub  T_SyncFilesX_1( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_1_Sub /set_input:"+_
		"10.8.9.98.y.99.", "_out.txt"
		'// 10:"SubForWork\UpdateWork_WorkOnly.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_1_EchoAnswer.txt"

	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_1_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_Folder] >>> 
'********************************************************************************
Sub  T_SyncFilesX_Folder( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	key = ""
	key = key +"1.8.y.9."  '// 1
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."  '// 5
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."  '// 10
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."  '// 15
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."  '// 20
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
		'// エラーにならないこと

	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_Folder_Sub /set_input:"+_
		key +"99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_Folder_EchoAnswer.txt"

	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_Folder_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Folder.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_AutoSame] >>> 
'********************************************************************************
Sub  T_SyncFilesX_AutoSame( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	key = ""
	key = key +"1.8.9."    '// 1
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."  '// 5
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."    '// 10
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.9."    '// 15
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."  '// 20
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
		'// エラーにならないこと

	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_AutoSame_Sub /set_input:"+_
		key +"99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_Auto_EchoAnswer.txt"

	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_AutoSame_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Auto.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_CommandLine] >>> 
'********************************************************************************
Sub  T_SyncFilesX_CommandLine( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	Assert  not IsSynchronizedFilesX( new_FilePathForFileInScript( "FilesA\Project - Synced\SyncFilesX.vbs" ) )

	'// Test Main
	Assert      IsSynchronizedFilesX( "FilesA\Project - Synced\SyncFilesX_Synced.xml" )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Assert  IsSynchronizedFilesX( "NotFound.xml" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_PathNotFound

	'// Clean
	del  "FilesA"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_RootFolders_UI] >>> 
'********************************************************************************
Sub  T_SyncFilesX_RootFolders_UI( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "_work" ) ).Enable()

	'// Set up
	del  "_work"
	unzip2  "FilesB.zip", "_work"

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_RootFolders_UI_Sub "+_
		"/set_input:1.1.9.99.2.1.8.9.99.99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_RootFolders_EchoAnswer.txt"

	'// Clean
	del  "_work"
	del  "_out.txt"

	Pass
End Sub


Sub  T_SyncFilesX_RootFolders_UI_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_RootFolders] >>> 
'********************************************************************************
Sub  T_SyncFilesX_RootFolders( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()

	'// Set up
	del  "_work"
	unzip2  "FilesB.zip", "_work"

	SetVar  "Setting_getDiffCmdLine", "ArgsLog"
	g_CUI.m_Auto_KeyEnter = "."
	set_input  "1.1.8.y.y.9.99.2.1.8.y.y.9.99.99."

	'// Test Main
	Set sync = new SyncFilesX_Class
	path = "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	result = sync.OpenCUI()

	'// Check
	del  "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	Assert  fc( "_work\FilesB", "Files\FilesB_Answer" )
	SetVar  "Setting_getDiffCmdLine", ""

	'// Clean
	del  "_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_Clone] >>> 
'********************************************************************************
Sub  T_SyncFilesX_Clone( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "FilesA", "_out.txt" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_Clone_Sub /set_input:"+_
		"14.8.y.9.97.19.9.99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_Clone_EchoAnswer.txt"


	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub


Sub  T_SyncFilesX_Clone_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Clone.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_FileList] >>> 
'********************************************************************************
Sub  T_SyncFilesX_FileList( Opt, AppKey )
	out_path = g_sh.SpecialFolders( "Desktop" )+"\_SyncFiles.txt"
	Set w_=AppKey.NewWritable( Array( "_work", out_path ) ).Enable()

	'// Set up
	del  "_work"
	unzip2  "FilesB.zip", "_work"
	g_CUI.m_Auto_KeyEnter = "."
	set_input  "98..99."

	'// Test Main
	Set sync = new SyncFilesX_Class
	path = "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	result = sync.OpenCUI()

	'// Check
	AssertFC  out_path, "Files\T_SyncFilesX_FileList_EchoAnswer.txt"

	'// Clean
	del  "_work"
	del  out_path

	Pass
End Sub


 
'********************************************************************************
'  <<< [sc] >>> 
'********************************************************************************
Sub  sc( Opt, AppKey )
	SyncFilesX_Command  Opt, AppKey
End Sub


'********************************************************************************
'  <<< [SyncFilesX_Command] >>> 
'********************************************************************************
Sub  SyncFilesX_Command( Opt, AppKey )
	Set c = g_VBS_Lib

	'// UI
	path = InputPath( "SyncFilesX XML path>", c.CheckFileExists )
	echo_line

	'// Main
	Set sync = new SyncFilesX_Class
	Do
		sync.LoadScanListUpAll  path, ReadFile( path )
		Set w_=AppKey.NewWritable( AddArrElemEx( sync.GetWritableFolders(), _
			g_sh.SpecialFolders( "Desktop" ), True ) ).Enable()
		result = sync.OpenCUI()

		If result = "Exit" Then  Exit Do
	Loop
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


 
