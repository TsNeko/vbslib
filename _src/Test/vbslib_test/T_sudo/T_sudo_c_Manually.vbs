Option Explicit 

Sub  Main( Opt, AppKey )
'//	SetStartSectionTree  "T_Sample2"
	Dim  e
	Dim  w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  section : Set section = new SectionTree


	If section.Start( "T_sudo_c_1" ) Then
		echo  "管理者として子プロセスを起動でき、子プロセスが終わるまで親プロセスが待つこと。"
		pause

		sudo  "cscript T_sudo_c_target.vbs from_vbs", "T_sudo_c_Manual(Normal)", ""

		echo  "return from sudo"
	End If : section.End_


	If section.Start( "T_sudo_c_Err" ) Then
		echo  "管理者プロセスでエラーが発生したら pause して、エラーメッセージを確認できること。"
		pause

		If TryStart(e) Then  On Error Resume Next
			sudo  "cscript T_sudo_c_target.vbs err", "T_sudo_c_Manual(Error)", ""
		If TryEnd Then  On Error GoTo 0
		If e.num <> 450 Then  e.Raise
		e.Clear
	End If : section.End_


	If section.Start( "T_sudo_c_debugger" ) Then
		echo  "最後のテストです。（デバッガでブレークして中断するため）"
		echo  "管理者プロセスをデバッガに接続し、ブレークできること（ブレークできたら終了です）"
		pause

		sudo  "cscript //x T_sudo_c_target_debug0.vbs from_vbs", "T_sudo_c_Manual(Debugger)", ""
	End If : section.End_

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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
