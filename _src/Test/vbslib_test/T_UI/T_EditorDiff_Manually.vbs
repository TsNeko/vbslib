Option Explicit 

Sub  Main( Opt, AppKey )
	Dim  in_data, e
	Do
		echo_line
		echo  "[T_EditorDiff_Manually] のドキュメントを参照。"
		echo  "1. setting_default フォルダーを開く（PC_setting_default.vbs の内容をコピーします）"
		echo  "2. setting フォルダーを開く（コピーした内容を貼り付けた PC_setting.vbs を作成してください。"+_
		      "最優先で使うツールを設定するか、ツールが無いときの警告が出るような設定をしてください。"+_
		      "設定したらこのコマンドプロンプトを再起動してください。終わったら PC_setting.vbs を削除してください）"
		echo  "3. T_EditorManually"
		echo  "4. T_DiffManually"
		echo  "9. Quit"
		in_data = input( "番号を選んでください >" )
		echo_line


		If in_data = 9 Then  Exit Do

		If TryStart(e) Then  On Error Resume Next
			Select Case  in_data
				Case 1:  Setting_openFolder  g_vbslib_ver_folder +"setting_default"
				Case 2:  Setting_openFolder  g_vbslib_ver_folder +"setting"
				Case 3:  T_EditorManually
				Case 4:  T_DiffManually
				Case Else: Err.Raise 1,,"メニュー項目がありません"
			End Select
		If TryEnd Then  On Error GoTo 0
		If e.num=0 or e.num=21 Then  echo  "Pass" : e.Clear
		If e.num <> 0 Then  echo  e.DebugHint : e.Clear
	Loop
End Sub


 
'********************************************************************************
'  <<< [T_EditorManually] >>> 
'********************************************************************************
Sub  T_EditorManually()
	Dim  param, cmd

	EchoTestStart  "T_EditorManually"

	For Each param  In Array( "Text1.txt", "Text2.txt(3)", "Text2.txt:5", _
			"Text3.txt:Text1", "Text3.txt#Text1", "Text3.txt:Text#2", "Text3.txt#Text#2", _
			"Text3.txt:Text:3", "Text3.txt#Text:3" )
			'// Text2.txt:5 is line number

		echo_line
		echo  "PC_setting_temp.vbs の設定に従って、テキスト・エディターを開きます。"

		cmd = GetEditorCmdLine( param )
		echo  "GetEditorCmdLine( """+ param +""" )"

		echo  ">"+cmd
		echo  "ファイルの内容が合っていること。 ツールによっては、開いた時のカーソルの位置も合っていること。"
		pause
		echo_line

		start cmd

		echo_line
		echo  "次のテストに進みます。"
		pause
	Next
	echo  "テストはパスしました"
	pause
End Sub


 
'********************************************************************************
'  <<< [T_DiffManually] >>> 
'********************************************************************************
Sub  T_DiffManually()
	Dim  params, cmd

	EchoTestStart  "T_DiffManually"

	For Each params  In Array(_
			Array( "Text1.txt", "Text2.txt" ),_
			Array( "Text1.txt(5)", "Text2.txt" ),_
			Array( "Text1.txt", "Text2.txt(3)" ),_
			Array( "Text1.txt", "Text2.txt", "Text3.txt" ),_
			Array( "Text1.txt(5)", "Text2.txt", "Text3.txt" ),_
			Array( "Text1.txt", "Text2.txt(3)", "Text3.txt" ),_
			Array( "Text1.txt", "Text2.txt", "Text3.txt(4)" ) )

		echo_line
		echo  "PC_setting_temp.vbs の設定に従って、Diff ツールを開きます。"

		If UBound( params ) = 1 Then
			cmd = GetDiffCmdLine( params(0), params(1) )
			echo  "GetDiffCmdLine( """+ params(0) +""", """+ params(1) +""" )"
		ElseIf UBound( params ) = 2 Then
			cmd = GetDiffCmdLine3( params(0), params(1), params(2) )
			echo  "GetDiffCmdLine3( """+ params(0) +""", """+ params(1) +""", """+ params(2) +""" )"
		Else
			Fail
		End If

		echo  ">"+cmd
		echo  "ファイルの内容が合っていること。 ツールによっては、開いた時のカーソルの位置も合っていること。"
		pause
		echo_line

		start cmd

		echo_line
		echo  "次のテストに進みます。"
		pause
	Next
	echo  "テストはパスしました"
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


 
