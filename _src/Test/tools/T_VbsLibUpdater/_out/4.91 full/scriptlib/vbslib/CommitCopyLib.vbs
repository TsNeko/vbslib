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
Dim  g_CommitCopyLib_Path
     g_CommitCopyLib_Path = g_SrcPath


 
'*************************************************************************
'  <<< [CommitCopy_App] >>> 
'*************************************************************************
Sub  CommitCopy_App( AppKey, Path )
	Set commit = new CommitCopyUI_Class
	Set root = LoadXML( Path, Empty )

	commit.ShareFolderPath  = root.getAttribute( "share_folder_path" )
	commit.WorkFolderPath   = root.getAttribute( "work_folder_path" )
	commit.ShareName        = root.getAttribute( "name" )
	commit.IsHistoryInShare = root.getAttribute( "is_history_in_share" )

	If IsNull( commit.ShareFolderPath ) Then  Error
	If IsNull( commit.WorkFolderPath )  Then  commit.WorkFolderPath = "."
	If IsNull( commit.ShareName )       Then  commit.ShareName = "CommitCopy"
	If IsNull( commit.IsHistoryInShare ) Then commit.IsHistoryInShare = "yes"
	commit.IsHistoryInShare = ( commit.IsHistoryInShare <> "no" )

	Set w_=AppKey.NewWritable( Array( _
		commit.ShareFolderPath, _
		commit.WorkFolderPath, _
		commit.SyncedFolderName ) ).Enable()

	commit.OpenCUI
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [CommitCopyUI_Class] >>>> 
'-------------------------------------------------------------------------
 Class  CommitCopyUI_Class
	Public  UserName
	Public  ShareName
	Public  ExceptNames             '// This is compared by names in sub folder, too
	Public  ShareFolderPath
	Public  ShareFolderExceptNames  '// array of string
	Public  WorkFolderPath
	Public  WorkFolderFullPath
	Public  WorkFolderExceptNames   '// array of string
	Public  IsHistoryInShare
	Public  SyncedFolderName
	Public  HistoryFolderName
	Public  HistoryXML_FileName
	Public  StartTagName
	Public  SyncBackTagName
	Public  MutexFileName

	Public  m_ObjectNamesInShare  '// Object is file or folder
	Public  m_ObjectNamesInWork
	Public  m_ObjectNamesInSynced

	Public  E_NotSame
	Public  IsNewFunction '[TODO]

	Private Sub  Class_Initialize()
		Me.UserName = env("%USERNAME%@%USERDOMAIN%")
		Me.ExceptNames            = Array( "Thumbs.db" )
		Me.ShareFolderExceptNames = Array( )
		Me.WorkFolderExceptNames  = Array( )
		Me.IsHistoryInShare    = True
		Me.SyncedFolderName    = "_synced"
		Me.HistoryFolderName   = "_history"
		Me.HistoryXML_FileName = "history.xml"
		Me.StartTagName        = "(start)"
		Me.SyncBackTagName     = "previous"
		Me.MutexFileName       = "_Mutex.txt"
		Me.E_NotSame = &h4301
		Me.IsNewFunction = False
	End Sub

	Public Sub  SetRelatedAttributes()
		commit.WorkFolderFullPath = GetFullPath( commit.WorkFolderPath, Empty )
	End Sub

 
'*************************************************************************
'  <<< [CommitCopyUI_Class::OpenCUI] >>> 
'*************************************************************************
Public Sub  OpenCUI()
	g_CUI.SetAutoKeysFromMainArg
	Do
		echo_line
		echo  "共有フォルダー：("+ Me.ShareName +") "+ ShareFolderPath
		echo  ""

		If not Me.GetIsChechOuted() Then
			echo  "1. チェックアウト（ワーク・フォルダーへコピー） [CheckOut]"
			echo  "3. 排他制御のテスト                             [TestMutex]"
		Else
			echo  "2. 比較                         [Compare]"
		End If
		echo  "4. ワーク・フォルダーを開く     [OpenWork]"
		echo  "5. 共有フォルダーを開く         [OpenShare]"
		echo  "6. 前回の同期のフォルダーを開く [OpenSynced]"
		If Me.GetIsChechOuted() Then
			echo  "7. 更新（ワーク・フォルダーへコピー）  [Update]"
			echo  "8. コミット（共有フォルダーへコピー）  [Commit]"
			echo  "9. マージ（前回の同期をコピーして更新）[UpdateForMerge]"
		End If
		echo  "99. 終了 [Exit]"
		key = Input( "["+ Me.UserName +"] 番号またはコマンド名 >" )
		echo_line

		Select Case  key
			Case "1" : key = "CheckOut"
			Case "2" : key = "Compare"
			Case "3" : key = "TestMutex"
			Case "4" : key = "OpenWork"
			Case "5" : key = "OpenShare"
			Case "6" : key = "OpenSynced"
			Case "7" : key = "Update"
			Case "8" : key = "Commit"
			Case "9" : key = "UpdateForMerge"
			Case "99": key = "Exit"
		End Select

		If TryStart(e) Then  On Error Resume Next

		echo  ">"+ key
		Select Case  key
			Case "CheckOut"
				echo  "慣れるまで誤操作したときのために、共有フォルダー と ワーク・フォルダーのバックアップをしてください。"
				key = Input( "ワーク・フォルダーの内容を上書きまたは削除します(y/n)" )
				If key = "y" or key = "Y" Then
					Me.CheckOut
				End If

			Case "Compare"
				Me.Compare

			Case "TestMutex"
				Me.TestMutex

			Case "OpenShare"
				OpenFolder  Me.ShareFolderPath

			Case "OpenWork"
				OpenFolder  Me.WorkFolderPath

			Case "OpenSynced"
				OpenFolder  Me.SyncedFolderName

			Case "Commit"
				key = Input( "共有フォルダーの内容を上書きまたは削除します(y/n)" )
				If key = "y" or key = "Y" Then
					Me.Commit
				End If

			Case "Update"
				key = Input( "ワーク・フォルダーの内容を上書きまたは削除します(y/n)" )
				If key = "y" or key = "Y" Then
					Me.Update
				End If

			Case "UpdateForMerge"
				key = Input( "前回の同期のフォルダーの内容を、バックアップ・コピーしてから"+_
					"上書きまたは削除します(y/n)" )
				If key = "y" or key = "Y" Then
					Me.UpdateForMerge

					echo_line
					echo  "前回の同期のフォルダー      ："""+ Me.SyncedFolderName +" - "+ Me.SyncBackTagName +""""
					echo  "現在の共有フォルダーのコピー："""+ Me.SyncedFolderName +""""
					echo  "上記を参考にマージしたものを、ワーク・フォルダーに作成してください。 "+ _
						"作成したら、"""+ Me.SyncedFolderName +" - "+ Me.SyncBackTagName +_
						""" を削除してから、Commit してください"
				End If

			Case "Exit"
				Exit Sub
		End Select

		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then  echo  "[ERROR] "+ e.desc : e.Clear
	Loop
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::CheckOut] >>> 
'*************************************************************************
Public Sub  CheckOut()
	m_CheckProperties

	If Me.GetIsChechOuted() Then
		Raise  E_WriteAccessDenied, "前回の同期のフォルダーが存在しているときは、"+_
			"チェックアウトできません"
	End If

	Set mutex = m_LockByFileMutex()
	Me.ScanFolders

	'// Delete in work
	CallForEach1  GetRef("CallForEach_del"), m_ObjectNamesInWork, Me.WorkFolderPath

	'// Copy from share to work
	CallForEach2  GetRef("CallForEach_copy"), m_ObjectNamesInShare, _
		Me.ShareFolderPath, Me.WorkFolderPath

If Me.IsNewFunction Then
	'// Unset read only
	For Each  name  In m_ObjectNamesInShare
		path = GetFullPath( name, Me.WorkFolderFullPath )
		If g_fs.FolderExists( path ) Then
			If GetReadOnlyList( path, read_onlys, Empty ) > 0 Then  '//[out] read_onlys
				For Each step_path  In read_onlys
					Set file = g_fs.GetFile( path +"\"+ step_path )
					file.Attributes = file.Attributes  and  not ReadOnly
				Next
			End If
		Else
			Set file = g_fs.GetFile( path )
			file.Attributes = file.Attributes  and  not ReadOnly
		End If
	Next
End If

	'// Copy from work to synced
	del  Me.SyncedFolderName
	CallForEach2  GetRef("CallForEach_copy"), m_ObjectNamesInShare, _
		Me.WorkFolderPath, Me.SyncedFolderName

	'// Make history
	If Me.IsHistoryInShare Then _
		Me.MakeHistory  Me.ShareFolderPath, m_ObjectNamesInShare, False
	Me.MakeHistory  Me.WorkFolderPath,  m_ObjectNamesInShare, False
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::Compare] >>> 
'*************************************************************************
Public Sub  Compare()
	m_CheckProperties
	Me.ScanFolders

	is_share_update = m_CheckUpdate( "共有フォルダー", m_ObjectNamesInShare, Me.ShareFolderPath )
	is_work_update  = m_CheckUpdate( "ワーク・フォルダー", m_ObjectNamesInWork, Me.WorkFolderPath )

	If is_share_update Then
		If is_work_update Then
			echo  ""
			echo  "次に実行するコマンドは、UpdateForMerge と思われます。"
		Else
			echo  ""
			echo  "次に実行するコマンドは、Update と思われます。"
		End If
	Else
		If is_work_update Then
			echo  ""
			echo  "次に実行するコマンドは、Commit と思われます。"
		Else
		End If
	End If
End Sub


Private Function  m_CheckUpdate( FolderName, Names, FolderPath )
	Set ec = new EchoOff

	is_same = Me.CheckSameFolder( _
			FolderName, Names, FolderPath, _
			"前回の同期のフォルダー", m_ObjectNamesInSynced, Me.SyncedFolderName, _
			Empty )

	ec = Empty

	If is_same Then
		echo  FolderName +"の内容は、前回同期した内容と 同じです。○"
		m_CheckUpdate = False
	Else
		echo  FolderName +"の内容は、前回同期した内容と 異なります。▲"
		m_CheckUpdate = True
	End If
End Function


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::TestMutex] >>> 
'*************************************************************************
Public Sub  TestMutex()
	echo  "複数の PC から共有フォルダーにアクセスするときの排他制御をテストします。"+_
		"PC-A でロックした状態で、PC-B でロックしようとしたら、待つことを確認してください。"
	mutex = Empty

	Do
		echo  "1) ロックする"
		echo  "2) ロック解除する"
		echo  "9) 終了する"
		key = Input( "番号 >" )

		Select Case  key
			Case "1" : Set mutex = m_LockByFileMutex()
			Case "2" : mutex = Empty
			Case "9" : Exit Do
		End Select
	Loop
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::Commit] >>> 
'*************************************************************************
Public Sub  Commit()
	m_CheckProperties

	If exist( Me.SyncedFolderName +" - "+ Me.SyncBackTagName ) Then
		Raise  1, Me.SyncedFolderName +" - "+ Me.SyncBackTagName +" フォルダーを削除してください"
	End If

	Set mutex = m_LockByFileMutex()
	Me.ScanFolders

	Me.CheckSameFolder _
		"共有フォルダー", m_ObjectNamesInShare, Me.ShareFolderPath, _
		"前回の同期のフォルダー", m_ObjectNamesInSynced, Me.SyncedFolderName, _
		"共有フォルダーが更新された可能性があります。"

'//[TODO]
If Me.IsNewFunction Then
	For Each name  In m_ObjectNamesInShare

		'// Compare
		share_path = GetFullPath( name, Me.ShareFolderPath )
		work_path  = GetFullPath( name, Me.WorkFolderPath )
		If g_fs.FolderExists( share_path ) Then
			If not IsSameFolder( share_path, work_path, Empty ) Then
				del  share_path
				copy_ren  work_path, share_path
			End If
		Else
			If not IsSameBinaryFile( share_path, work_path, Empty ) Then
				del  share_path
				copy_ren  work_path, share_path
			End If
		End If
	Next
Else
	'// Delete in share
	CallForEach1  GetRef("CallForEach_del"), m_ObjectNamesInShare, Me.ShareFolderPath

	'// Copy from work to share
	CallForEach2  GetRef("CallForEach_copy"), m_ObjectNamesInWork, _
		Me.WorkFolderPath, Me.ShareFolderPath
End If

	'// Copy from work to synced
	del  Me.SyncedFolderName
	CallForEach2  GetRef("CallForEach_copy"), m_ObjectNamesInWork, _
		Me.WorkFolderPath, Me.SyncedFolderName

	'// Make history
	If Me.IsHistoryInShare Then _
		Me.MakeHistory  Me.ShareFolderPath, m_ObjectNamesInWork, True
	Me.MakeHistory  Me.WorkFolderPath,  m_ObjectNamesInWork, True
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::Update] >>> 
'*************************************************************************
Public Sub  Update()
	m_CheckProperties

	If exist( Me.SyncedFolderName +" - "+ Me.SyncBackTagName ) Then
		Raise  1, Me.SyncedFolderName +" - "+ Me.SyncBackTagName +" フォルダーを削除してください"
	End If

	Set mutex = m_LockByFileMutex()
	Me.ScanFolders

	Me.CheckSameFolder _
		"ワーク・フォルダー", m_ObjectNamesInWork, Me.WorkFolderPath, _
		"前回の同期のフォルダー", m_ObjectNamesInSynced, Me.SyncedFolderName, _
		"ワーク・フォルダーが更新された可能性があります。"

	If Me.CheckSameFolder( _
		"ワーク・フォルダー", m_ObjectNamesInWork, Me.WorkFolderPath, _
		"共有フォルダー", m_ObjectNamesInShare, Me.ShareFolderPath, _
		Empty ) Then

		echo  "更新はありません。"
		Exit Sub
	End If

	'// Delete in work
	CallForEach1  GetRef("CallForEach_del"), m_ObjectNamesInWork, Me.WorkFolderPath

	'// Copy from share to work
	CallForEach2  GetRef("CallForEach_copy"), m_ObjectNamesInShare, _
		Me.ShareFolderPath, Me.WorkFolderPath

	'// Copy from work to synced
	del  Me.SyncedFolderName
	CallForEach2  GetRef("CallForEach_copy"), m_ObjectNamesInShare, _
		Me.WorkFolderPath, Me.SyncedFolderName

	'// Make history
	Me.MakeHistory  Me.WorkFolderPath,  m_ObjectNamesInShare, True
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::MakeHistory] >>> 
'*************************************************************************
Sub  MakeHistory( FolderPath, Names, IsCommit )
	Set c = g_VBS_Lib
	new_history_xml = ""

	echo  ">MakeHistory  """+ FolderPath +""""

	time_stamp = W3CDTF( TestableNow() )
	time_stamp = Replace( time_stamp, ":", ";" )
	folder_full_path = GetFullPath( FolderPath, Empty )
	history_folder_path = GetFullPath( Me.HistoryFolderName, folder_full_path )
	ExpandWildcard  history_folder_path +"\*", c.Folder, folder, entity_names

	Set options_for_is_same_folder = new OptionsFor_IsSameFolder_Class
	options_for_is_same_folder.ExceptNames = Me.ExceptNames


	'// Make "... (start)" folder
	is_exist_start = False
	For Each  entity_name  In entity_names
		If InStr( entity_name, Me.StartTagName ) > 0 Then _
			is_exist_start = True : Exit For
	Next
	If not is_exist_start Then
		start_entity_name =  time_stamp +"  "+ Me.StartTagName
			'// Double space is for sort
		CallForEach2  GetRef("CallForEach_copy"), Names, _
			FolderPath, GetFullPath( start_entity_name, history_folder_path )

		AddArrElem  entity_names, start_entity_name


		'// Add to "new_history_xml"
		new_history_xml = new_history_xml + vbCRLF +"<Commit name="""+ _
			XmlAttr( start_entity_name ) +""">"+ vbCRLF
		For Each  name  In Names
			If g_fs.FolderExists( GetFullPath( name, folder_full_path ) ) Then
				file_or_folder = "Folder"
			Else
				file_or_folder = "File  "
			End If
			new_history_xml = new_history_xml +_
				"<"+ file_or_folder +" name="""+ XmlAttr( name ) +""" entity="""+ _
				XmlAttr( start_entity_name ) +"""/>"+ vbCRLF
		Next
		new_history_xml = new_history_xml +"</Commit>"+ vbCRLF
	End If


	If IsCommit Then

		'// Set "sorted_entity_names". "entity" is folder in history folder.
		sorted_entity_names = ArrayToNameOnlyClassArray( entity_names )
		ShakerSort  sorted_entity_names, 0, UBound( sorted_entity_names ), GetRef("NameCompare"), Empty


		'// ...
		new_entity_name = time_stamp +" "+ Me.UserName
		new_entity_path = GetFullPath( new_entity_name, history_folder_path )
		new_history_xml = new_history_xml + vbCRLF +"<Commit name="""+ _
			XmlAttr( new_entity_name ) +""">"+ vbCRLF


		'// Make "... <user>" folder
		For Each  name  In Names
			source_path = GetFullPath( name, folder_full_path )


			'// Set "entity_name"
			entity_name = Empty
			For i = UBound( sorted_entity_names )  To 0  Step -1
				entity_name = sorted_entity_names( i ).Name
				entity_path = GetFullPath( entity_name, history_folder_path )

				old_path = GetFullPath( name, entity_path )
				If exist( old_path ) Then
					If not IsSameFolder( source_path, old_path, options_for_is_same_folder ) Then
						entity_name = Empty
					End If
					Exit For
				End If
			Next
			If IsEmpty( entity_name )  or  i = -1 Then
				entity_name = new_entity_name
				entity_path = GetFullPath( entity_name, history_folder_path )

				'// Copy file or folder
				copy  source_path, new_entity_path
			End If


			'// Add to "new_history_xml"
			If g_fs.FolderExists( source_path ) Then
				file_or_folder = "Folder"
			Else
				file_or_folder = "File  "
			End If
			new_history_xml = new_history_xml +_
				"<"+ file_or_folder +" name="""+ XmlAttr( name ) +""" entity="""+ _
				XmlAttr( entity_name ) +"""/>"+ vbCRLF
		Next

		new_history_xml = new_history_xml +"</Commit>"+ vbCRLF
	End If


	'// Make history xml file
	xml_path = GetFullPath( HistoryXML_FileName, history_folder_path )
	If not exist( xml_path ) Then
		Set cs = new_TextFileCharSetStack( "Unicode" )
		CreateFile  xml_path, _
			"<?xml version=""1.0"" encoding=""UTF-16""?>"+ vbCRLF +_
			"<History>"+ vbCRLF +_
			"</History>"+ vbCRLF
	End If
	Set file = OpenForAppendXml( xml_path, Empty )
	file.Write  new_history_xml
	file = Empty
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::UpdateForMerge] >>> 
'*************************************************************************
Public Sub  UpdateForMerge()
	m_CheckProperties

	synced_back_up_name = Me.SyncedFolderName +" - "+ Me.SyncBackTagName
	synced_back_up_path = GetFullPath( synced_back_up_name, Me.WorkFolderFullPath )
	If exist( synced_back_up_path ) Then
		Raise  E_WriteAccessDenied, "<ERROR msg=""フォルダーが既に存在します"" path="""+ _
			synced_back_up_path +"""/>"
	End If

	Set mutex = m_LockByFileMutex()
	Me.ScanFolders

	'// Move from synced to synced back up
	new_synced_full_path = GetFullPath( Me.SyncedFolderName, Me.WorkFolderFullPath )
	ren  new_synced_full_path, synced_back_up_name

	'// Copy from share to synced
	CallForEach2  GetRef("CallForEach_copy"), m_ObjectNamesInShare, _
		Me.ShareFolderPath, GetFullPath( Me.SyncedFolderName, Me.WorkFolderFullPath )

	'// Make history
	move  GetFullPath( Me.HistoryFolderName, Me.WorkFolderFullPath ), new_synced_full_path
	Me.MakeHistory  new_synced_full_path,  m_ObjectNamesInShare, True
	move  GetFullPath( Me.HistoryFolderName, new_synced_full_path ), Me.WorkFolderFullPath
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::m_CheckProperties] >>> 
'*************************************************************************
Private Sub  m_CheckProperties()
	Me.WorkFolderFullPath = GetFullPath( Me.WorkFolderPath, Empty )

	Assert  InStr( Me.UserName, "/" ) = 0
	Assert  InStr( Me.UserName, "\" ) = 0
	AssertExist  Me.ShareFolderPath
	AssertExist  Me.WorkFolderFullPath
	Assert  InStr( Me.SyncedFolderName, "/" ) = 0
	Assert  InStr( Me.SyncedFolderName, "\" ) = 0

	Assert  StrComp( g_sh.CurrentDirectory, Me.WorkFolderFullPath, 1 ) = 0  or _
		StrCompHeadOf( Me.WorkFolderFullPath +"\", g_sh.CurrentDirectory, Empty ) <> 0
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::m_LockByFileMutex] >>> 
'*************************************************************************
Private Function  m_LockByFileMutex()
	Set c = g_VBS_Lib
	Set m_LockByFileMutex = LockByFileMutex( _
		GetFullPath( Me.MutexFileName, GetFullPath( Me.ShareFolderPath, Empty ) ), _
		c.Forever )
End Function


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::GetIsChechOuted] >>> 
'*************************************************************************
Public Function  GetIsChechOuted()
	GetIsChechOuted = exist( Me.SyncedFolderName )
End Function


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::ScanFolders] >>> 
'*************************************************************************
Public Sub  ScanFolders()

	'// Set "m_ObjectNamesInShare"
	except_files = Array( Me.MutexFileName, Me.SyncedFolderName, WScript.ScriptName, Me.HistoryFolderName )
	AddArrElem  except_files, Me.ShareFolderExceptNames
	AddArrElem  except_files, Me.ExceptNames
	m_EnumNames  Me.ShareFolderPath, m_ObjectNamesInShare, except_files


	'// Set "m_ObjectNamesInWork"
	If StrComp( g_sh.CurrentDirectory, Me.WorkFolderFullPath, 1 ) = 0 Then  '// same_work_as_current
		except_files = Array( g_fs.GetFileName( g_vbslib_folder ), _
			Me.SyncedFolderName, WScript.ScriptName, HistoryFolderName )
	Else
		except_files = Array( )
	End If
	AddArrElem  except_files, Me.WorkFolderExceptNames
	AddArrElem  except_files, Me.ExceptNames
	m_EnumNames  Me.WorkFolderPath, m_ObjectNamesInWork, except_files


	'// Set "m_ObjectNamesInSynced"
	If exist( Me.SyncedFolderName ) Then
		except_files = Array( )
		AddArrElem  except_files, Me.ExceptNames
		m_EnumNames  Me.SyncedFolderName, m_ObjectNamesInSynced, except_files
	Else
		m_ObjectNamesInSynced = Array( )
	End If
End Sub


'//[CommitCopyUI_Class::m_EnumNames]
Private Sub  m_EnumNames( FolderPath, out_Names, ExceptNames )
	Set c = g_VBS_Lib

	is_sort = g_Vers("ExpandWildcard_Sort")
	g_Vers("ExpandWildcard_Sort") = True

	ExpandWildcard  GetFullPath( "*", GetFullPath( FolderPath, Empty ) ), _
		c.File or c.Folder, folder, step_paths

	g_Vers("ExpandWildcard_Sort") = is_sort

	ReDim  out_Names( UBound( step_paths ) )
	skip_count = 0
	i = 0
	For Each name  In step_paths
		is_skip = False
		For Each  except_name  In ExceptNames
			If StrComp( name, except_name, 1 ) = 0 Then
				is_skip = True
				Exit For
			End If
		Next

		If not is_skip Then
			out_Names( i ) = name
			i = i + 1
		Else
			skip_count = skip_count + 1
		End If
	Next
	ReDim Preserve  out_Names( UBound( step_paths ) - skip_count )
End Sub


 
'*************************************************************************
'  <<< [CommitCopyUI_Class::CheckSameFolder] >>> 
'*************************************************************************
Public Function  CheckSameFolder( FolderNameA, ObjectNamesA, FolderPathA, _
	FolderNameB, ObjectNamesB, FolderPathB, RaiseMessage )

	Set c = g_VBS_Lib

	Set obj = new OptionsFor_IsSameFolder_Class
	obj.ExceptNames = Me.ExceptNames
	options_for_is_same_folder = Array( c.EchoV_NotSame, obj )
	obj = Empty

	If UBound( ObjectNamesA ) <> UBound( ObjectNamesB ) Then
		If not IsEmpty( RaiseMessage ) Then
			Raise  Me.E_NotSame, FolderNameA +" と "+ FolderNameB + _
				" のファイルまたはフォルダーの数が異なります。"+ RaiseMessage
		Else
			CheckSameFolder = False
			Exit Function
		End If
	End If

	If not IsSameArrayOutOfOrder( ObjectNamesA, ObjectNamesB, Empty ) Then
		If not IsEmpty( RaiseMessage ) Then
			Raise  Me.E_NotSame, FolderNameA +" と "+ FolderNameB + _
				" の中のファイルまたはフォルダーの名前が異なります。"+ RaiseMessage
		Else
			CheckSameFolder = False
			Exit Function
		End If
	End If

	folder_A_full_path = GetFullPath( FolderPathA, Empty )
	folder_B_full_path = GetFullPath( FolderPathB, Empty )
	For Each  name  In ObjectNamesA
		object_A_full_path = GetFullPath( name, folder_A_full_path )
		object_B_full_path = GetFullPath( name, folder_B_full_path )
		If not IsSameFolder( object_A_full_path, object_B_full_path, _
				options_for_is_same_folder ) Then
			If not IsEmpty( RaiseMessage ) Then
				Raise  Me.E_NotSame, object_A_full_path +" と "+ object_B_full_path + _
					" の中の "+ name +" の内容が異なります。"+ RaiseMessage
			Else
				CheckSameFolder = False
				Exit Function
			End If
		End If
	Next

	CheckSameFolder = True
End Function


 
' ### <<<< End of Class implement >>>> 
End Class


 
