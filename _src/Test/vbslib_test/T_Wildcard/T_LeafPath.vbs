Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_FileHashCache", _
			"2","T_LeafPath", _
			"3","T_LeafPathWithFullSet", _
			"4","T_PatchAndBackUp" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_FileHashCache
'***********************************************************************
Sub  T_FileHashCache( Opt, AppKey )
	Set cache = g_FileHashCache
	g_FileHashCache.RemoveAll

	Assert  cache( "Files\1\A.txt" ) = "d41d8cd98f00b204e9800998ecf8427e"
		Assert  g_fs.GetFile( "Files\1\A.txt" ).Size = 0
	Assert  cache( "Files\Patch\01\Modify_Del.txt"    ) = "9060587edeb01a63e3d3edc959678d1e"
	Assert  cache( "Files\Patch\01\Modify_Equal.txt"  ) = "9060587edeb01a63e3d3edc959678d1e"
	Assert  cache( "Files\Patch\01\Modify_Modify.txt" ) = "f919feb1d9584b01ed285d230b9883a4"
	Assert  cache( "Files\Patch\01" ) = "Folder"
	Assert  cache( "data\fo2" ) = "EmptyFolder"
	Assert  cache( "Files\Patch\01\NotFound" ) = ""
	cache.Remove  "_NotFound.txt"  '// Check no error


	Set w_= AppKey.NewWritable( "_work" ).Enable()

	cache.CopyRenFile  "Files\Patch\02\Add.txt", "_work\Add.txt"
	cache.CopyRenFile  "data\fo2", "_work\fo2"
	Assert  IsSameBinaryFile( "_work\Add.txt", "Files\Patch\02\Add.txt", Empty )
	Assert  g_fs.GetFolder( "_work\fo2" ).Files.Count = 0
	Assert  g_fs.GetFolder( "_work\fo2" ).SubFolders.Count = 0

	cache.DeleteFile  "_work\Add.txt"
Stop
	cache.DeleteFile  "_work\fo2"
	Assert  not exist( "_work\Add.txt" )
	Assert  not exist( "_work\fo2" )

	Pass
End Sub


 
'***********************************************************************
'* Function: T_LeafPath
'***********************************************************************
Sub  T_LeafPath( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	g_Vers("ExpandWildcard_Sort") = True
	Set section = new SectionTree
'//SetStartSectionTree  "0"

	If section.Start( "T_LeafPath_1" ) Then

	For Each  type_of_patch  In  Array( "Object", "String", "ChangePatchToTarget" )

		'// Set up
		g_FileHashCache.RemoveAll
		del  "_work"

		'// Test Main
		Set  files_01 = EnumerateToLeafPathDictionary( "Files\Patch\01" )
		If type_of_patch = "Object" Then
			Set  patch_02 = EnumerateToPatchAndBackUpDictionary( "Files\Patch\02-Patch-of-01" )
			AttachPatchAndBackUpDictionary  files_01, patch_02, "Files\Patch\01", False
		ElseIf type_of_patch = "String" Then
			AttachPatchAndBackUpDictionary  files_01, "Files\Patch\02-Patch-of-01", "Files\Patch\01", False
		Else
			Assert  type_of_patch = "ChangePatchToTarget"
			Set  patch_02 = EnumerateToPatchAndBackUpDictionary( "Files\Patch\02-Patch-of-01" )
			ChangeKeyOfPatchAndBackUpDictionaryToTarget  patch_02, "Files\Patch\01"
			AttachPatchAndBackUpDictionary  files_01, patch_02, "Files\Patch\01", False
		End If
		RemoveKeyOfEmptyItemInLeafPathDictionary  files_01, False

		'// Check
		Set  files_02 = EnumerateToLeafPathDictionary( "Files\Patch\02" )
		Assert  files_01.Count = files_02.Count
		keys_1 = files_01.Keys
		keys_2 = files_02.Keys
		For i=0  To  files_01.Count - 1
			Assert  keys_1(i) = Replace( keys_2(i), "\02\", "\01\" )
		Next

		Set  files_02 = EnumerateToLeafPathDictionary( "Files\Patch\02-Patch-of-01" )
		Assert  not files_02.Exists( GetFullPath( "Files\Patch\02-Patch-of-01", Empty ) )

		'// Test Main
		ChangeKeyOfLeafPathDictionary  files_01, "Files", "_work"
		CopyFilesToLeafPathDictionary  files_01, True

		'// Check
		Assert  fc( "_work\Patch\01", "Files\Patch\02" )

		For Each  key  In  files_01.Keys
			Assert  key = files_01( key )
		Next

		'// Clean
		del  "_work"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_CheckBackUp" ) Then

	For Each  bad_file_name  In  Array( Empty, "Del.txt", "Modify_Equal.txt", "AlreadyDeleted.txt" )

		'// Set up
		g_FileHashCache.RemoveAll
		del  "_work"
		copy  "Files\Patch\02-Patch-of-01\*", "_work\Patch\02-Patch-of-01"
		If not IsEmpty( bad_file_name ) Then
			CreateFile  "_work\Patch\02-Patch-of-01\back_up\"+ bad_file_name, "BadBackUp"
		End If
		Set  files_01 = EnumerateToLeafPathDictionary( "Files\Patch\01" )
		Set  patch_02 = EnumerateToPatchAndBackUpDictionary( "_work\Patch\02-Patch-of-01" )

		'// Test Main
		If IsEmpty( bad_file_name ) Then
			AttachPatchAndBackUpDictionary  files_01, patch_02, "Files\Patch\01", False
		Else
			'// Error Handling Test
			echo  vbCRLF+"Next is Error Test"
			If TryStart(e) Then  On Error Resume Next

				AttachPatchAndBackUpDictionary  files_01, patch_02, "Files\Patch\01", True

			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2
			echo    e2.desc
			Assert  InStr( e2.desc, "_work\Patch\02-Patch-of-01\back_up" ) > 0
			Assert  e2.num = E_NotExpectedBackUp
		End If

		'// Clean
		del  "_work"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_MakePatch" ) Then

		For Each  is_dic  In  Array( True, False )

			'// Set up
			g_FileHashCache.RemoveAll
			del  "_work"

			If is_dic Then
				Set dic_01 = EnumerateToLeafPathDictionary( "Files\Patch\01" )
				Set dic_02 = EnumerateToLeafPathDictionary( "Files\Patch\02" )
			Else
				dic_01 = Empty
				dic_02 = Empty
			End If

			'// Test Main
			Set patch_ = MakePatchAndBackUpDictionary( _
				dic_02, "Files\Patch\02", _
				dic_01, "Files\Patch\01", _
				"_work\Patch" )

			CopyFilesToLeafPathDictionary  patch_, False

			'// Check
			Assert  fc( "_work\Patch", "Files\Patch\02-Patch-of-01" )

			'// Clean
			del  "_work"
		Next


		'//===========================================================

		'// Set up
		g_FileHashCache.RemoveAll
		del  "_work"

		'// Test Main
		Set patch_ = MakePatchAndBackUpDictionary( _
			Empty, "Files\Patch\12", _
			Empty, "Files\Patch\11", _
			"_work\Patch" )
		CopyFilesToLeafPathDictionary  patch_, False

		'// Check
		Assert  fc( "_work\Patch", "Files\Patch\12-Patch-of-11" )

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_AttachSeparatePatch" ) Then

	'// Set up
	del  "_work"
	copy  "Files\Patch\01\*", "_work\target"
	copy  "Files\Patch\02-Patch-of-01\back_up\*", "_work\back_up"

	'// Test Main
	files = Empty
	g_FileHashCache.RemoveAll
	Set patch_ = MakePatchAndBackUpDictionary( _
		Empty, "Files\Patch\02-Patch-of-01\patch", Empty, "_work\back_up", Empty )
	AttachPatchAndBackUpDictionary  files,  patch_,  "_work\target",  False
	CopyFilesToLeafPathDictionary  files, True

	'// Check
	Assert  fc( "_work\target", "Files\Patch\02" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_IsSameHash" ) Then

	For Each  is_object  In  Array( True, False )

		'// Set up
		g_FileHashCache.RemoveAll
		del  "_work"
		copy  "Files\1\*", "_work"
		If is_object Then
			Set  files_01 = EnumerateToLeafPathDictionary( "Files\1" )
			Set  files_02 = EnumerateToLeafPathDictionary( "_work" )
		Else
			files_01 = Empty
			files_02 = Empty
		End If
		g_FileHashCache.RemoveAll

		'// Test Main
		is_same = IsSameHashValuesOfLeafPathDictionary( _
			files_01, "Files\1", files_02, "_work" )

		'// Check
		Assert  is_same


		'// Set up
		CreateFile  "_work\A.txt", "Updated"
		If not is_object Then
			files_01 = Empty
			files_02 = Empty
		End If
		g_FileHashCache.RemoveAll

		'// Test Main
		is_same = IsSameHashValuesOfLeafPathDictionary( _
			files_01, "Files\1", files_02, "_work" )

		'// Check
		Assert  not is_same

		'// Clean
		del  "_work"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_IsSameName" ) Then

	For Each  is_object  In  Array( True, False )

		'// Set up
		g_FileHashCache.RemoveAll
		del  "_work"
		copy  "Files\1\*", "_work"
		CreateFile  "_work\A.txt", "Updated"
		If is_object Then
			Set  files_01 = EnumerateToLeafPathDictionary( "Files\1" )
			Set  files_02 = EnumerateToLeafPathDictionary( "_work" )
		Else
			files_01 = Empty
			files_02 = Empty
		End If

		'// Test Main
		is_same = IsSameFileNamesOfLeafPathDictionary( _
			files_01, "Files\1", files_02, "_work" )

		'// Check
		Assert  is_same


		'// Set up
		ren  "_work\A.txt", "_work\Plus.txt"
		If is_object Then
			Set  files_02 = EnumerateToLeafPathDictionary( "_work" )
		Else
			files_01 = Empty
			files_02 = Empty
		End If

		'// Test Main
		is_same = IsSameFileNamesOfLeafPathDictionary( _
			files_01, "Files\1", files_02, "_work" )

		'// Check
		Assert  not is_same

		'// Clean
		del  "_work"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_RemoveEmpty" ) Then

		'// Set up
		g_FileHashCache.RemoveAll
		del  "_work"
		copy  "Files\1\A.txt", "_work"
		copy  "Files\1\B.txt", "_work"
		copy  "Files\1\C.ini", "_work"
		work_path = GetFullPath( "_work", Empty )

		'// Test Main : Not Delete Files
		Set dic = Dict(Array( _
			work_path +"\A.txt", new_NameOnlyClass( Empty, Empty ), _
			work_path +"\B.txt", new_NameOnlyClass( Empty, Empty ), _
			work_path +"\C.ini", new_NameOnlyClass( work_path +"\C.ini", Empty ) ))
		RemoveKeyOfEmptyItemInLeafPathDictionary  dic, False

		'// Check
		Assert  not dic.Exists( work_path +"\A.txt" )
		Assert  not dic.Exists( work_path +"\B.txt" )
		Assert      dic.Exists( work_path +"\C.ini" )
		Assert      exist( work_path +"\A.txt" )
		Assert      exist( work_path +"\B.txt" )
		Assert      exist( work_path +"\C.ini" )

		'// Test Main : Delete Files
		Set dic = Dict(Array( _
			work_path +"\A.txt", new_NameOnlyClass( Empty, Empty ), _
			work_path +"\B.txt", new_NameOnlyClass( Empty, Empty ), _
			work_path +"\C.ini", new_NameOnlyClass( work_path +"\C.ini", Empty ) ))
		RemoveKeyOfEmptyItemInLeafPathDictionary  dic, True

		'// Check
		Assert  not dic.Exists( work_path +"\A.txt" )
		Assert  not dic.Exists( work_path +"\B.txt" )
		Assert      dic.Exists( work_path +"\C.ini" )
		Assert  not exist( work_path +"\A.txt" )
		Assert  not exist( work_path +"\B.txt" )
		Assert      exist( work_path +"\C.ini" )

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_GetNotSameFiles" ) Then
		Const  NotCaseSensitive = 1

		'// Set up
		Set dic = CreateObject( "Scripting.Dictionary" )
		dic.CompareMode = NotCaseSensitive
		g_Vers("ExpandWildcard_Sort") = True

		base = GetFullPath( "Files\Patch", Empty )

		Set dic( base +"\02-Patch-of-01\back_up\Del.txt" ) = _
			new_NameOnlyClass( base +"\01\Del.txt", Empty )

		Set dic( base +"\02-Patch-of-01\back_up\Modify_Del.txt" ) = _
			new_NameOnlyClass( base +"\02\Modify_Del.txt", Empty )

		Set dic( base +"\02-Patch-of-01\back_up\Modify_Equal.txt" ) = _
			new_NameOnlyClass( base +"\01\Modify_Equal.txt", Empty )

		Set dic( base +"\02-Patch-of-01\back_up\Modify_Modify.txt" ) = _
			new_NameOnlyClass( base +"\02\Modify_Modify.txt", Empty )


		'// Test Main
		not_same_paths = GetNotSameFileKeysAsItemsOfLeafPathDictionary( dic )


		'// Check
		Assert  IsSameArray( not_same_paths, Array( _
			base +"\02-Patch-of-01\back_up\Modify_Del.txt", _
			base +"\02-Patch-of-01\back_up\Modify_Modify.txt" ) )


		'//===========================================================
		'// Set up
		Set dic = CreateObject( "Scripting.Dictionary" )
		dic.CompareMode = NotCaseSensitive

		Set dic( base +"\02-Patch-of-01\back_up\Del.txt" ) = _
			new_NameOnlyClass( base +"\01\Del.txt", Empty )

		Set dic( base +"\02-Patch-of-01\back_up\Modify_Del.txt" ) = _
			new_NameOnlyClass( base +"\01\Modify_Del.txt", Empty )


		'// Test Main
		not_same_paths = GetNotSameFileKeysAsItemsOfLeafPathDictionary( dic )


		'// Check
		Assert  UBound( not_same_paths ) = -1

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPath_Normalize" ) Then

		'// Set up
		Set dic = CreateObject( "Scripting.Dictionary" )
		dic.CompareMode = NotCaseSensitive
		Set dic( "C:\Folder" )            = new_NameOnlyClass( "C:\Folder", Empty )
		Set dic( "C:\Folder\File.txt" )   = new_NameOnlyClass( "C:\Folder\File.txt", Empty )
		Set dic( "C:\FolderB" )           = new_NameOnlyClass( "C:\FolderB", Empty )
		Set dic( "C:\FolderBB" )          = new_NameOnlyClass( "C:\FolderBB", Empty )
		Set dic( "C:\FolderBBB" )         = new_NameOnlyClass( "C:\FolderBBB", Empty )
		Set dic( "C:\FolderBB\File.txt" ) = new_NameOnlyClass( "C:\FolderBB\File.txt", Empty )
		Set dic( "" )                     = new_NameOnlyClass( "", Empty )

		'// Test Main
		NormalizeLeafPathDictionary  dic

		'// Check
		Assert  IsSameArray( dic.Keys, Array( "C:\Folder\File.txt", "C:\FolderB", "C:\FolderBBB", _
			"C:\FolderBB\File.txt" ) )

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_LeafPathWithFullSet
'***********************************************************************
Sub  T_LeafPathWithFullSet( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	g_Vers("ExpandWildcard_Sort") = True
	Set section = new SectionTree
	Set tc = get_ToolsLibConsts()
'//SetStartSectionTree  "T_LeafPathWithFullSet_BodyList"

	If g_is_vbslib_for_fast_user Then
	Else
		Skip
	End If


	'//===========================================================
	If section.Start( "T_LeafPathWithFullSet_1" ) Then


	'// Test Main
	Set  leaves = EnumerateToLeafPathDictionaryByFullSetFile( "Files\T_Leaf\List",  Empty,  Empty )

	'// Check
	Assert  leaves.Count = 4

	For Each  t  In DicTable( Array( _
		"Key",       "Name",      "HashValue",                         "TimeStamp",                  "BodyFullPath",  Empty, _
		"1.txt",     "1.txt",     "c4ca4238a0b923820dcc509a6f75849b",  "2017-01-22T11:01:00+09:00",  Empty, _
		"Empty",     "Empty",     tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      Empty, _
		"Sub\1.txt", "Sub\1.txt", "66d19fb5de18851b7bf65fdecf08851d",  "2017-01-22T11:03:00+09:00",  Empty, _
		"Sub\2.txt", "Sub\2.txt", "4d36f72a68dd010154268d557b42cb2b",  "2017-01-22T11:04:00+09:00",  Empty ) )

		T_LeafPathWithFullSet_check  leaves,  t
	Next


	'// Test Main
	Set  leaves = EnumerateToLeafPathDictionaryByFullSetFile( "Files\T_Leaf\ListAndFile",  Empty,  Empty )

	'// Check
	Assert  leaves.Count = 16
	base = GetFullPath( "Files\T_Leaf\ListAndFile",  Empty )

	For Each  t  In DicTable( Array( _
		"Key",                   "Name",                  "HashValue",                         "TimeStamp",                  "BodyFullPath",  Empty, _
		"File\1.txt",            "File\1.txt",            "c4ca4238a0b923820dcc509a6f75849b",  "2017-01-22T11:01:00+09:00",  GetFullPath( "File\1.txt", base ), _
		"File\Empty",            "File\Empty",            tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      GetFullPath( "File\Empty", base ), _
		"File\Sub\1.txt",        "File\Sub\1.txt",        "66d19fb5de18851b7bf65fdecf08851d",  "2017-01-22T11:03:00+09:00",  GetFullPath( "File\Sub\1.txt", base ), _
		"File\Sub\2.txt",        "File\Sub\2.txt",        "4d36f72a68dd010154268d557b42cb2b",  "2017-01-22T11:04:00+09:00",  GetFullPath( "File\Sub\2.txt", base ), _
		"List\1.txt",            "List\1.txt",            "c4ca4238a0b923820dcc509a6f75849b",  "2016-03-03T03:01:00+09:00",  Empty, _
		"List\Empty",            "List\Empty",            tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      Empty, _
		"List\Sub\1.txt",        "List\Sub\1.txt",        "66d19fb5de18851b7bf65fdecf08851d",  "2016-03-03T03:03:00+09:00",  Empty, _
		"List\Sub\2.txt",        "List\Sub\2.txt",        "4d36f72a68dd010154268d557b42cb2b",  "2016-03-03T03:04:00+09:00",  Empty, _
		"ListAndFile\1.txt",     "ListAndFile\1.txt",     "c4ca4238a0b923820dcc509a6f75849b",  "2016-03-03T03:05:00+09:00",  GetFullPath( "ListAndFile\1.txt", base ), _
		"ListAndFile\Empty",     "ListAndFile\Empty",     tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      GetFullPath( "ListAndFile\Empty", base ), _
		"ListAndFile\Sub\1.txt", "ListAndFile\Sub\1.txt", "66d19fb5de18851b7bf65fdecf08851d",  "2016-03-03T03:07:00+09:00",  GetFullPath( "ListAndFile\Sub\1.txt", base ), _
		"ListAndFile\Sub\2.txt", "ListAndFile\Sub\2.txt", "4d36f72a68dd010154268d557b42cb2b",  "2016-03-03T03:08:00+09:00",  GetFullPath( "ListAndFile\Sub\2.txt", base ), _
		"ListDiffFile\1.txt",    "ListDiffFile\1.txt",    "6af2d30e671ebc9deaa134b9f0a1e248",  "2017-01-22T11:09:00+09:00",  GetFullPath( "ListDiffFile\1.txt", base ), _
		"ListDiffFile\Empty",    "ListDiffFile\Empty",    tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      GetFullPath( "ListDiffFile\Empty", base ), _
		"ListDiffFile\Sub\1.txt","ListDiffFile\Sub\1.txt","31f1540088f935faa99ed6bce3c69ea3",  "2017-01-22T11:11:00+09:00",  GetFullPath( "ListDiffFile\Sub\1.txt", base ), _
		"ListDiffFile\Sub\2.txt","ListDiffFile\Sub\2.txt","5ea81f4a530b2f033c1e17481a16a7ff",  "2017-01-22T11:12:00+09:00",  GetFullPath( "ListDiffFile\Sub\2.txt", base ) ) )

		T_LeafPathWithFullSet_check  leaves,  t
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LeafPathWithFullSet_NoFullSetFile" ) Then

	'// Test Main
	Set  leaves = EnumerateToLeafPathDictionaryByFullSetFile( "Files\T_Leaf\File",  Empty,  Empty )

	'// Check
	Assert  leaves.Count = 4
	base_folder = GetFullPath( "Files\T_Leaf\File",  Empty )

	For Each  t  In DicTable( Array( _
		"Key",       "Name",      "HashValue",                         "TimeStamp",                  "BodyFullPath",  Empty, _
		"1.txt",     "1.txt",     "c4ca4238a0b923820dcc509a6f75849b",  "2017-01-22T11:01:00+09:00",  GetFullPath( "1.txt", base_folder ), _
		"Empty",     "Empty",     tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      GetFullPath( "Empty", base_folder ), _
		"Sub\1.txt", "Sub\1.txt", "66d19fb5de18851b7bf65fdecf08851d",  "2017-01-22T11:03:00+09:00",  GetFullPath( "Sub\1.txt", base_folder ), _
		"Sub\2.txt", "Sub\2.txt", "4d36f72a68dd010154268d557b42cb2b",  "2017-01-22T11:04:00+09:00",  GetFullPath( "Sub\2.txt", base_folder ) ) )

		T_LeafPathWithFullSet_check  leaves,  t
	Next

	End If : section.End_


	'//===========================================================
	For Each  is_object  In  Array( False, True )
	If section.Start( "T_LeafPathWithFullSet_BodyList_"+ GetEchoStr( is_object ) ) Then

	'// Set up
	list_of_MD5 = "Files\T_Leaf\BodyList.txt"
	If is_object Then _
		Set list_of_MD5 = OpenForDefragment( list_of_MD5,  Empty )

	'// Test Main
	Set  leaves = EnumerateToLeafPathDictionaryByFullSetFile( "Files\T_Leaf\ListAndFile", _
		list_of_MD5,  Empty )

	'// Check
	Assert  leaves.Count = 16
	base_folder = GetFullPath( "Files\T_Leaf\ListAndFile",  Empty )
	If NOT is_object Then
		base_of_hash = GetParentFullPath( list_of_MD5 )
	Else
		base_of_hash = g_fs.GetParentFolderName( list_of_MD5.FileFullPath )
	End If

	For Each  t  In DicTable( Array( _
		"Key",                   "Name",                  "HashValue",                         "TimeStamp",                  "BodyFullPath",  Empty, _
		"File\1.txt",            "File\1.txt",            "c4ca4238a0b923820dcc509a6f75849b",  "2017-01-22T11:01:00+09:00",  GetFullPath( "File\1.txt", base_folder ), _
		"File\Empty",            "File\Empty",            tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      GetFullPath( "File\Empty", base_folder ), _
		"File\Sub\1.txt",        "File\Sub\1.txt",        "66d19fb5de18851b7bf65fdecf08851d",  "2017-01-22T11:03:00+09:00",  GetFullPath( "File\Sub\1.txt", base_folder ), _
		"File\Sub\2.txt",        "File\Sub\2.txt",        "4d36f72a68dd010154268d557b42cb2b",  "2017-01-22T11:04:00+09:00",  GetFullPath( "File\Sub\2.txt", base_folder ), _
		"List\1.txt",            "List\1.txt",            "c4ca4238a0b923820dcc509a6f75849b",  "2016-03-03T03:01:00+09:00",  GetFullPath( "File\1.txt", base_of_hash ), _
		"List\Empty",            "List\Empty",            tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      Empty, _
		"List\Sub\1.txt",        "List\Sub\1.txt",        "66d19fb5de18851b7bf65fdecf08851d",  "2016-03-03T03:03:00+09:00",  GetFullPath( "File\Sub\1.txt", base_of_hash ), _
		"List\Sub\2.txt",        "List\Sub\2.txt",        "4d36f72a68dd010154268d557b42cb2b",  "2016-03-03T03:04:00+09:00",  GetFullPath( "File\Sub\2.txt", base_of_hash ), _
		"ListAndFile\1.txt",     "ListAndFile\1.txt",     "c4ca4238a0b923820dcc509a6f75849b",  "2016-03-03T03:05:00+09:00",  GetFullPath( "ListAndFile\1.txt", base_folder ), _
		"ListAndFile\Empty",     "ListAndFile\Empty",     tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      GetFullPath( "ListAndFile\Empty", base_folder ), _
		"ListAndFile\Sub\1.txt", "ListAndFile\Sub\1.txt", "66d19fb5de18851b7bf65fdecf08851d",  "2016-03-03T03:07:00+09:00",  GetFullPath( "ListAndFile\Sub\1.txt", base_folder ), _
		"ListAndFile\Sub\2.txt", "ListAndFile\Sub\2.txt", "4d36f72a68dd010154268d557b42cb2b",  "2016-03-03T03:08:00+09:00",  GetFullPath( "ListAndFile\Sub\2.txt", base_folder ), _
		"ListDiffFile\1.txt",    "ListDiffFile\1.txt",    "6af2d30e671ebc9deaa134b9f0a1e248",  "2017-01-22T11:09:00+09:00",  GetFullPath( "ListDiffFile\1.txt", base ), _
		"ListDiffFile\Empty",    "ListDiffFile\Empty",    tc.EmptyFolderMD5,                   tc.EmptyFolderTimeStamp,      GetFullPath( "ListDiffFile\Empty", base ), _
		"ListDiffFile\Sub\1.txt","ListDiffFile\Sub\1.txt","31f1540088f935faa99ed6bce3c69ea3",  "2017-01-22T11:11:00+09:00",  GetFullPath( "ListDiffFile\Sub\1.txt", base ), _
		"ListDiffFile\Sub\2.txt","ListDiffFile\Sub\2.txt","5ea81f4a530b2f033c1e17481a16a7ff",  "2017-01-22T11:12:00+09:00",  GetFullPath( "ListDiffFile\Sub\2.txt", base ) ) )

		T_LeafPathWithFullSet_check  leaves,  t
	Next

	End If : section.End_
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_LeafPathWithFullSet_check
'***********************************************************************
Sub  T_LeafPathWithFullSet_check( in_Leaves,  in_Data )
	Set  leaf = in_Leaves( in_Data( "Key" ) )
	Assert  leaf.Name = in_Data( "Name" )
	Assert  leaf.HashValue = in_Data( "HashValue" )
	Assert  leaf.TimeStamp = in_Data( "TimeStamp" )
	If IsEmpty( in_Data( "TimeStamp" ) ) Then
		Assert  IsEmpty( leaf.BodyFullPath )
	Else
		Assert  leaf.BodyFullPath = in_Data( "BodyFullPath" )
	End If
End Sub


 
'***********************************************************************
'* Function: T_PatchAndBackUp
'***********************************************************************
Sub  T_PatchAndBackUp( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
	Set c = get_ToolsLibConsts()
'//SetStartSectionTree  "T_PatchAndBackUp_TwistedMerge"


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_1" ) Then

	'// Set up
	del  "_work"
	copy  "Files\Patch\*", "_work"
	g_FileHashCache.RemoveAll

	'// Test Main
	AttachPatchAndCheckBackUp  "_work\01",  Empty, _
		"_work\02-Patch-of-01\patch",  "_work\02-Patch-of-01\back_up"

	'// Check
	Assert  fc( "_work\01", "Files\Patch\02" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_Moved" ) Then

	'// Set up
	del  "_work"
	copy  "Files\MovedPatch\*", "_work"
	g_FileHashCache.RemoveAll

	'// Test Main
	AttachPatchAndCheckBackUp  "_work\01\Sub",  "_work\01", _
		"_work\02-Patch-of-01\patch",  "_work\02-Patch-of-01\back_up"

	'// Check
	Assert  fc( "_work\01", "Files\MovedPatch\02" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_Attach" ) Then

	'// Set up
	del  "_work"
	copy  "Files\Patch\*", "_work"
	g_FileHashCache.RemoveAll

	'// Test Main
	patch_path = "_work\02-Patch-of-01"
	target_path = "_work\01"
	echo  ">AttachPatchAndBackUp  """+ target_path +""""
	Set ec = new EchoOff
	target = Empty
	Set patch_ = EnumerateToPatchAndBackUpDictionary( patch_path )
	AttachPatchAndBackUpDictionary  target,  patch_,  target_path,  True
	CopyFilesToLeafPathDictionary  target, False
	ec = Empty

	'// Check
	Assert  fc( target_path, "Files\Patch\02" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_Make" ) Then

	'// Set up
	del  "_work"
	copy  "Files\Patch\*", "_work"
	g_FileHashCache.RemoveAll

	'// Test Main
	patch_path = "_work\_patch"
	echo  ">MakePatchAndBackUp  """+ patch_path +""""
	Set ec = new EchoOff
	before = Empty
	after = Empty
	Set patch_ = MakePatchAndBackUpDictionary( after, "_work\02", before, "_work\01", patch_path )
	CopyFilesToLeafPathDictionary  patch_, False
	ec = Empty

	'// Check
	Assert  fc( patch_path, "_work\02-Patch-of-01" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_Merge_CheckToTest" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	Set patch_A       = EnumerateToPatchAndBackUpDictionary( "Files\MergePatch\02-PatchA-of-01" )
	Set patch_mutual  = EnumerateToPatchAndBackUpDictionary( "Files\MergePatch\02-PatchMutual-of-01" )
	Set patch_primary = EnumerateToPatchAndBackUpDictionary( "Files\MergePatch\02-PatchPrimary-of-01" )


	'// Check : Cannot attach patch
	For Each  t  In DicTable( Array( _
		"CaseID",  "Patch1",      "Patch2",   Empty, _
		"1",       patch_A,       patch_primary, _
		"2A",      patch_A,       patch_mutual, _
		"2B",      patch_mutual,  patch_A ) )

		del  "_work"
		copy  "Files\MergePatch\01", "_work"
		files_path = "_work\01"
		Set files = EnumerateToLeafPathDictionary( files_path )


		AttachPatchAndBackUpDictionary  files, t("Patch1"), files_path, Empty

		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			AttachPatchAndBackUpDictionary  files, t("Patch2"), files_path, Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0

		del  "_work"
	Next


	'// Set up
	del  "_work"
	copy  "Files\MergePatch\01", "_work"
	files_path = "_work\01"
	Set files = EnumerateToLeafPathDictionary( files_path )

	'// Test Main
	AttachPatchAndBackUpDictionary  files, patch_primary, files_path, Empty
	AttachPatchAndBackUpDictionary  files, patch_A, files_path, Empty

	'// Check : No error

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_Merge" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	Set patch_A       = EnumerateToPatchAndBackUpDictionary( "Files\MergePatch\02-PatchA-of-01" )
	Set patch_mutual  = EnumerateToPatchAndBackUpDictionary( "Files\MergePatch\02-PatchMutual-of-01" )
	Set patch_primary = EnumerateToPatchAndBackUpDictionary( "Files\MergePatch\02-PatchPrimary-of-01" )

	del  "_work"
	copy  "Files\MergePatch\01", "_work"
	files_path = "_work\01"
	Set files = EnumerateToLeafPathDictionary( files_path )


	'// Test Main
	Set  patch_ = patch_A.Copy()
	MergePatchAndBackUpDictionary  patch_,  Empty,  patch_mutual,  Empty
	MergePatchAndBackUpDictionary  patch_,  Empty,  patch_primary, Empty
	AttachPatchAndBackUpDictionary  files,  patch_,  files_path,   Empty
	CopyFilesToLeafPathDictionary  files,  True

	'// Check
	Assert  fc( files_path, "Files\MergePatch\02" )


	'// Set up
	conflict_path = "_work\02-PatchConflictA1-of-01"
	del  conflict_path
	copy_ren  "Files\MergePatch\02-PatchA-of-01", conflict_path
	CreateFile  "_work\02-PatchConflictA1-of-01\patch\MoveAndModifyFromMutualToA.txt", "Conflict"
	Set patch_conflict = EnumerateToPatchAndBackUpDictionary( conflict_path )

	'// Test Main & Check
	Set  patch_ = patch_A.Copy()
	Assert  CanAttachFriendPatchAndBackUpDictionary( patch_, Empty,  patch_conflict, Empty ) = c.CannotAttachBoth
	Assert  CanAttachFriendPatchAndBackUpDictionary( patch_, Empty,  patch_A, Empty )        = c.Attachable
	Assert  CanAttachFriendPatchAndBackUpDictionary( patch_, Empty,  patch_primary, Empty )  = c.MustAttachAfterFriend
	Assert  CanAttachFriendPatchAndBackUpDictionary( patch_, Empty,  patch_mutual, Empty )   = c.MustMergeWithFriend

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_TwistedMerge" ) Then
	Set w_= AppKey.NewWritable( "_work" ).Enable()

	'// Set up : Make twisted patches
	del  "_work"

	copy  "Files\MergePatch\01\*", "_work\01\sub"
	Set files = EnumerateToLeafPathDictionary( "_work\01\sub" )

	copy  "Files\MergePatch\02\*", "_work\02\sub"

	copy  "Files\MergePatch\02-PatchA-of-01\patch\*",   "_work\02-PatchA-of-01\patch\sub"
	copy  "Files\MergePatch\02-PatchA-of-01\back_up\*", "_work\02-PatchA-of-01\back_up"
	Set patch_A = EnumerateToPatchAndBackUpDictionary( "_work\02-PatchA-of-01" )

	copy  "Files\MergePatch\02-PatchMutual-of-01\patch\*",   "_work\02-PatchMutual-of-01\patch"
	copy  "Files\MergePatch\02-PatchMutual-of-01\back_up\*", "_work\02-PatchMutual-of-01\back_up\sub"
	Set patch_mutual = EnumerateToPatchAndBackUpDictionary( "_work\02-PatchMutual-of-01" )

	copy  "Files\MergePatch\02-PatchPrimary-of-01\patch\*",   "_work\02-PatchPrimary-of-01\patch\sub"
	copy  "Files\MergePatch\02-PatchPrimary-of-01\back_up\*", "_work\02-PatchPrimary-of-01\back_up\sub"
	Set patch_primary  = EnumerateToPatchAndBackUpDictionary( "_work\02-PatchPrimary-of-01" )

	conflict_path = "_work\02-PatchConflictA1-of-01"
	copy_ren  "Files\MergePatch\02-PatchA-of-01", conflict_path
	CreateFile  conflict_path +"\patch\MoveAndModifyFromMutualToA.txt", "Conflict"
	Set patch_conflict = EnumerateToPatchAndBackUpDictionary( conflict_path )


	'// Test Main
	Set  patch_ = patch_A.Copy()
	MergePatchAndBackUpDictionary _
		patch_,  Array( "_work\01", "_work\01\sub" ), _
		patch_mutual,  Array( "_work\01\sub", "_work\01" )
	MergePatchAndBackUpDictionary  patch_,  patch_.PatchRootPath,  patch_primary,  "_work\01"
	target_path = patch_.PatchRootPath
	AttachPatchAndBackUpDictionary  files,  patch_,  target_path,  Empty
	CopyFilesToLeafPathDictionary  files,  True

	'// Check
	Assert  fc( "_work\01", "_work\02" )


	'// Test Main & Check
	Set  patch_ = patch_A.Copy()

	Assert  CanAttachFriendPatchAndBackUpDictionary( _
		patch_,  Array( "_work\01", "_work\01\sub" ),  patch_conflict,  "_work\01\sub" ) _
		= c.CannotAttachBoth

	Assert  CanAttachFriendPatchAndBackUpDictionary( _
		patch_,  Array( "_work\01", "_work\01\sub" ),  patch_A,  Array( "_work\01", "_work\01\sub" ) ) _
		= c.Attachable

	Assert  CanAttachFriendPatchAndBackUpDictionary( _
		patch_,  Array( "_work\01", "_work\01\sub" ),  patch_primary,  "_work\01" ) _
		= c.MustAttachAfterFriend

	Assert  CanAttachFriendPatchAndBackUpDictionary( _
		patch_,  Array( "_work\01", "_work\01\sub" ),  patch_mutual,  Array( "_work\01\sub", "_work\01" ) ) _
		= c.MustMergeWithFriend


	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 






'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib include is provided under 3-clause BSD license.
'// Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_Vers : If IsEmpty( g_Vers ) Then
Set  g_Vers = CreateObject("Scripting.Dictionary") : g_Vers("vbslib") = 99.99
Dim  g_debug, g_debug_params, g_admin, g_vbslib_path, g_CommandPrompt, g_fs, g_sh, g_AppKey
Dim  g_MainPath, g_SrcPath, g_f, g_include_path, g_i, g_debug_tree, g_debug_process, g_is_compile_debug
Dim  g_is64bitWSH
g_SrcPath = WScript.ScriptFullName : g_MainPath = g_SrcPath
SetupVbslibParameters
Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject("WScript.Shell") : g_f = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
For g_i = 20 To 1 Step -1 : If g_fs.FileExists(g_vbslib_path) Then  Exit For
g_vbslib_path = "..\" + g_vbslib_path  : Next
If g_fs.FileExists(g_vbslib_path) Then  g_vbslib_path = g_fs.GetAbsolutePathName( g_vbslib_path )
g_sh.CurrentDirectory = g_f
If g_i=0 Then WScript.Echo "Not found " + g_fs.GetFileName( g_vbslib_path ) +vbCR+vbLF+_
	"Let's download vbslib and Copy scriptlib folder." : Stop : WScript.Quit 1
Set g_f = g_fs.OpenTextFile( g_vbslib_path,,,-2 ): Execute g_f.ReadAll() : g_f = Empty
If ResumePush Then  On Error Resume Next
	CallMainFromVbsLib
ResumePop : On Error GoTo 0
End If
'---------------------------------------------------------------------------------

Sub  SetupDebugTools()
	set_input  ""
	SetBreakByFName  Empty
	SetStartSectionTree  ""
End Sub

Sub  SetupVbslibParameters()
	'--- start of parameters for vbslib include -------------------------------
	g_Vers("vbslib") = 99.99
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
