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


out = "ans\Test_log_1.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_current"
file.WriteLine  "<Section tree=""T_SubTest - Test_current"">"
file.WriteLine  "Current = Sub1"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_build"
file.WriteLine  "<Section tree=""T_SubTest - Test_build"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_build )))"
file.WriteLine  "  ((( [T_SubTest] )))"
file.WriteLine  "This is ManualTest."
file.WriteLine  "T_SubTest - Test_build Sub1"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_setup"
file.WriteLine  "<Section tree=""T_SubTest - Test_setup"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_setup )))"
file.WriteLine  "T_SubTest - Test_setup Sub1"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_start"
file.WriteLine  "<Section tree=""T_SubTest - Test_start"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_start )))"
file.WriteLine  "T_SubTest - Test_start Sub1"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_check"
file.WriteLine  "<Section tree=""T_SubTest - Test_check"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_check )))"
file.WriteLine  "T_SubTest - Test_check Sub1"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_clean"
file.WriteLine  "<Section tree=""T_SubTest - Test_clean"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_clean )))"
file.WriteLine  "T_SubTest - Test_clean Sub1"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  "[ManualTest] T_SubTest in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=5, Manual=1, Skip=0, Fail=0)"
file.WriteLine  ""
file = Empty


out = "ans\Test_log_2.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "Test Start : Test_target.vbs"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_current"
file.WriteLine  "<Section tree=""T_SubTest - Test_current"">"
file.WriteLine  "Current = Sub2"
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_build"
file.WriteLine  "<Section tree=""T_SubTest - Test_build"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_build )))"
file.WriteLine  "  ((( [T_SubTest] )))"
file.WriteLine  "This is ManualTest."
file.WriteLine  "T_SubTest - Test_build Sub2"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_setup"
file.WriteLine  "<Section tree=""T_SubTest - Test_setup"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_setup )))"
file.WriteLine  "T_SubTest - Test_setup Sub2"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_start"
file.WriteLine  "<Section tree=""T_SubTest - Test_start"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_start )))"
file.WriteLine  "T_SubTest - Test_start Sub2"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_check"
file.WriteLine  "<Section tree=""T_SubTest - Test_check"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_check )))"
file.WriteLine  "T_SubTest - Test_check Sub2"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  ""
file.WriteLine  "SectionTree >> T_SubTest - Test_clean"
file.WriteLine  "<Section tree=""T_SubTest - Test_clean"">"
file.WriteLine  "=========================================================="
file.WriteLine  "((( [T_SubTest\Test_target.vbs] - Test_clean )))"
file.WriteLine  "T_SubTest - Test_clean Sub2"
file.WriteLine  "Pass."
file.WriteLine  "</Section>"
file.WriteLine  "[ManualTest] T_SubTest in """+ base +"\Test_target.vbs"""
file.WriteLine  "=========================================================="
file.WriteLine  "Test Finish (Pass=5, Manual=1, Skip=0, Fail=0)"
file.WriteLine  ""
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
