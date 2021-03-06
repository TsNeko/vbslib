Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_CommitCopyUI_1",_
			"2","T_CommitCopyUI_UpdateForMerge",_
			"3","T_CommitCopyUI_ExceptFile",_
			"4","T_CommitCopyUI_File",_
			"5","T_CommitCopyUI_UI" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


Dim g_g : Sub GetMainSetting( g ) : If not IsEmpty(g_g) Then Set g=g_g : Exit Sub
    Set g = new LazyDictionaryClass : Set g_g=g


    '[Setting]
    '==============================================================================
    g("${IsHistoryInShare}") = True
    '==============================================================================
End Sub


 
'********************************************************************************
'  <<< [T_CommitCopyUI_1] >>> 
'********************************************************************************
Sub  T_CommitCopyUI_1( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work", "_share", "_temporary_moved" ) ).Enable()
	Set ds = new CurDirStack
	Set section = new SectionTree
	GetMainSetting  g
'//SetStartSectionTree  "T_Sample2"


	For Each  is_history_in_share  In Array( True, False )
	g("${IsHistoryInShare}") = is_history_in_share

	If g("${IsHistoryInShare}") Then
		folders_with_history = Array( "_work", "_share" )
	Else
		folders_with_history = Array( "_work" )
	End If


	day_num = 1


	'//==== Check Out

	'// Set up
	del   "_work"
	del   "_share"
	del   "_temporary_moved"
	mkdir  "_work"
	copy  "Files\1_Share\*", "_share"
	Set tn = new_TestableNow( DateSerial( 2014, 1, 1 ) )


	'// Test Main
	pushd  "_work"
	Set commit = new CommitCopyUI_Class
	commit.UserName        = "user1@PC22"
	commit.ShareName       = "PC01"
	commit.ShareFolderPath = "..\_share"
	commit.WorkFolderPath  = "."
	If not is_history_in_share Then  commit.IsHistoryInShare = False
	commit.CheckOut
	popd


	'// Check
	T_CommitCopyUI_1_CheckSameFolder
	If commit.IsNewFunction Then
		Assert  GetReadOnlyList( "_work", Empty, Empty ) = 0
	End If

	del   "_temporary_moved"
	If g("${IsHistoryInShare}") Then
		move  "_share\_history", "_temporary_moved"
	Else
		Assert  not exist( "_share\_history" )
	End If
	entity = Replace( W3CDTF( TestableNow() ), ":", ";" )+"  (start)"

		If g("${IsHistoryInShare}") Then _
			Assert  fc( "_temporary_moved\_history\"+ entity, "_share" )
		Assert  fc( "_work\_history\"+ entity, "_share" )

	If g("${IsHistoryInShare}") Then _
		move  "_temporary_moved\_history", "_share"
	del   "_temporary_moved"

	AssertFC   "_work\_history\history.xml", "Files\1_"& day_num &"_history.xml"
	If g("${IsHistoryInShare}") Then _
		AssertFC  "_share\_history\history.xml", "Files\1_"& day_num &"_history.xml"
	day_num = day_num + 1


	'//==== Fail to Check Out

	'// Test Main
	pushd  "_work"

	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		commit.CheckOut

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "チェックアウトできません" ) > 0
	Assert  e2.num <> 0
	popd


	'//==== Commit : No changed
	If section.Start( "T_CommitCopyUI_NoChanged" ) Then

	'// Set up
	tn = Empty
	Set tn = new_TestableNow( DateSerial( 2014, 1, 2 ) )

	'// Test Main
	pushd  "_work"
	commit.Commit
	popd

	'// Check
	T_CommitCopyUI_1_CheckSameFolder
	AssertFC   "_work\_history\history.xml", "Files\1_"& day_num &"_history.xml"
	If g("${IsHistoryInShare}") Then
		AssertFC  "_share\_history\history.xml", "Files\1_"& day_num &"_history.xml"
	Else
		Assert  not exist( "_share\_history" )
	End If
	day_num = day_num + 1

	End If : section.End_


	'//==== Compare : When committed
	pushd  "_work"
	commit.Compare
	popd


	'//==== Commit : Update file in work
	If section.Start( "T_CommitCopyUI_UpdateFileInWork" ) Then

	new_file_path1 = "_work\new1.txt"
	new_file_path2 = "_work\sub\new1.txt"
	For Each  update_file_path  In Array( "_work\1.txt", "_work\sub\1.txt", _
			new_file_path1, new_file_path2, Empty )

		'// Set up
		If not IsEmpty( update_file_path ) Then
			CreateFile  update_file_path, "update1"
		Else
			del  new_file_path1
			del  new_file_path2
		End If
		CreateFile   "_work\Thumbs.db", "1"
		CreateFile  "_share\Thumbs.db", "2"
		CreateFile   "_work\sub\Thumbs.db", "1"
		CreateFile  "_share\sub\Thumbs.db", "2"

		pushd  "_work"
		commit.Compare  '// Compare : When before commit
		popd

		tn = Empty
		Set tn = new_TestableNow( DateSerial( 2014, 1, day_num ) )

		'// Test Main
		pushd  "_work"
		commit.Commit
		popd

		'// Check
		del   "_work\Thumbs.db"
		del  "_share\Thumbs.db"
		del   "_work\sub\Thumbs.db"
		del  "_share\sub\Thumbs.db"
		del  "_work\_synced\sub\Thumbs.db"

		T_CommitCopyUI_1_CheckSameFolder
		AssertFC   "_work\_history\history.xml", "Files\1_"& day_num &"_history.xml"
		If g("${IsHistoryInShare}") Then
			AssertFC  "_share\_history\history.xml", "Files\1_"& day_num &"_history.xml"
		Else
			Assert  not exist( "_share\_history" )
		End If

		If update_file_path = new_file_path1 Then
			For Each  work_or_share  In folders_with_history
				Assert  IsSameBinaryFile( _
					work_or_share +"\_history\2014-01-05T00;00;00+09;00 user1@PC22\new1.txt",_
					new_file_path1, Empty )
			Next
		End If
		If update_file_path = new_file_path2 Then
			For Each  work_or_share  In folders_with_history
				Assert  IsSameBinaryFile( _
					work_or_share +"\_history\2014-01-06T00;00;00+09;00 user1@PC22\sub\new1.txt",_
					new_file_path2, Empty )
			Next
		End If
		last_commit_day_num = day_num
		day_num = day_num + 1
	Next

	End If : section.End_


	'//==== Update : Update file in share
	If section.Start( "T_CommitCopyUI_UpdateFileInShare" ) Then

	new_file_path1 = "_share\new1.txt"
	new_file_path2 = "_share\sub\new1.txt"
	For Each  update_file_path  In Array( "_share\1.txt", "_share\sub\1.txt", _
			new_file_path1, new_file_path2, Empty )

		'// Set up
		If not IsEmpty( update_file_path ) Then
			CreateFile  update_file_path, "update2"
		Else
			del  new_file_path1
			del  new_file_path2
		End If
		CreateFile   "_work\Thumbs.db", "1"
		CreateFile  "_share\Thumbs.db", "2"
		CreateFile   "_work\sub\Thumbs.db", "1"
		CreateFile  "_share\sub\Thumbs.db", "2"

		tn = Empty
		Set tn = new_TestableNow( DateSerial( 2014, 1, day_num ) )

		'// Test Main
		pushd  "_work"
		commit.Update
		popd

		'// Check
		del   "_work\Thumbs.db"
		del  "_share\Thumbs.db"
		del   "_work\sub\Thumbs.db"
		del  "_share\sub\Thumbs.db"
		del  "_work\_synced\sub\Thumbs.db"

		T_CommitCopyUI_1_CheckSameFolder
		AssertFC   "_work\_history\history.xml", "Files\1_"& day_num &"_history.xml"
		If g("${IsHistoryInShare}") Then
			AssertFC  "_share\_history\history.xml", "Files\1_"& last_commit_day_num &"_history.xml"
		Else
			Assert  not exist( "_share\_history" )
		End If
		day_num = day_num + 1
	Next

	End If : section.End_


	'//==== Commit : Can not commit
	If section.Start( "T_CommitCopyUI_CanNotCommit" ) Then

	For Each  update_file_path  In Array( "_share\1.txt", "_share\sub\1.txt", "_share\9.txt", Empty )

		'// Set up
		If IsEmpty( update_file_path ) Then
			copy_ren  "_share\sub\1.txt", "_temporary_moved\1.txt"
			del  "_share\sub\1.txt"
		Else
			If exist( update_file_path ) Then _
				copy_ren    update_file_path, "_temporary_moved\1.txt"
			CreateFile  update_file_path, "update3"
		End If


		'// Error Handling Test
		pushd  "_work"

		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			commit.Commit

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num = commit.E_NotSame

		popd


		'// Clean
		If IsEmpty( update_file_path ) Then
			move_ren  "_temporary_moved\1.txt", "_share\sub\1.txt"
		Else
			If g_fs.GetFileName( update_file_path ) = "1.txt" Then
				move_ren  "_temporary_moved\1.txt", update_file_path
			Else
				del  update_file_path
			End If
		End If
	Next

	End If : section.End_


	'//==== Update : Can not update
	If section.Start( "T_CommitCopyUI_CanNotUpdate" ) Then

	For Each  update_file_path  In Array( "_work\1.txt", "_work\sub\1.txt", "_work\9.txt", Empty )

		'// Set up
		If IsEmpty( update_file_path ) Then
			copy_ren  "_work\sub\1.txt", "_temporary_moved\1.txt"
			del  "_work\sub\1.txt"
		Else
			If exist( update_file_path ) Then _
				copy_ren    update_file_path, "_temporary_moved\1.txt"
			CreateFile  update_file_path, "update4"
		End If


		'// Error Handling Test
		pushd  "_work"

		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			commit.Update

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num = commit.E_NotSame

		popd


		'// Clean
		If IsEmpty( update_file_path ) Then
			move_ren  "_temporary_moved\1.txt", "_work\sub\1.txt"
		Else
			If g_fs.GetFileName( update_file_path ) = "1.txt" Then
				move_ren  "_temporary_moved\1.txt", update_file_path
			Else
				del  update_file_path
			End If
		End If
	Next

	End If : section.End_


	'// Clean
	del   "_work"
	del   "_share"
	del   "_temporary_moved"
	tn = Empty

	Next  '// is_history_in_share

	Pass
End Sub


'//[T_CommitCopyUI_1_CheckSameFolder]
Sub  T_CommitCopyUI_1_CheckSameFolder()
	GetMainSetting  g

	del   "_temporary_moved"
	If g("${IsHistoryInShare}") Then _
		move  "_share\_history", "_temporary_moved\_share"
	move  "_work\_synced",   "_temporary_moved\_work"
	move  "_work\_history",  "_temporary_moved\_work"

	Assert  fc( "_work", "_share" )
	Assert  fc( "_temporary_moved\_work\_synced", "_share" )

	If g("${IsHistoryInShare}") Then _
		move  "_temporary_moved\_share\_history", "_share"
	move  "_temporary_moved\_work\_synced",   "_work"
	move  "_temporary_moved\_work\_history",  "_work"
	del   "_temporary_moved"
End Sub


 
'********************************************************************************
'  <<< [SetUpWork] >>> 
'********************************************************************************
Function  SetUpWork()
	Set ds = new CurDirStack

	del   "_work1"
	del   "_share1"
	del   "_temporary_moved"
	mkdir  "_work1"
	copy  "Files\1_Share\*", "_share1"

	pushd  "_work1"
	Set commit = new CommitCopyUI_Class
	commit.UserName        = "user1"
	commit.ShareName       = "PC333"
	commit.ShareFolderPath = "..\_share1"
	commit.WorkFolderPath  = "."
	commit.CheckOut
	popd

	Set SetUpWork = commit
End Function


 
'********************************************************************************
'  <<< [T_CommitCopyUI_UpdateForMerge] >>> 
'********************************************************************************
Sub  T_CommitCopyUI_UpdateForMerge( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work1", "_share1", "_temporary_moved" ) ).Enable()
	Set ds = new CurDirStack


	'//==== UpdateForMerge : Update file in both

	'// Set up
	Set tn = new_TestableNow( DateSerial( 2014, 1, 1 ) )
	Set commit = SetUpWork()
	tn = Empty

	copy  "_share1", "_temporary_moved\before"

	CreateFile  "_work1\1.txt", "update_work_1"
	CreateFile  "_share1\sub\1.txt", "update_share_1"

	copy  "_work1",  "_temporary_moved\after"
	copy  "_share1", "_temporary_moved\after"


	'// Test Main
	Set tn = new_TestableNow( DateSerial( 2014, 2, 1 ) )
	pushd  "_work1"
	commit.UpdateForMerge
	popd
	tn = Empty


	'// Check
	Assert  fc( "_work1\_synced - previous\sub",   "_temporary_moved\before\_share1\sub" )
	Assert  fc( "_work1\_synced - previous\1.txt", "_temporary_moved\before\_share1\1.txt" )
	Assert  fc( "_share1\sub",   "_temporary_moved\after\_share1\sub" )
	Assert  fc( "_share1\1.txt", "_temporary_moved\after\_share1\1.txt" )
	Assert  fc( "_work1\sub",    "_temporary_moved\after\_work1\sub" )
	Assert  fc( "_work1\1.txt",  "_temporary_moved\after\_work1\1.txt" )
	Assert  fc( "_work1\_history\2014-02-01T00;00;00+09;00 user1\sub\1.txt", _
		"_temporary_moved\after\_share1\sub\1.txt" )
	AssertFC  "_work1\_history\history.xml", "Files\1_UpdateForMerge.xml"


	'//==== UpdateForMerge : Can not UpdateForMerge

	'// Error Handling Test
	pushd  "_work1"

	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		commit.UpdateForMerge

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "フォルダーが既に存在します" ) > 0
	Assert  e2.num <> 0
	popd


	'// Clean
	del   "_work1"
	del   "_share1"
	del   "_temporary_moved"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CommitCopyUI_ExceptFile] >>> 
'********************************************************************************
Sub  T_CommitCopyUI_ExceptFile( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work1", "_share1", "_temporary_moved" ) ).Enable()
	Set ds = new CurDirStack


	'// Set up
	Set commit = SetUpWork()

	CreateFile  "_share1\except1.txt", "e"
	mkdir       "_share1\except2"
	CreateFile  "_work1\except3.txt", "e"
	mkdir       "_work1\except4"


	'// Test Main
	commit.ShareFolderExceptNames = Array( "except1.txt", "except2" )
	commit.WorkFolderExceptNames  = Array( "except3.txt", "except4" )
	pushd  "_work1"
	commit.Update
	commit.Commit
	popd


	'// Check
	'// No Error only


	'// Clean
	del   "_work1"
	del   "_share1"
	del   "_temporary_moved"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CommitCopyUI_File] >>> 
'********************************************************************************
Sub  T_CommitCopyUI_File( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work1", "_share1" ) ).Enable()
	Set ds = new CurDirStack


	'// Set up
	Set commit = SetUpWork()
	CreateFile   "_work1\zero.txt", ""
	CreateFile  "_share1\zero.txt", ""
	CreateFile   "_work1\_synced\zero.txt", ""


	'// Test Main
	pushd  "_work1"
	commit.Commit
	popd


	'// Check
	'// No Error only


	'// Clean
	del   "_work1"
	del   "_share1"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CommitCopyUI_UI] >>> 
'********************************************************************************
Sub  T_CommitCopyUI_UI( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work", "_share" ) ).Enable()
	vbs_template_path = "..\..\..\..\Samples\CommitCopy\_CommitCopy.vbs"

	'// Set up
	del   "_work"
	del   "_share"
	copy  "Files\1_Share\*", "_share"
	copy  vbs_template_path, "_work"
	copy  g_vbslib_folder +"*", "_work\_scriptlib"

	vbs_path = "_work\"+ g_fs.GetFileName( vbs_template_path )
	Set file = OpenForReplace( vbs_path, Empty )
	file.Replace  "\\PC01\folder\share", "..\_share"
	file.Replace  "scriptlib", "_scriptlib"
	file.Replace  "CommitCopyUI_Class", _
		"CommitCopyUI_Class"+ vbCRLF +_
		vbTab +"g_CUI.SetAutoKeysFromMainArg"
	file = Empty


	'// Test Main
	RunProg  "cscript  ""_work\_CommitCopy.vbs"" /set_input:CheckOut.y.CheckOut.y.Commit.y.Exit.", ""

	For Each  update_file_path  In Array( "_work\1.txt", "_work\sub\1.txt" )
		CreateFile  update_file_path, "update1"
		RunProg  "cscript  ""_work\_CommitCopy.vbs"" /set_input:Commit.y.Exit.", ""
	Next


	'// Check
	Assert  ReadFile( "_share\1.txt" )     = "update1"
	Assert  ReadFile( "_share\sub\1.txt" ) = "update1"


	'// Test Main
	For Each  update_file_path  In Array( "_share\1.txt", "_share\sub\1.txt" )
		CreateFile  update_file_path, "update2"
		RunProg  "cscript  ""_work\_CommitCopy.vbs"" /set_input:Update.y.Exit.", ""
	Next


	'// Check
	Assert  ReadFile( "_work\1.txt" )     = "update2"
	Assert  ReadFile( "_work\sub\1.txt" ) = "update2"


	'// Test Main
	For Each  update_file_path  In Array( "_share\1.txt", "_share\sub\1.txt" )
		CreateFile  update_file_path, "update3"
		RunProg  "cscript  ""_work\_CommitCopy.vbs"" /set_input:Commit.y.Exit.", ""
	Next

	For Each  update_file_path  In Array( "_work\1.txt", "_work\sub\1.txt" )
		CreateFile  update_file_path, "update4"
		RunProg  "cscript  ""_work\_CommitCopy.vbs"" /set_input:Update.y.Exit.", ""
	Next


	'// Check
	Assert  ReadFile( "_work\1.txt" )  = "update4"
	Assert  ReadFile( "_share\1.txt" ) = "update3"


	'// Test Main
	RunProg  "cscript  ""_work\_CommitCopy.vbs"" /set_input:UpdateForMerge.y.Exit.", ""


	'// Clean
	del   "_work"
	del   "_share"

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


 
