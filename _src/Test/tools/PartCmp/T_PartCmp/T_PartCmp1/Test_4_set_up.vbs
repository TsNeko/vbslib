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


out = "T_Basic1_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\right1.txt"" without sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same."
file = Empty


out = "T_Basic2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\right2.txt"" without sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same."
file = Empty


out = "T_Basic3_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\right3.txt"" without sub folder ..."
file.WriteLine  ""
file.WriteLine  "diff"
file = Empty

out = "T_Basic4_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\right4.txt"" without sub folder ..."
file.WriteLine  ""
file.WriteLine  "diff"
file = Empty


out = "T_Basic5_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\right5.txt"" without sub folder ..."
file.WriteLine  ""
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """PartCmp.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "<ERROR err_number='101' err_description='Not found ""[start]"" in the start 50 lines or 256 characters in """+ base +"\right5.txt""'/>"
file = Empty

out = "T_Bin_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\bin1.bin"" without sub folder ..."
file.WriteLine  ""
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """PartCmp.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "<ERROR err_number='101' err_description='Not found ""[start]"" in the start 50 lines or 256 characters in """+ base +"\bin1.bin""'/>"
file = Empty


out = "T_ParamErr_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "PartCmp  part_file  whole_file  start_tag"
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
