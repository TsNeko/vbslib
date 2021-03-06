Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_GetIniFileTextValue",_
			"2","T_SetIniFileTextValue",_
			"3","T_RegFile1",_
			"4","T_RegFileInterest",_
			"5","T_RegFileStr" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_GetIniFileTextValue] >>> 
'********************************************************************************
Sub  T_GetIniFileTextValue( Opt, AppKey )

	text = ReadFile( "Files\IniSample1.ini" )
	Assert  GetIniFileTextValue( text, Empty, "NameA", Empty ) = "AAA"
	Assert  GetIniFileTextValue( text, Empty, "NameB", Empty ) = "BBB"
	Assert  GetIniFileTextValue( text, Empty, "NameC", Empty ) = "CC"
	Assert  IsEmpty( GetIniFileTextValue( text, Empty, "UnknownName", Empty ) )

	text = ReadFile( "Files\IniSample2.ini" )
	Assert  GetIniFileTextValue( text, "SectionB", "NameA", Empty ) = "111"
	Assert  GetIniFileTextValue( text, "SectionB", "NameB", Empty ) = "222"
	Assert  GetIniFileTextValue( text, "SectionB", "NameC", Empty ) = "33"

	text = ReadFile( "Files\IniSample3.ini" )
	values = GetIniFileTextValues( text, "SectionB", "NameA", Empty )
	Assert  IsSameArray( values, Array( "111B" ) )
	values = GetIniFileTextValues( text, "SectionC", "NameA", Empty )
	Assert  IsSameArray( values, Array( "CCC1", 111 ) )
	values = GetIniFileTextValues( text, "SectionA", "NameD", Empty )
	Assert  IsSameArray( values, Array( ) )


	'// Test of "ParseIniFileLine"
	Set file = new StringStream
	file.SetString  _
		"[Section1]" +vbCRLF+ _
		"Name1 = Value1" +vbCRLF+ _
		" Name2 = Value2 " +vbCRLF+ _
		"Name3 =" +vbCRLF+ _
		"" +vbCRLF+ _
		"//" +vbCRLF+ _
		";" +vbCRLF+ _
		"Name4 = " +vbCRLF+ _
		"" +vbCRLF+ _
		"[Section2] " +vbCRLF+ _
		"Name5 = Value5"

	answer = DicTable( Array( _
		"Section",   "Name",   "Value",  Empty, _
		"Section1",  Empty,    Empty, _
		Empty,       "Name1",  "Value1", _
		Empty,       "Name2",  "Value2", _
		Empty,       "Name3",  "", _
		Empty,       Empty,    Empty, _
		Empty,       Empty,    Empty, _
		Empty,       Empty,    Empty, _
		Empty,       "Name4",  "", _
		Empty,       Empty,    Empty, _
		"Section2",  Empty,    Empty, _
		Empty,       "Name5",  "Value5" ) )

	i = 0
	Do Until  file.AtEndOfStream()
		line_string = file.ReadLine()
		Set line = ParseIniFileLine( line_string )

		Assert  IsSame( line.Section, answer(i)("Section") )
		Assert  IsSame( line.Name,    answer(i)("Name") )
		Assert  IsSame( line.Value,   answer(i)("Value") )
		i = i + 1
	Loop

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SetIniFileTextValue] >>> 
'********************************************************************************
Sub  T_SetIniFileTextValue( Opt, AppKey )

	'//===========================================================
	'// No section ini file

	For Each  file_name  In Array( "IniSample1.ini", "IniSample2.ini" )
	For Each  is_last_lf  In Array( false, true )
	For Each  t  In DicTable( Array( _
		"Name",   "ValueBefore", "ValueAfter", "ReplaceBefore", "ReplaceAfter",  Empty, _
		"NameA",  "AAA",         "a",          "AAA",           "a", _
		"NameB",  "BBB",         2,            "BBB",          " 2", _
		"NameC",  "CC",          "ccc",        " CC",           "ccc"  ) )

		before_text = ReadFile( "Files\"+ file_name )
		If is_last_lf Then _
			before_text = before_text + vbCRLF

		'// TestMain
		If file_name = "IniSample1.ini" Then
			after_text = SetIniFileTextValue( before_text, Empty, _
				t("Name"), t("ValueAfter"), Empty )
		Else
			after_text = SetIniFileTextValue( before_text, "SectionA", _
				t("Name"), t("ValueAfter"), Empty )
		End If

		'// Check
		Assert  after_text = Replace( before_text, _
			t("ReplaceBefore"), t("ReplaceAfter") )
	Next
	Next
	Next


	'//===========================================================
	'// With section ini file

	For Each  section_name  In Array( "SectionB", "[SectionB]" )
	For Each  is_last_lf  In Array( false, true )
	For Each  t  In DicTable( Array( _
		"Name",   "ValueBefore", "ValueAfter", "ReplaceBefore", "ReplaceAfter",  Empty, _
		"NameA",  "AAA",         "a",          "111",           "a", _
		"NameB",  "BBB",         2,            "222",          " 2", _
		"NameC",  "CC",          "ccc",        " 33",           "ccc"  ) )

		before_text = ReadFile( "Files\IniSample2.ini" )
		If is_last_lf Then _
			before_text = before_text + vbCRLF

		'// TestMain
		after_text = SetIniFileTextValue( before_text, section_name, _
			t("Name"), t("ValueAfter"), Empty )

		'// Check
		Assert  after_text = Replace( before_text, _
			t("ReplaceBefore"), t("ReplaceAfter") )
	Next
	Next
	Next


	'//=== Error Handling Test : Unknown variable name
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		after_text = SetIniFileTextValue( before_text, Empty, _
			"UnknownName", "1", Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_RegFile1] >>> 
'********************************************************************************
Sub  T_RegFile1( Opt, AppKey )
	Set f = LoadReg( "Files\Sample1.reg", Empty )
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Enable" )
	If v <> 1 Then  Fail

	Set f = LoadReg( "Files\Sample2.reg", Empty )
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub1\Enable1" )
	If v <> 1 Then  Fail
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub1\Enable2" )
	If v <> 2 Then  Fail
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub2\Enable1" )
	If v <> 3 Then  Fail
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub2\Enable2" )
	If v <> &h8F000000 Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_RegFileInterest] >>> 
'********************************************************************************
Sub  T_RegFileInterest( Opt, AppKey )
	Set f = LoadReg( "Files\Sample2.reg", "HKEY_LOCAL_MACHINE\Sample\Sub2" )
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub1\Enable1" )
	If not IsEmpty( v ) Then  Fail
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub1\Enable2" )
	If not IsEmpty( v ) Then  Fail
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub2\Enable1" )
	If v <> 3 Then  Fail
	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub2\Enable2" )
	If v <> &h8F000000 Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_RegFileStr] >>> 
'********************************************************************************
Sub  T_RegFileStr( Opt, AppKey )
	Set f = LoadReg(_
		 "[HKEY_LOCAL_MACHINE\Sample\Sub1]"+vbCRLF+_
		 "    ""Enable1""=dword:1"+vbCRLF, F_Str )

	v = f.RegRead( "HKEY_LOCAL_MACHINE\Sample\Sub1\Enable1" )
	If not IsEmpty( v ) Then  Fail

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


 
