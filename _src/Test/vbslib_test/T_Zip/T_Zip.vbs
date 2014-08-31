Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_unzip",_
			"2","T_unzip2",_
			"3","T_BadZip",_
			"4","T_zip2" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_unzip] >>> 
'********************************************************************************
Sub  T_unzip( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "sample1" ).Enable()

	'// set up
	del  "sample1"

	'// Test Main
	unzip  "sample1.zip", "sample1", Empty

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"

	'// clean
	del  "sample1"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_unzip2] >>> 
'********************************************************************************
Sub  T_unzip2( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "sample2" ).Enable()

	'// set up
	del  "sample2"

	'// Test Main
	unzip2  "sample1.zip", "sample2"

	'// check
	Assert  ReadFile( "sample2\sample1\file1.txt" ) = "T_Zip"

	'// clean
	del  "sample2"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_BadZip] >>> 
'********************************************************************************
Sub  T_BadZip( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( Array( "sample1", "sample2" ) ).Enable()

	'// set up
	del  "sample1"
	del  "sample2"


	'// Test Main
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		unzip  "sample_bad.zip", "sample1", Empty

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'// Test Main
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		unzip2  "sample_bad.zip", "sample2"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_zip2] >>> 
'********************************************************************************
Sub  T_zip2( Opt, AppKey )
	delete_paths = Array( "sample2", "_out", "_out.zip", "_out_fo", "_out_fo.zip" )
	Set w_=AppKey.NewWritable( delete_paths ).Enable()

	'// set up
	CallForEach1  GetRef("CallForEach_del"), delete_paths, "."
	unzip2  "sample1.zip", "sample2"

	'// Test Main
	zip2  "_out.zip",    "sample2", False
	zip2  "_out_fo.zip", "sample2", True

	'// check
	unzip2  "_out.zip",    "_out"
	unzip2  "_out_fo.zip", "_out_fo"
	Assert  fc( "_out", "sample2" )
	Assert  fc( "_out_fo\sample2", "sample2" )

	'// clean
	CallForEach1  GetRef("CallForEach_del"), delete_paths, "."

	Pass
End Sub


 







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


 
