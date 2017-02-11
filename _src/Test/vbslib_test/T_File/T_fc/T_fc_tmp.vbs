Set g_fs = CreateObject( "Scripting.FileSystemObject" )
Set g_sh = WScript.CreateObject( "WScript.Shell" )
Sub  echo( Message ) : WScript.Echo  Message : End Sub
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
ChangeScriptMode
Main


Sub  Main()
	Set f = CreateObject( "ADODB.Stream" )
	f.Type = 1

	f.Open
	f.LoadFromFile  "_work\A\bin.bin"
	a_bin = f.Read( -1 )
	f.Close

	f.Open
	f.LoadFromFile  "_work\B\bin.bin"
	b_bin = f.Read( -1 )
	f.Close

	echo  "000=>"&  StrComp( a_bin, b_bin, 0 )
	Stop
End Sub


 
'*************************************************************************
'  <<< [ChangeScriptMode] >>> 
'*************************************************************************
Sub  ChangeScriptMode()
	If LCase( Right( WScript.FullName, 11 ) ) = "wscript.exe" Then
		path_system32 = g_sh.ExpandEnvironmentStrings( "%windir%\system32" )
		path_WOW64 = g_sh.ExpandEnvironmentStrings( "%windir%\SysWOW64" )

		If g_fs.FolderExists( path_WOW64 ) Then
			If g_is64bitWSH = True Then
				path_system = path_system32
			Else
				path_system = path_WOW64
			End If
		Else
			path_system = path_system32
		End If

		CreateObject("WScript.Shell").Run _
			path_system +"\cmd /K cscript.exe //nologo """+WScript.ScriptFullName+""""
		WScript.Quit  0
	End If
End Sub


 
