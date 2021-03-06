Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_SafeFileUpdate", _
			"2","T_SafeFileUpdateEx", _
			"3","T_SafeFileUpdate_ReadOnly" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SafeFileUpdate] >>> 
'********************************************************************************
Sub  T_SafeFileUpdate( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	del  "copyfile.txt"
	del  "src2.txt"
	copy_ren  "data\src1.txt", "copyfile.txt"
	copy_ren  "data\src2\src2.txt", "src2.txt"

	'// Test Main
	SafeFileUpdate  "src2.txt", "copyfile.txt"

	'// Check
	If not fc( "copyfile.txt", "data\src2\src2.txt" ) Then  Fail

	'// Clean
	del  "copyfile.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SafeFileUpdateEx] >>> 
'********************************************************************************
Sub  T_SafeFileUpdateEx( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	del  "copyfile.txt"
	del  "src2.txt"
	copy_ren  "data\src1.txt", "copyfile.txt"
	copy_ren  "data\src2\src2.txt", "src2.txt"

	'// Test Main
	SafeFileUpdateEx  "src2.txt", "copyfile.txt", Empty

	'// Check
	If not fc( "copyfile.txt", "data\src2\src2.txt" ) Then  Fail

	'// Clean
	del  "copyfile.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SafeFileUpdate_ReadOnly] >>> 
'********************************************************************************
Sub  T_SafeFileUpdate_ReadOnly( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	del  "copyfile.txt"
	del  "src2.txt"
	copy_ren  "data\src1.txt", "copyfile.txt"
	copy_ren  "data\src2\src2.txt", "src2.txt"
	SetFileToReadOnly  g_fs.GetFile( "copyfile.txt" )
	del  ".\*.updating"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		SafeFileUpdateEx  "src2.txt", "copyfile.txt", Empty

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '// Set "e2"
	echo    e2.desc
	Assert  InStr( e2.desc, "copyfile.txt" ) >= 1
	Assert  InStr( e2.desc, "copyfile.1.txt.updating" ) >= 1
	Assert  e2.num <> 0

	'// Clean
	del  ".\*.updating"
	del  "src2.txt"
	del  "copyfile.txt"

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

 
