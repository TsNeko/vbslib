Sub  Main( Opt, AppKey ) : RunTestPrompt AppKey.NewWritable( "." ) : End Sub


'***********************************************************************
'* Function: Test_setup
'***********************************************************************
Sub  Test_setup( tests )
	Dim  f
	Const  b_ResumePop_catch_error = True
	vbslib_test = GetFullPath( "..", Empty )

	Set f = OpenForWrite( "T_Err2_Debug1_NoDebugger_ans.txt", Empty )
	f.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
	f.WriteLine  String( 70, "-" )
	f.WriteLine  """T_Err2_Debug1_NoDebugger.vbs"" /g_debug:1"
	f.WriteLine  String( 70, "-" )
	If b_ResumePop_catch_error Then
		f.WriteLine  "<ERROR err_number='500' err_description='この変数は宣言されていません。'/>"
	Else
		f.WriteLine  GetFullPath( "T_Err2_Debug1_NoDebugger.vbs", Empty ) + _
			"(0, 1) Microsoft VBScript 実行時エラー: この変数は宣言されていません。" + vbCRLF
	End If

	Set f = OpenForWrite( "T_Err2_Debug2_NoDebugger_ans.txt", Empty )
	f.WriteLine  "error resolved"
	f.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
	f.WriteLine  String( 70, "-" )
	f.WriteLine  """T_Err2_Debug2_NoDebugger.vbs"" /g_debug:2"
	f.WriteLine  String( 70, "-" )
	If b_ResumePop_catch_error Then
		f.WriteLine  "<ERROR err_number='500' err_description='この変数は宣言されていません。'/>"
	Else
		f.WriteLine  GetFullPath( "T_Err2_Debug2_NoDebugger.vbs", Empty ) + _
			"(0, 1) Microsoft VBScript 実行時エラー: この変数は宣言されていません。" + vbCRLF
	End If

	Set f = OpenForWrite( "T_Err2_DupSymbol_ans.txt", Empty )

	f.WriteLine  "下記のファイルを include したときにエラーが発生しました。"
	f.WriteLine  """"+ vbslib_test + "\scriptlib\vbslib\TestScript.vbs"""
	f.WriteLine  "構文エラーではないときは、g_debug を設定している場所のすぐ下に、次のように記述すると、エラーが発生した場所が分かります。"
	f.WriteLine  " g_is_compile_debug = 1"
	f.WriteLine  ""
	f.WriteLine  GetFullPath( "T_Err2_DupSymbol.vbs", Empty )+"(0, 1) Microsoft VBScript 実行時エラー: 名前が二重に定義されています。"
	f.WriteLine  ""
	f.WriteLine  "<ERROR err_number='1041' err_description='名前が二重に定義されています。'/>"

	Pass
End Sub


'***********************************************************************
'* Function: Test_start
'***********************************************************************
Sub  Test_start( tests )
	T_Err2_Pass
	TestAndCheckByFC      "T_Err2_Main"
	TestAndCheckByFC      "T_Err2_Clear"
	ManualTest            "T_Err2_Clear_w"
	TestAndCheckByFC_Err  "T_Err2_Debug0_NoDebugger", 500
	TestAndCheckByFC_Err  "T_Err2_ClearNot", 1
	ManualTest            "T_Err2_ClearNot_w"
	ManualTest            "T_Err2_ManualTest\T_Err2_Debug*_WithDebugger_*"
	TestAndCheckByFC      "T_Err2_Debug1_NoDebugger"
	TestAndCheckByFC      "T_Err2_Debug2_NoDebugger"
	TestAndCheckByFC_Err  "T_Err2_NotDim", 500
	T_Err2_DupSymbol
	ManualTest            "T_ErrInfo_Err_prompt_close2"
	Pass
End Sub


'***********************************************************************
'* Function: T_Err2_Pass
'***********************************************************************
Sub  T_Err2_Pass()
	Dim  r
	Const  t_name = "T_Err2_Pass"
	EchoTestStart  t_name
	If g_fs.FileExists( t_name+"_log.txt" ) Then  g_fs.DeleteFile  t_name+"_log.txt"
	r= RunProg( "cscript //nologo "+ t_name +".vbs /ChildProcess:0",  t_name +"_log.txt" )
	If Not fc_r( t_name +"_log.txt",  t_name +"_ans.txt", "" ) Then  Fail
	CheckTestErrLevel  r
End Sub


'***********************************************************************
'* Function: TestAndCheckByFC
'*    エラーが発生しないときのテスト
'***********************************************************************
Sub  TestAndCheckByFC( in_T_Name )
	Dim  r, e

	echo  ""
	echo  ">> T_Err2 >> "+ in_T_Name

	If g_fs.FileExists( in_T_Name+"_log.txt" ) Then  g_fs.DeleteFile  in_T_Name+"_log.txt"
	If TryStart(e) Then  On Error Resume Next

		r= RunProg( "cscript //nologo "+ in_T_Name +".vbs /ChildProcess:0",  in_T_Name +"_log.txt" )
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If Not fc_r( in_T_Name +"_log.txt",  in_T_Name +"_ans.txt", "" ) Then  Fail
End Sub


'***********************************************************************
'* Function: TestAndCheckByFC_Err
'*    エラーが発生するときのテスト
'*
'* Description:
'*    ここでは、/ChildProcess:0 の プロセスA を生成して、
'*    そこから、/ChildProcess:0 ではない、テスト対象となる プロセスB を生成して、
'*    その echo ログが正しいことをチェックします。
'*    プロセスA は、エラーが発生してもウィンドウを閉じるためと、
'*    どの Test.vbs から起動してもエラーの通し番号が変わらないように
'*    （プロセスA でリセット）するため。
'*    ウィンドウが閉じないことのテストは、別途、手動テストで行います。
'*
'* Cakk Tree:
'* - TestAndCheckByFC_Err
'* - | g_sh.Run  Test.vbs  // プロセスA、テスト対象のホスト
'* - | | TestAndCheckByFC_Err_Sub
'* - | | | g_sh.Run  (T_Name).vbs  // プロセスB、テスト対象
'***********************************************************************
Sub  TestAndCheckByFC_Err( in_T_Name,  in_ExpectedErrorNum )
	If g_is64bitWindows = g_is64bitWSH Then
		cscript_exe = env("%windir%\System32\cscript.exe")
	Else
		cscript_exe = env("%windir%\SysWOW64\cscript.exe")
	End If

	echo  ""
	echo  ">> T_Err2 >> "+ in_T_Name

	r= g_sh.Run( "cmd /c ( "+ cscript_exe +" //nologo Test.vbs /ChildProcess:0 /Main:TestAndCheckByFC_Err_Sub "+ _
		"/T_Name:"+ in_T_Name +" /Expected:"+ CStr( in_ExpectedErrorNum ) +")",, True )
	CheckTestErrLevel  r
End Sub


'***********************************************************************
'* Function: TestAndCheckByFC_Err_Sub
'***********************************************************************
Sub  TestAndCheckByFC_Err_Sub( Opt, AppKey )
	Dim  r
	Dim  e  ' as Err2

	a_test_name = WScript.Arguments.Named( "T_Name" )
	expected_error_num = CLng( WScript.Arguments.Named( "Expected" ) )
	Set w_= AppKey.NewWritable( a_test_name +"_log.txt" ).Enable()
	If g_is64bitWindows = g_is64bitWSH Then
		cscript_exe = env("%windir%\System32\cscript.exe")
	Else
		cscript_exe = env("%windir%\SysWOW64\cscript.exe")
	End If
	If g_fs.FileExists( a_test_name +"_log.txt") Then _
		g_fs.DeleteFile  a_test_name+"_log.txt"

	echo  ""
	echo  ">> T_Err2 >> "+ a_test_name +" >> "+ a_test_name +".vbs"

	If TryStart(e) Then  On Error Resume Next

		r= g_sh.Run( "cmd /c ( "+ cscript_exe +" //nologo "+ a_test_name +".vbs  2>&1 ) >>"+ _
			a_test_name +"_log.txt",, True )

	If TryEnd Then  On Error GoTo 0
	If e.num = expected_error_num  Then  e.Clear
	If e.num <> 0 Then  e.Raise

	If Not fc_r( a_test_name+"_log.txt",  a_test_name+"_ans.txt", "" ) Then  Fail
End Sub


'***********************************************************************
'* Function: T_Err2_DupSymbol
'***********************************************************************
Sub  T_Err2_DupSymbol()
	echo  ""
	echo  ">> T_Err2 >> T_Err2_DupSymbol"

	If g_is64bitWindows = g_is64bitWSH Then
		cscript_exe = env("%windir%\System32\cscript.exe")
	Else
		cscript_exe = env("%windir%\SysWOW64\cscript.exe")
	End If
	del  "T_Err2_DupSymbol_log.txt"

	r= g_sh.Run( "cmd /c ( "+ cscript_exe +" //nologo T_Err2_DupSymbol.vbs /ChildProcess:0 2>&1 ) "+_
		">>T_Err2_DupSymbol_log.txt",, True )
	If not fc( "T_Err2_DupSymbol_log.txt", "T_Err2_DupSymbol_ans.txt" ) Then  Fail
End Sub


'***********************************************************************
'* Functions:
'*    Callback function from Test.vbs.
'***********************************************************************
Sub  Test_current( tests ) : End Sub
Sub  Test_build( tests ) : Pass : End Sub
Sub  Test_check( tests ) : Pass : End Sub
Sub  Test_clean( tests ) : Pass : End Sub


 







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

 
