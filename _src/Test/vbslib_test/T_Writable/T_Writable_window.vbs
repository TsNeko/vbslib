Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		o.Lead = "別のメニューを選ぶときは、スクリプトを起動しなおしてください。"
		Set o.CommandReplace = Dict(Array(_
			"1","T_Writable_OK",_
			"2","T_Writable_Cancel" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


Sub  T_Writable_OK( Opt, AppKey )
	Set w_= AppKey.NewWritable( "work2" ).Enable()
	mkdir "work2"
	Assert  exist("work2")
	del   "work2"
	Assert  not exist("work2")
	w_ = Empty


	If exist("work2") Then  Raise 1, "work2 フォルダーを削除してください"

	echo "次のウィンドウでは、OK を押してください。"
	pause

	mkdir "work2"  '// 上書き確認ウィンドウが表示されます
	Assert  exist("work2")

	del "work2"  '// 一度許可したため、上書き確認ウィンドウは表示されません
	Assert  not exist("work2")

	AppKey.SetWritableMode  F_IgnoreIfWarn
	mkdir "work3"  '// 一度許可したため、上書き確認ウィンドウは表示されません
	Assert  exist("work3")
	del "work3"  '// 一度許可したため、上書き確認ウィンドウは表示されません
	Assert  not exist("work3")

	echo "今までに２回以上ウィンドウが表示されたら、Fail です。"
	echo "今までに１回なら、Pass です。"
	pause

	echo  "次のテストをするときは、スクリプトを起動しなおしてください。"
	pause

	Pass
End Sub


Sub  T_Writable_Cancel( Opt, AppKey )
	If exist("work2") Then  Raise 1, "work2 フォルダーを削除してください"

	echo "次の次の Out of Writable のウィンドウでは、Cancel を押してください。"
	pause


	SetWritableMode  F_AskIfWarn
	If TryStart(e) Then  On Error Resume Next
		mkdir "work2"  '// 上書き確認ウィンドウが表示されます
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear


	SetWritableMode  F_ErrIfWarn

	Set w_= AppKey.NewWritable( "work4" ).Enable()
	del  "work4"
	CreateFile  "work4\a.txt", "test"
	CreateFile  "work4\sub\a.txt", "test"
	Set w_= AppKey.NewWritable( "work4\sub" ).Enable()

	echo  "次の以降の質問には y を押して、削除を実行してください。"
	Pause

		echo "Test of del_confirmed, Please answer yes."
		del_confirmed  "work4\sub"
		If TryStart(e) Then  On Error Resume Next
			del_confirmed  "work4"
		If TryEnd Then  On Error GoTo 0
		If e.num <> E_OutOfWritable  Then Fail
		e.Clear
		If not exist("work4") Then  Fail
		CreateFile  "work4\sub\a.txt", "test"

	Set w_= AppKey.NewWritable( "work4" ).Enable()
	del "work4"

	echo  "次のテストをするときは、スクリプトを起動しなおしてください。"
	pause

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
	g_CommandPrompt = 0
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
