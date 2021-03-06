Sub  Main( Opt, AppKey )
	Dim  e  ' as Err2
	Dim  w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  f


	'// Set up
	Set ec = new EchoOff
	del  "_work_file.txt"
	CreateFile  "_work_file.txt", "abc"
	ec = Empty


	'// Guide
	EchoTestStart  "T_WaitForLockAtCUI"
	echo  "2回再試行すること。"
	Pause


	'// Set up
	Set ec = new EchoOff
	Set f = OpenForWrite( "_work_file.txt", Empty )  '// 既存のファイルを上書き(1)
	f.WriteLine  "def"


	'// Error Handling Test : Locking
	g_FileSystemMaxRetryMSec = 8*1000
	If TryStart(e) Then  On Error Resume Next
		 CreateFile  "_work_file.txt", "test"  '// 既存のファイルを上書き(2)
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_WriteAccessDenied  Then  Fail
	e.Clear

	f = Empty
	ec = Empty


	'//=====

	'// Guide
	EchoTestStart  "T_ReadOnlyForLockAtCUI"
	echo  "読み取り専用なので、すぐにエラー復帰すること"
	Pause


	'// Set up
	g_fs.GetFile( "_work_file.txt" ).Attributes = _
		g_fs.GetFile( "_work_file.txt" ).Attributes  or _
		ReadOnly


	'// Error Handling Test : Read Only
	Set ec = new EchoOff
	If TryStart(e) Then  On Error Resume Next
		del  "_work_file.txt"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_WriteAccessDenied  Then  Fail
	echo_v  e.desc
	e.Clear


	'// Clean
	g_fs.GetFile( "_work_file.txt" ).Attributes = _
		g_fs.GetFile( "_work_file.txt" ).Attributes  and _
		not ReadOnly

	del  "_work_file.txt"
	ec = Empty

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

 
