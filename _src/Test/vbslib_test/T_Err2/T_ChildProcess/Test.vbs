
Sub  Main( Opt, AppKey ) : RunTestPrompt AppKey.NewWritable( "." ) : End Sub


Sub  Test_setup( tests )
	Dim rep, line

	Set rep = StartReplace( "T_ChildProcessErr.vbs", "T_ChildProcessErr_Manually.vbs", True )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "g_debug = 0", "g_debug = 1"+vbCRLF+"g_debug_process = 1" )
		If InStr( line, "Main(" ) > 0 Then
			line = line +vbCRLF+ "echo  ""T_ChildProcessErr_Sub.vbs で発生するエラーでブレーク"+_
			"することを g_MainPath で確認してください。""" +vbCRLF+ "pause"
		End If
		rep.w.WriteLine  line
	Loop
	rep.Finish

	Set rep = StartReplace( "T_ChildProcessNotClear.vbs", "T_ChildProcessNotClear_Manually.vbs", True )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "g_debug = 0", "g_debug = 1.5"+vbCRLF+"g_debug_process = 1" )
		If InStr( line, "Main(" ) > 0 Then
			line = line +vbCRLF+ "echo  ""T_ChildProcessNotClear_Sub.vbs で発生するエラーでブレーク"+_
			"することを g_MainPath で確認してください。""" +vbCRLF+ "pause"
		End If
		rep.w.WriteLine  line
	Loop
	rep.Finish

	Set rep = StartReplace( "T_ChildProcessNotClear_Sub.vbs", "T_ChildProcessNotClear_Sub_Manually.vbs", True )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "g_debug = 0", "g_debug = 1.5" )
		If InStr( line, "Main(" ) > 0 Then
			line = line +vbCRLF+ "echo  ""T_ChildProcessNotClear_Sub_Manually.vbs で発生するエラーでブレーク"+_
			"することを g_MainPath で確認してください。""" +vbCRLF+ "pause"
		End If
		rep.w.WriteLine  line
	Loop
	rep.Finish

	Set rep = StartReplace( "T_ChildProcessIDNest.vbs", "T_ChildProcessIDNest_Manually.vbs", True )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "g_debug = 0", "g_debug = 5"+vbCRLF+"g_debug_process = Array(3,1)" )
		If InStr( line, "Main(" ) > 0 Then
			line = line +vbCRLF+ vbTab +"echo  ""T_ChildProcessIDNest_SubSub.vbs で発生するエラーでブレーク"+_
			"することを g_MainPath で確認してください。""" +vbCRLF+ vbTab +"Pause" +vbCRLF+vbCRLF+vbCRLF
		End If
		rep.w.WriteLine  line
	Loop
	rep.Finish

	ConvertToFullPath  "T_ChildProcessErrMsgInTest_ans_tmp.txt", "T_ChildProcessErrMsgInTest_ans.txt"

	Pass
End Sub


Sub  Test_start( tests )
	Dim  r
	Dim  ex, out, ans
	Dim  a_32bit_system_dir
	Dim  command_line

	If g_sh.ExpandEnvironmentStrings( "%ProgramFiles(x86)%" ) = "%ProgramFiles(x86)%" Then
		a_32bit_system_dir = "%windir%\system32"  '// For 32bit Windows
	Else
		a_32bit_system_dir = "%windir%\SysWOW64"  '// For 64bit Windows
	End If
	a_32bit_system_dir = g_sh.ExpandEnvironmentStrings( a_32bit_system_dir )


	'// T_ChildProcess*.vbs を起動するときは、/ChildProcess オプションが自動で付く RunProg を使わないこと
	EchoTestStart  "[T_ChildProcess1]"
	r= g_sh.Run( "cscript.exe T_ChildProcess1.vbs",, True )
	CheckTestErrLevel  r

	EchoTestStart  "[T_ChildProcess2]"
	r= g_sh.Run( "cscript.exe T_ChildProcess2.vbs",, True )
	CheckTestErrLevel  r

	EchoTestStart  "[T_ChildProcess0]"
	g_sh.Run  "T_ChildProcess0.bat",, True
	AssertFC  "T_ChildProcess0_log.txt", "T_ChildProcess0_ans.txt"
	del  "T_ChildProcess0_log.txt"

	EchoTestStart  "[T_ChildProcessID]"
	r= g_sh.Run( "cscript.exe T_ChildProcessID.vbs",, True )
	CheckTestErrLevel  r

	EchoTestStart  "[T_ChildProcessIDNest]"
	r= g_sh.Run( "cscript.exe T_ChildProcessIDNest.vbs",, True )
	CheckTestErrLevel  r


	'// [T_ChildProcessErr]
	EchoTestStart  "T_ChildProcessErr"
	command_line = a_32bit_system_dir +"\cmd /C "+ a_32bit_system_dir +"\cscript.exe T_ChildProcessErr.vbs"

	Set ex = g_sh.Exec( command_line )
	T_ChildProcess_checkErrMsg  ex, out
	ex = Empty
	ans = ReadFile( "T_ChildProcessErr_ans.txt" )
	If out <> ans Then  Fail


	'// [T_ChildProcessErrChangingTemp]
	EchoTestStart  "T_ChildProcessErrChangingTemp"

	'// Set up
	include  "Setting_getTemp_Reset.vbs"
	g_TempFile = Empty  '// Setup to set another folder path
	get_TempFile

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		RunProg  "cscript.exe  //nologo  T_ChildProcessErr.vbs", ""

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '// Set "e2"
	echo    e2.desc
	Assert  InStr( e2.desc, "<ERROR msg=""エラー（日本語）"" apos='apos'/>" ) >= 1
	Assert  e2.num <> 0


	'// Set up
	include  "Setting_getTemp.vbs"
	g_TempFile = Empty  '// Setup to set another folder path
	get_TempFile

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		RunProg  "cscript.exe  //nologo  T_ChildProcessErr.vbs", ""

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '// Set "e2"
	echo    e2.desc
	Assert  InStr( e2.desc, "<ERROR msg=""エラー（日本語）"" apos='apos'/>" ) >= 1
	Assert  e2.num <> 0

	'// Clean
	include  "Setting_getTemp_Reset.vbs"
	g_TempFile = Empty  '// Setup to set another folder path
	get_TempFile


	'// [T_ChildProcessNotClear]
	EchoTestStart  "T_ChildProcessNotClear"
		Set ex = g_sh.Exec( a_32bit_system_dir +"\cscript.exe T_ChildProcessNotClear.vbs" )
	T_ChildProcess_checkErrMsg  ex, out
	ex = Empty
	ans = ReadFile( "T_ChildProcessNotClear_ans.txt" )
	If out <> ans Then  Fail


	'// [T_ChildProcessErrMsgInTest]
	del  "T_ChildProcessErrMsgInTest_log.txt"
	r= RunProg( "cscript //nologo TestFor_T_ChildProcessErrMsgInTest.vbs /ChildProcess:0 /set_input:5.9. /log:T_ChildProcessErrMsgInTest_log.txt", "" )
		'// TestFor_T_ChildProcessErrMsgInTest.vbs : Log
			'// T_ChildProcessErr_SubTree.vbs : Error
	CheckTestErrLevel  r
	If not fc( "T_ChildProcessErrMsgInTest_log.txt", "T_ChildProcessErrMsgInTest_ans.txt" ) Then  Fail
	del  "T_ChildProcessErrMsgInTest_log.txt"


	ManualTest  "T_ChildProcessErr_Manually"
	ManualTest  "T_ChildProcessIDNest_Manually"
	ManualTest  "T_ChildProcessIDNest_Manually2"
	ManualTest  "T_ChildProcessNotClear_Manually"
	ManualTest  "T_ChildProcessNotClear_Sub_Manually"

	Pass
End Sub


Sub  T_ChildProcess_checkErrMsg( ex, out )
	Do While ex.Status = 0 : WScript.Sleep 100 : Loop

	'// エラーメッセージまでスキップする
	Do Until ex.StdOut.AtEndOfStream
		out = ex.StdOut.ReadLine()
		If InStr( out, g_ConnectDebugMsgV5 ) > 0 Then  Exit Do
	Loop

	'// エラーメッセージ以降を out へ
	out = out + vbCRLF
	Do Until ex.StdOut.AtEndOfStream
		out = out + ex.StdOut.ReadLine() +vbCRLF
	Loop
End Sub


Sub  Test_clean( tests )
	del  "T_ChildProcessErrMsgInTest_ans.txt"
	Pass
End Sub


Sub  Test_current( tests ) : End Sub
Sub  Test_build( tests ) : Pass : End Sub
Sub  Test_check( tests ) : Pass : End Sub


 







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

 
