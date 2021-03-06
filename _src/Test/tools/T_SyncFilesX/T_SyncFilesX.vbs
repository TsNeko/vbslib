Sub  Main( Opt, AppKey )
	include  "SettingForTest_pre.vbs"
	include  "SettingForTest.vbs"

	Set o = new InputCommandOpt
		o.Lead = "SyncFilesX を試す：SyncFilesX_UI (略語：ui)"
		Set o.CommandReplace = Dict(Array(_
			"1", "T_SyncFilesX_1",_
			"2", "T_SyncFilesX_Folder",_
			"3", "T_SyncFilesX_AutoSame",_
			"4", "T_SyncFilesX_4way",_
			"5", "T_SyncFilesX_4way2",_
			"6", "T_SyncFilesX_3way2",_
			"8", "T_SyncFilesX_CommandLine",_
			"9", "T_SyncFilesX_RootFolders_UI",_
			"10","T_SyncFilesX_RootFolders",_
			"11","T_SyncFilesX_ParentFolder",_
			"13","T_SyncFilesX_FileList",_
			"14","T_SyncFilesX_TestTools",_
			"15","T_SyncFilesX_sth" ))

			'// "", "T_SyncFilesX_SyncVersionUp"
			'// "ui", "SyncFilesX_UI",
			'// "11","T_SyncFilesX_Clone",_
			'// "12","T_SyncFilesX_Finder",_

	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_1] >>> 
'********************************************************************************
Sub  T_SyncFilesX_1( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_1_Sub /set_input:"+_
		"10.8.9.98.y.95.y.99.", "_out.txt"
		'// 10:"SubForWork\UpdateWork_WorkOnly.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_1_EchoAnswer.txt"

	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_1_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_Folder] >>> 
'********************************************************************************
Sub  T_SyncFilesX_Folder( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	key = ""
	key = key +"1.8.y.9."  '// 1
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."  '// 5
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."  '// 10
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."  '// 15
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."  '// 20
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."  '// 25
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
		'// エラーにならないこと

	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_Folder_Sub /set_input:"+_
		key +"99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_Folder_EchoAnswer.txt"

	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_Folder_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Folder.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_AutoSame] >>> 
'********************************************************************************
Sub  T_SyncFilesX_AutoSame( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	key = ""
	key = key +"1.8.9."    '// 1
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."  '// 5
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."    '// 10
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.9."    '// 15
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."  '// 20
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."  '// 25
	key = key +"1.8.9."
	key = key +"1.8.y.9."
	key = key +"1.8.9."
	key = key +"1.8.y.9."
		'// エラーにならないこと

	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_AutoSame_Sub /set_input:"+_
		key +"99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_Auto_EchoAnswer.txt"

	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_AutoSame_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Auto.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_4way] >>> 
'********************************************************************************
Sub  T_SyncFilesX_4way( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_4way_Sub /set_input:"+_
		"9.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_4way_EchoAnswer.txt"

	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_4way_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_4way.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_4way2] >>> 
'********************************************************************************
Sub  T_SyncFilesX_4way2( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work", "_out.txt" ) ).Enable()

	'// Set up
	del  "_work"
	unzip2  "FilesA.zip", "_work"
	copy  "_work\FilesA\Project - Synced\Base\*", "_work\00_SyncedBase"
	copy  "_work\FilesA\Project - Synced\Work\*", "_work\01_SyncedWork"
	copy  "_work\FilesA\Project\Base\*", "_work\10_Base"
	copy  "_work\FilesA\Project\Work\*", "_work\11_Work"
	ren   "_work\00_SyncedBase\SubForBase", "SubForSyncedBase"
	ren   "_work\01_SyncedWork\SubForWork", "SubForSyncedWork"
	ren   "_work\00_SyncedBase\UpdateBothAlmostSame.txt", "UpdateBothAlmostSame_00.txt"
	ren   "_work\01_SyncedWork\UpdateBothAlmostSame.txt", "UpdateBothAlmostSame_01.txt"
	ren   "_work\10_Base\UpdateBothAlmostSame.txt", "UpdateBothAlmostSame_10.txt"
	ren   "_work\11_Work\UpdateBothAlmostSame.txt", "UpdateBothAlmostSame_11.txt"
	copy  "_work\FilesA\Project - Synced\SyncFilesX_4way2.xml", "_work"

	'[TODO] 4way merge is not supported yet
	If False Then
		copy  "Files\Conflict\Base.txt",  "_work\00_Base"
		copy  "Files\Conflict\Left.txt",  "_work\01_Left"
		copy  "Files\Conflict\Right.txt", "_work\02_Right"
	End If

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_4way2_Sub /set_input:"+_
		"7.9.8.9.99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_4way2_EchoAnswer.txt"

	'// Clean
	del  "_work"
	del  "_out.txt"

	Pass
End Sub

Sub  T_SyncFilesX_4way2_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg

	Set sync = new SyncFilesX_Class
	path = "_work\SyncFilesX_4way2.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_3way2] >>> 
'
' 関連するテスト: T_ThreeWayMerge_sth_FullSetting
'********************************************************************************
Sub  T_SyncFilesX_3way2( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_SyncFilesX_TestTools_CopyFromBase"

	For Each  case_  In  Array( "T_UI_1", "T_UI_1_NoDiff", "T_UI", "T_UI_1_Commit", _
		"T_NotAutoMerge", "T_NoMergeSetting", "T_WithSetting", _
		"T_No_Left", "T_No_Right", "T_No_Base", "T_No_LeftRight", "T_No_BaseLeft", "T_No_BaseRight" )

		If section.Start( "T_SyncFilesX_3way2_"+ case_ ) Then

		Set w_=AppKey.NewWritable( Array( "_work", "_out.txt" ) ).Enable()

		'// Set up : Pick up from "FilesA.zip"
		Set ec = new EchoOff
		del  "_work"
		del  "_out.txt"
		unzip2  "FilesA.zip", "_work"
		copy  "_work\FilesA\Project - Synced\Base\*", "_work\00_Base"
		copy  "_work\FilesA\Project - Synced\Work\*", "_work\01_Left"
		copy  "_work\FilesA\Project\Base\*", "_work\02_Right"
		ren   "_work\00_Base\SubForBase", "B"
		ren   "_work\01_Left\SubForWork", "L"
		ren   "_work\02_Right\SubForBase", "R"
		copy  "_work\FilesA\Project - Synced\SyncFilesX_3way2.xml", "_work"
		copy  "_work\FilesA\Project - Synced\SyncFilesX_3way2A.xml", "_work"
		copy  "_work\FilesA\Project - Synced\SyncFilesX_3way2N.xml", "_work"
		copy  "_work\FilesA\Project - Synced\SyncFilesX_3way2C.xml", "_work"
		copy  "Files\Conflict\Base.txt",  "_work\00_Base"
		copy  "Files\Conflict\Left.txt",  "_work\01_Left"
		copy  "Files\Conflict\Right.txt", "_work\02_Right"
		del  "_work\03_Merged"
		ec = Empty


		If case_ = "T_UI" Then

			'// Test Main
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2_Sub /set_input:"+_
				"3.9.99.", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2_EchoAnswer.txt"

		ElseIf case_ = "T_UI_1" Then

			'// Test Main
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2A_Sub /set_input:"+_
				"9.", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2A_EchoAnswer.txt"

		ElseIf case_ = "T_UI_1_NoDiff" Then

			'// Test Main
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2N_Sub /set_input:"+_
				"9.", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2N_EchoAnswer.txt"

		ElseIf case_ = "T_UI_1_Commit" Then

			'// Test Main
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2C_Sub /set_input:"+_
				"3.8.9."+ _
				"2.88.Files\UpdateBothSame_ForBase_Modified.8.9."+ _
				"99.", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2C1_EchoAnswer.txt"

			'// Test Main : Continue
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2C_Sub /set_input:"+_
				"1.99", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2C2_EchoAnswer.txt"
			Assert  IsSameBinaryFile( _
				"_work\03_Merged\M\UpdateBothSame_ForBase.txt", _
				"_work\04_Commit\M\UpdateBothSame_ForBase.txt", Empty )

			For Each  sub_case  In  Array( "LeftNew", "RightModified", "MergedModified", "Cleaned" )

				'// Set up
				If sub_case = "LeftNew" Then
					CreateFile  "_work\01_Left\L\UpdateBothSame_ForBase.txt",  "modified2"
				ElseIf sub_case = "RightModified" Then
					CreateFile  "_work\02_Right\R\UpdateBothSame_ForBase.txt",  "modified2"
				ElseIf sub_case = "MergedModified" Then
					CreateFile  "_work\03_Merged\M\UpdateBothSame_ForBase.txt",  "modified2"
				ElseIf sub_case = "Cleaned" Then
					'// Do nothing
				Else
					Error
				End If


				'// Test Main
				RunProg  "cscript //nologo """+ WScript.ScriptName +_
					""" T_SyncFilesX_3way2C_Sub /set_input:"+_
					"1.99", "_out.txt"

				'// Check
				AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2C3_EchoAnswer\"+ sub_case +".txt"

				'// Clean
				If sub_case = "LeftNew" Then
					del  "_work\01_Left\L\UpdateBothSame_ForBase.txt"
				ElseIf sub_case = "RightModified" Then
					CreateFile  "_work\02_Right\R\UpdateBothSame_ForBase.txt",  "update"
				ElseIf sub_case = "MergedModified" Then
					CreateFile  "_work\03_Merged\M\UpdateBothSame_ForBase.txt",  "modified"
				ElseIf sub_case = "Cleaned" Then
					'// Do nothing
				Else
					Error
				End If
			Next


			'// Test Main : Commit All
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2C_Sub /set_input:"+_
				"1.1.8.9.99", ""
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2C_Sub /set_input:"+_
				"1.99", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2C5_EchoAnswer.txt"


			'// Test Main : Reset
			RunProg  "cscript //nologo """+ WScript.ScriptName +_
				""" T_SyncFilesX_3way2C_Sub /set_input:"+_
				"2.99.", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2C4_EchoAnswer.txt"
			Assert  not IsSameBinaryFile( _
				"_work\03_Merged\M\UpdateBothSame_ForBase.txt", _
				"_work\04_Commit\M\UpdateBothSame_ForBase.txt", Empty )

		ElseIf StrCompHeadOf( case_, "T_No_", Empty ) = 0 Then

			If case_ = "T_No_Base"  or  case_ = "T_No_BaseLeft"  or  case_ = "T_No_BaseRight" Then
				del  "_work\00_Base\B"
				del  "_work\00_Base\Base.txt"
			End If
			If case_ = "T_No_Left"  or  case_ = "T_No_LeftRight"  or  case_ = "T_No_BaseLeft" Then
				del  "_work\01_Left\L"
				del  "_work\01_Left\Left.txt"
			End If
			If case_ = "T_No_Right"  or  case_ = "T_No_LeftRight"  or  case_ = "T_No_BaseRight" Then
				del  "_work\02_Right\R"
				del  "_work\02_Right\Right.txt"
			End If


			'// Test Main
			RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_3way2_Sub /set_input:"+_
				"99.", "_out.txt"

			'// Check
			AssertFC  "_out.txt", "Files\T_SyncFilesX_3way2D_EchoAnswer\"+ case_ +".txt"

		Else
			path = "_work\SyncFilesX_3way2.xml"

			If case_ = "T_NotAutoMerge" Then
				Set merge = new ThreeWayMergeOptionClass
				merge.IsAutoMergeEx = False
			ElseIf case_ = "T_NoMergeSetting" Then
				merge = Empty
			Else
				Assert  case_ = "T_WithSetting"

				Set merge = LoadThreeWayMergeOptionClass( path )
			End If


			Set sync = new SyncFilesX_Class
			sync.LoadScanListUpAll  path, ReadFile( path )
			Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()


			'// Test Main
			sync.Merge  merge


			'// Check
			If case_ = "T_NotAutoMerge" Then
				AssertFC  "_work\03_Merged\Merged.txt", "Files\Conflict\MergedAnswer.txt"
			ElseIf case_ = "T_NoMergeSetting" Then
				AssertFC  "_work\03_Merged\Merged.txt", "Files\Conflict\MergedAnswerEx0.txt"
			Else
				AssertFC  "_work\03_Merged\Merged.txt", "Files\Conflict\MergedAnswerEx.txt"
			End If
		End If


		'// Clean
		Set w_=AppKey.NewWritable( Array( "_work", "_out.txt" ) ).Enable()
		del  "_work"
		del  "_out.txt"

		End If : section.End_
	Next

	Pass
End Sub


Sub  T_SyncFilesX_3way2_Sub( Opt, AppKey )
	T_SyncFilesX_3way2_SubSub  Opt, AppKey, "_work\SyncFilesX_3way2.xml"
End Sub
Sub  T_SyncFilesX_3way2A_Sub( Opt, AppKey )
	T_SyncFilesX_3way2_SubSub  Opt, AppKey, "_work\SyncFilesX_3way2A.xml"
End Sub
Sub  T_SyncFilesX_3way2N_Sub( Opt, AppKey )
	T_SyncFilesX_3way2_SubSub  Opt, AppKey, "_work\SyncFilesX_3way2N.xml"
End Sub
Sub  T_SyncFilesX_3way2C_Sub( Opt, AppKey )
	T_SyncFilesX_3way2_SubSub  Opt, AppKey, "_work\SyncFilesX_3way2C.xml"
End Sub
Sub  T_SyncFilesX_3way2_SubSub( Opt, AppKey, in_Path )
	g_CUI.SetAutoKeysFromMainArg

	Set sync = new SyncFilesX_Class
	sync.LoadScanListUpAll  in_Path,  ReadFile( in_Path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	sync.Merge  Empty
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_CommandLine] >>> 
'********************************************************************************
Sub  T_SyncFilesX_CommandLine( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "FilesA" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	Assert  not IsSynchronizedFilesX( new_FilePathForFileInScript( "FilesA\Project - Synced\SyncFilesX.vbs" ) )

	'// Test Main
	Assert      IsSynchronizedFilesX( "FilesA\Project - Synced\SyncFilesX_Synced.xml" )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Assert  IsSynchronizedFilesX( "NotFound.xml" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_PathNotFound

	'// Clean
	del  "FilesA"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_RootFolders_UI] >>> 
'********************************************************************************
Sub  T_SyncFilesX_RootFolders_UI( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "_work" ) ).Enable()


	'//===========================================================
	'// Case of Basic

	'// Set up
	del  "_work"
	unzip2  "FilesB.zip", "_work"

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_RootFolders_UI_Sub "+_
		"/set_input:1.1.9.99.2.1.8.9.99.99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_RootFolders_EchoAnswer.txt"

	'// Clean
	del  "_work"
	del  "_out.txt"


	'//===========================================================
	'// Case of "used_ID"

	'// Set up
	del  "_work"
	unzip2  "FilesB.zip", "_work"

	Set xml = OpenForReplaceXML( "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml", Empty )
	xml.Write  "/SyncFilesX/@used_ID", "202"
	xml = Empty

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_RootFolders_UI_Sub "+_
		"/set_input:9.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_RootFolders_2_EchoAnswer.txt"

	'// Clean
	del  "_work"
	del  "_out.txt"

	Pass
End Sub


Sub  T_SyncFilesX_RootFolders_UI_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_RootFolders] >>> 
'********************************************************************************
Sub  T_SyncFilesX_RootFolders( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()

	'// Set up
	del  "_work"
	unzip2  "FilesB.zip", "_work"

	SetVar  "Setting_getDiffCmdLine", "ArgsLog"
	g_CUI.m_Auto_KeyEnter = "."
	set_input  "1.1.8.y.y.9.99.2.1.8.y.y.9.99.99."

	'// Test Main
	Set sync = new SyncFilesX_Class
	path = "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	result = sync.OpenCUI()

	'// Check
	del  "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	Assert  fc( "_work\FilesB", "Files\FilesB_Answer" )
	SetVar  "Setting_getDiffCmdLine", ""

	'// Clean
	del  "_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_ParentFolder] >>> 
'********************************************************************************
Sub  T_SyncFilesX_ParentFolder( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "_work" ) ).Enable()

	'// Set up
	del  "_work"
	unzip2  "FilesC.zip", "_work"

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_ParentFolder_Sub "+_
		"/set_input:1.2.8.y.9.1.2.8.y.9.1.2.8.y.9.1.2.8.y.9.1.2.8.y.9.99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_ParentFolder_EchoAnswer.txt"

	'// Clean
	del  "_work"
	del  "_out.txt"

	Pass
End Sub


Sub  T_SyncFilesX_ParentFolder_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "_work\FilesC\Project - Synced\T_Parent_SyncFilesX.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_Clone] >>> 
'********************************************************************************
Sub  T_SyncFilesX_Clone( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "FilesA", "_out.txt" ) ).Enable()

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	RunProg  "cscript //nologo """+ WScript.ScriptName +""" T_SyncFilesX_Clone_Sub /set_input:"+_
		"14.8.y.9.97.19.9.99.", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_SyncFilesX_Clone_EchoAnswer.txt"


	'// Clean
	del  "FilesA"
	del  "_out.txt"

	Pass
End Sub


Sub  T_SyncFilesX_Clone_Sub( Opt, AppKey )
	g_CUI.SetAutoKeysFromMainArg
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"

	Set sync = new SyncFilesX_Class
	path = "FilesA\Project - Synced\SyncFilesX_Clone.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
	result = sync.OpenCUI()

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_Finder] >>> 
'********************************************************************************
Sub  T_SyncFilesX_Finder( Opt, AppKey )
	Set sync = new SyncFilesX_Class
	path = "T_Finder\SyncFilesX_Moved.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
'//sync.OpenCUI

	sync.FindMoved  sync.Sets(0)
Skipped

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_FileList] >>> 
'********************************************************************************
Sub  T_SyncFilesX_FileList( Opt, AppKey )
	out_path = g_sh.SpecialFolders( "Desktop" )+"\_SyncFiles.txt"
	Set w_=AppKey.NewWritable( Array( "_work", out_path ) ).Enable()

	'// Set up
	del  "_work"
	unzip2  "FilesB.zip", "_work"
	g_CUI.m_Auto_KeyEnter = "."
	set_input  "98..99."

	'// Test Main
	Set sync = new SyncFilesX_Class
	path = "_work\FilesB\Project - Synced\SyncFilesX_Setting.xml"
	sync.LoadScanListUpAll  path, ReadFile( path )
	result = sync.OpenCUI()

	'// Check
	AssertFC  out_path, "Files\T_SyncFilesX_FileList_EchoAnswer.txt"

	'// Clean
	del  "_work"
	del  out_path

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_TestTools] >>> 
'********************************************************************************
Sub  T_SyncFilesX_TestTools( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_SyncFilesX_TestTools_CopyFromBase"


	For Each  test_name  In Array( "CopyFromUpdated", "CopyFromBase", "SyncForTest" )

		If section.Start( "T_SyncFilesX_TestTools_"+ test_name ) Then

		'// Set up
		w_=Empty : Set w_=AppKey.NewWritable( Array( "_work", "FilesA", "Answer" ) ).Enable()
		del  "_work"
		unzip  "FilesA.zip", "FilesA", F_AfterDelete
		unzip  "Answer.zip", "Answer", F_AfterDelete
		g_CUI.m_Auto_KeyEnter = "."
		Select Case  test_name
			Case "CopyFromUpdated" : set_input  "AutoCommit.y.AutoMerge.CopyFromUpdated.y.99."
			Case "CopyFromBase"    : set_input  "AutoCommit.y.AutoMerge.CopyFromBase.y.99."
			Case "SyncForTest"     : set_input  "SyncForTest.y.99."
		End Select


		'// Test Main
		Set sync = new SyncFilesX_Class
		path = "FilesA\Project - Synced\SyncFilesX_Auto.xml"
		sync.LoadScanListUpAll  path, ReadFile( path )
		w_=Empty : Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
		result = sync.OpenCUI()


		'// Check
		w_=Empty : Set w_=AppKey.NewWritable( Array( "_work", "FilesA", "Answer" ) ).Enable()
		del  "FilesA\Project - Synced\*.xml"
		del  "FilesA\Project - Synced\*.vbs"

		Select Case  test_name
			Case "CopyFromUpdated"
				Assert  fc( "FilesA", "Answer\T_SyncFilesX_TestTools_CopyFromUpdated" )
			Case "CopyFromBase"
				Assert  fc( "FilesA", "Answer\T_SyncFilesX_TestTools_CopyFromBase" )
			Case "SyncForTest"
				Assert  fc( "FilesA", "Answer\T_SyncFilesX_TestTools_SyncForTest" )
		End Select


		'// Clean
		del  "FilesA"
		del  "Answer"
		del  "_work.txt"

		End If : section.End_
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_SyncVersionUp] >>> 
'********************************************************************************
Sub  T_SyncFilesX_SyncVersionUp( Opt, AppKey )
	is_unzip = True
	target_path = "_work\target"

	Set w_=AppKey.NewWritable( Array( "_work", "T_SyncVersionUp" ) ).Enable()

	echo  "1. そのまま終了するテスト"
	echo  "2. ユーザーが調整するテスト"
	echo  "3. 調整メニューを再開して調整するテスト"
	echo  "9. クリーンする"
	test_case = CInt2( Input( "番号>" ) )

	If test_case = 9 Then  test_case = 1


	'// Set up
	del  "_work"
	If is_unzip Then
		unzip  "T_SyncVersionUp.zip", "T_SyncVersionUp", F_AfterDelete
	End If
	copy  "T_SyncVersionUp\ver1 modified\*", target_path


	echo_line
	Select Case  test_case
		Case 1:  echo  "調整メニューではそのまま終了してください。"
		Case 2:  echo  "update modified.txt の新版の 3行目を ******** に変えてください。"
		Case 3:  echo  "調整メニューが出たら終了し、"+_
			"""デスクトップ\T_SyncVersionUp_Updater\Updating 1.00 to 2.00.vbs"" をダブルクリックし、"+_
			"update modified.txt の新版の 3行目を ******** に変えてください。 "+_
			"""Updating 1.00 to 2.00.vbs"" の「終了」を選び、"+_
			"""_work\target\update modified.txt"" の 3行目が ******** であることを確認してください。"
		Case Else: Error
	End Select
	Pause


	'// Test Main
	echo  ""
	echo  " ((( サンプル・アップデート )))"
	echo_line

	setting_path = "T_SyncVersionUp\ver2\Version Info\1.00 to 2.00.xml"

	Set sync = new SyncFilesX_Class
	sync.LoadRootPaths  setting_path, ReadFile( setting_path )
	Set a_set = sync.Sets(0)

	echo  "更新しています……"
	Set ec = new EchoOff

	w_= Empty : Set w_=AppKey.NewWritable( Array( "_work", _
		target_path,                sync.CleanRootFullPath, _
		a_set.OldBaseRootFullPath,  a_set.OldWorkRootFullPath, _
		a_set.NewBaseRootFullPath,  a_set.NewWorkRootFullPath ) ).Enable()
	Assert  StrCompHeadOf( sync.CleanRootFullPath, g_sh.SpecialFolders( "Desktop" ), Empty ) = 0
	del  sync.CleanRootFullPath
	copy  "T_SyncVersionUp\ver1\*",        a_set.OldBaseRootFullPath  '// Downloaded files
	copy  "T_SyncVersionUp\ver2\*",        a_set.OldWorkRootFullPath  '// Downloaded files
	copy  "_work\target\*",                a_set.NewBaseRootFullPath  '// Back up copy
	copy  a_set.OldWorkRootFullPath +"\*", a_set.NewWorkRootFullPath  '// Modifing

	sync.LoadScanListUpAll  setting_path, ReadFile( setting_path )
	sync.Attach  target_path

	ec = Empty
	echo  "更新内容の候補をデスクトップの T_SyncVersionUp_Updater に作成しました。"


	'// Check
	Set ec = new EchoOff
	answer_folder = "_work\ver2 not merged answer"
	copy  "T_SyncVersionUp\ver2 not merged answer\*", answer_folder
	copy  Left( g_vbslib_folder, Len( g_vbslib_folder ) - 1 ), answer_folder

	Assert  fc( sync.CleanRootFullPath, answer_folder )

	del  answer_folder
	ec = Empty


	'// Test Main
	sync.UpdateCUI  target_path


	'// Check
	Select Case  test_case
		Case 1
			Assert  fc( target_path, "T_SyncVersionUp\ver2 modified answer" )

		Case 2
			copy  "T_SyncVersionUp\ver2 modified answer\*", "_work\_answer"
			CreateFile  "_work\_answer\update modified.txt", _
				"========"+ vbCRLF +_
				"2"+ vbCRLF +_
				"********"+ vbCRLF
			Assert  fc( target_path, "_work\_answer" )
			del  "_work\_answer"
	End Select


	'// Clean
	Assert  StrCompHeadOf( sync.CleanRootFullPath, g_sh.SpecialFolders( "Desktop" ), Empty ) = 0
	w_= Empty : Set w_=AppKey.NewWritable( sync.CleanRootFullPath ).Enable()
	del  sync.CleanRootFullPath

	w_= Empty : Set w_=AppKey.NewWritable( Array( "_work", "T_SyncVersionUp" ) ).Enable()
	del  "_work"

	If is_unzip Then
		del  "T_SyncVersionUp"
	End If

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SyncFilesX_sth] >>> 
'********************************************************************************
Sub  T_SyncFilesX_sth( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_answer.txt", "FilesA" ) ).Enable()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )

	'// Set up
	del  "FilesA"
	unzip2  "FilesA.zip", "."

	'// Test Main
	RunProg  "cscript //nologo """+ prompt_vbs +""" SyncFilesX  "+ _
		"""FilesA\Project\Work""  "+ _
		"""FilesA\Project\Base""  "+ _
		"""FilesA\Project - Synced\Work""  "+ _
		"""FilesA\Project - Synced\Base""  "+ _
		"25  7  """"  8  y  9  99", ""
		'// 4-way merge "UpdateBoth.txt"

	'// Check
	CreateFile  "_answer.txt", _
		"<<<<<<< Left.txt"+ vbCRLF + _
		"update base"+ vbCRLF + _
		"||||||| LeftBase.txt"+ vbCRLF + _
		"old"+ vbCRLF + _
		"======="+ vbCRLF + _
		"update work"+ vbCRLF + _
		">>>>>>> Right.txt"+ vbCRLF
	AssertFC  "FilesA\Project\Work\UpdateBoth.txt", "_answer.txt"

	'// Clean
	del  "FilesA"
	del  "_answer.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [ui] >>> 
'********************************************************************************
Sub  ui( Opt, AppKey )
	SyncFilesX_UI  Opt, AppKey
End Sub


'********************************************************************************
'  <<< [SyncFilesX_UI] >>> 
'********************************************************************************
Sub  SyncFilesX_UI( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "FilesA.zip を解凍した FilesA フォルダーがあることを想定しています。"
	default_path = "FilesA\Project - Synced\SyncFilesX_Auto.xml"

	'// UI
	echo  ""
	echo  "Enterのみ： """+ default_path +""""
	path = InputPath( "SyncFilesX XML path>", c.CheckFileExists  or  c.AllowEnterOnly )
	If path = "" Then _
		path = GetFullPath( default_path,  g_start_in_path )
	echo_line

	'// Main
	Set sync = new SyncFilesX_Class
	Do
		sync.LoadScanListUpAll  path, ReadFile( path )
		Set w_=AppKey.NewWritable( AddArrElemEx( sync.GetWritableFolders(), _
			g_sh.SpecialFolders( "Desktop" ), True ) ).Enable()
		result = sync.OpenCUI()

		If result = "Exit" Then  Exit Do
	Loop
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


 
