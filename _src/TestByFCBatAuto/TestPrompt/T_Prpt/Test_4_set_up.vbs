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


out = "ans\Test_logs_2.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_current"
file.WriteLine  "<Section tree=""T_Prpt - Test_current"">"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_build"
file.WriteLine  "<Section tree=""T_Prpt - Test_build"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_build )))"
file.WriteLine  "  ((( [T_Prpt] )))"
file.WriteLine  "This is ManualTest."
file.WriteLine  "Test_build"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_setup"
file.WriteLine  "<Section tree=""T_Prpt - Test_setup"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_setup )))"
file.WriteLine  "Test_setup"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_start"
file.WriteLine  "<Section tree=""T_Prpt - Test_start"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_start )))"
file.WriteLine  "Test_start"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_check"
file.WriteLine  "<Section tree=""T_Prpt - Test_check"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_check )))"
file.WriteLine  "Test_check"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_clean"
file.WriteLine  "<Section tree=""T_Prpt - Test_clean"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_clean )))"
file.WriteLine  "Test_clean"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  "[ManualTest] T_Prpt in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=5, Manual=1, Skip=0, Fail=0)"
file.WriteLine  "ExpectedPassConut = 5 [OK]"
file.WriteLine  ""
file = Empty


out = "ans\Test_logs_2_Err.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_current"
file.WriteLine  "<Section tree=""T_Prpt - Test_current"">"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_build"
file.WriteLine  "<Section tree=""T_Prpt - Test_build"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_build )))"
file.WriteLine  "  ((( [T_Prpt] )))"
file.WriteLine  "This is ManualTest."
file.WriteLine  "Test_build"
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] Fail the Test"
file.WriteLine  " in ""Test_build"" function in """+ base +"\Test_target.vbs"""
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_setup"
file.WriteLine  "<Section tree=""T_Prpt - Test_setup"">"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_start"
file.WriteLine  "<Section tree=""T_Prpt - Test_start"">"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_check"
file.WriteLine  "<Section tree=""T_Prpt - Test_check"">"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_Prpt - Test_clean"
file.WriteLine  "<Section tree=""T_Prpt - Test_clean"">"
file.WriteLine  "</Section>"
file.WriteLine  "[ManualTest] T_Prpt in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=1, Skip=0, Fail=1)"
file.WriteLine  "ExpectedPassConut = 5 [FAIL]"
file.WriteLine  ""
file = Empty


out = "ans\Test_logs_3.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_build )))"
file.WriteLine  "  ((( [T_Prpt] )))"
file.WriteLine  "This is ManualTest."
file.WriteLine  "Test_build"
file.WriteLine  "Pass."
file.WriteLine  "[ManualTest] T_Prpt in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=1, Manual=1, Skip=0, Fail=0)"
file.WriteLine  "ExpectedPassConut = 5 [FAIL]"
file.WriteLine  ""
file = Empty


out = "ans\Test_logs_3_Err.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_build )))"
file.WriteLine  "  ((( [T_Prpt] )))"
file.WriteLine  "This is ManualTest."
file.WriteLine  "Test_build"
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] Fail the Test"
file.WriteLine  " in ""Test_build"" function in """+ base +"\Test_target.vbs"""
file.WriteLine  "[ManualTest] T_Prpt in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=1, Skip=0, Fail=1)"
file.WriteLine  "ExpectedPassConut = 5 [FAIL]"
file.WriteLine  ""
file = Empty


out = "ans\Test_logs_4_Err.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_setup )))"
file.WriteLine  "Test_setup"
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] Fail the Test"
file.WriteLine  " in ""Test_setup"" function in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=0, Skip=0, Fail=1)"
file.WriteLine  "ExpectedPassConut = 5 [FAIL]"
file.WriteLine  ""
file = Empty


out = "ans\Test_logs_5_Err.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_start )))"
file.WriteLine  "Test_start"
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] Fail the Test"
file.WriteLine  " in ""Test_start"" function in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=0, Skip=0, Fail=1)"
file.WriteLine  "ExpectedPassConut = 5 [FAIL]"
file.WriteLine  ""
file = Empty


out = "ans\Test_logs_6_Err.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_check )))"
file.WriteLine  "Test_check"
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] Fail the Test"
file.WriteLine  " in ""Test_check"" function in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=0, Skip=0, Fail=1)"
file.WriteLine  "ExpectedPassConut = 5 [FAIL]"
file.WriteLine  ""
file = Empty


out = "ans\Test_logs_7_Err.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_Prpt\Test_target.vbs] - Test_clean )))"
file.WriteLine  "Test_clean"
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """Test_target.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "[FAIL] Fail the Test"
file.WriteLine  " in ""Test_clean"" function in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=0, Manual=0, Skip=0, Fail=1)"
file.WriteLine  "ExpectedPassConut = 5 [FAIL]"
file.WriteLine  ""
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
