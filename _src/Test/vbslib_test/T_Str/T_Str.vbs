Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1", "T_StrComp",_
			"2", "T_StrCount",_
			"3", "T_MeltQuot",_
			"4", "T_sscanf",_
			"5", "T_ScanFromTemplate",_
			"6", "T_ScanMultipleFromTemplate",_
			"7", "T_Trim2",_
			"8", "T_InStrLast",_
			"9", "T_InStrEx",_
			"10","T_InStrExWholeWord",_
			"11","T_InStrExArray",_
			"12","T_InStrExLineHeadTail",_
			"13","T_AddIfNotExist" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_StrComp] >>> 
'********************************************************************************
Sub  T_StrComp( Opt, AppKey )
	Dim  s
	Dim  c : Set c = g_VBS_Lib

	s = "abcde" : CutLastOf  s, "de", Empty : Assert  s = "abc"
	s = "abcde" : CutLastOf  s, "DE", Empty : Assert  s = "abc"
	s = "abcde" : CutLastOf  s, "", Empty   : Assert  s = "abcde"
	s = "abcde" : CutLastOf  s, "DE", c.CaseSensitive : Assert  s = "abcde"

	s = "abc.abc.de" : CutLastOfFileName  s, "bc", Empty : Assert  s = "abc.a.de"
	s = "abc.abc.de" : CutLastOfFileName  s, "BC", Empty : Assert  s = "abc.a.de"
	s = "abc.abc.de" : CutLastOfFileName  s, "cc", Empty : Assert  s = "abc.abc.de"
	s = "abc.abc.de" : CutLastOfFileName  s, "bc", c.CaseSensitive : Assert  s = "abc.a.de"
	s = "abc.abc.de" : CutLastOfFileName  s, "BC", c.CaseSensitive : Assert  s = "abc.abc.de"
	s = "abc"        : CutLastOfFileName  s, "BC", Empty : Assert  s = "a"

	Assert  StrCompHeadOf( "abc.de", "AbC.", Empty ) = 0
	Assert  StrCompHeadOf( "abc.de", "abE",  Empty ) < 0
	Assert  StrCompHeadOf( "abc",    "AbCd", Empty ) < 0
	Assert  StrCompHeadOf( "abc.de", "AbC", c.CaseSensitive ) <> 0

	Assert  StrCompLastOf( "abc.de", "c.de", Empty ) = 0
	Assert  StrCompLastOf( "abc.de", "C.DE", Empty ) = 0
	Assert  StrCompLastOf( "abc.de", "C.DE", c.CaseSensitive ) <> 0

	Assert  StrCompLastOfFileName( "abc.abc.de", "bc", Empty ) = 0
	Assert  StrCompLastOfFileName( "abc.abc.de", "de", Empty ) <> 0
	Assert  StrCompLastOfFileName( "abc.abc.de", "BC", Empty ) = 0
	Assert  StrCompLastOfFileName( "abc.abc.de", "BC", c.CaseSensitive ) <> 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_StrCount] >>> 
'********************************************************************************
Sub  T_StrCount( Opt, AppKey )
	Dim  s
	Dim  c : Set c = g_VBS_Lib

	Assert  StrCount( "ABCABC", "ABC", 1, Empty ) = 2
	Assert  StrCount( "ABCABC", "B",   1, Empty ) = 2
	Assert  StrCount( "ABCABC", "D",   1, Empty ) = 0
	Assert  StrCount( "/ABC/ABC", "/", 2, Empty ) = 1
	Assert  StrCount( "/ABC/abc", "b", 2, Empty ) = 2
	Assert  StrCount( "/ABC/abc", "b", 2, c.CaseSensitive ) = 1

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_MeltQuot] >>> 
'********************************************************************************
Sub  T_MeltQuot( Opt, AppKey )
	Dim    i
	Const  line = " ""ABC"" ""456"""

	i = 1
	Assert  MeltQuot( line, i ) = "ABC"
	Assert  MeltQuot( line, i ) = "456"
	Assert  IsEmpty( MeltQuot( line, i ) )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_sscanf] >>> 
'********************************************************************************
Sub  T_sscanf( Opt, AppKey )
	Assert  sscanf( "<<< [113] >>>", "<<< [%d] >>>" ) = 113
	Assert  sscanf( "<<< [Title] >>>", "<<< [%s] >>>" ) = "Title"
	Assert  sscanf( "===<<< [113] >>>===", "<<< [%d] >>>" ) = 113
	Assert  sscanf( "===[ [ 123 ] ]===", "[%s]" ) = " [ 123 "
	Assert  sscanf( "===[123] [456]===", "[%s]" ) = "123"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ScanFromTemplate] >>> 
'********************************************************************************
Sub  T_ScanFromTemplate( Opt, AppKey )

	'//===========================================================
	'// テンプレートが先頭にマッチするとき
	Set out = ScanFromTemplate(_
		"ab12cde"+ vbCRLF +"/xyz/hi",_
		"ab%A%cde"+ vbCRLF +"/$a/$bi",_
		Array( "%A%", "$a", "$b" ), Empty )
	Assert  out("%A%") = "12"
	Assert  out("$a")  = "xyz"
	Assert  out("$b")  = "h"


	'//===========================================================
	'// テンプレートが先頭より後にマッチするとき
	Set out = ScanFromTemplate(_
		"ab12cde34xyz",_
		"b%A%cde$axy",_
		Array( "%A%", "$a" ), Empty )
	Assert  out("%A%") = "12"
	Assert  out("$a")  = "34"


	'//===========================================================
	'// 最初のキーワード（%A%）より前のテンプレートのテキストが複数にマッチするとき
	Set out = ScanFromTemplate(_
		"  a1x_a2y_a3z_a4z",_
		"a%A%z",_
		Array( "%A%" ), Empty )
	Assert  out("%A%") = "3"


	'//===========================================================
	'// Case of get empty string
	Set out = ScanFromTemplate(_
		"  az",_
		"a%A%z",_
		Array( "%A%" ), Empty )
	Assert  out("%A%") = ""


	'//===========================================================
	'// Error Handling Test : Bad last TemplateString
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set out = ScanFromTemplate(_
			"ab12cde"+ vbCRLF +"/xyz/hX",_
			"ab%A%cde"+ vbCRLF +"/$a/hi",_
			Array( "%A%", "$a" ), Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'//===========================================================
	'// Error Handling Test : Bad first TemplateString
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set out = ScanFromTemplate(_
			"ab12cde"+ vbCRLF +"/xyz/hi",_
			"Xb%A%cde"+ vbCRLF +"/$a/$bi",_
			Array( "%A%", "$a", "$b" ), Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'//===========================================================
	'// Error Handling Test : Bad Keyword
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set out = ScanFromTemplate(_
			"ab12cde"+ vbCRLF +"/xyz/hi",_
			"ab%A%cde"+ vbCRLF +"/$a/hi",_
			Array( "%A%", "$x" ), Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'//===========================================================
	'// Error Handling Test : Bad Order
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set out = ScanFromTemplate(_
			"ab12cde"+ vbCRLF +"/xyz/hi",_
			"ab%A%cde"+ vbCRLF +"/$a/hi",_
			Array( "$a", "%A%" ), Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0
	Assert  InStr( e2.desc, "順番を変えてください" ) > 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ScanMultipleFromTemplate] >>> 
'********************************************************************************
Sub  T_ScanMultipleFromTemplate( Opt, AppKey )

	'//===========================================================
	ScanMultipleFromTemplate  "a1x a2x a3z a4a5x a6", "a#x", "#", Empty, scaned  '//(out) scaned

	Assert  IsSameArray( scaned, Array( "1", "2", "5" ) )


	'//===========================================================
	ScanMultipleFromTemplate  "a1xx11z a2xx22 a3xx33z a4xx", "a#xx$z", _
		Array( "#", "$" ), Empty, scaned  '//(out) scaned

	Assert  UBound( scaned ) = 2 - 1
	Assert  IsSameDictionary( scaned(0), Dict(Array( "#","1", "$","11" )), Empty )
	Assert  IsSameDictionary( scaned(1), Dict(Array( "#","3", "$","33" )), Empty )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Trim2] >>> 
'********************************************************************************
Sub  T_Trim2( Opt, AppKey )
	Assert  Trim2( "ABC" )   = "ABC"
	Assert  Trim2( " ABC " ) = "ABC"
	Assert  Trim2( vbTab +" ABC "+ vbTab ) = "ABC"
	Assert  Trim2( vbCRLF + vbTab +" ABC "+ vbCRLF + vbLF + vbCRLF ) = "ABC"
	Assert  Trim2( vbTab +"("+ vbTab +" ABC "+ vbCRLF +")"+ vbCRLF ) = "("+ vbTab +" ABC "+ vbCRLF +")"

	Assert  LTrim2( vbTab +" ABC "+ vbTab ) = "ABC "+ vbTab
	Assert  RTrim2( vbTab +" ABC "+ vbTab ) = vbTab +" ABC"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_InStrLast] >>> 
'********************************************************************************
Sub  T_InStrLast( Opt, AppKey )
	Assert  InStrLast( "ABCDEF", "CD" ) = 5
	Assert  InStrLast( "ABCDEF", "DC" ) = 0
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_InStrEx] >>> 
'********************************************************************************
Sub  T_InStrEx( Opt, AppKey )
	Set c = g_VBS_Lib

	Assert  InStrEx( "answer ans", "Ans", 1, Empty ) = 1
	Assert  InStrEx( "answer ans", "Ans", 1, c.WholeWord ) = 8
	Assert  InStrEx( "answer Ans", "Ans", 1, c.CaseSensitive ) = 8
	Assert  InStrEx( "answer ans", "Ans",-1, c.Rev ) = 8
	Assert  InStrEx( "answer Ans", "Ans", 1, c.LastNextPos ) = 4

	Assert  InStrEx( "n", "Ans", 1, Empty ) = 0
	Assert  InStrEx( "n", "Ans", 1, c.WholeWord ) = 0
	Assert  InStrEx( "n", "Ans", 1, c.CaseSensitive ) = 0
	Assert  InStrEx( "n", "Ans",-1, c.Rev ) = 0
	Assert  InStrEx( "n", "Ans", 1, c.LastNextPos ) = 0

	Assert  InStrEx( "xaxax", "a", 0, Empty ) = 2
	Assert  InStrEx( "xaxax", "a", 0, c.Rev ) = 4

	Assert  InStrEx( "answer ans Ans", "Ans", 1, c.WholeWord or c.CaseSensitive ) = 12
	Assert  InStrEx( "ans ans Ans", "ans", -1, c.CaseSensitive or c.Rev ) = 5

	Assert  InStrEx( "ABCDEF", "CD", 1, c.LastNextPos ) = 5
	Assert  InStrEx( "ABCDEF", "DC", 1, c.LastNextPos ) = 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_InStrExWholeWord] >>> 
'********************************************************************************
Sub  T_InStrExWholeWord( Opt, AppKey )
	Set c = g_VBS_Lib

	Assert  InStrEx( "x",  "x", 1, c.WholeWord ) = 1
	Assert  InStrEx( "/x", "x", 1, c.WholeWord ) = 2
	Assert  InStrEx(  "x/","x", 1, c.WholeWord ) = 1
	Assert  InStrEx( "0x", "x", 1, c.WholeWord ) = 0
	Assert  InStrEx(  "x0","x", 1, c.WholeWord ) = 0
	Assert  InStrEx( "9x", "x", 1, c.WholeWord ) = 0
	Assert  InStrEx(  "x9","x", 1, c.WholeWord ) = 0
	Assert  InStrEx( ":x", "x", 1, c.WholeWord ) = 2
	Assert  InStrEx(  "x:","x", 1, c.WholeWord ) = 1
	Assert  InStrEx( "@x", "x", 1, c.WholeWord ) = 2
	Assert  InStrEx(  "x@","x", 1, c.WholeWord ) = 1
	Assert  InStrEx( "Ax", "x", 1, c.WholeWord ) = 0
	Assert  InStrEx(  "xA","x", 1, c.WholeWord ) = 0
	Assert  InStrEx( "Zx", "x", 1, c.WholeWord ) = 0
	Assert  InStrEx(  "xZ","x", 1, c.WholeWord ) = 0
	Assert  InStrEx( "[x", "x", 1, c.WholeWord ) = 2
	Assert  InStrEx(  "x[","x", 1, c.WholeWord ) = 1
	Assert  InStrEx( "`x", "x", 1, c.WholeWord ) = 2
	Assert  InStrEx(  "x`","x", 1, c.WholeWord ) = 1
	Assert  InStrEx( "ax", "x", 1, c.WholeWord ) = 0
	Assert  InStrEx(  "xa","x", 1, c.WholeWord ) = 0
	Assert  InStrEx( "zx", "x", 1, c.WholeWord ) = 0
	Assert  InStrEx(  "xz","x", 1, c.WholeWord ) = 0
	Assert  InStrEx( "{x", "x", 1, c.WholeWord ) = 2
	Assert  InStrEx(  "x{","x", 1, c.WholeWord ) = 1
	Assert  InStrEx( "あx", "x", 1, c.WholeWord ) = 2
	Assert  InStrEx(  "xあ","x", 1, c.WholeWord ) = 1

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_InStrExArray] >>> 
'********************************************************************************
Sub  T_InStrExArray( Opt, AppKey )
	Set c = g_VBS_Lib

	Assert  InStrEx( "abcde", Array( "bc", "cd" ), 0, Empty ) = 2
	Assert  InStrEx( "abcde", Array( "cd", "bc" ), 0, Empty ) = 2
	Assert  InStrEx( "abcde", Array( "bc", "cd" ), 0, c.Rev ) = 3
	Assert  InStrEx( "abcde", Array( "cd", "bc" ), 0, c.Rev ) = 3

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_InStrExLineHeadTail] >>> 
'********************************************************************************
Sub  T_InStrExLineHeadTail( Opt, AppKey )
	Set c = g_VBS_Lib


	'//===========================================================
	'// Use "c.LineHead"
	'//  123     4 5    67     8 9    01     2 3    4567
	s = "abc"+ vbCRLF +"BC"+ vbCRLF +"bc"+ vbCRLF +"AB D"
	Assert  InStrEx( s, "ab", 0, c.LineHead ) = 1
	Assert  InStrEx( s, "AB", 0, c.LineHead ) = 1
	Assert  InStrEx( s, "bc", 0, c.LineHead ) = 6
	Assert  InStrEx( s, "bc", 0, c.LineHead or c.CaseSensitive ) = 10
	Assert  InStrEx( s, "ab", 0, c.LineHead or c.WholeWord ) = 14


	'//===========================================================
	'// Use "c.LineHead", "c.Rev"
	'//  1234     5 6    78     9 0    12     3 4    567
	s = "AB D"+ vbCRLF +"bc"+ vbCRLF +"BC"+ vbCRLF +"abc"
	Assert  InStrEx( s, "ab", 0, c.Rev or c.LineHead ) = 15
	Assert  InStrEx( s, "AB", 0, c.Rev or c.LineHead ) = 15
	Assert  InStrEx( s, "bc", 0, c.Rev or c.LineHead ) = 11
	Assert  InStrEx( s, "bc", 0, c.Rev or c.LineHead or c.CaseSensitive ) = 7
	Assert  InStrEx( s, "ab", 0, c.Rev or c.LineHead or c.WholeWord ) = 1


	'//===========================================================
	'// Use "c.LineTail"
	'//  123     4 5    67     8 9    01     2 3    4567
	s = "abc"+ vbCRLF +"AB"+ vbCRLF +"ab"+ vbCRLF +"A BC"
	Assert  InStrEx( s, "bc", 0, c.LineTail ) = 2
	Assert  InStrEx( s, "BC", 0, c.LineTail ) = 2
	Assert  InStrEx( s, "ab", 0, c.LineTail ) = 6
	Assert  InStrEx( s, "ab", 0, c.LineTail or c.CaseSensitive ) = 10
	Assert  InStrEx( s, "bc", 0, c.LineTail or c.WholeWord ) = 16
	Assert  InStrEx( s, "A BC", 0, c.LineTail ) = 14
	Assert  InStrEx( s, "A B",  0, c.LineTail ) = 0
	Assert  InStrEx( s, "A ",   0, c.LineTail ) = 0
	Assert  InStrEx( s + vbCRLF, "A BC", 0, c.LineHead or c.LineTail ) = 14
	Assert  InStrEx( s, "A B",  0, Empty ) = 14


	'//===========================================================
	'// Use "c.LineTail", "c.Rev"
	'//  1234     5 6    78     9 0    12     3 4    567
	s = "A BC"+ vbCRLF +"ab"+ vbCRLF +"AB"+ vbCRLF +"abc"
	Assert  InStrEx( s, "bc", 0, c.Rev or c.LineTail ) = 16
	Assert  InStrEx( s, "BC", 0, c.Rev or c.LineTail ) = 16
	Assert  InStrEx( s, "ab", 0, c.Rev or c.LineTail ) = 11
	Assert  InStrEx( s, "ab", 0, c.Rev or c.LineTail or c.CaseSensitive ) = 7
	Assert  InStrEx( s, "bc", 0, c.Rev or c.LineTail or c.WholeWord ) = 3


	'//===========================================================
	'// Use "c.LineHead", "c.LineTail"
	'//  1234     5 6    7890     1 2    345     6 7    890     1 2    3456
	s = " abc"+ vbCRLF +"abc "+ vbCRLF +"abc"+ vbCRLF +"abc"+ vbCRLF +"tail"
	Assert  InStrEx( s, "abc",  0, c.LineHead or c.LineTail ) = 13
	Assert  InStrEx( s, "ABC",  0, c.LineHead or c.LineTail ) = 13
	Assert  InStrEx( s, "ABC",  0, c.LineHead or c.LineTail or c.CaseSensitive ) = 0
	Assert  InStrEx( s, "tail", 0, c.LineHead or c.LineTail ) = 23


	'//===========================================================
	'// Use "c.LineHead", "c.LineTail", "c.Rev"
	'//  1234     5 6    789     0 1    234     5 6    7890     1 2    3456
	s = "head"+ vbCRLF +"abc"+ vbCRLF +"abc"+ vbCRLF +"abc "+ vbCRLF +" abc"
	Assert  InStrEx( s, "abc",  0, c.Rev or c.LineHead or c.LineTail ) = 12
	Assert  InStrEx( s, "ABC",  0, c.Rev or c.LineHead or c.LineTail ) = 12
	Assert  InStrEx( s, "ABC",  0, c.Rev or c.LineHead or c.LineTail or c.CaseSensitive ) = 0
	Assert  InStrEx( s, "head", 0, c.Rev or c.LineHead or c.LineTail ) = 1

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_AddIfNotExist] >>> 
'********************************************************************************
Sub  T_AddIfNotExist( Opt, AppKey )
	Dim  c : Set c = g_VBS_Lib

	Assert  AddIfNotExist( "ABC;DEF", "XYZ", ";", Empty ) = "XYZ;ABC;DEF"
	Assert  AddIfNotExist( "ABC,XYZ", "XYZ", ",", Empty ) = "ABC,XYZ"
	Assert  AddIfNotExist( "ABC,xyz", "XYZ", ",", Empty ) = "ABC,xyz"
	Assert  AddIfNotExist( "XYZ,ABC,xyz", "XYZ", ",", c.CaseSensitive ) = "XYZ,ABC,xyz"
	Assert  AddIfNotExist( "", "XYZ", ";", Empty ) = "XYZ;"

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
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
