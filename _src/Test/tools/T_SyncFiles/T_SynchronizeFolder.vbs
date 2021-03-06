Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_SynchronizeFolder1",_
			"2","T_SynchronizeFolder_ExceptRevision" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SynchronizeFolder1] >>> 
'********************************************************************************
Sub  T_SynchronizeFolder1( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
'//get_CoverageLogClass().Reset  Empty

	delay_msec_for_time_stamp = 2000


	'//=== Test case of updating 1 file or new 1 file

	case_num = 0
	For Each  t In g_TwoFoldersCases
		case_num = case_num + 1
		echo  " ((( [Updating1File("& case_num &")] )))"

		'// Set up
		del  "_work"
		copy  "T_SyncFolder_Files\*", "_work\1"
		copy  "T_SyncFolder_Files\*", "_work\2"

		'// Test Main
		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty
		echo_line

		CreateFile  t.UpdateFolder +"\1.ini", "updated"

		CreateFile  t.UpdateFolder +"\New1.ini", "new"

		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty
		echo_line

		'// Check
		Assert  fc( t.LeftFolder, t.RightFolder )

		copy  t.LeftFolder +"\"+ "*.ini",  "_work\1_Part"
		Assert  fc( "_work\1_Part", "_work\sync" )

		'// Clean
		del  "_work"
	Next


	'//=== Test case of manual synchronize

	case_num = 0
	For only_1_index = 0  To 3
	For Each  t In g_TwoFoldersCases
		case_num = case_num + 1
		echo  " ((( [ManualSynchronize("& case_num &")] )))"

		'// Set up
		del  "_work"
		copy  "T_SyncFolder_Files\*", "_work\1"
		copy  "T_SyncFolder_Files\*", "_work\2"

		'// Test Main
		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty
		echo_line

		If only_1_index = 1  or  only_1_index = 0  Then
			CreateFile  t.UpdateFolder +"\1.ini", "updatedA"
			Sleep  delay_msec_for_time_stamp
			CreateFile  t.OtherFolder  +"\1.ini", "updatedB"
		End If

		If only_1_index = 2  or  only_1_index = 0  Then
			CreateFile  t.UpdateFolder +"\2.ini", "updated"
			del         t.OtherFolder  +"\2.ini"
		End If

		If only_1_index = 3  or  only_1_index = 0  Then
			del         t.UpdateFolder +"\3.ini"
		End If

		echo_line


		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0

		If only_1_index = 0  Then
			Set root = LoadXML( e2.desc, F_Str )
			path_A = root.getAttribute( "hint_path" )
			path_B = "T_SyncFolder_Answer\out_2_"+ g_fs.GetFileName( t.UpdateFolder ) +".txt"
			AssertFC  path_A, path_B
		End If

		echo_line


		'// Clean
		del  "_work"
	Next
	Next


	'//=== Test case of both changed and both new

	case_num = 0
	For Each  t In g_TwoFoldersCases
		case_num = case_num + 1
		echo  " ((( [Both("& case_num &")] )))"

		'// Set up
		del  "_work"
		copy  "T_SyncFolder_Files\*", "_work\1"
		copy  "T_SyncFolder_Files\*", "_work\2"

		'// Test Main
		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty
		echo_line

		CreateFile  t.UpdateFolder +"\1.ini",    "updatedA"
		CreateFile  t.UpdateFolder +"\New1.ini", "new"
		CreateFile  t.UpdateFolder +"\2.ini",    "updatedA"
		CreateFile  t.UpdateFolder +"\New2.ini", "new"
		del         t.UpdateFolder +"\3.ini"

		Sleep  delay_msec_for_time_stamp

		copy        t.UpdateFolder +"\1.ini",     t.OtherFolder
		copy        t.UpdateFolder +"\New1.ini",  t.OtherFolder
		CreateFile  t.OtherFolder  +"\2.ini",    "updatedA"
		CreateFile  t.OtherFolder  +"\New2.ini", "new"
		del         t.OtherFolder  +"\3.ini"

		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty
		echo_line


		'// Check
		Assert  g_fs.GetFile( t.UpdateFolder +"\2.ini" ).DateLastModified = _
			g_fs.GetFile( t.OtherFolder  +"\2.ini" ).DateLastModified
		Assert  g_fs.GetFile( t.UpdateFolder +"\New2.ini" ).DateLastModified = _
			g_fs.GetFile( t.OtherFolder  +"\New2.ini" ).DateLastModified


		'// Clean
		del  "_work"
	Next


	'//=== Test of filter
	echo  " ((( [Filter] )))"

	'// Set up
	del  "_work"
	copy  "T_SyncFolder_Files\*", "_work\1"
	copy  "T_SyncFolder_Files\*", "_work\2"

	'// Test Main
	echo_line
	SynchronizeFolder  "_work\1", "_work\2", "_work\sync", "*.txt", Empty
	echo_line

	CreateFile  "_work\1\1.ini", "updatedA"
	Sleep  delay_msec_for_time_stamp
	CreateFile  "_work\2\1.ini", "updatedB"

	'// Check : No error
	echo_line
	SynchronizeFolder  "_work\1", "_work\2", "_work\sync", "*.txt", Empty
	echo_line

	'// Clean
	del  "_work"


	'// get_CoverageLogClass().Check  1, 14
	Pass
End Sub


 
'********************************************************************************
'  <<< [TwoFoldersClass] >>> 
'********************************************************************************
Class  TwoFoldersClass
	Public  LeftFolder
	Public  RightFolder
	Public  UpdateFolder
	Public  OtherFolder
End Class

Function  new_TwoFoldersClass( LeftFolder, RightFolder, UpdateFolder, OtherFolder )
	Set object = new TwoFoldersClass
	object.LeftFolder  = LeftFolder
	object.RightFolder = RightFolder
	object.UpdateFolder = UpdateFolder
	object.OtherFolder  = OtherFolder
	Set new_TwoFoldersClass = object
End Function


g_TwoFoldersCases = Array( _
	new_TwoFoldersClass( "_work\1", "_work\2", "_work\1", "_work\2" ),_
	new_TwoFoldersClass( "_work\1", "_work\2", "_work\2", "_work\1" ) )


 
'********************************************************************************
'  <<< [T_SynchronizeFolder_ExceptRevision] >>> 
'********************************************************************************
Sub  T_SynchronizeFolder_ExceptRevision( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()

	delay_msec_for_time_stamp = 2000


	'//=== Set "rep"
	Set rep = new StringReplaceSetClass
	rep.ReplaceRange  "$Rev:", "$",  "$Rev: $"


	'//=== Test case of automatic synchronize

	case_num = 0
	For Each  t In g_TwoFoldersCases
		case_num = case_num + 1
		echo  " ((( [Updating1File("& case_num &")] )))"

		'// Set up
		del  "_work"
		CreateFile  "_work\1\A.ini", "aaa$Rev: 0 $bbb"+ vbCRLF +"ccc"
		CreateFile  "_work\1\B.ini", "aaa$Rev: 0 $bbb"+ vbCRLF +"ccc"
		copy  "_work\1\*", "_work\2"
		Sleep  delay_msec_for_time_stamp  '// Set not same time stamp with synchronized


		'// Test Main
		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty
		echo_line


		'// Update both. Same
		CreateFile  t.UpdateFolder +"\A.ini", "aaa$Rev: 11 $bbb"+ vbCRLF +"ccc"
		Sleep  delay_msec_for_time_stamp
		CreateFile  t.OtherFolder  +"\A.ini", "aaa$Rev: 22 $bbb"+ vbCRLF +"ccc"

		'// Update
		CreateFile  t.UpdateFolder +"\B.ini", "aaa$Rev: 11 $bbb"+ vbCRLF +"update"


		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", rep
		echo_line

		'// Check
		Assert  fc( "_work\sync", "_work\1" )
		Assert  fc( "_work\sync", "_work\2" )

		'// Clean
		del  "_work"
	Next


	'//=== Test case of manual synchronize

	case_num = 0
	For Each  t In g_TwoFoldersCases
		case_num = case_num + 1
		echo  " ((( [Updating1File("& case_num &")] )))"

		'// Set up
		del  "_work"
		CreateFile  "_work\1\A.ini", "aaa$Rev: 0 $bbb"+ vbCRLF +"ccc"
		copy  "_work\1\*", "_work\2"
		Sleep  delay_msec_for_time_stamp  '// Set not same time stamp with synchronized


		'// Test Main
		echo_line
		SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", Empty
		echo_line


		'// Update both. Not same
		CreateFile  t.UpdateFolder +"\A.ini", "aaa$Rev: 11 $bbb"+ vbCRLF +"Update11"
		Sleep  delay_msec_for_time_stamp
		CreateFile  t.OtherFolder  +"\A.ini", "aaa$Rev: 22 $bbb"+ vbCRLF +"Update22"


		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			SynchronizeFolder  t.LeftFolder, t.RightFolder, "_work\sync", "*.ini", rep

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0


		'// Clean
		del  "_work"
	Next

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


 
