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
file.WriteLine  "Investigating in """+ base +"\1\*"" with sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same: "+ base +"\1\right1.txt"
file.WriteLine  "Same: "+ base +"\1\right2.txt"
file.WriteLine  "All Same."
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
file.WriteLine  "Investigating in """+ base +"\2\*"" with sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same: "+ base +"\2\right1.txt"
file.WriteLine  "Same: "+ base +"\2\right2.txt"
file.WriteLine  "違いあり: "+ base +"\2\right3.txt"
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
file.WriteLine  "Investigating in """+ base +"\3\*"" with sub folder ..."
file.WriteLine  ""
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """PartCmp.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "<ERROR msg=""開始タグを含むファイルが見つかりませんでした。"" search_folder="""+ base +""" file=""3\*"" start_tag=""[start]""/>"
file = Empty


out = "T_OutBat1_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\1\*"" with sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same: "+ base +"\1\right1.txt"
file.WriteLine  "Same: "+ base +"\1\right2.txt"
file.WriteLine  "All Same."
file = Empty


out = "T_OutBat2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\2\*"" with sub folder ..."
file.WriteLine  ""
file.WriteLine  "Same: "+ base +"\2\right1.txt"
file.WriteLine  "Same: "+ base +"\2\right2.txt"
file.WriteLine  "違いあり: "+ base +"\2\right3.txt"
file = Empty


out = "T_OutBat2_out_ans.bat"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "set out="+ base +"\2\right3.txt"
file = Empty


out = "T_OutBat3_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "[PartCmp]"
file.WriteLine  "PartStartTag: ""[start]"""
file.WriteLine  "MasterPartFile: """+ base +"\left1.txt"""
file.WriteLine  ""
file.WriteLine  "Investigating in """+ base +"\3\*"" with sub folder ..."
file.WriteLine  ""
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """PartCmp.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "<ERROR msg=""開始タグを含むファイルが見つかりませんでした。"" search_folder="""+ base +""" file=""3\*"" start_tag=""[start]""/>"
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
