Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_CopyTagFiles",_
			"2","T_CopyExists",_
			"3","T_MakeShortcutFiles",_
			"4","T_CopyNotExists", _
			"5","T_CopyWindowClass" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_CopyTagFiles
'***********************************************************************
Sub  T_CopyTagFiles( Opt, AppKey )
	Dim  c : Set c = g_VBS_Lib
	Dim w_:Set w_=AppKey.NewWritable( "T_Tag_work" ).Enable()

	del      "T_Tag_work"
	copy_ex  "T_Tag_data\*_tag1.*",  "T_Tag_work",  c.CutTag
	Assert  fc( "T_Tag_work\fo",  "T_Tag_ans" )

	del      "T_Tag_work"
	copy_ex  "T_Tag_data\fo\*_tag1.*",  "T_Tag_work",  c.CutTag
	Assert  fc( "T_Tag_work",  "T_Tag_ans" )

	'// Clean
	del      "T_Tag_work"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_CopyExists
'***********************************************************************
Sub  T_CopyExists( Opt, AppKey )
	Dim  c : Set c = g_VBS_Lib
	Dim w_:Set w_=AppKey.NewWritable( "T_Exist_work" ).Enable()

	del      "T_Exist_work"
	copy     "T_Exist_data\*",  "T_Exist_work"

	'// Test Main
	copy_ex  "T_Tag_data\fo\*",  "T_Exist_work",  c.ExistOnly

	'// Check
	Assert  fc( "T_Exist_work",  "T_Exist_ans" )

	'// Clean
	del      "T_Exist_work"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_MakeShortcutFiles
'***********************************************************************
Sub  T_MakeShortcutFiles( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	'// Test Main
	copy_ex  "T_Tag_data\fo\*",  "_work",  c.MakeShortcutFiles

	'// Check
	fo = g_sh.CurrentDirectory +"\T_Tag_data\fo\"
	Assert  g_sh.CreateShortcut( "_work\file1.lnk" ).TargetPath     = fo +"file1.txt"
	Assert  g_sh.CreateShortcut( "_work\no_ext1.lnk" ).TargetPath   = fo +"no_ext1"
	Assert  g_sh.CreateShortcut( "_work\fo1\file1.lnk" ).TargetPath = fo +"fo1\file1.txt"

	'// Clean
	del      "_work"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_CopyNotExists
'***********************************************************************
Sub  T_CopyNotExists( Opt, AppKey )
	Dim  c : Set c = g_VBS_Lib
	Dim w_:Set w_=AppKey.NewWritable( Array( "_work", "T_Exist_data\Empty", "T_Exist_ans\Empty" ) ).Enable()

	del      "_work"
	copy     "T_Exist_ans\file1.txt",           "_work"
	copy     "T_Exist_ans\fo1\file2_tag1.txt",  "_work\fo1"
	mkdir    "T_Exist_data\Empty"
	mkdir    "T_Exist_ans\Empty"

	'// Test Main
	copy_ex  "T_Exist_data\*",  "_work",  c.NotExistOnly

	'// Check
	Assert  fc( "_work", "T_Exist_ans" )

	'// Clean
	del      "T_Exist_data\Empty"
	del      "T_Exist_ans\Empty"
	del      "_work"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_CopyWindowClass
'***********************************************************************
Sub  T_CopyWindowClass( Opt, AppKey )
If g_is_vbslib_for_fast_user Then
	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()

	'//===========================================================
	'// Set up
	del  "_work"
	mkdir  "_work"
	RunProg  "fsutil  file  createnew  ""_work\large-1.bin""  100000000",  ""
	RunProg  "fsutil  file  createnew  ""_work\large-2.bin""  100000000",  ""

	'// Test Main
	Set copies = new CopyWindowClass
	copies.CopyAndRenameStart  "_work\large-1.bin", "_work\large-1-copy.bin"
	copies.CopyAndRenameStart  "_work\large-2.bin", "_work\large-2-copy.bin"
	copies.WaitUntilCompletion

	'// Check
	AssertExist  "_work\large-1-copy.bin"
	AssertExist  "_work\large-2-copy.bin"

	'// Clean
	del  "_work"


	'//===========================================================
	'// Set up
	Const  number_of_process = 16
	del  "_work"
	mkdir  "_work"
	For i=1 To  number_of_process
		RunProg  "fsutil  file  createnew  ""_work\large-"+ CStr( i ) +".bin""  20000000",  ""
	Next

	'// Test Main
	Set copies = new CopyWindowClass
	For i=1 To  number_of_process
		echo  i
		copies.CopyAndRenameStart  "_work\large-"+ CStr( i ) +".bin", "_work\sub\large-"+ CStr( i ) +"-copy.bin"
	Next
	copies = Empty

	'// Check
	For i=1 To  number_of_process
		AssertExist  "_work\sub\large-"+ CStr( i ) +"-copy.bin"
	Next

	'// Clean
	del  "_work"

	Pass
End If
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

 
