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
	Set variables = LoadVariableInXML( root,  projects_path )
	Set project_tag = root.selectSingleNode( "./Project[@name='"+ Replace( project_name, "\", "\\" ) +"']" )
	If project_tag  is Nothing Then _
		Raise  1, "Not found """+ project_name +""""

	For Each  module_tag  In  project_tag.selectNodes( "./Module" )
		master_path  = module_tag.getAttribute( "master" )

		echo  master_path
		project_path = module_tag.getAttribute( "project" )
		source_path = work_path +"\"+ project_path
		source_path = variables( source_path )
		destination_path = variables( master_path )

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
	Set variables = LoadVariableInXML( root,  projects_path )
	Set project_tag = root.selectSingleNode( "./Project[@name='"+ Replace( project_name, "\", "\\" ) +"']" )
	If project_tag  is Nothing Then _
		Raise  1, "Not found """+ project_name +""""
	hash_list_path  = root.selectSingleNode( "./Fragment" ).getAttribute( "list" )
	hash_list_path  = variables( hash_list_path )
	base_path_in_hash_list = GetParentFullPath( hash_list_path )
	Set defrag = OpenForDefragmentMini( hash_list_path,  Empty )

	For Each  module_tag  In  project_tag.selectNodes( "./Module" )
		master_path  = module_tag.getAttribute( "master" )

		echo  master_path
		project_path = module_tag.getAttribute( "project" )
		source_path = variables( master_path )
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
		g_fs.CopyFolder  g_fs.GetAbsolutePathName( in_SourcePath ), _
			g_fs.GetAbsolutePathName( in_DestinationPath ),  True
	Else
		g_fs.CopyFile  in_SourcePath,  in_DestinationPath,  True
	End If
End Sub


 
'***********************************************************************
'* Function: exist
'***********************************************************************
Function  exist( in_Path )
	exist = ( g_fs.FileExists( in_Path ) = True ) Or ( g_fs.FolderExists( in_Path ) = True )
End Function


 
'*************************************************************************
'* Function: GetFullPath
'*************************************************************************
Function  GetFullPath( StepPath, BasePath )
	GetFullPath = GetFullPath_TypeA( StepPath, BasePath )
End Function


 
'*************************************************************************
'* Function: GetFullPath_TypeA
'*
'* Description:
'*    アプリケーションから、この関数を呼び出すときは、GetFullPath 関数を
'*    経由してください。
'*************************************************************************
Function  GetFullPath_TypeA( StepPath, BasePath )
	If IsFullPath( StepPath ) Then
		GetFullPath_TypeA = StepPath
	Else
		If IsEmpty( BasePath ) Then
			GetFullPath_TypeA = g_fs.GetAbsolutePathName( StepPath )
		Else
			GetFullPath_TypeA = g_fs.GetAbsolutePathName( BasePath + "\" + StepPath )
		End If
	End If
End Function


 
'*************************************************************************
'* Function: GetFullPath_TypeB
'*
'* Description:
'*    アプリケーションから、この関数を呼び出すときは、GetFullPath 関数を
'*    経由してください。 また、アプリケーションが "vbslib_mini.vbs" を
'*    インクルードした後で、GetFullPath の定義を再定義してください。
'*************************************************************************
Function  GetFullPath_TypeB( in_StepPath,  in_BasePath )

	'//=== Cut ... (SearchParent)
	If InStr( in_StepPath,  "..." ) > 0 Then
		i = InStr( in_StepPath,  "\...\" )
		If i = 0 Then
			If Left( in_StepPath, 4 ) = "...\" Then _
				i = 1
		Else
			i = i + 1
		End If
		If i > 0 Then
			If i >= 2 Then
				current_directory = GetFullPath_TypeA( Left( in_StepPath,  i-2 ),  in_BasePath )
			Else
				current_directory = in_BasePath
			End If
			step_path = Mid( in_StepPath, i+4 )
			Do
				is_root = ( InStr( current_directory, "\" ) = InStrRev( current_directory, "\" ) )
				If is_root Then
					full_path = current_directory + step_path
				Else
					full_path = current_directory +"\"+ step_path
				End If

				If exist( full_path ) Then
					GetFullPath_TypeB = g_fs.GetAbsolutePathName( full_path )
					Exit Function
				End If
				If is_root Then  Error
				current_directory = g_fs.GetAbsolutePathName( current_directory +"\.." )
			Loop
		End If
	End If


	'// Call "GetFullPath"
	GetFullPath_TypeB = GetFullPath_TypeA( in_StepPath,  in_BasePath )
End Function


 
'*************************************************************************
'* Function: GetParentFullPath
'*************************************************************************
Function  GetParentFullPath( in_Path )
    GetParentFullPath = g_fs.GetAbsolutePathName( in_Path + "\.." )
End Function


 
'*************************************************************************
'* Function: Input
'*************************************************************************
Function  Input( in_Prompt )
	WScript.StdOut.Write  in_Prompt
	Input = WScript.StdIn.ReadLine()
End Function


 
'*************************************************************************
'* Function: IsFullPath
'*************************************************************************
Function  IsFullPath( in_Path )
    bs = InStr( in_Path, "\" )
    sl = InStr( in_Path, "/" )
    co = InStr( in_Path, ":" )
    If bs > 0 Then  If co > bs Then  co = 0
    If sl > 0 Then  If co > sl Then  co = 0

    IsFullPath = ( bs = co + 1  or  sl = co + 1 ) or ( Left( in_Path, 2 ) = "\\" )
End Function


 
'***********************************************************************
'* Class: LazyDictionaryClass
'***********************************************************************
Class  LazyDictionaryClass
	Private  m_Dictionary
	Public   DebugMode  '// as Empty or True
	Public   MaxExpandCount  '// as integer

	Private Sub  Class_Initialize()
		Set m_Dictionary = CreateObject( "Scripting.Dictionary" )
		Me.MaxExpandCount = 100
	End Sub


	'// LazyDictionaryClass::Item
	Public Default Property Get  Item( in_Key )
		Item = in_Key

		If Me.DebugMode Then
			echo_v  "<DictionaryEx operation=""Get"" key="""+ in_Key +""">"
		End If

		Me_Expand  in_Key,  Item,  Empty,  expand_count  '//Set "Item"

		If Me.DebugMode Then
			echo_v  "</DictionaryEx>"
		End If
	End Property


	'// LazyDictionaryClass::Me_Expand
	Public Sub  Me_Expand( in_Key,  in_out_Item,  in_Index,  expand_count )
		sub_expand_count = 0
		Do
			start_pos = InStr( in_out_Item, "${" )
			If start_pos = 0 Then
				escape_pos = InStr( in_out_Item, "$\" )
				If escape_pos = 0 Then
					Exit Do
				End If
			End If

			If Me.DebugMode Then
				If sub_expand_count = 0 Then
					If not IsEmpty( in_Index ) Then
						echo_v  "<Item index="""& in_Index &""">"
					End If
				End If
			End If

			If start_pos > 0 Then
				last_pos = InStr( start_pos, in_out_Item, "}" )

				start_pos = InStrRev( in_out_Item, "${", last_pos )
				child_key = Mid( in_out_Item,  start_pos,  last_pos - start_pos + 1 )
				If not m_Dictionary.Exists( child_key ) Then
					a_key = "%"+ Mid( child_key, 3, Len( child_key ) - 3 ) +"%"
					child_item = g_sh.ExpandEnvironmentStrings( a_key )
					If child_item = a_key Then _
						Error
				Else
					LetSet  child_item,  m_Dictionary( child_key )
				End If

				If IsObject( child_item ) Then
					Set in_out_Item = child_item
					Exit Sub
				End If

				expand_count = expand_count + 1
				sub_expand_count = sub_expand_count + 1
				If in_out_Item = child_key Then
					in_out_Item = child_item

					If IsNull( in_out_Item ) Then _
						in_out_Item = Empty
						'// Portable to standard dictionary

					If VarType( in_out_Item ) <> vbString Then _
						Exit Do
				Else
					in_out_Item = Replace( in_out_Item,  child_key,  child_item )
				End If

				If expand_count >= Me.MaxExpandCount Then _
					Error

				If Me.DebugMode Then
					echo_v  "<Expand count="""& expand_count &""">"+ in_out_Item +"</Expand>"
				End If

			Else '// escape_pos > 0
				If IsNull( in_out_Item ) Then
					in_out_Item = Empty  '// Portable to standard dictionary
					Exit Do
				End If

				in_out_Item = Replace( in_out_Item, "$\", "$" )
				expand_count = expand_count + 1

				If Me.DebugMode Then
					echo_v  "<Expand count="""& expand_count &""">"+ in_out_Item +"</Expand>"
				End If
				Exit Do
			End If
		Loop

		If Me.DebugMode Then
			If not IsEmpty( in_Index ) Then
				If sub_expand_count = 0 Then
					echo_v  "<Item index="""& in_Index &""">"+ _
						GetEchoStr( in_out_Item ) +"</Item>"
				Else
					echo_v  "</Item>"
				End If
			End If
		End If
	End Sub


	'// LazyDictionaryClass::Item
	Public Property Let  Item( in_Key, in_NewItem )
		Me.CheckAsKey  in_Key
		If Me.DebugMode Then  Me.EchoSetForDebug  in_Key,  in_NewItem
		m_Dictionary( in_Key ) = in_NewItem
	End Property


	'// LazyDictionaryClass::Item
	Public Property Set  Item( in_Key,  in_NewItem )
		Me.CheckAsKey  in_Key
		If Me.DebugMode Then  Me.EchoSetForDebug  in_Key,  in_NewItem
		Set  m_Dictionary( in_Key ) = in_NewItem
	End Property


	'// LazyDictionaryClass::IsKeyOnly
	Public Function  IsKeyOnly( in_Key )
		IsKeyOnly = Left( in_Key, 2 ) = "${"  and  Right( in_Key, 1 ) = "}"  and  InStr( 3, in_Key, "${" ) = 0
	End Function

	Public Sub  CheckAsKey( in_Key )
		If not Me.IsKeyOnly( in_Key ) Then
			Error  '// Not found ${ }
		End If
	End Sub


	'// LazyDictionaryClass  Othets
	Public Sub  EchoSetForDebug( in_Key,  in_NewItem )
		echo_v  "<DictionaryEx operation=""Set"" key="""+ in_Key +""">"+ GetEchoStr( in_NewItem ) +_
			"</DictionaryEx>"
	End Sub


	'// LazyDictionaryClass::AppendFromVariableXML
	Public Sub  AppendFromVariableXML( in_XML_Element,  in_BaseFullPath )
		name   = in_XML_Element.getAttribute( "name" )
		value  = in_XML_Element.getAttribute( "value" )
		type__ = in_XML_Element.getAttribute( "type" )
		If Me.Exists( name ) Then _
			Error  '// Aleady Exists
		If IsNull( type__ ) Then
			Me.Item( name ) = value
		ElseIf type__ = "FullPathType" Then
			Me.Item( name ) = GetFullPath_TypeB( value,  in_BaseFullPath )
		End If
	End Sub


	Public Property Get  Count() : Count = m_Dictionary.Count : End Property
	Public Property Get  Keys()  : Keys  = m_Dictionary.Keys  : End Property
	Public Property Get  Items() : Items = m_Dictionary.Items : End Property
	Public Function  Exists( in_Key ) : Exists = m_Dictionary.Exists( in_Key ) : End Function
	Public Property Get  CompareMode() : CompareMode = m_Dictionary.CompareMode : End Property
	Public Property Let  CompareMode( x ) : m_Dictionary.CompareMode = x : End Property
	Public Sub  Remove( in_Key )
		If m_Dictionary.Exists( in_Key ) Then  m_Dictionary.Remove  in_Key
	End Sub
	Public Sub  RemoveAll() : m_Dictionary.RemoveAll : End Sub
End Class


 
'***********************************************************************
'* Function: LetSet
'***********************************************************************
Sub  LetSet( Out, In_ )
	If IsObject( In_ ) Then
		Set Out = In_
	Else
		Out = In_
	End If
End Sub


 
'***********************************************************************
'* Function: LoadVariableInXML
'***********************************************************************
Function  LoadVariableInXML( in_RootXML_Element,  in_FilePathOfXML )
	base_path = GetParentFullPath( in_FilePathOfXML )
	Set variables = new LazyDictionaryClass

	For Each  variable_tag  In  in_RootXML_Element.selectNodes( ".//Variable" )
		variables.AppendFromVariableXML  variable_tag,  base_path
	Next

	Set LoadVariableInXML = variables
End Function


 
'*************************************************************************
'* Function: LoadXML
'*************************************************************************
Function  LoadXML( in_Path,  in_Ignored )
    Set xml = CreateObject( "MSXML2.DOMDocument" )
    r = xml.load( in_Path )
    If r=0 Then  Raise 53,"""" + in_Path + """ が見つかりません"
    Set LoadXML = xml.lastChild  '// If firstChild, <?xml> may be got.
End Function


 
'***********************************************************************
'* Function: mkdir
'***********************************************************************
Function  mkdir( in_Path )
	If g_fs.FolderExists( in_Path ) Then _
		mkdir = 0 : Exit Function
	folder_names = Array()

	n = 0
	fo2 = g_fs.GetAbsolutePathName( in_Path )
	Do
		If g_fs.FolderExists( fo2 ) Then Exit Do

		n = n + 1
		Redim Preserve  folder_names(n)
		folder_names(n) = g_fs.GetFileName( fo2 )
		fo2 = g_fs.GetParentFolderName( fo2 )
	Loop

	mkdir = n

	For n=n To 1 Step -1
		fo2 = GetFullPath( folder_names(n),  fo2 )

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
Sub  Raise( in_ErrNum,  in_Description )
	Err.Raise  in_ErrNum,  "ERROR",  in_Description
End Sub


 
'*************************************************************************
'* Function: SearchParent
'*************************************************************************
Function  SearchParent( ByVal  in_StepPath )
	current = g_sh.CurrentDirectory

	If IsFullPath( in_StepPath ) Then
		If exist( in_StepPath ) Then _
			SearchParent = in_StepPath
		Exit Function
	End If

	i = 0
	Do
		i = InStr( i+1, current, "\" )
		If exist( in_StepPath ) Then
			SearchParent = GetFullPath( in_StepPath,  Empty )
			Exit Function
		End If
		If i = 0 Then _
			Exit Function
		in_StepPath = "..\"+ in_StepPath
	Loop
End Function


 
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


 
