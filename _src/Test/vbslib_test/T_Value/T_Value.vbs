Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_LenK",_
			"2","T_DateAddStr",_
			"3","T_AssertValue",_
			"4","T_EchoStr",_
			"5","T_ChangeNumToCommandOrNot" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_LenK] >>> 
'********************************************************************************
Sub  T_LenK( Opt, AppKey )
	EchoTestStart  "T_LenK"
	If LenK("abc") <> 3 Then  Fail
	If LenK("abあc") <> 5 Then  Fail
	If LenK("雑１") <> 4 Then  Fail
End Sub


 
'********************************************************************************
'  <<< [T_DateAddStr] >>> 
'********************************************************************************
Sub  T_DateAddStr( Opt, AppKey )
	Dim  d1, d2

	EchoTestStart  "T_DateAddStr"

	d1 = DateAddStr( CDate("2009/1/1"), "+1month 10days" )
	d2 = CDate("2009/2/11")
	If Abs(DateDiff("s", d1, d2 )) >= 1 Then  Fail

	d1 = DateAddStr( CDate("17:00"), "-8hours" )
	d2 = CDate("9:00")
	If Abs(DateDiff("s", d1, d2 )) >= 1 Then  Fail

	d1 = DateAddStr( CDate("2010/1/1 1:11:01"), "1year 1month 1day 1hour -1minute 1second" )
	d2 = CDate("2011/2/2 2:10:00")
	If Abs(DateDiff("s", d1, d2 )) >= 1 Then  Fail

	d1 = DateAddStr( CDate("2010/2/2 2:22:22"), "-1years 1months 1days -1hours +1minutes 1seconds" )
	d2 = CDate("2009/1/1 1:23:23")
	If Abs(DateDiff("s", d1, d2 )) >= 1 Then  Fail

	d1 = DateAddStr( CDate("11:11:11"), "+1min+1sec" )
	d2 = CDate("11:12:12")
	If Abs(DateDiff("s", d1, d2 )) >= 1 Then  Fail
End Sub


 
'********************************************************************************
'  <<< [T_AssertValue] >>> 
'********************************************************************************
Sub  T_AssertValue( Opt, AppKey )
	Dim  en,ed,e
	Dim  c : Set c = g_VBS_Lib

	EchoTestStart  "T_AssertValue"

	'//=== check number
	AssertValue  "Number", 1, 1, Empty
	AssertValue  "Number", 1, Array( 1, 2 ), Empty
	AssertValue  "Number", 2, Array( 1, 2 ), Empty
	AssertValue  "Number", 2, Array( 1, 3 ), c.Range
	AssertValue  "Number", 1, Array( 1, 3 ), c.Range
	AssertValue  "Number", 3.1, Array( 1.2, 3.1 ), c.Range

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Number", 1, 2, Empty
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Number", 1

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Number", 2, Array( 1, 3 ), Empty
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Number", 2

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Number", 0, Array( 1, 3 ), c.Range
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Number", 0

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Number", 4, Array( 1, 3 ), c.Range
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Number", 4


	'//=== check string
	AssertValue  "Str", "ABC", "ABC", Empty
	AssertValue  "Str", "ABC", "abc", Empty
	AssertValue  "Str", "ABC", "ABC", c.CaseSensitive
	AssertValue  "Str", "ABC", Array( "A", "ABC" ), Empty

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Str", "ABC", "abc", c.CaseSensitive
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Str", "ABC"

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Str", "ABC", Array( "A", "abc" ), c.CaseSensitive
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Str", "ABC"


	'//=== check Empty
	AssertValue  "Empty", Empty, Empty, Empty

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Empty", Empty, "1", Empty
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Empty", Empty


	'//=== check envitonment variable
	SetVar  "Var1", "ABC"
	AssertValue  "Var1", c.EnvVar, "ABC", Empty
	AssertValue  "Var1", c.EnvVar, "abc", Empty

	If TryStart(e) Then  On Error Resume Next
		AssertValue  "Var1", c.EnvVar, "X", Empty
	If TryEnd Then  On Error GoTo 0
	T_AssertValue_check  e, "Var1", "ABC"
End Sub


Sub  T_AssertValue_check( e, Name, Value )
	If e.num <> 1 Then  Err.Raise en,,ed
	If e.desc <> "<ERROR msg=""値が想定外です"" name="""+ Name +""" now_value="""& Value &"""/>" Then  Err.Raise en,,ed
	e.Clear
End Sub


 
'********************************************************************************
'  <<< [T_EchoStr] >>> 
'********************************************************************************
Sub  T_EchoStr( Opt, AppKey )
	Dim  dic : Set dic = CreateObject( "Scripting.Dictionary" )
	Dim  str, ans

	EchoTestStart  "T_EchoStr"

	Assert  GetEchoStr( "A" ) = "A"
	Assert  GetEchoStr( 2 ) = "2"
	Assert  GetEchoStr( 1.2 ) = "1.2"

	ans = _
		"<Array ubound=""1"">"+vbCRLF+_
		"  <Item id=""0"">A</Item>"+vbCRLF+_
		"  <Item id=""1"">B</Item>"+vbCRLF+_
		"</Array>"
	Assert  GetEchoStr( Array( "A", "B" ) ) = ans

	ans = _
		"<Array ubound=""1"">"+vbCRLF+_
		"  <Item id=""0"">A</Item>"+vbCRLF+_
		"  <Item id=""1""><Array ubound=""1"">"+vbCRLF+_
		"    <Item id=""0"">B1</Item>"+vbCRLF+_
		"    <Item id=""1"">B2</Item>"+vbCRLF+_
		"  </Array></Item>"+vbCRLF+_
		"</Array>"
	Assert  GetEchoStr( Array( "A", Array( "B1", "B2" ) ) ) = ans

	'//=== Test of Dictionary_xml_sub
	dic.RemoveAll
	dic("Key1") = "Item1"
	dic("Key2") = "Item2"
	ans = _
		"<Dictionary count=""2"">{" +vbCRLF+_
		"  ""Key1"" : ""Item1""," +vbCRLF+_
		"  ""Key2"" : ""Item2""," +vbCRLF+_
		"}</Dictionary>"
	Assert  GetEchoStr( dic ) = ans

	dic.RemoveAll
	dic("Key1") = "Item1"
	dic("Key2") = Array( "B1", "B2" )
	ans = _
		"<Dictionary count=""2"">{"+vbCRLF+_
		"  ""Key1"" : ""Item1"","+vbCRLF+_
		"  ""Key2"" : ""<Array ubound=""""1"""">"+vbCRLF+_
		"    <Item id=""""0"""">B1</Item>"+vbCRLF+_
		"    <Item id=""""1"""">B2</Item>"+vbCRLF+_
		"  </Array>"","+vbCRLF+_
		"}</Dictionary>"
	Assert  GetEchoStr( dic ) = ans

	'//=== Test of SWbemObjectEx_xml_sub
	WaitForJustSecond
	Dim  n : n = Now()
	ans = _
		"<Win32_LocalTime Server='"+ env("%COMPUTERNAME%") +"' TypeName='SWbemObjectEx' Service='WMI'"+vbCRLF+_
		"  Day='"& Day( n ) &"'"+vbCRLF+_
		"  DayOfWeek='"& Weekday( n ) - 1 &"'"+vbCRLF+_
		"  Hour='"& Hour( n ) &"'"+vbCRLF+_
		"  Milliseconds=''"+vbCRLF+_
		"  Minute='"& Minute( n ) &"'"+vbCRLF+_
		"  Month='"& Month( n ) &"'"+vbCRLF+_
		"  Quarter='"& Int((Month( n )-1)/3)+1 &"'"+vbCRLF+_
		"  Second='"& Second( n ) &"'"+vbCRLF+_
		"  WeekInMonth='"& Int( ( Day( n ) - Weekday( n ) + 13 ) / 7 ) &"'"+vbCRLF+_
		"  Year='"& Year( n ) &"'"+vbCRLF+_
		"/>"
	str = GetEchoStr( get_WMI( Empty, "Win32_LocalTime" ) )
	echo  str
	echo  ans
	Assert  str = ans
Sleep  2000
End Sub


 
'********************************************************************************
'  <<< [WaitForJustSecond] >>> 
'********************************************************************************
Sub  WaitForJustSecond()
	Dim  t

	t = Now()
	While t = Now() : WEnd
End Sub


 
'********************************************************************************
'  <<< [T_ChangeNumToCommandOrNot] >>> 
'********************************************************************************
Sub  T_ChangeNumToCommandOrNot( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_out.txt" ).Enable()
	RunProg  "cscript  //nologo  T_Value.vbs  T_ChangeNumToCommandOrNot_Sub"+ _
		"  """"  99  77  7  Last",  "_out.txt"
	AssertFC  "_out.txt", "T_ChangeNumToCommandOrNot_Answer.txt"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ChangeNumToCommandOrNot_Sub] >>> 
'********************************************************************************
Sub  T_ChangeNumToCommandOrNot_Sub( Opt, AppKey )
	Set commands = Dict( Array( "7", "Command7", "8", "Command8", "99", "Exit" ) )
	name = "NumName"

	Assert  ChangeNumToCommandOrNot( "1",     commands,  name,  False ) = "1"
	Assert  ChangeNumToCommandOrNot( "7",     commands,  name,  False ) = "Command7"
	Assert  ChangeNumToCommandOrNot( "99",    commands,  name,  True  ) = "99"
	Assert  ChangeNumToCommandOrNot( "99",    commands,  name,  True  ) = "Exit"
	Assert  ChangeNumToCommandOrNot( "Exit",  commands,  name,  True  ) = "Exit"
	Assert  ChangeNumToCommandOrNot( "7",     commands,  "N",   True  ) = "Command7"
	Assert  Input("Check>") = "Last"
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

 
