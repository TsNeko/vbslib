'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
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


 
'***********************************************************************
'* Class: CopyWindowClass
'*********************************************************************** 
Class  CopyWindowClass
	Public  Processes  '// as ArrayClass of CopyWindow_ProcessClass
	Public  MaxCountOfProcess
	Public  DownloadingFolderName


	Private Sub  Class_Initialize()
		Confirm_VBS_Lib_ForFastUser
		Set Me.Processes = new ArrayClass
		Me.MaxCountOfProcess = 6
		Me.DownloadingFolderName = "__Download"  '// TODO: Cut?
	End Sub

	Private Sub  Class_Terminate()
		Me.WaitUntilCompletion
	End Sub


 
'***********************************************************************
'* Method: CopyAndRenameStart
'*
'* Name Space:
'*    CopyWindowClass::CopyAndRenameStart
'***********************************************************************
Public Sub  CopyAndRenameStart( in_SourceFilePath,  in_DestinationFilePath )
	If Me.Processes.Count >= Me.MaxCountOfProcess Then _
		Me.WaitUntil  Me.MaxCountOfProcess - 1
	Set new_process = new CopyWindow_ProcessClass

	vbs_path = g_vbslib_ver_folder +"tools\CopyWithProcessDialog.vbs"
	AssertExist  vbs_path
	AssertExist  in_SourceFilePath
	new_process.DestinationFullPath = GetFullPath( in_DestinationFilePath,  Empty )
	destination_folder_path = new_process.DestinationFullPath +".updating"
	new_process.DownloadedFullPath = destination_folder_path +"\"+ g_fs.GetFileName( in_SourceFilePath )

	For Each  a_process  In  Me.Processes.Items
		If StrComp( new_process.DestinationFullPath,  a_process.DestinationFullPath, 1 ) = 0 Then
			Raise  E_WriteAccessDenied,  "<ERROR msg=""重複しています。"" path="""+ _
				new_process.DestinationFullPath +"""/>"
		End If
	Next

	mkdir  destination_folder_path

	Set new_process.ExecObject = _
		g_sh.Exec( "wscript  """+ vbs_path +"""  """+ _
			in_SourceFilePath +""" """+ destination_folder_path +"""" )

	Me.Processes.Add  new_process
End Sub


 
'***********************************************************************
'* Method: WaitUntilCompletion
'*
'* Name Space:
'*    CopyWindowClass::WaitUntilCompletion
'***********************************************************************
Public Sub  WaitUntilCompletion()
	Me.WaitUntil  0
End Sub


 
'***********************************************************************
'* Method: WaitUntil
'*
'* Name Space:
'*    CopyWindowClass::WaitUntil
'***********************************************************************
Public Sub  WaitUntil( in_CountOfBusyProcess )
	Do
		Me.Dispatch

		If Me.Processes.Count <= in_CountOfBusyProcess Then _
			Exit Sub
		Assert  in_CountOfBusyProcess >= 0

		WScript.Sleep  100  '// msec
	Loop
End Sub


 
'***********************************************************************
'* Method: Dispatch
'*
'* Name Space:
'*    CopyWindowClass::Dispatch
'***********************************************************************
Public Sub  Dispatch()
	For Each  a_process  In  Me.Processes.Items
		Set  ex = a_process.ExecObject
		If ex.Status <> 0 Then  '// The process finished.
			r = ex.ExitCode
			CheckTestErrLevel  r

			Set ec = new EchoOff
			SafeFileUpdateEx  a_process.DownloadedFullPath,  a_process.DestinationFullPath,  Empty
			del  g_fs.GetParentFolderName( a_process.DownloadedFullPath )
			ec = Empty

			Me.Processes.RemoveObject  a_process
		End If
	Next
End Sub


 
End Class

'* Section: Global


 
'***********************************************************************
'* Class: CopyWindow_ProcessClass
'*********************************************************************** 
Class  CopyWindow_ProcessClass
	Public  ExecObject  '// as WshScriptExec
	Public  DestinationFullPath
	Public  DownloadedFullPath
End Class

'* Section: Global


 
'***********************************************************************
'* Class: ExistenceCacheClass
'***********************************************************************
Class  ExistenceCacheClass
	Public  Cache  '// as dictionary of (boolean) or (dictionary of True). Key=full path
	Public  TargetRootPath
	Public  IsEnabled
	Public  CountOfCheckingExistence
	Public  CountOfEnumeration
	Public  FileExistsID
	Public  FolderExistsID

	Private Sub  Class_Initialize()
		Confirm_VBS_Lib_ForFastUser
		Const  c_NotCaseSensitive = 1
		Set Me.Cache = CreateObject( "Scripting.Dictionary" )
		Me.Cache.CompareMode = c_NotCaseSensitive
		Me.TargetRootPath = "\\"
		Me.IsEnabled = True
		Me.CountOfCheckingExistence = 0
		Me.CountOfEnumeration = 0
		Me.FileExistsID = 1
		Me.FolderExistsID = 2
	End Sub


 
'***********************************************************************
'* Method: Exists
'*
'* Name Space:
'*    ExistenceCacheClass::Exists
'***********************************************************************
Public Function  Exists( in_Path )
	Exists = Me.ExistsAs( in_Path,  Me.FileExistsID or Me.FolderExistsID )
End Function


 
'***********************************************************************
'* Method: FileExists
'*
'* Name Space:
'*    ExistenceCacheClass::FileExists
'***********************************************************************
Public Function  FileExists( in_Path )
	FileExists = Me.ExistsAs( in_Path,  Me.FileExistsID )
End Function


 
'***********************************************************************
'* Method: FolderExists
'*
'* Name Space:
'*    ExistenceCacheClass::FolderExists
'***********************************************************************
Public Function  FolderExists( in_Path )
	FolderExists = Me.ExistsAs( in_Path,  Me.FolderExistsID )
End Function


 
'***********************************************************************
'* Method: ExistsAs
'*
'* Name Space:
'*    ExistenceCacheClass::ExistsAs
'***********************************************************************
Public Function  ExistsAs( in_Path,  in_ExistsID )
	is_enabled = Me.IsEnabled
	If is_enabled Then
		checking_path = GetFullPath( in_Path, Empty )
		is_UNC = ( Left( checking_path,  2 ) = "\\" )
		Set Me_Cache = Me.Cache  '// For faster
		loop_index = 0
		If StrCompHeadOf( checking_path,  Me.TargetRootPath,  Empty ) <> 0 Then _
			is_enabled = False
	End If
	is_file_checking   = ( IsBitSet( in_ExistsID,  Me.FileExistsID   ) <> 0 )
	is_folder_checking = ( IsBitSet( in_ExistsID,  Me.FolderExistsID ) <> 0 )


	'// Cache is not used.
	If not is_enabled Then

		If g_fs.FileExists( in_Path ) Then
			ExistsAs = is_file_checking
			Me.CountOfCheckingExistence = Me.CountOfCheckingExistence + 1
		Else
			ExistsAs = g_fs.FolderExists( in_Path )
			If ExistsAs Then _
				ExistsAs = is_folder_checking
			Me.CountOfCheckingExistence = Me.CountOfCheckingExistence + 2
		End If

		Exit Function
	End If


	'// Set "root_length"
	If not is_UNC Then
		root_length = 3  '// e.g. "C:\"
		g_Coverage_ExistenceCacheClass(0) = True
	Else
		root_length = InStr( 3,  checking_path,  "\" )
		Assert  root_length >= 1
		root_length = InStr( root_length + 1,  checking_path,  "\" ) - 1
		If root_length = -1 Then _
			root_length = Len( checking_path )
		g_Coverage_ExistenceCacheClass(1) = True
	End If


	'// Set "is_exists_as_return_value"
	GetDicItem  Me_Cache,  checking_path,  item_in_cache  '// Set "item_in_cache"
	If IsObject( item_in_cache ) Then  '// "checking_path" is a folder. "item_in_cache" is ArrayClass.
		is_exists_as_return_value = is_folder_checking
		g_Coverage_ExistenceCacheClass(2) = True
	ElseIf not IsEmpty( item_in_cache ) Then  '// "checking_path" is a folder.
		is_exists_as_return_value = ( item_in_cache = True )
		If is_exists_as_return_value Then _
			is_exists_as_return_value = is_folder_checking
		g_Coverage_ExistenceCacheClass(3) = True
	Else

		'// Search in cache
		path_in_cache = checking_path
		path_not_in_cache = Empty
		Do While  Len( path_in_cache ) > root_length
			path_in_cache = g_fs.GetParentFolderName( path_in_cache )

			GetDicItem  Me_Cache,  path_in_cache,  item_in_cache  '// Set "item_in_cache"
			If not IsEmpty( item_in_cache ) Then _
				Exit Do
			path_not_in_cache = path_in_cache
		Loop

		Do While  IsEmpty( is_exists_as_return_value )
			loop_index = loop_index + 1
			If loop_index > 2 Then _
				Error


			'// Search in file system
			If IsEmpty( item_in_cache ) Then
				is_found = False

				If g_fs.FileExists( checking_path ) Then

					is_exists_as_return_value = is_file_checking
					Me.CountOfCheckingExistence = Me.CountOfCheckingExistence + 1

					folder_path = g_fs.GetParentFolderName( checking_path )
					g_Coverage_ExistenceCacheClass(4) = True

				ElseIf g_fs.FolderExists( checking_path ) Then

					is_exists_as_return_value = is_folder_checking
					Me.CountOfCheckingExistence = Me.CountOfCheckingExistence + 2

					folder_path = checking_path
					g_Coverage_ExistenceCacheClass(5) = True

				Else
					is_exists_as_return_value = False
					Me.CountOfCheckingExistence = Me.CountOfCheckingExistence + 2

					If Len( checking_path ) >= root_length Then
						not_folder_path = checking_path
					Else
						not_folder_path = Empty
					End If

					folder_path = g_fs.GetParentFolderName( checking_path )
					Do
						If Len( folder_path ) < root_length Then
							folder_path = Empty
							Exit Do
						End If
						Me.CountOfCheckingExistence = Me.CountOfCheckingExistence + 1

						If g_fs.FolderExists( folder_path ) Then
							Exit Do
						End If
						not_folder_path = folder_path
						folder_path = g_fs.GetParentFolderName( folder_path )
						g_Coverage_ExistenceCacheClass(6) = True
					Loop
				End If


				'// Set "Me.Cache"
				If not IsEmpty( not_folder_path ) Then
					Me_Cache( not_folder_path ) = False
					g_Coverage_ExistenceCacheClass(7) = True
				End If

				If not IsEmpty( folder_path ) Then
					Do While  not Me_Cache.Exists( folder_path )

						Me_Cache( folder_path ) = True
						If Len( folder_path ) <= root_length Then _
							Exit Do
						folder_path = g_fs.GetParentFolderName( folder_path )
						g_Coverage_ExistenceCacheClass(8) = True
					Loop
				End If


			'// At middle state
			ElseIf NOT IsObject( item_in_cache ) Then
				If not item_in_cache Then

					is_exists_as_return_value = False
					g_Coverage_ExistenceCacheClass(9) = True
				Else

					'// Enumerate in file system
					Set item_in_cache = CreateObject( "Scripting.Dictionary" )
					Set folder = g_fs.GetFolder( path_in_cache )
					For Each  file  In  folder.Files
						item_in_cache.Add  file.Name,  False  '// False = Not Folder
					Next
					For Each  folder  In  folder.SubFolders
						item_in_cache.Add  folder.Name,  True  '// True = Folder
					Next
					Me.CountOfEnumeration = Me.CountOfEnumeration + 1

					Set Me_Cache( path_in_cache ) = item_in_cache
				End If
			End If


			'// Check items in a folder in the cache
			If IsObject( item_in_cache ) Then
				If IsEmpty( path_not_in_cache ) Then
					name = g_fs.GetFileName( checking_path )

					If item_in_cache.Exists( name ) Then
						If item_in_cache( name ) Then
							is_exists_as_return_value = is_folder_checking
						Else
							is_exists_as_return_value = is_file_checking
						End If
					Else
						is_exists_as_return_value = False
					End If
					g_Coverage_ExistenceCacheClass(10) = True
				Else
					name = g_fs.GetFileName( path_not_in_cache )

					If not item_in_cache.Exists( name ) Then

						is_exists_as_return_value = False
						If Len( path_not_in_cache ) < Len( checking_path ) Then
							Me_Cache( path_not_in_cache ) = False
						End If
						g_Coverage_ExistenceCacheClass(11) = True
					Else
						item_in_cache = Empty  '// Search in file system in next loop
						g_Coverage_ExistenceCacheClass(12) = True
					End If
				End If
			End If
		Loop
	End If

	ExistsAs = is_exists_as_return_value
End Function


 
'***********************************************************************
'* Method: Save
'*
'* Name Space:
'*    ExistenceCacheClass::Save
'***********************************************************************
Sub  Save( in_CacheFilePath,  in_BasePath,  in_RootPath )
	If IsEmpty( in_BasePath ) Then
		base_path = GetParentFullPath( in_CacheFilePath )
	Else
		base_path = GetFullPath( in_BasePath,  Empty )
	End If
	If IsEmpty( in_RootPath ) Then
		root_path = ""
	Else
		root_path = GetFullPath( in_RootPath,  Empty )
	End If
	Set c = g_VBS_Lib
	Set Me_Cache = Me.Cache  '// For faster

	Set file = OpenForWrite( in_CacheFilePath,  c.Unicode )
	For Each  path  In  Me_Cache.Keys
	If StrCompHeadOf( path,  root_path,  c.AsPath ) = 0 Then
		GetDicItem  Me_Cache,  path,  item  '// Set "item"
		If IsObject( item ) Then
			QuickSortDicByKeyForNotObject  item
			value = ",(,"
			For Each  name  In  item.Keys
				If item( name ) Then
					comma = "\,"
				Else
					comma = ","
				End If
				value = value + CSVText( name ) + comma
			Next
			value = value +")"
		Else
			If item Then
				value = ",T"
			Else
				value = ",F"
			End If
		End If

		file.WriteLine  CSVText( GetStepPath( path,  base_path ) ) + value
	End If
	Next
End Sub


 
'***********************************************************************
'* Method: Load
'*
'* Name Space:
'*    ExistenceCacheClass::Load
'***********************************************************************
Sub  Load( in_CacheFilePath,  in_BasePath )
	If IsEmpty( in_BasePath ) Then
		base_path = GetParentFullPath( in_CacheFilePath )
	Else
		base_path = GetFullPath( in_BasePath,  Empty )
	End If
	Set c = g_VBS_Lib
	Set Me_Cache = Me.Cache  '// For faster

	Set file = OpenForRead( in_CacheFilePath )
	Do Until  file.AtEndOfStream
		line = file.ReadLine()

		index = 1
		path = GetFullPath( MeltCSV( line, index ),  base_path )
		Select Case  MeltCSV( line, index )
			Case "T": Me_Cache( path ) = True
			Case "F": Me_Cache( path ) = False

			Case "("
				Set item = CreateObject( "Scripting.Dictionary" )
				Do
					name = MeltCSV( line, index )
					If name = ")" Then _
						Exit Do

					If Right( name, 1 ) = "\" Then
						item.Add  Left( name, Len( name ) - 1 ),  True
					Else
						item.Add  name,  False
					End If
				Loop

				Set Me_Cache( path ) = item
			Case Else : Error
		End Select
	Loop
End Sub


 
'* Section: End_of_Class
End Class
ReDim  g_Coverage_ExistenceCacheClass(12)


 
