'********************************************************************************
'  <<< [unzip2] >>> 
'********************************************************************************
Sub  unzip2( ZipPath, ExpandFolderPath )
	echo  ">unzip2 """ + ZipPath + """, """ + ExpandFolderPath + """"

	If not g_fs.FileExists( ZipPath ) Then  Raise E_FileNotExist, "<ERROR msg=""ファイルが見つかりません"" path="""+ ZipPath +"""/>"

	Set ex = g_sh.Exec( """" + g_vbslib_ver_folder + "zip\unzip2.exe"" """ + ZipPath + """ """ + _
		ExpandFolderPath + """" )

	Do While ex.Status = 0 : WScript.Sleep 100 : Loop
	Do Until ex.StdOut.AtEndOfStream : WScript.Echo ex.StdOut.ReadLine : Loop
	Do Until ex.StdErr.AtEndOfStream : WScript.Echo ex.StdErr.ReadLine : Loop
	r = ex.ExitCode

	If r <> 0 Then  Raise  r, "unzip2.exe: ERROR"
End Sub

 
'********************************************************************************
'  <<< [unzip] >>> 
'********************************************************************************
Dim  F_IfNotExist  : F_IfNotExist  =     4  '// => IgnoreIfExist
Dim  F_IfExistsErr : F_IfExistsErr = &h400  '// => ErrorIfExist
Dim  F_AfterDelete : F_AfterDelete =  &h40  '// => AfterDelete

Sub  unzip( in_FolderZipPath,  ByVal in_NewFolderPath,  ByVal in_Flags )
	Set c = g_VBS_Lib

	echo  ">unzip """ + in_FolderZipPath + """, """ + in_NewFolderPath + """"
	Set ec = new EchoOff

	If IsEmpty( in_NewFolderPath ) Then
		in_NewFolderPath = g_fs.GetParentFolderName( in_FolderZipPath )
		Select Case  Right( in_NewFolderPath, 1 )
			Case "", "\"
				'// Do Noting
			Case Else
				in_NewFolderPath = in_NewFolderPath +"\"
		End Select
		in_NewFolderPath = in_NewFolderPath + g_fs.GetBaseName( in_FolderZipPath )
	End If

	If VarType( in_Flags ) = vbBoolean Then
		If in_Flags Then
			in_Flags = c.AfterDelete
		Else
			in_Flags = c.IgnoreIfExist
		End If
	End If
	is_exist_new_folder = exist( in_NewFolderPath )


	If not exist( in_FolderZipPath ) Then _
		Err.Raise  E_FileNotExist,, "ファイルが見つかりません。: " + in_FolderZipPath
	If in_Flags and c.IgnoreIfExist Then If is_exist_new_folder Then _
		Exit Sub
	If in_Flags and c.ErrorIfExist Then If is_exist_new_folder Then _
		Err.Raise  E_Others,, "フォルダーが存在するため展開できません。: " + in_NewFolderPath
	If in_Flags and c.AfterDelete Then _
		del in_NewFolderPath
	If ( in_Flags and c.CheckFolderExists ) <> 0  and  ( is_exist_new_folder ) Then
		unzipped_path = GetTempPath( "_unzip" )
		del  unzipped_path
		is_check = True
	Else
		unzipped_path = in_NewFolderPath
	End If


	unzip2  in_FolderZipPath,  unzipped_path


	'// Move files in one folder
	Set folder = g_fs.GetFolder( unzipped_path )
	If folder.Files.Count = 0 Then
		If folder.SubFolders.Count = 1 Then
			For Each  sub_path  In folder.SubFolders
				Exit For
			Next
			sub_path = unzipped_path +"\"+ sub_path.Name
			move  sub_path +"\*",  unzipped_path

			Set folder = g_fs.GetFolder( sub_path )
			If folder.Files.Count = 0 Then
				If folder.SubFolders.Count = 0 Then
					g_fs.DeleteFolder  sub_path, True
				End If
			End If
		End If
	End If


	If is_check Then
		Assert  IsSameFolder( in_NewFolderPath,  unzipped_path,  c.EchoV_NotSame )
		del  unzipped_path
	End If
End Sub


 
'********************************************************************************
'  <<< [zip2] >>> 
'********************************************************************************
Sub  zip2( ZipPath, SourceFolderPath, IsFolderName )
	echo  ">zip2  """+ ZipPath +""""
	If not g_is_debug Then  Set ec = new EchoOff

	zip_helper_exe = g_vbslib_ver_folder +"zip\zlib_helper.exe"
	AssertExist  zip_helper_exe

	g_AppKey.CheckWritable  ZipPath, Empty

	del  ZipPath

	option_ = ""
	If IsFolderName Then _
		option_ = option_ + " /f"

	r= RunProg( """"+ zip_helper_exe +""" /silent zip """+ ZipPath +""" """+ SourceFolderPath +""""+ _
		option_ , "" )
		Assert  r = 0
End Sub


 
'***********************************************************************
'* Class: DownloadAndExtractFileIn7zClass
'*********************************************************************** 
Class  DownloadAndExtractFileIn7zClass
	Public  Downloader  '// as CopyWindowClass
	Public  DownloadThreads  '// as dictionary of DownloadAndExtractFileIn7z_ThreadClass. Key = server_7z_full_path
	Public  CacheRootFullPath
	Public  ExistenceCache


	Private Sub  Class_Initialize()
		Confirm_VBS_Lib_ForFastUser
		Const  c_NotCaseSensitive = 1
		Set Me.Downloader = new CopyWindowClass
		Set Me.DownloadThreads = CreateObject( "Scripting.Dictionary" )
		Me.DownloadThreads.CompareMode = c_NotCaseSensitive
		Me.CacheRootFullPath = GetTempPath( "Fragments" )
		Set Me.ExistenceCache = new ExistenceCacheClass
	End Sub


 
'***********************************************************************
'* Method: DownloadStart
'*
'* Name Space:
'*    DownloadAndExtractFileIn7zClass::DownloadStart
'***********************************************************************
Public Function  DownloadStart( in_PathIn7zInServer )
	Set ec = new EchoOff
	server_file_full_path = GetFullPath( in_PathIn7zInServer, Empty )
	server_7z_full_path = Me.Get7zFullPathInServer( server_file_full_path )
	If IsEmpty( server_7z_full_path ) Then
		Set DownloadStart = Nothing
		Exit Function
	End If

	If Me.DownloadThreads.Exists( server_7z_full_path ) Then  '// It hits the cache or downloading.
		Set thread = Me.DownloadThreads( server_7z_full_path )
		Set DownloadStart = thread
		Exit Function
	End If

	Set thread = new DownloadAndExtractFileIn7z_ThreadClass
	Set DownloadStart = thread
	hash_file_full_path = Me.GetHashFileFullPath( server_7z_full_path )
	If g_fs.FileExists( hash_file_full_path ) Then
			'// hash_file_full_path is in local cache.
			'// The cache is not used in local.

		hash_of_7z = ReadFile( hash_file_full_path )
	End If


	'// Download .7z file
	If hash_of_7z = "" Then
		no_hash_cache_7z_full_path = Left( _
				hash_file_full_path, _
				Len( hash_file_full_path ) - Len( "-7z.txt" ) _
			) +".7z"
		del  no_hash_cache_7z_full_path +".updating"
		cache_7z_full_path = no_hash_cache_7z_full_path   '// Temporary for next "If".
		g_Coverage_DownloadAndExtractFileIn7z(4) = True
	Else
		cache_7z_full_path = Me.CacheRootFullPath +"\"+ Left( hash_of_7z, 2 ) +"\"+ hash_of_7z +".7z"
		g_Coverage_DownloadAndExtractFileIn7z(5) = True
	End If
	If not g_fs.FileExists( cache_7z_full_path ) Then
			'// The cache is not used in local.
		ec = Empty
		echo  ">Download  """+ server_7z_full_path +""""
		Set ec = new EchoOff

		Me.Downloader.CopyAndRenameStart  server_7z_full_path,  cache_7z_full_path


			'// ================================ Start of pseudo multi thread.
					Me.DownloadThreads.Add  server_7z_full_path,  thread
					thread.StepIndex = 2
				Else
					thread.StepIndex = Empty
				End If
				thread.server_7z_full_path = server_7z_full_path
				thread.hash_of_7z = hash_of_7z
				thread.hash_file_full_path = hash_file_full_path
				thread.cache_7z_full_path = cache_7z_full_path
			End Function

			'***********************************************************************
			'* Method: Dispatch
			'***********************************************************************
			Public Sub  Dispatch( thread )
				Select Case  thread.StepIndex
					Case  2: Me.Step2  thread
					Case Else:  Error
				End Select
			End Sub

			'***********************************************************************
			'* Method: Step2
			'***********************************************************************
			Public Sub  Step2( thread )
				hash_of_7z = thread.hash_of_7z
				hash_file_full_path = thread.hash_file_full_path
				cache_7z_full_path = thread.cache_7z_full_path
			'// ================================== End of pseudo multi thread.


		Me.Downloader.Dispatch

		If g_fs.FolderExists( cache_7z_full_path +".updating" ) Then _
			Exit Sub
			'// The cache is not used in local (destination).

		If hash_of_7z = "" Then
			Set ec = new EchoOff
			hash_of_7z = GetHashOfFile( cache_7z_full_path, "MD5" )
			CreateFile  hash_file_full_path,  hash_of_7z

			new_cache_7z_full_path = Me.CacheRootFullPath +"\"+ Left( hash_of_7z, 2 ) +"\"+ _
				hash_of_7z +".7z"
			move_ren  cache_7z_full_path,  new_cache_7z_full_path
			cache_7z_full_path = new_cache_7z_full_path

		End If
'// End If


			'// ================================ Start of pseudo multi thread.
				thread.StepIndex = Empty
				thread.cache_7z_full_path = cache_7z_full_path
			'// ================================== End of pseudo multi thread.
End Sub


 
'***********************************************************************
'* Method: GetLocalPath
'*
'* Name Space:
'*    DownloadAndExtractFileIn7zClass::GetLocalPath
'***********************************************************************
Public Function  GetLocalPath( in_PathIn7zInServer )

	Set thread = Me.DownloadStart( in_PathIn7zInServer )
	If thread is Nothing Then _
		Exit Function  '// Returns "Empty".

	Do While  not IsEmpty( thread.StepIndex )
		WScript.Sleep  100

		Me.Dispatch  thread
	Loop
	server_file_full_path = GetFullPath( in_PathIn7zInServer, Empty )
	cache_7z_full_path = thread.cache_7z_full_path
	server_7z_full_path = thread.server_7z_full_path


	'// Extract .7z file
	extracted_7z_path = AddLastOfFileName( cache_7z_full_path, "." )  '// Cut extension
	If not g_fs.FolderExists( extracted_7z_path ) Then
		ec = Empty
		echo  ">Extract  """+ server_7z_full_path +""""
		Set ec = new EchoOff

		exe7z = Setting_get7zExePath()
		r= RunProg( """"+ exe7z +"""  x  -y  """+ cache_7z_full_path +_
			"""  -o"""+ extracted_7z_path +"""",  "" )
		If r <> 0 Then
			g_Coverage_DownloadAndExtractFileIn7z(6) = True
			Raise  1,  "<ERROR msg=""展開に失敗しました。"" path="""+ cache_7z_full_path + _
				""" path_in_server="""+ server_7z_full_path +"""  error_level="""+ CStr( r ) +"""/>"
		End If
	End If


	'// Set return value
	GetLocalPath = extracted_7z_path +"\"+ _
		GetStepPath( server_file_full_path,  g_fs.GetParentFolderName( server_7z_full_path ) )
End Function


 
'***********************************************************************
'* Method: WaitUntilCompletion
'*
'* Name Space:
'*    DownloadAndExtractFileIn7zClass::WaitUntilCompletion
'***********************************************************************
Public Sub  WaitUntilCompletion()
	Do
		active_count= 0
		For Each  thread  In  Me.DownloadThreads.Items
			If not IsEmpty( thread.StepIndex ) Then

				Me.Dispatch  thread
				active_count = active_count + 1
			End If
		Next
		If active_count = 0 Then _
			Exit Do
		WScript.Sleep  100
	Loop
End Sub


 
'***********************************************************************
'* Method: Get7zFullPathInServer
'*
'* Name Space:
'*    DownloadAndExtractFileIn7zClass::Get7zFullPathInServer
'***********************************************************************
Public Function  Get7zFullPathInServer( in_FullPathIn7zInServer )
	Assert  IsFullPath( in_FullPathIn7zInServer )
	folder_path = GetPathWithSeparator( g_fs.GetParentFolderName( in_FullPathIn7zInServer ) )
	If Left( folder_path, 2 ) = "\\" Then
		out_of_position = 2  '// In server
		g_Coverage_DownloadAndExtractFileIn7z(0) = True
	Else
		out_of_position = 0  '// In local
		g_Coverage_DownloadAndExtractFileIn7z(1) = True
	End If
	position = Len( folder_path )
	Do

		server_7z_full_path = folder_path +"_Fragment.7z"
		If Me.ExistenceCache.FileExists( server_7z_full_path ) Then _
			Exit Do

		position = InStrRev( folder_path,  "\",  position - 1 )
		If position <= out_of_position Then
			g_Coverage_DownloadAndExtractFileIn7z(2) = True
			Exit Function  '// Returns Empty
		End If
		folder_path = Left( folder_path,  position )
		g_Coverage_DownloadAndExtractFileIn7z(3) = True
	Loop

	Get7zFullPathInServer = server_7z_full_path
End Function


 
'***********************************************************************
'* Method: GetHashFileFullPath
'*
'* Name Space:
'*    DownloadAndExtractFileIn7zClass::GetHashFileFullPath
'***********************************************************************
Public Function  GetHashFileFullPath( in_7zFullPathInServer )
	Assert  IsFullPath( in_7zFullPathInServer )
	server_folder_path_hash = new_BinaryArrayAsText( in_7zFullPathInServer, Empty ).MD5
	GetHashFileFullPath = Me.CacheRootFullPath +"\"+ Left( server_folder_path_hash, 2 ) +"\"+ _
		server_folder_path_hash +"-Fragment-7z.txt"
End Function


 
End Class

'* Section: Global


 
'***********************************************************************
'* Class: DownloadAndExtractFileIn7z_ThreadClass
'***********************************************************************
Class  DownloadAndExtractFileIn7z_ThreadClass
	Public  StepIndex

	'// Local variables
	Public  server_7z_full_path
	Public  hash_of_7z
	Public  hash_file_full_path
	Public  cache_7z_full_path
End Class


 
ReDim  g_Coverage_DownloadAndExtractFileIn7z(6)

 
