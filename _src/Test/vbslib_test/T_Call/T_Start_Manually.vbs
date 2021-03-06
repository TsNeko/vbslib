Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	Dim  t : t = WScript.Arguments.Named.Item("Test")
	If t="T_StartErr" or t="ALL" Then  T_StartErr
	If t="T_Start64"  or t="ALL" Then  T_Start64
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_StartErr] >>> 
'********************************************************************************
Sub  T_StartErr()
	EchoTestStart  "T_StartErr"

	echo  ""
	echo  "C2) cscript で起動した err_c2.vbs が正常終了したとき、ウィンドウが表示されたまま終わること。"
	pause
	start  "cscript  err_c2.vbs /NoError"

	echo  ""
	echo  "C2E) cscript で起動した err_c2.vbs がエラーが発生したとき、エラーメッセージが表示されたまま終わること。"
	pause
	start  "cscript  err_c2.vbs"

	echo  ""
	echo  "C1) cscript で起動した err_c1.vbs が正常終了したとき、ウィンドウが閉じること。"
	pause
	start  "cscript  err_c1.vbs /NoError"

	echo  ""
	echo  "C1E) cscript で起動した err_c1.vbs がエラーが発生したとき、エラーメッセージが表示されたまま終わること。"
	pause
	start  "cscript  err_c1.vbs"

	echo  ""
	echo  "C0) cscript で起動した err_c0.vbs が正常終了したとき、ウィンドウが開かないこと。"
	pause
	start  "cscript  err_c0.vbs /NoError"

	echo  ""
	echo  "C0E) cscript で起動した err_c0.vbs がエラーが発生したとき、エラーメッセージが表示されること。"
	pause
	start  "cscript  err_c0.vbs"

	echo  ""
	echo  "W2) wscript で起動した err_c2.vbs が正常終了したとき、ウィンドウが表示されたまま終わること。"
	pause
	start  "wscript  err_c2.vbs /NoError"

	echo  ""
	echo  "W2E) wscript で起動した err_c2.vbs がエラーが発生したとき、エラーメッセージが表示されたまま終わること。"
	pause
	start  "wscript  err_c2.vbs"

	echo  ""
	echo  "W1) wscript で起動した err_c1.vbs が正常終了したとき、ウィンドウが閉じること。"
	pause
	start  "wscript  err_c1.vbs /NoError"

	echo  ""
	echo  "W1E) wscript で起動した err_c1.vbs がエラーが発生したとき、エラーメッセージが表示されたまま終わること。"
	pause
	start  "wscript  err_c1.vbs"

	echo  ""
	echo  "W0) wscript で起動した err_c0.vbs が正常終了したとき、ウィンドウが開かないこと。"
	pause
	start  "wscript  err_c0.vbs /NoError"

	echo  ""
	echo  "W0E) wscript で起動した err_c0.vbs がエラーが発生したとき、エラーメッセージが表示されること。"
	pause
	start  "wscript  err_c0.vbs"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Start64] >>> 
'********************************************************************************
Sub  T_Start64()
	echo  ""
	echo  "W32ToW64) "
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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
