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
g_is64bitWindows = g_fs.FolderExists( g_sh.ExpandEnvironmentStrings( "%windir%\SysWOW64" ) )


test_target = "T_fcNoFeq1.vbs"

test_name = "T_fcNoFeq1"
WScript.Echo  "((( ["+ test_name +"] )))"
r= RunProg( "cscript //nologo "+ test_target,  test_name +"_log.txt" )
If not fc( test_name +"_log.txt",  test_name +"_ans.txt" ) Then  Err.Raise 507


WScript.Echo  "Pass."
WScript.Quit  21


 
'*************************************************************************
'  <<< [RunProg] >>> 
'*************************************************************************
Function  RunProg( ByVal CommandLine, RedirectPath )
	WScript.Echo  g_sh.CurrentDirectory +">"+ CommandLine

	If g_is64bitWindows Then
		If Left( CommandLine, 7 ) = "cscript" Then
			CommandLine = Replace( CommandLine, "cscript",_
				g_sh.ExpandEnvironmentStrings( "%windir%\SysWOW64\cscript" ),1,1 )
		End If
	End If

	Set ex = g_sh.Exec( CommandLine )

	If RedirectPath <> ""  and  RedirectPath <> "nul" Then
		is_unicode = False
		Set file = g_fs.CreateTextFile( RedirectPath, True, is_unicode )
	End If

	Do While ex.Status = 0
		If RedirectPath = "nul" or IsEmpty( RedirectPath ) Then
			Do Until ex.StdOut.AtEndOfStream : ex.StdOut.ReadLine : Loop
			Do Until ex.StdErr.AtEndOfStream : ex.StdErr.ReadLine : Loop
		ElseIf RedirectPath = "" Then
			EchoStream  ex.StdOut, WScript.StdOut, ex, g_ChildHead
			EchoStream  ex.StdErr, WScript.StdErr, ex, g_ChildHead
		Else
			Do Until ex.StdOut.AtEndOfStream
				line = ex.StdOut.ReadLine
				file.WriteLine  line
				WScript.Echo  line
			Loop
			Do Until ex.StdErr.AtEndOfStream
				line = ex.StdErr.ReadLine
				file.WriteLine  line
				WScript.Echo  line
			Loop
		End If
	Loop

	If RedirectPath = "nul" or IsEmpty( RedirectPath ) Then
		Do Until ex.StdOut.AtEndOfStream : ex.StdOut.ReadLine : Loop
		Do Until ex.StdErr.AtEndOfStream : ex.StdErr.ReadLine : Loop
	ElseIf RedirectPath = "" Then
		EchoStream  ex.StdOut, WScript.StdOut, ex, g_ChildHead
		EchoStream  ex.StdErr, WScript.StdErr, ex, g_ChildHead
	Else
		Do Until ex.StdOut.AtEndOfStream
			line = ex.StdOut.ReadLine
			file.WriteLine  line
			WScript.Echo  line
		Loop
		Do Until ex.StdErr.AtEndOfStream
			line = ex.StdErr.ReadLine
			file.WriteLine  line
			WScript.Echo  line
		Loop
	End If
	WScript.Echo  ""
	RunProg = ex.ExitCode
End Function


Dim  g_EchoStreamBuf
Sub  EchoStream( StreamIn, StreamOut, ex, Prompt )
	Dim  c, b, i

	Do Until StreamIn.AtEndOfStream
		c = StreamIn.Read(1)
		If c <> vbCR and c <> vbLF Then
			If g_EchoStreamBuf = "" Then  StreamOut.Write  Prompt
			g_EchoStreamBuf = g_EchoStreamBuf + c
		End If

		'// pause のみ対応
		If Left( g_EchoStreamBuf, 6 ) = "続行するには" Then
			i = 0
			If g_EchoStreamBuf="続行するには何かキーを押してください . . . " Then  i = 1
			If g_EchoStreamBuf=Left(g_PauseMsg,g_PauseMsgStone)+"*"+Chr(8) Then  i = 3
			If g_EchoStreamBuf=g_PauseMsg Then  i = 2
			If i > 0 Then
				StreamOut.Write  c
				If ex.Status = 0 Then
					If i < 3 Then
						WScript.StdIn.ReadLine  '// Waiting Enter from only main process
						If i = 1 Then
							ex.StdIn.Write  vbCR
							StreamIn.ReadLine
						Else
							ex.StdIn.Write  vbCRLF
						End If
					End If
				End If
				If not IsEmpty( g_Test ) Then  g_Test.WriteLogLine  g_EchoStreamBuf
				g_EchoStreamBuf = ""
				c = ""
			End If
		End If

		'// echo
		If c = vbLF Then
			StreamOut.Write  vbLF
			If not IsEmpty( g_Test ) Then  g_Test.WriteLogLine  g_EchoStreamBuf
			g_EchoStreamBuf = ""
		Else
			StreamOut.Write  c
		End If
	Loop
End Sub


 
'*************************************************************************
'  <<< [fc] >>> 
'*************************************************************************
Function  fc( PathA, PathB )
	WScript.Echo  ">fc  """+ PathA +""", """+ PathB +""""
	Set file = g_fs.OpenTextFile( PathA,,,-2 )
	TextA = file.ReadAll()
	Set file = g_fs.OpenTextFile( PathB,,,-2 )
	TextB = file.ReadAll()
	fc = ( TextA = TextB )
End Function


 
