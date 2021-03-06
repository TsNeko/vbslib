Sub  Main( Opt, AppKey )
	T_Shutdown_onStartTest
	Set o = new InputCommandOpt
		o.Lead = "手動テストは、Test.vbs の Test_check まで実行した後で使えます。"
		Set o.CommandReplace = Dict(Array(_
			"1","T_Standby",_
			"2","T_StandbyCancel",_
			"3","T_StandbyNow",_
			"4","T_StandbyZero",_
			"5","T_ShutdownSleep",_
			"6","T_Hibernate",_
			"7","T_PowerOff",_
			"8","T_Reboot",_
			"9","T_ShutdownDefault",_
			"10","T_ShutdownDefaultSetting" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


Sub  T_Standby( Opt, AppKey )
	echo  "5秒後に、スタンバイ状態になること。"
	pause
	Shutdown  "Standby", 5
End Sub


Sub  T_StandbyCancel( Opt, AppKey )
	echo  "キャンセルボタンを押してスタンバイ状態にならないこと。"
	pause
	Shutdown  "Standby", 30
End Sub


Sub  T_StandbyNow( Opt, AppKey )
	echo  "OK ボタンを押してすぐにスタンバイ状態になること。"
	pause
	Shutdown  "Standby", 30
End Sub


Sub  T_StandbyZero( Opt, AppKey )
	echo  "MsgBox が出ないですぐにスタンバイ状態になること。"
	pause
	Shutdown  "Standby", 0
End Sub


Sub  T_ShutdownSleep( Opt, AppKey )
	echo  "5秒後に、スリープすること。"
	pause
	Shutdown  "Sleep", 5
End Sub


Sub  T_Hibernate( Opt, AppKey )
	echo  "5秒後に、ハイバネートすること。"
	pause
	Shutdown  "Hibernate", 5
End Sub


Sub  T_PowerOff( Opt, AppKey )
	If GetOSVersion() >= 6.2 Then
		echo  "Windows 8 高速スタートアップの設定を確認してください。"
		echo  "[ デスクトップ > （チャームの）設定 > コントロール パネル > （右上の検索に）"+_
			"""電源ボタンの動作"" > 電源ボタンの動作の変更 ]、"+_
			"[ 現在利用可能ではない設定を変更します ] をクリックしてから、"+_
			"[ 高速スタートアップを有効にする ]" + vbCRLF
	End If

	echo  "5秒後に、電源オフすること。"

	pause
	Shutdown  "PowerOff", 5
End Sub


Sub  T_Reboot( Opt, AppKey )
	echo  "5秒後に、再起動すること。"
	pause
	Shutdown  "Reboot", 5
End Sub


Sub  T_ShutdownDefault( Opt, AppKey )
	echo  "デフォルト（PowerOff,60秒）。"
	pause
	Shutdown  Empty, Empty
End Sub


Sub  T_ShutdownDefaultSetting( Opt, AppKey )
	include  "T_Shutdown_Setting.vbs"
	echo  "T_Shutdown_Setting.vbs の設定（Sleep,12秒）に従うこと。"
	pause
	Shutdown  Empty, Empty
End Sub


Sub  T_Shutdown_onStartTest()

	'// Echo supported power state
	RunProg  "powercfg /a", ""

	echo_line
	echo  ""

	Select Case GetOSVersion()
		Case 5   : echo "OS = Windows 2000"
		Case 5.1 : echo "OS = Windows XP"
		Case 6   : echo "OS = Windows Vista"
		Case 6.1 : echo "OS = Windows 7"
		Case Else  echo  "Unknown Windows"
	End Select
	echo  ""
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


 
