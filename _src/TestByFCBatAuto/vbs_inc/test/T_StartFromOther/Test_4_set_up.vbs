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


out = "T_StartFromOther_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "g_sh.CurrentDirectory = "+ base +""
file = Empty


out = "T_StartFromOther_Manually_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">cscript.exe """+ base +"\T_StartFromOther_Manually_sub.vbs"""
file.WriteLine  "g_start_in_path = "+ base +"\T_StartFromOther"
file.WriteLine  "g_vbslib_path = %base_vbslib%\vbslib\vbs_inc_sub.vbs"
file = Empty


out = "T_StartFromOther_Manually_out_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "g_sh.CurrentDirectory = "+ base +""
file.WriteLine  "g_start_in_path = "+ base +"\T_StartFromOther"
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
