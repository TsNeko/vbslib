Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( "1","T_InputPath_WorkFolder_File" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_InputPath_WorkFolder_File] >>> 
'********************************************************************************
Sub  T_InputPath_WorkFolder_File( Opt, AppKey )
	Set c = g_VBS_Lib
	EchoTestStart  "T_InputPath_WorkFolder_File"

	echo  "g_start_in_path = "+ g_start_in_path
	Assert  InStr( g_start_in_path, "T_Open_Data" )  '// This script file must be called from Test.vbs

	'//=== step path from g_start_in_path
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  "File1.txt"+vbLF
	path = InputPath( "path>", c.CheckFileExists )
	echo  "path = "+ path
	Assert  path = g_start_in_path +"\File1.txt"

	'//=== new file path
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  "NotFound\NewFile.txt"+vbLF
	path = InputPath( "path>", Empty )
	echo  "path = "+ path
	Assert  path = g_start_in_path +"\NotFound\NewFile.txt"

	'//=== new file path (c.AllowEnterOnly)
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  "NotFound\NewFile.txt"+vbLF
	path = InputPath( "path>", c.AllowEnterOnly )
	echo  "path = "+ path
	Assert  path = g_start_in_path +"\NotFound\NewFile.txt"

	'//=== absolute path (1)
	g_CUI.m_Auto_KeyEnter = vbLF
	abs_path = GetFullPath( "File1.txt", g_start_in_path )
	set_input  abs_path + vbLF
	path = InputPath( "path>", c.CheckFileExists )
	echo  "path = "+ path
	Assert  path = abs_path

	'//=== absolute path (2)
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  "X:\folder\File1.txt"+vbLF
	path = InputPath( "path>", Empty )
	echo  "path = "+ path
	Assert  path = "X:\folder\File1.txt"

	'//=== tag jump path
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  "File1.txt(10)"+vbLF
	path = InputPath( "path>", c.CheckFileExists )
	echo  "path = "+ path
	Assert  path = g_start_in_path +"\File1.txt(10)"

	'//=== LAN address
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  "\\pc01.sample.com\folder\File1.txt(10)"+vbLF
	path = InputPath( "path>", Empty )
	echo  "path = "+ path
	Assert  path = "\\pc01.sample.com\folder\File1.txt(10)"

	'//=== Input Enter only Error
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  vbLF +"exit_function.txt" +vbLF
	path = InputPath( "path>", Empty )  '// Error
	echo  "path = "+ path
	Assert  path = g_start_in_path +"\exit_function.txt"

	'//=== Input Enter only
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  vbLF
	path = InputPath( "path>", c.AllowEnterOnly )
	echo  "path = "+ path
	Assert  path = ""

	'//=== overwrite g_start_in_path
	g_start_in_path = GetFullPath( "..", g_start_in_path )
	g_CUI.m_Auto_KeyEnter = vbLF
	set_input  "T_Open_Data\File1.txt"+vbLF
	path = InputPath( "path>", c.CheckFileExists )
	echo  "path = "+ path
	Assert  path = g_start_in_path +"\T_Open_Data\File1.txt"
End Sub


 
'********************************************************************************
'  <<< [T_InputPath_TestOfCheck] >>> 
'********************************************************************************
Sub  T_InputPath_TestOfCheck( Opt, AppKey )
	Set c = g_VBS_Lib

	'//===========================================================
	EchoTestStart  "T_InputPath_Wildcard"
	g_CUI.m_Auto_KeyEnter = vbLF

	set_input  "*.mak"+vbLF
	path = InputPath( "disabled *>", c.CheckFileExists or c.AllowWildcard )

	set_input  "*.mak"+vbLF+ "Text1.txt"+vbLF
	path = InputPath( "disabled *>", c.CheckFileExists )

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


 
