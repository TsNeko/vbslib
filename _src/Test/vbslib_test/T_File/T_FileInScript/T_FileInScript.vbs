Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_ReadVBS_Comment",_
			"2","T_WriteVBS_Comment",_
			"3","T_new_FilePathForFileInScript" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_ReadVBS_Comment] >>> 
'********************************************************************************
Sub  T_ReadVBS_Comment( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "_Target.vbs" ) ).Enable()
	Set c = g_VBS_Lib


	'//==== Shift-JIS

	'// Set up
	del  "_out.txt"

	'// Test Main
	RunProg  "cscript  TargetCopy.vbs  T_ReadVBS_Comment_Sub", ""

	'// Check
	Assert  ReadFile( "_out.txt" ) = "Pass"
	Assert  ReadUnicodeFileBOM( "TargetCopy.vbs" ) = c.No_BOM

	'// Clean
	del  "_out.txt"


	'//==== Unicode

	'// Set up
	del  "_out.txt"

	script = ReadFile( "TargetCopy.vbs" )
	Set cs = new_TextFileCharSetStack( "Unicode" )
	CreateFile  "_Target.vbs", script
	cs = Empty

	'// Test Main
	RunProg  "cscript  _Target.vbs  T_ReadVBS_Comment_Sub", ""

	'// Check
	Assert  ReadFile( "_out.txt" ) = "Pass"
	Assert  ReadUnicodeFileBOM( "_Target.vbs" ) = c.Unicode

	'// Clean
	del  "_Target.vbs"
	del  "_out.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_WriteVBS_Comment] >>> 
'********************************************************************************
Sub  T_WriteVBS_Comment( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "_Target.vbs" ) ).Enable()
	Set c = g_VBS_Lib

	For Each  cs_name  In Array( "Shift-JIS", "Unicode" )

		'//==== Set up

		'// Make "_Target.vbs"
		If cs_name = "Shift-JIS" Then
			copy_ren  "TargetCopy.vbs", "_Target.vbs"
			Assert  ReadUnicodeFileBOM( "_Target.vbs" ) = c.No_BOM
		Else
			script = ReadFile( "TargetCopy.vbs" )
			Set cs = new_TextFileCharSetStack( "Unicode" )
			CreateFile  "_Target.vbs", script
			cs = Empty
			Assert  ReadUnicodeFileBOM( "_Target.vbs" ) = c.Unicode
		End If


		'//==== Test Main
		RunProg  "cscript  _Target.vbs  T_WriteVBS_Comment_Sub  8fahenk3q", ""


		'//==== Check
		Assert  ReadFile( "_out.txt" ) = "Pass"

		If cs_name = "Shift-JIS" Then
			Assert  ReadUnicodeFileBOM( "_Target.vbs" ) = c.No_BOM
		Else
			Assert  ReadUnicodeFileBOM( "_Target.vbs" ) = c.Unicode
		End If


		'//==== Clean
		del  "_Target.vbs"
		del  "_out.txt"
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_new_FilePathForFileInScript] >>> 
'********************************************************************************
Sub  T_new_FilePathForFileInScript( Opt, AppKey )

	'// Test Main
	CommandA  new_FilePathForFileInScript( Empty )


	'// Test Main
	Assert  ReadFile( new_FilePathForFileInScript( "TargetCopy2.vbs" ) ) = _
		"1"+ vbCRLF +"2"+ vbCRLF


	'// Test Main
	Set path = new_FilePathForFileInScript( Empty )
	Set root = LoadXML( path, Empty )
	Assert  root.selectSingleNode( "./Tag" ).getAttribute( "attr" ) = "12"


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		CommandA  new_FilePathForFileInScript( "NotFound.xml" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set path = new_FilePathForFileInScript( "TargetCopy2.vbs#NotFound" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "TargetCopy2.vbs#NotFound" ) >= 1
	Assert  e2.num <> 0


	'// Test Main
	Set root = LoadXML( new_FilePathForFileInScript( "XML.vbs#FileA.xml" ), Empty )
	Assert  root.selectSingleNode( "./B/@value" ).nodeValue = "2"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set root = LoadXML( new_FilePathForFileInScript( "XML.vbs#SyntaxError.xml" ), Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "XML.vbs#SyntaxError.xml" ) >= 1
	Assert  InStr( e2.desc, "line=""2""" ) >= 1
	Assert  e2.num <> 0

	Pass
End Sub


Sub  CommandA( Path )
	Set root = LoadXML( Path, Empty )
	Assert  root.selectSingleNode( "./Tag" ).getAttribute( "attr" ) = "12"
End Sub

'------------------------------------------------------------[FileInScript.xml]
'<Root>
'<Tag attr="12"/>
'</Root>
'-----------------------------------------------------------[/FileInScript.xml]


 







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


 
