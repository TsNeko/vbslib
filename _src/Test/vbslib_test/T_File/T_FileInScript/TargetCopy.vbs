'// 下記の ----- から ----- の間は、行頭に ' を必ず記述してください。
'-------------------------------------------------------------------[FileA.xml]
' ABC 
'==
'END
'------------------------------------------------------------------[/FileA.xml]

'-------------------------------------------------------------------[FileB.xml]
'((( ２つ目 )))
'------------------------------------------------------------------[/FileB.xml]

'---------------------------------------------------------------[NotEndTagText]
'abc
'def



Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_ReadVBS_Comment_Sub" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_ReadVBS_Comment_Sub] >>> 
'********************************************************************************
Sub  T_ReadVBS_Comment_Sub( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_out.txt"  ).Enable()

	'// Set up
	del  "_out.txt"

	'// Test Main
	text1 = ReadVBS_Comment( Empty, "["+"FileA.xml]", "[/"+"FileA.xml]", Empty )
	text2 = ReadVBS_Comment( Empty, "["+"FileB.xml]", "[/"+"FileB.xml]", Empty )
	text3 = ReadVBS_Comment( "TargetCopy2.vbs", "["+"FileB.xml]", "[/"+"FileB.xml]", Empty )
	text4 = ReadVBS_Comment( "TargetCopy2.vbs#FileB.xml", "["+"Default.xml]", "[/"+"Default.xml]", Empty )
	text5 = ReadVBS_Comment( "#FileB.xml", "["+"Default.xml]", "[/"+"Default.xml]", Empty )

	'// Check
	Assert  text1 = _
		" ABC "+ vbCRLF +_
		"=="+ vbCRLF +_
		"END"+ vbCRLF

	Assert  text2 = "((( ２つ目 )))"+ vbCRLF
	Assert  text3 = "((( ３つ目 )))"+ vbCRLF
	Assert  text4 = "((( ３つ目 )))"+ vbCRLF
	Assert  text5 = "((( ２つ目 )))"+ vbCRLF


	'// Clean


	'// Case of not found keyword
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		text = ReadVBS_Comment( Empty, "<"+"NotFound>", "<"+"/NotFound>", 0 )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'// Case of no EndTag text
	text = ReadVBS_Comment( Empty, "["+"NotEndTagText]", Empty, 0 )
	echo_line : echo  text : echo_line
	Assert  text = "abc"+ vbCRLF +"def"+ vbCRLF


	'// Pass
	CreateFile  "_out.txt", "Pass"
End Sub


 
'********************************************************************************
'  <<< [T_WriteVBS_Comment_Sub] >>> 
'********************************************************************************
Sub  T_WriteVBS_Comment_Sub( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", WScript.ScriptFullName, "_back_up.vbs" ) ).Enable()

	text1 = " DEF "+ vbCRLF +_
		"=="+ vbCRLF +_
		"END"+ vbCRLF

	text2 = "((( ２つ目のデータ )))"+ vbCRLF


	'// Set up
	del  "_out.txt"
	password = Input( "Password >" )
	Assert  password = "8fahenk3q"
	copy_ren  WScript.ScriptFullName, "_back_up.vbs"
	before1 = ReadVBS_Comment( Empty, "["+"FileA.xml]", "[/"+"FileA.xml]", Empty )
	before2 = ReadVBS_Comment( Empty, "["+"FileB.xml]", "[/"+"FileB.xml]", Empty )


	'// Test Main
	WriteVBS_Comment  Empty, "["+"FileA.xml]", "[/"+"FileA.xml]", text1, Empty
	WriteVBS_Comment  Empty, "["+"FileB.xml]", "[/"+"FileB.xml]", text2, Empty


	'// Check
	text = ReadVBS_Comment( Empty, "["+"FileA.xml]", "[/"+"FileA.xml]", Empty )
	Assert  text = text1

	text = ReadVBS_Comment( Empty, "["+"FileB.xml]", "[/"+"FileB.xml]", Empty )
	Assert  text = text2

	Assert  not fc( WScript.ScriptFullName, "_back_up.vbs" )


	'// Test Main
	WriteVBS_Comment  Empty, "["+"FileA.xml]", "["+"/FileA.xml]", before1, Empty
	WriteVBS_Comment  Empty, "["+"FileB.xml]", "["+"/FileB.xml]", before2, Empty


	'// Check
	Assert  fc( WScript.ScriptFullName, "_back_up.vbs" )


	'// Clean
	del  "_back_up.vbs"

	'// Pass
	CreateFile  "_out.txt", "Pass"
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


 
