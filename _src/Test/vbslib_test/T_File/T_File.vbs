Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_MkDir",_
			"2","T_TempFile",_
			"3","T_TempDel",_
			"4","T_OpenForWrite",_
			"5","T_CreateFile",_
			"6","T_touch",_
			"7","T_Del",_
			"8","T_ReadFile", _
			"9","T_ReadFileInTag", _
			"10","T_ReadUnicodeFileBOM", _
			"11","T_ReadLineSeparator",_
			"12","T_OpenFile", _
			"13","T_OverwriteFolderFile", _
			"14","T_AssertExist",_
			"15","T_Exist", _
			"16","T_CreateFile_Err" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_MkDir] >>> 
'********************************************************************************
Sub  T_MkDir( Opt, AppKey )
	Dim w_, path

	SetWritableMode  F_ErrIfWarn


	'//=== make sub directory

	For Each  path  In Array( "sub1\sub2", "sub1\sub2\" )

		'// set up
		Set w_=AppKey.NewWritable( "." ).Enable()
		del  "sub1"

		'// main
		Set w_=AppKey.NewWritable( "sub1\sub2\text.txt" ).Enable()
		mkdir  path

		'// check
		Assert  g_fs.FolderExists( "sub1\sub2" )

		'// clean
		Set w_=AppKey.NewWritable( "." ).Enable()
		del  "sub1"
	Next


	'//=== mkdir_for

	'// set up
	Set w_=AppKey.NewWritable( "." ).Enable()
	del  "sub1"

	'// main
	Set w_=AppKey.NewWritable( "sub1\sub2\text.txt" ).Enable()
	mkdir_for  "sub1\sub2\file.txt"

	'// check
	Assert  g_fs.FolderExists( "sub1\sub2" )

	'// clean
	Set w_=AppKey.NewWritable( "." ).Enable()
	del  "sub1"


	'//=== mkdir_for : at root

	Set w_=AppKey.NewWritable( "C:\text.txt" ).Enable()
	mkdir_for  "C:\text.txt"


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TempFile] >>> 
'********************************************************************************
Sub  T_TempFile( Opt, AppKey )
	Dim  path1, f1, path2, f2

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()


	'//=== Check Not double path
	path1 = GetTempPath("DataA_*.xml")
	Set f1 = OpenForWrite( path1, Empty )

	path2 = GetTempPath("DataA_*.xml")
	Set f2 = OpenForWrite( path2, Empty )

	f1.WriteLine  "<sample/>"
	f2.WriteLine  "<sample2/>"
	f1 = Empty
	f2 = Empty

	del  path1
	del  path2
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TempDel] >>> 
'********************************************************************************
Sub  T_TempDel( Opt, AppKey )
	Dim  path1, f1, path2, f2

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()


	'//=== Check auto delete old file
	include  "Setting_getTemp.vbs"
	g_TempFile = Empty  '// Setup to set another folder path
	get_TempFile
	path1 = GetTempPath("DataB_*.xml")
	CreateFile  path1, "<sample/>"

	'// Sleep  2000  '// wait for time limit of temporary file

	g_TempFile = Empty  '// Setup to delete template folder again
	get_TempFile
	path2 = GetTempPath("DataC_*.xml")

	If not exist( g_TempFile.m_FolderPath + "\*" ) Then  Fail

	Sleep  4000  '// wait for time limit of temporary file

	g_TempFile = Empty  '// Setup to delete template folder again
	get_TempFile
	path2 = GetTempPath("DataC_*.xml")

	If exist( g_TempFile.m_FolderPath + "\*" ) Then  Fail

	del  path1
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OpenForWrite] >>> 
'********************************************************************************
Dim  g_System_Path

Sub  T_OpenForWrite( Opt, AppKey )
	Dim  f, path
	Dim  c : Set c = g_VBS_Lib

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	If not IsEmpty( g_System_Path ) Then  Error  '// OpenForWrite can be used without System.vbs


	'//=== Create any character code set file, Test of new_TextFileCharSet
	Dim  charset,  charset_stack,  safe,  safe_stack,  ans_path,  flags,  append_flags

	Dim  charset_case
		Const  CharSet_1_ShiftJIS = 1,  CharSet_2_Unicode = 2,  CharSet_3_UTF_8_BOM = 3
		Const  CharSet_4_UTF_8_No_BOM = 4,  CharSet_5_EUC_JP = 5
		Const  CharSet_6_ISO_2022_JP = 6,  charset_case_max = 6
	Dim  write_case
		Const  Write_1_Normal = 1,  Write_2_NormalOver = 2,  Write_3_NormalAppend = 3
		Const  Write_4_SafeFileUpdateNew = 4,  Write_5_SafeFileUpdateOver = 5
		Const  Write_6_NormalAndCharSetFlag = 6,  write_case_max = 6

	For charset_case = 1  To charset_case_max
	For write_case  = 1  To write_case_max

		'//=== setup parameters
		Select Case  charset_case   '// [charset](1)               [ans_path]
			Case  CharSet_1_ShiftJIS     : charset = "shift_jis"    : ans_path = "T_CreateFile2_ShiftJIS_ans.txt"
			Case  CharSet_2_Unicode      : charset = "unicode"      : ans_path = "T_CreateFile2_Unicode_ans.txt"
			Case  CharSet_3_UTF_8_BOM    : charset = "utf-8"        : ans_path = "T_CreateFile2_UTF-8_BOM_ans.txt"
			Case  CharSet_4_UTF_8_No_BOM : charset = "utf-8-no-BOM" : ans_path = "T_CreateFile2_UTF-8_NoBOM_ans.txt"
			Case  CharSet_5_EUC_JP       : charset = "euc-JP"       : ans_path = "T_CreateFile2_EUC_JP_ans.txt"
			Case  CharSet_6_ISO_2022_JP  : charset = "ISO-2022-JP"  : ans_path = "T_CreateFile2_ISO-2022-JP_ans.txt"
		End Select

		If write_case = Write_3_NormalAppend Then
			Select Case  charset_case   '// [append_flags]
				Case  CharSet_1_ShiftJIS     : append_flags = c.Append
				Case  CharSet_2_Unicode      : append_flags = c.Append
				Case  CharSet_3_UTF_8_BOM    : append_flags = c.Append
				Case  CharSet_4_UTF_8_No_BOM : append_flags = c.Append or c.UTF_8_No_BOM
				Case  CharSet_5_EUC_JP       : append_flags = c.Append or c.EUC_JP       '// cannot auto charset
				Case  CharSet_6_ISO_2022_JP  : append_flags = c.Append or c.ISO_2022_JP  '// cannot auto charset
			End Select
		End If

		Select Case  write_case          '// [safe]
			Case  Write_1_Normal             :  safe = False
			Case  Write_2_NormalOver         :  safe = False
			Case  Write_3_NormalAppend       :  safe = False
			Case  Write_4_SafeFileUpdateNew  :  safe = True
			Case  Write_5_SafeFileUpdateOver :  safe = True
			Case  Write_6_NormalAndCharSetFlag
				safe = False
				Select Case  charset_case   '// [charset](2)
					Case  CharSet_1_ShiftJIS     : charset = c.Shift_JIS
					Case  CharSet_2_Unicode      : charset = c.Unicode
					Case  CharSet_3_UTF_8_BOM    : charset = c.UTF_8
					Case  CharSet_4_UTF_8_No_BOM : charset = c.UTF_8_No_BOM
					Case  CharSet_5_EUC_JP       : charset = c.EUC_JP
					Case  CharSet_6_ISO_2022_JP  : charset = c.ISO_2022_JP
				End Select
		End Select


		'//=== setup files
		Select Case  write_case
			Case  Write_1_Normal             :  del         "work"
			Case  Write_2_NormalOver         :  CreateFile  "work\sub\T_OpenForWrite_out.txt", "---"
			Case  Write_3_NormalAppend       :  del         "work"  '// create file is in next block
			Case  Write_4_SafeFileUpdateNew  :  del         "work"
			Case  Write_5_SafeFileUpdateOver :  CreateFile  "work\sub\T_OpenForWrite_out.txt", "---"
			Case  Write_6_NormalAndCharSetFlag : del        "work"
		End Select


		'//=== Do test
		If IsNumeric( charset ) Then
			flags = charset
		Else
			flags = Empty
			Set charset_stack = new_TextFileCharSetStack( charset )
		End If
		Set safe_stack = new_IsSafeFileUpdateStack( safe )


		Set f = OpenForWrite( "work\sub\T_OpenForWrite_out.txt", flags )  '//##################### Test Point
		f.Write      "あいう"  : Assert f.Line = 1

		If write_case = Write_3_NormalAppend Then
			f = Empty
			charset_stack = Empty
			Set f = OpenForWrite( "work\sub\T_OpenForWrite_out.txt", append_flags )
		End If

		f.WriteLine  "ABC"     : Assert f.Line = 2
		f.Write      "うえお"  : Assert f.Line = 2
		f.Close


		If not fc(  "work\sub\T_OpenForWrite_out.txt", ans_path ) Then  Fail
		charset_stack = Empty
		safe_stack = Empty
		del  "work"

	Next
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OpenForWrite_Overwrite] >>> 
'********************************************************************************
Sub  T_OpenForWrite_Overwrite( Opt, AppKey )
	Dim  file,  file_name
	Dim w_:Set w_=AppKey.NewWritable( "work" ).Enable()

	'// 上書きする前のファイルが Unicode なら、Unicode にする

	For Each  file_name  In Array(_
		"T_CreateFile2_ShiftJIS_ans.txt",_
		"T_CreateFile2_Unicode_ans.txt" )

		'// set up
		copy  file_name, "work"

		'// Test Main
		Set file = OpenForWrite( "work\"+ file_name, Empty )
		file.WriteLine  "あいうABC"
		file.Write      "うえお"
		file = Empty

		'// check
		echo  ">IsSameBinaryFile"
		Assert IsSameBinaryFile( "work\"+ file_name,  file_name,  Empty )
	Next

	'// clean
	del  "work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CreateFile] >>> 
'********************************************************************************
Sub  T_CreateFile( Opt, AppKey )
	Dim  path

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()


	'//=== Create Ascii file
	CreateFile  "T_CreateFile1_out.txt", "abc_ascii" +vbCRLF+ "cde"  '//##################### Test Point
	If not fc( "T_CreateFile1_out.txt", "T_CreateFile1_ans.txt" ) Then  Fail
	del  "T_CreateFile1_out.txt"


	'//=== Create any character code file, Test of new_TextFileCharSet
	Dim  charset_name,  charset_stack,  is_safe,  safe_stack,  ans_path

	Dim  charsets : Set charsets = ReadTestCase( "T_File_Data.xml", "CharSet_for_T_CreateFile" )
	Dim  write_types : Set write_types = ReadTestCase( "T_File_Data.xml", "WriteType_for_T_CreateFile" )
	Dim  charset, write_type  '// <SubCase>

	For Each  charset  In charsets.Items
	For Each  write_type  In write_types.Items

		'//=== setup parameters
		charset_name = charset("name")
		is_safe = ( StrComp( write_type("is_safe"), "True", 1 ) = 0 )
		ans_path = charset("ans_path")


		'//=== setup files
		Select Case  write_type("name")
			Case  "Normal"             :  del         "work"
			Case  "SafeFileUpdateNew"  :  del         "work"
			Case  "SafeFileUpdateOver" :  CreateFile  "work\sub\T_CreateFile2_out.txt", "---"
		End Select


		'//=== Do test
		Set charset_stack = new_TextFileCharSetStack( charset_name )
		Set safe_stack = new_IsSafeFileUpdateStack( is_safe )

		CreateFile  "work\sub\T_CreateFile2_out.txt", "あいうABC" +vbCRLF+ "うえお"  '//##################### Test Point

		If not IsEmpty( ans_path ) Then
			If not fc(  "work\sub\T_CreateFile2_out.txt", ans_path ) Then  Fail
		End If
		charset_stack = Empty
		safe_stack = Empty
		del  "work"

	Next
	Next


	'//=== Create file in temporary folder
	path = CreateFile( "*.txt", "abc" )   '//##################### Test Point
	If g_fs.GetParentFolderName( path ) <> g_fs.GetParentFolderName( GetTempPath("*.txt") ) Then  Fail
	del  path


	'//=== Not change character set
	For Each  file_name  In Array( _
		"T_CreateFile2_ShiftJIS_ans.txt", _
		"T_CreateFile2_Unicode_ans.txt", _
		"T_CreateFile2_UTF-8_BOM_ans.txt" )


		'// Set up
		copy_ren  file_name, "_work.txt"

		'// Test Main : 下記のコードは、文書にあるサンプルコードをコピーしたものです
		text = ReadFile( "_work.txt" )
		'// ここで text を更新
		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( "_work.txt" ) )
		CreateFile  "_work.txt", text
		cs = Empty

		'// Check
		Assert  IsSameBinaryFile( "_work.txt", file_name, Empty )

		'// Clean
		del  "_work.txt"
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CreateFile_Err] >>> 
'********************************************************************************
Sub  T_CreateFile_Err( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "tmp" ).Enable()
	Set c = g_VBS_Lib

	'// Set up
	del  "tmp"
	mkdir  "tmp"

	'// Test Main
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		T_CreateFile_Err_Sub

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	'// Check
	ExpandWildcard  "tmp\*", c.File, folder, step_paths
	Assert  UBound( step_paths ) = -1   '//############## Do not create any files

	'// Clean
	del  "tmp"

	Pass
End Sub


Sub  T_CreateFile_Err_Sub()
	CreateFile  "tmp", "A"   '//################ "tmp" is folder. Folder can not be written
End Sub


 
'********************************************************************************
'  <<< [T_touch] >>> 
'********************************************************************************
Sub  T_touch( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work.txt" ).Enable()

	'//=== Test case of touch

	'// Set up
	copy_ren  "Files\T_Read_SJis_CRLF_LF.txt", "_work.txt"
	recent_time = DateAddStr( Now(), "-10sec" )
	Assert  recent_time > g_fs.GetFile("_work.txt").DateLastModified

	'// Test Main
	touch  "_work.txt"

	'// Check
	Assert  recent_time < g_fs.GetFile("_work.txt").DateLastModified

	'// Clean
	del  "_work.txt"



	'//=== Test case of no file

	'// Set up
	Assert  not exist( "_work.txt" )

	'// Test Main
	touch  "_work.txt"

	'// Check
	AssertExist  "_work.txt"
	Assert  recent_time < g_fs.GetFile("_work.txt").DateLastModified

	'// Clean
	del  "_work.txt"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Del] >>> 
'********************************************************************************
Sub  T_Del( Opt, AppKey )

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()


	mkdir  "work" : CreateFile  "work\file.txt", "1"
	del  "work"
	Assert  not exist( "work" )

	mkdir  "work" : CreateFile  "work\file.txt", "1"
	del  "work\file.txt"
	Assert  not exist( "work\file.txt" )

	del  "work\not_exist_sub\file.txt"
	del  "work\not_exist_sub\*.txt"  '// not call ExpandWildcard inside


	'// clean
	del  "work"
	Pass
End Sub
 
'********************************************************************************
'  <<< [T_ReadFile] >>> 
'********************************************************************************
Sub  T_ReadFile( Opt, AppKey )
	Dim  cs,  t1,  t2,  ans2
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( "_tmp.txt" ).Enable()

	Dim  ans : ans = "あいうABC"+vbCRLF+"うえお"


	'//=== auto detect charcode
	Assert  ReadFile( "T_CreateFile1_ans.txt" ) = "abc_ascii"+vbCRLF+"cde"
	Assert  ReadFile( "T_CreateFile2_ShiftJIS_ans.txt" ) = ans
	Assert  ReadFile( "T_CreateFile2_Unicode_ans.txt" ) = ans
	Assert  ReadFile( "T_CreateFile2_UTF-8_BOM_ans.txt" ) = ans
	Assert  ReadFile( "T_CreateFile2_0Byte.txt" ) = ""
	Assert  ReadFile( "T_CreateFile2_1Byte.txt" ) = "1"

	ans2 = " ((( CheckEnglishOnly )))"+vbCRLF+_
		"テキストファイルが英語だけになっているかチェックします。"+vbCRLF+_
		"チェックするファイルまたはフォルダーのパス: T_CheckEnglishOnly"+vbCRLF+_
		"設定ファイルのパス: T_CheckEnglishOnly\SettingForCheckEnglish.ini"+vbCRLF+vbCRLF
	t1 = ReadFile( "T_CreateFile3_BrokenSJIS.txt" )
	t2 = g_fs.OpenTextFile( "T_CreateFile3_BrokenSJIS.txt", 1, False, -2 ).ReadAll()
							 '// -2=文字コードを自動判定する。 このファイルは文字化けするファイル
	Assert  t1 = ans2
	Assert  t1 <> t2


	'//=== explicit detect charcode
	Set cs = new_TextFileCharSetStack( "EUC-JP" )
		Assert  ReadFile( "T_CreateFile2_EUC_JP_ans.txt" ) = ans
	cs = Empty
	Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
		Assert  ReadFile( "T_CreateFile2_UTF-8_NoBOM_ans.txt" ) = ans
	cs = Empty
	Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )  '// ADODB.Stream inside
		Assert  ReadFile( "T_CreateFile2_Zero.txt" ) = ""
	cs = Empty


	'//=== not found file from FileSystemObject
	Assert  ReadFile( "NotFound.txt" ) = ""
	Assert  ReadFile( "sub\sub2\NotFound.txt" ) = ""


	'//=== not found file from ADODB.Stream
	Set cs = new_TextFileCharSetStack( "EUC-JP" )
	Assert  ReadFile( "NotFound.txt" ) = ""
	Assert  ReadFile( "sub\sub2\NotFound.txt" ) = ""
	cs = Empty


	'//=== read write lock
	copy  "T_CreateFile1_ans.txt", "_tmp.txt"
	Set file = OpenForWrite( "_tmp.txt", c.Append )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Assert  ReadFile( "_tmp.txt" ) <> ""

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "_tmp.txt" ) > 0
	Assert  e2.num <> 0

	file = Empty
	del  "_tmp.txt"

	Pass
End Sub

 
'********************************************************************************
'  <<< [T_ReadFileInTag] >>> 
'********************************************************************************
Sub  T_ReadFileInTag( Opt, AppKey )
	Dim  e, e2  ' as Err2
	Dim  s

	Assert  ReadFileInTag( "T_CreateFile2_ans.txt", "いう", "code" ) = "Uni"
	Assert  ReadFileInTag( "T_CreateFile2_ans.txt", "あいう", "うえお" ) = "Unicode"
	Assert  ReadFileInTag( "T_CreateFile2_ans.txt", "Unicode", "えお" ) = "う"
	Assert  ReadFileInTag( "T_CreateFile2_ans.txt", "Unicode", Empty ) = "うえお"
	Assert  ReadFileInTag( "T_CreateFile2_ans.txt", "Unicode", "" )    = "うえお"
	Assert  ReadFileInTag( "T_CreateFile2_ans.txt", Empty, "Unicode" ) = "あいう"
	Assert  ReadFileInTag( "T_CreateFile2_ans.txt", "",    "Unicode" ) = "あいう"
	Assert  ReadFileInTag( "T_ReadFileInTag1.txt", "<Tag1>", "</Tag1>" ) = "ABC"+vbCRLF+"DEF"
	Assert  ReadFileInTag( "T_ReadFileInTag1.txt", "<Tag2>", "</Tag2>" ) = ""

	If TryStart(e) Then  On Error Resume Next
		s = ReadFileInTag( "T_ReadFileInTag1.txt", "<NotFound>", "</Tag2>" )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If e2.num <> E_NotFoundSymbol Then  e2.Raise

	If TryStart(e) Then  On Error Resume Next
		s = ReadFileInTag( "T_ReadFileInTag1.txt", "<Tag2>", "</NotFound>" )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If e2.num <> E_NotFoundSymbol Then  e2.Raise

	Pass
End Sub

 
'********************************************************************************
'  <<< [T_ReadUnicodeFileBOM] >>> 
'********************************************************************************
Sub  T_ReadUnicodeFileBOM( Opt, AppKey )
	Dim c : Set c = g_VBS_Lib
	Assert  ReadUnicodeFileBOM( "T_CreateFile2_ShiftJIS_ans.txt" )  = c.No_BOM
	Assert  ReadUnicodeFileBOM( "T_CreateFile2_UTF-8_BOM_ans.txt" ) = c.UTF_8
	Assert  ReadUnicodeFileBOM( "T_CreateFile2_Unicode_ans.txt" )   = c.Unicode
	Pass
End Sub

 
'********************************************************************************
'  <<< [T_ReadLineSeparator] >>> 
'********************************************************************************
Sub  T_ReadLineSeparator( Opt, AppKey )
	Assert  ReadLineSeparator( "T_CreateFile2_ShiftJIS_ans.txt" )    = vbCRLF
	Assert  ReadLineSeparator( "T_CreateFile2_EUC_JP_ans.txt" )      = vbCRLF
	Assert  ReadLineSeparator( "T_CreateFile2_EUC_JP_LF_1_ans.txt" ) = vbLF
	Assert  ReadLineSeparator( "T_CreateFile2_EUC_JP_LF_2_ans.txt" ) = vbLF
	Pass
End Sub

 
'********************************************************************************
'  <<< [T_OpenFile] >>> 
'********************************************************************************
Sub  T_OpenFile( Opt, AppKey )
	Dim  f, en, ed, cs
	Dim  e, e2  ' as Err2

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  section : Set section = new SectionTree


	Set f = OpenForRead( "T_CreateFile1_ans.txt" )
	Assert  f.ReadLine() = "abc_ascii"
	f = Empty

	On Error Resume Next
		Set f = OpenForRead( "." )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	Assert  en = E_ReadAccessDenied
	Assert  InStr( ed, GetFullPath( ".", Empty ) ) > 0


	'//=== auto detect charcode
	If section.Start( "T_OpenFile_AutoDetectCharCode" ) Then
	Set f = OpenForRead( "T_CreateFile1_ans.txt" )
		Assert  f.ReadLine() = "abc_ascii"
	f = Empty
	Set f = OpenForRead( "T_CreateFile2_ShiftJIS_ans.txt" )
		Assert  f.ReadLine() = "あいうABC"
	f = Empty
	Set f = OpenForRead( "T_CreateFile2_Unicode_ans.txt" )
		Assert  f.ReadLine() = "あいうABC"
	f = Empty
	Set f = OpenForRead( "T_CreateFile2_UTF-8_BOM_ans.txt" )
		Assert  f.ReadLine() = "あいうABC"
	f = Empty
	Set f = OpenForRead( "T_CreateFile2_0Byte.txt" )
		Assert  f.AtEndOfStream
	f = Empty
	Set f = OpenForRead( "T_CreateFile2_1Byte.txt" )
		Assert  f.ReadLine() = "1"
	f = Empty
	End If : section.End_


	'//=== explicit detect charcode
	If section.Start( "T_OpenFile_ExplicitDetectCharCode" ) Then
	Set cs = new_TextFileCharSetStack( "EUC-JP" )
		Set f = OpenForRead( "T_CreateFile2_EUC_JP_ans.txt" )
			Assert  f.ReadLine() = "あいうABC"
		f = Empty
	cs = Empty
	Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
		Set f = OpenForRead( "T_CreateFile2_UTF-8_NoBOM_ans.txt" )
			Assert  f.ReadLine() = "あいうABC"
		f = Empty
	cs = Empty
	Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
		Set f = OpenForRead( "T_CreateFile2_0Byte.txt" )  '// ADODB.Stream inside
			Assert  f.ReadLine() = ""
			Assert  f.AtEndOfStream
		f = Empty
	cs = Empty
	Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
		Set f = OpenForRead( "T_CreateFile2_1Byte.txt" )  '// ADODB.Stream inside
			Assert  f.ReadLine() = "1"
		f = Empty
	cs = Empty
	End If : section.End_


	'//=== not found file from FileSystemObject
	If section.Start( "T_OpenFile_NotFoundFromFS" ) Then
	If TryStart(e) Then  On Error Resume Next
		Set f = OpenForRead( "NotFound.txt" )   '########### Test Point
		f = Empty
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If InStr( e2.desc, "NotFound.txt" ) = 0 Then  Fail
	If e2.num <> E_FileNotExist Then  e2.Raise

	If TryStart(e) Then  On Error Resume Next
		Set f = OpenForRead( "sub\sub2\NotFound.txt" )   '########### Test Point
		f = Empty
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If InStr( e2.desc, "sub\sub2\NotFound.txt" ) = 0 Then  Fail
	If e2.num <> E_PathNotFound Then  e2.Raise
	End If : section.End_


	'//=== not found file from ADODB.Stream
	If section.Start( "T_OpenFile_NotFoundFromADODB" ) Then
	Set cs = new_TextFileCharSetStack( "EUC-JP" )

	If TryStart(e) Then  On Error Resume Next
		Set f = OpenForRead( "NotFound.txt" )   '########### Test Point
		f = Empty
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If InStr( e2.desc, "NotFound.txt" ) = 0 Then  Fail
	If e2.num <> E_FileNotExist Then  e2.Raise

	If TryStart(e) Then  On Error Resume Next
		Set f = OpenForRead( "sub\sub2\NotFound.txt" )   '########### Test Point
		f = Empty
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If InStr( e2.desc, "sub\sub2\NotFound.txt" ) = 0 Then  Fail
	If e2.num <> E_FileNotExist Then  e2.Raise
	cs = Empty
	End If : section.End_


	'//=== complex line separator from FileSystemObject
	If section.Start( "T_OpenFile_LineSepFromFS" ) Then
	Set f = OpenForRead( "Files\T_Read_SJis_CRLF_LF.txt" )
	Assert  f.ReadLine() = "あいう"
	Assert  f.ReadLine() = "えお"
	Assert  f.ReadLine() = "かきく"
	f = Empty
	End If : section.End_


	'//=== complex line separator from ADODB.Stream
	If section.Start( "T_OpenFile_LineSepFromADODB" ) Then
	Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
	Set f = OpenForRead( "Files\T_Read_Utf8NoBom_CRLF_LF.txt" )
	Assert  f.ReadLine() = "あいう"
	Assert  f.ReadLine() = "えお"
	Assert  f.ReadLine() = "かきく"
	f = Empty
	cs = Empty
	End If : section.End_


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OverwriteFolderFile] >>> 
'********************************************************************************
Sub  T_OverwriteFolderFile( Opt, AppKey )
	Dim  e  ' as Err2
	Dim  t1, t2

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	'//=== overwrite file on folder
	mkdir  "work_folder"

	t1 = Now()
	If TryStart(e) Then  On Error Resume Next
		OpenForWrite  "work_folder", Empty
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_WriteAccessDenied  Then  Fail
	e.Clear
	t2 = Now()
	If DateDiff( "s", t1, t2 ) > 3 Then  Fail


	t1 = Now()
	If TryStart(e) Then  On Error Resume Next
		CreateFile  "work_folder", "..."
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_WriteAccessDenied  Then  Fail
	e.Clear
	t2 = Now()
	If DateDiff( "s", t1, t2 ) > 3 Then  Fail

	del  "work_folder"


	'//=== overwrite folder on file
	CreateFile  "work_file.txt", "test"

	t1 = Now()
	If TryStart(e) Then  On Error Resume Next
		mkdir  "work_file.txt"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_AlreadyExist  Then  Fail
	e.Clear
	t2 = Now()
	If DateDiff( "s", t1, t2 ) > 3 Then  Fail

	del  "work_file.txt"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_AssertExist] >>> 
'********************************************************************************
Sub  T_AssertExist( Opt, AppKey )
	Dim  en, ed, abs_path

	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	AssertExist  "T_File.vbs"
	AssertExist  ".\T_File.vbs"
	AssertExist  "."

	abs_path = GetFullPath( "not_found.vbs", Empty )


	'// Case of step path
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		AssertExist  "not_found.vbs"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.desc = "<ERROR msg=""ファイルまたはフォルダーが見つかりません"" path="""+_
		"not_found.vbs"""+ vbCRLF +" abs_path="""+ abs_path +"""/>"
	Assert  e2.num = E_PathNotFound


	'// Case of abstract path
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		AssertExist  abs_path

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.desc = "<ERROR msg=""ファイルまたはフォルダーが見つかりません"" path="""+_
		abs_path +"""/>"
	Assert  e2.num = E_PathNotFound


	'// Case of Empty
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		AssertExist  Empty

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_PathNotFound


	'// Call "T_AssertExist_Sub"
	RunProg  "cscript //nologo  "+ WScript.ScriptName +" T_AssertExist_Sub", "_out3.txt"

	'// Check
	answer_output = ReadFile( "T_AssertExist_ans.txt" )
	answer_output = Replace( answer_output, "%FullPath(.)%", g_sh.CurrentDirectory )
	Assert  ReadFile( "_out3.txt" ) = answer_output

	'// Clean
	del  "_out3.txt"

	Pass
End Sub


Sub  T_AssertExist_Sub( Opt, AppKey )

	'// Case of upper case path
	upper_path = UCase( "T_File.vbs" )
	AssertExist  upper_path
End Sub


 
'********************************************************************************
'  <<< [T_Exist] >>> 
'********************************************************************************
Sub  T_Exist( Opt, AppKey )
	Set c = g_VBS_Lib

	Assert      exist( "T_CreateFile1_ans.txt" )
	Assert  not exist( "T_CreateFile1_ans__.txt" )

	Assert      exist( "T_CreateFile*" )
	Assert  not exist( "NotFound*" )

	Assert      exist_ex( "T_CreateFile1_ans.txt", c.CaseSensitive )
	Assert  not exist_ex( "T_CreateFile1_ANS.txt", c.CaseSensitive )
	Assert      exist(    "T_CreateFile1_ANS.txt" )

	Pass
End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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

	g_Vers.Add  "IncludeType", "no,System.vbs"
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
