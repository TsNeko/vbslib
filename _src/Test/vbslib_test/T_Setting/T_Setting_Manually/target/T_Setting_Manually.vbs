Option Explicit 

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Setting_Manually" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Setting_Manually] >>> 
'********************************************************************************
Sub  T_Setting_Manually( Opt, AppKey )
	Dim  r
	Dim  default_setting_path : default_setting_path = g_vbslib_ver_folder +"setting_default"
	Dim  custom_setting_path  : custom_setting_path  = g_vbslib_ver_folder +"setting"
	Dim  machine_setting_path : machine_setting_path = g_sh.ExpandEnvironmentStrings( "%APPDATA%\Scripts" )
	Dim  usbmem_setting_path  : usbmem_setting_path  = g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\scriptlib\setting_mem" )

	If g_sh.ExpandEnvironmentStrings( "%myhome_mem%" ) = "%myhome_mem%" Then _
		Raise  1, "myhome_mem 環境変数を設定してください"

	echo  "default_setting_path = """+ default_setting_path +""""
	echo  "machine_setting_path = """+ machine_setting_path +""""
	echo  "usbmem_setting_path  = """+ usbmem_setting_path +""""
	echo  "custom_setting_path  = """+ custom_setting_path  +""""
	echo_line
	echo  "上記の設定でテストを行います。"
	echo  "上記の setting フォルダーのパスが合っていなければ、このウィンドウを閉じて、"+_
		"テスト・スクリプトを修正してください。"

	pause

	echo  "設定ファイル T_Setting_getIdentification.vbs を作成します。"
	echo  "machine_setting_path に書き込みを許可してください。"
	pause

	Dim w_:Set w_=AppKey.NewWritable( Array( default_setting_path, machine_setting_path, _
		usbmem_setting_path, custom_setting_path ) ).Enable()

	'// set up
	MakeSettingScript  default_setting_path, "1"
	MakeSettingScript  usbmem_setting_path,  "2"
	MakeSettingScript  machine_setting_path, "3"
	MakeSettingScript  custom_setting_path,  "4"
	EchoExist  default_setting_path, machine_setting_path, usbmem_setting_path, custom_setting_path

	'// Test Main
	r= RunProg( "cscript T_Setting_Manually_main.vbs  4", "" )

	'// check
	If r <> 21 Then  Err.Raise  1,,"ERROR"

	'// set up
	MakeSettingScript  custom_setting_path,  Empty
	EchoExist  default_setting_path, machine_setting_path, usbmem_setting_path, custom_setting_path

	'// Test Main
	r= RunProg( "cscript T_Setting_Manually_main.vbs  3", "" )

	'// check
	If r <> 21 Then  Err.Raise  1,,"ERROR"

	'// set up
	MakeSettingScript  machine_setting_path,  Empty
	EchoExist  default_setting_path, machine_setting_path, usbmem_setting_path, custom_setting_path

	'// Test Main
	r= RunProg( "cscript  T_Setting_Manually_main.vbs  2", "" )

	'// check
	If r <> 21 Then  Err.Raise  1,,"ERROR"

	'// set up
	MakeSettingScript  usbmem_setting_path,  Empty
	EchoExist  default_setting_path, machine_setting_path, usbmem_setting_path, custom_setting_path

	'// Test Main
	r= RunProg( "cscript  T_Setting_Manually_main.vbs  1", "" )

	'// check
	If r <> 21 Then  Err.Raise  1,,"ERROR"

	'// clean
	MakeSettingScript  default_setting_path,  Empty
	EchoExist  default_setting_path, machine_setting_path, usbmem_setting_path, custom_setting_path
	echo  "上記が not exist になっていれば、設定ファイル T_Setting_getIdentification.vbs が削除されています。"

	echo  "Pass."
	pause

	WScript.Quit  21  '// Pass
End Sub


Sub  MakeSettingScript( FolderPath, Id )
	If IsEmpty( Id ) Then
		del  FolderPath +"\T_Setting_getIdentification.vbs"
	Else
		CreateFile  FolderPath +"\T_Setting_getIdentification.vbs", _
			"Function  T_Setting_getIdentification() : T_Setting_getIdentification = """& Id &""" : End Function"
	End If
End Sub


Sub  EchoExist( default_setting_path, machine_setting_path, usbmem_setting_path, custom_setting_path )
	Dim  s

	If g_fs.FileExists( default_setting_path +"\T_Setting_getIdentification.vbs" ) Then  s = "exist"  Else  s = "not exist"
	echo  "default_setting_path = "+ s

	If g_fs.FileExists( machine_setting_path +"\T_Setting_getIdentification.vbs" ) Then  s = "exist"  Else  s = "not exist"
	echo  "machine_setting_path = "+ s

	If g_fs.FileExists( usbmem_setting_path +"\T_Setting_getIdentification.vbs" ) Then  s = "exist"  Else  s = "not exist"
	echo  "usbmem_setting_path = "+ s

	If g_fs.FileExists( custom_setting_path +"\T_Setting_getIdentification.vbs" ) Then  s = "exist"  Else  s = "not exist"
	echo  "custom_setting_path = "+ s

	pause
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


 
