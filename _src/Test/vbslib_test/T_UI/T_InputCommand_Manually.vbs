Sub  Main( Opt, AppKey )
	echo  "1. 任意コマンド入力テスト [T_InputCommand1]"
	echo  "2. メニュー選択テスト [T_InputCommand2]"
	echo  "3. 終わってもウィンドウを閉じないテスト [T_InputCommandClose0]"
	Select Case  CInt2( key )
		Case  1 : T_InputCommand1  Opt, AppKey
		Case  2 : T_InputCommand2  Opt, AppKey
		Case  3 : T_InputCommandClose  Opt, AppKey
	End Select
End Sub


'*************************************************************************
'  <<< [T_InputCommand1] >>> 
'*************************************************************************
Sub  T_InputCommand1( Opt, AppKey )
	InputCommand  "入力できるコマンド：FuncA, ErrTest", "プロンプト＞", Opt, AppKey
End Sub


Sub  FuncA( Opt, AppKey )
	echo  "FuncA 関数が呼ばれました。"
End Sub


Sub  FuncB( Opt, AppKey )
	echo  "FuncB 関数が呼ばれました。"
End Sub


Sub  ErrTest( Opt, Appkey )
	echo  "「エラーのテスト」エラーが発生すること"
	echo  "エラーが発生してから、InputCommand のメニューに戻ること"
	pause
	Raise  1, "エラーのテスト"
End Sub


Sub  QuitFunc( Opt, Appkey )
	WScript.Quit  0
End Sub


'*************************************************************************
'  <<< [T_InputCommand2] >>> 
'*************************************************************************
Sub  T_InputCommand2( Opt, AppKey )
	Set o = new InputCommandOpt
		o.Lead = "1 (Enter), 2 (Enter), FuncA (Enter), xxx (Enter) と入力してください"
		Set o.CommandReplace = Dict(Array( "1","FuncA", "2","FuncB", "quit", "QuitFunc" ))
		Set o.MenuCaption = Dict(Array( "2","menu2 [%name%]" ))
	InputCommand  o, "番号またはコマンド >", Opt, AppKey
End Sub


'*************************************************************************
'  <<< [T_InputCommandClose] >>> 
'*************************************************************************
Sub  T_InputCommandClose( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_T_InputCommand_temporary.vbs" ).Enable()
	Set section = new SectionTree
	OpenForReplace( "T_InputCommand_Target2.vbs", "_T_InputCommand_temporary.vbs" ). _
		Replace  "g_CommandPrompt = 2", "g_CommandPrompt = 1"
'//SetStartSectionTree  "T_InputCommandClose_PassClose0"


	'//===
	If section.Start( "T_InputCommandClose_Pass" ) Then

	'// Set up
	echo_line
	echo  "一瞬別ウィンドウが開いてすぐ閉じて、After Run が表示されて Pause すること。"
	Pause

	'// Test Main
	g_sh.Run  "_T_InputCommand_temporary.vbs  2",, True

	'// Check
	echo  "After Run"
	Pause

	End If : section.End_


	'//===
	If section.Start( "T_InputCommandClose_Fail" ) Then

	'// Set up
	echo_line
	echo  "別ウィンドウが開いて、エラーメッセージが表示され、別ウィンドウが閉じないこと。"
	echo  "それを確認したら、別ウィンドウを閉じてください。"
	Pause

	'// Test Main
	g_sh.Run  "_T_InputCommand_temporary.vbs  3",, True

	'// Check
	echo  "After Run"
	Pause

	End If : section.End_


	'//===
	If section.Start( "T_InputCommandClose_PassClose0" ) Then

	'// Set up
	echo_line
	echo  "別ウィンドウが開いて、別ウィンドウが閉じないこと。"
	echo  "それを確認したら、別ウィンドウを閉じてください。"
	Pause

	'// Test Main
	g_sh.Run  "_T_InputCommand_temporary.vbs  2 /close:0",, True

	'// Check
	echo  "After Run"
	Pause

	End If : section.End_


	'// Clean
	del  "_T_InputCommand_temporary.vbs"
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


 
