Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_OpenForReplace",_
			"2","T_OpenForReplaceText",_
			"3","T_OpenForReplaceRegExp",_
			"4","T_OpenForReplaceRange",_
			"5","T_OpenForReplaceCharSet",_
			"6","T_StartReplace",_
			"7","T_PassThroughLineFilters",_
			"8","T_FromLock",_
			"9","T_StringStream",_
			"10","T_CutCRLF",_
			"11","T_GetPreviousLinePosition" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplace] >>> 
'********************************************************************************
Sub  T_OpenForReplace( Opt, AppKey )
	Set section = new SectionTree
	Set w_= AppKey.NewWritable( "work" ).Enable()

'//SetStartSectionTree  "T_OpenForReplace_Rollback2"


	'//=== Base case
	If section.Start( "T_OpenForReplace" ) Then

	'// setup
	del   "work"
	copy  "files\*", "work"

	'// Main Test
	Set  rep = OpenForReplace( "work\file1.txt", "work\file1_out.txt" )
	rep.Replace  "from", "to"
	rep = Empty

	'// check
	If not fc( "work\file1_out.txt", "work\file1_ans.txt" ) Then  Fail

	End If : section.End_


	'//=== DstPath = SrcPath
	If section.Start( "T_OpenForReplace_DstEqSrc" ) Then

	'// setup
	del    "work"
	mkdir  "work"
	copy   "files\*", "work"

	'// Main Test
	Set  rep = OpenForReplace( "work\file1.txt", "work\file1.txt" )
	rep.Replace  "from", "to"
	rep = Empty

	'// check
	If not fc( "work\file1.txt", "work\file1_ans.txt" ) Then  Fail

	End If : section.End_


	'//=== DstPath = Empty
	If section.Start( "T_OpenForReplace_DstEmpty" ) Then

	'// setup
	del    "work"
	mkdir  "work"
	copy   "files\*", "work"

	'// Main Test
	Set  rep = OpenForReplace( "work\file1.txt", Empty )
	rep.Replace  "from", "to"
	rep = Empty

	'// check
	If not fc( "work\file1.txt", "work\file1_ans.txt" ) Then  Fail

	End If : section.End_


	'//=== 置換後のワードが、別の場所にあるとき
	If section.Start( "T_OpenForReplace_DstSame" ) Then

	'// setup
	del   "work"
	copy  "files\*", "work"

	'// Main Test
	Set  rep = OpenForReplace( "work\file1.txt", "work\file1_out.txt" )
	rep.Replace  "abc", "from"
	rep = Empty

	'// check
	If not fc( "work\file1_out.txt", "work\file1_ans_to_same.txt" ) Then  Fail

	End If : section.End_


	'//=== 二重展開をしないテスト : １行内
	If section.Start( "T_OpenForReplace_DoubleDst" ) Then

	del    "work"
	copy   "files\*", "work"

	Set  rep = OpenForReplace( "work\file1.txt", Empty )
	rep.Replace  "abc", "abc  def"
	rep = Empty
	Set  rep = OpenForReplace( "work\file1.txt", Empty )
	rep.Replace  "abc", "abc  def"
	rep = Empty
	If not fc( "work\file1.txt", "work\file1_ans2.txt" ) Then  Fail

	End If : section.End_


	'//=== 二重展開をしないテスト : 複数行
	If section.Start( "T_OpenForReplace_DoubleDstMultiLine" ) Then

	del    "work"
	copy   "files\*", "work"

	Set  rep = OpenForReplace( "work\file1.txt", Empty )
	rep.Replace  "abc  from", "abc  from"+vbCRLF+"-------"
	rep = Empty
	Set  rep = OpenForReplace( "work\file1.txt", Empty )
	rep.Replace  "abc  from", "abc  from"+vbCRLF+"-------"
	rep = Empty
	If not fc( "work\file1.txt", "work\file1_ans3.txt" ) Then  Fail

	End If : section.End_


	'//=== ファイルが無いとき
	If section.Start( "T_OpenForReplace_NoFile" ) Then

	If TryStart(e) Then  On Error Resume Next
		Set rep = OpenForReplace( "NotFound.txt", Empty )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If InStr( e2.desc, "NotFound.txt" ) = 0 Then  Fail
	If e2.num <> E_PathNotFound Then  Fail

	End If : section.End_


	'//=== 他の処理でエラーがあったとき、更新しない
	If section.Start( "T_OpenForReplace_Rollback" ) Then

	del    "work"
	copy   "files\file1.txt", "work"
	If TryStart(e) Then  On Error Resume Next

		T_OpenForReplace_Sub  "Rollback"

	If TryEnd Then  On Error GoTo 0
	e.Clear
	AssertFC  "work\file1.txt", "files\file1.txt"

	End If : section.End_


	If section.Start( "T_OpenForReplace_Rollback2" ) Then

	del    "work"
	copy   "files\file1.txt", "work"
	If TryStart(e) Then  On Error Resume Next

		Set  rep = OpenForReplace( "work\file1.txt", Empty )
		rep.Replace  "abc  from", "abc  from"+vbCRLF+"-------"
		Error

	If TryEnd Then  On Error GoTo 0
	rep = Empty
	e.Clear
	AssertFC  "work\file1.txt", "files\file1.txt"

	End If : section.End_


	del  "work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplace_Sub] >>> 
'********************************************************************************
Sub  T_OpenForReplace_Sub( in_TestName )
	If in_TestName = "Rollback" Then
		Set  rep = OpenForReplace( "work\file1.txt", Empty )
		rep.Replace  "abc  from", "abc  from"+vbCRLF+"-------"
		Error
	End If
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplaceText] >>> 
'********************************************************************************
Sub  T_OpenForReplaceText( Opt, AppKey )

	'// setup
	del   "work"
	copy  "files\*", "work"

	'// Main Test
	Set  rep = OpenForReplace( "work\file1.txt", "work\file1_out.txt" )
	rep.Text = Replace( rep.Text, "from", "to" )
	rep = Empty

	'// check
	If not fc( "work\file1_out.txt", "work\file1_ans.txt" ) Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplaceRegExp] >>> 
'********************************************************************************
Sub  T_OpenForReplaceRegExp( Opt, AppKey )

	'// setup
	del   "work"
	copy  "files\*", "work"

	'// Main Test
	Set  rep = OpenForReplace( "work\file1.txt", "work\file1_out.txt" )
	rep.Replace  new_RegExp( "fr(.)m", True ), "t$1"
	rep = Empty

	'// check
	If not fc( "work\file1_out.txt", "work\file1_ans.txt" ) Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplaceRange] >>> 
'********************************************************************************
Sub  T_OpenForReplaceRange( Opt, AppKey )
	Dim  rep
	Dim  e, e2  ' as Err2

	Dim w_:Set w_= AppKey.NewWritable( "work" ).Enable()


	del    "work"
	mkdir  "work"
	copy   "files\*", "work"

	del  "work\range1_out.txt"
	Set  rep = OpenForReplace( "work\range1.txt", "work\range1_out.txt" )
	rep.ReplaceRange  "<Replace>", "</Replace>", "<Replace>456</Replace>"
	rep = Empty
	If not fc( "work\range1_out.txt", "work\range1_ans.txt" ) Then  Fail

	del  "work\range2_out.txt"
	Set  rep = OpenForReplace( "work\range2.txt", "work\range2_out.txt" )
	rep.ReplaceRange  "<Replace>", "</Replace>", "<Replace>456</Replace>"
	rep = Empty
	If not fc( "work\range2_out.txt", "work\range1_ans.txt" ) Then  Fail

	del  "work\range2_out.txt"
	Set  rep = OpenForReplace( "work\range2.txt", "work\range2_out.txt" )
	rep.ReplaceRange  "<Replace>", "</Replace>", _
		"<Replace>abc"+ vbCRLF +"def"+ vbCRLF +"ghi"+ vbCRLF +"xyz</Replace>"
	rep = Empty
	If not fc( "work\range2_out.txt", "work\range2_ans.txt" ) Then  Fail

	If TryStart(e) Then  On Error Resume Next
		Set  rep = OpenForReplace( "work\range2.txt", "work\range2_out.txt" )
		rep.ReplaceRange  "<Replace>", "</NotFound>", _
			"<Replace>abc"+ vbCRLF +"def"+ vbCRLF +"ghi"+ vbCRLF +"xyz</Replace>"
		rep = Empty
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If e2.num <> E_NotFoundSymbol Then  e2.Raise

	del  "work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplaceCharSet] >>> 
'********************************************************************************
Sub  T_OpenForReplaceCharSet( Opt, AppKey )
	Dim  f

	Dim w_:Set w_= AppKey.NewWritable( "work" ).Enable()

	del    "work"
	copy   "files\*", "work"

	Set f = OpenForReplace( "work\charset_sjis.txt", "work\out.txt" )
	f.Replace  "いう", "おう"
	f = Empty
	Assert  fc( "work\out.txt", "work\charset_sjis_ans.txt" )

	Set f = OpenForReplace( "work\charset_unicode.txt", "work\out.txt" )
	f.Replace  "いう", "おう"
	f = Empty
	Assert  fc( "work\out.txt", "work\charset_unicode_ans.txt" )

	Set f = OpenForReplace( "work\charset_utf8bom.txt", "work\out.txt" )
	f.Replace  "いう", "おう"
	f = Empty
	Assert  fc( "work\out.txt", "work\charset_utf8bom_ans.txt" )

	Set cs = new_TextFileCharSetStack( "UTF-8" )
	Set f = OpenForReplace( "work\charset_utf8_nobom.txt", "work\out.txt" )
	f.Replace  "いう", "おう"
	f = Empty
	cs = Empty
	Assert  fc( "work\out.txt", "work\charset_utf8_nobom_ans.txt" )

	del  "work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplaceFindLines] >>> 
'********************************************************************************
Sub  T_OpenForReplaceFindLines( Opt, AppKey )



	Pass
End Sub


 
'********************************************************************************
'  <<< [T_StartReplace] >>> 
'********************************************************************************
Sub  T_StartReplace( Opt, AppKey )
	Dim rep, line, e
	Dim w_:Set w_= AppKey.NewWritable( Array( "work1.txt", "work2.txt", "T_CharCode" ) ).Enable()
	Dim c : Set c = g_VBS_Lib
	Dim section : Set section = new SectionTree

	'// SetStartSectionTree  "T_StartReplace_WithBackUpErrBeforeFin"


	'//================ Basic
	If section.Start( "T_StartReplace" ) Then

	'// set up
	copy_ren  "files\file1.txt",  "work1.txt"
	del  "work2.txt"

	'// Test Main
	Set rep = StartReplace( "work1.txt", "work2.txt", True )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "from", "to" )
		rep.w.WriteLine  line
	Loop
	rep.Finish

	'// check
	Assert  fc( "work2.txt", "files\file1_ans.txt" )

	'// clean
	del  "work1.txt" : del  "work2.txt"

	End If : section.End_


	'//================ Error before finish
	If section.Start( "T_StartReplace_ErrBeforeFin" ) Then

	'// set up
	copy_ren  "files\file1.txt",  "work1.txt"
	del  "work2.txt"

	'// Test Main
	If TryStart(e) Then  On Error Resume Next
		T_StartReplaceErrorBeforeFinish_sub  True
	If TryEnd Then  On Error GoTo 0
	If e.num <> 1 Then  Fail
	e.Clear

	'// check
	Assert  fc( "work1.txt", "files\file1.txt" )
	Assert  not exist( "work2.txt" )

	'// clean
	del  "work1.txt" : del  "work2.txt"

	End If : section.End_


	'//================ Error after finish
	If section.Start( "T_StartReplace_ErrAfterFin" ) Then

	'// set up
	copy_ren  "files\file1.txt",  "work1.txt"
	del  "work2.txt"

	'// Test Main
	If TryStart(e) Then  On Error Resume Next
		T_StartReplaceErrorAfterFinish_sub
	If TryEnd Then  On Error GoTo 0
	If e.num <> 1 Then  Fail
	e.Clear

	'// check
	Assert  fc( "work2.txt", "files\file1_ans.txt" )

	'// clean
	del  "work1.txt" : del  "work2.txt"

	End If : section.End_


	'//================= Keep line separator (1) first line sep. is CR+LF
	If section.Start( "T_StartReplace_KeepRet_1" ) Then

	'// set up
	del  "T_CharCode"
	unzip  "T_CharCode.zip", "T_CharCode", Empty

	'// Test Main
	Set rep = StartReplace( "T_CharCode\CRLF_LF_1.txt", "work1.txt", True )

	Assert  rep.w.LineSeparator = vbCRLF
	rep.w.WriteLine  "トップ"
	rep.w.WriteLineDefault  "LineDef(1)"+vbCRLF+"LineDef(2)"+vbLF+"LineDef(3)"
	rep.w.WriteLineDefault  "LineDef(4)"+vbCRLF
	rep.w.WriteLine  "LF"+vbLF
	Assert  rep.w.LineSeparator = vbLF
	rep.w.WriteLine  "no"
	rep.w.WriteLine  "CR+LF"+vbCRLF
	Assert  rep.w.LineSeparator = vbCRLF
	rep.w.WriteLine  "no"
	rep.w.WriteLine  "LF for next"+vbLF

	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		If rep.r.Line - 1 = 1 Then  Assert  Right( line, 2 ) = vbCRLF  '// First line
		If rep.r.Line - 1 = 2 Then  Assert  Right( line, 1 ) = vbLF

		line = Replace( line, "え", "" )
		line = Replace( line, "いう", "いうえ" )
		rep.w.WriteLine  line
	Loop
	rep.w.WriteLine  "no"
	Assert  rep.w.Line = 17
	rep.Finish


	'// check
	Assert  fc( "work1.txt", "T_CharCode\CRLF_LF_1_ans.txt" )

	'// clean
	del  "work1.txt"
	del  "T_CharCode"

	End If : section.End_


	'//================= Keep line separator (2) first line sep. is LF
	If section.Start( "T_StartReplace_KeepRet_2" ) Then

	'// set up
	del  "T_CharCode"
	unzip  "T_CharCode.zip", "T_CharCode", Empty

	'// Test Main
	Set rep = StartReplace( "T_CharCode\CRLF_LF_2.txt", "work1.txt", True )

	Assert  rep.w.LineSeparator = vbLF
	rep.w.WriteLine  "トップ"
	rep.w.WriteLineDefault  "LineDef(1)"+vbCRLF+"LineDef(2)"+vbLF+"LineDef(3)"
	rep.w.WriteLineDefault  "LineDef(4)"+vbCRLF
	rep.w.WriteLine  "no"
	rep.w.WriteLine  "LF"+vbLF
	rep.w.WriteLine  "CR+LF"+vbCRLF

	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "え", "" )
		line = Replace( line, "いう", "いうえ" )
		rep.w.WriteLine  line
	Loop
	rep.w.WriteLine  "no"
	Assert  rep.w.Line = 13
	rep.Finish


	'// check
	Assert  fc( "work1.txt", "T_CharCode\CRLF_LF_2_ans.txt" )

	'// clean
	del  "work1.txt"
	del  "T_CharCode"

	End If : section.End_


	'//================ with back up
	If section.Start( "T_StartReplace_WithBackUp" ) Then

	'// set up
	copy_ren  "files\file1.txt",  "work1.txt"
	del  "work2.txt"

	'// Test Main
	Set rep = StartReplace( "work1.txt", "work2.txt", c.DstIsBackUp )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "from", "to" )
		rep.w.WriteLine  line
	Loop
	rep.Finish

	'// check
	Assert  fc( "work1.txt", "files\file1_ans.txt" )
	Assert  fc( "work2.txt", "files\file1.txt" )

	'// clean
	del  "work1.txt" : del  "work2.txt"

	End If : section.End_


	'//================ with back up Error before finish
	If section.Start( "T_StartReplace_WithBackUpErrBeforeFin" ) Then

	'// set up
	copy_ren  "files\file1.txt",  "work1.txt"
	del  "work2.txt"

	'// Test Main
	If TryStart(e) Then  On Error Resume Next
		T_StartReplaceErrorBeforeFinish_sub  c.DstIsBackUp
	If TryEnd Then  On Error GoTo 0
	If e.num <> 1 Then  Fail
	e.Clear

	'// check
	Assert  fc( "work1.txt", "files\file1.txt" )
	Assert  not exist( "work2.txt" )

	'// clean
	del  "work1.txt" : del  "work2.txt"

	End If : section.End_


	Pass
End Sub


Sub  T_StartReplaceErrorBeforeFinish_sub( IsDstWillBeExist )
	Dim rep, line

	Set rep = StartReplace( "work1.txt", "work2.txt", IsDstWillBeExist )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "from", "to" )
		rep.w.WriteLine  line

		Error
	Loop
	rep.Finish
End Sub


Sub  T_StartReplaceErrorAfterFinish_sub()
	Dim rep, line

	Set rep = StartReplace( "work1.txt", "work2.txt", True )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()
		line = Replace( line, "from", "to" )
		rep.w.WriteLine  line
	Loop
	rep.Finish

	Error
End Sub


 
'********************************************************************************
'  <<< [T_PassThroughLineFilters] >>> 
'********************************************************************************
Sub  T_PassThroughLineFilters( Opt, AppKey )
	Dim w_:Set w_= AppKey.NewWritable( Array( "out.txt" ) ).Enable()


	'//=== basic case
	PassThroughLineFilters  "files\T_PassThroughLineFilters.txt", "out.txt", True, Empty, _
		Array( "(TRACE)", "(DEBUG)" )
	AssertFC  "out.txt", "files\T_PassThroughLineFilters_ans.txt"

	PassThroughLineFilters  "files\T_PassThroughLineFilters.txt", "out.txt", True, Empty, _
		Array( )
	Assert  ReadFile( "out.txt" ) = ""


	'//=== not matched line (Opt=False)
	PassThroughLineFilters  "files\T_PassThroughLineFilters.txt", "out.txt", True, False, _
		Array( "(TRACE)", "(DEBUG)" )
	AssertFC  "out.txt", "files\T_PassThroughLineFilters_ans_not.txt"

	PassThroughLineFilters  "files\T_PassThroughLineFilters.txt", "out.txt", True, False, _
		Array( )
	AssertFC  "out.txt", "files\T_PassThroughLineFilters.txt"

	del  "out.txt"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_FromLock] >>> 
'********************************************************************************
Sub  T_FromLock( Opt, AppKey )
	Dim  e, e2  ' as Err2
	Dim  retry_msec

	Dim w_:Set w_= AppKey.NewWritable( Array( "text1.txt", "text1_tmp.txt" ) ).Enable()

	del  "text1.txt"

	retry_msec = g_FileSystemMaxRetryMSec
	g_FileSystemMaxRetryMSec = 8*1000

	If TryStart(e) Then  On Error Resume Next
		T_FromLock_sub
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If e2.num <> 70 Then  Fail

	del  "text1.txt"
	g_FileSystemMaxRetryMSec = retry_msec

	Pass
End Sub


Sub  T_FromLock_sub()
	Dim rep, line, f

	Set f = g_fs.CreateTextFile( "text1.txt", True, False )
	f.WriteLine "text9"

	Set rep = StartReplace( "text1.txt", "text1_tmp.txt", False )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine
		line = Replace( line, "text", "TEXT" )
		rep.w.WriteLine  line
	Loop
	rep.Finish
	rep = Empty

	f = Empty

	Pass
End Sub

 
'********************************************************************************
'  <<< [T_StringStream] >>> 
'********************************************************************************
Sub  T_StringStream( Opt, AppKey )
	Set f = new StringStream

	'//=== ReadLine : EOF is not vbCRLF
	f.SetString  "123" +vbCRLF+ "456"

	Assert  not f.AtEndOfStream
	Assert  f.ReadLine() = "123"
	Assert  not f.AtEndOfStream
	Assert  f.ReadLine() = "456"
	Assert  f.AtEndOfStream


	'//=== ReadLine : EOF is vbCRLF
	f.SetString  "123" +vbCRLF+ "456" +vbCRLF
	Assert  not f.AtEndOfStream
	Assert  f.ReadLine() = "123"
	Assert  not f.AtEndOfStream
	Assert  f.ReadLine() = "456"
	Assert  f.AtEndOfStream


	'//=== ReadLine : return code is vbLF
	f.SetString  "123" +vbLF+ "456" +vbLF
	Assert  not f.AtEndOfStream
	Assert  f.ReadLine() = "123"
	Assert  not f.AtEndOfStream
	Assert  f.ReadLine() = "456"
	Assert  f.AtEndOfStream


	'//=== SetString and RealAll is not supported. Because vbCR is lost.
	f.SetString  "123" +vbCRLF+ "456" +vbCRLF

	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		text = f.ReadAll()

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'//=== WriteLine
	Set f = new StringStream

	f.WriteLine  "123"
	f.WriteLine  "456"
	text = f.ReadAll()

	Assert  text = "123"+vbCRLF+"456"+vbCRLF


	'//=== IsWithLineFeed
	Set rf = new StringStream  '// rf = Reading File
	Set wf = new StringStream  '// wf = Writing File
	rf.IsWithLineFeed = True
	wf.IsWithLineFeed = True

	a_str = "123"+ vbCRLF +"456"+ vbLF +"789"
	rf.SetString  a_str
	Do Until  rf.AtEndOfStream
		line = rf.ReadLine()
		wf.Write  line
	Loop
	Assert  wf.ReadAll() = a_str


	'//=== ReadingLineFeed
	Set rf = new StringStream  '// rf = Reading File
	rf.ReadingLineFeed = vbCRLF
	rf.SetString  "123"+ vbLF +"456"+ vbCRLF +"789"
	line = rf.ReadLine()
	Assert  line = "123"+ vbLF +"456"
	line = rf.ReadLine()
	Assert  line = "789"


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CutCRLF] >>> 
'********************************************************************************
Sub  T_CutCRLF( Opt, AppKey )
	Assert  CutCRLF( "A"+ vbCRLF +"B"+ vbLF +"C" ) = "ABC"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_GetPreviousLinePosition] >>> 
'********************************************************************************
Sub  T_GetPreviousLinePosition( Opt, AppKey )
	lines = _
		"A"+ vbCRLF +_
		"C"+ vbCRLF +_
		"F"+ vbCRLF +_
		"K"

	Assert  GetPreviousLinePosition( lines, InStr( lines, "F" ) ) = InStr( lines, "C" )
	Assert  GetPreviousLinePosition( lines, InStr( lines, "F" ) + 1 ) = InStr( lines, "F" )
	Assert  GetPreviousLinePosition( lines, 1 ) = 0
	Assert  GetPreviousLinePosition( lines, 2 ) = 1

	Assert  GetLeftEndOfLinePosition( lines, InStr( lines, "F" ) ) = InStr( lines, "F" )
	Assert  GetLeftEndOfLinePosition( lines, InStr( lines, "F" ) + 1 ) = InStr( lines, "F" )
	Assert  GetLeftEndOfLinePosition( lines, 1 ) = 1

	Assert  GetNextLinePosition( lines, InStr( lines, "F" ) ) = InStr( lines, "K" )
	Assert  GetNextLinePosition( lines, InStr( lines, "F" ) + 1 ) = InStr( lines, "K" )
	Assert  GetNextLinePosition( lines, InStr( lines, "K" ) ) = 0

	lines = _
		"A"+ vbCRLF +_
		""

	Assert  GetNextLinePosition( lines, InStr( lines, "A" ) ) = 0
	Assert  GetNextLinePosition( lines, InStr( lines, "A" ) + 3 ) = 0

	Assert  GetLeftEndOfLinePosition( lines, 2 ) = 1
	Assert  GetLeftEndOfLinePosition( lines, 4 ) = 4

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


 
