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


out = "T_AOpt1_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  """+ base +"\dst_work\*"""
file.WriteLine  ""+ base +"\dst_work\txt1.txt"
file.WriteLine  ""+ base +"\dst_work\txt2.txt"
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  "2 個のファイルが下記の [From] と一致しました。"
file.WriteLine  "/G オプションを付けて PartRep を起動すると、[To] の内容に置き換えます。"
file.WriteLine  "[From] "+ base +"\from1.txt"
file.WriteLine  "[To]   "+ base +"\to1.txt"
file.WriteLine  "[From] "+ base +"\from2.txt"
file.WriteLine  "[To]   "+ base +"\to2.txt"
file = Empty


out = "T_AOpt1_g_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst_work\*"""
file.WriteLine  ""+ base +"\dst_work\txt1.txt"
file.WriteLine  ""+ base +"\dst_work\txt2.txt"
file.WriteLine  ""+ base +"\dst_work\sub\txt1.txt"
file.WriteLine  "3 個のファイルを置き換えました。"
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
