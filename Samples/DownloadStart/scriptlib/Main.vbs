Sub  Main( Opt, AppKey )


	'// Copyright (C) 2017-20xx あなたの名前または所属  All Rights Reserved.
	echo  "Hello, world!"      ' ← ここにスクリプトを書きます ●
	echo  ""
	echo  "CurrentDirecotry = """+ g_sh.CurrentDirectory +""""
	echo  "g_start_in_path  = """+ g_start_in_path +""""
	echo  "g_vbslib_folder  = """+ g_vbslib_folder +""""


End Sub


 







'--- start of unzip ------------------------------------------------------ 
g_zip_path = "scriptlib.zip"
g_scriptlib_path = "scriptlib"
g_extracting_path = "scriptlib_extracting"
Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject( "WScript.Shell" )
Set  g_app = WScript.CreateObject( "Shell.Application" )
g_start_in_path = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
If not g_fs.FolderExists( g_scriptlib_path ) Then
	If not g_fs.FolderExists( g_extracting_path ) Then _
		g_fs.CreateFolder  g_extracting_path
	g_zip_path = g_fs.GetAbsolutePathName( g_zip_path )
	g_extracting_path = g_fs.GetAbsolutePathName( g_extracting_path )
	Set  g_zip_file = g_app.NameSpace( g_zip_path ).items
	Set  g_output_folder = g_app.NameSpace( g_extracting_path )
	g_output_folder.CopyHere  g_zip_file,  &h14
	g_fs.MoveFolder  g_extracting_path,  g_scriptlib_path
End If
g_sh.CurrentDirectory = g_start_in_path
g_start_in_path = Empty
g_zip_path = Empty : g_extracting_path = Empty : g_fs = Empty : g_sh = Empty
g_app = Empty : g_zip_file = Empty : g_output_folder = Empty
'--- end of unzip --------------------------------------------------------

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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
