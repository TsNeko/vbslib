Sub  Main( Opt, AppKey )
	Set g = GetTemporaryTestsObject().CurrentTest.Delegate
	RunTestPrompt  AppKey.NewWritable( Array( ".",_
		SearchParent( g("TestRootFolder") ) +"\"+ g("TestTargetFolder") ) )
End Sub


Sub  Test_current( tests )
	If IsEmpty( tests.CurrentTest.Delegate ) Then
		Dim g : Set g = CreateObject( "Scripting.Dictionary" ) : Set tests.CurrentTest.Delegate = g

		'[Setting]
		'==============================================================================
		g("TestRootFolder") = "Samples\PartRep"
		g("TestTargetFolder") = "PartRepSampleTarget"
		'==============================================================================
	End If
End Sub


Sub  Test_setup( tests )
	Set g = tests.CurrentTest.Delegate

	from_str = "%TestRootFolder%"
	to_str = SearchParent( g("TestRootFolder") )
	OpenForReplace( "ans1.txt", "ans1_tmp.txt" ).Replace  from_str,  to_str
	OpenForReplace( "ans2.txt", "ans2_tmp.txt" ).Replace  from_str,  to_str
	OpenForReplace( "ans3.txt", "ans3_tmp.txt" ).Replace  from_str,  to_str

	'// Check same script
	test_root = to_str
	replica_root = SearchParent( "_src\_replica" )
	For Each file_name  In Array( "PartCmp.vbs", "PartRep.vbs" )
		AssertFC  test_root +"\_PartRep\"+ file_name, _
			replica_root +"\2 Sync vbslib\_old\"+ file_name
	Next

	Pass
End Sub


Sub  Test_start( tests )
	Set g = tests.CurrentTest.Delegate
	test_root_folder = SearchParent( g("TestRootFolder") )


	'// Set up
	del  test_root_folder +"\"+ g("TestTargetFolder")

	unzip _
		test_root_folder +"\"+ g("TestTargetFolder") +".zip",_
		test_root_folder +"\"+ g("TestTargetFolder"), Empty


	'// Test Main
	echo  "=== PartCmp ==="
	echo  vbCRLF+"Next is expected Error"
	If TryStart(e) Then  On Error Resume Next
		r = RunProg( "cscript //nologo """+ test_root_folder +"\_PartRep\PartCmp.vbs""" , "out1.txt" )
	If TryEnd Then  On Error GoTo 0
	e.Clear

	echo  "=== PartRep ==="
	r = RunProg( "cscript //nologo """+ test_root_folder +"\_PartRep\PartRep.vbs"" /set_input:y." , "out2.txt" )
	CheckTestErrLevel  r

	echo  "=== PartCmp ==="
	r = RunProg( "cscript //nologo """+ test_root_folder +"\_PartRep\PartCmp.vbs""" , "out3.txt" )
	CheckTestErrLevel  r


	'// Check
	AssertFC  "out1.txt", "ans1_tmp.txt"
	AssertFC  "out2.txt", "ans2_tmp.txt"
	AssertFC  "out3.txt", "ans3_tmp.txt"


	'// Clean
	del  "out1.txt"
	del  "out2.txt"
	del  "out3.txt"


	'// Resume sample folder
	del  test_root_folder +"\"+ g("TestTargetFolder")

	unzip _
		test_root_folder +"\"+ g("TestTargetFolder") +".zip",_
		test_root_folder +"\"+ g("TestTargetFolder"), Empty
	Pass
End Sub


Sub  Test_clean( tests )
	del  "ans1_tmp.txt"
	del  "ans2_tmp.txt"
	del  "ans3_tmp.txt"
	Pass
End Sub


Sub  Test_build( tests ) : Pass : End Sub
Sub  Test_check( tests ) : Pass : End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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


 
