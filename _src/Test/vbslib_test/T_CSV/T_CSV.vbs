Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_CSV",_
			"2","T_CSVText",_
			"3","T_CSV_insert",_
			"4","T_CSV_set",_
			"5","T_CSV_remove" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_CSV] >>> 
'********************************************************************************
Sub  T_CSV( Opt, AppKey )
	Dim  i, s, line

	line = "abc,def, ghi ,"" jkl"", ""mno"" , ,, ""p""""q"""
	i = 1

	s = MeltCSV( line, i )
	If s <> "abc" Then Fail
	If i <> 5 Then Fail

	s = MeltCSV( line, i )
	If s <> "def" Then Fail
	If i <> 9 Then Fail

	s = MeltCSV( line, i )
	If s <> "ghi" Then Fail
	If i <> 15 Then Fail

	s = MeltCSV( line, i )
	If s <> " jkl" Then Fail
	If i <> 22 Then Fail

	s = MeltCSV( line, i )
	If s <> "mno" Then Fail
	If i <> 30 Then Fail

	s = MeltCSV( line, i )
	If s <> "" Then Fail
	If i <> 32 Then Fail

	s = MeltCSV( line, i )
	If s <> "" Then Fail
	If i <> 33 Then Fail

	s = MeltCSV( line, i )
	If s <> "p""q" Then Fail
	If i <> 0 Then Fail

	s = MeltCSV( line, i )
	If s <> "" Then Fail
	If i <> 0 Then Fail


	'// ArrayFromCSV
	s = ArrayFromCSV( " ABC , DEF " )
	Assert  IsSameArray( s, Array( "ABC", "DEF" ) )

	s = ArrayFromCSV( " ABC , " )
	Assert  s(0) = "ABC"
	Assert  IsEmpty( s(1) )

	s = ArrayFromCSV( " ABC , """"" )
	Assert  s(0) = "ABC"
	Assert  VarType( s(1) ) = vbString
	Assert  s(1) = ""

	s = ArrayFromCSV( " " )
	Assert  UBound( s ) = -1

	s = ArrayFromCSV( " A, B," +vbCRLF+ "C" )
	Assert  IsSameArray( s, Array( "A", "B", "C" ) )


	s = ArrayFromCSV_Int( " 123 , -456 " )
	Assert  IsSameArray( s, Array( 123, -456 ) )


	'// CSVFrom
	Assert  CSVFrom( Array( "a", "b" ) ) = "a,b"
	Assert  CSVFrom( Empty )    = ""  and  VarType( CSVFrom( Empty ) )    = vbString
	Assert  CSVFrom( Array( ) ) = ""  and  VarType( CSVFrom( Array( ) ) ) = vbString
	Assert  CSVFrom( Array( "a" ) ) = "a"


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CSVText] >>> 
'********************************************************************************
Sub  T_CSVText( Opt, AppKey )
	Assert  CSVText( "a" ) = "a"
	Assert  CSVText( " a" ) = """ a"""
	Assert  CSVText( "a b" ) = "a b"
	Assert  CSVText( "a " ) = """a """
	Assert  CSVText( "a""b" ) = """a""""b"""
	Assert  CSVText( 1 ) = "1"
	Assert  VarType( CSVText( 1 ) ) = vbString

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CSV_insert] >>> 
'********************************************************************************
Sub  T_CSV_insert( Opt, AppKey )

	Assert  CSV_insert( "A,B,C", 1, "x" ) = "A,x,B,C"


	'// Case of insert position
	Assert  CSV_insert( "A,B,C", 0, "xx" ) = "xx,A,B,C"
	Assert  CSV_insert( "A,B,C", 3, "xx" ) = "A,B,C,xx"
	Assert  CSV_insert( "A,B,C", 4, "xx" ) = "A,B,C,,xx"
	Assert  CSV_insert( "", 0, "x" ) = "x"
	Assert  CSV_insert( "", 1, "x" ) = ",x"
	Assert  CSV_insert( "A", 0, "x" ) = "x,A"
	Assert  CSV_insert( "A", 1, "x" ) = "A,x"


	'// Case of " " for the space
	Assert  CSV_insert( "A,B,C", 1, " xx" ) = "A,"" xx"",B,C"


	'//=== Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		CSV_insert  "A,B,C", -1, "xx"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CSV_set] >>> 
'********************************************************************************
Sub  T_CSV_set( Opt, AppKey )

	Assert  CSV_set( "A,B,C", 1, "x" ) = "A,x,C"


	'// Case of insert position
	Assert  CSV_set( "A,B,C", 0, "xx" ) = "xx,B,C"
	Assert  CSV_set( "A,B,C", 3, "xx" ) = "A,B,C,xx"
	Assert  CSV_set( "A,B,C", 4, "xx" ) = "A,B,C,,xx"
	Assert  CSV_set( "", 0, "x" ) = "x"
	Assert  CSV_set( "", 1, "x" ) = ",x"
	Assert  CSV_set( "A", 0, "x" ) = "x"
	Assert  CSV_set( "A", 1, "x" ) = "A,x"


	'// Case of " " for the space
	Assert  CSV_set( "A,B,C", 1, " xx" ) = "A,"" xx"",C"


	'//=== Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		CSV_set  "A,B,C", -1, "xx"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CSV_remove] >>> 
'********************************************************************************
Sub  T_CSV_remove( Opt, AppKey )

	Assert  CSV_remove( "A,B,C", 1 ) = "A,C"


	'// Case of insert position
	Assert  CSV_remove( "A,B,C", 0 ) = "B,C"
	Assert  CSV_remove( "A,B,C",  3 ) = "A,B,C"
	Assert  CSV_remove( "A,B,C,", 3 ) = "A,B,C"
	Assert  CSV_remove( "A,B,C", 4 ) = "A,B,C,"
	Assert  CSV_remove( "", 0 ) = ""
	Assert  CSV_remove( "", 1 ) = ","
	Assert  CSV_remove( "A", 0 ) = ""
	Assert  CSV_remove( "A", 1 ) = "A"


	'//=== Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		CSV_remove  "A,B,C", -1

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

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

 
