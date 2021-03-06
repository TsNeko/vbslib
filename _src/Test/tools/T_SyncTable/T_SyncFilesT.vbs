Sub  Main( Opt, AppKey )
	include  SearchParent( "_src\Test\tools\T_SyncFiles\SettingForTest_pre.vbs" )
	include  SearchParent( "_src\Test\tools\T_SyncFiles\SettingForTest.vbs" )

	Set o = new InputCommandOpt
		o.Lead = "ui: User Interface Trial"
		Set o.CommandReplace = Dict(Array(_
			"1","T_SyncFilesT_1",_
			"2","T_SyncFilesT_2",_
			"3","T_SyncFilesT_4_DiffRevision",_
			"4","T_SyncFilesT_Create",_
			"5","T_SyncFilesT_Check",_
			"6","T_SyncFilesT_4way",_
			"7","T_SyncFilesT_Except" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub

Sub  ui( Opt, AppKey ) : T_SyncFilesT_ui  Opt, AppKey : End Sub
Sub  ui2(Opt, AppKey ) : T_SyncFilesT_ui2 Opt, AppKey : End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_1
'***********************************************************************
Sub  T_SyncFilesT_1( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_SyncFilesT_1_Commit_False"
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )


	'//===========================================================
	If section.Start( "T_SyncFilesT_1" ) Then

	Set w_=AppKey.NewWritable( Array( "Files\1\_SyncFilesT_Setting.xml", "Files\1\_out.xml" ) ).Enable()

	'// Set up
	copy_ren  "Files\1\11_SyncFilesT_Setting.xml", "Files\1\_SyncFilesT_Setting.xml"

	'// Test Main
	Set  sync = new SyncFilesT_Class
	sync.Run  "Files\1\_SyncFilesT_Setting.xml", "Files\1\_out.xml", "ModuleX"

	'// Check
	AssertFC  "Files\1\_out.xml", "Files\1\12_SyncFilesT_Out.xml"

	'// Clean
	del  "Files\1\_SyncFilesT_Setting.xml"
	del  "Files\1\_out.xml"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_SyncFilesT_1_New2" ) Then

	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()

	'// Set up
	del  "_work"
	copy  "Files\1\*", "_work"
	CreateFile  "_work\ModuleX\Target9\g2.c",     "X\1\B\02"  '// Emulate to Update
	CreateFile  "_work\ModuleX\Target7\sub\g3.c", "X\2\B\02"
	CreateFile  "_work\ModuleX\Target8\g3.c",     "X\2\B\02"
	CreateFile  "_work\ModuleX\Target9\g3.c",     "X\2\C\02"

	'// Test Main
	Set  sync = new SyncFilesT_Class
	sync.Run  "_work\11_SyncFilesT_Setting.xml", "_work\_out.xml", "ModuleX"

	'// Check
	AssertFC  "_work\_out.xml", "Files\1\13_SyncFilesT_Out.xml"

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	For Each  is_prompt  In  Array( False, True )
	If section.Start( "T_SyncFilesT_1_Commit_"+ GetEchoStr( is_prompt ) ) Then

	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()

	commit_tags_answer = _
		"<File kind=""1"" description="" , ,B"" name=""g2.c"" line_num=""11""/>"+ vbCRLF +_
		"<File kind=""2"" description="" ,C,B"" name=""g3.c"" line_num=""13""/>"+ vbCRLF +_
		"<CommittedFile  hash=""2533e64c0b9f38070319c0a31392e650""  revision=""ModuleX\1\01\B""/>"+ vbCRLF +_
		"<CommittedFile  hash=""ff41c5679ed8aa11688c0506f54bb28b""  revision=""ModuleX\2\01\C""/>"+ vbCRLF


	'// Set up
	del  "_work"
	copy  "Files\1\*", "_work"
	CreateFile  "_work\ModuleX\Target7\g1.c",     "X\1\B\02+04"  '// Emulate to Updated Commit
	CreateFile  "_work\ModuleX\Target8\sub\g1.c", "X\1\B\02+04"
	CreateFile  "_work\ModuleX\Target9\g2.c",     "X\1\B\02"  '// Emulate to Update
	CreateFile  "_work\ModuleX\Target7\sub\g3.c", "X\2\B\02"
	CreateFile  "_work\ModuleX\Target8\g3.c",     "X\2\B\02"

	If not is_prompt Then

		'// Test Main
		Set  sync = new SyncFilesT_Class
		sync.Run  "_work\21_SyncFilesT_Setting.xml", "_work\_out.xml", "ModuleX"
		sync.SaveHTML  "_work\_out.html",  g_vbslib_ver_folder +"tools\SyncFilesT_Template.html"
		tags = sync.GetAllCommitTags()

		'// Check
		AssertFC  "_work\_out.xml",  "Files\1\23_SyncFilesT_Out.xml"
		AssertFC  "_work\_out.html", "Files\1\23_SyncFilesT_Out.html"
			'// ModuleX\2\00\A の <CommittedFile> は、出力しない
		Assert  tags = commit_tags_answer
	Else
		'// Test Main
		RunProg  "cscript  //nologo  """+ prompt_vbs +"""  SyncFilesT  ""_work\21_SyncFilesT_Setting.xml"""+ _
			"  SaveForTest  ""_work\_info.xml""  /silent  Exit", ""
		Set root = LoadXML( "_work\_info.xml", Empty )

		'// Check
		AssertFC  root.getAttribute( "out_xml_path" ),  "Files\1\23_SyncFilesT_Out.xml"
		AssertFC  root.getAttribute( "out_html_path" ), "Files\1\23_SyncFilesT_Out.html"

		'// Clean
		del  root.getAttribute( "out_xml_path" )
		del  root.getAttribute( "out_html_path" )
	End If

	'// Clean
	del  "_work"

	End If : section.End_
	Next


	Pass
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_2
'***********************************************************************
Sub  T_SyncFilesT_2( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )


	'//===========================================================
	If section.Start( "T_SyncFilesT_2_SkipObj" ) Then

	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()

	'// Set up
	copy  "Files\2\*", "_work"

	'// Test Main
	Set  sync = new SyncFilesT_Class
	sync.Run  "_work\11_SyncFilesT_Setting.xml", "_work\_out.xml", "ModuleX"
	sync.SaveHTML  "_work\_out.html",  g_vbslib_ver_folder +"tools\SyncFilesT_Template.html"

	'// Check
	AssertFC  "_work\_out.xml",  "Files\2\13_SyncFilesT_Out.xml"
	AssertFC  "_work\_out.html", "Files\2\13_SyncFilesT_Out.html"

	'// Clean
	del  "_work"

	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_4_DiffRevision
'***********************************************************************
Sub  T_SyncFilesT_4_DiffRevision( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )


	'//===========================================================
	If section.Start( "T_SyncFilesT_4_DiffRevision" ) Then

	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()

	'// Set up
	copy  "Files\4_DiffRevision\*", "_work"

	'// Test Main
	Set  sync = new SyncFilesT_Class
	sync.Run  "_work\21_SyncFilesT_Setting.xml", "_work\_out.xml", "ModuleX"
	sync.SaveHTML  "_work\_out.html",  g_vbslib_ver_folder +"tools\SyncFilesT_Template.html"

	'// Check
	AssertFC  "_work\_out.html", "Files\4_DiffRevision\23_SyncFilesT_Out.html"

	'// Clean
	del  "_work"

	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_Create
'***********************************************************************
Sub  T_SyncFilesT_Create( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )


	'//===========================================================
	For Each  is_prompt  In  Array( False, True )
	If section.Start( "T_SyncFilesT_CreateFirst_"+ GetEchoStr( is_prompt ) ) Then

	'// Set up
	setting_path = "Files\1\_SyncFilesT_ModuleX.xml"
	Set w_=AppKey.NewWritable( Array( setting_path ) ).Enable()
	del  setting_path

	'// Test Main
	If not  is_prompt Then
		SyncFilesT_Class_createFirstSetting  "Files\1\ModuleX",  Empty
	Else
		RunProg  "cscript  //nologo  """+ prompt_vbs +"""  SyncFilesT_new  ""Files\1\ModuleX""  /silent", ""
	End If

	'// Check
	AssertFC  setting_path, "Files\1\FirstSetting_Answer.xml"

	'// Clean
	del  setting_path

	End If : section.End_
	Next


	Pass
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_Check
'***********************************************************************
Sub  T_SyncFilesT_Check( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()
	Set section = new SectionTree
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )


	'//===========================================================
	For Each  is_prompt  In  Array( False, True )
	If section.Start( "T_SyncFilesT_ScanModified_"+ GetEchoStr( is_prompt ) ) Then

	If not is_prompt Then

		'// Test Main
		Set  syncs = new_SyncFilesT_Class_Array( "Files\3_SyncX\*_SyncFilesT_Setting.xml" )

		'// Check
		Assert  syncs.Count = 2
		Assert  syncs(0).SettingPath = GetFullPath( "Files\3_SyncX\11_SyncFilesT_Setting.xml", Empty )
		Assert  syncs(0).ModifiedCount = 0
		Assert  syncs(1).SettingPath = GetFullPath( "Files\3_SyncX\21_SyncFilesT_Setting.xml", Empty )
		Assert  syncs(1).ModifiedCount = 2
	Else
		'// Set up
		del  "_work\_out.txt"

		'// Test Main
		RunProg  "cscript  //nologo  """+ prompt_vbs +"""  SyncFilesT  """+ _
			"Files\3_SyncX\*_SyncFilesT_Setting.xml""  /silent", _
			"_work\_out.txt"

		'// Check
		AssertFC  "_work\_out.txt", "Files\T_SyncFilesT_ScanModified.txt"

		'// Clean
		del  "_work"
	End If

	End If : section.End_
	Next


	'//===========================================================
	'// 以下の仕様は、採用されない可能性があります。
	If False Then
	For Each  is_prompt  In  Array( False, True )
	If section.Start( "T_SyncFilesT_CheckWithPath_"+ GetEchoStr( is_prompt ) ) Then

	'// Set up
	del  "_work"
	copy  "Files\1\21_SyncFilesT_Setting.xml", "_work"


	'// Test Main
	Set  sync = new SyncFilesT_Class
		Transpose : For i=0 To 1 : If i=1 Then
	Set  sync.OverwrittenModulePaths = t_over
		Else ' Transpose
		Set t_over = CreateObject( "Scripting.Dictionary" )
		t_over( "ModuleX\Target6" ) = "..\Files\1\ModuleX\Target6"
		t_over( "ModuleX\Target7" ) = "..\Files\1\ModuleX\Target7"
		t_over( "ModuleX\Target8" ) = "..\Files\1\ModuleX\Target8"
		t_over( "ModuleX\Target9" ) = "..\Files\1\ModuleX\Target9"
		Transpose : End If : Next

	sync.Run  "_work\21_SyncFilesT_Setting.xml", Empty, Empty
	sync.Check  Empty


	'// Check
	AssertFC  "_work\Log.txt", "_work\Check_LogAnswer.txt"

	'// Clean
	del  "_work"

	End If : section.End_
	Next
	End If

	Pass
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_4way
'***********************************************************************
Sub  T_SyncFilesT_4way( Opt, AppKey )
	setting_path = "Files\3_SyncX\21_SyncFilesT_Setting.xml"
	Set w_=AppKey.NewWritable( Array( setting_path, "ArgsLog.txt" ) ).Enable()

	'// Set up
	set_input  Replace( "1.2.9.",  ".",  g_CUI.m_Auto_KeyEnter )
	SetVar  "Setting_getDiffCmdLine", "ArgsLog"
	del  "ArgsLog.txt"

	Set  sync = new SyncFilesT_Class
	sync.Run  setting_path, Empty, Empty

	'// Test Main
	sync.StartDiffTool  "11", 1, 2, Empty

	'// Check
	AssertFC  "ArgsLog.txt", "Files\ArgsLog_4way.txt"

	'// Clean
	del  "ArgsLog.txt"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_Except
'***********************************************************************
Sub  T_SyncFilesT_Except( Opt, AppKey )
	setting_path = "Files\5_Except\SyncFilesT_Setting.xml"
	Set w_=AppKey.NewWritable( Array( setting_path,  "_work" ) ).Enable()

	'// Set up
	del  "_work"

	'// Test Main
	Set  sync = new SyncFilesT_Class
	sync.Run  setting_path,  "_work\_out1.xml",  Empty
	sync.SaveHTML  "_work\_out2.html",  "Files\5_Except\Template.html"

	'// Check
	AssertFC  "_work\_out1.xml",  "Files\5_Except\out_answer.xml"

	'// Clean
	del  "_work"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_ui
'***********************************************************************
Sub  T_SyncFilesT_ui( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	del  "_work"
	copy  "Files\0\*", "_work"

	Set parameters = new_ArrayClass( g_InputCommand_Args )
	If parameters.Count >= 1 Then _
		parameters.Remove  0, 1  '// Remove special command name
	parameters = CmdLineFromStr( parameters.Items )
	set_input  ""


	start  "cscript //nologo  """+ prompt_vbs +"""  SyncFilesT  ""_work\SyncFilesT_ModuleX.xml""  "+ _
		parameters +" /g_debu_g:1"


	echo  "パラメーターの例： 2 1 3"
	echo  "このパラメーターは、2) g3.c ファイルの 1. TargetA 版と 3. TargetC 版を比較する Diff ツールを起動します。"
	echo  "続行すると、_work フォルダーを削除します。"
	Pause
	del  "_work"
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_ui2
'*    2 targets.
'***********************************************************************
Sub  T_SyncFilesT_ui2( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	del  "_work"
	copy  "Files\0-2\*", "_work"

	Set parameters = new_ArrayClass( g_InputCommand_Args )
	If parameters.Count >= 1 Then _
		parameters.Remove  0, 1  '// Remove special command name
	parameters = CmdLineFromStr( parameters.Items )
	set_input  ""


	start  "cscript //nologo  """+ prompt_vbs +"""  SyncFilesT  ""_work\SyncFilesT_ModuleX.xml.synct""  "+ _
		parameters +" /g_debu_g:1"


	echo  "パラメーターの例： 1 2"
	echo  "この 1 は、1) g1.c ファイルを比較する Diff ツールを起動します。"
	echo  "この 2 は、2) g2.c ファイルを比較する Diff ツールを起動します。"
	echo  "続行すると、_work フォルダーを削除します。"
	Pause
	del  "_work"
End Sub


 
'***********************************************************************
'* Function: T_SyncFilesT_ui_old
'***********************************************************************
Sub  T_SyncFilesT_ui_old( Opt, AppKey )  '// TODO:
	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	copy  "Files\1\*", "_work"

	Set parameters = new_ArrayClass( g_InputCommand_Args )
	If parameters.Count >= 1 Then _
		parameters.Remove  0, 1  '// Remove special command name
	parameters = CmdLineFromStr( parameters.Items )
	set_input  ""


	start  "cscript //nologo  """+ prompt_vbs +"""  SyncFilesT  ""_work\21_SyncFilesT_Setting.xml""  "+ _
		parameters +" /g_debu_g:1"


	echo  "パラメーターの例： 4 1 3 4"
	echo  "続行すると、_work フォルダーを削除します。"
	Pause
	del  "_work"
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


 
