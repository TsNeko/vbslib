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
Dim  g_TestScript_Path
     g_TestScript_Path = g_SrcPath


' グローバル変数
Dim  g_Test, g_echo_on, g_Err2, g_bSkipped
Dim  g_ReadTestCaseParams  '// as Dictionary( XmlPath ).Dictionary( TestCaseID ) = Condition

Function  InitializeModule
	g_echo_on = True
	Set  g_Test = new TestScript : ErrCheck
	Set  g_ReadTestCaseParams = CreateObject( "Scripting.Dictionary" )
End Function
Dim  g_InitializeModule
Set  g_InitializeModule = GetRef( "InitializeModule" )

Dim E_TestPass : E_TestPass = 21
Dim E_TestSkip : E_TestSkip = 22
Dim E_TestFail : E_TestFail = 23


 
'********************************************************************************
'  <<< [call_vbs_t] >>> 
'   - path, func as string, param as variant
'********************************************************************************
Function  call_vbs_t( ByVal path, ByVal func, param )
	Dim oldDir, f, funcX, in_interpret, e, en, ed, es
	Dim  fin : Set fin = new FinObj : fin.SetFunc "call_vbs_t_Finally"
	Dim  ds_:Set ds_= New CurDirStack

	in_interpret = False
	oldDir = g_sh.CurrentDirectory

	path = g_sh.ExpandEnvironmentStrings( path )
	path = g_fs.GetAbsolutePathName( path )

	'-----------------------------------------
	' Interpret

	g_SrcPath = path

	If IsEmpty( g_Err2 ) Then
		On Error Resume Next
	Else
		If TryStart(e) Then  On Error Resume Next
	End If

		g_sh.CurrentDirectory = g_fs.GetParentFolderName( path )
		If Err=0 Then  Set f = g_fs.OpenTextFile( g_fs.GetFileName( path ),,,-2 )
		If Err=0 Then  in_interpret = True : ExecuteGlobal f.ReadAll()
		If Err=&h411 Then  in_interpret = False : Err.Clear  ' Ignore symbol override error
		If Err=0 Then  in_interpret = False
		If Err=0 Then  Set funcX = GetRef( func )

	If IsEmpty( g_Err2 ) Then
		en = Err.Number : ed = Err.Description : es = Err.Source : On Error GoTo 0
	Else
		If TryEnd Then  On Error GoTo 0
		en = g_Err2.num : ed = g_Err2.desc
	End If

	If en <> 0 Then
		If in_interpret Then
			ed = ed + " 文法エラーでは、VBSファイルをダブルクリックすると問題がある場所が分かります。"
		End If
		If en = &h35 Then  ed = "Not found file '" + path
		If en = 5 Then  ed = "Not found func name '" + func + "' in " + path
		Err.Raise  en,, ed
	End If
	f.Close


	'-----------------------------------------
	' Call
	If en = 0 Then
		call_vbs_t = funcX( param )
	End If
End Function : Sub  call_vbs_t_Finally( Vars )
	g_SrcPath = Empty
End Sub
 
'********************************************************************************
'  <<< [call_vbs_d] >>> 
'********************************************************************************
' Function  call_vbs_d( ByVal path, ByVal func, param )
'   Dim oldDir, f, funcX, in_call, in_interpret, en
'
'   oldDir = g_sh.CurrentDirectory
'
'   path = g_sh.ExpandEnvironmentStrings( path )
'   path = g_fs.GetAbsolutePathName( path )
'   g_SrcPath = path
'
'   g_sh.CurrentDirectory = g_fs.GetParentFolderName( path )
'
'   Set f = g_fs.OpenTextFile( g_fs.GetFileName( path ),,,-2 )
'   ExecuteGlobal f.ReadAll()
'   f.Close
'   Set funcX = GetRef( func )  ' If error, Not found func symbol
'   call_vbs_d = funcX( param )
'   g_sh.CurrentDirectory = oldDir
'   g_SrcPath = Empty
' End Function



 
'********************************************************************************
'  <<< [get_TestScriptConsts] >>> 
'********************************************************************************
Dim  g_TestScriptConsts

Function    get_TestScriptConsts()
	If IsEmpty( g_TestScriptConsts ) Then _
		Set g_TestScriptConsts = new TestScriptConsts
	Set get_TestScriptConsts =   g_TestScriptConsts
End Function


Class  TestScriptConsts
	Public  TestBuildFunc, TestSetupFunc, TestStartFunc, TestCheckFunc, TestCleanFunc
	Public  StepOfLastTestFunc
	Public  TestFuncStrs, TestResultStrs_imp
	Public  Skipped

	Private Sub  Class_Initialize()
		TestBuildFunc = 1 : TestSetupFunc = 2 : TestStartFunc = 3 : TestCheckFunc = 4 : TestCleanFunc = 5
		StepOfLastTestFunc = 5
		TestFuncStrs = Array( "", "Test_build", "Test_setup", "Test_start", "Test_check", "Test_clean" )
		TestResultStrs_imp = Array( "Pass", "Skip", "Fail", "Skip" )  '// Err.Number - E_TestPass
		Skipped = 24
	End Sub

	Function  TestResultStrs( i )
		If i >= E_TestPass  and  i <= Skipped Then
			TestResultStrs = TestResultStrs_imp( i - E_TestPass )
		Else
			TestResultStrs = "NotYet"
		End If
	End Function

	Function  TestResultIDs( s )
		TestResultIDs = SearchInSimpleArray( s, TestResultStrs_imp, E_TestPass, Empty )
	End Function

	Function  TestFuncIDs( s )
		TestFuncIDs = SearchInSimpleArray( s, TestFuncStrs, 0, Empty )
	End Function
End Class
 
'-------------------------------------------------------------------------
' ### <<<< [TestScript] Class >>>> 
'-------------------------------------------------------------------------

Class  TestScript
	Public  c           '// as TestScriptConst
	Public  TestResult  '// as integer. E_TestPass, E_TestFail, E_TestSkip, Empty
	Public  StepOfFunc  '// as integer. Empty, c.TestBuildFunc, c.TestSetupFunc, ...
	Public  ExpectedPassConut  '// as integer

	Public  m_nPass  ' as integer
	Public  m_nSkip  ' as integer
	Public  m_nFail  ' as integer
	Public  m_Log    ' as Text File
	Public  m_DefLogFName  ' as string
	Public  m_MemLog  ' as string. Empty=disabled, (""or string)=enabled
	Public  m_Path    ' as string
	Public  m_ManualTests() ' as string
	Public  m_ManualTestsPath() ' as string
	Public  m_IsErrBreakMode  ' as boolean
'//  Public  m_Pass   ' as boolean
 
'********************************************************************************
'  <<< [TestScript::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize()
	Set Me.c = get_TestScriptConsts()
	Me.m_DefLogFName = "Test_logs.txt"
	Me.m_IsErrBreakMode = False
	ReDim  m_ManualTests(-1)      '// Me.m_ManualTests
	ReDim  m_ManualTestsPath(-1)  '// Me.m_ManualTestsPath
End Sub


 
'********************************************************************************
'  <<< [TestScript::Class_Terminate] >>> 
'********************************************************************************
Private Sub  Class_Terminate
	If Not IsEmpty( m_Log ) Then  Finish
End Sub


 
'********************************************************************************
'  <<< [TestScript::Start] >>> 
'********************************************************************************
Public Sub  Start
	Dim  sub_test ' Boolean

	Set m_Log = g_fs.CreateTextFile( m_DefLogFName, True, (LCase( g_FileOptions.CharSet ) = "unicode") )
	m_MemLog = Empty
	ReDim  m_ManualTests(-1)      '// Me.m_ManualTests
	ReDim  m_ManualTestsPath(-1)  '// Me.m_ManualTestsPath

	sub_test = False
	If WScript.Arguments.Count >= 1 Then
		If WScript.Arguments(0) = "-sub_test" Then sub_test = True
	End If

	If Not sub_test Then  echo  "Test Start : " & g_fs.GetFileName( Wscript.ScriptFullName )

	Me.m_nPass = 0
	Me.m_nSkip = 0
	Me.m_nFail = 0
End Sub


 
'********************************************************************************
'  <<< [TestScript::Do_] >>> 
'********************************************************************************
Public Sub  Do_( ByVal vbs_path, ByVal func, ByVal param )
	Dim  e,en,ed,es, def_log_fname, b_echo_err_func, b_echo_err_file, debug_code
	Dim  err_id

	m_Path = vbs_path


	'//=== Call Me.Start
	If IsEmpty( m_Log ) And func <> "Test_current" Then
		def_log_fname = m_DefLogFName
		m_DefLogFName = g_fs.GetParentFolderName( vbs_path ) + "\" + def_log_fname
		Me.Start
	End If


	'//=== Echo the Test title
	If func <> "Test_current" Then
		echo "=========================================================="
		If g_fs.GetFileName( g_fs.GetParentFolderName( vbs_path ) ) = "" Then
			echo "((( [" & g_fs.GetFileName( vbs_path ) & "] - " & func & " )))"
		Else
			echo "((( [" & g_fs.GetFileName( g_fs.GetParentFolderName( vbs_path ) ) & "\" _
					 & g_fs.GetFileName( vbs_path ) & "] - " & func & " )))"
		End If
	End If


	'//=== Call the Test function
	If Me.m_IsErrBreakMode Then
	ElseIf IsEmpty( g_Err2 ) Then
		On Error Resume Next
	Else
		If TryStart(e) Then  On Error Resume Next
	End If

		call_vbs_t  vbs_path, func, param


	'//=== Get error information
	If Me.m_IsErrBreakMode Then
	ElseIf IsEmpty( g_Err2 ) Then
		en = Err.Number : ed = Err.Description : es = Err.Source : On Error GoTo 0
	Else
		If TryEnd Then  On Error GoTo 0
		en = g_Err2.num : ed = g_Err2.desc
		err_id = g_Err2.ErrID
		debug_code = g_Err2.GetDebugHintPart()
		g_Err2.Clear
	End If


	'//=== Echo the Test result
	If en = 0 Then
	 If func <> "Test_current" Then
		Me.TestResult = E_TestFail
		Me.m_nFail = Me.m_nFail + 1
		echo "[FAIL] テスト関数は Pass 関数を呼びませんでした。"
		b_echo_err_func = True
	 End If
	ElseIf en = E_TestPass Then
	 If func <> "Test_current" Then
		Me.TestResult = E_TestPass
		Me.m_nPass = Me.m_nPass + 1
		'// echo "Pass." is already done in Pass function
	 End If
	ElseIf en = E_TestSkip Then
		Me.TestResult = E_TestSkip
		Me.m_nSkip = Me.m_nSkip + 1
		echo ed
		b_echo_err_func = True
	Else
		Me.TestResult = E_TestFail

		If err_id = 0 Then  err_id = 1
		If IsEmpty( g_Err2 ) Then
			echo  WScript.ScriptName + g_ConnectDebugMsg + vbCRLF + String( 70, "-" ) + _
						vbCRLF + "g_debug = "& err_id
			echo  String( 70, "-" )
		Else
			echo  debug_code
		End If

		Me.m_nFail = Me.m_nFail + 1

		If en = E_TestFail Then
			echo "[FAIL] " & ed
		ElseIf en >= 0 and en <= &h7FFF Then
			echo "[FAIL] [ERROR](" & en & ") " & ed
		Else
			echo "[FAIL] [ERROR](" & Hex(en) & ") " & ed
		End If
		If en < 1000 or en >4096 Then
			b_echo_err_func = True
		Else
			b_echo_err_file = True
		End IF
	End If
	If b_echo_err_func Then
		echo " in """ & func & """ function in """ & vbs_path & """"
	ElseIf b_echo_err_file Then
		echo " in """ & vbs_path & """"
	End If


	'//=== Call Me.Finish
	If Not IsEmpty( def_log_fname ) Then
		Me.Finish
		m_DefLogFName = def_log_fname
	End If

	m_Path = Empty
End Sub


 
'********************************************************************************
'  <<< [TestScript::WriteLogLine] >>> 
'********************************************************************************
Public Sub  WriteLogLine( Message )
	If not IsEmpty( m_Log ) Then
		m_Log.WriteLine  Message
	End If
	If not IsEmpty( m_MemLog ) Then
		m_MemLog = m_MemLog + Message + vbCRLF
	End If
End Sub
 
'********************************************************************************
'  <<< [TestScript::AddManualTest] >>> 
'********************************************************************************
Public Sub  AddManualTest( TestSymbol )
	ReDim Preserve  m_ManualTests( UBound( Me.m_ManualTests ) + 1 )
	Me.m_ManualTests( UBound( Me.m_ManualTests ) ) = TestSymbol
	ReDim Preserve  m_ManualTestsPath( UBound( Me.m_ManualTestsPath ) + 1 )
	Me.m_ManualTestsPath( UBound( Me.m_ManualTestsPath ) ) = m_Path
End Sub


 
'********************************************************************************
'  <<< [TestScript::Raise] >>> 
'********************************************************************************
Public Sub  Raise( en, ed )
	Me.m_nFail = Me.m_nFail + 1
	If en >= 0 and en <= &h7FFF Then
		echo "[FAIL] [ERROR](" & en & ") " & ed
	Else
		echo "[FAIL] [ERROR](" & Hex(en) & ") " & ed
	End If
End Sub


 
'********************************************************************************
'  <<< [TestScript::Finish] >>> 
'********************************************************************************
Public Sub  Finish
	Dim  TestSymbol, sub_test ' Boolean
	Dim  i

	i=0
	For Each TestSymbol  In Me.m_ManualTests
		echo  "[ManualTest] " + TestSymbol + " in """ + Me.m_ManualTestsPath(i) + """"
		i=i+1
	Next

	m_MemLog = Empty

	sub_test = False
	If WScript.Arguments.Count >= 1 Then
		If WScript.Arguments(0) = "-sub_test" Then sub_test = True
	End If

	If sub_test Then
		If Me.m_nFail = 0 Then  Stop:WScript.Quit 0  Else  Stop:WScript.Quit 1
	Else
		echo "=========================================================="
		echo "Test Finish (Pass=" & Me.m_nPass & ", Manual=" & UBound(Me.m_ManualTests)+1 & _
				 ", Skip=" & Me.m_nSkip & ", Fail=" & Me.m_nFail & ")"
		If not IsEmpty( Me.ExpectedPassConut ) Then
			str = "ExpectedPassConut = "& Me.ExpectedPassConut
			If Me.m_nPass = Me.ExpectedPassConut  and  Me.m_nFail = 0 Then
				echo  str +" [OK]"
			Else
				echo  str +" [FAIL]"
			End If
		End If
		echo ""
	End If

	ReDim  m_ManualTests(-1)  '// Me.m_ManualTests
	m_Log = Empty
End Sub





 
End Class 
 
'-------------------------------------------------------------------------
' ### <<<< [Tests] Class >>>> 
'-------------------------------------------------------------------------
Class Tests

	Public   c       '// as TestScriptConst
	Private  m_AllTestSet      '// as Dictionary of UnitTest. key is UnitTest::Symbol
	Private  m_BaseFolderPath  '// as string. All Test ROOT
	Private  m_Prompt          '// as TestPrompt or Empty
	Private  m_CurrentSymbol   '// as string of current test symbol or ALL or ALL_R
	Private  m_CurrentSubSymbol   '// as string
	Public   CurrentTest      '// as UnitTest of m_CurrentSymbol
	Public   CurrentTestPriority  '// as integer  small is high priority
	Private  m_bAllTest  '// as boolean
	Private  m_AllFName  '// as string
	Private  m_Symbol    '// as string of doing test symbol
	Public   EnabledTestSet  '// as dictionary item:UnitTest
	Public   bTargetDebug    '// as boolean
	Public   c_ErrDblSymbol  '// as const number
	Public   m_bDisableAddTestScript  '// as boolean
	Public   m_bAutoDiff_     '// as boolean
	Public   CanModify       '// as boolean

	'----------------------------------
	Public Property Get  Sets : Set Sets = m_AllTestSet : End Property
	Public Property Get  BaseFolderPath : BaseFolderPath = m_BaseFolderPath : End Property
	Public Property Let  BaseFolderPath( x ) : m_BaseFolderPath = x : End Property
	Public Property Set  Prompt( x ) : Set m_Prompt = x : End Property
	Public Property Get  Prompt
		If not IsEmpty( m_Prompt ) Then Set Prompt = m_Prompt
	End Property
	Public Property Get  CurrentSymbol : CurrentSymbol = m_CurrentSymbol : End Property
	Public Property Get  bAllTest : bAllTest = m_bAllTest : End Property
	Public Property Let  Symbol( x )
			 If Me.CanModify Then  m_Symbol = x
		 End Property
	Public Property Get  Symbol : Symbol = m_Symbol : End Property
 
'********************************************************************************
'  <<< [Tests::Class_Initialize] >>> 
'********************************************************************************
Private  Sub  Class_Initialize()
	Set Me.c = get_TestScriptConsts()
	Set m_AllTestSet = CreateObject("Scripting.Dictionary")
	m_BaseFolderPath = g_fs.GetParentFolderName( WScript.ScriptFullName )
	m_CurrentSymbol = "ALL"
	m_AllFName = "T_ALL.vbs"
	m_bAllTest = False
	Set Me.EnabledTestSet = CreateObject( "Scripting.Dictionary" )
	Me.bTargetDebug = False
	Me.c_ErrDblSymbol = 1010
	m_bDisableAddTestScript = False
	m_bAutoDiff_ = False
	Me.CanModify = False
End Sub

 
'********************************************************************************
'  <<< [Tests::AddTestScriptAuto] >>> 
'********************************************************************************
Public Function  AddTestScriptAuto( BasePath, FName )
	m_AllFName = FName
	AddTestScriptAuto_EnumSubFolders  g_fs.GetFolder( BasePath ), FName
End Function


Private Sub AddTestScriptAuto_EnumSubFolders( fo, FName )
	Dim  subfo

	If g_fs.FileExists( fo.Path + "\" + FName ) Then
		AddTestScript  g_fs.GetFileName( fo.Path ), fo.Path + "\" + FName
	End If
	For Each subfo in fo.SubFolders
		AddTestScriptAuto_EnumSubFolders subfo, FName
	Next
End Sub
 
'********************************************************************************
'  <<< [Tests::AddTestScript] >>> 
'********************************************************************************
Public Function  AddTestScript( Symbol, Path )
	Dim  test, path2, parent

	If Not g_fs.FileExists( Path ) Then  Err.Raise 53,,"ファイルが見つかりません " + Path
	If m_bDisableAddTestScript Then  Exit Function


	'//=== Create new UnitTest
	Set test = new UnitTest : ErrCheck
	test.ScriptPath = g_fs.GetAbsolutePathName( Path )
	test.Priority = 1000
	test.Symbol = Symbol


	'//=== Get UnitTest in parent folder
	path2 = test.ScriptPath
	Do
		path2 = g_fs.GetParentFolderName( path2 )
		If path2 = "" Then  Exit Do

		For Each parent  In m_AllTestSet.Items
			If parent.ScriptPath = path2 +"\"+ m_AllFName Then
				Set test.ParentUnitTest = parent
				Exit For
			End If
		Next
	Loop


	'//=== Call Test_current for get test property
	Me.CanModify = True
	Set Me.CurrentTest = test
	Me.CurrentTestPriority = Empty
	Me.Symbol = Symbol

	call_vbs_t  Path, "Test_current", Me

	If not IsEmpty( Me.CurrentTestPriority ) Then  test.Priority = Me.CurrentTestPriority
	If not IsEmpty( Me.Symbol ) Then  test.Symbol = Me.Symbol
	Me.CanModify = False


	'//=== Add UnitTest to m_AllTestSet
	If m_AllTestSet.Exists( test.Symbol ) Then
		If IsEmpty( m_AllTestSet.Item(Symbol) ) Then
			path2 = "?"
		Else
			path2 = m_AllTestSet.Item(Symbol).ScriptPath
		End If
		Err.Raise c_ErrDblSymbol, "class Tests", "<ERROR msg=""Already defined test symbol"" symbol="""+_
			Symbol +""" "+ vbCRLF +"  path1="""+ test.ScriptPath +_
			""" "+ vbCRLF +"  path2="""+ path2 +"""/>"
	End If
	m_AllTestSet.Add  test.Symbol, test


	Set AddTestScript = test
End Function

 
'********************************************************************************
'  <<< [Tests::LoadTestSet] >>> 
'********************************************************************************
Public Sub  LoadTestSet( XmlPath, XPathForTag, AttrName )
	Dim  xml, r, root, attr, is_load

	Me.EnabledTestSet.RemoveAll

	If not g_fs.FileExists( XmlPath ) Then  Exit Sub

	Dim xx : Set xx = ReadTestCase( XmlPath, Empty )
	is_load = True
	If not IsEmpty( Me.Prompt ) Then
		If xx.Exists( "TestScriptFileName" ) Then
			If xx( "TestScriptFileName" ) <> Me.Prompt.TestScriptFileName Then _
				is_load = False
		End If
		If xx.Exists( "TestScriptFileNameExcepted" ) Then
			If xx( "TestScriptFileNameExcepted" ) = Me.Prompt.TestScriptFileName Then _
				is_load = False
		End If
	End If

	If is_load Then
		If xx.Exists( AttrName ) Then
			Dic_addFromArray  Me.EnabledTestSet, ArrayFromCSV( xx( AttrName ) ), Empty
		End If
	End If
End Sub


 
'********************************************************************************
'  <<< [Tests::SelectEnabledTestSet_sub] >>> 
'********************************************************************************
Public Sub  SelectEnabledTestSet_sub()
	Dim  key, keys

	If Me.EnabledTestSet.Count = 0 Then
		keys = m_AllTestSet.Keys
	Else
		keys = Me.EnabledTestSet.Keys
	End If

	Me.EnabledTestSet.RemoveAll
	For Each  key  In keys
		If not m_AllTestSet.Exists( key ) Then
			Err.Raise  1,, "<ERROR msg=""TestCommon_Data.xml に指定したテスト・シンボルがありません"""+_
				" symbol="""+ key +""" test_file_name="""+ Me.Prompt.TestScriptFileName +"""/>"
		End If
		Set Me.EnabledTestSet.Item( key ) = m_AllTestSet.Item( key )
	Next
End Sub


 
'********************************************************************************
'  <<< [Tests::SetCurrentSymbol] >>> 
'********************************************************************************
Public Function SetCurrentSymbol( Symbol_or_Path )
	Dim  key, item, b

	SetCurrentSymbol = 0

	'// ALL and ALL_R is special symbol
	If Symbol_or_Path = "ALL" or Symbol_or_Path = "ALL_R" Then  m_CurrentSymbol = Symbol_or_Path : _
		Me.CurrentTest = Empty : Exit Function

	'// Search by test symbol
	For Each key in m_AllTestSet.Keys()
		If key = Symbol_or_Path Then  m_CurrentSymbol = Symbol_or_Path : _
			Set Me.CurrentTest = m_AllTestSet.Item( m_CurrentSymbol ) : Exit Function
	Next

	'// Search by path
	For Each item in m_AllTestSet.Items()
		If item.ScriptPath = Symbol_or_Path Then  m_CurrentSymbol = item.Symbol : _
			Set Me.CurrentTest = m_AllTestSet.Item( m_CurrentSymbol ) : Exit Function
	Next

	'// If Symbol is path, Add test symbol
	If g_fs.FileExists( Symbol_or_Path ) Then
		If UCase(g_fs.GetFileName( Symbol_or_Path )) = UCase(m_AllFName) Then _
			m_CurrentSymbol = g_fs.GetFileName( g_fs.GetParentFolderName( g_fs.GetAbsolutePathName(Symbol_or_Path) ) ) _
		Else  m_CurrentSymbol = g_fs.GetBaseName( Symbol_or_Path )

		b = True : If m_AllTestSet.Exists( m_CurrentSymbol ) Then _
			b = ( m_AllTestSet.Item( m_CurrentSymbol ).ScriptPath <> g_fs.GetAbsolutePathName( Symbol_or_Path ) )
		If b Then  'If Not m_AllTestSet.Exists( m_CurrentSymbol ) or _
							 '  m_AllTestSet.Item( m_CurrentSymbol ).ScriptPath <> g_fs.GetAbsolutePathName( Symbol_or_Path ) Then
			AddTestScript  m_CurrentSymbol, Symbol_or_Path
		End If
		Set Me.CurrentTest = m_AllTestSet.Item( m_CurrentSymbol )
		Exit Function
	End If

	'// Error: Symbol
	echo "[ERROR] Not found symbol or path """ + Symbol_or_Path + """. CurrentDirectory = " & g_sh.CurrentDirectory
	SetCurrentSymbol = 1
End Function


 
'********************************************************************************
'  <<< [Tests::GetCallingOrder] >>> 
'********************************************************************************
Public Sub  GetCallingOrder( out_UnitTests )
	ShakerSort_fromDic  Me.Sets, out_UnitTests, +1, GetRef("CmpUnitTestPriorityInc"), Empty
End Sub


 
'********************************************************************************
'  <<< [Tests::DoTest] >>> 
'********************************************************************************
Public Sub  DoTest( Func, bReverse )

	If m_CurrentSymbol = "ALL" Or m_CurrentSymbol = "ALL_R" Then
		Redim  utests(-1)

		If bReverse Then
			ShakerSort_fromDic  m_AllTestSet, utests, -1, GetRef("CmpUnitTestPriorityDec"), Empty
		Else
			ShakerSort_fromDic  m_AllTestSet, utests, +1, GetRef("CmpUnitTestPriorityInc"), Empty
		End If

		g_Test.m_DefLogFName = m_BaseFolderPath +"\"+ g_fs.GetFileName( g_Test.m_DefLogFName )
		g_Test.Start
		If m_bAutoDiff_ Then  g_Test.m_MemLog = ""
		For Each CurrentTest in utests
			Me.OnTestCurrentSetup
			g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_current", Me
			Me.OnTestFunctionSetup  Empty
			g_Test.Do_  Me.CurrentTest.ScriptPath, Func, Me
			Me.OnTestFunctionFinish
			If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
		Next
		g_Test.Finish
	Else
		g_Test.m_DefLogFName = g_fs.GetParentFolderName( Me.CurrentTest.ScriptPath ) + "\" + g_fs.GetFileName( g_Test.m_DefLogFName )
		g_Test.Start
		If m_bAutoDiff_ Then  g_Test.m_MemLog = ""
		Set Me.CurrentTest = m_AllTestSet.Item( m_CurrentSymbol )
		Me.OnTestCurrentSetup
		g_Test.Do_  CurrentTest.ScriptPath, "Test_current", Me
		Me.OnTestFunctionSetup  Empty
		g_Test.Do_  CurrentTest.ScriptPath, Func, Me
		Me.OnTestFunctionFinish
		If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
		g_Test.Finish
	End If
End Sub

 
'********************************************************************************
'  <<< [Tests::DoAllTest] >>> 
'********************************************************************************
Public Sub  DoAllTest()
	Dim  is_all_passed,  u
	Dim  section : Set section = new SectionTree
	m_bAllTest = True
	If m_CurrentSymbol = "ALL" Or m_CurrentSymbol = "ALL_R" Then
		Redim  utests_inc(-1), utests_dec(-1)

		Me.SelectEnabledTestSet_sub

		ShakerSort_fromDic  Me.EnabledTestSet, utests_inc, +1, GetRef("CmpUnitTestPriorityInc"), Empty
		ShakerSort_fromDic  Me.EnabledTestSet, utests_dec, -1, GetRef("CmpUnitTestPriorityDec"), Empty

		g_Test.m_DefLogFName = m_BaseFolderPath + "\" + g_fs.GetFileName( g_Test.m_DefLogFName )
		g_Test.Start
		If m_bAutoDiff_ Then  g_Test.m_MemLog = ""

		For Each CurrentTest  In utests_inc
			If section.Start( Me.Symbol +" - Test_current" ) Then
				Me.OnTestCurrentSetup
				g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_current", Me
				If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
			End If : section.End_
		Next
		For Each CurrentTest  In utests_inc
			If section.Start( Me.Symbol +" - Test_build" ) Then
				If not Me.IsSkipFunctionWhenALLTest( Me.c.TestBuildFunc ) Then
					Me.OnTestFunctionSetup  Me.c.TestBuildFunc
					g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_build", Me
					Me.OnTestFunctionFinish
					If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
				End If
			End If : section.End_
		Next
		For Each CurrentTest in utests_inc
			If section.Start( Me.Symbol +" - Test_setup" ) Then
				If not Me.IsSkipFunctionWhenALLTest( Me.c.TestSetupFunc ) Then
					Me.OnTestFunctionSetup  Me.c.TestSetupFunc
					g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_setup", Me
					Me.OnTestFunctionFinish
					If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
				End If
			End If : section.End_
		Next
		For Each CurrentTest in utests_inc
			If section.Start( Me.Symbol +" - Test_start" ) Then
				If not Me.IsSkipFunctionWhenALLTest( Me.c.TestStartFunc ) Then
					Me.OnTestFunctionSetup  Me.c.TestStartFunc
					g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_start", Me
					Me.OnTestFunctionFinish
					If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
				End If
			End If : section.End_
		Next
		For Each CurrentTest in utests_dec
			If section.Start( Me.Symbol +" - Test_check" ) Then
				If not Me.IsSkipFunctionWhenALLTest( Me.c.TestCheckFunc ) Then
					Me.OnTestFunctionSetup  Me.c.TestCheckFunc
					g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_check", Me
					Me.OnTestFunctionFinish
					If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
				End If
			End If : section.End_
		Next
		For Each CurrentTest in utests_dec
			If section.Start( Me.Symbol +" - Test_clean" ) Then
				If not Me.IsSkipFunctionWhenALLTest( Me.c.TestCleanFunc ) Then
					Me.OnTestFunctionSetup  Me.c.TestCleanFunc
					g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_clean", Me
					Me.OnTestFunctionFinish
					If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
				End If
			End If : section.End_
		Next
		g_Test.Finish

		'//=== If all test was passed, Reset PassedStepLevel for re-Test all
		is_all_passed = True
		For Each  u  In  Me.Sets.Items
			If u.PassedStepLevel < 5 Then  is_all_passed = False : Exit For
		Next
		If is_all_passed Then
			For Each  u  In  Me.Sets.Items : u.PassedStepLevel = 0 : Next
		End If
	Else
		Set Me.CurrentTest = m_AllTestSet.Item( m_CurrentSymbol )
		g_Test.m_DefLogFName = g_fs.GetParentFolderName( Me.CurrentTest.ScriptPath ) + "\" + g_fs.GetFileName( g_Test.m_DefLogFName )
		g_Test.Start
		If m_bAutoDiff_ Then  g_Test.m_MemLog = ""
		If section.Start( Me.Symbol +" - Test_current" ) Then
			Me.OnTestCurrentSetup
			g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_current", Me
			Me.OnTestFunctionFinish
		End If : section.End_
		If section.Start( Me.Symbol +" - Test_build" ) Then
			If not Me.IsSkipFunctionWhenALLTest( Me.c.TestBuildFunc ) Then
				Me.OnTestFunctionSetup  Me.c.TestBuildFunc
				g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_build", Me
				Me.OnTestFunctionFinish
				If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
			End If
		End If : section.End_
		If section.Start( Me.Symbol +" - Test_setup" ) Then
			If not Me.IsSkipFunctionWhenALLTest( Me.c.TestSetupFunc ) Then
				Me.OnTestFunctionSetup  Me.c.TestSetupFunc
				g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_setup", Me
				Me.OnTestFunctionFinish
				If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
			End If
		End If : section.End_
		If section.Start( Me.Symbol +" - Test_start" ) Then
			If not Me.IsSkipFunctionWhenALLTest( Me.c.TestStartFunc ) Then
				Me.OnTestFunctionSetup  Me.c.TestStartFunc
				g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_start", Me
				Me.OnTestFunctionFinish
				If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
			End If
		End If : section.End_
		If section.Start( Me.Symbol +" - Test_check" ) Then
			If not Me.IsSkipFunctionWhenALLTest( Me.c.TestCheckFunc ) Then
				Me.OnTestFunctionSetup  Me.c.TestCheckFunc
				g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_check", Me
				Me.OnTestFunctionFinish
				If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
			End If
		End If : section.End_
		If section.Start( Me.Symbol +" - Test_clean" ) Then
			If not Me.IsSkipFunctionWhenALLTest( Me.c.TestCleanFunc ) Then
				Me.OnTestFunctionSetup  Me.c.TestCleanFunc
				g_Test.Do_  Me.CurrentTest.ScriptPath, "Test_clean", Me
				Me.OnTestFunctionFinish
				If Me.AutoDiff() Then  g_Test.Finish : m_bAllTest = False : Exit Sub
			End If
		End If : section.End_
		g_Test.Finish
	End If

	m_bAllTest = False
End Sub


 
'********************************************************************************
'  <<< [Tests::ResetTestResult] >>> 
'********************************************************************************
Public  Sub  ResetTestResult()
	Dim  u

	For Each u  In Me.Sets.Items  '// as UnitTest
		u.ResetTestResult
	Next
End Sub

 
'********************************************************************************
'  <<< [Tests::IsSkipFunctionWhenALLTest] >>> 
'********************************************************************************
Public Function  IsSkipFunctionWhenALLTest( StepOfFunc )  '// private
	Dim  ret
	Dim  u : Set u = Me.CurrentTest  '// as UnitTest


	'//=== Fail した後の関数は呼び出さない。
	ret = ( StepOfFunc <> u.PassedStepLevel + 1 )


	'//=== ただし、Skip したときの Test_clean は呼び出す。また、前回 Skip したテストは実施しない。
	If u.TestResult = E_TestSkip  and  StepOfFunc = Me.c.TestCleanFunc Then
		ret = False
	ElseIf u.TestResult = Me.c.Skipped Then
		ret = True
	End If


	'//=== ただし、親、または 子が Fail していたら、テストはしない
	If StepOfFunc <= Me.c.TestStartFunc Then
		Do
			Set u = u.ParentUnitTest
			If u Is Nothing Then  Exit Do
			If u.TestResult = E_TestFail Then  ret = True : Exit Do
		Loop
	Else
		If u.FailedChildren.Count > 0 Then  ret = True
	End If

	IsSkipFunctionWhenALLTest = ret
End Function


 
'********************************************************************************
'  <<< [Tests::OnTestCurrentSetup] >>> 
'********************************************************************************
Public Sub  OnTestCurrentSetup()  '// private
	m_Symbol = Me.CurrentTest.Symbol  '//[out] Me.m_Symbol
	Me.CurrentTestPriority = Me.CurrentTest.Priority
'//  g_Test.m_Pass = True
End Sub

 
'********************************************************************************
'  <<< [Tests::OnTestFunctionSetup] >>> 
'********************************************************************************
Public Sub  OnTestFunctionSetup( StepOfFunc )  '// private
	m_Symbol = Me.CurrentTest.Symbol
'//  g_Test.m_Pass = False
	g_Test.StepOfFunc = StepOfFunc
End Sub

 
'********************************************************************************
'  <<< [Tests::OnTestFunctionFinish] >>> 
'********************************************************************************
Public Sub  OnTestFunctionFinish()  '// private
	Dim  t : Set t = g_Test  '// as TestScript

	If not IsEmpty( t.StepOfFunc ) Then
		Dim  parent
		Dim  u : Set u = Me.CurrentTest  '// as UnitTest


		'//=== set u.PassedStepLevel, u.TestResult
		If t.TestResult = E_TestPass Then
			If u.PassedStepLevel = t.StepOfFunc - 1 Then _
				u.PassedStepLevel = u.PassedStepLevel + 1

			If u.PassedStepLevel = Me.c.StepOfLastTestFunc Then
				u.TestResult = E_TestPass
			ElseIf u.TestResult = E_TestSkip Then
				u.TestResult = Me.c.Skipped
			End If
		Else
			u.TestResult = t.TestResult
		End If


		'//=== set parent.FailedChildren
		Set parent = u.ParentUnitTest
		Do
			If parent is Nothing Then  Exit Do

			If t.TestResult = E_TestFail Then
				parent.FailedChildren.Item( u.Symbol ) = Empty  '// Add key only
			Else
				If parent.FailedChildren.Exists( u.Symbol ) Then _
					parent.FailedChildren.Remove  u.Symbol
			End If

			Set parent = parent.ParentUnitTest
		Loop

	End If
End Sub

 
'********************************************************************************
'  <<< [Tests::SetCur] >>> 
'********************************************************************************
Public Sub  SetCur( SubSymbol )
	m_CurrentSubSymbol = SubSymbol
End Sub

 
'********************************************************************************
'  <<< [Tests::IsCur] >>> 
'********************************************************************************
Public Function  IsCur( SubSymbol )
	If m_CurrentSubSymbol = "ALL" Or m_CurrentSubSymbol = "ALL_R" Or _
		 m_CurrentSubSymbol = SubSymbol Then
		IsCur = True
	Else
		IsCur = False
	End IF
End Function

 
'********************************************************************************
'  <<< [Tests::AutoDiff] >>> 
'********************************************************************************
Public Function  AutoDiff()
	If m_bAutoDiff_ and g_Test.m_nFail > 0 Then
		Dim  f : Set f = new StringStream : ErrCheck
		ReDim  path(1)
		Dim    n_path, line


		'//=== parse the output of fc command
		n_path = 0
		f.SetString  g_Test.m_MemLog
		Do Until f.AtEndOfStream
			line = f.ReadLine
			If Left( line, 6 ) = "***** " Then
				path( n_path ) = Mid( line, 7 )
				n_path = n_path + 1
				If n_path = 2 Then Exit Do
			End If
		Loop
		f = Empty


		'//=== Start Diff tool
		If not IsEmpty( path(1) ) Then
			path(0) = GetFullPath( path(0), g_fs.GetParentFolderName( Me.CurrentTest.ScriptPath ) )
			path(1) = GetFullPath( path(1), g_fs.GetParentFolderName( Me.CurrentTest.ScriptPath ) )
			If IsDefined("Setting_getDiffCmdLine") Then
				line = """" + Setting_getDiffCmdLine(0) + """ """ + path(0) + """ """ + path(1) + """"
				CreateFile  g_fs.GetParentFolderName( Me.CurrentTest.ScriptPath ) + "\Test_diff.bat", _
										"start """" " + line
				g_sh.Run  line
			Else
				echo  "[WARNING] Cannot open diff tool : not defined Setting_getDiffCmdLine"
			End If
			AutoDiff = True : Exit Function
		End If

	End If
	AutoDiff = False
End Function

 
'********************************************************************************
'  <<< [Tests::OpenFailFolder] >>> 
'********************************************************************************
Public Sub  OpenFailFolder()
	echo  ">OpenFailFolder"
	Dim  ec
	Set  ec = new EchoOff : ErrCheck

	Dim  f, line, i, s
	Dim  ds_:Set ds_= new CurDirStack : ErrCheck

	Set f = OpenTextFile( g_Test.m_DefLogFName )
	ec = Empty

	Do Until f.AtEndOfStream
		line = f.ReadLine
		If Left( line, 6 ) = "[FAIL]" Then

			'//=== Open fail folder and ReTest
			echo  line
			line = f.ReadLine
			echo  line

			Set ec = new EchoOff : ErrCheck
			i = 1
			s = MeltQuot( line, i )
			If i > 0 Then
				s = MeltQuot( line, i )
				If not IsEmpty( s ) Then

					OpenFolder  s

					If LCase( g_fs.GetFileName( s ) ) = "test.vbs" Then
						CreateFile  g_fs.GetParentFolderName( s ) + "\Test_debugger.bat", _
												"cscript //x  Test.vbs /g_debug:1 /set_input:8.5.5."
						echo "Created debug.bat"
						Sleep 1000
						echo "Run Test.vbs AutoDiff mode"
						g_sh.Run  "cscript """ + s + """ /set_input:8.5.2.9.",,True

						'// echo "Run Test.vbs AutoDiff mode"
						'// cd g_fs.GetParentFolderName( s )
						'// g_sh.Run  "debug.bat"
					End If
				End If
			End If


			'//=== Change from [FAIL] to [FAIL:Checked] in Test_logs.txt file
			f = Empty
			Set f = StartReplace( "Test_logs.txt", "Test_logs_replacing.txt", False )
			i = 0
			Do Until f.r.AtEndOfStream
				line = f.r.ReadLine
				If i = 0 and InStr( line, "[FAIL]" ) > 0 Then
					line = Replace( line, "[FAIL]", "[FAIL:Checked]" )
					i = 1
				End If
				f.w.WriteLine  line
			Loop
			f.Finish
			ec = Empty
			Exit Sub
		End If
	Loop
	Raise  1, "No Fail"
End Sub
 
'********************************************************************************
'  <<< [Tests::NextFail] >>> 
'********************************************************************************
Public Sub  NextFail()
	Dim  f, line, i, s
	Dim  ds_:Set ds_= new CurDirStack : ErrCheck

	Set f = OpenTextFile( g_Test.m_DefLogFName )

	Do Until f.AtEndOfStream
		line = f.ReadLine
		If Left( line, 6 ) = "[FAIL]" Then

			'//=== Open fail folder
			echo  line
			line = f.ReadLine
			echo  line
			i = 1
			s = MeltQuot( line, i )
			If i > 0 Then
				s = MeltQuot( line, i )
				If not IsEmpty( s ) Then
					OpenFolder  s
					If LCase( g_fs.GetFileName( s ) ) = "test.vbs" Then
						CreateFile  g_fs.GetParentFolderName( s ) + "\Test_debugger.bat", _
												"cscript //x  Test.vbs /g_debug:1 /set_input:8.5.5."
						echo "Created debug.bat"
						Sleep 1000
						echo "Run Test.vbs AutoDiff mode"
						g_sh.Run  "cscript """ + s + """ /set_input:8.5.2.9.",,True

						'// echo "Run Test.vbs AutoDiff mode"
						'// cd g_fs.GetParentFolderName( s )
						'// g_sh.Run  "debug.bat"
					End If
				End If
			End If


			'//=== Change from [FAIL] to [FAIL:Checked] in Test_logs.txt file
			f = Empty
			Set f = StartReplace( "Test_logs.txt", "Test_logs_replacing.txt", False )
			i = 0
			Do Until f.r.AtEndOfStream
				line = f.r.ReadLine
				If i = 0 and InStr( line, "[FAIL]" ) > 0 Then
					line = Replace( line, "[FAIL]", "[FAIL:Checked]" )
					i = 1
				End If
				f.w.WriteLine  line
			Loop
			f = Empty
			Exit Sub
		End If
	Loop
	Raise  1, "No Fail"
End Sub
 
'********************************************************************************
'  <<< [Tests::SaveTestResultHtml] >>> 
'********************************************************************************
Public Sub  SaveTestResultHtml( ByVal SavePath )
	Dim  f

	If IsEmpty( SavePath ) Then  SavePath = "TestResult.html"

	Set f = OpenForWrite( SavePath, Empty )
	f.WriteLine  ""
End Sub


 
'********************************************************************************
'  <<< [Tests::SaveTestResultCSV] >>> 
'********************************************************************************
Public Sub  SaveTestResultCSV( ByVal SavePath )
	Dim  f, u, step_str

	If IsEmpty( SavePath ) Then  SavePath = "TestResult.csv"

	Set f = g_fs.CreateTextFile( SavePath, True, False )

	f.WriteLine  "Test symbol,result,step,path,priority"

	For Each u  In Me.Sets.Items  '// as UnitTest

		'//=== set step_str
		If u.PassedStepLevel = Me.c.StepOfLastTestFunc Then
			step_str = ""
		Else
			step_str = Me.c.TestFuncStrs( u.PassedStepLevel + 1 )
		End If

		'//=== write line
		f.WriteLine  u.Symbol +","+ Me.c.TestResultStrs( u.TestResult ) +","+ step_str +_
			","+ GetStepPath( u.ScriptPath, Empty ) +","& u.Priority
	Next
End Sub


 
'********************************************************************************
'  <<< [Tests::LoadTestResultCSV] >>> 
'********************************************************************************
Public Sub  LoadTestResultCSV( ByVal LoadPath )
	Dim  f, u, columns

	If IsEmpty( LoadPath ) Then  LoadPath = "TestResult.csv"

	Set f = OpenForRead( LoadPath )
	f.SkipLine

	Do Until  f.AtEndOfStream
		columns = ArrayFromCSV( f.ReadLine() )

		Set u = Me.Sets.Item( columns(0) )  '// as UnitTest
		u.TestResult = Me.c.TestResultIDs( columns(1) )
		If u.TestResult = E_TestSkip Then  u.TestResult = Me.c.Skipped

		If columns(2) = "" Then
			u.PassedStepLevel = Me.c.StepOfLastTestFunc
		Else
			u.PassedStepLevel = Me.c.TestFuncIDs( columns(2) ) - 1
		End If
	Loop
End Sub


 
End Class 
 
'********************************************************************************
'  <<< [CmpUnitTestPriorityInc] >>> 
'********************************************************************************
Function  CmpUnitTestPriorityInc( left, right, param )
	CmpUnitTestPriorityInc = left.Priority - right.Priority
End Function
 
'********************************************************************************
'  <<< [CmpUnitTestPriorityDec] >>> 
'********************************************************************************
Function  CmpUnitTestPriorityDec( left, right, param )
	CmpUnitTestPriorityDec = right.Priority - left.Priority
End Function
 
'-------------------------------------------------------------------------
' ### <<<< [UnitTest] Class >>>> 
'-------------------------------------------------------------------------
Class UnitTest

	Public  Symbol     '// as string
	Public  ScriptPath '// as string
	Public  Priority   '// as integer
	Public  Delegate   '// as variant
	Public  PassedStepLevel  '// as integer. 0, 1..= c.TestBuildFunc, ..
	Public  TestResult       '// as integer. E_TestPass, E_TestFail, E_TestSkip, c.Skipped, Empty
	Public  ParentUnitTest   '// as UnitTest or Nothing
	Public  FailedChildren   '// as Dictionary of Empty. Key=UnitTest::Symbol

	'----------------------------------
	Private  Sub  Class_Initialize()
		Me.Symbol = "NoSymbol"
		Me.ScriptPath = ""
		Me.PassedStepLevel = 0
		Set Me.ParentUnitTest = Nothing
		Set Me.FailedChildren = CreateObject( "Scripting.Dictionary" )
	End Sub

	Public Function  Value()
		Value = "[" & Me.Symbol & "]" & vbCR & vbLF & " " & Me.ScriptPath
	End Function

	Public Function  PathToAbs( BaseFolderPath )
		Dim  s
		PathToAbs = True
		s = g_fs.GetAbsolutePathName( BaseFolderPath & "\" & Me.ScriptPath )
		If Not g_fs.FileExists( s ) Then  echo "[ERROR] Not found " + Me.ScriptPath + ", Base=" + BaseFolderPath : PathToAbs = False
		Me.ScriptPath = s
	End Function

	Public Sub  ResetTestResult()
		Me.PassedStepLevel = 0
		Me.TestResult = Empty
		Me.FailedChildren.RemoveAll
	End Sub

End Class


 
'-------------------------------------------------------------------------
' ### <<<< Test Result >>>> 
'-------------------------------------------------------------------------

 
'********************************************************************************
'  <<< [Pass] >>> 
'********************************************************************************
Sub  Pass
	Dim  b : b = g_EchoObj.m_bEchoOff : g_EchoObj.m_bEchoOff = False
	Const skip_msg = "Pass. ただし、Skipped が呼ばれています。 g_debug=99 にしてデバッガを起動し、Skipped にブレークポイントを張って、Skipped をカットしてください。"

	If Err.Number <> 0 Then  Err.Raise  Err.Number, Err.Source, Err.Description

	If g_bSkipped Then
		echo  skip_msg
	Else
		echo  "Pass."
	End If

	g_EchoObj.m_bEchoOff = b

	If g_bSkipped Then
		g_bSkipped = False
		Skip
	Else
		Raise  E_TestPass, "Pass."
	End If
End Sub



 
'********************************************************************************
'  <<< [Fail] >>> 
'********************************************************************************
Sub  Fail()
	Raise  E_TestFail, "Fail the Test"
End Sub



 
'********************************************************************************
'  <<< [Skip] >>> 
'********************************************************************************
Sub  Skip()
	Raise  E_TestSkip, "<SKIP/>"
End Sub


 
'********************************************************************************
'  <<< [Skipped] >>> 
'********************************************************************************
Sub  Skipped()
	g_bSkipped = True
	echo  "[Skipped]"
End Sub



 
'********************************************************************************
'  <<< [ManualTest] >>> 
'********************************************************************************
Sub  ManualTest( TestSymbol )
	Dim  b : b = g_EchoObj.m_bEchoOff : g_EchoObj.m_bEchoOff = False
	echo  "  ((( ["+TestSymbol+"] )))"
	echo  "This is ManualTest."
	g_EchoObj.m_bEchoOff = b

	g_Test.AddManualTest  TestSymbol
End Sub

 
'-------------------------------------------------------------------------
' ### <<<< Read Test Case >>>> 
'-------------------------------------------------------------------------

Dim  g_ReadTestCase

Function  ReadTestCase( XmlPath, TestCaseID )
	If IsEmpty( g_ReadTestCase ) Then  Set g_ReadTestCase = new XmlObjReader
	Set ReadTestCase = g_ReadTestCase.ReadTestCase( XmlPath, TestCaseID )
End Function

Sub  SetReadTestCase( XmlPath, TestCaseID, Condition )
	If IsEmpty( g_ReadTestCase ) Then  Set g_ReadTestCase = new XmlObjReader
	g_ReadTestCase.SetReadTestCase  XmlPath, TestCaseID, Condition
End Sub


Class  XmlObjReader
	Public  RootElemName
	Public  GroupElemName
	Public  UnitElemName
	Public  BaseDataAttrName
	Public  PlusAttrAttrName
	Public  AggregateAttrName
	Public  IsVerbose

	Private Sub  Class_Initialize()
		Me.RootElemName      = "TestCases"
		Me.GroupElemName     = "TestCase"
		Me.UnitElemName      = "SubCase"
		Me.BaseDataAttrName  = "base_data"
		Me.PlusAttrAttrName  = "plus_attr"
		Me.AggregateAttrName = "aggregate"
	End Sub


 
'********************************************************************************
'  <<< [ReadTestCase] >>> 
'********************************************************************************
Public Function  ReadTestCase( XmlPath, TestCaseID )
	Dim  out_cases, root, cases, a_case, group, x, attr, case_dic, condition, roots, stop_plus

	Set root = LoadXML( XmlPath, Empty )

	If root.getAttribute( "ReadTestCase_VerboseMode" ) = "True" Then  Me.IsVerbose = True

	If Me.IsVerbose Then  echo_v  "<Verbose func=""XmlObjReader::ReadTestCase"" XmlPath="""+ XmlPath +_
		""" TestCaseID="""+ TestCaseID +"""/>"

	If IsEmpty( TestCaseID ) Then

		'//=== call AddAttributes_sub : ルートタグについて
		Set x = CreateObject( "Scripting.Dictionary" )
		Set stop_plus = CreateObject( "Scripting.Dictionary" )
		AddAttributes_sub  x, root, stop_plus, XmlPath, root, roots
		Set ReadTestCase = x
	Else
		GetDicItem  g_ReadTestCaseParams, XmlPath, case_dic  '//[out] case_dic
		If not IsEmpty( case_dic ) Then _
			condition = case_dic.Item( TestCaseID )

		Set out_cases = new ArrayClass
		If IsEmpty( condition ) Then

			'//=== call AddChildElements_sub : SetReadTestCase によって、フィルタリングされていない場合
			Set cases = root.selectSingleNode( "./"+ Me.GroupElemName +"[@id='"+ TestCaseID +"']" )
			If not cases is Nothing Then
				AddChildElements_sub  cases, out_cases, XmlPath, root, roots
			End If
		Else

			'//=== call AddAttributes_sub : SetReadTestCase によって、フィルタリングされている場合
			Set a_case = Root.selectSingleNode( "./"+ Me.GroupElemName +"[@id='"+ TestCaseID +"']/"+ Me.UnitElemName +"[@"+ Condition +"]" )
			If a_case  is Nothing Then
				Set group = Root.selectSingleNode( "./"+ Me.GroupElemName +"[@id='"+ TestCaseID +"']" )
				Set a_case = SearchChildElement_sub( roots, group, XmlPath, root, condition )
			End If
			If a_case is Nothing Then  Raise  1, "<ERROR msg=""Not found test case"" xml="""+_
				XmlAttr( XmlPath ) +""" TestCaseID="""+ TestCaseID +""" Condition="""+ XmlAttr( condition ) +"""/>"

			Set x = CreateObject( "Scripting.Dictionary" )
			Set stop_plus = CreateObject( "Scripting.Dictionary" )
			AddAttributes_sub  x, a_case, stop_plus, XmlPath, root, roots
			AddAttributes_sub  x, a_case.parentNode, stop_plus, XmlPath, root, roots
			out_cases.Add  x
		End If

		Set ReadTestCase = out_cases
	End If
End Function


Private Sub  AddChildElements_sub( GroupXmlElem, OutDicArray, XmlPath, Root, Roots )
	Dim  a_case, x, stop_plus, value, name, sub_group, e

	'//=== call AddAttributes_sub : Me.UnitElemName タグと Me.GroupElemName タグの属性を Read する
	For Each a_case  In GroupXmlElem.selectNodes( "./"+ Me.UnitElemName )
		If Me.IsVerbose Then  echo_v  "<Verbose func=""XmlObjReader::AddChildElements_sub"">" + a_case.xml +"</DEBUG>"
		Set x = CreateObject( "Scripting.Dictionary" )
		Set stop_plus = CreateObject( "Scripting.Dictionary" )
		AddAttributes_sub  x, a_case, stop_plus, XmlPath, Root, Roots
		AddAttributes_sub  x, GroupXmlElem, stop_plus, XmlPath, Root, Roots
		OutDicArray.Add  x
	Next

	'//=== call AddChildElements_sub : 別のグループの要素を集約する
	value = GroupXmlElem.getAttribute( Me.AggregateAttrName )
	If not IsNull( value ) Then
		If IsEmpty( Roots ) Then  Set Roots = new_LinkedXMLs_sub()
		For Each name  In ArrayFromCSV( value )
			Roots.StartNavigation  XmlPath, Root

			If TryStart(e) Then  On Error Resume Next

				Set sub_group = Roots.GetLinkTargetNode( name )

			If TryEnd Then  On Error GoTo 0
			If e.num = E_NotFoundSymbol Then
				Raise  E_NotFoundSymbol,  Left( e.desc, Len( e.desc ) - 2 ) +">"+ vbCRLF+_
					GroupXmlElem.xml +vbCRLF+ "</ERROR>"
				e.Clear
			End If
			If e.num <> 0 Then  e.Raise

			AddChildElements_sub  sub_group, OutDicArray, Roots.TargetXmlPath, Roots.TargetXmlRootElem, Roots
			Roots.EndNavigation
		Next
	End If
End Sub


Private Function  SearchChildElement_sub( Roots, GroupXmlElem, XmlPath, Root, Condition )
	Dim  value, name, group, a_case, e
	Set a_case = Nothing

	value = GroupXmlElem.getAttribute( Me.AggregateAttrName )
	If not IsNull( value ) Then
		If IsEmpty( Roots ) Then  Set Roots = new_LinkedXMLs_sub()
		For Each name  In ArrayFromCSV( value )
			Roots.StartNavigation  XmlPath, Root

			If TryStart(e) Then  On Error Resume Next

				Set group = Roots.GetLinkTargetNode( name )

			If TryEnd Then  On Error GoTo 0
			If e.num = E_NotFoundSymbol Then
				Raise  E_NotFoundSymbol,  Left( e.desc, Len( e.desc ) - 2 ) +">"+vbCRLF+_
					head( GroupXmlElem.xml, 1 ) +vbCRLF+ "</ERROR>"
				e.Clear
			End If
			If e.num <> 0 Then  e.Raise

			Set a_case = group.selectSingleNode( "./"+ Me.UnitElemName +"[@"+ Condition +"]" )
			If a_case Is Nothing Then
				Set a_case = SearchChildElement_sub( Roots, group, Roots.TargetXmlPath, Roots.TargetXmlRootElem, Condition )
			End If
			Roots.EndNavigation
		Next
	End If

	Set SearchChildElement_sub = a_case
End Function


Private Function  AddAttributes_sub( x, XmlElem, StopPlusAttrs, XmlPath, Root, Roots )
	Dim  attr, attrs, e

	'//=== plus_attrs: plus_attrs 属性を辞書型にする
	Dim  plus_attrs : Set plus_attrs = CreateObject( "Scripting.Dictionary" )
	attrs = XmlElem.getAttribute( Me.PlusAttrAttrName )
	If not IsNull( attrs ) Then
		For Each attr  In ArrayFromCSV( attrs )
			plus_attrs.Item( attr ) = True
		Next
	End If


	For Each attr  In XmlElem.attributes
		'// If attr.name = "Ad" Then  Stop  '// base_data debug
		If not StopPlusAttrs.Exists( attr.name ) Then

			'//=== x: XmlElem の XML 属性を登録する
			If not x.Exists( attr.name ) Then
				x( attr.name ) = attr.value
			Else
				x( attr.name ) = x( attr.name ) +", "+ attr.value
			End If


			'//=== StopPlusAttrs: 存在する属性名が、plus_attrs に無ければ、属性名を登録する
			If not plus_attrs.Exists( attr.name ) Then
				StopPlusAttrs.Item( attr.name ) = True  '// not inherit more
			End If
		End If
	Next


	'//=== call ReadBaseTestCase_sub : base_data 属性のリンク先から継承する
	attr = XmlElem.getAttribute( Me.BaseDataAttrName )
	If not IsNull( attr ) Then
		If IsEmpty( Roots ) Then  Set Roots = new_LinkedXMLs_sub()

		If TryStart(e) Then  On Error Resume Next

			ReadBaseTestCase_sub  x, attr, XmlPath, Root, Roots, StopPlusAttrs

		If TryEnd Then  On Error GoTo 0
		If e.num = E_NotFoundSymbol Then
			Raise  E_NotFoundSymbol,  Left( e.desc, Len( e.desc ) - 8 ) + vbCRLF+_
				head( XmlElem.xml, 1 ) + vbCRLF+ "</ERROR>"
			e.Clear
		End If
		If e.num <> 0 Then  e.Raise
	End If

	Set AddAttributes_sub = x
End Function


Private Sub  ReadBaseTestCase_sub( x, Locations, FromPath, Root, Roots, StopPlusAttrs )
	Dim  location, loc, name, a_case, attrs, plus_attrs, path, attr, e, err_msg

	For Each location  In ArrayFromCSV( Locations )
		err_msg = Empty

		Roots.StartNavigation  FromPath, Root

		If TryStart(e) Then  On Error Resume Next

			Set a_case = Roots.GetLinkTargetNode( location )

		If TryEnd Then  On Error GoTo 0
		If e.num = E_NotFoundSymbol Then
			Raise  E_NotFoundSymbol,  Left( e.desc, Len( e.desc ) - 2 ) +">"+ vbCRLF+_
				"link_attribute_name = """+ Me.BaseDataAttrName +"""" +vbCRLF+_
				"</ERROR>"
			e.Clear
		End If
		If e.num <> 0 Then  e.Raise


		'//=== plus_attrs: plus_attrs 属性を辞書型にする
		Set plus_attrs = CreateObject( "Scripting.Dictionary" )
		attrs = a_case.getAttribute( Me.PlusAttrAttrName )
		If not IsNull( attrs ) Then
			For Each attr  In ArrayFromCSV( attrs )
				plus_attrs.Item( attr ) = True
			Next
		End If


		'//=== x: a_case の XML 属性を登録する
		For Each attr  In a_case.attributes
			'// If attr.name = "Ad" Then  Stop  '// base_data debug
			If not StopPlusAttrs.Exists( attr.name ) Then
				If not x.Exists( attr.name ) Then
					x( attr.name ) = attr.value
				Else
					x( attr.name ) = x( attr.name ) +", "+ attr.value
				End If
			End If

			'//=== StopPlusAttrs: 存在する属性名が、plus_attrs に無ければ、属性名を登録する
			If not plus_attrs.Exists( attr.name ) Then
				StopPlusAttrs.Item( attr.name ) = True  '// not inherit more
			End If
		Next


		'//=== call ReadBaseTestCase_sub : base_data 属性のリンク先から継承する
		attr = a_case.getAttribute( Me.BaseDataAttrName )
		If not IsNull( attr ) Then

			If TryStart(e) Then  On Error Resume Next

				ReadBaseTestCase_sub  x, attr, Roots.TargetLocation, Roots.TargetXmlRootElem, Roots, StopPlusAttrs

			If TryEnd Then  On Error GoTo 0
			If e.num = E_NotFoundSymbol Then
				Raise  E_NotFoundSymbol,  Left( e.desc, Len( e.desc ) - 8 ) + vbCRLF+_
					head( a_case.xml, 1 ) + vbCRLF+ "</ERROR>"
				e.Clear
			End If
			If e.num <> 0 Then  e.Raise
		End If

		Roots.EndNavigation
	Next
End Sub


 
'********************************************************************************
'  <<< [SetReadTestCase] >>> 
'********************************************************************************
Public Sub  SetReadTestCase( XmlPath, TestCaseID, Condition )
	Dim  case_dic

	GetDicItem  g_ReadTestCaseParams, XmlPath, case_dic  '//[out] case_dic
	If IsEmpty( case_dic ) Then
		Set case_dic = CreateObject( "Scripting.Dictionary" )
		Set g_ReadTestCaseParams.Item( XmlPath ) = case_dic
	End If

	case_dic.Item( TestCaseID ) = Condition
End Sub



'********************************************************************************
'  <<< [new_LinkedXMLs_sub] >>> 
'********************************************************************************
Function  new_LinkedXMLs_sub()
	Set new_LinkedXMLs_sub = new LinkedXMLs
	new_LinkedXMLs_sub.XmlTagNamesHavingIdName = Array( Me.RootElemName, Me.GroupElemName, Me.UnitElemName )
End Function


 
End Class 
 
'-------------------------------------------------------------------------
' ### <<<< Tools for Test Program >>>> 
'-------------------------------------------------------------------------

 
'********************************************************************************
'  <<< [EchoTestStart] >>> 
'********************************************************************************
Sub  EchoTestStart( TestSymbol )
	echo  "  ((( ["+TestSymbol+"] )))"
End Sub


 
'********************************************************************************
'  <<< [CheckTestErrLevel] >>> 
'********************************************************************************
Sub  CheckTestErrLevel( r )
	If r = E_TestSkip Then
		Skip
	ElseIf r <> E_TestPass Then
		Fail
	End If
End Sub


 
'********************************************************************************
'  <<< [GetTemporaryTestsObject] >>> 
'********************************************************************************
Function  GetTemporaryTestsObject()
	Dim  o : Set o = new Tests
	Set o.CurrentTest = new UnitTest
	Test_current  o
	Set GetTemporaryTestsObject = o
End Function


 
'********************************************************************************
'  <<< [ConvertToFullPath] >>> 
'********************************************************************************
Sub  ConvertToFullPath( SrcPath, DstPath )
	Dim  src, dst, dst_parent, line, p1, p2, path, cs, base_path, length

	mkdir_for  DstPath
	echo  ">ConvertToFullPath """ + SrcPath + """, """ + DstPath + """"
	base_path = g_fs.GetParentFolderName( g_fs.GetAbsolutePathName( DstPath ) )
	If IsDefined( "ReadUnicodeFileBOM" ) Then
		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( SrcPath ) )
		Dim  ec : Set ec = new EchoOff
		Set src = OpenForRead( SrcPath )
		Set dst = OpenForWrite( DstPath, Empty )
	Else
		g_AppKey.CheckWritable  DstPath, Empty
		Set  src = OpenTextFile( SrcPath )
		Set  dst = g_fs.CreateTextFile( DstPath, True, False )
	End If

	Do Until src.AtEndOfStream
		line = src.ReadLine
		Do
			p1 = InStr( line, "%FullPath(" ) : length = 10
			If p1 = 0 Then  p1 = InStr( line, "%AbsPath(" ) : length = 9
			If p1 = 0 Then  Exit Do
			p2 = InStr( p1 + length, line, ")%" )
			path = Mid( line,  p1 + length,  p2 - p1 - length )
			path = GetFullPath( path, base_path )
			line = Left( line, p1 - 1 ) + path + Mid( line, p2 + 2 )
		Loop
		line = Replace( line, "%DesktopPath%", g_sh.SpecialFolders("Desktop") )
		dst.WriteLine  line
	Loop
	src = Empty
	dst = Empty
End Sub


'//[ConvertToAbsPath]
Sub  ConvertToAbsPath( SrcPath, DstPath )
	ConvertToFullPath  SrcPath, DstPath
	ThisIsOldSpec
End Sub


 
'********************************************************************************
'  <<< [OpenTextFile] >>> 
'********************************************************************************
Function  OpenTextFile( Path )
	Dim  en, ed

	ErrCheck : On Error Resume Next
		Set OpenTextFile = g_fs.OpenTextFile( Path,,,-2 )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_FileNotExist or en = E_PathNotFound  Then  Err.raise  en,,ed+" : "+Path
	If en <> 0 Then  Err.Raise en,,ed
End Function


 
'********************************************************************************
'  <<< [EchoOpenEditorLog] >>> 
'********************************************************************************
Function  EchoOpenEditorLog( CommandLine )
	Dim  i, s, args, args_arr

	echo  ">"+ CommandLine

	i = 1
	s = MeltCmdLine( CommandLine, i )  '// exe name
	args = Mid( CommandLine, i )

	args_arr = ArrayFromCmdLineWithoutOpt( args, Empty )

	type_  args_arr(0)

	EchoOpenEditorLog = 0
End Function


 
'********************************************************************************
'  <<< [Execute_Echo] >>> 
'********************************************************************************
Function  Execute_Echo( ByVal ExpressionStr, Label )
	If IsEmpty( ExpressionStr ) Then
		ExpressionStr = "Empty"
	ElseIf VarType( ExpressionStr ) <> vbString Then
		ExpressionStr = GetEchoStr( ExpressionStr )
	End If

	Execute_Echo = "  Wscript.StdOut.Write  """+ GetEchoStr( Label ) +": "+ ExpressionStr +" = """+vbCRLF+_
		""+vbCRLF+_
		"  On Error Resume Next"+vbCRLF+_
		"    If IsEmpty( "+ ExpressionStr +" ) Then"+vbCRLF+_
		"      Wscript.StdOut.WriteLine  ""Empty"""+vbCRLF+_
		"    ElseIf VarType( "+ ExpressionStr +" ) = vbString Then"+vbCRLF+_
		"      Wscript.StdOut.WriteLine  """"""""+ GetEchoStr( "+ ExpressionStr +" ) + """""" as ""+ TypeName( "+ ExpressionStr +")"+vbCRLF+_
		"    Else"+vbCRLF+_
		"      Wscript.StdOut.WriteLine  GetEchoStr( "+ ExpressionStr +" ) + ""  as ""+ TypeName( "+ ExpressionStr +")"+vbCRLF+_
		"    End If"+vbCRLF+_
		"  If Err.Number <> 0 Then  Wscript.StdOut.WriteLine  Err.Description +"" as Error"""+vbCRLF+_
		"  On Error GoTo 0"
End Function


 
'********************************************************************************
'  <<< [AssertStr] >>> 
'********************************************************************************
Sub  AssertStr( StrA, StrB, Opt )
	If IsEmpty( Opt ) Then  Opt = 0
	If StrComp( StrA, StrB, Opt and 1 ) = 0 Then  Exit Sub

	Dim  tmp_a_path : tmp_a_path = GetTempPath( "StrA_*.txt" )
	Dim  tmp_b_path : tmp_b_path = GetTempPath( "StrB_*.txt" )

	Dim  cs : Set cs = new_TextFileCharSetStack( "UTF-16" )
	CreateFile  tmp_a_path,  StrA
	CreateFile  tmp_b_path,  StrB

	AssertFC  tmp_a_path,  tmp_b_path  '// start diff tool

	'// if same file, when string was saved.
	Dim  file,  pos,  ch_a,  ch_b,  line_top_pos,  column,  line_num

	pos = 1 : line_num = 1 : column = 1
	Do
		ch_a = Mid( StrA, pos, 1 )
		ch_b = Mid( StrB, pos, 1 )
		If StrComp( ch_a, ch_b, Opt and 1 ) Then
			Raise  1, "<ERROR msg=""Not same"" line=""" & line_num & """ column=""" & column & _
				""" str_a_char_code=""" & Asc( ch_a ) & """ str_b_char_code=""" & Asc( ch_b ) & """/>"
		End If
		Assert  ch_a <> ""
		pos = pos + 1
		column = column + 1
		If ch_a = vbLF Then  line_num = line_num + 1 : column = 1
	Loop
End Sub


 
'********************************************************************************
'  <<< [AssertFC] >>> 
'********************************************************************************
Sub  AssertFC( Path1, Path2 )
	echo  ">AssertFC  """+ Path1 +""" """+ Path2 +""""

	Set c = g_VBS_Lib
	Set ec = new EchoOff

	If TryStart(e) Then  On Error Resume Next
		IsSameTextFile  Path1, Path2, c.RightHasPercentFunction or c.ErrorIfNotSame
	If TryEnd Then  On Error GoTo 0

	ec = Empty

	If e.num = E_TestFail Then
		echo  "<ERROR msg=""Assert が Fail しました。""/>"
		If IsEmpty( g_Vers("AssertFC_Diff") )  or  g_Vers("AssertFC_Diff") Then
			start  GetDiffCmdLine( _
				GetFullPath( Path1, Empty ) & _
				"(" & LoadXML( e.desc, F_Str ).getAttribute( "line1_num" ) & ")", _
				GetFullPath( Path2, Empty ) )
		End If
		e.Raise
	ElseIf e.num <> 0 Then
		e.Raise
	End If
End Sub


 
'*************************************************************************
'  <<< [AssertString] >>> 
'*************************************************************************
Sub  AssertString( TestString, AnswerString, Option_ )
	If StrComp( TestString, AnswerString, StrCompOption( Option_ ) ) <> 0 Then
		start  GetDiffStringCmdLine( _
			"<AssertString><![CDATA["+ TestString +"]]>"+ _
			new_BinaryArrayAsText( TestString, Empty ).xml +"</AssertString>", _
			"<AssertString><![CDATA["+ AnswerString +"]]>"+ _
			new_BinaryArrayAsText( AnswerString, Empty ).xml +"</AssertString>" )
	End If
End Sub


 
'*************************************************************************
'  <<< [GetDiffStringCmdLine] >>> 
'*************************************************************************
Function  GetDiffStringCmdLine( StringA, StringB )
	Set GetDiffStringCmdLine = GetDiffStringCmdLine3( StringA, StringB, Empty )
End Function


 
'*************************************************************************
'  <<< [GetDiffStringCmdLine3] >>> 
'*************************************************************************
Function  GetDiffStringCmdLine3( StringA, StringB, StringC )
	Set ec = new EchoOff
	Set diff = new DiffCmdLineClass

	diff.PathA = GetTempPath( "Diff_*_A.txt" )
	CreateFile  diff.PathA, StringA

	diff.PathB = GetTempPath( "Diff_*_B.txt" )
	CreateFile  diff.PathB, StringB

	If not IsEmpty( StringC ) Then
		diff.PathC = GetTempPath( "Diff_*_C.txt" )
		CreateFile  diff.PathC, StringC
	End If

	Set GetDiffStringCmdLine3 = diff
End Function


 
'*************************************************************************
'  <<< [DiffCmdLineClass] >>> 
'*************************************************************************
Class  DiffCmdLineClass
	Public  PathA
	Public  PathB
	Public  PathC

	Public Default Property Get  CmdLine()
		If IsEmpty( PathC ) Then
			CmdLine = GetDiffCmdLine( PathA, PathB )
		Else
			CmdLine = GetDiffCmdLine3( PathA, PathB, PathC )
		End If
	End Property

	Sub  Remove()
		del  Me.PathA
		del  Me.PathB
		del  Me.PathC
	End Sub
End Class


 
'***********************************************************************
'* Function: GetDiffOneLineCmdLine
'***********************************************************************
Function  GetDiffOneLineCmdLine( in_PathAndLineNumA, in_PathAndLineNumB )
	ReDim  jumps(1)

	If not IsArray( in_PathAndLineNumA ) Then
		Set jumps(0) = GetTagJumpParams( in_PathAndLineNumA )
	Else
		Set jumps(0) = new TagJumpParams
		jumps(0).Keyword = in_PathAndLineNumA(0)
	End If

	If not IsArray( in_PathAndLineNumB ) Then
		Set jumps(1) = GetTagJumpParams( in_PathAndLineNumB )
	Else
		Set jumps(1) = new TagJumpParams
		jumps(1).Keyword = in_PathAndLineNumB(0)
	End If

	file_num = 1
	For Each  jump  In  jumps
		If not IsEmpty( jump.Path ) Then

			Set file = OpenForRead( jump.Path )
			line = ""
			Do Until  file.AtEndOfStream
				file.SkipLine

				If file.Line = jump.LineNum Then
					line = file.ReadLine()
					Exit Do
				End If
			Loop
			file = Empty
		Else
			line = jump.Keyword
		End If


		jump.Path = GetTempPath( "DiffOneLine_"+ CStr( file_num ) +".txt" )
		Set file = OpenForWrite( jump.Path, Empty )
		For i=1 To Len( line )

			file.WriteLine  Mid( line, i, 1 )
		Next
		file = Empty

		file_num = file_num + 1
	Next

	Set diff_ = new DiffCmdLineClass
	diff_.PathA = jumps(0).Path
	diff_.PathB = jumps(1).Path

	Set GetDiffOneLineCmdLine = diff_
End Function


 
