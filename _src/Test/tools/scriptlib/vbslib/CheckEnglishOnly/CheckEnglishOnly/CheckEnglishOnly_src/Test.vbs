Sub  Main( Opt, AppKey )
	Dim  path : path = SearchParent("TestCommon.vbs")
	If not IsEmpty( path ) Then  include  path
	RunTestPrompt  AppKey.NewWritable( Array( ".", "..\CheckEnglishOnly.exe" ) )
End Sub

Sub  Test_current( tests )
	If IsEmpty( tests.CurrentTest.Delegate ) Then
		Dim g : Set g = CreateObject( "Scripting.Dictionary" ) : Set tests.CurrentTest.Delegate = g
		If IsDefined( "TestCommon_setVariables" ) Then  TestCommon_setVariables  g
		Dim  x

		'[Setting]
		'==============================================================================
		g("ExeName") = "CheckEnglishOnly"
		g("Config")  = "Release"
		'==============================================================================

		x = WScript.Arguments.Named( "Config" ) : If not IsEmpty( x ) Then  g("Config") = x
	End If
End Sub


Sub  Test_build( tests )
	Set g = tests.CurrentTest.Delegate
	r = RunProg( "cscript "+g("ExeName")+"_setup.vbs /MakeProj", "" )
	CheckTestErrLevel  r
	devenv_rebuild  g("ExeName")+".sln", g("Config")
	Pass
End Sub


Sub  Test_start( tests )
	Set g = tests.CurrentTest.Delegate
	Set ds = new CurDirStack
	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"  '// 一部のセクションだけ実行するときは有効にする


	'//=== Test case : Basic
	If section.Start( "T_Basic" ) Then

	'// Set up
	del  "out.txt"

	'// Test Main
	r = RunProg( g("Config") +"\"+g("ExeName")+".exe /Folder:TestData "+_
		"/Setting:TestData\SettingForCheckEnglish.ini", "out.txt" )

	'// Check
	Assert  r = 1
	AssertFC  "out.txt", "Answer\T_Basic.txt"

	'// Clean
	del  "out.txt"

	End If : section.End_


	'//=== Test case : Parent folder
	If section.Start( "T_ParentFolder" ) Then

	'// Set up
	del  "work"
	For Each  file_name  In Array( "KanjiInUnicode.txt", "SettingForCheckEnglish.ini" )
		copy  "TestData\"+ file_name, "work\work\TestData"
	Next
	exe = GetFullPath( g("Config") +"\"+g("ExeName")+".exe", Empty )

	'// Test Main
	pushd  "work\work\TestData"
	r = RunProg( """"+ exe +""" /Folder:..\.. "+_
		"/Setting:SettingForCheckEnglish.ini", "..\..\..\out.txt" )
	popd

	'// Check
	Assert  r = 1
	AssertFC  "out.txt", "Answer\T_ParentFolder.txt"

	'// Clean
	del  "work"

	End If : section.End_

	Pass
End Sub


Sub  Test_check( tests )
	copy_ren  "Release\CheckEnglishOnly.exe", "..\CheckEnglishOnly.exe"
	Pass
End Sub


Sub  Test_clean( tests )
	Dim  g : Set g = tests.CurrentTest.Delegate
	Dim  r : r = RunProg( "cscript "+g("ExeName")+"_setup.vbs /Clean", "" )
	CheckTestErrLevel  r
	del  "out.txt"
	Pass
End Sub


Sub  Test_setup( tests ) : Pass : End Sub


 







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


 
