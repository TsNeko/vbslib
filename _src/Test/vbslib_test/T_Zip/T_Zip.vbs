Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_unzip",_
			"2","T_unzip2",_
			"3","T_unzip_sth",_
			"4","T_BadZip",_
			"5","T_zip2",_
			"6","T_DownloadAndExtractFileIn7z" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_unzip] >>> 
'********************************************************************************
Sub  T_unzip( Opt, AppKey )
	Set c = g_VBS_Lib
	Dim w_:Set w_=AppKey.NewWritable( Array( _
		"sample1", "sample11", "sample11_r", "sample2" ) ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_unzip_1_CheckFolderExists"


	'//===========================================================
	If section.Start( "T_unzip_1" ) Then

	'// set up
	del  "sample1"

	'// Test Main
	unzip  "sample1.zip", "sample1", Empty

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"

	'// clean
	del  "sample1"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_1_Empty" ) Then

	'// set up
	del  "sample1"

	'// Test Main
	unzip  "sample1.zip", Empty, Empty

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"

	'// clean
	del  "sample1"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_11" ) Then

	'// set up
	del  "sample11"

	'// Test Main
	unzip  "sample11.zip", "sample11", Empty

	'// check
	Assert  ReadFile( "sample11\file1.txt" ) = "T_Zip"

	'// clean
	del  "sample11"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_11_ren" ) Then

	'// set up
	del  "sample11_r"

	'// Test Main
	unzip  "sample11.zip", "sample11_r", Empty

	'// check
	Assert  ReadFile( "sample11_r\file1.txt" ) = "T_Zip"

	'// clean
	del  "sample11_r"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_2" ) Then

	'// set up
	del  "sample2"

	'// Test Main
	unzip  "sample2.zip", "sample2", Empty

	'// check
	Assert  ReadFile( "sample2\file1.txt" ) = "T_Zip"
	Assert  ReadFile( "sample2\file2.txt" ) = "T_Zip2"

	'// clean
	del  "sample2"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_1_AfterDelete" ) Then

	'// set up
	del  "sample1"
	CreateFile  "sample1\file2.txt", "a"
	Assert  exist( "sample1\file2.txt" )

	'// Test Main
	unzip  "sample1.zip", Empty, F_AfterDelete

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"
	Assert  not exist( "sample1\file2.txt" )

	'// clean
	del  "sample1"

	'// set up
	del  "sample1"
	CreateFile  "sample1\file2.txt", "a"
	Assert  exist( "sample1\file2.txt" )

	'// Test Main
	unzip  "sample1.zip", Empty, True

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"
	Assert  not exist( "sample1\file2.txt" )

	'// clean
	del  "sample1"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_1_IfNotExist" ) Then

	'// set up
	del  "sample1"
	CreateFile  "sample1\file2.txt", "a"
	Assert  not exist( "sample1\file1.txt" )
	Assert      exist( "sample1\file2.txt" )

	'// Test Main
	unzip  "sample1.zip", Empty, F_IfNotExist

	'// check
	Assert  not exist( "sample1\file1.txt" )
	Assert      exist( "sample1\file2.txt" )

	'// clean
	del  "sample1"

	'// set up
	del  "sample1"
	CreateFile  "sample1\file2.txt", "a"
	Assert  not exist( "sample1\file1.txt" )
	Assert      exist( "sample1\file2.txt" )

	'// Test Main
	unzip  "sample1.zip", Empty, False

	'// check
	Assert  not exist( "sample1\file1.txt" )
	Assert      exist( "sample1\file2.txt" )

	'// clean
	del  "sample1"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_1_CheckFolderExists" ) Then

	'// Set up
	del  "sample1"
	del  "sample2"

	'// Test Main : Case of Not Exist
	unzip  "sample1.zip", "sample1", c.CheckFolderExists
	unzip  "sample2.zip", "sample2", c.CheckFolderExists

	'// Test Main : Case of Pass
	unzip  "sample1.zip", "sample1", c.CheckFolderExists
	unzip  "sample2.zip", "sample2", c.CheckFolderExists

	'// Set up
	CreateFile  "sample1\file1.txt", "Modified"
	del  "sample2\file2.txt"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		unzip  "sample1.zip", "sample1", c.CheckFolderExists

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '// Set "e2"
	echo    e2.desc
	Assert  e2.num <> 0

	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		unzip  "sample2.zip", "sample2", c.CheckFolderExists

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '// Set "e2"
	echo    e2.desc
	Assert  e2.num <> 0

	'// clean
	del  "sample1"
	del  "sample2"

	End If : section.End_

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
'  <<< [T_unzip_sth] >>> 
'********************************************************************************
Sub  T_unzip_sth( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "sample1", "sample2", _
		"sample1_old", "sample1_old2", "sample1_old3" ) ).Enable()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	Set section = new SectionTree
'//SetStartSectionTree  "T_unzip_sth_2"


	'// set up
	del  "sample1"
	del  "sample1_old"
	del  "sample1_old2"
	del  "sample1_old3"


	'//===========================================================
	If section.Start( "T_unzip_sth_1" ) Then

	'// set up
	del  "sample1"

	'// Test Main
	r= RunProg( "cscript //nologo  """+ prompt_vbs +"""  unzip  sample1.zip", "" )

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"


	'//===========================================================
	'// T_unzip_sth_1_over

	'// set up
	CreateFile  "sample1\file1.txt",  "T_Zip_old"

	'// Test Main
	r= RunProg( "cscript //nologo  """+ prompt_vbs +"""  unzip  sample1.zip", "" )
	CheckTestErrLevel  r

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"
	Assert  ReadFile( "sample1_old\file1.txt" ) = "T_Zip_old"


	'//===========================================================
	'// T_unzip_sth_1_over2

	'// set up
	CreateFile  "sample1\file1.txt",  "T_Zip_old2"

	'// Test Main
	r= RunProg( "cscript //nologo  """+ prompt_vbs +"""  unzip  sample1.zip", "" )
	CheckTestErrLevel  r

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"
	Assert  ReadFile( "sample1_old\file1.txt" ) = "T_Zip_old"
	Assert  ReadFile( "sample1_old2\file1.txt" ) = "T_Zip_old2"


	'//===========================================================
	'// T_unzip_sth_1_over3

	'// set up
	CreateFile  "sample1\file1.txt",  "T_Zip_old3"

	'// Test Main
	r= RunProg( "cscript //nologo  """+ prompt_vbs +"""  unzip  sample1.zip", "" )
	CheckTestErrLevel  r

	'// check
	Assert  ReadFile( "sample1\file1.txt" ) = "T_Zip"
	Assert  ReadFile( "sample1_old\file1.txt" ) = "T_Zip_old"
	Assert  ReadFile( "sample1_old2\file1.txt" ) = "T_Zip_old2"
	Assert  ReadFile( "sample1_old3\file1.txt" ) = "T_Zip_old3"

	'// clean
	del  "sample1"
	del  "sample1_old"
	del  "sample1_old2"
	del  "sample1_old3"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_unzip_sth_2" ) Then

	'// set up
	del  "sample1"

	'// Test Main
	r= RunProg( "cscript //nologo  """+ prompt_vbs +"""  unzip  sample2.zip", "" )

	'// check
	Assert  ReadFile( "sample2\file1.txt" ) = "T_Zip"

	End If : section.End_


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


 
'***********************************************************************
'* Function: T_DownloadAndExtractFileIn7z
'***********************************************************************
Sub  T_DownloadAndExtractFileIn7z( Opt, AppKey )
If g_is_vbslib_for_fast_user Then
	network_path = env("\\%USERDOMAIN%\T_Download")
	is_exist_network = g_fs.FolderExists( network_path )
	Set section = new SectionTree
'//SetStartSectionTree  ""

	test_cases = DicTable( Array( _
		"ServerPath",                      "Content",  "Option",  Empty, _
		"T_Download\1\FileA.txt",          "A",        "", _
		"T_Download\1\Sub\FileB.txt",      "B",        "", _
		"T_Download\1\FileA.txt",          "A",        "E", _
		"T_Download\0\FileA.txt",          Empty,      "", _
		network_path +"\1\FileA.txt",      "A",        "", _
		network_path +"\1\Sub\FileB.txt",  "B",        "", _
		network_path +"\0\FileA.txt",      Empty,      "", _
		"T_Download\2\FileA.txt",          Array( "Error", "T_Download\2\_Fragment.7z" ),  "" ))
	interrupted_file_path = GetFullPath( "T_Download\1\_Fragment.7z",  Empty )

	Set w_=AppKey.NewWritable( "_work" ).Enable()
	cache_path = GetTempPath( "Fragments" )
	del  cache_path
	For i=0 To UBound( g_Coverage_DownloadAndExtractFileIn7z )
		g_Coverage_DownloadAndExtractFileIn7z(i) = False
	Next


	For Each  case_name  In  Array( "Direct", "PreDownload" )
	If section.Start( "T_DownloadAndExtractFileIn7z_"+ case_name ) Then

		'// Set up
		del  "_work"
		del  cache_path


		'// Test Main
		Set downloader = new DownloadAndExtractFileIn7zClass

		If case_name = "PreDownload" Then
			For Each  t  In  test_cases
				If InStr( t("Option"), "E" ) >= 1 Then
					'// 前のダウンロードが中断されたことをエミュレートする
					downloader.WaitUntilCompletion
					downloader.DownloadThreads.Remove  interrupted_file_path
				End If

				downloader.DownloadStart  t("ServerPath")
			Next
		End If


		For Each  t  In  test_cases

			echo  t("ServerPath")

			If case_name = "Direct" Then
				If InStr( t("Option"), "E" ) >= 1 Then
					'// 前のダウンロードが中断されたことをエミュレートする
					downloader.WaitUntilCompletion
					downloader.DownloadThreads.Remove  interrupted_file_path
				End If
			End If

			is_error_test = False
			If IsArray( t("Content") ) Then
				Assert  t("Content")(0) = "Error"
				is_error_test = True
			End If
			If NOT is_exist_network  and  Left( t("ServerPath"), 2 ) = "\\" Then
				Skipped
			ElseIf NOT is_error_test Then


				'// Test Main
				local_path = downloader.GetLocalPath( t("ServerPath") )


				'// Check
				If IsEmpty( t("Content") ) Then
					Assert  IsEmpty( local_path )
				Else
					Assert  ReadFile( local_path ) = t("Content")
				End If

			Else : Assert  is_error_test

				'// Error Handling Test
				echo  vbCRLF+"Next is Error Test"
				If TryStart(e) Then  On Error Resume Next

					local_path = downloader.GetLocalPath( t("ServerPath") )

				If TryEnd Then  On Error GoTo 0
				e.CopyAndClear  e2  '// Set "e2"
				echo    e2.desc
				For i=1 To UBound( t("Content") )
					Assert  InStr( e2.desc, t("Content")(i) ) >= 1
				Next
				Assert  e2.num <> 0
			End If
			ec = Empty
		Next

		'// Clean
		del  "_work"
		del  cache_path
		downloader = Empty
	End If : section.End_
	Next

	'// Check
	For i=0 To UBound( g_Coverage_DownloadAndExtractFileIn7z )
		Assert  g_Coverage_DownloadAndExtractFileIn7z(i)
	Next

End If
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


 
