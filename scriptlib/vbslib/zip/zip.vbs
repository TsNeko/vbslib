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


 
