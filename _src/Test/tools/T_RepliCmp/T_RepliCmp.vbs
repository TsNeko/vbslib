Sub  Main( Opt_, AppKey )
	desktop = g_sh.SpecialFolders("Desktop")

	wr = Array( _
		"data_upd_work",_
		desktop + "\_RepliCmp",_
		"Editing",_
		"New" )
	Set w_= AppKey.NewWritable( wr ).Enable()

	del  desktop + "\_RepliCmp"

	Set opt = new RepliCmp_Option
	opt.m_EditorPath = Setting_getEditorCmdLine(0)
	opt.m_DiffPath = Setting_getDiffCmdLine(0)
	opt.m_bSilent = True

	Select Case  WScript.Arguments.Named.Item("Test")
		Case "T_2Folders3Files" : T_2Folders3Files  opt
		Case "T_2FoldersNoInMaster" : T_2FoldersNoInMaster  opt
		Case "T_3Folders1or2Files" : T_3Folders1or2Files  opt
		Case "T_3Folders4Files" : T_3Folders4Files  opt
		Case "T_RepliCmpUpdate" : T_RepliCmpUpdate  opt
		Case "T_NewPatch_New"  : T_NewPatch_New   opt
		Case "T_NewPatch_Both" : T_NewPatch_Both  opt
		Case Else : T_2Folders3Files  opt  '// for Debug
	End Select

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_2Folders3Files] >>> 
'********************************************************************************
Sub T_2Folders3Files( Opt )

	'//=== Out Diff
	folders = Array( _
		"data\folder0",_
		"data\folder1" )

	files = Array(_
		"file2.txt" )  '// 1 file in master + 2 files in folders

	RepliCmp  folders, files, Opt

	'//=== Merge
	desktop = g_sh.SpecialFolders("Desktop")
	r = RunProg( "cscript.exe //nologo " + dbg1 + """" + desktop + "\_RepliCmp\Merge.vbs"""+_
			 dbg2 + " /set_input:1.7.6.7.8.y.8.y.7.4.7.9.-1.", "" )

	If not exist( desktop + "\_RepliCmp\New\file2.txt" ) Then  Fail
	If not fc( desktop + "\_RepliCmp\New\file2.txt", "data\folder1\sub1\file2.txt" ) Then  Fail
End Sub


 
'********************************************************************************
'  <<< [T_2FoldersNoInMaster] >>> 
'********************************************************************************
Sub T_2FoldersNoInMaster( Opt )
	folders = Array( _
		"data\folder0",_
		"data\folder1" )

	files = Array(_
		"fileErr.txt" )  '// no file in master

	If TryStart(e) Then  On Error Resume Next
		RepliCmp  folders, files, Opt
	If TryEnd Then  On Error GoTo 0
	If e.num = 0 Then  Fail
	e.Clear
End Sub


 
'********************************************************************************
'  <<< [T_3Folders1or2Files] >>> 
'********************************************************************************
Sub T_3Folders1or2Files( Opt )

	'//=== Out Diff
	folders = Array(_
		"data\folder0",_
		"data\folder1",_
		"data\folder2" )

	files = Array(_
		"file1.txt",_
		"file0.txt" )  '// no file in folders
			'// "file1.txt" : 1 file in master + 1 file in folders

	RepliCmp  folders, files, Opt


	'//=== Merge
	desktop = g_sh.SpecialFolders("Desktop")
	r = RunProg( "cscript.exe //nologo " + dbg1 + """" + desktop + "\_RepliCmp\Merge.vbs"""+_
			 dbg2 + " /set_input:1.7.6.7.8.y.8.y.7.4.7.9.-1.", "" )

	If not exist( desktop + "\_RepliCmp\New\file1.txt" ) Then  Fail
	If not fc( desktop + "\_RepliCmp\New\file1.txt", "data\folder0\file1.txt" ) Then  Fail

End Sub




 
'********************************************************************************
'  <<< [T_3Folders4Files] >>> 
'********************************************************************************
Sub T_3Folders4Files( Opt )

	'//=== Out Diff
	folders = Array(_
		"data\folder3\master",_
		"data\folder1",_
		"data\folder3" )

	files = Array(_
		"file3.txt" )  '// 1 file in master + 3 files in folders

	RepliCmp  folders, files, Opt


	'//=== Merge
	desktop = g_sh.SpecialFolders("Desktop")
	new_path = desktop + "\_RepliCmp\New\file3.txt"
	f2_path = desktop + "\_RepliCmp\Editing\file3(2).txt"
	f1M_path = desktop + "\_RepliCmp\Editing\file3(1)M.txt"

	r = RunProg( "cscript.exe //nologo " + dbg1 + """" + desktop + "\_RepliCmp\Merge.vbs"""+_
			 dbg2 + " /set_input:1.7.5.7.7.5.7.9.-1.", "" )

	If not exist( new_path ) Then  Fail
	If not fc( new_path, "data\folder3\master\file3.txt" ) Then  Fail
	If not exist( f2_path ) Then  Fail
	If not exist( f1M_path ) Then  Fail

	r = RunProg( "cscript.exe //nologo " + dbg1 + """" + desktop + "\_RepliCmp\Merge.vbs"""+_
			 dbg2 + " /set_input:1.8.y.8.y.8.y.9.-1. /autokeys_debug", "" )

	If exist( new_path ) Then  Fail
	If exist( f2_path ) Then  Fail
	If not exist( f1M_path ) Then  Fail

End Sub

 
'********************************************************************************
'  <<< [T_RepliCmpUpdate] >>> 
'********************************************************************************
Sub T_RepliCmpUpdate( Opt )

	'//=== Make data folder
	del  "data_upd_work"
	copy "data_upd\*", "data_upd_work"
	copy_ren "data_upd_work\folder1\sub1\file2.txt", "data_upd_work\file112.txt"
	copy_ren "data_upd_work\folder2\sub1\file2.txt", "data_upd_work\file212.txt"
	copy_ren "data_upd_work\folder2\sub1\file2.txt", "data_upd_work\folder2\sub1\backup\file2 (1).txt"


	'//=== Out Diff
	folders = Array(_
		"data_upd_work\folder0",_
		"data_upd_work\folder1",_
		"data_upd_work\folder2" )

	files = Array(_
		"file2.txt" )  '// 1 file in master + 2 files in folders

	RepliCmp  folders, files, Opt


	'//=== Merge
	desktop = g_sh.SpecialFolders("Desktop")
	r = RunProg( "cscript.exe //nologo " + dbg1 + """" + desktop + "\_RepliCmp\Merge.vbs"""+_
			 dbg2 + " /set_input:1.7.4.7.7.y.9.-1", "" )

	If not fc( "data_upd_work\folder0\file2.txt", "data_upd_work\folder1\sub1\file2.txt" ) Then Fail
	If not fc( "data_upd_work\folder0\file2.txt", "data_upd_work\folder1\sub2\file2.txt" ) Then Fail
	If not fc( "data_upd_work\folder0\file2.txt", "data_upd_work\folder2\sub1\file2.txt" ) Then Fail
	If not fc( "data_upd_work\file112.txt", "data_upd_work\folder1\sub1\backup\file2 (1).txt" ) Then Fail
	If not fc( "data_upd_work\file212.txt", "data_upd_work\folder2\sub1\backup\file2 (2).txt" ) Then Fail


	'//=== Delete data folder
	del  "data_upd_work"
End Sub

 
'********************************************************************************
'  <<< [T_NewPatch_New] >>> 
'********************************************************************************
Sub  T_NewPatch_New( Opt )
	del  "Editing"
	del  "New"

	Set opt2 = new Merge_Option
	With  opt2
		.m_EditorPath = Opt.m_EditorPath
		.m_DiffPath   = Opt.m_DiffPath
	End With

	Set patch_files = new PatchFiles
	With  patch_files
		Set .m_MergeOption = opt2
		.m_OldFolderPath   = "data\folder1"
		.m_PatchFolderPath = "data\folder2"
		.m_NewFolderPath   = "data\folder0"
	End With

	patch_files.AddPatchFile  "file4.txt"

	g_CUI.m_Auto_Keys = "1.7.9.-1."
	patch_files.RunMergePrompt

	If not exist( "New\file4.txt" ) Then  Fail

	del  "Editing"
	del  "New"
End Sub
 
'********************************************************************************
'  <<< [T_NewPatch_Both] >>> 
'********************************************************************************
Sub  T_NewPatch_Both( Opt )
	del  "Editing"
	del  "New"

	Set opt2 = new Merge_Option
	With  opt2
		.m_EditorPath = Opt.m_EditorPath
		.m_DiffPath   = Opt.m_DiffPath
	End With

	Set patch_files = new PatchFiles
	With  patch_files
		Set .m_MergeOption = opt2
		.m_OldFolderPath   = "data\folder1"
		.m_PatchFolderPath = "data\folder2"
		.m_NewFolderPath   = "data\folder0"
	End With

	patch_files.AddPatchFile  "file5.txt"

	g_CUI.m_Auto_Keys = "1.7.6.7.9.-1"
	patch_files.RunMergePrompt


	If not exist( "New\file5.txt" ) Then  Fail

	del  "Editing"
	del  "New"
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


 
