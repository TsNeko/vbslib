Sub  Main( Opt, AppKey )
g_Vers( "Moas_KeywordSubstitution" ) = True
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1", "T_ModuleAssort2_RunPrompt" ))
'//			"11","ModuleAssort2"
	InputCommand  o, Empty, Opt, AppKey
End Sub


Dim  g_is_vbslib_for_fast_user


 
'***********************************************************************
'* Function: T_ModuleAssort2_RunPrompt
'***********************************************************************
Sub  T_ModuleAssort2_RunPrompt( Opt, AppKey )
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	Set section = new SectionTree
'//SetStartSectionTree  "T_ModuleAssort2_EmptyFolder_01_02"

	'// Set read only
	SetReadOnlyAttribute  "1_Open", True
	SetReadOnlyAttribute  "2A_Fragment", True
	SetReadOnlyAttribute  "3_EmptyFolder", True


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Open" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_log.txt" ).Enable()
	del  "_log.txt"

	'// Test Main : プロジェクトを開く。
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"1_Open\Test.xml.proja  "+ _
		"      1_Open\ProjectA  4  6  "+ _
		"GoTo  ${ProjA}\A.txt  4  6  "+ _
		"GoTo  1_Open\ProjectA\NotFound.txt  4  0  6  0  "+ _
		"GoTo  1_Open\OutOfProjectA  """"  "+ _
		"Exit",  "_log.txt"

	'// Check
	AssertFC  "_log.txt",  "1_Open\LogAnswer_of_Open.txt"

	'// Clean
	del  "_log.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Open2" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( Array( "_log.txt",  "2A_Fragment\Masters\ModuleA_Copy\Work" ) ).Enable()
	del  "_log.txt"
	del  "2A_Fragment\Masters\ModuleA_Copy\Work"
	copy  "2A_Fragment\Masters\ModuleA_Copy\02\*",  "2A_Fragment\Masters\ModuleA_Copy\Work"

	'// Test Main : マスターズを開く。
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"2A_Fragment\Projects\Sub\Main.xml.proja  "+ _
		"      2A_Fragment\ProjectWork\Copy\A_Copy.txt  "+ _
		"GoTo  2A_Fragment\Masters\ModuleA\02\A.txt  4  6  "+ _
		"GoTo  ${Masters}\ModuleA_Copy\02  4  6  "+ _
		"GoTo  2A_Fragment\Masters\ModuleA_Copy\02\A_Copy.txt  4  0  6  "+ _
		"GoTo  2A_Fragment\Masters\ModuleA_Copy\01  """"  "+ _
		"GoTo  2A_Fragment\Masters\NotFound  """"  "+ _
		"GoTo  2A_Fragment\Masters\ModuleA_Copy\Work  4  5  6  "+ _
		"Exit",  "_log.txt"
			'// ProjectWork\Copy\A_Copy.txt = Set current project
			'// ModuleA\02\A.txt = File
			'// ModuleA_Copy\02 = Folder
			'// ModuleA_Copy\02\A_Copy.txt = in "_FullSet.txt"
			'// ModuleA_Copy\01 = Not Used Master
			'// NotFound = Not folder not file
			'// ModuleA_Copy\Work = Work Folder

	'// Check
	AssertFC  "_log.txt",  "2A_Fragment\LogAnswer_of_Open.txt"

	'// Clean
	del  "_log.txt"
	del  "2A_Fragment\Masters\ModuleA_Copy\Work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Open3" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( Array( "_log.txt",  "_ProjectWork" ) ).Enable()
	del  "_log.txt"
	del  "_ProjectWork"

	'// Test Main : フォルダー指定のチェックアウト
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"1_Open\Test.xml.proja  "+ _
		"      _ProjectWork  CheckOut  Project-A\01  """"", _
		"_log.txt"

	'// Check
	AssertFC  "_log.txt",  "1_Open\LogAnswer_of_Open3.txt"
	Assert  GetReadOnlyList( "_ProjectWork", Empty, Empty ) = 0

	'// Clean
	del  "_log.txt"
	del  "_ProjectWork"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Open4" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( Array( "_log.txt" ) ).Enable()
	del  "_log.txt"

	'// Test Main : モジュールがプロジェクトのサブ フォルダーだけにあるとき。
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"1_Open\Test.xml.proja  1_Open\ProjectC  "+ _
		"Exit",  "_log.txt"

	'// Check
	AssertFC  "_log.txt",  "1_Open\LogAnswer_of_Open4.txt"

	'// Clean
	del  "_log.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Open5" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( Array( "_log.txt" ) ).Enable()
	del  "_log.txt"

	'// Test Main : モジュール一覧
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"1_Open\Test.xml.proja  1_Open\ProjectB  Modules  1  2  """"  "+ _
		"Exit",  "_log.txt"

	'// Check
	AssertFC  "_log.txt",  "1_Open\LogAnswer_of_Open5.txt"

	'// Clean
	del  "_log.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Open6" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( Array( "_work", "_log.txt" ) ).Enable()
	del  "_log.txt"
	del  "_work"
	copy  "1_Open\ProjectC",        "_work"
	copy  "1_Open\Test.xml.proja",  "_work"
	copy  "1_Open\Masters",         "_work"
	SetReadOnlyAttribute  "_work", False
	del   "_work\ProjectC\A"

	'// Test Main : モジュールのフォルダーがプロジェクトにないとき。
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"_work\Test.xml.proja  _work\ProjectC  "+ _
		"GoTo  ${Masters}\ModuleA\02  4  6  0  "+ _
		"Exit",  "_log.txt"

	'// Check
	AssertFC  "_log.txt",  "1_Open\LogAnswer_of_Open6.txt"

	'// Clean
	del  "_work"
	del  "_log.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_CheckOut" ) Then
		'// ユーザーが入手したフォルダーにチェックアウトする。
		'// Check out to user input folder.

	'// Set up
	Set w_= AppKey.NewWritable( "_ProjectWork" ).Enable()
	del  "_ProjectWork"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"1_Open\Test.xml.proja  _ProjectWork  CheckOut  Project-B\02  Exit",  ""

	'// Check
	Assert  IsSameFolder( "_ProjectWork", "1_Open\ProjectB", c.EchoV_NotSame )
	Assert  GetReadOnlyList( "_ProjectWork", Empty, Empty ) = 0

	'// Clean
	del  "_ProjectWork"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_CheckOut_InProjectCache" ) Then
		'// Test of <ProjectCache> tag
		'// ProjectCache の中にある空のフォルダーなら、自動でチェックアウトします。

	'// Set up
	Set w_= AppKey.NewWritable( "_Project" ).Enable()
	del  "_Project"
	mkdir  "_Project\Project-B\02"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"1_Open\Test.xml.proja  _Project\Project-B\02  Exit",  ""

	'// Check
	Assert  IsSameFolder( "_Project\Project-B\02", "1_Open\ProjectB", c.EchoV_NotSame )

	'// Clean
	del  "_Project"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_CheckOut_ByMenu" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	del    "_work"
	copy   "1_Open\*", "_work"
	del    "_work\ProjectB"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"_work\Test.xml.proja  2  1  """"  Exit",  ""

	'// Check
	Assert  IsSameFolder( "_work\ProjectB", "1_Open\ProjectB", c.EchoV_NotSame )
	Assert  GetReadOnlyList( "_work\ProjectB", Empty, Empty ) = 0

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_CheckOut_Automatic" ) Then
		'// Not input project full name

	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	del    "_work"
	copy   "1_Open\*", "_work"
	del    "_work\ProjectB"
	mkdir  "_work\ProjectB"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"_work\Test.xml.proja  _work\ProjectB  CheckOut  """"  Exit",  ""

	'// Check
	Assert  IsSameFolder( "_work\ProjectB", "1_Open\ProjectB", c.EchoV_NotSame )
	Assert  GetReadOnlyList( "_work\ProjectB", Empty, Empty ) = 0

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_CheckOut_Error" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	del    "_work"
	copy   "2B_FragmentEx\2\*", "_work"
	del  "_work\Masters\ModuleA_Copy\01"
	del  "_work\Masters\ModuleNew\01"


    '// Error Handling Test
    echo  vbCRLF+"Next is Error Test"
    If TryStart(e) Then  On Error Resume Next

		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Main.xml.proja  _work\Project  CheckOut  Project\01  Exit",  "_work\log.txt"

    If TryEnd Then  On Error GoTo 0
    e.CopyAndClear  e2  '// Set "e2"
    echo    e2.desc
    Assert  e2.num <> 0

	'// Check
	AssertFC  "_work\log.txt",  "2B_FragmentEx\2\Answer\log.txt"

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	For Each  yes_no  In  Array( "Yes", "No" )  '// keyword_substitution
	If section.Start( "T_ModuleAssort2_MakePackage_"+ yes_no ) Then

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		Set d = new LazyDictionaryClass
		d("${KS}") = "2B_FragmentEx\3_KS"
		w_=Empty : Set w_= AppKey.NewWritable( Array( d("${KS}") ) ).Enable()
		unzip  d("${KS}.zip"),  d("${KS}"),  c.CheckSameIfExist
		Set files = Dict(Array( _
			d("${KS}\Masters_"+ yes_no +"\ModuleA\01\A.txt"),    W3CDTF( "2005-01-01T01:01:00+09:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleA\01\bin.bin"),  W3CDTF( "2005-01-02T01:01:00+09:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleA\01\svn.txt"),  W3CDTF( "2005-01-03T01:01:00+09:00" ) ))
		For Each  path  In  files.Keys
			SetReadOnlyAttribute  path, False  '// For next "SetDateLastModified"
		Next
		SetDateLastModified  files
		w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
		copy  d("${KS}\*"),  "_work"
		ren  "_work\Masters_"+ yes_no,  "_work\Masters"
		w_=Empty

		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Main_"+ yes_no +".xml.proja  _work\Release  MakePackage  Exit  Exit",  ""

		'// Check
		w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
		AssertFC  _
			"_work\Release\_Modules\MD5List.txt", _
			d("${KS}\ReleaseAnswer\Release"+ yes_no +"\_Modules\MD5List.txt")
		copy_ren _
			d("${KS}\ReleaseAnswer\Release"+ yes_no +"\_Modules\MD5List.txt"), _
			"_work\Release\_Modules\MD5List.txt"

		Assert  IsSameFolder( "_work\Release", d("${KS}\ReleaseAnswer\Release"+ yes_no ), c.EchoV_NotSame )
		w_=Empty

		'// Clean
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		w_=Empty : Set w_= AppKey.NewWritable( d("${KS}") ).Enable()
		del  d("${KS}")
		w_=Empty
	End If : section.End_
	Next


	'//===========================================================
	If section.Start( "T_ModuleAssort2_MakePackage_Patch" ) Then

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"

		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"7_Release\2\Project.xml.proja  _work\Package  MakePackage  Exit  Exit",  ""

		'// Check
		Assert  IsSameFolder( "_work\Package", "7_Release\2\PackageOfFullProjectAnswer", c.EchoV_NotSame )


		'// Set up
		Assert  not exist( "_work\Package\_Modules\ModuleA" )
		Assert  not exist( "_work\Package\_Modules\ModuleB" )

		'// Test Main
		Set ds = new CurDirStack
		cd  "_work\Package\_Modules"
		RunProg  "AssortAll.bat  /no_input",  ""
		ds = Empty

		'// Check
		Assert  IsSameFolder( "_work\Package\_Modules\ModuleA",  "7_Release\2\Masters\ModuleA",  Empty )
		Assert  IsSameFolder( "_work\Package\_Modules\ModuleB",  "7_Release\2\Masters\ModuleB",  Empty )

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Publish" ) Then

		'// Set up
		local_path = env( "%USERPROFILE%\Downloads\_ModuleAssortTest" )
		Set w_= AppKey.NewWritable( Array( "_work",  local_path ) ).Enable()
		del  "_work"
		copy  "7_Release\3_1_Publish\*",  "_work"
		copy_ren  "_work\PubBefore",  "_work\Pub"
		SetReadOnlyAttribute  "_work\Pub", True


		'// Test Main : Publish
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  ModuleAssort2  "+ _
			"_work\Masters\ForPublish.xml.proja  _work\Pub  Publish  y  Exit",  ""

		'// Check
		Assert  IsSameFolder( "_work\Pub",  "_work\PubExpected",  Empty )


		'// Set up
		del  local_path
		echo_line
		cache_root_path = GetTempPath( "Fragments" )
		del  cache_root_path

		'// Test Main : Download
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  ModuleAssort2  /ArgsLog  /EchoOff  "+ _
			"""""  Download  _work\Pub  "+ _
			"/MD5List:Modules\MD5List.txt  /Existence:Modules\ExistenceCache.txt  """+ _
			local_path +"""  y  "+ _
			"Projects\A  "+ _
			"Modules\ModuleA\01  "+ _
			"unknown  "+ _
			"""""",  "_work\_log.txt"

		'// Check
		Assert  IsSameFolder( env("%USERPROFILE%\Downloads\_ModuleAssortTest"), _
			"_work\DownloadExpected",  Empty )
		Assert  GetReadOnlyList( env("%USERPROFILE%\Downloads\_ModuleAssortTest"), Empty, Empty ) = 0
		AssertFC  "_work\_log.txt",  "7_Release\3_1_Publish\Answer\Download_1_Log.txt"

		'// Test Main : Other Path
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  ModuleAssort2  /ArgsLog  /EchoOff  "+ _
			"""""  Download  _work\Pub  "+ _
			"/MD5List:Modules\MD5List.txt  /Existence:Modules\ExistenceCache.txt  """+ _
			local_path +"""  y  "+ _
			"Projects\A\A.xml.proja  "+ _
			"Modules\ModuleA\01\_FullSet.txt  "+ _
			"unknown  "+ _
			"""""",  "_work\_log.txt"

		'// Check
		Assert  IsSameFolder( env("%USERPROFILE%\Downloads\_ModuleAssortTest"), _
			"_work\DownloadExpected",  Empty )
		Assert  GetReadOnlyList( env("%USERPROFILE%\Downloads\_ModuleAssortTest"), Empty, Empty ) = 0
		AssertFC  "_work\_log.txt",  "7_Release\3_1_Publish\Answer\Download_2_Log.txt"

		'// Clean
		del  "_work"
		del  local_path
		del  cache_root_path

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Defragment" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_ProjectWork" ).Enable()
	del    "_ProjectWork"
	mkdir  "_ProjectWork"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"2A_Fragment\Projects\Sub\Main.xml.proja  _ProjectWork  CheckOut  Project\01  Exit",  ""

	'// Check
	Assert  IsSameFolder( "_ProjectWork", "2A_Fragment\ProjectWork", c.EchoV_NotSame )
	Assert  GetReadOnlyList( "_ProjectWork", Empty, Empty ) = 0

	'// Clean
	del  "_ProjectWork"

	End If : section.End_


	'//===========================================================
	For Each  case_  In  Array( "", "_GoTo" )

		If section.Start( "T_ModuleAssort2_Assort"+ case_ ) Then

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "2A_Fragment\Masters\*",  "_work\Masters"
		OpenForReplace( "2A_Fragment\Projects\Sub\Main.xml.proja", "_work\Projects\Sub\Main.xml.proja" ).Replace _
			"value=""..\..\ProjectWork""",  "value=""..\..\..\2A_Fragment\ProjectWork"""
		SetReadOnlyAttribute  "_work\Masters",  False

		If case_ = "_GoTo" Then
			appended_command = " GoTo  2A_Fragment\ProjectWork\Copy\A_Copy.txt "
		Else
			appended_command = ""
		End If


		'// Test Main & Check : No Error
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Sub\Main.xml.proja  2A_Fragment\ProjectWork "+ appended_command +" Assort  y  Exit", _
			"_work\log.txt"


		'// Check
		read_only_count = _
			GetReadOnlyList( "_work\Masters\ModuleA\02", Empty, Empty ) + _
			GetReadOnlyList( "_work\Masters\ModuleA_Copy\02", Empty, Empty )
		file_count = _
			( UBound( ArrayFromWildcard( "_work\Masters\ModuleA\02" ).FilePaths ) + 1 ) + _
			( UBound( ArrayFromWildcard( "_work\Masters\ModuleA_Copy\02" ).FilePaths ) + 1 )

		Assert  InStr( ReadFile( "_work\log.txt" ), "警告の数 = 0" ) >= 1
		Assert  read_only_count = file_count

		'// Clean
		del  "_work"

		End If : section.End_
	Next


	'//===========================================================
	For Each  case_  In  Array( "WithoutWork", "WithoutWork_GoTo", "WithWork", "Remove" )

		If section.Start( "T_ModuleAssort2_Assort_"+ case_ ) Then

		'// WithoutWork = Work フォルダーを新規作成するとき
		'// WithoutWork_GoTo = Work フォルダーを新規作成するとき、カレント モジュールを移動して
		'// WithWork = Work フォルダーがすでにあるとき
		'// Remove =削除するファイルがあるとき

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"

		copy  "2A_Fragment\*",  "_work"
		SetReadOnlyAttribute  "_work", False
		If case_ <> "Remove" Then
			CreateFile  "_work\ProjectWork\A.txt",            "ModifiedA"
			CreateFile  "_work\ProjectWork\Copy\A_Copy.txt",  "ModifiedA"
		Else
			del  "_work\ProjectWork\A.txt"
			del  "_work\ProjectWork\Copy\A_Copy.txt"
		End If
		If case_ = "WithWork" Then
			mkdir       "_work\Masters\ModuleA\Work"
			del         "_work\Masters\ModuleA\Work\*"
			CreateFile  "_work\Masters\ModuleA\Work\A.txt", ""
			mkdir       "_work\Masters\ModuleA_Copy\Work"
			del         "_work\Masters\ModuleA_Copy\Work\*"
			copy        "_work\Masters\ModuleA_Copy\02\_FullSet.txt",  "_work\Masters\ModuleA_Copy\Work"
		End If
		SetReadOnlyAttribute  "_work", True

		If case_ = "WithoutWork_GoTo" Then
			appended_command = " GoTo  _work\ProjectWork\Copy\A_Copy.txt "
		Else
			appended_command = ""
		End If


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Sub\Main.xml.proja  _work\ProjectWork "+ appended_command +" Assort  "+ _
			"1  1  99  2  9  1  Exit", _
			"_work\log.txt"


		'// Check
		If case_ <> "Remove" Then
			Assert  InStr( ReadFile( "_work\log.txt" ), "警告の数 = 2" ) >= 1
		End If
		If case_ = "WithWork" Then
			Assert  IsSameBinaryFile( "_work\Masters\ModuleA\Work\A.txt", _
				"_work\ProjectWork\A.txt",  Empty )
			Assert  IsSameBinaryFile( "_work\Masters\ModuleA_Copy\Work\A_Copy.txt", _
				"_work\ProjectWork\Copy\A_Copy.txt",  Empty )
			AssertFC  "_work\log.txt",  "2A_Fragment\LogAnswer_of_WithWork.txt"
		End If
		If case_ = "WithoutWork" Then
			AssertFC  "_work\log.txt",  "2A_Fragment\LogAnswer_of_Assort.txt"
		End If


		'// 2nd assort
		If case_ = "WithWork" Then

			'// Test Main : Work フォルダーとプロジェクトの内容が同じとき
			RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
				"_work\Projects\Sub\Main.xml.proja  _work\ProjectWork "+ appended_command +" Assort  "+ _
				"1  1  99  2  9  1  Exit", _
				"_work\log.txt"

			'// Check
			AssertFC  "_work\log.txt",  "2A_Fragment\LogAnswer_of_WithWork.txt"
		End If
		If case_ = "Remove" Then

			'// Test Main : Work フォルダーがすでにあるとき
			RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
				"_work\Projects\Sub\Main.xml.proja  _work\ProjectWork "+ appended_command +" Assort  """"  Exit", _
				"_work\log.txt"

			'// Check : No Error
		End If


		'// Clean
		del  "_work"

		End If : section.End_
	Next


	'//===========================================================
	If section.Start( "T_ModuleAssort2_AssortEx_1" ) Then

		echo  "=================================="
		echo  ">T_ModuleAssort2_AssortEx_1 > 01-02"
		echo  ""


		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		Set d = new LazyDictionaryClass
		d("${2}") = "2B_FragmentEx\1"
		d("${M}") = "_work\Masters"
		w_=Empty : Set w_= AppKey.NewWritable( Array( d("${2}\Masters"), d("${2}\ProjectWork\02") ) ).Enable()
		Set files = Dict(Array( _
			d("${2}\Masters\ModuleA\02\A.txt"),      CDate( "2001/02/01 12:34:00" ), _
			d("${2}\Masters\ModuleAB\02\B.txt"),     CDate( "2009/09/09 09:09:00" ), _
			d("${2}\Masters\ModuleAB\02\Sub\B.txt"), CDate( "2009/09/09 09:09:00" ) ))
		For Each  path  In  files.Keys
			SetReadOnlyAttribute  path, False  '// For next "SetDateLastModified"
		Next
		SetDateLastModified  files
		w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
		copy  d("${2}\*"),  "_work"
		SetReadOnlyAttribute  d("${M}"), True
		del  "_work\ProjectWork\01"
		ren  "_work\ProjectWork\02", "01"  '// *********


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Main.xml.proja  _work\ProjectWork\01  Assort  """"  Exit", _
			"_work\log.txt"


		'// Check
		full_set_txt = ReadFile( d("${M}\ModuleAB\WorkNewFiles\_FullSet.txt") )

		Assert  IsSameBinaryFile( _
			d("${M}\ModuleAB\Work\01_A_Copy.txt"), _
			d("${2}\Masters\ModuleA\01\A.txt") , Empty )
		Assert  IsSameBinaryFile( _
			d("${M}\ModuleAB\Work\B.txt"), _
			d("${2}\ProjectWork\02\B.txt") , Empty )
		Assert  not exist( d("${M}\ModuleAB\Work\B0.txt") )
		Assert  IsSameBinaryFile( _
			d("${M}\ModuleAB\WorkNewFiles\Sub\B.txt"), _
			d("${2}\ProjectWork\02\Sub\B.txt") , Empty )
		Assert  InStr( full_set_txt, " adbcdb535252ce614ad9ed5c77978b69 Sub\B.txt" ) >= 1


		echo  "=================================="
		echo  ">T_ModuleAssort2_AssortEx_1 > 02"
		echo  ""


		'// Set up
		ren  "_work\ProjectWork\01", "02"
		copy  "_work\Masters\ModuleAB\Work\01_A_Copy.txt",  "_work\Masters\ModuleAB\02"
		SetReadOnlyAttribute  "_work\Masters\MD5List.txt",  False
		del  "_work\*\Work\"


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Main.xml.proja  _work\ProjectWork\02  Assort  y  Exit", _
			"_work\log.txt"
			'// "y" meams to commot.


		'// Check
		hash_list_txt = ReadFile( "_work\Masters\MD5List.txt" )

		Assert  not exist( d("ModuleAB\02\01_A_Copy.txt") )
		Assert  InStr( hash_list_txt, " adbcdb535252ce614ad9ed5c77978b69 ModuleAB\02\Sub\B.txt" ) >= 1


		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_AssortEx_2" ) Then
		'// コミットしたときに、MD5List が更新されるテスト

		'// Test of to add "new_MD5_path" in "MD5List.txt".

		'// Set up
		new_MD5_path = "01\New.txt"
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "2B_FragmentEx\2\*",  "_work"
		Assert  InStr( ReadFile( "_work\Masters\MD5List.txt" ),  new_MD5_path ) = 0

		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Main.xml.proja  _work\ProjectWork\01  Assort  y  Exit", _
			""

		'// Check
		Assert  InStr( ReadFile( "_work\Masters\MD5List.txt" ),  new_MD5_path ) >= 1

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	For Each  is_KS  In  Array( True, False )
	If section.Start( "T_ModuleAssort2_AssortEx_3_KS_"+ GetEchoStr( is_KS ) ) Then

		echo  "=================================="
		echo  ">T_ModuleAssort2_AssortEx_3_KS > 01-02"
		'// XML による設定は01、プロジェクトのフォルダー名も01、プロジェクト ファイルの内容は02
		'// つまり、モジュールの Workフォルダーの元は01
		echo  ""

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		If is_KS Then
			yes_no = "Yes"
		Else
			yes_no = "No"
		End If
		Set d = new LazyDictionaryClass
		d("${KS}") = "2B_FragmentEx\3_KS"
		d("${M}") = "_work\Masters"
		w_=Empty : Set w_= AppKey.NewWritable( Array( d("${KS}") ) ).Enable()

		unzip  d("${KS}.zip"),  d("${KS}"),  c.CheckSameIfExist
		Set files = Dict(Array( _
			d("${KS}\Masters_"+ yes_no +"\ModuleA\01\svn_only.txt"),   CDate( "2001/01/01 12:34:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleA\01\svn_only_up.txt"),CDate( "2001/01/01 12:34:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleA\02\A.txt"),          CDate( "2001/02/01 12:34:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleAB\02\B.txt"),         CDate( "2009/09/09 09:09:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleAB\02\Sub\B.txt"),     CDate( "2009/09/09 09:09:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleC\01\C.txt"),          CDate( "2008/01/01 01:01:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleC\01\C_stay.txt"),     CDate( "2008/01/01 01:01:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleC\02\C.txt"),          CDate( "2008/02/02 02:02:00" ), _
			d("${KS}\Masters_"+ yes_no +"\ModuleC\02\C_stay.txt"),     CDate( "2008/02/02 02:02:00" ), _
			d("${KS}\ProjectWork\02\svn.txt"),        CDate( "2005/01/01 11:01:00" ), _
			d("${KS}\ProjectWork\02\svn_only.txt"),   CDate( "2005/01/01 11:01:00" ), _
			d("${KS}\ProjectWork\02\svn_only_up.txt"),CDate( "2005/01/01 11:01:00" ), _
			d("${KS}\ProjectWork\02\01_A_Copy.txt"),  CDate( "2005/01/01 11:01:00" ), _
			d("${KS}\ProjectWork\02\02_A_Copy.txt"),  CDate( "2005/01/01 11:01:00" ), _
			d("${KS}\ProjectWork\02\A.txt"),          CDate( "2005/01/01 01:01:00" ), _
			d("${KS}\ProjectWork\02\B.txt"),          CDate( "2005/01/01 02:01:00" ), _
			d("${KS}\ProjectWork\02\C.txt"),          CDate( "2008/11/11 11:11:00" ) ))
			'// Year 2009 means that using time stamp is in "_FullSet.txt".
			'// Year 2005 means that there are files in project".
		For Each  path  In  files.Keys
			SetReadOnlyAttribute  path, False
		Next
		SetDateLastModified  files
		w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
		copy  d("${KS}\*"),  "_work"
		ren  "_work\Masters_"+ yes_no,  "_work\Masters"
		SetReadOnlyAttribute  d("${M}"), True
		del  "_work\ProjectWork\01"
		ren  "_work\ProjectWork\02", "01"  '// *********


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Main_"+ yes_no +".xml.proja  _work\ProjectWork\01  Assort  """"  Exit", _
			"_work\log.txt"

		'// Check
		Assert  IsSameFolder( _
			d("${M}\ModuleA\Work"), _
			d("${KS}\MastersWorkAnswer\KS_"+ yes_no +"\ModuleA\Work_") , c.EchoV_NotSame )
		Assert  IsSameFolder( _
			d("${M}\ModuleAB\Work"), _
			d("${KS}\MastersWorkAnswer\KS_"+ yes_no +"\ModuleAB\Work_") , c.EchoV_NotSame )
		Assert  IsSameFolder( _
			d("${M}\ModuleA\WorkNewFiles"), _
			d("${KS}\MastersWorkAnswer\KS_"+ yes_no +"\ModuleA\WorkNewFiles_") , c.EchoV_NotSame )

		Assert  IsSameFolder( _
			"_work\ProjectWork\01", _
			d("${KS}\ProjectWorkAfter\01-02-"+ yes_no ),  c.EchoV_NotSame )

		Assert _
			g_fs.GetFile( "_work\ProjectWork\01\A.txt" ).DateLastModified = _
			g_fs.GetFile( d("${M}\ModuleA\Work\A.txt") ).DateLastModified
		Assert _
			g_fs.GetFile( d("${M}\ModuleA\Work\A.txt") ).DateLastModified = _
			g_fs.GetFile( d("${KS}\ProjectWork\02\A.txt") ).DateLastModified
		Assert _
			g_fs.GetFile( d("${M}\ModuleA\01\svn.txt") ).DateLastModified = _
			g_fs.GetFile( d("${M}\ModuleA\Work\svn.txt") ).DateLastModified
		Assert _
			g_fs.GetFile( d("${M}\ModuleA\Work\svn.txt") ).DateLastModified = _
			g_fs.GetFile( d("_work\ProjectWork\01\svn.txt") ).DateLastModified
		If yes_no = "No" Then
			Assert _
				g_fs.GetFile( d("${M}\ModuleA\Work\svn.txt") ).DateLastModified = _
				g_fs.GetFile( "_work\ProjectWork\01\svn.txt" ).DateLastModified
			'// yes_no = "Yes" では、$ModuleRevision: が編集されたため、日時は異なる
		End If
		Assert _
			g_fs.GetFile( d("${M}\ModuleA\01\svn_only.txt") ).DateLastModified = _
			g_fs.GetFile( d("_work\ProjectWork\01\svn_only.txt") ).DateLastModified
		Assert _
			g_fs.GetFile( d("${M}\ModuleA\01\svn_only_up.txt") ).DateLastModified <> _
			g_fs.GetFile( d("${M}\ModuleA\Work\svn_only_up.txt") ).DateLastModified
		Assert _
			g_fs.GetFile( d("${M}\ModuleA\Work\svn_only_up.txt") ).DateLastModified = _
			g_fs.GetFile( d("${KS}\ProjectWork\02\svn_only_up.txt") ).DateLastModified
		Assert _
			g_fs.GetFile( d("${M}\ModuleAB\01\02_A_Copy.txt") ).DateLastModified = _
			g_fs.GetFile( d("${M}\ModuleAB\Work\02_A_Copy.txt") ).DateLastModified
		Assert _
			g_fs.GetFile( d("${M}\ModuleAB\Work\02_A_Copy.txt") ).DateLastModified = _
			g_fs.GetFile( "_work\ProjectWork\01\02_A_Copy.txt" ).DateLastModified


		echo  "=================================="
		echo  ">T_ModuleAssort2_AssortEx_3_KS > 02"
		'// XML による設定は02、実際にプロジェクトにあるファイルも02
		echo  ""

		'// Set up
		ren  "_work\ProjectWork\01", "02"
		SetReadOnlyAttribute  "_work\Masters\MD5List.txt",  False
		del  "_work\Masters\*\Work*"

		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Main_"+ yes_no +".xml.proja  _work\ProjectWork\02  Assort  y  Exit", _
			"_work\log.txt"

		'// Check
		Set work_folders = ArrayFromWildcard( "_work\Masters\*\Work*" )
		Assert  UBound( work_folders.FolderPaths ) = -1

		Assert  IsSameFolder( _
			"_work\ProjectWork\02", _
			d("${KS}\ProjectWorkAfter\02-"+ yes_no ),  c.EchoV_NotSame )

		Assert  g_fs.GetFolder( "_work\Masters\ModuleAB\02" ).Files.Count = 1 + 1
		list_txt = ReadFile( "_work\Masters\MD5List.txt" )
		Assert  InStr( list_txt, " adbcdb535252ce614ad9ed5c77978b69 ModuleAB\02\Sub\B.txt" ) >= 1
		Assert _
			g_fs.GetFile( "_work\ProjectWork\02\A.txt" ).DateLastModified = _
			W3CDTF( "2016-10-12T20:03:40+09:00" )  '// From "ModuleA\02\_FullSet.txt"
		Assert _
			g_fs.GetFile( "_work\ProjectWork\02\B.txt" ).DateLastModified = _
			W3CDTF( "2002-02-01T11:11:00+09:00" )  '// From "ModuleAB\02\_FullSet.txt"


		'// Clean
		del  "_work"
		w_=Empty : Set w_= AppKey.NewWritable( d("${KS}") ).Enable()
		del  d("${KS}")
		w_=Empty

	End If : section.End_
	Next


	'//===========================================================
	If section.Start( "T_ModuleAssort2_AssortEx_3_KS_ReadOnly" ) Then

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		Set d = new LazyDictionaryClass
		d("${KS}") = "2B_FragmentEx\3_KS"
		d("${M}") = "_work\Masters"
		w_=Empty : Set w_= AppKey.NewWritable( Array( d("${KS}") ) ).Enable()

		unzip  d("${KS}.zip"),  d("${KS}"),  c.CheckSameIfExist
		w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
		copy  d("${KS}\*"),  "_work"
		ren  "_work\Masters_Yes",  "_work\Masters"
		del  "_work\ProjectWork\01"
		ren  "_work\ProjectWork\02", "01"  '// *********
		SetReadOnlyAttribute  "_work\ProjectWork\01\A.txt", True


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Projects\Main_Yes.xml.proja  _work\ProjectWork\01  Assort  """"  Exit", _
			"_work\log.txt"

		'// Check
		Assert  InStr( ReadFile( "_work\log.txt" ), "リードオンリー" ) >= 1

		'// Clean
		del  "_work"
		w_=Empty : Set w_= AppKey.NewWritable( d("${KS}") ).Enable()
		del  d("${KS}")
		w_=Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_AssortEx_4" ) Then
		'// Work に Project と同じ内容があるけど、Commit は選べないこと。

		'// Set up
		work_path = "4_AssortEx\4\Masters\ModuleC\Work"
		Set w_= AppKey.NewWritable( work_path ).Enable()
		del  work_path
		copy  work_path +"\..\02\*",  work_path
		w_=Empty

		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"4_AssortEx\4\Main.xml.proja  4_AssortEx\4\ProjectWork\02  Assort  Exit  Exit", _
			""

		'// Check
		AssertExist  work_path +"\C_stay.txt"
		AssertFC _
			"4_AssortEx\4\Masters\ModuleC\Work\C_KS.txt", _
			"4_AssortEx\4\Masters\ModuleC\02\C_KS.txt"

		'// Clean
		'// Nothing

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_AssortEx_5" ) Then


		'// Set up
		AssertExist "4_AssortEx\5\Masters\ModuleA\Work\_FullSet.txt"
			'// New _FullSet.txt
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "4_AssortEx\5\*",  "_work"
		w_=Empty


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Main.xml.proja  _work\ProjectWork\02  Assort  Exit  Exit", _
			""

		'// Check
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		SortFolderMD5List  "_work\Masters\ModuleA\Work\_FullSet.txt", _
			"_work\_FullSetSorted.txt",  Empty
		del  "_work\Masters\ModuleA\Work\_FullSet.txt"  '// For next CheckFolderMD5List

		'// No error of "Not found _FullSet.txt".

		CheckFolderMD5List  "_work\Masters\ModuleA\Work",  "_work\_FullSetSorted.txt",  Empty


		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	For Each  full_set_type  In Array( _
		"not",  "with_date_both",  "with_date_work",  "with_date_commit",  "without_date" )
	If section.Start( "T_ModuleAssort2_AssortEx_6_"+ GetEchoStr( full_set_type ) ) Then


		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "4_AssortEx\6\*",  "_work"


		'// Set up : Make "_FullSet.txt"
		If full_set_type <> "not" Then

			copy  "4_AssortEx\6\*",  "_work\_body"

			If StrCompLastOf( full_set_type,  "work",  Empty ) = 0 Then
				revisions = Array( "Work" )
			ElseIf StrCompLastOf( full_set_type,  "commit",  Empty ) = 0 Then
				revisions = Array( "01" )
			Else
				revisions = Array( "01", "Work" )
			End If

			For Each  case_  In  Array( "01_Add", "01_Del", "02_Add", "02_Del" )
			For Each  revision  In  Array( "01", "Work" )

				folder_path = "_work\"+ case_ +"\Masters\ModuleA\"+ revision
				If StrCompHeadOf( full_set_type,  "with_date",  Empty ) = 0 Then
					option_ = tc.BasePathIsList  or  tc.TimeStamp
				Else
					option_ = tc.BasePathIsList
				End If

				MakeFolderMD5List  folder_path,  folder_path +"\_FullSet.txt", _
					option_

				Set paths = ArrayFromWildcard( folder_path )
				paths.AddRemove  folder_path +"\_FullSet.txt"
				CallForEach1  GetRef("CallForEach_del"),  paths.FilePaths,  "."
				CallForEach1  GetRef("CallForEach_del"),  paths.DeleteFolderPaths,  "."

				Set rep = OpenForReplace( _
					"_work\"+ case_ +"\Project.xml.proja",  Empty )
				rep.Replace _
					"</ModuleAssort2_Projects>", _
					_
					"<Variable  name=""${body}""  value=""..\_body""  type=""FullPathType""/>"+ vbCRLF + _
					"<Fragment  list=""${body}\MD5List.txt""/>"+ vbCRLF + _
					"</ModuleAssort2_Projects>"
				rep.Close
			Next
			Next
		End If


		'// Test Main : 02_Del
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\02_Del\Project.xml.proja  _work\02_Del\ProjectWork  Assort  1  Exit", _
			"_work\02_Del\Log.txt"

		'// Check
		Assert  InStr( _
			ReadFile( "_work\02_Del\Log.txt" ), _
			"7. フォルダーを開く - WorkNewFiles" ) >= 1
		Assert  IsSameBinaryFile( _
			"_work\02_Del\Masters\ModuleA\Work\A.txt.bin", _
			"_work\02_Del\ProjectWork\A.txt.bin",  Empty )
		Assert  IsSameBinaryFile( _
			"_work\02_Del\Masters\ModuleA\WorkNewFiles\B.txt.bin", _
			"_work\02_Del\ProjectWork\B.txt.bin",  Empty )
		Assert  not exist( "_work\02_Del\Masters\ModuleA\Work\C.txt.bin" )


		'// Test Main : 01_Del
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\01_Del\Project.xml.proja  _work\01_Del\ProjectWork  Assort  1  7  Exit", _
			"_work\01_Del\Log.txt"

		'// Check
		Assert  InStr( _
			ReadFile( "_work\01_Del\Log.txt" ), _
			"7. フォルダーを開く - WorkNewFiles" ) >= 1
		Assert  IsSameBinaryFile( _
			"_work\01_Del\Masters\ModuleA\Work\A.txt.bin", _
			"_work\01_Del\ProjectWork\A.txt.bin",  Empty )
		Assert  IsSameBinaryFile( _
			"_work\01_Del\Masters\ModuleA\WorkNewFiles\B.txt.bin", _
			"_work\01_Del\ProjectWork\B.txt.bin",  Empty )


		'// Test Main : 01_Add
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\01_Add\Project.xml.proja  _work\01_Add\ProjectWork  Assort  1  Exit", _
			"_work\01_Add\Log.txt"

		'// Check
		Assert  InStr( _
			ReadFile( "_work\01_Add\Log.txt" ), _
			"7. フォルダーを開く - WorkNewFiles" )  = 0
		For Each  name  In  Array( "A", "B", "C" )
			Assert  IsSameBinaryFile( _
				"_work\01_Add\Masters\ModuleA\Work\"+ name +".txt.bin", _
				"_work\01_Add\ProjectWork\"+ name +".txt.bin",  Empty )
		Next
		Assert  not exist( "_work\01_Add\Masters\ModuleA\WorkNewFiles" )


		'// Test Main : 02_Add
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\02_Add\Project.xml.proja  _work\02_Add\ProjectWork  Assort  1  Exit", _
			"_work\02_Add\Log.txt"

		'// Check
		Assert  InStr( _
			ReadFile( "_work\02_Add\Log.txt" ), _
			"7. フォルダーを開く - WorkNewFiles" )  = 0
		For Each  name  In  Array( "A", "B", "C" )
			Assert  IsSameBinaryFile( _
				"_work\02_Add\Masters\ModuleA\Work\"+ name +".txt.bin", _
				"_work\02_Add\ProjectWork\"+ name +".txt.bin",  Empty )
		Next
		Assert  not exist( "_work\02_Add\Masters\ModuleA\WorkNewFiles" )


		'// Clean
		del  "_work"

	End If : section.End_
	Next


	'//===========================================================
	If section.Start( "T_ModuleAssort2_AssortEx_7" ) Then
		'// モジュールごとに Keyword Substitution を編集するかどうか

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "4_AssortEx\7\*",  "_work"
If False Then
		SetDateLastModified  Dict(Array( _
			"FileA.txt", CDate( "2008/06/16 12:00:00" ) ))
End If
		w_=Empty


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Project.xml.proja  _work\Project  Assort  Exit  Exit", _
			""

		'// Check
		Assert  IsSameFolder( "_work\Masters\Base\Work",     "_work\Answer\Base_Work",     c.EchoV_NotSame )
		Assert  IsSameFolder( "_work\Masters\ModuleA\Work",  "_work\Answer\ModuleA_Work",  c.EchoV_NotSame )
		Assert  IsSameFolder( "_work\Project",               "_work\Answer\Project",       c.EchoV_NotSame )

		'// Clean
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		w_=Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_AssortEx_8" ) Then
		'// AssortOne

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "4_AssortEx\8\*",  "_work"


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Project.xml.proja  Project\01  Assort  1  AssortOne  2  AssortOne  Exit", _
			"_work\log.txt"

		'// Check
		AssertFC  "_work\log.txt",  "4_AssortEx\8\Answer\log_1.txt"


		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\Project.xml.proja  Project\02  AssortOne  Exit", _
			"_work\log.txt"

		'// Check
		AssertFC  "_work\log.txt",  "4_AssortEx\8\Answer\log_2.txt"


		'// Clean
		del  "_work"
		w_=Empty

	End If : section.End_


	'//===========================================================
	For Each  case_name  In  Array( _
		"File_File",  "File_FullSet",  "FullSet_File",  "FullSet_FullSet", _
		"EmptyFolder_EmptyFolder",  "EmptyFolder_FullSet",  "FullSet_EmptyFolder",  "EmptyFolder_2FullSet" )

	If section.Start( "T_ModuleAssort2_Assort_Duplicated_"+ case_name ) Then

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "4_AssortEx\1\*",  "_work"
		echo  "=================================="
		Set g = new LazyDictionaryClass : g("${M}") = "_work\Masters"
		Select Case  case_name

			Case  "File_File"
				copy_ren  g("${M}\ModuleA\01\A.txt"),  g("${M}\ModuleB\01\A.txt")

			Case  "File_FullSet"
				copy_ren  g("${M}\ModuleA\01\A.txt"),  g("${M}\ModuleA\01\A_Copy.txt")

			Case  "FullSet_File"
				copy_ren  g("${M}\ModuleA\01\A.txt"),  g("${M}\ModuleB\01\A_Copy.txt")

			Case  "FullSet_FullSet"
				CreateFile  g("${M}\ModuleB_Copy\01\_FullSet.txt"), _
					"2016-02-20T11:01:04+09:00 7fc56270e7a70fa81a5935b72eacbe29 A_Copy.txt"+ vbCRLF + _
					"2016-02-20T11:01:04+09:00 9d5ed678fe57bcca610140957afab571 B_Copy.txt"+ vbCRLF

			Case  "EmptyFolder_EmptyFolder"
				mkdir  g("${M}\ModuleA\01\Empty")
				mkdir  g("${M}\ModuleB\01\Empty")
				mkdir  "_work\Project\Empty"

			Case  "EmptyFolder_FullSet"
				mkdir  g("${M}\ModuleA\01\Empty")
				CreateFile  g("${M}\ModuleB_Copy\01\_FullSet.txt"), _
					"2016-02-20T11:01:04+09:00 00000000000000000000000000000000 Empty"+ vbCRLF + _
					"2016-02-20T11:01:04+09:00 9d5ed678fe57bcca610140957afab571 B_Copy.txt"+ vbCRLF
				mkdir  "_work\Project\Empty"

			Case  "FullSet_EmptyFolder"
				CreateFile  g("${M}\ModuleA_Copy\01\_FullSet.txt"), _
					"2016-02-20T11:01:04+09:00 00000000000000000000000000000000 Empty"+ vbCRLF + _
					"2016-02-20T11:01:04+09:00 7fc56270e7a70fa81a5935b72eacbe29 A_Copy.txt"+ vbCRLF
				mkdir  g("${M}\ModuleB\01\Empty")
				mkdir  "_work\Project\Empty"

			Case  "EmptyFolder_2FullSet"
				CreateFile  g("${M}\ModuleA_Copy\01\_FullSet.txt"), _
					"2016-02-20T11:01:04+09:00 00000000000000000000000000000000 Empty"+ vbCRLF + _
					"2016-02-20T11:01:04+09:00 7fc56270e7a70fa81a5935b72eacbe29 A_Copy.txt"+ vbCRLF
				CreateFile  g("${M}\ModuleB_Copy\01\_FullSet.txt"), _
					"2016-02-20T11:01:04+09:00 00000000000000000000000000000000 Empty"+ vbCRLF + _
					"2016-02-20T11:01:04+09:00 9d5ed678fe57bcca610140957afab571 B_Copy.txt"+ vbCRLF
				mkdir  "_work\Project\Empty"
		End Select
		echo  ""

		'// Test Main
		RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
			"_work\A.xml.proja  _work\Project  Assort  Exit", _
			"_work\log.txt"

		'// Check
		AssertFC  "_work\log.txt",  "_work\Answer\"+ case_name +".txt"

		'// Clean
		del  "_work"

	End If : section.End_
	Next


	'//===========================================================

	work_paths = Array( "_work", "3_EmptyFolder\WithEmpty__.xml.proja", _
		"3_EmptyFolder\Masters\ModuleA\Work", _
		"3_EmptyFolder\Masters\ModuleB\Work", _
		"3_EmptyFolder\Masters\ModuleC\Work", _
		"3_EmptyFolder\Masters\ModuleFA\Work", _
		"3_EmptyFolder\Masters\ModuleFB\Work", _
		"3_EmptyFolder\Masters\ModuleFC\02\Sub", _
		"3_EmptyFolder\Masters\ModuleFC\Work" )
	Set w_= AppKey.NewWritable( work_paths ).Enable()


	If section.Start( "T_ModuleAssort2_EmptyFolder_01" ) Then

	'// Set up : Revision 01
	echo  "=== Revision 01."
	CallForEach1  GetRef("CallForEach_del"),  work_paths,  "."


	'// Test Main & Check : CheckOut : No Error
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"3_EmptyFolder\WithEmpty.xml.proja  _work  CheckOut  Project-A\01  """"", _
		"_work\log.txt"

	'// Check
	AssertFC  "_work\log.txt",  "3_EmptyFolder\LogAnswer_01a.txt"
	del  "_work\log.txt"


	'// Test Main & Check : Assort and Commit : No Error
	OpenForReplace( "3_EmptyFolder\WithEmpty.xml.proja",  "3_EmptyFolder\WithEmpty__.xml.proja" ).Replace _
		"value=""ProjectA""",  "value=""..\_work"""
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"3_EmptyFolder\WithEmpty__.xml.proja  _work  Assort  y  Exit", _
		"_work\log.txt"

	'// Check
	AssertFC  "_work\log.txt",  "3_EmptyFolder\LogAnswer_01b.txt"

	'// Clean
	del  "_work\*"
	del  "3_EmptyFolder\WithEmpty__.xml.proja"
	CallForEach1  GetRef("CallForEach_del"),  work_paths,  "."

	End If : section.End_


	If section.Start( "T_ModuleAssort2_EmptyFolder_01_02" ) Then

	'// Set up : Revision 01-02
	echo  "=== Revision 01-02."
	CallForEach1  GetRef("CallForEach_del"),  work_paths,  "."

	copy  "3_EmptyFolder\Works\02\*",  "_work"
	SetReadOnlyAttribute  "_work", False
	OpenForReplace( "3_EmptyFolder\WithEmpty.xml.proja",  "3_EmptyFolder\WithEmpty__.xml.proja" ).Replace _
		"value=""ProjectA""",  "value=""..\_work"""


	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"3_EmptyFolder\WithEmpty__.xml.proja  _work  "+ _
		"Assort  1  7  Exit",  "_work\log.txt"

	'// Check
	AssertFC  "_work\log.txt",  "3_EmptyFolder\LogAnswer_01_02.txt"
	Assert  not exist( "3_EmptyFolder\Masters\ModuleA\Work\A" )
	AssertExist  "3_EmptyFolder\Masters\ModuleC\Work\Sub\C"
	AssertExist  "3_EmptyFolder\Masters\ModuleA\WorkNewFiles\B"

	'// Clean
	del  "_work"
	del  "3_EmptyFolder\WithEmpty__.xml.proja"
	CallForEach1  GetRef("CallForEach_del"),  work_paths,  "."

	End If : section.End_


	If section.Start( "T_ModuleAssort2_EmptyFolder_02" ) Then

	'// Set up : Revision 02
	echo  "=== Revision 02."
	CallForEach1  GetRef("CallForEach_del"),  work_paths,  "."
	del       "3_EmptyFolder\Masters\ModuleFC\02\Sub"
	copy_ren  "3_EmptyFolder\Masters\ModuleFC\02",  "3_EmptyFolder\Masters\ModuleFC\Work"

	copy  "3_EmptyFolder\Works\02\*",  "_work"
	SetReadOnlyAttribute  "_work", False
	Set file = OpenForReplace( "3_EmptyFolder\WithEmpty.xml.proja",  "3_EmptyFolder\WithEmpty__.xml.proja" )
	file.Replace  "value=""ProjectA""",  "value=""..\_work"""
	file.Replace  "<ModuleAssort2_Projects>",  "<ModuleAssort2_Projects>"+ vbCRLF + vbCRLF + _
		"<ProjectTag  name=""Project-A""  value=""Project-A\02""/>"
	file = Empty


	'// Test Main & Check : No Error
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"3_EmptyFolder\WithEmpty__.xml.proja  _work  "+ _
		"Assort  y  Exit",  "_work\log.txt"


	'// Check
	AssertFC  "_work\log.txt",  "3_EmptyFolder\LogAnswer_02.txt"
	Assert  not exist( "3_EmptyFolder\Masters\ModuleFC\Work" )

	'// Clean
	del  "_work"
	del  "3_EmptyFolder\WithEmpty__.xml.proja"
	CallForEach1  GetRef("CallForEach_del"),  work_paths,  "."

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Assort_NoFolderInProject" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( Array( "_log.txt", "4_AssortEx\2" ) ).Enable()
	del  "_log.txt"
	del  "4_AssortEx\2\*\Work"
	del  "4_AssortEx\2\*\WorkNewFiles"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"4_AssortEx\2\A.xml.proja  4_AssortEx\2\Project  Assort  n  """"  Exit", _
		"_log.txt"

	'// Check
	AssertFC  "_log.txt",  "4_AssortEx\2\LogAnswer.txt"

	'// Clean
	del  "4_AssortEx\2\Masters\ModuleA\WorkNewFiles"
	del  "_log.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Assort_NoFolderInMaster" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( Array( "_log.txt", "4_AssortEx\3" ) ).Enable()
	del  "_log.txt"
	del  "4_AssortEx\3\Masters"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"4_AssortEx\3\A.xml.proja  4_AssortEx\3\Project  Assort  y  """"  Exit", _
		"_log.txt"

	'// Check
	AssertFC  "_log.txt",  "4_AssortEx\3\LogAnswer.txt"

	'// Clean
	del  "_log.txt"
	del  "4_AssortEx\3\Masters"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_TotalMD5List" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	del  "_work"
	copy  "2A_Fragment\Masters\ModuleA",              "_work\Masters"
	copy  "2A_Fragment\Masters\ModuleA_Copy",         "_work\Masters"
	copy  "2A_Fragment\Projects\Sub\Main.xml.proja",  "_work\Projects\Sub"
	copy  "2A_Fragment\Masters\MD5List.txt",          "_work\Masters"
	total_path = "_work\Masters\_TotalMD5List.txt"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"_work\Projects\Sub\Main.xml.proja  """"  "+ _
		"MakeTotalMD5List  Exit  Exit",  ""

	'// Check
	AssertFC  total_path,  "2A_Fragment\Masters\TotalMD5List_Answer.txt"

	'// Clean
	del  total_path
	del  "_work"
	w_ = Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_CheckUpdate" ) Then

	'// 6_CheckUpdate

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Make" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_ProjectCache" ).Enable()
	del  "_ProjectCache"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"5_MakeRule\MakeFile.xml.proja  Project-A\01  Make  Exit", _
		"_ProjectCache\_log.txt"

	'// Check
	AssertFC  "_ProjectCache\_log.txt",  "5_MakeRule\LogAnswer01.txt"

	'// Clean
	del  "_ProjectCache"
	w_ = Empty


	'// Error case of MultiMatch
	'// Set up
	Set w_= AppKey.NewWritable( "_ProjectCache" ).Enable()
	del  "_ProjectCache"

	'// Test Main
	RunProg  "cscript //nologo "+ WScript.ScriptName +"  /ArgsLog  ModuleAssort2  "+ _
		"5_MakeRule\MultiMatch.xml.proja  Project-A\01  Exit", _
		"_ProjectCache\_log.txt"

	'// Check
	AssertFC  "_ProjectCache\_log.txt",  "5_MakeRule\LogAnswer_MultiMatch.txt"

	'// Clean
	del  "_ProjectCache"
	w_ = Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ModuleAssort2_Example" ) Then
		prompt_vbs = SearchParent( "vbslib Prompt.vbs" )

		'// Test case based on "T_ModuleAssort2_CheckOut".

		'// Set up
		Set w_= AppKey.NewWritable( "_ProjectWork" ).Enable()
		del  "_ProjectWork"

		'// Test Main
		RunProg  "cscript //nologo """+ prompt_vbs +"""  ModuleAssort2  "+ _
			"1_Open\Test.xml.proja  _ProjectWork  CheckOut  Project-B\02  Exit",  ""

		'// Check
		Assert  IsSameFolder( "_ProjectWork", "1_Open\ProjectB", c.EchoV_NotSame )
		Assert  GetReadOnlyList( "_ProjectWork", Empty, Empty ) = 0

		'// Clean
		del  "_ProjectWork"


		'// Test case based on "T_ModuleAssort2_Assort".

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		copy  "2A_Fragment\Masters\*",  "_work\Masters"
		OpenForReplace( "2A_Fragment\Projects\Sub\Main.xml.proja", "_work\Projects\Sub\Main.xml.proja" ).Replace _
			"value=""..\..\ProjectWork""",  "value=""..\..\..\2A_Fragment\ProjectWork"""
		SetReadOnlyAttribute  "_work\Masters\MD5List.txt",  False

		'// Test Main & Check : No Error

		RunProg  "cscript //nologo """+ prompt_vbs +"""  ModuleAssort2  "+ _
			"_work\Projects\Sub\Main.xml.proja  2A_Fragment\ProjectWork  Assort  y  Exit", _
			"_work\log.txt"

		'// Check
		Assert  InStr( ReadFile( "_work\log.txt" ), "警告の数 = 0" ) >= 1
		Assert  InStr( ReadFile( "_work\log.txt" ), "チェックアウトできることを確認しました" ) >= 1

		'// Clean
		del  "_work"

	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: ModuleAssort2_Installer
'*
'* Description:
'*    スクリプトを小さくするため、このコマンドはインストール専用コマンドです。
'***********************************************************************
Sub  ModuleAssort2_Installer( Opt, ref_AppKey )
	Set c = g_VBS_Lib
	echo  "プロジェクト フォルダーを構成します。"
	projects_file_path = InputPath( ".proja ファイルのパス >", c.CheckFileExists )
	project_name = Input( "プロジェクト名 >" )
	echo  ""

	echo  "パスの入力はドラッグ&ドロップでもできます。"
	project_folder_path = InputPath( "出力先のパス >", 0 )
	echo  ""
	Set w_= ref_AppKey.NewWritable( project_folder_path ).Enable()

	Set prompt_ = new ModuleAssort2_PromptClass
	prompt_.Initialize  projects_file_path
	prompt_.CheckOut  project_name,  project_folder_path
	echo  ""
	echo  "出力しました。 このウィンドウは閉じることができます。"
	Do
		Sleep  10000
	Loop
End Sub


 
'***********************************************************************
'* Function: ModuleAssort2
'*
'* Call Tree:
'* - <ModuleAssort2_PromptClass.Initialize>
'* - | 設定をロードする <ModuleAssort2_SettingFileClass.Load>
'* - | <ModuleAssort2_CurrentClass.Reset>
'* - カレントを設定する <ModuleAssort2_PromptClass.RunChangingCurrent>
'* - | <InputPath>
'* - | チェックアウトする <ModuleAssort2_PromptClass.CheckOut>
'* - | | <ModuleAssort2_PromptClass.CheckOutOneFolder>
'* - | | <ModuleAssort2_SettingFileClass.ChangeCurrentProjectRevision>
'* - | <ModuleAssort2_PromptClass.ChangeCurrent>
'* - | | 場所を解析する <ModuleAssort2_PromptClass.SearchModuleInProjects>
'* - カレントに対するメニュー <ModuleAssort2_PromptClass.RunCurrentModuleRevisionMenu>
'* - | <Input>
'* - | アソートする <ModuleAssort2_PromptClass.Assort>
'***********************************************************************
Sub  ModuleAssort2( Opt, ref_AppKey )
	Set c = g_VBS_Lib
	If ArgumentExist( "ArgsLog" ) Then
		include  SearchParent( "scriptlib\vbslib\ArgsLog\SettingForTest_pre.vbs" )
		include  SearchParent( "scriptlib\vbslib\ArgsLog\SettingForTest.vbs" )
		SetVar  "Setting_openFolder", "echo_v"
		SetVar  "Setting_getFolderDiffCmdLine", "DiffCUI"
		echo  ""
	End If

	g_is_vbslib_for_fast_user = True

	If ArgumentExist( "EchoOff" ) Then _
		Set ec = new EchoOff

	echo  "バージョン管理と構成管理を行います。"
	echo  "パスの入力はドラッグ&ドロップでもできます。"
	echo  ""
	echo  "Enter のみ：メンテナンス メニュー"
	projects_file_path = InputPath( "設定ファイル（.proja）のパス >", _
		c.CheckFileExists or c.AllowEnterOnly )
	echo  ""
	If NOT ( projects_file_path = "" ) Then
		boot_command = Empty
		boot_command_parameter = Empty
	Else
		boot_command = "Maintenance"
		boot_command_parameter = Empty
	End If

	Do
		Set prompt_ = new ModuleAssort2_PromptClass
		prompt_.BootCommand = boot_command
		prompt_.BootCommandParameter = boot_command_parameter
		If ArgumentExist( "EchoOff" ) Then _
			Set prompt_.EchoObject = ec
		If not IsEmpty( old_prompt_ ) Then _
			Set prompt_.OldPrompt = old_prompt_
		If NOT( prompt_.BootCommand = "Maintenance" ) Then

			prompt_.Initialize  projects_file_path
		End If

		If prompt_.BootCommand = "Assort"  or  prompt_.BootCommand = "AssortOne" Then
			prompt_.ChangeCurrent  prompt_.BootCommandParameter

			If prompt_.BootCommand = "Assort" Then
				target_module = Empty
			Else
				prompt_.Current.ModulePathInMasters     = prompt_.OldPrompt.Current.ModulePathInMasters
				prompt_.Current.ModuleFullPathInMasters = prompt_.OldPrompt.Current.ModuleFullPathInMasters

				Set target_module = prompt_.Current.Project.Modules( _
					prompt_.Current.ModuleFullPathInMasters )
			End If

			prompt_.Assort  ref_AppKey,  target_module
			prompt_.BootCommand = Empty
			prompt_.BootCommandParameter = Empty
			is_changing_current_menu = ( prompt_.WorkingModules.Count >= 1 )
		ElseIf prompt_.BootCommand = "Maintenance" Then
			is_changing_current_menu = False
		Else
			is_changing_current_menu = True
		End If
		If is_changing_current_menu Then

			prompt_.RunChangingCurrent  ref_AppKey,  "メンテナンス メニューへ"
			If prompt_.IsExit Then _
				Exit Do
		End If
		If  NOT  IsEmpty( prompt_.Current.ModulePathInMasters ) Then

			prompt_.RunCurrentModuleRevisionMenu  ref_AppKey
		ElseIf not IsEmpty( prompt_.CurrentMakeRelation ) Then

			prompt_.RunMakeTreeMenu  ref_AppKey
		Else

			prompt_.RunMaintenanceMenu  ref_AppKey
		End If

		If not IsEmpty( prompt_.BootCommand ) Then _
			prompt_.IsExit = False

		If prompt_.IsExit Then _
			Exit Do

		boot_command = prompt_.BootCommand
		boot_command_parameter = prompt_.BootCommandParameter
		Set old_prompt_ = prompt_
	Loop
End Sub


 
'***********************************************************************
'* Function: get_ModuleAssort2_Const
'***********************************************************************
Dim  g_ModuleAssort2_Const

Function  get_ModuleAssort2_Const()
	If IsEmpty( g_ModuleAssort2_Const ) Then _
		Set g_ModuleAssort2_Const = new ModuleAssort2_ConstClass
	Set get_ModuleAssort2_Const = g_ModuleAssort2_Const
End Function

Class  ModuleAssort2_ConstClass
	Public  NoKS, UpdatedKS, MasterCopy

	Private Sub  Class_Initialize()
		NoKS = 1  '// No Keyword Substitution
		UpdatedKS = 2
		MasterCopy = 3
	End Sub
End Class


 
'***********************************************************************
'* Class: ModuleAssort2_PromptClass
'***********************************************************************
Class  ModuleAssort2_PromptClass
	Public  SettingFile  '// as ModuleAssort2_SettingFileClass
	Public  Current      '// as ModuleAssort2_CurrentClass
	Public  Defragmenter '// as OpenForDefragmentClass
	Public  WorkingModules  '// as ArrayClass of ModuleAssort2_ModuleInFileClass
	Public  CurrentMakeRelation  '// as ArrayClass of string
	Public  FilesPath
	Public  RegExpOfKeywordSubstitution
	Private Me_DefragmentOption  '// as OpenForDefragmentOptionClass
	Public  BootCommand
	Public  BootCommandParameter
	Public  EchoObject
	Public  OldPrompt
	Public  IsExit
	Public  Constant  '// as ModuleAssort2_ConstClass
	Private Me_ReadOnlyWarningCount


Private Sub  Class_Initialize()
	Set Me.Constant = get_ModuleAssort2_Const()
	Set Me.Current = new ModuleAssort2_CurrentClass
End Sub


 
'***********************************************************************
'* Method: Initialize
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::Initialize
'***********************************************************************
Public Sub  Initialize( in_ProjectsFilePath )
	Set prompt_ = Me
	Set prompt_.SettingFile = new ModuleAssort2_SettingFileClass
	Set prompt_.Current = new ModuleAssort2_CurrentClass

	prompt_.SettingFile.Load  in_ProjectsFilePath
	prompt_.Current.Reset  prompt_.SettingFile

	fragment_path = prompt_.SettingFile.FragmentListFullPath
	If not IsEmpty( fragment_path ) Then
		If not exist( fragment_path ) Then
			echo  ""
			echo  fragment_path
			key = Input( "上記のファイルが見つかりません。 ファイルを作成しますか。[Y/N]" )
			If key <> "y"  and  key <> "Y" Then _
				Error
			CreateFile  fragment_path,  ""
		End If

		Set prompt_.Defragmenter = OpenForDefragment( fragment_path,  get_ToolsLibConsts().TimeStamp )
	End If

	Set prompt_.WorkingModules = new ArrayClass
	Set Me_DefragmentOption = new OpenForDefragmentOptionClass
'// 2017-02-20	Set Me_DefragmentOption.CopyOneFileFunction = GetRef( "ModuleAssort2_PromptClass_copyAndFillKS" )

	'// Set "FilesPath"
	Set ds = new CurDirStack
	Set ec = new EchoOff
	pushd  g_fs.GetParentFolderName( WScript.ScriptFullName )
	prompt_.FilesPath = SearchParent( "_src\Test\tools\T_ModuleAssort2\Files" )
	popd
	ec = Empty

	'// ...
	Set ks_re = CreateObject( "VBScript.RegExp" )
	ks_re.Pattern = "(\$[A-Za-z0-9]+::?)([^\$]*)\$"  '// ks = KeywordSubstitution
	ks_re.Global = True
	ks_re.MultiLine = True

	Set Me.RegExpOfKeywordSubstitution = ks_re
End Sub


 
'***********************************************************************
'* Method: RunChangingCurrent
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::RunChangingCurrent
'***********************************************************************
Public Sub  RunChangingCurrent( ref_AppKey,  in_MenuOfEnterOnly )
	Set c = g_VBS_Lib
	is_check_out = False
	is_check_out_soon = False
	is_show_menu = True
	project_full_name = ""

	Do
		do_it = True

		If is_show_menu Then
			echo_line
			If Me.WorkingModules.Count >= 1 Then
				num = 1
				For Each  module  In  Me.WorkingModules.Items
					If module.PathInMasters = Me.Current.ModulePathInMasters Then
						mark_ = "*"
					Else
						mark_ = " "
					End If

					echo  mark_ + CStr( num )+". "+ module.PathInMasters
					num = num + 1
				Next
				echo_line
				message_header_1 = "・上記の番号"
				message_header_2 = "上記の番号、または、"

			ElseIf Me.SettingFile.ProjectTags.Count >= 1 Then
				num = 1
				For Each  project_tag_name  In  Me.SettingFile.ProjectTags.Keys
					echo  " "+ CStr( num )+". "+ project_tag_name
					num = num + 1
				Next
				echo_line
				message_header_1 = "・上記の番号"
				message_header_2 = "上記の番号、または、"
			Else
				message_header_1 = Empty
				message_header_2 = ""
			End If

			echo  "以下のいずれかを入力してください。"
			If not IsEmpty( message_header_1 ) Then _
				echo  message_header_1
			echo  "・プロジェクト名＋リビジョン名。例：Project\01"
				'// Search "GetMakeRelations" in this file.
			echo  "・アソート＆コミットする XML の Project/@path に記述したパス"
				'// Search "ChangeCurrent" in this file.
			echo  "・プロジェクトをチェックアウトまたはリリースする空のフォルダーのパス"
				'// Search "IsEmptyFolder" in this file.
			If not IsEmpty( in_MenuOfEnterOnly ) Then _
				echo  "・Enter のみ : "+ in_MenuOfEnterOnly
		End If
		is_show_menu = True

		key = Input( message_header_2 +"パス >" )
		echo  ""
		If key = "" Then _
			Exit Sub

		If StrComp( key, "exit", 1 ) = 0 Then
			Me.IsExit = True
			Exit Do
		End If


		'// ...
		If do_it Then
			old_current_path = Me.Current.ModulePathInMasters
			If TryStart(e) Then  On Error Resume Next

				Me.ChangeCurrent  key
			If TryEnd Then  On Error GoTo 0
			full_path = Me.Current.FullPathOfKey
			If e.num = E_PathNotFound  or ( e.num = 0  and  IsEmptyFolder( full_path ) ) Then
				echo_v  e.Description
				e.Clear
				If StrCompHeadOf( full_path,  Me.SettingFile.ProjectCacheFullPath,  c.AsPath ) = 0  and _
						IsEmptyFolder( full_path ) Then

					is_check_out = True
					command = "CheckOut"
					project_full_name = GetRelativePath( full_path,  Me.SettingFile.ProjectCacheFullPath )
				Else
					Do
						echo  ""
						echo  "1. 指定したパスにプロジェクトを出力する [CheckOut]"
						If not IsEmpty( Me.Current.Project ) Then
							echo  "11. 指定したパスに "+ Me.Current.Project.Name + _
								" プロジェクトを出力する [CheckOutSoon]"
						End If
						echo  "2. 指定したパスにプロジェクトとモジュールを公開する [Publish]"
						echo  "3. 指定したパスにパッケージを出力する [MakePackage]"
						echo  "Enter のみ: 戻る"
						key = Trim( Input( "番号またはコマンド名>" ) )
						Select Case  key
							Case "1": key = "CheckOut"
							Case "11":key = "CheckOutSoon"
							Case "2": key = "Publish"
							Case "3": key = "MakePackage"
							Case "" : key = "Return"
						End Select
						If StrComp( key, "CheckOut", 1 ) = 0 Then

							is_check_out = True
							is_check_out_soon = False
							command = "CheckOut"
							Exit Do
						ElseIf StrComp( key, "CheckOutSoon", 1 ) = 0 Then
							is_check_out = True
							is_check_out_soon = True
							command = "CheckOutSoon"
							Exit Do
						ElseIf StrComp( key, "Publish", 1 ) = 0 Then
							Set w_= ref_AppKey.NewWritable( full_path ).Enable()

							Me.Publish  full_path,  True
							w_= Empty
							Me.IsExit = True
							Exit Do
						ElseIf StrComp( key, "MakePackage", 1 ) = 0 Then
							Set w_= ref_AppKey.NewWritable( full_path ).Enable()

							Me.MakePackage  full_path
							w_= Empty
							Me.IsExit = True
							Exit Do
						ElseIf StrComp( key, "Return", 1 ) = 0 Then
							Exit Do
						End If
					Loop
				End If
			ElseIf e.num <> 0 Then
				echo_v  "Error in ChangeCurrent 0x"+ Hex( e.num ) +": "+ e.Description
				e.Clear
				do_it = False  '// continue
			End If
		End If
		If do_it Then
			If not IsEmpty( old_current_path ) Then  '// at 2nd time and after
				Set ec = new EchoOff
				If StrCompHeadOf( full_path,  Me.Current.ModuleFullPathInWorkProject,  c.AsPath ) = 0 Then
					path = GetFullPath( Me.Current.RelativePath,  Me.Current.ModuleFullPathInMasters )
					If exist( path ) Then

						OpenFolder  path
					End If
				End If
				ec = Empty
			End If


			If is_check_out Then
'// TODO:			If command = "CheckOut"  or  command = "CheckOutSoon" Then
				echo  ""
				echo  "プロジェクトをチェックアウトします。"
				If project_full_name = "" Then
					If IsEmpty( Me.Current.Project ) Then
						echo  "Enter のみ: 戻る"
					Else
						echo  "Enter のみ: "+ Me.Current.Project.Name
					End If
				End If
				Do
					If project_full_name = "" Then
						If not is_check_out_soon  and  command = "CheckOut" Then
							project_full_name = Input( "プロジェクト名\リビジョン（例：ProjectA\01）>" )
						Else
							project_full_name = Me.Current.Project.Name
							echo  "プロジェクト名\リビジョン（例：ProjectA\01）>"+ project_full_name
							is_check_out_soon = False
							command = "CheckOut"
						End If
					End If
					If project_full_name = "" Then _
						If not IsEmpty( Me.Current.Project ) Then _
							project_full_name = Me.Current.Project.Name
					If project_full_name = "" Then
						If not IsEmpty( Me.Current.ProjectName ) Then
							Exit Do
						Else
							'// Input again
						End If
					Else
						Set w_= ref_AppKey.NewWritable( full_path ).Enable()
						echo  ""


						Me.CheckOut  project_full_name,  full_path


						echo  ""
						echo  "チェックアウトしてできたフォルダーのパスを .proja ファイル(XML形式)の中"+ _
							"の Project/@path 属性に記述してから ModuleAssort を起動すると、"+ _
							"アソート＆コミットできるようになります。 "+ _
							"なお、ファイルの中に記述された ${...} は、Variable タグで定義している変数です。"
						echo  ""
						echo  "完了しました。"
						Pause

						Me.IsExit = True
						Exit Do
					End If
				Loop
			End If

			Exit Do
		End If
	Loop
End Sub


 
'***********************************************************************
'* Method: RunCurrentModuleRevisionMenu
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::RunCurrentModuleRevisionMenu
'***********************************************************************
Public Sub  RunCurrentModuleRevisionMenu( ref_AppKey )
	Set c = g_VBS_Lib
	Do
		echo_line
		echo  "Project Root = "+ Me.Current.Project.FullPath
		is_in_project = g_fs.FolderExists( Me.Current.Project.FullPath )
		If not is_in_project Then
			echo  ""
			echo  "Project Name = "+ Me.Current.ProjectName
			echo  ""
			echo  "プロジェクト フォルダーが見つかりません。"
			echo  ""
			echo  " 1. プロジェクトをチェックアウトする [CheckOut]"
			echo  " 3. プロジェクトのモジュールを一覧する [Modules]"
		Else
			echo  "Module in Project = "+ Me.Current.ModulePathInProject
			If Me.Current.RelativePath <> "." Then
				echo  "File   in Project = "+ GetRelativePath( GetFullPath( _
					Me.Current.RelativePath,  Me.Current.ModuleFullPathInWorkProject ),  Me.Current.Project.FullPath )
			End If
			echo  ""
			echo  "Project Name = "+ Me.Current.ProjectName
			echo  "Module in Masters = "+ Me.Current.ModulePathInMasters
			If exist( Me.Current.WorkModuleFullPath ) Then
				echo  "                    "+ Me.Current.WorkModulePath
			End If
			echo  ""
			echo  " 1. 現在のモジュールのフォルダーを比較する [Diff]"
			echo  " 2.   プロジェクトをアソート＆コミットする [Assort]"
			echo  " 22.  現在のモジュールをアソートする [AssortOne]"
			echo  " 3.   プロジェクトのモジュールを一覧する [Modules]"
			echo  " 4. フォルダーを開く - マスターの中のモジュール"
			If exist( Me.Current.WorkModuleFullPath ) Then _
				echo  " 5. フォルダーを開く - マスターの中のワーク モジュール"
			echo  " 6. フォルダーを開く - プロジェクトの中のモジュール"
			If not IsEmpty( Me.Current.WorkNewModulePath ) Then _
				echo  " 7. フォルダーを開く - WorkNewFiles"
		End If
		If not IsEmpty( Me.CurrentMakeRelation ) Then _
			echo  " 8. メイク ツリーを表示する [Make]"
		echo  " 9. カレント モジュールを変更する [GoTo]"
		echo  ""

		Do
			key = Trim2( Input( "番号またはコマンド>" ) )


			If key = "1" Then
				If is_in_project Then
					key = "Diff"
				Else
					key = "CheckOut"
				End If
			End If


			If StrComp( key, "Exit", 1 ) = 0 Then
				Me.IsExit = True
				Exit Sub


			ElseIf StrComp( key, "Diff", 1 ) = 0 Then

				Me.OpenDiffTool
				Me.RunChangingCurrent  ref_AppKey,  "戻る"
				Exit Do


			ElseIf StrComp( key, "CheckOut", 1 ) = 0 Then
				Set w_ = ref_AppKey.NewWritable( Me.Current.Project.FullPath ).Enable()

				Me.CheckOut  Me.Current.ProjectName,  Me.Current.Project.FullPath
				echo  "Completed."
				Me.IsExit = True
				Exit Do


			ElseIf key = "2"  or  StrComp( key, "Assort", 1 ) = 0 Then

				Me.BootCommand = "Assort"
				Me.BootCommandParameter = Me.Current.CurrentKey
				Me.IsExit = True
				Exit Do

			ElseIf key = "22"  or  StrComp( key, "AssortOne", 1 ) = 0 Then

				Me.BootCommand = "AssortOne"
				Me.BootCommandParameter = Me.Current.CurrentKey
				Me.IsExit = True
				Exit Do

			ElseIf key = "3"  or  StrComp( key, "Modules", 1 ) = 0 Then

				Me.RunModulesMenu
				Me.RunChangingCurrent  ref_AppKey,  "戻る"
				Exit Sub

			ElseIf key = "4" Then
				Set ec = new EchoOff

				OpenFolder  GetFullPath( Me.Current.RelativePath, _
					Me.Current.ModuleFullPathInMasters )
				ec = Empty

			ElseIf key = "5" Then
				Set ec = new EchoOff

				OpenFolder  GetFullPath( Me.Current.RelativePath, _
					Me.Current.WorkModuleFullPath )
				ec = Empty

			ElseIf key = "6" Then
				Set ec = new EchoOff

				OpenFolder  GetFullPath( Me.Current.RelativePath, _
					Me.Current.ModuleFullPathInWorkProject )
				ec = Empty

			ElseIf key = "7" Then
				Set ec = new EchoOff

				OpenFolder  Me.Current.WorkNewModuleFullPath
				ec = Empty

			ElseIf key = "8"  or  StrComp( key, "Make", 1 ) = 0 Then
				If not IsEmpty( Me.CurrentMakeRelation ) Then
					Me.RunMakeTreeMenu  ref_AppKey
					Me.IsExit = True
					Exit Do
				End If

			ElseIf key = "9"  or  StrComp( key, "GoTo", 1 ) = 0 Then

				Me.RunChangingCurrent  ref_AppKey,  "戻る"
				Exit Do

			ElseIf key = "" Then
				Exit Do  '// Show a Menu

			Else
				echo  "そのコマンドはありません。"
			End If
		Loop

		If Me.IsExit Then _
			Exit Do
	Loop
End Sub


 
'***********************************************************************
'* Method: RunModulesMenu
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::RunModulesMenu
'***********************************************************************
Public Sub  RunModulesMenu()
	GetDicItemOrError  Me.SettingFile.Projects,  Me.Current.ProjectName,  project_,  "Project"  '// Set "project_"
		AssertD_TypeName  project_, "ModuleAssort2_ProjectInFileClass"

	echo  ""
	DicItemToArr  project_.Modules,  modules  '// Set "modules".
	index = 0
	For Each  module  In  modules
		index = index + 1
		echo  AlignString( index, 3, " ", Empty ) +". "+ module.PathInMasters
	Next
	echo  "Enter のみ： 戻る"
	Do
		key = Input( "開くフォルダーの番号 >" )
		key = Trim( key )
		If key = "" Then _
			Exit Do

		index = CInt2( key )
		If index >= 1  and  index <= UBound( modules ) + 1 Then
			Set module = modules( index - 1 )
			OpenFolder  module.FullPathInMasters
		End If
	Loop
End Sub


 
'***********************************************************************
'* Method: RunMakeTreeMenu
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::RunMakeTreeMenu
'***********************************************************************
Public Sub  RunMakeTreeMenu( ref_AppKey )
	echo  "Make Tree:"
	echo  Me.SettingFile.MakeRuleSet.GetMakeTreeString( Me.CurrentMakeRelation )
	echo  Me.SettingFile.MakeRuleSet.GetAllCommandsString( Me.CurrentMakeRelation )

	echo  "9. 終了する [Exit]"
	key = Trim( Input( "番号またはコマンド名>" ) )
	Me.IsExit = True
End Sub


 
'***********************************************************************
'* Method: RunMaintenanceMenu
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::RunMaintenanceMenu
'***********************************************************************
Public Sub  RunMaintenanceMenu( ref_AppKey )
	Set prompt_ = Me
	Set tc = get_ToolsLibConsts()
	Do
		echo  "1. ダウンロードする [Download]"
		echo  "2. 設定ファイルを編集する [Edit]"
		If not IsEmpty( prompt_.Defragmenter ) Then
			list_full_path = prompt_.SettingFile.FragmentListFullPath
			name = g_fs.GetFileName( list_full_path )
			echo  "3. "+ name +" と _FullSet.txt を集めた _Total"+ name +" を作る [MakeTotalMD5List]"
		End If
		echo  "9. 戻る [Exit]"
		key = Trim( Input( "番号またはコマンド名>" ) )
		Select Case  key
			Case "1": key = "Download"
			Case "2": key = "Edit"
			Case "3": key = "MakeTotalMD5List"
			Case "9": key = "Exit"
		End Select

		If StrComp( key, "Download", 1 ) = 0 Then
			prompt_.EchoObject.Close

			prompt_.RunDownloadMenu  ref_AppKey
			prompt_.IsExit = True
			prompt_.BootCommand = Empty
			Exit Do

		ElseIf StrComp( key, "Edit", 1 ) = 0 Then
			start  GetEditorCmdLine( prompt_.SettingFile.Path )

		ElseIf StrComp( key, "MakeTotalMD5List", 1 ) = 0 Then
			Assert  not IsEmpty( prompt_.Defragmenter )
			list_full_path = prompt_.SettingFile.FragmentListFullPath
			total_path = g_fs.GetParentFolderName( list_full_path ) +"\_Total"+ g_fs.GetFileName( list_full_path )
			root_path = g_fs.GetParentFolderName( list_full_path )
			Set w_= ref_AppKey.NewWritable( total_path ).Enable()

			echo  ""
			echo  "集めています ..."
			MakeFolderMD5List  root_path,  total_path,  tc.IncludeFullSet or tc.FasterButNotSorted
			echo  ""
			echo  "完了しました。"

		ElseIf StrComp( key, "Exit", 1 ) = 0 Then
			Exit Do
		End If
	Loop
End Sub


 
'***********************************************************************
'* Method: RunDownloadMenu
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::RunDownloadMenu
'***********************************************************************
Public Sub  RunDownloadMenu( ref_AppKey )
	echo  "ModuleAssort Downloader"
	echo  "モジュールやプロジェクトをダウンロードします。"
	echo  ""
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()

	server_path = InputPath( "サーバーのパス >",  c.CheckFolderExists )

	If ArgumentExist( "MD5List" ) Then
		hash_list_path = WScript.Arguments.Named( "MD5List" )
		hash_list_path = GetFullPath( hash_list_path,  server_path )
	Else
		back_up = g_start_in_path
		g_start_in_path = server_path

		hash_list_path = InputPath( "サーバーにある MD5リストのパス >", _
			c.CheckFileExists )
		g_start_in_path = back_up
	End If
	Set defragmenter = OpenForDefragment( hash_list_path,  tc.TimeStamp )
	defragmenter.ExistenceCache.TargetRootPath = server_path

	If ArgumentExist( "Existence" ) Then
		existence_cache_path = WScript.Arguments.Named( "Existence" )
		existence_cache_path = GetFullPath( existence_cache_path,  server_path )
	Else
		back_up = g_start_in_path
		g_start_in_path = server_path

		existence_cache_path = InputPath( "サーバーにある存在キャッシュ ファイルのパス >", _
			c.CheckFileExists )
		g_start_in_path = back_up
	End If
	defragmenter.ExistenceCache.Load  existence_cache_path,  Empty

	Do
		echo  ""
		downloaded_path_default = env("%USERPROFILE%\Downloads\ModuleAssort\") + _
			g_fs.GetFileName( server_path )
		echo  "Enter のみ："+ downloaded_path_default
		downloaded_path = InputPath( _
			"ダウンロードしたファイルを入れる、ローカル フォルダーのパス >", _
			c.AllowEnterOnly )
		If downloaded_path = "" Then _
			downloaded_path = downloaded_path_default

		If StrCompHeadOf( downloaded_path,  server_path,  c.AsPath ) = 0 Then
			echo  "ローカルのパスを指定してください。"
		Else
			Exit Do
		End If
	Loop

	If NOT g_fs.FolderExists( downloaded_path ) Then
		echo  ""
		key = Input( "指定したローカル フォルダーは存在しません。作りますか。[Y/N]" )
		If key <> "y"  and  key <> "Y"  and  key <> "" Then _
			Exit Sub  ' ... Cancel
		Set w_= ref_AppKey.NewWritable( downloaded_path ).Enable()
		mkdir  downloaded_path
		w_ = Empty
	End If

	echo  ""
	echo  "サーバーにある _FullSet.txt ファイルに書かれた一覧から構成されるモジュールをダウンロード、"+ _
		"または、.proja ファイルに書かれたプロジェクトをチェックアウトします。 "+_
		"サーバーにある下記をここへドラッグアンドドロップしてください。"
	echo  "  ・サーバーにある _FullSet.txt ファイル（が入ったフォルダー）"
	echo  "  ・サーバーにある .proja ファイル（が入ったフォルダー）"

	Do
		back_up = g_start_in_path
		g_start_in_path = server_path

		echo  ""
		path_in_server = InputPath( "サーバーの中のパス >",  c.CheckFileExists  or  c.CheckFolderExists _
			or  c.AllowEnterOnly )
		g_start_in_path = back_up
		If path_in_server = "" Then _
			Exit Do
		path_in_local = ReplaceRootPath( path_in_server,  server_path,  downloaded_path,  True )
		If g_fs.FileExists( path_in_server ) Then
			path_in_local_folder = g_fs.GetParentFolderName( path_in_local )
		Else
			path_in_local_folder = path_in_local
		End If
		Set w_= ref_AppKey.NewWritable( path_in_local_folder ).Enable()


		Me.Download  path_in_server,  path_in_local,  defragmenter
		w_ = Empty
		Set ec = new EchoOff

		OpenFolder  path_in_local_folder
		ec = Empty
	Loop
End Sub


 
'***********************************************************************
'* Method: Download
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::Download
'***********************************************************************
Public Sub  Download( in_PathInServer,  in_PathInLocal,  in_Defragmenter )
	If not IsEmpty( ref_Copies ) Then _
		AssertD_TypeName  ref_Copies,  "CopyWindowClass"

	'// TODO: ModuleAssort2::ExistenceCache (1)
	in_Defragmenter.ExistenceCache.IsEnabled = True
	in_Defragmenter.ExistenceCache.CountOfCheckingExistence = 0

	If g_fs.FolderExists( in_PathInServer ) Then
		Set paths = ArrayFromWildcard2( in_PathInServer +"\*\_FullSet.txt | "+ in_PathInServer +"\*.proja" )
		For Each  path_in_server  In  paths.FullPaths
			path_in_local = ReplaceRootPath( _
				path_in_server,  in_PathInServer,  in_PathInLocal,  True )

			Me.Download  path_in_server,  path_in_local,  in_Defragmenter
		Next

	ElseIf  g_fs.GetFileName( in_PathInServer ) = "_FullSet.txt" Then
		parent_in_local = GetParentFullPath( in_PathInLocal )
		Set ec = new EchoOff
		del  parent_in_local
		ec = Empty

		in_Defragmenter.DownloadStart _
			g_fs.GetParentFolderName( in_Defragmenter.FileFullPath ), _
			g_fs.GetParentFolderName( in_PathInServer ), _
			parent_in_local,  Empty

		in_Defragmenter.CopyFolder _
			g_fs.GetParentFolderName( in_Defragmenter.FileFullPath ), _
			g_fs.GetParentFolderName( in_PathInServer ), _
			parent_in_local,  Empty
		SetReadOnlyAttribute  parent_in_local,  False
		count_of_cheking_existence = in_Defragmenter.ExistenceCache.CountOfCheckingExistence

	ElseIf  g_fs.GetExtensionName( in_PathInServer ) = "proja" Then
		Set proja_file = new ModuleAssort2_PromptClass
		proja_file.Initialize  in_PathInServer
		parent_in_local = GetParentFullPath( in_PathInLocal )
		Set ec = new EchoOff
		del  parent_in_local
		ec = Empty
		Set proja_file.Defragmenter.           ExistenceCache = in_Defragmenter.ExistenceCache
		Set proja_file.Defragmenter.Downloader.ExistenceCache = in_Defragmenter.ExistenceCache

		proja_file.CheckOut  GetFirst( proja_file.SettingFile.Projects.Keys ), _
			parent_in_local
		count_of_cheking_existence = proja_file.Defragmenter.ExistenceCache.CountOfCheckingExistence
	End If

	'// TODO: ModuleAssort2::ExistenceCache (2)
	If not IsEmpty( count_of_cheking_existence ) Then
		echo_v  "(count_of_cheking_existence = "+ CStr( count_of_cheking_existence ) +")"
	End If
	in_Defragmenter.ExistenceCache.IsEnabled = False
End Sub


 
'***********************************************************************
'* Method: OpenDiffTool
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::OpenDiffTool
'***********************************************************************
Public Sub  OpenDiffTool()
	Set option_ = new DiffCmdLineOptionClass
	option_.IsComparing(2) = False

	command_line = GetDiffCmdLine3Ex( _
		Me.Current.ModuleFullPathInMasters, _
		Me.Current.WorkModuleFullPath, _
		Me.Current.ModuleFullPathInWorkProject, _
		option_ )

	If not IsEmpty( command_line ) Then _
		start  command_line
End Sub


 
'***********************************************************************
'* Method: CheckOut
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::CheckOut
'***********************************************************************
Public Sub  CheckOut( in_ProjectFullName,  in_OutputPath )
	position = InStrRev( in_ProjectFullName, "\" )
	GetDicItemOrError  Me.SettingFile.Projects,  in_ProjectFullName,  project_,  "Project"  '// Set "project_"
		AssertD_TypeName  project_, "ModuleAssort2_ProjectInFileClass"
	Const  c_NotCaseSensitive = 1
	Set c = g_VBS_Lib
	Set written_files = CreateObject( "Scripting.Dictionary" )
	written_files.CompareMode = c_NotCaseSensitive
	If not IsEmpty( Me.Current.Project ) Then _
		current_back_up = Me.Current.Project.FullPath
	Set Me_DefragmentOption.Delegate = new ModuleAssort2_CurrentOfFillKS_Class
	Set Me_DefragmentOption.Delegate.Me_ = Me


	If exist( in_OutputPath ) Then
		If not IsEmptyFolder( in_OutputPath ) Then
			Raise  E_WriteAccessDenied, _
				"<ERROR  msg=""チェックアウト先のフォルダーまたはフォルダーの中を先に削除してください。""  path="""+ _
				in_OutputPath +"""/>"
		End If
	End If


	project_.ChangeCurrentProjectRevision  in_OutputPath


	is_not_found = False
	For Each  module  In  project_.Modules.Items
		If not g_fs.FolderExists( module.FullPathInMasters ) Then
			echo  "<ERROR msg=""フォルダーが見つかりません。"" path="""+ module.PathInMasters + _
				""" full_path="""+ module.FullPathInMasters +"""/>"
			is_not_found = True
		End If
	Next
	If is_not_found Then _
		Raise  E_PathNotFound,  "<ERROR msg=""フォルダーが見つかりません。""/>"


	For Each  module  In  project_.Modules.Items
		Me.DownloadOneFolderStart  module.FullPathInMasters,  module.FullPathInWorkProject
	Next


	For Each  module  In  project_.Modules.Items
		AssertD_TypeName  module, "ModuleAssort2_ModuleInFileClass"
		Set Me_DefragmentOption.Delegate.Module = module
		If IsEmpty( module.IsFillKS ) Then
			Me_DefragmentOption.Delegate.IsFill = project_.IsFillKS
		Else
			Me_DefragmentOption.Delegate.IsFill = module.IsFillKS
		End If
		If Me_DefragmentOption.Delegate.IsFill Then
			Set Me_DefragmentOption.CopyOneFileFunction = GetRef( "ModuleAssort2_PromptClass_copyAndFillKS" )
		Else
			Me_DefragmentOption.CopyOneFileFunction = Empty
		End If
		Me_DefragmentOption.Flags = c.ToNotReadOnly


		echo  module.PathInMasters


		'// Show warnings
		ExpandWildcard  module.FullPathInMasters +"\*",  c.File or c.SubFolder,  folder,  relative_paths
		For Each  relative_path  In  relative_paths
			writing_full_path = GetFullPath( relative_path, folder )
			If not written_files.Exists( writing_full_path ) Then
				Set written_files( writing_full_path ) = module
			Else
				Set old_module = written_files( writing_full_path )

				echo  "<WARNING msg=""Overwritten""  module_1="""+ old_module.PathInMasters + _
					"""  module_2="""+ module.PathInMasters +"""  relative_path="""+ relative_path +"""/>"
			End If
		Next
		Set ec = new EchoOff


		Me.CheckOutOneFolder  module.FullPathInMasters,  module.FullPathInWorkProject


		ec = Empty
	Next
	Dic_add  files, Me_DefragmentOption.Delegate.Files  '// Set "files"

	SetDateLastModified  files
	SetReadOnlyAttribute  in_OutputPath, False
	If not IsEmpty( current_back_up ) Then _
		project_.ChangeCurrentProjectRevision  current_back_up
	Me_DefragmentOption.Delegate = Empty
End Sub


 
'***********************************************************************
'* Method: ChangeCurrent
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::ChangeCurrent
'***********************************************************************
Public Sub  ChangeCurrent( in_PathOrKey )
	Set c = g_VBS_Lib

	Set module = Me.SearchModuleInProjects( in_PathOrKey,  work_path_in_project,  relative_path )
		'// Set "work_path_in_project", "relative_path", "full_path_of_key"


	If TypeName( module ) = "ModuleAssort2_ModuleInFileClass" Then

		Me.SettingFile.Projects( module.ProjectName ).ChangeCurrentProjectRevision  work_path_in_project
		Me.Current.RelativePath = relative_path

		Me.Current.ProjectName = module.ProjectName
		Set Me.Current.Project = Me.SettingFile.Projects( Me.Current.ProjectName )
		Me.Current.Projects( Me.Current.ProjectName ).WorkProjectFullPathBackUp = module.FullPathInWorkProject
		Me.Current.ModulePathInMasters = module.PathInMasters
		Me.Current.ModulePathInProject = module.PathInProject
		Me.Current.WorkModulePath      = module.WorkPathInMasters
		Me.Current.ModuleFullPathInMasters     = module.FullPathInMasters
		Me.Current.ModuleFullPathInWorkProject = module.FullPathInWorkProject
		Me.Current.WorkModuleFullPath          = module.FullPathInWorkMasters

	End If
End Sub


 
'***********************************************************************
'* Method: SearchModuleInProjects
'*
'* Argument:
'*    in_PathOrKey - path, number or project name
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::SearchModuleInProjects
'***********************************************************************
Public Function  SearchModuleInProjects( in_PathOrKey,  out_WorkProjectRootPath,  out_RelativePath )
	Set c = g_VBS_Lib
	out_WorkProjectRootPath = Empty
	input_full_path = Empty

	If IsNumeric( in_PathOrKey ) Then
		index = CInt2( in_PathOrKey ) - 1
		If Me.WorkingModules.Count >= 1 Then
			If index >= 0  and  index <= Me.WorkingModules.UBound_ Then


				'// Block: Number of WorkingModules
				input_full_path = Me.WorkingModules( index ).FullPathInMasters
				Me.Current.CurrentKey = input_full_path
			Else
				index = -1
			End If
		ElseIf Me.SettingFile.ProjectTags.Count >= 1 Then
			ReDim  project_tag_names( Me.SettingFile.ProjectTags.Count - 1 )
			num = 0
			For Each  project_tag_name  In  Me.SettingFile.ProjectTags.Keys
				project_tag_names( num ) = project_tag_name
				num = num + 1
			Next
			If index >= 0  and  index <= UBound( project_tag_names ) Then


				'// Block: Number of ProjecTags
				project_tag_name = project_tag_names( index )
				project_name = Me.SettingFile.ProjectTags( project_tag_name )
				Me.Current.CurrentKey = project_name
			Else
				index = -1
			End If
		End If
		If index < 0 Then
			echo  "番号が範囲外です。"
			echo  ""
			is_show_menu = False
			do_it = False  '// continue
		End If
	Else
		project_name = in_PathOrKey
		Me.Current.CurrentKey = in_PathOrKey
	End If
	If IsEmpty( input_full_path ) Then


		'// Block: Project Name
		If Me.SettingFile.Projects.Exists( project_name ) Then
			GetDicItemOrError  Me.SettingFile.Projects,  _
				project_name,  project_,  "Project"  '// Set "project_"
				AssertD_TypeName  project_, "ModuleAssort2_ProjectInFileClass"
			If IsEmpty( project_.FullPath ) Then _
				project_.FullPath = GetFullPath( project_name,  Me.SettingFile.ProjectCacheFullPath )
			input_full_path = project_.FullPath
		End If
	End If
	If IsEmpty( input_full_path ) Then


		'// Block: Step Path
		input_full_path = Me.SettingFile.Variables.GetFullPath( in_PathOrKey,  g_start_in_path )
	End If


	'// Block: Query of URL. e.g. "folder\sub?project=name\01"
	is_project_query = False
	question_position = InStr( input_full_path, "?" )
	If question_position >= 1 Then
		query = Mid( input_full_path,  question_position + 1 )
		input_full_path = Left( input_full_path,  question_position - 1 )
		If StrCompHeadOf( query,  "project=",  Empty ) = 0 Then
			is_project_query = True
			equal_position = InStr( query, "=" )
			target_project_name = Mid( query,  equal_position + 1 )
			For Each  project_name  In  Me.SettingFile.Projects.Keys
				If StrComp( target_project_name,  project_name,  1 ) = 0 Then

					Set project_ = Me.SettingFile.Projects( project_name )
					out_WorkProjectRootPath = input_full_path
					Exit For  '// Set "project_name"
				End If
			Next
		End If
	End If


	'// Block: Search MakeRule
	If Me.SettingFile.MakeRuleSet.IsFoundMakeRelations( input_full_path ) Then
		Set ec = new EchoOff

		Set Me.CurrentMakeRelation = Me.SettingFile.MakeRuleSet.GetMakeRelations( input_full_path )
		ec = Empty
	End If


	If not IsEmpty( project_ ) Then
		out_WorkProjectRootPath = project_.FullPath
		If not g_fs.FolderExists( out_WorkProjectRootPath ) Then _
			If g_fs.FolderExists( input_full_path ) Then _
				out_WorkProjectRootPath = input_full_path
	End If


	If IsEmpty( project_ ) Then

		'// Set "project_names_" : "Me.Current.ProjectName" + "Me.Current.Projects"
		If IsEmpty( Me.Current.ProjectName ) Then
			ReDim  project_names_( Me.Current.Projects.Count - 1 )
			i = 0
			insert_index = 0
		Else
			ReDim  project_names_( Me.Current.Projects.Count )

			project_names_(0) = Me.Current.ProjectName
			i = 1
			insert_index = 1
		End If
		For Each  project_name  In  Me.Current.Projects.Keys

			project_names_(i) = project_name  '// Example: "Project\01"
			i = i + 1
		Next


		'// Set "project_names" : Sort by "<ProjectTag>".
		Set project_names = new_ArrayClass( project_names_ )
		ReverseNotObjectArray  Me.SettingFile.ProjectTags.Items,  tag_values  '// Set "tag_values"
		For Each  project_name  In  tag_values
			index = project_names.Search( project_name,  GetRef("StdCompare"),  0,  insert_index )
			If not IsEmpty( index ) Then

				project_names.Remove  index, 1
			End If

			project_names.Insert  insert_index,  project_name
			insert_index = insert_index + 1
		Next
		project_names = project_names.Items

		For Each  project_name  In  project_names
			GetDicItemOrError  Me.SettingFile.Projects,  project_name,  project_,  "Project"  '// Set "project_"
				AssertD_TypeName  project_, "ModuleAssort2_ProjectInFileClass"


			'// Block: Search "project_" in "project_.FullPath". key = "input_full_path".
			If StrCompHeadOf( input_full_path,  project_.FullPath,  c.AsPath ) = 0 Then
				Exit For  '// Set "project_name", "project_"
			End If
		Next
		If IsEmpty( project_name ) Then _
			project_ = Empty
	End If


	'// Search "module" in the project
	If not IsEmpty( project_ ) Then
		near_module = Empty
		near_module_length = 0

		'// Search in module in project_
		For Each  module  In  project_.Modules.Items
			AssertD_TypeName  module, "ModuleAssort2_ModuleInFileClass"


			'// Block: Search "module" in "module.FullPathInWorkProject". key = "input_full_path".
			If StrCompHeadOf( input_full_path,  module.FullPathInWorkProject,  c.AsPath ) = 0 Then
				path_in_masters = ReplaceRootPath( input_full_path, _
					module.FullPathInWorkProject,  module.FullPathInMasters,  True )
				If exist( path_in_masters ) Then
					near_module = Empty
					Exit For  '// Set "module"
				Else
					If Len( module.FullPathInWorkProject ) > near_module_length Then
						Set near_module = module
						near_module_length = Len( module.FullPathInWorkProject )
					End If
				End If
			End If
		Next
		If not IsEmpty( near_module ) Then _
			Set module = near_module
		If IsEmpty( module ) Then _
			GetDicItemByIndex  project_.Modules,  0,  module  '// Set "module"
		out_RelativePath = GetRelativePath( input_full_path,  module.FullPathInWorkProject )


	'// Search in module in masters
	ElseIf not IsEmpty( Me.Current.ProjectName ) Then
		GetDicItemOrError  Me.SettingFile.Projects,  Me.Current.ProjectName,  project_,  "Project"  '// Set "project_"
			AssertD_TypeName  project_, "ModuleAssort2_ProjectInFileClass"

		For Each  module  In  project_.Modules.Items
			AssertD_TypeName  module, "ModuleAssort2_ModuleInFileClass"


			'// Block: Search "module" in "module.FullPathInMasters". key = "input_full_path".
			is_in_committed = ( StrCompHeadOf( input_full_path,  module.FullPathInMasters,  c.AsPath ) = 0 )
			If is_in_committed Then
				If exist( module.FullPathInMasters ) Then
					out_RelativePath = GetRelativePath( input_full_path,  module.FullPathInMasters )
					Exit For  '// Set "module"
				End If
			End If

			is_in_work = ( StrCompHeadOf( input_full_path,  module.FullPathInWorkMasters,  c.AsPath ) = 0 )
			If is_in_work  Then
				If exist( module.FullPathInWorkMasters ) Then
					out_RelativePath = GetRelativePath( input_full_path,  module.FullPathInWorkMasters )
					Exit For  '// Set "module"
				End If
			End If
		Next
	End If

	Me.Current.FullPathOfKey = input_full_path

	If not IsEmpty( module ) Then

		Set SearchModuleInProjects = module
		If IsEmpty( out_WorkProjectRootPath ) Then _
			out_WorkProjectRootPath = project_.FullPath

		is_in_project = ( StrCompHeadOf( input_full_path,  out_WorkProjectRootPath,  c.AsPath ) = 0 )
		If not is_in_project  and  not is_project_query Then
			Me.Current.CurrentKey = Me.Current.CurrentKey +"?project="+ Me.Current.ProjectName
		End If
	Else
		Raise  E_PathNotFound,  "<ERROR msg=""プロジェクト（Project/@path属性）の外、"+ _
			"および、そのプロジェクトが使うマスターの外のようです。""  path="""+ _
			input_full_path +"""/>"
	End If
End Function


 
'***********************************************************************
'* Method: CheckOutOneFolder
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::CheckOutOneFolder
'***********************************************************************
Public Sub  CheckOutOneFolder( in_PathInMasters,  in_PathInProject )
	Set c = g_VBS_Lib
	path_in_masters = GetFullPath( in_PathInMasters,  Empty )
	If StrCompHeadOf( path_in_masters,  Me.SettingFile.ProjectCacheFullPath,  c.AsPath ) <> 0 Then
		If IsEmpty( Me.Defragmenter ) Then

			copy_ren  in_PathInMasters,  in_PathInProject
			del  in_PathInProject +"\_FullSet.txt"
		Else
			Set option_ = Me_DefragmentOption

			Me.Defragmenter.CopyFolder _
				g_fs.GetParentFolderName( Me.SettingFile.FragmentListFullPath ), _
				in_PathInMasters,  in_PathInProject,  option_  '// Set "option_"
		End If
	Else
		project_full_name = GetRelativePath( path_in_masters,  Me.SettingFile.ProjectCacheFullPath )

		Me.CheckOut  project_full_name,  in_PathInProject
	End If
End Sub


 
'***********************************************************************
'* Method: DownloadOneFolderStart
'*    Prefetch of Me.CheckOutOneFolder
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::DownloadOneFolderStart
'***********************************************************************
Public Sub  DownloadOneFolderStart( in_PathInMasters,  in_PathInProject )
	Set c = g_VBS_Lib
	path_in_masters = GetFullPath( in_PathInMasters,  Empty )
	If StrCompHeadOf( path_in_masters,  Me.SettingFile.ProjectCacheFullPath,  c.AsPath ) <> 0 Then
		If IsEmpty( Me.Defragmenter ) Then
		Else
			Set option_ = Me_DefragmentOption

			Me.Defragmenter.DownloadStart _
				g_fs.GetParentFolderName( Me.SettingFile.FragmentListFullPath ), _
				in_PathInMasters,  in_PathInProject,  option_  '// Set "option_"
		End If
	End If
End Sub


 
'***********************************************************************
'* Method: Publish
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::Publish
'***********************************************************************
Public Sub  Publish( in_PublicFolderPath,  in_IsFragment )
	echo  ""
	Set ec = new EchoOff

	Const  c_NotCaseSensitive = 1
	Set ds = new CurDirStack
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	Set defragmenters = CreateObject( "Scripting.Dictionary" )
	defragmenters.CompareMode = c_NotCaseSensitive
	Set files = CreateObject( "Scripting.Dictionary" )
	files.CompareMode = c_NotCaseSensitive
	Set empty_folders = CreateObject( "Scripting.Dictionary" )
	empty_folders.CompareMode = c_NotCaseSensitive
	Set module_folders = CreateObject( "Scripting.Dictionary" )
	module_folders.CompareMode = c_NotCaseSensitive
	exe7z = Setting_get7zExePath()

	Set proja_files = ArrayFromWildcard2( in_PublicFolderPath +"\*.proja" )
	For Each  proja_path  In  proja_files.FullPaths
	If StrComp( proja_path,  Me.SettingFile.Path,  1 ) <> 0 Then
		ec = Empty

		echo  proja_path

		SetReadOnlyAttribute  proja_path,  True
		Set proja_file = new ModuleAssort2_PromptClass
		proja_file.Initialize  proja_path
		Set ec = new EchoOff

		path = proja_file.Defragmenter.FileFullPath
		SetReadOnlyAttribute  path,  False
		If NOT defragmenters.Exists( path ) Then
			Set defragmenters( path ) = proja_file.Defragmenter
		Else
			Set proja_file.Defragmenter = defragmenters( path )
		End If
		defragmenter_base_path = g_fs.GetParentFolderName( path )

		For Each  project  In  proja_file.SettingFile.Projects.Items

			For Each  module  In  project.Modules.Items
				AssertD_TypeName  module,  "ModuleAssort2_ModuleInFileClass"
				module_destination_path = module.FullPathInMasters

				If not exist( module_destination_path ) Then
					mkdir  module_destination_path
					cd  module_destination_path
					module_folders( module_destination_path ) = True

					If TryStart(e) Then  On Error Resume Next

						module_source_path = Me.SettingFile.Variables( module.PathInMasters )

					If TryEnd Then  On Error GoTo 0
					If e.num <> 0 Then
						e.OverRaise  e.Number,  AppendErrorMessage( e.Description, _
							"defined_in="""+ Me.SettingFile.Path +"""" )
					End If

					Assert  IsFullPath( module_source_path )
					If in_IsFragment Then _
						Set full_set_file = OpenForWrite( "_FullSet.txt",  c.Unicode )


					'// Copy a module from Me to proja_file.
					Set paths = EnumerateToLeafPathDictionaryByFullSetFile( _
						module_source_path,  Me.Defragmenter,  Empty ) '// MD5ListLeafClass
					For Each  an_item  In  paths.Items
						relative_path = an_item.Name

						is_copy = False
						If NOT in_IsFragment Then
							is_copy = True
						Else  '// in_IsFragment

							full_set_file.WriteLine  an_item.TimeStamp +" "+ an_item.HashValue +" "+ relative_path
							If an_item.HashValue = tc.EmptyFolderMD5 Then
								is_copy = True
							ElseIf IsEmpty( proja_file.Defragmenter.GetRelativePath( an_item.HashValue, Empty ) ) Then
								is_copy = True
							End If
						End If

						If is_copy Then
							If an_item.HashValue = tc.EmptyFolderMD5 Then
								mkdir  relative_path
								empty_folders( GetFullPath( relative_path,  module_destination_path ) ) = True
							Else
								copy_ren  an_item.BodyFullPath,  relative_path
								files( GetFullPath( relative_path,  module_destination_path ) ) = True
							End If
						End If
					Next


					If in_IsFragment Then
						full_set_file = Empty

						'// Change to ascii file, if ascii
						If GetLineNumsExistNotEnglighChar( "_FullSet.txt", Empty ) = 0 Then
							text = ReadFile( "_FullSet.txt" )
							CreateFile  "_FullSet.txt",  text
						End If

						'// ...
						proja_file.Defragmenter.Append  Empty,  _
							defragmenter_base_path,  module_destination_path,  Empty

						'// Make .7z file
						move  "_FullSet.txt",  ".."
						r= RunProg( """"+ exe7z +""" a """+ module_destination_path +".7z"" -ssw *", "" )
						Assert  r = 0
						move_ren  "..\"+ g_fs.GetFileName( module_destination_path ) +".7z",  "_Fragment.7z"
						move  "..\_FullSet.txt",  "."
					End If
				End If
			Next
		Next
	End If
	Next

	For Each  a_defragmenter  In  defragmenters.Items
		a_defragmenter.Save  a_defragmenter.FileFullPath
		SetReadOnlyAttribute  a_defragmenter.FileFullPath,  True
	Next


	'// Delete files before compression
	For Each  path  In  files.Keys
		del  path
	Next
	For Each  path  In  empty_folders.Keys
		del  path
	Next
	For Each  path  In  module_folders.Keys
		For Each  sub_folder  In  g_fs.GetFolder( path ).SubFolders
			path = sub_folder.Path
			If StrCompHeadOf( path,  in_PublicFolderPath,  c.AsPath ) = 0 Then
				del  path
			End If
		Next
	Next


	'// Save ExistenceCache
	Set a_defragmenter = GetFirst( defragmenters.Items )
	cache_path = GetFullPath( "..\ExistenceCache.txt",  a_defragmenter.FileFullPath )
	ec = Empty
	echo  "Save  """+ cache_path +""""

	Set cache = new ExistenceCacheClass
	cache.TargetRootPath = ""
	Set ec = new EchoOff
	Const  time_stamp_length = 25
	Const  hash_length = 32
	column_of_path_with_time_stamp = time_stamp_length + 1 + hash_length + 2
	column_of_path_without_time_stamp = hash_length + 2
	Set paths = ArrayFromWildcard( in_PublicFolderPath )
	For Each  leaf_full_path  In  paths.LeafPaths

		cache.Exists  leaf_full_path  '// Add to cache

		If g_fs.GetFileName( leaf_full_path ) = "_FullSet.txt" Then
			Set file = OpenForRead( leaf_full_path )
			base_path = g_fs.GetParentFolderName( leaf_full_path )
			Do Until file.AtEndOfStream
				SplitLineAndCRLF  file.ReadLine(), line, cr_lf  '// Set "line", "cr_lf"
				If Trim( line ) <> "" Then
					If IsEmpty( column_of_path ) Then
						is_with_time_stamp = ( Mid( line, 5, 1 ) = "-" )
						If is_with_time_stamp Then
							column_of_path = column_of_path_with_time_stamp
						Else
							column_of_path = column_of_path_without_time_stamp
						End If
					End If
					relative_path_in_full_set = Mid( line,  column_of_path )

					cache.Exists  GetFullPath( relative_path_in_full_set,  base_path )
						'// Add to cache
				End If
			Loop
			file = Empty
		End If
	Next

	cache.Save  cache_path,  Empty,  proja_files.BasePath
End Sub


 
'***********************************************************************
'* Method: MakePackage
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::MakePackage
'***********************************************************************
Public Sub  MakePackage( in_OutputFolderPath )
	echo  ""
	Set ds = new CurDirStack
	Set tc = get_ToolsLibConsts()
	Set c = g_VBS_Lib
	Set Me_DefragmentOption.Delegate = new ModuleAssort2_CurrentOfFillKS_Class
	Set Me_DefragmentOption.Delegate.Me_ = Me
	output_folder_path = GetFullPath( in_OutputFolderPath, Empty )
	output_modules_path = output_folder_path +"\_Modules"
	common_parent_path = ""
	Set time_stamps = CreateObject( "Scripting.Dictionary" )
	setting_time_stamp = g_fs.GetFile( Me.SettingFile.Path ).DateLastModified
	ReDim  files_array( Me.SettingFile.ProjectTags.Count - 1 )


	'// Set "common_parent_path" in masters.
	For Each  project_name  In  Me.SettingFile.ProjectTags.Items
		GetDicItemOrError  Me.SettingFile.Projects,  project_name,  project_,  "Project"  '// Set "project_"
		For Each  module  In  project_.Modules.Items
			common_parent_path = GetCommonParentFolderPath( common_parent_path,  module.FullPathInMasters )
		Next
	Next
	Assert  Not  common_parent_path = ""


	'// Create "Project.xml.proja" files.
	For Each  project_tag_name  In  Me.SettingFile.ProjectTags.Keys
		project_name = Me.SettingFile.ProjectTags( project_tag_name )
		Set variables = CreateObject( "Scripting.Dictionary" )


		output_path = output_modules_path +"\_Assort\"+ project_tag_name +"\Project.xml.proja"
		Set proja = OpenForWrite( output_path,  g_VBS_Lib.UTF_8 )
		time_stamps( output_path ) = setting_time_stamp
		proja.Write  _
			"<?xml version=""1.0"" encoding=""UTF-8""?>"+ vbCRLF + _
			"<ModuleAssort2_Projects>"+ vbCRLF + _
			""+ vbCRLF + _
			"<Variable  name=""${Masters}""  value=""...\_Modules""  type=""FullPathType""/>"+ vbCRLF + _
			"<<Variables/>>"
		proja.WriteLine  ""

		proja.WriteLine  _
			"<ProjectTag  name="""+ project_tag_name +"""  value="""+ _
			Me.SettingFile.ProjectTags( project_tag_name ) +"""/>"
		proja.WriteLine  ""
		proja.WriteLine  "<Project  name="""+ project_name +""">"
		GetDicItemOrError  Me.SettingFile.Projects,  project_name,  project_,  "Project"  '// Set "project_"

		For Each  module  In  project_.Modules.Items

			proja.WriteLine  vbTab +"<Module  master="""+ module.PathInMasters + _
				"""  project="""+ module.PathInProject +"""/>"

			ParseDollarVariableString  module.PathInMasters,  Empty,  sub_variables_1
			ParseDollarVariableString  module.PathInProject,  Empty,  sub_variables_2
			Dic_addFromArray  variables,  sub_variables_1,  Empty
			Dic_addFromArray  variables,  sub_variables_2,  Empty
		Next
		proja.WriteLine  "</Project>"
		proja.WriteLine  ""
		GetDicItemOrError  Me.SettingFile.Projects,  project_name,  project_,  "Project"  '// Set "project_"

		For Each  module  In  project_.Modules.Items

			proja.WriteLine  "<FilesInModule  master="""+ module.PathInMasters +""">"
			If  NOT  g_fs.FileExists( module.FullPathInMasters +"\_FullSet.txt" ) Then
				Set ec = new EchoOff
				pushd  module.FullPathInMasters
				ec = Empty
				column_of_path = Len( module.FullPathInMasters ) + 2
				ExpandWildcard  "*",  c.File  or  c.SubFolder  or  c.EmptyFolder,  folder,  relative_paths
				For Each  relative_path  In  relative_paths

					proja.WriteLine  relative_path
				Next
				Set ec = new EchoOff
				popd
				ec = Empty
			Else
				column_of_path = GetColumnOfPathInFolderMD5List( module.FullPathInMasters +"\_FullSet.txt" )
				Set file = OpenForRead( module.FullPathInMasters +"\_FullSet.txt" )
				Do Until  file.AtEndOfStream
					line = file.ReadLine()

					proja.WriteLine  Mid( line,  column_of_path )
				Loop
				file = Empty
			End If
			proja.WriteLine  "</FilesInModule>"
		Next

		proja.WriteLine  _
			""+ vbCRLF + _
			"<Fragment  list=""${Masters}\MD5List.txt""/>"+ vbCRLF + _
			"</ModuleAssort2_Projects>"
		proja = Empty
		Set variable_tags = new StringStream
		For Each  name  In  variables.Keys
		If name <> "${Masters}" Then
			type_value = Me.SettingFile.Variables.Type_( name )
			If type_value <> "" Then _
				type_value = "  type="""+ type_value +""""

			variable_tags.WriteLine  "<Variable  name="""+ name +"""  value="""+ _
				Me.SettingFile.Variables.Formula( name ) +""""+ type_value +"/>"
		End If
		Next
		Set proja = OpenForReplace( output_path,  Empty )

		proja.Replace  "<<Variables/>>",  variable_tags.ReadAll()
		proja = Empty
	Next


	'// Create batch files.
	project_num = 0
	For Each  project_tag_name  In  Me.SettingFile.ProjectTags.Keys
		project_name = Me.SettingFile.ProjectTags( project_tag_name )
		GetDicItemOrError  Me.SettingFile.Projects,  project_name,  project_,  "Project"  '// Set "project_"

		batch = get_ModuleAssort2_PromptClass_BatchFileTemplate()
		batch = Replace( batch,  "${ProjectTagName}",  project_tag_name )
		batch = Replace( batch,  "${ProjectName}",  project_name )
		batch = Replace( batch,  "${T}",  vbTab )

		path = output_modules_path +"\_Assort\"+ project_tag_name +"\Assort.bat"
		CreateFile  path, batch
		time_stamps( path ) = setting_time_stamp
		project_num = project_num + 1
	Next

	path = output_modules_path +"\AssortAll.bat"
	Set file = OpenForWrite( path, Empty )
	time_stamps( path ) = setting_time_stamp
	file.WriteLine  "@echo off"
	file.WriteLine  ""
	For Each  project_tag_name  In  Me.SettingFile.ProjectTags.Keys
		project_name = Me.SettingFile.ProjectTags( project_tag_name )
		file.WriteLine  "echo."
		file.WriteLine  "pushd  _Assort\"+ project_tag_name
		file.WriteLine  "call  ..\ModuleAssortMini.bat  Assort  """+ _
			project_tag_name +"""  """+ project_name +"""  /no_input"
		file.WriteLine  "popd"
		file.WriteLine  ""
	Next
	file.WriteLine  "echo."
	file.WriteLine  "echo All projects are assorted."
	file.WriteLine  "if not ""%~1"" == ""/no_input"" ( pause )"
	file = Empty


	'// Check out projects.
	For Each  project_tag_name  In  Me.SettingFile.ProjectTags.Keys
		project_name = Me.SettingFile.ProjectTags( project_tag_name )
		echo  ""
		echo  project_tag_name

		Me.CheckOut  project_name,  GetFullPath( project_tag_name,  output_folder_path )
	Next


	'// ...
	For Each  file_name  In  Array( _
			"_Assort\ModuleAssortMini.vbs",  "_Assort\ModuleAssortMini.bat", _
			"README_jp.txt",  "README_en.txt" )

		copy_ren  Me.FilesPath +"\"+ file_name,  output_modules_path +"\"+ file_name
	Next

	SetDateLastModified  time_stamps

	MakeFolderMD5List  output_folder_path, _
		output_modules_path +"\MD5List.txt",  tc.TimeStamp or tc.BasePathIsList
End Sub


 
'***********************************************************************
'* Method: Assort
'*    Assort and Commit.
'*
'* Arguments:
'*    in_TargetModule - in_TargetModule or Empty(= All modules)
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::Assort
'***********************************************************************
Public Sub  Assort( ref_AppKey,  in_TargetModule )
	echo  ""
	Assert  not IsEmpty( Me.Current.Project )
	GetDicItemOrError  Me.SettingFile.Projects,  Me.Current.ProjectName,  project_,  "Project"  '// Set "project_"
		AssertD_TypeName  project_, "ModuleAssort2_ProjectInFileClass"
	warning_count = 0
	Set tc = get_ToolsLibConsts()
	Set ds_ = new CurDirStack
	Set c = g_VBS_Lib
	Me.WorkingModules.ToEmpty
	Const  c_NotCaseSensitive = 1
	empty_folder_MD5 = tc.EmptyFolderMD5
	Set work_paths = CreateObject( "Scripting.Dictionary" )
	work_paths.CompareMode = c_NotCaseSensitive
	Set fragmenting_paths = new ArrayClass
	base_path_in_MD5_list = g_fs.GetParentFolderName( Me.SettingFile.FragmentListFullPath )
	Const  length_of_hash = 32  '// MD5
	debugging_path = "?"  '// Set "?" if disable
	If debugging_path <> "?" Then _
		SetBreakByFName  debugging_path


	'// Set "new_leaves" : New files and empty folders.
	Set new_leaves = CreateObject( "Scripting.Dictionary" )
	If IsEmpty( in_TargetModule ) Then
If False Then  '// TODO:
	Set new_leaves = EnumerateToLeafPathDictionary( Me.Current.Project.FullPath )
		'// This has Full Path.
Else
		EnumFolderObjectDic  Me.Current.Project.FullPath,  Empty, folders  '// Set "folders"
		For Each  folder_relative_path  In  folders.Keys
			Set folder = folders( folder_relative_path )
			If folder.Files.Count = 0 Then
				If folder.SubFolders.Count = 0 Then
					new_leaves( folder_relative_path ) = True
				End If
			Else
				If folder_relative_path <> "." Then
					For Each  file  In  folder.Files
						new_leaves( folder_relative_path +"\"+ file.Name ) = True
					Next
				Else
					For Each  file  In  folder.Files
						new_leaves( file.Name ) = True
					Next
				End If
			End If
		Next
End If
	Else  '// in_TargetModule
		EnumFolderObjectDic  in_TargetModule.FullPathInMasters,  Empty, folders  '// Set "folders"
		For Each  folder_relative_path  In  folders.Keys
			Set folder = folders( folder_relative_path )
			If folder.Files.Count = 0 Then
				If folder.SubFolders.Count = 0 Then
					folder_full_path = GetFullPath( folder_relative_path, _
						in_TargetModule.FullPathInWorkProject )
					If g_fs.FolderExists( folder_full_path ) Then _
						new_leaves( GetRelativePath( folder_full_path,  Me.Current.Project.FullPath ) ) = True
				End If
			Else
				For Each  file  In  folder.Files
					file_full_path = GetFullPath( folder_relative_path +"\"+ file.Name, _
						in_TargetModule.FullPathInWorkProject )
					If g_fs.FileExists( file_full_path ) Then _
						new_leaves( GetRelativePath( file_full_path,  Me.Current.Project.FullPath ) ) = True
				Next
			End If
		Next
	End If
	Set exists_in_project = CreateObject( "Scripting.Dictionary" )
		'// Key = step path in project,  Item = path in master


	'// Block: モジュールのループ
	For Each  module  In  Me.Current.Project.Modules.Items
		AssertD_TypeName  module, "ModuleAssort2_ModuleInFileClass"
	If IsEmpty( in_TargetModule ) Then
		do_it = True
	Else
		do_it = ( module  is  in_TargetModule )
	End If
	If do_it Then

		Me_ReadOnlyWarningCount = 0

		echo  module.PathInMasters


		'//    C:\Masters\ModuleA\01\SubFile.txt  C:\Project----\ModuleA------------------\Sub\File.txt
		'//       ^committed_path                 ^project_path  ^file_relative_path_long  ^file_relative_path_short

		committed_path = module.FullPathInMasters
		work_path = g_fs.GetParentFolderName( committed_path ) +"\Work"
		If work_paths.Exists( work_path ) Then
			echo _
				"    <WARNING msg=""Work フォルダーが重複しています。"""+ vbCRLF + _
				"     work="""+ work_path +""""+ vbCRLF + _
				"     commit_1="""+ work_path +"\"+ work_paths( work_path ) +""""+ vbCRLF + _
				"     commit_2="""+ work_path +"\"+ g_fs.GetFileName( committed_path ) +"""/>"+ vbCRLF
			warning_count = warning_count + 1
		End If
		work_paths( work_path ) = g_fs.GetFileName( committed_path )
		project_path = module.FullPathInWorkProject
		project_relative_path = GetRelativePath( project_path,  Me.Current.Project.FullPath )
		Set assorted_paths = CreateObject( "Scripting.Dictionary" )
		Set time_stamps_in_master  = CreateObject( "Scripting.Dictionary" )
		Set time_stamps_in_project = CreateObject( "Scripting.Dictionary" )
		Set time_stamps_ks_in_project = CreateObject( "Scripting.Dictionary" )
		Set not_read_onlys = new ArrayClass
		Set w_= ref_AppKey.NewWritable( Array( committed_path,  work_path,  project_path ) ).Enable()


		If not g_fs.FolderExists( project_path ) Then
			echo _
				"    <WARNING msg=""プロジェクトにフォルダーがありません"""+ vbCRLF + _
				"     master="""+ module.PathInMasters +""""+ vbCRLF + _
				"     master_path="""+ module.FullPathInMasters +""""+ vbCRLF + _
				"     project="""+ project_path +""""+ vbCRLF + _
				"     relative_path="".""/>"+ vbCRLF
			warning_count = warning_count + 1
			is_committed = False


		ElseIf g_fs.FolderExists( committed_path ) Then

			is_committed = True
			Set ks_files = CreateObject( "Scripting.Dictionary" )  '// Files with Keyword Substitution
			is_new_work = not exist( work_path )

			Set leaves = CreateObject( "Scripting.Dictionary" )

			Set committed_leaves = EnumerateToLeafPathDictionaryByFullSetFile( _
				committed_path,  Me.SettingFile.FragmentListFullPath,  Empty )
			For Each  relative_path  In  committed_leaves.Keys
				Set committed_leaf = committed_leaves( relative_path )

				Set leaf = Dic_addNewObject( leaves,  "ModuleAssort2_RelativePathClass",  relative_path,  True )
				leaf.CommittedBodyFullPath = committed_leaf.BodyFullPath
				leaf.CommittedHashValue = committed_leaf.HashValue
				leaf.CommittedTimeStamp = committed_leaf.TimeStamp
				If is_new_work Then
					leaf.MasterBodyFullPath = committed_leaf.BodyFullPath
					leaf.MasterHashValue    = committed_leaf.HashValue
				End If
			Next

			If NOT is_new_work Then
				Set work_leaves = EnumerateToLeafPathDictionaryByFullSetFile( _
					work_path,  Me.SettingFile.FragmentListFullPath,  Empty )
				For Each  relative_path  In  work_leaves.Keys
					Set work_leaf = work_leaves( relative_path )

					Set leaf = Dic_addNewObject( leaves,  "ModuleAssort2_RelativePathClass",  relative_path,  True )
					leaf.WorkHashValue      = work_leaf.HashValue
					leaf.MasterBodyFullPath = work_leaf.BodyFullPath
					leaf.MasterHashValue    = work_leaf.HashValue
				Next
			End If
			is_full_set_file = Empty
			is_work_only_file = False
			is_commit_only_file = False
			Set ec = new EchoOff


			cd  project_path
			ec = Empty


			'// Set "TypeInProject"
			For Each  relative_path  In  leaves.Keys
				Set leaf = leaves( relative_path )  '// as ModuleAssort2_RelativePathClass
				If g_fs.FileExists( relative_path ) Then

					leaf.TypeInProject = c.File
				ElseIf g_fs.FolderExists( relative_path ) Then
					leaf.TypeInProject = c.EmptyFolder
				Else
					leaf.TypeInProject = c.NotFound
				End If
			Next


			'// Block: ファイルのループ
			For Each  relative_path  In  leaves.Keys

				Set leaf = leaves( relative_path )  '// as ModuleAssort2_RelativePathClass

				'// Set "relative_path_in_project"
				If project_relative_path <> "." Then
					relative_path_in_project = project_relative_path +"\"+ relative_path
				Else
					relative_path_in_project = relative_path
				End If


				'// Call "new_leaves.Remove"
				If new_leaves.Exists( relative_path_in_project ) Then
					If is_new_work Then
						is_in_masters = not IsEmpty( leaf.CommittedHashValue )
					Else
						is_in_masters = not IsEmpty( leaf.WorkHashValue )
					End If
					If is_in_masters  and  leaf.TypeInProject <> c.NotFound Then

						new_leaves.Remove  relative_path_in_project
						exists_in_project.Add  relative_path_in_project,  committed_path +"\"+ relative_path
					End If
				ElseIf exists_in_project.Exists( relative_path_in_project ) Then
					previous_committed_path = exists_in_project( relative_path_in_project )
					If IsEmpty( is_full_set_file ) Then
						If is_new_work Then
							is_full_set_file = g_fs.FileExists( committed_path +"\_FullSet.txt" )
						Else
							is_full_set_file = g_fs.FileExists( work_path +"\_FullSet.txt" )
						End If
					End If

					echo _
						"    <WARNING msg=""ファイル、または、_FullSet.txt の行が重複しています"""+ vbCRLF + _
						"     master_1="""+ previous_committed_path +""""
					If is_full_set_file Then
						echo _
						"     master_2="""+ committed_path +"\"+ relative_path +""""+ vbCRLF + _
						"     is_2_in_full_set_txt=""yes""/>"
					Else
						echo _
						"     master_2="""+ committed_path +"\"+ relative_path +"""/>"
					End If
					warning_count = warning_count + 1
				End If


				If IsEmpty( leaf.CommittedHashValue ) Then
					is_work_only_file = True

				ElseIf IsEmpty( leaf.MasterHashValue ) Then
					is_commit_only_file = True


				'// Case of a file
				ElseIf leaf.MasterHashValue <> empty_folder_MD5 Then
					If IsEmpty( module.IsFillKS ) Then
						is_fill_KS = project_.IsFillKS
					Else
						is_fill_KS = module.IsFillKS
					End If

					If is_fill_KS Then


						'// Block: Keyword Substitution を更新する。
						result_of_KS = Me.AssortKeywordSubstitution( module, _
							leaf.CommittedBodyFullPath,  leaf.CommittedTimeStamp, _
							work_path +"\"+ relative_path, _
							relative_path )
						Select Case  result_of_KS
							Case  Me.Constant.NoKS
								file_path_of_work = project_path +"\"+ relative_path
							Case  Me.Constant.UpdatedKS
								file_path_of_work = work_path +"\"+ relative_path
								assorted_paths( work_path +"\"+ relative_path ) = _
									work_path +"\"+ relative_path
							Case  Me.Constant.MasterCopy
								not_read_onlys.Add  project_path +"\"+ relative_path
								assorted_paths( work_path +"\"+ relative_path ) = leaf.CommittedBodyFullPath
									'// 後で Defrag する。
								If not IsEmpty( leaf.CommittedTimeStamp ) Then
									time_stamp = W3CDTF( leaf.CommittedTimeStamp )
									time_stamps_in_master(  work_path    +"\"+ relative_path ) = time_stamp
									time_stamps_in_project( project_path +"\"+ relative_path ) = time_stamp
								End If
							Case Else
								Error
						End Select

					Else '// NOT is_fill_KS
						file_path_of_work = project_path +"\"+ relative_path
						result_of_KS = Me.Constant.NoKS
					End If

					If result_of_KS <> Me.Constant.MasterCopy Then
						Assert  not IsEmpty( leaf.MasterBodyFullPath )


						'// Block: コミット済みのフォルダーと同じかどうかチェックする。
						'// KS があるときは、更新後のテキストをチェックする。
						If NOT IsEmpty( leaf.CommittedHashValue ) Then
							If not IsSameBinaryFile( _
									file_path_of_work, _
									leaf.CommittedBodyFullPath, _
									Empty ) Then
								If is_committed Then  '// Show only one warning
									If IsEmpty( is_full_set_file ) Then
										If is_new_work Then
											is_full_set_file = g_fs.FileExists( committed_path +"\_FullSet.txt" )
										Else
											is_full_set_file = g_fs.FileExists( work_path +"\_FullSet.txt" )
										End If
									End If

									If is_full_set_file Then
										echo _
											"    <WARNING msg=""ハッシュ値（＝ファイルの内容）に違いがあります"""+ vbCRLF + _
											"     master="""+ module.PathInMasters +"\_FullSet.txt"""
									Else
										echo _
											"    <WARNING msg=""違いがあります"""+ vbCRLF + _
											"     master="""+ module.PathInMasters +""""
									End If
									echo _
										"     project="""+ module.PathInProject +""""+ vbCRLF + _
										"     relative_path="""+ relative_path +"""/>"+ vbCRLF
									warning_count = warning_count + 1
									is_committed = False
								End If

							Else
								If IsEmpty( leaf.CommittedTimeStamp ) Then _
									leaf.CommittedTimeStamp = g_fs.GetFile( _
										leaf.CommittedBodyFullPath ).DateLastModified
								If VarType( leaf.CommittedTimeStamp ) = vbString Then _
									leaf.CommittedTimeStamp = W3CDTF( leaf.CommittedTimeStamp )
								committed_time_stamp = leaf.CommittedTimeStamp
								If result_of_KS = Me.Constant.UpdatedKS  or  not  is_fill_KS Then

										time_stamps_in_master( work_path +"\"+ relative_path ) = _
											committed_time_stamp
								End If
								If is_fill_KS Then
									time_stamps_ks_in_project( project_path +"\"+ relative_path ) = _
										committed_time_stamp
								Else
									time_stamps_in_project( project_path +"\"+ relative_path ) = _
										committed_time_stamp
								End If
							End If
						Else
							If result_of_KS = Me.Constant.NoKS Then
								Set ec = new EchoOff

								copy_ren  project_path +"\"+ relative_path,  work_path +"\"+ relative_path
								ec = Empty
							End If
						End If
					End If


				'// Block: Empty フォルダーがあるかどうかをチェックします。
				Else  '// is_empty_folder


					If is_committed Then  '// Show only one warning
						If not g_fs.FolderExists( project_path +"\"+ relative_path ) Then
							If IsEmpty( is_full_set_file ) Then
								If is_new_work Then
									is_full_set_file = g_fs.FileExists( committed_path +"\_FullSet.txt" )
								Else
									is_full_set_file = g_fs.FileExists( work_path +"\_FullSet.txt" )
								End If
							End If

							If is_full_set_file Then
								echo _
								"    <WARNING msg=""ハッシュ値（＝ファイルの内容）に違いがあります"""+ vbCRLF + _
								"     master="""+ module.PathInMasters +"\_FullSet.txt"""
							Else
								echo _
								"    <WARNING msg=""プロジェクトにフォルダーがありません"""+ vbCRLF + _
								"     master="""+ module.PathInMasters +""""
							End If
							echo _
								"     project="""+ module.PathInProject +""""+ vbCRLF + _
								"     relative_path="""+ relative_path +"""/>"+ vbCRLF
							warning_count = warning_count + 1
							is_committed = False
						End If
					End If
				End If
			Next


			'// Block: ファイルの構成（数）をチェックする。
			If is_work_only_file  or  is_commit_only_file Then
				echo _
					"    <WARNING msg=""ファイルの構成が異なります。"""+ vbCRLF + _
					"     masters_path="""+ committed_path +""""+ vbCRLF + _
					"     work_path   ="""+ work_path +"""/>"+ vbCRLF
				warning_count = warning_count + 1
				is_committed = False
			End If


			If g_debug_var(9) = 1 Then
				echo_v  "Step 4. Create Work folder"
				Stop
			End If


			If is_committed  and  exist( work_path ) Then
				Set ec = new EchoOff
				cd  g_fs.GetParentFolderName( committed_path )
				ec = Empty
				If is_new_work Then _
					Set ec = new EchoOff

				'// 一時ファイルを削除します。
				del  work_path

				If is_new_work Then _
					ec = Empty

				If g_fs.FileExists( committed_path +"\_FullSet.txt" ) Then
					fragmenting_paths.Add  committed_path
				End If


			'// Block: 新しく Work フォルダーを作成する。
			'// Work フォルダーにファイルを存在させることで、後でコピーをする対象にする。
			ElseIf not is_committed  and  ( not exist( work_path )  or  is_new_work ) Then
				echo  "    プロジェクトから抽出したモジュール： "+ _
					g_fs.GetParentFolderName( module.PathInMasters ) +"\Work"
				echo  ""
				Set ec = new EchoOff
				If  NOT  g_fs.FileExists( committed_path +"\_FullSet.txt" ) Then
					copy_ex  committed_path +"\*",  work_path,  c.NotExistOnly
				Else
					copy  committed_path +"\_FullSet.txt",  work_path
				End If
				ec = Empty
			End If


			'// Block: Work フォルダーにファイルをコピーする。
			If g_fs.FolderExists( work_path ) Then
				Me.WorkingModules.Add  module
				Set ec = new EchoOff

				cd  work_path

				SetReadOnlyAttribute  work_path,  False


				If  Not  g_fs.FileExists( work_path +"\_FullSet.txt" ) Then
					For Each  relative_path  In  leaves.Keys
						Set leaf = leaves( relative_path )  '// as ModuleAssort2_RelativePathClass
						full_path_in_project = project_path +"\"+ relative_path
						If is_new_work Then
							hash_in_masters = leaf.MasterHashValue
						Else
							hash_in_masters = leaf.WorkHashValue
						End If

						If hash_in_masters = empty_folder_MD5 Then
							If g_fs.FolderExists( full_path_in_project ) Then
								mkdir  full_path_in_project
							Else
								del  relative_path
							End If

						ElseIf not IsEmpty( hash_in_masters ) Then  '// File
							If project_relative_path <> "." Then
								relative_path_in_project = project_relative_path +"\"+ relative_path
							Else
								relative_path_in_project = relative_path
							End If
							full_path_in_work = work_path +"\"+ relative_path

							If not assorted_paths.Exists( full_path_in_work ) Then
								If exists_in_project.Exists( relative_path_in_project ) Then
									If g_fs.FileExists( full_path_in_project ) Then

										copy_ren  full_path_in_project,  relative_path
										If new_leaves.Exists( file_relative_path ) Then
											new_leaves.Remove  file_relative_path
											exists_in_project.Add  file_relative_path,  full_path_in_work
										End If
									Else
										del  relative_path
									End If
								Else
									del  relative_path
								End If
							Else  '// Already exist
								assorted_path = assorted_paths( full_path_in_work )
								If assorted_path <> full_path_in_work Then

									copy_ren  assorted_path,  full_path_in_work
									SetReadOnlyAttribute  full_path_in_work,  False
								End If
							End If
						End If
					Next

				ElseIf not g_fs.FolderExists( project_path ) Then
					'// Already warned

				Else  '// If g_fs.FileExists( work_path +"\_FullSet.txt" )
					If IsEmpty( Me.Defragmenter ) Then _
						Raise  1, "_FullSet.txt ファイルが見つかりました。 Fragment/@list 属性を設定してください。"

					cd  project_path

					column_of_path = GetColumnOfPathInFolderMD5List( work_path +"\_FullSet.txt" )
					column_of_hash = column_of_path - length_of_hash - 1
					Set deleting_paths = new ArrayClass

					'// Update "Work\_FullSet.txt".
					Set rep = StartReplace( work_path +"\_FullSet.txt",  work_path +"\_FullSet_next.txt",  False )
					Do Until rep.r.AtEndOfStream
						SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf  '// Set "line", "cr_lf"
						relative_path = Mid( line,  column_of_path )
						hash_in_master = Mid( line,  column_of_hash,  length_of_hash )
						hash_in_project = Empty
						full_path_in_work = work_path +"\"+ relative_path
						If hash_in_master <> empty_folder_MD5 Then  '// If a file in _FullSet.txt
							If g_fs.FileExists( relative_path ) Then
								If not assorted_paths.Exists( full_path_in_work ) Then

									hash_in_project = ReadBinaryFile( relative_path ).MD5
								Else
									assorted_path = assorted_paths( full_path_in_work )
									hash_in_project = ReadBinaryFile( assorted_path ).MD5
								End If
							ElseIf g_fs.FolderExists( relative_path ) Then
								hash_in_project = empty_folder_MD5
							Else
								hash_in_project = Empty
							End If

							If hash_in_master <> hash_in_project  and  not IsEmpty( hash_in_project ) Then

								line = hash_in_project +" "+ relative_path
								If column_of_hash >= 2 Then
									line = _
										W3CDTF( g_fs.GetFile( relative_path ).DateLastModified ) +" "+ _
										line
								End If

								If hash_in_project <> empty_folder_MD5 Then
									If not assorted_paths.Exists( full_path_in_work ) Then

										copy_ren  relative_path,  full_path_in_work
									End If
								Else
									mkdir  full_path_in_work
								End If
							End If
						Else  '// Empty Folder
							If g_fs.FolderExists( relative_path ) Then
								hash_in_project = empty_folder_MD5
							Else
								hash_in_project = Empty
							End If
						End If
						If not IsEmpty( hash_in_project ) Then

							rep.w.WriteLine  line + cr_lf

							'// Copy no KS file or folder of new hash in "Work\_FullSet.txt".
							If not assorted_paths.Exists( full_path_in_work ) Then
								If hash_in_project = empty_folder_MD5 Then
									If not g_fs.FolderExists( full_path_in_work ) Then
										del    full_path_in_work
										mkdir  full_path_in_work
									End If
								Else
									If not g_fs.FileExists( full_path_in_work ) Then
										del    full_path_in_work
										copy_ren  relative_path,  full_path_in_work
									End If
								End If
							End If
						Else
							deleting_paths.Add  work_path +"\"+ relative_path
						End If
					Loop
					rep.Finish


					'// Defragment
					If exist( committed_path +"\_FullSet.txt" ) Then
						Set defrag_from_committed = OpenForDefragment( committed_path +"\_FullSet.txt", Empty )
						defrag_from_committed.CopyFolder  committed_path,  committed_path,  _
							committed_path,  c.NotExistOnly or c.ExistOnly
					End If

					Me.Defragmenter.CopyFolder  base_path_in_MD5_list,  work_path,  work_path, _
						c.NotExistOnly  or  c.ToNotReadOnly

					For Each  full_path_in_work  In  assorted_paths.Keys
						assorted_path = assorted_paths( full_path_in_work )
						If assorted_path <> full_path_in_work Then
							copy_ren  assorted_path,  full_path_in_work
							SetReadOnlyAttribute  full_path_in_work,  False
						End If
					Next

					For Each  path  In  deleting_paths.Items
						del  path
					Next
				End If
				ec = Empty
			End If


			If g_debug_var(9) = 1 Then
				echo_v  "Step 5. SetDateLastModified"
				Stop
			End If
			g_debug_var(9) = Empty


			'// Call "SetDateLastModified"
			For Each  full_path  In  time_stamps_in_master.Keys
				If not exist( full_path ) Then _
					time_stamps_in_master.Remove  full_path
			Next
			For Each  full_path  In  time_stamps_ks_in_project.Keys
				If not exist( full_path ) Then _
					time_stamps_ks_in_project.Remove  full_path
			Next
			For Each  full_path  In  time_stamps_in_project.Keys
				If not exist( full_path ) Then _
					time_stamps_in_project.Remove  full_path
			Next

			SetDateLastModified    time_stamps_in_master
			SetDateLastModifiedKS  time_stamps_ks_in_project,  Empty
			SetDateLastModified    time_stamps_in_project
			For Each  path  In  not_read_onlys.Items
				SetReadOnlyAttribute  path,  False
			Next


			'// Block: リビジョンのフォルダーをデフラグメントする。
			If not is_committed  and  exist( committed_path +"\_FullSet.txt" ) Then
				echo  "    _FullSet.txt の内容でデフラグメントします。"
				echo  ""
				Set ec = new EchoOff

				Me.Defragmenter.CopyFolder  base_path_in_MD5_list,  committed_path, _
					committed_path,  c.NotExistOnly
				ec = Empty
			End If


			w_=Empty
		Else
			echo  "    <WARNING msg=""使用するマスターフォルダーが存在しません。"""+ vbCRLF + _
				"     master="""+ module.PathInMasters +""""+ vbCRLF + _
				"     master_path="""+ module.FullPathInMasters +"""/>"+ vbCRLF

			key = Input( "フォルダーを作成しますか。[Y/N]" )
			If key = "y"  or  key = "Y" Then
				Set w_= ref_AppKey.NewWritable( module.FullPathInMasters ).Enable()

				mkdir  module.FullPathInMasters
				w_= Empty
				echo  ""
			Else
				warning_count = warning_count + 1
				Me.WorkingModules.Add  module
			End If
		End If
	End If
	Next


	'// Fragment
	Set ec = new EchoOff
	For Each  path  In  fragmenting_paths.Items
		Set w_= ref_AppKey.NewWritable( path ).Enable()

		Me.Defragmenter.Fragment  base_path_in_MD5_list,  path,  Empty

		w_= Empty
	Next
	ec = Empty


	'// Block: WorkNewFiles フォルダーを作成する。
	Set module = GetFirst( Me.Current.Project.Modules.Items )
	If InStr( g_fs.GetFileName( module.PathInMasters ), "${" ) = 0 Then
		Me.Current.WorkNewModulePath = g_fs.GetParentFolderName( module.PathInMasters ) +"\WorkNewFiles"
	Else
		Me.Current.WorkNewModulePath = module.PathInMasters +"\..\WorkNewFiles"
	End If
	Me.Current.WorkNewModuleFullPath = GetFullPath( "..\WorkNewFiles",  module.FullPathInMasters )
	Set w_= ref_AppKey.NewWritable( Me.Current.WorkNewModuleFullPath ).Enable()
	If IsEmpty( in_TargetModule ) Then
		Set ec = new EchoOff
		del  Me.Current.WorkNewModuleFullPath
		ec = Empty
	End If

	If new_leaves.Count >= 1 Then
		warning_count = warning_count + 1
		project_path = Me.Current.Project.FullPath

		echo  Me.Current.WorkNewModulePath

		Set ec = new EchoOff
		Set file = OpenForWrite( Me.Current.WorkNewModuleFullPath +"\_FullSet.txt",  c.UTF_8 )
		For Each  relative_path  In  new_leaves.Keys
			path_in_project = project_path +"\"+ relative_path
			full_path_in_work = _
				Me.Current.WorkNewModuleFullPath +"\"+ ReplaceParentPath( relative_path, "..", "_parent" )
			exists_in_project( relative_path ) = full_path_in_work

			copy_ren  path_in_project,  full_path_in_work

			If g_fs.FileExists( path_in_project ) Then
				line = _
					W3CDTF( g_fs.GetFile( path_in_project ).DateLastModified ) +" "+ _
					ReadBinaryFile( path_in_project ).MD5 +" "+ _
					relative_path

				file.WriteLine  line

			ElseIf g_fs.FolderExists( path_in_project ) Then
				line = _
					W3CDTF( g_fs.GetFolder( path_in_project ).DateLastModified ) +" "+ _
					empty_folder_MD5 +" "+ _
					relative_path

				file.WriteLine  line
			End If
		Next
		ec = Empty
		file = Empty

		echo  "    <WARNING msg=""WorkNewFiles フォルダーにできたファイルを、"+ vbCRLF + _
			"    該当するモジュールの Work フォルダーに移動してください。"+ vbCRLF + _
			"    Work フォルダーに _FullSet.txt ファイルがあるときは、"+ vbCRLF + _
			"    WorkNewFiles\_FullSet.txt から行を移動してください。"+ vbCRLF + _
			"    ただし、行末のパスは、基準が _FullSet.txt ファイルがある"+ vbCRLF + _
			"    フォルダーになるように変更してください。""/>"
	Else
		Me.Current.WorkNewModulePath = Empty
		Me.Current.WorkNewModuleFullPath = Empty
	End If
	w_= Empty


	If not IsEmpty( in_TargetModule ) Then
		echo  "    <WARNING msg=""すべてのモジュールを同時にアソートしていません。""/>"
		warning_count = warning_count + 1


		For Each  old_module  In  Me.OldPrompt.WorkingModules.Items
			For Each  new_module  In  project_.Modules.Items
				If old_module.PathInMasters = new_module.PathInMasters Then
					If old_module.PathInMasters <> in_TargetModule.PathInMasters Then
						Me.WorkingModules.Add  new_module
					End If
				End If
			Next
		Next
	End If


	If False Then
		For Each  relative_path  In  exists_in_project.Keys

			echo_v  GetFullPath( relative_path,  Me.Current.Project.FullPath ) +" => "+ _
				exists_in_project( relative_path )
		Next
	End If


	If warning_count = 0 Then
		echo  ""
		echo  "正しくチェックアウトできるか確認しています ..."


		'// Block: 一時的なファイル リストからチェックアウトできるかチェックする。
		check_out_path = GetTempPath( "__CheckOutTest" )
		echo  check_out_path
		echo  ""

		Set ec = new EchoOff
		del  check_out_path
		ec = Empty
		hash_list = GetTempPath( "__WorkProject_MD5List.txt" )

		Me.CheckOut  Me.Current.ProjectName,  check_out_path

		echo  ""
		Assert  GetFullPath( check_out_path,  Empty ) <> GetFullPath( Me.Current.Project.FullPath,  Empty )
		MakeFolderMD5List  Me.Current.Project.FullPath,  hash_list,  Empty  '// Write to "hash_list"
		CheckFolderMD5List  check_out_path,  hash_list,  Empty
		echo  ""

		echo  Me.Current.ProjectName
		echo  "を正しくチェックアウトできることを確認しました。"
		echo  "下記 date 属性を設定ファイルに追加することをお勧めします。"
		echo  ""
		echo  "  <Project  name="""+ Me.Current.ProjectName +""""
		echo  "            date="""+ W3CDTF( Now() ) +""">"

		For Each  module  In  project_.Modules.Items
			If StrCompLastOf( g_fs.GetFileName( module.FullPathInMasters ), "_Tmp", Empty ) = 0 Then
				echo  "<WARNING msg=""リビジョン名に _Tmp が含まれています。""/>"
				Exit For
			End If
		Next

		key = Input( "コミットしますか[Y/N]" )
		is_commit = ( key = "y"  or  key = "Y" )

		Set ec = new EchoOff
		del  check_out_path
		ec = Empty
	Else
		is_commit = False
	End If


	'// Block: Commit
	If is_commit Then
		echo  ""


		'// Set read only
		For Each  module  In  Me.Current.Project.Modules.Items
			SetReadOnlyAttribute  module.FullPathInMasters,  True
		Next


		'// Block: 新しいファイルのハッシュ値を Defragmenter に追加する。
		If not IsEmpty( Me.Defragmenter ) Then
			Set ec = new EchoOff
			For Each  module  In  Me.Current.Project.Modules.Items
				AssertD_TypeName  module, "ModuleAssort2_ModuleInFileClass"

				Me.Defragmenter.Append  Empty,  base_path_in_MD5_list, _
					module.FullPathInMasters,  Empty
			Next
			ec = Empty
			Set w_= ref_AppKey.NewWritable( Me.SettingFile.FragmentListFullPath ).Enable()

			Me.Defragmenter.Save  Me.SettingFile.FragmentListFullPath
			w_= Empty
		End If


		'// Block: ファイル リストを作成する。

		'// Set "used_variables" : 使用している変数を集める
		Set expressions = new ArrayClass
		expressions.Add  Me.Current.Project.Path
		'//expressions.Add  Me.Current.Project.FilesPath
		For Each  module  In  Me.Current.Project.Modules.Items
			expressions.Add  module.PathInMasters
			expressions.Add  module.PathInProject
		Next
		Set used_variables = CreateObject( "Scripting.Dictionary" )
		For Each  expression  In  expressions.Items

			ParseDollarVariableString  expression,  Empty,  variables
			For Each  variable  In  variables

				used_variables( variable ) = True
			Next
		Next


		'// Make temporary file list.
		Set ec = new EchoOff
		proja_path = GetTempPath( "__making_ProjectFiles.xml.proja" )
		Set file = OpenForWrite( proja_path,  c.UTF_8 )
		ec = Empty
		file.WriteLine  "<?xml version=""1.0"" encoding=""UTF-8""?>"
		file.WriteLine  "<ModuleAssort2_Files>"

		Set g = Me.SettingFile.Variables
		For Each  variable_name  In  g.Keys
			If not IsFullPath( g.Formula( variable_name ) ) Then
				file.WriteLine  "<Variable  name="""+ variable_name +"""  value="""+ _
					g.Formula( variable_name ) +"""/>"
			Else
				file.WriteLine  "<Variable  name="""+ variable_name +"""  value="""+ _
					GetRelativePath( g.Formula( variable_name ),  base_path ) + _
					"""  type=""FullPathType""/>"
			End If
		Next
		file.WriteLine  ""
		max_length_of_module = 0
		For Each  module  In  Me.Current.Project.Modules.Items
			If Len( module.PathInMasters ) > max_length_of_module Then _
				max_length_of_module = Len( module.PathInMasters )
		Next

		file.WriteLine  "<Project  name="""+ Me.Current.ProjectName +">"
		For Each  module  In  Me.Current.Project.Modules.Items
			spaces = String( max_length_of_module - Len( module.PathInMasters ),  " " )
			file.WriteLine  "<Module  master="""+ module.PathInMasters + """  "+ spaces + _
				"project="""+ module.PathInProject +"""/>"
		Next
		file.WriteLine  "</Project>"
		file.WriteLine  ""

		file.WriteLine  "<ProjectFiles  name="""+ Me.Current.ProjectName +">"
		For Each  module  In  Me.Current.Project.Modules.Items
			Set writing_lines = new ArrayClass
			spaces = String( max_length_of_module - Len( module.PathInMasters ),  " " )

			full_set_txt = module.FullPathInMasters +"\_FullSet.txt"
			If g_fs.FileExists( full_set_txt ) Then
				column_of_path = GetColumnOfPathInFolderMD5List( full_set_txt )
				column_of_hash = column_of_path - length_of_hash - 1
				If column_of_hash >= 2 Then  '// If date exists
					length_of_date = column_of_hash - 2
				Else
					length_of_date = 0
				End If

				Set full_file = OpenForRead( full_set_txt )
				Do Until  full_file.AtEndOfStream
					reading_line = full_file.ReadLine()
					relative_path = Mid( reading_line,  column_of_path )
					Set writing_line = new NameOnlyClass
					writing_line.Name = relative_path

					writing_line.Delegate = "date="""+ Left( reading_line,  length_of_date ) + _
						"""  hash="""+ Mid( reading_line,  column_of_hash,  length_of_hash ) +"""  "
					writing_lines.Add  writing_line
				Loop
			Else
				EnumFolderObject  module.FullPathInMasters,  folders  '// Set "folders"
				For Each  folder  In folders  '// folder as Folder Object
					For Each  a_file  In  folder.Files '// a_file as File Object
						file_path = a_file.Path
						Set writing_line = new NameOnlyClass
						writing_line.Name = GetRelativePath( file_path,  module.FullPathInMasters )

						writing_line.Delegate = "date="""+ W3CDTF( a_file.DateLastModified ) + _
							"""  hash="""+ GetHashOfFile( file_path, "MD5" ) +"""  "
						writing_lines.Add  writing_line
					Next
				Next
			End If

			QuickSort  writing_lines,  0,  writing_lines.UBound_,  GetRef("PathNameCompare"),  Empty
			For Each  writing_line  In  writing_lines.Items
				If module.PathInProject = "." Then
					relative_path = writing_line.Name
				Else
					relative_path = module.PathInProject +"\"+ writing_line.Name
				End If

				file.WriteLine  "<File  "+ writing_line.Delegate + "module="""+ module.PathInMasters + _
					"""  "+ spaces +"path="""+ relative_path +"""/>"
			Next
		Next
		file.WriteLine  "</ProjectFiles>"
		file.WriteLine  "</ModuleAssort2_Files>"
		file = Empty
		ec = Empty
	End If

	echo  ""
	echo  "警告の数 = "+ CStr( warning_count )
End Sub


 
'***********************************************************************
'* Method: AssortKeywordSubstitution
'*    KeywordSubstitution の値を編集します。
'*
'* Return Value:
'*    Me.Constant の NoKS, UpdatedKS, MasterCopy
'*
'* Description:
'*    編集する対象は、"$ModuleRevision", "$Date", "$Version" です。
'*    編集しなければ、in_FilePathInModuleWork 引数のファイルを作りません。
'*    プロジェクトにあるファイルは、Keyword Substitution の値を更新します。
'*    マスターに入れるファイルは、Keyword Substitution の値をカットします。
'***********************************************************************
Public Function  AssortKeywordSubstitution( in_Module, _
		in_CommittedFilePath,  in_TimeStampInFullSetTxt, _
		in_FilePathInModuleWork,  in_FilePathInProject )

	AssertD_TypeName  in_Module, "ModuleAssort2_ModuleInFileClass"
	Set ec = new EchoOff
	Set c = g_VBS_Lib
	If not exist( in_FilePathInProject )  or _
			not g_Vers("TextFileExtension").Exists( g_fs.GetExtensionName( in_FilePathInProject ) ) Then
		AssortKeywordSubstitution = Me.Constant.NoKS
		Exit Function
	End If


	'// Set "ks_re". ks = Keyword Substitution's Regular Expression
	Set ks_re = Me.RegExpOfKeywordSubstitution


	'// Set "text_in_work"
	'// Set "ks_matches_reverse". ks = KeywordSubstitution
	If g_fs.FileExists( in_FilePathInModuleWork ) Then _
		SetReadOnlyAttribute  in_FilePathInModuleWork,  False

	Set file = OpenForReplace( in_FilePathInProject,  in_FilePathInModuleWork )

	text_in_work = Me.ChangeToEmptyKS( file.Text,  ks_matches_reverse )  '// Set "ks_matches_reverse"
	count_of_ks_reverse = UBound( ks_matches_reverse ) + 1

	is_exist_module_revision = False
	For Each  match  In  ks_matches_reverse
		If StrCompHeadOf( match.SubMatches(0),  "$ModuleRevision",  c.CaseSensitive ) = 0 Then
			is_exist_module_revision = True
			Exit For
		End If
	Next

	If count_of_ks_reverse = 0 Then
		file.IsSaveInTerminate = False
		file = Empty
		copy_ren  in_FilePathInProject,  in_FilePathInModuleWork

		AssortKeywordSubstitution = Me.Constant.NoKS
		Exit Function
	End If


	'// Set "is_modified", "is_all_values_filled"
	text_in_commit_old = ReadFile( in_CommittedFilePath )
	text_in_commit = Me.ChangeToEmptyKS( text_in_commit_old,  ks_matches_commit )  '// Set "ks_matches_commit"
	is_modified = ( text_in_work <> text_in_commit )

	is_all_values_filled = True
	For Each  match_in_commit  In  ks_matches_commit
		AssertD_TypeName  match_in_commit, "IMatch2"
		is_empty_value = ( Trim2( match_in_commit.SubMatches(1) ) = "" )
		If is_empty_value Then

			is_all_values_filled = False
			Exit For
		End If
	Next


	'// Edit
	If is_exist_module_revision  or  is_modified  or  not is_all_values_filled Then
		time_stamp_in_project = W3CDTF( g_fs.GetFile( in_FilePathInProject ).DateLastModified )
		If g_fs.FileExists( in_CommittedFilePath ) Then _
			time_stamp_of_commit  = W3CDTF( g_fs.GetFile( in_CommittedFilePath ).DateLastModified )
		If is_exist_module_revision  or  is_modified Then
			text_in_project = file.Text
			ks_matches_project = ks_matches_reverse
		Else
			text_in_project = text_in_commit_old
			ks_matches_project = ks_matches_commit
		End If


		'// Set "text_in_project".  Update keyword substitution in project file
		text_in_project = Me.FillKS_Sub( text_in_project,  ks_matches_project,  ks_matches_commit,  in_Module, _
			in_TimeStampInFullSetTxt,  time_stamp_of_commit,  time_stamp_in_project, _
			is_exist_module_revision,  is_modified )


		If text_in_project <> file.Text Then
			If IsBitNotSet( g_fs.GetFile( in_FilePathInProject ).Attributes,  ReadOnly ) Then
				Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( in_FilePathInProject ) )

				CreateFile  in_FilePathInProject +".updating",  text_in_project
				cs = Empty
				SafeFileUpdateEx  in_FilePathInProject +".updating",  in_FilePathInProject,  Empty
			Else
				If Me_ReadOnlyWarningCount = 0 Then _
					echo_v  "    <WARNING msg=""リードオンリーです。"" a_path="""+ in_FilePathInProject +"""/>"
				Me_ReadOnlyWarningCount = Me_ReadOnlyWarningCount + 1
			End If
		End If


		If count_of_ks_reverse = 0 Then
			file.IsSaveInTerminate = False
			AssortKeywordSubstitution = Me.Constant.NoKS
		ElseIf is_exist_module_revision  or  is_modified Then
			file.Text = text_in_work
			AssortKeywordSubstitution = Me.Constant.UpdatedKS
		Else
			file.IsSaveInTerminate = False
			file = Empty
			If g_fs.FileExists( in_FilePathInModuleWork ) Then _
				SetReadOnlyAttribute  in_FilePathInModuleWork,  False

			AssortKeywordSubstitution = Me.Constant.MasterCopy
		End If
		file = Empty  '// Save "in_FilePathInModuleWork".
'//TODO: If g_debug_var(0) = 1 Then Stop:OrError

		If count_of_ks_reverse >= 1  and  is_modified Then
			previous_time_stamp = W3CDTF( time_stamp_in_project )
		ElseIf is_exist_module_revision Then
			previous_time_stamp = W3CDTF( time_stamp_of_commit )
		End If

		'// Not change time stamp by updating KS.
		If not IsEmpty( previous_time_stamp ) Then
			SetDateLastModified  Dict(Array( _
				in_FilePathInProject,     previous_time_stamp, _
				in_FilePathInModuleWork,  previous_time_stamp ))
		End If

	Else '// If text_in_work = text_in_commit Then
		file.IsSaveInTerminate = False
		file = Empty
		If g_fs.FileExists( in_FilePathInProject ) Then _
			SetReadOnlyAttribute  in_FilePathInProject,  False

		copy_ren  in_CommittedFilePath,  in_FilePathInProject
		del  in_FilePathInModuleWork
		AssortKeywordSubstitution = Me.Constant.MasterCopy
	End If
End Function


 

'***********************************************************************
'* Method: ChangeToEmptyKS
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::ChangeToEmptyKS
'***********************************************************************
Public Function  ChangeToEmptyKS( in_Text,  out_KS_MatchesReverse )

	assorting_KS_array = Array( "$ModuleRevision", "$Date", "$Version" )

	Set ks_matches = Me.RegExpOfKeywordSubstitution.Execute( in_Text )
	Reverse_COM_ObjectArray  ks_matches,  pre_ks_matches_reverse  '// Set "pre_ks_matches_reverse"
	ReDim  ks_matches_reverse( ks_matches.Count - 1 )
	count_of_ks_reverse = 0

	For Each  match  In  pre_ks_matches_reverse
		If InStr( match.Value,  vbLF ) = 0 Then
			is_double_colon = ( Right( match.SubMatches(0),  2 ) = "::" )
			If is_double_colon Then
				colons = "::"
			Else
				colons = ":"
			End If
			For Each  a_KS  In  assorting_KS_array
				If match.SubMatches(0) = a_KS + colons Then _
					Exit For
			Next
			If not IsEmpty( a_KS ) Then

				Set ks_matches_reverse( count_of_ks_reverse ) = match
				count_of_ks_reverse = count_of_ks_reverse + 1
			End If
		End If
	Next
	ReDim Preserve  ks_matches_reverse( count_of_ks_reverse - 1 )


	'// Set "text".  Replace to empty keyword substitution in master file
	text = in_Text
	For Each  match  In  ks_matches_reverse
		AssertD_TypeName  match, "IMatch2"
		is_double_colon = ( Right( match.SubMatches(0),  2 ) = "::" )

		If not is_double_colon Then  '// e.g. "$Key:"

			text = Left( text,  match.FirstIndex ) + _
				match.SubMatches(0) +" $" + _
				Mid( text,  match.FirstIndex + 1 + match.Length )

		Else  '// e.g. "$Key::"
			text = Left( text,  match.FirstIndex ) + _
				match.SubMatches(0) + String( Len( match.SubMatches(1) ), " " ) +"$" + _
				Mid( text,  match.FirstIndex + 1 + match.Length )
		End If
	Next

	out_KS_MatchesReverse = ks_matches_reverse
	ChangeToEmptyKS = text
End Function


 
'***********************************************************************
'* Method: FillKS_Sub
'*
'* Name Space:
'*    ModuleAssort2_PromptClass::FillKS_Sub
'***********************************************************************
Public Function  FillKS_Sub( in_Text,  ks_matches_reverse,  ks_matches_commit,  in_Module, _
		in_TimeStampInFullSetTxt,  in_TimeStampOfCommit,  in_TimeStampForModified, _
		in_IsExistModuleRevision,  in_IsModified )

	text = in_Text

	For Each  match  In  ks_matches_reverse
		AssertD_TypeName  match, "IMatch2"
		If Right( match.SubMatches(0),  2 ) = "::" Then
			colon_length = 2
		Else
			colon_length = 1
		End If
		matched_key = Left( match.SubMatches(0),  Len( match.SubMatches(0) ) - colon_length )


		If in_IsModified Then
			is_update_value = True
			time_stamp = in_TimeStampForModified

		ElseIf in_IsExistModuleRevision Then
			is_update_value = True
			If IsEmpty( in_TimeStampInFullSetTxt ) Then
				time_stamp = in_TimeStampOfCommit
			Else
				time_stamp = in_TimeStampInFullSetTxt
			End If
		Else
			is_empty_value_in_project = ( Trim2( match.SubMatches(1) ) = "" )

			is_empty_value_in_commit = is_empty_value_in_project
			For Each  match_in_commit  In  ks_matches_commit
				If match.SubMatches(0) = match_in_commit.SubMatches(0) Then

					is_empty_value_in_commit = ( Trim2( match_in_commit.SubMatches(1) ) = "" )
				End If
			Next

			is_update_value = is_empty_value_in_project  or  is_empty_value_in_commit
			If is_empty_value_in_commit Then
				If IsEmpty( in_TimeStampInFullSetTxt ) Then
					time_stamp = in_TimeStampOfCommit
				Else
					time_stamp = in_TimeStampInFullSetTxt
				End If
			Else
				time_stamp = Empty  '// Does not modify
			End If
		End If
		new_value = Empty


		If is_update_value Then
			If matched_key = "$Date" Then
				new_value = time_stamp
			ElseIf matched_key = "$ModuleRevision" Then
				new_value = Replace( in_Module.PathInMasters, "$", "" )
			Else : Assert  matched_key = "$Version"
				If Me.SettingFile.Versions.Exists( in_Module.FullPathInMasters ) Then
					new_value = Trim2( Me.SettingFile.Versions( in_Module.FullPathInMasters ) )  '// Not change temporary
				Else
					new_value = ""
				End If
			End If
		End If


		If not IsEmpty( new_value ) Then
			If colon_length = 1 Then  '// e.g. "$Key:"
				If new_value <> "" Then _
					new_value = new_value +" "

				text = Left( text,  match.FirstIndex ) + _
					match.SubMatches(0) +" "+ new_value +"$" + _
					Mid( text,  match.FirstIndex + 1 + match.Length )

			Else  '// colon_length = 2.  e.g. "$Key::"
				count_of_spaces = Len( match.SubMatches(1) ) - Len( new_value ) - 1
				If count_of_spaces < 0 Then _
					count_of_spaces = 0

				text = Left( text,  match.FirstIndex ) + _
					match.SubMatches(0) +" "+ new_value + String( count_of_spaces, " " ) +"$" + _
					Mid( text,  match.FirstIndex + 1 + match.Length )
			End If
		End If
	Next

	FillKS_Sub = text
End Function


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Function: ModuleAssort2_PromptClass_copyAndFillKS
'*    as CopyFunction. KS = Keyword Substitution.
'***********************************************************************
Sub  ModuleAssort2_PromptClass_copyAndFillKS( in_SourcePath,  in_DestinationPath,  ref_Option )
	destination_full_path = GetFullPath( in_DestinationPath, Empty )

	If g_Vers("TextFileExtension").Exists( g_fs.GetExtensionName( in_SourcePath ) )  and _
			ref_Option.Delegate.IsFill Then
		AssertD_TypeName  ref_Option.Delegate,  "ModuleAssort2_CurrentOfFillKS_Class"
		Set Me_ = ref_Option.Delegate.Me_

		Set file = OpenForReplace( in_SourcePath,  in_DestinationPath )

		Me_.ChangeToEmptyKS  file.Text,  ks_matches_reverse  '// Set "ks_matches_reverse"
		If UBound( ks_matches_reverse ) = -1 Then
			file.IsSaveInTerminate = False
			file = Empty

			copy_ren  in_SourcePath,  in_DestinationPath
		Else
			time_stamp_in_full_set = ref_Option.CurrentTimeStampInFullSetFile
			time_stamp_in_project = W3CDTF( g_fs.GetFile( in_SourcePath ).DateLastModified )
			time_stamp_of_commit  = W3CDTF( g_fs.GetFile( in_SourcePath ).DateLastModified )

			text = Me_.FillKS_Sub( file.Text,  ks_matches_reverse,  Array( ),  ref_Option.Delegate.Module, _
				time_stamp_in_full_set,  time_stamp_of_commit,  time_stamp_in_project,  False,  False )
			If text = file.Text Then
				file.IsSaveInTerminate = False
				file = Empty

				copy_ren  in_SourcePath,  in_DestinationPath
				time_stamp_in_project = Empty
			Else
				file.Text = text
				file = Empty

			End If
		End If
	Else
		copy_ren  in_SourcePath,  in_DestinationPath
	End If

	ref_Option.Delegate.Files( destination_full_path ) = W3CDTF( time_stamp_in_project )
End Sub


 
'***********************************************************************
'* Function: get_ModuleAssort2_PromptClass_BatchFileTemplate
'***********************************************************************
Function  get_ModuleAssort2_PromptClass_BatchFileTemplate()
    If IsEmpty( g_ModuleAssort2_PromptClass_BatchFileTemplate ) Then
    	g_ModuleAssort2_PromptClass_BatchFileTemplate = _
			"@echo off"+ vbCRLF + _
			"..\ModuleAssortMini.bat  Assort  ""${ProjectTagName}""  ""${ProjectName}"""+ vbCRLF
	End If
    get_ModuleAssort2_PromptClass_BatchFileTemplate = g_ModuleAssort2_PromptClass_BatchFileTemplate
End Function
Dim  g_ModuleAssort2_PromptClass_BatchFileTemplate


 
'***********************************************************************
'* Class: ModuleAssort2_SettingFileClass
'*
'* Date Structure:
'* - <ModuleAssort2_SettingFileClass>
'* - | dictionary< <ModuleAssort2_ProjectInFileClass> >  .Projects
'* - | | dictionary< <ModuleAssort2_ModuleInFileClass> >    .Modules
'***********************************************************************
Class  ModuleAssort2_SettingFileClass
	Public  Path
	Public  SubPaths     '// as ArrayClass
	Public  Variables    '// as LazyDictionaryClass
	Public  ProjectTags  '// as dictionary of string. Key=Name
	Public  Projects     '// as dictionary of ModuleAssort2_ProjectInFileClass. Key=Name
	Public  FragmentListFullPath
	Public  Versions     '// as dictionary of string. Key=FullPath
	Public  ProjectCachePath      '// with variable
	Public  ProjectCacheFullPath  '// without variable
	Public  MakeRuleSet  '// as MakeRuleSetOfRevisionFolderClass


	Private Sub  Class_Initialize()
		Set Me.SubPaths = new ArrayClass
		Set Me.ProjectTags = CreateObject( "Scripting.Dictionary" )
		Set Me.Projects    = CreateObject( "Scripting.Dictionary" )
		Set Me.Versions    = CreateObject( "Scripting.Dictionary" )
	End Sub


'***********************************************************************
'* Method: Load
'*
'* Name Space:
'*    ModuleAssort2_SettingFileClass::Load
'***********************************************************************
Public Sub  Load( in_Path )
	Set root = LoadXML( in_Path, Empty )
	Set Me.Variables = LoadVariableInXML( root,  in_Path )
	Me.Path = GetFullPath( in_Path, Empty )
	Me.SubPaths.Add  Me.Path
	parent_path = g_fs.GetParentFolderName( Me.Path )

	For Each  sub_project_tag  In  root.selectNodes( "./SubProject" )
		path_ = XmlReadOrError( sub_project_tag,  "@path",  in_Path )
		path_ = GetFullPath( Me.Variables( path_ ),  parent_path )
		Me.SubPaths.Add  path_
	Next

	For i = Me.SubPaths.UBound_ To 0 Step -1
		Me.LoadSub  Me.SubPaths(i)
	Next
End Sub


'***********************************************************************
'* Method: LoadSub
'*
'* Name Space:
'*    ModuleAssort2_SettingFileClass::LoadSub
'***********************************************************************
Public Sub  LoadSub( in_Path )
	If GetFullPath( in_Path, Empty ) <> Me.Path Then _
		echo  "Load  """+ in_Path +""""
	Set root = LoadXML( in_Path, Empty )
	parent_path = GetParentFullPath( in_Path )

	For Each  project_tag_tag  In  root.selectNodes( "./ProjectTag" )
		Me.ProjectTags( XmlReadOrError( project_tag_tag, "@name",  in_Path ) ) = _
			XmlReadOrError( project_tag_tag, "@value",  in_Path )
	Next

	For Each  project_tag  In  root.selectNodes( "./Project" )
		Set project_ = new ModuleAssort2_ProjectInFileClass
		project_.Name = XmlReadOrError( project_tag,  "@name",  in_Path )
		project_.Path = XmlRead( project_tag,  "@path" )
		Set project_.Variables = LoadLocalVariableInXML( project_tag.selectSingleNode( "./Module" ), _
			Me.Variables,  in_Path )

		project_.IsFillKS = XmlReadBoolean( project_tag,  "@keyword_substitution",  Empty,  in_Path )
		a_KS = XmlReadBoolean( project_tag,  "@KS",  Empty,  in_Path )
		If not IsEmpty( a_KS ) Then
			If not IsEmpty( project_.IsFillKS ) Then
				Raise  1, "<ERROR msg=""keyword_substitution と KS は同時に指定できません。"" xpath="""+ _
					GetXPath( project_tag, Array("name") ) +"""/>"
			Else
				project_.IsFillKS = a_KS
			End If
		End If
		If IsEmpty( project_.IsFillKS ) Then _
			project_.IsFillKS = True

		For Each  module_tag  In  project_tag.selectNodes( "./Module" )
			Set module = new ModuleAssort2_ModuleInFileClass
			module.PathInMasters = XmlReadOrError( module_tag,  "@master",  in_Path )
			module.FullPathInMasters = project_.Variables( module.PathInMasters )
				AssertFullPath  module.FullPathInMasters, "Module/@master"
			module.WorkPathInMasters = NormalizePath( module.PathInMasters +"\..\Work" )
			module.FullPathInWorkMasters = GetFullPath( "..\Work",  module.FullPathInMasters )
			module.PathInProject = XmlReadOrError( module_tag,  "@project",  in_Path )

			module.IsFillKS = XmlReadBoolean( module_tag,  "@keyword_substitution",  Empty,  in_Path )
			a_KS = XmlReadBoolean( module_tag,  "@KS",  Empty,  in_Path )
			If not IsEmpty( a_KS ) Then
				If not IsEmpty( module.IsFillKS ) Then
					Raise  1, "<ERROR msg=""keyword_substitution と KS は同時に指定できません。"" xpath="""+ _
						GetXPath( module_tag, Array("master") ) +"""/>"
				Else
					module.IsFillKS = a_KS
				End If
			End If

			module.ProjectName = project_.Name

			Dic_addElemOrError  project_.Modules,  module.FullPathInMasters,  module,  project_.Name
		Next

		Set Me.Projects( project_.Name ) = project_
	Next

	Me.FragmentListFullPath = Me.Variables( XmlRead( root, "./Fragment/@list" ) )
	If not IsEmpty( Me.FragmentListFullPath ) Then
		AssertFullPath  Me.FragmentListFullPath,  in_Path +" の Fragment/@list 属性"
		Me.FragmentListFullPath = NormalizePath( Me.FragmentListFullPath )
	End If

	Me.ProjectCachePath = XmlRead( root, "./ProjectCache/@path" )
	If IsEmpty( Me.ProjectCachePath ) Then
		Me.ProjectCacheFullPath = GetFullPath( "_ProjectCache", parent_path )
	Else
		Me.ProjectCacheFullPath = Me.Variables( Me.ProjectCachePath )
	End If
	AssertFullPath  Me.ProjectCacheFullPath,  in_Path +" の ProjectCache/@path 属性"

	For Each  version_tag  In  root.selectNodes( "./Version" )
		path_ = XmlReadOrError( version_tag,  "@path",  in_Path )
		path_ = GetFullPath( Me.Variables( path_ ),  parent_path )
		Me.Versions( path_ ) = XmlReadOrError( version_tag,  "@name",  in_Path )
	Next

	'// Set "MakeRuleSet" : Read "<MakeRule>"
	Set Me.MakeRuleSet = OpenForMakeRuleOfRevisionFolder( in_Path )
	Me.MakeRuleSet.Variables.AddDictionary  Me.Variables


	'// Add "Projects" to "MakeRuleSet"
	Set make_rule_file = new StringStream
	make_rule_file.WriteLine  "<MakeRuleOfRevisionFolder>"
	make_rule_file.WriteLine  ""
	For Each  project_  In  Me.Projects.Items
		make_rule_file.WriteLine  "<MakeRule>"
		make_rule_file.WriteLine  vbTab +"<Output path="""+ _
			Me.ProjectCachePath +"\"+ g_fs.GetParentFolderName( project_.Name ) +"\*""/>"
		revision_set = g_fs.GetFileName( project_.Name ) +", "
		For Each  module  In  project_.Modules.Items
			make_rule_file.WriteLine  vbTab +"<Input  path="""+ _
				g_fs.GetParentFolderName( module.PathInMasters ) +"\*""/>"
			revision_set = revision_set + g_fs.GetFileName( module.PathInMasters ) +", "
		Next
		CutLastOf  revision_set,  ", ",  Empty
		make_rule_file.WriteLine  vbTab +"<RevisionSet>"+ revision_set +"</RevisionSet>"
		make_rule_file.WriteLine  "</MakeRule>"
		make_rule_file.WriteLine  ""
	Next
	make_rule_file.WriteLine  "</MakeRuleOfRevisionFolder>"

	Me.MakeRuleSet.LoadAdditionally  new_FilePathForString( make_rule_file.ReadAll() )
End Sub

'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: ModuleAssort2_ProjectInFileClass
'***********************************************************************
Class  ModuleAssort2_ProjectInFileClass
	Public  Name      '// Project name and revision
	Public  Path      '// with variables
	Public  FullPath  '// without variables
	Public  Modules   '// as dictionary of ModuleAssort2_ModuleInFileClass. Key=FullPathInMasters
	Public  Variables '// as LazyDictionaryClass
	Public  IsFillKS  '// KS = Keyword Substitution


	Private Sub  Class_Initialize()
		Set Me.Modules = CreateObject( "Scripting.Dictionary" )
		Me.IsFillKS = True
	End Sub


 
'***********************************************************************
'* Method: ChangeCurrentProjectRevision
'*
'* Name Space:
'*    ModuleAssort2_ProjectInFileClass::ChangeCurrentProjectRevision
'***********************************************************************
Public Sub  ChangeCurrentProjectRevision( in_PathInProjectWithVariable )
	Set project_ = Me

	project_.FullPath = project_.Variables.GetFullPath( in_PathInProjectWithVariable,  Empty )
		AssertFullPath  project_.FullPath, "PathInProject"

	For Each  module  In  project_.Modules.Items
		AssertD_TypeName  module, "ModuleAssort2_ModuleInFileClass"

		module.FullPathInWorkProject = GetFullPath( _
			project_.Variables( module.PathInProject ), _
			project_.FullPath )
	Next
End Sub


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: ModuleAssort2_ModuleInFileClass
'***********************************************************************
Class  ModuleAssort2_ModuleInFileClass
	Public  PathInMasters          '// with variables
	Public  PathInProject          '// with variables
	Public  WorkPathInMasters      '// with variables
	Public  FullPathInMasters      '// without variables
	Public  FullPathInWorkProject  '// without variables
	Public  FullPathInWorkMasters  '// without variables
	Public  IsFillKS               '// as Empty or boolean

	Public  ProjectName

'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: ModuleAssort2_CurrentClass
'*
'* Date Structure:
'* - <ModuleAssort2_CurrentClass>
'* - | dictionary< <ModuleAssort2_CurrentOfProjectClass> > .Projects
'***********************************************************************
Class  ModuleAssort2_CurrentClass
	Public  CurrentKey
	Public  FullPathOfKey
	Public  ProjectName  '// Included revision. without variables
	Public  Project      '// as ModuleAssort2_ProjectInFileClass
	Public  RelativePath '// without variables
	Public  ModulePathInMasters  '// with variables
	Public  ModulePathInProject  '// with variables
	Public  WorkModulePath       '// with variables
	Public  WorkNewModulePath    '// with variables
	Public  ModuleFullPathInMasters      '// without variables
	Public  ModuleFullPathInWorkProject  '// without variables
	Public  WorkModuleFullPath           '// without variables
	Public  WorkNewModuleFullPath        '// without variables

	Public  Projects '// as dictionary of ModuleAssort2_CurrentOfProjectClass. Key=Name


	Private Sub  Class_Initialize()
		Set Me.Projects = CreateObject( "Scripting.Dictionary" )
	End Sub


'***********************************************************************
'* Method: Reset
'*
'* Name Space:
'*    ModuleAssort2_CurrentClass::Reset
'***********************************************************************
Public Sub  Reset( in_SettingFile )
	Set current = Me
	For Each  project_in_file  In  in_SettingFile.Projects.Items
		AssertD_TypeName  project_in_file, "ModuleAssort2_ProjectInFileClass"

		Set project_ = new ModuleAssort2_CurrentOfProjectClass
		project_.Name = project_in_file.Name
		'// project_.WorkProjectFullPathBackUp = Empty

		full_path = project_in_file.Variables( project_in_file.Path )
		If not IsEmpty( full_path )  and  not IsFullPath( full_path ) Then
			Raise  1, "<ERROR msg=""Project/@path 属性がフル パスではありません。""  path="""+ _
				project_in_file.Path +"""/>"
		End If
		project_in_file.FullPath = full_path

		For Each  module_in_file  In  project_in_file.Modules.Items

			AssertD_TypeName  module_in_file, "ModuleAssort2_ModuleInFileClass"
			module_in_file.FullPathInWorkProject = GetFullPath( _
				project_in_file.Variables( module_in_file.PathInProject ), _
				project_in_file.FullPath )
		Next

		Set current.Projects( project_.Name ) = project_
	Next
End Sub


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: ModuleAssort2_CurrentOfProjectClass
'***********************************************************************
Class  ModuleAssort2_CurrentOfProjectClass
	Public  Name  '// "ProjectName" + \ + "RevisionName"
	Public  WorkProjectFullPathBackUp

'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: ModuleAssort2_CurrentOfFillKS_Class
'***********************************************************************
Class  ModuleAssort2_CurrentOfFillKS_Class
	Public  Me_     '// ModuleAssort2_PromptClass
	Public  Module  '// ModuleAssort2_ModuleInFileClass
	Public  Files   '// as dictionary of string. Key=path, Item=Date
	Public  IsFill


	Private Sub  Class_Initialize()
		Set Me.Files = CreateObject( "Scripting.Dictionary" )
	End Sub

'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: ModuleAssort2_RelativePathClass
'***********************************************************************
Class  ModuleAssort2_RelativePathClass
	Public  Name  '// Step path

	Public  CommittedBodyFullPath
	Public  CommittedHashValue
	Public  CommittedTimeStamp

	Public  WorkHashValue

	Public  MasterBodyFullPath
	Public  MasterHashValue

	Public  TypeInProject  '// c.File, c.EmptyFolder, c.NotFound

'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Function: new_ModuleAssort2_RelativePathClass
'***********************************************************************
Function  new_ModuleAssort2_RelativePathClass()
    Set new_ModuleAssort2_RelativePathClass = new ModuleAssort2_RelativePathClass
End Function


 







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


 
