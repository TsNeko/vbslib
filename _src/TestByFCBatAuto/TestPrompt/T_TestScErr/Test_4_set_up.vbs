Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject( "WScript.Shell" )

If LCase( Right( WScript.FullName, 11 ) ) = "wscript.exe" Then
	CreateObject("WScript.Shell").Run _
		""""+g_sh.ExpandEnvironmentStrings( "%windir%" )+"\system32\cmd.exe"" /K "+_
		"cscript //nologo """+WScript.ScriptFullName+""""
	WScript.Quit  0
End If

base = g_fs.GetParentFolderName( WScript.ScriptFullName )
g_sh.CurrentDirectory = base


out = "Test_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_TestScErr - Test_current"
file.WriteLine  "<Section tree=""T_TestScErr - Test_current"">"
file.WriteLine  "  ((( [T_TestScErr] )))"
file.WriteLine  "This is ManualTest."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_TestScErr - Test_build"
file.WriteLine  "<Section tree=""T_TestScErr - Test_build"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_TestScErr\Test_target.vbs] - Test_build )))"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_TestScErr - Test_setup"
file.WriteLine  "<Section tree=""T_TestScErr - Test_setup"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_TestScErr\Test_target.vbs] - Test_setup )))"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_TestScErr - Test_start"
file.WriteLine  "<Section tree=""T_TestScErr - Test_start"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_TestScErr\Test_target.vbs] - Test_start )))"
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target.vbs"" /g_debug:3"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] [ERROR](500) この変数は宣言されていません。"
file.WriteLine  " in ""Test_start"" function in """+ base +"\Test_target.vbs"""
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_TestScErr - Test_check"
file.WriteLine  "<Section tree=""T_TestScErr - Test_check"">"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_TestScErr - Test_clean"
file.WriteLine  "<Section tree=""T_TestScErr - Test_clean"">"
file.WriteLine  "</Section>"
file.WriteLine  "[ManualTest] T_TestScErr in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=2, Manual=1, Skip=0, Fail=1)"
file.WriteLine  ""
file = Empty


out = "Test_sub_err_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target_sub_proc.vbs"" /g_debug:1;1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] [ERROR](500) この変数は宣言されていません。"
file.WriteLine  " in ""Test_start"" function in """+ base +"\Test_target_sub_proc.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=0, Skip=0, Fail=1)"
file.WriteLine  ""
file = Empty


out = "Test_sub_fail_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target_sub_proc.vbs"" /g_debug:1;1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] Fail the Test"
file.WriteLine  " in ""Test_check"" function in """+ base +"\Test_target_sub_proc.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=0, Skip=0, Fail=1)"
file.WriteLine  ""
file = Empty



WScript.Echo  "Done."
WScript.Quit  21
