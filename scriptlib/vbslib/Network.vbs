'// vbslib - VBScript ShortHand Library  ver4.91  Oct.13, 2014
'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_SrcPath
Dim  g_vbslib_network_Path
     g_vbslib_network_Path = g_SrcPath


g_DownloadChannelCountMax = 8  '//[g_DownloadChannelCountMax]
g_DownloadTimeout_sec = 50     '//[g_DownloadTimeout_sec]


 
'********************************************************************************
'  <<< [DownloadByHttp] >>> 
'********************************************************************************
Sub  DownloadByHttp( DownloadURL, OutLocalPath )
	Set sv = get_VirtualServerAtLocal()
	exe_path = g_vbslib_ver_folder +"sage_p_downloader\sage_p_downloader.exe"
	Set c = g_VBS_Lib


	'// Set first "set_of_URL"
	If IsArray( DownloadURL ) Then
		If UBound( DownloadURL ) >= g_DownloadChannelCountMax Then
			next_index = g_DownloadChannelCountMax
		Else
			next_index = UBound( DownloadURL ) + 1
		End If

		ReDim  set_of_URL( next_index - 1 )
		For i=0  To next_index - 1
			set_of_URL(i) = DownloadURL(i)
		Next
		count_of_DownloadURL = UBound( DownloadURL ) + 1
	Else
		ReDim  set_of_URL(0)
		set_of_URL(0) = DownloadURL
		next_index = 1
		count_of_DownloadURL = 1
	End If


	'// Make the folder
	g_AppKey.CheckWritable  OutLocalPath, Empty
	If IsArray( DownloadURL ) Then
		mkdir  OutLocalPath
	Else
		mkdir_for  OutLocalPath
	End If


	base_index = 0
	Do
		ReDim  asyncs( UBound( set_of_URL ) )


		'// Echo
		echo_flush
		For url_index = 0  To UBound( set_of_URL )
			url = set_of_URL( url_index )

			If count_of_DownloadURL >= 2 Then
				echo_v  "Downloading("& ( base_index + url_index ) &"): "+ url
			Else
				echo_v  "Downloading: "+ url
			End If

			'// Check
			If Left( url, 7 ) <> "http://" Then  Error
				'// ftp: cannot supported
		Next


		'// Start downloading
		For url_index = 0  To UBound( set_of_URL )
			url = set_of_URL( url_index )

			If IsArray( DownloadURL ) Then
				out_local_file_path = OutLocalPath +"\"+ g_fs.GetFileName( url )
			Else
				out_local_file_path = OutLocalPath
			End If
			out_local_file_path = Replace( out_local_file_path, "?", "_" )

			If IsArray( DownloadURL ) Then _
				DownloadURL( base_index + url_index ) = out_local_file_path

			If sv.IsVirtual( url ) Then
				Set asyncs( url_index ) = sv.DownloadAsyncExec( url, out_local_file_path )
			Else
				Set asyncs( url_index ) = _
					g_sh.Exec( """"+ exe_path +""" """+_
						GetPercentURL( url ) +""" """+ out_local_file_path +"""" )
					'// Stdout is not echoed in this function
			End If
		Next


		'// Receive result
		ReDim  is_received( UBound( set_of_URL ) )
		For url_index = 0  To UBound( set_of_URL )
			is_received( url_index ) = False
		Next
		time_out = DateAddStr( Now(), "+"+ CStr( g_DownloadTimeout_sec ) +"sec" )

		Do
			finished_count = 0
			For url_index = 0  To UBound( set_of_URL )
				Set async = asyncs( url_index )

				If is_received( url_index ) Then
					finished_count = finished_count + 1
				ElseIf async.Status = c.WshFinished Then
					If CInt( async.ExitCode ) <> 0 Then
						If count_of_DownloadURL >= 2 Then
							index_message = " index="""& ( base_index + url_index ) &""""
						Else
							index_message = ""
						End If
						Raise 1, "<ERROR msg=""エラーが発生しました。"" exit_code="""&_
							async.ExitCode &""""& index_message &"/>"
					End If
					is_received( url_index ) = True
				End If
			Next


			'// Exit this loop
			If finished_count = UBound( set_of_URL ) + 1 Then
				Exit Do
			End If


			'// Timeout
			If Now() >= time_out Then
				For url_index = 0  To UBound( set_of_URL )
					Set async = asyncs( url_index )

					If async.Status = c.WshRunning Then
						KillProcess  async.ProcessID

						If IsArray( DownloadURL ) Then _
							DownloadURL( base_index + url_index ) = Empty
					End If
				Next

				base_index = base_index + UBound( set_of_URL ) + 1
				For i = base_index  To  count_of_DownloadURL - 1
					If IsArray( DownloadURL ) Then _
						DownloadURL( i ) = Empty
				Next

				Err.Raise  462
			End If


			Sleep  200
		Loop


		'// Exit this loop
		if next_index = count_of_DownloadURL Then
			Exit Do
		End If


		'// Set next "set_of_URL"
		base_index = next_index
		If count_of_DownloadURL - base_index >= g_DownloadChannelCountMax Then
			next_index = base_index + g_DownloadChannelCountMax
		Else
			next_index = count_of_DownloadURL
		End If

		ReDim  set_of_URL( next_index - base_index - 1 )
		For i=0  To UBound( set_of_URL )
			set_of_URL(i) = DownloadURL( base_index + i )
		Next
	Loop
End Sub


 
'********************************************************************************
'  <<< [DownloadByHttp_old] >>> 
'********************************************************************************
Sub  DownloadByHttp_old( DownloadURL, OutLocalPath )
	Dim  sv : Set sv = get_VirtualServerAtLocal()

	echo_flush
	echo_v  ">DownloadByHttp  """+ DownloadURL +""", """+ OutLocalPath +""""

	If Left( DownloadURL, 7 ) <> "http://" Then  Error

	g_AppKey.CheckWritable  OutLocalPath, Empty

	If sv.IsVirtual( DownloadURL ) Then
		copy_ren  sv.GetLocalPath( DownloadURL ), OutLocalPath
	Else
		Dim  http, stream, e, b_manual

		Set http = WScript.CreateObject( "MSXML2.XMLHTTP" )  '// from Internet Explorer 6
		http.Open  "GET", GetPercentURL( DownloadURL ), False

		If TryStart(e) Then  On Error Resume Next
			http.Send
		If TryEnd Then  On Error GoTo 0
		b_manual = False
		If e.num = &h800C0005  Then  b_manual = True : e.Clear
		If e.num <> 0 Then  e.Raise

		If b_manual Then
			echo  ""
			echo  "ファイアーウォールがあるため、代わりの方法でダウンロードします。"
			Do
				echo  ""
				echo  "  "+ DownloadURL
				echo  ""
				echo  "からダウンロードを開始します。ファイルは下記に保存してください。"
				echo  ""
				echo  "  "+ GetFullPath( OutLocalPath, Empty )
				echo  ""
				pause
				start  "explorer  """+ DownloadURL +""""
				input  "保存できたら Enter を押してください。"
				If exist( OutLocalPath ) Then  Exit Do
			Loop
		Else
			Set stream = WScript.CreateObject( "Adodb.Stream" )
			stream.Type = 1 '// 1=adTypeBinary
			stream.Open
			stream.Write  http.ResponseBody

			stream.SaveToFile  OutLocalPath, 2  '// 2=adSaveCreateOverWrite
		End If
	End If
	echo_v  "Download Completed."
End Sub


 
'********************************************************************************
'  <<< [SetVirtualFileServer] >>> 
'********************************************************************************
Sub  SetVirtualFileServer( VirtualURL, LocalPath )
	echo  ">SetVirtualFileServer  """+ VirtualURL +""", """+ LocalPath +""""

	Dim  sv : Set sv = get_VirtualServerAtLocal()
	Dim  fo : Set fo = new VirtualFileFolder

	sv.m_VirtualFolders.Add  fo
	fo.m_BaseURL = VirtualURL
	fo.m_VirtualFileLocalPath = LocalPath
End Sub


 
'********************************************************************************
'  <<< [GetPercentURL] >>> 
'********************************************************************************
Function  GetPercentURL( UnicodeURL )
	Dim  c, cc, i


	'//=== Skip to ":"
	i = 1
	Do
		c = Mid( UnicodeURL, i, 1 )
		If c = "" Then  Error
		If c = ":" Then  Exit Do
		i=i+1
	Loop


	'//=== Skip to not "/"
	i=i+1
	Do
		c = Mid( UnicodeURL, i, 1 )
		If c <> "/" Then  Exit Do
		i=i+1
	Loop

	GetPercentURL = Left( UnicodeURL, i-1 )


	'//=== Replace to percent escape
	Do
		c = Mid( UnicodeURL, i, 1 )
		If c = "" Then  Exit Do

		If c >= " "  and  c <= "~" Then
			cc = g_PercentURLTable( Asc( c ) - &h20 )
		Else
			cc = "%" + Hex( Asc( c ) )
		End If

		GetPercentURL = GetPercentURL + cc
		i=i+1
	Loop
End Function


Dim  g_PercentURLTable : g_PercentURLTable = Array(_
	"%20", "!", "%22", "%23", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", _
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "%3C", "=", "%3E", "?", _
	"@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", _
	"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "%5B", "%5C", "%5D", "%5E", "_", _
	"%60", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", _
	"p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "%7B", "%7C", "%7D", "~" )


 
'-------------------------------------------------------------------------
' ### <<<< [VirtualServerAtLocal] Class >>>> 
'-------------------------------------------------------------------------
Class  VirtualServerAtLocal
	Public  m_VirtualFolders  ' as ArrayClass
	Public  m_Delays          ' as Dictionary of int (milisecond), key=path

	Private Sub Class_Initialize()
		Set m_VirtualFolders = new ArrayClass
		Set m_Delays = CreateObject( "Scripting.Dictionary" )
	End Sub

	Public Function  GetLocalPath( URL )
		For Each fo  In m_VirtualFolders.Items
			If Left( URL, Len( fo.m_BaseURL ) ) = fo.m_BaseURL Then
				GetLocalPath = Replace( URL, fo.m_BaseURL, fo.m_VirtualFileLocalPath )
				GetLocalPath = Replace( GetLocalPath, "/", "\" )
				Exit Function
			End If
		Next
		Raise  E_PathNotFound, _
				"<ERROR msg=""指定の URL の仮想ファイル・サーバーが設定されていません"" url="""+_
				src +"""/>"
	End Function

	Public Function  IsVirtual( URL )
		For Each fo  In m_VirtualFolders.Items
			If Left( URL, Len( fo.m_BaseURL ) ) = fo.m_BaseURL Then
				IsVirtual = True : Exit Function
			End If
		Next
		IsVirtual = False
	End Function

	Function  DownloadAsyncExec( URL, OutLocalPath )
		Set ec = new EchoOff

		mkdir_for  OutLocalPath

		If m_Delays.Exists( URL ) Then
			timeout_command = "call :timeout_ " & -Int( -( m_Delays( URL ) / 1000 ) ) & vbCRLF
		Else
			timeout_command = ""
		End If

		Set DownloadAsyncExec = RunBatAsync( _
			"echo Downloading...>"+ OutLocalPath +vbCRLF+ _
			timeout_command + _
			"copy  """+ Me.GetLocalPath( url ) +""" """+ OutLocalPath +"""" +vbCRLF+ _
			"goto :fin" +vbCRLF+ _
			"" +vbCRLF+ _
			":timeout_" +vbCRLF+ _
			"echo Waiting %1 seconds ..." +vbCRLF+ _
			"ping 1.1.1.1 -n 1 -w %1000 > nul" +vbCRLF+ _
			"goto :eof" +vbCRLF+ _
			":fin"+ _
			"" )
	End Function
End Class


Class  VirtualFileFolder
	Public  m_BaseURL  ' as string
	Public  m_VirtualFileLocalPath  ' as string
End Class


Function    get_VirtualServerAtLocal()  '// has_interface_of ClassI
	If IsEmpty( g_VirtualServerAtLocal ) Then _
		Set g_VirtualServerAtLocal = new VirtualServerAtLocal : ErrCheck
	Set get_VirtualServerAtLocal =   g_VirtualServerAtLocal
End Function

Dim  g_VirtualServerAtLocal


 
'*************************************************************************
'  <<< [LockByFileMutex] >>> 
'*************************************************************************
Function  LockByFileMutex( UNC_FilePath, TimeOut_msec )
	file_path = GetFullPath( UNC_FilePath, Empty )
	echo  env("%USERDOMAIN%\%USERNAME%") +">LockByFileMutex  """+ file_path +""""
	Set c = g_VBS_Lib

	g_AppKey.CheckWritable  file_path, Empty

	access_denied_count = 0
	Do
		'// Open file and Set "access_denied_count"
		If TryStart(e) Then  On Error Resume Next

			Set file = g_fs.CreateTextFile( file_path, True, True )

		If TryEnd Then  On Error GoTo 0
		If e.num = E_WriteAccessDenied Then
			access_denied_count = access_denied_count + 1
			e.Clear
		ElseIf e.num = 0 Then
			access_denied_count = 0
		End If
		If e.num <> 0 Then  e.Raise


		If access_denied_count = 0 Then _
			Exit Do


		'// Time out
		If access_denied_count * 1000 > TimeOut_msec  and  TimeOut_msec <> c.Forever Then
			If TimeOut_msec = 0 Then
				Set LockByFileMutex = Nothing
				Exit Function
			Else
				Raise  E_TimeOut, "<ERROR msg=""タイムアウト"" time_msec=""" & TimeOut_msec & """/>"
			End If
		End If


		'// Echo owner
		If access_denied_count = 1 Then
			Set read_file = g_fs.OpenTextFile( file_path, 1, True, True )
			owner = Trim2( read_file.ReadAll() )
			read_file = Empty
			echo_v  owner +" による処理の完了を待っています . . ."
		End If


		'// ...
		Sleep  1000
	Loop


	file.WriteLine  env("%USERDOMAIN%\%USERNAME%")


	'// Set "mutex"
	Set mutex = new FileMutexClass
	mutex.Path = file_path
	Set mutex.File = file
	Set LockByFileMutex = mutex
End Function


'[FileMutexClass]
Class  FileMutexClass
	Public  Path
	Public  File

	Private Sub  Class_Terminate() : Me.Close : End Sub

	Public Sub  Close()
		Dim  en,ed : en = Err.Number : ed = Err.Description
		On Error Resume Next  '// This clears the error

		Me.File.Close

		g_fs.DeleteFile  Me.Path

		echo  ">End of FileMutex  """+ Me.Path +""""

		ErrorCheckInTerminate  en
		If en = 0 and not m_bFinished Then  NotCallFinish
		On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
	End Sub
End Class


 
