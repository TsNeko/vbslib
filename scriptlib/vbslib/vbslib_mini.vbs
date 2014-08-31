'*************************************************************************
'  <<< [ArgumentExist] >>> 
'*************************************************************************
Function  ArgumentExist( name )
	For Each key in WScript.Arguments.Named
		If key = name  Then  ArgumentExist = True : Exit Function
	Next
	ArgumentExist = False
End Function


 
'********************************************************************************
'  <<< [AssertExist] >>> 
'********************************************************************************
Sub  AssertExist( Path )
	If not exist( Path ) Then
		Raise  1, "<ERROR msg=""ファイルまたはフォルダーが見つかりません"""+_
			" path="""+ Path +"""/>"
	End If
End Sub


 
'*************************************************************************
'  <<< [AssertFC] >>> 
'*************************************************************************
Sub  AssertFC( Path1, Path2 )
	WScript.Echo  ">AssertFC  """+ Path1 +""", """+ Path2 +""""
	Set f1 = g_fs.OpenTextFile( Path1, 1, False, False )
	Set f2 = g_fs.OpenTextFile( Path2, 1, False, False )

	is_multi_line = False
	Do Until f1.AtEndOfStream
		line1 = f1.ReadLine()
		If not is_multi_line Then _
			line2 = f2.ReadLine()

		If line2 = "%MultiLine%" Then
			is_multi_line = True
			line2 = f2.ReadLine()
		End If

		If is_multi_line Then
			If line1 = line2 Then
				is_multi_line = False
			End If
		Else
			If line1 <> line2 Then  Err.Raise  507
		End If
	Loop
	If is_multi_line Then  Err.Raise  507
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


 
'********************************************************************************
'  <<< [GetFullPath] >>>
'********************************************************************************
Function  GetFullPath( StepPath, BasePath )
    If IsFullPath( StepPath ) Then
        GetFullPath = StepPath
    Else
        GetFullPath = g_fs.GetAbsolutePathName( BasePath + "\" + StepPath )
    End If
End Function


 
'********************************************************************************
'  <<< [GetParentFullPath] >>>
'********************************************************************************
Function  GetParentFullPath( Path )
    GetParentFullPath = g_fs.GetAbsolutePathName( Path + "\.." )
End Function


 
'********************************************************************************
'  <<< [IsFullPath] >>>
'********************************************************************************
Function  IsFullPath( Path )
    bs = InStr( Path, "\" )
    sl = InStr( Path, "/" )
    co = InStr( Path, ":" )
    If bs > 0 Then  If co > bs Then  co = 0
    If sl > 0 Then  If co > sl Then  co = 0

    IsFullPath = ( bs = co + 1  or  sl = co + 1 ) or ( Left( Path, 2 ) = "\\" )
End Function


 
'********************************************************************************
'  <<< [copy] >>> 
'********************************************************************************
Sub  copy( SrcPath, ByVal DstFolderPath )
	DstFolderPath = g_fs.GetAbsolutePathName( DstFolderPath )
	If not exist( DstFolderPath ) Then _
		mkdir  DstFolderPath

	If Right( SrcPath, 2 ) = "\*" Then
		Set fo = g_fs.GetFolder( Left( SrcPath, Len( SrcPath ) - 2 ) )
		For Each f in fo.Files
			g_fs.CopyFile  f.Path, DstFolderPath +"\"+ f.Name, True
		Next
		For Each subfo in fo.SubFolders
			g_fs.CopyFolder   subfo.Path, DstFolderPath +"\"+ subfo.Name, True
		Next
	Else
		If g_fs.FileExists( SrcPath ) Then
			g_fs.CopyFile  SrcPath, DstFolderPath, True
		ElseIf g_fs.FolderExists( SrcPath ) Then
			g_fs.CopyFolder  SrcPath, DstFolderPath, True
		Else
			Raise  1, "Not found "+ SrcPath
		End If
	End If
End Sub


 
'*************************************************************************
'  <<< [CreateFile] >>> 
'*************************************************************************
Sub  CreateFile( Path, Text )
	g_fs.CreateTextFile( Path, True, False ).Write  Text
End Sub


 
'********************************************************************************
'  <<< [del] >>> 
'********************************************************************************
Sub  del( ByVal path )
	If g_fs.FileExists( path ) Then
		g_fs.DeleteFile  path
	ElseIf g_fs.FolderExists( path ) Then
		rmdir  path
	End If
End Sub


 
'********************************************************************************
'  <<< [del_empty_folder] >>> 
'********************************************************************************
Sub  del_empty_folder( FolderPath )
	Dim  root_foler_paths,  root_folder_path,  folder_paths,  folder_path,  folder
	Dim  c : Set c = g_VBS_Lib

	If IsArray( FolderPath ) Then  root_foler_paths = FolderPath _
	Else  root_foler_paths = Array( FolderPath )

	For Each root_folder_path  In root_foler_paths
		ExpandWildcard  root_folder_path+"\*", c.Folder or c.SubFolder or c.AbsPath,_
			Empty, folder_paths

		folder_paths = ArrayToNameOnlyClassArray( folder_paths )
		ShakerSort  folder_paths, 0, UBound( folder_paths ), GetRef("LengthNameCompare"), -1

		ReDim Preserve  folder_paths( UBound( folder_paths ) + 1 )
		Set folder_paths( UBound( folder_paths ) ) = new NameOnlyClass
		folder_paths( UBound( folder_paths ) ).Name = root_folder_path

		For Each folder_path  In folder_paths
			If g_fs.FolderExists( folder_path.Name ) Then
				Set  folder = g_fs.GetFolder( folder_path.Name )
				If folder.Files.Count = 0 Then
					If folder.SubFolders.Count = 0 Then
						g_fs.DeleteFolder  folder_path.Name
					End If
				End If
			End If
		Next
	Next
End Sub


 
'********************************************************************************
'  <<< [EchoOff] >>> 
'********************************************************************************
Class  EchoOff
End Class


 
'*************************************************************************
'  <<< [Input] >>> 
'*************************************************************************
Function  Input( Prompt )
	WScript.StdOut.Write  Prompt
	Input = WScript.StdIn.ReadLine()
End Function


 
'********************************************************************************
'  <<< [mkdir] >>> 
'********************************************************************************
Function  mkdir( ByVal Path )
	If g_fs.FolderExists( Path ) Then  mkdir = 0 : Exit Function

	n = 0
	fo2 = g_fs.GetAbsolutePathName( Path )
	Do
		If g_fs.FolderExists( fo2 ) Then Exit Do

		n = n + 1
		Redim Preserve  names(n)
		names(n) = g_fs.GetFileName( fo2 )
		fo2 = g_fs.GetParentFolderName( fo2 )
	Loop

	mkdir = n

	For n=n To 1 Step -1
		fo2 = GetFullPath( names(n), fo2 )

		n_retry = 0
		g_fs.CreateFolder  fo2
		If en <> 0 Then
			If g_fs.FileExists( fo2 ) Then _
				Raise  E_AlreadyExist, "<ERROR msg=""ファイルが存在する場所にフォルダー"+_
					"を作成しようとしました"" path="""+ fo2 +"""/>"
			Err.Raise en,,ed
		End If
	Next
End Function


 
'*************************************************************************
'  <<< [Pause] >>> 
'*************************************************************************
Sub  Pause()
	echo_v  "続行するには Enter キーを押してください . . ."
	WScript.StdIn.ReadLine
End Sub


 
'********************************************************************************
'  <<< [Raise] >>> 
'********************************************************************************
Sub  Raise( ErrNum, Description )
	Err.Raise  ErrNum, "ERROR", Description
End Sub


 
'*************************************************************************
'  <<< [ReadFile] >>> 
'*************************************************************************
Function  ReadFile( Path )
	Set f = g_fs.OpenTextFile( Path, 1, False, -2 )
	ReadFile = f.ReadAll()
End Function


 
'*************************************************************************
'  <<< [RunProg] >>> 
'*************************************************************************
Function  RunProg( cmdline, stdout_stderr_redirect )
	Set ex = g_sh.Exec( cmdline )
	echo_v  ">RunProg  "+ cmdline
	RunProg = WaitForFinishAndRedirect( ex, stdout_stderr_redirect )
	echo_v  ""
End Function


 
'*************************************************************************
'  <<< [WaitForFinishAndRedirect] >>> 
'*************************************************************************
Function  WaitForFinishAndRedirect( ex, path )
	Do While ex.Status = 0
		Do Until ex.StdOut.AtEndOfStream : echo_v  ex.StdOut.ReadLine : Loop
		Do Until ex.StdErr.AtEndOfStream : echo_v  ex.StdErr.ReadLine : Loop
	Loop
	Do Until ex.StdOut.AtEndOfStream : echo_v  ex.StdOut.ReadLine : Loop
	Do Until ex.StdErr.AtEndOfStream : echo_v  ex.StdErr.ReadLine : Loop
	WaitForFinishAndRedirect = ex.ExitCode
End Function


 
