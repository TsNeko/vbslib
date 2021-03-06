'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************


'***********************************************************************
'* Constants: error code in SyncFilesMenuLib.vbs
'*
'*    : E_ModuleAssort_NotFullPackage - 321
'*    : E_ModuleAssort_WorkingYet     - 322
'***********************************************************************
Dim E_ModuleAssort_NotFullPackage : E_ModuleAssort_NotFullPackage = 321
Dim E_ModuleAssort_WorkingYet     : E_ModuleAssort_WorkingYet     = 322


 
'***********************************************************************
'* Class: SyncFilesMenu
'***********************************************************************
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

	'***********************************************************************
	'* Method: AddRootFolder
	'*
	'* Name Space:
	'*    SyncFilesMenu::AddRootFolder
	'***********************************************************************
	Public Function  AddRootFolder( IndexNum, RootFolderPath )
		Dim  o : Set o = new SyncFilesRoot

		o.AbsPath = GetFullPath( RootFolderPath, Empty )
		Set  o.Files = new ArrayClass
		Set  o.IsSameFolderAsBinary = new ArrayClass

		If IndexNum > Me.RootFolders.UBound_ Then  Me.RootFolders.ReDim_  IndexNum
		Set Me.RootFolders( IndexNum ) = o
		Set AddRootFolder = o
	End Function

	'***********************************************************************
	'* Method: AddFile
	'*
	'* Name Space:
	'*    SyncFilesMenu::AddFile
	'***********************************************************************
	Public Sub  AddFile( StepPath )
		AddFileWithLabel  Empty, StepPath
	End Sub

	'***********************************************************************
	'* Method: AddFileWithLabel
	'*
	'* Name Space:
	'*    SyncFilesMenu::AddFileWithLabel
	'***********************************************************************
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

	'***********************************************************************
	'* Method: Compare
	'*
	'* Name Space:
	'*    SyncFilesMenu::Compare
	'***********************************************************************
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

	'***********************************************************************
	'* Method: Compare_sub
	'*
	'* Name Space:
	'*    SyncFilesMenu::Compare_sub
	'***********************************************************************
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

	'***********************************************************************
	'* Method: OpenSyncMenu
	'*
	'* Name Space:
	'*    SyncFilesMenu::OpenSyncMenu
	'***********************************************************************
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
			echo_line

			Me.Compare_sub  file_num, Me.RootFolders.UBound_
		Loop
	End Sub

	'***********************************************************************
	'* Method: IsSameFolder
	'*
	'* Name Space:
	'*    SyncFilesMenu::IsSameFolder
	'***********************************************************************
	Public Function  IsSameFolder( FolderA_IndexNum, FolderB_IndexNum )
		IsSameFolder = Me.RootFolders( FolderA_IndexNum ).IsSameFolderAsBinary( FolderB_IndexNum )
	End Function

	'***********************************************************************
	'* Method: SetParentFolderProxyName
	'*
	'* Name Space:
	'*    SyncFilesMenu::SetParentFolderProxyName
	'***********************************************************************
	Public Sub  SetParentFolderProxyName( IndexNum, Name )
		Me.RootFolders( IndexNum ).ParentFolderProxyName = Name
	End Sub
End Class


 
'***********************************************************************
'* Class: SyncFilesRoot
'***********************************************************************
Class  SyncFilesRoot
	Public  Label      '// as string
	Public  AbsPath    '// as string
	Public  ParentFolderProxyName  '// as string
	Public  Files      '// as SyncFilesFile<dic key="StepPath"/>
	Public  IsSameFolderAsBinary  '// as boolean<ArrayClass index_num="SyncFilesMenu::RootFolders"/>
End Class


 
'***********************************************************************
'* Class: SyncFilesFile
'***********************************************************************
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
	Set sync = new SyncFilesX_Class : ErrCheck

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
			local_writables = sync.GetWritableFolders()
			AddArrElem   local_writables, g_sh.SpecialFolders( "Desktop" )
			Set w_=AppKey.NewWritable( local_writables ).Enable()
			result = sync.OpenCUI()

			If result = "Exit" Then  Exit Do
		Loop
	End If
End Sub


 
'***********************************************************************
'* Class: SyncFilesX_Class
'***********************************************************************
Class  SyncFilesX_Class
	Public  SettingFileFullPath
	Public  SettingFolderFullPath
	Public  XML_String
	Public  Variables
	Public  UsedID
	Public  RestartVBS_FullPath
	Public  CleanRootFullPath

	Public  IsNextAutoSynchronize
	Public  IsNextAutoCommit
	Public  IsEnabledCommit
	Public  IsNextAutoMergeFromBase
	Public  IsNoCUI
	Public  IsMergeMode
	Public  IsForceThreeWayMerge

	Public  Sets  '// as ArrayClass of SyncFilesX_SetClass

	Public  IsSameFunction
	Public  CustomUpdateFunction
	Public  CustomUpdateFunctionParameter
	Public  CustomRestartCodeForRestartVBS
	Public  CustomUpdateCodeForRestartVBS

	Public  IsAttached
	Public  IsMerged
	Public  IsSkipIfAllSynchronized
	Public  BaseCaption
	Public  WorkCaption
	Public  SyncedBaseCaption
	Public  SyncedWorkCaption
	Public  CommittedCaption
	Public  NewCaption
	Public  OldCaption
	Public  CustomCaption
	Public  BaseIsWas

	Private Sub  Class_Initialize()
		Me.IsNextAutoSynchronize = False
		Me.IsNextAutoCommit = False
		Me.IsEnabledCommit = True
		Me.IsNextAutoMergeFromBase = False
		Me.IsNoCUI = False
		Me.IsMergeMode = False
		Me.IsForceThreeWayMerge = False
		Set Me.Sets = new ArrayClass
		Set Me.IsSameFunction = GetRef( "SyncFilesX_FileClass_isSameDefault" )
		Me.IsAttached = False
		Me.IsMerged = False
		Me.IsSkipIfAllSynchronized = False
		Me.BaseCaption = "ベース"
		Me.WorkCaption = "ワーク"
		Me.CommittedCaption = "前回コミット時"
		Me.NewCaption = "現在"
		Me.OldCaption = "同期"
		Me.CustomCaption = ""
		Me.BaseIsWas = "でした。"
	End Sub


 
'***********************************************************************
'* Method: Run
'*
'* Name Space:
'*    SyncFilesX_Class::Run
'***********************************************************************
Public Sub  Run( in_LeftLabel, in_RightLabel,  in_NewLeftPath, in_NewRightPath, in_OldLeftPath, in_OldRightPath )

	setting = _
		"<SyncFilesX>" +vbCRLF+ _
		"<SynchronizingSet" +vbCRLF+ _
		"    base_name="""+ CStr( in_LeftLabel ) +"""" +vbCRLF+ _
		"    work_name="""+ CStr( in_RightLabel ) +"""" +vbCRLF+ _
		"    base="""+ in_NewLeftPath  +"""" +vbCRLF+ _
		"    path="""+ in_NewRightPath +"""" +vbCRLF+ _
		"    synced_base="""+ in_OldLeftPath  +"""" +vbCRLF+ _
		"    synced_path="""+ in_OldRightPath +""">" +vbCRLF+ _
		"" +vbCRLF+ _
		"<File path="".""/>" +vbCRLF+ _
		"</SynchronizingSet>" +vbCRLF+ _
		"</SyncFilesX>" +vbCRLF
	Do
			Me.LoadScanListUpAll  g_sh.SpecialFolders( "Desktop" ) +"\_work", setting
			w_ = Empty
			local_writables = Me.GetWritableFolders()
			AddArrElem   local_writables, g_sh.SpecialFolders( "Desktop" )
			result = Me.OpenCUI()

			If result = "Exit" Then  Exit Do
	Loop
End Sub


 
'***********************************************************************
'* Method: LoadRootPaths
'*
'* Name Space:
'*    SyncFilesX_Class::LoadRootPaths
'***********************************************************************
Public Sub  LoadRootPaths( SettingFilePath, XML_String )
	Set root = LoadXML( XML_String, F_Str )
	Me.LoadRootXML_Sub  root, SettingFilePath, XML_String


	'// Set "sync_sets" : Parse <SynchronizingSet>
	Me.Sets.ToEmpty
	Set sync_sets = new ArrayClass

	For Each  root_folder_tag  In root.selectNodes( "./SynchronizingSet | ./ThreeWayMergeSet" )
		Set  a_sync_set = new SyncFilesX_SetClass
		sync_sets.Add  a_sync_set

		Set a_sync_set.SetTag = root_folder_tag
		Me.LoadScanListUpAll_SetPaths_Sub  a_sync_set
	Next


	'// Set "Me.Sets"
	For Each  a_sync_set  In sync_sets.Items
		Me.Sets.Add  a_sync_set
	Next
End Sub


 
'***********************************************************************
'* Method: LoadScanListUpAll
'*
'* Name Space:
'*    SyncFilesX_Class::LoadScanListUpAll
'***********************************************************************
Public Sub  LoadScanListUpAll( SettingFilePath, XML_String )
	Const  c_NotCaseSensitive = 1

	Set root = LoadXML( XML_String, F_Str )
	Me.LoadRootXML_Sub  root, SettingFilePath, XML_String

	echo  Me.SettingFileFullPath
	echo  ""
	echo  Me.OldCaption +"するファイルの一覧："
	echo  "  中央の記号の意味: [=]同じ [!]異なる [ ]両方不在"
	echo  "  左右の記号の意味: [*]変更 [+]追加 [-]削除 [.]不変 [ ]不在"
	echo  "  左は"+ Me.BaseCaption +"、右は"+ Me.WorkCaption
	echo  ""


	'// Set "sync_sets" : Parse <SynchronizingSet>
	Me.Sets.ToEmpty
	Set sync_sets = new ArrayClass

	For Each  root_folder_tag  In root.selectNodes( "./SynchronizingSet | ./ThreeWayMergeSet" )
		If IsEmpty( Me.UsedID ) Then
			is_used = True
		Else
			If Me.UsedID = root_folder_tag.getAttribute( "ID" ) Then
				is_used = True
			Else
				is_used = False
			End If
		End If

		If is_used Then
			Set  a_sync_set = new SyncFilesX_SetClass
			sync_sets.Add  a_sync_set

			Set a_sync_set.SetTag = root_folder_tag
			Me.LoadScanListUpAll_SetPaths_Sub  a_sync_set
		End If
	Next


	'// Parse <File>
	root_num = 0
	For Each  a_sync_set  In sync_sets.Items
		Me.Sets.Add  a_sync_set
		root_num = root_num + 1

		If sync_sets.Count = 1 Then
			a_string = ""
		Else
			a_string = root_num & "."
		End If
		If not IsEmpty( a_sync_set.ID_Label ) Then
			a_string = a_string +" ["+ a_sync_set.ID_Label +"]"
		End If

		If a_string <> "" Then _
			echo  a_string
		If not Me.IsMergeMode Then
			echo  "■"+ Me.BaseCaption +"（"+ a_sync_set.BaseName +"）: """+ a_sync_set.NewBaseRootStepPath +""""
			echo  "■"+ Me.WorkCaption +"（"+ a_sync_set.WorkName +"）: """+ a_sync_set.NewWorkRootStepPath +""""
		Else
			echo  "■"+ Me.SyncedWorkCaption +"（"+ a_sync_set.WorkName +"）: """+ a_sync_set.OldWorkRootStepPath +""""
			echo  "■"+ Me.BaseCaption       +"（"+ a_sync_set.BaseName +"）: """+ a_sync_set.NewBaseRootStepPath +""""
		End If

		Me.LoadScanListUp_Sub  a_sync_set

		echo  ""
	Next


	If Me.Sets.Count = 0 Then
		Raise  1, "<ERROR msg=""設定ファイルが見つからないか、SynchronizingSet タグによる設定がありません"+ _
			""" path="""+ Me.SettingFileFullPath +"""/>"
	End If
End Sub


 
'***********************************************************************
'* Method: LoadScanListUpAll_SetPaths_Sub
'*
'* Name Space:
'*    SyncFilesX_Class::LoadScanListUpAll_SetPaths_Sub
'***********************************************************************
Public Sub  LoadScanListUpAll_SetPaths_Sub( a_sync_set )
	Set root_folder_tag = a_sync_set.SetTag

	a_sync_set.ID_Label = Me.Variables( root_folder_tag.getAttribute( "ID" ) )

	value = Me.Variables( root_folder_tag.getAttribute( "base_name" ) )
	If IsEmpty( value ) Then
		a_sync_set.BaseName = Me.Variables( root_folder_tag.getAttribute( "right_name" ) )
	Else
		a_sync_set.BaseName = value
	End If

	value = Me.Variables( root_folder_tag.getAttribute( "work_name" ) )
	If IsEmpty( value ) Then
		a_sync_set.WorkName = Me.Variables( root_folder_tag.getAttribute( "left_name" ) )
	Else
		a_sync_set.WorkName = value
	End If


	base_value = root_folder_tag.getAttribute( "base" )
	Me.IsMergeMode = IsNull( base_value )
	If not Me.IsMergeMode Then
		a_sync_set.NewBaseRootStepPath = base_value
		a_sync_set.NewWorkRootStepPath = root_folder_tag.getAttribute( "path" )
		a_sync_set.OldBaseRootStepPath = root_folder_tag.getAttribute( "synced_base" )
		a_sync_set.OldWorkRootStepPath = root_folder_tag.getAttribute( "synced_path" )
		a_sync_set.CommittedWorkRootStepPath = Empty
	Else
		Me.BaseCaption = "右"
		Me.WorkCaption = "後"
		Me.SyncedBaseCaption = "前"
		Me.SyncedWorkCaption = "左"
		Me.CommittedCaption = "済"
		a_sync_set.OldBaseRootStepPath = root_folder_tag.getAttribute( "base_path" )
		a_sync_set.NewBaseRootStepPath = root_folder_tag.getAttribute( "right_path" )
		a_sync_set.OldWorkRootStepPath = root_folder_tag.getAttribute( "left_path" )
		a_sync_set.NewWorkRootStepPath = root_folder_tag.getAttribute( "merged_path" )
		a_sync_set.CommittedWorkRootStepPath = root_folder_tag.getAttribute( "committed_path" )
		If IsNull( a_sync_set.CommittedWorkRootStepPath ) Then _
			a_sync_set.CommittedWorkRootStepPath = Empty
	End If

	a_sync_set.NewBaseRootStepPath = Me.Variables( a_sync_set.NewBaseRootStepPath )
	a_sync_set.NewWorkRootStepPath = Me.Variables( a_sync_set.NewWorkRootStepPath )
	a_sync_set.OldBaseRootStepPath = Me.Variables( a_sync_set.OldBaseRootStepPath )
	a_sync_set.OldWorkRootStepPath = Me.Variables( a_sync_set.OldWorkRootStepPath )
	a_sync_set.CommittedWorkRootStepPath = Me.Variables( a_sync_set.CommittedWorkRootStepPath )

	a_sync_set.NewBaseRootFullPath = GetFullPath( a_sync_set.NewBaseRootStepPath, Me.SettingFolderFullPath )
	a_sync_set.NewWorkRootFullPath = GetFullPath( a_sync_set.NewWorkRootStepPath, Me.SettingFolderFullPath )
	a_sync_set.OldBaseRootFullPath = GetFullPath( a_sync_set.OldBaseRootStepPath, Me.SettingFolderFullPath )
	a_sync_set.OldWorkRootFullPath = GetFullPath( a_sync_set.OldWorkRootStepPath, Me.SettingFolderFullPath )
	a_sync_set.CommittedWorkRootFullPath = GetFullPath( a_sync_set.CommittedWorkRootStepPath, Me.SettingFolderFullPath )
	If IsEmpty( a_sync_set.CommittedWorkRootFullPath ) Then
		a_sync_set.MergedListPath = Empty
	Else
		a_sync_set.MergedListPath = GetFullPath( "_MergedList.xml",  a_sync_set.CommittedWorkRootFullPath )
	End If
End Sub


 
'***********************************************************************
'* Method: LoadScanListUp_Sub
'*
'* Name Space:
'*    SyncFilesX_Class::LoadScanListUp_Sub
'***********************************************************************
Sub  LoadScanListUp_Sub( a_sync_set )
	Set parent_tag = a_sync_set.SetTag

	debugging_name = Empty  '// Empty or ""(ALL) or string


	'// Step 1. ファイル パスをキー、XMLタグをアイテムとした辞書を作成する
	'// Set "path_dics" as array of dictionary of IXMLDOMElement

	Set files_folders_tags = parent_tag.selectNodes( "./File | ./Folder" )

	Me_GetAttributeNames  at_path,  at_base,  at_s_path,  at_s_base

	For Each  tag  In  files_folders_tags
		Me_SetDefaultFileAttribute  tag,  at_path,  at_base,  at_s_path,  at_s_base

		For Each  tag2  In  tag.selectNodes( "./Except" )
			Me_SetDefaultFileAttribute  tag2,  at_path,  at_base,  at_s_path,  at_s_base
		Next
	Next

	ReDim  path_dics(4-1)
	Set parent_ = new PathDictionaryOptionClass
	If not Me.IsMergeMode Then _
		parent_.IsReplaceParentPath = True
	Set path_dics(0) = new_PathDictionaryClass_fromXML( files_folders_tags,  at_path,  a_sync_set.NewWorkRootFullPath )
	Set path_dics(1) = new_PathDictionaryClass_fromXML( files_folders_tags,  at_base,  a_sync_set.NewBaseRootFullPath )
	Set path_dics(2) = new_PathDictionaryClass_fromXML_Ex( files_folders_tags,  at_s_path,  a_sync_set.OldWorkRootFullPath,  parent_ )
	Set path_dics(3) = new_PathDictionaryClass_fromXML_Ex( files_folders_tags,  at_s_base,  a_sync_set.OldBaseRootFullPath,  parent_ )

	Set path_dic = CreateObject( "Scripting.Dictionary" )
	For index = UBound( path_dics )  To 0  Step -1
		path_dics( index ).IsNotFoundError = False
		For Each  file_path  In  path_dics( index ).FilePaths
			Set tag = path_dics( index )( file_path )
			Set path_dic( file_path ) = tag

			If not IsEmpty( debugging_name ) Then
				If InStr( file_path, debugging_name ) > 0 Then
					echo_v  "path_dic("+ CStr( index ) +"):"""+ file_path +""""+ vbCRLF +"    "+ tag.xml
				End If
			End If
		Next
	Next


	'// Step 2. same="clone" のフォルダーのパスをを追加し、その中にあるすべてのファイルのパスを除く
	Set clone_tags = new ArrayClass
	For Each  file_path  In  path_dic.Keys
		Set tag = path_dic( file_path )
		If tag.tagName = "Folder" Then
			If tag.getAttribute( "same" ) = "clone" Then
				Error  '// Not supported
				clone_tags.Add  tag
			End If
		End If
	Next

	For Each  file_path  In  path_dic.Keys
		Set tag = path_dic( file_path )
		If tag.getAttribute( "same" ) = "clone" Then
			path_dic.Remove  file_path
		End If
	Next

	For Each  tag  In clone_tags.Items
		path = tag.getAttribute( "path" )
		Set path_dic( path ) = tag
	Next


	'// Step 3. キー（ファイルパス）でソートする
	ShakerSortDicByKeyCompare  path_dic,  GetRef( "PathCompare" ),  Empty


	'// Step 4. ファイルに関連付けされた XML タグから、
	'// file.NewBaseStepPath, NewWorkStepPath, OldBaseStepPath, OldWorkStepPath を設定する
	'// Set "file" in "work_step_path_dic" as dictionary of SyncFilesX_FileClass

	a_sync_set.Files.ToEmpty
	file_num = 0
	Set work_step_path_dic = CreateObject( "Scripting.Dictionary" )
	Set all_step_path_dic = CreateObject( "Scripting.Dictionary" )


	For Each  file_step_path  In  path_dic.Keys

	'// ◆ ここでのファイル一覧は、base にあるファイルの ABC 順と、それに続いて
	'//    work にあるファイルの ABC 順にソートされます。
	'//    file.NewWorkStepPath の ABC順にソートされません。
	'//    Me.OpenCUI() では、ABC順にソートされます。

		If not IsEmpty( debugging_name ) Then
			If InStr( file_step_path, debugging_name ) > 0 Then
				echo_v  ""
				echo_v  "path_dic>"+ file_step_path
			End If
		End If


		'// Set "file"
		Set file = new SyncFilesX_FileClass
		file.IsMergeMode = Me.IsMergeMode
		Set tag = path_dic( file_step_path )

		If tag.tagName = "File" Then
			file.NewWorkStepPath = tag.getAttribute( at_path )

			file.NewBaseStepPath = tag.getAttribute( at_base )
			If IsNull( file.NewBaseStepPath ) Then
				file.NewBaseStepPath = file.NewWorkStepPath
			End If

			file.OldWorkStepPath = tag.getAttribute( at_s_path )
			If IsNull( file.OldWorkStepPath ) Then
				file.OldWorkStepPath = file.NewWorkStepPath
			End If
			If not Me.IsMergeMode Then _
				file.OldWorkStepPath = Replace( file.OldWorkStepPath, "..\", "_parent\" )

			file.OldBaseStepPath = tag.getAttribute( at_s_base )
			If IsNull( file.OldBaseStepPath ) Then
				file.OldBaseStepPath = file.NewBaseStepPath
			End If
			If not Me.IsMergeMode Then _
				file.OldBaseStepPath = Replace( file.OldBaseStepPath, "..\", "_parent\" )

			file.NewWorkFullPath = GetFullPath( file.NewWorkStepPath, a_sync_set.NewWorkRootFullPath )
			file.NewBaseFullPath = GetFullPath( file.NewBaseStepPath, a_sync_set.NewBaseRootFullPath )
			file.OldWorkFullPath = GetFullPath( file.OldWorkStepPath, a_sync_set.OldWorkRootFullPath )
			file.OldBaseFullPath = GetFullPath( file.OldBaseStepPath, a_sync_set.OldBaseRootFullPath )
			If not IsEmpty( a_sync_set.CommittedWorkRootFullPath ) Then _
				file.CommittedWorkFullPath = GetFullPath( file.NewWorkStepPath, a_sync_set.CommittedWorkRootFullPath )

			If not IsWildcard( file.NewWorkFullPath ) Then
				If g_fs.FolderExists( file.NewWorkFullPath ) Then
					echo_v  "<Warning  msg=""File XML tag specifies a folder.""  path="""+ _
						file.NewWorkStepPath +"""/>"  '// TODO: now many same warning
				End If
			End If


			If not IsEmpty( debugging_name ) Then
				If _
					InStr( file.OldBaseStepPath, debugging_name ) > 0  or _
					InStr( file.OldWorkStepPath, debugging_name ) > 0  or _
					InStr( file.NewBaseStepPath, debugging_name ) > 0  or _
					InStr( file.NewWorkStepPath, debugging_name ) > 0 Then

					echo_v  "------------------------------------------------"
					echo_v  "file.OldBase:00:"""+ file.OldBaseStepPath +""""
					echo_v  "file.OldWork:01:"""+ file.OldWorkStepPath +""""
					echo_v  "file.NewBase:02:"""+ file.NewBaseStepPath +""""
					echo_v  "file.NewWork:03:"""+ file.NewWorkStepPath +""""
					echo_v  ""
				End If
			End If

		Else
			Assert  tag.tagName = "Folder"


			'// Set "*_in_tag"
			path_in_tag = tag.getAttribute( at_path )
			base_in_tag = tag.getAttribute( at_base )
			s_path_in_tag = tag.getAttribute( at_s_path )
			s_base_in_tag = tag.getAttribute( at_s_base )

			path_in_tag = GetPathWithSeparator( path_in_tag )
			If path_in_tag = ".\" Then _
				path_in_tag = ""

			If IsNull( base_in_tag ) Then
				base_in_tag = path_in_tag
			Else
				base_in_tag = GetPathWithSeparator( base_in_tag )
				If base_in_tag = ".\" Then _
					base_in_tag = ""
			End If

			If IsNull( s_path_in_tag ) Then
				s_path_in_tag = path_in_tag
			Else
				s_path_in_tag = GetPathWithSeparator( s_path_in_tag )
				If s_path_in_tag = ".\" Then _
					s_path_in_tag = ""
			End If
			If not Me.IsMergeMode Then _
				s_path_in_tag = Replace( s_path_in_tag, "..\", "_parent\" )

			If IsNull( s_base_in_tag ) Then
				s_base_in_tag = base_in_tag
			Else
				s_base_in_tag = GetPathWithSeparator( s_base_in_tag )
				If s_base_in_tag = ".\" Then _
					s_base_in_tag = ""
			End If
			If not Me.IsMergeMode Then _
				s_base_in_tag = Replace( s_base_in_tag, "..\", "_parent\" )


			'// Set "sub_step_path"
			If StrCompHeadOf( file_step_path,  path_in_tag,  Empty ) = 0 Then
				sub_step_path = Mid( file_step_path, Len( path_in_tag ) + 1 )
			ElseIf StrCompHeadOf( file_step_path,  base_in_tag,  Empty ) = 0 Then
				sub_step_path = Mid( file_step_path, Len( base_in_tag ) + 1 )
			ElseIf StrCompHeadOf( file_step_path,  s_path_in_tag,  Empty ) = 0 Then
				sub_step_path = Mid( file_step_path, Len( s_path_in_tag ) + 1 )
			ElseIf StrCompHeadOf( file_step_path,  s_base_in_tag,  Empty ) = 0 Then
				sub_step_path = Mid( file_step_path, Len( s_base_in_tag ) + 1 )
			Else
				Raise  1, "<ERROR  msg=""Folder XML tag specifies a file.""  path="""+ _
					s_base_in_tag +"""/>"
			End If


			'// ...
			key = path_in_tag + sub_step_path
			If all_step_path_dic.Exists( key ) Then
				Set  file = all_step_path_dic( key )
			Else
				Set  all_step_path_dic( key ) = file

				file.NewWorkStepPath = path_in_tag + sub_step_path
				file.NewWorkFullPath = GetFullPath( file.NewWorkStepPath, a_sync_set.NewWorkRootFullPath )

				file.NewBaseStepPath = base_in_tag + sub_step_path
				file.NewBaseFullPath = GetFullPath( file.NewBaseStepPath, a_sync_set.NewBaseRootFullPath )

				file.OldWorkStepPath = s_path_in_tag + sub_step_path
				file.OldWorkFullPath = GetFullPath( file.OldWorkStepPath, a_sync_set.OldWorkRootFullPath )

				file.OldBaseStepPath = s_base_in_tag + sub_step_path
				file.OldBaseFullPath = GetFullPath( file.OldBaseStepPath, a_sync_set.OldBaseRootFullPath )

				If not IsEmpty( a_sync_set.CommittedWorkRootFullPath ) Then _
					file.CommittedWorkFullPath = GetFullPath( file.NewWorkStepPath, a_sync_set.CommittedWorkRootFullPath )
			End If


			If not IsEmpty( debugging_name ) Then
				If InStr( sub_step_path, debugging_name ) > 0 Then
					echo_v  "------------------------------------------------"
					echo_v  "file.OldBase:00:"""+ file.OldBaseStepPath +""""
					echo_v  "file.OldWork:01:"""+ file.OldWorkStepPath +""""
					echo_v  "file.NewBase:02:"""+ file.NewBaseStepPath +""""
					echo_v  "file.NewWork:03:"""+ file.NewWorkStepPath +""""
					echo_v  ""
					End If
			End If
		End If


		If not work_step_path_dic.Exists( file.NewWorkStepPath ) Then


			'// Step 5. ファイルの対応関係の一覧に登録する
			Set work_step_path_dic( file.NewWorkStepPath ) = file


			'// Step 6. 他の属性を設定する
			file.Relation = tag.getAttribute( "same" )
			If IsNull( file.Relation ) Then
				file.Relation = "SameOrNotSame"
			ElseIf LCase( file.Relation ) = "yes" Then
				file.Relation = "Same"
			ElseIf LCase( file.Relation )  = "no" Then
				file.Relation = "NotSame"
			ElseIf LCase( file.Relation )  = "clone" Then
				file.Relation = "Clone"
			ElseIf LCase( file.Relation )  = "compatible" Then
				file.Relation = "Compatible"
			Else
				file.Relation = "SameOrNotSame"
			End If

			file.Caption            = g_fs.GetFileName( file.NewWorkStepPath )
			Set file.IsSameFunction = Me.IsSameFunction


			'// Echo
			file_num = file_num + 1
			file.Scan
			echo  file_num & ". "+ file.GetStateMark() +" "+ file.NewWorkStepPath
		End If
	Next

	ShakerSortDicByKeyCompare  work_step_path_dic,  GetRef( "PathCompare" ), Empty
	For Each  file  In work_step_path_dic.Items
		a_sync_set.Files.Add  file
	Next
End Sub


 
'***********************************************************************
'* Method: LoadRootXML_Sub
'*
'* Name Space:
'*    SyncFilesX_Class::LoadRootXML_Sub
'***********************************************************************
Public Sub  LoadRootXML_Sub( root,  in_SettingFilePath,  in_XML_String )

	Set Me.Variables = LoadVariableInXML( root,  in_FilePathOfXML )

	If IsObject( in_SettingFilePath ) Then
		Set Me.SettingFileFullPath = in_SettingFilePath
	Else
		Me.SettingFileFullPath = GetFullPath( GetFilePathString( in_SettingFilePath ), Empty )
	End If
	Me.SettingFolderFullPath = GetParentFullPath( GetFilePathString( Me.SettingFileFullPath ) )
	Me.XML_String = in_XML_String

	Me.UsedID              = Me.Variables( root.getAttribute( "used_ID" ) )
	Me.RestartVBS_FullPath = Me.Variables( root.getAttribute( "restart_vbs" ) )
	Me.CleanRootFullPath   = Me.Variables( root.getAttribute( "clean_root" ) )

	If IsNull( Me.RestartVBS_FullPath ) Then
		Me.RestartVBS_FullPath = Empty
	Else
		Me.RestartVBS_FullPath = Me.Variables( Me.RestartVBS_FullPath )
		Me.RestartVBS_FullPath = GetFullPath( Me.RestartVBS_FullPath, Me.SettingFolderFullPath )
	End If

	If IsNull( Me.CleanRootFullPath ) Then
		Me.CleanRootFullPath = Empty
	Else
		Me.CleanRootFullPath   = Me.Variables( Me.CleanRootFullPath )
		Me.CleanRootFullPath   = GetFullPath( Me.CleanRootFullPath,   Me.SettingFolderFullPath )
	End If
End Sub


 
'***********************************************************************
'* Method: Me_SetDefaultFileAttribute
'*
'* Name Space:
'*    SyncFilesX_Class::Me_SetDefaultFileAttribute
'***********************************************************************
Private Sub  Me_SetDefaultFileAttribute( tag,  at_path,  at_base,  at_s_path,  at_s_base )
	main_path = tag.getAttribute( at_path )
	If IsNull( main_path ) Then
		main_path = tag.getAttribute( "path" )
		tag.setAttribute  at_path,  main_path
		Assert  not IsNull( main_path )
	End If

	If IsNull( tag.getAttribute( at_base ) ) Then _
		tag.setAttribute  at_base,  main_path
	If IsNull( tag.getAttribute( at_s_path ) ) Then _
		tag.setAttribute  at_s_path,  main_path
	If IsNull( tag.getAttribute( at_s_base ) ) Then _
		tag.setAttribute  at_s_base,  tag.getAttribute( at_base )
End Sub


 
'***********************************************************************
'* Method: GetCountOfNotSynchronized
'*
'* Name Space:
'*    SyncFilesX_Class::GetCountOfNotSynchronized
'***********************************************************************
Public Function  GetCountOfNotSynchronized()
	count = 0
	For Each  a_set  In Me.Sets.Items
		If not a_set.GetIsAllSynced() Then
			count = count + 1
		End If
	Next
	GetCountOfNotSynchronized = count
End Function


 
'***********************************************************************
'* Method: GetIsAllSynchronized
'*
'* Name Space:
'*    SyncFilesX_Class::GetIsAllSynchronized
'***********************************************************************
Public Function  GetIsAllSynchronized()
	GetIsAllSynchronized = ( Me.GetCountOfNotSynchronized() = 0 )
End Function


 
'***********************************************************************
'* Method: GetCountOfBaseNotSynchronized
'*
'* Name Space:
'*    SyncFilesX_Class::GetCountOfBaseNotSynchronized
'***********************************************************************
Public Function  GetCountOfBaseNotSynchronized()
	count = 0
	For Each  a_set  In Me.Sets.Items
		If not a_set.GetIsAllBaseSynced() Then
			count = count + 1
		End If
	Next
	GetCountOfBaseNotSynchronized = count
End Function


 
'***********************************************************************
'* Method: GetIsAllBaseSynchronized
'*
'* Name Space:
'*    SyncFilesX_Class::GetIsAllBaseSynchronized
'***********************************************************************
Public Function  GetIsAllBaseSynchronized()
	GetIsAllBaseSynchronized = ( Me.GetCountOfBaseNotSynchronized() = 0 )
End Function


 
'***********************************************************************
'* Method: Attach
'*
'* Name Space:
'*    SyncFilesX_Class::Attach
'***********************************************************************
Public Sub  Attach( TargetPath )
	Set c = get_SyncFilesX_FileClassConsts()

	echo  ">Attach"
	Set ec = new EchoOff

	For Each  a_set  In Me.Sets.Items
		For Each  a_file  In a_set.Files.Items
			If not a_file.IsBaseSynced Then  '// If user updated
				If a_file.BaseState = c.Deleted  or _
						( a_file.WorkState = c.NotExist  and _
						a_file.BaseState <> c.New_ ) Then
					del  a_file.NewWorkFullPath
				ElseIf a_file.IsOldSame = True  or  IsEmpty( a_file.IsOldSame ) Then
					copy_ren  a_file.NewBaseFullPath, a_file.NewWorkFullPath
				ElseIf a_file.Relation = "Compatible" Then
					If a_file.BaseState = c.Changed Then
						copy_ren  a_file.NewBaseFullPath, a_file.NewWorkFullPath
					End If
				End If
			End If
		Next
	Next

	Me.MakeRestartVBS  TargetPath

	Me.ChangedToAttachedMode
End Sub


 
'***********************************************************************
'* Method: MakeRestartVBS
'*
'* Name Space:
'*    SyncFilesX_Class::MakeRestartVBS
'***********************************************************************
Public Sub  MakeRestartVBS( TargetPath )
	Assert  not IsEmpty( Me.RestartVBS_FullPath )
	restart_vbs_folder = GetParentFullPath( Me.RestartVBS_FullPath )


	'// Set "root": Make restart VBScript
	Set root = LoadXML( Me.SettingFileFullPath, Empty ) '// as IXMLDOMElement
	For Each a_set  In root.selectNodes( "./SynchronizingSet" )
		For Each attribute_name  In Array( "synced_base", "synced_path", "base", "path" )
			path = a_set.getAttribute( attribute_name )
			path = Me.Variables( path )
			path = GetStepPath( path, restart_vbs_folder )
			a_set.setAttribute  attribute_name, path
		Next
	Next
	For Each attribute_name  In Array( "restart_vbs", "clean_root" )
		path = root.getAttribute( attribute_name )
		path = Me.Variables( path )
		path = GetStepPath( path, restart_vbs_folder )
		root.setAttribute  attribute_name, path
	Next


	'// Make restart script
	Set file = OpenForWrite( Me.RestartVBS_FullPath, Empty )
	file.WriteLine  "'------------------------------------------------------------[FileInScript.xml]"
	file.WriteLine  "'"+ Replace( root.ownerDocument.lastChild.xml, vbCRLF, vbCRLF +"'" ) 
	file.WriteLine  "'-----------------------------------------------------------[/FileInScript.xml]"
	file.WriteLine  ""
	file.WriteLine  "Sub  Main( Opt, AppKey )"
	file.WriteLine  vbTab +"Set sync = new SyncFilesX_Class"
	file.WriteLine  vbTab +"Set sync.SettingFileFullPath = new_FilePathForFileInScript( Empty )"
	file.WriteLine  vbTab +"sync.LoadRootPaths  sync.SettingFileFullPath, ReadFile( sync.SettingFileFullPath )"
	file.WriteLine  vbTab +"echo  ""再開しています……。"""
	file.WriteLine  vbTab +"sync.ChangedToAttachedMode"
	file.WriteLine  ""
	file.WriteLine  vbTab +"target_path = """+ GetFullPath( TargetPath, Empty ) +""""
	file.WriteLine  vbTab +"If InStr( target_path, ""AppData\Local"" ) > 0 Then _"
	file.WriteLine  vbTab + vbTab + "AppKey.SetWritableMode  F_IgnoreIfWarn"
	file.WriteLine  vbTab +"Set w_=AppKey.NewWritable( target_path ).Enable()"
	file.WriteLine  vbTab +"SetWritableMode  F_AskIfWarn"
	file.WriteLine  ""
	If not IsEmpty( Me.CustomRestartCodeForRestartVBS ) Then
		file.WriteLine  Me.CustomRestartCodeForRestartVBS
		file.WriteLine  ""
	End If
	file.WriteLine  vbTab +"sync.UpdateCUI  target_path"
	file.WriteLine  ""
	file.WriteLine  vbTab +"echo  ""インストールは完了しました。"""
	file.WriteLine  vbTab +"echo  ""このウィンドウは閉じることができます。"""
	file.WriteLine  vbTab +"While True : Sleep 5000 : WEnd"
	file.WriteLine  "End Sub"
	file.WriteLine  ""
	file.WriteLine  ""
	If not IsEmpty( Me.CustomUpdateCodeForRestartVBS ) Then
		file.WriteLine  Me.CustomUpdateCodeForRestartVBS
	End If

	Set option_ = new WriteVBSLibFooter_Option
	option_.CommandPromptMode = 1

	WriteVBSLibFooter  file, option_
	file = Empty


	'// Copy "scriptlib" folder
	copy  Left( g_vbslib_folder, Len( g_vbslib_folder ) - 1 ), restart_vbs_folder
End Sub


 
'***********************************************************************
'* Method: ChangedToAttachedMode
'*
'* Name Space:
'*    SyncFilesX_Class::ChangedToAttachedMode
'***********************************************************************
Public Sub  ChangedToAttachedMode()
	Me.IsAttached = True
	Me.BaseCaption = "旧版"
	Me.WorkCaption = "新版"
	Me.CommittedCaption = "デフォルト設定"
	Me.NewCaption = "ユーザー設定"
	Me.OldCaption = "更新"
	Me.CustomCaption = "ユーザーが変更した"
	Me.BaseIsWas = "です。"
End Sub


 
'***********************************************************************
'* Method: HideSynchronizedSet
'*
'* Name Space:
'*    SyncFilesX_Class::HideSynchronizedSet
'***********************************************************************
Public Sub  HideSynchronizedSet()
	For Each  a_sync_set  In Me.Sets.Items
		If a_sync_set.GetIsAllSynced() Then
			a_sync_set.IsShow = False
		End If
	Next
End Sub


 
'***********************************************************************
'* Method: Merge
'*
'* Name Space:
'*    SyncFilesX_Class::Merge
'***********************************************************************
Public Sub  Merge( in_MergeOption )
	echo  ">Merge"
	Set ec = new EchoOff

	Me.IsMerged = True


	'// Set "merge_"
	If not IsEmpty( in_MergeOption ) Then
		AssertD_TypeName  in_MergeOption, "ThreeWayMergeOptionClass"
		Set merge_ = in_MergeOption
	Else
		Set merge_ = new ThreeWayMergeOptionClass
	End If
	merge_.IsEnableToRaiseConflictError = False


	'// Reset or Continue committed folder
	echo_line
	is_exist = False
	For Each  a_sync_set  In Me.Sets.Items
		If exist( a_sync_set.NewWorkRootFullPath ) Then
			If not IsEmpty( a_sync_set.CommittedWorkRootStepPath ) Then
				path = a_sync_set.CommittedWorkRootFullPath
				If exist( path ) Then
					echo  path
					is_exist = True
				End If
			End If
		Else
			If not IsEmpty( a_sync_set.CommittedWorkRootStepPath ) Then
				del  a_sync_set.CommittedWorkRootFullPath
			End If
		End If
	Next
	If is_exist Then
		ec = Empty
		echo  "コミット済みファイルが入る上記のフォルダーが見つかりました。"
		echo  "1. まだコミットしていないファイルのマージの続きをする [Continue]"
		echo  "2. コミット済みのフォルダーを削除して、最初からマージする [Reset]"
		Do
			key = Trim( Input( "番号またはコマンド名>" ) )
			Select Case  key
				Case "1": key = "Continue"
				Case "2": key = "Reset"
			End Select

			If StrComp( key, "Continue", 1 ) = 0 Then
				Exit Do

			ElseIf StrComp( key, "Reset", 1 ) = 0 Then
				For Each  a_sync_set  In Me.Sets.Items
					If not IsEmpty( a_sync_set.CommittedWorkRootStepPath ) Then
						del  a_sync_set.NewWorkRootFullPath
						del  a_sync_set.CommittedWorkRootFullPath
					End If
				Next

				Exit Do
			End If
		Loop
		Set ec = new EchoOff
	End If


	'// ...
	is_flushed = False
	For Each  a_sync_set  In Me.Sets.Items

		If not is_flushed Then
			g_FileHashCache.RemoveAll
			is_flushed = True
		End If


		'// Call "LoadMergedList"
		If exist( a_sync_set.CommittedWorkRootFullPath ) Then _
			Me.LoadMergedList


		'// Set "files", "patch_"
		Set files = CreateObject( "Scripting.Dictionary" )
		files.CompareMode = c_NotCaseSensitive

		Set patch_ = new PatchAndBackUpDictionaryClass
		Set  patch_.BackUpPaths = CreateObject( "Scripting.Dictionary" )
		patch_.BackUpPaths.CompareMode = c_NotCaseSensitive
		Set  patch_.PatchPaths = CreateObject( "Scripting.Dictionary" )
		patch_.PatchPaths.CompareMode = c_NotCaseSensitive

		patch_.BackUpRootPath = a_sync_set.OldBaseRootFullPath
		patch_.PatchRootPath  = a_sync_set.NewBaseRootFullPath

		For Each  file  In  a_sync_set.Files.Items
			If Me.IsModifiedFromMerged( a_sync_set,  file ) Then
				merged_step_path = GetStepPath( file.NewWorkFullPath, _
					a_sync_set.NewWorkRootFullPath )

				'// files( merged ) = left
				merged_path = file.NewWorkFullPath
				left_path = file.OldWorkFullPath
				If g_FileHashCache( left_path ) = "" Then _
					left_path = Empty
				Set files( merged_path ) = new_NameOnlyClass( left_path, Empty )

				'// BackUpPaths( base_key ) = base
				base_key_path = GetFullPath( merged_step_path, a_sync_set.OldBaseRootFullPath )
				base_path = file.OldBaseFullPath
				If g_FileHashCache( base_path ) = "" Then _
					base_path = Empty
				Set patch_.BackUpPaths( base_key_path ) = new_NameOnlyClass( base_path, Empty )

				'// PatchPaths( right_key ) = right
				right_key_path = GetFullPath( merged_step_path, a_sync_set.NewBaseRootFullPath )
				right_path = file.NewBaseFullPath
				If g_FileHashCache( right_path ) = "" Then _
					right_path = Empty
				Set patch_.PatchPaths( right_key_path ) = new_NameOnlyClass( right_path, Empty )
			End If
		Next


		'// Merge
		AttachPatchAndBackUpDictionary  files,  patch_,  a_sync_set.NewWorkRootFullPath,  merge_
		CopyFilesToLeafPathDictionary  files, False


		'// Commit
		If not IsEmpty( a_sync_set.CommittedWorkRootStepPath ) Then
			If not exist( a_sync_set.CommittedWorkRootFullPath ) Then
				For Each  file  In  a_sync_set.Files.Items
					If file.GetIsMergeSynced() Then
						source = file.NewWorkFullPath
					Else
						source = file.OldBaseFullPath
					End If

					If exist( source ) Then
						copy_ren  source,  file.CommittedWorkFullPath
					Else
						del  file.CommittedWorkFullPath
					End If
				Next
			End If
		End If


		'// Scan again
		For Each  file  In  a_sync_set.Files.Items
			file.Scan
		Next
	Next
End Sub


 
'***********************************************************************
'* Method: LoadMergedList
'*
'* Name Space:
'*    SyncFilesX_Class::LoadMergedList
'***********************************************************************
Public Sub  LoadMergedList()
	For Each  a_sync_set  In Me.Sets.Items
		If exist( a_sync_set.MergedListPath ) Then

			Set root = LoadXML( a_sync_set.MergedListPath, Empty )
			For Each  file_tag  In  root.selectNodes( "./File" )

				Set merged = new SyncFilesX_MergedClass

				Set tag = file_tag.selectSingleNode( "./Base" )
				merged.BaseHash     = tag.getAttribute( "hash" )
				merged.BaseStepPath = tag.getAttribute( "path" )
				merged.BaseFullPath = GetFullPath( merged.BaseStepPath, _
					a_sync_set.OldBaseRootFullPath )

				Set tag = file_tag.selectSingleNode( "./Left" )
				merged.LeftHash     = tag.getAttribute( "hash" )
				merged.LeftStepPath = tag.getAttribute( "path" )
				merged.LeftFullPath = GetFullPath( merged.LeftStepPath, _
					a_sync_set.OldWorkRootFullPath )

				Set tag = file_tag.selectSingleNode( "./Right" )
				merged.RightHash     = tag.getAttribute( "hash" )
				merged.RightStepPath = tag.getAttribute( "path" )
				merged.RightFullPath = GetFullPath( merged.RightStepPath, _
					a_sync_set.NewBaseRootFullPath )

				Set tag = file_tag.selectSingleNode( "./Merged" )
				merged.MergedHash     = tag.getAttribute( "hash" )
				merged.MergedStepPath = tag.getAttribute( "path" )
				merged.MergedFullPath = GetFullPath( merged.MergedStepPath, _
					a_sync_set.NewWorkRootFullPath )

				If exist( merged.BaseFullPath ) Then
					is_exist = True
				ElseIf exist( merged.LeftFullPath ) Then
					is_exist = True
				ElseIf exist( merged.RightFullPath ) Then
					is_exist = True
				ElseIf exist( merged.MergedFullPath ) Then
					is_exist = True
				Else
					is_exist = False
				End If

				If is_exist Then _
					Set a_sync_set.MergedList( merged.MergedStepPath ) = merged
			Next
		End If
	Next
End Sub


 
'***********************************************************************
'* Method: SaveMergedList
'*
'* Name Space:
'*    SyncFilesX_Class::SaveMergedList
'***********************************************************************
Public Sub  SaveMergedList()
	For Each  a_sync_set  In Me.Sets.Items
		If not IsEmpty( a_sync_set.MergedListPath ) Then
			Set file = OpenForWrite( a_sync_set.MergedListPath, g_VBS_Lib.Unicode )
			file.WriteLine  "<?xml version=""1.0"" encoding=""UTF-16""?>"
			file.WriteLine  "<MergedList>"
			For Each  merged  In  a_sync_set.MergedList.Items
				AssertD_TypeName  merged, "SyncFilesX_MergedClass"
				file.WriteLine  "<File>"
				file.WriteLine  "<Base   hash="""+ merged.BaseHash +""" path="""+ merged.BaseStepPath +"""/>"
				file.WriteLine  "<Left   hash="""+ merged.LeftHash +""" path="""+ merged.LeftStepPath +"""/>"
				file.WriteLine  "<Right  hash="""+ merged.RightHash +""" path="""+ merged.RightStepPath +"""/>"
				file.WriteLine  "<Merged hash="""+ merged.MergedHash +""" path="""+ merged.MergedStepPath +"""/>"
				file.WriteLine  "</File>"
			Next
			file.WriteLine  "</MergedList>"
		End If
	Next
End Sub


 
'***********************************************************************
'* Method: AddToMergedList
'*
'* Name Space:
'*    SyncFilesX_Class::AddToMergedList
'***********************************************************************
Public Sub  AddToMergedList( in_SyncSet,  in_File )
	AssertD_TypeName  in_SyncSet, "SyncFilesX_SetClass"
	AssertD_TypeName  in_File, "SyncFilesX_FileClass"
	Set c = g_VBS_Lib_System

	Set merged = new SyncFilesX_MergedClass

	merged.BaseStepPath = in_File.OldBaseStepPath
	merged.BaseFullPath = in_File.OldBaseFullPath
	If exist( merged.BaseFullPath ) Then
		merged.BaseHash = ReadBinaryFile( merged.BaseFullPath ).MD5
	Else
		merged.BaseHash = c.NotExistFileMD5
	End If

	merged.LeftStepPath = in_File.OldWorkStepPath
	merged.LeftFullPath = in_File.OldWorkFullPath
	If exist( merged.LeftFullPath ) Then
		merged.LeftHash = ReadBinaryFile( merged.LeftFullPath ).MD5
	Else
		merged.LeftHash = c.NotExistFileMD5
	End If

	merged.RightStepPath = in_File.NewBaseStepPath
	merged.RightFullPath = in_File.NewBaseFullPath
	If exist( merged.RightFullPath ) Then
		merged.RightHash = ReadBinaryFile( merged.RightFullPath ).MD5
	Else
		merged.RightHash = c.NotExistFileMD5
	End If

	merged.MergedStepPath = in_File.NewWorkStepPath
	merged.MergedFullPath = in_File.NewWorkFullPath
	If exist( merged.MergedFullPath ) Then
		merged.MergedHash = ReadBinaryFile( merged.MergedFullPath ).MD5
	Else
		merged.MergedHash = c.NotExistFileMD5
	End If

	Set in_SyncSet.MergedList( merged.MergedStepPath ) = merged
End Sub


 
'***********************************************************************
'* Method: IsModifiedFromMerged
'*
'* Name Space:
'*    SyncFilesX_Class::IsModifiedFromMerged
'***********************************************************************
Public Function  IsModifiedFromMerged( in_SyncSet,  in_File )
	merged_step_path = GetStepPath( in_File.NewWorkFullPath,  in_SyncSet.NewWorkRootFullPath )

	If  NOT  in_SyncSet.MergedList.Exists( merged_step_path ) Then
		is_modified = True
	Else
		Set merged = in_SyncSet.MergedList( merged_step_path )

		is_modified = Me_IsModifiedFromMergedSub( _
			merged.BaseStepPath,  in_File.OldBaseStepPath, _
			merged.BaseHash,  merged.BaseFullPath )

		If not is_modified Then
			is_modified = Me_IsModifiedFromMergedSub( _
				merged.LeftStepPath,  in_File.OldWorkStepPath, _
				merged.LeftHash,  merged.LeftFullPath )
		End If
		If not is_modified Then
			is_modified = Me_IsModifiedFromMergedSub( _
				merged.RightStepPath,  in_File.NewBaseStepPath, _
				merged.RightHash,  merged.RightFullPath )
		End If
		If not is_modified Then
			is_modified = Me_IsModifiedFromMergedSub( _
				merged.MergedStepPath,  in_File.NewWorkStepPath, _
				merged.MergedHash,  merged.MergedFullPath )
		End If
	End If

	IsModifiedFromMerged = is_modified
End Function


 
'***********************************************************************
'* Method: Me_IsModifiedFromMergedSub
'*
'* Name Space:
'*    SyncFilesX_Class::Me_IsModifiedFromMergedSub
'***********************************************************************
Public Function  Me_IsModifiedFromMergedSub( in_StepPath, in_NewStepPath, in_Hash, in_FullPath )
	If in_StepPath <> in_NewStepPath Then
		is_modified = True
	Else
		is_exist_new = g_fs.FileExists( in_FullPath )
		If in_Hash = g_VBS_Lib_System.NotExistFileMD5 Then
			is_modified = is_exist_new
		Else
			If is_exist_new Then
				hash = ReadBinaryFile( in_FullPath ).MD5
				is_modified = ( hash <> in_Hash )
			Else
				is_modified = True
			End If
		End If
	End If

	Me_IsModifiedFromMergedSub = is_modified
End Function


 
'***********************************************************************
'* Method: UpdateCUI
'*
'* Name Space:
'*    SyncFilesX_Class::UpdateCUI
'***********************************************************************
Public Sub  UpdateCUI( TargetPath )
	Assert  not IsEmpty( Me.CleanRootFullPath )
	is_skip = Me.GetIsAllSynchronized()  and  Me.IsSkipIfAllSynchronized

	If not is_skip Then
		echo  "更新先フォルダー："""+ GetFullPath( TargetPath, Empty ) +""""
		echo  ""
		echo  "  調整メニューの凡例："
		echo  "    中央の記号の意味: [=]同じ [!]異なる [ ]両方不在"
		echo  "    左右の記号の意味: [*]変更 [+]追加 [-]削除 [.]不変 [ ]不在"
		echo  "    左の記号は旧版、右の記号は新版"
		echo  ""
		echo  "更新により、互換性がない一部の設定（ファイル）がリセットされることがあります（後で ! と表示）。 "+_
			"リセットしたくない設定があれば、以下を続行した後の調整メニューで調整してください。 "+ _
			"互換性がある設定は継続して使われます（後で = と表示）。 "+_
			"調整メニューでは、ユーザーが変更した設定ファイルを一覧します。 "+ _
			"そこで「終了」を選ぶと、「新版」の「ユーザー設定」の内容で、"+ _
			"インストールを実行します。"+ _
			"途中でウィンドウを閉じたり、インストール後でも、以下のスクリプト ファイルを"+ _
			"ダブルクリックすると、調整メニューを再開できます。"+ vbCRLF + _
			""""+ Me.RestartVBS_FullPath +""""
		echo  ""
		echo  "よくわからなければ、Enter を押してから「終了」を選び、更新を実行してください。"
		Pause

		Do
			echo_line
			echo  "更新内容を調べています……"
			Set ec = new EchoOff
			Me.LoadScanListUpAll  Me.SettingFileFullPath, ReadFile( Me.SettingFileFullPath )
			ec = Empty
			result = Me.OpenCUI()
			If result = "Exit" Then  Exit Do
		Loop
	End If

	echo_line
	echo  "インストールしています……"
	Set ec = new EchoOff
	Assert  not IsArray( TargetPath )

	del   TargetPath +"\*"
	copy  Me.Sets(0).NewWorkRootFullPath +"\*", TargetPath

	ec = Empty

	If not IsEmpty( Me.CustomUpdateFunction ) Then
		Me.CustomUpdateFunction  Me.CustomUpdateFunctionParameter
	End If

	echo  "インストールしました！（以下のフォルダーが更新されました）"
	echo  "    """+ TargetPath +""""
	If not is_skip Then
		echo_line
		echo  "更新する前後の様子（差分）のコピーを以下のフォルダーに置きました。"
		echo  "更新したプログラムが正しく動くことを確認したら、削除できます。"
		echo  """"+ Me.CleanRootFullPath +""""
		echo  ""
		echo  "以下に示すスクリプトをダブルクリックすると、"+ _
			"調整メニューとインストールを再度実行することができます。"
		echo  """"+ Me.RestartVBS_FullPath +""""
		echo  ""
		Pause
	End If
End Sub


 
'***********************************************************************
'* Method: OpenCUI
'*
'* Name Space:
'*    SyncFilesX_Class::OpenCUI
'***********************************************************************
Public Function  OpenCUI()
	current_root = Empty
	is_one_file = ( Me.Sets.Count = 1  and  Me.Sets(0).Files.Count = 1 )
	is_all_files = is_one_file

	Do
		'// Set "current_root" as "SyncFilesX_SetClass"
		If IsEmpty( current_root ) Then
			If Me.Sets.Count = 1 Then
				Set current_root = Me.Sets(0)
			Else
				Do
					echo_line
					Set root_array = new ArrayClass
					For Each  a_sync_set  In Me.Sets.Items
					If a_sync_set.IsShow Then
						root_array.Add  a_sync_set

						a_string = root_array.Count & ". "
						If not IsEmpty( a_sync_set.ID_Label ) Then _
							a_string = a_string +"["+ a_sync_set.ID_Label +"] "
						a_string = a_string + a_sync_set.GetIsAllSyncedMark()
						echo  a_string

						If not Me.IsMergeMode Then
							echo  "■"+ Me.BaseCaption +"（"+ a_sync_set.BaseName +"）: """+ _
								a_sync_set.NewBaseRootStepPath +""""
							echo  "■"+ Me.WorkCaption +"（"+ a_sync_set.WorkName +"）: """+ _
								a_sync_set.NewWorkRootStepPath +""""
						Else
							echo  "■"+ Me.SyncedWorkCaption +"（"+ a_sync_set.WorkName +"）: """+ _
								a_sync_set.OldWorkRootStepPath +""""
							echo  "■"+ Me.BaseCaption +"（"+ a_sync_set.BaseName +"）: """+ _
								a_sync_set.NewBaseRootStepPath +""""
						End If
					End If
					Next
					echo  ""
					echo  "91. 再スキャンする [Rescan]"
					echo  "93. すべての"+ Me.WorkCaption +"ファイルの一覧をファイルに出力する"
					echo  "99. 終了"
					key = Input( Me.OldCaption +"するセットの番号 >" )


					Select Case  key
						Case "Rescan"     : key = 91
						Case Else : key = CInt2( key )
					End Select

					If key >= 1  and  key <= root_array.Count Then
						Set current_root = root_array( key - 1 )
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
		If not Me.IsMergeMode Then
			For Each  file  In current_root.Files.Items
				If is_all_files Then
					is_not_synced = True
				ElseIf not Me.IsAttached Then
					If not file.IsSynced Then
						is_not_synced = True
					Else
						is_not_synced = False
					End If
				Else  '// Me.IsAttached
					If file.IsNewSame Then
						is_not_synced = False
					ElseIf not file.IsSynced Then
						is_not_synced = True
					Else
						is_not_synced = False
					End If
				End If

				If is_not_synced Then
					not_synced_files.Add  file
				End If
			Next

			both_side_count = 0
			For Each  file  In current_root.Files.Items
				If exist( file.NewBaseFullPath ) and exist( file.NewWorkFullPath ) Then _
					both_side_count = both_side_count + 1
			Next
		Else
			For Each  file  In current_root.Files.Items
				If is_all_files Then
					is_not_synced = True
				Else
					If IsEmpty( current_root.CommittedWorkRootStepPath ) Then
						is_not_synced = not file.GetIsMergeSynced()
					Else
						is_not_synced = not file.IsCommitSynced
					End If
				End If

				If is_not_synced Then
					not_synced_files.Add  file
				End If
			Next

			both_side_count = 0
			For Each  file  In current_root.Files.Items
				If exist( file.NewBaseFullPath ) and exist( file.OldWorkFullPath ) Then _
					both_side_count = both_side_count + 1
			Next
		End If

		If not_synced_files.Count = 0 Then
			If Me.IsSkipIfAllSynchronized Then
				If Me.Sets.Count = 1 Then
					OpenCUI = "Exit"
					Exit Function
				End If
			End If
		End If


		'// Select a file
		echo_line
		If not Me.IsMergeMode Then
			echo  Me.SettingFolderFullPath
			echo  Me.CommittedCaption +"の"+ Me.BaseCaption +": """+ current_root.OldBaseRootStepPath +""""
			echo  Me.CommittedCaption +"の"+ Me.WorkCaption +": """+ current_root.OldWorkRootStepPath +""""
			echo_line
			echo  "■"+ Me.BaseCaption +"（"+ current_root.BaseName +"）: """+ current_root.NewBaseRootStepPath +""""
			echo  "■"+ Me.WorkCaption +"（"+ current_root.WorkName +"）: """+ current_root.NewWorkRootStepPath +""""
		Else
			echo  "■"+ Me.SyncedBaseCaption +": """+ current_root.OldBaseRootStepPath +""""
			echo  "■"+ Me.SyncedWorkCaption +"（"+ current_root.WorkName +"）: """+ current_root.OldWorkRootStepPath +""""
			echo  "■"+ Me.BaseCaption       +"（"+ current_root.BaseName +"）: """+ current_root.NewBaseRootStepPath +""""
			echo  "■"+ Me.WorkCaption       +": """+ current_root.NewWorkRootStepPath +""""
			If not IsEmpty( current_root.CommittedWorkRootFullPath ) Then _
				echo  "■"+ Me.CommittedCaption +": """+ current_root.CommittedWorkRootStepPath +""""
		End If

		is_auto_commit = False
		is_auto_copy_s = False  '// is automatic copy for same relation
		is_auto_copy_u = False  '// is automatic copy from updated it
		is_auto_copy_b = False  '// is automatic copy from updated base
		file_num = 0
		file_num_max = 89
		For Each  file  In not_synced_files.Items
			file_num = file_num + 1
			If file.IsAbleToAutoCommit Then _
				is_auto_commit = True
			If file.IsAbleToCopyForSameRelation Then _
				is_auto_copy_s = True
			If file.IsAbleToCopyFromUpdatedAuto Then _
				is_auto_copy_u = True
			If file.IsAbleToCopyFromBaseAuto Then _
				is_auto_copy_b = True

			echo  file_num & ". "+ file.GetStateMark() +" "+ file.GetSameMark() + _
				file.NewWorkStepPath + file.GetCloneMark()

			If file_num = file_num_max Then
				echo  "（以下略）"
				Exit For
			End If
		Next
		If not_synced_files.Count = 0 Then
			echo  "なし（同期完了）"
		End If

		If both_side_count <> current_root.Files.Count Then
			echo  "左右両方あるファイルの数＝ "+ _
				CStr( both_side_count ) +"/"+ CStr( current_root.Files.Count ) +" ("+ _
				CStr( CInt( both_side_count * 100 / current_root.Files.Count ) ) +"%)"
		End If

		If Me.IsNoCUI Then
			OpenCUI = "Exit"
			Exit Function
		End If

		echo  ""
		echo  "91. 再スキャンする [Rescan]"
		echo  "92. ルート・フォルダーを開く"
		echo  "93. 状況を分析する [Analyze]"
		If is_auto_copy_s Then
			echo  "95. ★「同じ内容」になるべきファイルを同じ内容にする [AutoSynchronize]"
		End If
		If ( is_auto_copy_u  or  is_auto_copy_b ) and  not is_auto_commit  and  not is_auto_copy_s Then
			echo  "96. ★ 自動マージしてコミットする [AutoMerge]"
		End If
		If not_synced_files.Count = 0 Then
			echo  "97. すべてのファイルを表示する"
		End If
		If is_auto_commit  and  not is_auto_copy_s Then
			echo  "98. ★ "+ Me.BaseCaption +"と"+ Me.WorkCaption +"が同じファイルをすべてコミットする [AutoCommit]"
		End If
		If Me.Sets.Count = 1 Then
			echo  "99. 終了"
		Else
			echo  "99. 戻る"
		End If


		If Me.IsNextAutoSynchronize Then
			key = "AutoSynchronize"
			echo  "番号>"+ key
		ElseIf Me.IsNextAutoCommit Then
			key = "AutoCommit"
			echo  "番号>"+ key
		ElseIf Me.IsNextAutoMergeFromBase Then
			key = "AutoMerge"
			echo  "番号>"+ key
		ElseIf is_one_file Then
			key = 1
		Else
			key = Input( "番号 >" )
		End If


		Select Case  key
			Case "Rescan"      : key = 91
			Case "Analyze"     : key = 93
			Case "AutoSynchronize" : key = 95
			Case "AutoMerge"   : key = 96
			Case "AutoCommit"  : key = 98
			Case "SyncForTest" : key = 961
			Case Else : key = CInt2( key )
		End Select

		If key >= 1  and  key <= not_synced_files.Count  and  key <= file_num_max  Then
			echo_line
			Me.OpenFileCUI  current_root, not_synced_files( key - 1 )

			If is_one_file Then
				OpenCUI = "Exit"
				Exit Function
			End If
		ElseIf key = 91 Then
			Me.LoadScanListUp_Sub  current_root
		ElseIf key = 92 Then
			Do
				echo_line
				If not Me.IsMergeMode Then
					echo  "1. "+ Me.BaseCaption +"（"+ current_root.BaseName +"）: """+ _
						current_root.NewBaseRootStepPath +""""
					echo  "2. "+ Me.WorkCaption +"（"+ current_root.WorkName +"）: """+ _
						current_root.NewWorkRootStepPath +""""
					echo  "3. 設定ファイルがあるフォルダー"
					echo  "4. "+ Me.CommittedCaption +"の"+ Me.BaseCaption
					echo  "5. "+ Me.CommittedCaption +"の"+ Me.WorkCaption
					echo  "9 または Enter : 戻る"
					key = CInt2( Input( "どのルート・フォルダーを開きますか >" ) )

					If key = 1 Then
						echo_line
						OpenFolder  current_root.NewBaseRootFullPath
					ElseIf key = 2 Then
						echo_line
						OpenFolder  current_root.NewWorkRootFullPath
					ElseIf key = 3 Then
						echo_line
						OpenFolder  Me.SettingFileFullPath
					ElseIf key = 4 Then
						echo_line
						OpenFolder  current_root.OldBaseRootFullPath
					ElseIf key = 5 Then
						echo_line
						OpenFolder  current_root.OldWorkRootFullPath
					ElseIf key = 9  or  key = 0 Then
						Exit Do
					End If
				Else
					echo  "1. "+ Me.SyncedWorkCaption +"（"+ current_root.WorkName +"）: """+ _
						current_root.OldWorkRootStepPath +""""
					echo  "2. "+ Me.BaseCaption +"（"+ current_root.BaseName +"）: """+ _
						current_root.NewBaseRootStepPath +""""
					echo  "3. 設定ファイルがあるフォルダー"
					echo  "4. "+ Me.SyncedBaseCaption
					echo  "5. "+ Me.WorkCaption
					If not IsEmpty( current_root.CommittedWorkRootFullPath ) Then _
						echo  "6. "+ Me.CommittedCaption
					echo  "9 または Enter : 戻る"
					key = CInt2( Input( "どのルート・フォルダーを開きますか >" ) )

					If key = 1 Then
						echo_line
						OpenFolder  current_root.OldWorkRootFullPath
					ElseIf key = 2 Then
						echo_line
						OpenFolder  current_root.NewBaseRootFullPath
					ElseIf key = 3 Then
						echo_line
						OpenFolder  Me.SettingFileFullPath
					ElseIf key = 4 Then
						echo_line
						OpenFolder  current_root.OldBaseRootFullPath
					ElseIf key = 5 Then
						echo_line
						OpenFolder  current_root.NewWorkRootFullPath
					ElseIf key = 6 Then
						echo_line
						OpenFolder  current_root.CommittedWorkRootFullPath
					ElseIf key = 9  or  key = 0 Then
						Exit Do
					End If
				End If
			Loop
		ElseIf key = 93 Then
			Me.FindMoved  current_root
		ElseIf key = 95 Then
			echo  ""
			For Each  file  In not_synced_files.Items
				If file.IsAbleToCopyForSameRelation Then _
					echo  file.GetStateMark() +" ="+ file.NewWorkStepPath
			Next
			If Me.IsNextAutoSynchronize Then
				Me.IsNextAutoSynchronize = False
				key = "Y"
			Else
				key = Input( "以上のファイルをすべてコミットしますか(y/n)" )
			End If
			If key = "Y" or key = "y" Then
				echo_line
				For Each  file  In not_synced_files.Items
					If file.IsAbleToCopyForSameRelation Then
						file.CopyFromUpdatedAuto
						file.Commit
					End If
				Next
			End If

		ElseIf key = 961 Then
			echo  ""
			For Each  file  In not_synced_files.Items
				If file.IsAbleToSyncForTest Then _
					echo  file.GetStateMark() +" "+ file.NewWorkStepPath
			Next
			key = Input( "以上のファイルをテスト用に同期してコミットしますか(y/n)" )
			If key = "Y" or key = "y" Then
				echo_line
				For Each  file  In not_synced_files.Items
					If file.IsAbleToSyncForTest Then
						file.SyncForTest
						file.Commit
					End If
				Next
			End If
		ElseIf key = 96 Then
			If is_auto_copy_u Then
				echo  "1. 前回のコミットが同じ内容のファイルについて、"+_
					"更新があった方から無かった方へコピーしてコミットする [CopyFromUpdated]"
			End If
			If is_auto_copy_b Then
				echo  "2. 前回のコミットが同じ内容のファイルについて、"+_
					"ベースにだけ更新があったらワークへコピーしてコミットする [CopyFromBase]"
			End If
			echo  "9. 戻る"


			If Me.IsNextAutoMergeFromBase Then
				key2 = "CopyFromBase"
				echo  "番号>"+ key2
			Else
				key2 = Input( "番号>" )
			End If


			Select Case  key2
				Case "CopyFromUpdated" : key2 = 1
				Case "CopyFromBase"    : key2 = 2
				Case Else : key2 = CInt2( key2 )
			End Select
			If key2 = 1 Then
				echo  ""
				For Each  file  In not_synced_files.Items
					If file.IsAbleToCopyFromUpdatedAuto Then _
						echo  file.GetStateMark() +" "+ file.NewWorkStepPath
				Next
				key = Input( "以上のファイルを新しい方の内容になるようにコピーしてコミットしますか(y/n)" )
				If key = "Y" or key = "y" Then
					echo_line
					For Each  file  In not_synced_files.Items
						If file.IsAbleToCopyFromUpdatedAuto Then
							file.CopyFromUpdatedAuto
							file.Commit
						End If
					Next
				End If
			End If
			If key2 = 2 Then
				echo  ""
				For Each  file  In not_synced_files.Items
					If file.IsAbleToCopyFromBaseAuto Then _
						echo  file.GetStateMark() +" "+ file.NewWorkStepPath
				Next
				If Me.IsNextAutoMergeFromBase Then
					Me.IsNextAutoMergeFromBase = False
					key = "Y"
				Else
					key = Input( "以上のファイルをベースからコピーしてコミットしますか(y/n)" )
				End If
				If key = "Y" or key = "y" Then
					echo_line
					For Each  file  In not_synced_files.Items
						If file.IsAbleToCopyFromBaseAuto Then
							file.CopyFromBaseAuto
							file.Commit
						End If
					Next
				End If
			End If
		ElseIf key = 97 Then
			is_all_files = not is_all_files
		ElseIf key = 98 Then
			echo  ""
			For Each  file  In not_synced_files.Items
				If file.IsAbleToAutoCommit Then _
					echo  file.GetStateMark() +" "+ file.NewWorkStepPath
			Next
			If Me.IsNextAutoCommit Then
				Me.IsNextAutoCommit = False
				key = "Y"
			Else
				key = Input( "以上のファイルをすべてコミットしますか(y/n)" )
			End If
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


 
'***********************************************************************
'* Method: OpenFileCUI
'*
'* Name Space:
'*    SyncFilesX_Class::OpenFileCUI
'***********************************************************************
Sub  OpenFileCUI( a_Set, in_File ) '// in_File as SyncFilesX_FileClass
	Set c = g_VBS_Lib
	is_commit = False
	work_back_up_path = g_fs.GetParentFolderName( in_File.NewWorkFullPath )+"\"+ _
		g_fs.GetBaseName( in_File.NewWorkFullPath ) + _
		".back_up."+ g_fs.GetExtensionName( in_File.NewWorkFullPath )
	base_back_up_path = g_fs.GetParentFolderName( in_File.NewBaseFullPath )+"\"+ _
		g_fs.GetBaseName( in_File.NewBaseFullPath ) + _
		".back_up."+ g_fs.GetExtensionName( in_File.NewBaseFullPath )
	Do

		If not Me.IsMergeMode Then
			old_base_step_path = Replace( in_File.OldBaseStepPath, "_parent\", "..\" )
			old_work_step_path = Replace( in_File.OldWorkStepPath, "_parent\", "..\" )

			If in_File.NewBaseStepPath <> old_base_step_path Then _
				echo  "前回の"+ Me.BaseCaption +"："""+ in_File.OldBaseFullPath +""""
			If in_File.NewWorkStepPath <> old_work_step_path Then _
				echo  "前回の"+ Me.WorkCaption +"："""+ in_File.OldWorkFullPath +""""
			echo  Me.BaseCaption +"："""+ in_File.NewBaseFullPath +""""
			echo  Me.WorkCaption +"："""+ in_File.NewWorkFullPath +""""
		Else
			echo  Me.SyncedBaseCaption +"："""+ in_File.OldBaseFullPath +""""
			echo  Me.SyncedWorkCaption +"："""+ in_File.OldWorkFullPath +""""
			echo  Me.BaseCaption       +"："""+ in_File.NewBaseFullPath +""""
			echo  Me.WorkCaption       +"："""+ in_File.NewWorkFullPath +""""
			If not IsEmpty( in_File.CommittedWorkFullPath ) Then _
				echo  Me.CommittedCaption +"："""+ in_File.CommittedWorkFullPath +""""
		End If

		If not Me.IsMergeMode Then
			echo  in_File.GetGuideA( Me.BaseCaption, Me.WorkCaption, Me.BaseIsWas )
			If is_commit Then
				echo  "コミットしました。"
				is_commit = False
			Else
				echo  "次のメニューの 1.で開く２つのファイルを手動で"+ Me.OldCaption +"したら、コミットしてください。"
			End If
		End If
		echo_line

		in_File.Scan

		If not Me.IsMergeMode Then
			If in_File.NewBaseStepPath <> old_base_step_path Then _
				echo  "前回コミット時の"+ Me.BaseCaption +"："+ in_File.OldBaseStepPath
			If in_File.NewWorkStepPath <> old_work_step_path Then _
				echo  "前回コミット時の"+ Me.WorkCaption +"："+ in_File.OldWorkStepPath
			echo  "★"+ Me.BaseCaption +"（"+ a_Set.BaseName +"）: "+ in_File.NewBaseStepPath + _
				" ("+ in_File.c.ToStr( in_File.BaseState ) +")"
			echo  "★"+ Me.WorkCaption +"（"+ a_Set.WorkName +"）: "+ in_File.NewWorkStepPath + _
				" ("+ in_File.c.ToStr( in_File.WorkState ) +")"
		Else
			If in_File.IsCommitSynced Then
				commit_state = "（済）"
			Else
				commit_state = "（未）"
			End If

			echo  Me.SyncedBaseCaption +"："+ in_File.OldBaseStepPath
			echo  Me.SyncedWorkCaption +"（"+ a_Set.WorkName +"）："+ in_File.OldWorkStepPath
			echo  Me.BaseCaption       +"（"+ a_Set.BaseName +"）："+ in_File.NewBaseStepPath
			echo  Me.WorkCaption       + commit_state +"："+ in_File.NewWorkStepPath
		End If
		echo  ""
		If not Me.IsMergeMode Then
			echo  "1. Diff で開く："+ Me.CustomCaption + Me.OldCaption +"する"+ in_File.GetTypeName() + _
				" ("+ GetEqualString( in_File.IsNewSame ) +_
				") [ "+ Me.BaseCaption +" / "+ Me.WorkCaption +" ]"
			echo  "2. Diff で開く："+ Me.CommittedCaption +"の"+ Me.OldCaption +"内容 ("+ _
				GetEqualString( in_File.IsOldSame ) +_
				") [ "+ Me.BaseCaption +" / "+ Me.WorkCaption +" ]"
			echo  "4. Diff で開く："+ Me.BaseCaption +" ("+ in_File.c.ToStr( in_File.BaseState ) +") [ "+ _
				Me.CommittedCaption +" / "+ Me.NewCaption +" ]"
			echo  "5. Diff で開く："+ Me.WorkCaption +" ("+ in_File.c.ToStr( in_File.WorkState ) +") [ "+ _
				Me.CommittedCaption +" / "+ Me.NewCaption +" ]"
			echo  "44.Diff で開く：[ "+ Me.CommittedCaption +"の"+ _
				Me.BaseCaption +" / "+ Me.BaseCaption +" / "+ Me.WorkCaption +" ]"
			echo  "55.Diff で開く：[ "+ Me.BaseCaption + " / "+ Me.WorkCaption +" / "+ Me.CommittedCaption + _
				"の"+ Me.WorkCaption +" ]"
		Else
			If exist( in_File.NewWorkFullPath ) Then
				option_string = ""
			Else
				option_string = " (後は不在)"
			End If

			echo  "1.  Diff で開く：[ "+ _
				Me.SyncedWorkCaption +" / "+ Me.WorkCaption +" / "+ Me.BaseCaption +" ]"+ option_string
			echo  "11. Diff で開く：[ "+ _
				Me.SyncedWorkCaption +" / "+ Me.WorkCaption +" ]      ("+ _
				GetEqualString( in_File.IsWorkSynced ) +")"
			echo  "12. Diff で開く：     [ "+ _
				Me.WorkCaption +" / "+ Me.BaseCaption +" ] ("+ _
				GetEqualString( in_File.IsNewSame ) +")"
			echo  "2.  Diff で開く：[ "+ _
				Me.SyncedWorkCaption +" / "+ Me.SyncedBaseCaption +" / "+ Me.BaseCaption +" ] 左右=("+ _
				GetEqualString( in_File.IsLeftRightSame ) +")"
			echo  "21. Diff で開く：[ "+ _
				Me.SyncedWorkCaption +" / "+ Me.SyncedBaseCaption +" ]      ("+ _
				in_File.c.ToStr( in_File.OldState ) +")"
			echo  "22. Diff で開く：     [ "+ _
				Me.SyncedBaseCaption +" / "+ Me.BaseCaption +" ] ("+ _
				in_File.c.ToStr( in_File.BaseState ) +")"
		End If
		If in_File.Relation = "Clone" Then
			echo  "6. フォルダーを開く"
		Else
			echo  "6. ファイルまたはフォルダーを開く"
		End If
		If Me.IsMergeMode  and  not Me.IsMerged Then
			echo  "7. 3ウェイ マージする"
		End If
		If exist( work_back_up_path ) Then
			echo  "77.Diff で開く [ ワークのバックアップ / 3ウェイ マージ後のワーク ]"
		End If
		If exist( base_back_up_path ) Then
			echo  "78.Diff で開く [ ベースのバックアップ / マージ後のベース ]"
		End If
		If Me.IsEnabledCommit Then
			echo  "Enterのみ: 再スキャンする"
			echo  "8. "+ Me.OldCaption +"をコミットする"
			echo  "9. 戻る"
		Else
			echo  "9 or Enter. 戻る"
		End If
		If in_File.BaseState = in_File.c.New_  or  in_File.BaseState = in_File.c.Deleted  or _
				in_File.WorkState = in_File.c.New_  or  in_File.WorkState = in_File.c.Deleted Then _
			echo  "★改名・結合・分離・部分移動があったときの SyncFilesX の説明を参考。"

		key = Input( "番号 >" )

		If key = ""  and  not Me.IsEnabledCommit Then _
			Exit Do

		key = CInt2( key )

		If not Me.IsMergeMode Then
			If key = 1 Then
				echo_line
				start  GetDiffCmdLine( in_File.NewBaseFullPath, in_File.NewWorkFullPath )
			ElseIf key = 2 Then
				echo_line
				start  GetDiffCmdLine( in_File.OldBaseFullPath, in_File.OldWorkFullPath )
			ElseIf key = 4 Then
				echo_line
				start  GetDiffCmdLine( in_File.OldBaseFullPath, in_File.NewBaseFullPath )
			ElseIf key = 5 Then
				echo_line
				start  GetDiffCmdLine( in_File.OldWorkFullPath, in_File.NewWorkFullPath )
			ElseIf key = 44 Then
				echo_line
				start  GetDiffCmdLine3( in_File.OldBaseFullPath, in_File.NewBaseFullPath, in_File.NewWorkFullPath )
			ElseIf key = 55 Then
				echo_line
				start  GetDiffCmdLine3( in_File.NewBaseFullPath, in_File.NewWorkFullPath, in_File.OldWorkFullPath )
			End If
		Else
			If key = 1 Then
				echo_line
				start  GetDiffCmdLine3( in_File.OldWorkFullPath, in_File.NewWorkFullPath, in_File.NewBaseFullPath )
			ElseIf key = 11 Then
				echo_line
				start  GetDiffCmdLine( in_File.OldWorkFullPath, in_File.NewWorkFullPath )
			ElseIf key = 12 Then
				echo_line
				start  GetDiffCmdLine( in_File.NewWorkFullPath, in_File.NewBaseFullPath )
			ElseIf key = 2 Then
				echo_line
				start  GetDiffCmdLine3( in_File.OldWorkFullPath, in_File.OldBaseFullPath, in_File.NewBaseFullPath )
			ElseIf key = 21 Then
				echo_line
				start  GetDiffCmdLine( in_File.OldWorkFullPath, in_File.OldBaseFullPath )
			ElseIf key = 22 Then
				echo_line
				start  GetDiffCmdLine( in_File.OldBaseFullPath, in_File.NewBaseFullPath )
			End If
		End If
		If key = 77 Then
				echo_line
				start  GetDiffCmdLine( work_back_up_path, in_File.NewWorkFullPath )
		ElseIf key = 78 Then
				echo_line
				start  GetDiffCmdLine( base_back_up_path, in_File.NewBaseFullPath )
		ElseIf key = 6 Then
			Do
				echo_line
				echo  "1. "+ in_File.NewBaseFullPath
				echo  "2. "+ in_File.NewWorkFullPath
				echo  "4. "+ in_File.OldBaseFullPath
				echo  "5. "+ in_File.OldWorkFullPath
				If not IsEmpty( in_File.CommittedWorkFullPath ) Then _
					echo  "6. "+ in_File.CommittedWorkFullPath
				echo_line
				echo  in_File.NewWorkStepPath
				If not Me.IsMergeMode Then
					echo  in_File.GetGuideA( Me.BaseCaption, Me.WorkCaption, Me.BaseIsWas )
					echo  "  > "+ Me.BaseCaption +" ("+ in_File.c.ToStr( in_File.BaseState ) +")："+ a_Set.BaseName
					echo  "  > "+ Me.WorkCaption +" ("+ in_File.c.ToStr( in_File.WorkState ) +")："+ a_Set.WorkName
					If in_File.Relation = "Clone" Then
						echo  "1. "+ Me.BaseCaption +" フォルダーを開く"
						echo  "2. "+ Me.WorkCaption +" フォルダーを開く"
						echo  "4. "+ Me.CommittedCaption +"の"+ Me.BaseCaption +" フォルダーを開く"
						echo  "5. "+ Me.CommittedCaption +"の"+ Me.WorkCaption +" フォルダーを開く"
					Else
						If g_fs.FileExists( in_File.NewBaseFullPath ) Then
							s = ""
						Else
							s = "（不在）"
						End If
						echo  "1. "+ Me.BaseCaption +" / ファイルを開く"+ s
						echo  "11.       / フォルダーを開く"


						If g_fs.FileExists( in_File.NewWorkFullPath ) Then
							s = ""
						Else
							s = "（不在）"
						End If
						echo  "2. "+ Me.WorkCaption +" / ファイルを開く"+ s
						echo  "22.       / フォルダーを開く"


						If g_fs.FileExists( in_File.OldBaseFullPath ) Then
							s = ""
						Else
							s = "（不在）"
						End If
						echo  "4. "+ Me.CommittedCaption +"の"+ Me.BaseCaption +" / ファイルを開く"+ s
						echo  "44.                       / フォルダーを開く"


						If g_fs.FileExists( in_File.OldWorkFullPath ) Then
							s = ""
						Else
							s = "（不在）"
						End If
						echo  "5. "+ Me.CommittedCaption +"の"+ Me.WorkCaption +" / ファイルを開く"+ s
						echo  "55.                       / フォルダーを開く"


						If g_fs.FileExists( in_File.CommittedWorkFullPath ) Then
							s = ""
						Else
							s = "（不在）"
						End If
						echo  "6. "+ Me.CommittedCaption +" / ファイルを開く"+ s
						echo  "66.                       / フォルダーを開く"
					End If
					echo  "9 または Enter: 戻る"
					key = CInt2( Input( "番号 >" ) )
					echo_line

					edit_path = Empty
					folder_path = Empty
					If key = 1 Then
						edit_path = in_File.NewBaseFullPath
					ElseIf key = 11 Then
						folder_path = in_File.NewBaseFullPath
					ElseIf key = 2 Then
						edit_path = in_File.NewWorkFullPath
					ElseIf key = 22 Then
						folder_path = in_File.NewWorkFullPath
					ElseIf key = 4 Then
						edit_path = in_File.OldBaseFullPath
					ElseIf key = 44 Then
						folder_path = in_File.OldBaseFullPath
					ElseIf key = 5 Then
						edit_path = in_File.OldWorkFullPath
					ElseIf key = 55 Then
						folder_path = in_File.OldWorkFullPath
					ElseIf key = 6 Then
						edit_path = in_File.CommittedWorkFullPath
					ElseIf key = 66 Then
						folder_path = in_File.CommittedWorkFullPath
					ElseIf key = 9  or  key = 0 Then
						Exit Do
					End If
				Else
					echo  "  > "+ Me.SyncedWorkCaption +" ("+ in_File.c.ToStr( in_File.OldState ) +")："+ a_Set.BaseName
					echo  "  > "+ Me.BaseCaption +" ("+ in_File.c.ToStr( in_File.BaseState ) +")："+ a_Set.WorkName


					If g_fs.FileExists( in_File.OldWorkFullPath ) Then
						s = ""
					Else
						s = "（不在）"
					End If
					echo  "1. "+ Me.SyncedWorkCaption +" / ファイルを開く"+ s
					echo  "11.   / フォルダーを開く"


					If g_fs.FileExists( in_File.NewBaseFullPath ) Then
						s = ""
					Else
						s = "（不在）"
					End If
					echo  "2. "+ Me.BaseCaption +" / ファイルを開く"+ s
					echo  "22.   / フォルダーを開く"


					If g_fs.FileExists( in_File.OldBaseFullPath ) Then
						s = ""
					Else
						s = "（不在）"
					End If
					echo  "4. "+ Me.SyncedBaseCaption +" / ファイルを開く"+ s
					echo  "44.   / フォルダーを開く"


					If g_fs.FileExists( in_File.NewWorkFullPath ) Then
						s = ""
					Else
						s = "（不在）"
					End If
					echo  "5. "+ Me.WorkCaption +" / ファイルを開く"+ s
					echo  "55.   / フォルダーを開く"


					If IsEmpty( a_Set.CommittedWorkRootStepPath ) Then
						If g_fs.FileExists( in_File.CommittedWorkFullPath ) Then
							s = ""
						Else
							s = "（不在）"
						End If
						echo  "6. "+ Me.CommittedCaption +" / ファイルを開く"+ s
						echo  "66.                       / フォルダーを開く"
					End If

					echo  "9 または Enter: 戻る"
					key = CInt2( Input( "番号 >" ) )
					echo_line

					edit_path = Empty
					folder_path = Empty
					If key = 1 Then
						edit_path = in_File.OldWorkFullPath
					ElseIf key = 11 Then
						folder_path = in_File.OldWorkFullPath
					ElseIf key = 2 Then
						edit_path = in_File.NewBaseFullPath
					ElseIf key = 22 Then
						folder_path = in_File.NewBaseFullPath
					ElseIf key = 4 Then
						edit_path = in_File.OldBaseFullPath
					ElseIf key = 44 Then
						folder_path = in_File.OldBaseFullPath
					ElseIf key = 5 Then
						edit_path = in_File.NewWorkFullPath
					ElseIf key = 55 Then
						folder_path = in_File.NewWorkFullPath
					ElseIf key = 6 Then
						edit_path = in_File.CommittedWorkFullPath
					ElseIf key = 66 Then
						folder_path = in_File.CommittedWorkFullPath
					ElseIf key = 9  or  key = 0 Then
						Exit Do
					End If
				End If

				If in_File.Relation = "Clone"  and  not IsEmpty( edit_path ) Then
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
							OpenFolder  folder_path
						Else
							OpenFolder  parent_path
						End If
					End If
				End If
			Loop
		ElseIf key = 7 Then
			echo_line
			way_count = 4
			If not exist( work_back_up_path ) Then
				Set ec = new EchoOff
				copy_ren  in_File.NewWorkFullPath, work_back_up_path
				ec = Empty
				echo  "ワークのバックアップを作成しました："""+ work_back_up_path +""""
				echo  "バックアップはコミット時に削除されます。"
			End If

			If way_count = 3 Then
				echo  ""
				echo  "3ウェイ マージを行います。 結果をワークに格納します。"
				echo  "  Base ："+ in_File.OldBaseStepPath
				echo  "  Left ："+ in_File.NewBaseStepPath
				echo  "  Right："+ in_File.NewWorkStepPath
				echo  "  Out  ："+ in_File.NewWorkStepPath
				echo  "Enter のみ：マージの設定ファイルを使わない。"
				setting_path = InputPath( "マージの設定ファイル >", _
					c.CheckFileExists or c.AllowEnterOnly )

				If setting_path = "" Then
					merge_ = Empty
				Else
					Set merge_ = LoadThreeWayMergeOptionClass( setting_path )
				End If


				If TryStart(e) Then  On Error Resume Next

					ThreeWayMerge  in_File.OldBaseFullPath, _
						in_File.NewBaseFullPath,  work_back_up_path, _
						in_File.NewWorkFullPath,  merge_

				If TryEnd Then  On Error GoTo 0
				If e.num = E_Conflict  Then  e.Clear
				If e.num <> 0 Then  e.Raise
			Else
				Assert  way_count = 4

				If not exist( base_back_up_path ) Then
					Set ec = new EchoOff
					copy_ren  in_File.NewBaseFullPath, base_back_up_path
					ec = Empty
					echo  "ベースのバックアップを作成しました："""+ base_back_up_path +""""
					echo  "バックアップはコミット時に削除されます。"
				End If

				echo  ""
				echo  "4ウェイ マージを行います。 結果をワークとベースに格納します。" 
				Pause

				FourWayMerge _
					in_File.OldBaseFullPath,  base_back_up_path,  in_File.NewBaseFullPath, _
					in_File.OldWorkFullPath,  work_back_up_path,  in_File.NewWorkFullPath, Empty
			End If
		ElseIf key = 8  and  Me.IsEnabledCommit Then
			If IsEmpty( in_File.CommittedWorkFullPath ) Then
				warning_ = Empty
				If in_File.Relation = "SameOrNotSame" Then
					If not exist( in_File.OldWorkFullPath )  and  not exist( in_File.OldBaseFullPath ) Then
					ElseIf in_File.IsSameFunction( in_File.OldWorkFullPath, in_File.OldBaseFullPath ) Then
						If not exist( in_File.NewWorkFullPath )  and  not exist( in_File.NewBaseFullPath ) Then
						ElseIf not in_File.IsSameFunction( in_File.NewWorkFullPath, in_File.NewBaseFullPath ) Then
							warning_ = "★[WARNING] "+ Me.BaseCaption +"と"+ Me.WorkCaption +_
								"で内容が同じだったのが異なるようになりました。"
						End If
					Else
						If not exist( in_File.NewWorkFullPath )  and  not exist( in_File.NewBaseFullPath ) Then
						ElseIf in_File.IsSameFunction( in_File.NewWorkFullPath, in_File.NewBaseFullPath ) Then
							warning_ = "★[WARNING] "+ Me.BaseCaption +"と"+ Me.WorkCaption +_
								"で内容が異なっていたのが同じになりました。"
						End If
					End If
				ElseIf in_File.Relation = "NotSame" Then
					If in_File.IsSameFunction( in_File.NewWorkFullPath, in_File.NewBaseFullPath ) Then
						warning_ = "★[WARNING] "+ Me.BaseCaption +"と"+ Me.WorkCaption +_
							"で内容が同じになってしまっています。"
					End If
				Else
					If not in_File.IsSameFunction( in_File.NewWorkFullPath, in_File.NewBaseFullPath ) Then
						warning_ = "★[WARNING] "+ Me.BaseCaption +"と"+ Me.WorkCaption +_
							"で内容が異なります。"
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

				If Me.IsMergeMode Then
					Do
						key = Input( "右→前、後→左 のコピーをします。よろしいですか(y/n)" )
						If key = "Y"  or  key = "y"  or  key = "N"  or  key = "n" Then
							Exit Do
						End If
					Loop
				End If

				If key = "Y" or key = "y" Then
					echo_line

					If exist( work_back_up_path ) Then _
						del  work_back_up_path
					If exist( base_back_up_path ) Then _
						del  base_back_up_path

					in_File.Commit
					echo  "コミットしました。"
					is_commit = True
				End If
			Else
				echo_line
				If exist( in_File.NewWorkFullPath ) Then
					copy_ren  in_File.NewWorkFullPath,  in_File.CommittedWorkFullPath
				Else
					del  in_File.CommittedWorkFullPath
				End If

				Me.AddToMergedList  a_Set, in_File
				Me.SaveMergedList

				echo  "コミットしました。"
				is_commit = True
			End If
		ElseIf key = 88 Then
			echo  ""
			echo  "次の入力では、拡張子の入力しないでください。コピー先の拡張子になります。"
			path = Input( "コミット後の内容が入ったファイルのパス >" )
			If path <> "" Then
				echo_line
				path = GetFullPath( path +"."+ g_fs.GetExtensionName( _
					in_File.NewWorkFullPath ), Empty )
				copy_ren  path,  in_File.NewWorkFullPath
			End If
		ElseIf key = 0 Then
			'// 再スキャンは、メニューを表示するときに行う
		ElseIf key = 9 Then
			Exit Do
		End If
		echo_line
	Loop
End Sub


 
'***********************************************************************
'* Method: GetWritableFolders
'*
'* Name Space:
'*    SyncFilesX_Class::GetWritableFolders
'***********************************************************************
Function  GetWritableFolders()
	Const  c_NotCaseSensitive = 1
	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.CompareMode = c_NotCaseSensitive

	Me_GetAttributeNames  at_path,  at_base,  at_s_path,  at_s_base
	attribute_names = Array( at_path,  at_base,  at_s_path,  at_s_base )

	For Each  a_sync_set  In Me.Sets.Items
		roots = Array( _
			a_sync_set.NewWorkRootFullPath, _
			a_sync_set.NewBaseRootFullPath, _
			a_sync_set.OldWorkRootFullPath, _
			a_sync_set.OldBaseRootFullPath )
		For Each  root_path  In  roots
			dic( root_path ) = True
		Next

		If not Me.IsMergeMode Then
			ReDim Preserve  roots( 1 ) '// Cut attribute replacing from "..\" to "_parent\"
		End If

		For Each  tag  In  a_sync_set.SetTag.selectNodes( "./File | ./Folder" )
			For i=0 To UBound( roots )
				step_path = tag.getAttribute( attribute_names(i) )
				If InStr( step_path, ".." ) >= 1 Then
					dic( GetFullPath( step_path,  roots(i) ) ) = True
				End If
			Next
		Next

		dic( a_sync_set.CommittedWorkRootFullPath ) = True
	Next

	GetWritableFolders = dic.Keys
End Function


 
'***********************************************************************
'* Method: Me_GetAttributeNames
'*
'* Name Space:
'*    SyncFilesX_Class::Me_GetAttributeNames
'***********************************************************************
Private Sub  Me_GetAttributeNames( at_path,  at_base,  at_s_path,  at_s_base )
	If not Me.IsMergeMode Then
		at_path   = "path"         '// attribute_name_of_path
		at_base   = "base"         '// attribute_name_of_base
		at_s_path = "synced_path"  '// attribute_name_of_synchronized_path
		at_s_base = "synced_base"  '// attribute_name_of_synchronized_base
	Else
		at_path   = "merged_path"
		at_base   = "right_path"
		at_s_path = "left_path"
		at_s_base = "base_path"
	End If
End Sub


 
'***********************************************************************
'* Method: FindMoved
'*
'* Name Space:
'*    SyncFilesX_Class::FindMoved
'***********************************************************************
Sub  FindMoved( in_CurrentRoot )
	AssertD_TypeName  in_CurrentRoot, "SyncFilesX_SetClass"

	Const  c_NotCaseSensitive = 1

	Set base_moved_files = CreateObject( "Scripting.Dictionary" )
	base_moved_files.CompareMode = c_NotCaseSensitive

	Set work_moved_files = CreateObject( "Scripting.Dictionary" )
	work_moved_files.CompareMode = c_NotCaseSensitive

	Set moved = CreateObject( "Scripting.Dictionary" )
	moved.CompareMode = c_NotCaseSensitive


	'// Set "moved_files" as dictionary of ModuleAssort_MovedFileClass. Key = file name
	For Each  file  In  in_CurrentRoot.Files.Items
		AssertD_TypeName  file,  "SyncFilesX_FileClass"

		For Each  t  In DicTable( Array( _
				"moved_files",     "state",         "file_path",  Empty, _
				base_moved_files,  file.BaseState,  file.NewBaseStepPath, _
				work_moved_files,  file.WorkState,  file.NewWorkStepPath ) )

			sign = t("state")
			If sign <> file.c.NotExist Then

				file_name_as_key = g_fs.GetFileName( t("file_path") )

				Set moved_file = Dic_addNewObject( t("moved_files"), _
					"ModuleAssort_MovedFileClass",  file_name_as_key,  True )

					Transpose : For i=0 To 1 : If i=1 Then

				If sign = file.c.New_ Then
					moved_file.DestinationFoldersStepPaths.Add  t_folder_path
				ElseIf sign = file.c.Deleted Then
					moved_file.SourceFoldersStepPaths.Add  t_folder_path
				Else
					moved_file.NotMovedFoldersStepPaths.Add  t_folder_path
				End If

					Else ' Transpose

					t_folder_path = g_fs.GetParentFolderName( t("file_path") )
					If t_folder_path = "" Then
						t_folder_path = t("file_path")
					End If

					Transpose : End If : Next
			End If
		Next
	Next


	'// Set "moved" as dictionary of array of string. Key = t_move_pattern
	'//     複数のファイルがあるフォルダーの移動をまとめる。 移動パターンごとにまとめる。
	'//     例："FolderX\A.txt" の "FolderX" と "FolderX\B.txt" の "FolderX" を同じキーに関連する配列へ。
	For Each  moved_files  In  Array( base_moved_files,  work_moved_files )
		For Each  a_file_name  In  moved_files.Keys
			Set moved_file = moved_files( a_file_name )

				Transpose : For i=0 To 1 : If i=1 Then

			Dic_addInArrayItem  moved,  t_move_pattern,  a_file_name

				Else ' Transpose

				t_move_pattern = moved_file.SourceFoldersStepPaths.CSV +",:,"+ _
					moved_file.DestinationFoldersStepPaths.CSV

				Transpose : End If : Next
		Next
	Next


	'// TODO: Set "moved" : 移動前後のパスの右側で共通の親フォルダーをカットする。
	'//     例："A\C"->"B\C" to "A"->"B"
	'//For Each  file_names  In  moved.Items
	'//Next


	'// 表示する
	For Each  file_names  In  moved.Items

		'// Set "base_file", "work_file", "is_base_moved", "is_work_moved"
		a_file_name = file_names(0)
		If base_moved_files.Exists( a_file_name ) Then
			Set base_file = base_moved_files( a_file_name )
			AssertD_TypeName  base_file, "ModuleAssort_MovedFileClass"
		Else
			Assert  work_moved_files.Exists( a_file_name )
			base_file = Empty
		End If

		If work_moved_files.Exists( a_file_name ) Then
			Set work_file = work_moved_files( a_file_name )
			AssertD_TypeName  work_file, "ModuleAssort_MovedFileClass"
		Else
			Assert  base_moved_files.Exists( a_file_name )
			work_file = Empty
		End If

		is_base_moved = False
		If not IsEmpty( base_file ) Then
			If base_file.SourceFoldersStepPaths.Count >= 1 Then
				If base_file.DestinationFoldersStepPaths.Count >= 1 Then
					is_base_moved = True
				End If
			End If
		End If

		is_work_moved = False
		If not IsEmpty( work_file ) Then
			If work_file.SourceFoldersStepPaths.Count >= 1 Then
				If work_file.DestinationFoldersStepPaths.Count >= 1 Then
					is_work_moved = True
				End If
			End If
		End If


		If is_base_moved  or  is_work_moved Then

			'// 表示する
			echo_line

			If is_base_moved Then

				'// echo
				source_path = base_file.SourceFoldersStepPaths( 0 )
				destionation_path = base_file.DestinationFoldersStepPaths( 0 )

				echo  "ベースは、"""+ source_path +""" から """+ _
					destionation_path +""" に移動したようです。"

				'// echo
				shared_sub = GetCommonSubPath( source_path,  destionation_path,  False )
				If shared_sub <> "" Then

					echo  "    共通のサブ フォルダー："""+ shared_sub +""""
				End If
			End If
			If is_work_moved Then

				'// echo
				source_path = work_file.SourceFoldersStepPaths( 0 )
				destionation_path = work_file.DestinationFoldersStepPaths( 0 )

				echo  "ワークは、"""+ source_path +""" から """+ _
					destionation_path +""" に移動したようです。"

				'// echo
				shared_sub = GetCommonSubPath( source_path,  destionation_path,  False )
				If shared_sub <> "" Then

					echo  "    共通のサブ フォルダー："""+ shared_sub +""""
				End If
			End If

			echo  "    参考にしたファイルの名前："+ """"+ _
				Replace( file_names.CSV,  ",",  """, """ ) +""""

			echo  "追加するタグ："

				Transpose : For i=0 To 1 : If i=1 Then

			echo  "    <Folder  synced_base="""+ t_synced_base + """ synced_path="""+ t_synced_path + _
				""" base="""+ t_base + """ path="""+ t_path + """/>"

				Else ' Transpose

				If is_base_moved Then
					t_synced_base = base_file.SourceFoldersStepPaths( 0 )
					t_base = base_file.DestinationFoldersStepPaths( 0 )
				End If

				If is_work_moved Then
					t_synced_path = work_file.SourceFoldersStepPaths( 0 )
					t_path = work_file.DestinationFoldersStepPaths( 0 )
				End If

				If not  is_base_moved Then
					t_synced_base = base_file.NotMovedFoldersStepPaths( 0 )
					t_base = base_file.NotMovedFoldersStepPaths( 0 )
				End If

				If not  is_work_moved Then
					t_synced_path = work_file.NotMovedFoldersStepPaths( 0 )
					t_path = work_file.NotMovedFoldersStepPaths( 0 )
				End If

				Transpose : End If : Next

			synced_base_path = t_synced_base
			synced_work_path = t_synced_path
			base_path = t_base
			work_path = t_path


			If not  is_base_moved  <>  not  is_work_moved Then

				If not  is_base_moved Then
					echo  "ベースも移動したら追加するタグ："
				Else
					echo  "ワークも移動したら追加するタグ："
				End If

					Transpose : For i=0 To 1 : If i=1 Then

				echo  "    <Folder  synced_base="""+ t_synced_base + """ synced_path="""+ t_synced_path + _
					""" base="""+ t_base + """ path="""+ t_path + """/>"

					Else ' Transpose

					t_synced_base = synced_base_path
					t_synced_path = synced_work_path
					t_base = base_path
					t_path = work_path

					If not  is_base_moved Then
						t_base = t_path
					Else
						t_path = t_base
					End If

					Transpose : End If : Next
			End If
		End If
	Next
End Sub


 
End Class
'* Section: Global


 
'***********************************************************************
'* Class: SyncFilesX_SetClass
'***********************************************************************
Class  SyncFilesX_SetClass
	Public  SetTag

	Public  ID_Label
	Public  BaseName
	Public  WorkName
	Public  IsShow

	'// For base -> work synchronization
	Public  NewBaseRootStepPath  '// NewCaption(Current) + BaseCaption,  Right
	Public  NewWorkRootStepPath  '// NewCaption(Current) + WorkCaption,  Merged
	Public  OldBaseRootStepPath  '// OldCaption(Commit)  + BaseCaption,  Base
	Public  OldWorkRootStepPath  '// OldCaption(Commit)  + WorkCaption,  Left
	Public  CommittedWorkRootStepPath  '// CommittedCaption in IsMergeMode

	Public  NewBaseRootFullPath  '// NewCaption(Current) + BaseCaption
	Public  NewWorkRootFullPath  '// NewCaption(Current) + WorkCaption
	Public  OldBaseRootFullPath  '// OldCaption(Commit)  + BaseCaption
	Public  OldWorkRootFullPath  '// OldCaption(Commit)  + WorkCaption
	Public  CommittedWorkRootFullPath  '// CommittedCaption in IsMergeMode

	'// For old -> new user setting update (for ChangedToAttachedMode() )
	Property Get  OldUserSetFullPath() : OldUserSetFullPath = NewBaseRootFullPath : End Property
	Property Get  NewUserSetFullPath() : NewUserSetFullPath = NewWorkRootFullPath : End Property
	Property Get  OldDefaultFullPath() : OldDefaultFullPath = OldBaseRootFullPath : End Property
	Property Get  NewDefaultFullPath() : NewDefaultFullPath = OldWorkRootFullPath : End Property

	'// ...
	Public  Files        '// as ArrayClass of SyncFilesX_FileClass
	Public  PathXML_Dic  '// as dictionary of IXMLDOMElement, key=SyncFilesX_FileClass::NewWorkStepPath
	Public  MergedList   '// as dictionary of SyncFilesX_MergedClass. Key = NewWorkFullPath
	Public  MergedListPath

	Private Sub  Class_Initialize()
		Me.IsShow = True
		Set Me.Files = new ArrayClass

		Const  c_NotCaseSensitive = 1
		Set Me.PathXML_Dic = CreateObject( "Scripting.Dictionary" )
		Me.PathXML_Dic.CompareMode = c_NotCaseSensitive

		Set Me.MergedList = CreateObject( "Scripting.Dictionary" )
		Me.MergedList.CompareMode = c_NotCaseSensitive
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

	Public Function  GetIsAllBaseSynced()
		GetIsAllBaseSynced = True
		For Each  file  In Me.Files.Items
			If not file.IsBaseSynced Then
				GetIsAllBaseSynced = False
				Exit Function
			End If
		Next
	End Function
End Class
'* Section: Global


 
'***********************************************************************
'* Class: SyncFilesX_FileClass
'***********************************************************************
Class  SyncFilesX_FileClass
	Public  NewBaseStepPath  '// or Right
	Public  NewWorkStepPath  '// or Merged
	Public  OldBaseStepPath  '// or Base
	Public  OldWorkStepPath  '// or Left

	Public  NewBaseFullPath
	Public  NewWorkFullPath
	Public  OldBaseFullPath
	Public  OldWorkFullPath
	Public  CommittedWorkFullPath

	Public  IsMergeMode

	Public  Caption
	Public  Relation  '// "SameOrNotSame", "Same", "NotSame", "Clone", "Compatible"
		'// "Clone"= フォルダーの中のすべてのファイルが "Same"

	Public  IsNewSame  '// IsSameFunction( NewWorkFullPath, NewBaseFullPath )
	Public  IsOldSame  '// IsSameFunction( OldWorkFullPath, OldBaseFullPath )
	Public  BaseState  '// Me.c ( Same, Changed, New_, NotExist, Deleted )
	Public  WorkState  '// Me.c ( Same, Changed, New_, NotExist, Deleted )
	Public  OldState   '// Me.c ( Same, Changed, New_, NotExist, Deleted )

	Public  IsSynced  '// IsBaseSynced and IsWorkSynced
	Public  IsBaseSynced  '// NewBase = OldBase
	Public  IsWorkSynced  '// NewWork = OldWork
	Public  IsLeftRightSame  '// OldWork = NewBase
	Public  IsCommitSynced   '// Merged(Work) = Committed
	Public  IsAbleToAutoCommit           '// Able to "Commit()"
	Public  IsAbleToCopyForSameRelation  '// Able to "CopyForSameRelation()"
	Public  IsAbleToCopyFromUpdatedAuto  '// Able to "CopyFromUpdatedAuto()"
	Public  IsAbleToCopyFromBaseAuto     '// Able to "CopyFromBaseAuto()"
	Public  IsAbleToSyncForTest          '// Able to "SyncForTest()"

	Public  IsSameFunction

	Public  c  '// as SyncFilesX_FileClassConsts

	Private Sub  Class_Initialize()
		Set c = get_SyncFilesX_FileClassConsts()
		Set Me.IsSameFunction   = GetRef( "SyncFilesX_FileClass_isSameDefault" )
	End Sub


 
'***********************************************************************
'* Method: Scan
'*
'* Name Space:
'*    SyncFilesX_FileClass::Scan
'***********************************************************************
Sub  Scan()
	Set file = Me

	If exist( file.NewBaseFullPath )  or  exist( file.NewWorkFullPath ) Then
		file.IsNewSame = Me.IsSameFunction( file.NewBaseFullPath, file.NewWorkFullPath )
	Else
		file.IsNewSame = Empty  '// Not True
	End If

	If exist( file.OldBaseFullPath )  or  exist( file.OldWorkFullPath ) Then
		file.IsOldSame = Me.IsSameFunction( file.OldBaseFullPath, file.OldWorkFullPath )
	Else
		file.IsOldSame = Empty  '// Not True
	End If

	If exist( file.NewBaseFullPath )  or  exist( file.OldBaseFullPath ) Then
		file.IsBaseSynced = Me.IsSameFunction( file.NewBaseFullPath, file.OldBaseFullPath )
	Else
		file.IsBaseSynced = Empty
	End If

	If exist( file.NewWorkFullPath )  or  exist( file.OldWorkFullPath ) Then
		file.IsWorkSynced = Me.IsSameFunction( file.NewWorkFullPath, file.OldWorkFullPath )
	Else
		file.IsWorkSynced = Empty
	End If

	If exist( file.OldWorkFullPath )  or  exist( file.NewBaseFullPath ) Then
		file.IsLeftRightSame = Me.IsSameFunction( file.OldWorkFullPath, file.NewBaseFullPath )
	Else
		file.IsLeftRightSame = Empty
	End If

	If exist( file.CommittedWorkFullPath )  or  exist( file.NewWorkFullPath ) Then
		file.IsCommitSynced = Me.IsSameFunction( file.CommittedWorkFullPath, file.NewWorkFullPath )
	Else
		file.IsCommitSynced = True
	End If

	If IsEmpty( file.IsWorkSynced ) Then
		If IsEmpty( file.IsBaseSynced ) Then
			file.IsSynced = True
		Else
			file.IsSynced = file.IsBaseSynced
		End If
	Else
		If IsEmpty( file.IsBaseSynced ) Then
			file.IsSynced = file.IsWorkSynced
		Else
			file.IsSynced = ( file.IsWorkSynced  and  file.IsBaseSynced ) <> 0
		End If
	End If

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

	If exist( file.OldBaseFullPath ) Then
		If exist( file.OldWorkFullPath ) Then
			If file.IsOldSame Then
				file.OldState = Me.c.Same
			Else
				file.OldState = Me.c.Changed
			End If
		Else
			file.OldState = Me.c.Deleted
		End If
	Else
		If exist( file.OldWorkFullPath ) Then
			file.OldState = Me.c.New_
		Else
			file.OldState = Me.c.NotExist
		End If
	End If


	file.IsAbleToAutoCommit = _
		not file.IsSynced  and _
		( file.IsNewSame or IsEmpty( file.IsNewSame ) )


	'// Set "file.IsAbleToCopyFromUpdatedAuto"
	If file.IsOldSame  or  IsEmpty( file.IsOldSame ) Then
		If file.IsNewSame  or  IsEmpty( file.IsNewSame ) Then
			is_able = False
		Else
			If file.IsBaseSynced <> file.IsWorkSynced Then
				is_able = True
			ElseIf IsEmpty( file.IsBaseSynced )  and  not file.IsWorkSynced Then
				is_able = True
			ElseIf IsEmpty( file.IsWorkSynced )  and  not file.IsBaseSynced Then
				is_able = True
			Else
				is_able = False
			End If
		End If
	Else
		is_able = False
	End If
	file.IsAbleToCopyFromUpdatedAuto = is_able


	'// Set "file.IsAbleToCopyForSameRelation"
	file.IsAbleToCopyForSameRelation = _
		( file.IsAbleToCopyFromUpdatedAuto  and  file.Relation = "Same" )


	'// Set "file.IsAbleToCopyFromBaseAuto"
	If file.IsOldSame  or  IsEmpty( file.IsOldSame ) Then
		If file.IsNewSame  or  IsEmpty( file.IsNewSame ) Then
			is_able = False
		Else
			If not file.IsBaseSynced Then
				If file.IsWorkSynced or IsEmpty( file.IsWorkSynced ) Then
					is_able = True
				Else
					is_able = False
				End If
			Else
				is_able = False
			End If
		End If
	Else
		is_able = False
	End If
	file.IsAbleToCopyFromBaseAuto = is_able


	is_able = _
		( not file.IsOldSame  and  not IsEmpty( file.IsOldSame )  and _
		not file.IsNewSame  and  not IsEmpty( file.IsNewSame )  and _
		not file.IsBaseSynced ) <> 0  '// "file.IsWorkSynced" is "True" or "False"

	is_able = is_able  or  file.IsAbleToCopyFromBaseAuto

	is_able = is_able  or _
		file.WorkState = Me.c.New_     or  file.BaseState = Me.c.New_  or _
		file.WorkState = Me.c.Deleted  or  file.BaseState = Me.c.Deleted
		'// Not copy but commit

	file.IsAbleToSyncForTest = ( is_able <> 0 )
End Sub


 
'***********************************************************************
'* Method: GetIsMergeSynced
'*
'* Name Space:
'*    SyncFilesX_FileClass::GetIsMergeSynced
'***********************************************************************
Function  GetIsMergeSynced()
	Set file = Me

	If file.IsOldSame  and  file.IsBaseSynced  Then  '// Oldes=Base-Left, Bases=Base-Right
		GetIsMergeSynced = True
	ElseIf file.OldState = file.c.Same  and  file.BaseState = file.c.Changed Then
		GetIsMergeSynced = True
	ElseIf file.OldState = file.c.Changed  and  file.BaseState = file.c.Same Then
		GetIsMergeSynced = True
	ElseIf file.OldState = file.c.New_  and  file.BaseState = file.c.NotExist Then
		GetIsMergeSynced = True
	ElseIf file.OldState = file.c.NotExist  and  file.BaseState = file.c.New_ Then
		GetIsMergeSynced = True
	ElseIf file.OldState = file.c.NotExist  and  file.BaseState = file.c.NotExist Then
		GetIsMergeSynced = True
	ElseIf file.OldState = file.c.Deleted  and  file.BaseState = file.c.Deleted Then
		GetIsMergeSynced = True
	ElseIf file.BaseState = file.c.New_  and  file.IsLeftRightSame Then
		GetIsMergeSynced = True
	Else
		GetIsMergeSynced = False
	End If
End Function


 
'***********************************************************************
'* Method: Commit
'*
'* Name Space:
'*    SyncFilesX_FileClass::Commit
'***********************************************************************
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


 
'***********************************************************************
'* Method: CopyFromUpdatedAuto
'*
'* Name Space:
'*    SyncFilesX_FileClass::CopyFromUpdatedAuto
'***********************************************************************
Sub  CopyFromUpdatedAuto()
	Set file = Me

	If file.IsOldSame  or  IsEmpty( file.IsOldSame ) Then
		If not file.IsBaseSynced  and  ( file.IsWorkSynced or IsEmpty( file.IsWorkSynced ) ) Then
			If exist( file.NewBaseFullPath ) Then
				copy_ren  file.NewBaseFullPath, file.NewWorkFullPath
			Else
				del  file.NewWorkFullPath
			End If
		ElseIf ( file.IsBaseSynced or IsEmpty( file.IsBaseSynced ) )  and  not file.IsWorkSynced Then
			If exist( file.NewWorkFullPath ) Then
				copy_ren  file.NewWorkFullPath, file.NewBaseFullPath
			Else
				del  file.NewBaseFullPath
			End If
		End If
	End If

	file.Scan
End Sub


 
'***********************************************************************
'* Method: CopyFromBaseAuto
'*
'* Name Space:
'*    SyncFilesX_FileClass::CopyFromBaseAuto
'***********************************************************************
Sub  CopyFromBaseAuto()
	Set file = Me

	If file.IsOldSame  or  IsEmpty( file.IsOldSame ) Then
		m_CopyFromBaseAuto_Sub
	End If

	file.Scan
End Sub


 
'***********************************************************************
'* Method: m_CopyFromBaseAuto_Sub
'*
'* Name Space:
'*    SyncFilesX_FileClass::m_CopyFromBaseAuto_Sub
'***********************************************************************
Sub  m_CopyFromBaseAuto_Sub()
	Set file = Me

	If not file.IsBaseSynced  and  ( file.IsWorkSynced or IsEmpty( file.IsWorkSynced ) ) Then
		If exist( file.NewBaseFullPath ) Then
			copy_ren  file.NewBaseFullPath, file.NewWorkFullPath
		Else
			del  file.NewWorkFullPath
		End If
	End If
End Sub


 
'***********************************************************************
'* Method: SyncForTest
'*
'* Name Space:
'*    SyncFilesX_FileClass::SyncForTest
'***********************************************************************
Sub  SyncForTest()
	Set file = Me

	If file.IsAbleToSyncForTest Then
		If file.IsOldSame or IsEmpty( file.IsOldSame ) Then
			m_CopyFromBaseAuto_Sub
		Else
			If exist( file.NewBaseFullPath ) Then
				If not file.IsBaseSynced  and  not file.IsNewSame Then
					If exist( file.NewWorkFullPath ) Then
						CreateFile  file.NewWorkFullPath, _
							ReadFile( file.NewBaseFullPath ) + vbCRLF + _
							ReadFile( file.NewWorkFullPath )
					Else
						copy_ren  file.NewBaseFullPath, file.NewWorkFullPath
					End If
				End If
			End If
		End If
	End If

	file.Scan
End Sub


 
'***********************************************************************
'* Method: GetStateMark
'*
'* Name Space:
'*    SyncFilesX_FileClass::GetStateMark
'***********************************************************************
Function  GetStateMark()
	Set file = Me
	If not Me.IsMergeMode Then
		GetStateMark = Left( file.c.ToStr( file.BaseState ), 1 ) + _
			Left( GetEqualString( file.IsNewSame ), 1 ) + _
			Left( file.c.ToStr( file.WorkState ), 1 )
	Else
		GetStateMark = Left( file.c.ToStr( file.OldState ), 1 ) + _
			Left( GetEqualString( file.IsLeftRightSame ), 1 ) + _
			Left( file.c.ToStr( file.BaseState ), 1 )
	End If
End Function


 
'***********************************************************************
'* Method: GetSameMark
'*
'* Name Space:
'*    SyncFilesX_FileClass::GetSameMark
'***********************************************************************
Function  GetSameMark()
	If Me.Relation = "Same" Then
		GetSameMark = "="
	Else
		GetSameMark = " "
	End If
End Function


 
'***********************************************************************
'* Method: GetCloneMark
'*
'* Name Space:
'*    SyncFilesX_FileClass::GetCloneMark
'***********************************************************************
Function  GetCloneMark()
	If Me.Relation = "Clone" Then
		GetCloneMark = "\"
	Else
		GetCloneMark = ""
	End If
End Function


 
'***********************************************************************
'* Method: GetTypeName
'*
'* Name Space:
'*    SyncFilesX_FileClass::GetTypeName
'***********************************************************************
Function  GetTypeName()
	If Me.Relation = "Clone" Then
		GetTypeName = "フォルダー"
	Else
		GetTypeName = "ファイル"
	End If
End Function


 
'***********************************************************************
'* Method: GetGuideA
'*
'* Name Space:
'*    SyncFilesX_FileClass::GetGuideA
'***********************************************************************
Function  GetGuideA( BaseCaption, WorkCaption, BaseIsWas )
	type_name = Me.GetTypeName()

	If Me.Relation = "SameOrNotSame" Then
		If IsEmpty( Me.IsOldSame ) Then
			GetGuideA = ""
		ElseIf Me.IsOldSame Then
			GetGuideA = BaseCaption +" "+ type_name +"と"+ WorkCaption +" "+ type_name +_
				"は「同じ内容」"+ BaseIsWas
		Else
			GetGuideA = BaseCaption +" "+ type_name +"と"+ WorkCaption +" "+ type_name +_
				"は「異なる内容」"+ BaseIsWas
		End If
	ElseIf Me.Relation = "NotSame" Then
		GetGuideA = BaseCaption +" "+ type_name +"と"+ WorkCaption +" "+ type_name +_
			"は「ほぼ」同じ内容になるべきとのことです。"
	Else
		If Me.IsNewSame  or  IsEmpty( Me.IsNewSame ) Then
			GetGuideA = BaseCaption +" "+ type_name +"と"+ WorkCaption +" "+ type_name +_
				"は「同じ内容」です。"
		Else
			GetGuideA = BaseCaption +" "+ type_name +"と"+ WorkCaption +" "+ type_name +_
				"が「同じ内容」になるべきとのことです。"
		End If
	End If
End Function


 
End Class
'* Section: Global


 
'***********************************************************************
'* Class: SyncFilesX_MergedClass
'***********************************************************************
Class  SyncFilesX_MergedClass
	Public  BaseStepPath
	Public  BaseFullPath
	Public  BaseHash

	Public  LeftStepPath
	Public  LeftFullPath
	Public  LeftHash

	Public  RightStepPath
	Public  RightFullPath
	Public  RightHash

	Public  MergedStepPath
	Public  MergedFullPath
	Public  MergedHash
End Class
'* Section: Global


 
'*************************************************************************
'  <<< [SyncFilesX_FileClass_isSameDefault] >>> 
'*************************************************************************
Function  SyncFilesX_FileClass_isSameDefault( FileOrFolderA_Path, FileOrFolderB_Path )
	Set ec = new EchoOff
	SyncFilesX_FileClass_isSameDefault = _
		IsSameFolder( FileOrFolderA_Path, FileOrFolderB_Path, Empty )
End Function


 
'***********************************************************************
'* Function: new_SyncFilesT_Class_Array
'***********************************************************************
Public Function  new_SyncFilesT_Class_Array( in_Path )
	Set paths = ArrayFromWildcard2( in_Path )
	Set objects = new ArrayClass
	For Each  path  In  paths.FullPaths
		Set object = new SyncFilesT_Class

		object.Run  path, Empty, Empty

		objects.Add  object
	Next
	Set new_SyncFilesT_Class_Array = objects
End Function


 
'***********************************************************************
'* Class: SyncFilesT_Class
'*
'* Data structure:
'* - <SyncFilesT_Class>
'* - | <SyncFilesT_TargetClass> .Targets
'* - | | <SyncFilesT_FileClass>   .Files
'***********************************************************************
Class  SyncFilesT_Class

	'* Var: SettingPath
		Public  SettingPath

	'* Var: ModuleName
		Public  ModuleName

	'* Var: Targets
		'// as dictionary of SyncFilesT_TargetClass. Key=TargetName
		Public  Targets

	'* Var: Descriptions
		'// as dictionary of ArrayClass of SyncFilesT_FileClass. Key=DescriptionPath
		'// Example of "DescriptionPath" is "Module\1\*\A".
		Public  Descriptions

	'* Var: KindValues
		'// as dictionary of SyncFilesT_KindClass. Key=KindValue
		Public  KindValues

	'* Var: ModifiedCount
		Public  ModifiedCount

	'* Var: HashValues
		'// as dictionary of string "RevisionPath". Key=HashValue
		'// Example of "DescriptionPath" is "Module\1\01\A".
		Public  HashValues

	'* Var: BadPaths
		'// as dictionary of (True=NotSet, False=NotFound). Key=Name or StepPath
		Public  BadPaths

	'* Var: Colors
		'// as array of string
		Public  Colors

	'* Var: OverwrittenModulePaths
		'// as dictionary of string. Key=RootFolderPath
		Public  OverwrittenModulePaths

	'* Var: CommittedListPath as string
		Public  CommittedListPath


	Private Sub  Class_Initialize()
		Set Me.Targets = CreateObject( "Scripting.Dictionary" )
		Set Me.Descriptions = CreateObject( "Scripting.Dictionary" )
		Set Me.KindValues = CreateObject( "Scripting.Dictionary" )
		Set Me.HashValues = CreateObject( "Scripting.Dictionary" )
		Set Me.BadPaths = CreateObject( "Scripting.Dictionary" )
		Me.Colors = Array( "#CCFFFF", "#FFFFCC", "#CCFFCC", "#FFEBCD", "#DDDDFF", "#FFDDDD", _
			"#FFCCDD", "#FFFFFF" )
	End Sub


 
'***********************************************************************
'* Method: Run
'*
'* Name Space:
'*    SyncFilesT_Class::Run
'***********************************************************************
Public Sub  Run( in_SettingPath, in_OutPath, in_ModuleName )
	echo  "SyncFilesT_Class::Run  """+ in_SettingPath +""", """+ in_OutPath +""""
	Set ec = new EchoOff
	Set c = g_VBS_Lib
	Const  c_NotCaseSensitive = 1
	Me.BadPaths.RemoveAll

	If not IsEmpty( Me.OverwrittenModulePaths ) Then
		Set over = Me.OverwrittenModulePaths
	Else
		Set over = CreateObject( "Scripting.Dictionary" )
	End If


	UpdateLineAttributeInXML  in_SettingPath, "@line_num"



	'// Load "in_SettingPath"
	Set root = LoadXML( in_SettingPath, Empty )
	base_path = GetParentFullPath( in_SettingPath )
	Me.SettingPath = base_path +"\"+ g_fs.GetFileName( in_SettingPath )
	If not IsEmpty( in_ModuleName ) Then
		Me.ModuleName = in_ModuleName
	Else
		Me.ModuleName = root.selectSingleNode( "./ModuleFiles/@module_name" ).nodeValue
	End If

	Me.CommittedListPath = GetFullPath( XmlRead( root, "./HashList/@path" ), base_path )
	Set  expand_wildcards = CreateObject( "Scripting.Dictionary" )
	expand_wildcards.CompareMode = c_NotCaseSensitive

	For Each  module_tag  In  root.selectNodes( "./ModuleFiles[@module_name='"+ Me.ModuleName +"']" )
		Set current_targets = new ArrayClass
		For Each  target_tag  In  module_tag.selectNodes( "./TargetFiles" )
			Set target = Dic_addNewObject( Me.Targets, "SyncFilesT_TargetClass", _
				target_tag.getAttribute( "target_name" ), False )
			current_targets.Add  target
			If not  over.Exists( target.Name ) Then
				target.RootFullPath = GetFullPath( target_tag.getAttribute( "path" ),  base_path )
			Else
				target.RootFullPath = GetFullPath( over( target.Name ), base_path )
			End If
			Set target.TargetXML_Tag = target_tag
			target.DescriptionIndex = target_tag.getAttribute( "index" )
		Next

		For Each  file_tag  In  module_tag.selectNodes( "./File" )
			descriptions_ = ArrayFromCSV( file_tag.getAttribute( "description" ) )
			For Each  target  In  current_targets.Items
				If CInt( target.DescriptionIndex ) - 1 > UBound( descriptions_ ) Then _
					Raise  1, "<ERROR msg=""index が大きすぎます。""  target="""+ target.Name +"""/>"
				description = Trim( descriptions_( CInt( target.DescriptionIndex ) - 1 ) )
				If description <> "" Then
					Set file = Dic_addNewObject( target.Files, "SyncFilesT_FileClass", _
						file_tag.getAttribute( "name" ), False )
					file_name = file.Name

					If not expand_wildcards.Exists( target.Name ) Then
						Set nodes = target.TargetXML_Tag.selectNodes( "Folder | File" )
						If nodes.length = 0 Then

							ExpandWildcard  target.RootFullPath +"\*", _
								c.File or c.SubFolder,  folder,  step_paths
						Else
							Set path_dic = new_PathDictionaryClass_fromXML( nodes,  "path",  base_path )
							step_paths = path_dic.FilePaths
							folder = base_path
						End If

						Set cache_ = new NameOnlyClass
						cache_.Name = folder
						cache_.Delegate = step_paths

						Set expand_wildcards( target.Name ) = cache_
					Else
						Set cache_ = expand_wildcards( target.Name )
						folder = cache_.Name
						step_paths = cache_.Delegate
					End If

					i = 0
					For Each  step_path  In  step_paths
						If StrCompLastOf( step_path, file_name, Empty ) = 0 Then _
							Exit For  '// Set "step_path"
					Next
					If not IsEmpty( step_path ) Then
						file.FullPath = folder +"\"+ step_path

						file.KindName = Trim( file_tag.getAttribute( "kind" ) )
						'//TODO: Set Me.KindValues( file.KindName ) = file
						file.DescriptionName = description
						file.HashValue = ReadBinaryFile( file.FullPath ).MD5
						file.LineNumInSetting = file_tag.getAttribute( "line_num" )
						description_path = Me.ModuleName +"\"+ file.KindName +"\*\"+ description
						Dic_addInArrayItem  Me.Descriptions,  description_path,  file
						Set target.FilesFromKind( file.KindName ) = file
					Else
						target.Files.Remove  file_name
						Me.BadPaths( target.RootFullPath +"\*\"+ file_name ) = False
					End If
				End If
			Next
		Next

		For Each  ignore_tag  In  module_tag.selectNodes( "./Ignore" )
			For Each  target  In  current_targets.Items
				Set paths = new PathDictionaryClass
				paths.BasePath = target.RootFullPath
				Set paths( ignore_tag.getAttribute( "name" ) ) = Nothing
				target.Ignores.Add  paths
			Next
		Next
	Next
	For Each  commit_tag  In  root.selectNodes( "./CommittedFile" )
		Me.HashValues( commit_tag.getAttribute( "hash" ) ) = commit_tag.getAttribute( "revision" )
	Next


	'// Set "Me.BadPaths" : Check all files exists
	For Each  target  In  Me.Targets.Items
		Set nodes = target.TargetXML_Tag.selectNodes( "Folder | File" )
		If nodes.length = 0 Then

			ExpandWildcard  target.RootFullPath +"\*", _
				c.File or c.SubFolder,  folder,  step_paths
		Else
			Set path_dic = new_PathDictionaryClass_fromXML( nodes,  "path",  base_path )
			step_paths = path_dic.FilePaths
			folder = base_path
		End If

		Set  dic = CreateObject( "Scripting.Dictionary" )
		Dic_addFromArray  dic,  step_paths,  True
		For Each  file  In  target.Files.Items
			step_path = GetStepPath( file.FullPath,  folder )
			If dic.Exists( step_path ) Then

				dic.Remove  step_path
			End If
		Next
		For Each  paths  In  target.Ignores.Items
			For Each  step_path  In  paths.FilePaths
				If dic.Exists( step_path ) Then

					dic.Remove  step_path
				End If
			Next
		Next
		For Each  step_path  In  dic.Keys

			Me.BadPaths( target.RootFullPath +"\"+ step_path ) = True
		Next
	Next


	'// Set "file.Revision"
	For Each  description_path  In  Me.Descriptions.Keys
		new_ID = 1
		For Each  file  In  Me.Descriptions( description_path ).Items
			If not Me.HashValues.Exists( file.HashValue ) Then
				file.Revision = "new_"+ CStr( new_ID )
				revision_path = Replace( description_path,  "\*\",  "\"+ file.Revision+ "\" )

				new_ID = new_ID + 1
				Me.HashValues( file.HashValue ) = revision_path
			Else
				file.Revision = g_fs.GetFileName( g_fs.GetParentFolderName( _
					Me.HashValues( file.HashValue ) ) )

				description_in_hash = g_fs.GetFileName( Me.HashValues( file.HashValue ) )
				If description_in_hash <> file.DescriptionName Then
					file.Revision = file.Revision +"+X"
					file.DescriptionName = file.DescriptionName +"? or "+ description_in_hash +"?"
				End If
			End If
		Next
	Next


	'// Set "Me.KindValues"
	Me.KindValues.RemoveAll
	modified_count = 0
	For Each  target  In  Me.Targets.Items
		For Each  file  In  target.Files.Items
			Set Me.KindValues( file.KindName ) = new SyncFilesT_KindClass
		Next
	Next
	For Each  kind_name  In  Me.KindValues.Keys
		is_modified = False
		previous_revision = Empty
		For Each  target  In  Me.Targets.Items
			If target.FilesFromKind.Exists( kind_name ) Then
				Set file = target.FilesFromKind( kind_name )
				If Me.IsUpdatedFile( file ) Then
					is_modified = True
					Exit For
				End If

				If IsEmpty( previous_revision ) Then
					previous_revision = file.Revision
				Else
					If file.Revision <> previous_revision Then
						is_modified = True
						Exit For
					End If
				End If
			End If
		Next

		Me.KindValues( kind_name ).IsModified = is_modified

		If is_modified Then
			modified_count = modified_count + 1
		End If
	Next

	Me.ModifiedCount = modified_count


	'// Write to "in_OutPath"
	If not IsEmpty( in_OutPath ) Then
		Set write_file = OpenForWrite( in_OutPath, Empty )
		write_file.WriteLine  "<SyncTableChecked>"
		write_file.WriteLine  ""
		For Each  target  In  Me.Targets.Items
			write_file.WriteLine  "<ModifiedModuleFiles  index="""+ target.DescriptionIndex + _
				"""  target_name="""+ target.Name + _
				"""  root_path="""+ target.RootFullPath +""">"
			For Each  file  In  target.Files.Items
				write_file.WriteLine  vbTab +"<File  kind="""+ file.KindName + _
					"""  name="""+ file.Name + _
					"""  revision="""+ Me.ModuleName +"\"+ file.KindName +"\"+ _
						file.Revision +"\"+ file.DescriptionName + _
					"""  hash="""+ file.HashValue + _
					"""  line_num="""+ file.LineNumInSetting + _
					"""  full_path="""+ file.FullPath +"""/>"
			Next
			write_file.WriteLine  "</ModifiedModuleFiles>"
			write_file.WriteLine  ""
		Next

		tags = Me.GetAllCommitTags()
		If tags <> "" Then
			write_file.WriteLine  "<TemplateOfCommitAllFiles>"
			write_file.Write      tags
			write_file.WriteLine  "</TemplateOfCommitAllFiles>"
			write_file.WriteLine  ""
		End If

		If Me.BadPaths.Count >= 1 Then
			For Each  bad_path  In  Me.BadPaths.Keys
				If Me.BadPaths( bad_path ) Then
					write_file.WriteLine  "<NotSet    path="""+ bad_path +"""/>"
				Else
					write_file.WriteLine  "<NotFound  path="""+ bad_path +"""/>"
				End If
			Next
			write_file.WriteLine  ""
			echo_v  "<WARNING  msg=""見つからないパス、または、設定していないパスがあります。"""+ _
				"  see="""+ in_OutPath +"""/>"
		End If

		write_file.WriteLine  "</SyncTableChecked>"
	End If
End Sub


 
'***********************************************************************
'* Method: SaveHTML
'*
'* Name Space:
'*    SyncFilesT_Class::SaveHTML
'***********************************************************************
Public Sub  SaveHTML( in_OutPath, in_TemplatePath )
	echo  "SyncFilesT_Class::SaveHTML  """+ in_OutPath +""""
	Set ec = new EchoOff

	'// Write "target.Name"
	Set write_file = new StringStream
	write_file.WriteLine  "<Caption>"+ Me.ModuleName +"</Caption>"
	write_file.WriteLine  "<TR><TH style=""writing-mode: lr-tb;"">File (Kind) \ Target</TH>"
	write_file.WriteLine  vbTab +"<TH style=""font-size:small;"">Modified</TH>"
	num = 0
	For Each  target  In  Me.Targets.Items
		num = num + 1
		write_file.WriteLine  vbTab +"<TH>"+ CStr( num ) +". "+ g_fs.GetFileName( target.Name ) +"</TH>"
	Next
	write_file.WriteLine  "</TR>"
	Set list_of_ID = CreateObject( "Scripting.Dictionary" )


	'// Write "file.Revision"
	For Each  kind_name  In  Me.KindValues.Keys

		is_first = True
		Set colors_ = CreateObject( "Scripting.Dictionary" )
		For Each  target  In  Me.Targets.Items
			If is_first Then
				file_name = ""
				kind_path = Me.ModuleName +"\"+ kind_name +"\"
				For Each  path  In  Me.Descriptions.Keys
					If StrCompHeadOf( path, kind_path, Empty ) = 0 Then
						file_name = Me.Descriptions( path )(0).Name
						Exit For
					End If
				Next

				write_file.WriteLine  "<TR kind="""+ CStr( kind_name ) + _
					"""><TD style=""text-align: left;"">"+ kind_name +") "+ _
					file_name +", ...</TD>"

				If Me.KindValues( kind_name ).IsModified Then
					modified_tag = "<TD style=""background-color:#FFDDDD;"">*</TD>"
				Else
					modified_tag = "<TD></TD>"
				End If
				write_file.WriteLine  vbTab + modified_tag

				is_first = False
			End If

			If target.FilesFromKind.Exists( kind_name ) Then
				Set file = target.FilesFromKind( kind_name )
				a_ID = file.Revision +"\"+ file.DescriptionName
				If colors_.Exists( a_ID ) Then
					color = colors_( a_ID )
				Else
					color_index = colors_.Count
					If color_index > UBound( Me.Colors ) Then _
						color_index = UBound( Me.Colors )
					color = Me.Colors( color_index )
					colors_( a_ID ) = color
				End If
				If Me.IsUpdatedFile( file ) Then
					bold_css = " font-weight:bold;"
				Else
					bold_css = ""
				End If

				write_file.WriteLine  vbTab +"<TD style=""background-color:"+ color +";"+ _
					bold_css +""">"+ a_ID +"</TD>"

				revision = Me.ModuleName +"\"+ kind_name +"\"+ a_ID
				list_of_ID( revision ) = True
			Else
				write_file.WriteLine  vbTab +"<TD></TD>"
			End If
		Next
		write_file.WriteLine  "</TR>"
	Next


	If Me.BadPaths.Count >= 1 Then
		write_file.WriteLine  "<UL>"
		For Each  bad_path  In  Me.BadPaths.Keys
			If Me.BadPaths( bad_path ) Then
				tag_name = "NotSet or Duplicated"
			Else
				tag_name = "NotFound"
			End If
			write_file.WriteLine  "<LI>"+ tag_name +"  """+ g_fs.GetFileName( bad_path ) + _
				""" at """+ bad_path +""""
		Next
		write_file.WriteLine  "</UL>"
		write_file.WriteLine  ""
	End If


	'// Set "setting_tags".
	setting_tags = ReadFile( Me.SettingPath )
	setting_length = Len( setting_tags )
	If Left( setting_tags, 5 ) = "<?xml" Then

		'// Cut "<?xml ?>".
		end_of_instruction = InStrLast( setting_tags, ">" )
		setting_tags = Trim2( Mid( setting_tags,  end_of_instruction ) )
		setting_offset = setting_length - Len( setting_tags )
	Else
		setting_offset = 0
	End If


	'// Cut "<CommittedFile>" in "setting_tags", if not newest.
	Set parser1 = CreateObject( "MSXML2.DOMDocument" )
	Set parser2 = new PositionOfXML_Class
	parser2.Load  Me.SettingPath
	Set cut_commits = new ArrayClass
	i = 1 : Do
		Set commit_tag = parser2.SelectSingleNode( "//CommittedFile["+ CStr( i ) +"]" )
		If commit_tag is Nothing Then _
			Exit Do

		'// e.g. <CommittedFile  hash="..."  revision="ModuleX\2\01\A"/>
		commit_tag_string = Mid( setting_tags, _
			commit_tag.PositionOfLeftOfStartTag - setting_offset, _
			commit_tag.PositionOfNextOfEndTag - commit_tag.PositionOfLeftOfStartTag )
		r= parser1.loadXML( commit_tag_string ) : If r=0 Then Error
		revision = parser1.lastChild.getAttribute( "revision" )

		If not list_of_ID.Exists( revision ) Then
			cut_commits.Add  commit_tag
		End If

		i = i + 1
	Loop
	For  i = cut_commits.UBound_  To  0  Step  -1
		Set commit_tag = cut_commits( i )
		setting_tags = Left( setting_tags,  commit_tag.PositionOfLeftOfStartTag - 1 ) + _
			Mid( setting_tags,  commit_tag.PositionOfNextOfEndTag  )
	Next


	'// Write using template
	Set  replace_file = OpenForReplace( in_TemplatePath, in_OutPath )
	replace_file.ReplaceRange _
		"<!-- Start_of_Output_from_SyncTable -->", _
		"<!-- End_of_Output_from_SyncTable -->", _
		"<!-- Start_of_Output_from_SyncTable -->"+ vbCRLF + _
		write_file.ReadAll() + vbCRLF + vbCRLF + _
		setting_tags + vbCRLF + vbCRLF + _
		"<!-- End_of_Output_from_SyncTable -->"
	replace_file = Empty
End Sub


 
'***********************************************************************
'* Method: GetFileFromTable
'*
'* Name Space:
'*    SyncFilesT_Class::GetFileFromTable
'***********************************************************************
Public Function  GetFileFromTable( in_KindName, in_TargetNumberOrName )
	If VarType( in_TargetNumberOrName ) = vbInteger Then
		num = 0
		For Each  target  In  Me.Targets.Items
			num = num + 1
			If num = in_TargetNumberOrName Then _
				Exit For
		Next
	Else
		Set target = Me.Targets( in_TargetNumberOrName )
	End If

	For Each  file  In  target.Files.Items
		If file.KindName = in_KindName Then
			Set GetFileFromTable = file
			Exit For
		End If
	Next
End Function


 
'***********************************************************************
'* Method: ScanAFile
'*
'* Name Space:
'*    SyncFilesT_FileClass::ScanAFile
'***********************************************************************
Public Sub  ScanAFile( in_File )
	Set file = in_File

	file.HashValue = ReadBinaryFile( file.FullPath ).MD5


	'// Set "file.Revision"
	If Me.HashValues.Exists( file.HashValue ) Then
		revision_path = Me.HashValues( file.HashValue )
		If StrCompHeadOf( revision_path,  Me.ModuleName +"\"+ file.KindName +"\",  Empty ) = 0 Then
			If g_fs.GetFileName( revision_path ) = file.DescriptionName Then
				file.Revision = g_fs.GetFileName( g_fs.GetParentFolderName( revision_path ) )
			End If
		End If
	Else
		If StrCompLastOf( file.Revision, "+alpha", Empty ) <> 0 Then _
			file.Revision = file.Revision + "+alpha"
	End If
End Sub


 
'***********************************************************************
'* Method: Check
'*
'* Name Space:
'*    SyncFilesT_Class::Check
'***********************************************************************
Public Function  Check( in_EmptyOption )
	For Each  target  In  Me.Targets.Items
		For Each  file  In  target.Files.Items
			If not IsNumeric( file.Revision ) Then
				echo_v  "<NewFile"+ vbCRLF + _
					"  path="""+ file.FullPath +""""+ vbCRLF + _
					"  revision="""+ Me.ModuleName +"\"+ file.KindName +"\"+ _
						file.Revision +"\"+ file.DescriptionName + _
					"""  line_num="""+ file.LineNumInSetting + """/>"
			End If
		Next
	Next
End Function


 
'***********************************************************************
'* Method: StartDiffTool
'*
'* Name Space:
'*    SyncFilesT_FileClass::StartDiffTool
'***********************************************************************
Public Sub  StartDiffTool( in_KindName, in_LeftTargetName, in_RightTargetName, in_EmptyOption )

	Set left_file  = Me.GetFileFromTable( in_KindName, in_LeftTargetName )
	Set right_file = Me.GetFileFromTable( in_KindName, in_RightTargetName )

	If IsEmpty( Me.CommittedListPath ) Then
		start  GetDiffCmdLine( left_file.FullPath, right_file.FullPath )
	Else
		'// Set "old_files"
		ReDim  hash_values(1)
		description_names = Array( left_file.DescriptionName,  right_file.DescriptionName )
		left_or_right = Array( "Left ",  "Right" )
		For i=0 To 1
			position = InStr( description_names(i), "?" )
			If position >= 1 Then _
				description_names(i) = Left( description_names(i),  position - 1 )
			description_path = Me.ModuleName +"\"+ in_KindName +"\*\"+ description_names(i)
			echo  left_or_right(i) +".Description = "+ description_path
			description_path = Replace( description_path, "\", "\\" )
			description_path = Replace( description_path, "*", "([0-9].*)" )

			Set re = new_RegExp( description_path, False )
			newest_revision = Empty
			For Each  hash_value  In  Me.HashValues.Keys
				description_name = Me.HashValues( hash_value )
				Set matches = re.Execute( description_name )
				If matches.Count >= 1 Then
					revision = re.Replace( description_name, "$1" )
					If IsEmpty( newest_revision ) Then
						newest_revision = revision
						hash_values(i) = hash_value
					Else
						If PathCompare( revision,  newest_revision,  Empty ) > 0 Then
							newest_revision = revision
							hash_values(i) = hash_value
						End If
					End If
				End If
			Next
		Next


		'// Set "paths"
		ReDim  paths(1)
		Set file = OpenForRead( Me.CommittedListPath )
		Do Until  file.AtEndOfStream
			line = file.ReadLine()
			If Mid( line, 11, 1 ) = "T" Then _
				line = Mid( line,  InStr( line, " " ) + 1 )
			position = InStr( line, " " )
			hash_value = Left( line, position - 1 )
			If hash_value = hash_values(0) Then _
				paths(0) = Mid( line, position + 1 )
			If hash_value = hash_values(1) Then _
				paths(1) = Mid( line, position + 1 )
		Loop
		file = Empty

		parent_path = GetParentFullPath( Me.CommittedListPath )
		If IsEmpty( paths(0) ) Then
			paths(0) = left_file.FullPath
		Else
			paths(0) = GetFullPath( paths(0),  parent_path )
		End If
		If IsEmpty( paths(1) ) Then
			paths(1) = right_file.FullPath
		Else
			paths(1) = GetFullPath( paths(1),  parent_path )
		End If


		'// SyncFilesX
		Set sync_x = new SyncFilesX_Class
		sync_x.IsEnabledCommit = False
		sync_x.Run  in_LeftTargetName,  in_RightTargetName, _
			left_file.FullPath,  right_file.FullPath,  paths(0),  paths(1)
	End If
End Sub


 
'***********************************************************************
'* Method: GetCommitTag
'*
'* Name Space:
'*    SyncFilesT_FileClass::GetCommitTag
'***********************************************************************
Public Function  GetCommitTag( in_File )
	Set file = in_File
	GetCommitTag = "<CommittedFile  hash="""+ file.HashValue +_
		"""  revision="""+ Me.ModuleName +"\"+ file.KindName +"\"+ _
		file.Revision +"\"+ file.DescriptionName +"""/>"
End Function


 
'***********************************************************************
'* Method: GetAllCommitTags
'*
'* Name Space:
'*    SyncFilesT_FileClass::GetAllCommitTags
'***********************************************************************
Public Function  GetAllCommitTags()

	'// UpdatedFile は、既存の description の次から自動的に割り当てる
	Set file_tags = CreateObject( "Scripting.Dictionary" )
	text_1 = ""  '// <File>
	text_2 = ""  '// <CommittedFile>
	For Each  kind_name  In  Me.KindValues.Keys
		Set committed_files = CreateObject( "Scripting.Dictionary" )
		next_description = "A"
		newest_revision = ""
		For Each  target  In  Me.Targets.Items
			If target.FilesFromKind.Exists( kind_name ) Then
				Set file = target.FilesFromKind( kind_name )
				If not Me.IsUpdatedFile( file ) Then
					If PathCompare( file.Revision,  newest_revision,  Empty ) > 0 Then _
						newest_revision = file.Revision
					If file.DescriptionName >= next_description Then _
						next_description = Chr( Asc( file.DescriptionName ) + 1 )

					Set committed_files( file.HashValue ) = file
				End If
			End If
		Next

		For Each  target  In  Me.Targets.Items
			If target.FilesFromKind.Exists( kind_name ) Then
				Set file = target.FilesFromKind( kind_name )
				If Me.IsUpdatedFile( file ) Then

					'// Set "file_tags"
					Set file_tag = target.TargetXML_Tag.parentNode.selectSingleNode( _
						"./File[@name='"+ Replace( file.Name, "\", "\\" ) +"']" )
					descriptions_ = ArrayFromCSV( file_tag.getAttribute( "description" ) )
					If not  committed_files.Exists( file.HashValue ) Then
						descriptions_( CInt( target.DescriptionIndex ) - 1 ) = next_description
					Else
						descriptions_( CInt( target.DescriptionIndex ) - 1 ) = _
							committed_files( file.HashValue ).DescriptionName
					End If
					For i=0 To UBound( descriptions_ )
						If IsEmpty( descriptions_(i) ) Then _
							descriptions_(i) = " "
					Next
					file_tag.setAttribute  "description",  new_ArrayClass( descriptions_ ).CSV
					Set file_tags( file.Name ) = file_tag

					If not  committed_files.Exists( file.HashValue ) Then

						'// Call "GetCommitTag"
						Set new_file = new SyncFilesT_FileClass
						new_file.HashValue = file.HashValue
						new_file.KindName = kind_name
						new_file.Revision = "01"
						new_file.DescriptionName = next_description

						text_2 = text_2 + Me.GetCommitTag( new_file ) + vbCRLF

						Assert  next_description <> "Z"
						next_description = Chr( Asc( next_description ) + 1 )

						Set committed_files( file.HashValue ) = new_file
					End If
				End If
			End If
		Next
	Next

	For Each  file_name  In  file_tags.Keys
		text_1 = text_1 + file_tags( file_name ).xml + vbCRLF
	Next

	GetAllCommitTags = text_1 + text_2
End Function


 
'***********************************************************************
'* Method: IsUpdatedFile
'*
'* Name Space:
'*    SyncFilesT_FileClass::IsUpdatedFile
'***********************************************************************
Public Function  IsUpdatedFile( in_File )
	IsUpdatedFile = Left( in_File.Revision, 4 ) = "new_"
End Function


 
End Class

'* Section: Global


 
'***********************************************************************
'* Class: SyncFilesT_TargetClass
'***********************************************************************
Class  SyncFilesT_TargetClass

	'* Var: Name
		Public  Name

	'* Var: RootFullPath
		Public  RootFullPath

	'* Var: TargetXML_Tag
		Public  TargetXML_Tag

	'* Var: DescriptionIndex
		'// as string
		Public  DescriptionIndex

	'* Var: Files
		'// as dictionary of SyncFilesT_FileClass. Key=File.Name
		Public  Files

	'* Var: Ignores
		'// as ArrayClass of PathDictionaryClass.
		Public  Ignores

	'* Var: FilesFromKind
		'// as dictionary of SyncFilesT_FileClass. Key=KindName
		Public  FilesFromKind


	Private Sub  Class_Initialize()
		Set Me.Files = CreateObject( "Scripting.Dictionary" )
		Set Me.Ignores = new ArrayClass
		Set Me.FilesFromKind = CreateObject( "Scripting.Dictionary" )
	End Sub
End Class

'* Section: Global


 
'***********************************************************************
'* Function: new_SyncFilesT_TargetClass
'***********************************************************************
Function  new_SyncFilesT_TargetClass()
    Set new_SyncFilesT_TargetClass = new SyncFilesT_TargetClass
End Function


 
'***********************************************************************
'* Class: SyncFilesT_KindClass
'***********************************************************************
Class  SyncFilesT_KindClass
	Public  IsModified
End Class

'* Section: Global


 
'***********************************************************************
'* Class: SyncFilesT_FileClass
'***********************************************************************
Class  SyncFilesT_FileClass
	Public  Name
	Public  FullPath
	Public  KindName
	Public  DescriptionName  '// e.g. "A"
	Public  HashValue
	Public  Revision  '// e.g. "01"
	Public  LineNumInSetting
End Class

'* Section: Global


 
'***********************************************************************
'* Function: new_SyncFilesT_FileClass
'***********************************************************************
Function  new_SyncFilesT_FileClass()
    Set new_SyncFilesT_FileClass = new SyncFilesT_FileClass
End Function


 
'***********************************************************************
'* Function: SyncFilesT_Class_createFirstSetting
'***********************************************************************
Sub  SyncFilesT_Class_createFirstSetting( in_ModuleFolderPath, in_Empty )
	Set Me_ = new SyncFilesT_Class
	Const  c_NotCaseSensitive = 1
	Set c = g_VBS_Lib
	sort_setting_back_up = g_Vers("ExpandWildcard_Sort")
	g_Vers("ExpandWildcard_Sort") = False


	Me_.ModuleName = g_fs.GetFileName( in_ModuleFolderPath )

	Set files_in_a_module = CreateObject( "Scripting.Dictionary" )  '// Key=IdentifiableFileName
	files_in_a_module.CompareMode = c_NotCaseSensitive


	'// Scan file paths in "in_ModuleFolderPath"
	next_description_index = 1
	For Each  sub_folder  In  g_fs.GetFolder( in_ModuleFolderPath ).SubFolders
		Set target = Dic_addNewObject( Me_.Targets, "SyncFilesT_TargetClass", sub_folder.Name, False )
		target.RootFullPath = sub_folder.Path

		target.DescriptionIndex = next_description_index
		next_description_index = next_description_index + 1

		ExpandWildcard  target.RootFullPath +"\*",  c.File or c.SubFolder or c.FullPath,  Empty,  full_paths
		Set target.Files = GetIdentifiableFileNames( full_paths )
		For Each  id_file_name  In  target.Files.Keys
			Set file = new SyncFilesT_FileClass
			file.Name = id_file_name
			file.FullPath = target.Files( id_file_name )

			Set target.Files( id_file_name ) = file

			Set files_in_a_module( id_file_name ) = Nothing
		Next
	Next
	QuickSortDicByKey  files_in_a_module


	'// Write to a "SyncFilesT" setting file
	Set write_file = OpenForWrite( GetFullPath( "_SyncFilesT_"+ Me_.ModuleName +".xml", _
		GetParentFullPath( in_ModuleFolderPath ) ), _
		Empty )

	write_file.WriteLine  "<SyncFilesT>"
	write_file.WriteLine  ""
	write_file.WriteLine  "<ModuleFiles  module_name="""+ Me_.ModuleName +""">"

	indexes = ""
	next_index = 1
	For Each  target  In  Me_.Targets.Items

		write_file.WriteLine  "<TargetFiles  index="""+ CStr( target.DescriptionIndex ) +_
			"""  target_name="""+ Me_.ModuleName +"\"+ target.Name +_
			"""  path="""+ Me_.ModuleName +"\"+ target.Name +"""/>"

		indexes = indexes + CStr( next_index ) +","
		next_index = next_index + 1
	Next
	indexes = Left( indexes,  Len( indexes ) - 1 )

	write_file.WriteLine  "<!--                         """+ indexes +""" -->"

	next_kind_number = 1
	For Each  id_file_name  In  files_in_a_module.Keys


		'// Write "<File>"
		description = ""
		For Each  target  In  Me_.Targets.Items
			If target.Files.Exists( id_file_name ) Then
				description = description +"A,"
			Else
				description = description +" ,"
			End If
		Next
		description = Left( description,  Len( description ) - 1 )

		write_file.WriteLine  "<File  kind="""+ CStr( next_kind_number ) +_
			"""  description="""+ description +"""  name="""+ id_file_name + _
			"""  line_num=""""/>"

		next_kind_number = next_kind_number + 1
	Next

	write_file.WriteLine  "</ModuleFiles>"
	write_file.WriteLine  ""
	write_file.WriteLine  "</SyncFilesT>"

	g_Vers("ExpandWildcard_Sort") = sort_setting_back_up
End Sub


 
'***********************************************************************
'  <<< [GetEqualString] >>> 
'***********************************************************************
Function  GetEqualString( IsSame )
	If IsEmpty( IsSame ) Then
		GetEqualString = " なし"
	ElseIf IsSame Then
		GetEqualString = "=同じ"
	Else
		GetEqualString = "!異なる"
	End If
End Function


 
'***********************************************************************
'  <<< [get_SyncFilesX_FileClassConsts] >>>
'***********************************************************************
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


 
'***********************************************************************
'* Function: new_ReplaceTemplateClass
'***********************************************************************
Function  new_ReplaceTemplateClass( in_PathOfXML )
	Set c = g_VBS_Lib

	Set Me_ = new ReplaceTemplateClass
	Set Me_.Files = new MultiTextXML_Class

	If g_fs.FolderExists( in_PathOfXML ) Then
		ExpandWildcard  in_PathOfXML +"\*.replace.xml", c.File or c.SubFolder, folder, step_paths
		For Each step_path  In step_paths
			Me_.AppendLoadSetting  GetFullPath( step_path, folder )
		Next

		ExpandWildcard  in_PathOfXML +"\*.before.*", c.File or c.SubFolder, folder, step_paths
		For Each step_path  In step_paths
			before_path = GetFullPath( step_path, folder )
			after_path = Replace( before_path, ".before.", ".after." )
			Me_.AppendTemplateText  ReadFile( before_path ), ReadFile( after_path )
		Next
	Else
		Me_.AppendLoadSetting  in_PathOfXML
	End If

	Set new_ReplaceTemplateClass = Me_
End Function


 
'***********************************************************************
'* Class: ReplaceTemplateClass
'***********************************************************************
Class  ReplaceTemplateClass
	Public  Files
	Public  TargetFolders

	Public  StepNum
	Public  BreakStepNum

	Public  EnabledTemplateIDs
	Public  EnabledTemplateKeywords
	Public  EnabledTemplates

	Public  CheckTargetDefault

	Public  ReplaceTemplate  '// as array of ReplaceTemplateClass


	Private Sub  Class_Initialize()
		Me.StepNum = 0
		Set Me.ReplaceTemplate = new ArrayClass
	End Sub


 
'***********************************************************************
'* Method: AppendTemplateText
'*
'* Name Space:
'*    ReplaceTemplateClass::AppendTemplateText
'***********************************************************************
Public Sub  AppendTemplateText( in_TextBefore, in_TextAfter )
	Set replace_ = new OneReplaceTemplateClass
	replace_.TextBefore = in_TextBefore
	replace_.TextAfter  = in_TextAfter
	Me.ReplaceTemplate.Add  replace_
End Sub


 
'***********************************************************************
'* Method: AppendLoadSetting
'*
'* Name Space:
'*    ReplaceTemplateClass::AppendLoadSetting
'***********************************************************************
Public Sub  AppendLoadSetting( in_PathOfXML )
	xml_full_path = GetFullPath( in_PathOfXML, Empty )
	Set xml_root = LoadXML_Cached( xml_full_path, Empty )


	'// Set "Me.TargetFolders"
	Set dic = new_PathDictionaryClass_fromXML( _
		xml_root.selectNodes( "Target" ), _
		"path",  g_fs.GetParentFolderName( xml_full_path ) )
	If IsEmpty( Me.TargetFolders ) Then
		Set Me.TargetFolders = dic
	Else
		Dic_add  Me.TargetFolders,  dic
	End If


	'// Set "Me.EnabledTemplates" from XML
	Set text_object = xml_root.selectSingleNode( "./EnabledTemplateIDs/text()" )
	If not text_object is Nothing Then
		Me.EnabledTemplateIDs = ArrayFromLines( Trim2( text_object.nodeValue ) )

		'// Set "Me.EnabledTemplates", ...
		ReDim  template_array( UBound( Me.EnabledTemplateIDs ) )
		ReDim  keyword_array(  UBound( Me.EnabledTemplateIDs ) )
		For index = 0  To UBound( Me.EnabledTemplateIDs )
			template_array( index ) = Me.Files.GetText( xml_full_path + _
				Me.EnabledTemplateIDs( index ) )
			keyword_array( index ) = Me.Files.GetText( xml_full_path + _
				Me.EnabledTemplateIDs( index ) +"_Keyword" )
			CutLastOf  keyword_array( index ), vbCRLF, Empty
		Next
		Me.EnabledTemplates = template_array
		Me.EnabledTemplateKeywords = keyword_array
	End If


	'// Set "Me.CheckTargetDefault" from XML
	Set text_object = xml_root.selectSingleNode( "./CheckTargetDefault/text()" )
	If not text_object is Nothing Then _
		Me.CheckTargetDefault = Trim2( text_object.nodeValue )


	'// Set "Me.ReplaceTemplate" from XML
	Set text_object = xml_root.selectSingleNode( "./ReplaceTemplateID_From/text()" )
	If not text_object is Nothing Then
		Set replace_ = new OneReplaceTemplateClass
	 	replace_.ID_Before = Trim2( text_object.nodeValue )
		Set text_object = xml_root.selectSingleNode( "./ReplaceTemplateID_To/text()" )
		If not text_object is Nothing Then
			replace_.ID_After = Trim2( text_object.nodeValue )
			Me.ReplaceTemplate.Add  replace_
		End If
	End If

	For Each  tag  In  xml_root.selectNodes( "./ReplaceTemplate" )
		Set replace_ = new OneReplaceTemplateClass
		replace_.ID_Before = xml_full_path + tag.getAttribute( "before" )
		replace_.ID_After  = xml_full_path + tag.getAttribute( "after" )
		Me.ReplaceTemplate.Add  replace_
	Next


	'// Set "KeywordBefore"
	For i=0 To Me.ReplaceTemplate.UBound_
		keyword_URL = xml_full_path + Me.ReplaceTemplate(i).ID_Before + "_Keyword"
		If Me.Files.IsExist( keyword_URL ) Then
			a_str = Me.Files.GetText( keyword_URL )
			CutLastOf  a_str, vbCRLF, Empty
		Else
			a_str = ""
		End If
		Me.ReplaceTemplate(i).KeywordBefore = a_str
	Next
End Sub


 
'***********************************************************************
'* Method: SetTargetPath
'*
'* Name Space:
'*    ReplaceTemplateClass::SetTargetPath
'***********************************************************************
Sub  SetTargetPath( in_Path )
	If IsArray( in_Path ) Then
		ReDim  paths( UBound( in_Path ) )
		For i=0 To UBound( in_Path )
			paths(i) = GetFullPath( in_Path(i), Empty )
		Next
		Set dic = new_PathDictionaryClass( paths )
	Else
		Set dic = new_PathDictionaryClass( GetFullPath( in_Path, Empty ) )
	End If

	If IsEmpty( Me.TargetFolders ) Then
		Set Me.TargetFolders = dic
	Else
		Dic_add  Me.TargetFolders,  dic
	End If
End Sub


 
'***********************************************************************
'* Method: RemoveTargetPath
'*
'* Name Space:
'*    ReplaceTemplateClass::RemoveTargetPath
'***********************************************************************
Sub  RemoveTargetPath( in_Path )
	Me.TargetFolders.Remove  GetFullPath( in_Path, Empty )
End Sub


 
'***********************************************************************
'* Method: EchoOld
'*
'* Name Space:
'*    ReplaceTemplateClass::EchoOld
'***********************************************************************
Sub  EchoOld()
	echo  "以下の場所にあるテキスト ファイルの一部がテンプレートがマッチしませんでした。"
	echo  "下記のパスの末尾にある番号は、テンプレートの中のキーワードがある行番号です。"
	echo  "vbslib Prompt.vbs の OpenByStepPath コマンドで開くことができます。"
	echo  "基準パス："""+ g_sh.CurrentDirectory +""""
	echo  "GetDifference コマンドでテンプレートの中のマッチしなかった行の行番号が表示されます。"
	echo_line
	For Each  folder  In Me.TargetFolders.FilePaths
		For index = 0  To UBound( Me.EnabledTemplates )
			Set ec = new EchoOff
			founds = SearchStringTemplate( folder, _
				Me.EnabledTemplateKeywords( index ), _
				Me.EnabledTemplates( index ),  Empty )
			ec = Empty

			For Each  found  In  founds( UBound( founds ) )
				found.CalcLineCount
				echo  found.Path &"("& found.LineNum &") : "+ Me.EnabledTemplateKeywords( index )
			Next
		Next
	Next
End Sub


 
'***********************************************************************
'* Method: RunGetDifference
'*
'* Name Space:
'*    ReplaceTemplateClass::RunGetDifference
'***********************************************************************
Sub  RunGetDifference()
	Set c = g_VBS_Lib

	If IsEmpty( Me.EnabledTemplateIDs ) Then
		Raise  1, "<ERROR msg=""EnabledTemplateIDs タグを記述しないで実行することは未対応です。""/>"
	End If

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


 
'***********************************************************************
'* Method: RunReplace
'*
'* Name Space:
'*    ReplaceTemplateClass::RunReplace
'***********************************************************************
Sub  RunReplace()
	If Me.ReplaceTemplate.Count = 0 Then _
		Exit Sub

	echo  "以下の場所にあるファイルの中にあるテンプレートを置き換えます"
	If Me.TargetFolders.Count = 0 Then
		Raise  E_Others, "編集するファイル または フォルダーが指定されていません。"
	End If
	echo  "編集するフォルダー = "+ GetEchoStr( Me.TargetFolders )
	echo  "ReplaceTemplate(0).ID_Before = "+ Me.ReplaceTemplate(0).ID_Before
	echo  "ReplaceTemplate(0).ID_After = " + Me.ReplaceTemplate(0).ID_After

	Set ec = new EchoOff

	For Each  file_path  In Me.TargetFolders.FilePaths

		'// "PauseForDebug"
		If Me.IsBreak( file_path ) Then
			echo_v  "StepNum = "+ CStr( Me.StepNum ) + _
				" : <ReplaceTemplate> タグによる置き換えを開始します。"+ vbCRLF + _
				"    ファイル = """+ file_path +""""

			PauseForDebug
		End If


If True Then '// 160807
		'// Call "ReplaceStringTemplates"
		ReDim  templates( Me.ReplaceTemplate.UBound_ )
		For i=0 To  Me.ReplaceTemplate.UBound_

			Set replace_1 = Me.ReplaceTemplate(i)
			Set replace_2 = new StringTemplateReplaceClass

			replace_2.KeywordBefore = replace_1.KeywordBefore

			If IsEmpty( replace_1.ID_Before ) Then
				template_before = replace_1.TextBefore
			Else
				Assert  IsEmpty( replace_1.TextBefore )
				template_before = Me.Files.GetText( replace_1.ID_Before )
			End If

			If IsEmpty( replace_1.ID_After ) Then
				template_after = replace_1.TextAfter
			Else
				Assert  IsEmpty( replace_1.TextAfter )
				template_after = Me.Files.GetText( replace_1.ID_After )
			End If

			CutLastOf  template_before,  vbCRLF,  Empty
			CutLastOf  template_after,   vbCRLF,  Empty
			replace_2.TemplateBefore = template_before
			replace_2.TemplateAfter  = template_after

			Set templates(i) = replace_2
		Next

		ReplaceStringTemplates  file_path,  templates,  Empty

Else

		For i=0 To Me.ReplaceTemplate.UBound_

			'// "ReplaceStringTemplate"
			Set replace_ = Me.ReplaceTemplate(i)
			If not IsEmpty( replace_.ID_Before ) Then
				ReplaceStringTemplate  file_path, _
					replace_.KeywordBefore, _
					Me.Files.GetText( replace_.ID_Before ), _
					Me.Files.GetText( replace_.ID_After ), _
					Empty
			ElseIf not IsEmpty( replace_.TextBefore ) Then
				ReplaceStringTemplate  file_path, _
					replace_.KeywordBefore, _
					replace_.TextBefore, _
					replace_.TextAfter, _
					Empty
			End If


			'// "PauseForDebug"
			If Me.IsBreak( file_path ) Then
				echo_v  "StepNum = "+ CStr( Me.StepNum ) + _
					" : <ReplaceTemplate> タグによる置き換えを１つ行いました。"+ vbCRLF + _
					"    ファイル = """+ file_path +""""+ vbCRLF + _
					"    タグ = "+ replace_.ID_Before

				PauseForDebug
			End If
		Next
End If
	Next
End Sub


 
'***********************************************************************
'* Method: IsBreak
'*
'* Name Space:
'*    ReplaceTemplateClass::IsBreak
'***********************************************************************
Function  IsBreak( in_WatchingPath )
	If not IsEmpty( Me.BreakStepNum ) Then
		Me.StepNum = Me.StepNum + 1
		IsBreak = ( Me.StepNum >= Me.BreakStepNum )
		FileWatcher_copyAFileToTheLog  in_WatchingPath
	End If
End Function


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: OneReplaceTemplateClass
'***********************************************************************
Class  OneReplaceTemplateClass
	Public  KeywordBefore
	Public  ID_Before
	Public  TextBefore

	Public  ID_After
	Public  TextAfter
End Class


'* Section: Global
 
