Sub  Main( Opt, AppKey )
	If GetOSVersion() >= 6.0 Then
		echo  WScript.ScriptName +" をダブルクリックした直後に、[ UAC（ユーザーアカウント制御）予告 ] "+_
			"という『予告』が表示されていなければ、Fail です。"
		echo  ""
	End If

	Dim  in_data, e
	Do
		echo  ""
		echo  "--------------------------------------------------------"
		echo  " ((( T_Admin )))"
		echo  "1. T_Admin_MkDir"
		echo  "2. T_Admin_Err"
		echo  "9. Quit"
		in_data = input( "番号を選んでください >" )
		echo "--------------------------------------------------------"

		If in_data = 9 Then  Exit Do

		If in_data = 2 Then  T_Admin_Err  '// no catch

		If TryStart(e) Then  On Error Resume Next
			Select Case  in_data
				Case 1:  T_Admin_MkDir  AppKey
				Case Else: Err.Raise 1,,"メニュー項目がありません"
			End Select
		If TryEnd Then  On Error GoTo 0
		If e.num=0 or e.num=21 Then  echo  "Pass" : e.Clear
		If e.num <> 0 Then  echo  e.DebugHint : e.Clear
	Loop
End Sub


 
'********************************************************************************
'  <<< [T_Admin_MkDir] >>> 
'********************************************************************************
Sub  T_Admin_MkDir( AppKey )
	Dim  test_path2, bFail, w_
	Const  test_folder_name = "__vbslib_test"
	Dim  test_path : test_path = env("%ProgramFiles%")+"\"+test_folder_name

	bFail = False

	AppKey.SetWritableMode  F_IgnoreIfWarn
	Set w_=AppKey.NewWritable( test_path ).Enable()
	SetWritableMode  F_AskIfWarn


	'//=== Set up
	echo_line
	echo  "テストを行う前提の状態にします。"
	If exist( test_path ) Then
		echo  """"+ test_path +""" を削除してください。"
		Fail
	End If

	If GetOSVersion() < 6.0 Then
	Else
		test_path2 = env("%USERPROFILE%\AppData\Local\VirtualStore\Program Files\"+test_folder_name)
		If exist( test_path2 ) Then
			echo  """"+ test_path2 +""" を削除してください。"
			Fail
		End If
	End If
	echo  "テストを行う前提の状態になりました。"
	echo_line


	'//=== Test Main
	'// Access in system folder
	mkdir  test_path


	'//=== Check
	'// Windows XP
	If GetOSVersion() < 6.0 Then

		Assert  exist( test_path )


	'// Windows Vista/7
	Else
		AssertExist  test_path
		bFail = exist( test_path2 )
		echo  test_path +" にフォルダーがあることを確認してください。"
		pause
		del  test_path2
	End If
	Assert  not bFail


	'//=== Clean
	del  test_path
	Assert  not exist( test_path )
	echo  test_path +" フォルダーを削除しました。"
End Sub


 
'********************************************************************************
'  <<< [T_Admin_Err] >>> 
'********************************************************************************
Sub  T_Admin_Err()
	echo  "エラーメッセージを確認できること。"
	pause
	cd  g_fs.GetParentFolderName( WScript.ScriptFullName )
	Error
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
	g_CommandPrompt = 0
	g_debug = 0

	g_admin = 1
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
