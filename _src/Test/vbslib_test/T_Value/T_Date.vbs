Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_Date", _
			"2","T_EMailDate", _
			"3","T_GetMonthNumberFromString", _
			"4","T_Bench", _
			"5","T_ProgressTimer" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Date] >>> 
'********************************************************************************
Sub  T_Date( Opt, AppKey )
	include  WScript.ScriptName

	Dim  t

	Assert  CStr( DateAddStr( CDate("3:01"), "+12:02" ) )       = "15:03:00"
	Assert  CStr( DateAddStr( CDate("3:01"), "+12:02:02" ) )    = "15:03:02"
	Assert  CStr( DateAddStr( CDate("3:01"), "-0:01" ) )         = "3:00:00"
	Assert  CStr( DateAddStr( CDate("3:01"), "-00:00:02" ) )     = "3:00:58"
	Assert  CStr( DateAddStr( CDate("3:00"), "+2:02-1:02:01" ) ) = "3:59:59"
	Assert  CStr( DateAddStr( CDate("9:09"), "-1:01-2:02" ) )    = "6:06:00"
	Assert  CStr( DateAddStr( CDate("3:00"), "-1:01+2:02" ) )    = "4:01:00"
	Assert  CStr( DateAddStr( CDate("3:00"), "-4:00" ) ) = "1899/12/29 23:00:00"
	Assert  CStr( DateAddStr( CDate("3:02"), "- 1hour 2min" ) )  = "2:00:00"
	Assert  CStr( DateAddStr( CDate("3:01"), "Z" ) )             = "3:01:00"  '// Z = UTC of W3C-DTF
	Assert  CStr( DateAddStr( CDate("2001-01-01"), "+1/10" ) ) = "2001/02/11"
			'// compare by string because compare by date(=double float) may have little error

	Assert  TimeZoneDesignator( 540 ) = "+09:00"
	Assert  TimeZoneDesignator(  61 ) = "+01:01"
	Assert  TimeZoneDesignator( -61 ) = "-01:01"
	Assert  TimeZoneDesignator( 601 ) = "+10:01"
	Assert  TimeZoneDesignator(-601 ) = "-10:01"
	Assert  TimeZoneDesignator(   0 ) = "Z"
	Assert  TimeZoneDesignator( Empty ) = TimeZoneDesignator( get_WMI( Empty, "Win32_TimeZone" ).Bias )
	Assert  TimeZoneDesignator( Empty ) = TimeZoneDesignator( get_WMI( Empty, "Win32_TimeZone" ).Bias )  '// test of time zone cache

	Assert  MinusTZD( 540 ) = "-09:00"
	Assert  MinusTZD(   0 ) = "Z"
	Assert  MinusTZD(-540 ) = "+09:00"
	Assert  MinusTZD( "+09:00" ) = "-09:00"
	Assert  MinusTZD( "-09:00" ) = "+09:00"
	Assert  MinusTZD( "Z" )      = "Z"

'  RegistClassToEchoStr  "SWbemObjectEx", GetRef( "SWbemObjectEx_xml_sub" )
'  RegistClassToEchoStr  "Dictionary", GetRef( "Dictionary_xml_sub" )

	Assert IsObject( get_WMI( Empty, "StdRegProv" ) )
	Assert IsObject( get_WMI( Empty, "Win32_TimeZone" ) )

	Dim  tzd : tzd = TimeZoneDesignator( Empty )

	'//=== W3CDTF from Date to string
	Assert  W3CDTF( CDate( "2001/01/01 1:01:01" ) ) = "2001-01-01T01:01:01" + tzd
	Assert  W3CDTF( CDate( "0100/01/01 1:01:01" ) ) = "0100-01-01T01:01:01" + tzd
	Assert  W3CDTF( CDate( "9999/12/30 1:01:01" ) ) = "9999-12-30T01:01:01" + tzd

	'//=== W3CDTF from string to Date
	Assert  W3CDTF( "2002" )       = CDate( "2002/01/01" )
	Assert  W3CDTF( "2002-02" )    = CDate( "2002/02/01" )
	Assert  W3CDTF( "2002-02-02" ) = CDate( "2002/02/02" )
	Assert  W3CDTF( "9999-12-31" ) = CDate( "9999/12/31" )
	Assert  W3CDTF( "2002-02-02T02:02"       + tzd ) = CDate( "2002/02/02 2:02" )
	Assert  W3CDTF( "2002-02-02T02:02:02"    + tzd ) = CDate( "2002/02/02 2:02:02" )
	Assert  W3CDTF( "2002-02-02T02:02:02.99" + tzd ) = CDate( "2002/02/02 2:02:02" )
	Assert  W3CDTF( "9999-12-30T23:59:59.99" + tzd ) = CDate( "9999/12/30 23:59:59" )
	Assert  W3CDTF( "  2002-02-02T02:02"+ tzd +"  ") = CDate( "2002/02/02 2:02:00" )
	Assert  W3CDTF( "  2002-02-02 02:02"+ tzd +"  ") = CDate( "2002/02/02 2:02:00" )

	'//=== W3CDTF from other time zone to local time zone
	Assert  W3CDTF( "2002-02-02T02:02:02Z" )      = DateAddStr( CDate( "2002/02/02 2:02:02" ), tzd )
	Assert  W3CDTF( "2002-02-02T02:02:02+09:00" ) = DateAddStr( CDate( "2002/02/02 2:02:02" ), tzd + "-9:00" )
	Assert  W3CDTF( "2002-02-02T02:02:02-10:30" ) = DateAddStr( CDate( "2002/02/02 2:02:02" ), tzd + "+10:30" )

	'//=== ConvertTimeZone
	Dim  local   : local   = CDate( "2002/02/02 2:02:02" )
	Dim  utc     : utc     = DateAddStr( local, MinusTZD( Empty ) )
	Dim  utc_dtf : utc_dtf = Left( W3CDTF( utc ), 19 ) + "Z"
	Assert  W3CDTF( utc_dtf ) = local
	Assert  ConvertTimeZone( "2002-02-02T11:02:02+09:00", "+9:00", "Z" ) = "2002-02-02T02:02:02Z"
	Assert  ConvertTimeZone( "2002-02-02T11:02:02+09:00","+09:00", "Z" ) = "2002-02-02T02:02:02Z"
	Assert  ConvertTimeZone( "2002-02-02T11:02:02+09:00", Empty,   "Z" ) = "2002-02-02T02:02:02Z"
	Assert  ConvertTimeZone( "2002-02-02T02:02:02Z",     "Z", "+09:00" ) = "2002-02-02T11:02:02+09:00"
	Assert  ConvertTimeZone( "2002-02-02T02:02:02Z",   Empty,  "+9:00" ) = "2002-02-02T11:02:02+09:00"
	Assert  ConvertTimeZone( "2002-02-02T02:02:02" + tzd, Empty, Empty ) = W3CDTF( local )
	Assert  ConvertTimeZone( local, tzd,   "Z" ) = utc
	Assert  ConvertTimeZone( local, Empty, "Z" ) = utc
	Assert  ConvertTimeZone( utc, "Z", tzd   ) = local
	Assert  ConvertTimeZone( utc, "Z", Empty ) = local

	local   = CDate( "2:02:02" )
	utc     = DateAddStr( local, MinusTZD( Empty ) )
	Assert  ConvertTimeZone( local, Empty, "Z" ) = utc
	Assert  ConvertTimeZone( utc, "Z", Empty ) = local

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_EMailDate] >>> 
'********************************************************************************
Sub  T_EMailDate( Opt, AppKey )

	a_date = CDateFromEMailDate( "Fri, 25 Oct 2013 22:07:30 +0900" )
	Assert  W3CDTF( a_date ) = "2013-10-25T22:07:30+09:00"

	a_date = CDateFromEMailDate( "Date: Fri, 25 Oct 2013 22:07:30 +0900" )
	Assert  W3CDTF( a_date ) = "2013-10-25T22:07:30+09:00"

	a_date = CDateFromEMailDate( "Date: 25 Oct 2013 22:07:30 +0900" )
	Assert  W3CDTF( a_date ) = "2013-10-25T22:07:30+09:00"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_GetMonthNumberFromString] >>> 
'********************************************************************************
Sub  T_GetMonthNumberFromString( Opt, AppKey )
	Assert  GetMonthNumberFromString( "Jan" ) = 1
	Assert  GetMonthNumberFromString( "Feb" ) = 2
	Assert  GetMonthNumberFromString( "Mar" ) = 3
	Assert  GetMonthNumberFromString( "Apr" ) = 4
	Assert  GetMonthNumberFromString( "May" ) = 5
	Assert  GetMonthNumberFromString( "Jun" ) = 6
	Assert  GetMonthNumberFromString( "Jul" ) = 7
	Assert  GetMonthNumberFromString( "Aug" ) = 8
	Assert  GetMonthNumberFromString( "Sep" ) = 9
	Assert  GetMonthNumberFromString( "Oct" ) = 10
	Assert  GetMonthNumberFromString( "Nov" ) = 11
	Assert  GetMonthNumberFromString( "Dec" ) = 12

	For Each  str  In Array( "De", "ec", "x" )
		If TryStart(e) Then  On Error Resume Next
			Assert  GetMonthNumberFromString( "De" ) = 12
		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		Assert  e2.num <> 0
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Bench] >>> 
'********************************************************************************
Sub  T_Bench( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "out.txt" ).Enable()
	RunProg  "cscript //nologo T_Date.vbs  T_BenchSub", "out.txt"
	AssertFC  "out.txt", "T_Bench_ans.txt"
	del  "out.txt"
	Pass
End Sub

Sub  T_BenchSub( Opt, AppKey )
	Dim  i
	BenchStart
		Sleep  200
	Bench  1
		Sleep  200
	Bench  2
		Sleep  200
	Bench  0
		Sleep  200
	For i=1 To 10
		Bench  2
			Sleep 1000
		Bench  0
	Next
		Sleep  200
	BenchEnd
End Sub


 
'********************************************************************************
'  <<< [T_ProgressTimer] >>> 
'********************************************************************************
Sub  T_ProgressTimer( Opt, AppKey )
	Set pr_timer = g_VBS_Lib.ProgressTimer
	Assert  TypeName( pr_timer ) = "g_VBS_Lib_ProgressTimerClass"

	'// Test
	Assert  pr_timer.GetShouldShow()
	Assert  not  pr_timer.GetShouldShow()
	Sleep  pr_timer.Interval_msec
	Assert  pr_timer.GetShouldShow()
	Assert  not  pr_timer.GetShouldShow()


	'// Example
	pr_timer.Start  Empty, 12, 100, ""
	Do Until  pr_timer.Count >= pr_timer.MaxCount
		Sleep  50  '// Do Anything

		pr_timer.Plus  +1, Empty
	Loop
	pr_timer.End_  ""

	Sleep  1000


	'// Test
	precision = 66
	pr_timer.Start  Empty, 2000, 500, "Start"
	text = Empty
	Do
		If pr_timer.Count + precision > pr_timer.MaxCount Then _
			precision = pr_timer.MaxCount - pr_timer.Count
		pr_timer.Plus  precision, text
		If pr_timer.Count >= pr_timer.MaxCount Then _
			Exit Do

		Sleep  precision

		text = "Testing ... "
		pr_timer.ShowFormat = " ${Percent}% ${Count}/${MaxCount} ${Text}"
	Loop
	pr_timer.End_  "Done."

	Sleep  1000


	'// Test
	pr_timer.Start  Empty, 2000, 500, Empty
	pr_timer.End_  Empty


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

 
