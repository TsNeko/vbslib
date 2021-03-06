Sub  Main( Opt, AppKey )
	t = WScript.Arguments.Named.Item("Test")
	If t="T_TestOrder"       or t="ALL" Then  b=1 : T_TestOrder        AppKey
	If t="T_LoadTestSet"     or t="ALL" Then  b=1 : T_LoadTestSet      AppKey
	If t="T_TestReport"      or t="ALL" Then  b=1 : T_TestReport       AppKey
	If t="T_CleanWhenFailed" or t="ALL" Then  b=1 : T_CleanWhenFailed  AppKey
	If t="T_ParentTestErr"   or t="ALL" Then  b=1 : T_ParentTestErr    AppKey
	If t="" Then  b=1 : T_CleanWhenFailed  AppKey  '// is debugging now
	If b <> 1 Then  Error
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TestOrder] TestOfTest1 >>> 
'********************************************************************************
Sub  T_TestOrder( AppKey )
	g_Test.m_DefLogFName = "TestOfTest1_logs.txt"

	Dim  ts : Set ts = new Tests
	ts.AddTestScriptAuto  ".", "TestOfTest1.vbs"
	ts.DoAllTest
End Sub

 
'********************************************************************************
'  <<< [T_LoadTestSet] >>> 
'********************************************************************************
Sub  T_LoadTestSet( AppKey )
	g_Test.m_DefLogFName = "T_LoadTestSet_logs.txt"

	Dim  ts : Set ts = new Tests
	ts.AddTestScriptAuto  ".", "TestOfTest1.vbs"
	ts.LoadTestSet  "TestCommon_Data.xml", ".", "TestSymbols"
	ts.DoAllTest
End Sub

 
'********************************************************************************
'  <<< [T_TestReport] TestOfTest2(1) >>> 
'********************************************************************************
Sub  T_TestReport( AppKey )
	Dim  t, ts
	Dim  w_:Set w_=AppKey.NewWritable( "." ).Enable()

	g_Test.m_DefLogFName = "TestOfTest2_1_logs.txt"

	Set ts = new Tests
	ts.AddTestScriptAuto  ".", "TestOfTest2.vbs"
	ts.DoAllTest
	T_TestReport_Check1_sub


	'//=== CSV, HTML の出力ファイルをチェック
	del  "TestResult.csv"
	del  "TestResult.html"

	ts.SaveTestResultCSV   Empty
	ts.SaveTestResultHtml  Empty

	Assert fc( "TestResult.csv",  "TestOfTest2_1_Result_ans.csv" )
If 0 Then
	Assert fc( "TestResult.html", "TestOfTest2_1_Result_ans.html" )
End If : Skipped


	'//=== 続きを実行する
	ts.DoAllTest
	T_TestReport_Check2_sub


	'//=== テスト結果をリセットする
	ts.ResetTestResult
	ts.DoAllTest
	T_TestReport_Check1_sub


	'//=== テスト結果を復帰する
	Set ts = new Tests
	ts.AddTestScriptAuto  ".", "TestOfTest2.vbs"
	ts.LoadTestResultCSV  Empty
	ts.DoAllTest
	T_TestReport_Check2_sub


	'//=== 後始末
	del  "TestResult.csv"
	del  "TestResult.html"
End Sub


Sub  T_TestReport_Check1_sub()
	Dim  t

	'//=== コールバックされた関数をチェック。 Fail した後は、関数を呼ばない
	t = ReadFile( g_Test.m_DefLogFName )
	Assert  InStr( t, "[T_SampA\TestOfTest2.vbs] - Test_clean" ) > 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_check" ) = 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_clean" ) = 0
	Assert  InStr( t, "[T_SampC\TestOfTest2.vbs] - Test_check" ) = 0
	Assert  InStr( t, "[T_SampC\TestOfTest2.vbs] - Test_clean" ) > 0
	Assert  InStr( t, "[T_SomeTests\TestOfTest2.vbs] - Test_clean" ) = 0
	del  g_Test.m_DefLogFName
End Sub


Sub  T_TestReport_Check2_sub()
	Dim  t

	'//=== コールバックされた関数をチェック。 Fail した後は、関数を呼ばない
	t = ReadFile( g_Test.m_DefLogFName )
	Assert  InStr( t, "[T_SampA\TestOfTest2.vbs]" ) = 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_build" ) = 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_setup" ) = 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_start" ) > 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_check" ) = 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_clean" ) = 0
	Assert  InStr( t, "[T_SampC\TestOfTest2.vbs]" ) = 0
	Assert  InStr( t, "[T_SomeTests\TestOfTest2.vbs]" ) = 0
	del  g_Test.m_DefLogFName
End Sub


 
'********************************************************************************
'  <<< [T_CleanWhenFailed] TestOfTest2(2) >>> 
'********************************************************************************
Sub  T_CleanWhenFailed( AppKey )
	Dim  t, ts
	Dim  w_:Set w_=AppKey.NewWritable( "." ).Enable()

	g_Test.m_DefLogFName = "TestOfTest2_2_logs.txt"

	Set ts = new Tests
	ts.AddTestScriptAuto  ".", "TestOfTest2.vbs"
	ts.DoAllTest  '// Failed

	ts.DoTest  "Test_clean", True


	'//=== コールバックされた関数をチェック。 Fail しても Test_clean は、すべてコールバックされること。
	t = ReadFile( g_Test.m_DefLogFName )
	Assert  InStr( t, "[T_SampA\TestOfTest2.vbs] - Test_clean" ) > 0
	Assert  InStr( t, "[T_SampB\TestOfTest2.vbs] - Test_clean" ) > 0
	Assert  InStr( t, "[T_SampC\TestOfTest2.vbs] - Test_clean" ) > 0
	Assert  InStr( t, "[T_SomeTests\TestOfTest2.vbs] - Test_clean" ) > 0
	del  g_Test.m_DefLogFName
End Sub


 
'********************************************************************************
'  <<< [T_ParentTestErr] TestOfTest3 >>> 
'********************************************************************************
Sub  T_ParentTestErr( AppKey )
	Dim  t, ts
	Dim  w_:Set w_=AppKey.NewWritable( "." ).Enable()

	g_Test.m_DefLogFName = "TestOfTest3_logs.txt"

	Set ts = new Tests
	ts.AddTestScriptAuto  ".", "TestOfTest3.vbs"
	ts.DoAllTest


	'//=== コールバックされた関数をチェック
	t = ReadFile( g_Test.m_DefLogFName )
	Assert  InStr( t, "[T_SomeTests\TestOfTest3.vbs] - Test_build" ) > 0
	Assert  InStr( t, "[T_SomeTests\TestOfTest3.vbs] - Test_setup" ) > 0
	Assert  InStr( t, "[T_SomeTests\TestOfTest3.vbs] - Test_start" ) = 0
	Assert  InStr( t, "[T_SampA\TestOfTest3.vbs] - Test_build" ) > 0
	Assert  InStr( t, "[T_SampA\TestOfTest3.vbs] - Test_setup" ) = 0
	del  g_Test.m_DefLogFName
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


 
