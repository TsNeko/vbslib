'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.92 $
'* - $ModuleRevision: {vbslib}\Public\592 $
'* - $Date: 2016-12-30T20:13:44+09:00 $
'***********************************************************************

Dim  g_SrcPath
Dim  g_vbslib_network_Path
     g_vbslib_network_Path = g_SrcPath


g_DownloadChannelCountMax = 8  '//[g_DownloadChannelCountMax]
g_DownloadTimeout_sec = 50     '//[g_DownloadTimeout_sec]


 
'********************************************************************************
'  <<< [DownloadByHttp] >>> 
'********************************************************************************
Sub  DownloadByHttp( in_DownloadURL, in_OutLocalPath )
	Set sv = get_VirtualServerAtLocal()
	exe_path = g_vbslib_ver_folder +"sage_p_downloader\sage_p_downloader.exe"
	Set c = g_VBS_Lib

	If IsArray( in_DownloadURL ) Then
		For Each  a_URL  In in_DownloadURL
			Assert  InStr( a_URL, "\" ) = 0
		Next
	Else
		Assert  InStr( in_DownloadURL, "\" ) = 0
	End If


	'// Set first "set_of_URL"
	If IsArray( in_DownloadURL ) Then
		If UBound( in_DownloadURL ) >= g_DownloadChannelCountMax Then
			next_index = g_DownloadChannelCountMax
		Else
			next_index = UBound( in_DownloadURL ) + 1
		End If

		ReDim  set_of_URL( next_index - 1 )
		For i=0  To next_index - 1
			set_of_URL(i) = in_DownloadURL(i)
		Next
		count_of_DownloadURL = UBound( in_DownloadURL ) + 1
	Else
		ReDim  set_of_URL(0)
		set_of_URL(0) = in_DownloadURL
		next_index = 1
		count_of_DownloadURL = 1
	End If


	'// Make the folder
	g_AppKey.CheckWritable  in_OutLocalPath, Empty
	If IsArray( in_DownloadURL ) Then
		mkdir  in_OutLocalPath
	Else
		mkdir_for  in_OutLocalPath
	End If


	base_index = 0
	Do
		ReDim  asyncs( UBound( set_of_URL ) )


		'// Echo
		echo_flush
		For index_of_URL = 0  To UBound( set_of_URL )
			a_URL = set_of_URL( index_of_URL )

			If count_of_DownloadURL >= 2 Then
				echo_v  "Downloading("& ( base_index + index_of_URL ) &"): "+ a_URL
			Else
				echo_v  "Downloading: "+ a_URL
			End If

			'// Check
			If Left( a_URL, 7 ) <> "http://" Then  Error
				'// ftp: cannot supported
		Next


		'// Start downloading
		For index_of_URL = 0  To UBound( set_of_URL )
			a_URL = set_of_URL( index_of_URL )

			If IsArray( in_DownloadURL ) Then
				out_local_file_path = in_OutLocalPath +"\"+ g_fs.GetFileName( a_URL )
			Else
				out_local_file_path = in_OutLocalPath
			End If
			out_local_file_path = Replace( out_local_file_path, "?", "_" )

			If IsArray( in_DownloadURL ) Then _
				in_DownloadURL( base_index + index_of_URL ) = out_local_file_path

			If sv.IsLocal( a_URL ) Then
				Set asyncs( index_of_URL ) = _
					sv.DownloadVirtualAsyncExec( a_URL, out_local_file_path )
			Else
				If sv.IsVirtual( a_URL ) Then
					a_URL = sv.GetLocalOrOtherPath( a_URL )
					If g_is_debug Then _
						echo_v  "  >DownloadByHttp: "+ a_URL
				End If

				Set asyncs( index_of_URL ) = _
					g_sh.Exec( """"+ exe_path +""" """+_
						GetPercentURL( a_URL ) +""" """+ out_local_file_path +"""" )
					'// Stdout is not echoed in this function
			End If
		Next


		'// Receive result
		ReDim  is_received( UBound( set_of_URL ) )
		For index_of_URL = 0  To UBound( set_of_URL )
			is_received( index_of_URL ) = False
		Next
		time_out = DateAddStr( Now(), "+"+ CStr( g_DownloadTimeout_sec ) +"sec" )

		Do
			finished_count = 0
			For index_of_URL = 0  To UBound( set_of_URL )
				Set async = asyncs( index_of_URL )

				If is_received( index_of_URL ) Then
					finished_count = finished_count + 1
				ElseIf async.Status = c.WshFinished Then
					If CInt( async.ExitCode ) <> 0 Then
						If count_of_DownloadURL >= 2 Then
							index_message = " index="""& ( base_index + index_of_URL ) &""""
						Else
							index_message = ""
						End If
						Raise 1, "<ERROR msg=""エラーが発生しました。"" exit_code="""&_
							async.ExitCode &""""& index_message &"/>"
					End If
					is_received( index_of_URL ) = True
				End If
			Next


			'// Exit this loop
			If finished_count = UBound( set_of_URL ) + 1 Then
				Exit Do
			End If


			'// Timeout
			If Now() >= time_out Then
				For index_of_URL = 0  To UBound( set_of_URL )
					Set async = asyncs( index_of_URL )

					If async.Status = c.WshRunning Then
						KillProcess  async.ProcessID

						If IsArray( in_DownloadURL ) Then _
							in_DownloadURL( base_index + index_of_URL ) = Empty
					End If
				Next

				base_index = base_index + UBound( set_of_URL ) + 1
				For i = base_index  To  count_of_DownloadURL - 1
					If IsArray( in_DownloadURL ) Then _
						in_DownloadURL( i ) = Empty
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
			set_of_URL(i) = in_DownloadURL( base_index + i )
		Next
	Loop
End Sub


 
'********************************************************************************
'  <<< [SetVirtualFileServer] >>> 
'********************************************************************************
Sub  SetVirtualFileServer( in_VirtualURL, in_LocalPath )
	echo  ">SetVirtualFileServer  """+ in_VirtualURL +""", """+ in_LocalPath +""""

	Set sv = get_VirtualServerAtLocal()

	sv.Add  in_VirtualURL, in_LocalPath, Empty
End Sub


 
'********************************************************************************
'  <<< [SetVirtualFileServer_byXML] >>> 
'********************************************************************************
Sub  SetVirtualFileServer_byXML( in_SettingXML_Path )
	echo  ">SetVirtualFileServer_byXML  """& in_SettingXML_Path &""""
	base_path = GetParentFullPath( in_SettingXML_Path )

	Set sv = get_VirtualServerAtLocal()

	If IsEmpty( in_SettingXML_Path ) Then
		sv.Add  Empty, Empty, Empty
	Else
		Set root = LoadXML( in_SettingXML_Path, Empty )
		Set variables = new_LazyDictionaryClass( root )

		For Each elem  In root.selectNodes( "./Replace" )
			to_value = elem.getAttribute( "to" )
			If IsNull( to_value ) Then _
				to_value = Empty

			from_value = variables( elem.getAttribute( "from" ) )
			to_value = variables( to_value )

			echo  "    >SetVirtualFileServer  """+ from_value +""", """+ to_value +""""
			sv.Add  from_value, to_value, base_path
		Next
	End If
End Sub


 
'********************************************************************************
'  <<< [GetPercentURL] >>> 
'********************************************************************************
Function  GetPercentURL( ByVal in_UnicodeURL )
	in_UnicodeURL = Replace( in_UnicodeURL, "\", "/" )


	'//=== Skip to ":"
	i = 1
	Do
		c = Mid( in_UnicodeURL, i, 1 )

		If c = "" Then  '// Step path
			i = 1
			Exit Do
		End If
		If c = ":" Then _
			Exit Do

		i=i+1
	Loop


	If c = ":" Then

		'//=== Skip to not "/"
		i=i+1
		Do
			c = Mid( in_UnicodeURL, i, 1 )
			If c <> "/" Then _
				Exit Do
			i=i+1
		Loop

		GetPercentURL = Left( in_UnicodeURL, i-1 )
	End If


	'// Split "hier_part" and "query" ("fragment")
	position = InStr( in_UnicodeURL, "#" )
	If position >= 1 Then
		fragment = Mid( in_UnicodeURL, position + 1 )
		hier_part_query = Left( in_UnicodeURL, position - 1 )
	Else
		hier_part_query = in_UnicodeURL
	End If

	position = InStr( hier_part_query, "?" )
	If position >= 1 Then
		query = Mid( hier_part_query, position + 1 )
		hier_part = Left( hier_part_query, position - 1 )
	Else
		hier_part = hier_part_query
	End If


	'// Replace "hier_part" to percent escape
	Do
		c = Mid( hier_part, i, 1 )
		If c = "" Then  Exit Do

		If c >= " "  and  c <= "~" Then
			cc = g_PercentURLTable_HierPart( Asc( c ) - &h20 )
		Else
			cc = "%" + Hex( Asc( c ) )
		End If

		GetPercentURL = GetPercentURL + cc
		i=i+1
	Loop


	'// Replace "query" and "fragment" to percent escape.
	For Each  delimiter  In  Array( "?", "#" )
		If delimiter = "?" Then
			part = query
		Else
			part = fragment
		End If

		If not IsEmpty( part ) Then
			GetPercentURL = GetPercentURL + delimiter

			i = 1
			Do
				c = Mid( part, i, 1 )
				If c = "" Then  Exit Do

				If c >= " "  and  c <= "~" Then
					cc = g_PercentURLTable_Fragment( Asc( c ) - &h20 )
				Else
					cc = "%" + Hex( Asc( c ) )
				End If

				GetPercentURL = GetPercentURL + cc
				i=i+1
			Loop
		End If
	Next
End Function


Dim  g_PercentURLTable_HierPart : g_PercentURLTable_HierPart = Array(_
	"%20", "%21", "%22", "#", "%24", "%25", "%26", "%27", "%28", "%29", "%2A", "%2B", "%2C", "-", ".", "/", _
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", "%3B", "%3C", "%3D", "%3E", "?", _
	"%40", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", _
	"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "%5B", "%5C", "%5D", "%5E", "_", _
	"%60", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", _
	"p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "%7B", "%7C", "%7D", "~" )

Dim  g_PercentURLTable_Fragment : g_PercentURLTable_Fragment = Array(_
	"%20", "!", "%22", "%23", "$", "%25", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", _
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
	Public  ServerKeyword

	Private Sub Class_Initialize()
		Set m_VirtualFolders = new ArrayClass
		Set m_Delays = CreateObject( "Scripting.Dictionary" )
		Me.ServerKeyword = "://"
	End Sub

	Public Sub  Add( in_VirtualURL,  in_LocalOrOtherPath,  in_BasePath )

		If InStr( to_value, Me.ServerKeyword ) = 0 Then
			local_path_last = Right( in_LocalOrOtherPath, 1 )
			If local_path_last <> "\" Then _
				local_path_last = ""

			in_LocalOrOtherPath = GetFullPath( in_LocalOrOtherPath, in_BasePath ) + local_path_last
		End If


		If in_VirtualURL = "" Then
			Me.m_VirtualFolders.ToEmpty
		Else
			For Each fo  In m_VirtualFolders.Items
				If fo.m_BaseURL = in_VirtualURL Then _
					Exit For
			Next
			If IsEmpty( fo ) Then
				Set fo = new VirtualFileFolder
				Me.m_VirtualFolders.Add  fo
				fo.m_BaseURL = in_VirtualURL
			End If
			If in_LocalOrOtherPath = "" Then
				fo.m_VirtualFileLocalPath = Empty
			Else
				fo.m_VirtualFileLocalPath = in_LocalOrOtherPath
			End If

			ShakerSort  m_VirtualFolders, 0, m_VirtualFolders.UBound_, _
				GetRef("VirtualFileFolder_compare_byBaseURL"), Empty
		End If
	End Sub

	Public Function  GetLocalOrOtherPath( in_URL )
		Set fo = SearchVirtualFileFolder( in_URL )
		If fo is Nothing Then
			Raise  E_PathNotFound, _
				"<ERROR msg=""指定の URL の仮想ファイル・サーバーが設定されていません"" URL="""+_
				src +"""/>"
		End If

		GetLocalOrOtherPath = Replace( in_URL, fo.m_BaseURL, fo.m_VirtualFileLocalPath )
		If InStr( fo.m_VirtualFileLocalPath, Me.ServerKeyword ) = 0 Then
			GetLocalOrOtherPath = Replace( GetLocalOrOtherPath, "/", "\" )
		End If
	End Function

	Public Function  IsVirtual( in_URL )  '// Local or Other in Server
		Set fo = SearchVirtualFileFolder( in_URL )
		If fo is Nothing Then
			IsVirtual = False
		Else
			IsVirtual = not IsEmpty( fo.m_VirtualFileLocalPath )
		End If
	End Function

	Public Function  IsLocal( in_URL )
		Set fo = SearchVirtualFileFolder( in_URL )
		If fo is Nothing Then
			IsLocal = False
		ElseIf IsEmpty( fo.m_VirtualFileLocalPath ) Then
			IsLocal = False
		Else
			IsLocal = ( InStr( fo.m_VirtualFileLocalPath, Me.ServerKeyword ) = 0 )
		End If
	End Function

	Public Function  SearchVirtualFileFolder( in_URL )
		For Each fo  In m_VirtualFolders.Items
			If Left( in_URL, Len( fo.m_BaseURL ) ) = fo.m_BaseURL Then
				Set SearchVirtualFileFolder = fo
				Exit Function
			End If
		Next
		Set SearchVirtualFileFolder = Nothing
	End Function

	Function  DownloadVirtualAsyncExec( in_URL, in_OutLocalPath )
		Set ec = new EchoOff

		mkdir_for  in_OutLocalPath

		If m_Delays.Exists( in_URL ) Then
			timeout_command = "call :timeout_ " & -Int( -( m_Delays( in_URL ) / 1000 ) ) & vbCRLF
		Else
			timeout_command = ""
		End If

		If g_is_debug Then _
			echo_v  "  >copy_ren  """+ Me.GetLocalOrOtherPath( in_URL ) +""" """+ in_OutLocalPath +""""

		Set DownloadVirtualAsyncExec = RunBatAsync( _
			"echo Downloading...>"""+ in_OutLocalPath +""""+vbCRLF+ _
			timeout_command + _
			"copy  """+ Me.GetLocalOrOtherPath( in_URL ) +""" """+ in_OutLocalPath +"""" +vbCRLF+ _
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


Function  VirtualFileFolder_compare_byBaseURL( Left, Right, Parameter )
    VirtualFileFolder_compare_byBaseURL = StrComp( Right.m_BaseURL, Left.m_BaseURL, 1 )
End Function


Function    get_VirtualServerAtLocal()  '// has_interface_of ClassI
	If IsEmpty( g_VirtualServerAtLocal ) Then _
		Set g_VirtualServerAtLocal = new VirtualServerAtLocal : ErrCheck
	Set get_VirtualServerAtLocal =   g_VirtualServerAtLocal
End Function

Dim  g_VirtualServerAtLocal


 
'*************************************************************************
'  <<< [LockByFileMutex] >>> 
'*************************************************************************
Function  LockByFileMutex( in_UNC_FilePath, in_TimeOut_msec )
	file_path = GetFullPath( in_UNC_FilePath, Empty )
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
		If access_denied_count * 1000 > in_TimeOut_msec  and  in_TimeOut_msec <> c.Forever Then
			If in_TimeOut_msec = 0 Then
				Set LockByFileMutex = Nothing
				Exit Function
			Else
				Raise  E_TimeOut, "<ERROR msg=""タイムアウト"" time_msec=""" & in_TimeOut_msec & """/>"
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


 
