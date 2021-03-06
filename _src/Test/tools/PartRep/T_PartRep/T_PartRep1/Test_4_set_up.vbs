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


out = "T_Basic_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst1_x.txt"""
file.WriteLine  ""+ base +"\dst1_x.txt"
file.WriteLine  "1 個のファイルを置き換えました。"
file = Empty


out = "T_BigHeadDst_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst60_x.txt"""
file.WriteLine  "Not found """+ base +"\from1.txt"" in the start 50 lines or 256 characters in """+ base +"\dst60_x.txt"""
file = Empty


out = "T_BigReplace_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst60_x.txt"""
file.WriteLine  "Not found """+ base +"\src60.txt"" in the start 50 lines or 256 characters in """+ base +"\dst60_x.txt"""
file = Empty


out = "T_BigTo_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst1_x.txt"""
file.WriteLine  "Too big """+ base +"\src60.txt"""
file = Empty


out = "T_Bin_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\bin1_x.bin"""
file.WriteLine  "Not found """+ base +"\from1.txt"" in the start 50 lines or 256 characters in """+ base +"\bin1_x.bin"""
file = Empty


out = "T_HitPart_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst2_x.txt"""
file.WriteLine  "Not found """+ base +"\from1.txt"" in the start 50 lines or 256 characters in """+ base +"\dst2_x.txt"""
file = Empty


out = "T_BigFrom_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst1_x.txt"""
file.WriteLine  "Not found """+ base +"\src60.txt"" in the start 50 lines or 256 characters in """+ base +"\dst1_x.txt"""
file = Empty


out = "T_PartMatch1_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst3_x.txt"""
file.WriteLine  ""+ base +"\dst3_x.txt"
file.WriteLine  "1 個のファイルを置き換えました。"
file = Empty


out = "T_PartMatch2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "-------------------------------------------------------------------------------"
file.WriteLine  ">PartRep_replaceFiles  /G """+ base +"\dst4_x.txt"""
file.WriteLine  ""+ base +"\dst4_x.txt"
file.WriteLine  "1 個のファイルを置き換えました。"
file = Empty


out = "T_ParamErr_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cd  """+ base +""""
file.WriteLine  "PartRep  [/G][/S][/E:path][/A:n]  from_file  to_file  dst_file"
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
