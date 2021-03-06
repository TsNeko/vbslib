'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************

Dim  g_SrcPath
Dim  g_TestPrompt_Path
     g_TestPrompt_Path = g_SrcPath


 
'********************************************************************************
'  <<< Global Variables >>> 
'********************************************************************************
Const  Op__NoOperation = 0
Const  Op__SelectTest = 1
Const  Op__EachTest = 2
Const  Op__EachTestR = 3
Const  Op__EachDebug = 4
Const  Op__AllTest = 5
Const  Op__Do1 = 6
Const  Op__Debug = 8
Const  Op__Exit = 9
Const  Op__OpenFail = 88
Const  Op__NextFail = 89

 
'********************************************************************************
'  <<< [RunTestPrompt] >>> 
'********************************************************************************
Sub  RunTestPrompt( Opt )
	If TypeName( Opt ) = "RunTestPromptConfigClass" Then
		Set config = Opt
	Else
		Set config = new RunTestPromptConfigClass
	End If


	If TypeName( Opt ) = "Writables" Then
		Set config.Writable = Opt
	ElseIf VarType( Opt ) = vbString Then
		config.TestTargetVBS_Path = Opt
	End If


	If not IsEmpty( config.Writable ) Then _
		Set w_ = config.Writable.Enable
	If not IsEmpty( config.ExpectedPassConut ) Then _
		g_Test.ExpectedPassConut = config.ExpectedPassConut


	g_AppKey.SetWritableMode  F_ErrIfWarn

	Set a_prompt = new TestPrompt : ErrCheck


	'//=== Select test from command line parameter
	If WScript.Arguments.Unnamed.Count >= 1 Then _
		a_prompt.SetOpenSymbolOrPath  WScript.Arguments.Unnamed(0)


	'//=== Setup unit test mode
	If not IsEmpty( config.TestTargetVBS_Path ) Then
		Set o = a_prompt.m_Tests
			o.m_bDisableAddTestScript = True
			Setting_buildTestPrompt  a_prompt
			o.m_bDisableAddTestScript = False
			If g_fs.FolderExists( config.TestTargetVBS_Path ) Then
				target_path = config.TestTargetVBS_Path +"\"+ WScript.ScriptName
			Else
				target_path = config.TestTargetVBS_Path
			End If
			target_path = g_fs.GetAbsolutePathName( target_path )
			o.AddTestScript  g_fs.GetBaseName( g_fs.GetParentFolderName( _
				target_path ) ), target_path
			o.SetCurrentSymbol  WScript.ScriptFullName
			o.m_bAutoDiff_ = True
		o = Empty
		g_Test.m_DefLogFName = "Test_log.txt"
	Else
		Setting_buildTestPrompt  a_prompt
	End If

	a_prompt.m_Tests.LoadTestSet  "TestCommon_Data.xml", ".", "TestSymbols"


	'//=== Set log file from command line parameter
	If not IsEmpty( WScript.Arguments.Named.Item("log") ) Then _
		g_Test.m_DefLogFName = WScript.Arguments.Named.Item("log")


	'//=== Set Test Symbol
	If Not IsEmpty( a_prompt.m_OpenSymbolOrPath ) Then _
		a_prompt.m_Tests.SetCurrentSymbol  a_prompt.m_OpenSymbolOrPath

	'//=== Start prompt
	g_CUI.SetAutoKeysFromMainArg
	a_prompt.DoPrompt
End Sub


 
'*-------------------------------------------------------------------------*
'* <<<< [RunTestPromptConfigClass] >>>> */ 
'*-------------------------------------------------------------------------*

Class  RunTestPromptConfigClass
	Public  Writable  '// as Writables
	Public  ExpectedPassConut  '// as integer
	Public  TestTargetVBS_Path  '// as string
End Class


 
'*-------------------------------------------------------------------------*
'* <<<< [TestPrompt] Class >>>> */ 
'*-------------------------------------------------------------------------*

Class  TestPrompt

	Public  m_Tests    ' as Tests
	Public  m_OpenSymbolOrPath ' param1 of TestPrompt.vbs
	Public  TestScriptFileName

	Public  m_Menu()     ' as MenuItem

	' const integer for other vbs file scope
	Public  Op_NoOperation
	Public  Op_SelectTest
	Public  Op_EachTest
	Public  Op_EachTestR
	Public  Op_EachDebug
	Public  Op_AllTest
	Public  Op_Do1
	Public  Op_Debug
	Public  Op_OpenFail
	Public  Op_NextFail
	Public  Op_Exit


 
'********************************************************************************
'  <<< [TestPrompt::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize
	Dim  i

	Set m_Tests = new Tests : ErrCheck
	m_Tests.bTargetDebug = Not IsEmpty( WScript.Arguments.Named("target_debug") )

	Set m_Tests.Prompt = Me
	Me.TestScriptFileName = WScript.ScriptName
	ReDim  m_Menu(10)
	For i=0 To 10
		Set m_Menu(i) = new MenuItem : ErrCheck
	Next

	Op_NoOperation = Op__NoOperation
	Op_SelectTest = Op__SelectTest
	Op_EachTest = Op__EachTest
	Op_EachTestR = Op__EachTestR
	Op_EachDebug = Op__EachDebug
	Op_AllTest = Op__AllTest
	Op_Do1 = Op__Do1
	Op_Debug = Op__Debug
	Op_OpenFail = Op__OpenFail
	Op_NextFail = Op__NextFail
	Op_Exit = Op__Exit
End Sub


 
'********************************************************************************
'  <<< [TestPrompt::ReDimMenu] >>> 
'********************************************************************************
Public Sub  ReDimMenu( UBound_ )
	For i=0 To UBound( m_Menu )
		m_Menu(i) = Empty
	Next

	ReDim  m_Menu( UBound_ )

	For i=0 To UBound_
		Set m_Menu(i) = new MenuItem : ErrCheck
	Next

End Sub


 
'********************************************************************************
'  <<< [TestPrompt::SetOpenSymbolOrPath] >>> 
'********************************************************************************
Public Sub  SetOpenSymbolOrPath( Symbol_or_Path )
	m_OpenSymbolOrPath = Symbol_or_Path
	If g_fs.FileExists( Symbol_or_Path ) Then
		m_Tests.BaseFolderPath = g_fs.GetParentFolderName( g_fs.GetAbsolutePathName(Symbol_or_Path) )
	ElseIf Symbol_or_Path <> "" Then
		m_Tests.BaseFolderPath = g_sh.CurrentDirectory
	End If
End Sub

 
'********************************************************************************
'  <<< [TestPrompt::DoPrompt] >>> 
'********************************************************************************
Public Sub  DoPrompt
	Dim  num, i, num_auto, case_

	case_ = WScript.Arguments.Named.Item("Case")
	If not IsEmpty( case_ ) Then
		If m_Tests.SetCurrentSymbol( case_ ) <> 0 Then _
			Err.Raise  1,, "<ERROR msg=""テストケースが見つかりません"" symbol="""+ case_ +"""/>"
	End If

	WScript.Echo "--------------------------------------------------------"
	Do
		WScript.Echo  "Test Prompt [" & m_Tests.CurrentSymbol & "]"
		If Not IsEmpty( m_Tests.CurrentTest ) Then  WScript.Echo "   test vbs = " & _
			GetStepPath( m_Tests.CurrentTest.ScriptPath, m_Tests.BaseFolderPath )
		WScript.Echo "   base folder = " & m_Tests.BaseFolderPath
		For num = 0 To UBound( m_Menu )
			If Not IsEmpty( m_Menu(num) ) And _
				 ( Not IsEmpty( m_Menu(num).m_Caption ) Or m_Menu(num).m_OpType = Op_SelectTest Or m_Menu(num).m_OpType = Op_Debug ) Then
				Select Case  m_Menu(num).m_OpType
					Case Op_SelectTest  WScript.Echo m_Menu(num).m_Caption & " (current test = " & m_Tests.CurrentSymbol & ")"
					Case Op_Debug       WScript.Echo m_Menu(num).m_Caption & " (debug script=" & g_is_debug & ", target=" & m_Tests.bTargetDebug & ")"
					Case Else           WScript.Echo m_Menu(num).m_Caption
				End Select
			End If
		Next

		num_auto = Empty
		If ArgumentExist( "All" )   Then  num_auto = "2"
		If ArgumentExist( "Build" ) Then  num_auto = "3"
		If ArgumentExist( "Setup" ) Then  num_auto = "4"
		If ArgumentExist( "Start" ) Then  num_auto = "5"
		If ArgumentExist( "Check" ) Then  num_auto = "6"
		If ArgumentExist( "Clean" ) Then  num_auto = "7"
		If IsEmpty( num_auto ) Then
			num = g_CUI.input( "Select number>" )
		Else
			num = num_auto
		End If
		num = CInt2( num )

		For i = 0 To UBound( m_Menu )
		 If not IsEmpty( m_Menu(i).m_Number ) Then
			 If num = m_Menu(i).m_Number Then  num = i : Exit For
		 End IF
		Next
		WScript.Echo "--------------------------------------------------------"

		Select Case  m_Menu(num).m_OpType
			Case Op_SelectTest  Me.SelectTest
			Case Op_EachTest    Me.DoTest  m_Menu(num).m_OpParam, False
			Case Op_EachTestR   Me.DoTest  m_Menu(num).m_OpParam, True
			Case Op_EachDebug   Me.DoTest  m_Menu(num).m_OpParam, True
			Case Op_AllTest
				m_Tests.DoAllTest
				m_Tests.SaveTestResultCSV  Empty
				'// Me.Sound  Me.c.AllTestIsDone
			Case Op_Debug       Me.ChgDebugMode
			Case Op_OpenFail    Me.OpenFail
			Case Op_NextFail    Me.NextFail
			Case Op_Exit        Exit Do
		End Select
		WScript.Echo "--------------------------------------------------------"

		If num_auto Then
			If g_Test.m_nFail > 0 Then  Err.Raise  E_TestFail,, "失敗したテストがあります"
			Exit Do
		End If
	Loop
End Sub


 
'********************************************************************************
'  <<< [TestPrompt::DoTest] >>> 
'********************************************************************************
Public Sub  DoTest( param, bReverse )
	m_Tests.DoTest  param, bReverse
End Sub

 
'********************************************************************************
'  <<< [TestPrompt::SelectTest] >>> 
'********************************************************************************
Public Sub  SelectTest
	Dim  key, keys, sym, i, i_sym, s

	Do
		'//=== Display test symbol list
		WScript.Echo "Test symbol list:"
		keys = m_Tests.Sets.Keys()
		If m_Tests.EnabledTestSet.Count = 0 Then
			s = " (default)"
		Else
			s = " (tests marked '+' by TestCommon_Data.xml#/TestCases/@TestSymbols)"
		End If
		WScript.Echo "  0) ALL"+ s
		i_sym = 1
		For Each key in keys
			If m_Tests.EnabledTestSet.Exists( key ) Then
				s = "+ "
			Else
				s = "  "
			End If
			WScript.Echo  s & i_sym & ") " & key
			i_sym = i_sym + 1
		Next

		'//=== Input test symbol or number
		sym = g_CUI.input( "Input test number or symbol or ""ALL"" or ""order"">" )
		If sym = "" Then sym = m_Tests.CurrentSymbol

		'//=== If sym is number, set sym to test symbol
		i_sym = CInt2( sym )
		If i_sym > 0 Then
			i = 1
			For Each key in keys
				If i_sym = i Then  sym = key : Exit For
				i = i + 1
			Next
		End If
		If sym = "0" Then  sym = "ALL"


		'//=== Echo calling order
		If sym = "order" Then
			m_Tests.GetCallingOrder  unit_tests  '//[out] unit_tests as array of UnitTest
			echo  ""
			echo  "Calling order:"
			echo  "Test Symbol, Priority"
			echo  "--------------------------------------------------"
			For Each  unit_test  In unit_tests
				echo  unit_test.Symbol +", "& unit_test.Priority
			Next
			Pause
			echo  ""

		'//=== Set test symbol and display test properties
		ElseIf m_Tests.SetCurrentSymbol( sym ) = 0 Then
			If sym <> "ALL" and sym <> "ALL_R" Then
				echo m_Tests.Sets.Item( sym )
			End If
			Exit Do
		End If
	Loop
End Sub


 
'********************************************************************************
'  <<< [TestPrompt::ChgDebugMode] >>> 
'********************************************************************************
Public Sub  ChgDebugMode()
	Dim  sym

	Do
		'//=== Display test symbol list
		WScript.Echo "1) Reload Test Script"
		If g_Test.m_IsErrBreakMode Then
			WScript.Echo "4) エラー・ブレークを無効にする（現在=有効）"
		Else
			WScript.Echo "4) エラー・ブレークを有効にする（現在=無効）"
		End If
		If m_Tests.m_bAutoDiff Then
			WScript.Echo "5) AutoDiff (current=on)"
		Else
			WScript.Echo "5) AutoDiff (current=off)"
		End If


		'//=== Input test symbol or number
		sym = g_CUI.input( "Input test number>" )
		sym = CInt2( sym )
		If sym = 0 Then Exit Do
		If sym = 1 Then  ChgTestScriptDebugMode g_debug : Exit Do
'//    If sym = 2 Then  ChgTestScriptDebugMode not g_debug : Exit Do
'//    If sym = 3 Then  m_Tests.bTargetDebug = not m_Tests.bTargetDebug : Exit Do
		If sym = 4 Then  g_Test.m_IsErrBreakMode = not g_Test.m_IsErrBreakMode : Exit Do
		If sym = 5 Then  m_Tests.m_bAutoDiff = not m_Tests.m_bAutoDiff : Exit Do
	Loop
End Sub


Public Sub  ChgTestScriptDebugMode( debug )
	Dim  param
	Dim  target_debug_opt

	If m_Tests.CurrentSymbol = "ALL" Then param = "ALL" _
	Else  param = m_Tests.CurrentTest.ScriptPath

	If m_Tests.bTargetDebug Then  target_debug_opt = " /target_debug:1" _
	Else                          target_debug_opt = ""

	If debug Then
		g_sh.Run "cscript //x //nologo """+WScript.ScriptFullName+""" """+param+""" /g_debug:1"+target_debug_opt
	Else
		g_sh.Run "cscript //nologo """+WScript.ScriptFullName+""" """+param+""""+target_debug_opt
	End If
	Stop:WScript.Quit 10
End Sub

 
'********************************************************************************
'  <<< [TestPrompt::OpenFail] >>> 
'********************************************************************************
Public Sub  OpenFail()
	Dim en,ed

	ErrCheck : On Error Resume Next
		m_Tests.OpenFailFolder
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 Then  echo  GetErrStr( en, ed )
End Sub

 
'********************************************************************************
'  <<< [TestPrompt::NextFail] >>> 
'********************************************************************************
Public Sub  NextFail()
	Dim en,ed

	ErrCheck : On Error Resume Next
		m_Tests.NextFail
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 Then  echo  GetErrStr( en, ed )
End Sub

 
End Class 
 
'*-------------------------------------------------------------------------*
'* ◆<<<< [MenuItem] Class >>>> */ 
'*-------------------------------------------------------------------------*

Class  MenuItem

	Public  m_Caption
	Public  m_Number
	Public  m_OpType  ' as integer  Op_SelectTest, Op_EachTest, Op_Do1
	Public  m_OpParam

	Private  Sub  Class_Initialize
		m_Caption = Empty : m_OpType = Op__NoOperation
	End Sub

End Class



 
