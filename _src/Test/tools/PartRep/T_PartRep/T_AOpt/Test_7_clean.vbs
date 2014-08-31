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


If g_fs.FolderExists( work ) Then  g_fs.DeleteFolder  work
del  "*_x.txt"
del  "*_x.bin"
del  "*_log.txt"


WScript.Echo  "Done."
WScript.Quit  21


 
'*************************************************************************
'  <<< [del] >>> 
'*************************************************************************
Sub  del( Path )
	Dim en,ed

	WScript.Echo  ">del  """+ Path +""""

	On Error Resume Next
		If InStr( Path, "*" ) > 0 Then
			g_fs.DeleteFile  Path
		Else
			If g_fs.FileExists( Path ) Then _
				g_fs.DeleteFile  Path
		End If
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 53 Then  en = 0
	If en <> 0 Then  Err.Raise en,,ed
End Sub


 
