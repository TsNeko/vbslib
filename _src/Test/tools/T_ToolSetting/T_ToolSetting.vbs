Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Setting_1" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Title: Deleting scriptlib folder
'*
'* Description:
'*    ".\scriptlib" フォルダーがあっても削除することで、このスクリプト 
'*    ファイルが "..\scriptlib" を使うようにします。 このテスト スクリプトは、
'*    "..\scriptlib" を使い、テスト対象は ".\scriptlib" を使います。
'***********************************************************************
If  NOT  WScript.Arguments.Named.Item("NotDeleteScriptlib") = "1" Then
	Set g_fs = CreateObject( "Scripting.FileSystemObject" )
	g_path = g_fs.GetParentFolderName( WScript.ScriptFullName ) +"\scriptlib"
	If g_fs.FolderExists( g_path ) Then _
		g_fs.DeleteFolder  g_path,  True
End If


 
'***********************************************************************
'* Function: T_Setting_1
'***********************************************************************
Sub  T_Setting_1( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_log.txt", "ArgsLog.txt", "scriptlib" ) ).Enable()

	echo  g_vbslib_folder
	If g_vbslib_folder = g_sh.CurrentDirectory +"\scriptlib\" Then
		echo  "scriptlib を削除して再起動してください。"
		Pause
		Exit Sub
	End If


	'// Set up
	del  "scriptlib"
	del  "_log.txt"
	del  "ArgsLog.txt"
	copy  "..\scriptlib",  "."
	del  "scriptlib\vbslib\CheckEnglishOnly\CheckEnglishOnly_src"
	If True Then

		'// テスト用の設定ファイルを使うようにする。
		copy_ren "setting_for_test\PC_setting_default_for_test.vbs", _
			"scriptlib\vbslib\setting_default\PC_setting_default.vbs"
			'// "PC_setting_default.vbs" という名前は、テスト対象の仕様なので、変えないでください。
	End If

	setting_path = env("%APPDATA%")+ "\Scripts\PC*.vbs"
	If exist( setting_path ) Then
		Raise  1, "<ERROR msg=""PC 全体の設定を一時的に無くしてください。""  path="""+ _
			setting_path +"""/>"
	End If

	setting_path = env("%myhome_mem%")+ "\prog\scriptlib\setting_mem\PC*.vbs"
	If exist( setting_path ) Then
		Raise  1, "<ERROR msg="" USB メモリーに入っている PC 全体の設定を一時的に無くしてください。""  path="""+ _
			setting_path +"""/>"
	End If


	'// Test Main : 設定の新規作成や設定ファイルを開くテスト
	RunProg  "cscript  //nologo  ""T_ToolSetting.vbs""  T_Setting_Main  /NotDeleteScriptlib:1  "+ _
		"1 """"  "+ _
		"2   2 1 9       1 4 """" 1   9 9  "+ _
		"3   2 1 2 3 9   1 4 """" 1   9 9  "+ _
		"4   2 1 2 9     1 4 """" 1   9 9  "+ _
		"5   2 1 9       1 4 """" 1   9 9   9  ", _
		"_log.txt"

		'// 上記の 2 1 9 など 2 から始まる部分は、設定のテストを実行しています。
		'// 1 4 など 1 から始まる部分は、設定を新規作成しています。
		'// 詳しくは、実行時の echo を参照。

	'// Check
	AssertFC  "_log.txt", "T_Setting_1_answer.txt"

	'// Clean
	del  "_log.txt"
	del  "scriptlib"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_Setting_Main
'*
'* Description:
'*    T_Setting_1 から呼ばれると自動実行しますが、T_Setting_Main を直接
'*    呼べば、ショートハンド・プロンプトのコマンドとして、試すことが
'*    できます。 scriptlib フォルダーを消したくないときは、
'*    /NotDeleteScriptlib:1 オプションをコマンドラインに指定してください。
'***********************************************************************
Sub  T_Setting_Main( Opt, AppKey )
	AssertExist  g_sh.CurrentDirectory +"\scriptlib"

	Set o = new VBS_LibToolSettingClass
	Set w_= AppKey.NewWritable( o.GetWritablePaths() ).Enable()

	Start_VBS_Lib_Settings
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


 
