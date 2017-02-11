Sub  Main( Opt, AppKey )
	path = SearchParent("TestCommon.vbs")
	If not IsEmpty( path ) Then  include  path
	RunTestPrompt  AppKey.NewWritable( "." )
End Sub


Sub  Test_current( tests )
	If IsEmpty( tests.CurrentTest.Delegate ) Then
		Set g = CreateObject( "Scripting.Dictionary" ) : Set tests.CurrentTest.Delegate = g
		If IsDefined( "TestCommon_setVariables" ) Then  TestCommon_setVariables  g


		'[Setting]
		'==============================================================================
		g("ExeName") = "feq"
		g("Config")  = "Release"
		'==============================================================================
	End If
End Sub


Sub  Test_build( tests )
	get_DevEnvObj : If IsEmpty( GetVar( "devenv_ver_name" ) ) Then  Skip

	Set g = tests.CurrentTest.Delegate
	r = RunProg( "cscript "+g("ExeName")+"_setup.vbs /MakeProj", "" )
	CheckTestErrLevel  r
	devenv_rebuild  g("ExeName")+".sln", g("Config")
	Pass
End Sub


Sub  Test_start( tests )
	get_DevEnvObj : If IsEmpty( GetVar( "devenv_ver_name" ) ) Then  Skip

	Set g = tests.CurrentTest.Delegate
	Set ds = new CurDirStack

	pushd  "T_feq\5"
	r = RunProg( """..\..\"+ g("Config") +"\"+g("ExeName")+".exe"" a b", "" )
	popd
	If r <> 0 Then  Fail
	Pass
End Sub


Sub  Test_check( tests )
	Set g = tests.CurrentTest.Delegate
	copy  g("Config") +"\"+g("ExeName")+".exe", "."
	Pass
End Sub


Sub  Test_clean( tests )
	get_DevEnvObj : If IsEmpty( GetVar( "devenv_ver_name" ) ) Then  Skip

	Set g = tests.CurrentTest.Delegate
	r = RunProg( "cscript "+g("ExeName")+"_setup.vbs /Clean", "" )
	CheckTestErrLevel  r
	Pass
End Sub


Sub  Test_setup( tests ) : Pass : End Sub


 







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


 
