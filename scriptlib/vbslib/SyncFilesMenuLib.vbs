'// vbslib - VBScript ShortHand Library  ver4.90  Aug.17, 2014
'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

'-------------------------------------------------------------------------
' ### <<<< [SyncFilesMenu] Class >>>> 
'-------------------------------------------------------------------------
Class  SyncFilesMenu
	Public  RootFolders  '// as SyncFilesRoot<ArrayClass index_num="for user"/>
	Public  IsCompareTimeStamp  '// as boolean
	Public  IsCompareContents   '// as boolean
	Public  IsCallViaFile       '// as boolean
	Public  Lead  '// as string


	Private Sub  Class_Initialize()
		Set Me.RootFolders = new ArrayClass
		Me.IsCompareTimeStamp = True
		Me.IsCompareContents  = True
		Me.IsCallViaFile = False
	End Sub

	'//[SyncFilesMenu::AddRootFolder]
	Public Function  AddRootFolder( IndexNum, RootFolderPath )
		Dim  o : Set o = new SyncFilesRoot

		o.AbsPath = GetFullPath( RootFolderPath, Empty )
		Set  o.Files = new ArrayClass
		Set  o.IsSameFolderAsBinary = new ArrayClass

		If IndexNum > Me.RootFolders.UBound_ Then  Me.RootFolders.ReDim_  IndexNum
		Set Me.RootFolders( IndexNum ) = o
		Set AddRootFolder = o
	End Function

	'//[SyncFilesMenu::AddFile]
	Public Sub  AddFile( StepPath )
		AddFileWithLabel  Empty, StepPath
	End Sub

	'//[SyncFilesMenu::AddFileWithLabel]
	Public Sub  AddFileWithLabel( Label, StepPath )
		Dim  o, folder

		folder_num = 0
		For Each  folder  In Me.RootFolders.Items
			If IsArray( StepPath ) Then
				a_step_path = StepPath( folder_num )
				folder_num = folder_num + 1
			Else
				a_step_path = StepPath
			End If

			Set o = new SyncFilesFile
			If IsEmpty( folder.ParentFolderProxyName ) Then
				o.StepPath = a_step_path
			Else
				o.StepPath = Replace( a_step_path, "..", folder.ParentFolderProxyName )
			End If
			o.AbsPath = GetFullPath( o.StepPath, folder.AbsPath )
			Set o.IsSameBinary = new ArrayClass
			o.Label = Label

			folder.Files.Add  o
		Next
	End Sub

	'//[SyncFilesMenu::Compare]
	Public Sub  Compare()
		Dim  step_path,  folder_num,  other_folder_num,  folder
		Dim  base_folder : Set base_folder = Me.RootFolders(0)
		Dim  folder_ubound : folder_ubound = Me.RootFolders.UBound_

		Assert  Me.IsCompareTimeStamp  or  Me.IsCompareContents
		Assert  not Me.IsCompareTimeStamp  '// not supported

		'//  Me.RootFolders( ... ).IsSameFolderAsBinary( ... ) : reset
		For folder_num = 0  To folder_ubound
			Me.RootFolders( folder_num ).IsSameFolderAsBinary.ReDim_  folder_ubound
			For other_folder_num = 0  To folder_ubound
				Me.RootFolders( folder_num ).IsSameFolderAsBinary( other_folder_num ) = True
			Next
		Next

		For file_num = 0  To base_folder.Files.UBound_
			Me.Compare_sub  file_num, folder_ubound
		Next
	End Sub

	'//[SyncFilesMenu::Compare_sub]
	Public Sub  Compare_sub( file_num, folder_ubound )
		Dim  folder_num,  other_folder_num,  file
		ReDim  texts( folder_ubound ),  files( folder_ubound )

		'// texts( folder_num ) : cache
		If Me.IsCompareContents Then
			For folder_num = 0  To folder_ubound
				Set files( folder_num ) = Me.RootFolders( folder_num ).Files( file_num )
				texts( folder_num ) = ReadFile( files( folder_num ).AbsPath )
			Next
		End If

		For folder_num = 0  To folder_ubound
			Set file = files( folder_num )
			file.IsExist = g_fs.FileExists( files( folder_num ).AbsPath )
			file.IsSameBinary.ReDim_  folder_ubound

			'// Me.RootFolders( folder_num ).Files( file_num ).IsSameBinary( other_folder_num )
			'// Me.RootFolders( ... ).IsSameFolderAsBinary( ... )
			For other_folder_num = 0  To folder_ubound
				If folder_num < other_folder_num Then
					If texts( folder_num ) = texts( other_folder_num ) Then
						file.IsSameBinary( other_folder_num ) = True
					Else
						file.IsSameBinary( other_folder_num ) = False
						Me.RootFolders( folder_num ).IsSameFolderAsBinary( other_folder_num ) = False
						Me.RootFolders( other_folder_num ).IsSameFolderAsBinary( folder_num ) = False
					End If
				ElseIf folder_num = other_folder_num Then
					file.IsSameBinary( other_folder_num ) = True
				Else
					file.IsSameBinary( other_folder_num ) = _
						files( other_folder_num ).IsSameBinary( folder_num )
				End If
			Next
		Next
	End Sub

	'//[SyncFilesMenu::OpenSyncMenu]
	Public Sub  OpenSyncMenu()
		Dim  line,  sub_line,  file,  step_path,  folder_num,  other_folder_num
		Dim  file_num,  key,  not_exist_count,  is_conma
		Dim  base_folder : Set base_folder = Me.RootFolders(0)
		Dim  folder_ubound : folder_ubound = Me.RootFolders.UBound_

		'// labels
		ReDim  labels( folder_ubound )
		For folder_num = 0  To folder_ubound
			labels( folder_num ) = Me.RootFolders( folder_num ).Label
			If IsEmpty( labels( folder_num ) ) Then
				If folder_num = 0 Then
					labels( folder_num ) = "Base"
				ElseIf folder_ubound = 1 Then
					labels( folder_num ) = "Update"
				Else
					labels( folder_num ) = "Folder" + Chr( folder_num + Asc("A") - 1 )
				End If
			End If
		Next

		Do
			If not IsEmpty( Me.Lead ) Then  echo  Me.Lead

			'// base_files : Me.RootFolders(0).Files(...)
			'// echo file list
			ReDim  base_files( base_folder.Files.Count )
			
			For file_num = 0  To base_folder.Files.UBound_
				Set base_files( file_num ) = base_folder.Files( file_num )
				step_path = base_files( file_num ).StepPath

				line = " " & ( file_num + 1 ) & ". " & step_path & " :"

				If IsEmpty( base_files( file_num ).Label ) Then
					is_conma = False
					If Me.IsCompareContents Then

						'// line : exist
						not_exist_count = 0
						sub_line = ""
						For folder_num = 0  To folder_ubound
							If not Me.RootFolders( folder_num ).Files( file_num ).IsExist Then
								If not_exist_count >= 1 Then  sub_line = sub_line + ","
								not_exist_count = not_exist_count + 1
								sub_line = sub_line +" "+ labels( folder_num )
							End If
						Next
						If not_exist_count = folder_ubound + 1 Then
							line = line +" すべてのフォルダーに存在しません"
							is_conma = True
						ElseIf not_exist_count = folder_ubound Then
							For folder_num = 0  To folder_ubound
								If Me.RootFolders( folder_num ).Files( file_num _
									).IsExist Then  Exit For
							Next
							line = line +" "+ labels( folder_num ) +" のみに存在します"
							is_conma = True
						ElseIf not_exist_count > 0 Then
							line = line + sub_line +" に存在しません"
							is_conma = True
						End If


						'// line : compare contents
						For folder_num = 0  To folder_ubound
							Set file = Me.RootFolders( folder_num ).Files( file_num )
							If file.IsExist Then  Exit For
						Next
						For other_folder_num = folder_num + 1  To folder_ubound
							If not file.IsSameBinary( other_folder_num ) Then _
								If Me.RootFolders( other_folder_num ).Files( file_num ).IsExist Then _
									Exit For
						Next
						If other_folder_num > folder_ubound  and  not_exist_count < folder_ubound Then
							If is_conma Then  line = line + ","
							line = line + " 同じ内容"
						Else
							For folder_num = 0  To folder_ubound
								Set file = Me.RootFolders( folder_num ).Files( file_num )
								For other_folder_num = 0  To folder_ubound
								If folder_num < other_folder_num Then
								If file.IsExist Then
									If Me.RootFolders( other_folder_num ).Files( file_num ).IsExist Then
										If is_conma Then  line = line + ","
										is_conma = True

										line = line +" "+ labels( folder_num )
										If file.IsSameBinary( other_folder_num ) Then
											line = line + "＝"
										Else
											line = line + "≠"
										End If
										line = line + labels( other_folder_num )
									End If
								End If
								End If
								Next
							Next
						End If
					End If
				Else
					line = line +" "+ base_files( file_num ).Label
				End If

				echo  line
			Next
			If IsCallViaFile Then  echo  " 80. CallViaFile"
			echo  " 99. 戻る"

			Do
				key = CInt2( input( "ファイルの番号を入力してください >" ) )
				If key >= 1  and  key <= UBound( base_files )  or  key = 99 Then  Exit Do
				If key = 80 Then  CallViaFile  Empty
			Loop
			If key = 99 Then  Exit Do

			file_num = key - 1
			step_path = base_files( file_num ).StepPath
			echo  ""
			echo  step_path

			echo_line

			If folder_ubound = 1 Then
				start  GetDiffCmdLine( Me.RootFolders(0).Files( file_num ).AbsPath, _
				                       Me.RootFolders(1).Files( file_num ).AbsPath )
			Else
				start  GetDiffCmdLine3( Me.RootFolders(0).Files( file_num ).AbsPath, _
				                        Me.RootFolders(1).Files( file_num ).AbsPath, _
				                        Me.RootFolders(2).Files( file_num ).AbsPath )
			End If

			Me.Compare_sub  file_num, Me.RootFolders.UBound_
		Loop
	End Sub

	'//[SyncFilesMenu::IsSameFolder]
	Public Function  IsSameFolder( FolderA_IndexNum, FolderB_IndexNum )
		IsSameFolder = Me.RootFolders( FolderA_IndexNum ).IsSameFolderAsBinary( FolderB_IndexNum )
	End Function

	'//[SyncFilesMenu::SetParentFolderProxyName]
	Public Sub  SetParentFolderProxyName( IndexNum, Name )
		Me.RootFolders( IndexNum ).ParentFolderProxyName = Name
	End Sub
End Class


Class  SyncFilesRoot
	Public  Label      '// as string
	Public  AbsPath    '// as string
	Public  ParentFolderProxyName  '// as string
	Public  Files      '// as SyncFilesFile<dic key="StepPath"/>
	Public  IsSameFolderAsBinary  '// as boolean<ArrayClass index_num="SyncFilesMenu::RootFolders"/>
End Class

Class  SyncFilesFile
	Public  StepPath      '// as string
	Public  AbsPath       '// as string
	Public  IsExist       '// as boolean
	Public  IsSameBinary  '// as boolean<ArrayClass index_num="SyncFilesMenu::RootFolders"/>
	Public  Label         '// as string
End Class


 
'*************************************************************************
'  <<< [IsSynchronizedFilesX] >>> 
'*************************************************************************
Function  IsSynchronizedFilesX( Path )
	AssertExist  Path
	Set sync = new SyncFilesX_Class
	Set ec = new EchoOff
	sync.LoadScanListUpAll  GetFilePathString( Path ), ReadFile( Path )
	IsSynchronizedFilesX = sync.GetIsAllSynchronized()
End Function


 
'*************************************************************************
'  <<< [SyncFilesX_App] >>> 
'*************************************************************************
Sub  SyncFilesX_App( AppKey, Path )
	Set sync = new SyncFilesX_Class

	AssertExist  Path

	If ArgumentExist("check") Then
		Set ec = new EchoOff
		sync.LoadScanListUpAll  GetFilePathString( Path ), ReadFile( path )

		If sync.GetIsAllSynchronized() Then
			Pass
		Else
			Fail
		End If
	Else
		Do
			sync.LoadScanListUpAll  GetFilePathString( Path ), ReadFile( Path )
			w_ = Empty
			Set w_=AppKey.NewWritable( Array( sync.GetWritableFolders(), _
				g_sh.SpecialFolders( "Desktop" ) ) ).Enable()
			result = sync.OpenCUI()

			If result = "Exit" Then  Exit Do
		Loop
	End If
End Sub


 
'*************************************************************************
'  <<< [SyncFilesX_Class] >>> 
'*************************************************************************
Class  SyncFilesX_Class
	Public  SettingFileFullPath
	Public  SettingFolderFullPath
	Public  XML_String

	Public  Sets  '// as ArrayClass of SyncFilesX_SetClass

	Public  IsSameFunction

	Private Sub  Class_Initialize()
		Set Me.Sets = new ArrayClass
		Set Me.IsSameFunction = GetRef( "SyncFilesX_FileClass_isSameDefault" )
	End Sub


 
'*************************************************************************
'  <<< [SyncFilesX_Class::LoadScanListUpAll] >>> 
'*************************************************************************
Public Sub  LoadScanListUpAll( SettingFilePath, XML_String )
	Me.SettingFileFullPath = GetFullPath( SettingFilePath, Empty )
	Me.SettingFolderFullPath = GetParentFullPath( SettingFilePath )
	Me.XML_String = XML_String
	Set sync_sets = new ArrayClass

	Set root = LoadXML( XML_String, F_Str )
	Set variables = new_LazyDictionaryClass( root )

	echo  Me.SettingFileFullPath
	echo  ""
	echo  "同期するファイルの一覧："
	echo  "  中央の記号の意味: [=]同じ [!]異なる [ ]両方不在"
	echo  "  左右の記号の意味: [*]変更 [+]追加 [-]削除 [.]不変 [ ]不在"
	echo  "  左はベース、右はワーク"
	echo  ""


	'// Set "sync_sets" : Parse <SynchronizingSet>
	Me.Sets.ToEmpty

	For Each  root_folder_tag  In root.selectNodes( "./SynchronizingSet" )
		Set  a_sync_set = new SyncFilesX_SetClass
		sync_sets.Add  a_sync_set

		Set a_sync_set.SetTag = root_folder_tag
		Me.LoadScanListUpAll_SetPaths_Sub  a_sync_set, variables
	Next


	'// Parse <File>
	root_num = 0
	For Each  a_sync_set  In sync_sets.Items
		Me.Sets.Add  a_sync_set
		root_num = root_num + 1
		If sync_sets.Count >= 2 Then _
			echo  root_num & "."
		echo  "■ベース（"+ a_sync_set.BaseName +"）: """+ a_sync_set.NewBaseRootStepPath +""""
		echo  "■ワーク（"+ a_sync_set.WorkName +"）: """+ a_sync_set.NewWorkRootStepPath +""""

		Me.LoadScanListUp_Sub  a_sync_set

		echo  ""
	Next
End Sub


 
'*************************************************************************
'  <<< [SyncFilesX_Class::LoadScanListUpAll_SetPaths_Sub] >>> 
'*************************************************************************
Public Sub  LoadScanListUpAll_SetPaths_Sub( a_sync_set, variables )
	Set root_folder_tag = a_sync_set.SetTag

	a_sync_set.BaseName = root_folder_tag.getAttribute( "base_name" )
	a_sync_set.WorkName = root_folder_tag.getAttribute( "work_name" )

	a_sync_set.NewBaseRootStepPath = root_folder_tag.getAttribute( "base" )
	a_sync_set.NewWorkRootStepPath = root_folder_tag.getAttribute( "path" )
	a_sync_set.OldBaseRootStepPath = root_folder_tag.getAttribute( "synced_base" )
	a_sync_set.OldWorkRootStepPath = root_folder_tag.getAttribute( "synced_path" )

	a_sync_set.NewBaseRootStepPath = variables( a_sync_set.NewBaseRootStepPath )
	a_sync_set.NewWorkRootStepPath = variables( a_sync_set.NewWorkRootStepPath )
	a_sync_set.OldBaseRootStepPath = variables( a_sync_set.OldBaseRootStepPath )
	a_sync_set.OldWorkRootStepPath = variables( a_sync_set.OldWorkRootStepPath )

	a_sync_set.NewBaseRootFullPath = GetFullPath( a_sync_set.NewBaseRootStepPath, Me.SettingFolderFullPath )
	a_sync_set.NewWorkRootFullPath = GetFullPath( a_sync_set.NewWorkRootStepPath, Me.SettingFolderFullPath )
	a_sync_set.OldBaseRootFullPath = GetFullPath( a_sync_set.OldBaseRootStepPath, Me.SettingFolderFullPath )
	a_sync_set.OldWorkRootFullPath = GetFullPath( a_sync_set.OldWorkRootStepPath, Me.SettingFolderFullPath )
End Sub


 
'*************************************************************************
'  <<< [SyncFilesX_Class::LoadScanListUp_Sub] >>> 
'*************************************************************************
Sub  LoadScanListUp_Sub( a_sync_set )
	Set parent_tag = a_sync_set.SetTag

	'// Set "all_both_dic", "all_work_dic", "all_base_dic" as "dictionary" of "IXMLDOMElement"
	'// Step 1. ファイルパスをキーとした辞書を作成する

	Set files_folders_tags = parent_tag.selectNodes( "./File | ./Folder" )

	Set path_only_tags = new ArrayClass
	Set path_and_base_tags = new ArrayClass
	For Each tag  In files_folders_tags
		If IsNull( tag.getAttribute( "base" ) ) Then
			path_only_tags.Add  tag
		Else
			path_and_base_tags.Add  tag
		End If
	Next

	ReDim  work_dic(2-1)
	ReDim  base_dic(4-1)
	Set work_dic(0) = new_PathDictionaryClass_fromXML( files_folders_tags, "path", a_sync_set.NewWorkRootFullPath )
	Set work_dic(1) = new_PathDictionaryClass_fromXML( files_folders_tags, "path", a_sync_set.OldWorkRootFullPath )
	Set base_dic(0) = new_PathDictionaryClass_fromXML( path_only_tags.Items,     "path", a_sync_set.NewBaseRootFullPath )
	Set base_dic(1) = new_PathDictionaryClass_fromXML( path_and_base_tags.Items, "base", a_sync_set.NewBaseRootFullPath )
	Set base_dic(2) = new_PathDictionaryClass_fromXML( path_only_tags.Items,     "path", a_sync_set.OldBaseRootFullPath )
	Set base_dic(3) = new_PathDictionaryClass_fromXML( path_and_base_tags.Items, "base", a_sync_set.OldBaseRootFullPath )

	Set all_both_dic = CreateObject( "Scripting.Dictionary" )
	Set all_work_dic = CreateObject( "Scripting.Dictionary" )
	Set all_base_dic = CreateObject( "Scripting.Dictionary" )
	For index = 0  To UBound( base_dic )
		base_dic( index ).IsNotFoundError = False
		For Each  file_path  In base_dic( index ).FilePaths
			Set tag = base_dic( index )( file_path )
			Set all_both_dic( file_path ) = tag
			Set all_base_dic( file_path ) = tag
		Next
	Next
	For index = 0  To UBound( work_dic )
		work_dic( index ).IsNotFoundError = False
		For Each  file_path  In work_dic( index ).FilePaths
			Set tag = work_dic( index )( file_path )
			Set all_both_dic( file_path ) = tag  '// ワークで上書きすることがある
			Set all_work_dic( file_path ) = tag
		Next
	Next


	'// Set "all_both_dic", "all_work_dic", "all_base_dic" as "dictionary" of "IXMLDOMElement"
	'// Step 2. same="clone" のフォルダーのパスをを追加し、その中にあるすべてのファイルのパスを除く
	Set clone_tags = new ArrayClass
	For Each  file_path  In  all_both_dic.Keys
		Set tag = all_both_dic( file_path )
		If tag.tagName = "Folder" Then
			If tag.getAttribute( "same" ) = "clone" Then
				clone_tags.Add  tag
			End If
		End If
	Next

	For Each  a_dic  In  Array( all_both_dic, all_work_dic, all_base_dic )
		For Each  file_path  In  a_dic.Keys
			Set tag = a_dic( file_path )
			If tag.getAttribute( "same" ) = "clone" Then
				a_dic.Remove  file_path
			End If
		Next
	Next

	For Each  tag  In clone_tags.Items
		path = tag.getAttribute( "path" )
		Set all_both_dic( path ) = tag
		Set all_work_dic( path ) = tag
		Set all_base_dic( path ) = tag
	Next


	'// Set "all_both_dic", "all_work_dic", "all_base_dic" as "dictionary" of "IXMLDOMElement"
	'// Step 3. キー（ファイルパス）でソートする

	ShakerSortDicByKeyCompare  all_both_dic, GetRef( "PathCompare" ), Empty
	ShakerSortDicByKeyCompare  all_work_dic, GetRef( "PathCompare" ), Empty
	ShakerSortDicByKeyCompare  all_base_dic, GetRef( "PathCompare" ), Empty


	'// ...
	a_sync_set.Files.ToEmpty
	file_num = 0
	Set work_step_path_dic = CreateObject( "Scripting.Dictionary" )


	For Each file_step_path  In all_both_dic.Keys
	'// ◆ ここでのファイル一覧は、base にあるファイルの ABC 順と、それに続いて
	'//    work にあるファイルの ABC 順にソートされます。
	'//    file.WorkStepPath の ABC順にソートされません。
	'//    Me.OpenCUI() では、ABC順にソートされます。

		work_file_step_path = Empty
		base_file_step_path = Empty
		If all_work_dic.Exists( file_step_path ) Then
			Set tag = all_work_dic( file_step_path )
			work_file_step_path = file_step_path
		Else
			Set tag = all_base_dic( file_step_path )
			base_file_step_path = file_step_path
		End If


		Set file = new SyncFilesX_FileClass

		If tag.tagName = "File" Then
			file.WorkStepPath = tag.getAttribute( "path" )
			file.BaseStepPath = tag.getAttribute( "base" )
			If IsNull( file.BaseStepPath ) Then
				file.BaseStepPath = file.WorkStepPath
			End If
		Else
			Assert  tag.tagName = "Folder"

			base_folder_step_path = tag.getAttribute( "base" )
			If IsNull( base_folder_step_path ) Then
				file.BaseStepPath = file_step_path
				file.WorkStepPath = file_step_path
			Else
				work_folder_step_path = tag.getAttribute( "path" )

				If not IsEmpty( work_file_step_path ) Then
					Assert  StrCompHeadOf( work_file_step_path, _
						work_folder_step_path, Empty ) = 0

					file.BaseStepPath = base_folder_step_path + _
						Mid( work_file_step_path, Len( work_folder_step_path ) + 1 )
					file.WorkStepPath = work_file_step_path
				Else
					Assert  StrCompHeadOf( base_file_step_path, _
						base_folder_step_path, Empty ) = 0

					file.BaseStepPath = base_file_step_path
					file.WorkStepPath = work_folder_step_path + _
						Mid( base_file_step_path, Len( base_folder_step_path ) + 1 )
				End If
			End If
		End If

		If not work_step_path_dic.Exists( file.WorkStepPath ) Then

			Set work_step_path_dic( file.WorkStepPath ) = file

			file.Relation = tag.getAttribute( "same" )
			If IsNull( file.Relation ) Then
				file.Relation = "SameOrNotSame"
			ElseIf file.Relation = "yes" Then
				file.Relation = "Same"
			ElseIf file.Relation = "no" Then
				file.Relation = "NotSame"
			ElseIf file.Relation = "clone" Then
				file.Relation = "Clone"
			Else
				file.Relation = "SameOrNotSame"
			End If

			file.Caption            = g_fs.GetFileName( file.WorkStepPath )
			file.NewBaseFullPath    = GetFullPath( file.BaseStepPath, a_sync_set.NewBaseRootFullPath )
			file.NewWorkFullPath    = GetFullPath( file.WorkStepPath, a_sync_set.NewWorkRootFullPath )
			file.OldBaseFullPath    = GetFullPath( file.BaseStepPath, a_sync_set.OldBaseRootFullPath )
			file.OldWorkFullPath    = GetFullPath( file.WorkStepPath, a_sync_set.OldWorkRootFullPath )
			Set file.IsSameFunction = Me.IsSameFunction


			'// Echo
			file_num = file_num + 1
			file.Scan
			echo  file_num & ". "+ file.GetStateMark() +" "+ file.WorkStepPath
		End If
	Next

	ShakerSortDicByKeyCompare  work_step_path_dic,  GetRef( "PathCompare" ), Empty
	For Each  file  In work_step_path_dic.Items
		a_sync_set.Files.Add  file
	Next
End Sub


 
'*************************************************************************
'  <<< [SyncFilesX_Class::GetIsAllSynchronized] >>> 
'*************************************************************************
Public Function  GetIsAllSynchronized()
	For Each  root  In Me.Sets.Items
		For Each  file  In root.Files.Items
			If not file.IsSynced Then
				GetIsAllSynchronized = False
				Exit Function
			End If
		Next
	Next
	GetIsAllSynchronized = True
End Function


 
'*************************************************************************
'  <<< [SyncFilesX_Class::OpenCUI] >>> 
'*************************************************************************
Public Function  OpenCUI()

	current_root = Empty
	is_all_files = False

	Do
		'// Set "current_root" as "SyncFilesX_SetClass"
		If IsEmpty( current_root ) Then
			If Me.Sets.Count = 1 Then
				Set current_root = Me.Sets(0)
			Else
				Do
					echo_line
					root_num = 0
					For Each  a_sync_set  In Me.Sets.Items
						root_num = root_num + 1
						echo  root_num & ". " & a_sync_set.GetIsAllSyncedMark()
						echo  "■ベース（"+ a_sync_set.BaseName +"）: """+ _
							a_sync_set.NewBaseRootStepPath +""""
						echo  "■ワーク（"+ a_sync_set.WorkName +"）: """+ _
							a_sync_set.NewWorkRootStepPath +""""
					Next
					echo  ""
					echo  "91. 再スキャンする"
					echo  "93. すべてのワークファイルの一覧をファイルに出力する"
					echo  "99. 終了"
					key = CInt2( Input( "同期するセットの番号 >" ) )
					If key >= 1  and  key <= Me.Sets.Count Then
						Set current_root = Me.Sets( key - 1 )
						Exit Do
					ElseIf key = 91 Then
						OpenCUI = "Rescan"
						For i=1 To 10 : echo  "" : Next
						Exit Function
					ElseIf key = 98 Then
						default_file_name = "_SyncFiles.txt"
						echo  "Enterのみ: (デスクトップ)\"+ default_file_name
						list_path = Input( "出力先のファイルのパス（★上書きします）>" )
						If list_path = "" Then  list_path = _
							g_sh.SpecialFolders( "Desktop" ) +"\"+ default_file_name
						echo_line
						Set out_file = OpenForWrite( list_path, Empty )

						For Each  a_sync_set  In Me.Sets.Items  '// as SyncFilesX_SetClass
							For Each  file  In a_sync_set.Files.Items  '// as SyncFilesX_FileClass
								out_file.WriteLine  file.NewWorkFullPath
							Next
						Next
						out_file = Empty

					ElseIf key = 99 Then
						echo_line
						OpenCUI = "Exit"
						Exit Function
					Else
						echo  "Error"
					End If
				Loop
			End If
		End If


		'// Set "not_synced_files" as "ArrayClass" of "SyncFilesX_FileClass"
		Set not_synced_files = new ArrayClass
		For Each  file  In current_root.Files.Items
			If not file.IsSynced  or  is_all_files Then
				not_synced_files.Add  file
			End If
		Next


		'// Select a file
		echo_line
		echo  Me.SettingFolderFullPath
		echo  "前回コミット時のベース: """+ current_root.OldBaseRootStepPath +""""
		echo  "前回コミット時のワーク: """+ current_root.OldWorkRootStepPath +""""
		echo  "*:同期されていないファイル、=:未同期でペースとワークの内容が同じ"
		echo_line
		echo  "■ベース（"+ current_root.BaseName +"）: """+ current_root.NewBaseRootStepPath +""""
		echo  "■ワーク（"+ current_root.WorkName +"）: """+ current_root.NewWorkRootStepPath +""""

		is_auto_commit = False
		file_num = 0
		file_num_max = 89
		For Each  file  In not_synced_files.Items
			file_num = file_num + 1
			If file.IsAbleToAutoCommit Then _
				is_auto_commit = True
			echo  file_num & ". "+ file.GetStateMark() +" "+ file.WorkStepPath + file.GetCloneMark()
			If file_num = file_num_max Then
				echo  "（以下略）"
				Exit For
			End If
		Next
		If not_synced_files.Count = 0 Then
			echo  "（なし）"
		End If
		echo  ""
		echo  "91. 再スキャンする"
		echo  "92. ルート・フォルダーを開く"
		If not_synced_files.Count = 0 Then
			echo  "97. すべてのファイルを表示する"
		End If
		If is_auto_commit Then
			echo  "98. ベースとワークが同じファイルをすべてコミットする"
		End IF
		If Me.Sets.Count = 1 Then
			echo  "99. 終了"
		Else
			echo  "99. 戻る"
		End If
		key = CInt2( Input( "番号 >" ) )

		If key >= 1  and  key <= not_synced_files.Count  and  key <= file_num_max  Then
			echo_line
			Me.OpenFileCUI  current_root, not_synced_files( key - 1 )
		ElseIf key = 91 Then
			Me.LoadScanListUp_Sub  current_root
		ElseIf key = 92 Then
			Do
				echo_line
				echo  "1. ベース（"+ current_root.BaseName +"）: """+ _
					current_root.NewBaseRootStepPath +""""
				echo  "2. ワーク（"+ current_root.WorkName +"）: """+ _
					current_root.NewWorkRootStepPath +""""
				echo  "3. 設定ファイルがあるフォルダー"
				echo  "4. 前回コミット時のベース"
				echo  "5. 前回コミット時のワーク"
				echo  "9 または Enter : 戻る"
				key = CInt2( Input( "どのルート・フォルダーを開きますか >" ) )

				If key = 1 Then
					echo_line
					Setting_openFolder  current_root.NewBaseRootFullPath
				ElseIf key = 2 Then
					echo_line
					Setting_openFolder  current_root.NewWorkRootFullPath
				ElseIf key = 3 Then
					echo_line
					Setting_openFolder  Me.SettingFolderFullPath
				ElseIf key = 4 Then
					echo_line
					Setting_openFolder  current_root.OldBaseRootFullPath
				ElseIf key = 5 Then
					echo_line
					Setting_openFolder  current_root.OldWorkRootFullPath
				ElseIf key = 9  or  key = 0 Then
					Exit Do
				End If
			Loop
		ElseIf key = 97 Then
			is_all_files = not is_all_files
		ElseIf key = 98 Then
			echo  ""
			For Each  file  In not_synced_files.Items
				If file.IsAbleToAutoCommit Then _
					echo  file.GetStateMark() +" "+ file.WorkStepPath
			Next
			key = Input( "以上のファイルをすべてコミットしますか(y/n)" )
			If key = "Y" or key = "y" Then
				echo_line
				For Each  file  In not_synced_files.Items
					If file.IsAbleToAutoCommit Then _
						file.Commit
				Next
			End If
		ElseIf key = 99 Then
			If Me.Sets.Count = 1 Then
				OpenCUI = "Exit"
				Exit Function
			Else
				current_root = Empty
			End If
		End If
	Loop
End Function


 
'*************************************************************************
'  <<< [SyncFilesX_Class::OpenFileCUI] >>> 
'*************************************************************************
Sub  OpenFileCUI( a_Set, File ) '// File as SyncFilesX_FileClass
	is_commit = False
	Do
		echo  "ベース："""+ File.NewBaseFullPath +""""
		echo  "ワーク："""+ File.NewWorkFullPath +""""
		echo  File.GetGuideA()
		If is_commit Then
			echo  "コミットしました。"
			is_commit = False
		Else
			echo  "手動で同期したら、コミットしてください。"
		End If
		echo_line

		File.Scan

		echo  "★ベース（"+ a_Set.BaseName +"）: "+ File.BaseStepPath +" ("+ File.c.ToStr( File.BaseState ) +")"
		echo  "★ワーク（"+ a_Set.WorkName +"）: "+ File.WorkStepPath +" ("+ File.c.ToStr( File.WorkState ) +")"
		echo  ""
		echo  "1. Diff で開く：同期する"+ File.GetTypeName() +" ("+ GetEqualString( File.IsNewSame ) +_
			") [ ベース / ワーク ]"
		echo  "2. Diff で開く：前回の同期 ("+ GetEqualString( File.IsOldSame ) +_
			") [ ベース / ワーク ]"
		echo  "4. Diff で開く：ベース ("+ File.c.ToStr( File.BaseState ) +") [ 前回コミット時 / 現在 ]"
		echo  "5. Diff で開く：ワーク ("+ File.c.ToStr( File.WorkState ) +") [ 前回コミット時 / 現在 ]"
		echo  "44.Diff で開く：[ 前回コミット時のベース / ベース / ワーク ]"
		echo  "55.Diff で開く：[ ベース / ワーク / 前回コミット時のワーク ]"
		If File.Relation = "Clone" Then
			echo  "6. フォルダーを開く"
		Else
			echo  "6. ファイルまたはフォルダーを開く"
		End If
		echo  "Enterのみ: 再スキャンする"
		echo  "8. 同期をコミットする"
		echo  "9. 戻る"
		key = CInt2( Input( "番号 >" ) )

		If key = 1 Then
			echo_line
			start  GetDiffCmdLine( File.NewBaseFullPath, File.NewWorkFullPath )
		ElseIf key = 2 Then
			echo_line
			start  GetDiffCmdLine( File.OldBaseFullPath, File.OldWorkFullPath )
		ElseIf key = 4 Then
			echo_line
			start  GetDiffCmdLine( File.OldBaseFullPath, File.NewBaseFullPath )
		ElseIf key = 5 Then
			echo_line
			start  GetDiffCmdLine( File.OldWorkFullPath, File.NewWorkFullPath )
		ElseIf key = 44 Then
			echo_line
			start  GetDiffCmdLine3( File.OldBaseFullPath, File.NewBaseFullPath, File.NewWorkFullPath )
		ElseIf key = 55 Then
			echo_line
			start  GetDiffCmdLine3( File.NewBaseFullPath, File.NewWorkFullPath, File.OldWorkFullPath )
		ElseIf key = 6 Then
			Do
				echo_line
				echo  File.WorkStepPath
				echo  File.GetGuideA()
				echo  "  > ベース ("+ File.c.ToStr( File.BaseState ) +")："+ a_Set.BaseName
				echo  "  > ワーク ("+ File.c.ToStr( File.WorkState ) +")："+ a_Set.WorkName
				If File.Relation = "Clone" Then
					echo  "1. ベース・フォルダーを開く"
					echo  "2. ワーク・フォルダーを開く"
					echo  "4. 前回コミット時のベース・フォルダーを開く"
					echo  "5. 前回コミット時のワーク・フォルダーを開く"
				Else
					echo  "1. ベース / ファイルを開く"
					echo  "11.       / フォルダーを開く"
					echo  "2. ワーク / ファイルを開く"
					echo  "22.       / フォルダーを開く"
					echo  "4. 前回コミット時のベース / ファイルを開く"
					echo  "44.                       / フォルダーを開く"
					echo  "5. 前回コミット時のワーク / ファイルを開く"
					echo  "55.                       / フォルダーを開く"
				End If
				echo  "9 または Enter: 戻る"
				key = CInt2( Input( "番号 >" ) )
				echo_line

				edit_path = Empty
				folder_path = Empty
				If key = 1 Then
					edit_path = File.NewBaseFullPath
				ElseIf key = 11 Then
					folder_path = File.NewBaseFullPath
				ElseIf key = 2 Then
					edit_path = File.NewWorkFullPath
				ElseIf key = 22 Then
					folder_path = File.NewWorkFullPath
				ElseIf key = 4 Then
					edit_path = File.OldBaseFullPath
				ElseIf key = 44 Then
					folder_path = File.OldBaseFullPath
				ElseIf key = 5 Then
					edit_path = File.OldWorkFullPath
				ElseIf key = 55 Then
					folder_path = File.OldWorkFullPath
				ElseIf key = 9  or  key = 0 Then
					Exit Do
				End If

				If File.Relation = "Clone"  and  not IsEmpty( edit_path ) Then
					folder_path = edit_path
					edit_path = Empty
				End If

				If not IsEmpty( edit_path ) Then
					start  GetEditorCmdLine( edit_path )
				ElseIf not IsEmpty( folder_path ) Then
					parent_path = g_fs.GetParentFolderName( folder_path )
					If not exist( parent_path ) Then
						echo  """"+ parent_path +""""
						key = Input( "上記フォルダーが存在しません。作成しますか(y/n)" )
						If key = "Y" or key = "y" Then _
							mkdir  parent_path
					End If
					If exist( parent_path ) Then
						If exist( folder_path ) Then
							Setting_openFolder  folder_path
						Else
							Setting_openFolder  parent_path
						End If
					End If
				End If
			Loop
		ElseIf key = 8 Then
			warning_ = Empty
			If File.Relation = "SameOrNotSame" Then
				If not exist( File.OldWorkFullPath )  and  not exist( File.OldBaseFullPath ) Then
				ElseIf File.IsSameFunction( File.OldWorkFullPath, File.OldBaseFullPath ) Then
					If not exist( File.NewWorkFullPath )  and  not exist( File.NewBaseFullPath ) Then
					ElseIf not File.IsSameFunction( File.NewWorkFullPath, File.NewBaseFullPath ) Then
						warning_ = "★[WARNING] ベースとワークで内容が同じだったのが異なるようになりました。"
					End If
				Else
					If not exist( File.NewWorkFullPath )  and  not exist( File.NewBaseFullPath ) Then
					ElseIf File.IsSameFunction( File.NewWorkFullPath, File.NewBaseFullPath ) Then
						warning_ = "★[WARNING] ベースとワークで内容が異なっていたのが同じになりました。"
					End If
				End If
			ElseIf File.Relation = "NotSame" Then
				If File.IsSameFunction( File.NewWorkFullPath, File.NewBaseFullPath ) Then
					warning_ = "★[WARNING] ベースとワークで内容が同じになってしまっています。"
				End If
			Else
				If not File.IsSameFunction( File.NewWorkFullPath, File.NewBaseFullPath ) Then
					warning_ = "★[WARNING] ベースとワークで内容が異なります。"
				End If
			End If
			If not IsEmpty( warning_ ) Then
				echo  ""
				echo  warning_
				echo  ""
			End If

			key = "Y"
			If not IsEmpty( warning_ ) Then
				Do
					key = Input( "警告がありましたが、よろしいですか(y/n)" )
					If key = "Y"  or  key = "y"  or  key = "N"  or  key = "n" Then
						Exit Do
					End If
				Loop
			End If

			If key = "Y" or key = "y" Then
				echo_line

				File.Commit
				echo  "コミットしました。"
				is_commit = True
			End If
		ElseIf key = 0 Then
			'// 再スキャンは、メニューを表示するときに行う
		ElseIf key = 9 Then
			Exit Do
		End If
		echo_line
	Loop
End Sub


 
'*************************************************************************
'  <<< [SyncFilesX_Class::GetWritableFolders] >>> 
'*************************************************************************
Function  GetWritableFolders()
	Set arr = new ArrayClass

	For Each  root_folder  In Me.Sets.Items
		arr.Add  root_folder.OldWorkRootFullPath
		arr.Add  root_folder.OldBaseRootFullPath
	Next

	GetWritableFolders = arr.Items
End Function


 
' ### <<<< End of Class implement >>>> 
End Class


 
'*************************************************************************
'  <<< [SyncFilesX_SetClass] >>> 
'*************************************************************************
Class  SyncFilesX_SetClass
	Public  SetTag

	Public  BaseName
	Public  WorkName

	Public  NewBaseRootStepPath
	Public  NewWorkRootStepPath
	Public  OldBaseRootStepPath  '// old = synchronized before
	Public  OldWorkRootStepPath

	Public  NewBaseRootFullPath
	Public  NewWorkRootFullPath
	Public  OldBaseRootFullPath  '// old = synchronized before
	Public  OldWorkRootFullPath

	Public  Files        '// as ArrayClass of SyncFilesX_FileClass
	Public  PathXML_Dic  '// as dictionary of IXMLDOMElement, key=SyncFilesX_FileClass::WorkStepPath

	Private Sub  Class_Initialize()
		Set Me.Files = new ArrayClass

		Const  NotCaseSensitive = 1
		Set Me.PathXML_Dic = CreateObject( "Scripting.Dictionary" )
		Me.PathXML_Dic.CompareMode = NotCaseSensitive
	End Sub

	Public Function  GetIsAllSynced()
		GetIsAllSynced = True
		For Each  file  In Me.Files.Items
			If not file.IsSynced Then
				GetIsAllSynced = False
				Exit Function
			End If
		Next
	End Function

	Public Function  GetIsAllSyncedMark()
		If Me.GetIsAllSynced() Then
			GetIsAllSyncedMark = ""
		Else
			GetIsAllSyncedMark = "*"
		End If
	End Function


 
' ### <<<< End of Class implement >>>> 
End Class


 
'*************************************************************************
'  <<< [SyncFilesX_FileClass] >>> 
'*************************************************************************
Class  SyncFilesX_FileClass
	Public  BaseStepPath
	Public  WorkStepPath

	Public  NewBaseFullPath
	Public  NewWorkFullPath
	Public  OldBaseFullPath  '// old = synchronized before
	Public  OldWorkFullPath

	Public  Caption
	Public  Relation  '// "SameOrNotSame", "Same", "NotSame", "Clone"
		'// "Clone"= フォルダーの中のすべてのファイルが "Same"

	Public  IsNewSame  '// IsSameFunction( NewWorkFullPath, NewBaseFullPath )
	Public  IsOldSame  '// IsSameFunction( OldWorkFullPath, OldBaseFullPath )
	Public  BaseState  '// Me.c ( Same, Changed, New_, NotExist, Deleted )
	Public  WorkState  '// Me.c ( Same, Changed, New_, NotExist, Deleted )

	Public  IsSynced  '// IsBaseSynced and IsWorkSynced
	Public  IsBaseSynced  '// NewBase = OldBase
	Public  IsWorkSynced  '// NewWork = OldWork
	Public  IsAbleToAutoCommit

	Public  IsSameFunction

	Public  c  '// as SyncFilesX_FileClassConsts

	Private Sub  Class_Initialize()
		Set c = get_SyncFilesX_FileClassConsts()
		Set Me.IsSameFunction   = GetRef( "SyncFilesX_FileClass_isSameDefault" )
	End Sub


	Sub  Scan()
		Set file = Me

		If exist( file.NewBaseFullPath )  or  exist( file.NewWorkFullPath ) Then
			file.IsNewSame = Me.IsSameFunction( file.NewBaseFullPath, file.NewWorkFullPath )
		Else
			file.IsNewSame = Empty
		End If

		If exist( file.OldBaseFullPath )  or  exist( file.OldWorkFullPath ) Then
			file.IsOldSame = Me.IsSameFunction( file.OldBaseFullPath, file.OldWorkFullPath )
		Else
			file.IsOldSame = Empty
		End If

		file.IsBaseSynced = Me.IsSameFunction( file.NewBaseFullPath, file.OldBaseFullPath )
		file.IsWorkSynced = Me.IsSameFunction( file.NewWorkFullPath, file.OldWorkFullPath )

		file.IsSynced = file.IsWorkSynced  and  file.IsBaseSynced

		If exist( file.NewWorkFullPath ) Then
			If exist( file.OldWorkFullPath ) Then
				If file.IsWorkSynced Then
					file.WorkState = Me.c.Same
				Else
					file.WorkState = Me.c.Changed
				End If
			Else
				file.WorkState = Me.c.New_
			End If
		Else
			If exist( file.OldWorkFullPath ) Then
				file.WorkState = Me.c.Deleted
			Else
				file.WorkState = Me.c.NotExist
			End If
		End If

		If exist( file.NewBaseFullPath ) Then
			If exist( file.OldBaseFullPath ) Then
				If file.IsBaseSynced Then
					file.BaseState = Me.c.Same
				Else
					file.BaseState = Me.c.Changed
				End If
			Else
				file.BaseState = Me.c.New_
			End If
		Else
			If exist( file.OldBaseFullPath ) Then
				file.BaseState = Me.c.Deleted
			Else
				file.BaseState = Me.c.NotExist
			End If
		End If

		file.IsAbleToAutoCommit = not file.IsSynced  and _
			( file.IsNewSame or IsEmpty( file.IsNewSame ) )
	End Sub

	Sub  Commit()
		Set file = Me

		If exist( file.NewWorkFullPath ) Then
			copy_ren  file.NewWorkFullPath, file.OldWorkFullPath
		Else
			del  file.OldWorkFullPath
		End If

		If exist( file.NewBaseFullPath ) Then
			copy_ren  file.NewBaseFullPath, file.OldBaseFullPath
		Else
			del  file.OldBaseFullPath
		End If

		file.Scan
	End Sub

	Function  GetStateMark()
		Set file = Me
		GetStateMark = Left( file.c.ToStr( file.BaseState ), 1 ) + _
			Left( GetEqualString( file.IsNewSame ), 1 ) + _
			Left( file.c.ToStr( file.WorkState ), 1 )
	End Function

	Function  GetCloneMark()
		If Me.Relation = "Clone" Then
			GetCloneMark = "\"
		Else
			GetCloneMark = ""
		End If
	End Function

	Function  GetTypeName()
		If Me.Relation = "Clone" Then
			GetTypeName = "フォルダー"
		Else
			GetTypeName = "ファイル"
		End If
	End Function

	Function  GetGuideA()
		type_name = Me.GetTypeName()

		If Me.Relation = "SameOrNotSame" Then
			If IsEmpty( Me.IsOldSame ) Then
				GetGuideA = ""
			ElseIf Me.IsOldSame Then
				GetGuideA = "ベース・"+ type_name +"とワーク・"+ type_name +_
					"は「同じ内容」でした"
			Else
				GetGuideA = "ベース・"+ type_name +"とワーク・"+ type_name +_
					"は「異なる内容」でした"
			End If
		ElseIf Me.Relation = "NotSame" Then
			GetGuideA = "ベース・"+ type_name +"とワーク・"+ type_name +_
				"は「ほぼ」同じ内容になるべきとのことです"
		Else
			If Me.IsNewSame  or  IsEmpty( Me.IsNewSame ) Then
				GetGuideA = "ベース・"+ type_name +"とワーク・"+ type_name +_
					"は「同じ内容」です"
			Else
				GetGuideA = "ベース・"+ type_name +"とワーク・"+ type_name +_
					"が「同じ内容」になるべきとのことです"
			End If
		End If
	End Function
 
' ### <<<< End of Class implement >>>> 
End Class


 
'*************************************************************************
'  <<< [SyncFilesX_FileClass_isSameDefault] >>> 
'*************************************************************************
Function  SyncFilesX_FileClass_isSameDefault( FileOrFolderA_Path, FileOrFolderB_Path )
	Set ec = new EchoOff
	SyncFilesX_FileClass_isSameDefault = _
		IsSameFolder( FileOrFolderA_Path, FileOrFolderB_Path, Empty )
End Function


 
'*************************************************************************
'  <<< [GetEqualString] >>> 
'*************************************************************************
Function  GetEqualString( IsSame )
	If IsEmpty( IsSame ) Then
		GetEqualString = " なし"
	ElseIf IsSame Then
		GetEqualString = "=同じ"
	Else
		GetEqualString = "!異なる"
	End If
End Function


 
'********************************************************************************
'  <<< [get_SyncFilesX_FileClassConsts] >>>
'********************************************************************************
Dim  g_SyncFilesX_FileClassConsts

Function  get_SyncFilesX_FileClassConsts()
	If IsEmpty( g_SyncFilesX_FileClassConsts ) Then _
		Set g_SyncFilesX_FileClassConsts = new SyncFilesX_FileClassConsts
	Set get_SyncFilesX_FileClassConsts = g_SyncFilesX_FileClassConsts
End Function


Class  SyncFilesX_FileClassConsts
	Public  Same, Changed, New_, NotExist, Deleted

	Private Sub  Class_Initialize()
		Same     = 1
		Changed  = 2
		New_     = 3
		NotExist = 4
		Deleted  = 5
	End Sub

	Public Function  ToStr( Number )
		Select Case  Number
			Case Same     : ToStr = ".不変"
			Case Changed  : ToStr = "*変更"
			Case New_     : ToStr = "+新規"
			Case NotExist : ToStr = " なし"
			Case Deleted  : ToStr = "-削除"
		End Select
	End Function
End Class


 
'*************************************************************************
'  <<< [new_ReplaceTemplateClass] >>> 
'*************************************************************************
Function  new_ReplaceTemplateClass( path_of_XML )
	Set Me_ = new ReplaceTemplateClass
	Set Me_.Files = new MultiTextXML_Class
	Set xml_root = LoadXML_Cached( path_of_XML, Empty )

	Set Me_.TargetFolders = new_PathDictionaryClass_fromXML( _
		xml_root.selectNodes( "Target" ), _
		"path",  GetParentFullPath( path_of_XML ) )

	Me_.EnabledTemplateIDs = ArrayFromLines( Trim2( xml_root.selectSingleNode( _
		"./EnabledTemplateIDs/text()" ).nodeValue ) )

	'// Set "Me_.EnabledTemplates", ...
	ReDim  template_array( UBound( Me_.EnabledTemplateIDs ) )
	ReDim  keyword_array(  UBound( Me_.EnabledTemplateIDs ) )
	For index = 0  To UBound( Me_.EnabledTemplateIDs )
		template_array( index ) = Me_.Files.GetText( path_of_XML + _
			Me_.EnabledTemplateIDs( index ) )
		keyword_array( index ) = Me_.Files.GetText( path_of_XML + _
			Me_.EnabledTemplateIDs( index ) +"_Keyword" )
		CutLastOf  keyword_array( index ), vbCRLF, Empty
	Next
	Me_.EnabledTemplates = template_array
	Me_.EnabledTemplateKeywords = keyword_array


	'// ...
	Me_.CheckTargetDefault = Trim2( xml_root.selectSingleNode( _
		"./CheckTargetDefault/text()" ).nodeValue )
	Me_.ReplaceTemplateID_From = Trim2( xml_root.selectSingleNode( _
		"./ReplaceTemplateID_From/text()" ).nodeValue )

	path = path_of_XML + Me_.ReplaceTemplateID_From
	If Me_.Files.IsExist( path ) Then
		Me_.ReplaceTemplate_From = Me_.Files.GetText( path )

		a_str = Me_.Files.GetText( _
			path_of_XML + Me_.ReplaceTemplateID_From + "_Keyword" )
		CutLastOf  a_str, vbCRLF, Empty
		Me_.ReplaceTemplateKeyword_From = a_str
	Else
		Me_.ReplaceTemplate_From = Empty
		Me_.ReplaceTemplateKeyword_From = Empty
	End If


	Me_.ReplaceTemplateID_To = Trim2( xml_root.selectSingleNode( _
		"./ReplaceTemplateID_To/text()" ).nodeValue )
	Me_.ReplaceTemplateIndex_To = SearchInSimpleArray( _
		Me_.ReplaceTemplateID_To,  Me_.EnabledTemplateIDs,  0,  Empty )

	Set new_ReplaceTemplateClass = Me_
End Function


'//[ReplaceTemplateClass]
Class  ReplaceTemplateClass
	Public  Files
	Public  TargetFolders

	Public  EnabledTemplateIDs
	Public  EnabledTemplateKeywords
	Public  EnabledTemplates

	Public  CheckTargetDefault

	Public  ReplaceTemplateID_From
	Public  ReplaceTemplate_From
	Public  ReplaceTemplateKeyword_From

	Public  ReplaceTemplateID_To
	Public  ReplaceTemplateIndex_To


'//[ReplaceTemplateClass::EchoOld]
Sub  EchoOld()
	echo  "以下の場所にあるテンプレートがマッチしませんでした。"
	echo  "Template_getDifference コマンドで、違いがある場所の行番号を調べられます。"
	echo_line
	For Each  folder  In Me.TargetFolders.FilePaths
		For index = 0  To UBound( Me.EnabledTemplates )
			Set ec = new EchoOff
			founds = SearchStringTemplate( folder, _
				Me.EnabledTemplateKeywords( index ), _
				Me.EnabledTemplates( index ),  Empty )
			ec = Empty

			For Each  found  In founds( UBound( founds ) )
				found.CalcLineCount
				echo  found.Path &"("& found.LineNum &")"
			Next
		Next
	Next
End Sub


'//[ReplaceTemplateClass::RunGetDifference]
Sub  RunGetDifference()
	Set c = g_VBS_Lib

	echo  ""
	echo  "Enterのみ："""+ Me.CheckTargetDefault +""""
	target_path = InputPath( "調べるファイルのパス >", c.CheckFileExists or c.AllowEnterOnly )
	If target_path = "" Then  target_path = Me.CheckTargetDefault

	echo  "以下の場所にあるテンプレートがマッチしませんでした。"
	echo_line

	target_text = ReadFile( target_path )
	For index = 0  To UBound( Me.EnabledTemplates )
		line_num = GetLineNumOfTemplateDifference( target_text, _
			Me.EnabledTemplateKeywords( index ), _
			Me.EnabledTemplates( index ) )
		If line_num <> 0 Then
			echo  target_path &"("& line_num &")"
		End If
	Next
End Sub


'//[ReplaceTemplateClass::RunReplace]
Sub  RunReplace()
	echo  "以下の場所にあるファイルの中にあるテンプレートを置き換えます"
	echo  "編集するフォルダー = "+ GetEchoStr( Me.TargetFolders )
	echo  "ReplaceTemplateID_From = "+ Me.ReplaceTemplateID_From
	echo  "ReplaceTemplateID_To = "  + Me.ReplaceTemplateID_To

	If IsEmpty( Me.ReplaceTemplate_From ) Then
		Raise  1, "ReplaceTemplateID_From に指定した id が存在しません"
	End If
	If IsEmpty( Me.ReplaceTemplateIndex_To ) Then
		Raise  1, "ReplaceTemplateID_To に指定した id が存在しないか、"+_
			"現在使われているテンプレートではありません"
	End If

	Pause
	echo_line

	For Each  folder  In Me.TargetFolders.FilePaths
		ReplaceStringTemplate  folder, _
			Me.ReplaceTemplateKeyword_From, _
			Me.ReplaceTemplate_From, _
			Me.EnabledTemplates( Me.ReplaceTemplateIndex_To ), _
			Empty
	Next
End Sub


End Class


 
