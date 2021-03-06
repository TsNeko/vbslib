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


out = "T_DOpt1_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left*.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\target\*.txt"" without sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same: "+ base +"\target\right1.txt"
file.WriteLine  "  matched part file: left1.txt"
file.WriteLine  "Same: "+ base +"\target\right2.txt"
file.WriteLine  "  matched part file: left1.txt"
file.WriteLine  "違いあり: "+ base +"\target\right3.txt"
file.WriteLine  "Same: "+ base +"\target\right4.txt"
file.WriteLine  "  matched part file: left2.txt"
file.WriteLine  "違いあり: "+ base +"\target\right5.txt"
file.WriteLine  ""
file.WriteLine  "-----------------------------------------------------"
file.WriteLine  ""
file.WriteLine  "Same as left1.txt are 2 files"
file.WriteLine  ""+ base +"\target\right1.txt"
file.WriteLine  ""+ base +"\target\right2.txt"
file.WriteLine  ""
file.WriteLine  "Same as left2.txt are 1 files"
file.WriteLine  ""+ base +"\target\right4.txt"
file.WriteLine  ""
file.WriteLine  "Others are 2 files"
file.WriteLine  ""+ base +"\target\right3.txt"
file.WriteLine  ""+ base +"\target\right5.txt"
file.WriteLine  ""
file.WriteLine  "Total 5 files"
file = Empty


out = "T_DOpt2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left*.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\target\*.txt"" with sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same: "+ base +"\target\right1.txt"
file.WriteLine  "  matched part file: left1.txt"
file.WriteLine  "Same: "+ base +"\target\right2.txt"
file.WriteLine  "  matched part file: left1.txt"
file.WriteLine  "違いあり: "+ base +"\target\right3.txt"
file.WriteLine  "Same: "+ base +"\target\right4.txt"
file.WriteLine  "  matched part file: left2.txt"
file.WriteLine  "違いあり: "+ base +"\target\right5.txt"
file.WriteLine  "Same: "+ base +"\target\2\right1.txt"
file.WriteLine  "  matched part file: left1.txt"
file.WriteLine  ""
file.WriteLine  "-----------------------------------------------------"
file.WriteLine  ""
file.WriteLine  "Same as left1.txt are 3 files"
file.WriteLine  ""+ base +"\target\right1.txt"
file.WriteLine  ""+ base +"\target\right2.txt"
file.WriteLine  ""+ base +"\target\2\right1.txt"
file.WriteLine  ""
file.WriteLine  "Same as left2.txt are 1 files"
file.WriteLine  ""+ base +"\target\right4.txt"
file.WriteLine  ""
file.WriteLine  "Others are 2 files"
file.WriteLine  ""+ base +"\target\right3.txt"
file.WriteLine  ""+ base +"\target\right5.txt"
file.WriteLine  ""
file.WriteLine  "Total 6 files"
file = Empty


out = "_out_ans.bat"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "set out="+ base +"\target\right3.txt"
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
