Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_MakeRuleR_Tree", _
			"2","T_MakeRuleR_Command" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_MakeRuleR_Tree
'***********************************************************************
Sub  T_MakeRuleR_Tree( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_out.txt" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_MakeRuleR_Error_SameRule"

	For Each  t  In DicTable( Array( _
		"Files",    "RuleFilePath",   "Target",    "Answer",  Empty, _
		"RFiles1",  "MakeRule1.xml",  "Step1\01",  "Answer1.txt", _
		"RFiles2",  "MakeRule2.xml",  "Step1\01",  "Answer2.txt", _
		"RFiles2",  "MakeRule2A.xml", "Step1\01",  "Answer2AB.txt", _
		"RFiles3",  "3A_MakeRu*.xml", "Step1\01",  "3A_Answer.txt", _
		"RFiles3",  "3B_MakeRu*.xml", "Step1\01",  "3B_Answer.txt", _
		"RFiles3",  "3C_MakeRu*.xml", "Step1\01",  "3C_Answer.txt", _
		"RFiles3",  "3D_MakeRu*.xml", "Step1\01",  "3D_Answer.txt", _
		"RFiles3",  "3E_MakeRu*.xml", "Step1\01",  "3E_Answer.txt" ) )
	If section.Start( "T_MakeRuleR_1_"+ g_fs.GetBaseName( t("RuleFilePath") ) ) Then

		'// Set up
		del  "_out.txt"
		rule_file_path = GetFirst( ArrayFromWildcard( t("Files") +"\"+ t("RuleFilePath") ).FilePaths )
			'// Parse wildcard

		'// Test Main
		Set maker = OpenForMakeRuleOfRevisionFolder( rule_file_path )
		tree_string = maker.GetMakeTreeString( t("Files") +"\"+ t("Target") )

		'// Check
		CreateFile  "_out.txt",  tree_string
		AssertFC    "_out.txt",  t("Files") +"\"+ t("Answer")

		'// Clean
		del  "_out.txt"

	End If : section.End_
	Next


	For Each  t  In DicTable( Array( _
		"Files",         "RuleFilePath",        "Target",    "ErrorMessage",  Empty, _
		"RFilesErrors",  "FewRevisionSet.xml",  "Step1\01",  "${Files}\Step1\*", _
		"RFilesErrors",  "NotFoundTarget.xml",  "Step1\01",  "RFilesErrors\Step1\01", _
		"RFilesErrors",  "SameRule.xml",        "Step1\01",  "RFilesErrors\Step1\01" ) )
	If section.Start( "T_MakeRuleR_Error_"+ g_fs.GetBaseName( t("RuleFilePath") ) ) Then

		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		maker = Empty
		If TryStart(e) Then  On Error Resume Next

			Set maker = OpenForMakeRuleOfRevisionFolder( t("Files") +"\"+ t("RuleFilePath") )
			If not IsEmpty( maker ) Then
				tree_string = maker.GetMakeTreeString( t("Files") +"\"+ t("Target") )
			End If

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"
		echo    e2.desc
		Assert  InStr( e2.desc, t("ErrorMessage") ) >= 1
		Assert  e2.num <> 0


	End If : section.End_
	Next

	If section.Start( "T_MakeRuleR_Error_EmptyNotError" ) Then
		Set maker = OpenForMakeRuleOfRevisionFolder( "RFilesErrors\EmptyNotError.xml" )
		tree_string = maker.GetMakeTreeString( "RFilesErrors\Step1\01" )
		'// Check No Error
	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_MakeRuleR_Command
'***********************************************************************
Sub  T_MakeRuleR_Command( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_out.txt", "RFiles4" ) ).Enable()
	Set section = new SectionTree

	If section.Start( "T_MakeRuleR_Command_1" ) Then

	'// Set up
	del  "_out.txt"
	del    "RFiles4\*\Work"
	mkdir  "RFiles4\_WorkD"
	w_=Empty

	'// Test Main
	Set maker = OpenForMakeRuleOfRevisionFolder( "RFiles4\MakeRule4.xml" )
	commands_string = maker.GetAllCommandsString( "RFiles4\Step1\01" )
	echo  commands_string

	'// Test Main
	maker.Make  "RFiles4\Step1\01",  AppKey

	'// Check
	Set w_=AppKey.NewWritable( Array( "_out.txt", "RFiles4" ) ).Enable()
	AssertFC  "RFiles4\_WorkD\_log.txt",  "RFiles4\Answer\CommandStep2.txt"
	CreateFile  "_out.txt",  commands_string
	AssertFC    "_out.txt",  "RFiles4\Answer\Commands.txt"

	'// Clean
	del  "_out.txt"
	del  "RFiles4\*\Work"
	del  "RFiles4\_log.txt"
	del  "RFiles4\_WorkD"
	w_=Empty

	End If : section.End_


	'//===========================================================
	For Each  t  In DicTable( Array( _
		"Case",        "Before",          "After",            "Message", Empty, _
		"ErrorStep2",  "CommandA.bat 2",  "CommandA.bat 2E",  "Step2\01", _
		"ErrorStep1",  "CommandA.bat 1",  "CommandA.bat 1E",  "Step1\01" ) )
	If section.Start( "T_MakeRuleR_Comand_"+ t("Case") ) Then

	'// Set up
	Set w_=AppKey.NewWritable( Array( "RFiles4" ) ).Enable()
	del  "RFiles4\*\Work"
	mkdir  "RFiles4\_WorkD"
	OpenForReplace( "RFiles4\MakeRule4.xml", "RFiles4\_MakeRule4.xml" ).Replace  t("Before"),  t("After")
	w_=Empty

	'// Test Main
	Set maker = OpenForMakeRuleOfRevisionFolder( "RFiles4\_MakeRule4.xml" )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		maker.Make  "RFiles4\Step1\01",  AppKey

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '// Set "e2"
	echo    e2.desc
	Assert  InStr( e2.desc, t("Message") ) >= 1
	Assert  e2.num <> 0

	'// Clean
	Set w_=AppKey.NewWritable( Array( "RFiles4" ) ).Enable()
	del  "RFiles4\_WorkD"
	del  "RFiles4\*\Work"
	w_=Empty

	End If : section.End_
	Next

	Pass
End Sub


 
'// 失敗したとき、新規出力のとき、

'// XMLがない、親のXMLがない、フォルダーがない
'// <Skip input="02,03,04,05,06"/>  CSV2 = 値の両隣にコンマ
'// Skip は、親によって変わるときは、適切なレベルの親に Skip を書く










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


 
