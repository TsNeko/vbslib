'***********************************************************************
'* Function: ArgumentExist
'***********************************************************************
Function  ArgumentExist( name )
	For Each key in WScript.Arguments.Named
		If key = name  Then  ArgumentExist = True : Exit Function
	Next
	ArgumentExist = False
End Function


 
'***********************************************************************
'* Function: Assert
'***********************************************************************
Sub  Assert( in_Condition )
	If in_Condition Then '// This is not same behavior as "If not Condition Then Fail"
	Else
		Error
	End If
End Sub


 
'***********************************************************************
'* Function: AssertExist
'***********************************************************************
Sub  AssertExist( Path )
	If not exist( Path ) Then
		Raise  1, "<ERROR msg=""ファイルまたはフォルダーが見つかりません"""+_
			" path="""+ Path +"""/>"
	End If
End Sub


 
'***********************************************************************
'* Function: AssertFC
'***********************************************************************
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

		Dim  cmdline : cmdline = _
			path_system+"\cmd /C cscript.exe  //nologo """+WScript.ScriptFullName+""""
		For i=0 To WScript.Arguments.Count - 1
			If InStr( WScript.Arguments(i), " " ) = 0 Then _
				cmdline=cmdline+" "+WScript.Arguments(i) _
			Else _
				cmdline=cmdline+" """+WScript.Arguments(i)+""""
		Next

 		CreateObject("WScript.Shell").Run  cmdline, 7
		WScript.Quit  0
	End If
End Sub


 
'***********************************************************************
'* Function: copy
'***********************************************************************
Sub  copy( SrcPath, ByVal DstFolderPath )
	DstFolderPath = g_fs.GetAbsolutePathName( DstFolderPath )
	If not exist( DstFolderPath ) Then _
		mkdir  DstFolderPath

	If Right( SrcPath, 2 ) = "\*" Then
		Set fo = g_fs.GetFolder( Left( SrcPath, Len( SrcPath ) - 2 ) )
		For Each f in fo.Files
			g_fs.CopyFile  f.Path, DstFolderPath +"\"+ f.Name, True
				'// TODO: See copy_ren
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
'* Function: CreateFile
'***********************************************************************
Sub  CreateFile( Path, Text )
	g_fs.CreateTextFile( Path, True, False ).Write  Text
End Sub


 
'***********************************************************************
'* Function: del
'***********************************************************************
Sub  del( ByVal path )
	If g_fs.FileExists( path ) Then
		g_fs.DeleteFile  path
	ElseIf g_fs.FolderExists( path ) Then
		g_fs.DeleteFolder  path
	End If
End Sub


 
'***********************************************************************
'* Function: del_empty_folder
'***********************************************************************
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


 
'***********************************************************************
'* Function: echo
'***********************************************************************
Sub  echo( in_Message )
	WScript.Echo  in_Message
End Sub


 
'***********************************************************************
'* Function: echo_v
'***********************************************************************
Sub  echo_v( in_Message )
	WScript.Echo  in_Message
End Sub


 
'***********************************************************************
'* Class: EchoOff
'***********************************************************************
Class  EchoOff
End Class


 
'***********************************************************************
'* Function: Error
'***********************************************************************
Sub  Error()
	Err.Raise  1,,"Error!"
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


 
'***********************************************************************
'* Function: include
'***********************************************************************
Sub  include( in_Path )
	Set f = g_fs.OpenTextFile( in_Path,,,-2 )
	ExecuteGlobal  f.ReadAll()
End Sub


 
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


 
'*************************************************************************
'* Function: mkdir_for
'*************************************************************************
Sub  mkdir_for( in_Path )
    path2 = GetParentFullPath( in_Path )
    If path2 = "" Then Exit Sub
    mkdir  path2
End Sub


 
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
		If Right( fo2, 1 ) <> "\" Then _
			fo2 = fo2 +"\"
		fo2 = fo2 + folder_names(n)

		n_retry = 0
		g_fs.CreateFolder  fo2
		If en <> 0 Then
			If g_fs.FileExists( fo2 ) Then
				Err.Raise  58, "<ERROR msg=""ファイルが存在する場所にフォルダー"+ _
					"を作成しようとしました"" path="""+ fo2 +"""/>"
			End If
			Err.Raise en,,ed
		End If
	Next
End Function


 
'***********************************************************************
'* Function: Pause
'***********************************************************************
Sub  Pause()
	echo_v  "続行するには Enter キーを押してください . . ."
	WScript.StdIn.ReadLine
End Sub


 
'***********************************************************************
'* Function: Raise
'***********************************************************************
Sub  Raise( in_ErrNum,  in_Description )
	Err.Raise  in_ErrNum,  "ERROR",  in_Description
End Sub


 
'***********************************************************************
'* Function: ReadFile
'***********************************************************************
Function  ReadFile( in_Path )
	Set f = g_fs.OpenTextFile( in_Path,  1,  False,  -2 )
	ReadFile = f.ReadAll()
End Function


 
'***********************************************************************
'* Function: RunProg
'***********************************************************************
Function  RunProg( in_CommandLine,  in_StdOut_StdErr_Redirect )
	Set ex = g_sh.Exec( in_CommandLine )
	echo_v  ">RunProg  "+ in_CommandLine
	RunProg = WaitForFinishAndRedirect( ex,  in_StdOut_StdErr_Redirect )
	echo_v  ""
End Function


 
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
'* Function: WaitForFinishAndRedirect
'***********************************************************************
Function  WaitForFinishAndRedirect( ex, path )
	Do While ex.Status = 0
		Do Until ex.StdOut.AtEndOfStream : echo_v  ex.StdOut.ReadLine : Loop
		Do Until ex.StdErr.AtEndOfStream : echo_v  ex.StdErr.ReadLine : Loop
	Loop
	Do Until ex.StdOut.AtEndOfStream : echo_v  ex.StdOut.ReadLine : Loop
	Do Until ex.StdErr.AtEndOfStream : echo_v  ex.StdErr.ReadLine : Loop
	WaitForFinishAndRedirect = ex.ExitCode
End Function


 
