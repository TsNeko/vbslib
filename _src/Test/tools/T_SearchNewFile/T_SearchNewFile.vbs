Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_SearchNewFile" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SearchNewFile] >>> 
'********************************************************************************
Sub  T_SearchNewFile( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	vbs = SearchParent( "vbslib Prompt.vbs" )

	'// Test Main
	RunProg  "cscript """+ vbs +""" SearchNewFile ""2012/06/11 1:10"" """+_
		SearchParent( "Samples\ExceptExtension.txt" ) +""" Files /out:out.txt", ""

	'// Check
	text = ReadFile( "out.txt" )
	Assert  InStr( text, "Files\File1.txt" ) = 0
	Assert  InStr( text, "Files\File2.txt" ) > 0
	Assert  InStr( text, "Files\Log.log" ) = 0
	Assert  InStr( text, "Files\Sub\File1.txt" ) = 0
	Assert  InStr( text, "Files\Sub\File2.txt" ) > 0
	Assert  InStr( text, "Files\Sub\Log.log" ) = 0

	'// Clean
	del  "out.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Test2] >>> 
'********************************************************************************
Sub  T_Test2( Opt, AppKey )
	Dim  f,  in_path,  out_path

	EchoTestStart  "T_Test2"

	in_path = WScript.Arguments.Named.Item( "setting" )

	'//=== Get test parameters from test parameter file
	If IsEmpty( in_path ) Then
		out_path = "out.txt"
	Else
		Set f = g_fs.OpenTextFile( in_path )
		out_path = Trim( f.ReadLine )
		f = Empty
	End If


	'//=== Make the return file
	Dim w_:Set w_=AppKey.NewWritable( out_path ).Enable()
	Set f = g_fs.CreateTextFile( out_path, True, False )
	f.WriteLine "Pass."
	f = Empty
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


 
