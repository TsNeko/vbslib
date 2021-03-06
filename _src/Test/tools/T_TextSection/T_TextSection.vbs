Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_TextSectionCut",_
			"2","T_TextSectionPickUp",_
			"3","T_ReadTextSections",_
			"4","T_CreateFromTextSections",_
			"5","T_MakeTxScFile",_
			"6","T_TextMix",_
			"7","T_TextShrink",_
			"8","T_ConvertDCF",_
			"9","T_MakeCrossedOldSections" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_TextSectionCut] >>> 
'********************************************************************************
Sub  T_TextSectionCut( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( "_work" ).Enable()

	For Each  is_set_last_separator  In Array( False, True )
	For Each  cut_section  In Array( "Section1", "Section2", "Section3", "Section4" )

		'// Set up
		copy  "files\T_TextSection1.txt", "_work"
		If is_set_last_separator Then
			OpenForWrite( "_work\T_TextSection1.txt", c.Append ).WriteLine  " "
		End If


		'// Test Main
		Set file = OpenForWriteTextSection( "_work\T_TextSection1.txt", Empty, Empty )
		file.Cut  cut_section
		file = Empty


		'// Check
		Select Case  cut_section
			Case  "Section1" : answer_file_name = "T_TextSection1_cut1_ans.txt"
			Case  "Section2" : answer_file_name = "T_TextSection1_cut2_ans.txt"
			Case  "Section3" : answer_file_name = "T_TextSection1_cut3_ans.txt"
			Case  "Section4" : answer_file_name = "T_TextSection1_cut4_ans.txt"
			Case Else : Error
		End Select

		copy_ren  "files\"+ answer_file_name, "_work\answer.txt"
		If is_set_last_separator  and  cut_section <> "Section4" Then
			OpenForWrite( "_work\answer.txt", c.Append ).WriteLine  " "
		End If

		AssertFC  "_work\T_TextSection1.txt", "_work\answer.txt"


		'// Clean
		del  "_work"
	Next
	Next


	'// SourcePath, DestinationPath引数のテスト

	'// Set up
	copy  "files\T_TextSection1.txt", "_work"

	'// Test Main
	Set file = OpenForWriteTextSection( "_work\T_TextSection1.txt", _
		"_work\T_TextSection1_out.txt", Empty )
	file.Cut  "Section1"
	file = Empty

	'// Check
	AssertFC  "_work\T_TextSection1_out.txt", "files\T_TextSection1_cut1_ans.txt"

	'// Clean
	del  "_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TextSectionPickUp] >>> 
'********************************************************************************
Sub  T_TextSectionPickUp( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( "_work" ).Enable()

	For Each  is_set_last_separator  In Array( False, True )
	For Each  cut_section  In Array( "Section1", "Section2", "Section3", "Section4" )

		'// Set up
		copy  "files\T_TextSection1.txt", "_work"
		If is_set_last_separator Then
			OpenForWrite( "_work\T_TextSection1.txt", c.Append ).WriteLine  " "
		End If


		'// Test Main
		Set file = OpenForWriteTextSection( "_work\T_TextSection1.txt", Empty, Empty )
		For Each  section  In Array( "Section1", "Section2", "Section3", "Section4" )
			If section <> cut_section Then
				file.PickUp  section
			End If
		Next
		file = Empty


		'// Check
		Select Case  cut_section
			Case  "Section1" : answer_file_name = "T_TextSection1_cut1_ans.txt"
			Case  "Section2" : answer_file_name = "T_TextSection1_cut2_ans.txt"
			Case  "Section3" : answer_file_name = "T_TextSection1_cut3_ans.txt"
			Case  "Section4" : answer_file_name = "T_TextSection1_cut4_ans.txt"
			Case Else : Error
		End Select

		copy_ren  "files\"+ answer_file_name, "_work\answer.txt"
		If is_set_last_separator  and  cut_section <> "Section4" Then
			OpenForWrite( "_work\answer.txt", c.Append ).WriteLine  " "
		End If

		AssertFC  "_work\T_TextSection1.txt", "_work\answer.txt"


		'// Clean
		del  "_work"
	Next
	Next


	'//===========================================================
	'// SourcePath, DestinationPath引数のテスト

	'// Set up
	copy  "files\T_TextSection1.txt", "_work"

	'// Test Main
	Set file = OpenForWriteTextSection( "_work\T_TextSection1.txt", _
		"_work\T_TextSection1_out.txt", Empty )
	file.PickUp  "Section2"
	file.PickUp  "Section3"
	file.PickUp  "Section4"
	file = Empty

	'// Check
	AssertFC  "_work\T_TextSection1_out.txt", "files\T_TextSection1_cut1_ans.txt"

	'// Clean
	del  "_work"


	'//===========================================================
	'// 同じセクション区切り記号の２つ目のセクション

	'// Set up
	copy  "files\T_TextSection2.txt", "_work"

	'// Test Main
	Set file = OpenForWriteTextSection( "_work\T_TextSection2.txt", Empty, Empty )
	file.PickUp  "Section2"
	file.PickUp  "Section5"
	file.PickUp  "Section6"
	file = Empty

	'// Check
	AssertFC  "_work\T_TextSection2.txt", "files\T_TextSection2_PickUp2_5_6.txt"

	'// Clean
	del  "_work"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ReadTextSections] >>> 
'*************************************************************************
Sub  T_ReadTextSections( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_ReadTextSections_2"

	If section.Start( "T_ReadTextSections_1" ) Then

	'// Set up
	del  "_work"
	path = "Files\SettingA.xml"
	Set xml_root = LoadXML( path, Empty )

	'// Test Main
	text = ReadTextSections( xml_root, "/MixedText[@id='mixed_1']", path, Empty, Empty )

	'// Check
	CreateFile  "_work\out.txt", text
	AssertFC  "_work\out.txt", "files\SettingA_answer.txt"

	'// Clean
	del  "_work"

	End If : section.End_


	If section.Start( "T_ReadTextSections_1_Line" ) Then

	'// Set up
	del  "_work"
	path = "Files\SettingA_L.xml"
	Set xml_root = LoadXML( path, Empty )

	'// Test Main
	text = ReadTextSections( xml_root, "/MixedText[@id='mixed_1']", path, Empty, Empty )

	'// Check
	CreateFile  "_work\out.txt", text
	AssertFC  "_work\out.txt", "files\SettingA_answer.txt"

	'// Clean
	del  "_work"

	End If : section.End_


	If section.Start( "T_ReadTextSections_1_OverVaraible" ) Then

	'// Set up
	del  "_work"
	path = "Files\SettingA.xml"
	Set xml_root = LoadXML( path, Empty )
	Set g = new LazyDictionaryClass
	g("${Var}") = "File2.txt"

	'// Test Main
	text = ReadTextSections( xml_root, "/MixedText[@id='mixed_1']", path, g, Empty )

	'// Check
	CreateFile  "_work\out.txt", text
	AssertFC  "_work\out.txt", "files\SettingA_OverVariable_answer.txt"

	'// Clean
	del  "_work"

	End If : section.End_


	If section.Start( "T_ReadTextSections_2" ) Then


	'// Set up
	del  "_work"
	Set linker = new LinkedXMLs
	linker.XmlTagNamesHavingIdName = Array( "MixedText" )

	xml_path = "files\SettingB.xml"
	Set xml_root = LoadXML( xml_path, Empty )


	'// Test Main
	linker.StartNavigation  xml_path, xml_root
	Set mixed_text_tag = linker.GetLinkTargetNode( xml_root.getAttribute( "mixed_text" ) )
	text = ReadTextSections( mixed_text_tag, ".", linker.TargetXmlPath, Empty, Empty )
	linker.EndNavigation


	'// Check
	CreateFile  "_work\out.txt", text
	AssertFC  "_work\out.txt", "files\SettingA_answer.txt"


	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_CreateFromTextSections] >>> 
'*************************************************************************
Sub  T_CreateFromTextSections( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_CreateFromTextSections_NoSection"


	'//===========================================================
	If section.Start( "T_CreateFromTextSections_1" ) Then

	'// Set up
	del  "_work"
	path = "Files\SettingA.xml"
	Set xml_root = LoadXML( path, Empty )

	'// Test Main
	CreateFromTextSections  "Files\SettingA.xml", Empty, "_work\out.txt", "/MixedText[@id='mixed_1']", Empty

	'// Check
	AssertFC  "_work\out.txt", "files\SettingA_answer.txt"

	'// Test Main
	CreateFromTextSections  "Files\SettingA.xml", xml_root, "_work\out.txt", "#mixed_1", Empty

	'// Check
	AssertFC  "_work\out.txt", "files\SettingA_answer.txt"

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_CreateFromTextSections_All" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	CreateFromTextSections  "Files\SettingA_C.xml", Empty, Empty, Empty, Empty

	'// Check
	AssertFC  "_work\out.txt", "files\SettingA_answer.txt"

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_CreateFromTextSections_NoSection" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	CreateFromTextSections  "Files\SettingA_N.xml", Empty, Empty, Empty, get_ToolsLibConsts().DeleteIfNoSection

	'// Check
	Assert  not exist( "_work\out.txt" )

	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_MakeTxScFile] >>> 
'*************************************************************************
Sub  T_MakeTxScFile( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_ReadTextSections_2"


	'//===========================================================
	If section.Start( "T_MakeTxScFile_1" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_TxSc\*", "_work"
	CreateFile  "_work\_txsc\README.txt", ".txsc file is TextSectionIndexFile."

	'// Test Main
	MakeTextSectionIndexFile  "_work\Library_NaturalDocsC1.c", "NaturalDocs", "C_Type", Empty, Empty

	'// Check
	AssertFC  "_work\Library_NaturalDocsC1.c.txsc", "Files\T_TxSc_Answer\Library_NaturalDocsC1.c.txsc"

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MakeTxScFile_2" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_TxSc\*", "_work"

	'// Test Main
	MakeTextSectionIndexFile  "_work\*.c", "NaturalDocs", "C_Type", Empty, Empty

	'// Check
	AssertFC  "_work\Library_NaturalDocsC1.c.txsc",     "Files\T_TxSc_Answer\Library_NaturalDocsC1.c.txsc"
	AssertFC  "_work\Sub\Library_NaturalDocsC2.c.txsc", "Files\T_TxSc_Answer\Sub\Library_NaturalDocsC2.c.txsc"

	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_TextShrink] >>> 
'*************************************************************************
Sub  T_TextShrink( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_TextShrink_Nest"
	Set g1 = new LazyDictionaryClass
	Set g2 = new LazyDictionaryClass

	checking_files_1 = Array( _
		"${_txsc}\library.c.txsc", _
		"${_txsc}\not_used.c.txsc", _
		"${_txsc}\sub\library2.c.txsc", _
		"${_txsc}\sub\library2.h.txsc", _
		"_setup_generating\Sections.xml" )
	checking_files_2 = Array( _
		"${_shrinked}\library.c", _
		"${_shrinked}\sub\library2.c", _
		"${_shrinked}\sub\library2.h" )


	'//===========================================================
	If section.Start( "T_TextShrink_1" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_TextShrink\*", "_work"

	'// Test Main
	DoTextShrink  "_work\Shrink.txmx.xml", Empty

	'// Check
	g1("${_txsc}") = "_txsc"
	g1("${_shrinked}") = "_shrinked"
	g2("${_txsc}") = "_txsc"
	g2("${_shrinked}") = "_shrinked"
	For Each  step_path  In  checking_files_1
		AssertFC  "_work\"+ g1( step_path ),  "Files\T_TextShrink_Answer\"+ g2( step_path )
	Next
	For Each  step_path  In  checking_files_2
		AssertFC  "_work\"+ g1( step_path ),  "Files\T_TextShrink_Answer\"+ g2( step_path )
	Next
	Assert  not exist( "_work\"+ g1("${_shrinked}\not_used.c") )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_TextShrink_Nest" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_TextShrink\*", "_work"
	move  "_work\LibraryFolder", "_work\MainFolder"

	Set rep = OpenForReplace( "_work\Shrink.txmx.xml", Empty )
	rep.Replace  "LibraryFolder", "MainFolder\LibraryFolder"
	rep.Replace  "shrinked_path=""_shrinked""  ", ""
	rep = Empty

	'// Test Main
	DoTextShrink  "_work\Shrink.txmx.xml", Empty

	'// Check
	g1("${_txsc}") = "_txsc"
	g1("${_shrinked}") = "MainFolder\LibraryFolder"
	g2("${_txsc}") = "_txsc"
	g2("${_shrinked}") = "_shrinked"
	For Each  step_path  In  checking_files_2
		AssertFC  "_work\"+ g1( step_path ),  "Files\T_TextShrink_Answer\"+ g2( step_path )
	Next

	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_TextMix] >>> 
'*************************************************************************
Sub  T_TextMix( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_TextMix_Library"


	'//===========================================================
	If section.Start( "T_TextMix_Library" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_TxSc\*", "_work"

	'// Test Main
	DoTextMix  "_work\Project.txmx.xml", Empty

	'// Check
	For Each  step_path  In  Array( _
			"Library_NaturalDocsC1.c.txsc", _
			"Library_NaturalDocsC1.h.txsc", _
			"Sub\Library_NaturalDocsC2.c.txsc" )
		AssertFC  "_work\_txsc\"+ step_path,  "Files\T_TxSc_Answer\_txsc\"+ step_path
	Next

	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'*************************************************************************
'  <<< [DoTextMix] >>> 
'*************************************************************************
Sub  DoTextMix( in_TxMxFilePath, in_Option )
	echo  ">DoTextMix  """+ in_TxMxFilePath +""""

	Set txmx = new TxMxClass
	txmx.ReadSettingTree  in_TxMxFilePath


	'// "MakeTextSectionIndexFile"
	For Each  source  In  txmx.AllSources.Items
		MakeTextSectionIndexFile  source.FilePath, "NaturalDocs", source.FileType, _
			source.BasePath, source.CachePath
	Next


	'// "ListUpUsingTxMxKeywords"
	Set txsc_paths = new PathDictionaryClass
	For Each  source  In  txmx.AllSources.Items
		Set txsc_paths( source.CachePath ) = txmx
	Next

	Set caller_paths = new PathDictionaryClass
	For Each  caller_path  In  txmx.Project.CallerFile.Items
		Set caller_paths( caller_path ) = txmx
	Next

	ListUpUsingTxMxKeywords  txsc_paths,  txmx.Project.UseSymbols.Items,  caller_paths,  used_symbols
	Set  txmx.Project.UsedSymbols = used_symbols


	'// "MakeMixedSectionsFile"
	txmx.ReadTxScFile  txsc_paths
	txmx.Project.MakeMixedSectionsFile  txmx


	'// Create File
	For Each  file  In  txmx.Project.CreateFiles.Items
		echo  "("+ file.FileType +") "+ file.FilePath
		'// Not implemented yet
	Next
End Sub


 
'********************************************************************************
'  <<< [T_ConvertDCF] >>> 
'********************************************************************************
Sub  T_ConvertDCF( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'// SetStartSectionTree  "T_ConvertDCF_sth"

	If section.Start( "T_ConvertDCF_1" ) Then

	'// Set up
	del  "_work"
	copy  "Files\T_ConvertDCF\*", "_work"

	For Each  t  In DicTable( Array( _
			"Input",                "Output",       "Answer",  Empty, _
			"_work\NaturalDocs.c",  "_work\_out.c",  "_work\Doxygen.c", _
			"_work\NaturalDocs2.c", "_work\_out2.c", "_work\Doxygen2.c" ))

		'// Test Main
		ConvertDocumetCommentFormat  t("Input"), t("Output"), _
			"NaturalDocs", "_work\Doxygen Format.xml"

		'// Check
		AssertFC  t("Output"), t("Answer")
	Next

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ConvertDCF_sth" ) Then

	sth_path = SearchParent( "vbslib Prompt.vbs" )

	'// Set up
	del  "_work"
	copy  "Files\T_ConvertDCF\*", "_work"

	'// Test Main
	RunProg  "cscript """+ sth_path +"""  ConvertDocumetCommentFormat  ""_work\NaturalDocs.c""  ""_work\_out.c"" "+ _
		""""" """"", ""

	'// Check
	AssertFC  "_work\_out.c", "_work\Doxygen.c"

	'// Clean
	del  "_work"

	End If : section.End_


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_MakeCrossedOldSections] >>> 
'********************************************************************************
Sub  T_MakeCrossedOldSections( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_MakeCrossedOldSections_PathDictionary"


	'//===========================================================
	If section.Start( "T_MakeCrossedOldSections_1" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	MakeCrossedOldSections  "_work\_out", "Files\T_CrossedOld\1\New", "Files\T_CrossedOld\1\Old", _
		"_work\_txsc\New", "_work\_txsc\Old", Empty

	'// Check
	Assert  fc( "_work\_out", "Files\T_CrossedOld\1\Answer" )
		'// End of File: は、MakeCrossedOldSections の中の ConnectInTextSectionIndexFile で
		'// 接続されるが、入力も出力も最後だけに存在するケース以外は、未対応。

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_MakeCrossedOldSections_PathDictionary" ) Then

	'// Set up
	del  "_work"

	Set paths = new PathDictionaryClass
	paths.BasePath = "Files\T_CrossedOld\PathDic\New"
	Set paths( "s\2.txt" ) = Nothing

	'// Test Main
	MakeCrossedOldSections  "_work\_out", paths, "Files\T_CrossedOld\PathDic\Old", _
		"_work\_txsc\New", "_work\_txsc\Old", Empty

	'// Check
	Assert  fc( "_work\_out", "Files\T_CrossedOld\PathDic\Answer" )
		'// End of File: は、MakeCrossedOldSections の中の ConnectInTextSectionIndexFile で
		'// 接続されるが、入力も出力も最後だけに存在するケース以外は、未対応。

	'// Clean
	del  "_work"

	End If : section.End_

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


 
