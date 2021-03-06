Set g_fs = CreateObject( "Scripting.FileSystemObject" )
Set g_sh = WScript.CreateObject( "WScript.Shell" )
Sub  echo( Message ) : WScript.Echo  Message : End Sub
g_start_in_path = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
ChangeScriptMode
Main


'***********************************************************************
'* Function: Main
'***********************************************************************
Sub  Main()
	If WScript.Arguments.Unnamed.Count >= 1 Then
		command_name = WScript.Arguments.Unnamed(0)
	Else
		command_name = Trim( Input( "Command>" ) )
	End If

	If command_name = "Assort" Then
		Assort
	ElseIf command_name = "ChechOut" Then
		ChechOut
	Else
		echo  "Unknown Command"
	End If
End Sub


 
'***********************************************************************
'* Function: Assort
'***********************************************************************
Sub  Assort()
	If WScript.Arguments.Unnamed.Count >= 2 Then
		projects_path = WScript.Arguments.Unnamed(1)
	Else
		projects_path = Input( ".proja File Path>" )
	End If
	projects_path = GetFullPath( projects_path,  g_start_in_path )

	If WScript.Arguments.Unnamed.Count >= 3 Then
		project_name = WScript.Arguments.Unnamed(2)
	Else
		project_name = Input( "Project Name>" )
	End If

	If WScript.Arguments.Unnamed.Count >= 4 Then
		work_path = WScript.Arguments.Unnamed(3)
	Else
		work_path = Input( "Work Project Path>" )
	End If
	work_path = GetFullPath( work_path,  g_start_in_path )


	Set root = LoadXML( projects_path, Empty )
	masters_path    = root.selectSingleNode( "./Variable[@name='${Masters}']" ).getAttribute( "value" )
	Set project_tag = root.selectSingleNode( "./Project[@name='"+ Replace( project_name, "\", "\\" ) +"']" )
	If project_tag  is Nothing Then _
		Raise  1, "Not found """+ project_name +""""

	For Each  module_tag  In  project_tag.selectNodes( "./Module" )
		master_path  = module_tag.getAttribute( "master" )

		echo  master_path
		project_path = module_tag.getAttribute( "project" )
		source_path = work_path +"\"+ project_path
		destination_path = Replace( master_path,  "${Masters}",  masters_path )

		Set files_tag = root.selectSingleNode( "./FilesInModule[@master='"+ Replace( master_path, "\", "\\" ) +"']" )
		Set step_paths = new StringStream
		step_paths.SetString  files_tag.selectSingleNode( "text()" ).nodeValue
		Do Until  step_paths.AtEndOfStream()
			step_path = Trim( step_paths.ReadLine() )
			If step_path <> "" Then

				copy_ren  source_path +"\"+ step_path,  destination_path +"\"+ step_path
			End If
		Loop
	Next

	echo  "Completed."
End Sub


 
'***********************************************************************
'* Function: ChechOut
'***********************************************************************
Sub  ChechOut()
	If WScript.Arguments.Unnamed.Count >= 2 Then
		projects_path = WScript.Arguments.Unnamed(1)
	Else
		projects_path = Input( ".proja File Path>" )
	End If
	projects_path = GetFullPath( projects_path,  g_start_in_path )

	If WScript.Arguments.Unnamed.Count >= 3 Then
		project_name = WScript.Arguments.Unnamed(2)
	Else
		project_name = Input( "Project Name>" )
	End If

	If WScript.Arguments.Unnamed.Count >= 4 Then
		output_path = WScript.Arguments.Unnamed(3)
	Else
		output_path = Input( "Output Path>" )
	End If
	output_path = GetFullPath( output_path,  g_start_in_path )


	Set root = LoadXML( projects_path, Empty )
	masters_path    = root.selectSingleNode( "./Variable[@name='${Masters}']" ).getAttribute( "value" )
	Set project_tag = root.selectSingleNode( "./Project[@name='"+ Replace( project_name, "\", "\\" ) +"']" )
	If project_tag  is Nothing Then _
		Raise  1, "Not found """+ project_name +""""
	hash_list_path  = root.selectSingleNode( "./Fragment" ).getAttribute( "list" )
	hash_list_path  = Replace( hash_list_path,  "${Masters}",  masters_path )
	base_path_in_hash_list = GetParentFullPath( hash_list_path )
	Set defrag = OpenForDefragmentMini( hash_list_path,  Empty )

	For Each  module_tag  In  project_tag.selectNodes( "./Module" )
		master_path  = module_tag.getAttribute( "master" )

		echo  master_path
		project_path = module_tag.getAttribute( "project" )
		source_path = Replace( master_path,  "${Masters}",  masters_path )
		destination_path = output_path +"\"+ project_path

		defrag.CopyFolder  base_path_in_hash_list,  source_path,  destination_path,  Empty
	Next

	echo  "Completed."
End Sub


 
'***********************************************************************
'* Function: OpenForDefragmentMini
'*    Ooen for defeagment for vbslib mini
'***********************************************************************
Function  OpenForDefragmentMini( in_MD5ListFilePath,  in_Empty )
	Set Me_ = new OpenForDefragmentMiniClass
	Me_.Open  in_MD5ListFilePath
	Set OpenForDefragmentMini = Me_
End Function


 
'***********************************************************************
'* Class: OpenForDefragmentMiniClass
'***********************************************************************
Class  OpenForDefragmentMiniClass
	Public  File
	Public  StepPathsFromHash  '// as dictionary of string. Key=Hash value
	Public  EmptyFolderMD5


 
'***********************************************************************
'* Method: Open
'*
'* Name Space:
'*    OpenForDefragmentMiniClass::Open
'***********************************************************************
Public Sub  Open( in_MD5ListFilePath )
	Set Me.File = g_fs.OpenTextFile( in_MD5ListFilePath,,,-2 )
	Set Me.StepPathsFromHash = CreateObject( "Scripting.Dictionary" )
	Me.EmptyFolderMD5 = String( 32, "0" )
End Sub


 
'***********************************************************************
'* Method: GetStepPath
'*
'* Return Value:
'*    A step path or Empty(= There is not hash value in the list)
'*
'* Name Space:
'*    OpenForDefragmentMiniClass::GetStepPath
'***********************************************************************
Public Function  GetStepPath( in_HashValueOfMD5,  in_Empty )

	If Me.StepPathsFromHash.Exists( in_HashValueOfMD5 ) Then

		GetStepPath = Me.StepPathsFromHash( in_HashValueOfMD5 )

	ElseIf not IsEmpty( Me.File ) Then
		Const  hash_length = 32
		Const  column_of_path = 60  '// with time stamp
		Const  column_of_hash = 27  '// with time stamp
		Set step_paths_from_hash = Me.StepPathsFromHash
		Set file_ = Me.File
		Do Until  file_.AtEndOfStream
			line = file_.ReadLine()
			hash = Mid( line,  column_of_hash,  hash_length )
			step_paths_from_hash( hash ) = Mid( line,  column_of_path )
			If hash = in_HashValueOfMD5 Then

				GetStepPath = Me.StepPathsFromHash( in_HashValueOfMD5 )

				Exit Function
			End If
		Loop
		Me.File = Empty
	End If
End Function


 
'***********************************************************************
'* Method: CopyFolder
'*
'* Name Space:
'*    OpenForDefragmentMiniClass::CopyFolder
'***********************************************************************
Public Sub  CopyFolder( in_BasePathInMD5List,  in_SourceFolderPath,  in_DestinationFolderPath,  in_Flags )
	full_set_path = in_SourceFolderPath +"\_FullSet.txt"
	If not g_fs.FileExists( full_set_path ) Then
		copy_ren  in_SourceFolderPath,  in_DestinationFolderPath
	Else
		Const  hash_length = 32
		Const  time_stamp_length = 25
		Const  column_of_path = 60  '// with time stamp
		Const  column_of_hash = 27  '// with time stamp
		empty_folder_MD5 = EmptyFolderMD5
		base_full_path_in_list = GetFullPath( in_BasePathInMD5List, Empty )
		destination_full_path = GetFullPath( in_DestinationFolderPath, Empty )

		Set file_ = OpenForRead( full_set_path )
		Set current_back_up = g_sh.CurrentDirectory

		g_sh.CurrentDirectory = in_SourceFolderPath

		Do Until  file_.AtEndOfStream
			line = file_.ReadLine()
			step_path = Mid( line,  column_of_path )
			destination_file_full_path = GetFullPath( step_path,  destination_full_path )

			If g_fs.FileExists( step_path ) Then
				copy_ren  step_path,  destination_file_full_path
			Else
				hash = Mid( line,  column_of_hash,  hash_length )
				step_path_in_list = Me.GetStepPath( hash )

				If hash = empty_folder_MD5 Then
					mkdir  destination_file_full_path

				ElseIf not IsEmpty( step_path_in_list ) Then
					source_full_path = GetFullPath( step_path_in_list,  base_full_path_in_list )

					copy_ren  source_full_path,  destination_file_full_path
				Else
					Raise  1, "<ERROR msg=""Not found""  hash_value="""+ hash + _
						"""  in="""+ Me.FileFullPath + _
						"""  source_path="""+ GetFullPath( step_path, Empty ) + _
						"""  in_="""+ full_set_path +"""/>"
				End If
			End If
		Loop

		g_sh.CurrentDirectory = current_back_up
	End If
End Sub


 
'* Section: End_of_Class
End Class


 
'*************************************************************************
'* Function: AssertExist
'*************************************************************************
Sub  AssertExist( Path )
	If not exist( Path ) Then
		Raise  1, "<ERROR msg=""ファイルまたはフォルダーが見つかりません"""+_
			" path="""+ Path +"""/>"
	End If
End Sub


 
'***********************************************************************
'* Function: ChangeScriptMode
'***********************************************************************
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


 
'*************************************************************************
'* Function: copy_ren
'*************************************************************************
Sub  copy_ren( in_SourcePath,  in_DestinationPath )
	is_source_a_folder = g_fs.FolderExists( in_SourcePath )
	If not g_fs.FileExists( in_SourcePath ) Then  AssertExist  in_SourcePath
	If is_source_a_folder Then
		If not g_fs.FolderExists( in_DestinationPath ) Then _
			mkdir  in_DestinationPath
	Else
		parent_destination_path = GetParentFullPath( in_DestinationPath )
		If not g_fs.FolderExists( parent_destination_path ) Then _
			mkdir  parent_destination_path
	End If

	If is_source_a_folder Then
		g_fs.CopyFolder  in_SourcePath,  in_DestinationPath,  True
	Else
		g_fs.CopyFile  in_SourcePath,  in_DestinationPath,  True
	End If
End Sub


 
'***********************************************************************
'* Function: exist
'***********************************************************************
Function  exist( ByVal path )
	exist = ( g_fs.FileExists( path ) = True ) Or ( g_fs.FolderExists( path ) = True )
End Function


 
'*************************************************************************
'* Function: GetFullPath
'*************************************************************************
Function  GetFullPath( StepPath, BasePath )
    If IsFullPath( StepPath ) Then
        GetFullPath = StepPath
    Else
        GetFullPath = g_fs.GetAbsolutePathName( BasePath + "\" + StepPath )
    End If
End Function


 
'*************************************************************************
'* Function: GetParentFullPath
'*************************************************************************
Function  GetParentFullPath( Path )
    GetParentFullPath = g_fs.GetAbsolutePathName( Path + "\.." )
End Function


 
'*************************************************************************
'* Function: Input
'*************************************************************************
Function  Input( Prompt )
	WScript.StdOut.Write  Prompt
	Input = WScript.StdIn.ReadLine()
End Function


 
'*************************************************************************
'* Function: IsFullPath
'*************************************************************************
Function  IsFullPath( Path )
    bs = InStr( Path, "\" )
    sl = InStr( Path, "/" )
    co = InStr( Path, ":" )
    If bs > 0 Then  If co > bs Then  co = 0
    If sl > 0 Then  If co > sl Then  co = 0

    IsFullPath = ( bs = co + 1  or  sl = co + 1 ) or ( Left( Path, 2 ) = "\\" )
End Function


 
'*************************************************************************
'* Function: LoadXML
'*************************************************************************
Function  LoadXML( in_Path, Opt )
    Set xml = CreateObject( "MSXML2.DOMDocument" )
    r = xml.load( in_Path )
    If r=0 Then  Raise 53,"""" + in_Path + """ が見つかりません"
    Set LoadXML = xml.lastChild  '// If firstChild, <?xml> may be got.
End Function


 
'*************************************************************************
'* Function: mkdir
'*************************************************************************
Function  mkdir( ByVal Path )
	If g_fs.FolderExists( Path ) Then  mkdir = 0 : Exit Function
	folder_names = Array()

	n = 0
	fo2 = g_fs.GetAbsolutePathName( Path )
	Do
		If g_fs.FolderExists( fo2 ) Then Exit Do

		n = n + 1
		Redim Preserve  folder_names(n)
		folder_names(n) = g_fs.GetFileName( fo2 )
		fo2 = g_fs.GetParentFolderName( fo2 )
	Loop

	mkdir = n

	For n=n To 1 Step -1
		fo2 = GetFullPath( folder_names(n), fo2 )

		n_retry = 0
		g_fs.CreateFolder  fo2
		If en <> 0 Then
			If g_fs.FileExists( fo2 ) Then
				Raise  E_AlreadyExist, "<ERROR msg=""ファイルが存在する場所にフォルダー"+ _
					"を作成しようとしました"" path="""+ fo2 +"""/>"
			End If
			Err.Raise en,,ed
		End If
	Next
End Function


 
'***********************************************************************
'* Function: Raise
'***********************************************************************
Sub  Raise( ErrNum, Description )
	Err.Raise  ErrNum, "ERROR", Description
End Sub


 
'***********************************************************************
'* Class: StringStream
'***********************************************************************
Class  StringStream

	Public   Str, StrLen
	Public   NextLinePos
	Public   IsWithLineFeed
	Public   WritingLineFeed
	Public   ReadingLineFeed
	Private  m_ReadLine, m_WriteLine, m_bPrevIsWrite

	Private Sub  Class_Initialize()
		Me.IsWithLineFeed = False
		Me.WritingLineFeed = vbCRLF
		Me.ReadingLineFeed = vbLF
	End Sub

	Public Property Get Line()
		If m_bPrevIsWrite Then  Line = m_WriteLine  Else  Line = m_ReadLine
	End Property

	Public  Sub  SetString( Str )
		If Me.IsWithLineFeed  or  Me.ReadingLineFeed = vbCRLF Then
			Me.Str = Str
		Else
			Me.Str = Replace( Str, vbCRLF, vbLF ) '// for supporting vbCRLF and vbLF
		End If
		Me.StrLen = Len( Me.Str )
		Me.NextLinePos = 1
		m_ReadLine = 1
		m_WriteLine = 1
	End Sub

	Public Function  ReadLine()
		i = InStr( Me.NextLinePos, Me.Str, Me.ReadingLineFeed )
		If i > 0 Then
			If Me.IsWithLineFeed Then
				ReadLine = Mid( Me.Str, Me.NextLinePos, i - Me.NextLinePos + 1 )
			Else
				ReadLine = Mid( Me.Str, Me.NextLinePos, i - Me.NextLinePos )
			End If
			Me.NextLinePos = i + Len( Me.ReadingLineFeed )
			If Me.NextLinePos > Me.StrLen Then
				Me.Str = Empty
				Me.NextLinePos = Empty
			End If
		Else
			ReadLine = Mid( Me.Str, Me.NextLinePos )
			Me.Str = Empty
			Me.NextLinePos = Empty
		End If
		m_ReadLine = m_ReadLine + 1
	End Function

	Public Function  ReadAll()
		If not IsEmpty( Me.StrLen ) Then  Raise 1, "対応していません"
			'// SetString and RealAll is not supported. Because vbCR is lost.
		ReadAll = Me.Str
		Me.Str = Empty
	End Function

	Public Property Get AtEndOfStream : AtEndOfStream = IsEmpty( Me.Str ) : End Property
	Public Sub  Write( Str ) : Me.Str = Me.Str + Str : End Sub

	Public Sub  WriteLine( LineStr )
		Me.Str = Me.Str + LineStr + Me.WritingLineFeed
		m_WriteLine = m_WriteLine + 1
	End Sub
End Class


 
