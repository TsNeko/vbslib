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
Dim  g_vbslib_main_Path
     g_vbslib_main_Path = g_SrcPath


 
'*************************************************************************
'  <<< Global variables >>> 
'*************************************************************************

Dim  g_WritablePathes
Dim  g_Err2, g_EchoObj
Dim  g_AppKey
Dim  g_Test
Dim  g_CUI
Dim  g_ChildHead
Dim  g_CurrentWritables
Dim  g_FileSystemRetryMSec
Dim  g_FileSystemMaxRetryMSec
Dim  g_Player  ' as Vbslib_Player
Dim  g_BreakByPath  ' as string
Dim  g_BrokenCountByPath  ' as integer
Dim  g_BreakCountByPath  ' as integer
Dim  g_debug_tree
Dim  g_IsAutoTest : g_IsAutoTest = False
Dim  g_StdRegProv
Dim  g_is_vbslib_for_fast_user


Function  InitializeModule( ThisPath )
	ReDim  g_WritablePathes(-1)
	get_TempFile
	g_Vers("CutPropertyM") = True
	Set o = new VarWithParameterClass
		o.VarNameAndStartBracket = "XML_File("
		Set o.GetVar = GetRef( "VarWithParameter_XML_FileClass_GetVar" )
	Set g_Vers( o.VarNameAndStartBracket ) = o
	Set o = new VarWithParameterClass
		o.VarNameAndStartBracket = "ArrayFromXML_File("
		Set o.GetVar = GetRef( "VarWithParameter_ArrayFromXML_FileClass_GetVar" )
	Set g_Vers( o.VarNameAndStartBracket ) = o
	Set o = new VarWithParameterClass
		o.VarNameAndStartBracket = "SpecialFolders("
		Set o.GetVar = GetRef( "VarWithParameter_SpecialFoldersClass_GetVar" )
	Set g_Vers( o.VarNameAndStartBracket ) = o

	Set g_CurrentWritables = new CurrentWritables : ErrCheck

	Set g_CustomEchoStrGenerators = CreateObject( "Scripting.Dictionary" )
	Set g_CustomEchoStrGenerators( "Dictionary" ) = GetRef( "Dictionary_xml_sub" )
	Set g_CustomEchoStrGenerators( "SWbemObjectEx" ) = GetRef( "SWbemObjectEx_xml_sub" )

	Set g_EchoObj = new EchoObj : ErrCheck
	Set g_Err2 = new Err2 : ErrCheck
	g_Err2.BreakErrID = g_debug
	g_Err2.BreakNestPos = g_debug_tree
	If IsNumeric( g_debug_process ) Then
		g_Err2.Break_ChildProcess_CallID.Add  g_debug_process
	ElseIf IsArray( g_debug_process ) Then
		g_Err2.Break_ChildProcess_CallID.Copy  g_debug_process
	End If

	Set g_FileOptions = new FileOptionsClass

	Set g_CUI = new CUI : ErrCheck
	g_FileSystemRetryMSec = 4*1000
	g_FileSystemMaxRetryMSec = 60*1000
	Set g_InterProcess = new InterProcess : ErrCheck
	new_ChildProcess_ifChildProcess
	If not g_ChildProcess is Nothing Then  g_InterProcess.OnCallInChild  g_ChildProcess

	g_InterProcess.InterProcessDataArray.Add  g_Err2

	Dim pr : Set pr = get_ChildProcess()
	If not pr is Nothing Then _
		g_Err2.loadXML  pr.m_InXML.selectSingleNode( "Err2" )

	If not IsObject( g_Vers("TextFileExtension") ) Then
		a_array = g_Vers("TextFileExtension")
		Set g_Vers("TextFileExtension") = CreateObject( "Scripting.Dictionary" )
		g_Vers("TextFileExtension").CompareMode = 1
		If not IsEmpty( a_array ) Then
			Dic_addFromArray  g_Vers("TextFileExtension"), a_array, True
		End If
	End If
End Function
Dim  g_InitializeModule
Set  g_InitializeModule = GetRef( "InitializeModule" )


Function  FinalizeModule( ThisPath, Reason )
	If not IsEmpty( g_Err2 ) Then
		If Reason = 0 Then
			g_Err2.OnSuccessFinish
		Else
			g_Err2.OnErrorFinish
		End If
	End If

	If not IsEmpty( g_ChildProcess ) Then
		If not g_ChildProcess is Nothing Then  g_ChildProcess.Finish
	End If

	If not IsEmpty( g_EchoObj ) Then  echo_flush
End Function
Dim g_FinalizeModule: Set g_FinalizeModule = GetRef( "FinalizeModule" )
Dim g_FinalizeLevel:      g_FinalizeLevel  = 100  ' If smaller, called early


Const  F_File      = 1
Const  F_Folder    = 2
Const  F_SubFolder = 4

Const  g_PauseMsg = "続行するには Enter キーを押してください . . . "
Const  g_PauseMsgStone = 24
Const  g_ConnectDebugMsg = "下記のファイルをテキストエディタで開いて次のように変数の値を修正すると、デバッガに接続して問題がある場所で停止します。"
Const  g_ConnectDebugMsgV5 = "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"


 
'*************************************************************************
'  <<< [g_VBS_Lib] >>> 
'*************************************************************************
Dim  g_VBS_Lib : Set g_VBS_Lib = new STH_VbsLibClass : ErrCheck


Class  STH_VbsLibClass
	Public  CutTag, ExistOnly, NotExistOnly, MakeShortcutFiles, ForMkDir, CopyV4, CopyRen, EnvVar, Range
	Public  ToNotReadOnly
	Public  WholeWord, CaseSensitive, EchoV_NotSame, Rev, LastNextPos, LineHead, LineTail
	Public  Reverse, NotEchoStartCommand, NotInstalled, ErrorIfNotExistBoth, ErrorIfExist, TimeStamp
	Public  Shift_JIS,  EUC_JP,  Unicode,  UTF_8,  UTF_8_No_BOM,  No_BOM,  UTF_7,  ISO_2022_JP
	Public  NODE_ELEMENT, NODE_ATTRIBUTE, NODE_TEXT, NODE_DOCUMENT, NODE_PROCESSING_INSTRUCTION
	Public  KeepLineSeparators, CutLastLineSeparator, CutLineSeparators, LF, CRLF
	Public  SkipLeftSpaceLine, RightHasPercentFunction, WithDollarVariable, ErrorIfNotSame
	Public  DstIsBackup,  CheckFileExists,  CheckFolderExists,  AllowEnterOnly,  AllowWildcard
	Public  UseArgument1,  UseArgument2
	Public  File, Folder, SubFolder, NotSubFolder, SubFolderIfWildcard, AbsPath, FullPath, ArrayOfArray
	Public  NotToEmptyArray, NotResetFoundFlag, EmptyFolder
	Public  CompareOnlyExistB, StopIsNotSame, ReplaceIfExist, IgnoreIfExist, AddAlways
	Public  NotCaseSensitive, AsPath, NoError, NoConfirm
	Public  NoRound, ToTrashBox, Append, AfterDelete, CheckSameIfExist
	Public  XML_DOM_ReadCache  '// as dictionary key=path, item=IXMLDOMElement class
	Public  TextReadCache  '// as dictionary key=path, item=string
	Public  WshRunning, WshFinished, Forever, NoRootXML, StringData, InheritSuperClass

	Public  ProgressTimer

	Private Sub  Class_Initialize()
		CutTag = 1
		ExistOnly = 2
		NotExistOnly = 8
		MakeShortcutFiles = 4
		ForMkDir = 1
		CopyV4 = 4
		CopyRen = 5
		Set EnvVar = new EnumType : EnvVar.Name = "EnvVar"
		Range = 2
		CaseSensitive = &h100
		WholeWord     = &h04
		Rev           = &h08
		LastNextPos   = &h10
		LineHead      = &h20
		LineTail      = &h40
		EchoV_NotSame = &h80
		ErrorIfNotExistBoth = &h200
		ErrorIfExist = &h400
		TimeStamp    = &h800
		Reverse = -1
		NotEchoStartCommand = 1
		NotInstalled = 16

		Shift_JIS    =   &h1000
		EUC_JP       =   &h2000
		ISO_2022_JP  =   &h4000
		ToNotReadOnly = &h10000
		Unicode      =        2
		UTF_8        =        8
		UTF_8_No_BOM =     &h80
		No_BOM       =     &h40
		UTF_7        =        7

		Append           =    4
		AfterDelete      = &h40
		CheckSameIfExist =    2

		NODE_ELEMENT = 1 :  NODE_ATTRIBUTE = 2  : NODE_TEXT = 3
		NODE_DOCUMENT = 9 : NODE_PROCESSING_INSTRUCTION = 7

		KeepLineSeparators = -2 : CutLastLineSeparator = 1 : CutLineSeparators = 4 :  LF = 10 : CRLF = -1
		SkipLeftSpaceLine = 2 : RightHasPercentFunction = 4 : WithDollarVariable = 8
		ErrorIfNotSame = &h4000

		DstIsBackup = 2

		CheckFileExists =   1
		CheckFolderExists = 2
		AllowEnterOnly =    4
		AllowWildcard  =    8
		UseArgument1 =   &h10
		UseArgument2 =   &h20

		File                = &h01
		Folder              = &h02
		SubFolder           = &h04
		NotSubFolder        = &h08
		SubFolderIfWildcard = &h20
		AbsPath             = &h08
		FullPath            = &h08
		ArrayOfArray        = &h10
		EmptyFolder         = &h40
		'// NotFound            = &h80

		NotToEmptyArray = &h4000
		NotResetFoundFlag = &h4000

		CompareOnlyExistB = 1
		StopIsNotSame     = 2

		ReplaceIfExist = 1
		AddAlways      = 3
		IgnoreIfExist  = 4

		NotCaseSensitive = 1
		AsPath           = 2

		NoError          = &h4000
		NoConfirm        = &h2000

		NoRound          = 1
		ToTrashBox       = 1

		WshRunning       = 0
		WshFinished      = 1
		Forever          = -1

		NoRootXML = 1       '// F_NoRoot
		StringData = &h8000  '// F_Str
		InheritSuperClass = 2


		Set XML_DOM_ReadCache = CreateObject( "Scripting.Dictionary" )
		XML_DOM_ReadCache.CompareMode = NotCaseSensitive
		Set TextReadCache = CreateObject( "Scripting.Dictionary" )
		TextReadCache.CompareMode = NotCaseSensitive

		Set Me.ProgressTimer = new g_VBS_Lib_ProgressTimerClass
	End Sub

	Public Property Get  NotFound()
		Confirm_VBS_Lib_ForFastUser
		NotFound = &h80
	End Property

	Private  m_XML_ElementBase64
	Public Property Get  XML_ElementBase64()
		If IsEmpty( m_XML_ElementBase64 ) Then
			Set xml = CreateObject( "MSXML2.DOMDocument" )
			Set m_XML_ElementBase64 = xml.createElement( "DummyTag" )
			m_XML_ElementBase64.dataType = "bin.base64"
		End If
		Set XML_ElementBase64 = m_XML_ElementBase64
	End Property
End Class


Class EnumType : Public Name : End Class


 
'*************************************************************************
'  <<< Error Code >>> 
'*************************************************************************

Dim E_Others            : E_Others            = 1

Dim E_TestPass          : E_TestPass          = 21
Dim E_TestSkip          : E_TestSkip          = 22
Dim E_TestFail          : E_TestFail          = 23
Dim E_UserCancel        : E_UserCancel        = 24

Dim E_BuildFail         : E_BuildFail         = &h80041004
Dim E_OutOfWritable     : E_OutOfWritable     = &h80041005
Dim E_NotFoundSymbol    : E_NotFoundSymbol    = &h80041006
Dim E_ProgRetNotZero    : E_ProgRetNotZero    = &h80041007
Dim E_Unexpected        : E_Unexpected        = &h80041008
Dim E_TimeOut           : E_TimeOut           = &h80041009

Dim E_WIN32_FILE_NOT_FOUND: E_WIN32_FILE_NOT_FOUND = &h80070002
Dim E_WIN32_DIRECTORY     : E_WIN32_DIRECTORY      = &h8007010B
Dim E_WIN32_INVALID_NAME  : E_WIN32_INVALID_NAME   = &h8007007B

Dim E_ProgTerminated    : E_ProgTerminated    = &hC0000005

Dim E_BadType           : E_BadType           = 13
Dim E_FileNotExist      : E_FileNotExist      = 53
Dim E_EndOfFile         : E_EndOfFile         = 62
Dim E_WriteAccessDenied : E_WriteAccessDenied = 70
Dim E_ReadAccessDenied  : E_ReadAccessDenied  = 70
Dim E_PathNotFound      : E_PathNotFound      = 76
Dim E_AlreadyExist      : E_AlreadyExist      = 58
Dim E_NoObjectProvider  : E_NoObjectProvider  = 3251


 
'*************************************************************************
'  <<< File Object >>> 
'*************************************************************************

Const ReadOnly  = 1


 
'*-------------------------------------------------------------------------*
'* ### <<<< Debugging >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [g_count_up] >>> 
'*************************************************************************
Redim  g_count(-1)

Function  g_count_up( i )
	If i > UBound( g_count ) Then  Redim Preserve  g_count(i)
	g_count_up = g_count(i) + 1
	g_count(i) = g_count_up
End Function


 
'*************************************************************************
'  <<< [SetTestMode] >>> 
'*************************************************************************
Dim  F_NotRandom : F_NotRandom = 1
Dim  g_TestModeFlags

Sub  SetTestMode( Flags )
	g_TestModeFlags = Flags
End Sub


 
'***********************************************************************
'* Function: Confirm_VBS_Lib_ForFastUser
'***********************************************************************
Sub  Confirm_VBS_Lib_ForFastUser()
	If g_is_vbslib_for_fast_user Then
	Else
		If IsEmpty( g_is_vbslib_for_fast_user ) Then _
			If MsgBox( "暫定仕様の機能を使います", vbOKCancel, "vbslib" ) = vbOK Then _
				g_is_vbslib_for_fast_user = True
		If g_is_vbslib_for_fast_user Then
		Else
			Error
		End If
	End If
End Sub


 
'*-------------------------------------------------------------------------*
'* ### <<<< User Interface >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [EchoObj] Class >>> 
'*************************************************************************
Class  EchoObj
	Public  m_bEchoOff
	Public  m_bDisableEchoOff
	Public  m_Buf
	Public  m_BufN

	Private Sub  Class_Initialize()
		Me.m_bEchoOff = False : Me.m_bDisableEchoOff = False
	End Sub
End Class
'// g_EchoObj


 
'*************************************************************************
'  <<< [echo] >>> 
'*************************************************************************
Function  echo( ByVal msg )
	If g_EchoObj.m_bEchoOff Then  Exit Function

	If not IsEmpty( msg ) Then
		msg = GetEchoStr( msg )

		If g_CommandPrompt = 0 Then
			If IsEmpty( g_EchoObj.m_Buf ) Then
				g_EchoObj.m_Buf = msg
			Else
				g_EchoObj.m_Buf = g_EchoObj.m_Buf & vbCRLF & msg
			End If
			g_EchoObj.m_BufN = g_EchoObj.m_BufN + 1
			If g_EchoObj.m_BufN >= 20 Then  echo_flush
		Else
			WScript.Echo  msg
		End If

		If not IsEmpty( g_Test ) Then _
			g_Test.WriteLogLine  msg
		If not IsEmpty( g_EchoCopyStream ) Then _
			g_EchoCopyStream.WriteLine  msg
	End If
	echo = msg
End Function


 
'*************************************************************************
'  <<< [GetEchoStr] >>> 
'*************************************************************************
Function  GetEchoStr( ByVal msg )
	GetEchoStr = GetEchoStr_sub( msg, 0 ) : CutLastOf  GetEchoStr, vbCRLF, Empty
End Function

Dim  g_CustomEchoStrGenerators  '// as Dictionary of Function. Key=TypeName

Function  GetEchoStr_sub( ByVal msg, ByVal Level )
	Dim  s, e, i, ss

	If IsObject( msg ) Then
		If g_CustomEchoStrGenerators.Exists( TypeName( msg ) ) Then
			s = g_CustomEchoStrGenerators.Item( TypeName( msg ) )( msg, Level )
		ElseIf msg is Nothing Then
			s = "Nothing" + vbCRLF
		Else
			s = "Class " & TypeName( msg )
			ErrCheck : On Error Resume Next
				s = msg.xml_sub( Level+1 )
				e = Err.Number
				If e = 438 Then  s = s + vbCRLF + msg.xml()
			On Error GoTo 0
			If e <> 0 And e <> 438 Then  Err.Raise e
				'// xml_sub の内部でエラーが出たときは、GetEchoStr の外から xml_sub を呼び出してください。
		End If

		GetEchoStr_sub = s
		Exit Function
	End If

	'// If Empty Then  msg = ""
	If IsNull( msg ) Then
		msg = GetTab( Level )+ "(null)"
	ElseIf VarType( msg ) = vbBoolean Then
		If msg Then  msg = GetTab( Level )+ "True" _
		Else         msg = GetTab( Level )+ "False"
	ElseIf IsArray( msg ) Then
		s = GetTab( Level )+ "<Array ubound="""& UBound( msg ) &""">" +vbCRLF
		For i=0 To UBound( msg )
			s = s + GetTab( Level+1 )+ "<Item id="""& i &""">"& Trim( GetEchoStr_sub( msg(i), Level+1 ) )
			CutLastOf  s, vbCRLF, Empty
			s = s + "</Item>" +vbCRLF
		Next
		s = s + GetTab( Level )+ "</Array>" +vbCRLF
		GetEchoStr_sub = s
		Exit Function
	End If

	GetEchoStr_sub = GetTab( Level ) & msg & vbCRLF
End Function


 
'*************************************************************************
'  <<< [echo_flush] >>> 
'*************************************************************************
Sub  echo_flush()
	If g_CommandPrompt = 0 Then
	 If ( g_EchoObj.m_BufN > 0 ) and ( Err.Number <> E_UserCancel ) and ( g_Err2.num <> E_UserCancel ) Then
		Do
			If MsgBox( g_EchoObj.m_Buf, vbOKCancel, WScript.ScriptName ) = vbCancel Then
				If MsgBox( "スクリプトを終了しますか？", vbYesNo, WScript.ScriptName ) = vbYes Then
					g_EchoObj.m_Buf = Empty
					g_EchoObj.m_BufN = 0
					If g_IsFinalizing Then
						Exit Sub
					Else
						Raise  E_UserCancel, "ユーザーによるキャンセル"
					End If
				End If
			Else
				Exit Do
			End If
		Loop
		g_EchoObj.m_Buf = Empty
		g_EchoObj.m_BufN = 0
	 End If
	End If
End Sub


 
'*************************************************************************
'  <<< [echo_line] >>> 
'*************************************************************************
Sub  echo_line()
	echo  "-------------------------------------------------------------------------------"
End Sub


 
'*************************************************************************
'  <<< [EchoOff] >>> 
'*************************************************************************
Class  EchoOff
	Public  m_Prev

	Private Sub  Class_Initialize()
		m_Prev = g_EchoObj.m_bEchoOff
		g_EchoObj.m_bEchoOff = not g_EchoObj.m_bDisableEchoOff
	End Sub

	Public Sub  Close()
		g_EchoObj.m_bEchoOff = m_Prev
		m_Prev = Empty
	End Sub

	Private Sub  Class_Terminate()
		If not IsEmpty( m_Prev ) Then _
			Me.Close
	End Sub
End Class


 
'*************************************************************************
'  <<< [DisableEchoOff] >>> 
'*************************************************************************
Sub  DisableEchoOff()
	g_EchoObj.m_bDisableEchoOff = True
End Sub


 
'*************************************************************************
'  <<< [echo_r] >>> 
' return: output message
'*************************************************************************
Function  echo_r( ByVal msg, redirect_path )
	Dim  f

	If IsObject( msg ) Then  msg = msg.xml

	If g_is_debug Then  WScript.Echo  msg

	If IsEmpty( redirect_path ) Then
	ElseIf redirect_path = "" Then
		If not g_is_debug Then  WScript.Echo  msg
	Else
		Set f = g_fs.OpenTextFile( redirect_path, 2, True, False )
		f.WriteLine  msg
	End If

	If not IsEmpty( g_EchoCopyStream ) Then _
		g_EchoCopyStream.WriteLine  msg

	echo_r = msg
End Function


 
'*************************************************************************
'  <<< [type_] >>> 
'*************************************************************************
Sub  type_( path )
	Dim  f

	Set f = g_fs.OpenTextFile( path,,,-2 )

	Do Until f.AtEndOfStream
		echo f.ReadLine
	Loop
End Sub


 
'*************************************************************************
'  <<< [Pause] >>> 
'*************************************************************************
Sub  Pause()
	If g_CommandPrompt = 0 Then
		echo  "続行するには Enter キーを押してください . . ."
		echo_flush
	Else
		g_CUI.input_sub  g_PauseMsg, False
	End If
End Sub


 
'*************************************************************************
'  <<< [pause2] >>> 
'*************************************************************************
Sub  pause2()
	If WScript.Arguments.Named("wscript")=1 Then input g_PauseMsg
End Sub


 
'*************************************************************************
'  <<< [PauseForDebug] >>> 
'*************************************************************************
Sub  PauseForDebug()
	If not g_IsSkipPauseForDebug Then
		message = "a と Enter : 今後は止めない" + vbCRLF + g_PauseMsg

		echo_v  ""
		echo_v  message
		echo_v  "別のウィンドウからの入力を待っています . . ."

		key = InputBox( message )
		If key = "a" Then _
			g_IsSkipPauseForDebug = True

		echo_v  ""
	End If
End Sub

Dim  g_IsSkipPauseForDebug : g_IsSkipPauseForDebug = False


 
'*************************************************************************
'  <<< [Input] >>> 
'*************************************************************************
Function  Input( ByVal msg )

	Input = g_CUI.input( msg )

End Function


 
'*************************************************************************
'  <<< [SetInput] >>> 
'*************************************************************************
Sub  SetInput( Keys )
	g_CUI.m_Auto_Keys = Keys
End Sub


 
'*************************************************************************
'  <<< [set_input] >>> 
'*************************************************************************
Sub  set_input( Keys )
	g_CUI.m_Auto_Keys = Keys
End Sub


 
'*************************************************************************
'  <<< [InputPath] >>> 
'*************************************************************************
'//Const  F_ChkFileExists   = 1
'//Const  F_ChkFolderExists = 2
'//Const  F_AllowEnterOnly  = 4

Function  InputPath( Prompt, Flags )
	Dim  path,  path_and_num
	Dim  c : Set c = g_VBS_Lib

	If Flags and ( c.UseArgument1 or c.UseArgument2 ) Then
		Dim  args : Set args = GetWScriptArgumentsUnnamed()
		Dim  num
		If Flags and c.UseArgument1 Then
			num = 1
		Else
			num = 2
		End If

		If args.Count >= num Then
			path = args( num - 1 )
		End If
	End If

	Do
		If IsEmpty( path ) Then _
			path = Input( Prompt )
		path = Trim2( path )

		If path = "" Then
			If  Flags and c.AllowEnterOnly  Then  path_and_num = "" : Exit Do
			echo  "パスを入力してください"
		Else
			If Left( path, 1 ) = """" and Right( path, 1 ) = """" Then _
				path = Mid( path, 2, Len( path ) - 2 )

			If Left( path, 2 ) <> "${" Then
				path_and_num = GetFullPath( path, g_start_in_path )
			Else
				path_and_num = path
			End If
			path = GetTagJumpParams( path_and_num ).Path

			If ( Flags and ( c.CheckFileExists or c.CheckFolderExists ) ) = 0 Then  Exit Do
			If ( Flags and c.AllowWildcard ) and ( InStr( path, "*" ) >= 1 ) Then  Exit Do
			If Flags and c.CheckFileExists Then
				If g_fs.FileExists( path ) Then  Exit Do
			End If
			If Flags and c.CheckFolderExists Then
				If g_fs.FolderExists( path ) Then  Exit Do
			End If
			echo  "見つかりません : "+ path
		End If
		path = Empty
	Loop
	InputPath = path_and_num
End Function


 
'*************************************************************************
'  <<< [InputCommand] >>> 
'*************************************************************************
Dim  g_InputCommand_Args

Sub  InputCommand( ByVal LeadOrOpt, ByVal Prompt, Opt, AppKey )
	Dim  key, keys, func, e, ds, s, i,  is_show_name

	If IsEmpty( Prompt ) Then  Prompt = "番号またはコマンド >"

	If IsEmpty( g_InputCommand_Args ) Then
		Set g_InputCommand_Args = GetWScriptArgumentsUnnamed()

		If VarType( LeadOrOpt ) = vbString Then
			s = LeadOrOpt
			Set LeadOrOpt = new InputCommandOpt : LeadOrOpt.Lead = s
		End If

		If g_InputCommand_Args.Count > 0 Then
			key = g_InputCommand_Args(0)

			s = ""
			For i = 1 To g_InputCommand_Args.Count - 1
				s = s + g_InputCommand_Args(i) + vbLF
			Next
			g_CUI.m_Auto_KeyEnter = vbLF
			If g_CUI.m_Auto_Keys <> "" Then _
				Raise 1, "InputCommand を使うときは、set_input または SetAutoKeysFromMainArg を呼び出さないでください"
			set_input  s
		End If
	Else
		i = InStr( g_CUI.m_Auto_Keys, vbLF )
		If i = 0 Then
			key = g_CUI.m_Auto_Keys
			If key = "" Then  Set g_InputCommand_Args = new ArrayClass  '// empty array
		Else
			key = Left( g_CUI.m_Auto_Keys, i-1 )
			g_CUI.m_Auto_Keys = Mid( g_CUI.m_Auto_Keys, i+1 )
		End If
	End If

	Do
		is_show_name = False

		If g_InputCommand_Args.Count = 0 Then
			If g_CommandPrompt = 0 Then
				echo_flush
			Else
				echo_line
			End If

			Do
				If not IsEmpty( LeadOrOpt.Lead ) Then _
					echo  LeadOrOpt.Lead

				For Each key  In LeadOrOpt.CommandReplace.Keys
					If IsNumeric( key ) Then
						If LeadOrOpt.MenuCaption.Exists( key ) Then
							s = Replace( LeadOrOpt.MenuCaption.Item( key ), "%name%", LeadOrOpt.CommandReplace.Item( key ) )
							echo  " "+ key +". " + env( s )
						Else
							echo  " "+ key +". " + LeadOrOpt.CommandReplace.Item( key )
						End If
					End If
				Next

				key = input( Prompt )

				If ( key = "" ) and ( g_CommandPrompt = 0 ) Then
					If MsgBox( "スクリプトを終了しますか？", vbYesNo, WScript.ScriptName ) = vbYes Then
						If g_IsFinalizing Then
							Exit Sub
						Else
							Raise  E_UserCancel, "ユーザーによるキャンセル"
						End If
					End If
				Else
					Exit Do
				End If
			Loop
		End If

		If LeadOrOpt.CommandReplace.Exists( key ) Then
			If IsNumeric( key ) Then  is_show_name = True
			key = LeadOrOpt.CommandReplace.Item( key )
			If LeadOrOpt.CommandReplace.Exists( key ) Then _
				key = LeadOrOpt.CommandReplace.Item( key )
		End If

		If not IsDefined( key ) Then
			If StrComp( key, LeadOrOpt.AllTestName, 1 ) = 0 Then
				keys = LeadOrOpt.CommandReplace.Items
				is_show_name = True
			Else
				If key <> "" Then
					s = "<ERROR msg="""+ key +" 関数がありません""/>"
					If g_InputCommand_Args.Count = 0 Then  echo  s  Else  Raise  E_NotFoundSymbol, s
				End If
				keys = Array( )
			End If
		Else
			keys = Array( key )
		End If

		For Each key  In keys
			If LeadOrOpt.CommandReplace.Exists( key ) Then _
				key = LeadOrOpt.CommandReplace.Item( key )

			If g_InputCommand_Args.Count = 0 Then  echo_line
			If is_show_name Then  echo  "  ((( ["& key &"] )))"

			If TryStart(e) Then  On Error Resume Next
				Set ds = new CurDirStack
				Set func = GetRef( key )
				func  Opt, AppKey
			If TryEnd Then  On Error GoTo 0
			If e.num <> 0  and  e.num <> E_TestPass Then
				echo  "InputCommand >> "+ key +" >> ERROR"
				echo  ""
				If g_InputCommand_Args.Count > 0 Then
					e.Raise
				Else
					echo  e.DebugHint()
				End If
			End If
			e.Clear
			ds = Empty
		Next

		If g_InputCommand_Args.Count > 0 Then  Exit Do
	Loop
End Sub


Class  InputCommandOpt
	Public  Lead  '// as string
	Public  CommandReplace  '// as Dictionary of string
	Public  MenuCaption     '// as Dictionary of string
	Public  AllTestName     '// as string

	Private Sub  Class_Initialize()
		Set Me.CommandReplace = CreateObject( "Scripting.Dictionary" )
		Set Me.MenuCaption    = CreateObject( "Scripting.Dictionary" )
		Me.AllTestName = "AllTest"
	End Sub
End Class


 
'***********************************************************************
'* Function: ChangeNumToCommandOrNot
'***********************************************************************
Function  ChangeNumToCommandOrNot( in_Key, in_CommandDictionary, in_NumName, in_IsInputNumOrCommand )
	key = in_Key
	If in_CommandDictionary.Exists( in_Key ) Then
		command_name = in_CommandDictionary( in_Key )
		If in_IsInputNumOrCommand Then
			Do
				echo  ""
				echo  in_Key +" は、"+ in_NumName +"ですか。それともコマンドですか。"
				echo  "  Enter のみ : "+ in_NumName
				echo  "  "+ in_Key +" : コマンド ["+ command_name +"]"
				key = Input( ">" )
				If key = "" Then
					key = in_Key
					Exit Do
				ElseIf key = in_Key Then
					key = command_name
					Exit Do
				End If
			Loop
		Else
			key = command_name
		End If
	End If
	ChangeNumToCommandOrNot = key
End Function


 
'***********************************************************************
'* Function: InputMenu
'*
'* Name Space:
'*    InputMenu
'***********************************************************************
Function  InputMenu( in_MenuDicTable, in_EmptyOption )
	Set variable = new LazyDictionaryClass

	For Each  menu_item  In  in_MenuDicTable
		If not IsEmpty( menu_item("Text") ) Then
			variable("${Name}") = menu_item("Name")
			echo  CStr( menu_item("Num") ) +". "+ variable( menu_item("Text") )
		End If
	Next

	Do
		key = Trim( Input( "番号またはコマンド名>" ) )
		echo_line

		For Each  menu_item  In  in_MenuDicTable
			If key = CStr( menu_item("Num") ) Then
				key = menu_item("Name")
				Exit For
			End If
		Next

		For Each  menu_item  In  in_MenuDicTable
			If key = CStr( menu_item("Name") ) Then
				InputMenu = key
				Exit Function
			End If
		Next
	Loop
End Function


 
'***********************************************************************
'* Function: Start_VBS_Lib_Settings
'***********************************************************************
Sub  Start_VBS_Lib_Settings()
	Do
		echo_line
		echo  "vbslib 外部プログラム設定"
		echo  ""
		echo  "以下のフォルダーとサブ フォルダーから起動したスクリプトに対する設定です。"
		echo  "    "+ g_fs.GetParentFolderName( g_vbslib_folder )
		echo  ""
		echo  "1. 設定ファイルを入れるフォルダーの一覧 [List]"
		echo  "2. フォルダーを開くプログラムの設定とテスト [Folder]"
		echo  "3. テキストファイルを開くプログラムの設定とテスト [Text]"
		echo  "4. テキストファイルを比較するプログラムの設定とテスト [Diff]"
		echo  "5. フォルダーを比較するプログラムの設定とテスト [DiffFolder]"
		echo  "9. 設定終了 [Exit]"
		key = Trim( Input( "番号またはコマンド名>" ) )
		echo_line
		Select Case  key
			Case "1": key = "List"
			Case "2": key = "Folder"
			Case "3": key = "Text"
			Case "4": key = "Diff"
			Case "5": key = "DiffFolder"
			Case "9": key = "Exit"
		End Select
		If StrComp( key, "List", 1 ) = 0 Then
			Set object = new VBS_LibToolSettingClass
			object.EchoSettingFolderPaths
			object = Empty
			echo  ""
			Pause
		ElseIf StrComp( key, "Folder", 1 ) = 0 Then
			RunOpenSettingOfFolder
		ElseIf StrComp( key, "Text", 1 ) = 0 Then
			RunOpenSettingOfText
		ElseIf StrComp( key, "Diff", 1 ) = 0 Then
			RunOpenSettingOfDiff
		ElseIf StrComp( key, "DiffFolder", 1 ) = 0 Then
			RunOpenSettingOfDiffFolder
		ElseIf StrComp( key, "Exit", 1 ) = 0 Then
			Exit Do
		End If
	Loop
End Sub


 
'***********************************************************************
'* Function: RunOpenSettingOfFolder
'***********************************************************************
Sub  RunOpenSettingOfFolder()
	test_scriptlib_path = g_vbslib_folder
	CutLastOf  test_scriptlib_path, "\", Empty

	Set  a_UI = new VBS_LibToolSettingClass
	a_UI.Description         = "フォルダーを開くツール"
	a_UI.SettingFileName     = "PC_setting.vbs"
	a_UI.SettingFunctionName = "Setting_openFolder"
	a_UI.Tests = DicTable( Array( _
		"Num",  "Name",  "Text",   Empty, _
		1, "Open", "フォルダーを開くテスト [${Name}]" ) )
	Do
		test_name = a_UI.Run()

		If TryStart(e) Then  On Error Resume Next

			If test_name = "Exit" Then
				Exit Do
			ElseIf test_name = "Open" Then
				OpenFolder  test_scriptlib_path
			End If

		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then
			echo_v  "Error 0x"+ Hex( e.num ) +": "+ e.Description
			e.Clear
		End If
	Loop
End Sub


 
'***********************************************************************
'* Function: RunOpenSettingOfText
'***********************************************************************
Sub  RunOpenSettingOfText()
	test_text_path = GetTempPath( "Test_PC_setting_default.vbs" )
	copy_ren  g_vbslib_ver_folder +"setting_default\PC_setting_default.vbs",  test_text_path


	Set  a_UI = new VBS_LibToolSettingClass
	a_UI.Description         = "テキスト ファイルを開くツール"
	a_UI.SettingFileName     = "PC_setting.vbs"
	a_UI.SettingFunctionName = "Setting_getEditorCmdLine"
	a_UI.Tests = DicTable( Array( _
		"Num",  "Name",  "Text",   Empty, _
		1, "Open", "テキスト ファイルを開くテスト [${Name}]", _
		2, "OpenLine", "10行目を開くテスト [${Name}]", _
		3, "OpenKeyword", "キーワード Setting_getEditorCmdLine を検索して開くテスト [${Name}]" ) )
	Do
		test_name = a_UI.Run()

		If TryStart(e) Then  On Error Resume Next

			If test_name = "Exit" Then
				Exit Do
			ElseIf test_name = "Open" Then
				command_line = GetEditorCmdLine( test_text_path )
				start  command_line
			ElseIf test_name = "OpenLine" Then
				command_line = GetEditorCmdLine( test_text_path +"(10)" )
				start  command_line
			ElseIf test_name = "OpenKeyword" Then
				command_line = GetEditorCmdLine( test_text_path +"#Setting_getEditorCmdLine" )
				start  command_line
			End If

		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then
			echo_v  "Error 0x"+ Hex( e.num ) +": "+ e.Description
			e.Clear
		End If
	Loop

	del  test_text_path
End Sub


 
'***********************************************************************
'* Function: RunOpenSettingOfDiff
'***********************************************************************
Sub  RunOpenSettingOfDiff()
	test_text_A_path = GetTempPath( "Test_VbsLib4_Include.txt" )
	test_text_B_path = GetTempPath( "Test_VbsLib5_Include.txt" )
	test_text_C_path = GetTempPath( "Test_VbsLib5_Include3.txt" )
	copy_ren  g_vbslib_ver_folder +"tools\VbsLib4_Include.txt",  test_text_A_path
	copy_ren  g_vbslib_ver_folder +"tools\VbsLib5_Include.txt",  test_text_B_path
	copy_ren  g_vbslib_ver_folder +"tools\VbsLib5_Include.txt",  test_text_B_path


	Set  a_UI = new VBS_LibToolSettingClass
	a_UI.Description         = "テキスト ファイルを比較する Diff ツール"
	a_UI.SettingFileName     = "PC_setting.vbs"
	a_UI.SettingFunctionName = "Setting_getDiffCmdLine"
	a_UI.Tests = DicTable( Array( _
		"Num",  "Name",  "Text",   Empty, _
		1, "Open", "テキスト ファイルを比較するテスト [${Name}]", _
		2, "OpenLine", "3行目と 5行目を開くテスト [${Name}]" ) )
	Do
		test_name = a_UI.Run()

		If TryStart(e) Then  On Error Resume Next

			If test_name = "Exit" Then
				Exit Do
			ElseIf test_name = "Open" Then
				command_line = GetDiffCmdLine( test_text_A_path,  test_text_B_path )
				start  command_line
			ElseIf test_name = "OpenLine" Then
				command_line = GetDiffCmdLine( test_text_A_path +"(3)",  test_text_B_path +"(5)" )
				start  command_line
			End If

		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then
			echo_v  "Error 0x"+ Hex( e.num ) +": "+ e.Description
			e.Clear
		End If
	Loop

	del  test_text_A_path
	del  test_text_B_path
End Sub


 
'***********************************************************************
'* Function: RunOpenSettingOfDiffFolder
'***********************************************************************
Sub  RunOpenSettingOfDiffFolder()
	test_folder_A_path = GetTempPath( "Test_setting_default" )
	test_folder_B_path = GetTempPath( "Test_setting" )
	test_folder_C_path = GetTempPath( "Test_setting3" )
	copy_ren  g_vbslib_ver_folder +"setting_default",  test_folder_A_path
	copy_ren  g_vbslib_ver_folder +"setting",          test_folder_B_path
	copy_ren  g_vbslib_ver_folder +"setting",          test_folder_C_path


	Set  a_UI = new VBS_LibToolSettingClass
	a_UI.Description         = "フォルダーを比較する Diff ツール"
	a_UI.SettingFileName     = "PC_setting.vbs"
	a_UI.SettingFunctionName = "Setting_getFolderDiffCmdLine"
	a_UI.Tests = DicTable( Array( _
		"Num",  "Name",  "Text",   Empty, _
		1, "Open", "フォルダーを比較するテスト [${Name}]" ) )
	Do
		test_name = a_UI.Run()

		If TryStart(e) Then  On Error Resume Next

			If test_name = "Exit" Then
				Exit Do
			ElseIf test_name = "Open" Then
				command_line = GetDiffCmdLine( test_folder_A_path,  test_folder_B_path )
				start  command_line
			ElseIf test_name = "Open3" Then
				command_line = GetDiffCmdLine( test_folder_A_path,  test_folder_B_path )
				start  command_line
			End If

		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then
			echo_v  "Error 0x"+ Hex( e.num ) +": "+ e.Description
			e.Clear
		End If
	Loop

	del  test_folder_A_path
	del  test_folder_B_path
	del  test_folder_C_path
End Sub


 
'***********************************************************************
'* Class: VBS_LibToolSettingClass
'***********************************************************************
Class  VBS_LibToolSettingClass
	Public  Description
	Public  SettingFileName
	Public  SettingFunctionName
	Public  Tests  '// dictionary of string. TestSymbol => Description
	Public  ScreenMode  '// as string
	Public  XML_Reader  '// as MultiTextXML_Class
	Public  RegExpOfFunctionName  '// RegExp


Private Sub  Class_Initialize()
	Set Me.XML_Reader = new MultiTextXML_Class
End Sub


 
'***********************************************************************
'* Method: GetSettingPaths
'*
'* Name Space:
'*    VBS_LibToolSettingClass::GetSettingPaths
'***********************************************************************
Function  GetSettingPaths()
	ReDim  paths(3)
	paths(0) = g_vbslib_ver_folder +"setting_default"
	paths(1) = g_sh.ExpandEnvironmentStrings( "%APPDATA%\Scripts" )
	paths(2) = g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\scriptlib\setting_mem" )
	paths(3) = g_vbslib_ver_folder +"setting"
	GetSettingPaths = paths
End Function


 
'***********************************************************************
'* Method: GetWritablePaths
'*
'* Name Space:
'*    VBS_LibToolSettingClass::GetWritablePaths
'***********************************************************************
Function  GetWritablePaths()
	ReDim  paths(2)
	paths(1) = g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\scriptlib\setting_mem" )
	If InStr( paths(1), "%" ) >= 1 Then _
		ReDim  paths(0)
	paths(0) = g_vbslib_ver_folder +"setting"
	GetWritablePaths = paths
End Function


 
'***********************************************************************
'* Method: EchoSettingFolderPaths
'*
'* Name Space:
'*    VBS_LibToolSettingClass::EchoSettingFolderPaths
'***********************************************************************
Sub  EchoSettingFolderPaths()
	paths = Me.GetSettingPaths()

	echo  "次のフォルダーの中にある設定ファイルに設定関数を記述してください。"
	echo  ""
	echo  " 1. vbslib のデフォルト設定（変更しないでください）："
	echo  "  "+ paths(0)
	echo  ""
	echo  " 2. PC 全体の設定："
	echo  "  "+ paths(1)
	echo  ""
	echo  " 3. USB メモリーに入っている PC 全体の設定："
	echo  "  "+ paths(2)
	If g_sh.ExpandEnvironmentStrings( "%myhome_mem%" ) = "%myhome_mem%" Then _
		echo  "  環境変数 %myhome_mem% は設定されていません。"
	echo  ""
	echo  " 4. フォルダーごとの設定："
	echo  "  "+ paths(3)
	echo  ""
	echo  " 5.（スクリプト内部で include した設定ファイル）"
	echo  ""
	echo  " 数字が大きいほど優先されます。"
End Sub


 
'***********************************************************************
'* Method: InputSettingFolderPath
'*
'* Name Space:
'*    VBS_LibToolSettingClass::InputSettingFolderPath
'***********************************************************************
Function  InputSettingFolderPath( in_SettingFunctionName )
	paths = Me.GetSettingPaths()

	'// Set "exist_mark"
	ReDim  exist_mark(3)
	For i=0 To UBound( exist_mark )
		If i = 0 Then
			file_name = AddLastOfFileName( Me.SettingFileName, "_default" )
		Else
			file_name = Me.SettingFileName
		End If
		If InStr( ReadFile( paths(i) +"\"+ file_name ),  in_SettingFunctionName ) >= 1 Then
			exist_mark(i) = "*"
		Else
			exist_mark(i) = " "
		End If
	Next

	echo  "設定を格納するフォルダーを次から選んでください。"
	echo  "なお、PC 全体の設定をするファイルに変更を加えるときは警告されますので、"+ _
		"警告内容を確認してください。 行頭の * がある設定は、設定ファイルに設定関数が存在します。"
	echo  ""
	echo  exist_mark(0) +"1. vbslib のデフォルト設定（変更しないでください）："
	echo  "  "+ paths(0)
	echo  ""
	echo  exist_mark(1) +"2. PC 全体の設定 [PC]："
	echo  "  "+ paths(1)
	echo  ""
	echo  exist_mark(2) +"3. USB メモリーに入っている PC 全体の設定 [Mem]："
	echo  "  "+ paths(2)
	If g_sh.ExpandEnvironmentStrings( "%myhome_mem%" ) = "%myhome_mem%" Then _
		echo  "  環境変数 %myhome_mem% は設定されていません。"
	echo  ""
	echo  exist_mark(3) +"4. フォルダーごとの設定 [Local]："
	echo  "  "+ paths(3)
	echo  ""
	echo  " 数字が大きいほど優先されます。"
	echo  ""
	echo  "Enter のみ：戻る"
	Do
		key = Trim( Input( "番号または [] の中の名前>" ) )
		echo_line
		If key = "" Then _
			Exit Do

		Select Case  key
			Case "1": key = "Default"
			Case "2": key = "PC"
			Case "3": key = "Mem"
			Case "4": key = "Local"
		End Select
		If StrComp( key, "Default", 1 ) = 0 Then
			InputSettingFolderPath = paths(0)
			Exit Do
		ElseIf StrComp( key, "PC", 1 ) = 0 Then
			InputSettingFolderPath = paths(1)
			Exit Do
		ElseIf StrComp( key, "Mem", 1 ) = 0 Then
			InputSettingFolderPath = paths(2)
			Exit Do
		ElseIf StrComp( key, "Local", 1 ) = 0 Then
			InputSettingFolderPath = paths(3)
			Exit Do
		End If
	Loop
End Function


 
'***********************************************************************
'* Method: Run
'*
'* Name Space:
'*    VBS_LibToolSettingClass::Run
'***********************************************************************
Function  Run()
	Set Me.RegExpOfFunctionName = new_RegExp( "(Sub|Function) +"+ Me.SettingFunctionName +" *\(", False )

	Do
		If Me.ScreenMode = "Test" Then
			key = "Test"
		Else
			echo  Me.Description +" の設定（"+ Me.SettingFunctionName +" 関数）"
			echo  ""
			echo  "現在の設定は、以下のファイルにあります。 下のほうにあるファイルの設定が優先されます。"

			setting_paths = Me.GetExistSettinsPaths()
			If UBound( setting_paths ) >= 0 Then
				For Each  path  In  setting_paths
					echo  path
				Next
			Else
				echo  "設定は見つかりません。"
			End If

			echo  ""
			echo  "1. 設定する [Set]"
			echo  "2. テストする [Test]"
			echo  "9. 戻る [Exit]"
			key = Trim( Input( "番号またはコマンド名>" ) )
			echo_line

			Select Case  key
				Case "1": key = "Set"
				Case "2": key = "Test"
				Case "9": key = "Exit"
			End Select
		End If

		If StrComp( key, "Set", 1 ) = 0 Then

			folder_path = Me.InputSettingFolderPath( Me.SettingFunctionName )
			If folder_path <> "" Then
				default_file_name = AddLastOfFileName( Me.SettingFileName, "_default" )
				default_file_path = folder_path +"\"+ default_file_name
				file_path = folder_path +"\"+ Me.SettingFileName
				If exist( default_file_path )  and  exist( file_path ) Then
					echo_v  "<WARNING msg=""同じフォルダーに設定ファイルとそのデフォルトのファイルを入れないでください。"+ _
						"""  folder="""+ folder_path +"""  setting="""+ file_path +"""  default="""+ _
						default_file_name +"""/>"
				End If

				If exist( default_file_path ) Then
					echo  "デフォルトの設定は、vbslib の提供者以外は、編集しないでください。"
					Pause
					file_path = default_file_path
				Else

					text = ReadFile( file_path )

					If  NOT  Me.RegExpOfFunctionName.Test( text ) Then

						text = text + vbCRLF + Me.XML_Reader.GetText( _
							g_vbslib_ver_folder +"tools\SettingTemplate.xml#"+ Me.SettingFunctionName )

						CreateFile  file_path,  text
						echo  ""
						echo  "新規作成しました。"
						Sleep  500
					End If

					echo  "設定ファイル（スクリプト）を開きます。 編集したら保存してテストしてください。"
					Pause
				End If


				start  GetEditorCmdLine( file_path +"#"+ Me.SettingFunctionName )


				Me.ScreenMode = "Test"
			End If

		ElseIf StrComp( key, "Test", 1 ) = 0 Then
			If Me.ScreenMode = "Test" Then _
				echo_line
			Me.ScreenMode = Empty

			menu_items = Me.Tests
			AddArrElem  menu_items,  DicTable( Array( _
				"Num",  "Name",  "Text",   Empty, _
				9, "Exit", "戻る [${Name}]", _
				Empty, "", Empty ) )


			Run = InputMenu( menu_items, Empty )


			If Run = ""  or  Run = "Exit"  Then
				'// Change to parent menu
			Else
				Me.Refresh
				Me.ScreenMode = "Test"
				Exit Function
			End If

		ElseIf StrComp( key, "Exit", 1 ) = 0 Then
			Run = "Exit"
			Exit Function
		End If
	Loop
End Function


 
'***********************************************************************
'* Method: GetExistSettinsPaths
'*
'* Name Space:
'*    VBS_LibToolSettingClass::GetExistSettinsPaths
'***********************************************************************
Function  GetExistSettinsPaths()
	paths = Me.GetSettingPaths()

	ReDim  exist_paths( UBound( paths ) )
	count = 0
	For i=0 To UBound( paths )
		path = paths(i) +"\"+ Me.SettingFileName
		text = ReadFile( path )
		If text = "" Then
			path = AddLastOfFileName( path, "_default" )
			text = ReadFile( path )
		End If

		Set matches = Me.RegExpOfFunctionName.Execute( text )
		If matches.Count >= 1 Then
			exist_paths( count ) = path
			count = count + 1
		End If
	Next
	ReDim Preserve  exist_paths( count - 1 )
	GetExistSettinsPaths = exist_paths
End Function


 
'***********************************************************************
'* Method: Refresh
'*
'* Name Space:
'*    VBS_LibToolSettingClass::Refresh
'***********************************************************************
Sub  Refresh()
	setting_paths = Me.GetExistSettinsPaths()
	For Each  path  In  setting_paths
		include  path
	Next
End Sub


 
	'// GetExistPathInSetting の verbose 表示
End Class

'* Section: Global


 
'*************************************************************************
'  <<< [SendKeys] Send keyboard code stroke to OS >>> 
'*************************************************************************
Sub  SendKeys( ByVal window_title, ByVal keycords, ByVal late_time )
	WScript.Sleep late_time
	If window_title <> "" Then
		If not g_sh.AppActivate( window_title ) Then _
			Raise E_NotFoundSymbol, "<ERROR msg='ウィンドウ・タイトルが見つかりません' title='"& window_title &"'/>"
	End If
	WScript.Sleep 100
	g_sh.SendKeys keycords
End Sub


 
'*-------------------------------------------------------------------------*
'* ### <<<< [CUI] Class >>>> 
'*-------------------------------------------------------------------------*

Class  CUI

	Public  m_Auto_InputFunc    ' as string of auto input function name
	Public  m_Auto_Src          ' as string of path
	Public  m_Auto_Keys         ' as string of auto input keys
	Public  m_Auto_KeyEnter     ' as string of the character of replacing to enter key
	Public  m_Auto_DebugCount   ' as integer


 
'*************************************************************************
'  <<< [CUI::Class_Initialize] >>> 
'*************************************************************************
Private Sub Class_Initialize
	Me.m_Auto_Keys = ""
	Me.m_Auto_KeyEnter = "."
	Me.m_Auto_DebugCount = Empty
End Sub


 
'*************************************************************************
'  <<< [CUI::input] >>> 
'*************************************************************************
Public Function  input( ByVal msg )
	input = input_sub( msg,  not IsEmpty( GetWScriptArgumentsNamed("GUI_input") ) )
End Function

Public Function  input_sub( ByVal msg, bGUI_input )
	Dim e, en, ed
	Dim InputFunc

	en = Err.Number : ed = Err.Description

	If not IsEmpty( g_EchoObj.m_Buf ) Then _
		msg = g_EchoObj.m_Buf + vbCRLF + msg
	g_EchoObj.m_Buf = Empty
	g_EchoObj.m_BufN = 0

	If ( msg = g_PauseMsg ) and ( not IsEmpty( m_Auto_Keys ) ) and ( m_Auto_Keys <> "" ) Then
		'// Owner process does not wait in EchoStream
		Me.StdOut_Write  Left( g_PauseMsg, g_PauseMsgStone )+"*"+Chr(8)+_
		                       Mid( g_PauseMsg, g_PauseMsgStone+1 )
	Else
		If g_CommandPrompt <> 0 Then _
			Me.StdOut_Write  msg
	End If

	On Error Resume Next

	If ( not IsEmpty( m_Auto_Keys ) ) and ( m_Auto_Keys <> "" ) Then
		If Not IsEmpty( m_Auto_KeyEnter ) Then
			e = InStr( m_Auto_Keys, m_Auto_KeyEnter )
			If e = 0 Then
				input_sub = m_Auto_Keys
				m_Auto_Keys = Empty
			Else
				input_sub = Left( m_Auto_Keys, e - 1 )
				m_Auto_Keys = Mid( m_Auto_Keys, e + 1 )
			End If
		Else
			input_sub = m_Auto_Keys
			m_Auto_Keys = Empty
		End If

		If IsEmpty( m_Auto_DebugCount ) Then
			Me.StdOut_WriteLine  input_sub
		ElseIf  m_Auto_DebugCount > 1 Then
			Me.StdOut_WriteLine  input_sub
			m_Auto_DebugCount = m_Auto_DebugCount - 1
		Else
			Me.StdOut_Write  input_sub
			If bGUI_input Then
				input_sub = InputBox( msg, WScript.ScriptName, "" )
				Me.StdOut_WriteLine  input_sub
			Else
				input_sub = StdIn_ReadLine_ForJP()
			End If
			Me.StdOut_WriteLine ""
		End If

	ElseIf IsEmpty( m_Auto_InputFunc ) Then
		If bGUI_input or ( g_CommandPrompt = 0 ) Then
			input_sub = InputBox( msg, WScript.ScriptName, "" )
			If g_CommandPrompt <> 0 Then _
				Me.StdOut_WriteLine  input_sub
		Else
			input_sub = StdIn_ReadLine_ForJP()
		End If
	Else
		If IsEmpty( m_Auto_Src ) Then
			Set InputFunc = GetRef( m_Auto_InputFunc )
			If Err.Number = 5 Then Me.StdOut_WriteLine vbCR+vbLF+"Not found function of """+_
				m_Auto_InputFunc +"""": Err.Clear
			If Not IsEmpty( InputFunc ) Then  input_sub = InputFunc( msg )
		Else
			input_sub = call_vbs_t( m_Auto_Src, m_Auto_InputFunc, msg )
			If Err.Number = 5 Then Me.StdOut_WriteLine vbCR+vbLF+"Not found function of """+_
				m_Auto_InputFunc +""" in """+m_Auto_Src+"""" : Err.Clear
			If IsEmpty( input_sub ) Then  Me.StdOut_Write  msg : input_sub = StdIn_ReadLine_ForJP()
		End If
	End If

	e = Err.Number : Err.Clear : On Error GoTo 0
	If e <> 0 Then
		If e <> 62 Then Err.Raise e  '62= End Of File (StdIn, ^C)
		Stop:WScript.Quit 1
	End If

	'//=== resume err
	If en <> 0 Then  On Error Resume Next : Err.Raise  en,, ed  '// : On Error GoTo 0
		'// This comment out means not clear Err.Number
End Function


 
'*************************************************************************
'  <<< [CUI::StdOut_Write] >>> 
'*************************************************************************
Public Sub  StdOut_Write( message )
	If m_Auto_Keys = "" Then
		is_show = True
	Else
		is_show = not g_EchoObj.m_bEchoOff
	End If

	If g_is_vbslib_for_fast_user Then
	Else
		is_show = True
	End If

	If is_show Then _
		WScript.StdOut.Write  message
End Sub


 
'*************************************************************************
'  <<< [CUI::StdOut_WriteLine] >>> 
'*************************************************************************
Public Sub  StdOut_WriteLine( message )
	Me.StdOut_Write  message + vbCRLF
End Sub


 
'*************************************************************************
'  <<< [CUI::SetAutoKeysFromMainArg] >>> 
'*************************************************************************
Public Sub  SetAutoKeysFromMainArg()
	If not IsEmpty( Me.m_Auto_Keys ) and Me.m_Auto_Keys = "" Then
		Me.m_Auto_Keys = GetWScriptArgumentsNamed("set_input")
		Me.m_Auto_KeyEnter = GetWScriptArgumentsNamed("set_input_enter")
		If IsEmpty( Me.m_Auto_KeyEnter ) Then  Me.m_Auto_KeyEnter = "."
		Me.m_Auto_DebugCount = GetWScriptArgumentsNamed("set_input_debug")
	End If
End Sub


 
End Class 


 
'*************************************************************************
'  <<< [StdIn_ReadLine_ForJP] >>> 
'*************************************************************************
Function  StdIn_ReadLine_ForJP()
	Dim  r, i, a
	Const  msg1 = "コマンドプロンプトや InputBox では、254文字以上は入りません。"
	Const  msg2 = "コマンドプロンプトでは、英文字以外の場合、128文字以上は入りません。"
	Const  msg3 = "もう一度入力してください。"

	Do
		r = WScript.StdIn.ReadLine()

		If Len( r ) >= 254 Then
			WScript.StdOut.WriteLine  msg1
			WScript.StdOut.Write  msg3 + ">"
		ElseIf Len( r ) > 128 Then
			For i=1 To 128
				a = Asc( Mid( r, i, 1 ) )
				If a < 0 or a > 127 Then
					r = InputBox( msg2+msg3, WScript.ScriptName )
					While  Len( r ) >= 254
						r = InputBox( msg1+msg3, WScript.ScriptName )
					WEnd
					WScript.StdOut.Write  msg3 +">"+ r +vbCRLF
					Exit For
				End If
			Next
			Exit Do
		Else
			Exit Do
		End If
	Loop

	StdIn_ReadLine_ForJP = r
End Function


 
'*************************************************************************
'  <<< [GetTextFromClipboard] >>> 
'*************************************************************************
Function  GetTextFromClipboard()
	Dim  ec: Set ec = new EchoOff
	Dim  temp_path : temp_path = GetPathOfClipboardText()
	GetTextFromClipboard = ReadFile( temp_path )
	del  temp_path
End Function


 
'*************************************************************************
'  <<< [GetPathOfClipboardText] >>> 
'*************************************************************************
Function  GetPathOfClipboardText()
	Dim  temp_path : temp_path = GetTempPath( "clip_*.txt" )
	Dim  r
	Dim  ec: Set ec = new EchoOff

	AssertExist  g_vbslib_ver_folder +"vbslib_helper.exe"
	mkdir_for  temp_path
	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" GetTextFromClipboard /Out:"""+_
		temp_path +"""", "" )
	If r = &h415 Then  Raise E_BadType, "クリップボードにテキストがありません"
	Assert  r = 0

	GetPathOfClipboardText = temp_path
End Function


 
'*************************************************************************
'  <<< [SetTextToClipboard] >>> 
'*************************************************************************
Sub  SetTextToClipboard( Text )
	Dim  temp_path : temp_path = GetTempPath( "clip_*.txt" )
	Dim  r
	Dim  ec: Set ec = new EchoOff

	AssertExist  g_vbslib_ver_folder +"vbslib_helper.exe"

	CreateFile  temp_path, Text
	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" SetTextToClipboard /In:"""+_
		temp_path +"""", "" )
	Assert  r = 0
	del  temp_path
End Sub


 
'*************************************************************************
'  <<< [EditAndRunScript] >>> 
'*************************************************************************
Sub  EditAndRunScript( ByVal ScriptPath, IsKeepThisProcessIfRun )
	If IsEmpty( ScriptPath ) Then  ScriptPath = WScript.ScriptFullName
	ScriptPath = GetFullPath( ScriptPath, Empty )
	echo  ">EditAndRunScript """ + ScriptPath + """"

	RunProg  GetEditorCmdLine( ScriptPath ), ""

	Dim  folder : folder = g_fs.GetParentFolderName( ScriptPath )
	Dim  file_name : file_name = g_fs.GetFileName( ScriptPath )

	If MsgBox( "今閉じたスクリプトを実行します。"+ vbCRLF+vbCRLF +_
		file_name +vbCRLF+vbCRLF +"フォルダー： "+ folder,_
		vbOKCancel, g_fs.GetFileName( ScriptPath ) ) = vbCancel Then _
			Exit Sub

	g_sh.Run  "wscript.exe //nologo """+ScriptPath+""""
	If not IsKeepThisProcessIfRun Then  WScript.Quit  21
End Sub


 
'*-------------------------------------------------------------------------*
'* ### <<<< File >>>> 
'*-------------------------------------------------------------------------*


 
'-------------------------------------------------------------------------
' ### <<<< [AppKeyClass] Class >>>> 
'-------------------------------------------------------------------------
Const  F_AskIfWarn = 0
Const  F_ErrIfWarn = 1
Const  F_IgnoreIfWarn = 2

Class  AppKeyClass
	Private  m_Key
	Private  m_bAppKey
	Private  m_WritableMode  ' as Flags
	Private  m_PlusWritables()

	Private Sub Class_Initialize()
		m_WritableMode = F_AskIfWarn
		ReDim  m_PlusWritables(-1)
	End Sub

	Public Function  SetKey( Key )
		If not IsEmpty( m_Key ) Then  Err.Raise 1,,"Double Key"
		Set m_Key = Key
		Key.SetKey_sub  Me
		Set SetKey = Key
	End Function
	Public Sub  SetKey_sub( Key )
		Dim  b, pathes

		If not IsEmpty( m_Key ) Then  Err.Raise 1,,"Double Key"
		m_bAppKey = ( Key Is g_AppKey )
		Set m_Key = Key

		b=( IsArray( g_debug_process ) )  'or
		If not b Then  b=( g_debug_process > 0 )
		If (g_is_debug  or g_debug = -1  or  b ) _
				and  IsDefined( "SetupDebugTools" ) Then
			Dim  mode_bk : mode_bk = m_WritableMode : m_WritableMode = F_IgnoreIfWarn
			SetupDebugTools
			m_WritableMode = mode_bk
		End If

		Set pathes = new ArrayClass
		pathes.Add  g_TempFile.m_FolderPath + "\"
		g_CurrentWritables.PushPathes  Me, pathes
	End Sub

	Public Function  IsSame( Key )
		IsSame = ( m_Key Is Key ) and Key.IsSame_sub( Me )
	End Function
	Public Function  IsSame_sub( Key )
		IsSame_sub = ( m_Key Is Key )
	End Function

	Public Sub  CheckGlobalAppKey()
		If not m_bAppKey Then _
			MsgBox "[ERROR] This is not AppKey from main2"
		If not IsSame( g_AppKey ) Then _
			MsgBox "[ERROR] g_AppKey was overrided by unknown"
	End Sub
	Private Sub  Class_Terminate()
		If m_bAppKey Then  CheckGlobalAppKey
	End Sub


 
'*************************************************************************
'  <<< [AppKeyClass::NewWritable] >>> 
'*************************************************************************
Public Function  NewWritable( in_Pathes )
	Me.CheckGlobalAppKey
	Dim  m : Set m = new Writables : ErrCheck
	m.SetPathes  Me, in_Pathes
	Set  NewWritable = m
End Function


 
'*************************************************************************
'  <<< [AppKeyClass::SetWritableMode] >>> 
'*************************************************************************
Public Sub  SetWritableMode( in_Flags )
	If g_AppKey Is Me Then
		If in_Flags = F_IgnoreIfWarn Then
			Err.Raise  1
		Else
			m_Key.SetWritableMode( in_Flags )
			Exit Sub
		End If
	End If

	Select Case  in_Flags
		Case  F_AskIfWarn : echo  ">SetWritableMode  F_AskIfWarn"
		Case  F_ErrIfWarn : echo  ">SetWritableMode  F_ErrIfWarn"
		Case  F_IgnoreIfWarn:echo ">SetWritableMode  F_IgnoreIfWarn"
		Case Else : Err.Raise  1
	End Select

	m_WritableMode = in_Flags
End Sub

Public Function  GetWritableMode()
	If g_AppKey Is Me Then
		GetWritableMode = m_Key.GetWritableMode()
	Else
		GetWritableMode = m_WritableMode
	End If
End Function


 
'*************************************************************************
'  <<< [AppKeyClass::CheckWritable] >>> 
'*************************************************************************
Public Sub  CheckWritable( in_Path,  in_Option )
	Dim  full_path, plus_path, b, i

	If g_AppKey Is Me Then
		m_Key.CheckWritable  in_Path,  in_Option
		Exit Sub
	End If

	If g_debug_or_test Then _
		g_AppKey.BreakByPath  in_Path


	'//=== If the folder in writable folder, Exit Sub
	'// If InStr( in_Path, "sub1\sub2" ) > 0 Then  Stop  '// for debug
	full_path = g_CurrentWritables.CheckWritablePart( in_Path,  in_Option )
	If IsEmpty( full_path ) Then _
		Exit Sub  '// Checked

	full_path = Me.CheckPlusWritablePart( full_path )
	If IsEmpty( full_path ) Then _
		Exit Sub  '// Checked


	'//=== Ask to add "plus writable"
	If not g_CurrentWritables.CanPlusNoAsk( full_path,  in_Option,  plus_path ) Then  '// Set "plus_path"
		plus_path = full_path
		Me.Ask  plus_path, Empty
	End If


	'//=== add "plus writable"
	If Right( plus_path, 2 ) = "\." Then
		plus_path = Left( plus_path, Len( plus_path ) - 1 )
	ElseIf Right( plus_path, 1 ) <> "\" Then
		plus_path = plus_path + "\"
	End If
	ReDim Preserve  m_PlusWritables( UBound( m_PlusWritables ) + 1 )
	m_PlusWritables( UBound( m_PlusWritables ) ) = plus_path

End Sub


 
'*************************************************************************
'  <<< [AppKeyClass::CheckPlusWritablePart] >>> 
'*************************************************************************
Public Function  CheckPlusWritablePart( in_FullPath )
	Dim  writable,  full_path

	If Me is g_AppKey Then
		CheckPlusWritablePart = m_Key.CheckPlusWritablePart( in_FullPath )
		Exit Function
	End If

	full_path = in_FullPath
	If Right( full_path, 2 ) <> "\." Then  full_path = full_path + "\."

	For Each  writable  In  m_PlusWritables
		If StrComp( writable, Left( full_path, Len( writable ) ), 1 ) = 0 Then  Exit Function
	Next
	CheckPlusWritablePart = in_FullPath
End Function


 
'*************************************************************************
'  <<< [AppKeyClass::Ask] >>> 
'*************************************************************************
Public Sub  Ask( in_CheckingPath,  in_Message )
	If Me is g_AppKey Then
		m_Key.Ask  in_CheckingPath,  in_Message
		Exit Sub
	End If

	Dim  s, msg2
	If IsEmpty( in_Message ) Then
		msg2 = "" : If exist( in_CheckingPath ) Then  msg2 = "Cannot overwrite, "
	Else
		msg2 = in_Message +", "
	End If

	Dim  writable
	For Each writable  In g_CurrentWritables.CurrentPathes

		If Right( writable, 3 ) = "\*\" Then  '// Case of last "\*"
			If Left( writable, Len(writable) - 2 ) = Left( in_CheckingPath, Len( writable ) - 2 ) or _
				 Left( writable, Len(writable) - 3 ) = in_CheckingPath Then
				If g_fs.FileExists( in_CheckingPath ) Then
					msg2 = "Cannot overwrite NOT NEW file, "
				Else
					msg2 = "Cannot overwrite NOT NEW folder, "
				End If
			End If
		End If
	Next

	If m_WritableMode <> F_ErrIfWarn Then
		echo_v  Me.GetWarningMessage( msg2, in_CheckingPath )
	End If

	If m_WritableMode = F_AskIfWarn Then
		Do
			echo_flush
			If g_CommandPrompt = 0 Then
				unique_mesaage = _
					"直前のウィンドウに表示した Requested タグの中のパスにファイルを出力します。"
			Else
				unique_mesaage = _
					"コマンドプロンプトに表示した Requested タグの中のパスにファイルを出力します。"
			End If
			s = InputBox( unique_mesaage & " 確認してください。" & vbCRLF & _
				"(Y) はい。そのファイルの出力を許可します" & vbCRLF & "(A) 以後、どんなパスでも許可" & vbCRLF & _
				"(N) いいえ。プログラムを終了します" & vbCRLF & "(R) パスをもう一度表示します", _
				"[WARNING] " +msg2+ "Out of Writable", "Y" )

			If s="Y" or s="y" Then
				Exit Do
			ElseIf s="A" or s="a" Then
				If MsgBox( "システムが壊れたり、データが失われる可能性があります。 よろしいですか。", _
						vbYesNo + vbDefaultButton2, "WARNING" ) = vbNo Then
					Me.Raise  "Out of Writable """ & in_CheckingPath & """"
				End If
				SetWritableMode  F_IgnoreIfWarn
				Exit Do
			ElseIf s="R" or s="r" Then
				MsgBox  in_CheckingPath, vbOKOnly, "[WARNING] Out of Writable"
			Else
				Me.Raise  "Out of Writable """ & in_CheckingPath & """"
			End If
		Loop
	End If

	If m_WritableMode = F_ErrIfWarn Then
		echo_v  Me.GetWarningMessage( msg2, CheckPath )
		Me.Raise  msg2+"Out of Writable """ & in_CheckingPath & """"
	End If
End Sub


 
'*************************************************************************
'  <<< [AppKeyClass::Raise] >>> 
'*************************************************************************
Public Sub  Raise( in_Message )
	If Err.Number = 0 Then
		Err.Raise  E_OutOfWritable,, in_Message
			' Watch  g_CurrentWritables.CurrentPathes and Path (CheckPath)
			' or call "g_AppKey.Watch"
	Else
		Err.Raise  Err.Number, Err.Source, Err.Description
	End If
End Sub


 
'*************************************************************************
'  <<< [AppKeyClass::InPath] >>> 
'*************************************************************************
Public Function  InPath( in_CheckingPathes,  in_WritablePathes )
	If TypeName( in_CheckingPathes ) = "ArrayClass" Then
		InPath = InPath( in_CheckingPathes.Items,  in_WritablePathes )
		Exit Function
	End If
	If TypeName( in_WritablePathes ) = "ArrayClass" Then
		InPath = InPath( in_CheckingPathes,  in_WritablePathes.Items )
		Exit Function
	End If

	Dim  c, w, b, cs, ws

	'// Change "in_CheckingPathes" to full path
	If IsArray( in_CheckingPathes ) Then
		ReDim  cs( UBound( in_CheckingPathes ) )
		For i=0 To UBound( cs )
			cs(i) = g_fs.GetAbsolutePathName( in_CheckingPathes(i) ) + "\"
		Next
	Else
		ReDim cs(0)
		cs(0) = g_fs.GetAbsolutePathName( in_CheckingPathes ) + "\"
	End If


	'// Change "in_WritablePathes" to full path
	If IsArray( in_WritablePathes ) Then
		ReDim  ws( UBound( in_WritablePathes ) )
		For i=0 To UBound( ws )
			ws(i) = g_fs.GetAbsolutePathName( in_WritablePathes(i) ) + "\"
		Next
	Else
		ReDim ws(0)
		ws(0) = g_fs.GetAbsolutePathName( in_WritablePathes ) + "\"
	End If


	'// Compare paths
	For Each c  In cs
		b = False
		For Each w  In ws
			If Left( c, Len(w) ) = w Then  b = True : Exit For
		Next
		If not b Then  InPath = False : Exit Function
	Next
	InPath = True
End Function


 
'*************************************************************************
'  <<< [AppKeyClass::BreakByPath] >>> 
'*************************************************************************
Public Sub  BreakByPath( Path )
	If IsEmpty( g_BreakByPath ) Then _
		Exit Sub
	If  NOT  StrComp( g_BreakByPath, _
			Right( g_fs.GetAbsolutePathName( Path ), Len( g_BreakByPath ) ), _
			vbTextCompare ) = 0 Then _
		Exit Sub

	g_BrokenCountByPath = g_BrokenCountByPath + 1
	echo_v  "Break by """+ g_BreakByPath +""" ("+ CStr( g_BrokenCountByPath ) +")"
	If IsEmpty( g_BreakCountByPath )  or  g_BrokenCountByPath >= g_BreakCountByPath Then _
		Stop  '// Look at caller function
End Sub


 
'*************************************************************************
'  <<< [AppKeyClass::BreakByWildcard] >>> 
'*************************************************************************
Public Sub  BreakByWildcard( Path, Flags )
	Dim  folder, fnames()
	Dim  fname

	If IsEmpty( g_BreakByPath ) Then  Exit Sub

	ExpandWildcard  Path, Flags, folder, fnames
	For Each fname in fnames
		If StrComp( g_BreakByPath, g_fs.GetFileName( fname ), vbTextCompare ) = 0 Then
			g_BrokenCountByPath = g_BrokenCountByPath + 1

			echo_v  "Break by """+ g_BreakByPath +""" ("+ CStr( g_BrokenCountByPath ) +")"
			Stop  '// Look at caller function
		End If
	Next
End Sub


 
'*************************************************************************
'  <<< [AppKeyClass::GetWarningMessage] >>> 
'*************************************************************************
Public Function  GetWarningMessage( msg2, CheckPath )

	s = ""

	If Err.Number <> 0 Then
		s=s+ vbCRLF + GetErrStr( Err.Number, Err.Description ) + vbCRLF + vbCRLF +_
			"以下の書き込みは途中までの可能性があります。" + vbCRLF
	End If

	s=s+ "<Warning msg=""" +msg2+ "Out of Writable, see the help of SetWritableMode."">"+vbCRLF

	For Each writable  In g_CurrentWritables.CurrentPathes
		s=s+ "  <Writable path="""+ Left( writable, Len( writable ) - 1 ) +"""/>"+vbCRLF
	Next
	For Each writable  In m_PlusWritables
		s=s+ "  <PlusWritable path="""+ Left( writable, Len( writable ) - 1 ) +"""/>"+vbCRLF
	Next

	s=s+ vbCRLF+vbCRLF +"  <Requested path=""" & CheckPath & """/>"+vbCRLF


	GetWarningMessage = s+ "</Warning>"
End Function


 
'*************************************************************************
'  <<< [AppKeyClass::Watch] >>> 
'*************************************************************************
Public Sub  Watch()
	If g_AppKey Is Me Then  m_Key.Watch : Exit Sub

	echo  Me.GetWarningMessage( "Watch of ", "" )
End Sub

 
End Class 


 
'*************************************************************************
'  <<< [CurrentWritables] Class >>> 
'*************************************************************************
Class  CurrentWritables
	Private  Me_PathesStack ' as ArrayClass of ArrayClass

	Private  Me_ProgramFiles
	Private  Me_windir
	Private  Me_APPDATA
	Private  Me_LOCALAPPDATA

	Public Property Get  CurrentPathes()
		If Me_PathesStack.Count > 0 Then
			CurrentPathes = Me_PathesStack( Me_PathesStack.Count-1 ).Items
		Else
			CurrentPathes = Me_PathesStack.Items
		End If
	End Property
	Public Property Get  PathesStack : Set PathesStack = Me_PathesStack : End Property


	Private Sub  Class_Initialize()
		Set  Me_PathesStack = new ArrayClass : ErrCheck

		Me_ProgramFiles = g_sh.ExpandEnvironmentStrings( "%ProgramFiles%" )
		Me_windir       = g_sh.ExpandEnvironmentStrings( "%windir%" )
		Me_APPDATA      = g_sh.ExpandEnvironmentStrings( "%APPDATA%" )
		Me_LOCALAPPDATA = g_sh.ExpandEnvironmentStrings( "%LOCALAPPDATA%" )

		If Me_ProgramFiles = "%ProgramFiles%" Then  Me_ProgramFiles = Empty
		If Me_windir       = "%windir%"       Then  Me_windir       = Empty
		If Me_APPDATA      = "%APPDATA%"      Then  Me_APPDATA      = Empty
		If Me_LOCALAPPDATA = "%LOCALAPPDATA%" Then  Me_LOCALAPPDATA = Empty
	End Sub


	Public Sub  PushPathes( in_AppKey,  in_Pathes )
		Dim  i
		If not g_AppKey.IsSame( in_AppKey ) Then _
			Err.Raise 1,, "Invalied AppKey"
		Dim  new_pathes : Set new_pathes = new ArrayClass : ErrCheck
		new_pathes.Copy  in_Pathes
		Me_PathesStack.Push  new_pathes
	End Sub


	Public Sub  PopPathes( in_AppKey,  in_Pathes )
		Dim  i,j

		If not g_AppKey.IsSame( in_AppKey ) Then _
			Err.Raise 1,, "Invalied AppKey"

		For i = Me_PathesStack.Count - 1  To  0  Step  -1
			If in_Pathes.Count = Me_PathesStack(i).Count Then
				For j=0 To in_Pathes.Count-1
					If in_Pathes(j) <> Me_PathesStack(i)(j) Then  Exit For
				Next
				If j = in_Pathes.Count Then _
					Exit For  '// If same all "in_Pathes"
			End If
		Next
		If i = -1 Then  Err.Raise 1

		For i=i To Me_PathesStack.Count-2
			Set Me_PathesStack(i) = Me_PathesStack(i+1)
		Next
		Me_PathesStack.Pop
	End Sub


	Public Function  CheckWritablePart( in_Path,  in_Option )
	'// return value = Empty(=Pass), full path out of writable
		Dim  full_path,  writable,  s
		If IsFullPath( in_Path ) Then

			If g_TempFile.m_FolderPath = in_Path Then _
				Exit Function  '// Checked. It returns Empty.
			full_path = in_Path
		Else
			full_path = g_fs.GetAbsolutePathName( in_Path )  '// Very slow
			If g_TempFile.m_FolderPath = full_path Then _
				Exit Function  '// Checked. It returns Empty.
		End If

		If Right( full_path, 2 ) <> "\." Then  If Right( full_path, 2 ) <> ":\" Then _
			full_path = full_path + "\."
		For Each  writable  In  Me.CurrentPathes

			If StrComp( writable,  Left( full_path,  Len( writable ) ),  1 ) = 0 Then _
				Exit Function  '// Checked
		Next
		full_path = Left( full_path,  Len( full_path ) - 1 )
		If in_Option = g_VBS_Lib.ForMkDir Then
			For Each writable  In Me.CurrentPathes

				If StrComp( full_path,  Left( writable,  Len( full_path ) ),  1 ) = 0 Then _
					Exit Function  '// Checked. It returns Empty.
			Next
		End If

		full_path = Left( full_path,  Len( full_path ) - 1 )
			'// Cut "." of "\."  or  "\" of ":\"

		If Right( full_path,  9 ) = ".updating" Then _
			Exit Function  '// Checked

		CheckWritablePart = full_path
	End Function


	Public Function  CanPlusNoAsk( in_FullPath,  in_Empty,  out_PlusPath )
		Dim  full_path, writable, i

		full_path = in_FullPath
		If Right( full_path, 2 ) <> "\." Then _
			full_path = full_path + "\."

		If not exist( full_path ) Then
		 '// If the folder already exists, do not writable

			For Each writable  In Me.CurrentPathes
				If Right( writable, 3 ) = "\*\" Then
					If Left( writable, Len(writable) - 2 ) = Left( full_path, Len( writable ) - 2 ) or _
							Left( writable, Len(writable) - 3 ) = full_path Then

						out_PlusPath = Left( full_path, InStr( Len( writable ) - 1, full_path, "\" ) )
							'// writable="fo\*\", full_path="fo\sub\sub2\f.txt", out_PlusPath="fo\sub\"
						CanPlusNoAsk = True
						Exit Function
					End If
				End If
			Next
		End If
		CanPlusNoAsk = False
	End Function


	Public Sub  AskFileAccess( in_FullPath )
		Const  s = "System folder access"

		If Left( in_FullPath, Len( g_TempFile.m_FolderPath ) + 1 ) = g_TempFile.m_FolderPath + "\" Then _
			Exit Sub

		If not IsEmpty( Me_ProgramFiles ) Then _
			If Left( in_FullPath, Len( Me_ProgramFiles ) ) = Me_ProgramFiles or _
				 Left( Me_ProgramFiles, Len( in_FullPath ) ) = in_FullPath Then _
				g_AppKey.Ask  in_FullPath, s

		If not IsEmpty( Me_windir ) Then _
			If Left( in_FullPath, Len( Me_windir ) ) = Me_windir or _
				 Left( Me_windir, Len( in_FullPath ) ) = in_FullPath Then _
				g_AppKey.Ask  in_FullPath, s

If True Then
		If not IsEmpty( Me_APPDATA ) Then _
			If Left( in_FullPath, Len( Me_APPDATA ) ) = Me_APPDATA or _
				 Left( Me_APPDATA, Len( in_FullPath ) ) = in_FullPath Then _
				g_AppKey.Ask  in_FullPath, s

		If not IsEmpty( Me_LOCALAPPDATA ) Then _
			If Left( in_FullPath, Len( Me_LOCALAPPDATA ) ) = Me_LOCALAPPDATA or _
				 Left( Me_LOCALAPPDATA, Len( in_FullPath ) ) = in_FullPath Then _
				g_AppKey.Ask  in_FullPath, s
End If
	End Sub

End Class


 
'*************************************************************************
'  <<< [WritablesStack] Class >>> 
'*************************************************************************
Class  WritablesStack
	Private  m_AppKey
	Private  m_Pathes

	Public Sub  PushPathes( in_AppKey, in_Pathes )
		Set  m_Pathes = new ArrayClass : ErrCheck
		m_Pathes.Copy  in_Pathes
		Set  m_AppKey = in_AppKey
		g_CurrentWritables.PushPathes  in_AppKey, in_Pathes
	End Sub

	Private Sub Class_Terminate()
		g_CurrentWritables.PopPathes  m_AppKey, m_Pathes
	End Sub
End Class


 
'*************************************************************************
'  <<< [Writables] Class >>> 
'*************************************************************************
Class  Writables
	Private  m_Pathes()
	Private  m_AppKey

	Public Sub  SetPathes( in_AppKey,  ByVal in_Pathes )
		Dim  full_path, i, j

		If not IsEmpty( m_AppKey ) Then  Err.Raise 1,,"Double key"
		If not g_AppKey.IsSame( in_AppKey ) Then _
			Err.Raise 1,,"Invalied AppKey"

		If TypeName( in_Pathes ) = "ArrayClass" Then
			in_Pathes = in_Pathes.Items
		ElseIf not IsArray( in_Pathes ) Then
			in_Pathes = Array( in_Pathes )
		End If

		ReDim  m_Pathes( UBound( in_Pathes ) + 1 )
		j=0
		For i=0 To UBound( in_Pathes )
			full_path = env( in_Pathes(i) )
			If not IsEmpty( full_path ) Then
				full_path = GetFullPath( full_path, Empty )
				g_CurrentWritables.AskFileAccess  full_path
				m_Pathes(j) = full_path + "\"
				j=j+1
			End If
		Next
		ReDim Preserve  m_Pathes( j )
		m_Pathes( j ) = g_TempFile.m_FolderPath + "\"  '// Last is Temp

		Set m_AppKey = in_AppKey
	End Sub

	Public Function  Enable()
		Dim  st : Set st = new WritablesStack : ErrCheck
		st.PushPathes  m_AppKey, m_Pathes
		Set Enable = st
	End Function
End Class


 
'*************************************************************************
'  <<< [SetWritableMode] >>> 
'*************************************************************************
Sub  SetWritableMode( in_Flags )
	g_AppKey.SetWritableMode  in_Flags
End Sub


 
'*************************************************************************
'  <<< [set_workfolder] old function >>> 
'*************************************************************************
Sub  set_workfolder( ByVal dir )
	ThisIsOldSpec
End Sub


Class  WorkFolderStack
	Private Sub Class_Initialize()
		ThisIsOldSpec
	End Sub
	Public Sub  set_( x ) : End Sub
End Class


 
'*************************************************************************
'  <<< [SetBreakByFName] >>> 
'*************************************************************************
Sub  SetBreakByFName( in_FileName )
	g_BreakByPath = in_FileName
	g_BreakCountByPath = Empty
End Sub


 
'*************************************************************************
'  <<< [SetBreakByPath] >>> 
'*************************************************************************
Sub  SetBreakByPath( in_Path, in_Count )
	g_BreakByPath = in_Path
	g_BreakCountByPath = in_Count
End Sub


 
'*************************************************************************
'  <<< [IsWriteAccessDenied] >>> 
'*************************************************************************
Function  IsWriteAccessDenied( ErrNumber, Path, FolderOrFile, in_out_nRetry )
	If ErrNumber = E_WriteAccessDenied Then
		Const  msg = "書き込みできません。(70)"
		Set c = g_VBS_Lib
		max_retry = g_FileSystemMaxRetryMSec / g_FileSystemRetryMSec


		'//=== error of overwrite file on folder or folder on file
		If (FolderOrFile and c.File)=0 Then
			If g_fs.FileExists( Path ) Then  Raise  ErrNumber, msg
		End If
		If (FolderOrFile and c.Folder)=0 Then
			If g_fs.FolderExists( Path ) Then  Raise  ErrNumber, msg
		End If


		'//=== If read only
		If in_out_nRetry = 0 Then
			is_read_only = False
			If g_fs.FileExists( Path ) Then
				If g_fs.GetFile( Path ).Attributes and ReadOnly Then
					is_read_only = True
				End If
			End If
			If g_fs.FolderExists( Path ) Then
				If g_fs.GetFolder( Path ).Attributes and ReadOnly Then
					is_read_only = True
				ElseIf GetReadOnlyList( Path, read_onlys, Empty ) >= 1 Then
					is_read_only = True

					echo_v  ""
					echo_v  "List of Read Only:"
					index = 0
					For Each  read_only_path  In  read_onlys.Keys
						If index >= 10 Then
							echo_v  "There are more files ...."
							Exit For
						End If
						echo_v  "    "+ read_only_path
						index = index + 1
					Next
				End If
			End If
			If is_read_only Then
				Err.Raise  70,, "<ERROR msg=""リードオンリーです"" path="""+ Path +"""/>"
			End If
		End If


		'//=== echo warning
		If g_CommandPrompt = 0 Then
			If MsgBox( msg, vbRetryCancel ) = vbCancel Then   Raise  ErrNumber, msg
		Else
			in_out_nRetry = in_out_nRetry + 1
			If in_out_nRetry = 1 Then
				echo_v  "<WARNING msg="""+ msg +""" msg2=""再試行しています"" retry_count=""1"""+ _
					vbCRLF+ " path="""+ Path +"""/>"
			ElseIf in_out_nRetry <= max_retry Then
				echo_v  "<WARNING msg="""+ msg +""" msg2=""再試行しています"" retry_count="""& _
					in_out_nRetry &"""/>"
			Else
				Raise  ErrNumber, msg
			End If

			WScript.Sleep  g_FileSystemRetryMSec
		End If
		IsWriteAccessDenied = True
	Else
		IsWriteAccessDenied = False
	End If
End Function


 
'***********************************************************************
'* Function: SetReadOnlyAttribute
'***********************************************************************
Sub  SetReadOnlyAttribute( in_Path,  in_IsReadOnly )
	If VarType( in_Path ) = vbString Then
		If g_fs.FolderExists( in_Path ) Then
			a_folder_path = in_Path
		Else
			Set a_file = g_fs.GetFile( in_Path )
		End If
	Else
		If TypeName( in_Path ) = "Folder" Then
			a_folder_path = in_Path.Path
		Else
			Set a_file = in_Path
		End If
	End If

	If in_IsReadOnly Then
		If not IsEmpty( a_file ) Then

			a_file.Attributes = a_file.Attributes or ReadOnly
		Else
			EnumFolderObjectDic  a_folder_path,  Empty,  folders  '// Set "folders"
			For Each  a_folder  In  folders.Items
				For Each  a_file  In  a_folder.Files

					a_file.Attributes = a_file.Attributes or ReadOnly
				Next
			Next
		End If
	Else
		If not IsEmpty( a_file ) Then

			a_file.Attributes = a_file.Attributes  and  not ReadOnly
		Else
			EnumFolderObjectDic  a_folder_path,  Empty,  folders  '// Set "folders"
			For Each  a_folder  In  folders.Items
				For Each  a_file  In  a_folder.Files

					a_file.Attributes = a_file.Attributes  and  not ReadOnly
				Next
			Next
		End If
	End If
End Sub


 
'*************************************************************************
'  <<< [SetFileToReadOnly] >>> 
'*************************************************************************
Sub  SetFileToReadOnly( ByVal  in_File )
	ThisIsOldSpec
	If VarType( in_File ) = vbString Then _
		Set in_File = g_fs.GetFile( in_File )

	in_File.Attributes = in_File.Attributes or ReadOnly
End Sub


 
'*************************************************************************
'  <<< [SetFileToNotReadOnly] >>> 
'*************************************************************************
Sub  SetFileToNotReadOnly( ByVal  in_File )
	ThisIsOldSpec
	If VarType( in_File ) = vbString Then _
		Set in_File = g_fs.GetFile( in_File )

	in_File.Attributes = in_File.Attributes  and  not ReadOnly
End Sub


 
'*************************************************************************
'  <<< [SetFilesToReadOnly] >>> 
'*************************************************************************
Sub  SetFilesToReadOnly( ByVal  in_Folder )
	ThisIsOldSpec
	If VarType( in_Folder ) = vbString Then _
		Set in_Folder = g_fs.GetFolder( in_Folder )
	For Each  file  In  in_Folder.Files

		file.Attributes = file.Attributes or ReadOnly
	Next
	For Each  sub_folder  In  in_Folder.SubFolders 
		SetFilesToReadOnly  sub_folder
	Next
End Sub


 
'*************************************************************************
'  <<< [SetFilesToNotReadOnly] >>> 
'*************************************************************************
Sub  SetFilesToNotReadOnly( ByVal  in_Folder )
	ThisIsOldSpec
	If VarType( in_Folder ) = vbString Then _
		Set in_Folder = g_fs.GetFolder( in_Folder )
	For Each  file  In  in_Folder.Files

		file.Attributes = file.Attributes  and  not ReadOnly
	Next
	For Each  sub_folder  In  in_Folder.SubFolders 
		SetFilesToNotReadOnly  sub_folder
	Next
End Sub


 
'*************************************************************************
'  <<< [cd] >>> 
'*************************************************************************
Sub  cd( dir )
	echo  ">cd  """ & dir & """"
	cd_sub  dir
End Sub

Sub  cd_sub( dir )
	old_current = g_sh.CurrentDirectory
	If Mid( old_current, 2 ) = ":" Then
		g_sh.CurrentDirectory = Left( old_current, 3 )
			'// Change to root folder of current drive for unlock
	End If

	ErrCheck : On Error Resume Next
		g_sh.CurrentDirectory = dir
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 Then _
		Err.Raise en,, "<ERROR msg=""フォルダーとしてアクセスできません"" path=""" + dir +_
			""" current="""+ g_sh.CurrentDirectory +"""/>"

	If not IsFullPath( dir ) Then  echo  g_sh.CurrentDirectory +">"
End Sub


 
'*************************************************************************
'  <<< [CurDirStack] >>> 
'*************************************************************************
Class  CurDirStack

	Public  m_Prev

	Private Sub Class_Initialize
		m_Prev = g_sh.CurrentDirectory
	End Sub

	Private Sub Class_Terminate
		g_sh.CurrentDirectory = m_Prev
	End Sub
End Class


 
'*************************************************************************
'  <<< [pushd] >>> 
'*************************************************************************
Dim  g_pushd_stack()
Dim  g_pushd_stack_n

Sub  pushd( dir )
	echo  ">pushd  """ & dir & """"

	g_pushd_stack_n = g_pushd_stack_n + 1
	Redim Preserve  g_pushd_stack( g_pushd_stack_n )

	g_pushd_stack( g_pushd_stack_n ) = g_sh.CurrentDirectory
	cd_sub  dir
End Sub


 
'*************************************************************************
'  <<< [popd] >>> 
'*************************************************************************
Sub  popd
	echo  ">popd"
	Dim  sh

	If g_pushd_stack_n < 1 Then Exit Sub

	Set sh = WScript.CreateObject("WScript.Shell")
	sh.CurrentDirectory = g_pushd_stack( g_pushd_stack_n )

	g_pushd_stack_n = g_pushd_stack_n - 1
End Sub


 
'*************************************************************************
'  <<< [cd_UpperCaseDrive] >>> 
'*************************************************************************
Sub  cd_UpperCaseDrive()
	current = g_sh.CurrentDirectory
	g_sh.CurrentDirectory = "\"
	g_sh.CurrentDirectory = UCase( Left( current, 1 ) ) + Mid( current, 2 )
End Sub


 
'*************************************************************************
'  <<< [copy] >>> 
'*************************************************************************
Sub  copy( SrcPath, DstFolderPath )
	Dim  c : Set c = g_VBS_Lib

	If g_Vers("CopyTargetIsFileOrFolder") Then
		copy_sub  SrcPath, DstFolderPath, Empty
	Else
		copy_sub  SrcPath, DstFolderPath, c.CopyV4
	End If
End Sub


Sub  copy_sub( SrcPath, DstPath, Opt )
	Dim  en, ed, n_retry, fo, src, dst, dst_fo, command_str
	Dim  c : Set c = g_VBS_Lib
	If Opt = c.CopyRen Then  command_str = ">copy_ren  """  Else  command_str = ">copy  """

	echo  command_str & SrcPath & """, """ & DstPath & """"
	Set en = new EchoOff

	If g_debug_or_test Then
		g_AppKey.BreakByPath DstPath
	End If


	'//=== If SrcPath had wildcard or destination folder was merged
	If IsWildcard( SrcPath )  or  ( Opt = c.CopyRen  and  g_fs.FolderExists( SrcPath ) ) Then
		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath, c.File or c.SubFolder

		src = SrcPath : CutLastOf  src, "\", Empty : CutLastOf  src, "/", Empty
		If Opt = c.CopyRen Then  src = src +"\*"
		If not g_fs.FolderExists( GetParentFullPath( src ) ) Then _
			Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ SrcPath +"""/>"
		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		g_AppKey.CheckWritable  DstPath + "\.", Empty  '// "\." is for able to make writable folder

		If Opt = c.CopyRen Then
			mkdir_for  DstPath
		Else
			mkdir  DstPath
		End If

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next


				g_fs.CopyFile  src, DstPath, True


			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.File, n_retry ) Then  Exit Do
		Loop
		If en = E_FileNotExist Then  en = 0
		If en <> 0 Then  Err.Raise en,,ed

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next


				g_fs.CopyFolder  src, DstPath, True


			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.Folder, n_retry ) Then  Exit Do
		Loop
		If en = E_PathNotFound Then  en = 0
		If en <> 0 Then  Err.Raise en,,ed


	ElseIf g_fs.FileExists( SrcPath ) Then
		If g_debug_or_test Then  g_AppKey.BreakByPath DstPath

		If g_fs.FolderExists( DstPath )  and  Opt <> c.CopyRen  Then
			dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		Else
			If Opt = c.CopyV4 Then  '// vbslib ver4
				dst_fo = DstPath
				dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
			Else  '// vbslib ver3 or c.CopyRen
				dst_fo = GetParentFullPath( DstPath )
				dst = DstPath
				If IsEmpty( Opt ) Then  ThisIsOldSpec  '// use copy_ren
			End If
			If not g_fs.FolderExists( dst_fo ) Then  mkdir  dst_fo
		End If

		If Opt = c.CopyV4 Then  '// vbslib ver4
			g_AppKey.CheckWritable  dst, Empty  '// "\." is for able to make writable folder
			If g_fs.FolderExists( dst ) Then  del  dst  '// for Replace from folder to file
		Else
			If not g_fs.FileExists( dst ) Then
				g_AppKey.CheckWritable  dst + "\.", Empty  '// "\." is for able to make writable folder
			Else
				g_AppKey.CheckWritable  dst, Empty
				If g_fs.FolderExists( dst ) Then  del  dst  '// for Replace from folder to file
			End If
		End If

		If StrComp( GetFullPath( SrcPath, Empty ), GetFullPath( dst, Empty ), 1 ) <> 0 Then
			n_retry = 0
			Do
				ErrCheck : On Error Resume Next


					g_fs.CopyFile  SrcPath, dst, True


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, dst, c.File, n_retry ) Then  Exit Do
			Loop
			If en <> 0 Then  Err.Raise en,,ed +"  """+ SrcPath +""", """+ dst +""""
		End If


	ElseIf g_fs.FolderExists( SrcPath ) Then
		If g_debug_or_test Then  g_AppKey.BreakByPath  DstPath

		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath+"\*", c.File or c.SubFolder

		dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		g_AppKey.CheckWritable  dst, Empty

		If StrComp( GetFullPath( SrcPath, Empty ), dst, 1 ) <> 0 Then
			n_retry = 0
			Do
				ErrCheck : On Error Resume Next


					g_fs.CopyFolder  SrcPath, dst, True


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, dst, c.Folder, n_retry ) Then  Exit Do
			Loop
			If en <> 0 Then  Err.Raise en,,ed
		End If

	' not found
	Else
		echo  command_str & SrcPath & """, """ & DstPath & """"
		Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ SrcPath +"""/>"
	End If
End Sub


 
'*************************************************************************
'  <<< [copy_ren] >>> 
'*************************************************************************
Sub  copy_ren( SrcPath, DstPath )
	Dim  c : Set c = g_VBS_Lib
	copy_sub  SrcPath, DstPath, c.CopyRen
End Sub


 
'*************************************************************************
'  <<< [copy_ren_tmp] >>> 
'*************************************************************************
Sub  copy_ren_tmp( SrcPath, DstPath )
	Dim  c : Set c = g_VBS_Lib
	copy_sub_tmp  SrcPath, DstPath, c.CopyRen
End Sub

Sub  copy_sub_tmp( SrcPath, DstPath, Opt )
	Dim  en, ed, n_retry, fo, src, dst, dst_fo, command_str
	Dim  c : Set c = g_VBS_Lib
	If Opt = c.CopyRen Then  command_str = ">copy_ren  """  Else  command_str = ">copy  """

	echo  command_str & SrcPath & """, """ & DstPath & """"
	Dim ec : Set ec = new EchoOff


	'//=== If DstPath had Wild card
	If IsWildcard( DstPath )  and  Opt = c.CopyRen Then
		Dim  src_path_wild,  dst_path_wild,  src_fo_path,  dst_fo_path,  src_fname,  dst_fname,  dst_path
		Dim  src_i,  src_left,  src_mid,  src_right,  src_left_len,  src_right_len,  src_len_not_wild
		Dim  dst_i,  dst_left,  dst_mid,  dst_right

		If not IsWildcard( SrcPath ) Then  Error

		src_path_wild = g_fs.GetFileName( SrcPath )
		dst_path_wild = g_fs.GetFileName( DstPath )
		src_fo_path = GetParentFullPath( SrcPath ) : CutLastOf  src_fo_path, "\", Empty : If IsWildcard( src_fo_path ) Then Error
		dst_fo_path = GetParentFullPath( DstPath ) : CutLastOf  dst_fo_path, "\", Empty : If IsWildcard( dst_fo_path ) Then Error
		src_i            = InStr( src_path_wild, "*" )
		src_left         = Left(  src_path_wild,  src_i - 1 )
		src_right        = Right( src_path_wild,  Len( src_path_wild ) - src_i )
		If InStr( src_i + 1,  src_path_wild,  "*" ) > 0 Then
			If src_i <> 1 Then Error
			If Right( src_path_wild, 1 ) <> "*" Then Error
			src_mid = Mid( src_path_wild, 2, Len( src_path_wild ) - 2 )
		End If
		src_left_len     = Len( src_left )
		src_right_len    = Len( src_right )
		src_len_not_wild = Len( src_path_wild ) - 1
		dst_i            = InStr( dst_path_wild, "*" )
		dst_left         = Left(  dst_path_wild,  dst_i - 1 )
		dst_right        = Right( dst_path_wild,  Len( dst_path_wild ) - dst_i )
		If InStr( dst_i + 1,  dst_path_wild,  "*" ) > 0 Then
			If dst_i <> 1 Then Error
			If Right( dst_path_wild, 1 ) <> "*" Then Error
			dst_mid = Mid( dst_path_wild, 2, Len( dst_path_wild ) - 2 )
		End If
		If IsEmpty( src_mid ) <> IsEmpty( dst_mid ) Then Error

		mkdir  dst_fo_path

		Set fo = g_fs.GetFolder( src_fo_path )
		For Each src  In fo.Files
			src_fname = src.Name
			dst_fname = Empty
			If IsEmpty( dst_mid ) Then
				If Left( src_fname, src_left_len ) = src_left  and  Right( src_fname, src_right_len ) = src_right Then

					dst_fname = dst_left + _
											Mid( src_fname,  src_i,  Len( src_fname ) - src_len_not_wild ) + _
											dst_right
						'// (sample) src_path_wild = "AB*CD" : dst_path_wild = "abcd*efgh"
						'//               1234567                 12345678901
						'//  src_fname = "AB123CD" : dst_fname = "abcd123efgh"
				End If
			Else
				If InStr( src_fname, src_mid ) > 0 Then
					dst_fname = Replace( src_fname, src_mid, dst_mid )
				End If
			End If
			If not IsEmpty( dst_fname ) Then
				dst_path = dst_fo_path +"\"+ dst_fname
				If g_fs.FolderExists( dst_path ) Then  Error
				g_fs.CopyFile  src_fo_path +"\"+ src_fname,  dst_path
			End If
		Next

		For Each src  In fo.SubFolders
			src_fname = src.Name
			dst_fname = Empty
			If IsEmpty( dst_mid ) Then
				If Left( src_fname, src_left_len ) = src_left  and  Right( src_fname, src_right_len ) = src_right Then
					dst_fname = dst_left + _
											Mid( src_fname,  src_i,  Len( src_fname ) - src_len_not_wild ) + _
											dst_right
				End If
			Else
				If InStr( src_fname, src_mid ) > 0 Then
					dst_fname = Replace( src_fname, src_mid, dst_mid )
				End If
			End If
			If not IsEmpty( dst_fname ) Then
				copy_sub_tmp  src_fo_path +"\"+ src_fname +"\*",  dst_fo_path +"\"+ dst_fname,  c.CopyRen
			End If
		Next


	'//=== If SrcPath had Wild card
	ElseIf IsWildcard( SrcPath )  or  ( Opt = c.CopyRen  and  g_fs.FolderExists( SrcPath ) ) Then
		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath, c.File or c.SubFolder

		src = SrcPath : CutLastOf  src, "\", Empty : CutLastOf  src, "/", Empty
		If Opt = c.CopyRen  and  g_fs.FolderExists( src ) Then  Assert( not IsWildcard( src ) ) : src = src +"\*"
		If not g_fs.FolderExists( GetParentFullPath( src ) ) Then _
			Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ SrcPath +"""/>"
		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		g_AppKey.CheckWritable  DstPath + "\.", Empty  '// "\." is for able to make writable folder

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.CopyFile  src, DstPath, True
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.File, n_retry ) Then  Exit Do
		Loop
		If en = E_FileNotExist Then  en = 0
		If en <> 0 Then  Err.Raise en,,ed

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.CopyFolder  src, DstPath, True
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.Folder, n_retry ) Then  Exit Do
		Loop
		If en = E_PathNotFound Then  en = 0
		If en <> 0 Then  Err.Raise en,,ed


	'//=== If SrcPath is file
	ElseIf g_fs.FileExists( SrcPath ) Then
		If g_debug_or_test Then  g_AppKey.BreakByPath DstPath

		If g_fs.FolderExists( DstPath )  and  Opt <> c.CopyRen  Then
			dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		Else
			If Opt = c.CopyV4 Then  '// vbslib ver4
				dst_fo = DstPath
				dst = GetAbsPatg( g_fs.GetFileName( SrcPath ), DstPath )
			Else  '// vbslib ver3 or c.CopyRen
				dst_fo = GetParentFullPath( DstPath )
				dst = DstPath
				If IsEmpty( Opt ) Then  ThisIsOldSpec  '// use copy_ren
			End If
			If not g_fs.FolderExists( dst_fo ) Then  mkdir  dst_fo
		End If

		If Opt = c.CopyV4 Then  '// vbslib ver4
			g_AppKey.CheckWritable  dst, Empty  '// "\." is for able to make writable folder
			If g_fs.FolderExists( dst ) Then  del  dst  '// for Replace from folder to file
		Else
			If not g_fs.FileExists( dst ) Then
				g_AppKey.CheckWritable  dst + "\.", Empty  '// "\." is for able to make writable folder
			Else
				g_AppKey.CheckWritable  dst, Empty
				If g_fs.FolderExists( dst ) Then  del  dst  '// for Replace from folder to file
			End If
		End If

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.CopyFile  SrcPath, dst, True
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, dst, c.File, n_retry ) Then  Exit Do
		Loop
		If en <> 0 Then  Err.Raise en,,ed


	' If SrcPath is folder
	ElseIf g_fs.FolderExists( SrcPath ) Then
		If g_debug_or_test Then  g_AppKey.BreakByPath  DstPath

		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath+"\*", c.File or c.SubFolder

		dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		g_AppKey.CheckWritable  dst, Empty

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.CopyFolder  SrcPath, dst, True
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, dst, c.Folder, n_retry ) Then  Exit Do
		Loop
		If en <> 0 Then  Err.Raise en,,ed


	' not found
	Else
		echo  command_str & SrcPath & """, """ & DstPath & """"
		Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ SrcPath +"""/>"
	End If
End Sub

 
'*************************************************************************
'  <<< [copy_ex] >>> 
'*************************************************************************
Sub  copy_ex( ByVal  in_SrcPath,  in_DstPath,  in_Option )
	Dim  folder, fnames(), fname, fname2, tag, to_tag, dst, fo, ec
	Dim  c : Set c = g_VBS_Lib

	echo  ">copy_ex  """+ in_SrcPath +""" """+ in_DstPath +""", "& in_Option

	g_AppKey.CheckWritable  in_DstPath +"\.", Empty  '// "\." is for able to make writable folder


	Select Case  in_Option

	 Case c.CutTag
		tag = Replace( g_fs.GetFileName( in_SrcPath ), "*", "" )
		If Right( tag, 1 ) = "." Then
			to_tag = "."
		Else
			to_tag = ""
		End If

	 Case c.MakeShortcutFiles
		in_SrcPath = GetFullPath( in_SrcPath, Empty )

	End Select


	ExpandWildcard  in_SrcPath,  c.File or c.SubFolder or c.EmptyFolder,  folder,  fnames
	For Each  fname  in  fnames

		Select Case  in_Option

		 Case  c.CutTag
		 	If Right( fname, 1 ) <> "\" Then  '// File
				echo  fname
				dst = in_DstPath +"\"+ g_fs.GetParentFolderName( fname ) +"\"
				fname2 = g_fs.GetFileName( fname )
				If InStr( fname2, "." ) = 0 Then
					dst = dst + Left( fname2, Len( fname2 ) - Len( tag ) + 1 )
				Else
					dst = dst + Replace( fname2, tag, to_tag )
				End If
				fo = g_fs.GetParentFolderName( dst )
				If not g_fs.FolderExists( fo ) Then  mkdir  fo
				g_fs.CopyFile  folder +"\"+ fname, dst
			End If

		 Case  c.ExistOnly
		 	If Right( fname, 1 ) <> "\" Then  '// File
				dst = in_DstPath +"\"+ fname
				If g_fs.FileExists( dst ) Then
					echo  fname
					g_fs.CopyFile  folder +"\"+ fname,  dst
				End If
			End If

		 Case  c.MakeShortcutFiles
		 	If Right( fname, 1 ) <> "\" Then  '// File
				echo  fname
				lnk_path = in_DstPath +"\"+ AddLastOfFileName( fname, ".lnk" )
				Set shcut = g_sh.CreateShortcut( lnk_path )
				shcut.TargetPath = folder +"\"+ fname
				mkdir_for  lnk_path
				shcut.Save
			Else  '// EmptyFolder
				mkdir  in_DstPath +"\"+ fname
			End If

		 Case  c.NotExistOnly
			dst = in_DstPath +"\"+ fname
		 	If Right( fname, 1 ) <> "\" Then  '// File
			 	If not g_fs.FileExists( dst ) Then
					echo  fname
					mkdir_for  dst
					g_fs.CopyFile  folder +"\"+ fname,  dst
			 	End If
			Else  '// EmptyFolder
				mkdir  dst
			End If

		 Case Else
		 	If Right( fname, 1 ) <> "\" Then  '// File
				echo  fname
				g_fs.CopyFile  folder +"\"+ fname,  in_DstPath +"\"+ fname
			End If
		End Select
	Next
End Sub


 
'*************************************************************************
'  <<< [cat] >>> 
'*************************************************************************
Sub  cat( Files, OutputPath )
	If IsArray( Files ) Then
		cat_sub  Files, OutputPath
	Else
		cat_sub  Array( Files ), OutputPath
	End If
End Sub

Sub  cat_sub( Files, OutputPath )
	Dim  path, f, text, ec, is_append

	is_append = ( Files(0) = OutputPath  and  UBound( Files ) = 1 )
	If is_append Then
		text = ">cat """+ Files(1) +""" >> """+ OutputPath +""""
	Else
		text = ">cat (array)"
		If not IsEmpty( OutputPath ) Then _
			text = text + " > """+ OutputPath +""""
	End If
	echo  text

	text = ""
	For Each path  In Files
		If not is_append Then  echo  "  """+ path +""""
		text = text + ReadFile( path )
	Next

	Set ec = new EchoOff
	If IsEmpty( OutputPath ) Then
		type_  path
	Else
		CreateFile  OutputPath, text
	End If
End Sub

 
'*************************************************************************
'  <<< [move] >>> 
'*************************************************************************
Sub  move( SrcPath, DstFolderPath )
	Dim  c : Set c = g_VBS_Lib

	If g_Vers("CopyTargetIsFileOrFolder") Then
		move_or_copy_del_sub  SrcPath, DstFolderPath, Empty
	Else
		move_or_copy_del_sub  SrcPath, DstFolderPath, c.CopyV4
	End If
End Sub


Sub  move_or_copy_del_sub( SrcPath, DstPath, Opt )
	If IsMovablePathToPath( SrcPath, DstPath, True ) Then
		move_sub  SrcPath, DstPath, Opt
	Else
		copy_sub  SrcPath, DstPath, Opt

		If TryStart(e) Then  On Error Resume Next
			del  SrcPath
		If TryEnd Then  On Error GoTo 0
		If e.num = E_WriteAccessDenied  Then  Raise 17, e.Description
		If e.num <> 0 Then  e.Raise
	End If
End Sub


Sub  move_sub( SrcPath, DstPath, Opt )
	Dim  en, en_, ed, n_retry, fo, src, dst, dst_fo, command_str
	Dim  c : Set c = g_VBS_Lib
	If Opt = c.CopyRen Then  command_str = ">move_ren  """  Else  command_str = ">move  """

	echo  command_str & SrcPath & """, """ & DstPath & """"
	Set en_ = new EchoOff

	If g_debug_or_test Then
		g_AppKey.BreakByPath  SrcPath
		g_AppKey.BreakByPath  DstPath
	End If


	'//=== Moving Folder
	If g_fs.FolderExists( SrcPath )  and  not exist( DstPath ) Then

		'// "BreakByPath" for the file
		If g_debug_or_test Then
			ExpandWildcard  SrcPath +"\*",  c.File or c.Folder or c.SubFolder,  folder,  fnames
			For Each  fname  In  fnames
				g_AppKey.BreakByPath  fname
			Next
		End If


		'// ...
		If Opt = c.CopyRen Then
			mkdir_for  DstPath

			g_fs.MoveFolder  SrcPath, DstPath
		Else
			mkdir  DstPath

			g_fs.MoveFolder  SrcPath, DstPath +"\"+ g_fs.GetFileName( SrcPath )
		End If


	'//=== If SrcPath had wildcard or destination folder was merged
	ElseIf IsWildcard( SrcPath )  or  ( Opt = c.CopyRen  and  g_fs.FolderExists( SrcPath ) ) Then
		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath, c.File or c.SubFolder

		src = SrcPath : CutLastOf  src, "\", Empty : CutLastOf  src, "/", Empty
		If Opt = c.CopyRen Then  src = src +"\*"
		If not g_fs.FolderExists( GetParentFullPath( src ) ) Then _
			Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ _
				SrcPath +"""/>"
		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		g_AppKey.CheckWritable  DstPath + "\.", Empty  '// "\." is for able to make writable folder
		is_parent_dst = False


		'//=== Delete dst files and folders
		If Opt <> c.CopyRen Then
			Dim  folder, fnames(), fname, parent
			parent = g_fs.GetFileName( g_fs.GetParentFolderName( src ) )

			ExpandWildcard  src, c.File or c.Folder, folder, fnames
			For Each fname  In fnames
				If parent <> fname Then
					del  DstPath +"\"+ fname
				ElseIf StrCompHeadOf( GetParentFullPath( src ), GetFullPath( DstPath, Empty ), _
						Empty ) = 0 Then
					temporary_dst = DstPath +"\"+ parent +"_"
					While  exist( temporary_dst )
						temporary_dst = temporary_dst +"_"
					WEnd
					is_parent_dst = True
				Else
					del  DstPath +"\"+ fname
				End If
			Next
		End If
		en = Empty


		'//=== Move files
		n_retry = 0
		Do
			ErrCheck : On Error Resume Next


				g_fs.MoveFile  src, DstPath


			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.File, n_retry ) Then  Exit Do
		Loop
		If en = E_FileNotExist Then  en = 0
		If en = E_AlreadyExist Then
			Do
				ErrCheck : On Error Resume Next


					g_fs.CopyFile  src, DstPath


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, DstPath, c.File, n_retry ) Then  Exit Do
			Loop
		End If
		If en <> 0 Then  Err.Raise en,,ed


		'//=== Move folders
		n_retry = 0
		If is_parent_dst Then
			mkdir  temporary_dst
			Do
				ErrCheck : On Error Resume Next


					g_fs.MoveFile  g_fs.GetParentFolderName( src ) +"\"+ parent +"\*", _
						temporary_dst


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, DstPath, c.Folder, n_retry ) Then  Exit Do
			Loop
			Do
				ErrCheck : On Error Resume Next


					g_fs.MoveFolder  g_fs.GetParentFolderName( src ) +"\"+ parent +"\*", _
						temporary_dst


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, DstPath, c.Folder, n_retry ) Then  Exit Do
			Loop
			g_fs.DeleteFolder  g_fs.GetParentFolderName( src ) +"\"+ parent
		End If
		Do
			ErrCheck : On Error Resume Next


				g_fs.MoveFolder  src, DstPath


			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.Folder, n_retry ) Then  Exit Do
		Loop
		If is_parent_dst Then
			g_fs.DeleteFolder  g_fs.GetParentFolderName( src )
			ren  temporary_dst,  parent
		End If
		If en = E_PathNotFound Then  en = 0
		If en = E_AlreadyExist Then
			Do
				ErrCheck : On Error Resume Next


					g_fs.CopyFolder  src, DstPath, True


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, DstPath, c.Folder, n_retry ) Then  Exit Do
			Loop
		End If
		If en <> 0 Then  Err.Raise en,,ed


		'// Delete source files and folders
		If StrCompHeadOf( SrcPath, DstPath, Empty ) = 0 Then
			'//
		ElseIf StrComp( SrcPath, DstPath, 1 ) <> 0 Then
			del  SrcPath
		End If


	ElseIf g_fs.FileExists( SrcPath ) Then

		'// Set "dst"
		If g_fs.FolderExists( DstPath )  and  Opt <> c.CopyV4 Then
			If Opt = c.CopyRen Then  Err.Raise  E_WriteAccessDenied
			dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		Else
			If Opt = c.CopyV4 Then  '// vbslib ver4
				dst_fo = DstPath
				dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
			Else  '// vbslib ver3 or c.CopyRen
				dst_fo = GetParentFullPath( DstPath )
				dst = DstPath
				If IsEmpty( Opt ) Then  ThisIsOldSpec  '// use move_ren
			End If

			If not g_fs.FolderExists( dst_fo ) Then
				g_AppKey.CheckWritable  SrcPath, Empty  '// If src cannot write, Don't make folder
				mkdir  dst_fo
			End If
		End If

		If StrComp( GetFullPath( SrcPath, Empty ), GetFullPath( dst, Empty ), 1 ) <> 0 Then

			'// Delete "dst"
			g_AppKey.CheckWritable  SrcPath, Empty
			If Opt = c.CopyV4 Then  '// vbslib ver4
				g_AppKey.CheckWritable  dst, Empty  '// "\." is for able to make writable folder
				del  dst  '// for Replace from folder to file
			Else
				If not g_fs.FileExists( dst ) Then
					g_AppKey.CheckWritable  dst + "\.", Empty  '// "\." is for able to make writable folder
				Else
					g_AppKey.CheckWritable  dst, Empty
					del  dst  '// for Replace from folder to file
				End If
			End If

			'// Move File
			n_retry = 0
			Do
				ErrCheck : On Error Resume Next


					g_fs.MoveFile  SrcPath, dst


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, dst, c.File, n_retry ) Then  Exit Do
			Loop
			If en <> 0 Then  Err.Raise en,,ed
		End If


	ElseIf g_fs.FolderExists( SrcPath ) Then

		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath+"\*", c.File or c.SubFolder

		dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		g_AppKey.CheckWritable  dst, Empty

		If StrComp( GetFullPath( SrcPath, Empty ), dst, 1 ) <> 0 Then
			n_retry = 0
			Do
				ErrCheck : On Error Resume Next


					g_fs.MoveFolder  SrcPath, dst


				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, dst, c.Folder, n_retry ) Then  Exit Do
			Loop
			If en <> 0 Then  Err.Raise en,,ed
		End If

	' not found
	Else
		echo  command_str & SrcPath & """, """ & DstPath & """"
		Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ SrcPath +"""/>"
	End If
End Sub


 
'*************************************************************************
'  <<< [move_ren] >>> 
'*************************************************************************
Sub  move_ren( SrcPath, DstPath )
	Dim  c : Set c = g_VBS_Lib
	move_or_copy_del_sub  SrcPath, DstPath, c.CopyRen
End Sub


 
'*************************************************************************
'  <<< [move_ren_tmp] >>> 
'*************************************************************************
Sub  move_ren_tmp( SrcPath, DstPath )
	Dim  c : Set c = g_VBS_Lib
	move_sub_tmp  SrcPath, DstPath, c.CopyRen
End Sub

Sub  move_sub_tmp( SrcPath, DstPath, Opt )
	Dim  en, ed, n_retry, fo, src, dst, dst_fo, command_str
	Dim  c : Set c = g_VBS_Lib
	If Opt = c.CopyRen Then  command_str = ">move_ren  """  Else  command_str = ">move  """

	echo  command_str & SrcPath & """, """ & DstPath & """"
	Dim ec : Set ec = new EchoOff


	'//=== If DstPath had Wild card
	If IsWildcard( DstPath )  and  Opt = c.CopyRen Then
		Dim  src_path_wild,  dst_path_wild,  src_fo_path,  dst_fo_path,  src_fname,  dst_fname,  dst_path
		Dim  src_i,  src_left,  src_mid,  src_right,  src_left_len,  src_right_len,  src_len_not_wild
		Dim  dst_i,  dst_left,  dst_mid,  dst_right

		If not IsWildcard( SrcPath ) Then  Error

		src_path_wild = g_fs.GetFileName( SrcPath )
		dst_path_wild = g_fs.GetFileName( DstPath )
		src_fo_path = GetParentFullPath( SrcPath ) : CutLastOf  src_fo_path, "\", Empty : If IsWildcard( src_fo_path ) Then Error
		dst_fo_path = GetParentFullPath( DstPath ) : CutLastOf  dst_fo_path, "\", Empty : If IsWildcard( dst_fo_path ) Then Error
		src_i            = InStr( src_path_wild, "*" )
		src_left         = Left(  src_path_wild,  src_i - 1 )
		src_right        = Right( src_path_wild,  Len( src_path_wild ) - src_i )
		If InStr( src_i + 1,  src_path_wild,  "*" ) > 0 Then
			If src_i <> 1 Then Error
			If Right( src_path_wild, 1 ) <> "*" Then Error
			src_mid = Mid( src_path_wild, 2, Len( src_path_wild ) - 2 )
		End If
		src_left_len     = Len( src_left )
		src_right_len    = Len( src_right )
		src_len_not_wild = Len( src_path_wild ) - 1
		dst_i            = InStr( dst_path_wild, "*" )
		dst_left         = Left(  dst_path_wild,  dst_i - 1 )
		dst_right        = Right( dst_path_wild,  Len( dst_path_wild ) - dst_i )
		If InStr( dst_i + 1,  dst_path_wild,  "*" ) > 0 Then
			If dst_i <> 1 Then Error
			If Right( dst_path_wild, 1 ) <> "*" Then Error
			dst_mid = Mid( dst_path_wild, 2, Len( dst_path_wild ) - 2 )
		End If
		If IsEmpty( src_mid ) <> IsEmpty( dst_mid ) Then Error

		mkdir  dst_fo_path

		Set fo = g_fs.GetFolder( src_fo_path )
		For Each src  In fo.Files
			src_fname = src.Name
			dst_fname = Empty
			If IsEmpty( dst_mid ) Then
				If Left( src_fname, src_left_len ) = src_left  and  Right( src_fname, src_right_len ) = src_right Then

					dst_fname = dst_left + _
						Mid( src_fname,  src_i,  Len( src_fname ) - src_len_not_wild ) + _
						dst_right
						'// (sample) src_path_wild = "AB*CD" : dst_path_wild = "abcd*efgh"
						'//               1234567                 12345678901
						'//  src_fname = "AB123CD" : dst_fname = "abcd123efgh"
				End If
			Else
				If InStr( src_fname, src_mid ) > 0 Then
					dst_fname = Replace( src_fname, src_mid, dst_mid )
				End If
			End If
			If not IsEmpty( dst_fname ) Then
				dst_path = dst_fo_path +"\"+ dst_fname
				If g_fs.FolderExists( dst_path ) Then  Error
				g_fs.MoveFile  src_fo_path +"\"+ src_fname,  dst_path
			End If
		Next

		For Each src  In fo.SubFolders
			src_fname = src.Name
			dst_fname = Empty
			If IsEmpty( dst_mid ) Then
				If Left( src_fname, src_left_len ) = src_left  and  Right( src_fname, src_right_len ) = src_right Then
					dst_fname = dst_left + _
											Mid( src_fname,  src_i,  Len( src_fname ) - src_len_not_wild ) + _
											dst_right
				End If
			Else
				If InStr( src_fname, src_mid ) > 0 Then
					dst_fname = Replace( src_fname, src_mid, dst_mid )
				End If
			End If
			If not IsEmpty( dst_fname ) Then
				move_sub_tmp  src_fo_path +"\"+ src_fname +"\*",  dst_fo_path +"\"+ dst_fname,  c.CopyRen
			End If
		Next


	'//=== If SrcPath had Wild card
	ElseIf IsWildcard( SrcPath )  or  ( Opt = c.CopyRen  and  g_fs.FolderExists( SrcPath ) ) Then
		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath, c.File or c.SubFolder

		src = SrcPath : CutLastOf  src, "\", Empty : CutLastOf  src, "/", Empty
		If Opt = c.CopyRen  and  g_fs.FolderExists( src ) Then  Assert( not IsWildcard( src ) ) : src = src +"\*"
		If not g_fs.FolderExists( GetParentFullPath( src ) ) Then _
			Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ SrcPath +"""/>"
		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		g_AppKey.CheckWritable  DstPath + "\.", Empty  '// "\." is for able to make writable folder


		'//=== Delete dst files and folders
		If Opt = c.CopyRen Then
			del  DstPath +"\*"
		Else
			Dim  folder, fnames(), fname

			ExpandWildcard  src, c.File or c.Folder, folder, fnames
			For Each fname  In fnames
				del  DstPath +"\"+ fname
			Next
		End If


		'//=== Move files
		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.MoveFile  src, DstPath
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.File, n_retry ) Then  Exit Do
		Loop
		If en = E_FileNotExist Then  en = 0
		If en <> 0 Then  Err.Raise en,,ed


		'//=== Move folders
		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.MoveFolder  src, DstPath
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, DstPath, c.Folder, n_retry ) Then  Exit Do
		Loop
		If en = E_PathNotFound Then  en = 0
		If en <> 0 Then  Err.Raise en,,ed

		If Opt = c.CopyRen Then  del  SrcPath


	'//=== If SrcPath is file
	ElseIf g_fs.FileExists( SrcPath ) Then
		If g_debug_or_test Then
			g_AppKey.BreakByPath SrcPath
			g_AppKey.BreakByPath DstPath
		End If

		If g_fs.FolderExists( DstPath )  and  Opt <> c.CopyV4 Then
			dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		Else
			If Opt = c.CopyV4 Then  '// vbslib ver4
				dst_fo = DstPath
				dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
			Else  '// vbslib ver3 or c.CopyRen
				dst_fo = GetParentFullPath( DstPath )
				dst = DstPath
				If IsEmpty( Opt ) Then  ThisIsOldSpec  '// use move_ren
			End If
			If not g_fs.FolderExists( dst_fo ) Then
				g_AppKey.CheckWritable  SrcPath, Empty  '// If src cannot write, Don't make folder
				mkdir  dst_fo
			End If
		End If

		g_AppKey.CheckWritable  SrcPath, Empty
		If Opt = c.CopyV4 Then  '// vbslib ver4
			g_AppKey.CheckWritable  dst, Empty  '// "\." is for able to make writable folder
			del  dst  '// for Replace from folder to file
		Else
			If not g_fs.FileExists( dst ) Then
				g_AppKey.CheckWritable  dst + "\.", Empty  '// "\." is for able to make writable folder
			Else
				g_AppKey.CheckWritable  dst, Empty
				del  dst  '// for Replace from folder to file
			End If
		End If

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.MoveFile  SrcPath, dst
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, dst, c.File, n_retry ) Then  Exit Do
		Loop
		If en <> 0 Then  Err.Raise en,,ed


	' If SrcPath is folder
	ElseIf g_fs.FolderExists( SrcPath ) Then
		If g_debug_or_test Then
			g_AppKey.BreakByPath  SrcPath
			g_AppKey.BreakByPath  DstPath
		End If

		If not g_fs.FolderExists( DstPath ) Then  mkdir  DstPath

		If g_debug_or_test Then  g_AppKey.BreakByWildcard  SrcPath+"\*", c.File or c.SubFolder

		dst = GetFullPath( g_fs.GetFileName( SrcPath ), GetFullPath( DstPath, Empty ) )
		g_AppKey.CheckWritable  dst, Empty

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.MoveFolder  SrcPath, dst
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, dst, c.Folder, n_retry ) Then  Exit Do
		Loop
		If en <> 0 Then  Err.Raise en,,ed


	' not found
	Else
		echo  command_str & SrcPath & """, """ & DstPath & """"
		Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ SrcPath +"""/>"
	End If
End Sub


 
'*************************************************************************
'  <<< [ren] >>> 
'*************************************************************************
Sub  ren( src, dst )
	echo  ">ren  """ & src & """, """ & dst & """"
	Set c = g_VBS_Lib

	dst_name = g_fs.GetFileName( dst )

	If StrComp( g_fs.GetFileName( src ), dst_name, 1 ) = 0 Then  Exit Sub

	If g_fs.FileExists( src ) Then
		g_AppKey.CheckWritable  src, Empty
		Set f = g_fs.GetFile( src )
		flag = c.File
	Else
		g_AppKey.CheckWritable  src + "\.", Empty  '// "\." is for able to make writable folder
		Set f = g_fs.GetFolder( src )
		flag = c.Folder
	End If

	n_retry = 0
	Do
		On Error Resume Next
			f.Name = dst_name
		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If not IsWriteAccessDenied( en, src, flag, n_retry ) Then  Exit Do
	Loop
	If en <> 0 Then  Err.Raise en,,ed
End Sub


 
'*************************************************************************
'  <<< [ReplaceShortcutFilesToFiles] >>> 
'*************************************************************************
Sub  ReplaceShortcutFilesToFiles( Path, Option_ )
	Set c = g_VBS_Lib
	echo  ">ReplaceShortcutFilesToFiles  """+ Path +""""
	Set ec = new EchoOff

	ExpandWildcard  Path +"\*.lnk", c.File or c.SubFolder, folder, step_paths
	copy_count = 0
	not_copy_count = 0
	For Each step_path  In step_paths
		lnk_path = GetFullPath( step_path, folder )
		target_path = g_sh.CreateShortcut( lnk_path ).TargetPath
		If exist( target_path ) Then
			destination_path = AddLastOfFileName( lnk_path, "."+ _
				g_fs.GetExtensionName( target_path ) )


			If exist( destination_path ) Then
				count = 2
				Do
					path = AddLastOfFileName( destination_path, " ("& count &")" )
					If not exist( path ) Then _
						Exit Do
					count = count + 1
				Loop
				destination_path = path
			End If


			copy_ren  target_path, destination_path
				
			del  lnk_path
			copy_count = copy_count + 1
		Else
			not_copy_count = not_copy_count + 1
		End If
	Next
	ec = Empty

	echo  copy_count & "個のファイルをコピーしました。"
	If not_copy_count >= 1 Then
		echo  not_copy_count & "個のリンク先が見つかりませんでした。"
	End If
End Sub


 
'*************************************************************************
'  <<< [IsMovablePathToPath] >>> 
'*************************************************************************
Function  IsMovablePathToPath( SrcPath, DstPath, IsDstFolder )
	'// src = soruce, dst = destination, pos = position

	src_path = Replace( SrcPath, "/", "\" )
	dst_path = Replace( DstPath, "/", "\" )

	If not IsFullPath( src_path ) Then  src_path = g_fs.GetAbsolutePathName( src_path )
	If not IsFullPath( dst_path ) Then  dst_path = g_fs.GetAbsolutePathName( dst_path )
	If IsDstFolder Then  dst_path = GetFullPath( "a", dst_path )

	If Left( src_path, 2 ) = "\\" Then
		If Left( dst_path, 2 ) = "\\" Then
			slash_pos = InStr( 3, src_path, "\" )
			slash_pos = InStr( slash_pos + 1, src_path, "\" )
			IsMovablePathToPath = ( UCase( Left( src_path, slash_pos ) ) =_
				UCase( Left( dst_path, slash_pos ) ) )
		Else
			IsMovablePathToPath = False
		End If
	Else
		If Left( dst_path, 2 ) = "\\" Then
			IsMovablePathToPath = False
		Else
			IsMovablePathToPath = ( UCase( Left( src_path, 1 ) ) = _
				 UCase( Left( dst_path, 1 ) ) )
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [SafeFileUpdate] >>> 
'*************************************************************************
Sub  SafeFileUpdate( in_FromTemporaryFilePath,  in_ToUpdateFilePath )
	SafeFileUpdateEx  in_FromTemporaryFilePath,  in_ToUpdateFilePath,  g_VBS_Lib.ToTrashBox
End Sub


 
'*************************************************************************
'  <<< [SafeFileUpdateEx] >>> 
'*************************************************************************
Sub  SafeFileUpdateEx( in_FromTemporaryFilePath,  in_ToUpdateFilePath,  in_Option )
	echo  ">SafeFileUpdate  """ & in_FromTemporaryFilePath & """, """ & in_ToUpdateFilePath & """"
	If not g_fs.FileExists( in_ToUpdateFilePath ) Then

		move_ren  in_FromTemporaryFilePath,  in_ToUpdateFilePath

		Exit Sub
	Else
		For i=1 To 999
			back_up_path = GetParentFullPath( in_ToUpdateFilePath ) + "\" + _
				g_fs.GetBaseName( in_ToUpdateFilePath ) + "." & i & _
					"." + g_fs.GetExtensionName( in_ToUpdateFilePath ) + ".updating"
			If not exist( back_up_path ) Then  Exit For
		Next
		If exist( back_up_path ) Then _
			Err.Raise E_Other,,"バックアップのファイル名が作れません。：" + in_ToUpdateFilePath
		ErrCheck : On Error Resume Next

			g_fs.CopyFile  in_ToUpdateFilePath,  back_up_path,  False  '// Step-1

		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If en <> 0 Then  Err.Raise en,,"バックアップコピーに失敗しました。"+vbCRLF+_
			 "バックアップ元："+in_ToUpdateFilePath+vbCRLF+ _
			 "バックアップ先："+ back_up_path +vbCRLF+ ed
		If in_Option = g_VBS_Lib.ToTrashBox Then

			del_to_trashbox  back_up_path  '// Step-2

		End If

		g_AppKey.CheckWritable  in_ToUpdateFilePath,  Empty
		ErrCheck : On Error Resume Next

			g_fs.CopyFile  in_FromTemporaryFilePath,  in_ToUpdateFilePath,  True  '// Step-3

		en2 = Err.Number : ed2 = Err.Description : On Error GoTo 0
		If en2 = 0 Then
			ErrCheck : On Error Resume Next

				g_fs.DeleteFile  in_FromTemporaryFilePath,  True  '// Step-4

			en = Err.Number : ed = Err.Description : On Error GoTo 0
		End If

		If in_Option = g_VBS_Lib.ToTrashBox Then
		Else
			If en2 = 0 Then
				ErrCheck : On Error Resume Next

					g_fs.DeleteFile  back_up_path, True  '// Step-5

				en3 = Err.Number : ed = Err.Description : On Error GoTo 0
			End If
		End If

		If en2 <> 0 Then
			If in_Option = g_VBS_Lib.ToTrashBox Then
				sub_message = "必要ならゴミ箱に入れたコピー先のバックアップ ファイルを復活させてください。"
			Else
				sub_message = ""
			End If
			Err.Raise  en2,, ed2 + vbCRLF + _
				"上書きコピーに失敗しました。"+ sub_message + vbCRLF + _
				"コピー元："+ in_FromTemporaryFilePath + vbCRLF + _
				"コピー先："+ in_ToUpdateFilePath + vbCRLF + _
				"コピー先のバックアップ ファイル："+ back_up_path + vbCRLF
		End If

		If en <> 0  or  en3 <> 0 Then
			If en = 0 Then _
				en = en3
			message = ""
			If en <> 0 Then
				message = message + "一時ファイル："+ in_FromTemporaryFilePath +vbCRLF
			End If
			If en3 <> 0 Then
				message = message + "バックアップ・ファイル："+ back_up_path +vbCRLF
			End If

			Err.Raise  en,, "更新は成功しましたが、次のファイルの削除に失敗しました。"+vbCRLF+_
				 message + "更新済みファイル："+ in_ToUpdateFilePath +vbCRLF
		End If
	End If
End Sub


 
'*************************************************************************
'  <<< [del] >>> 
'*************************************************************************
Sub  del( ByVal path )
	If TypeName( path ) = "PathDictionaryClass" Then
		del_by_PathDictionaryClass  path

	' If path had Wild card
	Else
		echo  ">del  """ & path & """"
		Set ec = new EchoOff
		Set c = g_VBS_Lib

		If IsWildCard( path ) Then
			ExpandWildcard  path, c.File, folder, fnames
			For Each fname in fnames
				del  folder +"\"+ fname
			Next

			ExpandWildcard  path, c.Folder, folder, fnames
			For Each fname in fnames
				del  folder +"\"+ fname
			Next

		' If path was file or folder path
		Else

			If g_fs.FileExists( path ) Then
				g_AppKey.CheckWritable  path, Empty

				n_retry = 0
				Do
					ErrCheck : On Error Resume Next
						g_fs.DeleteFile  path, True
					en = Err.Number : ed = Err.Description : On Error GoTo 0
					If not IsWriteAccessDenied( en, path, c.File, n_retry ) Then  Exit Do
				Loop
				If en <> 0 Then  Err.Raise en,,ed
			ElseIf g_fs.FolderExists( path ) Then
				rmdir  path
			End If
		End If
	End If
End Sub


 
'*************************************************************************
'  <<< [del_subfolder] >>> 
'*************************************************************************
Sub  del_subfolder( path )
	Set c = g_VBS_Lib
	Set arr = new ArrayClass : arr.AddElems  path
	echo  ">del_subfolder  """ & arr.CSV & """"

	For i = 0  To arr.UBound_
		If Left( arr(i), 2 ) = "*\" Then _
			arr(i) = Mid( arr(i), 3 )
		If Right( arr(i), 2 ) = "\*" Then _
			arr(i) = Left( arr(i), Len( arr(i) ) - 2 )
	Next

	ExpandWildcard  arr.Items, c.File or c.Folder or c.SubFolder, folder, fnames
	For Each fname in fnames
		del  folder +"\"+ fname
	Next
End Sub


 
'*************************************************************************
'  <<< [del_to_trashbox] >>> 
'*************************************************************************
Sub  del_to_trashbox( path )
	If False Then
		'// 削除の確認メッセージを表示するとき、ユーザーの入力が必要になるため却下
		del_to_trashbox_old  path
	Else
		g_AppKey.CheckWritable  path + "\.", Empty  '// "\." is for able to make writable folder
		If exist( path ) Then
			folder_in_tmp = GetTempPath( "_RecycleBin\*" )
			If TryStart(e) Then  On Error Resume Next
				move  path,  folder_in_tmp
			If TryEnd Then  On Error GoTo 0
			If e.num = 70 Then  Err.Raise 17,,"ゴミ箱へ移動できません : " + path
			If e.num <> 0 Then  e.Raise
		End If
	End If
End Sub



Sub  del_to_trashbox_old( ByVal path )
	echo  ">del_to_trashbox  """ & path & """"
	Dim  ec : Set ec = new EchoOff
	Dim  en,ed
	Dim  sh_ap, TrashBox, folder, item, fname

	g_AppKey.CheckWritable  path + "\.", Empty  '// "\." is for able to make writable folder

	Set  sh_ap = CreateObject("Shell.Application")
	Const  ssfBITBUCKET = 10


	'//=== Check deletable by rename for Windows XP
	ErrCheck : On Error Resume Next
		ren  path, g_fs.GetFileName( path ) + "_deleting"
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 70 Then  Err.Raise 17,,"ゴミ箱へ移動できません : " + path
	If en = 76 Then  Exit Sub  ' not found path
	If en <> 0 Then  Err.Raise en,,ed
	ErrCheck : On Error Resume Next
		ren  path + "_deleting", g_fs.GetFileName( path )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 and en <> E_OutOfWritable Then  Err.Raise en,,ed


	'//=== move to trashbox
	path = g_fs.GetAbsolutePathName( path )
	fname = g_fs.GetFileName( path )
	Set  folder = sh_ap.NameSpace( g_fs.GetParentFolderName( path ) )
	If folder is Nothing Then  Exit Sub
	Set  item = folder.Items.Item( fname )
	If item is Nothing Then  Exit Sub

	Set  TrashBox = sh_ap.NameSpace( ssfBITBUCKET )
	TrashBox.MoveHere  item, &h40


	'//=== for Windows Vista
	' If exist( path ) Then  Err.Raise 17,,"ゴミ箱へ移動できません : " + path


	'//=== for Windows XP
	Do
		WScript.Sleep 300
		Set  item = folder.Items.Item( fname )
		If item is Nothing Then Exit Do
		item = Empty
	Loop
End Sub


 
'*************************************************************************
'  <<< [del_confirmed] >>> 
'*************************************************************************
Function  del_confirmed( Path )
	echo  ""
	If exist( Path ) Then
		r = input( "削除してよろしいですか？ : """ + Path + """ (Y/N)" )
		del_confirmed = ( r="Y" or r="y" )
		If del_confirmed Then  del  Path
	Else
		del_confirmed = True
	End If
End Function


 
'*************************************************************************
'  <<< [del_empty_folder] >>> 
'*************************************************************************
Sub  del_empty_folder( FolderPath )
	Dim  root_foler_paths,  root_folder_path,  folder_paths,  folder_path,  folder
	Dim  c : Set c = g_VBS_Lib

	If IsArray( FolderPath ) Then  root_foler_paths = FolderPath _
	Else  root_foler_paths = Array( FolderPath )

	For Each root_folder_path  In root_foler_paths
		echo  ">del_empty_folder  """+ root_folder_path +""""

		ExpandWildcard  root_folder_path+"\*", c.Folder or c.SubFolder or c.AbsPath,_
			Empty, folder_paths

		folder_paths = ArrayToNameOnlyClassArray( folder_paths )
		QuickSort  folder_paths, 0, UBound( folder_paths ), GetRef("LengthNameCompare"), -1

		ReDim Preserve  folder_paths( UBound( folder_paths ) + 1 )
		Set folder_paths( UBound( folder_paths ) ) = new NameOnlyClass
		folder_paths( UBound( folder_paths ) ).Name = GetFullPath( root_folder_path, Empty )

		For Each folder_path  In folder_paths
			If IsEmptyFolder( folder_path.Name ) Then
				g_fs.DeleteFolder  folder_path.Name
			End If
		Next
	Next
End Sub


 
'*************************************************************************
'  <<< [del_by_PathDictionaryClass] >>> 
'*************************************************************************
Sub  del_by_PathDictionaryClass( in_PathDictionary )
	count = 0

	For Each  step_path  In  in_PathDictionary.FilePaths
		del  GetFullPath( step_path, in_PathDictionary.BasePath )

		count = count + 1
		If count = 2 Then
			echo  ">del  ..."
			Set ec = new EchoOff
		End If
	Next

	For Each  step_path  In  in_PathDictionary.DeleteFolderPaths
		del  GetFullPath( step_path, in_PathDictionary.BasePath )
	Next
End Sub


 
'*************************************************************************
'  <<< [mkdir] >>> 
'*************************************************************************
Function  mkdir( ByVal Path )
	Dim  i, n, names(), fo2, n_retry, en, ed
	Dim  c : Set c = g_VBS_Lib

	If Right( Path, 2 ) = ":\" Then
		g_AppKey.CheckWritable  Path + ".",  c.ForMkDir
	Else
		g_AppKey.CheckWritable  Path + "\.",  c.ForMkDir
	End If

	If g_fs.FolderExists( Path ) Then  mkdir = 0 : Exit Function

	n = 0
	fo2 = g_fs.GetAbsolutePathName( Path )
	Do
		If g_fs.FolderExists( fo2 ) Then Exit Do

		n = n + 1
		Redim Preserve  names(n)
		names(n) = g_fs.GetFileName( fo2 )
		fo2 = g_fs.GetParentFolderName( fo2 )

		If fo2 = "" Then
			Raise  E_WriteAccessDenied, "<ERROR msg=""Cannot mkdir"" path="""+ Path +"""/>"
		End If
	Loop

	mkdir = n

	For n=n To 1 Step -1
		fo2 = GetFullPath( names(n), fo2 )

		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				g_fs.CreateFolder  fo2
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, path, c.File, n_retry ) Then  Exit Do
		Loop
		If en <> 0 Then
			If g_fs.FileExists( fo2 ) Then _
				Raise  E_AlreadyExist, "<ERROR msg=""ファイルが存在する場所にフォルダーを作成しようとしました"""+_
					" path="""+ fo2 +"""/>"
			Err.Raise en,,ed
		End If
	Next
End Function


 
'*************************************************************************
'  <<< [mkdir_for] >>> 
'*************************************************************************
Sub  mkdir_for( Path )
	Dim  s

	s = GetParentFullPath( Path )
	If s = "" Then  Exit Sub
	mkdir  s
End Sub


 
'*************************************************************************
'  <<< [rmdir] >>> 
'*************************************************************************
Sub  rmdir( ByVal Path )
	echo  ">rmdir  """ & Path & """"
	Set c = g_VBS_Lib

	If Not g_fs.FolderExists( Path ) Then Exit Sub
	g_AppKey.CheckWritable  Path + "\.", Empty  '// "\." is for able to make writable folder


	' Cut last \
	path2 = Path
	If Right( path2, 1 ) = "\" Then  path2 = Left( path2, Len( path2 ) - 1 )

	nFolder = 1
	ReDim folderPathes(nFolder)
	folderPathes(nFolder) = path2

	' Enum sub folders
	iFolder = 1
	While iFolder <= nFolder
		Set fo = g_fs.GetFolder( folderPathes(iFolder) )
		For Each subf in fo.SubFolders
			nFolder = nFolder + 1
			ReDim Preserve folderPathes(nFolder)
			folderPathes(nFolder) = subf.Path
		Next
		iFolder = iFolder + 1
	WEnd

	' Remove read only attribute of all files in sub folders
	For iFolder = 1 To nFolder
		Set fo = g_fs.GetFolder( folderPathes(iFolder) )
		For Each f in fo.Files
			Set file = g_fs.GetFile( f.Path )
			If g_debug_or_test Then  g_AppKey.BreakByPath( f.Path )
			file.Attributes = file.Attributes and not ReadOnly
		Next
	Next

	' Delete folders
	n_retry = 0
	Do
		ErrCheck : On Error Resume Next
			g_fs.DeleteFolder( Path )
		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If not IsWriteAccessDenied( en, Path, c.Folder, n_retry ) Then  Exit Do
	Loop
	If en <> 0 Then  Err.Raise en,,ed
End Sub


 
'*************************************************************************
'  <<< [exist] >>> 
'*************************************************************************
Function  exist( ByVal path )
	If IsWildcard( path ) Then
		Set c = g_VBS_Lib

		If TryStart(e) Then  On Error Resume Next
			ExpandWildcard  path, c.File or c.Folder, folder, fnames
		If TryEnd Then  On Error GoTo 0
		If e.Num = E_PathNotFound  Then  ReDim fnames(-1) : e.Clear
		If e.Num <> 0 Then  e.Raise

		exist = UBound( fnames ) <> -1
	Else
		exist = ( g_fs.FileExists( path ) = True ) Or ( g_fs.FolderExists( path ) = True )
	End If
End Function


 
'*************************************************************************
'  <<< [exist_ex] >>> 
'*************************************************************************
Function  exist_ex( Path, Opt )
	If IsEmpty( Opt ) Then
		exist_ex = exist( Path )
	Else
		If exist( Path ) Then
			cs_path = GetCaseSensitiveFullPath( Path )
			If Left( cs_path, 2 ) = "\\" Then
				full_path = GetFullPath( Path, Empty )
				root_pos = GetRootSeparatorPosition( full_path )
				full_path = LCase( Left( full_path, root_pos ) ) + _
					Mid( full_path, root_pos + 1 )

				exist_ex = ( cs_path = full_path )
			Else
				exist_ex = ( cs_path = GetFullPath( Path, Empty ) )
			End If
		Else
			exist_ex = False
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [IsEmptyFolder] >>> 
'*************************************************************************
Function  IsEmptyFolder( in_Path )
	IsEmptyFolder = False

	If g_fs.FolderExists( in_Path ) Then
		Set  folder = g_fs.GetFolder( in_Path )
		If folder.Files.Count = 0 Then
			If folder.SubFolders.Count = 0 Then
				IsEmptyFolder = True
			End If
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [GetCaseSensitiveFullPath] >>> 
'*************************************************************************
Function  GetCaseSensitiveFullPath( Path )
	If g_fs.FileExists( Path ) Then
		GetCaseSensitiveFullPath = g_fs.GetFile( Path ).Path
	ElseIf g_fs.FolderExists( Path ) Then
		GetCaseSensitiveFullPath = g_fs.GetFolder( Path ).Path
	Else
		GetCaseSensitiveFullPath = GetFullPath( Path, Empty )
	End If
End Function


 
'*************************************************************************
'  <<< [CheckExist] >>> 
'*************************************************************************
Sub  CheckExist( Path, Flags )
	Set c = g_VBS_Lib
	If Flags and c.File Then
		If not g_fs.FileExists( Path ) Then
			Raise  E_FileNotExist, "<ERROR msg='ファイルが見つかりません' path='"+ XmlAttrA( Path ) +"'/>"
		End If
	ElseIf Flags and c.Folder Then
		If not g_fs.FolderExists( Path ) Then
			Raise  E_PathNotFound, "<ERROR msg='フォルダーが見つかりません' path='"+ XmlAttrA( Path ) +"'/>"
		End If
	Else
		Error
	End If
End Sub


 
'*************************************************************************
'  <<< [fc] file compare as binary >>> 
' argument
'  - return : True=same, False=different
'*************************************************************************
Function  fc( path_a, path_b )
	fc = fc_r( path_a, path_b, "" )
End Function


 
'*************************************************************************
'  <<< [fc_r] file compare as binary >>> 
' argument
'  - return : True=same, False=different
'*************************************************************************
Function  fc_r( path_a, path_b, redirect_path )
	Dim  opt : Set opt = new fc_option : ErrCheck

	opt.FcResultRedirectPath = redirect_path
	fc_r = fc_ex( path_a, path_b, opt )
End Function


 
'*************************************************************************
'  <<< [fc_ex] file compare as binary >>> 
'*************************************************************************
Function  fc_ex( PathA, PathB, Opt )
	Dim  cmdline, opt_echo, redirect_path, b_stdout, is_compare_xml
	Dim  s, is_not_redir


	'//=== set cmdline from Opt.FcOptionIniPath
	cmdline = """" + g_vbslib_ver_folder + "feq.exe"""
	If not IsEmpty( Opt ) Then
		If not IsEmpty( Opt.FcOptionIniPath ) Then
			cmdline = cmdline + " /ini:""" + Opt.FcOptionIniPath + """"
			opt_echo = " /ini:" + g_fs.GetFileName( Opt.FcOptionIniPath )
		End If
		is_compare_xml = not Opt.IsXmlComparedAsBinary  and  not IsEmpty( Opt.IsXmlComparedAsBinary )
	End If
	cmdline = cmdline + " """ + PathA + """ """ + PathB + """"


	'//=== set redirect_path from Opt.FcResultRedirectPath
	If not IsEmpty( Opt ) Then
		redirect_path = Opt.FcResultRedirectPath
		b_stdout = Opt.m_bStdOut
	End If


	'//=== echo
	is_not_redir = True : If Not IsEmpty( Opt ) Then  is_not_redir = (Opt.FcResultRedirectPath = "")
	If is_not_redir Then '// IsEmpty or
		echo  ">fc " + opt_echo + " """ + PathA + """, """ + PathB + """"
	End If


	If is_compare_xml Then
		Dim  root1, root2

		If not g_fs.FileExists( PathA )  or  not g_fs.FileExists( PathB ) Then
			If g_fs.FolderExists( PathA )  or  g_fs.FolderExists( PathB ) Then  Fail
			echo  "different"
			fc_ex = False
		Else
			Set root1 = LoadXML( PathA, Empty ) '// as IXMLDOMElement
			Set root2 = LoadXML( PathB, Empty ) '// as IXMLDOMElement
			fc_ex = ( root1.xml = root2.xml )
			If fc_ex Then  echo  "same"  Else  echo  "different"
		End If
	Else
		'//=== Exec
		Dim  ex
		chk_exist_in_lib  "feq.exe"
		Set  ex = g_sh.Exec( cmdline )
		If not IsEmpty( redirect_path ) Then  redirect_path = g_sh.ExpandEnvironmentStrings( redirect_path )
		fc_ex = ( WaitForFinishAndRedirect( ex, redirect_path ) = 0 )

		If not is_not_redir Then
			s = ReadFile( redirect_path )
			Dim f : Set f = g_fs.OpenTextFile( redirect_path, 2, True, False )
			f.WriteLine  ">fc " + opt_echo + " """ + PathA + """, """ + PathB + """"
			f.Write      s
			f = Empty
		End If
	End IF
End Function


 
'*************************************************************************
'  <<< [fc_option] >>> 
'*************************************************************************
Class  fc_option
	Public  FcOptionIniPath
	Public  FcResultRedirectPath
	Public  IsXmlComparedAsBinary
	Public  m_bStdOut
End Class


 
'*************************************************************************
'  <<< [IsSameTextFile] >>> 
'*************************************************************************
Function  IsSameTextFile( PathA, PathB, in_out_Options )
	Set c = g_VBS_Lib

	echo  ">IsSameTextFile  """+ PathA +""", """+ PathB +""""
	'// is_debugging = ( InStr( PathA, ".txt" ) >= 1 )

	ParseOptionArguments  in_out_Options

	option_flags = in_out_Options( "Integer" )
	If in_out_Options.Exists("OptionsFor_IsSameTextFile_Class") Then
		Set options = in_out_Options("OptionsFor_IsSameTextFile_Class")
	Else
		Set options = new OptionsFor_IsSameTextFile_Class
	End If

	Set in_out_Options( "PercentStringClass" ) = new PercentStringClass

	If option_flags and c.ErrorIfNotSame Then
		is_err_if_not_same = True
		option_flags = option_flags - c.ErrorIfNotSame
	End If

	If option_flags and c.CaseSensitive Then
		strcomp_opt = 0
		option_flags = option_flags - c.CaseSensitive
	Else
		strcomp_opt = 1
	End If

	err_msg = ""

	If option_flags = 0 Then
		Dim  text1, text2


		If is_debugging Then
			Stop:OrError
		End If


		Set cs1 = new_TextFileCharSetStack( options.CharSetA )
		text1 = ReadFile( PathA ) : text1 = Replace( text1, vbCRLF, vbLF )
		cs1 = Empty

		Set cs2 = new_TextFileCharSetStack( options.CharSetB )
		text2 = ReadFile( PathB ) : text2 = Replace( text2, vbCRLF, vbLF )
		cs2 = Empty

		If in_out_Options.Exists( "StringReplaceSetClass" ) Then
			Set rep = in_out_Options( "StringReplaceSetClass" )
			text1 = rep.DoReplace( text1 )
			text2 = rep.DoReplace( text2 )
		End If


		IsSameTextFile = ( StrComp( text1, text2, strcomp_opt ) = 0 )


		If not IsSameTextFile Then
		If is_err_if_not_same Then

			Set f  = new StringStream :  f.SetString  text1
			Set f2 = new StringStream : f2.SetString  text2

			Do Until f.AtEndOfStream
				line = f.ReadLine() : line2 = f2.ReadLine()
				If line <> line2 Then  Exit Do
			Loop
			Raise  E_TestFail, "<ERROR msg=""Not Same"" file1="""+_
				PathA +""" file2="""+ PathB +""" line=""" & ( f.Line - 1 ) & """/>"
		End If
		End If
	Else
		IsSameTextFile = False
		base_path = GetParentFullPath( PathB )

		Set cs1 = new_TextFileCharSetStack( options.CharSetA )
		Set cs2 = new_TextFileCharSetStack( options.CharSetB )

		Set f  = OpenForRead( PathA )
		Set f2 = OpenForRead( PathB )
		Do Until  f.AtEndOfStream


			If is_debugging Then
				If f.Line >= 5 Then
					'// Stop:OrError
					g_debug_var(1) = 1
				End If
				previous_line = f2.Line
			End If


			line = f.ReadLine()
			If IsEmpty( multi_line ) Then
				If f2.AtEndOfStream Then
					If is_err_if_not_same Then
						Raise  E_TestFail, "<ERROR msg=""Not Same"" file1="""+ PathA +_
							""" file2="""+ PathB +_
							""" line1_num=""" & ( f.Line - 1 ) & _
							""" line2_num=""" & ( f2.Line - 1 ) & _
							""" msg2=""file2 の全体は file1 の途中までと同じです""/>"
					End If
					Exit Function
				End If
				line2 = f2.ReadLine()
			End If

			If option_flags and c.RightHasPercentFunction Then

				'// read multi_line
				If StrCompHeadOf( line2, "%MultiLine%", Empty ) = 0 Then
						'// future is "%MultiLine(2)%%RegExp(var\[.\]=.*)%"

					multi_line = Mid( line2, Len("%MultiLine%") + 1 )
					If multi_line = "" Then  multi_line = "%RegExp(.*)%"
					If not f2.AtEndOfStream Then
						line2 = f2.ReadLine()
						Assert  StrCompHeadOf( line2, "%MultiLine%", Empty ) <> 0
					Else
						line2 = vbCRLF  '// not match any lines
					End If
				End If

				'// compare a line
				If TryStart(e) Then  On Error Resume Next

					is_same = IsSameTextLineByPercentFunction( _
						line,  line2,  base_path,  in_out_Options )

				If TryEnd Then  On Error GoTo 0
				If e.num <> 0  Then _
					is_err = True : Exit Do
				If is_same Then
					If not IsEmpty( multi_line ) Then _
						multi_line = Empty
				ElseIf IsEmpty( multi_line ) Then
					is_err = True : Exit Do

				'// compare multi_line
				Else
					If TryStart(e) Then  On Error Resume Next

						is_same = IsSameTextLineByPercentFunction( _
							line,  multi_line,  base_path,  in_out_Options )

					If TryEnd Then  On Error GoTo 0
					If e.num <> 0  Then _
						is_err = True : Exit Do
					If not is_same Then _
						is_err = True : Exit Do
				End If
				in_out_Options( "PercentStringClass" ).ExpandedString = Empty
			Else
				While  StrComp( text1, text2, strcomp_opt ) <> 0
					If option_flags = c.SkipLeftSpaceLine Then
						If Trim2( line ) <> "" Then  is_err = True : Exit Do
						If f.AtEndOfStream Then  is_err = True : Exit Do
						line = f.ReadLine()
					Else
						is_err = True : Exit Do
					End If
				WEnd
			End If
		Loop

		If IsEmpty( is_err ) Then
			If IsEmpty( multi_line ) Then
				If not f2.AtEndOfStream Then
					is_err = True
					err_msg = "msg2=""file1 の全体は file2 の途中までと同じです"""+ vbCRLF
				End If
			ElseIf line2 = vbCRLF Then
				is_err = False
			Else
				is_err = True
				err_msg = "msg2=""%MultiLine% の次の行(next_line)が見つかりません"" next_line="""+ _
					XmlAttr( line2 ) +""""+ vbCRLF
			End If
		End If

		If is_err Then
			If is_err_if_not_same Then
				If IsEmpty( in_out_Options( "PercentStringClass" ).ExpandedString ) Then
					line2_expanded_message = "line2="
				Else
					line2_expanded_message = "line2="""+ XmlAttr( _
						in_out_Options( "PercentStringClass" ).ExpandedString ) +""""+ _
						vbCRLF +"line2_source="
				End If

				error_message = "file1="""+ PathA +_
					""" file2="""+ PathB +""""+ vbCRLF + _
					"line1_num=""" & ( f.Line - 1 ) & _
					""" line2_num=""" & ( f2.Line - 1 ) & """"+ vbCRLF + _
					err_msg +"current_folder="""+ g_sh.CurrentDirectory +""""+ vbCRLF + _
					"line1="""+ XmlAttr( line ) +""""+ vbCRLF + _
					line2_expanded_message + _
					""""+ XmlAttr( line2 ) +""""

				and_ = ( TypeName( e ) = "Err"  or  TypeName( e ) = "Err2" )
				If and_ Then and_ = ( e.num <> 0 )
				If and_ Then
					error_message = AppendErrorMessage( e.Description, vbCRLF + error_message )
				ElseIf is_same Then
					error_message = "<ERROR "+ error_message +"/>"
				Else
					error_message = "<ERROR msg=""Not Same"" "+ error_message +"/>"
				End If

				Raise  E_TestFail,  error_message
			End If
			Exit Function
		End If
		IsSameTextFile = True
	End If
End Function


'//[IsSameTextFile_Old]
Function  IsSameTextFile_Old( PathA, CharSetA, PathB, CharSetB, in_out_Options )
	ThisIsOldSpec
	If IsEmpty( CharSetA )  and  IsEmpty( CharSetB ) Then
		IsSameTextFile_Old = IsSameTextFile( PathA, PathB, in_out_Options )
	Else
		Set proxy_options = new OptionsFor_IsSameTextFile_Class
		proxy_options.CharSetA = CharSetA
		proxy_options.CharSetB = CharSetB
		IsSameTextFile_Old = IsSameTextFile( PathA, PathB, Array( proxy_options, in_out_Options ) )
	End If
End Function


 
'*************************************************************************
'  <<< [OptionsFor_IsSameTextFile_Class] >>> 
'*************************************************************************
Class  OptionsFor_IsSameTextFile_Class
	Public  CharSetA
	Public  CharSetB
End Class


 
'*************************************************************************
'  <<< [IsSameTextLineByPercentFunction] >>> 
'*************************************************************************
Function  IsSameTextLineByPercentFunction( in_TextA,  in_TextBWithPercent,  in_BasePath,  in_out_Options )
	Set c = g_VBS_Lib

	option_flags = in_out_Options( "Integer" )

	If option_flags and c.CaseSensitive Then  strcomp_opt = 0  Else  strcomp_opt = 1

	If g_debug_var(1) = 1 Then _
		Stop:OrError

	If InStr( in_TextBWithPercent, "%" ) = 0 Then _
		IsSameTextLineByPercentFunction = ( in_TextA = in_TextBWithPercent ) : Exit Function '//Stop_

	IsSameTextLineByPercentFunction = False

	line = in_TextBWithPercent

	Do
		p1 = InStr( 1, line, "%FullPath(", 1 ) : length = 10
		If p1 = 0 Then  p1 = InStr( line, "%AbsPath(" ) : length = 9
		If p1 = 0 Then  Exit Do
		p2 = InStr( p1 + length, line, ")%" )
		path = Mid( line,  p1 + length,  p2 - p1 - length )
		path = GetFullPath( path, GetFullPath( in_BasePath,  Empty ) )
		line = Left( line, p1 - 1 ) + path + Mid( line, p2 + 2 )
	Loop

	line = Replace( line, "%DesktopPath%", g_sh.SpecialFolders("Desktop"), 1, -1, 1 )

	Do
		p1 = InStr( 1, line, "%Env(", 1 ) : length = 5
		If p1 = 0 Then  Exit Do
		p2 = InStr( p1 + length, line, ")%" )
		environment_name = Mid( line,  p1 + length,  p2 - p1 - length )
		line = Left( line, p1 - 1 ) + env( "%"+ environment_name +"%" ) + Mid( line, p2 + 2 )
	Loop

	If in_out_Options.Exists( "PercentStringClass" ) Then
		If line <> in_TextBWithPercent Then _
			in_out_Options( "PercentStringClass" ).ExpandedString = line
	End If


	p1 = InStr( 1,  line,  "%RegExp(",  1 )
	If p1 = 0 Then
		line = Replace( line, "%%", "%" )
		If StrComp( in_TextA,  line,  strcomp_opt ) <> 0  Then  Exit Function '//Stop_
	Else
		'// Example:
		'// line = "left.....%RegExp(pattern...)%right"
		'//         ^p0      ^p1     ^p1_over  ^p2

		p0 = 1
		pattern = ""
		Do
			p1 = InStr( p0,  line,  "%RegExp(",  1 )
			If p1 = 0 Then _
				Exit Do

			pattern = pattern + ToRegExpPattern( Replace( Mid( line,  p0,  p1 - p0 ), "%%", "%" ) )
			p1_over = p1 + 8
			p2 = InStr( p1_over,  line,  ")%" )

			pattern = pattern + Mid( line,  p1_over,  p2 - p1_over )
			p0 = p2 + 2
		Loop

		pattern = pattern + ToRegExpPattern( Replace( Mid( line,  p0 ), "%%", "%" ) )

		Set re = CreateObject( "VBScript.RegExp" )
		re.Pattern = pattern
		re.Global = False

		If in_TextA <> "" Then
			If re.Replace( in_TextA, "" ) <> "" Then  Exit Function '//Stop_
		Else
			If not re.Test( "" ) Then  Exit Function '//Stop_
		End If
	End If

	IsSameTextLineByPercentFunction = True
End Function


'//[PercentStringClass]
Class  PercentStringClass
	Public  ExpandedString
End Class


 
'*************************************************************************
'  <<< [ADODB_Stream_loadFromFile] >>> 
'*************************************************************************
Sub  ADODB_Stream_loadFromFile( Stream, Path )
	AssertExist  Path

	If TryStart(e) Then  On Error Resume Next
		Stream.LoadFromFile  Path
	If TryEnd Then  On Error GoTo 0
	If e.num = 3002  Then
		e.OverRaise  e.num, _
			"<ERROR msg=""ファイルを開けません"" path="""+ GetFullPath( Path, Empty ) +"""/>"
	End If
	If e.num <> 0 Then  e.Raise
End Sub


 
'*************************************************************************
'  <<< [IsSameBinaryFile] >>> 
'*************************************************************************
Function  IsSameBinaryFile( PathA, PathB, Opt )

	If not g_fs.FileExists( PathA ) Then
		IsSameBinaryFile = not g_fs.FileExists( PathB )

		If g_fs.FolderExists( PathA ) Then _
			If g_fs.FolderExists( PathB ) Then _
				Error

		Exit Function
	Else
		If not g_fs.FileExists( PathB ) Then
			IsSameBinaryFile = False
			Exit Function
		End If
	End If


	If False Then
		Set ec = new EchoOff
		IsSameBinaryFile = fc_r( PathA, PathB, "" )
	Else
		Set f = CreateObject( "ADODB.Stream" )
		f.Type = 1

		f.Open
		ADODB_Stream_loadFromFile  f, NormalizePath( PathA )
		a_bin = f.Read( -1 )
		f.Close

		f.Open
		ADODB_Stream_loadFromFile  f, NormalizePath( PathB )
		b_bin = f.Read( -1 )
		f.Close

		IsSameBinaryFile = ( StrComp( a_bin, b_bin, 0 ) = 0 )  '// KB3116900 breaks it!

		If IsNull( IsSameBinaryFile ) Then
			IsSameBinaryFile = ( IsNull( a_bin )  and  IsNull( b_bin ) )
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [IsSameFolder] >>> 
'*************************************************************************
Function  IsSameFolder( PathA, PathB, in_out_Options )
	Set c = g_VBS_Lib

	echo  ">IsSameFolder  """+ PathA +""", """+ PathB +""""
	Set ec = new EchoOff

	ParseOptionArguments  in_out_Options

	option_flags = in_out_Options("integer")
	If in_out_Options.Exists("OptionsFor_IsSameFolder_Class") Then
		Set options = in_out_Options("OptionsFor_IsSameFolder_Class")
	Else
		Set options = new OptionsFor_IsSameFolder_Class
	End If
	If IsEmpty( options.IsSameFileFunction ) Then
		Set compare_function = GetRef( "IsSameBinaryFile" )
	Else
		Set compare_function = options.IsSameFileFunction
	End If


	'// Check exist root folders
	If exist( PathA ) Then
		If exist( PathB ) Then
			If g_fs.FileExists( PathA ) Then
				If g_fs.FileExists( PathB ) Then
					IsSameFolder = compare_function( PathA, PathB, _
						options.IsSameFileFunction_Parameter )
					If not IsSameFolder Then
						If IsBitSet( option_flags, c.EchoV_NotSame ) Then
							echo_v  "<ERROR msg=""ファイルの内容が異なります"" "+_
								"path_A="""+ PathA +""" path_B="""+ PathB +"""/>"
						End If
					End If
				Else
					IsSameFolder = False
					If IsBitSet( option_flags, c.EchoV_NotSame ) Then
							echo_v  "<ERROR msg=""ファイルとフォルダーの違いがあります"" "+_
						"path_A="""+ PathA +""" path_B="""+ PathB +"""/>"
					End If
				End If
				Exit Function
			Else
				If g_fs.FileExists( PathB ) Then
					IsSameFolder = False
					If IsBitSet( option_flags, c.EchoV_NotSame ) Then
						echo_v  "<ERROR msg=""ファイルとフォルダーの違いがあります"" "+_
							"path_A="""+ PathA +""" path_B="""+ PathB +"""/>"
					End If
					Exit Function
				Else
				End If
			End If
		Else
			If IsBitSet( option_flags, c.EchoV_NotSame ) Then
				echo_v  "<ERROR msg=""見つかりません"" "+_
					"path="""+ PathB +"""/>"
			End If

			IsSameFolder = False
			Exit Function
		End If
	Else
		If exist( PathB ) Then
			If IsBitSet( option_flags, c.EchoV_NotSame ) Then
				echo_v  "<ERROR msg=""見つかりません"" "+_
					"path="""+ PathA +"""/>"
			End If

			IsSameFolder = False
		Else
			If IsBitSet( option_flags, c.ErrorIfNotExistBoth ) Then
				Raise  E_PathNotFound, "<ERROR msg=""両方とも見つかりません"" "+_
					"path_A="""+ PathA +""" path_B="""+ PathB +"""/>"
			Else
				IsSameFolder = True
			End If
		End If
		Exit Function
	End If


	'// Compare file contents at root
	is_same_type = True
	If g_fs.FileExists( PathA ) Then
		If g_fs.FileExists( PathB ) Then
			If IsSameBinaryFile( PathA, PathB, Empty ) Then
				IsSameFolder = True
			Else
				If IsBitSet( option_flags, c.EchoV_NotSame ) Then
					echo_v  "<ERROR msg=""ファイルの内容が異なります"" "+_
						"path_A="""+ PathA +""" path_B="""+ PathB +"""/>"
				End If

				IsSameFolder = False
			End If
			Exit Function
		Else
			is_same_type = False
		End If
	Else
		If g_fs.FileExists( PathB ) Then
			is_same_type = False
		Else
		End If
	End If
	If not is_same_type Then
		If IsBitSet( option_flags, c.EchoV_NotSame ) Then
			echo_v  "<ERROR msg=""ファイルとフォルダーの違いがあります"" "+_
				"path_A="""+ PathA +""" path_B="""+ PathB +"""/>"
		End If

		IsSameFolder = False
		Exit Function
	End If


	'// Set "except_reg_exps"
	If IsEmpty( options.ExceptNames ) Then
		except_reg_exps = Array( )
	Else
		ReDim  except_reg_exps( UBound( options.ExceptNames ) )
		i = 0
		For Each name  In options.ExceptNames
			Set re = CreateObject("VBScript.RegExp")
			re.Pattern = name
			re.IgnoreCase = True

			Set except_reg_exps( i ) = re
			i = i + 1
		Next
	End If


	'// Compare folder exists
	If IsBitSet( option_flags, c.NotSubFolder ) Then
		Set  folders_A = CreateObject( "Scripting.Dictionary" )
		folders_A.Add  ".", g_fs.GetFolder( PathA )
		Set  folders_B = CreateObject( "Scripting.Dictionary" )
		folders_B.Add  ".", g_fs.GetFolder( PathB )
	Else
		EnumFolderObjectDic  PathA, Empty, folders_A  '// [out] folders_A
		EnumFolderObjectDic  PathB, Empty, folders_B  '// [out] folders_B
	End If

	IsSameFolder_removeExceptInDic_Sub  folders_A, except_reg_exps
	IsSameFolder_removeExceptInDic_Sub  folders_B, except_reg_exps

	If IsSameFolder_isExistOneSideOnly_Sub( PathA, PathB, folders_A, folders_B, in_out_Options ) Then
		IsSameFolder = False
		Exit Function
	End If


	'// Compare file exists
	For Each  step_path  In folders_A.Keys
		step_path_A = PathA +"\"+ step_path
		step_path_B = PathB +"\"+ step_path
		Set folder_A = folders_A( step_path )
		Set folder_B = folders_B( step_path )

		EnumFileObjectDic  folder_A, files_A  '// [out] files_A
		EnumFileObjectDic  folder_B, files_B  '// [out] files_B

		IsSameFolder_removeExceptInDic_Sub  files_A, except_reg_exps
		IsSameFolder_removeExceptInDic_Sub  files_B, except_reg_exps

		If IsSameFolder_isExistOneSideOnly_Sub( step_path_A, step_path_B, _
				files_A, files_B, in_out_Options ) Then
			IsSameFolder = False
			Exit Function
		End If


		'// Compare file contents in a folder
		For Each  file_name  In files_A.Keys
			If not compare_function( _
					step_path_A +"\"+ file_name, _
					step_path_B +"\"+ file_name, _
					options.IsSameFileFunction_Parameter ) Then
				If IsBitSet( option_flags, c.EchoV_NotSame ) Then
					echo_v  "<ERROR msg=""ファイルの内容が異なります"" "+_
						"path="""+ NormalizePath( step_path +"\"+ file_name ) +"""/>"
				End If

				IsSameFolder = False
				Exit Function
			End If
		Next
	Next

	IsSameFolder = True
End Function


'//[IsSameFolder_removeExceptInDic_Sub]
Sub  IsSameFolder_removeExceptInDic_Sub( a_Dictionary, ExceptRegExps )
	For Each step_path  In a_Dictionary.Keys
		For Each  re  In ExceptRegExps
			If re.Test( g_fs.GetFileName( step_path ) ) Then
				a_Dictionary.Remove  step_path
			End If
		Next
	Next
End Sub


'//[IsSameFolder_isExistOneSideOnly_Sub]
Function  IsSameFolder_isExistOneSideOnly_Sub( PathA, PathB, objects_A, objects_B, in_out_Options )
	Set c = g_VBS_Lib
	option_flags = in_out_Options("integer")

	For Each step_path  In objects_A.Keys
		If not objects_B.Exists( step_path ) Then
			If IsBitSet( option_flags, c.EchoV_NotSame ) Then
				echo_v  "<ERROR msg=""片方のフォルダーにしか存在しません"" "+_
					"found_path="""+ NormalizePath( PathA +"\"+ step_path ) +""" "+ _
					"not_found_path="""+ NormalizePath( PathB +"\"+ step_path ) +"""/>"
			End If

			IsSameFolder_isExistOneSideOnly_Sub = True
			Exit Function
		End If
	Next

	For Each step_path  In objects_B.Keys
		If not objects_A.Exists( step_path ) Then
			If IsBitSet( option_flags, c.EchoV_NotSame ) Then
				echo_v  "<ERROR msg=""片方のフォルダーにしか存在しません"" "+_
					"found_path="""+ NormalizePath( PathB +"\"+ step_path ) +""" "+ _
					"not_found_path="""+ NormalizePath( PathA +"\"+ step_path ) +"""/>"
			End If

			IsSameFolder_isExistOneSideOnly_Sub = True
			Exit Function
		End If
	Next

	IsSameFolder_isExistOneSideOnly_Sub = False
End Function


'//[IsSameFolder_Old]
Function  IsSameFolder_Old( PathA, PathB, Options_, ExceptNames )
	ThisIsOldSpec
	If not IsEmpty( ExceptNames ) Then
		Set proxy_options = new OptionsFor_IsSameFolder_Class
		proxy_options.ExceptNames = ExceptNames
		IsSameFolder_Old = IsSameFolder( PathA, PathB, Array( Options_, proxy_options ) )
	Else
		IsSameFolder_Old = IsSameFolder( PathA, PathB, Options_ )
	End If
End Function


 
'*************************************************************************
'  <<< [OptionsFor_IsSameFolder_Class] >>> 
'*************************************************************************
Class  OptionsFor_IsSameFolder_Class
	Public  ExceptNames
	Public  IsSameFileFunction
	Public  IsSameFileFunction_Parameter
End Class


 
'*************************************************************************
'  <<< [find] find lines including keyword >>> 
'*************************************************************************
Function  find( ByVal keyword, ByVal path )
	Dim  f, line, ret
	Set  f = g_fs.OpenTextFile( path,,,-2 )

	ret = ""
	Do Until f.AtEndOfStream
		line = f.ReadLine
		If InStr( line, keyword ) > 0 Then  ret = ret + line
	Loop

	f.Close

	find = ret
End Function


 
'*************************************************************************
'  <<< [find_c] find lines count including keyword >>> 
'*************************************************************************
Function  find_c( ByVal keyword, ByVal path )
	Dim  f, line, ret
	Set  f = g_fs.OpenTextFile( path,,,-2 )

	ret = 0
	Do Until f.AtEndOfStream
		line = f.ReadLine
		If InStr( line, keyword ) > 0 Then  ret = ret + 1
	Loop

	f.Close

	find_c = ret
End Function


 
'*************************************************************************
'  <<< [grep] >>> 
'*************************************************************************
Function  grep( ByVal  in_Params,  ByVal  in_OutPath )
	Set c = g_VBS_Lib

	out_is_empty = IsEmpty( in_OutPath )
	is_echo_start = True
	If IsNumeric( in_OutPath ) Then
		If in_OutPath = c.NotEchoStartCommand Then
			is_echo_start = False
			out_is_empty = True
		End If
	End If

	If is_echo_start Then
		If out_is_empty  or  in_OutPath = "" Then
			echo  ">grep "+ in_Params
		Else
			echo  ">grep "+ in_Params +" > """+ in_OutPath +""""
		End If
	End If


	'//=== 正規表現を置き換える
	params_arr = ArrayFromBashCmdLine( in_Params )  '// bash cmdline -> string

	For expr_pos = 0  To UBound( params_arr )
		Select Case  params_arr( expr_pos )
			Case  "-u", "-L", "-c"
				grep_unicode_sub  params_arr, in_OutPath, grep
				Exit Function
		End Select
	Next

	If out_is_empty Then
		in_OutPath = GetTempPath( "grep_out_*.txt" )
	End If

	For expr_pos = 0  To UBound( params_arr )
		If Left( params_arr( expr_pos ), 1 ) <> "-" Then  Exit For
	Next
	If expr_pos >= UBound( params_arr ) Then
		Raise  1, "grep のパラメーターが少ないです。"
	End If

	expression = params_arr( expr_pos )

	'// first char "/" -> "\/"
	If Left( expression, 1 ) = "/" Then  expression = "\"+ expression

	'// space /C option
	If InStr( expression, " " ) > 0 Then _
		expression = "/C:"+ expression

	'// "+" -> "*"
	plus_pos = InStr( expression, "+" )
	While  plus_pos > 0

		'// Set "not_meta_character"
		ReDim  not_meta_character( Len( expression ) )
		pos = 1
		Do
			pos = InStr( pos, expression, "\" )
			If pos = 0 Then  Exit Do
			not_meta_character( pos + 1 - 1 ) = True
			pos = pos + 2
		Loop

		'// Example:
		'//    expression = "aa[aaaaaaaaaaaaaaaaa]+aaa"
		'//                    ^start_of_repeat   ^plus_pos
		'//    expression = "aa[aaaaaaaaaaaaaaaaa][aaaaaaaaaaaaaaaaa]*aaa"

		'// Set "start_of_repeat"
		If Mid( expression, plus_pos - 1, 1 ) = "]"  and _
				not not_meta_character( plus_pos - 1 - 1 ) Then
			pos = plus_pos
			Do
				pos = InStrRev( expression, "[", pos )
				Assert  pos > 0  '// Many "]"
				If not not_meta_character( pos - 1 ) Then _
					Exit Do
				pos = pos - 1
			Loop
			start_of_repeat = pos
		Else
			start_of_repeat = plus_pos - 1
		End If

		'// Set "expression"
		expression = Left( expression,  plus_pos - 1 ) + _
			Mid( expression,  start_of_repeat,  plus_pos - start_of_repeat ) + _
			"*" + _
			Mid( expression,  plus_pos + 1 )

		'// Next
		plus_pos = InStr( plus_pos, expression, "+" )
	WEnd

	'// "|" vertical line
	expression = Replace( expression, "\|", "\v" )
	expression = Replace( expression, "|", " " )
	expression = Replace( expression, "\v", "|" )

	'// Set "expression"
	If expression = "" Then  Raise  1, "検索キーワードがありません。"
	If InStr( expression, vbLF ) > 0 Then  Raise  1, "検索キーワードに改行があります。 -u オプションを指定してください"
	params_arr( expr_pos ) = expression


	'// target folder + "\*"
	target_path = params_arr( expr_pos + 1 )
	is_target_single_file = False
	If InStr( target_path, "*" ) = 0 Then
		If g_fs.FolderExists( target_path ) Then
			params_arr( expr_pos + 1 ) = target_path +"\*"
		ElseIf g_fs.FileExists( target_path ) Then
			is_exist_r = False
			For i = 0  To UBound( params_arr )
				If params_arr( i ) = "-r" Then _
					is_exist_r = True
			Next
			If not is_exist_r Then _
				is_target_single_file = True
		End If
	End If
	If LenK( target_path ) <> Len( target_path ) Then
		Raise  1, "Ascii 文字以外のファイルパスが指定されました。-u オプションを使ってください。"
	End If

	'// --include option
	For i = 0  To UBound( params_arr )
		If Left( params_arr( i ), 10 ) = "--include=" Then
			If InStr( target_path, "*" ) > 0 Then
				target_path = g_fs.GetParentFolderName( target_path )
				If target_path = "" Then
					params_arr( expr_pos + 1 ) = Mid( params_arr( i ), 11 )
				Else
					params_arr( expr_pos + 1 ) = target_path +"\"+ Mid( params_arr( i ), 11 )
				End If
			Else
				params_arr( expr_pos + 1 ) = target_path +"\"+ Mid( params_arr( i ), 11 )
			End If

			params_arr( i ) = ""
			Exit For
		End If
	Next


	'// Resume Params : string -> dos cmdline
	in_Params = CmdLineFromStr( params_arr )


	If g_is_debug Then  echo  ">>> "+ in_Params


	'//=== findstr を起動する
	in_Params = Replace( in_Params, "-i", "/I" )
	in_Params = Replace( in_Params, "-r", "/S" )
	in_Params = Replace( in_Params, "-l", "/M" )


	If in_OutPath <> "" Then _
		mkdir_for  in_OutPath


	is_use_safetee = False
	If out_is_empty Then
		If g_EchoObj.m_bEchoOff Then
			RunProg  "cmd /c findstr /R /N "+ in_Params +" > """+ in_OutPath +"""", c.NotEchoStartCommand
		Else
			is_use_safetee = True
		End If
	Else
		If in_OutPath = "" Then
			RunProg  "cmd /c findstr /R /N "+ in_Params, c.NotEchoStartCommand
		Else
			is_use_safetee = True
		End If
	End If
	If is_use_safetee Then
		AssertExist  g_vbslib_ver_folder +"safetee\safetee.exe"
		RunProg  "cmd /c findstr /R /N "+ in_Params +" | """+ g_vbslib_ver_folder +_
			"safetee\safetee.exe"" -o """+ in_OutPath +"""", c.NotEchoStartCommand
	End If


	'//=== findstr の出力を GrepFound クラスのメンバー変数に分配する
	If out_is_empty Then
		Set founds = new ArrayClass

		params_arr = ArrayFromCmdLine( in_Params )
		is_exist_colon = ( InStr( params_arr( UBound( params_arr ) ), ":" ) > 0 )
		is_exist_slashM = ( InStr( in_Params, "/M " ) > 0 )

		Set f = OpenForRead( in_OutPath )
		Do Until  f.AtEndOfStream
			line = f.ReadLine()
			If is_exist_slashM Then
				Set o = new GrepFound
					o.Path = line
				founds.Add  o
				o = Empty
			Else
				i = InStr( line, ":" )
				If is_exist_colon Then  i = InStr( i+1, line, ":" )
				If i > 0 Then
					i2 = InStr( i+1, line, ":" )
					If is_target_single_file Then _
						i2 = 0

					Set o = new GrepFound
					If i2 > 0 Then
						o.Path = Left( line, i-1 )
						o.LineNum = Mid( line, i+1, i2-i-1 )
						o.LineText = Mid( line, i2+1 )
					Else
						o.Path = target_path
						o.LineNum = Left( line, i-1 )
						o.LineText = Mid( line, i+1 )
					End If
					founds.Add  o
					o = Empty
				End If
			End If
		Loop
		f = Empty

		Set ec_= new EchoOff
		del  in_OutPath
	End If

	If not IsEmpty( founds ) Then
		grep = founds.Items
		If g_Vers("ExpandWildcard_Sort") Then  SortGrepFoundArray  grep
	End If
End Function


Class  GrepFound
	Public  Path  '// folder path in 2nd parameter in grep + step path
	Public  LineNum
	Public  LineText

	Public Sub  CalcLineCount()
		If IsArray( LineText ) Then
			text = ReadFile( Path )

			If IsEmpty( LineNum ) Then
				LineNum = GetLineCount( Left( text, LineText(0) ), Empty )
			End If

			text = Mid( text, LineText(0), LineText(1) - LineText(0) )
			LineText = text
		End If
	End Sub

	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		CalcLineCount
		xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" Path='"+ XmlAttrA( Path ) + _
			"' LineNum='"& XmlAttrA( LineNum ) &"'>"+ _
			LineText +"</"+TypeName(Me)+">"+ vbCRLF
	End Function
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [GrepClass] >>>> 
'-------------------------------------------------------------------------

Class  GrepClass
	Private  m_RegExp
	Public   IsRecurseSubFolders  '// as boolean. Ignored for PathDictionaryClass
	Public   IsOutFileNameOnly    '// as boolean
	Public   IsInvertMatch        '// as boolean
	Public   IsHitCount           '// as boolean

	Private Sub  Class_Initialize()
		Set m_RegExp = CreateObject("VBScript.RegExp")
		m_RegExp.MultiLine = True

		Me.IsRecurseSubFolders = False
		Me.IsOutFileNameOnly = False
		Me.IsInvertMatch = False
		Me.IsHitCount = False
	End Sub

	Public Property Let  Pattern( x ) : m_RegExp.Pattern = x : End Property
	Public Property Get  Pattern() : Pattern = m_RegExp.Pattern : End Property
	Public Property Let  IgnoreCase( x ) : m_RegExp.IgnoreCase = x : End Property
	Public Property Get  IgnoreCase() : IgnoreCase = m_RegExp.IgnoreCase : End Property
	Public Property Get  RegExp() : Set RegExp = m_RegExp : End Property


	Function  Execute( TargetPath )
		Set c = g_VBS_Lib
		out_founds = Array( )
		m_RegExp.Global = not Me.IsOutFileNameOnly

		If Me.IsRecurseSubFolders Then
			Set target_paths = ArrayFromWildcard( TargetPath )
		ElseIf TypeName( TargetPath ) = "PathDictionaryClass" Then
			Set target_paths = TargetPath
		Else
			If IsArray( TargetPath ) Then
				target_path_array = TargetPath
			Else
				target_path_array = Array( TargetPath )
			End If
			For index = 0  To UBound( target_path_array )
				target_path = target_path_array( index )

				CutLastOf  target_path, "\", c.CaseSensitive
				CutLastOf  target_path, "/", c.CaseSensitive

				'// Add ".\"
				sp = InStrEx( target_path, Array( "\", "/" ), 0, c.Rev )  '// Separator Position
				If sp = 0 Then
					target_path = ".\"+ target_path
				Else
					target_path = Left( target_path, sp ) +"."+ Mid( target_path, sp )
				End If

				target_path_array( index ) = target_path
			Next

			Set target_paths = ArrayFromWildcard( target_path_array )
		End If

		base_path = GetPathWithSeparator( target_paths.BasePath )
		For Each  target_path  In target_paths.FilePaths
			If IsFullPath( target_path ) Then
				target_full_path = target_path
			Else
				target_full_path = base_path + target_path
			End If

			Me.Execute_Sub  target_path,  target_full_path,  out_founds,  Empty
		Next

		If g_Vers("ExpandWildcard_Sort") Then  SortGrepFoundArray  out_founds

		Execute = out_founds
	End Function


	'// Share code with grep (unicode)
	Sub  Execute_Sub( target_path,  target_full_path,  out_founds,  out_file )
		Set c = g_VBS_Lib
		text = ReadFile( target_full_path )
		Set matches = m_RegExp.Execute( text )

		If Me.IsOutFileNameOnly Then
			found = Empty
			If not Me.IsInvertMatch  and  matches.Count >= 1 Then
				Set found = new GrepFound
			ElseIf Me.IsInvertMatch  and  matches.Count = 0 Then
				Set found = new GrepFound
			End If
			If not IsEmpty( found ) Then
				found.Path = target_path

				If not IsEmpty( out_founds ) Then
					ReDim Preserve  out_founds( UBound( out_founds ) + 1 )
					Set out_founds( UBound( out_founds ) ) = found
				End If

				echo  found.Path
				If not IsEmpty( out_file ) Then
					out_file.WriteLine  found.Path
				End If
			End If
		Else
			If not IsEmpty( out_founds ) Then
				old_ubound = UBound( out_founds )
				ReDim Preserve  out_founds( old_ubound + matches.Count )
			End If
			previous_line_num = -1

			For Each  match  In matches
				Set found = new GrepFound

				found.Path = target_path
				found.LineNum = GetLineCount( Left( text, match.FirstIndex ), Empty )

				If found.LineNum <> previous_line_num Then
						'// １行に複数ヒットしたときに複数作らないようにする
					previous_line_num = found.LineNum

					previous_lf = InStrRev( text, vbLF, match.FirstIndex + 1 )
					next_lf = InStr( match.FirstIndex + 1, text, vbLF )
					If next_lf = 0 Then  next_lf = Len( text ) + 1
					line = Mid( text, previous_lf + 1, next_lf - previous_lf - 2 )
					CutLastOf  line, vbCR, c.CaseSensitive
					found.LineText = line

					If not IsEmpty( out_founds ) Then
						old_ubound = old_ubound + 1
						Set out_founds( old_ubound ) = found
					End If

					line_string = found.Path +":" & found.LineNum & ":"+ line

					echo  line_string
					If not IsEmpty( out_file ) Then
						out_file.WriteLine  line_string
					End If
				End If
			Next
			If Me.IsHitCount  and  matches.Count = 0 Then
				Set found = new GrepFound

				found.Path = target_path
				found.LineNum = 0

				If not IsEmpty( out_founds ) Then
					old_ubound = old_ubound + 1
					ReDim Preserve  out_founds( old_ubound )
					Set out_founds( old_ubound ) = found
				End If

				line_string = found.Path +":" & found.LineNum & ":"

				echo  line_string
				If not IsEmpty( out_file ) Then
					out_file.WriteLine  line_string
				End If
			End If

			If not IsEmpty( out_founds ) Then
				If old_ubound < UBound( out_founds ) Then
					ReDim Preserve  out_founds( old_ubound )
				End If
			End If
		End If
	End Sub
End Class


 
Sub  grep_unicode_sub( params_arr, OutPath, out_founds )
	Set c = g_VBS_Lib

	Set a_grep = new GrepClass

	flags = c.File or c.FullPath
	unnamed_index = 0
	name_mask = "*"
	Set targets = new ArrayClass


	For Each a_parameter  In params_arr
		If a_parameter = "-u" Then
			'// ignore
		ElseIf a_parameter = "-r" Then
			flags = flags or c.SubFolderIfWildcard or c.NoError
		ElseIf a_parameter = "-i" Then
			a_grep.IgnoreCase = True
		ElseIf a_parameter = "-l" Then
			a_grep.IsOutFileNameOnly = True
			a_grep.IsInvertMatch = False
		ElseIf a_parameter = "-L" Then
			a_grep.IsOutFileNameOnly = True
			a_grep.IsInvertMatch = True
		ElseIf a_parameter = "-c" Then
			a_grep.IsHitCount = True
		ElseIf Left( a_parameter, 10 ) = "--include=" Then
			Assert  name_mask = "*"
			name_mask = MeltCmdLine( Mid( a_parameter, 11 ), 1 )
		Else
			Assert  Left( a_parameter, 1 ) <> "-"
			If unnamed_index = 0 Then
				expression = a_parameter
				If expression = "" Then  Raise  1, "検索キーワードがありません。"
			Else
				targets.Add  a_parameter
			End If
			unnamed_index = unnamed_index + 1
		End If
	Next


	If targets.Count = 0 Then
		Raise  1, "grep のパラメーターが少ないです。"
	End If
	ReDim  path_starts( targets.UBound_ )
	ReDim  path_heads( targets.UBound_ )

	path_start = Len( g_sh.CurrentDirectory ) + 2

	For index = 0 To targets.UBound_
		target_path = targets( index )

		base_path = ""
		If target_path = "*" Then
			target_path = name_mask
		Else
			If Right( target_path, 2 ) = "\*" Then
				target_path = Left( target_path, Len( target_path ) - 2 )
			ElseIf Right( target_path, 1 ) = "\" Then
				target_path = Left( target_path, Len( target_path ) - 1 )
			End If

			If not IsWildcard( target_path ) Then
				If g_fs.FolderExists( target_path ) Then
					base_path = target_path +"\"
					target_path = base_path + name_mask
				End If
			End If
		End If

		targets( index ) = target_path

		If IsFullPath( target_path ) Then
			path_starts( index ) = 1
			path_heads( index ) = ""
		ElseIf InStr( target_path, "\..\" ) = 0  and  Left( target_path, 3 ) <> "..\" Then
			path_starts( index ) = path_start
			path_heads( index ) = ""
		Else
			path_heads( index ) = g_fs.GetParentFolderName( target_path ) +"\"
			path_starts( index ) = Len( GetFullPath( path_heads( index ), Empty ) ) + 2
		End If
	Next


	a_grep.Pattern = expression
	a_grep.RegExp.Global = not a_grep.IsOutFileNameOnly
	out_founds = Array( )


	If VarType( OutPath ) = vbString  and  OutPath <> "" Then
		Set ec = new EchoOff
		Set out_file = OpenForWrite( OutPath, c.Unicode )
		ec = Empty
	Else
		out_file = Empty
	End If


	For index = 0 To targets.UBound_

		ExpandWildcard  targets( index ), flags, Empty, paths

		path_start = path_starts( index )
		path_head = path_heads( index )

		For Each  target_full_path  In paths
			target_path = path_head + Mid( target_full_path, path_start )

			a_grep.Execute_Sub  target_path,  target_full_path,  out_founds,  out_file
		Next
	Next

	If g_Vers("ExpandWildcard_Sort") Then  SortGrepFoundArray  out_founds

	echo  ""
End Sub


 
'*************************************************************************
'  <<< [SortGrepFoundArray] >>> 
'*************************************************************************
Sub  SortGrepFoundArray( GrepFounds )
	QuickSort  GrepFounds, 0, UBound( GrepFounds ), GetRef("SortGrepFoundArray_Sub"), Empty
End Sub

Function  SortGrepFoundArray_Sub( Left, Right, Param )
	sign = PathCompare( Left.Path, Right.Path, Param )
	If sign = 0 Then  sign = Left.LineNum - Right.LineNum
	SortGrepFoundArray_Sub = sign
End Function

 
'*************************************************************************
'  <<< [GrepKeyword] >>> 
'*************************************************************************
Function  GrepKeyword( Keyword )
	GrepKeyword = ToOldRegExpPattern( Keyword )
	GrepKeyword = Replace( GrepKeyword, "\", "\\" )
	If Left( Keyword, 1 ) = "-" Then  If Len( Keyword ) >= 2 Then _
		GrepKeyword = "\"+ GrepKeyword
End Function


 
'*************************************************************************
'  <<< [EGrepKeyword] >>> 
'*************************************************************************
Function  EGrepKeyword( Keyword )
	EGrepKeyword = ToRegExpPattern( Keyword )
	EGrepKeyword = Replace( EGrepKeyword, "\", "\\" )
	If Left( Keyword, 1 ) = "-" Then  If Len( Keyword ) >= 2 Then _
		EGrepKeyword = "\"+ EGrepKeyword
End Function


 
'*************************************************************************
'  <<< [GrepExpression] >>> 
'*************************************************************************
Function  GrepExpression( Keyword )
	GrepExpression = Keyword
	GrepExpression = Replace( GrepExpression, "\", "\\" )
	If Left( Keyword, 1 ) = "-" Then  If Len( Keyword ) >= 2 Then _
		GrepExpression = "\"+ GrepExpression
End Function


 
'*************************************************************************
'  <<< [sort] >>> 
'*************************************************************************
Sub  sort( InPath, OutPath )
	RunProg  "cmd /C sort """ + InPath + """ /o """ + OutPath + """", ""
End Sub


 
'*************************************************************************
'  <<< [CreateFile] >>> 
'*************************************************************************
Function  CreateFile( ByVal Path, ByVal Text )
	Dim  t,  f,  f2,  is_unicode,  folder,  n_retry,  org_path,  en, ed
	Dim  c : Set c = g_VBS_Lib
	Const  c_CannotWriteError = 3004

	If VarType( Text ) <> vbString Then _
		Text = CStr( Text )
	t = InStr( Text, vbCRLF )
	If t = 0 Then  t = Text+""""  Else  t = Left( Text, t-1 ) + """+vbCRLF+..."
	echo  ">CreateFile  """ & Path & """, """ & t

	If IsWildcard( Path ) Then _
		Path = GetTempPath( Path ) : echo  "Create  """ & Path & """"

	g_AppKey.CheckWritable  Path,  Empty

	If g_debug_or_test Then _
		g_AppKey.BreakByPath  Path

	If g_FileOptions.IsSafeFileUpdate Then
		org_path = Path
		Path = GetTempPath( "CreateFile_*.txt" )
	End If

	Dim  ec : Set ec = new EchoOff : ErrCheck

	Path = g_fs.GetAbsolutePathName( Path )
	folder = g_fs.GetParentFolderName( Path )
	If not g_fs.FolderExists( folder ) Then  mkdir  folder


	Select Case  g_FileOptions.CharSet
		Case  "unicode"                       : is_unicode = True
		Case  Empty, "shift_jis", "shift-jis" : is_unicode = False
		Case  Else
			Set f2 = CreateObject( "ADODB.Stream" )
			f2.Charset = g_FileOptions.CharSet
			f2.Open
			f2.WriteText  Text

			If g_FileOptions.CharSetEx = c.UTF_8_No_BOM Then
				f2.Position = 0
				f2.Type = 1  '// adTypeBinary
				f2.Position = 3  '// skip BOM
				t = f2.Read()  '// read all after BOM
				f2.Position = 0
				f2.Write  t
				f2.SetEOS
			End If
	End Select


	n_retry = 0
	Do
		ErrCheck : On Error Resume Next

			'//####################### main
			If IsEmpty( is_unicode ) Then
				f2.SaveToFile  Path, 2
				f2.Close
			Else
				Set f = g_fs.CreateTextFile( Path, True, is_unicode )
			End If

		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If not IsWriteAccessDenied( en, Path, c.File, n_retry ) Then  Exit Do
	Loop
	If en = c_CannotWriteError Then
		If ReadFile( Path ) = Text Then _
			en = 0
	End If
	If en <> 0 Then  Err.Raise en,,ed


	If not IsEmpty( f ) Then
		f.Write  Text
		f.Close
	End If


	If g_FileOptions.IsSafeFileUpdate Then
		SafeFileUpdate  Path, org_path
		del  Path
		Path = org_path
	End If

	CreateFile = Path
End Function


 
'*************************************************************************
'  <<< [touch] >>> 
'*************************************************************************
Sub  touch( Path )
	Set ec = new EchoOff
	If exist( Path ) Then
		g_AppKey.CheckWritable  Path, Empty
		r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" touch """+ Path +"""", "" )
		Assert  r = 0
	Else
		CreateFile  Path, ""
	End IF
End Sub


 
'*************************************************************************
'  <<< [SetDateLastModified_Old] >>>
'*************************************************************************
Sub  SetDateLastModified_Old( in_PathAndDate )
	Set ec = new EchoOff
	csv_path = GetTempPath( "SetDateLastModified_*.csv" )
	Set c = g_VBS_Lib
	Set csv_file = OpenForWrite( csv_path, c.Unicode )
	Set read_only_paths = new ArrayClass
	Set fin = new FinObj : fin.SetFunc "SetDateLastModified_Finally"
	fin.SetVar "read_only_paths", read_only_paths

	For Each  path  In  in_PathAndDate.Keys
		time_stamp = in_PathAndDate( path )

		AssertExist  path
		g_AppKey.CheckWritable  path, Empty
		If g_fs.GetFile( path ).Attributes and ReadOnly Then
			read_only_paths.Add  path

			Set file = g_fs.GetFile( path )
			file.Attributes = file.Attributes  and  not ReadOnly
			file = Empty
		End If

		Assert  VarType( time_stamp ) = vbDate
		time_stamp = W3CDTF( time_stamp )

		csv_file.WriteLine  path +","+ time_stamp
	Next
	csv_file = Empty

	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" SetDateLastModified """+ csv_path +"""", "" )
	Assert  r = 0

	del  csv_path
End Sub
 Sub  SetDateLastModified_Finally( Vars )
	en = Err.Number : ed = Err.Description : On Error Resume Next  '// This clears error

	Set read_only_paths = Vars.Item("read_only_paths")
	For Each  path  In  read_only_paths.Items
		Set file = g_fs.GetFile( path )
		file.Attributes = file.Attributes or ReadOnly
		file = Empty
	Next

	ErrorCheckInTerminate  en : On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
End Sub


 
'*************************************************************************
'  <<< [SetDateLastModified] >>> 
'*************************************************************************
Sub  SetDateLastModified( in_PathAndDate )
If g_is_vbslib_for_fast_user Then

	Set ec = new EchoOff
	csv_path = GetTempPath( "SetDateLastModified_*.csv" )
	log_path = GetTempPath( "SetDateLastModified_*.log" )
	Set c = g_VBS_Lib
	Set csv_file = OpenForWrite( csv_path, c.Unicode )

	For Each  path  In  in_PathAndDate.Keys
		time_stamp = in_PathAndDate( path )
		If VarType( time_stamp ) = vbDate Then _
			time_stamp = W3CDTF( time_stamp )
		g_AppKey.CheckWritable  path, Empty

		csv_file.WriteLine  path +","+ time_stamp
	Next
	csv_file = Empty

	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" SetDateLastModified """+ csv_path + _
		"""  /Log:"""+ log_path +"""", "" )
	If r <> 0 Then
		text = ReadFile( log_path )
		format = "<ERROR %s/>"
		text = Replace( format, "%s", sscanf( text, format ) )
		Raise  1, text
	End If

	del  csv_path
	del  log_path

Else
	SetDateLastModified_Old  in_PathAndDate
End If
End Sub


 
'***********************************************************************
'* Function: SetDateLastModifiedKS
'***********************************************************************
Sub  SetDateLastModifiedKS( in_PathAndDate,  in_Option )
	Set ec = new EchoOff
	is_set_time_stamp = ( IsEmpty( in_Option )  or  in_Option )
	Set path_and_date = CreateObject( "Scripting.Dictionary" )
	For Each  key  In  in_PathAndDate.Keys
		If g_Vers("TextFileExtension").Exists( g_fs.GetExtensionName( key ) ) Then
			a_date = in_PathAndDate( key )
			If VarType( a_date ) = vbString Then
				path_and_date( key ) = W3CDTF( a_date )
			Else
				path_and_date( key ) = a_date
			End If
		End If
	Next
	Set date_KS = CreateObject( "VBScript.RegExp" )
	date_KS.Pattern = "(\$Date::?)([^\$]*)\$"  '// KS = KeywordSubstitution


	For Each  path  In  path_and_date.Keys
		is_copy = ( InStr( path, "," ) >= 1 )
		If is_copy Then
			i = 1
			source_path      = MeltCSV( path, i )  '// Set "i"
			destination_path = MeltCSV( path, i )
		Else
			source_path      = path
			destination_path = path +".updating"
		End If

		If IsEmpty( path_and_date( path ) ) Then

			time_stamp = g_fs.GetFile( source_path ).DateLastModified
			If not is_copy Then
				path_and_date( path ) = time_stamp
			End If
		Else
			time_stamp = path_and_date( path )
		End If
		If is_copy Then
			path_and_date( destination_path ) = time_stamp
			path_and_date.Remove  path
		End If


		Set file = OpenForReplace( source_path,  destination_path )
		Set matches = date_KS.Execute( file.Text )
		If matches.Count >= 1 Then

			new_value = W3CDTF( time_stamp )

			Set match = matches(0)
			is_double_colon = ( Right( match.SubMatches(0), 2 ) = "::" )
			text = file.Text
			If not is_double_colon Then  '// "$Date:"

				text = Left( text,  match.FirstIndex ) + _
					match.SubMatches(0) +" "+ new_value +" $" + _
					Mid( text,  match.FirstIndex + 1 + match.Length )

			Else  '// "$Date::"
				count_of_spaces = Len( match.SubMatches(1) ) - Len( new_value ) - 1
				If count_of_spaces < 0 Then _
					count_of_spaces = 0

				text = Left( text,  match.FirstIndex ) + _
					match.SubMatches(0) +" "+ new_value + String( count_of_spaces, " " ) +"$" + _
					Mid( text,  match.FirstIndex + 1 + match.Length )
			End If
			file.Text = text
			file = Empty

			If not is_copy Then _
				SafeFileUpdateEx  destination_path,  source_path,  Empty

		Else  '// No "$Date"
			If not is_copy Then _
				file.IsSaveInTerminate = False
			file = Empty  '// Copy to "destination_path", if "is_copy".
		End If
	Next


	If is_set_time_stamp Then _
		SetDateLastModified  path_and_date
End Sub


 
'*************************************************************************
'  <<< [ReadFile] >>> 
'*************************************************************************
Function  ReadFile( Path )
	Set c = g_VBS_Lib

	If TypeName( Path ) = "FilePathClass" Then
		ReadFile = Path.Text
		Exit Function
	End If

	ReadFile = ""

	If StrComp( g_fs.GetFileName( Path ),  "nul",  1 ) = 0 Then _
		Exit Function

	ErrCheck : On Error Resume Next

		Select Case  g_FileOptions.CharSet
			Case  "unicode"
				Set f = g_fs.OpenTextFile( Path, 1, False, True )

			Case  Empty, "shift_jis", "shift-jis"
				Select Case  AnalyzeCharacterCodeSet( Path )
					Case  c.Unicode
						Set f = g_fs.OpenTextFile( Path, 1, False, True )
					Case  c.UTF_8
						Set cs = new_TextFileCharSetStack( "UTF-8" )
					Case  c.UTF_8_No_BOM
						Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
					Case  "ISO-8859-1"
						'// Use the following ADODB.Stream
					Case Else
						Set f = g_fs.OpenTextFile( Path, 1, False, False )
				End Select
		End Select

		If IsEmpty( f )  and  Err.Number = 0 Then
			Set f2 = CreateObject( "ADODB.Stream" )
			f2.Charset = g_FileOptions.CharSet
			f2.Open
			f2.LoadFromFile( Path )
		End If

	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_FileNotExist  or  en = E_PathNotFound  or _
		 en = E_EndOfFile  or  en = 3002  Then  Exit Function
			'// E_PathNotFound is not found parent folder
			'// 3002 is E_FileNotExist or E_PathNotFound from LoadFromFile

	If en <> 0 Then
		Raise  en, "<ERROR msg="""+ ed +""" path="""+ GetFullPath( GetEchoStr( Path ), Empty ) +"""/>"
	End If

	If IsEmpty( f2 ) Then
		ReadFile = ReadAll( f )
	Else
		ReadFile = f2.ReadText( -1 )  '// adReadAll
	End If
End Function


 
'*************************************************************************
'  <<< [ReadFileInTag] >>> 
'*************************************************************************
Function  ReadFileInTag( Path, StartOfText, EndOfText )
	ReadFileInTag = sscanf( ReadFile( Path ), StartOfText +"%s"+ EndOfText )
	While Left(  ReadFileInTag, 2 ) = vbCRLF : ReadFileInTag = Mid(  ReadFileInTag, 3 ) : WEnd
	While Right( ReadFileInTag, 2 ) = vbCRLF : ReadFileInTag = Left( ReadFileInTag, Len(ReadFileInTag) - 2 ) : WEnd
End Function


 
'*************************************************************************
'  <<< [type_] >>> 
'*************************************************************************
Sub  type_( Path )
	echo  ">type_  """ & Path & """"
	echo  ReadFile( Path )
End Sub


 
'*************************************************************************
'  <<< [OpenForRead] >>> 
'*************************************************************************
Function  OpenForRead( Path )
	Dim  f, f2, en, ed, cs
	Dim  c : Set c = g_VBS_Lib

	ErrCheck : On Error Resume Next

		Select Case  g_FileOptions.CharSet
			Case  "unicode"
				If IsEmpty( g_FileOptions.LineSeparator ) Then
					AssertExist  Path
					Set f = g_fs.OpenTextFile( Path, 1, False, True )
				Else
					Set cs = new_TextFileCharSetStack( "Unicode" )
				End IF

			Case  Empty, "shift_jis", "shift-jis"
				Select Case  AnalyzeCharacterCodeSet( Path )
					Case  c.Unicode
						If IsEmpty( g_FileOptions.LineSeparator ) Then
							Set f = g_fs.OpenTextFile( Path, 1, False, True )
						Else
							Set cs = new_TextFileCharSetStack( "Unicode" )
								'// to g_FileOptions.CharSet
						End IF
					Case  c.UTF_8
						Set cs = new_TextFileCharSetStack( "UTF-8" )
					Case  c.UTF_8_No_BOM
						Set cs = new_TextFileCharSetStack( "UTF-8-No-BOM" )
					Case Else
						If IsEmpty( g_FileOptions.LineSeparator ) Then
							Set f = g_fs.OpenTextFile( Path, 1, False, False )
						Else
							Set cs = new_TextFileCharSetStack( "Shift_JIS" )
						End If
				End Select
		End Select

		If IsNull( Path ) Then _
			Err.Raise  E_BadType,, "パスが指定されていません。 path=""""(Null)"
		If Path = "" Then _
			Err.Raise  E_BadType,, "パスが指定されていません。 path="""""

		If IsEmpty( f )  and  Err.Number = 0 Then
			AssertExist  Path
			Set f2 = CreateObject( "ADODB.Stream" )
			f2.Charset = g_FileOptions.CharSet
			f2.Open
			f2.LoadFromFile( Path )
		End If

	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_EndOfFile Then  en = 0  '// This is no problem, when FileSize=0
	If en <> 0 Then
		If en = 3002 Then
			If g_fs.FileExists( Path ) Then  en = E_ReadAccessDenied  Else  en = E_FileNotExist
				'// 3002 is E_FileNotExist or E_PathNotFound from LoadFromFile
		End If
		If en = E_FileNotExist  or  en = E_PathNotFound Then  ed = ed +" : "+ GetFullPath( Path, Empty )
		If en = E_ReadAccessDenied Then  ed = "アクセスが拒否されました。 : "+ GetFullPath( Path, Empty )
		Err.Raise en,,ed
	End If

	If not IsEmpty( f2 ) Then
		Set f = new TextStreamDelegateToADODBStream
		Set f.aADODBStream = f2
		If g_FileOptions.LineSeparator = g_VBS_Lib.KeepLineSeparators Then _
			f.LineSeparator = Empty  '// ReadLine, WriteLine の末尾に改行文字が付きます
		If IsEmpty( g_FileOptions.LineSeparator ) Then _
			f.LineSeparator = c.CutLineSeparators
	End If
	Set OpenForRead = f
End Function


 
'*************************************************************************
'  <<< [OpenForWrite] >>> 
'*************************************************************************
Function  OpenForWrite( ByVal Path, Flags )
	echo  ">OpenForWrite  """ & Path & """"
	Set c = g_VBS_Lib
	is_append  = ((Flags and c.Append)  = c.Append)

	If IsWildcard( Path ) Then  Path = GetTempPath( Path ) : echo  "Create  """ & Path & """"

	g_AppKey.CheckWritable  Path, Empty


	If is_append Then
		Select Case  AnalyzeCharacterCodeSet( Path )
			Case  c.Unicode : charset = "unicode"
			Case  c.UTF_8   : charset = "utf-8"
			Case  c.No_BOM  '// Do nothing
			Case  Empty    '// : is_append = False : Stop:OrError  '// TODO: 2016-11-08
		End Select
	End If

	If Flags and c.Shift_JIS Then    charset = "shift_jis"
	If Flags and c.Unicode Then      charset = "unicode"
	If Flags and c.UTF_8 Then        charset = "utf-8"
	If Flags and c.UTF_8_No_BOM Then charset = "utf-8-no-bom"
	If Flags and c.EUC_JP Then       charset = "euc-jp"
	If Flags and c.ISO_2022_JP Then  charset = "ISO-2022-JP"
	If not IsEmpty( charset ) Then  Set charset_stack = new_TextFileCharSetStack( charset )

	If IsEmpty( g_FileOptions.LineSeparator ) Then
		Select Case  g_FileOptions.CharSet
			Case  "unicode"                : is_unicode = True
			Case  "shift_jis", "shift-jis" : is_unicode = False
			Case  Empty
				Select Case  ReadUnicodeFileBOM( Path )
					Case  c.Unicode : is_unicode = True
					Case  c.UTF_8   : charset = "utf-8"
					Case  c.No_BOM  : is_unicode = False
					Case  Empty       '// Do nothing
				End Select
		End Select
	End If

	If IsEmpty( is_unicode ) Then
		If is_append Then
			Set o = CreateObject( "ADODB.Stream" )
			If IsEmpty( g_FileOptions.CharSet ) Then
				o.Charset = "_autodetect"
			Else
				o.Charset = g_FileOptions.CharSet
			End If
			o.Open
			ADODB_Stream_loadFromFile  o, Path
			text = o.ReadText( -1 )  '// -1 = adReadAll
			o.Close
		End If

		Set o = CreateObject( "ADODB.Stream" )
			If IsEmpty( g_FileOptions.CharSet ) or g_FileOptions.CharSet = "shift-jis" Then
				o.Charset = "shift_jis"
				'// Err.Number = E_NoObjectProvider(=3251) のエラーになるときは、
				'// 環境変数の値をチェックしてください
			Else
				o.Charset = g_FileOptions.CharSet
			End If
			o.Open
			If is_append Then  o.WriteText  text
		If not IsEmpty( g_FileOptions.LineSeparator ) Then _
			o.LineSeparator = g_VBS_Lib.LF
		Set OpenForWrite = new TextStreamDelegateToADODBStream
		Set OpenForWrite.aADODBStream = o
		OpenForWrite.WriteAbsPath = GetFullPath( Path, Empty )
		OpenForWrite.CharSetEx = g_FileOptions.CharSetEx
		OpenForWrite.LineSeparator = vbCRLF
	End If


	'//=== open
	n_retry = 0
	Do
		ErrCheck : On Error Resume Next

			If not IsEmpty( is_unicode ) Then
				If is_append Then
					Set OpenForWrite = g_fs.OpenTextFile( Path, 8, True, -2 )
				Else
					Set OpenForWrite = g_fs.CreateTextFile( Path, True, is_unicode )
				End If
			End If

		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If en = 0 Then  Exit Function
		If not IsWriteAccessDenied( en, Path, c.File, n_retry ) Then  Exit Do
	Loop


	'//=== create folder and open
	If en = E_PathNotFound Then
		Dim  fo : fo = g_fs.GetParentFolderName( Path )
		If not g_fs.FolderExists( fo ) Then
			mkdir  fo

			n_retry = 0
			Do
				ErrCheck : On Error Resume Next

					Set OpenForWrite = g_fs.CreateTextFile( Path, True, is_unicode )

				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If en = 0 Then  Exit Function
				If not IsWriteAccessDenied( en, Path, c.File, n_retry ) Then  Exit Do
			Loop
		End If
	End If
	Err.Raise en,,ed
End Function


 
'*************************************************************************
'  <<< [TextStreamDelegateToADODBStream] Class >>> 
'*************************************************************************
Class  TextStreamDelegateToADODBStream
	Public   aADODBStream
	Private  m_Line        '// as integer
	Public   WriteAbsPath  '// as string
	Public   CharSetEx     '// Empty, c.UTF_8_No_BOM
	Private  m_LineSeparator  '// for Property as vbCRLF or vbLF or Empty
	Private  m_ReadLineSeparator  '// as string

	Private Sub  Class_Initialize() : m_Line = 1 : m_LineSeparator = vbCRLF : End Sub
	Private Sub  Class_Terminate() : Me.Close : End Sub

	Public Function  Read( n )  : Read     = Me.aADODBStream.ReadText( n )  : Me.CountLine  Read : End Function
	Public Function  ReadAll()  : ReadAll  = Me.aADODBStream.ReadText( -1 ) : Me.CountLine  ReadAll : End Function

	Public Function  ReadLine()
		If m_ReadLineSeparator = "cut" Then
			ReadLine = Me.aADODBStream.ReadText( -2 )
			If Right( ReadLine, 1 ) = vbCR Then  ReadLine = Left( ReadLine, Len( ReadLine ) - 1 )
		Else
			ReadLine = Me.aADODBStream.ReadText( -2 ) + m_ReadLineSeparator
		End If
		m_Line = m_Line + 1
	End Function

	Public Sub  Skip( n )  : Me.aADODBStream.ReadText  n  :  m_Line = Empty : End Sub
	Public Sub  SkipLine() : Me.aADODBStream.SkipLine : m_Line = m_Line + 1 : End Sub

	Public Sub  Write( Text ) : Me.aADODBStream.WriteText  Text : Me.CountLine  Text : End Sub

	Public Sub  WriteLine( Text )
		If Right( Text, 1 ) = vbLF Then
			Me.aADODBStream.WriteText  Text, 0  '// 0=adWriteChar
			If m_LineSeparator = vbLF Then
				If Right( Text, 2 ) = vbCRLF Then  Me.LineSeparator = vbCRLF
			Else
				If Right( Text, 2 ) <> vbCRLF Then  Me.LineSeparator = vbLF
			End If
		Else
			Me.aADODBStream.WriteText  Text, 1  '// 1=adWriteLine
			m_Line = m_Line + 1
		End If
		Me.CountLine  Text
	End Sub

	Public Sub  WriteBlankLines( n )
		Dim i : For i=1 To n : Me.aADODBStream.WriteText  Me.LineSeparator, 0 : Next : m_Line = m_Line + n
	End Sub

	Public Sub  WriteLineDefault( ByVal Text )
		Text = Replace( Text, vbCRLF, vbLF )
		If m_LineSeparator = vbCRLF Then _
			Text = Replace( Text, vbLF, vbCRLF )
		Me.aADODBStream.WriteText  Text, 1  '// 1=adWriteLine
		Me.CountLine  Text
		m_Line = m_Line + 1
	End Sub

	Public Property Get  LineSeparator() : LineSeparator = m_LineSeparator : End Property
	Public Property Let  LineSeparator(x)
		Dim  c : Set c = g_VBS_Lib
		If x = vbCRLF Then
			Me.aADODBStream.LineSeparator = -1  '// -1=adCRLF
			m_ReadLineSeparator = ""
		ElseIf x = vbLF Then
			Me.aADODBStream.LineSeparator = 10  '// 10=adLF
			m_ReadLineSeparator = ""
		ElseIf x = c.CutLineSeparators Then
			Me.aADODBStream.LineSeparator = 10  '// 10=adLF
			m_ReadLineSeparator = "cut"
		Else
			Me.aADODBStream.LineSeparator = 10  '// 10=adLF
			m_ReadLineSeparator = vbLF
			x = Empty
		End If
		m_LineSeparator = x
	End Property

	Public Property Get  Line() : Line = m_Line : End Property
	Public Property Get  AtEndOfStream() : AtEndOfStream = aADODBStream.EOS : End Property

	Public Sub  CountLine( Text )
		If InStr( Text, vbLF ) = 0 Then  Exit Sub
		Dim  i : i = 1
		Do
			i = InStr( i, Text, vbLF )
			If i = 0 Then  Exit Sub
			m_Line = m_Line + 1
			i = i + 1
		Loop
	End Sub

	Public Function  Close()
		If not IsEmpty( Me.WriteAbsPath ) Then
			Dim  en,  ed,  n_retry,  o, t
			Dim  fo : fo = g_fs.GetParentFolderName( Me.WriteAbsPath )
			Dim  c : Set c = g_VBS_Lib

			If Me.CharSetEx = c.UTF_8_No_BOM Then
				Set o = Me.aADODBStream
					o.Position = 0
					o.Type = 1  '// adTypeBinary
					o.Position = 3  '// skip BOM
					t = o.Read()  '// read all after BOM
					o.Position = 0
					o.Write  t
					o.SetEOS
				o = Empty : t = Empty
			End If

			If not g_fs.FolderExists( fo ) Then  mkdir  fo

			n_retry = 0
			Do
				ErrCheck : On Error Resume Next

				Me.aADODBStream.SaveToFile  Me.WriteAbsPath, 2

				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If en = 0 Then  Exit Do
				If en = 3004 Then  en = E_WriteAccessDenied
				If not IsWriteAccessDenied( en, Me.WriteAbsPath, c.File, n_retry ) Then  Exit Do
			Loop
			If en <> 0 Then  Err.Raise en,,ed
			Me.WriteAbsPath = Empty
		End If

		If not IsEmpty( aADODBStream ) Then  aADODBStream.Close
		aADODBStream = Empty
	End Function
End Class


 
'*************************************************************************
'  <<< [GetTempPath] >>> 
'*************************************************************************
Class  TempFileClass
	Public  m_FolderPath
	Public  m_LimitDate
End Class

Dim  g_TempFile


Function  GetTempPath( Param )
	Set c = g_VBS_Lib

	'//=== Delete old files
	If not g_fs.FolderExists( g_TempFile.m_FolderPath ) Then _
		mkdir  g_TempFile.m_FolderPath

	Set fo = g_fs.GetFolder( g_TempFile.m_FolderPath )
	For Each f in fo.Files
		If f.DateLastModified < g_TempFile.m_LimitDate Then
			path = f.Path
			f.Attributes = f.Attributes  and  not ReadOnly
			n_retry = 0
			Do
				ErrCheck : On Error Resume Next
					g_fs.DeleteFile  path, True
				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, path, c.File, n_retry ) Then  Exit Do
			Loop
			If en <> 0 Then  Err.Raise en,,ed
		End If
	Next
	For Each f in fo.SubFolders
		If f.DateLastModified < g_TempFile.m_LimitDate Then
			path = f.Path
			SetReadOnlyAttribute  f, False
			n_retry = 0
			Do
				ErrCheck : On Error Resume Next
					g_fs.DeleteFolder  path
				en = Err.Number : ed = Err.Description : On Error GoTo 0
				If not IsWriteAccessDenied( en, path, c.Folder, n_retry ) Then  Exit Do
			Loop
			If en <> 0 Then  Err.Raise en,,ed
		End If
	Next


	'//=== path : Make unique path
	t = Now()
	param_abs = GetFullPath( Param, g_TempFile.m_FolderPath +"\"+ _
		Right( "0" & (Year(t) mod 100), 2 ) & _
		Right( "0" & Month(t), 2 )  &  Right( "0" & Day(t), 2 ) )

	t = Right( "0" & (Year(t) mod 100), 2 ) & _
		Right( "0" & Month(t), 2 )  &  Right( "0" & Day(t), 2 ) & "_" & _
		Right( "0" & Hour(t), 2 )  &  Right( "0" & Minute(t), 2 ) & "_"
	i = 1
	Do
		path = Replace( param_abs, "*", t & i )
		path = Replace( path, "?", i )
		If not exist( path ) Then  Exit Do
		i = i + 1
		If InStr( param_abs, "*" ) = 0  and  InStr( param_abs, "?" ) = 0 Then  Exit Do
	Loop
	GetTempPath = path
End Function


 
'*************************************************************************
'  <<< [get_TempFile] >>> 
'*************************************************************************
Sub  get_TempFile()
	If IsEmpty( g_TempFile ) Then
		Set g_TempFile = new TempFileClass : ErrCheck

		If IsDefined( "Setting_getTemp" ) Then
			Dim  out1, out2
			Setting_getTemp  out1, out2
			g_TempFile.m_FolderPath = out1
			g_TempFile.m_LimitDate = out2
		End If

		If IsEmpty( g_TempFile.m_FolderPath ) Then _
			g_TempFile.m_FolderPath = env( "%Temp%\Report" )
		If IsEmpty( g_TempFile.m_LimitDate ) Then _
			g_TempFile.m_LimitDate = DateAdd( "d", -2, Now() )

		If InStr( g_TempFile.m_FolderPath, "Temp" ) = 0 Then
			echo  "Not found ""Temp"" in temporary folder path in %Temp% or Setting_getTemp."
			echo  "Is this temporary folder path to delete? : " + g_TempFile.m_FolderPath
			echo  "これは削除してもよい一時フォルダのパスですか？ : " + g_TempFile.m_FolderPath
			pause
		End If
	End If
End Sub


 
'*************************************************************************
'  <<< [ReadAll] >>> 
'*************************************************************************
Function  ReadAll( FileStream )
	Dim  en, ed

	ReadAll = ""
	ErrCheck : On Error Resume Next
		ReadAll = FileStream.ReadAll()
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_EndOfFile Then  en = 0
	If en <> 0 Then  Err.Raise en,,ed
End Function


 
'*************************************************************************
'  <<< [ReadUnicodeFileBOM] >>> 
'*************************************************************************
Function  ReadUnicodeFileBOM( in_Path )
	Set c = g_VBS_Lib
	Const  adTypeBinary = 1
	Const  adReadLine = -2
	Const  adLF = 10

	If not g_fs.FileExists( in_Path ) Then _
		Exit Function
	size = g_fs.GetFile( in_Path ).Size
	If size <= 1 Then  ReadUnicodeFileBOM = c.No_BOM : Exit Function

	Set f = CreateObject( "ADODB.Stream" )
	f.Type = adTypeBinary
	f.Open
	ADODB_Stream_loadFromFile  f,  in_Path
	Dim byte0 : byte0 = CByte( AscB( f.Read( 1 ) ) )
	Dim byte1 : byte1 = CByte( AscB( f.Read( 1 ) ) )
	Dim byte2
	If size = 2 Then
		byte2 = 0
	Else
		byte2 = CByte( AscB( f.Read( 1 ) ) )
	End If

	If byte0 = &hEF  and  byte1 = &hBB  and  byte2 = &hBF Then
		ReadUnicodeFileBOM = c.UTF_8    '// EF BB BF

	ElseIf byte0 = &hFF  and  byte1 = &hFE Then
		ReadUnicodeFileBOM = c.Unicode  '// FF FE
	End If
	If IsEmpty( ReadUnicodeFileBOM ) Then
		If g_FileOptions.CharSet = "utf-8" Then
			ReadUnicodeFileBOM = c.UTF_8_No_BOM
		Else
			ReadUnicodeFileBOM = c.No_BOM
		End If
	End If
End Function


 
'***********************************************************************
'* Function: AnalyzeCharacterCodeSet
'***********************************************************************
Function  AnalyzeCharacterCodeSet( in_Path )
	Set c = g_VBS_Lib
	code_set = ReadUnicodeFileBOM( in_Path )

	If code_set = c.UTF_8  or  code_set = c.Unicode Then
		return_value = code_set

	ElseIf g_fs.FileExists( in_Path ) Then
		Set file = g_fs.OpenTextFile( in_Path )
		If not file.AtEndOfStream Then
			text = file.ReadLine()

			If Left( text, 5 ) = "<?xml" Then
				file = Empty

				Set f = CreateObject( "ADODB.Stream" )
				Set co = get_ADODBConsts()
				f.Charset = "ascii"
				f.Open
				f.LineSeparator = co.adLF
				f.LoadFromFile  in_Path

				text = f.ReadText( co.adReadLine )

				instruction = Left( text,  InStr( text, "?>" ) - 1 )
				instruction = "<_xml"+ Mid( instruction, 6 ) +"/>"
				Set root = LoadXML( instruction,  c.StringData )

				encoding = root.getAttribute( "encoding" )
				If IsNull( encoding ) Then
					return_value = c.No_BOM
				Else
					return_value = GetCharacterCodeSetFromString( encoding,  c.UTF_8_No_BOM )
				End If

			Else
				If not file.AtEndOfStream Then _
					text = text + vbCRLF + file.ReadAll()

				If InStr( text,  "Character Encoding:" ) = 0 Then

					If g_FileOptions.CharSet = "utf-8" Then
						return_value = c.UTF_8_No_BOM
					End If

				Else

					Set ec = new EchoOff
					Set  c = g_VBS_Lib
					Const  c_OEM          = 1
					Const  c_UTF_8        = 2
					Const  c_UTF_8_No_BOM = 3
					Const  c_UTF_16       = 4
					Const  c_XML          = 5
					vbs_helper_exe = g_vbslib_ver_folder + "vbslib_helper.exe"
					If not g_fs.FileExists( vbs_helper_exe ) Then
						Raise  1, "<ERROR  msg=""ファイルの文字コードの解析に exe ファイルが必要です。""  exe="""+ _
							vbs_helper_exe +"""  file="""+ GetFullPath( in_Path, Empty ) +"""/>"
					End If

					r= RunProg( """"+ vbs_helper_exe +"""  ReadCharacterEncodingCharacter  """+ _
						in_Path +"""",  "" )

					If r = c_OEM Then
						return_value = Empty
					ElseIf r = c_UTF_8_No_BOM Then
						return_value = c.UTF_8_No_BOM
					Else
						return_value = g_FileOptions.CharSet
					End If
				End If
			End If
		End If
	End If
	AnalyzeCharacterCodeSet = return_value
End Function


 
'***********************************************************************
'* Function: AnalyzeCharacterCodeSet_Old  TODO:
'***********************************************************************
Function  AnalyzeCharacterCodeSet_Old( in_Path )
	read_size = 8000
	Set ec = new EchoOff
	Set  c = g_VBS_Lib
	Const  c_OEM          = 1
	Const  c_UTF_8        = 2
	Const  c_UTF_8_No_BOM = 3
	Const  c_UTF_16       = 4
	Const  c_XML          = 5
	vbs_helper_exe = g_vbslib_ver_folder + "vbslib_helper.exe"

	r= RunProg( """"+ vbs_helper_exe +"""  ReadCharacterEncodingCharacter  """+ _
		in_Path +"""",  "" )

	If r = c_OEM Then
		return_value = Empty
	ElseIf r = c_UTF_8 Then
		return_value = c.UTF_8
	ElseIf r = c_UTF_8_No_BOM Then
		return_value = c.UTF_8_No_BOM
	ElseIf r = c_UTF_16 Then
		return_value = c.Unicode
	ElseIf r = c_XML Then

		Set f = CreateObject( "ADODB.Stream" )
		Set co = get_ADODBConsts()
		f.Charset = "ascii"
		f.Open
		f.LineSeparator = co.adLF
		f.LoadFromFile  in_Path

		line = f.ReadText( co.adReadLine )

		instruction = Left( line,  InStr( line, "?>" ) - 1 )
		instruction = "<_xml"+ Mid( instruction, 6 ) +"/>"
		Set root = LoadXML( instruction,  c.StringData )

		encoding = root.getAttribute( "encoding" )
		If IsNull( encoding ) Then
			return_value = c.No_BOM
		Else
			return_value = GetCharacterCodeSetFromString( encoding,  c.UTF_8_No_BOM )
		End If
	Else
		return_value = g_FileOptions.CharSet
	End If
	AnalyzeCharacterCodeSet = return_value
End Function


 
'********************************************************************************
'  <<< [GetStringFromCharacterCodeSet] >>> 
'********************************************************************************
Function  GetStringFromCharacterCodeSet( in_CharacterCodeSetConstant )
	If VarType( in_CharacterCodeSetConstant ) = vbString Then
		return_value = in_CharacterCodeSetConstant
	Else
		Set  c = g_VBS_Lib
		Select Case  in_CharacterCodeSetConstant
			Case  c.Shift_JIS,  c.No_BOM,  Empty
				return_value = "Shift_JIS"
			Case  c.EUC_JP
				return_value = "EUC-JP"
			Case  c.Unicode
				return_value = "Unicode"
			Case  c.UTF_8
				return_value = "UTF-8"
			Case  c.UTF_8_No_BOM
				return_value = "UTF-8-No-BOM"
			Case  c.ISO_2022_JP
				return_value = "ISO-2022-JP"
			Case Else
				Assert  False
		End Select
	End If
	GetStringFromCharacterCodeSet = return_value
End Function


 
'********************************************************************************
'  <<< [GetCharacterCodeSetFromString] >>> 
'********************************************************************************
Function  GetCharacterCodeSetFromString( in_CharacterCodeSetString,  in_UTF_8_CharacterCodeSet )
	If VarType( in_CharacterCodeSetString ) <> vbString Then
		return_value = in_CharacterCodeSetString
	Else
		Set  c = g_VBS_Lib
		If StrComp( in_CharacterCodeSetString,  "UTF-8",  1 ) = 0 Then
			return_value = in_UTF_8_CharacterCodeSet
		ElseIf StrComp( in_CharacterCodeSetString,  "UTF-8-BOM",  1 ) = 0 Then
			return_value = c.UTF_8
		ElseIf StrComp( in_CharacterCodeSetString,  "UTF-8-No-BOM",  1 ) = 0 Then
			return_value = c.UTF_8_No_BOM
		ElseIf StrComp( in_CharacterCodeSetString,  "Unicode",  1 ) = 0 Then
			return_value = c.Unicode
		ElseIf StrComp( in_CharacterCodeSetString,  "UTF-16",  1 ) = 0 Then
			return_value = c.Unicode
		ElseIf StrComp( in_CharacterCodeSetString,  "Shift_JIS",  1 ) = 0 Then
			return_value = c.Shift_JIS
		ElseIf StrComp( in_CharacterCodeSetString,  "EUC-JP",  1 ) = 0 Then
			return_value = c.EUC_JP
		ElseIf StrComp( in_CharacterCodeSetString,  "ISO-2022-JP",  1 ) = 0 Then
			return_value = c.ISO_2022_JP
		Else
			return_value = in_CharacterCodeSetString
		End If
	End If
	GetCharacterCodeSetFromString = return_value
End Function


 
'********************************************************************************
'  <<< [ReadVBS_Comment] >>> 
'********************************************************************************
Function  ReadVBS_Comment( ByVal Path, ByVal StartTag, ByVal EndTag, Opt )
	If IsEmpty( Path ) Then  Path = WScript.ScriptFullName
	ReadVBS_Comment = ""
	is_in_tag = False
	is_in_tag_once = False

	Set jumps = GetTagJumpParams( Path )
	If not IsEmpty( jumps.Keyword ) Then
		StartTag = "["+  jumps.Keyword +"]"
		EndTag   = "[/"+ jumps.Keyword +"]"
		If jumps.Path = "" Then  jumps.Path = WScript.ScriptFullName
	End If

	Set file = OpenForRead( jumps.Path )
	Do Until  file.AtEndOfStream
		line = file.ReadLine()
		If not is_in_tag Then
			If InStr( line, StartTag ) > 0 Then _
				is_in_tag = True : is_in_tag_once = True
		Else
			If not IsEmpty( EndTag ) Then  If InStr( line, EndTag ) > 0 Then _
				Exit Function

			If Left( line, 1 ) <> "'" Then _
				Exit Function


			ReadVBS_Comment = ReadVBS_Comment + Mid( line, 2 ) + vbCRLF
		End If
	Loop
	If not is_in_tag_once Then _
		Raise  1, "<ERROR msg=""見つかりません"" keyword="""+ StartTag +""" path="""+ Path +"""/>"

	If is_in_tag  and  not IsEmpty( EndTag ) Then _
		Raise  1, "<ERROR msg=""見つかりません"" keyword="""+ EndTag +""" path="""+ Path +"""/>"
End Function


 
'********************************************************************************
'  <<< [WriteVBS_Comment] >>> 
'********************************************************************************
Sub  WriteVBS_Comment( ByVal Path, StartTag, EndTag, Text, Opt )
	If IsEmpty( Path ) Then  Path = WScript.ScriptFullName

	c_text = "'"+ Replace( Text, vbLF, vbLF + "'" )  '// Commented text
	c_text = Left( c_text, Len( c_text ) - 1 )

	vbs_path = GetTempPath( "Overwriting_*.vbs" )
	Set rep = StartReplace( Path, vbs_path, True )
	Do Until  rep.r.AtEndOfStream
		SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf
		If not is_in_tag Then
			If InStr( line, StartTag ) > 0 Then
				is_in_tag = True : is_in_tag_once = True
			End If
			rep.w.WriteLine  line + cr_lf
		Else
			If not IsEmpty( EndTag ) Then  If InStr( line, EndTag ) > 0 Then _
				is_in_tag = False : Exit Do

			If Left( line, 1 ) <> "'" Then _
				Exit Do
		End If
	Loop

	rep.w.WriteLine  c_text
	rep.w.WriteLine  line + cr_lf

	Do Until  rep.r.AtEndOfStream
		SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf
		rep.w.WriteLine  line + cr_lf
	Loop

	If not is_in_tag_once Then _
		Raise  1, "<ERROR msg=""見つかりません"" keyword="""+ StartTag +""" path="""+ Path +"""/>"

	If is_in_tag  and  not IsEmpty( EndTag ) Then _
		Raise  1, "<ERROR msg=""見つかりません"" keyword="""+ EndTag +""" path="""+ Path +"""/>"

	rep = Empty

	SafeFileUpdateEx  vbs_path, Path, Empty
End Sub


 
'*************************************************************************
'  <<< [ReadLineSeparator] >>> 
'*************************************************************************
Function  ReadLineSeparator( Path )
	Dim  f, t, i, size

	If not g_fs.FileExists( Path ) Then  Exit Function

	size = g_fs.GetFile( Path ).Size : If size > 1000 Then  size = 1000

	Set f = g_fs.OpenTextFile( Path,,, -2 )
	t = f.Read( size )
	i = InStr( t, vbLF )
	If i = 0 Then
		'// ReadLineSeparator = Empty
	ElseIf i = 1 Then
		ReadLineSeparator = vbLF
	ElseIf Mid( t, i-1, 2 ) = vbCRLF Then
		ReadLineSeparator = vbCRLF
	Else
		ReadLineSeparator = vbLF
	End If
End Function


 
'*************************************************************************
'  <<< [Txt2BinTxt] >>> 
'*************************************************************************
Sub  Txt2BinTxt( SrcPath, DstPath )
	RunTxt2BinTxtExe  """"+SrcPath+""" """+DstPath+""""
End Sub


Sub  RunTxt2BinTxtExe( CmdLineParam )
	Dim  r
	Dim  txt2bintxt_exe : txt2bintxt_exe = g_vbslib_ver_folder + "txt2bintxt.exe"

	If not g_fs.FileExists( txt2bintxt_exe ) Then _
		Err.Raise  1,, "not found txt2bintxt.exe in vbslib folder"

	r = RunProg( """"+txt2bintxt_exe+""" "+ CmdLineParam, Empty )
	If r<>0 Then  Err.Raise  1,, "error 0x" & Hex(r) & " in txt2bintxt.exe"
End Sub


 
'*************************************************************************
'  <<< [ConvertTextFileCharSet] >>> 
'*************************************************************************
Sub  ConvertTextFileCharSet( FromPath, FromCharSet, ToPath, ToCharSet )
	RunTxt2BinTxtExe  "/From:"+ FromCharSet +" """+SrcPath+""" /To:"+ ToCharSet +" """+DstPath+""""
End Sub


 
'*************************************************************************
'  <<< [WriteVBSLibHeader] >>> 
'*************************************************************************
Sub  WriteVBSLibHeader( OutFileStream, Opt )
	Dim  file, line

	Set file = g_fs.OpenTextFile( WScript.ScriptFullName,,,-2 )
	Do Until file.AtEndOfStream

		line = file.ReadLine()

		If InStr( line, "g_CommandPrompt =" ) > 0 and not IsEmpty( Opt ) Then
			If not IsEmpty( Opt.m_OverCommandPrompt ) Then
				line = "  g_CommandPrompt = " & Opt.m_OverCommandPrompt
			End If
		End If
		If InStr( 1, line, "main(", 1 ) > 0 Then Exit Do
		If InStr( 1, line, "main2(", 1 ) > 0 Then Exit Do

		OutFileStream.WriteLine  line
	Loop
End Sub


Class  WriteVBSLibHeader_Option
	Public  m_OverCommandPrompt
End Class


 
'*************************************************************************
'  <<< [WriteVBSLibFooter] >>> 
'*************************************************************************
Sub  WriteVBSLibFooter( OutFileStream, Opt )
	Dim  file,  line,  i,  is_out,  is_main

	For i = 1  To 7
		OutFileStream.WriteLine  ""
	Next

	is_out = False

	Set file = g_fs.OpenTextFile( WScript.ScriptFullName,,,-2 )
	Do Until file.AtEndOfStream

		line = file.ReadLine()

		If InStr( 1, line, "g_CommandPrompt =", 1 ) > 0 and not IsEmpty( Opt ) Then
			If not IsEmpty( Opt.CommandPromptMode ) Then
				i = InStr( line, "=" )
				line = Left( line, i ) +" " & Opt.CommandPromptMode
			End If
		End If

		If InStr( 1, line, "main(", 1 ) > 0 Then   is_main = True
		If InStr( 1, line, "main2(", 1 ) > 0 Then  is_main = True

		If InStr( line, "--- start of "+"vbslib include ---" ) > 0 Then
				'// "+" is for avoid "PartRep" tool
			If is_main Then
				is_out = True
			Else
				Exit Do
			End If
		End If

		If is_out Then _
			OutFileStream.WriteLine  line
	Loop
End Sub


Class  WriteVBSLibFooter_Option
	Public  CommandPromptMode
End Class


 
'*************************************************************************
'  <<< [GetFullPath] >>> 
'*************************************************************************
Function  GetFullPath( StepPath, ByVal BasePath )
	Dim  i, ii, i3, sep_ch, path, cur, is_root

	If IsNull( StepPath ) Then  GetFullPath = Null : Exit Function
	If IsEmpty( StepPath ) Then  Exit Function
	If IsEmpty( BasePath ) Then  BasePath = g_sh.CurrentDirectory
	If not IsFullPath( BasePath ) Then _
		Raise E_Others, "GetFullPath の第2引数はフル・パスにしてください"
	If IsFullPath( StepPath ) Then  BasePath = Empty


	'//=== Joint and Replace to sep_ch
	sep_ch = GetFilePathSeparator( BasePath + StepPath )
	last_character = Right( BasePath, 1 )
	If last_character = "\"  or  last_character = "/"  or  IsEmpty( BasePath ) Then
		path = BasePath + StepPath
	Else
		path = BasePath + sep_ch + StepPath
	End If


	'// ...
	path = NormalizePath( path )


	'//=== Cut ... (SearchParent)
	If InStr( path, "..." ) > 0 Then
		i = InStr( path, sep_ch+"..."+sep_ch )
		If i = 0 Then
			If Left( path, 4 ) = "..."+sep_ch Then  i = 1
		Else
			i = i + 1
		End If
		If i > 0 Then
			Dim  ds_:Set ds_= new CurDirStack
			If i >= 2 Then  g_sh.CurrentDirectory = Left( path, i-2 )
			path = Mid( path, i+4 )
			Do
				cur = g_sh.CurrentDirectory
				is_root = ( InStr( cur, sep_ch ) = InStrRev( cur, sep_ch ) )  and  ( Right( cur, 1 ) = sep_ch )
				If exist( path ) Then
					If is_root Then
						path = g_sh.CurrentDirectory + path
					Else
						path = g_sh.CurrentDirectory +"\"+ path
					End If
					Exit Do
				End If
				If is_root Then  Err.Raise  E_PathNotFound
				g_sh.CurrentDirectory = ".."
			Loop
		End If
	End If


	If Right( path, 1 ) = ":" Then  path = path + sep_ch


	'(debug point) watch "path"

	GetFullPath = path
End Function


'//[GetAbsPath]
Function  GetAbsPath( StepPath, BasePath )
	GetAbsPath = GetFullPath( StepPath, BasePath )
	ThisIsOldSpec
End Function


 
'*************************************************************************
'  <<< [NormalizePath] >>> 
'*************************************************************************
Function  NormalizePath( ByVal Path )

	separator = GetFilePathSeparator( Path )


	'// Normalize separators
	If separator = "\" Then
		other_separator = "/"
	Else
		Assert  separator = "/"
		other_separator = "\"
	End If
	Path = Replace( Path, other_separator, separator )


	'// ...
	pos_root = GetRootSeparatorPosition( Path )


	'// Cut "\.\"
	Do
		i = InStr( Path, separator +"."+ separator )
		If i = 0 Then Exit Do
		Path = Left( Path, i ) + Mid( Path, i+3 )
	Loop
	While  Right( Path, 2 ) = separator+"."
		Path = Left( Path, Len(Path)-2 )
	WEnd
	While  Left( Path, 2 ) = "."+separator
		Path = Mid( Path, 3 )
	WEnd


	'// Cut "xxx\..\"
	pos_s1_s2 = 1  '// position of separator 1 to separator 2
	Do
		do_it = True

		pos_s1_s2 = InStr( pos_s1_s2, Path, separator+".."+separator )
		If pos_s1_s2 = 0 Then Exit Do

		pos_s0 = InStrRev( Path, separator, pos_s1_s2 - 1 )
		If pos_s0 < pos_root Then  Exit Do

		parent_name = Mid( Path,  pos_s0 + 1,  pos_s1_s2 - pos_s0 - 1 )
		If parent_name = ".." Then  do_it = False
		If parent_name = "" Then  do_it = False

		If do_it Then
			Path = Left( Path, pos_s0 ) + Mid( Path, pos_s1_s2 + 4 )
			pos_s1_s2 = pos_s0  '// Next of Separeor
			If pos_s0 = 0 Then Exit Do
		Else
			pos_s1_s2 = pos_s1_s2 + 3  '// Next of Separeor
		End If
	Loop


	'// Cut "\xxx\.."
	If Right( Path, 3 ) = separator + ".." Then
		pos_s1 = Len( Path ) - 2  '// position of separator 1
		If pos_s1 > pos_root Then
			pos_s0 = InStrRev( Path, separator, pos_s1 - 1 )
			If pos_s0 = pos_root Then
				If Mid( Path,  pos_s0 + 1,  pos_s1 - pos_s0 - 1 ) <> ".." Then
					If pos_s0 = 0 Then
						Path = "."
					Else
						Path = Left( Path, pos_root )
					End If
				End If
			ElseIf pos_s0 > pos_root Then
				If Mid( Path,  pos_s0 + 1,  pos_s1 - pos_s0 - 1 ) <> ".." Then
					Path = Left( Path, pos_s0 - 1 )
				End If
			End If
		End If
	End If


	'// Cut last "\"
	If Right( Path, 1 ) = "\" Then
		path_length = Len( Path )
		If path_length > pos_root Then
			Path = Left( Path, path_length - 1 )
		End If
	End If


	NormalizePath = Path
End Function


 
'*************************************************************************
'  <<< [GetRelativePath] >>> 
'*************************************************************************
Function  GetRelativePath( in_FullPath,  in_BasePath )
	GetRelativePath = GetStepPath( in_FullPath,  in_BasePath )
End Function


 
'*************************************************************************
'  <<< [GetStepPath] >>> 
' - in_FullPath, in_BasePath, (return) as string
'*************************************************************************
Function  GetStepPath( in_FullPath,  ByVal  in_BasePath )
	Dim  full_path_U,  base_path_U,  path,  sep_ch,  i, ii

	If IsNull( in_FullPath ) Then _
		GetStepPath = Null : Exit Function

	full_path_U = UCase( in_FullPath )
	If IsEmpty( in_BasePath ) Then _
		in_BasePath = g_sh.CurrentDirectory
	base_path_U = UCase( in_BasePath )

	sep_ch = GetFilePathSeparator( in_FullPath )


	'// path = common parent folder path. The last character is not sep_ch
	path = base_path_U
	If Right( base_path_U, 1 ) = sep_ch Then _
		path = Left( base_path_U, Len( base_path_U )-1 )
	Do
		path_length = Len(path)
		If path = Left( full_path_U, path_length ) Then
			If path = "" Then
				GetStepPath = in_FullPath
				Exit Function
			End If

			If Right( path, 1 ) = sep_ch Then
				path = Left( path, Len(path)-1 )
				Exit Do
			End If

			Select Case  Mid( full_path_U,  path_length + 1,  1 )
				Case  "\", "/", "" : Exit Do
			End Select
		End If
		path = g_fs.GetParentFolderName( path )
	Loop
	'(debug point) watch "path"


	'// GetStepPath = step path without ..\
	GetStepPath = Mid( in_FullPath, Len(path) + 2 )
	'(debug point) watch "GetStepPath"


	'// GetStepPath: Add "..\"
	path = Mid( in_BasePath, Len(path) + 2 )
	Do
		If path = "" Then Exit Do
		path = g_fs.GetParentFolderName( path )
		GetStepPath = ".." + sep_ch + GetStepPath
	Loop
	'(debug point) watch "GetStepPath"


	If GetStepPath = "" Then  GetStepPath = "."
	GetStepPath = NormalizePath( GetStepPath )
End Function


 
'*************************************************************************
'  <<< [GetParentFullPath] >>> 
'*************************************************************************
Function  GetParentFullPath( Path )
	GetParentFullPath = g_fs.GetParentFolderName( g_fs.GetAbsolutePathName( Path ) )
End Function


 
'***********************************************************************
'* Function: GetCommonParentFolderPath
'***********************************************************************
Function  GetCommonParentFolderPath( in_PathA, in_PathB )
	If in_PathA = "" Then
		GetCommonParentFolderPath = in_PathB
		Exit Function
	End If

	Assert  IsFullPath( in_PathA )
	Assert  IsFullPath( in_PathB )

	position = 1
	Do
		position_1 = InStr( position, in_PathA, "\" )
		position_2 = InStr( position, in_PathA, "/" )
		If position_1 = 0 Then
			If position_2 = 0 Then _
				Exit Do
			position_A = position_2
		ElseIf position_2 = 0 Then
			position_A = position_1
		ElseIf position_1 < position_2 Then
			position_A = position_1
		Else
			position_A = position_2
		End If

		position_1 = InStr( position, in_PathB, "\" )
		position_2 = InStr( position, in_PathB, "/" )
		If position_1 = 0 Then
			If position_2 = 0 Then _
				Exit Do
			position_B = position_2
		ElseIf position_2 = 0 Then
			position_B = position_1
		ElseIf position_1 < position_2 Then
			position_B = position_1
		Else
			position_B = position_2
		End If

		If _
			Mid( in_PathA, position, position_A - position ) <> _
			Mid( in_PathB, position, position_B - position ) Then

			Exit Do
		End If

		position = position_A + 1
	Loop

	GetCommonParentFolderPath = Left( in_PathA, position - 1 )
End Function


 
'***********************************************************************
'* Function: GetCommonSubPath
'***********************************************************************
Function  GetCommonSubPath( in_PathA, in_PathB, in_FilePath )
	If in_FilePath Then
		path_A = g_fs.GetParentFolderName( in_PathA )
		path_B = g_fs.GetParentFolderName( in_PathB )
	Else
		path_A = in_PathA
		path_B = in_PathB
	End If

	whole_length = Len( path_A )
	position = 0
	common = ""
	Do
		position = InStrRev( path_A, "\", position - 1 )

		length = whole_length - position
		common_candidate = Right( path_A, length )
		If common_candidate <> Right( path_B, length ) Then _
			Exit Do

		common = common_candidate
		If position = 0 Then _
			Exit Do
	Loop

	GetCommonSubPath = common
End Function


 
'***********************************************************************
'* Function: GetIdentifiableFileNames
'***********************************************************************
Function  GetIdentifiableFileNames( in_FullPathArray )
	Set id_files = CreateObject( "Scripting.Dictionary" )  '// Key=IdentifiableFileName
	id_files.CompareMode = c_NotCaseSensitive
	sort_setting_back_up = g_Vers("ExpandWildcard_Sort")
	g_Vers("ExpandWildcard_Sort") = False

	For Each  full_path  In  in_FullPathArray
		Dic_addInArrayItem  id_files,  g_fs.GetFileName( full_path ),  full_path
	Next

	For Each  file_name  In  id_files.Keys
		Set an_array = id_files( file_name )
		If an_array.Count = 1 Then  '// If identified
			id_file_name = file_name
			id_files( id_file_name ) = an_array(0)
		Else
			'// Call recursively
			ReDim  parent_paths( an_array.UBound_ )
			is_parent = True
			For i=0 To UBound( parent_paths )
				parent_paths(i) = g_fs.GetParentFolderName( an_array(i) )
				If parent_paths(i) = "" Then _
					is_parent = False
			Next
			If is_parent Then


				Set parent_names = GetIdentifiableFileNames( parent_paths )


				For Each  parent_name  In  parent_names.Keys
					If parent_name <> "" Then
						id_files( parent_name +"\"+ file_name ) = _
							parent_names( parent_name ) +"\"+ file_name
					Else
						full_path = parent_names( parent_name ) + file_name
						id_files( full_path ) = full_path
					End If
				Next
			Else
				full_path = an_array(0)
				If Right( full_path, 1 ) = "\" Then _
					full_path = Left( full_path,  Len( full_path ) - 1 )
				id_files( full_path ) = full_path
			End If

			id_files.Remove  file_name
		End If
	Next

	g_Vers("ExpandWildcard_Sort") = sort_setting_back_up
	If g_Vers("ExpandWildcard_Sort") Then _
		QuickSortDicByKeyForNotObject  id_files

	Set GetIdentifiableFileNames = id_files
End Function


 
'*************************************************************************
'  <<< [GetParentFoldersName] >>> 
'*************************************************************************
Function  GetParentFoldersName( FilePath, Level, SeparatorReplacedStr )
	full_path = g_fs.GetParentFolderName( g_fs.GetAbsolutePathName( FilePath ) )

	Assert  Level >= 1
	position = -1
	current_level = 0
	Do
		position_1 = InStrRev( full_path, "\", position )
		position_2 = InStrRev( full_path, "/", position )
		If position_1 > position_2 Then
			position = position_1
		Else
			position = position_2
		End If

		current_level = current_level + 1
		If current_level = Level Then _
			Exit Do
		If position = 0 Then _
			Exit Do
		position = position - 1
	Loop
	name = Mid( full_path, position + 1 )
	If not IsEmpty( SeparatorReplacedStr ) Then
		name = Replace( name, "\", SeparatorReplacedStr )
		name = Replace( name, "/", SeparatorReplacedStr )
	End If
	GetParentFoldersName = name
End Function


 
'*************************************************************************
'  <<< [GetRootSeparatorPosition] >>> 
'*************************************************************************
Function  GetRootSeparatorPosition( Path )

	separator = GetFilePathSeparator( Path )

	pos_separator = InStr( Path, separator )
	If pos_separator = 0 Then
		pos_root = 0
	ElseIf Mid( Path,  pos_separator + 1,  1 ) = separator Then  '// If double separator
		i = InStr( pos_separator + 2,  Path,  separator )
		If i > 0 Then
			If separator = "\" Then  '// UNC
				ii = InStr( i + 1,  Path,  separator )
				If ii > 0 Then  i = ii
			End If
			pos_root = i
		Else
			Path = Path + separator
			pos_root = Len( Path ) + 1
		End If
	Else
		If pos_separator >= 2 Then
			If Mid( Path,  pos_separator - 1,  1 ) = ":" Then
				pos_root = pos_separator
			Else
				pos_root = 0
			End If
		Else
			pos_root = pos_separator
		End If
	End If

	GetRootSeparatorPosition = pos_root
End Function


 
'*************************************************************************
'  <<< [GetFilePathSeparator] >>> 
'*************************************************************************
Function  GetFilePathSeparator( Path )
	Dim i  : i  = InStr( Path, "\" )
	Dim ii : ii = InStr( Path, "/" )

	If i > 0 Then
		If ii > 0 Then
			If i > ii Then  GetFilePathSeparator = "/" _
			Else            GetFilePathSeparator = "\"
		Else
			GetFilePathSeparator = "\"
		End If
	Else
		If ii > 0 Then  GetFilePathSeparator = "/" _
		Else            GetFilePathSeparator = "\"
	End If
End Function


 
'*************************************************************************
'  <<< [GetPathWithSeparator] >>> 
'*************************************************************************
Function  GetPathWithSeparator( in_Path )
	If in_Path = ""  or  in_Path = "." Then
		GetPathWithSeparator = ""
	Else
		separator = GetFilePathSeparator( in_Path )
		If Right( in_Path, 1 ) = separator Then
			GetPathWithSeparator = in_Path
		Else
			GetPathWithSeparator = in_Path + separator
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [GetLastSeparatorOfPath] >>> 
'*************************************************************************
Function  GetLastSeparatorOfPath( in_Path )
	last_character = Right( in_Path, 1 )
	If last_character = "\"  or  last_character = "/" Then
		GetLastSeparatorOfPath = last_character
	Else
		GetLastSeparatorOfPath = ""
	End If
End Function


 
'*************************************************************************
'  <<< [ReplaceParentPath] >>> 
'*************************************************************************
Function  ReplaceParentPath( ByVal Path, FromSign, ToSign )
	separator = GetFilePathSeparator( Path )
	Path = NormalizePath( Path )
	pos_root = GetRootSeparatorPosition( Path )
	sub_path = Mid( Path,  pos_root + 1 )

	'// Set "parents_from"
	parents_from = ""
	Do
		parents_from = parents_from + FromSign + separator
		If StrCompHeadOf( sub_path, parents_from, Empty ) <> 0 Then
			parents_from = Mid( parents_from, Len( FromSign ) + 2 )
			Exit Do
		End If
	Loop

	'// Set "sub_path" from "parents_from" to "parents_to"
	If Len( parents_from ) >= 1 Then
		parents_to = Replace( parents_from, FromSign + separator, ToSign + separator )
		after_parents_from = Mid( sub_path, Len( parents_from ) + 1 )

		If after_parents_from = FromSign Then
			sub_path = parents_to + ToSign
		Else
			sub_path = parents_to + after_parents_from
		End If
	End If

	'// Replace one parent only
	If sub_path = FromSign Then
		sub_path = ToSign
	End If

	'// ...
	Path = Left( Path, pos_root ) + sub_path

	ReplaceParentPath = Path
End Function


 
'********************************************************************************
'  <<< [ReplaceRootPath] >>> 
'********************************************************************************
Function  ReplaceRootPath( in_PathBefore,  in_RootFullPathBefore,  in_RootFullPathAfter,  in_IsReplaceParent )
	If not IsFullPath( in_RootFullPathBefore ) Then _
		Raise E_Others, "ReplaceRootPath の第2引数はフル・パスにしてください"
	If not IsFullPath( in_RootFullPathAfter ) Then _
		Raise E_Others, "ReplaceRootPath の第3引数はフル・パスにしてください"
	last_separator = GetLastSeparatorOfPath( in_PathBefore )

	If IsFullPath( in_PathBefore ) Then

		step_path = GetStepPath( in_PathBefore, in_RootFullPathBefore )

		If IsFullPath( step_path ) Then _
			Raise E_Others, "<ERROR msg=""親フォルダーではありません。"" child="""+ _
				in_PathBefore +""" parent="""+ in_RootFullPathBefore +"""/>"
	Else
		step_path = in_PathBefore
	End If

	If in_IsReplaceParent Then
		step_path = ReplaceParentPath( step_path, "..", "_parent" )
	End If

	ReplaceRootPath = GetFullPath( step_path, in_RootFullPathAfter ) + last_separator
End Function


 
'*************************************************************************
'  <<< [SearchParent] >>> 
'*************************************************************************
Function  SearchParent( ByVal StepPath )
	current = g_sh.CurrentDirectory
	Set c = g_VBS_Lib

	If IsFullPath( StepPath ) Then
		If exist( StepPath ) Then  SearchParent = StepPath
		Exit Function
	End If

	i = 0
	Do
		i = InStr( i+1, current, "\" )
		If exist( StepPath ) Then
			If IsWildcard( StepPath ) Then
				ExpandWildcard  StepPath, c.File or c.Folder, folder, fnames
				SearchParent = folder +"\"+ fnames(0)
			Else
				SearchParent = GetFullPath( StepPath, Empty )
			End If
			Exit Function
		End If
		If i = 0 Then  Exit Function
		StepPath = "..\"+ StepPath
	Loop
End Function


 
'*************************************************************************
'  <<< [IsFullPath] >>> 
'*************************************************************************
Function  IsFullPath( Path )
	bs = InStr( Path, "\" )
	sl = InStr( Path, "/" )
	co = InStr( Path, ":" )
	If bs > 0 Then  If co > bs Then  co = 0
	If sl > 0 Then  If co > sl Then  co = 0

	If co > 0 Then
		If IsEmpty( g_IsFullPath_RegExp ) Then
			Set g_IsFullPath_RegExp = CreateObject( "VBScript.RegExp" )
			g_IsFullPath_RegExp.Pattern = "[a-zA-Z0-9]+:"
		End If
		Set matches = g_IsFullPath_RegExp.Execute( Path )
		If matches.Count >= 1 Then
			If matches(0).FirstIndex <> 0 Then
				co = 0
			End If
		End If
	End If

	IsFullPath = ( bs = co+1  or  sl = co+1 ) or ( Left( Path, 2 ) = "\\" )
End Function

Dim  g_IsFullPath_RegExp


'  <<< [IsAbsPath] >>> 
Function  IsAbsPath( Path )
	IsAbsPath = IsFullPath( Path )
	ThisIsOldSpec
End Function


 
'*************************************************************************
'  <<< [FindParent] >>> 
'*************************************************************************
Function  FindParent( TargetStepPath, StartFolderPath )
	Dim  base : base = GetFullPath( StartFolderPath, Empty )
	Dim  path

	Do
		path = base + "\" + TargetStepPath
		If g_fs.FileExists( path ) or g_fs.FolderExists( path ) Then  Exit Do
		base = g_fs.GetParentFolderName( base )
		If base = "" Then  Raise  E_PathNotFound, _
			 "<ERROR msg='No FindParent' target='" + TargetStepPath + "'/>"
	Loop
	FindParent = path
End Function


 
'*************************************************************************
'  <<< [GetTagJumpPath] >>> 
'*************************************************************************
Function  GetTagJumpPath( PathAndLine )
	ThisIsOldSpec  '// use GetTagJumpParams
	GetTagJumpPath = GetTagJumpParams( PathAndLine ).Path
End Function


 
'*************************************************************************
'  <<< [GetTagJumpLine] >>> 
'*************************************************************************
Function  GetTagJumpLine( PathAndLine )
	ThisIsOldSpec  '// use GetTagJumpParams
	GetTagJumpLine = GetTagJumpParams( PathAndLine ).Line
	If IsEmpty( GetTagJumpLine ) Then  GetTagJumpLine = 0
End Function


 
'*************************************************************************
'  <<< [GetTagJumpParams] >>> 
'*************************************************************************
Class  TagJumpParams
	Public  Path
	Public  LineNum  '// as integer or Empty
	Public  Keyword  '// as string or Empty
End Class

Function  GetTagJumpParams( ByVal in_PathAndFragment )  '// as TagJumpParams
	Dim  s
	Dim  ret,  file_name,  number_pos,  kakko_pos,  colon_pos,  fragment
	Dim  folder_len

	colon_pos  = InStr( in_PathAndFragment,  ":" )  '// e.g. "File.txt:100", pos = position
	number_pos = InStr( in_PathAndFragment,  "#" )  '// e.g. "File.txt#100"

	'// Set "colon_pos" : ドライブ名や URL のスキーム（プロトコル）をスキップする
	If colon_pos >= 1 Then
		Set matches = new_RegExp( "[A-Z0-9]+:", False ).Execute( in_PathAndFragment )
			'// e.g. "C:", "http:"
		If matches.Count >= 1 Then
			If matches(0).FirstIndex = 0 Then
				colon_pos = InStr( colon_pos + 1,  in_PathAndFragment,  ":" ) 
			End If
		End If
	End If

	If number_pos >= 4 Then  '// 4 is for next "Mid"
		Do While  Mid( in_PathAndFragment,  number_pos - 3,  5 ) = "${>#}"

			'// Skip #'s escape "${>#}". 
			number_pos = InStr( number_pos + 1,  in_PathAndFragment,  "#" )
			If number_pos = 0 Then _
				Exit Do
		Loop
	End If

	If colon_pos > number_pos  and  number_pos > 0  Then _
		colon_pos  = 0  '// Use "number_pos"
	If number_pos > colon_pos  and  colon_pos  > 0  Then _
		number_pos = 0  '// Use "colon_pos"

	Set ret = new TagJumpParams
	If colon_pos > 0 Then
		fragment = Mid( in_PathAndFragment,  colon_pos + 1 )
		If IsPlusIntOrZeroString( fragment ) Then
			ret.LineNum = CInt( fragment )
		Else
			ret.Keyword = fragment
		End If
		ret.Path = Left( in_PathAndFragment,  colon_pos - 1 )
		Set GetTagJumpParams = ret
		Exit Function
	End If

	If number_pos > 0 Then
		ret.Path = Left( in_PathAndFragment,  number_pos - 1 )
		ret.Keyword = Mid( in_PathAndFragment,  number_pos + 1 )
		Set GetTagJumpParams = ret
		Exit Function
	End If

	If Right( in_PathAndFragment, 1 ) = ")" Then
		kakko_pos = InStrRev( in_PathAndFragment, "(" )
		s = Mid( in_PathAndFragment,  kakko_pos + 1 )
		s = Left( s, Len( s ) - 1 )
		If IsPlusIntOrZeroString( s ) Then
			ret.LineNum = CInt( s )
			ret.Path = Left( in_PathAndFragment, kakko_pos - 1 )
		Else
			ret.Path = in_PathAndFragment
		End If
		Set GetTagJumpParams = ret
		Exit Function
	End If

	ret.Path = in_PathAndFragment
	ret.Path = Replace( ret.Path, "${>#}", "#" )
	Set GetTagJumpParams = ret
End Function


 
'*************************************************************************
'  <<< [DecodePercentURL] >>> 
'
' Description:
'    This function must not be in "Network.vbs".
'    Because this is called from useful functions in this file.
'*************************************************************************
Function  DecodePercentURL( in_URL )
	pos = 1  '// pos = position
	out = ""  '// output URL
	Do
		next_pos = InStr( pos, in_URL, "%" )
		If next_pos = 0 Then _
			Exit Do
		out = out + Mid( in_URL,  pos,  next_pos - pos )
		out = out + Chr( CLng( "&h"+ _
			Mid( in_URL,  next_pos + 1,  1 ) + _
			Mid( in_URL,  next_pos + 2,  1 ) ) )
		pos = next_pos + 3
	Loop
	DecodePercentURL = out + Mid( in_URL, pos )
End Function


 
'*************************************************************************
'  <<< [AddLastOfFileName] >>> 
'*************************************************************************
Function  AddLastOfFileName( BasePath, AddName )
	Dim  parent : parent = g_fs.GetParentFolderName( BasePath )
	Dim  ext    : ext    = g_fs.GetExtensionName( AddName )
	Dim  base   : base   = g_fs.GetBaseName( BasePath )

	If parent <> "" Then  If Right( parent, 1 ) <> "\" Then  parent = parent + "\"

	If ext = "" Then
		If Right( AddName, 1 ) = "." Then
			AddLastOfFileName = parent + base + Left( AddName, Len(AddName)-1 )
		Else
			AddLastOfFileName = parent + base + AddName +"."+ g_fs.GetExtensionName( BasePath )
		End If
	Else
		AddLastOfFileName = parent + base + AddName
	End IF
End Function


 
'*************************************************************************
'  <<< [CutLastOfFileName] >>> 
'*************************************************************************
Sub  CutLastOfFileName( in_out_Path, LastStr, Opt )
	Dim  base : base = g_fs.GetBaseName( in_out_Path )
	Dim  last_length : last_length = Len( LastStr )

	If StrComp( Right( base, last_length ), LastStr, StrCompOption( Opt ) ) = 0 Then
		base = Left( base, Len( base ) - last_length )

		Dim  parent : parent = g_fs.GetParentFolderName( in_out_Path )
		Dim  ext : ext = g_fs.GetExtensionName( in_out_Path )

		If parent <> "" Then  If Right( parent, 1 ) <> "\" Then  parent = parent + "\"

		If ext = "" Then
			in_out_Path = parent + base
		Else
			in_out_Path = parent + base +"."+ ext
		End If
	End If
End Sub



 
'***********************************************************************
'* Function: CutFragmentInURL
'***********************************************************************
Function  CutFragmentInURL( in_URL )
	position = InStr( in_URL, "#" )
	If position = 0 Then
		CutFragmentInURL = in_URL
	Else
		CutFragmentInURL = Left( in_URL,  position - 1 )
	End If
End Function


 
'*************************************************************************
'  <<< [GetPathLabels] >>> 
'*************************************************************************
Function  GetPathLabels( FilePaths )
	Dim  file_ubound : file_ubound = UBound( FilePaths )
	ReDim  ret( file_ubound ), path( file_ubound ), name( file_ubound )
	Dim  i,  ii,  is_all_diff,  is_no_parent,  num

	'// return  file name only
	is_all_diff = True
	For i=0 To file_ubound
		ret(i) = g_fs.GetFileName( FilePaths(i) )
		If i>0 Then  If ret(i) = ret(0) Then  is_all_diff = False
	Next
	If is_all_diff Then  GetPathLabels = ret : Exit Function

	For i=0 To file_ubound
		path(i) = GetParentFullPath( FilePaths(i) )
	Next

	'// return  folder name + file name
	Do
		is_all_diff = True
		For i=0 To file_ubound
			name(i) = g_fs.GetFileName( path(i) )
			If i>0 Then  If name(i) = name(0) Then  is_all_diff = False
		Next
		If is_all_diff Then
			For i=0 To file_ubound
				ret(i) = name(i) +"/"+ ret(i)
			Next
			GetPathLabels = ret : Exit Function
		End If

		is_no_parent = False
		For i=0 To file_ubound
			path(i) = g_fs.GetParentFolderName( path(i) )
			If path(i) = ""  or  Right( path(i), 1 ) = "\" Then  is_no_parent = True
		Next
		If is_no_parent Then  Exit Do
	Loop

	'// return  number + file name
	For i=0 To file_ubound : name(i) = Empty : Next
	num = 1
	For i=0 To file_ubound
		If IsEmpty( name(i) ) Then
			name(i) = num : ret(i) = num & "/" & ret(i)
			For ii = i+1 To file_ubound
				If path(ii) = path(i) Then  name(ii) = num : ret(ii) = num & "/" & ret(ii)
			Next
			num = num + 1
		End If
	Next
	GetPathLabels = ret : Exit Function
End Function


 
'*************************************************************************
'  <<< [CutCRLF] >>> 
'*************************************************************************
Function  CutCRLF( Str )
	CutCRLF = Replace( Str, vbCRLF, "" )
	CutCRLF = Replace( CutCRLF, vbLF, "" )
End Function


 
'*************************************************************************
'  <<< [StrCompLastOfFileName] >>> 
'*************************************************************************
Function  StrCompLastOfFileName( Path, LastStr, Opt )
	StrCompLastOfFileName = StrComp( Right( g_fs.GetBaseName( Path ), Len(LastStr) ), LastStr, StrCompOption( Opt ) )
End Function



 
'*************************************************************************
'  <<< [DesktopPath] >>> 
'*************************************************************************
Function  DesktopPath()
	DesktopPath = g_sh.SpecialFolders( "Desktop" )
End Function


 
'*************************************************************************
'  <<< [IsWildcard] >>> 
'*************************************************************************
Function  IsWildcard( ByVal path )
	IsWildcard = InStr( path, "?" ) <> 0 Or InStr( path, "*" ) <> 0
End Function


 
'*************************************************************************
'  <<< [ReplaceFileNameWildcard] >>> 
'*************************************************************************
Function  ReplaceFileNameWildcard( ByVal Path, ByVal FromStr, ByVal ToStr )
	Dim  ret, pos1, pos2, s1, s2

	CutLastOf  FromStr, "\", Empty
	CutLastOf  ToStr, "\", Empty


	'// replace folder
	pos1 = InStrRev( Path, "\" )
	If pos1 > 0 Then  '// if exist parent folder path
		pos2 = InStrRev( FromStr, "\" )
		If pos2 > 0 Then
			s2 = LCase( Left( FromStr, pos2 ) )
			If InStr( s2, "*" ) > 0 Then  Error
		Else
			s2 = LCase( FromStr ) +"\"
		End If

		s1 = LCase( Left( Path, pos1 ) )
		If s1 <> s2 Then
			If StrCompHeadOf( s1, FromStr +"\", Empty ) = 0 Then
				ReplaceFileNameWildcard = ToStr +"\"+ Mid( Path, Len(FromStr) + 2 )
			End If
			Exit Function
		End If

		Path    = Mid( Path,    pos1 + 1 )  '// change to file name
		FromStr = Mid( FromStr, pos1 + 1 )  '// change to file name

		'// if move to sub folder
		If pos2 = 0 Then  ReplaceFileNameWildcard = ToStr +"\"+ Path : Exit Function

		pos2 = InStrRev( ToStr, "\" )
		If pos2 > 0 Then
			ret = Left( ToStr, pos2 )
			ToStr = Mid( ToStr, pos2 + 1 )
		End If
	Else
		If InStr( FromStr, "\" ) > 0 Then  Exit Function
	End If


	'// replace file
	pos1 = InStr( FromStr, "*" )
	If pos1 = 1  and  Right( FromStr, 1 ) = "*"  and  Len( FromStr ) >= 3 Then  '// double wildcard

		FromStr = Mid( FromStr, 2, Len( FromStr ) - 2 )
		If InStr( 1, Path, FromStr, 1 ) = 0 Then  Exit Function

		If ToStr = "" Then  ReplaceFileNameWildcard = "" : Exit Function

		If Left(  ToStr, 1 ) <> "*" Then  Error
		If Right( ToStr, 1 ) <> "*" Then  Error
		ToStr   = Mid( ToStr,   2, Len( ToStr )   - 2 )

		ret = ret + Replace( Path, FromStr, ToStr, 1,-1,1 )

	ElseIf pos1 > 0 Then  '// single wildcard

		If InStr( pos1 + 1,  FromStr, "*" ) > 0 Then  Error

		If LCase( Left( Path, pos1 - 1 ) ) <> LCase( Left( FromStr, pos1 - 1 ) ) Then  Exit Function
		If LCase( Right( Path, Len(FromStr) - pos1 ) ) <> LCase( Mid( FromStr, pos1 + 1 ) ) Then  Exit Function

		If ToStr = "" Then  ReplaceFileNameWildcard = "" : Exit Function

		pos2 = InStr( ToStr, "*" )
		If pos2 = 0 Then  Error
		If InStr( pos2 + 1,  ToStr,  "*" ) > 0 Then  Error

		ret = ret + Left( ToStr, pos2 - 1 ) +_
					Mid( Path, pos1,  Len( Path ) - Len( FromStr ) + 1 ) +_
					Mid( ToStr, pos2 + 1 )

			 '// [sample]  1234567           12345         1234567890
			 '//     Path="lfXYZrt" FromStr="lf*rt" ToStr="left*right"

	Else  '// no wildcard
		If LCase( Path ) <> LCase( FromStr ) Then  Exit Function
		ret = ret + ToStr
	End If

	ReplaceFileNameWildcard = ret
End Function


 
'*************************************************************************
'  <<< [ArrayFromWildcard] >>> 
'*************************************************************************
Function  ArrayFromWildcard( in_WildcardPath )
	Set dic = new PathDictionaryClass
	dic.BasePath = g_sh.CurrentDirectory
	Set ArrayFromWildcard = dic

	If TypeName( in_WildcardPath ) = "PathDictionaryClass" Then
		Set ArrayFromWildcard = in_WildcardPath
	Else
		For Each  path  In  ArrayFromOrPipe( in_WildcardPath )
			Set dic( path ) = Nothing
		Next
	End If
End Function


 
'********************************************************************************
'  <<< [ArrayFromWildcard2] >>> 
'********************************************************************************
Function  ArrayFromWildcard2( in_WildcardPath )
	Set dic = new PathDictionaryClass
	Set ArrayFromWildcard2 = dic

	If TypeName( in_WildcardPath ) = "PathDictionaryClass" Then
		Set ArrayFromWildcard2 = in_WildcardPath
	Else
		wildcard_paths = ArrayFromOrPipe( in_WildcardPath )

		base_path = Empty
		Set joins = new ArrayClass
		For Each  path  In  wildcard_paths

			'// Set "parent", "file_name"
			parent = g_fs.GetParentFolderName( path )
			If Right( parent, 2 ) = "\*" Then
				new_length = Len( parent ) - 2
				parent = Left( parent,  new_length )
				file_name = Mid( path, new_length + 2 )
			Else
				file_name = g_fs.GetFileName( path )
			End If
			Assert  not IsWildcard( parent )


			'// Set "joined"
			Set joined = new JoinedClass  '// dic.BasePath = joined.Left,  dic( joined.Right )
			If IsWildcard( file_name ) Then
				joined.Left = GetParentFullPath( path )
				joined.Right = file_name
			ElseIf g_fs.FolderExists( path ) Then
				joined.Left = GetFullPath( path, Empty )
				joined.Right = "."
			ElseIf g_fs.FileExists( path ) Then
				joined.Left = GetFullPath( parent, Empty )
				joined.Right = file_name
			Else
				Raise  E_PathNotFound,  "<ERROR msg=""Not found""  path="""+ path +"""/>"
			End If

			joins.Add  joined


			'// Set "base_path"
			If IsEmpty( base_path ) Then
				base_path = joined.Left +"\"
			Else
				base_path = GetCommonParentFolderPath( base_path +"\file",  joined.Left +"\file" )
			End If
		Next

		dic.BasePath = base_path
		For Each  joined  In  joins.Items
			last_separator = GetLastSeparatorOfPath( joined.Right )

			file_name = ReplaceRootPath( joined.Right,  base_path,  joined.Left,  False )
			file_name = GetStepPath( file_name,  base_path ) + last_separator
			Select Case  Left( file_name, 5 )
				Case  "..\*\", "..\.\"
					file_name = Mid( file_name, 4 )
			End Select
			Set dic( file_name ) = Nothing
		Next
	End If
End Function


 
'***********************************************************************
'* Function: ArrayFromOrPipe
'***********************************************************************
Function  ArrayFromOrPipe( in_OrPipedString )
	If IsArray( in_OrPipedString ) Then
		Set out_array = new ArrayClass
		For Each  a_string  In  in_OrPipedString
			For Each  an_array  In  ArrayFromCSV( Replace( a_string, "|", "," ) )
				out_array.AddElems  an_array
			Next
		Next
		ArrayFromOrPipe = out_array.Items
	Else
		a_CSV_string = Replace( in_OrPipedString, "|", "," )
		ArrayFromOrPipe = ArrayFromCSV( a_CSV_string )
	End If
End Function


 
'********************************************************************************
'  <<< [ReplaceRootOfStepPath] >>> 
'********************************************************************************
Function  ReplaceRootOfStepPath( in_BeforePath, _
		in_RootFullPathBefore,  in_RootFullPathAfter,  in_IsReplaceParent )
	'//TODO:
End Function


 
'********************************************************************************
'  <<< [GetInputOutputFilePaths] >>> 
'********************************************************************************
Function  GetInputOutputFilePaths( in_InputPath, in_OutputPath, in_TemporaryBaseName )
	tmp_path = GetTempPath( in_TemporaryBaseName )

	If not IsEmpty( in_OutputPath ) Then
		in_OutputPath = GetFullPath( in_OutputPath, Empty )
	End If

	Set paths = ArrayFromWildcard2( in_InputPath )
	file_paths = paths.FilePaths

	ReDim  pairs( UBound( file_paths ) )
	i = 0
	For Each  step_path  In  file_paths

		Set pair = new InputOutputFilePathClass

		pair.InputPath = GetFullPath( step_path, paths.BasePath )

		If IsEmpty( in_OutputPath ) Then
			pair.OutputPath = tmp_path
			pair.IsOutputPathTemporary = True
		Else
			If file_paths(0) = g_fs.GetFileName( in_InputPath ) Then
				pair.OutputPath = in_OutputPath
			Else
				pair.OutputPath = GetFullPath( step_path, in_OutputPath )
			End If

			If pair.InputPath = pair.OutputPath Then
				pair.OutputPath = tmp_path
				pair.IsOutputPathTemporary = True
			Else
				pair.IsOutputPathTemporary = False
			End If
		End If
		Set pairs( i ) = pair
		i = i + 1
	Next
	GetInputOutputFilePaths = pairs
End Function


 
'********************************************************************************
'  <<< [InputOutputFilePathClass] >>> 
'********************************************************************************
Class  InputOutputFilePathClass
	Public  InputPath
	Public  OutputPath
	Public  IsOutputPathTemporary
End Class


 
'*************************************************************************
'  <<< [ExpandWildcard] >>> 
'*************************************************************************
Sub  ExpandWildcard( WildcardPath, ByVal Flags, out_FolderPath, out_StepPaths )
	Set c = g_VBS_Lib
	Set work = new ExpandWildcardWorkClass

	If IsArray( WildcardPath ) Then  wildcard_paths = WildcardPath _
	Else                             wildcard_paths = Array( WildcardPath )

	ReDim  temp_folder_paths( UBound( wildcard_paths ) )
	out_FolderPath = Empty
	ReDim  out_StepPaths( -1 )
	work.out_fast_ubound = UBound( out_StepPaths )
	If g_Vers("ExpandWildcard_Sort") Then  Set work.sort_box = new ArrayClass

	Set reg_exp_dic = CreateObject( "Scripting.Dictionary" )
		'// reg_exp_dic is dictionary of work.items, key= folder path
		'// work.items is ArrayClass of { re, re2, re, re2, ... }
	reg_exp_dic.CompareMode = 1


	'// Set "reg_exp_dic"
	For path_num = 0  To UBound( wildcard_paths )
		do_it = True
		path = wildcard_paths( path_num )
		Set re = Nothing : Set re2 = Nothing

		Set item = new ExpandWildcardItemClass
		'// Set "IsSubFolder" : This will be overwritten after here.
		If Flags and c.SubFolder Then
			item.IsSubFolder = True
		Else
			item.IsSubFolder = False
		End If

		SplitPathToSubFolderSign  path, sub_folder_sign, is_folder, Empty

		If is_folder Then
			If IsBitSet( Flags, c.File )  and  IsBitNotSet( Flags, c.Folder ) Then
				Flags = Flags and not ( c.File or c.Folder )
				Flags = Flags or c.Folder
			End If
		ElseIf Flags and c.SubFolderIfWildcard Then
			If g_fs.FolderExists( path ) Then
				If sub_folder_sign = "" Then
					path = path +"\*"
					item.IsSubFolder = True
				End If
			End If
		End If


		folder_path = GetParentFullPath( path )
		If not g_fs.FolderExists( folder_path ) Then
			If Flags and c.SubFolderIfWildcard Then
				If IsBitNotSet( Flags, c.NoError ) Then
					Raise  E_PathNotFound, "<ERROR msg=""Not found"" path="""+ _
						XmlAttr( path ) +"""/>"
				Else
					do_it = False
				End If
			End If
		End If
		file_name = g_fs.GetFileName( path )

		If file_name = "*" Then  '// Else If file_name = "*" Then  re = re2 = Nothing
			If Flags and c.SubFolderIfWildcard Then
				item.IsSubFolder = True
			End If
		Else

			GetWildcardTester_sub  file_name, re, re2 '//[out] re, re2

			If re is Nothing Then
				Set re = new NameOnlyClass
				re.Name = file_name
				re.Delegate = LCase( file_name )

				If IsBitSet( Flags, c.SubFolderIfWildcard )  and  sub_folder_sign <> "*" Then
					If not exist( path ) Then
						If IsBitNotSet( Flags, c.NoError ) Then
							Raise  E_PathNotFound, "<ERROR msg=""Not found"" path="""+ _
								XmlAttr( path ) +"""/>"
						End If
						do_it = False
					End If
				End If
			ElseIf re2 is Nothing Then
				If Flags and c.SubFolderIfWildcard Then
					If IsWildcard( file_name ) Then
						item.IsSubFolder = True
					Else
						item.IsSubFolder = False
					End If


					and_              = ( InStr( file_name, "*" ) = 0 )
					If and_ Then and_ = ( not exist( GetFullPath( file_name, folder_path ) ) )
					If and_ Then and_ = ( ( Flags and c.NoError ) = 0 )
					If and_ Then
						Raise  E_PathNotFound, "<ERROR msg=""Not found"" path="""+ _
							XmlAttr( path ) +"""/>"
					End If
				End If
			End If


			'//=== ワイルドカードの判定に RegExp を使うとき、re, re2 に代入
			If re is Nothing Then  '// * が２つのときか、? があるとき

				If Flags and c.SubFolderIfWildcard Then
					item.IsSubFolder = True
				End If

				If Right( path, 2 ) = ".*" Then  Set re2 = CreateObject("VBScript.RegExp")

				Set re = CreateObject("VBScript.RegExp")
				re.Global = True

				'// Add escape character "\" in "file_name"
				For Each  str  In Array( "\\", "\.", "\$", "\^", "\{", "\}", "\[", "\]", _
						"\(", "\)", "\|", "\+" )
					re.Pattern = str :  file_name = re.Replace( file_name, str )
				Next

				'// Replace in "file_name"
				re.Pattern = "\*" :  file_name = re.Replace( file_name, ".*" )
				re.Pattern = "\?" :  file_name = re.Replace( file_name, "." )

				'// Set "re"
				If Left( re.Pattern, 2 ) = ".*" Then
					re.Pattern = Mid( re.Pattern, 3 )
				Else
					re.Pattern = "^" + file_name
				End If
				re.Global = False
				re.IgnoreCase = True

				'// Set "re2"
				If not re2 is Nothing Then  '// re2 is for no extension file at any extension pattern
					re2.Pattern = Left( re.Pattern, Len( re.Pattern ) - 4 ) +"$"
						'// "file_name" の最後の "\..*" をカットして "$" を追加する
					re2.Global = re.Global
					re2.IgnoreCase = re.IgnoreCase
				End If
			End If
		End If


		If do_it Then
			If sub_folder_sign = "*" Then
				item.IsSubFolder = True
			ElseIf sub_folder_sign = "." Then
				item.IsSubFolder = False
			End If


			If reg_exp_dic.Exists( folder_path ) Then
				Set work.items = reg_exp_dic.Item( folder_path )
			Else
				Set work.items = new ArrayClass
				Set reg_exp_dic.Item( folder_path ) = work.items
			End If

			Set item.re  = re
			Set item.re2 = re2
			work.items.Add  item
		End If
	Next


	'// Loop by "folder_path"
	For Each folder_path  In reg_exp_dic.Keys
		Set work.items = reg_exp_dic.Item( folder_path )
		sep_ch = GetFilePathSeparator( folder_path )
		work.folder_path = folder_path


		If Flags and c.ArrayOfArray Then
			prev_ubound = UBound( out_StepPaths )
		Else
			prev_ubound = work.out_fast_ubound
		End If



		'// ...
		ExpandWildcard_sub  work, Flags, out_StepPaths



		'// Set "out_FolderPath" : Common folder path
		If IsEmpty( out_FolderPath ) Then
			If Flags and c.AbsPath Then
				Select Case  Right( folder_path, 1 )
					Case sep_ch : new_folder_path = folder_path
					Case Else   : new_folder_path = folder_path + sep_ch
				End Select
				If Flags and c.ArrayOfArray Then
					For ii = prev_ubound + 1  To UBound( out_StepPaths )
						Set paths = out_StepPaths(ii)
						For i = 0  To paths.UBound_
							paths(i) = new_folder_path + paths(i)
						Next
					Next
				Else
					For i = prev_ubound + 1  To work.out_fast_ubound
						out_StepPaths(i) = new_folder_path + out_StepPaths(i)
					Next
				End If
			Else
				out_FolderPath = folder_path
			End If
		Else
			If StrCompHeadOf( folder_path, out_FolderPath, Empty ) <> 0 Then
				i=1
				Do
					If LCase( Mid( folder_path, i, 1 )) <> _
							LCase( Mid( out_FolderPath, i, 1 )) Then
						Exit Do
					End If
					i=i+1
				Loop
				new_folder_path = g_fs.GetParentFolderName( Left( out_FolderPath, i ) )
				If Right( new_folder_path, 1 ) = "\" Then _
					new_folder_path = Left( new_folder_path, Len( new_folder_path ) - 1 )
				step_path = Mid( out_FolderPath, Len( new_folder_path ) + 2 ) +"\"
				Assert  Len( new_folder_path ) > 0

				If Flags and c.ArrayOfArray Then
					For ii=0 To prev_ubound
						Set paths = out_StepPaths(ii)
						For i = 0  To paths.UBound_
							paths(i) = step_path + paths(i)
						Next
					Next
				Else
					For i=0 To prev_ubound
						out_StepPaths(i) = step_path + out_StepPaths(i)
					Next
				End If
				out_FolderPath = new_folder_path
			End If

			If folder_path <> out_FolderPath Then
				step_path = Mid( folder_path, Len( out_FolderPath ) + 2 ) +"\"
				If Flags and c.ArrayOfArray Then
					For ii = prev_ubound + 1  To UBound( out_StepPaths )
						Set paths = out_StepPaths(ii)
						For i = 0  To paths.UBound_
							paths(i) = step_path + paths(i)
						Next
					Next
				Else
					For i = prev_ubound + 1  To work.out_fast_ubound
						out_StepPaths(i) = step_path + out_StepPaths(i)
					Next
				End If
			End If
		End If
	Next


	If Flags and c.ArrayOfArray Then
	Else
		ReDim Preserve  out_StepPaths( work.out_fast_ubound )
	End If
End Sub


'//[ExpandWildcardWorkClass]
Class  ExpandWildcardWorkClass
	Public  items
	Public  is_root_folder
	Public  folder_path
	Public  first_out_count
	Public  out_fast_ubound
	Public  sort_box
End Class


'//[ExpandWildcardItemClass]
Class  ExpandWildcardItemClass
	Public  re
	Public  re2
	Public  IsSubFolder
End Class


'[GetWildcardTester_sub]
Sub  GetWildcardTester_sub( file_name, re, re2 )
	Set c = g_VBS_Lib
	Set re  = Nothing
	Set re2 = Nothing

	i = InStr( file_name, "*" )

	'//=== ワイルドカードがないとき、re に string 型を代入, re2=Nothing
	If i = 0 Then
		If InStr( file_name, "?" ) = 0 Then
			Exit Sub
		End If


	'//=== ワイルドカードの判定に StrMatchKey を使うとき、re に代入, re2=Nothing
	ElseIf InStrRev( file_name, "*" ) = i Then  '// * が１個のとき
		If InStr( file_name, "?" ) = 0 Then

			'// Set "re"
			Set re = new StrMatchKey
			re.Keyword = LCase( file_name )  '// そのまま
			re.IgnoreCase = True
			'// re2 = Nothing
		End If
	End If


	'//=== ワイルドカードの判定に RegExp を使うとき、re, re2 に代入
	If re is Nothing Then  '// * が２つのときか、? があるとき

		If Flags and c.SubFolderIfWildcard Then
			item.IsSubFolder = True
		End If

		If Right( file_name, 2 ) = ".*" Then _
			Set re2 = CreateObject("VBScript.RegExp")

		Set re = CreateObject("VBScript.RegExp")
		re.Global = True

		'// Add escape character "\" in "file_name"
		For Each  str  In Array( "\\", "\.", "\$", "\^", "\{", "\}", "\[", "\]", _
				"\(", "\)", "\|", "\+" )
			re.Pattern = str :  file_name = re.Replace( file_name, str )
		Next

		'// Replace in "file_name"
		re.Pattern = "\*" :  file_name = re.Replace( file_name, ".*" )
		re.Pattern = "\?" :  file_name = re.Replace( file_name, "." )

		'// Set "re"
		If Left( re.Pattern, 2 ) = ".*" Then
			re.Pattern = Mid( re.Pattern, 3 )
		Else
			re.Pattern = "^" + file_name
		End If
		re.Global = False
		re.IgnoreCase = True

		'// Set "re2"
		If not re2 is Nothing Then  '// re2 is for no extension file at any extension pattern
			re2.Pattern = Left( re.Pattern, Len( re.Pattern ) - 4 ) +"$"
				'// "file_name" の最後の "\..*" をカットして "$" を追加する
			re2.Global = re.Global
			re2.IgnoreCase = re.IgnoreCase
		End If
	End If
End Sub


'[ExpandWildcard_sub]
'- sort_box as ArrayClass of string. No pass data from caller
Sub  ExpandWildcard_sub( work, Flags, out_StepPaths )
	Set c = g_VBS_Lib

	If not g_fs.FolderExists( work.folder_path ) Then  Exit Sub


	If Flags and c.ArrayOfArray Then
		work.first_out_count = UBound( out_StepPaths ) + 1
		Assert  IsEmpty( work.sort_box )
		ReDim Preserve  out_StepPaths( UBound( out_StepPaths ) + work.items.Count )
		For i = work.first_out_count  To UBound( out_StepPaths )
			Set out_StepPaths(i) = new ArrayClass
		Next
	Else
		work.first_out_count = work.out_fast_ubound + 1
	End If


	'// Set "is_scan_sub_folder"
	is_scan_sub_folder = False
	is_all_file_path = True
	For i=0 To work.items.UBound_
		Set  item = work.items(i)

		If item.IsSubFolder Then
			is_scan_sub_folder = True
			is_all_file_path = False
		End If
		If TypeName( item.re ) <> "NameOnlyClass" Then
			is_all_file_path = False
		End If
	Next


	If is_all_file_path Then
		For i=0 To work.items.UBound_
			If UBound(out_StepPaths) <= work.out_fast_ubound Then _
				ReDim Preserve  out_StepPaths( ( work.out_fast_ubound + 100 ) * 4 )
			work.out_fast_ubound = work.out_fast_ubound + 1

			file_name = work.items(i).re.Name
			out_StepPaths( work.out_fast_ubound ) = file_name
		Next
	Else
		'// Set "folders"
		ReDim  folders(0)
		Set folders(0) = g_fs.GetFolder( work.folder_path )
		folders_fast_ubound = UBound( folders )
		folders_get_num = 0

		work.is_root_folder = True
		While  folders_get_num <= folders_fast_ubound
			is_empty_folder = True

			If not is_all_file_path Then

				'// Loop by "SubFolders" not sub folders
				For Each folder  In  folders( folders_get_num ).SubFolders
					is_empty_folder = False

					If is_scan_sub_folder Then

						'// Add "folder" to "folders"
						If UBound(folders) <= folders_fast_ubound Then _
							ReDim Preserve  folders( ( folders_fast_ubound + 100 ) * 4 )
						folders_fast_ubound = folders_fast_ubound + 1

						Set folders( folders_fast_ubound ) = folder
					End If



					'// Call "ExpandWildcard_sub2"
					If Flags and c.Folder Then
						ExpandWildcard_sub2  work, Flags, out_StepPaths, folder
					End If



				Next
				If not IsEmpty( work.sort_box ) Then
					QuickSort  work.sort_box, 0, work.sort_box.UBound_, _
						GetRef("NumStringNameCompare"), Empty

					i = work.out_fast_ubound
					If UBound(out_StepPaths) < i + work.sort_box.Count Then _
						ReDim Preserve  out_StepPaths( ( i + work.sort_box.Count + 100 ) * 4 )
					work.out_fast_ubound = i + work.sort_box.Count

					For Each o  In work.sort_box.Items
						i = i + 1 : out_StepPaths( i ) = o.Delegate
					Next
					work.sort_box.ToEmpty
				End If
			End If


			'// Call "ExpandWildcard_sub2"
			'// Loop by "Files" not sub folders
			If Flags and c.File Then
				For Each  file  In  folders( folders_get_num ).Files
					is_empty_folder = False

					ExpandWildcard_sub2  work, Flags, out_StepPaths, file
				Next
			ElseIf  is_empty_folder  Then
				If folders( folders_get_num ).Files.Count >= 1 Then _
					is_empty_folder = False
			End If

			If is_empty_folder Then
				If Flags and c.EmptyFolder Then
					previous_ubound = work.out_fast_ubound

					ExpandWildcard_sub2  work, Flags, out_StepPaths, folders( folders_get_num )
					For  i = previous_ubound + 1  To  work.out_fast_ubound
						out_StepPaths(i) = out_StepPaths(i) +"\"
					Next
				End If
			End If


			If not IsEmpty( work.sort_box ) Then
				QuickSort  work.sort_box, 0, work.sort_box.UBound_, _
					GetRef("NumStringNameCompare"), Empty

				i = work.out_fast_ubound
				If UBound(out_StepPaths) < i + work.sort_box.Count Then _
					ReDim Preserve  out_StepPaths( ( i + work.sort_box.Count + 100 ) * 4 )
				work.out_fast_ubound = i + work.sort_box.Count

				For Each o  In work.sort_box.Items
					i = i + 1 : out_StepPaths( i ) = o.Delegate
				Next
				work.sort_box.ToEmpty
			End If

			folders_get_num = folders_get_num + 1
			work.is_root_folder = False
		WEnd


		'// Change object to path
		n = Len( work.folder_path ) + 2
		If Flags and c.ArrayOfArray Then
			For ii = work.first_out_count  To UBound( out_StepPaths )
				Set paths = out_StepPaths(ii)
				For i = 0  To paths.UBound_
					If IsObject( paths( i ) ) Then
						paths( i ) = Mid( paths( i ).Path, n )
					Else
						paths( i ) = Mid( paths( i ), n )
					End If
					If paths( i ) = "" Then _
						If Flags and c.EmptyFolder Then _
							paths( i ) = ".\"
				Next
			Next
		Else
			For i = work.first_out_count To work.out_fast_ubound
				If IsObject( out_StepPaths( i ) ) Then
					out_StepPaths( i ) = Mid( out_StepPaths( i ).Path, n )
				Else
					out_StepPaths( i ) = Mid( out_StepPaths( i ), n )
				End If
				If out_StepPaths( i ) = "" Then _
					If Flags and c.EmptyFolder Then _
						out_StepPaths( i ) = ".\"
			Next
		End If
	End If
End Sub


'[ExpandWildcard_sub2]
Sub  ExpandWildcard_sub2( work, Flags, out_StepPaths, object )
	Set c = g_VBS_Lib

	'// Set "is_match", "match_num"
	is_match = True
	full_path = Empty
	For i=0 To work.items.UBound_
		If work.is_root_folder  or  work.items(i).IsSubFolder Then
			Set re  = work.items(i).re
			Set re2 = work.items(i).re2

			If re is Nothing Then
				match_num = i
			Else
				If IsEmpty( full_path ) Then
					full_path = object.Path
					fname = g_fs.GetFileName( full_path )
				End If
				is_match = ( not re2 is Nothing )
				If is_match Then is_match=( re2.Test( fname )  and  InStr( fname, "." ) = 0 )  'and
				If not is_match Then  'or
					If TypeName( re ) = "NameOnlyClass" Then
						is_match = ( LCase( fname ) = re.Delegate )
					Else
						is_match = re.Test( fname )
					End If
				End If
				If is_match Then  match_num = i : Exit For
			End If
		End If
	Next

	'// Add to "out_StepPaths" or "sort_box"
	If is_match Then
		If IsEmpty( work.sort_box ) Then
			If Flags and c.ArrayOfArray Then
				If IsEmpty( full_path ) Then
					out_StepPaths( match_num + work.first_out_count ).Add  object
				Else
					out_StepPaths( match_num + work.first_out_count ).Add  full_path
				End If
			Else
				If UBound(out_StepPaths) <= work.out_fast_ubound Then _
					ReDim Preserve  out_StepPaths( ( work.out_fast_ubound + 100 ) * 4 )
				work.out_fast_ubound = work.out_fast_ubound + 1

				If IsEmpty( full_path ) Then
					Set out_StepPaths( work.out_fast_ubound ) = object
				Else
					out_StepPaths( work.out_fast_ubound ) = full_path
				End If
			End If
		Else
			Set o = new NameOnlyClass
			If re is Nothing Then
				full_path = object.Path
				fname = g_fs.GetFileName( full_path )
			End If
			o.Name = fname
			o.Delegate = full_path
			work.sort_box.Add  o
		End If
	End If
End Sub


 
'***********************************************************************
'* Function: new_PathDictionaryClass
'***********************************************************************
Function  new_PathDictionaryClass( in_Path )
	If VarType( in_Path ) = vbString Then
		Set paths = new PathDictionaryClass
		If IsFullPath( in_Path ) Then
			paths.BasePath = g_fs.GetParentFolderName( in_Path )
		End If
		Set paths( in_Path ) = Nothing
		Set new_PathDictionaryClass = paths
	ElseIf IsArray( in_Path ) Then
		Set paths = new PathDictionaryClass
		For Each  path  In  in_Path
			If IsFullPath( path ) Then
				paths.BasePath = g_fs.GetParentFolderName( path )
			End If
			Set paths( path ) = Nothing
		Next
		Set new_PathDictionaryClass = paths
	ElseIf TypeName( in_Path ) = "PathDictionaryClass" Then
		Set new_PathDictionaryClass = in_Path
	Else
		Error
	End If
End Function


 
'********************************************************************************
'  <<< [new_PathDictionaryClass_withRemove] >>> 
'********************************************************************************
Function  new_PathDictionaryClass_withRemove( in_BasePath, in_RemovePathArray, in_DictionaryItem )
	Set dic = new PathDictionaryClass
	dic.BasePath = in_BasePath
	Set dic( "." ) = in_DictionaryItem
	If not IsEmpty( in_RemovePathArray ) Then
		For Each  path  In in_RemovePathArray
			dic.AddRemove  path
		Next
	End If
	Set new_PathDictionaryClass_WithRemove = dic
End Function


 
'*************************************************************************
'  <<< [new_PathDictionaryClass_fromXML] >>> 
'*************************************************************************
Function  new_PathDictionaryClass_fromXML( in_path_XML_Elements, in_AttributeName, in_BasePath )
	Set new_PathDictionaryClass_fromXML = new_PathDictionaryClass_fromXML_Ex( _
		in_path_XML_Elements, in_AttributeName, in_BasePath, new PathDictionaryOptionClass )
End Function


 
'*************************************************************************
'  <<< [GetPathDictionariesFromXML] >>> 
'*************************************************************************
Function  GetPathDictionariesFromXML( in_path_XML_Elements, in_AttributeName, in_MapAttributeName, in_BasePath )
	Set options_ = new PathDictionaryOptionClass
	options_.MapAttributeName = in_MapAttributeName

	Set GetPathDictionariesFromXML = new_PathDictionaryClass_fromXML_Ex( _
		in_path_XML_Elements, in_AttributeName, in_BasePath,  options_ )
End Function


 
'*************************************************************************
'  <<< [PathDictionaryClass_onRegExp] >>> 
' - in_Options as PathDictionaryOptionClass
'*************************************************************************
Function  PathDictionaryClass_onRegExp( ref_Dictionary,  in_FunctionName,  in_Parameter )
	Set dic = ref_Dictionary.Delegate
	Set out = new ArrayClass

	expression = ArrayFromCSV( in_Parameter )(0)

	Set re = new_RegExp( expression,  False )

	If IsEmpty( dic.AllLeafs ) Then
		Set dic.AllLeafs = EnumerateToLeafPathDictionary( dic.BasePath )
			'// as dictionary of NameOnlyClass

		'// Change to step path
		column_of_step_path = Len( GetPathWithSeparator( dic.BasePath ) ) + 1
		For Each  path  In  dic.AllLeafs.Keys
			Set dic.AllLeafs( Mid( path,  column_of_step_path ) ) = dic.AllLeafs( path )
			dic.AllLeafs.Remove  path
		Next
	End If

	For Each  path  In  dic.AllLeafs.Keys

		Set matches = re.Execute( path )
		If matches.Count = 1 Then
			If matches(0).FirstIndex= 0 Then
				If matches(0).Length = Len( path ) Then

					out.Add  path
				End If
			End If
		End If
	Next

	PathDictionaryClass_onRegExp = out.Items
End Function


 
'*************************************************************************
'  <<< [new_PathDictionaryClass_fromXML_Ex] >>> 
' - in_Options as PathDictionaryOptionClass
'*************************************************************************
Function  new_PathDictionaryClass_fromXML_Ex( in_path_XML_Elements, in_AttributeName, in_BasePath, in_Options )
	Set maps = CreateObject( "Scripting.Dictionary" )
	If IsEmpty( in_Options.MapAttributeName ) Then
		Set dic = new PathDictionaryClass
		dic.BasePath = in_BasePath
		Set maps( "" ) = dic
		Set new_PathDictionaryClass_fromXML_Ex = dic
	Else
		Set new_PathDictionaryClass_fromXML_Ex = maps
	End If
	Set ec = new EchoOff

	If IsArray( in_path_XML_Elements ) Then
		If UBound( in_path_XML_Elements ) = -1 Then  Exit Function
	Else
		If in_path_XML_Elements.Length = 0 Then  Exit Function
	End If


	'// Set "variables"
	Set root = in_path_XML_Elements(0).ownerDocument.lastChild
	Set variables = LoadVariableInXML( root,  GetFullPath( "dummy.txt", GetFullPath( in_BasePath, Empty ) ) )
	Set variables( "${RegExp()}" ) = GetRef( "PathDictionaryClass_onRegExp" )

	Set debug_tag = root.selectSingleNode( "//Debug" )
	If not debug_tag is Nothing Then
		is_log = ( debug_tag.getAttribute( "path_dictionary_scan_log" ) = "yes" )
		If not IsEmpty( dic ) Then _
			dic.IsDebugLog = is_log
	End If

	For Each  element  In in_path_XML_Elements

		If not IsEmpty( in_Options.MapAttributeName ) Then

			'// Set "map_name"
			map_name = ""
			Set elem = element
			Do Until  elem is root
				name = elem.getAttribute( in_Options.MapAttributeName )
				If not IsNull( name ) Then
					map_name = name
					Exit Do
				End If

				Set elem = elem.parentNode
			Loop


			'// Set "dic"
			If maps.Exists( map_name ) Then
				Set dic = maps( map_name )
			Else
				Set dic = new PathDictionaryClass
				dic.BasePath = in_BasePath
				dic.IsDebugLog = is_log
				Set maps( map_name ) = dic
			End If
		End If
		Set variables.Delegate = dic


		'// Set "dic( path )"
		path = element.getAttribute( in_AttributeName )
		If not IsNull( path ) Then

			path = variables( path )
			If  NOT  IsArray( path ) Then
				If in_Options.IsReplaceParentPath Then _
					path = ReplaceParentPath( path, "..", "_parent" )

				Set dic( path ) = element
			Else
				For Each  a_path  In  path
					Set dic( a_path ) = element
				Next
			End If
		End If


		'// Call "dic.AddRemove" : "Except" tag
		For Each  except  In element.selectNodes( "Except" )
			except_paths = except.getAttribute( in_AttributeName )
			If not IsNull( except_paths ) Then
				except_paths = variables( except_paths )
				If in_Options.IsReplaceParentPath Then _
					except_paths = ReplaceParentPath( except_paths, "..", "_parent" )
				For Each except_path  In ArrayFromCSV( except_paths )

					dic.AddRemove  except_path
				Next
			End If
		Next
	Next
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [PathDictionaryOptionClass] >>>> 
'-------------------------------------------------------------------------
Class  PathDictionaryOptionClass
	Public  IsReplaceParentPath
	Public  MapAttributeName

	Private Sub  Class_Initialize()
		IsReplaceParentPath = False
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [PathDictionaryClass] >>>> 
'-------------------------------------------------------------------------
Class  PathDictionaryClass

	Public  IsDebugLog  '// as boolean

	Public  m_PathDictionary         '// as dictionary of Empty
	Public  FilesDictionary          '// as dictionary of Variant
	Public  FoldersDictionary        '// as dictionary of True, key=step path
	Public  DeleteFoldersDictionary  '// as dictionary of False, key=step path
	Public  AllLeafs                 '// as dictionary of string
	Public  LeafsArray               '// as array of DicElem string(path)
	Public  FoldersArray             '// as array of DicElem string(path)
	Public  DeleteFoldersArray       '// as array of DicElem string(path)
	Public  RemoveFilesDictionary    '// as dictionary of False, key=step path
	Public  m_IsScaned         '// as boolean
	Public  m_IsFolderScaned     '// as boolean. Ignored if m_IsScaned = True
	Private m_BasePath         '// as string
	Public  RemovedObject      '// Item for ".AddRemoved"
	Public  IsNotFoundError    '// as boolean

	Public  ExceptRemoved  '// as constant integer

	Private Sub  Class_Initialize()
		Set m_PathDictionary = CreateObject( "Scripting.Dictionary" )
		Set Me.FilesDictionary = CreateObject( "Scripting.Dictionary" )
		Set Me.FoldersDictionary = CreateObject( "Scripting.Dictionary" )
		Set Me.DeleteFoldersDictionary = CreateObject( "Scripting.Dictionary" )
		Me.LeafsArray = Array( )
		Me.FoldersArray = Array( )
		m_IsScaned = True
		Me.BasePath = g_sh.CurrentDirectory
		Set Me.RemovedObject = new NameOnlyClass : Me.RemovedObject.Name = "Removed"
		Me.IsNotFoundError = True
		Me.ExceptRemoved = 1
	End Sub

	'// PathDictionaryClass::Item Set
	Public Property Set  Item( in_Key, NewItem )
		Set  m_PathDictionary( in_Key ) = NewItem
		m_IsScaned = False
	End Property

	'// PathDictionaryClass::AddRemove
	Public Sub  AddRemove( in_Key )
		Set  m_PathDictionary( in_Key ) = Me.RemovedObject
		m_IsScaned = False
	End Sub

	'// PathDictionaryClass::Item Get
	Public Default Property Get  Item( in_Key )
		If m_PathDictionary.Exists( in_Key ) Then
			LetSet  Item, m_PathDictionary( in_Key )
		Else
			If not m_IsScaned Then  Me.Scan
			If Me.FilesDictionary.Exists( in_Key ) Then
				LetSet  Item, Me.FilesDictionary( in_Key )
			ElseIf IsFullPath( in_Key ) Then
				step_path = GetStepPath( in_Key, Me.BasePath )
				If Me.FilesDictionary.Exists( step_path ) Then
					LetSet  Item, Me.FilesDictionary( step_path )
				Else
					Err.Raise  9,,"<ERROR msg=""キーが見つかりません"" key="""& in_Key &"""/>"
				End If
			Else
				Err.Raise  9,,"<ERROR msg=""キーが見つかりません"" key="""& in_Key &"""/>"
			End If
		End If
	End Property

	Public Function  Exists( in_Key )
		Exists = m_PathDictionary.Exists( in_Key )
	End Function

	Public Function  FileExists( in_Key )
		If not m_IsScaned Then  Me.Scan
		FileExists = Me.FilesDictionary.Exists( GetStepPath( in_Key, Me.BasePath ) )
	End Function

	Public Function  FolderExists( in_Key )
		If not m_IsScaned Then  Me.Scan
		If not m_IsFolderScaned Then  Me_ScanFolder
		FolderExists = Me.FoldersDictionary.Exists( GetStepPath( in_Key, Me.BasePath ) )
	End Function

	Public Function  DeleteFolderExists( in_Key )
		If not m_IsScaned Then  Me.Scan
		If not m_IsFolderScaned Then  Me_ScanFolder
		DeleteFolderExists = Me.DeleteFoldersDictionary.Exists( GetStepPath( in_Key, Me.BasePath ) )
	End Function

	Public Property Let  BasePath( x ) : m_BasePath = GetFullPath( x, Empty ) : End Property
	Public Property Get  BasePath() : BasePath = m_BasePath : End Property

	Public Sub  Add( Key, Item ) : m_PathDictionary.Add  Key, Item : End Sub
	Public Property Get  Count() : Count = m_PathDictionary.Count : End Property
	Public Property Get  Keys()  : Keys  = m_PathDictionary.Keys  : End Property
	Public Property Get  Items() : Items = m_PathDictionary.Items : End Property
	Public Property Get  CompareMode() : CompareMode = m_PathDictionary.CompareMode : End Property
	Public Property Let  CompareMode( x ) : m_PathDictionary.CompareMode = x : End Property
	Public Sub  Remove( Key ) : m_PathDictionary.Remove  Key : End Sub
	Public Sub  RemoveAll() : m_PathDictionary.RemoveAll : End Sub

	Public Property Get  KeysEx( Opt )
		If Opt = Me.ExceptRemoved Then
			ReDim  keys_ex( Me.Count )
			i = 0
			For Each  key  In  m_PathDictionary.Keys
				Set a_item = m_PathDictionary( key )
				If not a_item is Me.RemovedObject Then
					keys_ex( i ) = key
					i = i + 1
				End If
			Next
			ReDim Preserve  keys_ex( i - 1 )
			KeysEx = keys_ex
		Else
			KeysEx = m_PathDictionary.Keys
		End If
	End Property

	'// PathDictionaryClass::FilePaths Get
	Public Property Get  FilePaths()
		FilePaths = Array( )
		FilePaths_Sub  FilePaths '//[out]FilePaths
	End Property
	Public Sub  FilePaths_Sub( out )
		If not m_IsScaned Then  Me.Scan

		ReDim  out( UBound( Me.LeafsArray ) )
		out_index = 0
		For source_index = 0  To UBound( Me.LeafsArray )
			path = Me.LeafsArray( source_index ).Key
			If Right( path, 1 ) <> "\" Then
				out( out_index ) = path
				out_index = out_index + 1
			End If
		Next
		ReDim Preserve  out( out_index - 1 )
	End Sub

	'// PathDictionaryClass::FullPaths Get
	Public Property Get  FullPaths()
		FullPaths = Array( )
		FullPaths_Sub  FullPaths '//[out]FullPaths
	End Property
	Public Sub  FullPaths_Sub( out )
		If not m_IsScaned Then  Me.Scan

		base_path = GetPathWithSeparator( m_BasePath )

		ReDim  out( UBound( Me.LeafsArray ) )
		out_index = 0
		For source_index = 0  To UBound( Me.LeafsArray )
			path = Me.LeafsArray( source_index ).Key
			If Right( path, 1 ) <> "\" Then
				If IsFullPath( path ) Then
					out( out_index ) = path
				Else
					out( out_index ) = base_path + path
				End If
				out_index = out_index + 1
			End If
		Next
		ReDim Preserve  out( out_index - 1 )
	End Sub

	'// PathDictionaryClass::LeafPaths Get
	Public Property Get  LeafPaths()
		LeafPaths = Array( )
		If not m_IsScaned Then  Me.Scan
		DicElemArrayKeyToArr  Me.LeafsArray, LeafPaths '//[out]LeafPaths
	End Property

	'// PathDictionaryClass::FolderPaths Get
	Public Property Get  FolderPaths()
		FolderPaths = Array( )
		If not m_IsScaned Then  Me.Scan
		If not m_IsFolderScaned Then  Me_ScanFolder
		DicElemArrayKeyToArr  Me.FoldersArray, FolderPaths '//[out]FolderPaths
	End Property

	Public Property Get  DeleteFolderPaths()
		DeleteFolderPaths = Array( )
		If not m_IsScaned Then  Me.Scan
		If not m_IsFolderScaned Then  Me_ScanFolder
		DicElemArrayKeyToArr  Me.DeleteFoldersArray, DeleteFolderPaths '//[out]DeleteFolderPaths
	End Property

	Public Function  SearchParent( in_Path )
		SearchParent = Dic_searchParent( m_PathDictionary, m_BasePath, in_Path )
	End Function

	Public Property Let  IsScaned( x )
		m_IsScaned = x
		m_IsFolderScaned = x
	End Property
	Public Property Get  IsScaned()
		IsScaned = m_IsScaned
	End Property

	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		xml_sub = GetTab(Level)+ "<"+TypeName(Me)+">"+ vbCRLF
		For Each key  In m_PathDictionary.Keys
			If not m_PathDictionary( key ) is Me.RemovedObject Then _
				xml_sub = xml_sub + GetTab(Level) + key + vbCRLF
		Next
		xml_sub = xml_sub + GetTab(Level) +"</"+TypeName(Me)+">"
	End Function


'*************************************************************************
'  <<< [PathDictionaryClass::Scan] >>> 
'*************************************************************************
Public Sub  Scan()
	Set c = g_VBS_Lib
	Set Me.RemoveFilesDictionary = CreateObject( "Scripting.Dictionary" )

	Me.FilesDictionary.RemoveAll

	DicToArr  m_PathDictionary, paths  '// Set "paths"
	QuickSort  paths, 0, UBound( paths ), GetRef("PathNameCompare"), -1  '// -1 = 逆順
		'// 深いパスから処理します。 先にマッチしたファイルとアイテムの関連を優先します。
		'// ソート「ファイル ＝ フォルダー ＞ \ あり * ＞ \ なし * （拡張子のデフォルト）」

	'// ソート「ファイル ＞ \ あり * ＞ \ なし * （拡張子のデフォルト） ＞ フォルダー」
	paths2 = paths
	For Each  path_object  In  paths2
		step_path = path_object.Name
		If not IsWildcard( step_path ) Then
			full_path = GetFullPath( step_path,  Me.BasePath )
			If g_fs.FolderExists( full_path ) Then
				RemoveObjectsByNames  paths,  path_object
				AddArrElem  paths,  path_object
			End If
		End If
	Next


	'// Set "Me.FilesDictionary"
	For Each  path_object  In paths
		do_it = True
		step_path = path_object.Name
		SplitPathToSubFolderSign  step_path,  sub_folder_sign,  is_folder,  Empty
			'// Set "sub_folder_sign", "is_folder"
		full_path = GetFullPath( step_path,  Me.BasePath )
		is_wildcard = IsWildcard( step_path )
		separator = GetFilePathSeparator( full_path )

		If ( g_fs.FolderExists( full_path )  and  not  is_folder )  or _
				step_path = "."  or  step_path = ".."  or _
				is_wildcard  or  sub_folder_sign = "*" Then

			If sub_folder_sign <> "" Then
				wildcard = g_fs.GetParentFolderName( full_path ) + separator + _
					sub_folder_sign + separator + g_fs.GetFileName( step_path )
			Else
				If is_wildcard  and  Me.IsNotFoundError Then
					If not g_fs.FolderExists( g_fs.GetParentFolderName( full_path ) ) Then
						If not  path_object.Item  is  Me.RemovedObject Then
							Raise  E_PathNotFound, "<ERROR msg=""Not found"" path="""+ _
								path_object.Name + """/>"
						End If
					End If
				End If
				wildcard = full_path
			End If
			If is_folder Then _
				wildcard = wildcard + separator

			If is_wildcard Then
				pos_asterisk = InStr( step_path, "*" )
				pos_separator = InStrRev( step_path, separator, pos_asterisk )
				step_path = Left( step_path, pos_separator )
			ElseIf sub_folder_sign = "*" Then
				step_path = Left( step_path, Len( step_path ) - Len( g_fs.GetFileName( step_path ) ) )
			Else  '// If "full_path" was folder path
				If Right( step_path, 1 ) <> separator Then
					If step_path = "." Then
						step_path = ""
					Else
						step_path = step_path + separator
					End If
				End If
			End If

			If do_it Then
				last_separator = GetLastSeparatorOfPath( wildcard )
				If last_separator = "" Then


					ExpandWildcard  wildcard, _
						c.File  or  c.SubFolderIfWildcard  or  c.NoError  or  c.EmptyFolder, _
						folder,  sub_step_paths  '// Set "folder", "sub_step_paths"


				Else
					ExpandWildcard  wildcard, _
						c.Folder  or  c.SubFolderIfWildcard  or  c.NoError, _
						folder,  sub_step_paths  '// Set "folder", "sub_step_paths"
				End If

				For Each  sub_step_path  In  sub_step_paths
					If sub_step_path = "." Then
						file_step_path = step_path
						CutLastOf  file_step_path, separator, c.CaseSensitive
					ElseIf sub_step_path = ".\" Then
						If step_path = "" Then
							file_step_path = sub_step_path
						Else
							file_step_path = step_path
						End If
					Else
						file_step_path = step_path + sub_step_path
					End If
					If not Me.FilesDictionary.Exists( file_step_path ) Then
						Me.LogSetToFilesDictionary  file_step_path,  path_object.Name

						Set Me.FilesDictionary( file_step_path ) = path_object.Item
						If path_object.Item  is  Me.RemovedObject Then

							Me.RemoveFilesDictionary( file_step_path ) = False

							If last_separator <> "" Then
								folder_step_path = folder +"\"+ sub_step_path
								ExpandWildcard  folder_step_path +"\*", _
									c.File  or  c.SubFolderIfWildcard  or  c.NoError  or  c.EmptyFolder, _
									Empty,  sub2_step_paths  '// Set "sub2_step_paths"

								For Each  sub2_step_path  In  sub2_step_paths
									file2_step_path = file_step_path +"\"+ sub2_step_path
									If not Me.FilesDictionary.Exists( file2_step_path ) Then
										Me.LogSetToFilesDictionary  file2_step_path,  path_object.Name

										Set Me.FilesDictionary( file2_step_path ) = path_object.Item
										Me.RemoveFilesDictionary( file2_step_path ) = False
									End If
								Next
							End If
						End If
					End If
				Next
			End If
		ElseIf exist( full_path ) Then
			If not Me.FilesDictionary.Exists( step_path ) Then
				Me.LogSetToFilesDictionary  step_path,  path_object.Name
				Set Me.FilesDictionary( step_path ) = path_object.Item

				If path_object.Item Is Me.RemovedObject Then _
					Me.RemoveFilesDictionary( step_path ) = False
			End If
		ElseIf path_object.Item  is  Me.RemovedObject Then
			'// If "RemovedObject" is not found file or folder.
		ElseIf Me.IsNotFoundError Then
			Raise  E_PathNotFound, "<ERROR msg=""Not found"" path="""+ path_object.Name + """/>"
		End If
	Next


	'// Remove in "Me.FilesDictionary"
	For Each  key  In  Me.FilesDictionary.Keys
		If Me.FilesDictionary( key ) is Me.RemovedObject Then
			Me.FilesDictionary.Remove  key
		End If
	Next


	'// Set "Me.LeafsArray" : Sorted array
	DicToArr  Me.FilesDictionary, LeafsArray  '//[out] Me.LeafsArray
	QuickSort  LeafsArray, 0, UBound( LeafsArray ), GetRef("PathNameCompare"), +1

	m_IsScaned = True
	m_IsFolderScaned = False
End Sub


 
'*************************************************************************
'  <<< [PathDictionaryClass::Me_ScanFolder] >>> 
'*************************************************************************
Private Sub  Me_ScanFolder()
	Me.FoldersDictionary.RemoveAll
	Me.DeleteFoldersDictionary.RemoveAll

	For Each  file_path  In Me.FilesDictionary.Keys
		path = file_path
		Do
			path = g_fs.GetParentFolderName( path )
			If path = "" Then  Exit Do

			If Me.FoldersDictionary.Exists( path ) Then
				Exit Do
			End If

			Me.FoldersDictionary( path )= True
		Loop
	Next


	'// Set "Me.FoldersArray" : Sorted array
	DicToArr  Me.FoldersDictionary, FoldersArray  '//[out] Me.FoldersArray
	QuickSort  FoldersArray, 0, UBound( FoldersArray ), GetRef("PathNameCompare"), +1


	'// Set "remove_file_folders" from "Me.AddRemove()"
	Set remove_file_folders = CreateObject( "Scripting.Dictionary" )
	For Each  file_path  In Me.RemoveFilesDictionary.Keys
		path = file_path
		Do
			path = g_fs.GetParentFolderName( path )
			If path = "" Then  Exit Do

			If remove_file_folders.Exists( path ) Then
				Exit Do
			End If

			remove_file_folders( path )= True
		Loop
	Next


	'// "Me.DeleteFoldersDictionary" : Include sub folders
	'// Set "delete_folders"
	delete_folders = Array( )
	For Each  folder  In Me.FoldersArray
		If not remove_file_folders.Exists( folder.Name ) Then
			ReDim Preserve  delete_folders( UBound( delete_folders ) + 1 )
			Set delete_folders( UBound( delete_folders ) ) = folder

			Me.DeleteFoldersDictionary( folder.Name ) = False
		End If
	Next


	'// Set "Me.DeleteFoldersArray"
	'// Set "delete_folders"
	ReverseObjectArray  delete_folders,  delete_folders_reverse
	delete_folders = Array( )
	For Each  folder  In delete_folders_reverse
		path = g_fs.GetParentFolderName( folder.Name )

		If path = "" Then
			is_add = True
		ElseIf Me.DeleteFoldersDictionary.Exists( path ) Then
			is_add = False
		Else
			is_add = True
		End If

		If is_add Then
			ReDim Preserve  delete_folders( UBound( delete_folders ) + 1 )
			Set delete_folders( UBound( delete_folders ) ) = folder
		End If
	Next
	ReverseObjectArray  delete_folders,  DeleteFoldersArray


	m_IsFolderScaned = True
End Sub


 
'*************************************************************************
'  <<< [PathDictionaryClass::LogSetToFilesDictionary] >>> 
'*************************************************************************
Public Sub  LogSetToFilesDictionary( in_StepPath,  in_Key )
	If Me.IsDebugLog Then
		echo_v  "    "+ in_Key +" => "+ in_StepPath
		'// If InStr( 1, in_StepPath, "setting", 1 ) >= 1 Then  Stop:OrError
	End If
End Sub


' ### <<<< End of Class implement >>>> 
End Class


 
'*************************************************************************
'  <<< [GetBasePath] >>> 
'*************************************************************************
Function  GetBasePath( in_StringOrObject )
	If VarType( in_StringOrObject ) = vbString Then
		GetBasePath = in_StringOrObject
	ElseIf IsObject( in_StringOrObject ) Then
		GetBasePath = in_StringOrObject.BasePath
	End If
End Function


 
'***********************************************************************
'* Function: OpenPickUpCopy
'***********************************************************************
Function  OpenPickUpCopy( in_SettingFilePathWithID )
	Set Me_ = new OpenPickUpCopyClass
	Me_.Initialize  in_SettingFilePathWithID,  in_Empty
	Set OpenPickUpCopy = Me_
End Function


 
'***********************************************************************
'* Class: OpenPickUpCopyClass
'*********************************************************************** 
Class  OpenPickUpCopyClass
	Public  SettingFilePathWithID
	Public  RootTag
	Public  Variables
	Public  PickUpCopyTag
	Public  BasePathOfXML
	Public  Me_SourcePath


 
'***********************************************************************
'* Method: Initialize
'*    Subroutine of OpenPickUpCopy.
'***********************************************************************
Sub  Initialize( in_SettingFilePathWithID,  in_Empty )
	setting_file_path_with_ID = GetFilePathString( in_SettingFilePathWithID )
	If TypeName( in_SettingFilePathWithID ) = "FilePathClass" Then
		Set jumps = GetTagJumpParams( setting_file_path_with_ID )
		Set root = LoadXML( in_SettingFilePathWithID,  Empty )
	Else
		Set jumps = GetTagJumpParams( setting_file_path_with_ID )
		Set root = LoadXML( jumps.Path,  Empty )
	End If
	Me.SettingFilePathWithID = GetFullPath( setting_file_path_with_ID,  Empty )
	Set Me.RootTag = root
	Set Me.Variables = LoadVariableInXML( root,  jumps.Path )
	If IsEmpty( jumps.Keyword ) Then
		xpath = "//PickUpCopy"
	Else
		xpath = "//PickUpCopy[@id='"+ jumps.Keyword +"']"
	End If
	Set Me.PickUpCopyTag = Me.RootTag.selectSingleNode( xpath )
	If Me.PickUpCopyTag is Nothing Then _
		Raise  1, "<ERROR msg=""Not found"" path="""+ XmlAttr( Me.SettingFilePathWithID ) +"""/>"
	Me.BasePathOfXML = GetParentFullPath( jumps.Path )
End Sub


 
'***********************************************************************
'* Method: GetDefaultSourcePath
'*
'* Name Space:
'*    OpenPickUpCopyClass::GetDefaultSourcePath
'***********************************************************************
Function  GetDefaultSourcePath()
	default_source_path = Me.PickUpCopyTag.getAttribute( "default_source_path" )
	If IsNull( default_source_path ) Then _
		default_source_path = Empty
	GetDefaultSourcePath = GetFullPath( Me.Variables( default_source_path ),  Me.BasePathOfXML )
End Function


 
'***********************************************************************
'* Method: GetDefaultDestinationPath
'*
'* Name Space:
'*    OpenPickUpCopyClass::GetDefaultDestinationPath
'***********************************************************************
Function  GetDefaultDestinationPath( in_SourcePath )

	'// Set "in_SourcePath"
	If IsEmpty( in_SourcePath ) Then
		default_source_path = Me.PickUpCopyTag.getAttribute( "default_source_path" )
		If IsNull( default_source_path ) Then _
			Raise  1, "<ERROR msg=""Not found default_source_path attribute in PickUpCopy tag.""/>"

		Me_SourcePath = GetFullPath( Me.Variables( default_source_path ),  Me.BasePathOfXML )
	Else
		Me_SourcePath = GetFullPath( in_SourcePath,  Empty )
	End If

	'// Set "vars_"
	Set vars_ = new LazyDictionaryClass
	vars_.AddDictionary  Me.Variables
	vars_( "${SourceFolderName}" ) = g_fs.GetFileName( Me_SourcePath )

	'// Set "default_destination_path"
	default_destination_path = Me.PickUpCopyTag.getAttribute( "default_destination_path" )
	GetDefaultDestinationPath = GetFullPath( vars_( default_destination_path ),  GetParentFullPath( Me_SourcePath ) )
End Function


 
'***********************************************************************
'* Method: Copy
'*
'* Name Space:
'*    OpenPickUpCopyClass::Copy
'***********************************************************************
Sub  Copy( ByVal in_SourcePath,  ByVal in_DestinationPath,  in_Empty )

	'// Set "in_DestinationPath"
	If IsEmpty( in_DestinationPath ) Then
		in_DestinationPath = Me.GetDefaultDestinationPath( in_SourcePath )
		in_SourcePath = Me_SourcePath
	Else
		in_DestinationPath = GetFullPath( in_DestinationPath,  Empty )
		If IsEmpty( in_SourcePath ) Then
			in_SourcePath = Me.GetDefaultSourcePath()
		Else
			in_SourcePath = GetFullPath( in_SourcePath,  Empty )
		End If
	End If

	echo  ">Copy  """+ in_SourcePath +""", """+ in_DestinationPath +""""
	Set ec = new EchoOff
	If TryStart(e) Then  On Error Resume Next

		AssertExist  in_SourcePath

	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then
		e.OverRaise  e.Number,  AppendErrorMessage( e.Description, _
			"in="""+ Me.SettingFilePathWithID +"""" )
	End If

	in_SourcePath      = GetPathWithSeparator( in_SourcePath )
	in_DestinationPath = GetPathWithSeparator( in_DestinationPath )


	'// Set "files"
	Set files = new_PathDictionaryClass_fromXML( Me.PickUpCopyTag.selectNodes( "Folder | File" ), "path", _
		in_SourcePath )
	Set ds = new CurDirStack
	cd  in_SourcePath


	'// Scan
	If TryStart(e) Then  On Error Resume Next

		files.LeafPaths  '// Scan

	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then
		e.OverRaise  e.Number,  AppendErrorMessage( e.Description, _
			"in="""+ Me.SettingFilePathWithID +"""" )
	End If


	'// Copy
	For Each  step_path  In  files.LeafPaths
		destination_path = in_DestinationPath + step_path
		If g_fs.FolderExists( step_path ) Then
			mkdir  destination_path
		Else
			copy_ren  step_path,  destination_path
		End If
	Next
End Sub


 
End Class

'* Section: Global


 
'*************************************************************************
'  <<< [NewDiffFilePaths] >>> 
'*************************************************************************
Function  NewDiffFilePaths( in_PathArray, in_RemovePathArray )
	Set dic_A_B = CreateObject( "Scripting.Dictionary" )
	i_max = UBound( in_PathArray )
	ReDim  dummys( i_max )
	ReDim  dic( i_max )

	For  i = 0  To  i_max
		Set dummys(i) = new PathDictionaryClass
		dummys(i).BasePath = in_PathArray(i)

		Set dic(i) = new_PathDictionaryClass_withRemove( _
			in_PathArray(i), in_RemovePathArray, dummys(i) )
	Next
	For  i = 0  To  i_max
		Dic_addFilePaths_fromPathDirectory  dic_A_B, i, i_max, dic(i).BasePath, dic(i), dummys(i)
	Next
	Set NewDiffFilePaths = dic_A_B
End Function


 
'*************************************************************************
'  <<< [GetItemsFromDiffFilePathsDictionary] >>> 
'*************************************************************************
Sub  GetItemsFromDiffFilePathsDictionary( in_DiffFilePathsDictionary, out_ItemArray )
	Set base_path_dic = CreateObject( "Scripting.Dictionary" )

	For Each  files  In  in_DiffFilePathsDictionary.Items
		For i = 0  To  files.UBound_
			If not files( i ) Is Nothing Then
				Set base_path_dic( files( i ).BasePath ) = files( i )
			End If
		Next

		If base_path_dic.Count = files.Count Then  Exit For
	Next

	DicItemToArr  base_path_dic, out_ItemArray
End Sub


 
'*************************************************************************
'  <<< [Dic_addFilePaths_fromPathDirectory] >>> 
'*************************************************************************
Function  Dic_addFilePaths_fromPathDirectory( in_out_Dictionary, in_SetIndex, in_MaxIndex, _
		in_BasePath, in_PathDictionary, in_Item )

	If IsEmpty( in_out_Dictionary ) Then
		Set in_out_Dictionary = CreateObject( "Scripting.Dictionary" )
		in_out_Dictionary.CompareMode = 1
	End If

	is_error_back_up = in_PathDictionary.IsNotFoundError
	in_PathDictionary.IsNotFoundError = False


	For Each  full_path  In  in_PathDictionary.FullPaths
		If in_PathDictionary( full_path )  is  in_Item Then

			'// Set "key"
			If IsEmpty( in_BasePath ) Then
				key = full_path
			Else
				key = GetStepPath( full_path, in_BasePath )
			End If


			'// Set "item_array"
			If in_out_Dictionary.Exists( key ) Then
				Set item_array = in_out_Dictionary( key )
			Else
				Set item_array = new ArrayClass
				Set in_out_Dictionary( key ) = item_array
				item_array.ReDim_  in_MaxIndex
				For index = 0  To in_MaxIndex
					Set item_array( index ) = Nothing
				Next
			End If

			Set item_array( in_SetIndex ) = in_Item
		End If
	Next

	in_PathDictionary.IsNotFoundError = is_error_back_up

	Set Dic_addFilePaths_fromPathDirectory = in_out_Dictionary
End Function


 
'*************************************************************************
'  <<< [Dic_addFilePaths_fromOtherPathDirectory] >>> 
'*************************************************************************
Function  Dic_addFilePaths_fromOtherPathDirectory( in_out_Dictionary, in_SetIndex, in_MaxIndex, _
		in_BasePath, in_NewItem, _
		in_OtherBasePath, in_OtherPathDictionary, in_OtherItem )

	If IsEmpty( in_out_Dictionary ) Then
		Set in_out_Dictionary = CreateObject( "Scripting.Dictionary" )
		in_out_Dictionary.CompareMode = 1
	End If

	Set new_path_directory = new PathDictionaryClass
	new_path_directory.BasePath = in_BasePath

	For Each  key  In  in_OtherPathDictionary.Keys
		If IsFullPath( key ) Then
			step_path = GetStepPath( key, in_OtherBasePath )
		Else
			step_path = key
		End If
		If Left( step_path, 2 ) <> ".." Then
			full_path = GetFullPath( step_path, in_BasePath )
			If exist( full_path ) Then
				If in_OtherPathDictionary( key )  is  in_OtherItem Then
					Set new_path_directory( full_path ) = in_NewItem
				Else
					Set new_path_directory( full_path ) = new_path_directory.RemovedObject
				End If
			End If
		End If
	Next


	Set Dic_addFilePaths_fromOtherPathDirectory = Dic_addFilePaths_fromPathDirectory( _
		in_out_Dictionary, in_SetIndex, in_MaxIndex, _
		in_BasePath,  new_path_directory,  in_NewItem )
End Function


 
'*************************************************************************
'  <<< [SplitPathToSubFolderSign] >>> 
'*************************************************************************
Sub  SplitPathToSubFolderSign( in_out_Path, out_SubFolderSign, out_IsFolder, out_Separator )

	root_pos = GetRootSeparatorPosition( in_out_Path )


	'// Set "out_IsFolder"
	right_1 = Right( in_out_Path, 1 )
	If right_1 = "\"  or  right_1 = "/" Then  '// If there is the last separator
		out_IsFolder = True

		path_length = Len( in_out_Path )
		If root_pos = path_length Then
			out_SubFolderSign = ""
			out_Separator = right_1

			Exit Sub
		End If

		in_out_Path = Left( in_out_Path, path_length - 1 )
	Else
		out_IsFolder = False
	End If


	'// Set "last_separator_position"
	back_slash_position = InStrRev( in_out_Path, "\" )
	slash_position = InStrRev( in_out_Path, "/" )
	If back_slash_position > slash_position Then
		last_separator_position = back_slash_position
	Else
		last_separator_position = slash_position
	End If

	If last_separator_position = 0 Then
		out_SubFolderSign = ""

		If right_1 = "/" Then
			out_Separator = "/"
		Else
			out_Separator = "\"
		End If

		Exit Sub
	End If

	out_Separator = Mid( in_out_Path, last_separator_position, 1 )

	If last_separator_position = root_pos Then
		Select Case  g_fs.GetFileName( in_out_Path )
			Case "."
				path_length = Len( in_out_Path )
				If path_length - 1 = root_pos Then
					in_out_Path = Left( in_out_Path, path_length - 1 )
				Else
					in_out_Path = Left( in_out_Path, path_length - 2 )
				End If
			Case Else
				out_SubFolderSign = ""
		End Select

		Exit Sub
	End If


	'// Set "last2_separator_position"
	back_slash_position = InStrRev( in_out_Path, "\", last_separator_position - 1 )
	slash_position = InStrRev( in_out_Path, "/", last_separator_position - 1 )
	If back_slash_position > slash_position Then
		last2_separator_position = back_slash_position
	Else
		last2_separator_position = slash_position
	End If


	'// Set "out_SubFolderSign"
	parent_name = Mid( in_out_Path, _
		last2_separator_position + 1, _
		last_separator_position - last2_separator_position - 1 )
	Select Case  parent_name
		Case  "*" : out_SubFolderSign = parent_name
		Case  "." : out_SubFolderSign = parent_name
		Case Else : out_SubFolderSign = ""
	End Select


	'// Set "in_out_Path"
	If out_SubFolderSign = "" Then
		Select Case  g_fs.GetFileName( in_out_Path )
			Case "."
				in_out_Path = Left( in_out_Path, Len( in_out_Path ) - 2 )
		End Select
	Else
		in_out_Path = Left( in_out_Path, last2_separator_position ) +_
			Mid( in_out_Path, last_separator_position + 1 )
	End If
End Sub


 
'*************************************************************************
'  <<< [GetSubFolders] >>> 
' argument
'  - folders : (out) array of folder pathes
'  - path : base folder path
'*************************************************************************
Sub  GetSubFolders( folders, ByVal path )
	ReDim  folders(-1)
	EnumSubFolders  folders, g_fs.GetFolder( path )
End Sub

Sub  EnumSubFolders( folders, fo )
	Dim  subfo

	ReDim Preserve  folders( UBound(folders) + 1 )
	folders( UBound(folders) ) = fo.Path

	For Each subfo in fo.SubFolders
		EnumSubFolders  folders, subfo
	Next
End Sub


 
'*************************************************************************
'  <<< [EnumFolderObject] >>> 
'*************************************************************************
Sub  EnumFolderObject( in_FolderPath,  out_Folders )
	Dim  i_set, i_get, n, f

	ReDim  out_Folders(0)
	AssertExist  in_FolderPath
	Set out_Folders(0) = g_fs.GetFolder( in_FolderPath )
	i_set = 1 : i_get = 0

	While  i_get <= UBound( out_Folders )
		n = out_Folders( i_get ).SubFolders.Count
		ReDim Preserve  out_Folders( UBound( out_Folders ) + n )
		For Each f  In  out_Folders( i_get ).SubFolders
			Set out_Folders( i_set ) = f
			i_set = i_set + 1
		Next
		i_get = i_get + 1
	WEnd
End Sub


 
'*************************************************************************
'  <<< [EnumFolderObjectDic] >>> 
'*************************************************************************
Sub  EnumFolderObjectDic( in_FolderPath,  in_EmptyOption,  out_Folders )
	Dim  folders,  step_pos,  fo

	EnumFolderObject  in_FolderPath,  folders   '// Set "folders"
	step_pos = Len( folders(0).Path ) + 2

	Set out_Folders = CreateObject( "Scripting.Dictionary" )
	For Each fo  In folders  '// fo as Folder
		Set out_Folders( Mid( fo.Path, step_pos ) ) = fo
	Next
	Set out_Folders( "." ) = folders(0)
	out_Folders.Remove  ""
End Sub


 
'*************************************************************************
'  <<< [EnumFileObjectDic] >>> 
'*************************************************************************
Sub  EnumFileObjectDic( ByVal FolderOrPath, out_Files )
	Dim  files,  fi

	If VarType( FolderOrPath ) = vbString Then  Set FolderOrPath = g_fs.GetFolder( FolderOrPath )

	Set out_Files = CreateObject( "Scripting.Dictionary" )
	For Each fi  In FolderOrPath.Files
		Set out_Files( fi.Name ) = fi
	Next
End Sub


 
'*************************************************************************
'  <<< [IsMatchedWithWildcard] >>> 
'*************************************************************************
Function  IsMatchedWithWildcard( in_Path, in_WildCard )
	parent_of_path = g_fs.GetParentFolderName( in_Path )
	If Left( in_WildCard, 1 ) = "*" Then
		parent_of_wildcard = parent_of_path  '// For next if
	Else
		parent_of_wildcard = g_fs.GetParentFolderName( in_WildCard )
	End If
	If StrComp( parent_of_path,  parent_of_wildcard, 1 ) <> 0 Then
		is_match = False
	Else
		file_name_of_path     = g_fs.GetFileName( in_Path )
		file_name_of_wildcard = g_fs.GetFileName( in_WildCard )

		GetWildcardTester_sub  g_fs.GetFileName( in_WildCard ),  re, re2  '//(out)re, re2

		If re is Nothing Then
			is_match = ( StrComp( file_name_of_path,  file_name_of_wildcard, 1 ) = 0 )
		ElseIf re2 is Nothing Then
			If TypeName( re ) = "StrMatchKey" Then
				is_match = re.IsMatch( file_name_of_path )
			Else
				is_match = re.Test( file_name_of_path )
			End If
		Else
			is_match = ( re2.Test( file_name_of_path )  and  InStr( file_name_of_path, "." ) = 0 )  'and
			If not is_match Then  'or
				If TypeName( re ) = "NameOnlyClass" Then
					is_match = ( LCase( file_name_of_path ) = re.Delegate )
				Else
					is_match = re.Test( file_name_of_path )
				End If
			End If
		End If
	End If

	IsMatchedWithWildcard = is_match
End Function


 
'*************************************************************************
'  <<< [RemoveWildcardMatchedArrayItems] >>> 
'*************************************************************************
Sub  RemoveWildcard( WildCard, in_out_PathArray )  '//[RemoveWildcard]
	RemoveWildcardMatchedArrayItems  in_out_PathArray, WildCard
	ThisIsOldSpec
End Sub

Sub  RemoveWildcardMatchedArrayItems( in_out_PathArray, WildCard )
	Dim  s, path, fname, i, n, wc, wc_len


	'//=== Check by with wildcard
	If Left( WildCard, 1 ) = "*" Then
		wc = LCase( Mid( WildCard, 2 ) ) : wc_len = Len( wc )
		n = UBound( in_out_PathArray )
		For i = 0 To  n
			path = in_out_PathArray(i)
			Do
				fname = g_fs.GetFileName( path )
				If LCase( Right( fname, wc_len ) ) = wc Then  in_out_PathArray(i) = Empty : Exit Do
				path = g_fs.GetParentFolderName( path )
				If path = "" Then Exit Do
			Loop
		Next


	'//=== Check by no wildcard
	Else
		Assert  InStr( Wildcard, "*" ) = 0
		wc = LCase( WildCard )
		n = UBound( in_out_PathArray )
		For i = 0 To n
			path = in_out_PathArray(i)
			Do
				fname = g_fs.GetFileName( path )
				If LCase( fname ) = wc Then  in_out_PathArray(i) = Empty : Exit Do
				path = g_fs.GetParentFolderName( path )
				If path = "" Then Exit Do
			Loop
		Next
	End If


	'//=== shrink the array
	n = 0
	For i = 0 To UBound( in_out_PathArray )
		If not IsEmpty( in_out_PathArray(i) ) Then _
			in_out_PathArray(n) = in_out_PathArray(i) : n = n + 1
	Next
	Redim Preserve  in_out_PathArray( n - 1 )
End Sub


 
'*************************************************************************
'  <<< [RemoveWildcard] >>> 
'*************************************************************************
Sub  RemoveWildcard( WildCard, fnames )
	Dim  s, path, fname, i, n, wc, wc_len

ThisIsOldSpec

	'//=== check by with wildcard
	If Left( WildCard, 1 ) = "*" Then
		wc = LCase( Mid( WildCard, 2 ) ) : wc_len = Len( wc )
		n = UBound( fnames )
		For i = 0 To  n
			path = fnames(i)
			Do
				fname = g_fs.GetFileName( path )
				If LCase( Right( fname, wc_len ) ) = wc Then  fnames(i) = Empty : Exit Do
				path = g_fs.GetParentFolderName( path )
				If path = "" Then Exit Do
			Loop
		Next


	'//=== check by no wildcard
	Else
		wc = LCase( WildCard )
		n = UBound( fnames )
		For i = 0 To n
			path = fnames(i)
			Do
				fname = g_fs.GetFileName( path )
				If LCase( fname ) = wc Then  fnames(i) = Empty : Exit Do
				path = g_fs.GetParentFolderName( path )
				If path = "" Then Exit Do
			Loop
		Next
	End If


	'//=== shrink the array
	n = 0
	For i = 0 To UBound( fnames )
		If not IsEmpty( fnames(i) ) Then  fnames(n) = fnames(i) : n = n + 1
	Next
	Redim Preserve  fnames( n - 1 )
End Sub


 
'*************************************************************************
'  <<< [SetIniFileTextValue] >>> 
'*************************************************************************
Function  SetIniFileTextValue( Text, SectionName, VariableName, Value, Option_ )
	SearchInIniFileText  Text, SectionName, VariableName, Option_, line  '//(out) line

	If line is Nothing Then _
		Raise  E_PathNotFound, "<ERROR msg=""Not found VariableName"" variable_name="""+ _
			VariableName+"""/>"

	SetIniFileTextValue = Left( Text, line.EqualPosition ) & " " & Value & _
		Mid( Text, line.OverPosition  )
End Function


 
'*************************************************************************
'  <<< [ParseIniFileLine] >>> 
'*************************************************************************
Function  ParseIniFileLine( in_Line )
	Set return = new ParsedIniFileLineClass
	a_line = Trim2( in_Line )
	If Left( a_line, 1 ) = "[" Then
		If Right( a_line, 1 ) = "]" Then
			a_line = Mid( a_line, 2, Len( a_line ) - 2 )
		Else
			a_line = Mid( a_line, 2, Len( a_line ) - 1 )
		End If
		return.Section = Trim( a_line )
	Else
		equal_position = InStr( a_line, "=" )
		If equal_position > 0 Then
			return.Name = Trim2( Left( a_line, equal_position - 1 ) )
			return.Value = Trim2( Mid( a_line, equal_position + 1 ) )
		End If
	End If
	Set ParseIniFileLine = return
End Function

Class  ParsedIniFileLineClass
	Public  Section
	Public  Name
	Public  Value
End Class


 
'*************************************************************************
'  <<< [GetIniFileTextValue] >>> 
'*************************************************************************
Function  GetIniFileTextValue( Text, SectionName, VariableName, Option_ )
	SearchInIniFileText  Text, SectionName, VariableName, Option_, line  '//(out) line

	If line is Nothing Then _
		Exit Function

	value = Trim2( Mid( Text, line.EqualPosition + 1, _
		line.OverPosition - line.EqualPosition ) )
	If IsNumeric( value ) Then  value = Eval( value )
	GetIniFileTextValue = value
End Function


 
'*************************************************************************
'  <<< [GetIniFileTextValues] >>> 
'*************************************************************************
Function  GetIniFileTextValues( Text, ByVal SectionName, VariableName, Option_ )
	Set ret = new ArrayClass
	Do
		SearchInIniFileText  Text, SectionName, VariableName, Option_, line  '//(out) line
		If line is Nothing Then _
			Exit Do

		value = Trim2( Mid( Text, line.EqualPosition + 1, _
			line.OverPosition - line.EqualPosition ) )
		If IsNumeric( value ) Then  value = Eval( value )

		ret.Add  value

		SectionName = line.OverPosition
	Loop
	GetIniFileTextValues = ret.Items
End Function


'*************************************************************************
'  <<< [SearchInIniFileText] >>> 
'*************************************************************************
Sub  SearchInIniFileText( Text, SectionName, VariableName, Option_, out_Line )
	Set c = g_VBS_Lib
	name_length = Len( VariableName )

	'// Set "section_start", "section_over"
	If IsEmpty( SectionName ) Then
		section_start = 1
		section_over = Len( Text ) + 1
	ElseIf VarType( SectionName ) = vbString Then
		If Left( SectionName, 1 ) = "[" Then
			section_keyword = SectionName
		Else
			section_keyword = "["+ SectionName +"]"
		End If
		section_start = InStrEx( Text, section_keyword, 0, c.LineHead or c.LineTail )
		section_over  = InStrEx( Text, "[", section_start + 1, c.LineHead )
		If section_over = 0 Then _
			section_over = Len( Text ) + 1
	Else
		Assert  IsNumeric( SectionName )
		section_start = SectionName
		section_over  = InStrEx( Text, "[", section_start + 1, c.LineHead )
		If section_over = 0 Then _
			section_over = Len( Text ) + 1
	End If

	Set line = new IniFileTextLineClass
	p = section_start
	Do
		p = InStrEx( Text, VariableName, p, c.LineHead or c.WholeWord )
		If p = 0  or  p >= section_over Then
			Set out_Line = Nothing
			Exit Sub
		End If

		q = InStr( p + name_length, Text, "=" )
		If Trim2( Mid( Text, p, q - p ) ) = VariableName Then
			line.HeadPosition = p
			line.EqualPosition = q
			Exit Do
		End If

		p = p + 1
	Loop

	line.OverPosition = InStr( line.EqualPosition, Text, vbCRLF )
	If line.OverPosition = 0 Then
		line.OverPosition = Len( Text ) + 1
	End If

	Set out_Line = line
End Sub


Class  IniFileTextLineClass
	Public  HeadPosition
	Public  OverPosition
	Public  EqualPosition
End Class


 
'*************************************************************************
'  <<< [RenumberIniFileData] >>> 
'*************************************************************************
Sub  RenumberIniFileData( ReadStream, WriteStream, StartNumber, IsPlusSpaceLineOnly )
	number = StartNumber
	is_space_line_previous = True

	Do Until  ReadStream.AtEndOfStream()
		line = ReadStream.ReadLine()

		equal_position = InStr( line, "=" )
		left_position  = InStr( line, "(" )
		right_position = InStr( line, ")" )
		If equal_position > 0  and  left_position > 0  and  right_position > 0  and _
			left_position < equal_position  and  right_position < equal_position  and _
			left_position < right_position  Then

			line = Left( line, left_position ) & number & Mid( line, right_position )
		End If

		WriteStream.WriteLine  line


		'// Plus "number"
		If IsPlusSpaceLineOnly Then
			If Trim( line ) = "" Then
				If is_space_line_previous = False Then
					number = number + 1
				End If
				is_space_line_previous = True
			Else
				is_space_line_previous = False
			End If
		Else
			number = number + 1
		End If
	Loop
End Sub


 
'*************************************************************************
'  <<< [ParseJSON] >>> 
'*************************************************************************
Function  ParseJSON( JSON_String )
	Set sc = CreateObject("ScriptControl")
	sc.Language = "JScript"
	sc.AddCode  "function parseJSON(s) { return eval('(' + s + ')'); }"
	Set ParseJSON = sc.CodeObject.parseJSON( JSON_String )
End Function


 
'*************************************************************************
'  <<< [MeltCSV] >>> 
'*************************************************************************
Function  MeltCSV( Line, in_out_Start )
	Dim  s, i, c

	i = in_out_Start

	If i=0 Then Exit Function


	'//=== Skip space character
	Do
		c = Mid( Line, i, 1 )
		If c<>" " and c<>vbTab Then Exit Do
		i = i + 1
	Loop

	Select Case  c

	 '//=== If enclosed by " "
	 Case """"
		s = ""
		Do
			i = i + 1
			c = Mid( Line, i, 1 )
			If c = "" Then Exit Do
			If c = """" Then
				i = i + 1
				c = Mid( Line, i, 1 )
				If c = """" Then  s = s + c  Else  Exit Do
			Else
				s = s + c
			End If
		Loop

		MeltCSV = s

		Do
			If c = "" Then  in_out_Start = 0 : Exit Function
			If c = "," Then  in_out_Start = i+1 : Exit Function
			i = i + 1
			c = Mid( Line, i, 1 )
		Loop


	 '//=== If no value
	 Case ","
		in_out_Start = i+1 : Exit Function
	 Case ""
		in_out_Start = 0 : Exit Function


	 '//=== If NOT enclosed by " "
	 Case Else
		Do
			If c = "" or c = "," Then Exit Do
			s = s + c
			i = i + 1
			c = Mid( Line, i, 1 )
		Loop

		MeltCSV = Trim2( s )

		If c = "" Then  in_out_Start = 0 : Exit Function
		If c = "," Then  in_out_Start = i+1 : Exit Function
	End Select
End Function


 
'*************************************************************************
'  <<< [CSVText] >>> 
'*************************************************************************
Function  CSVText( s )
	If InStr( s, """" ) = 0 and  InStr( s, "," ) = 0 and  InStr( s, vbCRLF ) = 0 and _
		 	Left( s, 1 ) <> " " and  Right( s, 1 ) <> " " Then
		CSVText = CStr( s )
	Else
		CSVText = """" + Replace( s, """", """""" ) + """"
	End If
End Function


 
'*************************************************************************
'  <<< [CSV_insert] >>> 
'*************************************************************************
Function  CSV_insert( CSV_Line, RightColumnNum0, Element )
	CSV_insert = CSV_insert_or_set( CSV_Line, RightColumnNum0, Element, True )
End Function


Function  CSV_insert_or_set( CSV_Line, RightColumnNum0, Element, IsInsert )
	If RightColumnNum0 < 0 Then  Error

	column_num = 0
	text_position = 1
	Do
		If column_num = RightColumnNum0 Then _
			Exit Do

		MeltCSV  CSV_Line, text_position  '//(in/out)text_position
		column_num = column_num + 1
		If text_position = 0 Then
			CSV_insert_or_set = CSV_Line +_
				String( RightColumnNum0 - column_num + 1, "," ) +_
				CSVText( Element )
			Exit Function
		End If
	Loop

	If Trim( CSV_Line ) = "" Then
		CSV_insert_or_set = CSVText( Element )
	Else
		If IsInsert Then
			CSV_insert_or_set = Left( CSV_Line, text_position - 1 ) + _
				CSVText( Element ) +","+ _
				Mid( CSV_Line, text_position )
		Else
			next_position = text_position
			MeltCSV  CSV_Line, next_position  '//(in/out)next_position

			If next_position = 0 Then
				CSV_insert_or_set = Left( CSV_Line, text_position - 1 ) + _
					CSVText( Element )
			Else
				CSV_insert_or_set = Left( CSV_Line, text_position - 1 ) + _
					CSVText( Element ) +","+ _
					Mid( CSV_Line, next_position )
			End If
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [CSV_set] >>> 
'*************************************************************************
Function  CSV_set( CSV_Line, ColumnNum0, Element )
	CSV_set = CSV_insert_or_set( CSV_Line, ColumnNum0, Element, False )
End Function


 
'*************************************************************************
'  <<< [CSV_remove] >>> 
'*************************************************************************
Function  CSV_remove( CSV_Line, ColumnNum0 )
	If ColumnNum0 < 0 Then  Error

	column_num = 0
	text_position = 1
	Do
		If column_num = ColumnNum0 Then _
			Exit Do

		MeltCSV  CSV_Line, text_position  '//(in/out)text_position
		column_num = column_num + 1
		If text_position = 0 Then
			If CSV_Line = "" Then
				CSV_remove = _
					String( ColumnNum0 - column_num + 1, "," )
			Else
				CSV_remove = CSV_Line +_
					String( ColumnNum0 - column_num, "," )
			End IF
			Exit Function
		End If
	Loop

	next_position = text_position
	MeltCSV  CSV_Line, next_position  '//(in/out)next_position

	If next_position = 0 Then
		If text_position = 1 Then
			CSV_remove = ""
		Else
			CSV_remove = Left( CSV_Line, text_position - 2 )
		End If
	Else
		CSV_remove = Left( CSV_Line, text_position - 1 ) + _
			Mid( CSV_Line, next_position )
	End If
End Function


 
'*************************************************************************
'  <<< [XmlAttr] >>> 
'*************************************************************************
Function  XmlAttr( s )
	XmlAttr = Replace( s, "&", "&amp;" )
	XmlAttr = Replace( XmlAttr, """", "&quot;" )
	XmlAttr = Replace( XmlAttr, "<", "&lt;" )
End Function


 
'*************************************************************************
'  <<< [XmlAttrA] >>> 
'*************************************************************************
Function  XmlAttrA( s )
	XmlAttrA = Replace( s, "&", "&amp;" )
	XmlAttrA = Replace( XmlAttrA, "'", "&apos;" )
	XmlAttrA = Replace( XmlAttrA, "<", "&lt;" )
End Function


 
'*************************************************************************
'  <<< [XmlText] >>> 
'*************************************************************************
Function  XmlText( s )
	XmlText = Replace( s, "&", "&amp;" )
	XmlText = Replace( XmlText, "<", "&lt;" )
	XmlText = Replace( XmlText, ">", "&gt;" )
End Function


 
'*************************************************************************
'  <<< [XmlTags] >>> 
'*************************************************************************
Function  XmlTags( Xml, Level )
	Dim  f : Set f = new StringStream

	f.SetString  Replace( Xml, vbTab, "  " )
	Do Until f.AtEndOfStream
		XmlTags = XmlTags + GetTab( Level ) + f.ReadLine() + vbCRLF
	Loop
	CutLastOf  XmlTags, vbCRLF, Empty
End Function


 
'*************************************************************************
'  <<< [GetTab] >>> 
'*************************************************************************
Function  GetTab( Level )
	GetTab = String( Level*2, " " )
End Function


 
'*************************************************************************
'  <<< [CutIndentOfMultiLineText] >>> 
'*************************************************************************
Function  CutIndentOfMultiLineText( in_Text,  in_Indent,  in_NewLine,  ByVal  in_Option )
	Set c = g_VBS_Lib
	If in_Text = "" Then
		CutIndentOfMultiLineText = ""
		Exit Function
	End If


	'// Set "in_Option" : "in_NewLine"
	If in_NewLine = vbLF  or  in_NewLine = "LF" Then
		in_Option = in_Option  or  c.KeepLineSeparators
	End If


	'// Cut last Tab
	last_line = Mid( in_Text, InStrRev( in_Text, vbLF, Len( in_Text ) ) + 1 )
	count_of_last_tab = Len( last_line )
	If  last_line <> String( count_of_last_tab, vbTab )  and _
			last_line <> String( count_of_last_tab, " " ) Then
		count_of_last_tab = 0
	End If


	'// Cut first CR+LF
	char_1 = Left( in_Text, 1 )  '// char = character
	If char_1 = vbLF Then
		start_position = 2
	ElseIf char_1 = vbCR Then
		If Mid( in_Text, 2, 1 ) = vbLF Then
			start_position = 3
		Else
			start_position = 2
		End If
	Else
		start_position = 1
	End If


	'// Set "file"
	Set file = new StringStream
	file.IsWithLineFeed = True
	text = Mid( in_Text,  start_position, _
		Len( in_Text ) - ( start_position - 1 ) - count_of_last_tab )
	file.SetString  text


	'// Set "minimum_count_of_tab"
	Do Until  file.AtEndOfStream()
		line = file.ReadLine()
		count_of_tab = 0

		Do
			a_char = Mid( line,  count_of_tab + 1,  1 )  '// a_char = a character
			If a_char <> vbTab  and  a_char <> " " Then _
				Exit Do
			count_of_tab = count_of_tab + 1
		Loop


		If IsEmpty( minimum_count_of_tab ) Then
			minimum_count_of_tab = count_of_tab
		Else
			If count_of_tab < minimum_count_of_tab Then _
				minimum_count_of_tab = count_of_tab
		End If
	Loop


	'// Set "return_value"
	return_value = ""
	start_position = minimum_count_of_tab + 1
	file.SetString  text
	Do Until  file.AtEndOfStream()
		line = file.ReadLine()


		'// Change return code
		right_3_line = Right( line, 3 )
		length_of_line = Len( line )
		If right_3_line = "\r"+ vbLF Then
			line = Left( line, length_of_line - 3 ) + vbCR
		ElseIf right_3_line = "\n"+ vbLF Then
			If Right( line, 5 ) = "\r\n"+ vbLF Then
				line = Left( line, length_of_line - 5 ) + vbCRLF
			Else
				line = Left( line, length_of_line - 3 ) + vbLF
			End If
		ElseIf Right( line, 2 ) <> vbCRLF Then
			If IsBitSet( in_Option, c.KeepLineSeparators ) Then
			Else
				If length_of_line >= 1 Then
					line = Left( line, length_of_line - 1 ) + vbCRLF
				Else
					line = ""
				End If
			End If
		End If


		'// Cut tabs in left of line
		return_value = return_value + Mid( line, start_position )
	Loop


	If IsBitSet( in_Option, c.CutLastLineSeparator ) Then
		CutLastOf  return_value,  vbLF,  c.CaseSensitive
		CutLastOf  return_value,  vbCR,  c.CaseSensitive
	End If


	If VarType( in_Indent ) = vbString Then
		Set out = ScanFromTemplate( in_Indent, _
			"${Count}*${Character}",  Array( "${Count}", "${Character}" ), Empty )
		left_of_line = String( CInt( out("${Count}") ), out("${Character}") )
		return_value = left_of_line + Replace( return_value,  vbLF,  vbLF + left_of_line )

		If IsBitNotSet( in_Option,  c.CutLastLineSeparator ) Then
			return_value = Left( return_value,  Len( return_value ) - Len( left_of_line ) )
		End If
	End If

	CutIndentOfMultiLineText = return_value
End Function


 
'*************************************************************************
'  <<< [get_XMLDomConsts] >>> 
'*************************************************************************
Dim  g_XMLDomConsts

Function    get_XMLDomConsts()
	If IsEmpty( g_XMLDomConsts ) Then _
		Set g_XMLDomConsts = new XMLDomConsts
	Set get_XMLDomConsts =   g_XMLDomConsts
End Function


Class  XMLDomConsts
	Public  XMLDOMElement, XMLDOMText

	Private Sub  Class_Initialize()
		XMLDOMElement = 1
		XMLDOMText    = 3
	End Sub
End Class


 
'*************************************************************************
'  <<< [FilePathClass] >>> 
'*************************************************************************
Class  FilePathClass
	Public  Text
	Public  FilePath
End Class


 
'*************************************************************************
'  <<< [new_FilePathForString] >>> 
'*************************************************************************
Function  new_FilePathForString( Text )
	Set object = new FilePathClass
	object.Text = Text
	object.FilePath = WScript.ScriptFullName
	Set new_FilePathForString = object
End Function


 
'********************************************************************************
'  <<< [new_FilePathForFileInScript] >>> 
'********************************************************************************
Function  new_FilePathForFileInScript( Parameter )
	Set object = new FilePathClass
	object.Text = ReadVBS_Comment( Parameter, "["+"FileInScript.", "[/"+"FileInScript.", Empty )

	If IsEmpty( Parameter ) Then
		object.FilePath = WScript.ScriptFullName
	Else
		object.FilePath = GetFullPath( Parameter, Empty )
	End If
	Set new_FilePathForFileInScript = object
End Function


 
'*************************************************************************
'  <<< [GetFilePathString] >>> 
'*************************************************************************
Function  GetFilePathString( Path )
	If TypeName( Path ) = "FilePathClass" Then
		GetFilePathString = Path.FilePath
	Else
		GetFilePathString = Path
	End If
End Function


 
'*************************************************************************
'  <<< [LoadXML] >>> 
'*************************************************************************
Const  F_NoRoot = 1
Const  F_Str = &h8000

Function  LoadXML( PathOrStr, Opt )
	Set co = g_VBS_Lib
	Dim  xml, r, t, i, c, f, is_bom, proc_inst
	Const  start_tag = "<Dummy_Root_>"
	Const  end_tag = "</Dummy_Root_>"


	If Opt and co.InheritSuperClass Then
		Set base = GetHRefBase( PathOrStr, Array("SuperClass") )
		Set root = base.Linker.StackOfSourceXmlRootElem( 0 )

		For Each  destination_tag  In  root.selectNodes( "//*[@super_class]" )
			Set super = base.href( destination_tag.getAttribute( "super_class" ) )
			For Each  attribute  In  super.attributes
				If attribute.name <> "id"  and  attribute.name <> "name" Then
					destination_tag.setAttribute  attribute.name, attribute.value
				End If
			Next
			destination_tag.removeAttribute  "super_class"
		Next

		For Each  super  In  root.selectNodes( "..//SuperClass" )
			If not IsNull( super.firstChild ) Then
				Set sibling = super.nextSibling
				Set parent = super.parentNode
				If IsNull( super.getAttribute( "id" ) ) Then _
					parent.removeChild  super
				For Each  child  In  super.childNodes
					super.removeChild  child
					If sibling is Nothing Then
						parent.appendChild  child
					Else
						parent.insertBefore  child, sibling
					End If

					For Each  attribute  In  super.attributes
						If attribute.name <> "id"  and  attribute.name <> "name" Then
							child.setAttribute  attribute.name, attribute.value
						End If
					Next
				Next
			End If
		Next

		Set LoadXML = root
		Exit Function
	End If


	If TypeName( PathOrStr ) = "FilePathClass" Then
		t = PathOrStr.Text
	ElseIf Opt and co.StringData Then
		i=1 : Do : c = Mid( PathOrStr, i, 1 ) : If c<>" " and c<>vbTab Then Exit Do
		i=i+1 : Loop
		If (Opt and co.NoRootXML)  or  c <> "<" Then
			t = start_tag + PathOrStr + end_tag
		Else
			t = PathOrStr
		End If
	Else
		Set f = OpenForRead( PathOrStr )
		t = ReadAll( f )
'//    If Left( t, 2 ) = Chr(&h8145)+Chr(&hBF) Then  t = Mid( t, 3 ) : is_bom = True  '// BOM of UTF-8

		'// ?xml encoding
		If InStr( t, "<" ) = InStr( t, "<?xml" ) Then
			Set xml = CreateObject("MSXML2.DOMDocument")
			xml.resolveExternals = false
			xml.validateOnParse = false
			r = xml.load( PathOrStr )
		Else
			i=1 : Do : c = Mid( t, i, 1 ) : If c<>" " and c<>vbTab Then Exit Do
			i=i+1 : Loop  '// Mid( t, i, 1 ) = "<"
			If (Opt and co.NoRootXML) or c<>"<" Then  t = start_tag + t + end_tag
		End If
	End If

	If IsEmpty( xml ) Then
		Set xml = CreateObject("MSXML2.DOMDocument")
		xml.resolveExternals = false
		xml.validateOnParse = false
		r = xml.loadXML( t )
	End IF
	If not r Then
		If xml.parseError.errorCode = &HC00CE555 Then  '// ルート要素が複数あるとき
			t = start_tag + t + end_tag
			r = xml.loadXML( t )
		End If
	End If
	If not r Then  Raise 1,"<ERROR msg=""Unicode でないか、正しい XML 形式になっていません"" PathOrStr="""+ _
		XmlAttr( GetFilePathString( PathOrStr ) ) +_
		""" line="""& xml.parseError.line &""" column_in_line="""& xml.parseError.linepos &""" reason="""+ _
		Trim2( xml.parseError.reason ) +"""><![CDATA["+ vbCRLF + xml.parseError.srcText + vbCRLF +"]]></ERROR>"
	Set LoadXML = xml.lastChild  '// If firstChild, <?xml> may be got.
End Function


 
'*************************************************************************
'  <<< [Read_XML_Encoding] >>> 
'*************************************************************************
Function  Read_XML_Encoding( in_Path )
	Set c = g_VBS_Lib

	Set file = OpenForRead( in_Path )
	text = ReadAll( file )

	ch_set = AnalyzeCharacterCodeSet( in_Path )  '// ch_set = CharacterCodeSet
	Select Case  ch_set
		Case  c.No_BOM,  c.UTF_8_No_BOM,  Empty
			Read_XML_Encoding = "UTF-8"
		Case  g_VBS_Lib.Unicode
			Read_XML_Encoding = "UTF-16"
		Case Else
			Read_XML_Encoding = GetStringFromCharacterCodeSet( ch_set )
	End Select
End Function


 
'*************************************************************************
'  <<< [LoadXML_Cached] >>> 
'*************************************************************************
Function  LoadXML_Cached( PathOrStr, Opt )
	If TypeName( PathOrStr ) = "FilePathClass"  or  IsBitSet( Opt, g_VBS_Lib.StringData ) Then
		Set LoadXML_Cached = LoadXML( PathOrStr, Opt )
	Else
		full_path = GetFullPath( PathOrStr, Empty )
		If g_VBS_Lib.XML_DOM_ReadCache.Exists( full_path ) Then
			Set LoadXML_Cached = g_VBS_Lib.XML_DOM_ReadCache( full_path )
		Else
			Set LoadXML_Cached = LoadXML( PathOrStr, Opt )
			Set g_VBS_Lib.XML_DOM_ReadCache( full_path ) = LoadXML_Cached
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [OpenForReplaceXML] >>> 
'*************************************************************************
Function  OpenForReplaceXML( SrcPath, DstPath )
	echo  ">OpenForReplaceXML  """+ SrcPath +""", """& DstPath &""""
	Dim  ec : Set ec = new EchoOff

	Dim  o : Set o = new ReplaceXmlFile1
	o.SrcPath = SrcPath
	o.DstPath = DstPath
	If LCase( GetFullPath( SrcPath, Empty ) ) = LCase( GetFullPath( DstPath, Empty ) ) Then
		o.DstPath = Empty
	End If
	o.IsUserConfirm = False
	Set o.WriteSets = new ArrayClass
	Set OpenForReplaceXML = o
End Function


Class  ReplaceXmlFile1
	Public  SrcPath
	Public  DstPath
	Public  IsUserConfirm
	Public  WriteSets  ' as ArrayClass of ReplaceXmlFile1_Sets

	Public Sub  Write( XPath, Value )
		Dim  o : Set o = new ReplaceXmlFile1_Sets
		o.XPath = XPath
		o.Value = Value
		Me.WriteSets.Add  o
	End Sub

	Private Sub  Class_Terminate()
		If Err.Number = 0 Then
			Dim  en,ed : en = Err.Number : ed = Err.Description
			On Error Resume Next  '// This clears the error

				Me.Close

			ErrorCheckInTerminate  en
			On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
		End If
	End Sub

 Public Sub  Close()
	Dim  b, is_change, a, tmp_path, value, text, format, flags
	Dim  c : Set c = g_VBS_Lib

	format = AnalyzeCharacterCodeSet( Me.SrcPath )
	Dim  root : Set root = LoadXML( Me.SrcPath, Empty ) '// as IXMLDOMElement


	'//=== ユーザーに確認をとる
	If Me.IsUserConfirm Then
		For Each a  In Me.WriteSets.Items
			value = XmlRead( root, a.XPath )
			If value = a.Value Then  Me.WriteSets.RemoveObject  a
		Next

		echo_line
		For Each a  In Me.WriteSets.Items
			echo  a.XPath +"="""+ a.Value +""""
		Next

		If Me.WriteSets.Count = 0 Then  Exit Sub

		If IsEmpty( Me.DstPath ) Then  tmp_path = Me.SrcPath  Else  tmp_path = Me.DstPath
		echo  "更新ファイル："+ tmp_path
		echo  "XML ファイルの上記属性を変更します。"
		pause
		echo_line
	End If


	Dim  ec : Set ec = new EchoOff


	'//=== DOM オブジェクトを修正する
	is_change = False
	For Each a  In Me.WriteSets.Items
		b= XmlWrite( root, a.XPath, a.Value )
		is_change = is_change or b
	Next


	'//=== ファイルに保存する
	If is_change Then
		Dim  sf : Set sf = new_IsSafeFileUpdateStack( True )
		If format <> c.No_BOM Then  Dim  cs : Set cs = new_TextFileCharSetStack( format )
		If IsEmpty( Me.DstPath ) Then  tmp_path = Me.SrcPath  Else  tmp_path = Me.DstPath

		If root.ownerDocument.firstChild.nodeType = c.NODE_PROCESSING_INSTRUCTION Then
			If InStr( root.ownerDocument.firstChild.nodeValue, "encoding" ) > 0 Then
				Dim  s : s = root.ownerDocument.xml  '// This is not included <?xml encoding>
				Dim  xml_pos1 : xml_pos1 = InStr( s, "<?xml" )
				Dim  xml_pos2 : xml_pos2 = InStr( xml_pos1, s, "?>" )
				CreateFile  tmp_path,  Left( s, xml_pos1 - 1 ) +_
					"<?xml "+ root.ownerDocument.firstChild.nodeValue + Mid( s, xml_pos2 )
			Else
				CreateFile  tmp_path,  root.ownerDocument.xml
			End If
		Else
			CreateFile  tmp_path,  root.ownerDocument.xml
		End If
	End If
 End Sub
End Class

Class  ReplaceXmlFile1_Sets
	Public  XPath
	Public  Value
End Class



 
'*************************************************************************
'  <<< [OpenForAppendXml] >>> 
'*************************************************************************
Function  OpenForAppendXml( SrcPath, ByVal DstPath )
	Dim  ret,  xml_str,  pos
	Dim  is_dst_will_be_exist : is_dst_will_be_exist = not IsEmpty( DstPath )

	If IsEmpty( DstPath ) Then  DstPath = GetTempPath("OpenForAppendXml_*.xml")

	Set ret = new AppendXmlFile
	Set ret.Rep = StartReplace( SrcPath, DstPath, is_dst_will_be_exist )
	xml_str = ret.Rep.r.ReadAll()

	pos = InStrRev( xml_str, "<" )
	ret.CloseTag = Mid( xml_str, pos )

	xml_str = Left( xml_str, pos - 1 )
'//	pos = InStrRev( xml_str, vbLF )
'//	If pos = 0 Then
'//		ret.CR = vbCR
'//	ElseIf Mid( xml_str, pos - 1, 1 ) = vbCR Then
'//		ret.CR = vbCR
'//	Else
'//		ret.CR = ""
'//	End If

	ret.Rep.w.Write  xml_str
	Set OpenForAppendXml = ret
End Function


'//[AppendXmlFile]
Class  AppendXmlFile
	Public  Rep  '// as StartReplaceObj
	Public  CloseTag  '// as string
'//	Public  CR  '// string

	Public Sub  Write( Str ) : Me.Rep.w.Write  Str : End Sub
'//	Public Sub  WriteLine( LineStr ) : Me.Rep.w.WriteLine  LineStr + Me.CR : End Sub
	Public Sub  WriteLine( LineStr ) : Me.Rep.w.WriteLineDefault  LineStr : End Sub

	Public Sub  WriteXml( XmlStr )
		Dim  close_pos,  pos,  lf_pos,  close_tag,  root_tag,  xml_str
		close_pos = InStrRev( XmlStr, "<" )
		close_tag = Mid( XmlStr, close_pos )
		pos = InStr( close_pos, XmlStr, ">" )
		root_tag = "<" + Mid( close_tag, 3, pos - close_pos - 2 ) + ">"
		pos = InStr( XmlStr, root_tag )
		If pos = 0 Then  Raise  E_NotFoundSymbol, "<ERROR msg=""XML のルート・タグが見つかりません"""+_
			" root_tag="""+ XmlAttr( root_tag ) +""" close_tag="""+ XmlAttr( close_tag ) +"""/>"
		pos = pos + Len( root_tag )
		lf_pos = InStr( pos, XmlStr, vbLF )
		If lf_pos > 0 Then
			If Trim2( Mid( XmlStr, pos, lf_pos - pos ) ) = "" Then  pos = lf_pos + 1
		End If
		xml_str = Mid( XmlStr, pos, close_pos - pos )
		Me.Rep.w.Write  xml_str
'//		If Right( xml_str, 1 ) <> vbLF Then  Me.Rep.w.WriteLine  Me.CR
		If Right( xml_str, 1 ) <> vbLF Then  Me.Rep.w.WriteLineDefault  ""
	End Sub

	Private Sub  Class_Terminate()
		Me.Rep.w.Write  Me.CloseTag
		Me.Rep.Finish
	End Sub
End Class


 
'***********************************************************************
'* Class: PositionOfXML_Class
'***********************************************************************
Class  PositionOfXML_Class

    '* Var: DocumentString
		'// XML Data
		Public  DocumentString

    '* Var: StartTagMatchesDictionary
    	'* Key=TagName
		Public  StartTagMatchesDictionary

    '* Var: EndTagMatchesDictionary
    	'* Key=TagName
		Public  EndTagMatchesDictionary

    '* Var: EndIndexFromStartIndexDictionary
		'// Key=TagName. Item=ArrayClass of integer
		'// As Array( start_index ) = end_index  or  Me.EmptyElementTag
		Public  EndIndexFromStartIndexDictionary

    '* Var: TagRegExp
		'// Cache of the object
		Public  TagRegExp

    '* Var: EmptyElementTag
		'// Constant of "<Tag/>".
		Public  EmptyElementTag


Private Sub  Class_Initialize()
	Set Me.TagRegExp = CreateObject( "VBScript.RegExp" )
	Me.TagRegExp.MultiLine = True
	Me.TagRegExp.Global = True
	Set Me.StartTagMatchesDictionary        = CreateObject( "Scripting.Dictionary" )
	Set Me.EndTagMatchesDictionary          = CreateObject( "Scripting.Dictionary" )
	Set Me.EndIndexFromStartIndexDictionary = CreateObject( "Scripting.Dictionary" )
	Me.EmptyElementTag = -1
End Sub


 
'***********************************************************************
'* Method: Load
'*
'* Name Space:
'*    PositionOfXML_Class::Load
'***********************************************************************
Public Sub  Load( in_FilePath )
	Me.DocumentString = ReadFile( in_FilePath )
End Sub


 
'***********************************************************************
'* Method: SelectSingleNode
'*
'* Name Space:
'*    PositionOfXML_Class::SelectSingleNode
'***********************************************************************
Public Function  SelectSingleNode( in_XPath )

	'// Parse XPath
	bracket = InStr( in_XPath, "[" )
	tag_name = Mid( in_XPath,  3,  bracket - 3 )
	index    = Mid( in_XPath,  bracket + 1,  Len( in_XPath ) - 1 - bracket )


	'// Check syntax
	is_error = False
	If Left(  in_XPath, 2 ) <> "//" Then  is_error = True
	If Right( in_XPath, 1 ) <> "]"  Then  is_error = True
	If bracket = 0         Then  is_error = True
	If Len( tag_name ) = 0 Then  is_error = True
	If Len( index ) = 0    Then  is_error = True
	If is_error Then
		Raise  E_Others, "<ERROR  msg=""対応している XPath は、//Tag[n] ただし n=1以上か last() のみです"""+ _
			"  xpath="""+ in_XPath +"""/>"
	End If


	'// Set start tag "matches"
	If not Me.StartTagMatchesDictionary.Exists( tag_name ) Then
		Me.TagRegExp.Pattern = "<"+ tag_name +"[ \t$>/]"  '// "<Tag "

		Set matches = Me.TagRegExp.Execute( Me.DocumentString )
		Set Me.StartTagMatchesDictionary( tag_name ) = matches
	Else
		Set matches = Me.StartTagMatchesDictionary( tag_name )
	End If


	'// Set found "element"
	If matches.Count >= 1 Then
		Set element = new PositionOfXML_ElementClass
		Set element.Document = Me
		Set element.StartTagMatches = matches
		element.TagName = tag_name
		If IsNumeric( index ) Then

			element.Index = CInt( index )
			If element.Index < 1  or  element.Index > matches.Count Then _
				Set element = Nothing
		ElseIf index = "last()" Then
			element.Index = matches.Count
		Else
			Raise  E_Others, "<ERROR  msg=""対応している XPath は、//Tag[n] ただし n=1以上か last() のみです"""+ _
				"  xpath="""+ in_XPath +"""/>"
		End If
	Else
		Set element = Nothing
	End If

	Set SelectSingleNode = element
End Function


 
'***********************************************************************
'* Method: ParseEndTag
'*    This function is called from PositionOfXML_ElementClass.PositionOfNextOfEndTag.
'*
'* Name Space:
'*    PositionOfXML_Class::ParseEndTag
'***********************************************************************
Public Sub  ParseEndTag( in_TagName )

	'// Set "matches_end" = "Me.EndTagMatchesDictionary( ... )"
	Me.TagRegExp.Pattern = "</"+ in_TagName +">"  '// "</Tag>"

	Set matches_start = Me.StartTagMatchesDictionary( in_TagName )
	Set matches_end = Me.TagRegExp.Execute( Me.DocumentString )
	Set Me.EndTagMatchesDictionary( in_TagName ) = matches_end


	'// Set "end_from_start" = "Me.EndIndexFromStartIndexDictionary( ... )"
	Set end_from_start = new ArrayClass
	end_from_start.ReDim_  matches_start.Count - 1
	ReDim  stack_( matches_start.Count )
	stack_count = 0
	start_index = 0
	end_index = 0

	start_pos = matches_start(0).FirstIndex  '// pos = position = character index
	If matches_end.Count >= 1 Then
		end_pos = matches_end(0).FirstIndex
	Else
		end_pos = Len( Me.DocumentString )  '// ( start_pos < end_pos ) = True
	End If
	Do While  start_index < matches_start.Count  or  end_index < matches_end.Count

		If start_pos < end_pos Then
			end_of_tag = Mid( Me.DocumentString, _
				InStr( start_pos + 1,  Me.DocumentString,  ">" ) - 1, _
				2 )

			If end_of_tag <> "/>" Then
				stack_( stack_count ) = start_index
				stack_count = stack_count + 1
			Else
				end_from_start( start_index ) = Me.EmptyElementTag
			End If

			start_index = start_index + 1
			If start_index < matches_start.Count Then
				start_pos = matches_start( start_index ).FirstIndex
			Else
				start_pos = Len( Me.DocumentString )  '// ( start_pos < end_pos ) = False
			End If
		Else
			stack_count = stack_count - 1
			If stack_count < 0 Then
				Raise  E_Others,  "<ERROR msg=""開始タグと終了タグが対応していません""  tag="""+ _
					in_TagName +"""/>"
			End If

			end_from_start( stack_( stack_count ) ) = end_index
			end_index = end_index + 1
			If end_index < matches_end.Count Then
				end_pos = matches_end( end_index ).FirstIndex
			End If
		End If
	Loop

	Set Me.EndIndexFromStartIndexDictionary( in_TagName ) = end_from_start
End Sub


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: PositionOfXML_ElementClass
'***********************************************************************
Class  PositionOfXML_ElementClass

	Public   Document  '// as PositionOfXML_Class
	Public   StartTagMatches
	Public   TagName
	Public   Index

	Private  Me_PositionOfLeftOfStartTag
	Private  Me_PositionOfNextOfEndTag


 
'***********************************************************************
'* Property: PositionOfLeftOfStartTag
'*
'* Name Space:
'*    PositionOfXML_ElementClass::PositionOfLeftOfStartTag
'***********************************************************************
Public Property Get  PositionOfLeftOfStartTag()
	If not IsEmpty( Me_PositionOfLeftOfStartTag ) Then
		PositionOfLeftOfStartTag = Me_PositionOfLeftOfStartTag
		Exit Property
	End If

	'// Example1:
	'//    "<Other />         <Tag/>"
	'//    ^pos_LF  ^pos_end  ^pos_start
	'//
	'//    pos = position of character

	'// Example2:
	'//    "        <Tag       />"
	'//    ^pos_LF  ^pos_start  ^pos_end

	Set match = Me.StartTagMatches( Me.Index - 1 )  '// Matches are return value of "RegExp::Execute".
	Set document = Me.Document
	pos_start = match.FirstIndex + 1
	pos_LF = InStrRev( document.DocumentString,  vbLF,  pos_start )
	pos_end = InStr( pos_LF + 1,  document.DocumentString,  ">" )
	If pos_end < pos_start Then
		left_of_start_tag = pos_end + 1
	Else
		left_of_start_tag = pos_LF + 1
	End If

	Me_PositionOfLeftOfStartTag = left_of_start_tag
	PositionOfLeftOfStartTag    = left_of_start_tag
End Property


 
'***********************************************************************
'* Property: PositionOfNextOfEndTag
'*
'* Name Space:
'*    PositionOfXML_ElementClass::PositionOfNextOfEndTag
'***********************************************************************
Public Property Get  PositionOfNextOfEndTag()
	If not IsEmpty( Me_PositionOfNextOfEndTag ) Then
		PositionOfNextOfEndTag = Me_PositionOfNextOfEndTag
		Exit Property
	End If

	If not Me.Document.EndIndexFromStartIndexDictionary.Exists( Me.TagName ) Then
		Me.Document.ParseEndTag  Me.TagName
	End If

	Set matches_start  = Me.Document.StartTagMatchesDictionary( Me.TagName )
	Set matches_end    = Me.Document.EndTagMatchesDictionary( Me.TagName )
	Set end_from_start = Me.Document.EndIndexFromStartIndexDictionary( Me.TagName )


	'// Example:
	'//    "</Tag>          <Other      "
	'//           ^pos_end  ^pos_start  ^pos_LF
	'//
	'//    pos = position of character

	end_index = end_from_start( Me.Index - 1 )
	If end_index <> document.EmptyElementTag Then  '// "</Tag>"
		Set match = matches_end( end_index )
		pos_end = match.FirstIndex + match.Length + 1
	Else  '// "<Tag/>"
		start_pos = matches_start( Me.Index - 1 ).FirstIndex
		pos_end = InStr( start_pos + 1,  document.DocumentString,  ">" ) + 1
	End If

	pos_LF = InStr( pos_end,  document.DocumentString,  vbLF )
	If pos_LF >= 1 Then
		pos_start = InStr( pos_end,  document.DocumentString,  "<" )
		If pos_start >= 1 Then
			If pos_start < pos_LF Then
				next_of_end_tag = pos_end
			Else
				next_of_end_tag = pos_LF + 1
			End If
		Else
			next_of_end_tag = pos_LF + 1
		End If
	Else
		next_of_end_tag = Len( document.DocumentString ) + 1
	End If

	Me_PositionOfNextOfEndTag = next_of_end_tag
	PositionOfNextOfEndTag    = next_of_end_tag
End Property


 
'* Section: End_of_Class
End Class


 
'*************************************************************************
'  <<< [UpdateLineAttributeInXML] >>> 
'*************************************************************************
Sub  UpdateLineAttributeInXML( in_Path, ByVal in_AttributeName )
	Set ec = new EchoOff
	Set re = CreateObject( "VBScript.RegExp" )
	If Left( in_AttributeName, 1 ) <> "@" Then _
		Raise  1, "AttributeName の前に @を付けてください"
	in_AttributeName = Mid( in_AttributeName, 2 )
	re.Pattern = in_AttributeName +"=""[0-9]*"""
	re.Global = True

	Set rep = OpenForReplace( in_Path, Empty )
	Set matches = re.Execute( rep.Text )

	Set counter = new LineNumFromTextPositionClass
	counter.Text = rep.Text

	index = 1
	For Each  match  In  matches
		out = out + Mid( rep.Text,  index,  match.FirstIndex + 1 - index )
		index = match.FirstIndex + 1 + match.Length

		out = out + in_AttributeName +"="""+ CStr( counter.GetNextLineNum( match.FirstIndex + 1 ) ) +""""
	Next

	rep.Text = out + Mid( rep.Text, index )
	If rep.Text = counter.Text Then _
		rep.IsSaveInTerminate = False
End Sub


 
'*************************************************************************
'  <<< [XmlWriteEncoding] >>> 
'*************************************************************************
Sub  XmlWriteEncoding( RootXmlElement, CharSet )
	RootXmlElement.ownerDocument.insertBefore _
		RootXmlElement.ownerDocument.createProcessingInstruction( "xml", "version=""1.0"" encoding="""+ CharSet +"""" ), _
		RootXmlElement
End Sub

 
'*************************************************************************
'  <<< [XmlAttrDic] >>> 
'*************************************************************************
Function  XmlAttrDic( XmlElem )
	Dim  attr, dic
	Set dic = CreateObject( "Scripting.Dictionary" )
	For Each attr  In XmlElem.attributes
		dic( attr.name ) = attr.value
	Next
	Set XmlAttrDic = dic
End Function


 
'*************************************************************************
'  <<< [XmlWrite] >>> 
'*************************************************************************
Function  XmlWrite( BaseXmlElement, XPath, NewValue )
	XmlWrite = XmlWriteSub( BaseXmlElement, XPath, NewValue, True )
End Function

Function  XmlWriteSub( BaseXmlElement, XPath, NewValue, IsForWrite )
	Dim  nodes, node, is_attr, value, xpath2, text, i, attr_name, parent
	Dim  c : Set c = g_VBS_Lib
	Set xml = BaseXmlElement.ownerDocument

	If IsEmpty( XPath ) Then
		Set nodes = new ArrayClass : nodes.Add  BaseXmlElement
	Else
		Set nodes = BaseXmlElement.selectNodes( XPath )
	End If

	If BaseXmlElement.selectSingleNode( "/" ).lastChild.getAttribute("xml:space") = "preserve" Then
		is_space_preserve = True
	Else
		is_space_preserve = False  '// Not set Null
	End If


	'//=== Create new node
	If nodes.Length = 0 Then
		If IsEmpty( NewValue ) Then
			XmlWriteSub = False
		Else
			Dim  new_node, ii, i3, i4, i5, tag_name, name, is_last_node
			xpath2 = XPath

			Do
				xpath2 = g_fs.GetParentFolderName( xpath2 )
				If xpath2 = "" Then  Raise  E_NotFoundSymbol, "ルート・ノードは変更できません"
				Set nodes = BaseXmlElement.selectNodes( xpath2 )
				If nodes.Length > 0 Then  Exit Do
			Loop
			Set new_node = new ArrayClass  '// Cast from IXMLDOMNodeList to ArrayClass
			For Each node  In nodes
				new_node.Add  node
			Next
			Set nodes = new_node
			ReDim  new_node( nodes.UBound_ )
			ReDim  is_auto_space( nodes.UBound_ )

			ip = Len( xpath2 ) + 1  '// ip = index of path
			level = 0
			Do
				'//=== Set "tag_name", "is_attr", "is_last_node"
				ip2 = InStr( ip+1, XPath, "/" )
				If ip2 = 0 Then
					is_last_node = True
					xpath2 = XPath
					tag_name = Mid( XPath, ip+1 )
				Else
					is_last_node = (Len( Mid( XPath, ip2 ) ) = 1)
					xpath2 = Left( XPath, ip2 - 1 )
					tag_name = Mid( XPath, ip+1, ip2 - ip - 1 )
				End If
				is_attr = ( Left( tag_name, 1 ) = "@" )
				If is_attr Then  tag_name = Mid( tag_name, 2 )


				For i = 0  To  nodes.UBound_

					If not is_attr Then

						If level = 0 Then
							If is_space_preserve Then
								If InStr( nodes(i).xml, vbLF ) > 0 Then
									is_auto_space(i) = True
								Else
									is_auto_space(i) = False
								End If
							Else
								is_auto_space(i) = True
							End If
						End If


						'//=== Insert tab text for indent of xml element
						space_node = Empty
						If is_auto_space(i) Then
							i3 = 1 : Set node = nodes(i).parentNode.parentNode
							Do Until node is Nothing : Set node = node.parentNode : i3=i3+1 : Loop
							text = String( i3, vbTab )
							If nodes(i).hasChildNodes Then
								If nodes(i).lastChild.nodeType = c.NODE_TEXT Then
									If nodes(i).lastChild.previousSibling  is Nothing Then
										text = Empty
									Else
										text = vbTab
									End If
								Else
									text = vbCRLF + text
								End If
							Else
									text = vbCRLF + text
							End If
							If not IsEmpty( text ) Then
								Set space_node = xml.createTextNode( text )
								nodes(i).appendChild  space_node
							End If
						End If

						'//=== Insert xml element
						i3 = InStr( tag_name, "[" )
						If i3 = 0 Then
							Set new_node(i) = xml.createNode( c.NODE_ELEMENT, _
								tag_name, nodes(i).namespaceURI )
							If IsEmpty( space_node ) Then
								nodes(i).appendChild  new_node(i)
							Else
								XmlInsertAfter  space_node, new_node(i)
							End If
						Else
							i4 = InStr( i3, tag_name, "=" )
							name = Mid( tag_name, i3+2, i4-i3-2 )
							value = Mid( tag_name, i4+2, InStr( i4+2, tag_name, _
								Mid( tag_name, i4+1, 1 ) ) -i4-2 )
							tag_name = Left( tag_name, i3-1 )

							Set new_node(i) = nodes(i).appendChild( _
								xml.createElement( tag_name ) )
							new_node(i).setAttribute  name, value
						End If

						'//=== Insert tab text for indent of xml element
						If is_auto_space(i) Then
							i3 = 0 : Set node = new_node(i).parentNode.parentNode.parentNode
							Do Until node is Nothing : Set node = node.parentNode : i3=i3+1 : Loop
							nodes(i).appendChild  xml.createTextNode( vbCRLF + String( i3, vbTab ) )
						End If
					End If

					If is_last_node Then
						If is_attr Then
							'//=== Set xml attribute
							If IsEmpty( new_node(i) ) Then
								nodes(i).setAttribute  tag_name, NewValue
							Else
								new_node(i).setAttribute  tag_name, NewValue
							End If
						Else
							new_node(i).appendChild  xml.createTextNode( NewValue )
						End If
					End If

					If not IsEmpty( new_node(i) ) Then _
						Set nodes(i) = new_node(i)
				Next
				If is_last_node Then  Exit Do
				ip = ip2
				level = level + 1
			Loop
			XmlWriteSub = True
		End If


	'//=== Change xml attribute
	Else

		If nodes(0).nodeType = c.NODE_ATTRIBUTE Then
			i = InStr( XPath, "/@" )
			Set nodes = BaseXmlElement.selectNodes( Left( XPath, i-1 ) )
			attr_name = Mid( XPath, i+2 )
			is_attr = True
		End If


		XmlWriteSub = False
		For Each node  In nodes

			If is_attr Then

				value = node.getAttribute( attr_name )
				If IsEmpty( NewValue ) Then
					If not IsNull( value ) Then
						node.removeAttribute  attr_name
						XmlWriteSub = True
					End If
				Else
					If IsNull( value ) Then  value = Empty  '// for value <> NewValue
					If value <> NewValue Then
						If IsForWrite Then
							node.setAttribute  attr_name, NewValue
							XmlWriteSub = True
						Else
							'//=== Insert tab text for indent of xml element
							If node.nextSibling.nodeType = c.NODE_TEXT Then _
								node.nextSibling.nodeValue = _
									node.nextSibling.nodeValue + vbTab

							'//=== Insert xml element
							Set new_node = node.parentNode.appendChild(_
								node.ownerDocument.createElement( node.tagName ) )
							new_node.setAttribute  attr_name, NewValue

							'//=== Insert tab text for indent of xml element
							If not is_space_preserve Then
								i3 = 0 : Set parent = new_node.parentNode.parentNode.parentNode
								Do Until parent is Nothing : Set parent = parent.parentNode : i3=i3+1 : Loop
								node.parentNode.appendChild  node.ownerDocument.createTextNode(_
									vbCRLF + String( i3, vbTab ) )
							End If

							XmlWriteSub = True
							Exit For  '// xml element must be created one time
						End If
					End If
				End If

			Else

				Set text = node.selectSingleNode( "text()" )  '// as IXMLDOMText
				If text is Nothing Then
					If IsEmpty( NewValue ) or NewValue = "" Then
						XmlWriteSub = False
					Else
						node.appendChild  xml.createTextNode( NewValue )
						XmlWriteSub = True
					End If
				Else
					If IsEmpty( NewValue ) or NewValue = "" Then
						node.removeChild  text
						XmlWriteSub = True
					Else
						If text.nodeValue = NewValue Then
							XmlWriteSub = False
						Else
							text.nodeValue = NewValue
							XmlWriteSub = True
						End If
					End If
				End If

				'//=== remove parent, if IsEmpty( NewValue )
				If IsEmpty( NewValue ) Then

					Dim  deleting_depth,  current_depth
					xpath2 = GetXPath( BaseXmlElement, Array( ) )
					xpath2 = GetFullPath( XPath, xpath2 )
					deleting_depth = StrCount( xpath2, "/", 1, c.CaseSensitive )

					xpath2 = GetXPath( node, Array( ) )
					current_depth = StrCount( xpath2, "/", 1, c.CaseSensitive )

					Do
						If deleting_depth > current_depth Then  Exit Do
						Set text = node
						Set node = node.parentNode
						If node is Nothing Then  Exit Do
						If text.hasChildNodes Then  Exit Do

						If is_space_preserve Then
							If not IsNull( text.nextSibling ) Then
								Set sib = text.nextSibling
								If sib.nodeType = c.NODE_TEXT Then
									If Trim2( sib.nodeValue ) = "" Then
										node.removeChild  sib
									End If
								End If
							End If
						End If

						node.removeChild  text
						XmlWriteSub = True
						current_depth = current_depth - 1
					Loop
				End If
			End If
		Next
	End If
End Function


 
'*************************************************************************
'  <<< [XmlInsertAfter] >>> 
'*************************************************************************
Sub  XmlInsertAfter( in_out_ReferenceNode, in_NewNode )
	in_out_ReferenceNode.parentNode.insertBefore _
		in_NewNode, in_out_ReferenceNode.nextSibling
End Sub


'*************************************************************************
'  <<< [XmlRead] >>> 
'*************************************************************************
Function  XmlRead( in_BaseXmlElement, in_XPath )
	Dim  node
	Dim  c : Set c = g_VBS_Lib

	If IsEmpty( in_XPath ) Then
		Set node = in_BaseXmlElement
	Else
		Set node = in_BaseXmlElement.selectSingleNode( in_XPath )
		If node Is Nothing Then  Exit Function
	End If

	Select Case  node.nodeType
		Case  c.NODE_ATTRIBUTE
			XmlRead = node.value
		Case  c.NODE_ELEMENT
			Set node = node.selectSingleNode( "text()" )
			If not node is Nothing Then  XmlRead = node.nodeValue
		Case  c.NODE_TEXT
			XmlRead = node.nodeValue
	End Select
End Function


 
'***********************************************************************
'* Function: XmlReadOrError
'***********************************************************************
Function  XmlReadOrError( in_BaseXmlElement,  in_XPath,  in_FilePath )

	value = XmlRead( in_BaseXmlElement, in_XPath )

	If IsEmpty( value ) Then
		If IsEmpty( in_FilePath ) Then
			file_attribute = ""
		Else
			file_attribute = "  file="""+ in_FilePath + """"
		End If

		Raise  E_PathNotFound,  "<ERROR msg=""見つかりません"""+ file_attribute +"  xpath="""+ _
			NormalizePath( GetXPath( in_BaseXmlElement, Empty ) +"/"+ in_XPath ) + _
			"""/>"
	End If

	XmlReadOrError = value
End Function


 
'*************************************************************************
'  <<< [XmlReadBoolean] >>> 
'*************************************************************************
Function  XmlReadBoolean( in_BaseXmlElement, in_XPath, in_DefaultValue, in_FilePath )
	value = XmlRead( in_BaseXmlElement, in_XPath )

	If IsEmpty( value ) Then
		XmlReadBoolean = in_DefaultValue
	ElseIf StrComp( value, "yes", 1 ) = 0 Then
		XmlReadBoolean = True
	ElseIf StrComp( value, "no", 1 ) = 0 Then
		XmlReadBoolean = False
	ElseIf StrComp( value, "true", 1 ) = 0 Then
		XmlReadBoolean = True
	ElseIf StrComp( value, "false", 1 ) = 0 Then
		XmlReadBoolean = False
	Else
		If not IsEmpty( in_FilePath ) Then _
			header = GetEchoStr( in_FilePath ) +" の中の "

		Raise  E_BadType,  header + GetEchoStr( in_XPath ) +" の値が正しくありません"
	End If
End Function


 
'*************************************************************************
'  <<< [XmlSelect] >>> 
'*************************************************************************
Function  XmlSelect( in_BaseXmlElement, in_XPath )
	Dim  slash_pos, kakko_pos, equal_pos, attribute_name, value
	Const  E_NoObject = 424

	Set XmlSelect = in_BaseXmlElement.selectSingleNode( in_XPath )
	If XmlSelect is Nothing Then

		'// Parse "element[@attribute_name='value']"
		slash_pos = InStrRev( in_XPath, "/" )
		kakko_pos = InStr( slash_pos + 1, in_XPath, "[" )
		If kakko_pos > 0 Then
			Assert  Mid( in_XPath, kakko_pos + 1, 1 ) = "@"
			equal_pos = InStr( kakko_pos + 2, in_XPath, "=" )

			attribute_name = Mid( in_XPath, kakko_pos + 2,  equal_pos - kakko_pos - 2 )

			value = Mid( in_XPath, equal_pos + 1 )
			Select Case  Left( value, 1 )
			 Case  """"
				Assert  Right( value, 2 ) = """]"
				value = Mid( value, 2, Len( value ) - 3 )
			 Case  "'"
				Assert  Right( value, 2 ) = "']"
				value = Mid( value, 2, Len( value ) - 3 )
			End Select

			XmlWriteSub  in_BaseXmlElement, Left( in_XPath, kakko_pos - 1 ) +"/@"+ attribute_name, _
				value, False
			Set XmlSelect = in_BaseXmlElement.selectSingleNode( in_XPath )
		Else
			XmlWriteSub  in_BaseXmlElement, in_XPath +"/@dummy", "dummy", False
			Set XmlSelect = in_BaseXmlElement.selectSingleNode( in_XPath )
			XmlSelect.removeAttribute  "dummy"
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [XmlSort] >>> 
'*************************************************************************
Sub  XmlSort( in_BaseXmlElement, in_XPath, in_CompareFunc, in_CompareFuncParam )
	Const  I_XMLDOMElement = 1
	Const  I_XMLDOMText = 3

	Set sorting_tags = in_BaseXmlElement.selectNodes( in_XPath )
	If sorting_tags.length <= 1 Then  Exit Sub
	Set compare_parameters = new_JoinedClass( in_CompareFunc, in_CompareFuncParam )


	'// Set "last_of_groups"
	Set last_of_groups = new ArrayClass
	For  tag_num = 0  To  sorting_tags.length - 2
		Set next_tag = sorting_tags( tag_num ).nextSibling
		If not next_tag is Nothing Then
			If next_tag.nodeType = I_XMLDOMText Then _
				Set next_tag = next_tag.nextSibling
		End If

		If next_tag is Nothing Then
			last_of_groups.Add  tag_num
		Else
			If next_tag.nodeType = I_XMLDOMElement Then
				If next_tag.tagName <> sorting_tags(0).tagName Then _
					last_of_groups.Add  tag_num
			End If
		End If
		tag_num = tag_num + 1
	Next
	last_of_groups.Add  sorting_tags.length - 1


	left_num = 0
	For Each  right_num  In  last_of_groups.Items  '// Loop of groups
		Set parent_node = sorting_tags( left_num ).parentNode


		'// Set "next_node"
		If right_num = sorting_tags.length Then
			next_node = Empty
		Else
			Set next_node = sorting_tags( right_num ).nextSibling
			If next_node is Nothing Then
				next_node = Empty
			Else
				If next_node.nodeType = I_XMLDOMText Then _
					Set next_node = next_node.nextSibling
			End If
		End If


		'// Set "tags"
		'// Remove sorting tags
		ReDim  tags( right_num - left_num )
		For  tag_num = right_num  To  left_num  Step -1
			Set tag_set = new JoinedClass
			Set tag_set.Left = sorting_tags( tag_num )
			Set tag_set.Right = tag_set.Left.nextSibling
			If not tag_set.Right is Nothing Then
				If tag_set.Right.nodeType <> I_XMLDOMText Then _
					Set tag_set.Right = Nothing
			End If

			Set tags( tag_num - left_num ) = tag_set

			parent_node.removeChild  tag_set.Left
			If not tag_set.Right is Nothing Then
				parent_node.removeChild  tag_set.Right
			End If
		Next


		'// ...
		QuickSort  tags, 0, UBound( tags ), GetRef( "XmlSortSub" ), compare_parameters


		'// Add sorted tags
		If IsEmpty( next_node ) Then
			For Each  tag_set  In tags
				parent_node.appendChild  tag_set.Left
				If not tag_set.Right is Nothing Then
					parent_node.appendChild  tag_set.Right
				End If
			Next
		Else
			For Each  tag_set  In tags
				parent_node.insertBefore  tag_set.Left, next_node
				If not tag_set.Right is Nothing Then
					parent_node.insertBefore  tag_set.Right, next_node
				End If
			Next
		End If


		'// Next
		left_num = right_num + 1
	Next
End Sub

Function  XmlSortSub( in_LeftTagSet, in_RightTagSet, in_CompareParameters )
	XmlSortSub = in_CompareParameters.Left( _
		in_LeftTagSet.Left,  in_RightTagSet.Left,  in_CompareParameters.Right )
End Function


 
'*************************************************************************
'  <<< [GetXPath] >>> 
'*************************************************************************
Function  GetXPath( ByVal in_DOMObject, ByVal in_ShowAttrs )
	Dim  attr, value, attr_length, ss
	Dim  c : Set c = g_VBS_Lib
	If IsEmpty( in_ShowAttrs ) Then  in_ShowAttrs = Array( "id", "name" )
	If not IsArray( in_ShowAttrs ) Then  in_ShowAttrs = Array( in_ShowAttrs )

	While  not in_DOMObject is Nothing
		Select Case  in_DOMObject.nodeType
			Case  c.NODE_ELEMENT

				'//=== GetXPath add attribute
				attr_length = 0
				ss = ""
				For Each  attr  In  in_ShowAttrs
					value = in_DOMObject.getAttribute( attr )
					If not IsNull( value ) Then
						If attr_length = 0 Then
							ss = "["
						Else
							ss = ss + " and "
						End IF
						ss = ss + "@"+ attr +"='"+ value +"'"
						attr_length = attr_length + 1
					End If
				Next
				If attr_length > 0 Then  ss = ss + "]"

				'//=== GetXPath add tagName
				GetXPath = "/"+ in_DOMObject.tagName + ss + GetXPath
				Set in_DOMObject = in_DOMObject.parentNode

			Case  c.NODE_DOCUMENT
				Exit Function

			Case  c.NODE_ATTRIBUTE
				GetXPath = "@"+ in_DOMObject.name
				Exit Function

		End Select
	WEnd
End Function


 
'*************************************************************************
'  <<< [ChangeToXml] >>> 
'*************************************************************************
Function  ChangeToXml( Stream )
	Select Case  TypeName( Stream )
		Case "ParentChildProcess" : Set ChangeToXml = Stream.m_InXML
		Case "String"             : Set ChangeToXml = LoadXML( Stream, g_VBS_Lib.StringData )
		Case Else                 : Set ChangeToXml = Stream
			'// Else = Nothing, IXMLDOMElement
	End Select
End Function


 
'*************************************************************************
'  <<< [XML_ReadCacheClass] >>> 
'*************************************************************************
Class  XML_ReadCacheClass
	Public Default Property Get  Item( a_URL )
		Const NODE_ELEMENT = 1
		Const NODE_ATTRIBUTE = 2

		Me.Get_Sub  a_URL, root, fragment  '//(out) root, fragment

		CutLastOf  fragment, "/", Empty
		Set element = root.selectSingleNode( fragment )
		If element is Nothing Then  Me.NotFoundError  a_URL
		If element.nodeType = NODE_ELEMENT Then
			Set text_object = element.selectSingleNode( "./text()")
			If text_object is Nothing Then  Me.NotFoundError  a_URL
			Item = text_object.text
		Else
			If element.nodeType <> NODE_ATTRIBUTE Then  Me.NotFoundError  a_URL
			Item = element.value
		End If
	End Property

	Sub Get_Sub( a_URL, root, fragment )
		number_position = InStr( a_URL, "#" )
		If number_position = 0 Then  Raise  1, "<ERROR msg=""No #"" URL="""+ a_URL +"""/>"
		full_path = GetFullPath( Left( a_URL, number_position - 1 ), Empty )
		fragment = Mid( a_URL, number_position + 1 )


		'// Set "root"
		If g_VBS_Lib.XML_DOM_ReadCache.Exists( full_path ) Then
			Set root = g_VBS_Lib.XML_DOM_ReadCache( full_path )
		Else
			If not g_fs.FileExists( full_path ) Then  Me.NotFoundError  a_URL
			Set root = LoadXML( full_path, Empty )
			Set g_VBS_Lib.XML_DOM_ReadCache( full_path ) = root
		End If
	End Sub


	Function GetArray( a_URL )
		Me.Get_Sub  a_URL, root, fragment  '//(out) root, fragment

		CutLastOf  fragment, "/", Empty
		Set nodes = root.selectNodes( fragment )
		ReDim  return_array( nodes.length - 1 )
		i = 0
		For Each  element  In nodes
			Set text_object = element.selectSingleNode( "./text()")
			If text_object is Nothing Then  Me.NotFoundError  a_URL
			return_array(i) = text_object.text
			i = i + 1
		Next
		GetArray = return_array
	End Function


	Sub  NotFoundError( a_URL )
		Raise  E_FileNotExist, "<ERROR msg=""Not found"" URL="""+ a_URL +"""/>"
	End Sub
End Class


 
'***********************************************************************
'* Function: ParseAttributesInXML
'***********************************************************************
Function  ParseAttributesInXML( in_AttributesString,  in_AttributeNames )

	If IsEmpty( g_ParseAttributesInXML_RegExp ) Then
		Set attribute_reg_exp = new_RegExp( "([^ \r\n]*) *= *(""[^""]*""|'[^']*')", True )
		Set g_ParseAttributesInXML_RegExp = attribute_reg_exp
	Else
		Set attribute_reg_exp = g_ParseAttributesInXML_RegExp
	End If

	Set  attribute_names = CreateObject( "Scripting.Dictionary" )
	Dic_addFromArray  attribute_names,  in_AttributeNames,  True
	If attribute_names.Exists( "" ) Then _
		not_parsed = ""
	Set  output_attributes = CreateObject( "Scripting.Dictionary" )


	'// Parse by "attribute_reg_exp"
	Set matches = attribute_reg_exp.Execute( in_AttributesString )


	p = 1  '// Position of next out of attribute
	For Each  match  In  matches

		'// Add to "output_attributes"
		attribute_name  = match.SubMatches(0)
		attribute_value = match.SubMatches(1)
		is_pick_up_attribute = attribute_names.Exists( attribute_name )

		If is_pick_up_attribute Then
			attribute_value = Mid( attribute_value, 2, Len( attribute_value ) - 2 )
				'// Cut both end of " or '
			attribute_value = DecodeCharacterReferencesOfXML( attribute_value )

			If not output_attributes.Exists( attribute_name ) Then
				output_attributes( attribute_name ) = attribute_value
			Else
				output_attributes( attribute_name ) = output_attributes( attribute_name ) + _
					vbCRLF + attribute_value
			End If
		End If


		If not IsEmpty( not_parsed ) Then
			left_text_with_space = Mid( in_AttributesString,  p,  match.FirstIndex + 1 - p )
			left_text_with_space = DecodeCharacterReferencesOfXML( left_text_with_space )
			left_text_in_this_line = Mid( left_text_with_space, _
				GetLeftEndOfLinePosition( left_text_with_space,  Len( left_text_with_space ) + 1 ) )
			left_text = RTrim2( left_text_with_space )
			left_space_count = Len( left_text_with_space ) - Len( left_text )


			'// Set "right_space_count"
			p = match.FirstIndex + 1 + match.Length
			p_start = p
			Do While  Mid( in_AttributesString, p, 1 ) = " "
				p = p + 1
			Loop

			right_space_count = p - p_start


			'// Set "space_count"
			If left_space_count < right_space_count Then
				space_count = left_space_count
			Else
				space_count = right_space_count
			End If


			'// Add to "not_parsed"
			If is_pick_up_attribute Then
				not_parsed = not_parsed + Left( left_text_with_space, _
					Len( left_text_with_space ) - Len( left_text_in_this_line ) )

				is_cut_line = False
				next_character = Mid( in_AttributesString, p, 1 )
				If ( next_character = vbCR  or  next_character = vbLF  or  next_character = "" ) _
						and  Trim( left_text_in_this_line ) = "" Then
					left_of_line = GetLeftEndOfLinePosition( not_parsed,  Len( not_parsed ) + 1 )
					line = Mid( not_parsed,  left_of_line )
					is_cut_line = ( Trim( line ) = "" )
				End If
				If not is_cut_line Then

					not_parsed = not_parsed + _
						RTrim( left_text_in_this_line ) + String( space_count,  " " )

				Else
					not_parsed = Left( not_parsed,  left_of_line )

					'// Set "p"
					Do
						next_character = Mid( in_AttributesString, p, 1 )
						If next_character <> vbCR  and  next_character <> vbLF Then _
							Exit Do
						p = p + 1
					Loop
				End If
			Else
				not_parsed = not_parsed + _
					left_text_with_space + _
					DecodeCharacterReferencesOfXML( match.Value )
				p = p_start
			End If
		End If
	Next

	If not IsEmpty( not_parsed ) Then
		not_parsed = not_parsed + _
			DecodeCharacterReferencesOfXML( Mid( in_AttributesString,  p ) )
		output_attributes( "" ) = not_parsed
	End If

	Set  ParseAttributesInXML = output_attributes
End Function

Dim  g_ParseAttributesInXML_RegExp


 
'***********************************************************************
'* Function: DecodeCharacterReferencesOfXML
'***********************************************************************
Function  DecodeCharacterReferencesOfXML( in_String )
	If InStr( in_String, "&" ) = 0 Then
		DecodeCharacterReferencesOfXML = in_String
		Exit Function
	End If

	If IsEmpty( g_DecodeCharacterReferencesOfXML_RegExp ) Then
		Set amp_reg_exp = new_RegExp( "&[#a-zA-Z0-9]*[^#a-zA-Z0-9;]", True )  '// "&" not XML references
		Set g_DecodeCharacterReferencesOfXML_RegExp = amp_reg_exp
	Else
		Set amp_reg_exp = g_DecodeCharacterReferencesOfXML_RegExp
	End If


	a_string = Replace( in_String, "<", "&lt;" )
	a_string = Replace( a_string,  """", "&quot;" )

	Set matches = amp_reg_exp.Execute( a_string )
	If matches.Count >= 1 Then
		old_string = a_string
		a_string = ""
		p = 1
		For Each  match  In  matches
			a_string = a_string + _
				Mid( old_string,  p,  match.FirstIndex + 1 - p ) + _
				"&amp;"
			p = match.FirstIndex + 2
		Next
		a_string = a_string + Mid( old_string,  p )
	End If
	If Right( a_string, 1 ) = "&" Then _
		a_string = Left( a_string,  Len( a_string ) - 1 ) +"&amp;"


	Set xml = CreateObject( "MSXML2.DOMDocument" )
	r = xml.loadXML( "<T a="""+ a_string +"""/>" ) : If r=0 Then Error
	DecodeCharacterReferencesOfXML = xml.lastChild.getAttribute( "a" )
End Function

Dim  g_DecodeCharacterReferencesOfXML_RegExp


 
'*************************************************************************
'  <<< [MultiTextXML_Class] >>> 
'*************************************************************************
Class  MultiTextXML_Class
	Function  GetText( a_URL )
		Set jumps = GetTagJumpParams( a_URL )
		full_path = GetFullPath( jumps.Path, Empty )


		'// Case of without "#" in URL
		If IsEmpty( jumps.Keyword ) Then
			If g_VBS_Lib.TextReadCache.Exists( full_path ) Then
				GetText = g_VBS_Lib.TextReadCache( full_path )
			Else
				If not g_fs.FileExists( full_path ) Then
					Raise  E_FileNotExist, "<ERROR msg=""Not found"" URL="""+_
						full_path +"""/>"
				End If
				GetText = ReadFile( full_path )
				g_VBS_Lib.TextReadCache( full_path ) = GetText
			End If

		'// Case of with "#" in URL
		Else
			'// Set "root"
			If g_VBS_Lib.XML_DOM_ReadCache.Exists( full_path ) Then
				Set root = g_VBS_Lib.XML_DOM_ReadCache( full_path )
			Else
				If not g_fs.FileExists( full_path ) Then
					Raise  E_FileNotExist, "<ERROR msg=""Not found"" URL="""+ full_path +_
						"#"+ jumps.Keyword +"""/>"
				End If
				Set root = LoadXML( full_path, Empty )
				Set g_VBS_Lib.XML_DOM_ReadCache( full_path ) = root
			End If


			'// Set "text"
			Set text_tag = root.selectSingleNode("./Text[@id='"+ jumps.Keyword +"']")
			If text_tag is Nothing Then
				Raise  E_FileNotExist, "<ERROR msg=""Not found"" URL="""+ full_path +_
					"#"+ jumps.Keyword +"""/>"
			End If
			text = text_tag.text


			'// Modify "text"
			left_of_text = Left( text, 5 )
			If left_of_text = vbLF +"----" Then
				text = Mid( text, InStr( 6, text, vbLF ) + 1 )
			ElseIf Left( left_of_text, 1 ) = vbLF Then
				text = Mid( text, 2 )
			ElseIf Left( left_of_text, 4 ) = "----" Then
				text = Mid( text, InStr( 5, text, vbLF ) + 1 )
			End If

			right_of_text = Right( text, 5 )
			text_length = Len( text )
			If right_of_text = "----"+ vbLF Then
				text = Left( text, InStrRev( text, vbLF, text_length - 5 ) )
			ElseIf Right( right_of_text, 4 ) = "----" Then
				text = Left( text, InStrRev( text, vbLF, text_length - 4 ) )
			End If


			'// Call "CutIndentOfMultiLineText"
			If text_tag.getAttribute( "cut_indent" ) = "yes" Then
				GetText = CutIndentOfMultiLineText( text,  text_tag.getAttribute( "indent" ), _
					Empty,  g_VBS_Lib.CutLastLineSeparator )
			Else
				GetText = Replace( text, vbLF, vbCRLF )
			End If
		End If
	End Function

	Function  IsExist( a_URL )
		Set jumps = GetTagJumpParams( a_URL )
		full_path = GetFullPath( jumps.Path, Empty )

		'// Case of without "#" in URL
		If IsEmpty( jumps.Keyword ) Then
			IsExist = g_fs.FileExists( full_path )

		'// Case of with "#" in URL
		Else
			If g_VBS_Lib.XML_DOM_ReadCache.Exists( full_path ) Then
				Set root = g_VBS_Lib.XML_DOM_ReadCache( full_path )
			Else
				IsExist = g_fs.FileExists( full_path )
				If IsExist Then
					Set root = LoadXML( full_path, Empty )
					Set g_VBS_Lib.XML_DOM_ReadCache( full_path ) = root
				End If
			End If
			If not IsEmpty( root ) Then
				Set text_object = root.selectSingleNode("./Text[@id='"+ jumps.Keyword +"']/text()")
				IsExist = not ( text_object is Nothing )
			End If
		End If
	End Function
End Class


 
'*************************************************************************
'  <<< [GetHRefBase] >>> 
'*************************************************************************
Function  GetHRefBase( Path, TargetTagNames )
	Dim  o : Set o = new HRefBase
	Set o.Linker = new LinkedXMLs
	If IsArray( TargetTagNames ) Then
		o.Linker.XmlTagNamesHavingIdName = TargetTagNames
	Else
		o.Linker.XmlTagNamesHavingIdName = Array( TargetTagNames )
	End If
	o.Linker.StartNavigation  Path, LoadXML( Path, Empty )
	Set GetHRefBase = o
End Function


Class  HRefBase
	Public  Linker  '// as LinkedXMLs

	Function  href( Path )
		Set href = Me.Linker.GetLinkTargetNode( Path )
	End Function

	Private Sub  Class_Terminate()
		Me.Linker.EndNavigation
	End Sub
End Class




 
'*-------------------------------------------------------------------------*
'* ### <<<< [LinkedXMLs] Class >>>> 
'*-------------------------------------------------------------------------*

Class  LinkedXMLs
	Public  XmlTagNamesHavingIdName  '// as array of string
	Public  Roots    '// as dictionary of root IXMLDOMElement cache. key is abs path
	Public  SourceXmlPath      '// as string
	Public  SourceXmlRootElem  '// as IXMLDOMElement
	Public  TargetLocation     '// as string
	Public  TargetXmlPath      '// as string
	Public  TargetXmlRootElem  '// as IXMLDOMElement

	Public  DicOfVisitedLocation      '// as dictionary of True. key is Location(path+"#"+name)
	Public  StackOfVisitedLocation    '// as ArrayClass of string
	Public  StackOfSourceXmlPath      '// as ArrayClass of string
	Public  StackOfSourceXmlRootElem  '// as ArrayClass of IXMLDOMElement

	Private Sub  Class_Initialize()
		Set Me.Roots = CreateObject( "Scripting.Dictionary" )
		Set Me.DicOfVisitedLocation     = CreateObject( "Scripting.Dictionary" )
		Set Me.StackOfVisitedLocation   = new ArrayClass
		Set Me.StackOfSourceXmlPath     = new ArrayClass
		Set Me.StackOfSourceXmlRootElem = new ArrayClass
	End Sub

	Public Sub  StartNavigation( in_SourceLocation, in_SourceXmlRootElem )
		Set source_jump = GetTagJumpParams( in_SourceLocation )
		Me.StackOfSourceXmlPath.Push  Me.SourceXmlPath
		Me.StackOfSourceXmlRootElem.Push  in_SourceXmlRootElem

		Me.SourceXmlPath = source_jump.Path
		Set Me.SourceXmlRootElem = in_SourceXmlRootElem
		Me.DicOfVisitedLocation.Add  in_SourceLocation,  True  '// Check mutual link
		Me.StackOfVisitedLocation.Push  in_SourceLocation
	End Sub

	Public Sub  EndNavigation()
		Dim  location : location = Me.StackOfVisitedLocation.Pop()
		Me.DicOfVisitedLocation.Remove  location

		Me.StackOfSourceXmlPath.Pop
		Me.StackOfSourceXmlRootElem.Pop
	End Sub


 
'*************************************************************************
'  <<< [LinkedXMLs::GetLinkTargetNode] >>> 
'*************************************************************************
Function  GetLinkTargetNode( in_TargetLocation )
	Dim  node, jump, name, e, err_msg, elem_name

	If IsEmpty( Me.XmlTagNamesHavingIdName ) Then _
		Raise  1, "XmlTagNamesHavingIdName が設定されていません。"
	Assert  not IsEmpty( in_TargetLocation )
	Assert  not IsNull( in_TargetLocation )


	'//=== Me.TargetXmlRootElem: LoadXML( in_TargetLocation )
	'//=== name: in_TargetLocation の # より後ろ
	If Left( in_TargetLocation, 1 ) = "#" Then
		Set Me.TargetXmlRootElem = Me.SourceXmlRootElem
		Me.TargetXmlPath = Me.SourceXmlPath
		name = Mid( in_TargetLocation, 2 )
		Me.TargetLocation = Me.SourceXmlPath +"#"+ name
	Else
		Set jump = GetTagJumpParams( in_TargetLocation )
		Me.TargetXmlPath = GetFullPath( jump.Path, GetParentFullPath( Me.SourceXmlPath ) )
		name = jump.Keyword : If IsEmpty( name ) Then  name = ""

		If Me.Roots.Exists( Me.TargetXmlPath ) Then
			Set Me.TargetXmlRootElem = Me.Roots.Item( Me.TargetXmlPath )
		Else
			If TryStart(e) Then  On Error Resume Next
				Set Me.TargetXmlRootElem = LoadXML( Me.TargetXmlPath, Empty )
				If Trying Then  Set Me.Roots.Item( Me.TargetXmlPath ) = Me.TargetXmlRootElem
			If TryEnd Then  On Error GoTo 0
			If e.num <> 0  Then  err_msg = e.desc : e.Clear
		End If

		If name = "" Then
			Me.TargetLocation = Me.TargetXmlPath
		Else
			Me.TargetLocation = Me.TargetXmlPath +"#"+ name
		End If
	End If


	'// リンク先が見つからないときはエラーにする
	If name = "" Then  err_msg = "リンク先の名前が指定されていないか # が記述されていません"
	If not IsEmpty( err_msg ) Then
		Raise_sub  E_NotFoundSymbol, err_msg, in_TargetLocation
	End If


	'//=== node: id属性か name属性が name に一致する XML タグ
	For Each elem_name  In Me.XmlTagNamesHavingIdName
		Set node = Me.TargetXmlRootElem.selectSingleNode( "//"+ elem_name +"[@id='"+ name +"']" )
		If node is Nothing Then  Set node = Me.TargetXmlRootElem.selectSingleNode( "//"+ elem_name +"[@name='"+ name +"']" )
		If not node is Nothing Then  Exit For
	Next
	If node is Nothing Then
		Raise_sub  E_NotFoundSymbol, "リンク先が見つかりません", in_TargetLocation
	End If


	'// 循環参照していたらエラーにする
	If not IsEmpty( Me.DicOfVisitedLocation ) Then
		If Me.DicOfVisitedLocation.Exists( Me.TargetXmlPath +"#"+ name ) Then
			Raise_sub  E_NotFoundSymbol, "リンクが循環しているため処理が完了できません", in_TargetLocation
		End If
	End If

	Set GetLinkTargetNode = node
End Function


 
'*************************************************************************
'  <<< [LinkedXMLs::Raise_sub] >>> 
'*************************************************************************
Private Sub  Raise_sub( ErrCode, ErrMessage, TargetLocation )
	'// リンクのナビゲーションを開始したときは、Me.StartNavigation してください。
	Raise  ErrCode, "<ERROR msg="""+ ErrMessage +""" "+_
		"target_locaion="""+ XmlAttr( TargetLocation ) +""" from="""+ XmlAttr( Me.SourceXmlPath ) +_
		"""/>"
End Sub


 
End Class 
 
'*-------------------------------------------------------------------------*
'* ### <<<< Function call and include >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [call_vbs] >>> 
'*************************************************************************
Function  call_vbs( path, func, param )
	echo  ">call_vbs  """ & path & """, " & func
	call_vbs = call_vbs_t( path, func, param )
End Function


 
'*************************************************************************
'  <<< [SetupCallViaFile] >>> 
'*************************************************************************
Sub  SetupCallViaFile( SyncSendFilePath, SyncRecvFilePath, IsSyncWhenExit )
	If IsEmpty( g_CallViaFileSystem ) Then  Set g_CallViaFileSystem = new CallViaFileSystem
	Dim  o : Set o = g_CallViaFileSystem

	o.SyncSendFilePath = SyncSendFilePath
	o.SyncRecvFilePath = SyncRecvFilePath
	If IsEmpty( o.SyncSendFilePath ) or IsEmpty( o.SyncRecvFilePath ) Then
		Dim params : Set params = DicFromCmdLineOpt( GetCmdLine(), Array( "/SyncSendFile", "/SyncRecvFile" ) )
		If IsEmpty( o.SyncSendFilePath ) Then  o.SyncSendFilePath = params( "/SyncSendFile" )
		If IsEmpty( o.SyncRecvFilePath ) Then  o.SyncRecvFilePath = params( "/SyncRecvFile" )
	End If

	echo  ">SetupCallViaFile  """+ o.SyncSendFilePath +""", """+ o.SyncRecvFilePath +""""
	o.IsSyncWhenExit = IsSyncWhenExit
End Sub


Dim  g_CallViaFileSystem
Class  CallViaFileSystem
	Public  SyncSendFilePath
	Public  SyncRecvFilePath
	Public  IsSyncWhenExit

	Private Sub  Class_Terminate()
		If Me.IsSyncWhenExit Then
			Dim f : Set f = g_fs.CreateTextFile( Me.SyncSendFilePath, True, False )
			f.Write  "Finished"
			f.Close
		End If
	End Sub
End Class

 
'*************************************************************************
'  <<< [CallViaFile] >>> 
'*************************************************************************
Function  CallViaFile( ByVal Message )
	If IsEmpty( g_CallViaFileSystem ) Then  Raise  1, "SetupCallViaFile を呼び出してください。"
	Dim  o : Set o = g_CallViaFileSystem
	If IsEmpty( Message ) Then  Message = "Sync"
	echo  ">CallViaFile  """ & Message & """"
	Dim  ec : Set ec = new EchoOff
	CreateFile  o.SyncSendFilePath, Message
	CallViaFile = WaitForFile( o.SyncRecvFilePath )
End Function


 
'*************************************************************************
'  <<< [CallForEach0] >>> 
'*************************************************************************
Function  CallForEach0( Func, Collection )
	Dim  item

	If IsEmpty( Collection ) Then  Exit Function
	If IsArray( Collection ) Then
		For Each item  In Collection
			Func  item
		Next
	Else  '// Collection is single variable
		CallForEach1 = Func( Collection )
	End If
End Function


Function  CallForEach1( Func, Collection, Param1 )
	Dim  item

	If IsEmpty( Collection ) Then  Exit Function
	If IsArray( Collection ) Then
		For Each item  In Collection
			Func  item, Param1
		Next
	Else  '// Collection is single variable
		CallForEach1 = Func( Collection, Param1 )
	End If
End Function


Function  CallForEach2( Func, Collection, Param1, Param2 )
	Dim  item

	If IsEmpty( Collection ) Then  Exit Function
	If IsArray( Collection ) Then
		For Each item  In Collection
			Func  item, Param1, Param2
		Next
	Else  '// Collection is single variable
		CallForEach2 = Func( Collection, Param1, Param2 )
	End If
End Function


Function  CallForEach3( Func, Collection, Param1, Param2, Param3 )
	Dim  item

	If IsEmpty( Collection ) Then  Exit Function
	If IsArray( Collection ) Then
		For Each item  In Collection
			Func  item, Param1, Param2, Param3
		Next
	Else  '// Collection is single variable
		CallForEach2 = Func( Collection, Param1, Param2, Param3 )
	End If
End Function


Function  CallForEach4( Func, Collection, Param1, Param2, Param3, Param4 )
	Dim  item

	If IsEmpty( Collection ) Then  Exit Function
	If IsArray( Collection ) Then
		For Each item  In Collection
			Func  item, Param1, Param2, Param3, Param4
		Next
	Else  '// Collection is single variable
		CallForEach2 = Func( Collection, Param1, Param2, Param3, Param4 )
	End If
End Function


Sub  CallForEach_copy( FilePath, FromFolderPath, ToFolderPath )
	If VarType( FilePath ) <> vbString Then _
		Raise  13, "<ERROR msg=""ファイル名が文字列型になっていません"" type="""+ TypeName( FilePath ) +"""/>"

	If FilePath = "" Then  Exit Sub
	copy  GetFullPath( FilePath, GetFullPath( FromFolderPath, Empty ) ), _
		g_fs.GetParentFolderName( GetFullPath( FilePath, GetFullPath( ToFolderPath, Empty ) ) )
End Sub

Sub  CallForEach_move( FilePath, FromFolderPath, ToFolderPath )
	If VarType( FilePath ) <> vbString Then _
		Raise  13, "<ERROR msg=""ファイル名が文字列型になっていません"" type="""+ TypeName( FilePath ) +"""/>"

	If FilePath = "" Then  Exit Sub
	move  GetFullPath( FilePath, GetFullPath( FromFolderPath, Empty ) ), _
		g_fs.GetParentFolderName( GetFullPath( FilePath, GetFullPath( ToFolderPath, Empty ) ) )
End Sub

Sub  CallForEach_del( FilePath, FolderPath )
	If FilePath = "" Then  Exit Sub
	del  GetFullPath( FilePath, GetFullPath( FolderPath, Empty ) )
End Sub

Sub  CallForEach_AssertExist( FilePath, FolderPath )
	If FilePath = "" Then  Exit Sub
	AssertExist  GetFullPath( FilePath, GetFullPath( FolderPath, Empty ) )
End Sub

Sub  CallForEach_AssertNotExist( FilePath, FolderPath )
	If FilePath = "" Then  Exit Sub
	Assert  not exist( GetFullPath( FilePath, GetFullPath( FolderPath, Empty ) ) )
End Sub


 
'***********************************************************************
'* Function: Transpose
'***********************************************************************
Sub  Transpose : End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [MakeFileClass] Class >>>> 
'-------------------------------------------------------------------------
Class  MakeFileClass
	Public  Name         ' as string
	Public  RuleGroups   ' as Dictionary of MakeRuleGroup. key=MakeRuleGroup::TargetPath and MakeRule::Sources
	Public  Variables    ' as LazyDictionaryClass
	Public  Delegate     ' as variant
	Public  DebugMode    ' as integer. c.OutDebugXML, c.BreakBeforeCommand( FileName ), c.Watch( Function )
	Public  DebugMode_Param1
	Public  c              ' as MakeFileClassConst

	Private Sub  Class_Initialize()
		Set Me.RuleGroups = CreateObject( "Scripting.Dictionary" )
		Me.RuleGroups.CompareMode = 1  '// NotCaseSensitive
		Set Me.Variables = new LazyDictionaryClass
		Set c = get_MakeFileClassConst()
	End Sub


 
'*************************************************************************
'  <<< [MakeFileClass::AddRule] >>> 
'*************************************************************************
Public Sub  AddRule( a_MakeRule )
	If IsArray( a_MakeRule ) Then
		For Each  rule  In a_MakeRule
			Me.AddRule  rule
		Next
		Exit Sub
	End If
	AssertD_TypeName  a_MakeRule, "MakeRule"

	target_path = a_MakeRule.Target


	'//=== Add new "MakeRuleGroup" to "Me.RuleGroups"
	GetDicItem  Me.RuleGroups, target_path, group
	If IsEmpty( group ) Then
		Set o = new MakeRuleGroup
			o.TargetPath = target_path
			Set o.MakeFile = Me
		Set group = o
		Set Me.RuleGroups.Item( target_path ) = group
	End If


	'//=== Add new "MakeRuleSpec" to "group.Rules"
	Set o = new MakeRuleSpec
		Set o.Group = group
		Set o.Rule = a_MakeRule
		Set o.CommandFunc = a_MakeRule.Command
	Set rule = o
	Set a_MakeRule.Spec = rule
	group.Rules.Add  rule


	'//=== Add "src_group" to "rule.SourceFiles"
	For i_src=0 To UBound( a_MakeRule.Sources )
		src_path = a_MakeRule.Sources( i_src )
		GetDicItem  Me.RuleGroups, src_path, src_group  '//[out] src_group

		'//=== add source for timestamp
		If IsEmpty( src_group ) Then
			Set o = new MakeRuleGroup
				o.TargetPath = src_path
				Set o.MakeFile = Me
			Set src_group = o
			Set Me.RuleGroups( src_path ) = src_group
		End If


		'//=== mutual link source to target
		rule.SourceFiles.Add  src_group
		src_group.UserFiles.Add  rule
	Next
End Sub


 
'*************************************************************************
'  <<< [MakeFileClass::Make] >>> 
'*************************************************************************
Public Sub  Make()
	Set ds_= new CurDirStack

	echo  ">make"

	Set rules = new ArrayClass
	is_implicit = Me.GetIsImplicit()


	If Me.DebugMode and Me.c.OutDebugXML Then
		path = GetTempPath( "MakeFileDebug.xml" )
		Dim  f : Set f = OpenForWrite( path, g_VBS_Lib.Unicode )
		f.WriteLine  "<?xml version=""1.0"" encoding=""utf-16""?>"
		f.WriteLine  "<MakeFileClass current_folder="""+ g_sh.CurrentDirectory +""">"
	End If


	'//=== Expand wildcard (Implicit rules)
	If is_implicit Then
		expand_option = g_VBS_Lib.File  or  g_VBS_Lib.Folder  or  g_VBS_Lib.SubFolder

		Set rule_groups_back_up = Me.RuleGroups
		Set Me.RuleGroups = CreateObject( "Scripting.Dictionary" )
		For Each  target_path  In rule_groups_back_up.Keys
			Set group = rule_groups_back_up( target_path )
			If IsWildcard( target_path ) Then
				target_path_ex = Me.Variables( target_path )
				For Each rule_spec  In group.Rules.Items
					Set rule = rule_spec.Rule
					If UBound( rule.Sources ) >= 0 Then
						source_path = Me.Variables( rule.Sources(0) )
						ExpandWildcard  source_path, expand_option, folder, step_paths
						folder = GetStepPath( folder, Empty )
						For Each  step_path  In step_paths
							step_path_no_ext = ScanFromTemplate( step_path, _
								g_fs.GetFileName( source_path ), Array( "*" ), Empty )("*")
							Set o = new MakeRule
								o.Target = Replace( target_path_ex, "*", step_path_no_ext )
								o.Sources = rule.Sources
								o.Sources(0) = folder +"\"+ step_path
								Set o.Command = rule.Command
							Me.AddRule  o
						Next
						If UBound( step_paths ) = -1 Then
							If Me.DebugMode and Me.c.OutDebugXML Then
								f.WriteLine  "<MakeRuleNotMatch source_path="""+ _
									source_path +"""/>"
							End If
						End If
					End If
				Next
			Else
				Me.RuleGroups( target_path ) = group
			End If
		Next
	End If


	'//=== Set "Distance"
	For Each group  In Me.RuleGroups.Items  '// group as MakeRuleGroup
		If group.UserFiles.Count = 0 Then
			group.Distance = 0
			For Each rule  In group.Rules.Items
				For Each src  In rule.SourceFiles.Items
					src.Distance = 1
				Next
			Next
		End If
	Next
	dist = 1
	Do
		b = False
		For Each group  In RuleGroups.Items
			If group.Distance = dist Then
				For Each rule  In group.Rules.Items
					For Each src  In rule.SourceFiles.Items
						src.Distance = dist + 1
						b = True
					Next
				Next
			End If
		Next
		If not b Then  Exit Do
		dist = dist + 1
	Loop


	'//=== タイムスタンプをリードする
	For Each group  In Me.RuleGroups.Items
		If exist( group.TargetPath ) Then
			group.TargetTimeStamp = g_fs.GetFile( group.TargetPath ).DateLastModified
		Else
			group.TargetTimeStamp = Empty
		End If
	Next


	'//=== タイムスタンプを比較する
	For Each group  In RuleGroups.Items
		For Each rule  In group.Rules.Items
			rule.bDoCommand = False
			rule.Reason = Empty

			b=( not IsEmpty( rule.Rule ) )  'and
			If b Then b=( rule.Rule.Type_ <> group.c.Splitter )
			If b Then
				For Each src  In rule.SourceFiles.Items

					If IsEmpty( src.TargetTimeStamp ) Then
						'// Do Nothing
					ElseIf IsEmpty( group.TargetTimeStamp ) Then
						rule.bDoCommand = True
						rule.Reason = "No Target"
						rules.Add  rule
					ElseIf group.TargetTimeStamp < src.TargetTimeStamp Then
						rule.bDoCommand = True
						rule.Reason = "Timestamp"
						rules.Add  rule
					End If
				Next
				If rule.SourceFiles.Count = 0  and  not IsEmpty( rule.Rule ) Then
					If IsEmpty( rule.Group.TargetTimeStamp ) Then
						rule.bDoCommand = True
						rule.Reason = "NotExist"
						rules.Add  rule
					End If
				End If
			Else
				rule.Reason = "Splitter"
			End If
		Next
	Next


	'//=== コマンドを実行する順番を依存関係に合うように調整する
	i_rule = 0
	While  i_rule < rules.Count
		For Each user  In rules( i_rule ).Group.UserFiles.Items  '// user as MakeRuleSpec
			If not user.bDoCommand Then
				user.bDoCommand = True
				user.Reason = "Dependency"
				rules.Add  user  '// Add to last. Loop count +1
			End If
		Next
		i_rule = i_rule + 1
	WEnd


	'//=== Do biggest priority command only
	For Each group  In RuleGroups.Items
		rule2 = Empty
		For Each rule  In group.Rules.Items
			If rule.bDoCommand  and  not IsEmpty( rule.Rule ) Then
				If not IsEmpty( rule2 ) Then
					If rule.Rule.Priority > rule2.Rule.Priority Then
						rule2.bDoCommand = False
						rule2.Reason = rule2.Reason + ", but Priority"
					Else
						rule.bDoCommand = False
						rule.Reason = rule.Reason + ", but Priority"
					End If
				End If
				Set rule2 = rule
			End If
		Next
	Next


	'//=== Output debug xml
	If Me.DebugMode and Me.c.OutDebugXML Then
		f.WriteLine  "<MakeFile name="""+ Me.Name +""" max_distance="""& dist &""">"
		i_group = 0
		For Each group  In Me.RuleGroups.Items
			If group.Rules.Count > 0 Then

				b_do_command = False : do_priority = Empty
				For Each rule  In group.Rules.Items
					If rule.bDoCommand Then _
						b_do_command = True : do_priority = rule.Rule.Priority
				Next

				f.WriteLine  "<MakeRuleGroup id="""& i_group &""" file_name="""+ g_fs.GetFileName( group.TargetPath ) +""" distance="""&_
					group.Distance &""" b_do_command="""& b_do_command &""" do_priority="""& do_priority &""">"
				f.WriteLine  "  <Target time_stamp="""& group.TargetTimeStamp &""" path="""+ group.TargetPath +"""/>"
				For Each rule  In group.Rules.Items
				 If not IsEmpty( rule.Rule ) Then
					f.WriteLine  "  <MakeRule b_do_command="""& rule.bDoCommand &""" reason="""+_
						rule.Reason +""" priority="""& rule.Rule.Priority &""">"
					i_rule = 0
					For Each src  In rule.SourceFiles.Items
						f.WriteLine  "    <Source time_stamp="""& src.TargetTimeStamp &""" path="""+ rule.Rule.Sources( i_rule ) +"""/>"
						i_rule = i_rule + 1
					Next
					f.WriteLine  "  </MakeRule>"
				 End If
				Next
				f.WriteLine  "</MakeRuleGroup>"
			End If
			i_group = i_group + 1
		Next
		f.WriteLine  "</MakeFileClass>"
		f = Empty
		start  path
		Pause
	End If


	'//=== Call the command
	While  dist >= 0
		For Each group  In Me.RuleGroups.Items
			If group.Distance = dist Then
				For Each rule  In group.Rules.Items
					If rule.bDoCommand Then
						Set ec = new EchoOff
						cd  rule.Rule.CurrentDirectory
						ec = Empty

						echo  ""
						echo  "command by make for """+ rule.Rule.Target +""""

						Set rule.Rule.Variables = Me.Variables
						Me.Variables("${Target}") = rule.Rule.Target
						If UBound( rule.Rule.Sources ) = -1 Then
							Me.Variables("${Sources[0]}") = ""
						Else
							Me.Variables("${Sources[0]}") = rule.Rule.Sources(0)
						End If
						Me.Variables("${Sources}") = Replace( CmdLineFromStr( rule.Rule.Sources ), "\\", "\" )
						Me.Variables("${TargetNoExt}") = AddLastOfFileName( rule.Rule.Target, "." )

						If (Me.DebugMode and Me.c.Watch) and  not IsEmpty( Me.DebugMode_Param1 ) Then _
							Me.DebugMode_Param1  Me.Delegate, rule.Rule

						If (Me.DebugMode and Me.c.BreakBeforeCommand) Then _
							If ( IsEmpty( Me.DebugMode_Param1 ) or _
								InStr( rule.Rule.Target, Me.DebugMode_Param1 ) > 0 ) Then _
									Stop


						rule.CommandFunc  Me.Delegate, rule.Rule


						Me.Variables.Remove  "${Target}"
						Me.Variables.Remove  "${Sources[0]}"
						Me.Variables.Remove  "${Sources}"
						Me.Variables.Remove  "${TargetNoExt}"
						rule.Rule.Variables = Empty

						If (Me.DebugMode and Me.c.Watch) and  not IsEmpty( Me.DebugMode_Param1 ) Then _
							Me.DebugMode_Param1  Me.Delegate, rule.Rule
					End If
				Next
			End If
		Next
		dist = dist - 1
	WEnd


	'//=== Restore "Me.RuleGroups"
	If is_implicit Then
		Set Me.RuleGroups = rule_groups_back_up
	End If
End Sub


 
'*************************************************************************
'  <<< [MakeFileClass::GetIsImplicit] >>> 
'*************************************************************************
Function  GetIsImplicit()
	GetIsImplicit = False
	For Each group  In Me.RuleGroups.Items  '// group as MakeRuleGroup
		For Each rule_spec  In group.Rules.Items
			Set rule = rule_spec.Rule

			is_source_wildcard = False
			If UBound( rule.Sources ) >= 0 Then
				If IsWildcard( rule.Sources( 0 ) ) Then _
					is_source_wildcard = True
			End If

			If IsWildcard( rule.Target ) Then
				If is_source_wildcard Then
					GetIsImplicit = True
					Exit Function
				Else
					Error
				End If
			Else
				If is_source_wildcard Then _
					Error
			End If
		Next
	Next
End Function


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [MakeRule] Class >>>> 
'-------------------------------------------------------------------------
Class  MakeRule
	Public  Target     ' as string
	Public  Sources    ' as Array of string
	Public  Command    ' as Sub ()

	Public  Variables  ' as LazyDictionaryClass (Read Only)
	Public  CurrentDirectory  ' as string. abs path (Read Only)

	Public  Delegate ' as variant
	Public  Type_    ' as integer. 0 or Me.c.Splitter
	Public  Priority ' as number. Do biggest priority command only in same Target.

	Public  Spec     ' as MakeRuleSpec (Read Only)

	Public  c

	Private Sub  Class_Initialize()
		CurrentDirectory = g_sh.CurrentDirectory
		Set c = get_MakeFileClassConst()
		Priority = 1
	End Sub


	'//[MakeRule::NewestSource]
	Public Property Get  NewestSource()
		Dim  rule, newest_rule, i_src, i, rule_date, newest_date, b

		i = 0
		For Each rule  In Me.Spec.SourceFiles.Items
			If g_fs.FileExists( rule.TargetPath ) Then
				rule_date = g_fs.GetFile( rule.TargetPath ).DateLastModified

				b=( IsEmpty( newest_date ) )  'or
				If not b Then  b=( rule_date > newest_date )
				If b Then
					newest_date = rule_date
					i_src = i
				End If
			End If
			i = i + 1
		Next
		If not IsEmpty( i_src ) Then _
			NewestSource = Me.Sources( i_src )
	End Property


	'//[MakeRule::AllNewSource]
	Public Property Get  AllNewSource()  ' as Array
		Dim  group, i, srcs, target_date

		srcs = Array()
		If not g_fs.FileExists( Me.Spec.Group.TargetPath ) Then
			AllNewSource = Me.Sources
			Exit Property
		End If

		target_date = g_fs.GetFile( Me.Spec.Group.TargetPath ).DateLastModified
		i = 0
		For Each group  In Me.Spec.SourceFiles.Items
			If g_fs.FileExists( group.TargetPath ) Then
				If g_fs.GetFile( group.TargetPath ).DateLastModified > target_date Then
					ReDim Preserve  srcs( UBound( srcs ) + 1 )
					srcs( UBound( srcs ) ) = Me.Sources( i )
				End If
			End If
			i = i + 1
		Next
		AllNewSource = srcs
	End Property
End Class

 
'*************************************************************************
'  <<< [MakeRule_compare] >>> 
'*************************************************************************
Function  MakeRule_compare( TargetPath, SourcePath )
	If g_fs.FileExists( SourcePath ) Then
		If g_fs.FileExists( TargetPath ) Then
			MakeRule_compare = g_fs.GetFile( SourcePath ).DateLastModified > _
												 g_fs.GetFile( TargetPath ).DateLastModified
		Else
			MakeRule_compare = True
		End If
	Else
		MakeRule_compare = False
	End If
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [MakeRuleGroup] Class >>>> 
'-------------------------------------------------------------------------
Class  MakeRuleGroup
	Public  TargetPath       ' as string. abs path
	Public  TargetTimeStamp  ' as Date or Empty

	Public  Rules        ' as ArrayClass of MakeRuleSpec

	Public  Distance     ' as integer
	Public  UserFiles    ' as ArrayClass of MakeRuleSpec
	Public  MakeFile     ' as parnet of MakeFileClass

	Public  c

	Private Sub  Class_Initialize()
		Set Rules     = new ArrayClass
		Set UserFiles = new ArrayClass
		Set c = get_MakeFileClassConst()
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [MakeRuleSpec] Class >>>> 
'-------------------------------------------------------------------------
Class  MakeRuleSpec
	Public  Group        ' as parnet of MakeRuleGroup
	Public  Rule         ' as MakeRule
	Public  SourceFiles  ' as ArrayClass of MakeRuleGroup
	Public  CommandFunc  ' as Sub ( variant, MakeRuleSpec )
	Public  bDoCommand   ' as boolean
	Public  Reason       ' as string

	Private Sub  Class_Initialize()
		Set SourceFiles = new ArrayClass
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [MakeFileClassConst] Class >>>> 
'-------------------------------------------------------------------------
Dim  g_MakeFileClassConst

Function    get_MakeFileClassConst()  '// has_interface_of ClassI
	If IsEmpty( g_MakeFileClassConst ) Then _
		Set g_MakeFileClassConst = new MakeFileClassConst : ErrCheck
	Set get_MakeFileClassConst =   g_MakeFileClassConst
End Function

Class  MakeFileClassConst
	Public  Splitter, OutDebugXML, BreakBeforeCommand, Watch
	Private Sub  Class_Initialize() : Splitter = 1 : OutDebugXML = 1 : BreakBeforeCommand = 2
		Watch = 4 : End Sub
End Class


 
'*-------------------------------------------------------------------------*
'* ### <<<< Support of vbsool >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [CalculateVariables] >>> 
'*************************************************************************
Function  CalculateVariables( Formula, Variables )
	Dim  code,  key,  key2,  value,  prev_count
	Dim  not_out_vars : Set not_out_vars = CreateObject( "Scripting.Dictionary" )
	Dim  c : Set c = g_VBS_Lib

	If IsEmpty( Variables ) Then  Set Variables = CreateObject( "Scripting.Dictionary" )


	code = "Option Explicit" +vbCRLF+_
		 "Function  CalculateVariablesInside( Variables )" +vbCRLF


	'//=== 変数を参照していない値を出力する
	For Each  key  In Variables.Keys
		LetSet  value, Variables.Item( key )  '//[out] value
		If IsObject( value ) Then
			code = code + "  Dim "+ key +" : Set "+ key +" = Variables.Item( """+ key +""" )"+ vbCRLF
		ElseIf IsNumeric( value ) Then
			code = code + "  Dim "+ key +" : "+ key +" = "& value & vbCRLF
		Else
			not_out_vars.Add  key, True
		End If
	Next


	'//=== 変数を参照している値を出力する
	Do
		If not_out_vars.Count = 0 Then  Exit Do
		prev_count = not_out_vars.Count

		For Each  key  In not_out_vars.Keys
			LetSet  value, Variables.Item( key )  '//[out] value
			For Each  key2  In not_out_vars.Keys
				If InStrEx( value, key2, 1, c.WholeWord ) > 0 Then  Exit For
			Next
			If IsEmpty( key2 ) Then
				code = code + "  Dim "+ key +" : "+ key +" = "& value & vbCRLF
				not_out_vars.Remove  key
			End If
		Next

		If not_out_vars.Count = prev_count Then
			Raise  E_NotFoundSymbol, "<ERROR msg=""循環参照しています"" symbol="""+ _
				XmlAttr( DicKeyToCSV( not_out_vars ) ) +"""/>"
		End If
	Loop


	'//=== 計算する
	code = code +_
				 "  CalculateVariablesInside = "+ Replace( Formula, "0x", "&h" ) +vbCRLF+_
				 "End Function" +vbCRLF

	Execute  code

	CalculateVariables = CalculateVariablesInside( Variables )
End Function


 
'*************************************************************************
'  <<< [ObjToXML] >>> 
'*************************************************************************
Function  ObjToXML( TagName, Objs, Opt )
	Dim  o
	Dim  out

	If not IsEmpty( TagName ) Then  out = "<" + TagName + ">" + vbCRLF
	If IsArray( Objs ) Then
		For Each o In Objs : If not IsEmpty(o) Then  ObjToXML1  o, out
		Next
	ElseIf TypeName( Objs ) = "ArrayClass" Then
		For Each o In Objs.Items : ObjToXML1  o, out : Next
	ElseIf IsObject( Objs ) Then
		ObjToXML1  Objs, out
	End If
	If not IsEmpty( TagName ) Then  out = out + "</" + TagName + ">" + vbCRLF
	ObjToXML = Left( out, Len( out ) - 2 )
End Function


Sub  ObjToXML1( Obj, Out )
	Dim en,ed

	Out = Out + "<" + TypeName( Obj )

	ErrCheck : On Error Resume Next
		ed = Obj.Name
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 0 Then  Out = Out + " Name=""" & XmlAttr( Obj.Name ) & """"
	If en = 438 Then  en = 0
	If en <> 0 Then  Err.Raise en,,ed

	ErrCheck : On Error Resume Next
		ed = Obj.DefinePath
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 0 Then  Out = Out + " DefinePath=""" & XmlAttr( Obj.DefinePath ) & """"
	If en = 438 Then  en = 0
	If en <> 0 Then  Err.Raise en,,ed

	Out = Out + "/>" + vbCRLF
End Sub


 
'*************************************************************************
'  <<< [get_Object] >>> 
'*************************************************************************
Function  get_Object( Name )
	Dim  en,ed

	ErrCheck : On Error Resume Next
		Dim  get_func : Set  get_func = GetRef( "get_" + Name )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 5 Then  Err.Raise  en,,ed + " : Not defined 'get_" + Name + "'"
	If en <> 0 Then  Err.Raise en,,ed

	Set  get_Object = get_func()
End Function


 
'*************************************************************************
'  <<< [get_ObjectFromFile] >>> 
'*************************************************************************
Function  get_ObjectFromFile( ModulePath, Name )
	Dim  f

	g_SrcPath = g_fs.GetAbsolutePathName( ModulePath )
	If g_is_debug Then  echo  ">include """ + g_SrcPath + """"
	Set f = g_fs.OpenTextFile( g_SrcPath,,,-2 )
	If g_is_debug Then
		ExecuteGlobal  "'// " + g_SrcPath +vbCRLF+ f.ReadAll()
	Else
		ExecuteGlobal  f.ReadAll()
	End If

	Dim  get_func : Set  get_func = GetRef( "get_" + Name )
	Set  get_ObjectFromFile = get_func()
End Function


 
'*************************************************************************
'  <<< [get_NameDelegator] >>> 
'*************************************************************************
Dim  g_NameDic : Set g_NameDic = CreateObject( "Scripting.Dictionary" )

Function  get_NameDelegator( Name, TrueName, InterfaceName )
	If g_NameDic.Exists( Name +"__"+ TrueName ) Then
		Set get_NameDelegator = g_NameDic.Item( Name +"__"+ TrueName +"_"+ InterfaceName )
		Exit Function
	End If

	Set  get_NameDelegator = new_X( InterfaceName + "_Delegator" ) : With get_NameDelegator
		.Name = Name
		.m_Delegate = TrueName  '// if validated was need.
		If not g_bNeedValidateDelegate Then _
			Set .m_Delegate = get_Object( TrueName )  '// if validated was not need.
	End With

	Set  g_NameDic.Item( Name +"__"+ TrueName +"_"+ InterfaceName ) = get_NameDelegator
End Function


Const  F_ValidateOnlyDelegate = &h40000000
Dim    g_bNeedValidateDelegate


Function  NameDelegator_getTrueName( m )
	If VarType( m.m_Delegate ) = vbString Then
		NameDelegator_getTrueName = m.m_Delegate
	Else
		NameDelegator_getTrueName = m.m_Delegate.TrueName
	End If
End Function


Sub  NameDelegator_validate( m, Flags )
	If VarType( m.m_Delegate ) = vbString Then
		Set m.m_Delegate = get_Object( m.m_Delegate )
	End If
	If ( Flags and F_ValidateOnlyDelegate ) = 0 Then _
		m.m_Delegate.Validate  Flags
End Sub


Function  NameDelegator_getXML( m )
	If VarType( m.m_Delegate ) = vbString Then
		NameDelegator_getXML = "<" + TypeName( m ) + _
			" Name='" + m.Name + "' TrueName='" + m.TrueName + "'/>"
	Else
		NameDelegator_getXML = "<" + TypeName( m ) + _
			" Name='" + m.Name + "' TrueName='" + m.TrueName + "'>" +vbCRLF+_
			m.m_Delegate.xml + vbCRLF + "</" + TypeName( m ) + ">"
	End If
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [NameOnlyClass] Class >>>> 
'-------------------------------------------------------------------------
Class  NameOnlyClass

	Public Name
	Public Delegate

	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		If not IsObject( Delegate ) Then
			If Delegate = "" Then
				xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" Name='"+ _
					XmlAttrA( Name ) + "'/>"+ vbCRLF
			Else
				xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" Name='"+ _
					XmlAttrA( Name ) + "'>"+ _
					GetEchoStr( Delegate ) +"</"+TypeName(Me)+">"+ vbCRLF
			End If
		Else
			xml_sub2 = GetEchoStr_sub( Delegate, Level )
			If InStr( xml_sub2, vbLF ) = Len( xml_sub2 ) Then  '// Only 1 line
				CutLastOf  xml_sub2, vbCRLF, Empty
				If xml_sub2 = "" Then
					xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" Name='"+ _
						XmlAttrA( Name ) + "'/>"+ vbCRLF
				Else
					xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" Name='"+ _
						XmlAttrA( Name ) + "'>"+ _
						xml_sub2 +"</"+TypeName(Me)+">"+ vbCRLF
				End If
			Else
				xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" Name='"+ _
					XmlAttrA( Name ) + "'>"+vbCRLF+ _
					xml_sub2 + GetTab(Level) +"</"+TypeName(Me)+">"+ vbCRLF
			End If
		End If
	End Function
End Class


'//[new_NameOnlyClass]
Function  new_NameOnlyClass( in_Name, in_Delegate )
	Set object = new NameOnlyClass
	object.Name = in_Name
	If IsObject( in_Delegate ) Then
		Set object.Delegate = in_Delegate
	Else
		object.Delegate = in_Delegate
	End If
	Set new_NameOnlyClass = object
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [DestroyCountClass] Class >>>> 
'-------------------------------------------------------------------------
Dim  g_DestroyCount

Class  DestroyCountClass
	Sub Class_Terminate()
		g_DestroyCount = g_DestroyCount + 1
	End Sub

	Public Function  xml_sub( in_Level )
		xml_sub = vbCRLF
	End Function
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [JoinedClass] Class >>>> 
'-------------------------------------------------------------------------
Class  JoinedClass

	Public Left
	Public Right

	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" Left='"+ GetEchoStr( Left ) + "'>"+vbCRLF+ _
			GetEchoStr( Right ) +vbCRLF+"</"+TypeName(Me)+">"+ vbCRLF
	End Function
End Class


 
'*************************************************************************
'  <<< [new_JoinedClass] >>> 
'*************************************************************************
Function  new_JoinedClass( in_Left, in_Right )
	Set  self = new JoinedClass

	If IsObject( in_Left ) Then _
		Set self.Left = in_Left _
	Else _
		self.Left = in_Left

	If IsObject( in_Right ) Then _
		Set self.Right = in_Right _
	Else _
		self.Right = in_Right

	Set new_JoinedClass = self
End Function


 
'-------------------------------------------------------------------------
'  <<< [FuncRedir] Class >>> 
'-------------------------------------------------------------------------

Sub  FuncRedir_add( GetFuncs, FuncName )
	If IsEmpty( GetFuncs ) Then  Set GetFuncs = new FuncRedir
	If IsDefined( FuncName ) Then _
		GetFuncs.m_Funcs.Add  GetRef( FuncName )
End Sub


Class  FuncRedir
	Public  m_Funcs  ' as ArrayClass of Function
	Public  m_CallLevel  ' as integer

	Private Sub  Class_Initialize()
		Set m_Funcs = new ArrayClass
		m_CallLevel = 0
	End Sub

	Public Function  CallFunction0()
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		CallFunction0 = m_Funcs( i )()
		m_CallLevel = m_CallLevel - 1
	End Function

	Public Function  CallFunction1( Param1 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		CallFunction1 = m_Funcs( i )( Param1 )
		m_CallLevel = m_CallLevel - 1
	End Function

	Public Function  CallFunction2( Param1, Param2 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		CallFunction2 = m_Funcs( i )( Param1, Param2 )
		m_CallLevel = m_CallLevel - 1
	End Function

	Public Function  CallFunction3( Param1, Param2, Param3 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		CallFunction3 = m_Funcs( i )( Param1, Param2, Param3 )
		m_CallLevel = m_CallLevel - 1
	End Function

	Public Function  CallFunction4( Param1, Param2, Param3, Param4 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		CallFunction4 = m_Funcs( i )( Param1, Param2, Param3, Param4 )
		m_CallLevel = m_CallLevel - 1
	End Function

	Public Sub  CallSub0()
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		Call  m_Funcs( i )()
		m_CallLevel = m_CallLevel - 1
	End Sub

	Public Sub  CallSub1( Param1 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		Call  m_Funcs( i )( Param1 )
		m_CallLevel = m_CallLevel - 1
	End Sub

	Public Sub  CallSub2( Param1, Param2 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		Call  m_Funcs( i )( Param1, Param2 )
		m_CallLevel = m_CallLevel - 1
	End Sub

	Public Sub  CallSub3( Param1, Param2, Param3 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		Call  m_Funcs( i )( Param1, Param2, Param3 )
		m_CallLevel = m_CallLevel - 1
	End Sub

	Public Sub  CallSub4( Param1, Param2, Param3, Param4 )
		m_CallLevel = m_CallLevel + 1
		Dim  i : i = m_Funcs.Count - m_CallLevel : If i < 0 Then  i = 0
		Call  m_Funcs( i )( Param1, Param2, Param3, Param4 )
		m_CallLevel = m_CallLevel - 1
	End Sub
End Class


 
'*************************************************************************
'  <<< [new_X] >>> 
'*************************************************************************
Function  new_X( Name )
	Dim en,ed

	ErrCheck : On Error Resume Next
		Dim  new_f : Set  new_f = GetRef( "new_" + Name )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 5 Then  Err.Raise  en,,ed + " : Not defined 'new_" + Name + "'"
	If en <> 0 Then  Err.Raise en,,ed

	Set  new_X = new_f()
End Function


 
'*************************************************************************
'  <<< [include_objs] >>> 
'*************************************************************************
Dim  g_included_paths : Set g_included_paths = CreateObject( "Scripting.Dictionary" )

Sub  include_objs( Wildcard, Flags, out_GetObjectFuncs )
	Dim  ds_:Set ds_= new CurDirStack
	Dim  folder_path, fname_key_s, folders, i, fo, f, fi, t, en, ed, e, wildcards
	Dim  fname_key, fname_keys, is_match, fname,  folder_fnames,  path,  is_done
	Dim  file_names,  file_path,  file_names_fast_ubound
	Dim  c : Set c = g_VBS_Lib
	Const  NotCaseSensitive = 1

	If ( Flags and c.NotToEmptyArray ) = 0 Then _
		ReDim  out_GetObjectFuncs(-1)

	is_done = False
	If not IsArray( Wildcard ) Then
	 If not IsWildcard( Wildcard )  and  g_fs.FileExists( Wildcard ) Then

		g_SrcPath = GetFullPath( Wildcard, Empty )

		If IsEmpty( g_included_paths.Item( g_SrcPath ) ) Then

			If g_is_debug Then  echo  ">include """ + g_SrcPath + """"
			ExecuteGlobal  "Sub  get_StaticObjects(a,b) : End Sub"

			Set fi = g_fs.OpenTextFile( g_SrcPath,,,-2 )
			If g_is_debug Then  t = "'// " + g_SrcPath +vbCRLF+ fi.ReadAll()  Else  t = fi.ReadAll()
			fi.Close
			g_sh.CurrentDirectory = g_fs.GetParentFolderName( g_SrcPath )

			If not IsEmpty( g_debug_vbs_path ) and _
			       InStr( g_SrcPath, g_debug_vbs_path ) > 0 Then
				InvestigateInterpretError2  g_SrcPath, en, ed
			Else
				If TryStart(e) Then  On Error Resume Next
					ExecuteGlobal  t  '// Interpret  g_SrcPath
				If TryEnd Then  On Error GoTo 0
				If e.Num = 1041 Then
					InvestigateInterpretError  g_SrcPath, e.Num, e.desc
				ElseIf e.Num <> 0 Then
					e.Raise
				End If
			End If

			ReDim Preserve  out_GetObjectFuncs( UBound( out_GetObjectFuncs ) + 1 )
			Set out_GetObjectFuncs( UBound( out_GetObjectFuncs ) ) = GetRef( "get_StaticObjects" )

			Set  g_included_paths.Item( g_SrcPath ) = out_GetObjectFuncs( UBound( out_GetObjectFuncs ) )
		Else
			ReDim Preserve  out_GetObjectFuncs( UBound( out_GetObjectFuncs ) + 1 )
			Set out_GetObjectFuncs( UBound( out_GetObjectFuncs ) ) = g_included_paths.Item( g_SrcPath )
		End If
		is_done = True
	 End If
	End If
	If not is_done Then
		ReDim  file_names(-1)
		file_names_fast_ubound = UBound( file_names )
		Set folder_fnames = CreateObject( "Scripting.Dictionary" )
		folder_fnames.CompareMode = NotCaseSensitive
		'// folder_fnames as dictionary of array of StrMatchKey, key= folder_path

		If IsArray( Wildcard ) Then  wildcards = Wildcard  Else  wildcards = Array( Wildcard )
		For Each path  In wildcards
			If g_fs.FileExists( path ) Then
				If UBound(file_names) <= file_names_fast_ubound Then _
				ReDim Preserve  file_names( ( file_names_fast_ubound + 100 ) * 4 )
				file_names_fast_ubound = file_names_fast_ubound + 1

				file_names( file_names_fast_ubound ) = path
				folder_path = Empty
			ElseIf g_fs.FolderExists( path ) Then
				folder_path = path : fname_key_s = "*_obj.vbs"
			Else
				folder_path = GetParentFullPath( path ) : fname_key_s = g_fs.GetFileName( path )
			End If
			If not IsEmpty( folder_path ) Then
				Set fname_key = new StrMatchKey
				fname_key.Keyword = LCase( fname_key_s )

				If IsEmpty( folder_fnames.Item( folder_path ) ) Then
					Set fname_keys = new ArrayClass
					Set folder_fnames.Item( folder_path ) = fname_keys
				Else
					Set fname_keys = folder_fnames.Item( folder_path )
				End If
				fname_keys.Add  fname_key
			End If
		Next

		ReDim Preserve  file_names( file_names_fast_ubound )
		For Each file_path  In file_names
			include_objs  file_path, Flags or c.NotToEmptyArray, out_GetObjectFuncs
		Next

		For Each folder_path  In folder_fnames.Keys
			Set fname_keys = folder_fnames.Item( folder_path )  '// as ArrayClass

			EnumFolderObject  folder_path, folders  '// [out] folders
			For Each fo  In folders
				For Each f  In fo.Files
					fname = f.Name  '// time( f.ShortName ) + time( f.DateLastModified ) = time( f.Name ) * 0.506/0.871
					is_match = False
					For Each fname_key  In fname_keys.Items
						If fname_key.IsMatch( fname ) Then  is_match = True
					Next
					If is_match Then

						include_objs  f.Path, Flags or c.NotToEmptyArray, out_GetObjectFuncs

					End If
				Next
			Next
		Next
	End If
	g_SrcPath = Empty
End Sub


 
'*************************************************************************
'  <<< [get_ObjectsFromFile] >>> 
'*************************************************************************
Sub  get_ObjectsFromFile( GetObjectFuncs, InterfaceName, out_Objs )
	If VarType( GetObjectFuncs ) = vbString Then
		Dim  create_funcs
		include_objs  GetObjectFuncs, Empty, create_funcs '// [out] create_funcs
		get_ObjectsFromFile_sub  create_funcs, InterfaceName, out_Objs
	Else
		get_ObjectsFromFile_sub  GetObjectFuncs, InterfaceName, out_Objs
	End If
End Sub

Sub  get_ObjectsFromFile_sub( GetObjectFuncs, InterfaceName, out_Objs )
	Dim  func, objs

	ReDim  out_Objs(-1)
	For Each func  In GetObjectFuncs
		objs = Empty
		Call  func( InterfaceName, objs ) '// [out] objs
		AddArrElem  out_Objs, objs
	Next
End Sub


 
'*************************************************************************
'  <<< [get_DefineInfoObject] >>> 
'*************************************************************************
Class  DefineInfoClass
	Public  FullPath
End Class

Sub  get_DefineInfoObject( in_out_Object, FullPath )
	If not IsEmpty( in_out_Object ) and  not g_bInvestigateInterpretError Then
		Raise 1, "<ERROR msg=""DefineInfoObject が重複定義されています"" path1="""+ in_out_Object.FullPath +_
			 """ path2="""+ FullPath +"""/>"
	End If
	Set in_out_Object = new DefineInfoClass
	in_out_Object.FullPath = FullPath
End Sub


 
'*************************************************************************
'  <<< [new_ObjectFromStream] >>> 
'*************************************************************************
Sub  new_ObjectFromStream( out_Obj, ClassName, Stream )
	Dim  elem, obj
	Dim  stream_xml : Set stream_xml = ChangeToXml( Stream )

	out_Obj = Empty
	If stream_xml is Nothing Then  Exit Sub

	Set elem = stream_xml.selectSingleNode( ClassName )
	If not elem is Nothing Then
		Dim  i_attr : i_attr = InStr( ClassName, "[" )
		If i_attr = 0 Then
			Set out_Obj = new_X( ClassName )
		Else
			Set out_Obj = new_X( Left( ClassName, i_attr - 1 ) )
		End If
		out_Obj.loadXML  elem
	End If
End Sub


 
'*************************************************************************
'  <<< [new_ObjectsFromStream] >>> 
'*************************************************************************
Sub  new_ObjectsFromStream( out_Objs, ClassName, Stream )
	Dim  elem, obj, i_attr
	Dim  stream_xml : Set stream_xml = ChangeToXml( Stream )

	ReDim  out_Objs(-1)
	If stream_xml is Nothing Then  Exit Sub
	i_attr = InStr( ClassName, "[" )

	For Each elem  In stream_xml.selectNodes( ClassName )
		If i_attr = 0 Then
			Set obj = new_X( ClassName )
		Else
			Set obj = new_X( Left( ClassName, i_attr - 1 ) )
		End If
		obj.loadXML  elem
		ReDim Preserve  out_Objs( UBound( out_Objs ) + 1 )
		Set  out_Objs( UBound( out_Objs ) ) = obj
	Next
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [EventRespondersClass] >>>> 
'-------------------------------------------------------------------------

Class  EventRespondersClass
	Public  Responders

	Private Sub  Class_Initialize()
		ReDim  Responders(-1)
	End Sub

	Public Sub  Add( Func, Object, Priority )
		For Each responder  In Responders
			If responder.Object is Object Then
				Exit Sub
			End If
		Next

		Set responder = new EventResponder

		ReDim Preserve  Responders( UBound( Responders ) + 1 )
		Set Responders( UBound( Responders ) ) = responder
		responder.Priority = Priority
		Set responder.Func = Func
		Set responder.Object = Object

		ShakerSort  Responders,  0,  UBound( Responders ), _
			GetRef( "EventRespondersStaticClass_comparePriority" ), _
			Empty
	End Sub

	Public Sub  Remove( Object )
		For Each responder  In Responders
			If responder.Object is Object Then
				Exit For
			End If
		Next
		RemoveObjectArray  Responders, responder
	End Sub

	Public Sub  Calls( Caller, Args )
		For Each responder  In Responders
			responder.Func  responder.Object, Caller, Args
		Next
	End Sub
End Class

Class  EventResponder
	Public  Priority  '// as integer. Smallest fuction is called first.
	Public  Func      '// as 
	Public  Object
End Class

Function  EventRespondersStaticClass_comparePriority( Left, Right, Parameter )
	EventRespondersStaticClass_comparePriority = Left.Priority - Right.Priority
End Function


 
'*************************************************************************
'  <<< [DefaultFunction] >>> 
'*************************************************************************
Sub  DefaultFunction( Argument1 )
End Sub


 
'*************************************************************************
'  <<< [InvestigateInterpretError] >>> 
'*************************************************************************
Dim  g_debug_vbs_path
Dim  g_debug_vbs_err_num
Dim  g_bInvestigateInterpretError
Dim  g_IsDisableInvestigateInterpretError : g_IsDisableInvestigateInterpretError = False

Sub  InvestigateInterpretError( Path, en, ed )
	Dim  f, t

	If g_IsDisableInvestigateInterpretError Then  Exit Sub

	echo ""
	echo ">InvestigateInterpretError  """ + Path + """"
	g_bInvestigateInterpretError = True

	Set f = g_fs.OpenTextFile( Path,,,-2 ) : t = f.ReadAll() : f.Close
	Dim  en2, ed2
	ErrCheck : On Error Resume Next
		ExecuteGlobal  t
	en2 = Err.Number : ed2 = Err.Description : On Error GoTo 0

	If en2 = 0 Then
		Err.Raise  en,,"<ERROR msg='"+ ed +"' include_path="+vbCRLF+"'"+ g_SrcPath +_
			"'"+vbCRLF+"hint='2回目の ExecuteGlobal ではエラーが出ませんでした。"+_
			"次のコードを main 関数に記述して再実行してください' add_code=" +vbCRLF+_
			"'g_debug_vbs_path = """ + Path + """'/>"
	End If

	echo  GetErrStr( en, ed )


	'// Try to display error line
	RunProg  "wscript.exe """ + Path + """", ""


	'// Error of Duplicate Name
	If en2 = 1041 Then
		Err.Raise  en,,"<ERROR msg='"+ ed +"' include_path="+vbCRLF+"'"+ g_SrcPath +_
			"'"+vbCRLF+"hint='次のコードを main 関数に記述して再実行してください' add_code=" +vbCRLF+_
			"'g_debug_vbs_path = """ + Path + """ : g_debug_vbs_err_num = 1041'/>"
	End If


	'// Try to break at error line ([attention] 2nd execute may different behavior)
	Set f = g_fs.OpenTextFile( Path,,,-2 ) : t = f.ReadAll() : f.Close
	ExecuteGlobal  "'// This is 2nd execute(include) from InvestigateInterpretError." +vbCRLF + t


	'// This is no new hint
	Err.Raise  en,,"<ERROR msg='"+ ed +"' include_path="+vbCRLF+"'"+ g_SrcPath + "'/>"
End Sub


 
'*************************************************************************
'  <<< [InvestigateInterpretError2] >>> 
'*************************************************************************
Sub  InvestigateInterpretError2( Path, en, ed )
	Dim  f, t

	If g_IsDisableInvestigateInterpretError Then  Exit Sub

	If g_debug_vbs_err_num = 1041 Then
		Stop
		InvestigateDuplicatedNameError  g_SrcPath, en, ed
		Stop
	ElseIf g_debug_vbs_err_num = -1041 Then
		Stop  ' This is 1st include. Next is ...
		g_debug_vbs_err_num = 1041
		Set f = g_fs.OpenTextFile( Path,,,-2 ) : t = f.ReadAll() : f.Close
		ExecuteGlobal  t  '// Interpret  g_SrcPath
	Else
		Set f = g_fs.OpenTextFile( Path,,,-2 ) : t = f.ReadAll() : f.Close
		ExecuteGlobal  t  '// Interpret  g_SrcPath
	End If
End Sub


 
'*************************************************************************
'  <<< [InvestigateDuplicatedNameError] >>> 
'*************************************************************************
Sub  InvestigateDuplicatedNameError( Path, en, ed )
	Dim  f, t, i, j, c

	Set f = g_fs.OpenTextFile( Path,,,-2 )
	Do Until f.AtEndOfStream
		t = f.ReadLine()
		i = InStr( t, "Class" )
		If i = 0 Then  i = InStr( t, "Dim" )
		If i > 0 Then
			i=i+1
			Do
				If Mid(t,i,1)=" " Then Exit Do
				If Mid(t,i,1)="" Then Error
				i=i+1
			Loop
			Do
				If Mid(t,i,1)<>" " Then Exit Do
				i=i+1
			Loop

			j=i
			Do
				c = Mid(t,j,1)
				If not( (c>="A" and c<="Z") or (c>="a" and c<="z") or (c>="0" and c<="9") or c="_" ) Then _
					Exit Do
				j=j+1
			Loop
			If j > i Then
				If InStr( t, "Class" ) > 0 Then
					c = "Class " + Mid( t, i, j-i ) + " : End Class"
				Else
					c = "Dim " + Mid( t, i, j-i )
				End If
				echo ">ExecuteGlobal  """ + c + """"
				ExecuteGlobal  c
			End If
		End If
	Loop
	f.Close

	Err.Raise  en,,"<ERROR msg='"+ ed +"' include_path="+vbCRLF+"'"+ g_SrcPath +_
		"'"+vbCRLF+"hint='2回 include している可能性があります。"+_
		"次のコードを main 関数に記述して再実行してください' add_code=" +vbCRLF+_
		"'g_debug_vbs_path = """ + Path + """ : g_debug_vbs_err_num = -1041'/>"
End Sub


 
'*************************************************************************
'  <<< [LetIf] >>> 
'*************************************************************************
Sub  LetIf( in_out_Variable, Value, PassCondition )
	If in_out_Variable = Value Then  Exit Sub
	If not PassCondition Then  Stop : Error
	in_out_Variable = Value
End Sub


 
'*************************************************************************
'  <<< [ParseOptionArguments] >>> 
'*************************************************************************
Sub  ParseOptionArguments( in_out_Options )
	If TypeName( in_out_Options ) = "Dictionary" Then _
		Exit Sub

	Const  NotCaseSensitive = 1

	If IsEmpty( in_out_Options ) Then
		in_out_Options = Array( )
	ElseIf not IsArray( in_out_Options ) Then
		in_out_Options = Array( in_out_Options )
	End If

	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.CompareMode = NotCaseSensitive
	For Each  option_  In in_out_Options
		Select Case  VarType( option_ )
			Case vbObject  : Set dic( TypeName( option_ ) ) = option_
			Case vbInteger : dic( "integer" ) = option_
			Case vbLong    : dic( "integer" ) = option_
			Case vbByte    : dic( "integer" ) = option_
			Case vbSingle  : dic( "float" )   = option_
			Case vbDouble  : dic( "float" )   = option_
			Case Else      : dic( TypeName( option_ ) )  = option_
		End Select
	Next

	Set in_out_Options = dic
End Sub


 
'*************************************************************************
'  <<< [IsBitSet] >>> 
'*************************************************************************
Function  IsBitSet( Variable, ConstValue )
	If Variable and ConstValue Then
		IsBitSet = True
	Else
		IsBitSet = False
	End If
End Function


 
'*************************************************************************
'  <<< [IsAnyBitsSet] >>> 
'*************************************************************************
Function  IsAnyBitsSet( Variable, ConstValue )
	If Variable and ConstValue Then
		IsAnyBitsSet = True
	Else
		IsAnyBitsSet = False
	End If
End Function


 
'*************************************************************************
'  <<< [IsAllBitsSet] >>> 
'*************************************************************************
Function  IsAllBitsSet( Variable, ConstValue )
	If ( Variable and ConstValue ) = ConstValue Then
		IsAllBitsSet = True
	Else
		IsAllBitsSet = False
	End If
End Function


 
'*************************************************************************
'  <<< [IsBitNotSet] >>> 
'*************************************************************************
Function  IsBitNotSet( Variable, ConstValue )
	If not Variable and ConstValue Then
		IsBitNotSet = True
	Else
		IsBitNotSet = False
	End If
End Function


 
'*************************************************************************
'  <<< [IsAnyBitsNotSet] >>> 
'*************************************************************************
Function  IsAnyBitsNotSet( Variable, ConstValue )
	If not Variable and ConstValue Then
		IsAnyBitsNotSet = True
	Else
		IsAnyBitsNotSet = False
	End If
End Function


 
'*************************************************************************
'  <<< [IsAllBitsNotSet] >>> 
'*************************************************************************
Function  IsAllBitsNotSet( Variable, ConstValue )
	If ( not Variable and ConstValue ) = ConstValue Then
		IsAllBitsNotSet = True
	Else
		IsAllBitsNotSet = False
	End If
End Function


 
'*-------------------------------------------------------------------------*
'* ### <<<< Process >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [env] >>> 
'*************************************************************************
Function  env( s )
	Dim  i
	If IsEmpty( s ) Then Exit Function  '// for avoid to s=""
	If IsArray( s ) Then
		For i=0 To UBound( s )
			s(i) = env( s(i) )
		Next
		env = s
		Exit Function
	End If

	i = 1
	Do
		p1 = InStr( i, s, "%" )
		If p1 = 0 Then
			env = env + Mid( s, i )
			Exit Function
		End If

		env = env + Mid( s, i, p1 - i )
		If IsNumeric( Mid( s, p1 + 1, 1 ) ) Then
			env = env + "%"
			i = p1 + 1
		Else
			p2 = InStr( p1+1, s, "%" )
			If p2 = p1+1 Then
				env = env + "%"
			ElseIf p2 = 0 Then
				Raise  E_NotFoundSymbol, "<ERROR msg=""閉じる % が見つかりません"" expression="""+_
					XmlAttr( s ) +"""/>"
			Else
				p3 = InStr( p1+1, s, "(" )
				If p2 < p3  or  p3 = 0 Then
					symbol = Mid( s, p1+1, p2-p1-1 )
					value = GetVarSub( symbol, True )
				Else
					symbol = Mid( s, p1+1, p3-p1 )
					LetSet  value, GetVarSub( symbol, True )
					If TypeName( value ) = "VarWithParameterClass" Then
						p3 = p3 + 1
						p2 = InStr( p3, s, ")%" )
						If p2 = 0 Then
							Raise  E_NotFoundSymbol, "<ERROR msg=""閉じる )% が"+_
								"見つかりません"" expression="""+ XmlAttr( Str ) +"""/>"
						End If

						value = value.GetVar( Mid( s, p3, p2 - p3 ) )
						p2 = p2 + 1
					End If
				End If
				If IsArray( value ) Then
					For ii=0 To UBound( value )
						If IsEmpty( value(ii) ) Then
							Raise  E_NotFoundSymbol, "<ERROR msg="""+_
							"指定した名前の環境変数が見つかりません"" symbol="""+_
							symbol +""" array_index="""& ii &"""/>"
						End If
					Next

					If Mid( s, p2 ) <> "%" Then _
						Raise  E_NotFoundSymbol, "<ERROR msg=""値が配列なので文字列に変換できません""/>"
					env = value
					Exit Function
				End If
				If IsEmpty( value ) Then
					Raise  E_NotFoundSymbol, "<ERROR msg=""指定した名前の環境変数が見つかりません"" symbol="""+ symbol +"""/>"
				End If
				env = env & value
			End If
			i = p2 + 1
		End If
	Loop
End Function


 
'*************************************************************************
'  <<< [VarWithParameterClass] >>> 
'*************************************************************************
Class  VarWithParameterClass
	Public  VarNameAndStartBracket
	Public  GetVar  '// as function
End Class


 
'*************************************************************************
'  <<< [VarWithParameter_XML_FileClass_GetVar] >>> 
'*************************************************************************
Function  VarWithParameter_XML_FileClass_GetVar( Parameter )
	a_URL = env( Parameter )
	value = (new XML_ReadCacheClass)( a_URL )
	value = env( value )
	VarWithParameter_XML_FileClass_GetVar = value
End Function


 
'*************************************************************************
'  <<< [VarWithParameter_ArrayFromXML_FileClass_GetVar] >>> 
'*************************************************************************
Function  VarWithParameter_ArrayFromXML_FileClass_GetVar( Parameter )
	a_URL = env( Parameter )
	values = (new XML_ReadCacheClass).GetArray( a_URL )
	For i = 0 To UBound( values )
		values(i) = env( values(i) )
	Next
	VarWithParameter_ArrayFromXML_FileClass_GetVar = values
End Function


 
'*************************************************************************
'  <<< [VarWithParameter_SpecialFoldersClass_GetVar] >>> 
'*************************************************************************
Function  VarWithParameter_SpecialFoldersClass_GetVar( Parameter )
	identifier = env( Parameter )
	VarWithParameter_SpecialFoldersClass_GetVar = g_sh.SpecialFolders( identifier )
End Function


 
'*************************************************************************
'  <<< [start] >>> 
'*************************************************************************
Sub  start( cmdline )
	echo  ">start  " & cmdline
	cmdline = g_sh.ExpandEnvironmentStrings( cmdline )


	'//=== call a function
	If StrCompHeadOf( cmdline, "\?InCurrentProcessFunc\", Empty ) = 0 Then
		i = 1
		Dim  exe_path : exe_path = MeltCmdLine( cmdline, i )
		Dim func : Set func = GetRef( g_fs.GetFileName( exe_path ) )
		func  cmdline
		Exit Sub

	'//=== edit cmdline by g_CommandPrompt
	ElseIf InStr( cmdline, "cscript" ) > 0 Then
		Dim  f, line, i, ii, s, b_cscript

		i = 1
		Do
			s = MeltCmdLine( cmdline, i )
			Select Case  LCase( s )
				Case  "cscript", "cscript.exe" : b_cscript = True
				Case Else
					If b_cscript Then
						If Left( s, 1 ) <> "/" Then  Exit Do
					End If
			End Select
			s = Empty
			If i = 0 Then  Exit Do
		Loop

		If not IsEmpty( s ) Then
			i = 0
			Set f = OpenForRead( s )
			Do Until  f.AtEndOfStream
				line = f.ReadLine()
				ii = InStr( line, "g_CommandPrompt" )
				If ii > 0 Then  ii = InStr( ii, line, "=" )
				If ii > 0 Then
					ii = CInt( Mid( line, ii+1 ) )
					Exit Do
				End If
				ii = Empty
				i=i+1
				If i=100 Then  Exit Do
			Loop
			f = Empty

			If g_is64bitWindows Then
				cmdline = Replace( cmdline, "cscript",_
					g_sh.ExpandEnvironmentStrings( "%windir%\SysWOW64\cscript" ),1,1 )
			End If

			Select Case  ii
				Case 0:  cmdline = Replace( cmdline, "cscript", "wscript",1,1 )
				Case 1:  cmdline = "cmd /v:on /K ("+ cmdline +"& if ""!errorlevel!""==""21"" exit)"
				Case 2:  cmdline = "cmd /v:on /K ("+ cmdline +")"
			End Select
		End If
	End If


	'//=== create process
	Dim en,ed

	ErrCheck : On Error Resume Next

		g_sh.Run  cmdline,, FALSE

	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_WIN32_FILE_NOT_FOUND Then _
		Err.Raise en,,"<ERROR msg=""実行ファイルが見つからないか、ダブルクォーテーション"+_
			"で囲まれていません"" cmdline="""+ XmlAttr( cmdline ) +"""/>"
	If en <> 0 Then  Err.Raise en,,ed
End Sub


 
'*************************************************************************
'  <<< [RunProg] >>> 
'*************************************************************************
Function  RunProg( ByVal cmdline, ByVal stdout_stderr_redirect )
	Dim  dbg_cmd, pr, i, echo_do

	cmdline = Trim2( cmdline )

	'// ChildProcess object for cscript (1)
	If Left( cmdline, 7 ) = "cscript" Then
		If TypeName( stdout_stderr_redirect ) = "ParentChildProcess" Then
			Set pr = stdout_stderr_redirect : stdout_stderr_redirect = ""
		Else
			Set pr = new_ParentProcess()
		End If
	End If


	'// Echo command line
	echo_do = True
	If IsNumeric( stdout_stderr_redirect ) Then
		Set c = g_VBS_Lib
		If stdout_stderr_redirect = c.NotEchoStartCommand Then  echo_do = False
		stdout_stderr_redirect = ""
	End If
	If g_EchoObj.m_bEchoOff Then  echo_do = False
	If g_is_debug Then  echo_do = True
	If echo_do Then
		echo_v  ">current dir = """ & g_sh.CurrentDirectory & """"
		If stdout_stderr_redirect = "" Then
			echo_v  ">RunProg  " & cmdline
		Else
			echo_v  ">RunProg  " & cmdline+" > """+stdout_stderr_redirect+""""
		End If
	End If


	'// env
	cmdline = g_sh.ExpandEnvironmentStrings( cmdline )


	If not IsEmpty( pr ) Then  '// call cscript

		'// Break in ChildProcess by "g_debug_process"
		If g_InterProcess.ProcessCallID.UBound_ = g_Err2.Break_ChildProcess_CallID.UBound_ Then
			For i=0 To g_InterProcess.ProcessCallID.UBound_-1
				If g_InterProcess.ProcessCallID(i) <> g_Err2.Break_ChildProcess_CallID(i) Then  Exit For
			Next
			If i = g_InterProcess.ProcessCallID.UBound_ Then
				If g_InterProcess.ProcessCallID(i) + 1 = g_Err2.Break_ChildProcess_CallID(i) Then
					If InStr( cmdline, "//x " ) = 0 Then _
						cmdline = "cscript //x "+ Mid( cmdline, InStr( cmdline, " " ) )
				End If
			End If
		End If

		'// avoid to stop by StdIn
		cmdline = cmdline + " /GUI_input:1"

		'// Use 32bit WSH
		If g_is64bitWindows Then
			If Left( cmdline, 7 ) = "cscript" Then
				cmdline = Replace( cmdline, "cscript",_
					g_sh.ExpandEnvironmentStrings( "%windir%\SysWOW64\cscript" ),1,1 )
			End If
		End If

		'// Set "/g_debug", "/debug"
		If InStr( cmdline, "//x " ) > 0 Then
			If InStr( cmdline, "/g_debug" ) = 0 Then _
				cmdline = cmdline + " /g_debug:1"
			If InStr( cmdline, "/debug:" ) = 0 Then _
				cmdline = cmdline + " /debug:1"
		End If

		'// ChildProcess object for cscript (2)
		i = InStr( cmdline, "/ChildProcess:0" )
		If i > 0 Then  '// without /ChildProcess
			Select Case  Mid( cmdline, i + Len( "/ChildProcess:0" ), 1 )
				Case " " : i = -1 : Case "" : i = -1
			End Select
		End If
		If i <= 0 Then  '// with /ChildProcess
			pr.OnCallInParent
			If i = 0 Then
				step_path = GetStepPath( _
					g_fs.GetParentFolderName( pr.m_TempPath ), _
					env( "%TEMP%\Report\" ) )
				cmdline = cmdline +" /ChildProcess:"+ step_path +","+ pr.m_FileID
			End If
		End If
	End If


	'// Create new process
	Dim  ex
	Set ex = g_sh.Exec( cmdline )
	stdout_stderr_redirect = g_sh.ExpandEnvironmentStrings( stdout_stderr_redirect )
	RunProg = WaitForFinishAndRedirect( ex, stdout_stderr_redirect )
	echo  ""


	'// ChildProcess object for cscript (3)
	If not IsEmpty( pr ) Then  pr.OnReturnInParent  RunProg
End Function


 
'*************************************************************************
'  <<< [RunBat] >>> 
'*************************************************************************
Function  RunBat( BatchCommand, ByVal OutPath )
	Dim  BatPath : BatPath = GetTempPath( "RunBat_*.bat" )
	Dim  RetPath : RetPath = GetTempPath( "RunBatRet_*.txt" )
	Dim  b_tmp_out
	If IsEmpty( OutPath ) Then  OutPath = GetTempPath( "RunBatOut_*.txt" ) : b_tmp_out = True

	echo  g_sh.CurrentDirectory & ">"
	Dim  ec : Set ec = new EchoOff

	CreateFile  BatPath, BatchCommand +vbCRLF+ "@echo %errorlevel% > """+ RetPath +""""
	CreateFile  RetPath, "1"  '// default value

	del  OutPath
	ec = Empty  '// echo on in batch file
	RunProg  env("%windir%")+"\system32\cmd.exe /C cd """+ g_sh.CurrentDirectory +""" & ("""+_
		BatPath +""" 2>&1 )",  OutPath

	RunBat = CInt( ReadFile( RetPath ) )
	echo  "%errorlevel% = "& RunBat

	Set ec = new EchoOff
	del  BatPath
	del  RetPath
	IF b_tmp_out Then  del  OutPath
End Function


 
'*************************************************************************
'  <<< [RunBatAsync] >>> 
'*************************************************************************
Function  RunBatAsync( BatchCommand )
	Set self = new RunBatAsyncClass
	self.BatPath = GetTempPath( "RunBat_*.bat" )
	self.RetPath = GetTempPath( "RunBatRet_*.txt" )
	self.IsReceived = False

	echo  g_sh.CurrentDirectory & ">RunBatAsync"
	Dim  ec : Set ec = new EchoOff

	CreateFile  self.BatPath, BatchCommand +vbCRLF+ "@echo %errorlevel% > """+ self.RetPath +""""
	CreateFile  self.RetPath, "1"  '// default value

	ec = Empty  '// echo on in batch file
	Set self.Exec = g_sh.Exec( env("%windir%")+"\system32\cmd.exe "+_
		"/C cd """+ g_sh.CurrentDirectory +""" & ("""+_
		self.BatPath +""" 2>&1 )" )

	'// For debug
	'// exit_code = WaitForFinishAndRedirect( self.Exec, stdout_stderr_redirect ) : Pause

	Set RunBatAsync = self
End Function


'//[RunBatAsyncClass]
Class  RunBatAsyncClass
	Public  ExitCode

	Public Property Get  Status()
		Status = Exec.Status
	End Property

	Public Sub  DoEvents()
		If self.IsReceived Then  Exit Sub

		If Exec.Status = 1 Then
			self.ExitCode = CInt( ReadFile( self.RetPath ) )

			Set ec = new EchoOff
			del  self.BatPath
			del  self.RetPath

			self.IsReceived = True
		End If
	End Sub

	Public  Exec  '// as WshScriptExec
	Public  BatPath
	Public  RetPath
	Public  IsReceived
End Class


 
'*************************************************************************
'  <<< [WaitForFinishAndRedirect] >>> 
'*************************************************************************
Function  WaitForFinishAndRedirect( ex, path )
	Dim  f

	Const  output_is_nul    = 1
	Const  output_is_stdout = 2
	Const  output_is_file   = 3

	If path = "nul" Then
		output = output_is_nul
	ElseIf path = "" Then
		If g_EchoObj.m_bEchoOff Then
			output = output_is_nul
		Else
			output = output_is_stdout
		End If
	Else
		output = output_is_file
	End If


	If g_is_debug and IsEmpty( g_ChildHead ) Then  g_ChildHead = ">|"


	If output = output_is_file Then
		Set ec = new EchoOff
		Set f = OpenForWrite( path, Empty )
		ec = Empty
	End If

	Do While ex.Status = 0
		If output = output_is_nul Then
			Do Until ex.StdOut.AtEndOfStream : ex.StdOut.ReadLine : Loop
			Do Until ex.StdErr.AtEndOfStream : ex.StdErr.ReadLine : Loop
		ElseIf output = output_is_stdout Then
			EchoStream  ex.StdOut, WScript.StdOut, ex, g_ChildHead
			EchoStream  ex.StdErr, WScript.StdErr, ex, g_ChildHead
		Else
			Do Until ex.StdOut.AtEndOfStream
				line = ex.StdOut.ReadLine
				f.WriteLine  line
				echo  line
			Loop
			Do Until ex.StdErr.AtEndOfStream
				line = ex.StdErr.ReadLine
				f.WriteLine  line
				echo  line
			Loop
		End If
	Loop

	If output = output_is_nul Then
		Do Until ex.StdOut.AtEndOfStream : ex.StdOut.ReadLine : Loop
		Do Until ex.StdErr.AtEndOfStream : ex.StdErr.ReadLine : Loop
	ElseIf output = output_is_stdout Then
		EchoStream  ex.StdOut, WScript.StdOut, ex, g_ChildHead
		EchoStream  ex.StdErr, WScript.StdErr, ex, g_ChildHead
	Else
		Do Until ex.StdOut.AtEndOfStream
			line = ex.StdOut.ReadLine
			f.WriteLine  line
			echo  line
		Loop
		Do Until ex.StdErr.AtEndOfStream
			line = ex.StdErr.ReadLine
			f.WriteLine  line
			echo  line
		Loop
	End If

	WaitForFinishAndRedirect = ex.ExitCode
End Function


 
'*************************************************************************
'  <<< [EchoStream] echo supported No vbCRLF >>> 
'*************************************************************************
Dim  g_EchoStreamBuf
Sub  EchoStream( StreamIn, StreamOut, ex, Prompt )
	Dim  c, b, i

	Do Until StreamIn.AtEndOfStream
		c = StreamIn.Read(1)
		If c <> vbCR and c <> vbLF Then
			If g_EchoStreamBuf = "" Then  StreamOut.Write  Prompt
			g_EchoStreamBuf = g_EchoStreamBuf + c
		End If

		'// pause のみ対応
		If Left( g_EchoStreamBuf, 6 ) = "続行するには" Then
			i = 0
			If g_EchoStreamBuf="続行するには何かキーを押してください . . . " Then  i = 1
			If g_EchoStreamBuf=Left(g_PauseMsg,g_PauseMsgStone)+"*"+Chr(8) Then  i = 3
			If g_EchoStreamBuf=g_PauseMsg Then  i = 2
			If i > 0 Then
				StreamOut.Write  c
				If ex.Status = 0 Then
					If i < 3 Then
						WScript.StdIn.ReadLine  '// Waiting Enter from only main process
						If i = 1 Then
							ex.StdIn.Write  vbCR
							StreamIn.ReadLine
						Else
							ex.StdIn.Write  vbCRLF
						End If
					End If
				End If
				If not IsEmpty( g_Test ) Then  g_Test.WriteLogLine  g_EchoStreamBuf
				g_EchoStreamBuf = ""
				c = ""
			End If
		End If

		'// echo
		If c = vbLF Then
			StreamOut.Write  vbLF
			If not IsEmpty( g_Test ) Then  g_Test.WriteLogLine  g_EchoStreamBuf
			g_EchoStreamBuf = ""
		Else
			StreamOut.Write  c
		End If
	Loop
End Sub


 
'*************************************************************************
'  <<< [ArgumentExist] >>> 
'*************************************************************************
Function  ArgumentExist( name )
	Dim  key
	For Each key in WScript.Arguments.Named
		If key = name  Then  ArgumentExist = True : Exit Function
	Next
	ArgumentExist = False
End Function


 
'*************************************************************************
'  <<< [DicFromCmdLineOpt] >>> 
'*************************************************************************
Function  DicFromCmdLineOpt( CmdLine, ByVal OptionNames )
	Dim  i,  name,  value_type,  param,  length,  is_next_value
	Dim  params : params = ArrayFromCmdLine( CmdLine )
	Dim  options : Set options = CreateObject( "Scripting.Dictionary" )
	ReDim  value_types( UBound( OptionNames ) )
	Dim  colons : colons = Array( "", ":", "::" )
	Const  normal      = 0
	Const  space_value = 1
	Const  multi_value = 2


	'// value_types(i) : normal, space_value, multi_value
	'// OptionNames(i) : cut last of ":"
	For i=0 To UBound( OptionNames )
		name = OptionNames(i)
		If Right( name, 1 ) <> ":" Then
			value_types(i) = normal
		ElseIf Right( name, 2 ) <> "::" Then
			value_types(i) = space_value
			OptionNames(i) = Left( name, Len( name ) - 1 )
		Else
			value_types(i) = multi_value
			OptionNames(i) = Left( name, Len( name ) - 2 )
		End If
	Next


	'// options : return value of this function
	Set options( "no name" ) = new ArrayClass
	is_next_value = False
	For Each  param  In params
		If not is_next_value Then
			For i=0 To UBound( OptionNames )
				name = OptionNames(i)
				value_type = value_types(i)
				length = Len( name )

				If Left( param, length ) = name Then
					Select Case  Mid( param, length+1, 1 )
						Case  ":", "="
							If value_type <> multi_value Then
								options( Left( param, length ) + colons( value_type ) ) = Mid( param, length + 2 )
							Else
								If IsEmpty( options( name + colons( value_type ) ) ) Then _
									Set options( name + colons( value_type ) ) = new ArrayClass
								options( Left( param, length ) + colons( value_type ) ).Add  Mid( param, length + 2 )
							End If
						Case  ""
							If value_type <> normal Then
								is_next_value = True
							Else
								options( param ) = True
							End If
						Case Else
							If value_type <> multi_value Then
								options( Left( param, length ) + colons( value_type ) ) = Mid( param, length + 1 )
							Else
								If IsEmpty( options( name + colons( value_type ) ) ) Then _
									Set options( name + colons( value_type ) ) = new ArrayClass
								options( Left( param, length ) + colons( value_type ) ).Add  Mid( param, length + 1 )
							End If
					End Select
					Exit For
				End If
			Next
			If i = UBound( OptionNames ) + 1 Then
				options( "no name" ).Add  param
			End If
		Else
			If value_type = space_value Then
				options( name + colons( value_type ) ) = param
			Else
				If IsEmpty( options( name + colons( value_type ) ) ) Then _
					Set options( name + colons( value_type ) ) = new ArrayClass
				options( name + colons( value_type ) ).Add  param
			End If
			is_next_value = False
		End If
	Next
	Set DicFromCmdLineOpt = options
End Function


 
'*************************************************************************
'  <<< [ModifyCmdLineOpt] >>> 
'*************************************************************************
Function  ModifyCmdLineOpt( CmdLine, ByVal OptionName, NewOptionNameAndParam )
	Dim  params : params = ArrayFromCmdLine( CmdLine )
	Dim  param,  value_type,  length,  is_replaced,  is_next_replaced,  ret
	Dim  old_multi_value,  old_param
	Const  normal      = 0
	Const  space_value = 1
	Const  multi_value = 2


	'// value_type : normal, space_value, multi_value
	'// OptionName : cut last of ":"
	If InStr( OptionName, ":" ) = 0 Then
		value_type = normal
	ElseIf InStr( OptionName, "::" ) = 0 Then
		value_type = space_value
		length = InStr( OptionName, ":" )
		OptionName = Left( OptionName, length - 1 )
	Else
		value_type = multi_value
		length = InStr( OptionName, "::" )
		old_multi_value = Mid( OptionName, length + 2 )
		OptionName = Left( OptionName, length - 1 )
	End If


	'// ret : replace to NewOptionNameAndParam
	ret = ""
	is_replaced = False
	is_next_replaced = False
	For Each  param  In params
		If not is_next_replaced Then
			length = Len( OptionName )
			If Left( param, length ) = OptionName Then
				If value_type <> multi_value Then
					If not is_replaced Then
						If not IsEmpty( NewOptionNameAndParam ) Then _
							ret = ret +" "+ NewOptionNameAndParam
						If value_type = space_value Then  If Mid( param, length + 1, 1 ) = "" Then _
							is_next_replaced = True
						is_replaced = True
					Else
						ret = ret +" "+ param
					End If
				Else  '// value_type = multi_value
					If old_multi_value = "" Then
						ret = ret +" "+ NewOptionNameAndParam +" "+ param
						value_type = normal : is_replaced = True
					Else
						Set old_param = DicFromCmdLineOpt( param, Array( OptionName ) )
						If old_param( OptionName ) = True Then
							is_next_replaced = True
						Else
							If old_param( OptionName ) = old_multi_value Then
								If not IsEmpty( NewOptionNameAndParam ) Then _
									ret = ret +" "+ NewOptionNameAndParam
								value_type = normal : is_replaced = True
							Else
								ret = ret +" "+ param
							End IF
						End IF
					End If
				End If
			Else
				ret = ret +" "+ param
			End If
		Else
			If value_type = multi_value Then
				If param = old_multi_value Then
					If not IsEmpty( NewOptionNameAndParam ) Then _
						ret = ret +" "+ NewOptionNameAndParam
					value_type = normal : is_replaced = True
				Else
					ret = ret +" "+ OptionName +" "+ param
				End If
			End If
			is_next_replaced = False
		End If
	Next
	If not is_replaced Then
		If IsEmpty( NewOptionNameAndParam ) Then
			ModifyCmdLineOpt = CmdLine
		Else
			ModifyCmdLineOpt = NewOptionNameAndParam +" "+ CmdLine
		End If
	Else
		ModifyCmdLineOpt = Mid( ret, 2 )
	End If
End Function


 
'*************************************************************************
'  <<< [GetCommandLineOptionName] >>> 
'*************************************************************************
Function  GetCommandLineOptionName( OneParameter )
	Dim  i
	Dim  s : s = OneParameter

	s = Trim( s )
	If Left( s, 1 ) = "/" Then
		i = InStr( s, ":" )
		If i = 0 Then
			GetCommandLineOptionName = Mid( s, 2 )
		Else
			GetCommandLineOptionName = Mid( s, 2, i-2 )
		End If
	Else
		GetCommandLineOptionName = ""
	End If
End Function


 
'*************************************************************************
'  <<< [GetCommandLineOptionValue] >>> 
'*************************************************************************
Function  GetCommandLineOptionValue( OneParameter )
	Dim  i
	Dim  s : s = OneParameter

	s = Trim( s )
	i = InStr( s, ":" )
	If i > 0 Then
		GetCommandLineOptionValue = ArrayFromCmdLine( Mid( s, i+1 ) )(0)
	Else
		GetCommandLineOptionValue = ""
	End If
End Function


 
'*************************************************************************
'  <<< [ArrayFromCmdLine] >>> 
'*************************************************************************
Function  ArrayFromCmdLine( CmdLine )
	Dim  i, s, arr

	ReDim  arr(-1)
	i = 1
	Do
		ReDim Preserve  arr( UBound( arr ) + 1 )
		arr( UBound( arr ) ) = MeltCmdLine_sub( CmdLine, i, "DOS" )
		If i = 0 Then  ArrayFromCmdLine = arr : Exit Function
	Loop
End Function


 
'*************************************************************************
'  <<< [ArrayFromCmdLineWithoutOpt] >>> 
'*************************************************************************
Function  ArrayFromCmdLineWithoutOpt( CommandLine, ByVal OptionSigns )
	Dim  arr,  i, ii, j, is_opt

	If IsEmpty( OptionSigns ) Then  OptionSigns = Array( "-", "/" )

	arr = ArrayFromCmdLine( CommandLine )
	ii = 0
	For i=0 To UBound( arr )
		is_opt = False
		For j=0 To UBound( OptionSigns )
			If StrCompHeadOf( arr(i), OptionSigns(j), Empty ) = 0 Then  is_opt = True
		Next
		If not is_opt Then
			arr(ii) = arr(i)
			ii = ii + 1
		End If
	Next
	ReDim Preserve  arr(ii-1)
	ArrayFromCmdLineWithoutOpt = arr
End Function


 
'*************************************************************************
'  <<< [MeltCmdLine] >>> 
'*************************************************************************
Function  MeltCmdLine( CmdLine, in_out_Index1 )
	MeltCmdLine = MeltCmdLine_sub( CmdLine, in_out_Index1, "DOS" )
End Function

Function  MeltCmdLine_sub( CmdLine, in_out_Index1, ShellType )
	Dim  i, c, ret,  bs_count
	Dim  is_in_quot : is_in_quot = False
	Dim  is_skip : is_skip = False

	'// skip space
	Do
		c = Mid( CmdLine, in_out_Index1, 1 )
		If c <> " " Then  Exit Do
		in_out_Index1 = in_out_Index1 + 1
	Loop

	If c = "" Then  in_out_Index1 = 0 : Exit Function

	'// melt one parameter
	ret = ""
	Do
		Select Case  c

			Case  ""
				in_out_Index1 = 0
				Exit Do

			Case  """"
				is_in_quot = not is_in_quot

			Case  " "
				If is_in_quot Then
					ret = ret + c
				Else
					Do
						in_out_Index1 = in_out_Index1 + 1
						c = Mid( CmdLine, in_out_Index1, 1 )
						If c <> " " Then  Exit Do
					Loop
					If c = "" Then  in_out_Index1 = 0
					Exit Do
				End If

			Case  "\"
				If ShellType = "DOS" Then
					bs_count = 1
					Do
						in_out_Index1 = in_out_Index1 + 1
						c = Mid( CmdLine, in_out_Index1, 1 )

						If c <> "\" Then  Exit Do
						bs_count = bs_count + 1
					Loop
					If c = """" Then
						If bs_count Mod 2 = 1 Then
							ret = ret + String( ( bs_count - 1 ) / 2, "\" ) + """"
						Else
							ret = ret + String( bs_count / 2, "\" )
							is_in_quot = not is_in_quot
						End If
					Else
						ret = ret + String( bs_count, "\" )
						is_skip = True
					End If

				Else  '// bash
					in_out_Index1 = in_out_Index1 + 1
					c = Mid( CmdLine, in_out_Index1, 1 )
					Select Case  c
						Case  "\"
							ret = ret + "\"
						Case  """"
							ret = ret + """"
						Case Else
							ret = ret + "\" + c
					End Select
				End If

			Case Else
				ret = ret + c
		End Select

		If not is_skip Then
			in_out_Index1 = in_out_Index1 + 1
			c = Mid( CmdLine, in_out_Index1, 1 )
		Else
			is_skip = False
		End If
	Loop
	MeltCmdLine_sub = ret
End  Function


 
'*************************************************************************
'  <<< [CmdLineFromStr] >>> 
'*************************************************************************
Function  CmdLineFromStr( StrOrArray )
	Dim  arr : If IsArray( StrOrArray ) Then  arr = StrOrArray  Else  arr = Array( StrOrArray )
	Dim  ret, i, str,  back_sh_pos,  back_sh_count

	ret = ""
	For i=0 To UBound( arr )
		str = arr(i)
		If i >= 1 Then  ret = ret + " "

		'//  \" -> \\"
		back_sh_pos = 1
		Do
			back_sh_pos = InStr( back_sh_pos,  str, "\""" )
			If back_sh_pos = 0 Then  Exit Do
			back_sh_count = 1

			Do
				If back_sh_pos = 1 Then  Exit Do
				If Mid( str, back_sh_pos - 1, 1 ) <> "\" Then  Exit Do
				back_sh_pos = back_sh_pos - 1  '// pos of first \
				back_sh_count = back_sh_count + 1
			Loop

			str = Left( str, back_sh_pos - 1 ) + String( back_sh_count, "\" ) + _
					Mid( str, back_sh_pos )

			back_sh_pos = back_sh_pos + back_sh_count * 2 + 1
		Loop


		'// " -> \"
		str = Replace( str, """", "\""" )

		'// string -> "string"
		If InStrEx( str, Array( " ", "<", ">", "^", "|" ), 1, Empty ) > 0 Then _
			str = """"+ str +""""

		ret = ret + str
	Next
	CmdLineFromStr = ret
End Function


 
'*************************************************************************
'  <<< [GetWScriptArgumentsUnnamed] >>> 
'*************************************************************************
Function  GetWScriptArgumentsUnnamed()
	Set  args = new ArrayClass
	For index = 0  To WScript.Arguments.Unnamed.Count - 1
		args.Add  ParseWScriptArgumentQuotation( WScript.Arguments.Unnamed( index ) )
	Next
	Set GetWScriptArgumentsUnnamed = args
End Function


 
'*************************************************************************
'  <<< [GetWScriptArgumentsNamed] >>> 
'*************************************************************************
Function  GetWScriptArgumentsNamed( OptionName )
	GetWScriptArgumentsNamed = ParseWScriptArgumentQuotation( _
		WScript.Arguments.Named( OptionName ) )
End Function


 
'*************************************************************************
'  <<< [ParseWScriptArgumentQuotation] >>> 
'*************************************************************************
Function  ParseWScriptArgumentQuotation( in_Value )

	'// Replace \' to "
	Set re = new_RegExp( "\\+'", False )
	Set matches = re.Execute( in_Value )
	index = 0
	out = ""
	If IsEmpty( in_Value ) Then  Exit Function  '// Return Empty

	For Each match  In matches

		'// Add a string before matched string
		length = match.FirstIndex - index
		out = out + Mid( in_Value, index + 1, length )
		index = index + length

		'// Add replaced matched string
		length = match.Length - 1
		If length mod 2 = 0 Then
			out = out + String( length / 2, "\" ) + "'"
		Else
			out = out + String( ( length - 1 ) / 2, "\" ) + """"
		End If
		index = index + match.Length
	Next

	out = out + Mid( in_Value, index + 1 )


	'// Replace "/a" to /a
	If Left( out, 2 ) = """/" Then
		If Right( out, 1 ) = """" Then
			out = Mid( out, 2, Len( out ) - 2 )
		Else
			out = Mid( out, 2 )
		End If
	ElseIf Left( out, 2 ) = """\" Then
		out = """" + Mid( out, 3 )
	End If


	ParseWScriptArgumentQuotation = out
End Function


 
'*************************************************************************
'  <<< [ArrayFromBashCmdLine] >>> 
'*************************************************************************
Function  ArrayFromBashCmdLine( CmdLine )
	Dim  i, s, arr

	ReDim  arr(-1)
	i = 1
	Do
		ReDim Preserve  arr( UBound( arr ) + 1 )
		arr( UBound( arr ) ) = MeltCmdLine_sub( CmdLine, i, "bash" )
		If i = 0 Then  ArrayFromBashCmdLine = arr : Exit Function
	Loop
End Function


 
'*************************************************************************
'  <<< [MeltBashCmdLine] >>> 
'*************************************************************************
Function  MeltBashCmdLine( CmdLine, in_out_Index1 )
	MeltBashCmdLine = MeltCmdLine_sub( CmdLine, in_out_Index1, "bash" )
End Function


 
'*************************************************************************
'  <<< [new_ParentProcess] >>> 
'*************************************************************************
Function  new_ParentProcess()
	Dim  c : Set c = g_VBS_Lib
	Dim  Me_ : Set Me_ = new ParentChildProcess
	Me_.m_TempPath = GetTempPath( "ChildProcess_?" )
	Me_.m_FileID = Mid( Me_.m_TempPath, InStrRev( Me_.m_TempPath, "_" ) + 1 )
	Me_.m_DateID = g_fs.GetFileName( g_fs.GetParentFolderName( Me_.m_TempPath ) )
	Dim  ec : Set ec = new EchoOff
	Set Me_.m_OutFile = OpenForWrite( Me_.m_TempPath +"\In.xml", c.Unicode )
	ec = Empty
	Me_.m_OutFile.WriteLine  "<ToChildProcess>"
	Me_.m_OutFile_LastLine = "</ToChildProcess>"
	Set new_ParentProcess = Me_
End Function


 
'*************************************************************************
'  <<< [ParentChildProcess] >>> 
'*************************************************************************
Class  ParentChildProcess
	Public  m_DateID    ' as string. 例："090401"
	Public  m_FileID    ' as string. 例："1"
	Public  m_TempPath  ' as string. 送受信ファイルができるフォルダのパス
	Public  m_InXML     ' as IXMLDOMElement or Empty. ルート XML 要素
	Public  m_OutFile   ' as TextStream (Write)
	Public  m_OutFile_LastLine ' as string. "</ToChildProcess>" or  "</ToParentProcess>"
	Public  m_bFinished


	Sub  OnCallInParent()  '// ParentChildProcess::OnCallInParent
		g_InterProcess.OnCallInParent  Me

		m_OutFile.WriteLine  m_OutFile_LastLine
		m_OutFile.Close
		m_OutFile = Empty
	End Sub


	Sub  OnReturnInParent( ReturnedValue )  '// ParentChildProcess::OnReturnInParent
		Dim  ec
		Dim  c : Set c = g_VBS_Lib
		Dim  in_path : in_path = m_TempPath +"\Out.xml"
		If g_fs.FileExists( in_path ) Then
			Set ec = new EchoOff
			Set m_InXML = LoadXML( in_path, Empty )
			ec = Empty
			g_InterProcess.OnReturnInParent  Me
		Else
			If ReturnedValue <> 21 Then
				If ReturnedValue = 22 Then
					Raise  ReturnedValue, "<SKIP/>"
				ElseIf ReturnedValue = 0 Then
					Raise  E_Others, "cscript でエラーが発生しました(errorlevel=0)"
				Else
					Raise  ReturnedValue, "cscript でエラーが発生しました"
				End If
			End If
		End If

		Set ec = new EchoOff
		Set m_OutFile = OpenForWrite( m_TempPath +"\In.xml", c.Unicode )
		ec = Empty
		m_OutFile.WriteLine  "<ToChildProcess>"
		m_OutFile_LastLine = "</ToChildProcess>"
	End Sub


	Sub  Finish()  '// ParentChildProcess::Finish

		If m_OutFile_LastLine = "</ToChildProcess>" Then
			If not IsEmpty( m_OutFile ) Then  m_OutFile.Close : m_OutFile = Empty
			Dim  temp_path : temp_path = env( "%TEMP%" )
			If temp_path <> "%TEMP%"  and  Left( m_TempPath, Len( temp_path ) ) = temp_path Then
				If Err.Number = 0 Then
					Dim ec : Set ec = new EchoOff
					del  m_TempPath
					ec = Empty
				Else
					g_fs.DeleteFolder  m_TempPath  '// don't del because Err.Number becomes 0(clear)
				End If
			End If

		Else  '// If m_OutFile_LastLine = "</ToParentProcess>"
			g_InterProcess.OnReturnInChild  Me

			m_OutFile.WriteLine  m_OutFile_LastLine
			m_OutFile.Close
		End If
		m_bFinished = True
	End Sub


	Sub  Class_Terminate()  '// ParentChildProcess::Class_Terminate
		If not m_bFinished Then  Finish
	End Sub
End Class


 
'*************************************************************************
'  <<< [get_ChildProcess] >>> 
'*************************************************************************
Dim  g_ChildProcess

Function  get_ChildProcess()
	Set get_ChildProcess = g_ChildProcess
End Function


'*************************************************************************
'  <<< [new_ChildProcess_ifChildProcess] >>> 
'*************************************************************************
Sub  new_ChildProcess_ifChildProcess()
	Dim  opt : opt = WScript.Arguments.Named.Item("ChildProcess")
	If IsEmpty( opt ) or opt="0" Then  Set g_ChildProcess = Nothing : Exit Sub
	Dim xml : Set xml = CreateObject("MSXML2.DOMDocument")

	'// Initialize g_ChildProcess
	Dim  i : i = 1
	Dim  m : Set m = new ParentChildProcess
		m.m_DateID = MeltCSV( opt, i )
		m.m_FileID = MeltCSV( opt, i )

		m.m_TempPath = env( "%TEMP%\Report\" ) + m.m_DateID +"\ChildProcess_"+ m.m_FileID
		If Left( m.m_TempPath, 6 ) = "%TEMP%" Then  Error
		If not xml.load( m.m_TempPath +"\In.xml" ) Then  Error
		Set m.m_InXML = xml.lastChild

		Set m.m_OutFile = g_fs.CreateTextFile( m.m_TempPath +"\Out.xml", True, True )
			'// OpenForWrite は使えません。 g_AppKey がないため
		m.m_OutFile.WriteLine  "<ToParentProcess>"
		m.m_OutFile_LastLine = "</ToParentProcess>"
		m.m_bFinished = True  '// Disable Class_Terminate but enable Finish
	Set g_ChildProcess = m
End Sub


 
'*************************************************************************
'  <<< [InterProcess] >>> 
'*************************************************************************
Dim  g_InterProcess

Class InterProcess
	Public  InterProcessDataArray '// as ArrayClass of InterProcessData

	Public  ProcessCallID  '// as ArrayClass of integer
	Public  InterProcessUserData  '// as string

	Private Sub  Class_Initialize()
		Set Me.InterProcessDataArray = new ArrayClass
		Set Me.ProcessCallID = new ArrayClass
		Me.ProcessCallID.Add  0
	End Sub

	Property Get  xml()
		xml = "<"+ TypeName( Me ) +" call_id='"+ Me.ProcessCallID.CSV + "' user_data='"& Me.InterProcessUserData &"'/>"
	End Property

	Public Sub  loadXML( XmlObject )  '// InterProcess::loadXML
		Dim i,s  : i = 1
		Dim line : line = XmlObject.getAttribute( "call_id" )
		Me.ProcessCallID.ReDim_  -1
		Do
			s = MeltCSV( line, i )
			If not IsEmpty( s ) Then  Me.ProcessCallID.Add  CInt2( s )
			If i = 0 Then Exit Do
		Loop

		Me.InterProcessUserData = XmlObject.getAttribute( "user_data" )
	End Sub

	Public Sub  OnCallInParent( a_ParentProcess )  '// InterProcess::OnCallInParent
		Dim  obj
		For Each obj  In Me.InterProcessDataArray.Items
			obj.OnCallInParent  a_ParentProcess
		Next
		Me.ProcessCallID( Me.ProcessCallID.UBound_ ) = Me.ProcessCallID( Me.ProcessCallID.UBound_ ) + 1
		a_ParentProcess.m_OutFile.WriteLine  Me.xml

		If g_is_debug Then
			echo "<ChildProcess call_id='"+ Me.ProcessCallID.CSV +"' folder='"+ _
				a_ParentProcess.m_DateID +"\ChildProcess_"+ a_ParentProcess.m_FileID +"'/>"
		End If
	End Sub

	Public Sub  OnCallInChild( a_ChildProcess )  '// InterProcess::OnCallInChild
		Me.loadXML  a_ChildProcess.m_InXML.selectSingleNode( TypeName(Me) )
		Me.ProcessCallID.Add  0
	End Sub

	Public Sub  OnReturnInChild( a_ChildProcess )  '// InterProcess::OnReturnInChild
		Dim  obj
		Me.ProcessCallID.ReDim_  Me.ProcessCallID.UBound_ - 1
		a_ChildProcess.m_OutFile.WriteLine  Me.xml
		For Each obj  In Me.InterProcessDataArray.Items
			obj.OnReturnInChild  a_ChildProcess
		Next
	End Sub

	Public Sub  OnReturnInParent( a_ParentProcess )  '// InterProcess::OnReturnInParent
		Dim  obj, call_id_back

		Set call_id_back = new ArrayClass
		call_id_back.Copy  Me.ProcessCallID
		Me.loadXML  a_ParentProcess.m_InXML.selectSingleNode( TypeName(Me) )
		Me.ProcessCallID.Copy  call_id_back '// Me.ProcessCallID do not update by Child Process

		For Each obj  In Me.InterProcessDataArray.Items
			obj.OnReturnInParent  a_ParentProcess
		Next

		'// サブ・プロセスで発生したエラーを、メイン・プロセスでも投げる
		If g_Err2.Num <> 0 Then
			If g_Err2.Number = 21  Then
				Dim  pos : pos = g_Err2.PrevErrNestPos
				g_Err2.Clear  '// Pass code in exit code is not error
				g_Err2.PrevErrNestPos = pos  '// resume PrevErrNestPos
			Else
				g_Err2.Raise
			End If
		End If
	End Sub
End Class


Class  InterProcessData  '// defined_as_interface
	Public Sub  OnCallInParent( a_ParentProcess ) : End Sub
	Public Sub  loadXML( XmlObject ) : End Sub
	Public Sub  OnReturnInChild( a_ChildProcess ) : End Sub
	Public Sub  OnReturnInParent( a_ParentProcess ) : End Sub
End Class


 
'*************************************************************************
'  <<< [OpenFolder] >>> 
'*************************************************************************
Sub  OpenFolder( in_FolderOrFilePath )
	Set c = g_VBS_Lib

	If exist( in_FolderOrFilePath ) Then
		echo  ">OpenFolder  """+ in_FolderOrFilePath +""""

		Set ec = new EchoOff
		Setting_openFolder  in_FolderOrFilePath
		ec = Empty
	Else
		'// Set "parent_path", "existed_path"
		parent_path = GetParentFullPath( in_FolderOrFilePath )
		existed_path = parent_path
		Do While  not g_fs.FolderExists( existed_path )
			existed_path = g_fs.GetParentFolderName( existed_path )
			If existed_path = "" Then
				Raise  E_PathNotFound,  "<ERROR  msg=""ドライブが存在しません""  path="""+ _
					GetFullPath( in_FolderOrFilePath, Empty ) +"""/>"
			End If
		Loop
		folder_or_file_path = GetStepPath( in_FolderOrFilePath,  Empty )
		If StrCompHeadOf( parent_path, g_sh.CurrentDirectory, c.AsPath ) = 0 Then _
			parent_path = GetStepPath( parent_path,  Empty )
		If StrCompHeadOf( existed_path, g_sh.CurrentDirectory, c.AsPath ) = 0 Then _
			existed_path = GetStepPath( existed_path,  Empty )


		'// ...
		echo_v  ""
		echo_v  """"+ folder_or_file_path +""" が表示できません。"
		If not IsFullPath( folder_or_file_path ) Then _
			echo_v  "カレント="""+ g_sh.CurrentDirectory +""""
		echo_v  "  0. 表示しないで続きを実行する"
		echo_v  "  1. 親フォルダーを表示する "+ existed_path
		echo_v  "  2. フォルダーを作る "+ folder_or_file_path
		If not exist( parent_path ) Then _
			echo  "  3. フォルダーを作る "+ parent_path
		echo_v  "  8. ここでエラーを発生させる"
		Do
			key = Trim( Input( "番号>" ) )
			If key = "0" Then

				Exit Do
			ElseIf key = "1" Then

				Setting_openFolder  existed_path
			ElseIf key = "2" Then

				mkdir  in_FolderOrFilePath
				Setting_openFolder  in_FolderOrFilePath
			ElseIf key = "3" Then

				mkdir  parent_path
				Setting_openFolder  parent_path
			ElseIf key = "8" Then
				Error
			End If
		Loop
	End If
End Sub


 
'*************************************************************************
'  <<< [GetEditorCmdLine] >>> 
'  <<< [GetSearchOpenCmdLine] >>>
'*************************************************************************
Function  GetSearchOpenCmdLine( in_PathAndFragment )
	ThisIsOldSpec
	GetSearchOpenCmdLine = GetEditorCmdLine( Replace( in_PathAndFragment, "%d", "%L" ) )
End Function

Function  GetEditorCmdLine( in_PathAndFragment )
	Dim  cmd,  no_jump_cmd, jumps

	Set jumps = GetTagJumpParams( in_PathAndFragment )


	'//=== Check "jumps.Path"
	If not g_fs.FileExists( jumps.Path ) Then _
		Raise  E_FileNotExist, "<ERROR msg='ファイルが見つかりません' path='"+ GetFullPath( jumps.Path, Empty ) +"'/>"


	'//=== Get command line template. Set to "cmd" and "no_jump_cmd".
	If not IsDefined( "Setting_getEditorCmdLine" ) Then
		cmd = """C:\Windows\notepad.exe"" ""%1"""
		no_jump_cmd = cmd
	Else
		If not IsEmpty( jumps.Keyword ) Then
			cmd = Setting_getEditorCmdLine( 3 )
			If InStr( cmd, "%2" ) = 0 Then  cmd = Empty
		End If
		If IsEmpty( cmd ) Then  cmd = Setting_getEditorCmdLine( 2 )

		no_jump_cmd = Setting_getEditorCmdLine( 1 )
		If IsEmpty( no_jump_cmd ) Then
			no_jump_cmd = Setting_getEditorCmdLine( 0 )
			If IsEmpty( no_jump_cmd ) Then
				no_jump_cmd = env( """%windir%" ) +"\notepad.exe"" ""%1"""
			Else
				no_jump_cmd = """" + no_jump_cmd + """ ""%1"""
			End If
		End If

		If IsEmpty( cmd ) Then  cmd = no_jump_cmd
	End If


	'//=== Replace command line
	If jumps.Keyword <> "" Then
		If InStr( cmd, "%2" ) > 0 Then
			cmd = Replace( cmd, "%2", jumps.Keyword )
		ElseIf InStr( cmd, "%L" ) > 0 Then
			If IsEmpty( jumps.LineNum ) Then _
				jumps.LineNum = GetLineOfSearchOpen( jumps.Path, jumps.Keyword )
			cmd = Replace( cmd, "%L", CStr( jumps.LineNum ) )
		End If
	ElseIf not IsEmpty( jumps.LineNum ) Then
		cmd = Replace( cmd, "%L", CStr( jumps.LineNum ) )
	Else
		cmd = no_jump_cmd
	End If

	GetEditorCmdLine = Replace( cmd, "%1", GetFullPath( jumps.Path, Empty ) )
End Function


Function  GetLineOfSearchOpen( in_Path,  ByVal  in_Name )

	'// Read "${+%d}"
	If InStr( in_Name, "${+" ) >= 1 Then
		skip_count = sscanf( in_Name, "${+%d}" ) - 1
			If skip_count < 0 Then  Error
		in_Name = Replace( in_Name, "${+"+ CStr( skip_count + 1 ) +"}", "" )
	Else
		skip_count = 0
	End If


	'// Read "${\n}"
	is_right_end = ( Right( in_Name, 5 ) = "${\n}" )
	If is_right_end Then
		name_length = Len( in_Name ) - 5
		in_Name = Left( in_Name,  name_length )
	End If


	'// Escaped "$\{ }" to "${ }"
	in_Name = Replace( in_Name, "$\", "$" )


	'// ...
	Set f = OpenForRead( in_Path )
	i = 1
	Do Until  f.AtEndOfStream
		line = f.ReadLine()
		If InStr( line, in_Name ) > 0 Then
			If is_right_end Then
				is_match = ( Right( line,  name_length ) = in_Name )
			Else
				is_match = True
			End If
			If is_match Then
				If skip_count = 0 Then
					GetLineOfSearchOpen = i
					Exit Function
				End If
				skip_count = skip_count - 1
			End If
		End If
		i = i + 1
	Loop
	f = Empty
	GetLineOfSearchOpen = 1
End Function


 
'*************************************************************************
'  <<< [GetEditorCmdLine_DefaultParams] >>> 
'*************************************************************************
Function  GetEditorCmdLine_DefaultParams( i, ExeName, OptType2 )
	Dim  ret

	If i = 1 Then  ret = ExeName +" ""%1"""
	If i = 2 Then  ret = ExeName +" "+ OptType2
	If i = 3 Then  ret = ExeName +" ""%1#%2"""

	GetEditorCmdLine_DefaultParams = ret
End Function


 
'*************************************************************************
'  <<< [GetDiffCmdLine] >>> 
'*************************************************************************
Function  GetDiffCmdLine( PathA, PathB )
	Dim  jumps_a,  jumps_b,  cmd,  line_num

	If not IsDefined( "Setting_getDiffCmdLine" ) Then _
		ExecuteGlobal  "Function  Setting_getDiffCmdLine(t) : End Function"

	Set jumps_a = GetTagJumpParams( PathA )
	Set jumps_b = GetTagJumpParams( PathB )

	If not IsEmpty( jumps_a.Keyword ) and IsEmpty( jumps_a.LineNum ) Then _
		jumps_a.LineNum = GetLineOfSearchOpen( jumps_a.Path, jumps_a.Keyword )
	If not IsEmpty( jumps_b.Keyword ) and IsEmpty( jumps_b.LineNum ) Then _
		jumps_b.LineNum = GetLineOfSearchOpen( jumps_b.Path, jumps_b.Keyword )

	If g_fs.FolderExists( PathA )  or  g_fs.FolderExists( PathB ) Then
		cmd = Setting_getFolderDiffCmdLine( 2 )
	ElseIf not IsEmpty( jumps_a.LineNum ) Then
		cmd = Setting_getDiffCmdLine( 21 )
		line_num = jumps_a.LineNum
	ElseIf not IsEmpty( jumps_b.LineNum ) Then
		cmd = Setting_getDiffCmdLine( 22 )
		line_num = jumps_b.LineNum
	End If
	If IsEmpty( cmd ) Then  cmd = Setting_getDiffCmdLine( 2 )
	If IsEmpty( cmd ) Then
		cmd = Setting_getDiffCmdLine( 0 )
		If IsEmpty( cmd ) Then
			echo  "Diff  """ + PathA + """ """ + PathB + """"
			Exit Function
		Else
			cmd = """"+ cmd +""" ""%1"" ""%2"""
		End IF
	End IF

	cmd = Replace( cmd, "%1", jumps_a.Path )
	cmd = Replace( cmd, "%2", jumps_b.Path )
	cmd = Replace( cmd, "%L", line_num )

	GetDiffCmdLine = cmd
End Function


 
'*************************************************************************
'  <<< [GetDiffCmdLine3] >>> 
'*************************************************************************
Function  GetDiffCmdLine3( PathA, PathB, PathC )
	Dim  jumps_a,  jumps_b,  jumps_c,  cmd,  line_num

	If not IsDefined( "Setting_getDiffCmdLine" ) Then _
		ExecuteGlobal  "Function  Setting_getDiffCmdLine(t) : End Function"

	Set jumps_a = GetTagJumpParams( PathA )
	Set jumps_b = GetTagJumpParams( PathB )
	Set jumps_c = GetTagJumpParams( PathC )

	If not IsEmpty( jumps_a.Keyword ) and IsEmpty( jumps_a.LineNum ) Then _
		jumps_a.LineNum = GetLineOfSearchOpen( jumps_a.Path, jumps_a.Keyword )
	If not IsEmpty( jumps_b.Keyword ) and IsEmpty( jumps_b.LineNum ) Then _
		jumps_b.LineNum = GetLineOfSearchOpen( jumps_b.Path, jumps_b.Keyword )
	If not IsEmpty( jumps_c.Keyword ) and IsEmpty( jumps_c.LineNum ) Then _
		jumps_c.LineNum = GetLineOfSearchOpen( jumps_c.Path, jumps_c.Keyword )

	If g_fs.FolderExists( PathA )  or  g_fs.FolderExists( PathB )  or  g_fs.FolderExists( PathC ) Then
		cmd = Setting_getFolderDiffCmdLine( 3 )
	ElseIf not IsEmpty( jumps_a.LineNum ) Then
		cmd = Setting_getDiffCmdLine( 31 )
		line_num = jumps_a.LineNum
	ElseIf not IsEmpty( jumps_b.LineNum ) Then
		cmd = Setting_getDiffCmdLine( 32 )
		line_num = jumps_b.LineNum
	ElseIf not IsEmpty( jumps_c.LineNum ) Then
		cmd = Setting_getDiffCmdLine( 33 )
		line_num = jumps_c.LineNum
	End If
	If IsEmpty( cmd ) Then  cmd = Setting_getDiffCmdLine( 3 )
	If IsEmpty( cmd ) Then
		If IsEmpty( cmd ) Then
			cmd = Setting_getDiffCmdLine( 0 )
			If IsEmpty( cmd ) Then
				echo  "Diff  """ + PathA + """ """ + PathB + """ """ + PathC + """"
				Exit Function
			Else
				cmd = """"+ cmd +""" ""%1"" ""%2"""
			End IF
		End IF
		cmd = "cscript """+ g_vbslib_ver_folder +"diff3to2\diff3to2.vbs"" /DiffTool:"""+ _
			Setting_getDiffCmdLine( 0 ) +""" ""%1"" ""%2"" ""%3"""
	End If

	cmd = Replace( cmd, "%1", jumps_a.Path )
	cmd = Replace( cmd, "%2", jumps_b.Path )
	cmd = Replace( cmd, "%3", jumps_c.Path )
	cmd = Replace( cmd, "%L", line_num )

	GetDiffCmdLine3 = cmd
End Function


 
'***********************************************************************
'* Function: GetDiffCmdLine3Ex
'***********************************************************************
Function  GetDiffCmdLine3Ex( in_PathA,  in_PathB,  in_PathC,  in_Option )
	If IsEmpty( in_Option ) Then
		command_line = GetDiffCmdLine3( in_PathA,  in_PathB,  in_PathC )
	Else
		Assert  TypeName( in_Option ) = "DiffCmdLineOptionClass"
		Assert  g_fs.FolderExists( in_PathA )  or  g_fs.FolderExists( in_PathB )  or  g_fs.FolderExists( in_PathC )

		'// Set "bit_flags"
		bit_flags = 0
		a_flag = 1
		For i=0 To 2
			If in_Option.IsComparing(i) Then _
				bit_flags = bit_flags + a_flag
			a_flag = a_flag * 2
		Next

		'// ...
		If bit_flags = 7 Then
			command_line = GetDiffCmdLine3( in_PathA,  in_PathB,  in_PathC )
		Else

			command_template = Setting_getFolderDiffCmdLine( 30 + bit_flags )

			If IsEmpty( command_template ) Then
				command_line = GetDiffCmdLine3( in_PathA,  in_PathB,  in_PathC )
			Else
				cmd = command_template
				cmd = Replace( cmd, "%1", in_PathA )
				cmd = Replace( cmd, "%2", in_PathB )
				cmd = Replace( cmd, "%3", in_PathC )
				command_line = cmd
			End If
		End If
	End If

	GetDiffCmdLine3Ex = command_line
End Function


 
'*************************************************************************
'  <<< [GetDiffCmdLineMulti] >>> 
'*************************************************************************
Function  GetDiffCmdLineMulti( Files )
	Dim  op, cmd, i

	echo "--------------------------------------------------------"
	For i=0 To UBound( Files )
		echo (i+1) & ". " & Files(i)(0)
	Next
	op = CInt2( input( "Select number>" ) ) - 1
	echo "--------------------------------------------------------"


	Select Case UBound( Files(op)(1) )

		Case 1:  '// 2 files
			GetDiffCmdLineMulti = GetDiffCmdLine( _
				GetFullPath( Files(op)(1)(0) +"\"+ Files(op)(0), Empty ), _
				GetFullPath( Files(op)(1)(1) +"\"+ Files(op)(0), Empty ) )

		Case 2:  '// 3 files
			GetDiffCmdLineMulti = GetDiffCmdLine3( _
				GetFullPath( Files(op)(1)(0) +"\"+ Files(op)(0), Empty ), _
				GetFullPath( Files(op)(1)(1) +"\"+ Files(op)(0), Empty ), _
				GetFullPath( Files(op)(1)(2) +"\"+ Files(op)(0), Empty ) )

		Case Else
			Error
	End Select
End Function


 
'*************************************************************************
'  <<< [GetDiffCmdLine_DefaultParams] >>> 
'*************************************************************************
Function  GetDiffCmdLine_DefaultParams( i, ExeName )
	Dim  ret

	If i = 0 Then  ret = ExeName
	If i = 2 Then  ret = ExeName +" ""%1"" ""%2"""
	If i = 3 Then  ret = ExeName +" ""%1"" ""%2"" ""%3"""
	If i = 21 Then ret = ExeName +" -i=21 ""%1"" ""%2"""
	If i = 22 Then ret = ExeName +" -i=22 ""%1"" ""%2"""
	If i = 31 Then ret = ExeName +" -i=31 ""%1"" ""%2"" ""%3"""
	If i = 32 Then ret = ExeName +" -i=32 ""%1"" ""%2"" ""%3"""
	If i = 33 Then ret = ExeName +" -i=33 ""%1"" ""%2"" ""%3"""

	GetDiffCmdLine_DefaultParams = ret
End Function


 
'***********************************************************************
'* Class: DiffCmdLineOptionClass
'***********************************************************************
Class  DiffCmdLineOptionClass
	Public  IsComparing  '// array(0..2) of boolean

Private Sub  Class_Initialize()
	ReDim  IsComparing(2)
	For i=0 To 2
		Me.IsComparing(i) = True
	Next
End Sub


'* Section: End_of_Class
End Class


 
'*************************************************************************
'  <<< [DiffCUI] >>> 
'*************************************************************************
Function  DiffCUI( FilePaths, ByVal FileLabels )
	Dim  file_num,  file_ubound,  compare_num, key,  options,  temp_path
	Dim  exist_count, exist_num1, exist_num2
	ReDim  compare_files(1)
	Dim  c : Set c = g_VBS_Lib

	file_ubound = UBound( FilePaths )
	If IsEmpty( FileLabels ) Then
		FileLabels = GetPathLabels( FilePaths )
	End If
	Assert  file_ubound + 1 >= 2  and  file_ubound + 1 <= 6

	Do
		echo_line
		echo  " 1. 差分を調べて、結果をテキスト・エディターで開く"
		exist_count = 0 : exist_num1 = Empty
		For file_num = 0  To file_ubound
			If g_fs.FileExists( FilePaths( file_num ) ) Then
				echo  " " & (file_num + 4) & ". " & FileLabels( file_num ) & " のファイルを開く"
				exist_count = exist_count + 1
				If IsEmpty( exist_num1 ) Then  exist_num1 = file_num  Else  exist_num2 = file_num
			Else
				echo  " *. " & FileLabels( file_num ) & " のファイルは、存在しません"
			End If
		Next
		echo  " **. コピーする（コピー元(4以上)×10＋コピー先(4以上)"
		echo  "     例：45 ＝ "+ FileLabels( 0 ) +" → "+ FileLabels( 1 )
		echo  " 99. 戻る"

		Do
			key = CInt2( input( "操作の番号を入力してください >" ) )
			If key = 1  or  key = 99 Then  Exit Do
			If key >= 4  and  key <= 4 + file_ubound Then
				If g_fs.FileExists( FilePaths( key - 4 ) ) Then _
					Exit Do
			End If
			If key >= 44  and  key <= (file_ubound + 4) * 10 + 9 Then
				If key mod 10 >= 4  and  key mod 10 <= file_ubound + 4 Then _
					Exit Do
			End If
		Loop

		If key = 99 Then  Exit Do
		echo_line

		'// fc command
		If key = 1 Then
			If exist_count = 2 Then
				compare_files( 0 ) = exist_num1
				compare_files( 1 ) = exist_num2
			Else
				For compare_num = 1 To 2
					echo  "比較するファイルの " & compare_num & "つ目を選んでください。"
					For file_num = 0  To file_ubound
						If g_fs.FileExists( FilePaths( file_num ) ) Then _
							echo  " " & (file_num + 4) & ". " & FileLabels( file_num ) & " のファイル"
					Next
					Do
						key = CInt2( input( "番号を入力してください >" ) )
						If key >= 4  and  key <= file_ubound + 4 Then  Exit Do
					Loop
					compare_files( compare_num - 1 ) = key - 4
				Next
			End If

			temp_path = GetTempPath( "fc_*.txt" )

			If ReadUnicodeFileBOM( FilePaths( compare_files( 0 ) ) ) = c.Unicode Then
				options = " /N /U"
			Else
				options = " /N"
			End If
			Set ec = new EchoOff
			RunProg  "fc"+ options +" """+ FilePaths( compare_files( 0 ) ) +""" """+ _
				FilePaths( compare_files( 1 ) ) +"""", temp_path
			ec = Empty

			start  GetEditorCmdLine( temp_path )
			key = 1  '// goto next loop
		End If

		'// start Editor
		If key >= 4  and  key <= 4 + file_ubound Then
			start  GetEditorCmdLine( FilePaths( key - 4 ) )
		End If

		'// copy
		If key >= 44 Then
			compare_files( 0 ) = Fix( key / 10 ) - 4
			compare_files( 1 ) = key mod 10 - 4
			key = input( "コピー元： "+ FileLabels( compare_files( 0 ) ) +_
													 " : "+ FilePaths(  compare_files( 0 ) ) + vbCRLF +_
									 "コピー先： "+ FileLabels( compare_files( 1 ) ) +_
													 " : "+ FilePaths(  compare_files( 1 ) ) + vbCRLF +_
									 "上書きコピーしてよろしいですか？[Y/N]" )
			If key = "Y"  or  key = "y" Then
				copy_ren  FilePaths( compare_files( 0 ) ), FilePaths( compare_files( 1 ) )
			End If
		End If
	Loop
End Function


 
'*-------------------------------------------------------------------------*
'* ### <<<< Wait >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [Sleep] >>> 
'*************************************************************************
Sub  Sleep( ByVal msec )
	'// echo  ">Sleep  " & msec
	WScript.Sleep msec
End Sub


 
'*************************************************************************
'  <<< [WaitForFile] Wait for make the file >>> 
'*************************************************************************
Function  WaitForFile( Path )
	echo  ">WaitForFile  " & Path
	Set c = g_VBS_Lib

	'//=== Wait for file exists
	f = 0
	While g_fs.FileExists( Path ) = False
		WScript.Sleep 1000
		f=f+1 : If f=3 Then  WScript.Echo  ">WaitForFile  " & Path & " ..."
	Wend


	'//=== read as xml
	n_retry = 0
	Do
		ErrCheck : On Error Resume Next

			Set xml = CreateObject("MSXML2.DOMDocument")
			is_xml = ( xml.load( Path ) <> 0 )

		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If not IsWriteAccessDenied( en, Path, c.File, n_retry ) Then  Exit Do
	Loop
	If en <> 0 Then  Err.Raise en,,ed


	If is_xml Then

		WaitForFile = xml.lastChild.xml

	Else

		'//=== Open file supported lock
		n_retry = 0
		Do
			ErrCheck : On Error Resume Next

				Set f = g_fs.OpenTextFile( Path,,,-2 )

			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If not IsWriteAccessDenied( en, Path, c.File, n_retry ) Then  Exit Do
		Loop
		If en <> 0 Then  Err.Raise en,,ed


		'//=== Read file supported lock
		n_retry = 0
		Do
			ErrCheck : On Error Resume Next
				WaitForFile = f.ReadLine
			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If en <> E_EndOfFile Then
				If en <> 0 Then  Err.Raise en,,ed
				Exit Do
			End If

			Sleep  250  '// wait for close of write process
			n_retry = n_retry + 1
			If n_retry = 4 Then  WaitForFile = "" : Exit Do
		Loop
		f = Empty
	End If


	'//=== Delete file
	del  Path
	While  g_fs.FileExists( Path )
		WScript.Sleep 200  '// Delete may have delay ?
	WEnd


	'//=== Raise error
	If Left( WaitForFile, 6 ) = "<ERROR" Then
		num = xml.lastChild.getAttribute( "num" )
		If IsNull( num ) Then
			Raise  1, WaitForFile
		Else
			Raise  CInt(num), WaitForFile
		End If
	End If
End Function


 
'*-------------------------------------------------------------------------*
'* ### <<<< Sound >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [Play] >>> 
'*************************************************************************
Sub  Play( Path )
	Player_validate '// g_Player

	With g_Player.m_Obj
		.URL = Path
		'// .PreviewMode = True  '// Cannot play movie because WSH does not have window.
		.Controls.Play
	End With
End Sub


 
'*************************************************************************
'  <<< [SystemSound] >>> 
'*************************************************************************
Sub  SystemSound( Sound )
	Const  base = "HKEY_CURRENT_USER\AppEvents\Schemes\Apps\"
	Const  current = "\.Current\"
	Const  E_PathNotFound = &h80070002

	Dim  en,ed, parent, reg_path, file_path

	For Each parent  In Array( ".Default", "Explorer", "devenv", "dexplore", "sapisvr" )
		reg_path = base + parent +"\"+ Sound + current
		ErrCheck : On Error Resume Next
			file_path = env( g_sh.RegRead( reg_path ) )
		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If en = 0 Then  Exit For
		If en <> E_PathNotFound Then  Err.Raise en,,ed
	Next
	If file_path <> "" and file_path <> reg_path  Then  Play  file_path
End Sub


 
'*************************************************************************
'  <<< [WaitForSound] >>> 
'*************************************************************************
Sub  WaitForSound( Timeout_msec )
	Player_validate '// g_Player

	Dim  i : i = CInt( Timeout_msec / 250 )
	If IsEmpty( Timeout_msec ) Then  i=9
	For i=i To 1 Step -1
		If g_Player.m_Obj.PlayState = 1 Then Exit For
		If g_Player.m_Obj.PlayState = 10 Then  Raise E_PathNotFound, _
			"<ERROR msg='Cannot play the file' path='" + g_Player.m_Obj.URL + "'/>"
		WScript.Sleep  250
		If IsEmpty( Timeout_msec ) Then  i=9
	Next
	g_Player.m_Obj.Controls.Stop
End Sub


 
'*************************************************************************
'  <<< [SetVolume] >>> 
'*************************************************************************
Sub  SetVolume( Volume )
	Player_validate '// g_Player
	g_Player.m_Obj.Settings.Volume = Volume
End Sub


 
'*************************************************************************
'  <<< [Player_validate] >>> 
'*************************************************************************
Sub  Player_validate()
	If IsEmpty( g_Player ) Then  Set g_Player = new Vbslib_Player
End Sub

Class  Vbslib_Player
	Public  m_Obj

	Private Sub  Class_Initialize()
		Set m_Obj = CreateObject( "WMPlayer.OCX" )
		m_Obj.Settings.Volume = 100
	End Sub

	Private Sub  Class_Terminate()
		Dim  i
		For i=1 To 12 '// 12 = 3second for sound effects. Music will stop.
			If m_Obj.PlayState = 1 or m_Obj.PlayState = 10 Then Exit For
			WScript.Sleep  250
		Next
	End Sub
End Class


 
'*-------------------------------------------------------------------------*
'* ### <<<< Variable, Array and collection >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [DicItem] >>> 
'*************************************************************************
Function  DicItem( Dic, Key )
	If not Dic.Exists( Key ) Then  Exit Function
	If IsObject( Dic.Item( Key ) ) Then  Set DicItem = Dic.Item( Key )  Else  DicItem = Dic.Item( Key )
End Function


 
'*************************************************************************
'  <<< [IfElse] >>> 
'*************************************************************************
Function  IfElse( Condition, TrueValue, FalseValue )
	If Condition Then
		IfElse = TrueValue
	Else
		IfElse = FalseValue
	End If
End Function


 
'*************************************************************************
'  <<< [IfElseObj] >>> 
'*************************************************************************
Function  IfElseObj( Condition, TrueObject, FalseObject )
	If Condition Then
		Set IfElse = TrueValue
	Else
		Set IfElse = FalseValue
	End If
End Function

 
'*************************************************************************
'  <<< [GetDicItem] >>> 
'*************************************************************************
Sub  GetDicItem( in_Dictionary,  in_Key,  out_Item )
	If not in_Dictionary.Exists( in_Key ) Then
		out_Item = Empty
	Else
		LetSet  out_Item,  in_Dictionary( in_Key )
	End If
End Sub


 
'***********************************************************************
'* Function: GetDicItemOrError
'***********************************************************************
Sub  GetDicItemOrError( in_Dictionary,  in_Key,  out_Item,  in_DictionaryName )
	If not in_Dictionary.Exists( in_Key ) Then
		Raise  E_Others, "<ERROR msg=""見つかりません""  name="""+ _
			in_Key +"""  in="""+ in_DictionaryName +"""/>"
	Else
		LetSet  out_Item,  in_Dictionary( in_Key )
	End If
End Sub


 
'***********************************************************************
'* Function: GetDicKeyByIndex
'***********************************************************************
Function  GetDicKeyByIndex( in_Dictionary, in_IndexNum )
	If in_IndexNum < 0 Then _
		Exit Function

	i = 0
	For Each  key  In  in_Dictionary.Keys
		If in_IndexNum <= i Then
			GetDicKeyByIndex = key
			Exit For
		End If
		i=i+1
	Next
End Function


 
'***********************************************************************
'* Function: GetDicItemByIndex
'***********************************************************************
Sub  GetDicItemByIndex( in_Dictionary, in_IndexNum, out_Item )
	key = GetDicKeyByIndex( in_Dictionary, in_IndexNum )

	If IsEmpty( key ) Then
		out_Item = Empty
	ElseIf IsObject( in_Dictionary( key ) ) Then
		Set out_Item = in_Dictionary( key )
	Else
		out_Item = in_Dictionary( key )
	End If
End Sub


 
'*************************************************************************
'  <<< [GetDicItemAsArrayClass] >>> 
'*************************************************************************
Function  GetDicItemAsArrayClass( Dic, Key )
	If IsEmpty( Dic.Item( Key ) ) Then
		Set GetDicItemAsArrayClass = new ArrayClass
		Set Dic.Item( Key ) = GetDicItemAsArrayClass
	Else
		Set GetDicItemAsArrayClass = Dic.Item( Key )
	End If
End Function


 
'*************************************************************************
'  <<< [DicItemOfItem] >>> 
'*************************************************************************
Function  DicItemOfItem( Dic, ByVal Key )
	Dim  item
	Dim  ref_keys : Set ref_keys = CreateObject( "Scripting.Dictionary" )

	Do
		GetDicItem  Dic, Key, item  '//[out] item

		If VarType( item ) = vbString Then
			Select Case  Left( item, 1 )
				Case "$"
					item = Mid( item, 2 )
					If Left( item, 1 ) = "{" Then
						item = Mid( item, 2 )
						If Right( item, 1 ) = "}" Then _
							item = Left( item, Len(item)-1 )
					End IF

				Case "%"
					item = Mid( item, 2 )
					If Right( item, 1 ) = "%" Then _
						item = Left( item, Len(item)-1 )

				Case Else
					DicItemOfItem = item : Exit Function

			End Select
		ElseIf IsObject( item ) Then
			Set DicItemOfItem = item : Exit Function
		Else
			DicItemOfItem = item : Exit Function
		End If

		If ref_keys.Exists( item ) Then _
			Raise  E_NotFoundSymbol, "<ERROR msg=""循環参照しています"" key="""+ XmlAttr( DicKeyToCSV( ref_keys ) ) +"""/>"

		ref_keys.Item( item ) = True

		If not Dic.Exists( item ) Then _
			Raise  E_NotFoundSymbol, "<ERROR msg=""Not found symbol"" key="""+ XmlAttr( item ) +"""/>"

		Key = item
	Loop
End Function


 
'*************************************************************************
'  <<< [Dic_addNewObject] >>> 
'*************************************************************************
Function  Dic_addNewObject( Dic, ClassName, ObjectName, bDuplicate )
	GetDicItem  Dic, ObjectName, Dic_addNewObject  '//[out] Dic_addNewObject
	If IsEmpty( Dic_addNewObject ) Then
		Set Dic_addNewObject = new_X( ClassName )
		Set Dic.Item( ObjectName ) = Dic_addNewObject
		If g_Vers("CutPropertyM") Then
			Dic_addNewObject.Name = ObjectName
		Else
			Dic_addNewObject.m_Name = ObjectName
		End If
	ElseIf not bDuplicate Then
		Raise  E_AlreadyExist, "<ERROR msg='同じ名前のオブジェクトがあります' class='"&_
			ClassName & "' name='" & ObjectName & "'/>"
	End If
End Function


 
'***********************************************************************
'* Function: Dic_addInArrayItem
'***********************************************************************
Sub  Dic_addInArrayItem( ref_Dictionary, in_Key, in_Item )
	If ref_Dictionary.Exists( in_Key ) Then
		Set an_array = ref_Dictionary( in_Key )
	Else
		Set an_array = new ArrayClass
		Set ref_Dictionary( in_Key ) = an_array
	End If

	an_array.Add  in_Item
End Sub


 
'***********************************************************************
'* Function: Dic_addExInArrayItem
'***********************************************************************
Sub  Dic_addExInArrayItem( ref_Dictionary,  in_Key,  in_Item, _
		in_CompareFunction,  in_ParameterOfCompareFunction,  in_Option )

	Set c = g_VBS_Lib

	If ref_Dictionary.Exists( in_Key ) Then
		Set an_array = ref_Dictionary( in_Key )
		indexes = an_array.Search( in_Item,  in_CompareFunction,  in_ParameterOfCompareFunction,  Empty )
	Else
		indexes = Array( )
		Set an_array = new ArrayClass
		Set ref_Dictionary( in_Key ) = an_array
	End If

	If UBound( indexes ) = -1  or  in_Option = c.AddAlways Then
		is_add = True
		is_remove = False
	ElseIf in_Option = c.ReplaceIfExist Then
		is_add = True
		is_remove = True
	ElseIf in_Option = c.IgnoreIfExist Then
		is_add = False
		is_remove = False
	Else
		Error
	End If

	If is_remove Then
		an_array.RemoveByIndexes  indexes
	End If
	If is_add Then
		an_array.Add  in_Item
	End If
End Sub


 
'***********************************************************************
'* Function: Dic_removeInArrayItem
'***********************************************************************
Sub  Dic_removeInArrayItem( ref_Dictionary,  in_Key,  in_Item, _
		in_CompareFunction,  in_ParameterOfCompareFunction, _
		in_IsErrorIfNotFound,  in_IsMultiRemove )

	If ref_Dictionary.Exists( in_Key ) Then
		Set an_array = ref_Dictionary( in_Key )
		an_array.RemoveMatched  in_Item,  in_CompareFunction,  in_ParameterOfCompareFunction, _
			in_IsErrorIfNotFound,  in_IsMultiRemove

		If UBound( an_array.Items ) = -1 Then
			ref_Dictionary.Remove  in_Key
		End If
	Else
		If in_IsErrorIfNotFound Then _
			Err.Raise  E_NotFoundSymbol
	End If
End Sub


 
'***********************************************************************
'* Function: Dic_searchInArrayItem
'***********************************************************************
Function  Dic_searchInArrayItem( ref_Dictionary,  in_Key,  in_Item, _
		in_CompareFunction,  in_ParameterOfCompareFunction )

	If ref_Dictionary.Exists( in_Key ) Then
		Set an_array = ref_Dictionary( in_Key )

		ReDim  new_array( UBound( an_array.Items ) )
		k=0
		For i=0  To  UBound( new_array )
			If in_CompareFunction( an_array.Items(i), in_Item, in_ParameterOfCompareFunction ) = 0 Then
				new_array(k) = i
				k=k+1
			End If
		Next
		ReDim Preserve  new_array(k-1)
		Dic_searchInArrayItem = new_array
	Else
		Dic_searchInArrayItem = Array( )
	End If
End Function


 
'***********************************************************************
'* Function: Dic_getCountInArrayItem
'***********************************************************************
Function  Dic_getCountInArrayItem( ref_Dictionary )
	count = 0
	For Each  an_array  In  ref_Dictionary.Items
		count = count + an_array.Count
	Next
	Dic_getCountInArrayItem = count
End Function


 
'*************************************************************************
'  <<< [Dic_addElem] >>> 
'*************************************************************************
Sub  Dic_addElem( in_out_Dic, Key, Item )
	If IsEmpty( Item ) Then
		If in_out_Dic.Exists( Key ) Then _
			in_out_Dic.Remove  Key
	ElseIf IsObject( Item ) Then
		Set in_out_Dic.Item( Key ) = Item
	Else
		in_out_Dic.Item( Key ) = Item
	End If
End Sub


 
'***********************************************************************
'* Function: Dic_addElemOrError
'***********************************************************************
Sub  Dic_addElemOrError( ref_Dictionary,  in_KeyName,  in_AddingItem,  in_DictionaryName )
	If ref_Dictionary.Exists( in_KeyName ) Then
		Raise  E_Others, "<ERROR msg=""すでに登録済みです""  name="""+ in_KeyName +"""  in="""+ in_DictionaryName +"""/>"
	End If

	Dic_addElem  ref_Dictionary,  in_KeyName,  in_AddingItem
End Sub


 
'***********************************************************************
'* Function: Dic_addUniqueKeyItem
'***********************************************************************
Sub  Dic_addUniqueKeyItem( ref_Dictionary,  in_Key,  in_Item )
	If ref_Dictionary.Exists( in_Key ) Then
		Raise  E_AlreadyExist, "<ERROR msg=""Key is already exists"" key="""+ XmlAttr( in_Key ) +"""/>"
	End If
	Dic_addElem  ref_Dictionary,  in_Key,  in_Item
End Sub


 
'*************************************************************************
'  <<< [Dic_addPaths] >>> 
'*************************************************************************
Sub  Dic_addPaths( self, ByVal BasePath, StepPaths, Item )
	If BasePath <> "" Then
		If Right( BasePath, 1 ) <> "\" Then  BasePath = BasePath +"\"
	End If

	If IsObject( Item ) Then
		For Each  step_path  In StepPaths
			Set self( BasePath + step_path ) = Item
		Next
	Else
		For Each  step_path  In StepPaths
			self( BasePath + step_path ) = Item
		Next
	End If
End Sub


 
'*************************************************************************
'  <<< [DictionaryClass] >>> 
'*************************************************************************
Class  DictionaryClass
	Private  m_Dictionary
	Public   IsNotFoundSymbolError

	Private Sub  Class_Initialize()
		Set m_Dictionary = CreateObject( "Scripting.Dictionary" )
		Me.IsNotFoundSymbolError = True
	End Sub

	Public Default Property Get  Item( Key )
		If not m_Dictionary.Exists( Key ) Then
			If Me.IsNotFoundSymbolError Then  Err.Raise  9
		End If

		LetSet  Item, m_Dictionary( Key )
	End Property

	Public Sub  Add( Key, Item ) : m_Dictionary.Add  Key, Item : End Sub
	Public Property Get  Count() : Count = m_Dictionary.Count : End Property
	Public Property Get  Keys()  : Keys  = m_Dictionary.Keys  : End Property
	Public Property Let  Item( Key, NewItem ) : m_Dictionary( Key ) = NewItem : End Property
	Public Property Set  Item( Key, NewItem ) : Set  m_Dictionary( Key ) = NewItem : End Property
	Public Property Get  Items() : Items = m_Dictionary.Items : End Property
	Public Function  Exists( Key ) : Exists = m_Dictionary.Exists( Key ) : End Function
	Public Property Get  CompareMode() : CompareMode = m_Dictionary.CompareMode : End Property
	Public Property Let  CompareMode( x ) : m_Dictionary.CompareMode = x : End Property
	Public Sub  Remove( Key ) : m_Dictionary.Remove  Key : End Sub
	Public Sub  RemoveAll() : m_Dictionary.RemoveAll : End Sub
End Class


 
'********************************************************************************
'  <<< [FlatArray] >>> 
'********************************************************************************
Sub  FlatArray( out_FlatArray, NestedArray )
	count = 0
	For Each  a_item  In NestedArray
		If IsArray( a_item ) Then
			count = count + UBound( a_item ) + 1
		Else
			count = count + 1
		End If
	Next

	left_index = UBound( NestedArray )  '// Before "ReDim"
	right_index = count - 1

	If IsEmpty( out_FlatArray ) Then
		ReDim  out_FlatArray( count - 1 )
	Else
		ReDim Preserve  out_FlatArray( count - 1 )
	End If

	For left_index = left_index  To 0  Step -1
		If IsArray( NestedArray( left_index ) ) Then
			For child_index = UBound( NestedArray( left_index ) )  To 0  Step -1
				element = NestedArray( left_index )( child_index )
				out_FlatArray( right_index ) = element
					'// element は、out_FlatArray とNestedArray が同じ配列で
					'// left_index = right_index のときに発生するエラーを回避するため
				right_index = right_index - 1
			Next
		Else
			out_FlatArray( right_index ) = NestedArray( left_index )
			right_index = right_index - 1
		End If
	Next
End Sub


 
'********************************************************************************
'  <<< [LazyDictionaryClass] >>> 
'********************************************************************************
Class  LazyDictionaryClass
	Private  m_Dictionary
	Private  m_DictionaryFormula
	Public   IsNotFoundSymbolError
	Public   DebugMode  '// as Empty or True
	Public   ReadOnly   '// as True, False or Empty(False)
	Public   MaxExpandCount  '// as integer
	Public   Delegate  '// as Variant. User defined.

	Private Sub  Class_Initialize()
		Set m_Dictionary = CreateObject( "Scripting.Dictionary" )
		Set m_DictionaryFormula = CreateObject( "Scripting.Dictionary" )
		Me.IsNotFoundSymbolError = True
		Me.MaxExpandCount = 100
		g_Vers( "LazyDictionaryClass" ) = 2
	End Sub


	'// LazyDictionaryClass::Item
	Public Default Property Get  Item( in_Key )
		Item = in_Key

		expand_count = 0
		If Me.DebugMode Then
			echo_v  "<DictionaryEx operation=""Get"" key="""+ in_Key +""">"
		End If

		Do
			If not IsArray( Item ) Then
				Me_Expand  in_Key,  Item,  Empty,  expand_count  '//Set "Item"
			Else
				a_array = Item
				For index = 0  To UBound( a_array )
					Me_Expand  in_Key,  a_array( index ),  index,  expand_count
				Next
				FlatArray  Item, a_array
			End If

			If IsArray( Item ) Then
				is_loop = False
				For Each  a_item  In Item
					If InStr( a_item, "${" ) >= 1 Then
						is_loop = True
						Exit For
					End If
				Next
			Else
				is_loop = False
			End If

			If not is_loop Then  Exit Do
		Loop

		If Me.DebugMode Then
			echo_v  "</DictionaryEx>"
		End If
	End Property


	'// LazyDictionaryClass::Me_Expand
	Public Sub  Me_Expand( in_Key,  in_out_Item,  in_Index,  expand_count )
		sub_expand_count = 0
		Do
			start_pos = InStr( in_out_Item, "${" )
			If start_pos = 0 Then
				escape_pos = InStr( in_out_Item, "$\" )
				If escape_pos = 0 Then
					Exit Do
				End If
			End If

			If Me.DebugMode Then
				If sub_expand_count = 0 Then
					If not IsEmpty( in_Index ) Then
						echo_v  "<Item index="""& in_Index &""">"
					End If
				End If
			End If

			If start_pos > 0 Then
				last_pos = InStr( start_pos, in_out_Item, "}" )
				If last_pos = 0 Then
					Raise  1, "<ERROR msg=""値の ${ に対応する } がありません"" "+_
						"value="""+ in_out_Item +"""/>"
				End If

				start_pos = InStrRev( in_out_Item, "${", last_pos )
				child_key = Mid( in_out_Item,  start_pos,  last_pos - start_pos + 1 )
				If not m_Dictionary.Exists( child_key ) Then
					a_key = "%"+ Mid( child_key, 3, Len( child_key ) - 3 ) +"%"
					child_item = g_sh.ExpandEnvironmentStrings( a_key )
					If child_item <> a_key Then

					ElseIf StrCompHeadOf( child_key,  "${ToCSV(",  Empty ) = 0 Then
						child_item = Me_ParseToCSV( "${ToCSV(",  child_key )

					ElseIf InStr( 3, child_key, "(" ) >= 1 Then
						Me_Call  child_key,  child_item  '// Set "child_item"
					Else
						Raise  9, "<ERROR msg=""変数が定義されていません"" "+_
							"key="""+ child_key +"""/>"
					End If
				Else

					LetSet  child_item,  m_Dictionary( child_key )
				End If

				If IsObject( child_item ) Then
					Set in_out_Item = child_item
					Exit Sub
				End If

				expand_count = expand_count + 1
				sub_expand_count = sub_expand_count + 1
				If in_out_Item = child_key Then
					in_out_Item = child_item

					If Me.DebugMode Then
						If IsArray( in_out_Item ) Then
							echo_v  "<Expand count="""& expand_count &""">"+ _
								GetEchoStr( in_out_Item ) +"</Expand>"
						End If
					End If

					If IsNull( in_out_Item ) Then _
						in_out_Item = Empty
						'// Portable to standard dictionary

					If VarType( in_out_Item ) <> vbString Then _
						Exit Do
				Else
					in_out_Item = Replace( in_out_Item,  child_key,  child_item )
				End If

				If expand_count >= Me.MaxExpandCount Then
					Raise  1, "<ERROR msg=""循環参照しているかもしれません"" "+_
						"key="""+ in_Key +""" key2="""+ child_key +"""/>"
				End If

				If Me.DebugMode Then
					echo_v  "<Expand count="""& expand_count &""">"+ in_out_Item +"</Expand>"
				End If
			Else '// escape_pos > 0
				If IsNull( in_out_Item ) Then
					in_out_Item = Empty  '// Portable to standard dictionary
					Exit Do
				End If

				in_out_Item = Replace( in_out_Item, "$\", "$" )
				expand_count = expand_count + 1

				If Me.DebugMode Then
					echo_v  "<Expand count="""& expand_count &""">"+ in_out_Item +"</Expand>"
				End If
				Exit Do
			End If
		Loop

		If Me.DebugMode Then
			If not IsEmpty( in_Index ) Then
				If sub_expand_count = 0 Then
					echo_v  "<Item index="""& in_Index &""">"+ _
						GetEchoStr( in_out_Item ) +"</Item>"
				Else
					echo_v  "</Item>"
				End If
			End If
		End If
	End Sub


	'// LazyDictionaryClass::Me_ParseToCSV
	Private Function  Me_ParseToCSV( in_Head,  in_Key )
		parameter = Mid( in_Key,  Len( in_Head ) + 1 )
		CutLastOf  parameter, "}", Empty
		CutLastOf  parameter, " ", Empty
		CutLastOf  parameter, ")", Empty
		parameter = ArrayFromCSV( parameter )

		format_ = Me.Item( parameter(0) )
		start_  = parameter(1)
		last_   = parameter(2)
		If start_ <= last_ Then
			step_ = +1
		Else
			step_ = -1
		End If

		value_of_CSV = ""
		For  i = start_  To  last_  Step  step_
			value_of_CSV = value_of_CSV + sprintf( format_,  Array( i ) ) +", "
		Next

		Me_ParseToCSV = Left( value_of_CSV,  Len( value_of_CSV ) - 2 )
	End Function


	'// LazyDictionaryClass::Me_Call
	Private Sub  Me_Call( in_Key,  out_Item )
		position_of_parameter = InStr( 3,  in_Key,  "(" )
		a_function_name = Left( in_Key,  position_of_parameter ) +")}"
		If not m_Dictionary.Exists( a_function_name ) Then
			Raise  9, "<ERROR msg=""変数が定義されていません"" "+_
				"key="""+ in_Key +"""  or_key="""+ a_function_name +"""/>"
		End If

		Set a_function = m_Dictionary( a_function_name )

		parameter = Mid( in_Key,  position_of_parameter + 1 )
		CutLastOf  parameter, "}", Empty
		CutLastOf  parameter, " ", Empty
		CutLastOf  parameter, ")", Empty

		LetSet  out_Item,  a_function( Me,  a_function_name,  parameter )
	End Sub


	'// LazyDictionaryClass::Item  Let
	Public Property Let  Item( in_Key, in_NewItem )
		Me.CheckAsKey  in_Key
		If Me.DebugMode Then  Me.EchoSetForDebug  in_Key,  in_NewItem
		If Me.ReadOnly Then
			Me.Add  in_Key,  in_NewItem
		Else
			m_Dictionary( in_Key ) = in_NewItem
		End If
	End Property


	'// LazyDictionaryClass::Item  Set
	Public Property Set  Item( in_Key,  in_NewItem )
		Me.CheckAsKey  in_Key
		If Me.DebugMode Then  Me.EchoSetForDebug  in_Key,  in_NewItem
		If Me.ReadOnly Then
			Me.Add  in_Key,  in_NewItem
		Else
			Set  m_Dictionary( in_Key ) = in_NewItem
		End If
	End Property


	'// LazyDictionaryClass::Add
	Public Sub  Add( in_Key, in_Item )
		Me.CheckAsKey  in_Key
		If Me.DebugMode Then  Me.EchoSetForDebug  in_Key,  in_Item
		m_Dictionary.Add  in_Key,  in_Item
	End Sub


	'// LazyDictionaryClass::AddDictionary
	Public Sub  AddDictionary( in_Dictionary )
		in_Dictionary.AddDictionary_Sub  m_Dictionary,  m_DictionaryFormula
	End Sub
	Public Sub  AddDictionary_Sub( ref_TargetDictionary,  ref_TargetDictionaryFormula )
		For Each  key  In  m_Dictionary.Keys
			ref_TargetDictionary( key ) = m_Dictionary( key )
		Next
		For Each  key  In  m_DictionaryFormula.Keys
			Set ref_TargetDictionaryFormula( key ) = m_DictionaryFormula( key )
		Next
	End Sub


	'// LazyDictionaryClass::Formula
	Public Property Get  Formula( in_Key )
		If not m_Dictionary.Exists( in_Key ) Then
			If Me.IsNotFoundSymbolError Then _
				Err.Raise  9
		End If

		If m_DictionaryFormula.Exists( in_Key ) Then
			LetSet  Formula,  m_DictionaryFormula( in_Key ).Name
		Else
			LetSet  Formula,  m_Dictionary( in_Key )
		End If
	End Property


	'// LazyDictionaryClass::Type_
	Public Property Get  Type_( in_Key )
		If not m_Dictionary.Exists( in_Key ) Then
			If Me.IsNotFoundSymbolError Then _
				Err.Raise  9
		End If

		If m_DictionaryFormula.Exists( in_Key ) Then
			LetSet  Type_,  m_DictionaryFormula( in_Key ).Delegate
		Else
			Type_ = ""
		End If
	End Property


	'// LazyDictionaryClass::EachFormula
	Public Function  EachFormula( in_Template,  in_VariableName,  in_Array )
		m_EachFormula  in_Template,  in_VariableName,  in_Array,  EachFormula
	End Function

	Public Sub  m_EachFormula( in_Template,  in_VariableName,  in_Array,  out_Array )
		ReDim  out_Array( UBound( in_Array ) )
		For index = 0  To UBound( in_Array )
			out_Array( index ) = Replace( in_Template,  in_VariableName,  in_Array( index ) )
		Next
	End Sub


	'// LazyDictionaryClass::Each_
	Public Function  Each_( in_Template,  in_VariableName,  in_Array )
		m_EachFormula  in_Template,  in_VariableName,  in_Array, formulas
		m_EachEvaluate  formulas, Each_
	End Function

	Public Sub  m_EachEvaluate( in_Formulas,  out_Array )
		ReDim  out_Array( UBound( in_Formulas ) )
		For index = 0  To UBound( in_Formulas )
			out_Array( index ) = Me.Item( in_Formulas( index ) )
		Next
	End Sub


	'// LazyDictionaryClass::IsKeyOnly
	Public Function  IsKeyOnly( in_Key )
		IsKeyOnly = Left( in_Key, 2 ) = "${"  and  Right( in_Key, 1 ) = "}"  and  InStr( 3, in_Key, "${" ) = 0
	End Function

	Public Sub  CheckAsKey( in_Key )
		If not Me.IsKeyOnly( in_Key ) Then
			Raise  1, "<ERROR msg=""キー名は、${ から始まり、} で終わるようにしてください。"" "+_
				"key="""+ in_Key +"""/>"
		End If
	End Sub


	'// LazyDictionaryClass::EvaluateReverse
	Public Function  EvaluateReverse( ByVal in_Text )
		Me_GetWordPairArray  word_pair_array
		Me_EvaluateReverse_Replace  in_Text, word_pair_array
		EvaluateReverse = in_Text
	End Function

	Private Sub  Me_GetWordPairArray( out_WordPairArray )
		Redim  out_WordPairArray( m_Dictionary.Count - 1 )
		i = 0
		For Each  a_name  In m_Dictionary.Keys
			Set word_pair = new NameOnlyClass
			word_pair.Name = m_Dictionary( a_name )
			word_pair.Delegate = a_name

			Set out_WordPairArray( i ) = word_pair
			i = i + 1
		Next
		ShakerSort  out_WordPairArray, 0, UBound( out_WordPairArray ), _
			GetRef("CompareByNameLength"), -1
	End Sub

	Private Sub  Me_EvaluateReverse_Replace( in_out_Text, in_WordPairArray )
		For i=0 To  UBound( in_WordPairArray )
			Set word_pair = in_WordPairArray(i)
			in_out_Text = Replace( in_out_Text,  word_pair.Name,  word_pair.Delegate )
		Next
	End Sub


	'// LazyDictionaryClass::GetStepPath
	Public Function  GetStepPath( in_Path, in_BaseFullPath )
		Me_GetWordPairArray  word_pair_array

		is_root_replaced = False
		text = in_Path
		For i=0 To  UBound( word_pair_array )
			Set word_pair = word_pair_array(i)
			If StrCompHeadOf( text, word_pair.Name, Empty ) = 0 Then
				text = word_pair.Delegate + Mid( text, Len( word_pair.Name ) + 1 )
				is_root_replaced = True
				Exit For
			End If
		Next

		If not is_root_replaced Then
			text = Global_GetStepPath( text, in_BaseFullPath )
		End If
		Me_EvaluateReverse_Replace  text, word_pair_array
		GetStepPath = text
	End Function


	'// LazyDictionaryClass::GetFullPath
	Public Function  GetFullPath( in_Path, in_BaseFullPath )
		GetFullPath = Global_GetFullPath( Me.Item( in_Path ),  Me.Item( in_BaseFullPath ) )
	End Function


	'// LazyDictionaryClass  Others
	Public Sub  EchoSetForDebug( in_Key,  in_NewItem )
		echo_v  "<DictionaryEx operation=""Set"" key="""+ in_Key +""">"+ GetEchoStr( in_NewItem ) +_
			"</DictionaryEx>"
	End Sub


	Public Sub  AppendFromVariableXML( in_XML_Element,  in_BaseFullPath,  ref_DuplicateChecker )
		name   = in_XML_Element.getAttribute( "name" )
		value  = in_XML_Element.getAttribute( "value" )
		type__ = in_XML_Element.getAttribute( "type" )
		If IsEmpty( ref_DuplicateChecker ) Then
			is_exist = m_Dictionary.Exists( name )
		Else
			is_exist = ref_DuplicateChecker.Exists( name )
			ref_DuplicateChecker( name ) = True
		End If
		If is_exist Then _
			echo_v  "<WARNING msg=""すでに定義されています。"" name="""+ name +"""/>"

		If IsNull( type__ ) Then

			Me.Item( name ) = value

		ElseIf type__ = "FullPathType" Then
			Set attributes = new_NameOnlyClass( value,  type__ )

			Me.Item( name ) = Global_GetFullPath( value,  in_BaseFullPath )
			Set m_DictionaryFormula( name ) = attributes
		End If
	End Sub


	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( in_Level )
		xml_sub = GetTab( in_Level )+ "<"+TypeName(Me)+">"+ vbCRLF
		xml_sub = xml_sub + Me.GetSetListString( Level )
		xml_sub = xml_sub + GetTab( in_Level ) +"</"+TypeName(Me)+">"+ vbCRLF
	End Function

	Public Function  GetSetListString( in_Level )
		a_str = ""
		For Each key In m_Dictionary.Keys
			source_item = m_Dictionary( key )
			If VarType( source_item ) = vbString Then
				a_str = a_str + GetTab( in_Level ) + key +" = """+ source_item +""""
				If InStr( source_item, "${" ) > 0 Then
					If VarType( Me.Item( key ) ) = vbString Then
						a_str = a_str +" = """+ Me.Item( key ) +""""
					Else
						a_str = a_str +" = "+ GetEchoStr( Me.Item( key ) )
					End If
				End If
				a_str = a_str + vbCRLF
			Else
				a_str = a_str + GetTab( in_Level ) + key +" = "+ GetEchoStr( source_item ) + vbCRLF
			End If
		Next
		GetSetListString = a_str
	End Function

	Public Sub  EchoToEditor()
		Set ec = new EchoOff
		path = GetTempPath( "LazyDictionaryEcho_*.txt" )
		CreateFile  path,  Me.GetSetListString( 0 )
		ec = Empty
		start  GetEditorCmdLine( path )
	End Sub


	Public Property Get  Count() : Count = m_Dictionary.Count : End Property
	Public Property Get  Keys()  : Keys  = m_Dictionary.Keys  : End Property
	Public Property Get  Items() : Items = m_Dictionary.Items : End Property
	Public Function  Exists( in_Key ) : Exists = m_Dictionary.Exists( in_Key ) : End Function
	Public Property Get  CompareMode() : CompareMode = m_Dictionary.CompareMode : End Property
	Public Property Let  CompareMode( x ) : m_Dictionary.CompareMode = x : End Property
	Public Sub  Remove( in_Key )
		If m_Dictionary.Exists( in_Key ) Then  m_Dictionary.Remove  in_Key
	End Sub
	Public Sub  RemoveAll() : m_Dictionary.RemoveAll : End Sub
End Class

Function  Global_GetStepPath( in_Path, in_BaseFullPath )
	Global_GetStepPath = GetStepPath( in_Path, in_BaseFullPath )
End Function

Function  Global_GetFullPath( in_Path, in_BaseFullPath )
	Global_GetFullPath = GetFullPath( in_Path, in_BaseFullPath )
End Function


 
'***********************************************************************
'* Function: LoadVariableInXML
'***********************************************************************
Function  LoadVariableInXML( in_RootXML_Element,  in_FilePathOfXML )
	base_path = GetParentFullPath( GetFilePathString( in_FilePathOfXML ) )
	If TryStart(e) Then  On Error Resume Next

		Set LoadVariableInXML = LoadVariableInXML_Sub( _
			in_RootXML_Element,  base_path )

	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then
		e.OverRaise  e.Number,  AppendErrorMessage( e.Description, _
			"msg2=""Variable tag""  in="""+ in_FilePathOfXML +"""" )
	End If
End Function


 
'***********************************************************************
'* Function: LoadVariableInXML_Sub
'*    This is private funcion.
'***********************************************************************
Function  LoadVariableInXML_Sub( in_RootXML_Element,  in_BaseFullPath )
	Assert  TypeName( in_RootXML_Element ) = "IXMLDOMElement"
	Set variables = new LazyDictionaryClass

	For Each  variable_tag  In  in_RootXML_Element.selectNodes( ".//Variable" )
		variables.AppendFromVariableXML  variable_tag,  in_BaseFullPath,  Empty
	Next

	Set LoadVariableInXML_Sub = variables
End Function


 
'***********************************************************************
'* Function: LoadLocalVariableInXML
'***********************************************************************
Function  LoadLocalVariableInXML( in_CurrentXML_Element,  in_GlobalVariables,  in_FilePathOfXML )
	base_path = GetParentFullPath( in_FilePathOfXML )
	If TryStart(e) Then  On Error Resume Next

		Set LoadLocalVariableInXML = LoadLocalVariableInXML_Sub( _
			in_CurrentXML_Element,  in_GlobalVariables,  base_path )

	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then
		e.OverRaise  e.Number,  AppendErrorMessage( e.Description, _
			"msg2=""LocalVariable tag""  in="""+ in_FilePathOfXML +"""" )
	End If
End Function


 
'***********************************************************************
'* Function: LoadLocalVariableInXML_Sub
'*    This is private funcion.
'***********************************************************************
Function  LoadLocalVariableInXML_Sub( in_CurrentXML_Element,  in_GlobalVariables,  in_BaseFullPath )
	Set variables = new LazyDictionaryClass

	variables.AddDictionary  in_GlobalVariables

	If in_CurrentXML_Element is Nothing Then
		Set LoadLocalVariableInXML_Sub = variables
		Exit Function
	End If
	Assert  TypeName( in_CurrentXML_Element ) = "IXMLDOMElement"
	Set parent_tag = in_CurrentXML_Element.parentNode
	Set parent_tags = new ArrayClass

	Do While  parent_tag.nodeTypeString <> "document"
		parent_tags.Add  parent_tag
		Set parent_tag = parent_tag.parentNode
	Loop
	ReverseObjectArray  parent_tags.Items,  parent_tags

	For Each  parent_tag  In  parent_tags
		Set duplicate_checker = CreateObject( "Scripting.Dictionary" )
		For Each  variable_tag  In  parent_tag.SelectNodes( "./LocalVariable" )

			variables.AppendFromVariableXML  variable_tag,  in_BaseFullPath,  duplicate_checker
		Next
	Next

	Set LoadLocalVariableInXML_Sub = variables
End Function


 
'*************************************************************************
'  <<< [new_LazyDictionaryClass] >>> 
'*************************************************************************
Function  new_LazyDictionaryClass( ByVal RootXML_Element )
ThisIsOldSpec
	If TypeName( RootXML_Element ) = "FilePathClass" Then
		file_path = RootXML_Element.FilePath
		base_path = GetParentFullPath( file_path )
		Set RootXML_Element = RootXML_Element.Text
	End If


	If TryStart(e) Then  On Error Resume Next

		Set new_LazyDictionaryClass = LoadVariableInXML_Sub( RootXML_Element,  base_path )

	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then
		If not IsEmpty( file_path ) Then
			If Right( e.Description, 2 ) = "/>" Then
				message = Left( e.Description,  Len( e.Description ) - 2 ) + _
					" msg2=""Variable tag"" path="""+ file_path +"""/>"
				e.OverRaise  e.Number, message
			Else
				e.Raise
			End If
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [GetPathLazyDictionary] >>> 
'*************************************************************************
Dim  g_PathLazyDictionary

Function  GetPathLazyDictionary()
	If IsEmpty( g_PathLazyDictionary ) Then
		Set g_PathLazyDictionary = new LazyDictionaryClass

		Dim  path : path = g_vbslib_folder : CutLastOf  path, "\", Empty
		g_PathLazyDictionary("${scriptlib}") = path

		If WScript.ScriptName = "vbslib Prompt.vbs" Then
			g_PathLazyDictionary("${vbslib}") = g_fs.GetParentFolderName( g_vbslib_folder )
		End If
	End If
	Set GetPathLazyDictionary = g_PathLazyDictionary
End Function


 
'*************************************************************************
'  <<< [ObjectSetClass] >>> 
'*************************************************************************
Class  ObjectSetClass
	Public   Objects
	Private  m_NextID

	Private Sub  Class_Initialize()
		Set Me.Objects = CreateObject( "Scripting.Dictionary" )
		m_NextID = 0
	End Sub

	Public Sub  Add( Object )
		If Me.Exists( Object ) Then  Exit Sub

		Do
			m_NextID = m_NextID + 1
			If not Objects.Exists( CStr( m_NextID ) ) Then _
				Exit Do
		Loop
		Set Me.Objects( CStr( m_NextID ) ) = Object
	End Sub

	Function  Exists( Object )
		Exists = True
		For Each  item  In Me.Objects.Items
			If item is Object Then  Exit Function
		Next
		Exists = False
	End Function

	Public Sub  Remove( Object )
		For Each  key  In Me.Objects.Keys
			If Objects( key ) is Object Then
				Me.Objects.Remove  key
				Exit Sub
			End If
		Next
	End Sub

	Property Get  Count() : Count = Me.Objects.Count : End Property
	Property Get  Items() : Items = Me.Objects.Items : End Property
	Public Sub  RemoveAll() : Me.Objects.RemoveAll : End Sub
End Class


 
'***********************************************************************
'* Variable: g_ObjectIDs
'*
'* Example:
'*     > Me.ObjectID = g_ObjectIDs.Add( Me )
'*     > g_ObjectIDs.Remove  Me.ObjectID
'*     > Set object = g_ObjectIDs( other.ObjectID )
'***********************************************************************
Dim  g_ObjectIDs
Set  g_ObjectIDs = new ObjectIDsClass


 
'***********************************************************************
'* Class: ObjectIDsClass
'***********************************************************************
Class  ObjectIDsClass

	Public  Objects
	Public  PreviousAddedID


	Private Sub  Class_Initialize()
		Set Me.Objects = CreateObject( "Scripting.Dictionary" )
		Me.PreviousAddedID = 0
	End Sub


Public Default Property Get  Item( i )
	Set Item = Me.Objects( i )
End Property


Public Function  Add( in_Object )
	Const  max_count = &h7FFE
	Assert  Me.Objects.Count < max_count

	Do
		Me.PreviousAddedID = Me.PreviousAddedID + 1
		If not Me.Objects.Exists( Me.PreviousAddedID ) Then _
			Exit Do
	Loop
	If Me.PreviousAddedID > max_count  or  Me.PreviousAddedID < 1 Then _
		Me.PreviousAddedID = 0

	Set Me.Objects( Me.PreviousAddedID ) = in_Object

	Add = Me.PreviousAddedID
End Function


Public Sub  Remove( in_ObjectID )
	Me.Objects.Remove  in_ObjectID
End Sub


End Class


 
'*************************************************************************
'  <<< [LifeGroupCounterClass] >>> 
'*************************************************************************
Class  LifeGroupCounterClass
    Public  Group
    Public  CreatedMemberID
    Public  ReferenceCount
End Class


 
'*************************************************************************
'  <<< [LifeHandleClass] >>> 
'*************************************************************************
Class  LifeHandleClass
	Public  p  '// Target object of this handle

	Private Sub  Class_Terminate()
		If not IsEmpty( Me.p.LifeGroup.Group ) Then _
			Me.p.LifeGroup.Group.AddTerminated  Me.p
	End Sub
End Class


 
'*************************************************************************
'  <<< [LifeGroupClass] >>> 
'*************************************************************************
Class  LifeGroupClass
	Public   Name
	Public   Objects
	Public   TerminatedObjects
	Private  m_CreatedMemberID

	Private Sub  Class_Initialize()
		Set Me.Objects = CreateObject( "Scripting.Dictionary" )
		Set Me.TerminatedObjects = CreateObject( "Scripting.Dictionary" )
		m_CreatedMemberID = 0
	End Sub

	Public Sub  AddHandle( Handle, Object )
		If IsEmpty( Object.LifeGroup ) Then _
			Set Object.LifeGroup = new LifeGroupCounterClass

		If not IsEmpty( Object.LifeGroup.Group ) Then
			If not Object.LifeGroup.Group Is Me Then
				Err.Raise  1, "すでに別の LifeGroup に所属しているようです"
			End If

			If Object.LifeGroup.ReferenceCount = 0 Then
				Me.TerminatedObjects.Remove  Object.LifeGroup.CreatedMemberID
			End If
			Object.LifeGroup.ReferenceCount = Object.LifeGroup.ReferenceCount + 1
		Else
			Do
				m_CreatedMemberID = m_CreatedMemberID + 1
				If not Objects.Exists( m_CreatedMemberID ) Then _
					Exit Do
			Loop

			Set Me.Objects( m_CreatedMemberID ) = Object
			Set Object.LifeGroup.Group = Me

			Object.LifeGroup.CreatedMemberID = m_CreatedMemberID
			Object.LifeGroup.ReferenceCount = 1
		End If

		Set Handle.p = Object
	End Sub

	Public Function  Add( Object )
		Set Add = new LifeHandleClass
		Me.AddHandle  Add, Object
	End Function

	Public Sub  Remove( Object )
		If not Object.LifeGroup.Group Is Me Then  Exit Sub
		If not Me.Objects( Object.LifeGroup.CreatedMemberID ) Is Object Then  Exit Sub

		Object.DestroyReferences

		Me.Objects.Remove  Object.LifeGroup.CreatedMemberID
		Object.LifeGroup.Group = Empty
		Object.LifeGroup.CreatedMemberID = Empty
	End Sub

	Public Sub  AddTerminated( Object )
		If not Object.LifeGroup.Group Is Me Then  Exit Sub
		If not Me.Objects( Object.LifeGroup.CreatedMemberID ) Is Object Then  Exit Sub

		Object.LifeGroup.ReferenceCount = Object.LifeGroup.ReferenceCount - 1

		If Object.LifeGroup.ReferenceCount = 0 Then
			Set Me.TerminatedObjects( Object.LifeGroup.CreatedMemberID ) = Object

			If Me.TerminatedObjects.Count = Me.Objects.Count Then
				For Each  a_object  In Me.Objects.Items
					a_object.DestroyReferences
					a_object.LifeGroup = Empty
				Next
				Me.Objects.RemoveAll
				Me.TerminatedObjects.RemoveAll
			End If
		End If
	End Sub
End Class


 
'*************************************************************************
'  <<< [DestroyerClass] >>> 
'*************************************************************************
Class  DestroyerClass
	Public  Objects

	Private Sub  Class_Initialize()
		Set Me.Objects = new ObjectSetClass
	End Sub

	Private Sub  Class_Terminate()
		For Each  item  In Me.Objects.Objects.Items
			item.DestroyReferences
		Next
	End Sub

	Public Sub  Add( Object )
		Me.Objects.Add  Object
		Object.IsDestroyer = True
	End Sub

	Public Sub  Remove( Object )
		Me.Objects.Remove  Object
		Object.IsDestroyer = False
	End Sub
End Class


 
'*************************************************************************
'  <<< [CheckUnderDestroyer] >>> 
'*************************************************************************
Sub  CheckUnderDestroyer( Object )
	If not Object.IsDestroyer Then _
		Err.Raise 1,, "このオブジェクトは相互参照しているため、DestroyerClass の管理下に置く必要があります。"
End Sub


 
'*************************************************************************
'  <<< [DicTable] >>> 
'*************************************************************************
Function  DicTable( DataArray )
	Dim  i,  i_start,  i_over,  column_length,  dic,  arr

	Set arr = new ArrayClass


	'//=== column_length
	column_length = 0
	Do
		If IsEmpty( DataArray( column_length ) ) Then  Exit Do
		column_length = column_length + 1
	Loop
	If column_length = 0 Then  Error


	'//=== make dictionary
	i = column_length + 1
	While i <= UBound( DataArray )

		Set dic = CreateObject( "Scripting.Dictionary" )
		i_start = i
		i_over  = i + column_length
		While  i < i_over
			LetSetWithBracket  dic,  DataArray( i - i_start ),  DataArray( i )
			i = i + 1
		WEnd

		arr.Add  dic
	WEnd

	DicTable = arr.Items
End Function


 
'*************************************************************************
'  <<< [JoinDicTable] >>> 
'*************************************************************************
Function  JoinDicTable( DicTable1, KeyField, DicTable2 )
	Dim  row_num1,  row_num2,  row1,  row2,  key_value,  field,  table2
	Dim  nums2 : Set nums2 = CreateObject( "Scripting.Dictionary" )
	Dim  ret_table : Set ret_table = new ArrayClass


	'//=== make table2 from DicTable2
	If VarType( DicTable2(0) ) = vbString Then
		table2 = DicTable( DicTable2 )
	Else
		table2 = DicTable2
	End If


	'//=== nums2
	For row_num2 = 0  To UBound( table2 )
		Set row2 = table2( row_num2 )
		If row2.Exists( KeyField ) Then
			key_value = row2.Item( KeyField )
			If not IsEmpty( key_value ) Then _
				nums2( key_value ) = row_num2
		End If
	Next


	'//=== row1 LEFT JOIN row2 WHERE row1.KeyField = row2.KeyField
	For row_num1 = 0  To UBound( DicTable1 )
		If DicTable1( row_num1 ).Exists( KeyField ) Then

			'//=== if key_value
			Set row1 = DicTable1( row_num1 )
			key_value = row1( KeyField )
			If not IsEmpty( key_value ) Then

				'//=== init row1
				Set row1 = CreateObject( "Scripting.Dictionary" )
				Dic_add  row1, DicTable1( row_num1 )

				'//=== row2
				If nums2.Exists( key_value ) Then
					Set row2 = table2( nums2( key_value ) )

					'//=== JOIN
					Dic_add  row1, row2

					nums2( key_value ) = -1
				End If

				ret_table.Add  row1
			End If
		End If
	Next


	'//=== row1 RIGHT? JOIN row2 WHERE row1.KeyField = row2.KeyField
	For Each row_num2  In nums2.Items
		If row_num2 >= 0 Then
			Set row1 = CreateObject( "Scripting.Dictionary" )
			Dic_add  row1, table2( row_num2 )
			ret_table.Add  row1
		End If
	Next

	JoinDicTable = ret_table.Items
End Function


 
'*************************************************************************
'  <<< [Dic_add] >>> 
'*************************************************************************
Sub  Dic_add( in_out_Dic, PlusDic )
	If IsEmpty( in_out_Dic ) Then _
		Set in_out_Dic = CreateObject( "Scripting.Dictionary" )
	For Each key  In PlusDic.Keys
		Dic_addElem  in_out_Dic, key, PlusDic.Item( key )
	Next
End Sub


 
'*************************************************************************
'  <<< [Dic_sub] >>> 
'*************************************************************************
Sub  Dic_sub( out_Dic, WholeDic, BaseDic, CompareFunc, CompareFuncParam )
	Dim  key, whole_item

	If IsEmpty( out_Dic ) Then
		Set out_Dic = CreateObject( "Scripting.Dictionary" )
	Else
		out_Dic.RemoveAll
	End If

	If IsEmpty( CompareFunc ) Then  Set CompareFunc = GetRef( "StdCompare" )

	For Each key  In WholeDic.Keys
		GetDicItem  WholeDic, key, whole_item  '//[out] whole_item
		If BaseDic.Exists( key ) Then
			If CompareFunc( whole_item, BaseDic.Item( key ), CompareFuncParam ) <> 0 Then
				Dic_addElem  out_Dic, key, whole_item
			End If
		Else
			Dic_addElem  out_Dic, key, whole_item
		End If
	Next

	For Each key  In BaseDic.Keys
		If not WholeDic.Exists( key ) Then _
			out_Dic( key ) = Empty
	Next
End Sub


 
'*************************************************************************
'  <<< [Dic_searchParent] >>> 
'*************************************************************************
Function  Dic_searchParent( in_Dictionay, in_BasePath, in_Path )

	If IsFullPath( in_Path ) Then
		input_full_path = in_Path
		separator = GetFilePathSeparator( in_Path )
	Else
		input_full_path = GetFullPath( in_Path, in_BasePath )
		separator = GetFilePathSeparator( in_BasePath )
	End If

	matched_length_max = 0
	For Each  key  In in_Dictionay.Keys
		If InStr( 1, input_full_path, key, 1 ) > 0 Then
			If IsFullPath( key ) Then
				If Right( key, 1 ) = separator Then
					full_key = key
				Else
					full_key = key + separator
				End If
			Else
				full_key = GetFullPath( key, in_BasePath ) + separator
			End If
			If StrCompHeadOf( input_full_path, full_key, Empty ) = 0 Then
				matched_length = Len( full_key )
				If matched_length > matched_length_max Then
					matched_length_max = matched_length
					Dic_searchParent = key
				End If
			End If
		End If
	Next
End Function


 
'*************************************************************************
'  <<< [Dic_searchChildren] >>> 
'*************************************************************************
Function  Dic_searchChildren( in_Dictionay, in_BasePath, in_Path, out_PathArray, in_Option )

	If IsFullPath( in_Path ) Then
		separator = GetFilePathSeparator( in_Path )
		input_full_path = in_Path + separator
	Else
		separator = GetFilePathSeparator( in_BasePath )
		input_full_path = GetFullPath( in_Path, in_BasePath ) + separator
	End If

	ReDim  out_PathArray( in_Dictionay.Count )
	count = 0

	For Each  key  In in_Dictionay.Keys
		If InStr( 1, key, in_Path, 1 ) > 0 Then
			If IsFullPath( key ) Then
				full_key = key
			Else
				full_key = GetFullPath( key, in_BasePath )
			End If
			If StrCompHeadOf( full_key, input_full_path, Empty ) = 0 Then
				out_PathArray( count ) = key
				count = count + 1
			End If
		End If
	Next

	ReDim Preserve  out_PathArray( count - 1 )
End Function


 
'*************************************************************************
'  <<< [IsSameDictionary] >>> 
'*************************************************************************
Function  IsSameDictionary( DicA, DicB, Option_ )
	Set c = g_VBS_Lib
	IsSameDictionary = True

	If ( Option_ and c.CompareOnlyExistB ) = 0 Then
		If DicA.Count <> DicB.Count Then
			IsSameDictionary = False
			If Option_ and c.StopIsNotSame Then  Stop
			Exit Function
		End If
	End If

	For Each  key  In DicB.Keys
		If not DicA.Exists( key ) Then
			IsSameDictionary = False
			If Option_ and c.StopIsNotSame Then  Stop
		ElseIf DicA( key ) <> DicB( key ) Then
			IsSameDictionary = False
			If Option_ and c.StopIsNotSame Then  Stop
		End If
	Next
End Function


 
'*************************************************************************
'  <<< [DicToArr] >>> 
'*************************************************************************
Sub  DicToArr( Dic, Arr )
	Dim  keys : keys = Dic.Keys()
	Dim  key, i

	ReDim  Arr( UBound( keys ) )
	i = 0
	For Each key in keys
		Set Arr(i) = new DicElem : ErrCheck
		Arr(i).m_Key = key
		If IsObject( Dic.Item(key) ) Then
			Set Arr(i).m_Item = Dic.Item(key)
		Else
			Arr(i).m_Item = Dic.Item(key)
		End If
		i=i+1
	Next
End Sub

Class  DicElem
	Public  Key
	Public  Item
	Public Property Get  m_Key()  : m_Key  = Key  : End Property
	Public Property Let  m_Key(x) : Key    = x    : End Property
	Public Property Get  m_Item() : m_Item = Item : End Property
	Public Property Let  m_Item(x): Item   = x    : End Property
	Public Property Set  m_Item(x): Set Item = x  : End Property
	Public Property Get  Name()   : Name   = Key  : End Property
	Public Property Let  Name(x)  : Key    = x    : End Property
	Public Property Get  m_Name() : m_Name = Key  : End Property
	Public Property Let  m_Name(x): Key    = x    : End Property
	Public Sub  Init( a_Key, a_Item )
		Key = a_Key
		If IsObject( a_Item ) Then  Set Item = a_Item  Else  Item = a_Item
	End Sub
	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		xml_sub = GetTab(Level)+ "<"+TypeName(Me)+">"""+ Key +""" : "+ GetEchoStr( Item ) +"</"+TypeName(Me)+">"+ vbCRLF
	End Function
End Class

Function  DicElemCompare( Left, Right, Param )
	DicElemCompare = PathCompare( Left.m_Key, Right.m_Key, Empty )
End Function


 
'*************************************************************************
'  <<< [DicKeyToArr] >>> 
'*************************************************************************
Sub  DicKeyToArr( Dic, out_Array )
	Dim  keys : keys = Dic.Keys()
	Dim  key, i

	ReDim  out_Array( UBound( keys ) )
	i = 0
	For Each key in keys
		out_Array(i) = key
		i=i+1
	Next
End Sub


 
'*************************************************************************
'  <<< [DicItemToArr] >>> 
'*************************************************************************
Sub  DicItemToArr( Dic, Arr )
	Dim  keys : keys = Dic.Keys()
	Dim  key, i

	ReDim  Arr( UBound( keys ) )
	i = 0
	For Each key in keys
		If IsObject( Dic.Item(key) ) Then
			Set Arr(i) = Dic.Item(key)
		Else
			Arr(i) = dic.Item(key)
		End If
		i=i+1
	Next
End Sub


 
'*************************************************************************
'  <<< [DicElemArrayKeyToArr] >>> 
'*************************************************************************
Sub  DicElemArrayKeyToArr( a_DicElemArray, out_Array )
	ReDim  out_Array( UBound( a_DicElemArray ) )

	For index = 0  To UBound( a_DicElemArray )
		out_Array( index ) = a_DicElemArray( index ).Key
	Next
End Sub


 
'*************************************************************************
'  <<< [DicKeyToCSV] >>> 
'*************************************************************************
Function  DicKeyToCSV( Dic )
	Dim  key

	DicKeyToCSV = ""
	For Each key  In Dic.Keys
		If DicKeyToCSV <> "" Then  DicKeyToCSV = DicKeyToCSV + ","
		DicKeyToCSV = DicKeyToCSV + key
	Next
End Function

 
'*************************************************************************
'  <<< [Dictionary_xml_sub] >>> 
'*************************************************************************
Function  Dictionary_xml_sub( m, Level )
	Dim  key, s, ss

	s = GetTab( Level )+ "<Dictionary count="""& m.Count &""">{" +vbCRLF
	For Each key  In  m.Keys
		ss = Trim( GetEchoStr_sub( m.Item( key ), Level+1 ) )
		CutLastOf  ss, vbCRLF, Empty
		ss = CSVText( ss )
		If Left( ss, 1 ) <> """"  and _
				( VarType( m.Item( key ) ) = vbString  or  IsObject( m.Item( key ) ) ) Then _
			ss = """"+ ss +""""

		s = s +GetTab( Level+1 )+""""+ key +""" : " + ss +","+ vbCRLF
	Next
	s = s + GetTab( Level )+ "}</Dictionary>" +vbCRLF
	Dictionary_xml_sub = s
End Function


 
'*************************************************************************
'  <<< [CopyArr] >>> 
'*************************************************************************
Sub  CopyArr( Dst, Src )
	If g_cut_old Then Stop  ' Do not Dim a().  Dim a,b : b = Array( 1, 2 ) : a = b

	If IsArray( Src ) Then
		Dim  i

		ReDim  Dst( UBound( Src ) )
		For i=UBound( Src ) To 0 Step -1
			If IsObject( Src(i) ) Then  Set Dst(i) = Src(i)  Else  Dst(i) = Src(i)
		Next
	Else
		ReDim  Dst(0)
		If IsObject( Src ) Then  Set Dst(0) = Src  Else  Dst(0) = Src
	End If
End Sub


 
'********************************************************************************
'  <<< [Add] >>> 
'********************************************************************************
Function  Add( Operand1, Operand2 )
	If IsArray( Operand1 )  and  IsArray( Operand2 ) Then
		ReDim  a_array( UBound( Operand1 ) + UBound( Operand2 ) + 1 )

		For index = 0  To UBound( Operand1 )
			a_array( index ) = Operand1( index )
		Next
		count1 = UBound( Operand1 ) + 1
		For index = 0  To UBound( Operand2 )
			a_array( index + count1 ) = Operand2( index )
		Next
		Add = a_array
	Else
		Add = Operand1 + Operand2
	End If
End Function


 
'*************************************************************************
'  <<< [new_EmptyArray] >>> 
'*************************************************************************
Function  new_EmptyArray( in_UBound )
	ReDim  arr( in_UBound )
	new_EmptyArray = arr
End Function


 
'*************************************************************************
'  <<< [AddArrElem] >>> 
'*************************************************************************
Sub  AddArrElem( Dst, Src )
	AddArrElemEx  Dst, Src, False
End Sub


 
'*************************************************************************
'  <<< [AddArrElemEx] >>> 
'*************************************************************************
Function  AddArrElemEx( Dst, Src, IsReturn )
	If TypeName( Dst ) = "Dictionary" Then
		Dim  key, obj

		If IsArray( Src ) Then
			For Each obj  In Src : If not IsEmpty( obj ) Then
				If IsObject( obj ) Then  Set Dst.Item( obj.Name ) = obj  Else  Dst.Item( obj ) = True
			End If : Next
		ElseIf TypeName( Src ) = "Dictionary" Then
			For Each key  In Src.Keys()
				If IsObject( Src.Item( key ) ) Then
					Set Dst.Item( key ) = Src.Item( key )
				Else
					Dst.Item( key ) = Src.Item( key )
				End If
			Next
		Else
			If IsObject( Src ) Then  Set Dst.Item( Src.Name ) = Src  Else  Dst.Item( Src.Name ) = True
		End If

		If IsReturn Then  Set AddArrElemEx = Dst
	Else
		Dim  i, n

		n = UBound( Dst ) + 1
		If IsArray( Src ) Then
			ReDim Preserve  Dst( n + UBound( Src ) )
			For i=UBound( Src ) To 0 Step -1
				If IsObject( Src(i) ) Then  Set Dst(n+i) = Src(i)  Else  Dst(n+i) = Src(i)
			Next
		ElseIf TypeName( Src ) = "ArrayClass" Then
			ReDim Preserve  Dst( n + Src.UBound_ )
			For i=Src.UBound_ To 0 Step -1
				If IsObject( Src(i) ) Then  Set Dst(n+i) = Src(i)  Else  Dst(n+i) = Src(i)
			Next
		ElseIf not IsEmpty( Src ) Then
			ReDim Preserve  Dst( n )
			If IsObject( Src ) Then  Set Dst(n) = Src  Else  Dst(n) = Src
		End IF

		If IsReturn Then  AddArrElemEx = Dst
	End If
End Function


 
'*************************************************************************
'  <<< [SearchInSimpleArray] >>> 
'*************************************************************************
Function  SearchInSimpleArray( InData, InArray, OutBaseNumOrArray, DefaultOut )
	Dim  i

	For i=0 To UBound( InArray )
		If InData = InArray(i) Then
			If IsArray( OutBaseNumOrArray ) Then
				SearchInSimpleArray = OutBaseNumOrArray(i)
			Else
				SearchInSimpleArray = i + OutBaseNumOrArray
			End If
			Exit Function
		End If
	Next
	SearchInSimpleArray = DefaultOut
End Function


 
'*************************************************************************
'  <<< [GetFirst] >>> 
'*************************************************************************
Function  GetFirst( in_Collection )
	For Each  a_item  In  in_Collection
		Exit For
	Next
	LetSet  GetFirst, a_item
End Function


 
'*************************************************************************
'  <<< [ArrayFromLines] >>> 
'*************************************************************************
Function  ArrayFromLines( lines )
	ReDim  arr(-1)  '// output array
	arr_fast_ubound = UBound( arr )

	If lines = "" Then
		ArrayFromLines = Array( )
		Exit Function
	End If

	Set file = new StringStream
	file.SetString  lines
	Do Until  file.AtEndOfStream()
		If UBound(arr) < arr_fast_ubound + 1 Then _
			ReDim Preserve  arr( ( arr_fast_ubound + 100 ) * 4 )
		arr_fast_ubound = arr_fast_ubound + 1

		arr( arr_fast_ubound ) = file.ReadLine()
	Loop
	ReDim Preserve  arr( arr_fast_ubound )
	ArrayFromLines = arr
End Function


 
'*************************************************************************
'  <<< [CSVFrom] >>> 
'*************************************************************************
Function  CSVFrom( in_Array )
	If IsArray( in_Array ) Then
		CSVFrom = CSVFrom_Sub( in_Array )
	ElseIf TypeName( in_Array ) = "ArrayClass" Then
		CSVFrom = CSVFrom_Sub( in_Array.Items )
	End If
	If IsEmpty( CSVFrom ) Then _
		CSVFrom = ""
End Function


 
Function  CSVFrom_Sub( in_Array )
	For Each  an_item  In  in_Array
		If not IsEmpty( CSVFrom_Sub ) Then _
			CSVFrom_Sub = CSVFrom_Sub + ","

		CSVFrom_Sub = CSVFrom_Sub & an_item
	Next
End Function


 
'*************************************************************************
'  <<< [ArrayFromCSV] >>> 
'- return as ArrayClass
'*************************************************************************
Function  ArrayFromCSV( a_CSV )
	Dim  arr : Set arr = new ArrayClass
	arr.AddCSV  a_CSV, Empty
	ArrayFromCSV = arr.Items
End Function


 
'*************************************************************************
'  <<< [ArrayFromCSV_Int] >>> 
'*************************************************************************
Function  ArrayFromCSV_Int( a_CSV )
	Dim  arr : Set arr = new ArrayClass
	arr.AddCSV  a_CSV, vbInteger
	ArrayFromCSV_Int = arr.Items
End Function


 
'*************************************************************************
'  <<< [IsSame] >>> 
'*************************************************************************
Function  IsSame( in_Left, in_Right )
	IsSame = False
	If IsEmpty( in_Left ) Then
		IsSame = IsEmpty( in_Right )
	ElseIf IsNull( in_Left ) Then
		IsSame = IsNull( in_Right )
	ElseIf IsObject( in_Left ) Then
		If IsObject( in_Right ) Then
			IsSame = ( in_Left  is  in_Right )
		End If
	ElseIf IsArray( in_Left ) Then
		If IsArray( in_Right ) Then
			IsSame = IsSameArray( in_Left, in_Right )
		End If
	Else
		If IsEmpty( in_Right ) Then
		ElseIf IsNull( in_Right ) Then
		Else
			IsSame = ( in_Left  =  in_Right )
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [IsSameArray] >>> 
'*************************************************************************
Function  IsSameArray( Arr1, Arr2 )
	IsSameArray = IsSameArraySub( Arr1, Arr2, new IsSameArrayExOptionClass )
End Function


 
'*************************************************************************
'  <<< [IsSameArrayEx] >>> 
'*************************************************************************
Function  IsSameArrayEx( ArrayA, ArrayB, in_out_Option )
	If IsEmpty( in_out_Option ) Then  Set in_out_Option = new IsSameArrayExOptionClass
	If in_out_Option.IsOutOfOrder Then
		IsSameArrayEx = IsSameArrayOutOfOrderSub( ArrayA, ArrayB, in_out_Option )
	Else
		IsSameArrayEx = IsSameArraySub( ArrayA, ArrayB, in_out_Option )
	End If
End Function


 
'*************************************************************************
'  <<< [IsSameArrayExOptionClass] >>> 
'*************************************************************************
Class  IsSameArrayExOptionClass
	Public  IsOutOfOrder
	Public  IsStopNotSame
	Public  CompareFunction
	Public  ParameterOfCompareFunction

	Private Sub  Class_Initialize()
		Me.IsOutOfOrder = False
		Me.IsStopNotSame = False
	End Sub
End Class


 
'*************************************************************************
'  <<< [IsSameArraySub] >>> 
'*************************************************************************
Function  IsSameArraySub( Arr1, Arr2, in_out_Option )
	Dim  i, low, up

	If IsEmpty( Arr1 ) <> IsEmpty( Arr2 ) Then  IsSameArraySub = False : Exit Function
	If IsEmpty( Arr1 ) Then  IsSameArraySub = True : Exit Function

	If IsArray( Arr1 ) Then
		If IsArray( Arr2 ) Then
			If UBound( Arr1 ) <> UBound( Arr2 ) Then  IsSameArraySub = False : Exit Function
		Else
			If UBound( Arr1 ) <> UBound( Arr2.Items ) Then  IsSameArraySub = False : Exit Function
		End If
		low = LBound( Arr1 ) : up = UBound( Arr1 )
	Else
		If IsArray( Arr2 ) Then
			If UBound( Arr1.Items ) <> UBound( Arr2 ) Then  IsSameArraySub = False : Exit Function
		Else
			If UBound( Arr1.Items ) <> UBound( Arr2.Items ) Then  IsSameArraySub = False : Exit Function
		End If
		low = 0 : up = UBound( Arr1.Items )
	End If

	If IsEmpty( in_out_Option.CompareFunction ) Then
		For i = low To up
			If Arr1(i) = Arr2(i) Then
			Else
				If in_out_Option.IsStopNotSame Then _
					Stop
				IsSameArraySub = False : Exit Function
			End If
		Next
	Else
		For i = low To up
			If in_out_Option.CompareFunction( Arr1(i), Arr2(i), _
					in_out_Option.ParameterOfCompareFunction ) <> 0 Then
				If in_out_Option.IsStopNotSame Then _
					Stop
				IsSameArraySub = False : Exit Function
			End If
		Next
	End If
	IsSameArraySub = True
End Function


 
'*************************************************************************
'  <<< [IsSameArrayOutOfOrder] >>> 
'*************************************************************************
Function  IsSameArrayOutOfOrder( ArrayA, ArrayB, in_out_Option )
	If IsEmpty( in_out_Option ) Then  Set in_out_Option = new IsSameArrayExOptionClass
	If VarType( in_out_Option ) = vbInteger Then
		If in_out_Option = g_VBS_Lib.StopIsNotSame Then
			in_out_Option.IsStopNotSame = True
		End If
	End If

	IsSameArrayOutOfOrder = IsSameArrayOutOfOrderSub( ArrayA, ArrayB, in_out_Option )
End Function


 
'*************************************************************************
'  <<< [IsSameArrayOutOfOrderSub] >>> 
'*************************************************************************
Function  IsSameArrayOutOfOrderSub( ArrayA, ArrayB, in_out_Option )
	Set c = g_VBS_Lib

	Assert  IsEmpty( in_out_Option.CompareFunction )

	'// Reset "array_A_dictionary"
	Set array_A_dictionary = CreateObject( "Scripting.Dictionary" )
	For Each  element_A  In ArrayA
		If array_A_dictionary.Exists( element_A ) Then  Error
		array_A_dictionary( element_A ) = False
	Next

	'// Set "True" as "element_B" in "array_A_dictionary"
	For Each  element_B  In ArrayB
		If not array_A_dictionary.Exists( element_B ) Then
			If in_out_Option.IsStopNotSame Then _
				Stop
			IsSameArrayOutOfOrderSub = False
			Exit Function
		End If
		array_A_dictionary( element_B ) = True
	Next

	'// List up not same elements
	Set not_in_B_array = new ArrayClass
	For Each  element_A  In array_A_dictionary.Keys
		If not array_A_dictionary( element_A ) Then _
			not_in_B_array.Add  element_A
	Next
	If not_in_B_array.Count > 0 Then
		If in_out_Option.IsStopNotSame Then _
			Stop
		IsSameArrayOutOfOrderSub = False
		Exit Function
	End If
	IsSameArrayOutOfOrderSub = True
End Function


 
'***********************************************************************
'* Function: ReverseNotObjectArray
'***********************************************************************
Sub  ReverseNotObjectArray( in_Array,  out_Array )
	u_bound_ = UBound( in_Array )
	ReDim  out_Array( u_bound_ )
	For i=0 To  u_bound_
		out_Array( i ) = in_Array( u_bound_ - i )
	Next
End Sub


'***********************************************************************
'* Function: ReverseObjectArray
'***********************************************************************
Sub  ReverseObjectArray( in_Array,  out_Array )
	ReverseObjectArray_Sub  in_Array,  out_Array,  UBound( in_Array )
End Sub


 
'***********************************************************************
'* Function: Reverse_COM_ObjectArray
'***********************************************************************
Sub  Reverse_COM_ObjectArray( in_Array,  out_Array )
	ReverseObjectArray_Sub  in_Array,  out_Array,  in_Array.Count - 1
End Sub


 
'***********************************************************************
'* Function: ReverseObjectArray_Sub
'***********************************************************************
Sub  ReverseObjectArray_Sub( in_Array,  out_Array,  in_UBound )
	ReDim  out_Array( in_UBound )
	For i=0 To  in_UBound
		Set out_Array( i ) = in_Array( in_UBound - i )
	Next
End Sub


 
'*************************************************************************
'  <<< [RemoveObjectArray] >>> 
'*************************************************************************
Sub  RemoveObjectArray( in_out_Array, ElementObject )
	i = 1
	For Each obj  In in_out_Array
		If obj is ElementObject Then
			Exit For
		End If
		i = i + 1
	Next
	If not IsEmpty( obj ) Then
		i_max = UBound( in_out_Array )
		While  i < i_max
			Set in_out_Array( i - 1 ) = in_out_Array( i )
			i = i + 1
		WEnd
		ReDim Preserve  in_out_Array( i_max - 1 )
	End If
End Sub


 
'*************************************************************************
'  <<< [RemoveObjectsByNames] >>> 
'*************************************************************************
Sub  RemoveObjectsByNames( in_out_Array, Names )
	If IsArray( Names ) Then
		For Each  name  In  Names
			RemoveObjectsByNames  in_out_Array, name
		Next
	Else
		If TypeName( Names ) = "IRegExp2" Then
			Set key = Names
		Else
			If IsObject( Names ) Then
				key = Names.Name
			Else
				key = Names
			End If
		End If

		left_index = -1
		first_ubound = UBound( in_out_Array )
		For right_index = 0  To first_ubound
			name = in_out_Array( right_index ).Name

			If IsObject( key ) Then  '// key as RegExp
				is_match = key.Test( name )
			Else
				is_match = ( name = key )
			End If

			If not is_match Then
				left_index = left_index + 1

				If left_index <> right_index Then
					Set in_out_Array( left_index ) = in_out_Array( right_index )
				End If
			End If
		Next

		ReDim Preserve  in_out_Array( left_index )
	End If
End Sub


 
'*************************************************************************
'  <<< [ArrayToNameOnlyClassArray] >>> 
'*************************************************************************
Function  ArrayToNameOnlyClassArray( in_Array )
	Dim  o, i, arr

	ReDim  arr( UBound( in_Array ) )
	For i = 0 To UBound( in_Array )
		Set o = new NameOnlyClass
		o.Name = in_Array( i )
		Set arr( i ) = o
	Next

	ArrayToNameOnlyClassArray = arr
End Function


 
'********************************************************************************
'  <<< [NameOnlyClassArrayToArray] >>> 
'********************************************************************************
Function  NameOnlyClassArrayToArray( in_Array )
	ReDim  a_array( UBound( in_Array ) )

	index = 0
	For Each  object  In  in_Array
		a_array( index ) = object.Name
		index = index + 1
	Next

	NameOnlyClassArrayToArray = a_array
End Function


 
'********************************************************************************
'  <<< [DicItemToNameOnlyClassItem] >>> 
'********************************************************************************
Sub  DicItemToNameOnlyClassItem( ref_Dictionary )
	For Each  key  In  ref_Dictionary.Keys
		Set ref_Dictionary( key ) = new_NameOnlyClass( ref_Dictionary( key ), Empty )
	Next
End Sub


 
'********************************************************************************
'  <<< [NameOnlyClassItemToDicItem] >>> 
'********************************************************************************
Sub  NameOnlyClassItemToDicItem( ref_Dictionary )
	For Each  key  In  ref_Dictionary.Keys
		ref_Dictionary( key ) = ref_Dictionary( key ).Name
	Next
End Sub


 
'*************************************************************************
'  <<< [QuickSort_fromDic] >>> 
'dic as Scripting.Dictionary
'out_arr as [out] object array
'*************************************************************************
Sub  QuickSort_fromDic( dic, out_arr, compare_func, param )
	Dim    i, i_last, elem
	i_last = dic.Count - 1
	Redim  out_arr( i_last )

	i=0
	For Each elem  In dic.Items
		Set out_arr(i) = elem
		i = i + 1
	Next

	QuickSort  out_arr, 0, i_last, compare_func, param
End Sub


 
'***********************************************************************
'* Function: QuickSort_fromDicKey
'***********************************************************************
Sub  QuickSort_fromDicKey( in_out_Dictionary, out_SortedKeysArray, in_Empty )
	i_last = in_out_Dictionary.Count - 1
	Redim  out_SortedKeysArray( i_last )

	i=0
	For Each  key  In  in_out_Dictionary.Keys
		Set elem = new DicElem
		elem.Init  key, in_out_Dictionary.Item( key )
		Set out_SortedKeysArray(i) = elem
		i = i + 1
	Next

	QuickSort  out_SortedKeysArray, 0, i_last, GetRef( "DicElemCompare" ), 1
End Sub


 
'***********************************************************************
'* Function: QuickSortDicByKey
'***********************************************************************
Sub  QuickSortDicByKey( in_out_Dictionary )
	QuickSort_fromDicKey  in_out_Dictionary, items, Empty  '//[out] items
	in_out_Dictionary.RemoveAll
	For Each  item  In items
		Set in_out_Dictionary( item.Key ) = item.Item
			'// "item.Item" must have an object or "Nothing"
	Next
End Sub


 
'***********************************************************************
'* Function: QuickSortDicByKeyForNotObject
'***********************************************************************
Sub  QuickSortDicByKeyForNotObject( in_out_Dictionary )
	DicItemToNameOnlyClassItem  in_out_Dictionary
	QuickSortDicByKey           in_out_Dictionary
	NameOnlyClassItemToDicItem  in_out_Dictionary
End Sub


 
'*************************************************************************
'  <<< [QuickSort] >>> 
'*************************************************************************
Sub  QuickSort( arr, i_left, i_right, compare_func, param )
	Dim  pivot, i_pivot, i_big_eq, i_small, sw, n_min_count

	If i_left >= i_right Then Exit Sub  ' rule-b'

	i_pivot = ( i_left + i_right ) \ 2
	Set pivot = arr( i_pivot )


	'//== for debug
	' Const  watch_sort_id = 6  '//**********************************
	' Dim  sort_debug_id,  sort_debug_id2
	' g_SortDebugID = g_SortDebugID + 1
	' sort_debug_id = g_SortDebugID
	' Dim  i, sym, value
	' echo "QuickSort start (" & sort_debug_id & ") ----------------------"
	' For i = i_left To i_right
	'   QuickSort_Debug_getSym  arr, i, sym, value
	'   If i = i_pivot Then  value = value & " (pivot)"
	'   echo "(" & i & ") " & sym & " = " & value
	' Next
	' If sort_debug_id = watch_sort_id Then  Stop


	'//=== Split to [ arr(i_left) ][ smaller than ][ arr(i_pivot) ][ greater equal ][ arr(i_right) ]
	i_big_eq = i_left : i_small = i_right
	Do

		'// Plus i_big_eq.  Result is that ( *i_big_eq >= *i_pivot ).
		Do
			If compare_func( arr(i_big_eq), pivot, param ) >= 0 Then  Exit Do
			i_big_eq = i_big_eq + 1

			If i_big_eq > i_right Then
				If compare_func( pivot, arr( i_big_eq - 1 ), param ) < 0 Then
					Raise  1, "<Error msg=""常にマイナスの値を返すようです""/>"
				Else
					Raise  1, "<Error msg=""Null の比較はできません""/>"
				End If
			End If
		Loop


		'// Minus i_small.  Result is that ( *i_pivot > *i_small ).
		Do
			If i_small < i_left Then
				If compare_func( pivot, arr( i_small + 1 ), param ) > 0 Then
					Raise  1, "<Error msg=""常にプラスの値を返すようです""/>"
				End If

				Exit Do
			End If

			If compare_func( arr(i_small), pivot, param ) < 0 Then  Exit Do
			i_small = i_small - 1
		Loop


		'//== for debug
		' If sort_debug_id = watch_sort_id Then
		'   sort_debug_id2 = sort_debug_id2 + 1
		'   echo "QuickSort swap (" & sort_debug_id & "-" & sort_debug_id2 & ")-----------------"
		'   For i = i_left To i_right
		'     QuickSort_Debug_getSym  arr, i, sym, value
		'     If i = i_small   Then  value = value & " (i_small)"
		'     If i = i_big_eq     Then  value = value & " (i_big_eq)"
		'     If i = i_pivot   Then  value = value & " (i_pivot)"
		'     echo "(" & i & ") " & sym & " = " & value
		'   Next
		' End If


		'// Splitted
		If i_small < i_big_eq Then
			If i_left <= i_small Then
				Exit Do


		'// If *i_pivot is minimum Then  (4) collect minimums at left
			Else
				Set sw = arr(i_left) : Set arr(i_left) = arr(i_pivot) : Set arr(i_pivot) = sw
				i_big_eq = i_big_eq + 1
				n_min_count = n_min_count + 1


				i_small = i_right  '// i_small is iterater to same value as minimum
				Do
					If i_big_eq >= i_small Then  Exit Do

					'// while ( *i_big_eq == *i_left )  i_big_eq++
					If compare_func( arr(i_big_eq), pivot, param ) = 0 Then
						i_big_eq = i_big_eq + 1
						n_min_count = n_min_count + 1

					'// Swap *i_big_eq  and  *i_small
					Else
						Do
							If i_small <= i_big_eq Then  Exit Do
							If compare_func( arr(i_small), pivot, param ) = 0 Then
								Set sw = arr(i_small) : Set arr(i_small) = arr(i_big_eq) : Set arr(i_big_eq) = sw
								Exit Do
							End If
							i_small = i_small - 1
						Loop
						If i_small <= i_big_eq Then  Exit Do
					End If
				Loop
				Exit Do
			End If


		'// If i_big_eq < i_pivot < i_small Then  (1) Swap *i_big_eq and *i_small
		ElseIf i_big_eq < i_pivot  and  i_pivot < i_small Then
			Set sw = arr(i_big_eq) : Set arr(i_big_eq) = arr(i_small) : Set arr(i_small) = sw
			i_big_eq = i_big_eq + 1 : i_small = i_small - 1


		'// If i_big_eq = i_pivot < i_small Then  (2A) Rotate3 *i_small -> *i_pivot -> *(i_pivot+1);  i_pivot++
		ElseIf i_big_eq = i_pivot  and  i_pivot < i_small Then
			If i_pivot + 1 < i_small Then
				Set sw = arr(i_pivot+1) : Set arr(i_pivot+1) = arr(i_pivot)
				Set arr(i_pivot) = arr(i_small) : Set arr(i_small) = sw
				i_big_eq = i_big_eq + 1 : i_pivot = i_pivot + 1


		'// If i_big_eq = i_pivot  and  i_pivot+1 = i_small Then  (2B) Swap *i_big_eq and *i_small
		'// (If rotate3, The result is Not swaped)
			Else
				Set sw = arr(i_big_eq) : Set arr(i_big_eq) = arr(i_small) : Set arr(i_small) = sw
				i_big_eq = i_big_eq + 1
				Exit Do
			End If


		'// If i_big_eq < i_small < i_pivot Then  (3) Rotate3 *i_small -> *i_big_eq -> *i_pivot;  i_pivot--
		ElseIf i_big_eq < i_small  and  i_small < i_pivot Then
			Set sw = arr(i_pivot) : Set arr(i_pivot) = arr(i_big_eq)
			Set arr(i_big_eq) = arr(i_small) : Set arr(i_small) = sw
			i_big_eq = i_big_eq + 1 : i_small = i_small - 1 : i_pivot = i_pivot - 1


		Else
			Stop
		End If

	Loop


	'//== for debug
	' echo "QuickSort middle (" & sort_debug_id & ") ----------------------"
	' For i = i_left To i_right
	'   QuickSort_Debug_getSym  arr, i, sym, value
	'   If i = i_big_eq-1 Then  value = value & " (i_big_eq-1)"
	'   If i = i_big_eq   Then  value = value & " (i_big_eq)"
	'   echo "(" & i & ") " & sym & " = " & value
	' Next
	' If sort_debug_id = watch_sort_id Then  Stop


	QuickSort  arr, (i_left + n_min_count), i_big_eq-1, compare_func, param  ' rule-b
	QuickSort  arr, i_big_eq,  i_right, compare_func, param  ' rule-b


	'//== for debug
	' echo "QuickSort end (" & sort_debug_id & ")----------------------"
	' For i = i_left To i_right
	'   QuickSort_Debug_getSym  arr, i, sym, value
	'   echo "(" & i & ") " & sym & " = " & value
	' Next
	'If g_is_debug Then
	'  For  i_small = i_left  To i_right - 1
	'    If compare_func( arr(i_small), arr(i_small + 1), param ) > 0 Then  Error
	'  Next
	'End If
End Sub


'//== for debug
'Dim  g_SortDebugID
'Sub  QuickSort_Debug_getSym( Arr, Index, out_Symbol, out_Value )
'  out_Symbol = Index
'  out_Value  = Arr(Index).id
'End Sub


 
'*************************************************************************
'  <<< [ShakerSort_fromDic] >>> 
'dic as Scripting.Dictionary
'out_arr as [out] object array
'*************************************************************************
Sub  ShakerSort_fromDic( dic, out_arr, sign, compare_func, param )
	Dim    i, i_last, elem
	i_last = dic.Count - 1
	Redim  out_arr( i_last )

	If sign >= 0 Then
		i=0
		For Each elem  In dic.Items
			Set out_arr(i) = elem
			i = i + 1
		Next
	Else
		i=i_last
		For Each elem  In dic.Items
			Set out_arr(i) = elem
			i = i - 1
		Next
	End If

	ShakerSort  out_arr, 0, i_last, compare_func, param
End Sub


 
'*************************************************************************
'  <<< [ShakerSort_fromDicKey] >>> 
'*************************************************************************
Sub  ShakerSort_fromDicKey( dic, out_arr, Option_ )
	Dim    i, i_last, key, elem
	i_last = dic.Count - 1
	Redim  out_arr( i_last )

	i=0
	For Each key  In dic.Keys
		Set elem = new DicElem
		elem.Init  key, dic.Item( key )
		Set out_arr(i) = elem
		i = i + 1
	Next

	ShakerSort  out_arr, 0, i_last, GetRef( "DicElemCompare" ), 1
End Sub


 
'*************************************************************************
'  <<< [ShakerSortDicByKey] >>> 
'*************************************************************************
Sub  ShakerSortDicByKey( a_Dictionary )
	ShakerSort_fromDicKey  a_Dictionary, items, Empty  '//[out] items
	a_Dictionary.RemoveAll
	For Each  item  In items
		Set a_Dictionary( item.Key ) = item.Item
	Next
End Sub


 
'*************************************************************************
'  <<< [ShakerSortDicByKeyCompare] >>> 
'*************************************************************************
Sub  ShakerSortDicByKeyCompare( a_Dictionary, CompareFunc, CompareFuncParam )
	ShakerSort_fromDicKey_Sub  a_Dictionary, items, CompareFunc, CompareFuncParam  '//[out] items
	a_Dictionary.RemoveAll
	For Each  item  In items
		Set a_Dictionary( item.Key ) = item.Item
	Next
End Sub


 
'*************************************************************************
'  <<< [DelegateCompareClass] >>> 
'*************************************************************************
Class  DelegateCompareClass
	Public  CompareFunction
	Public  CompareFunctionParameter
End Class


 
'*************************************************************************
'  <<< [ShakerSort_fromDicKey_Sub] >>> 
'*************************************************************************
Sub  ShakerSort_fromDicKey_Sub( dic, out_arr, CompareFunc, CompareFuncParam )
	i_last = dic.Count - 1
	Redim  out_arr( i_last )

	i=0
	For Each key  In dic.Keys
		Set elem = new DicElem
		elem.Init  key, dic.Item( key )
		Set out_arr(i) = elem
		i = i + 1
	Next

	Set compare = new DelegateCompareClass
	Set compare.CompareFunction = CompareFunc
	If IsObject( CompareFuncParam ) Then
		Set compare.CompareFunctionParameter = CompareFuncParam
	Else
		compare.CompareFunctionParameter = CompareFuncParam
	End If

	ShakerSort  out_arr, 0, i_last, GetRef("DicKeyDelegateCompare"), compare
End Sub

Function  DicKeyDelegateCompare( Left, Right, Param )
	DicKeyDelegateCompare = Param.CompareFunction( _
		Left.Key, Right.Key, Param.CompareFunctionParameter )
End Function


 
'*************************************************************************
'  <<< [ShakerSort] >>> 
'*************************************************************************
Sub  ShakerSort( arr, ByVal i_left, ByVal i_right, compare_func, param )
	Dim  i_swap, i, sw

	Do
		i_swap = i_left+1
		For i=i_left+1 To i_right
			If compare_func( arr(i-1), arr(i), param ) > 0 Then
				Set sw = arr(i-1) : Set arr(i-1) = arr(i) : Set arr(i) = sw
				i_swap = i
			End If
		Next
		If i_swap = i_left+1 Then Exit Do
		i_right = i_swap-1

		i_swap = i_right-1
		For i=i_right-1 To i_left Step -1
			If compare_func( arr(i), arr(i+1), param ) > 0 Then
				Set sw = arr(i) : Set arr(i) = arr(i+1) : Set arr(i+1) = sw
				i_swap = i
			End If
		Next
		If i_swap = i_right-1 Then Exit Do
		i_left = i_swap+1
	Loop
End Sub


 
'*************************************************************************
'  <<< [ReverseDictionary] >>> 
'*************************************************************************
Function  ReverseDictionary( ref_Dictionary )
	index_max = ref_Dictionary.Count - 1
	ReDim  keys_( index_max )
	ReDim  items_( index_max )

	i = index_max
	For Each  key  In  ref_Dictionary.Keys
		keys_(i) = key
		LetSetWithBracket  items_,  i,  ref_Dictionary( key )
		i = i - 1
	Next

	ref_Dictionary.RemoveAll

	For i=0 To  index_max
		LetSetWithBracket  ref_Dictionary,  keys_(i),  items_(i)
	Next
End Function


 
'*************************************************************************
'  <<< [StdCompare] >>> 
'*************************************************************************
Function  StdCompare( Left, Right, Param )
	StdCompare = -1

	If IsObject( Left ) Then
		If IsObject( Right ) Then
			If Left is Right Then
				StdCompare = 0
			End If
		End If
	ElseIf VarType( Left ) = vbString Then
		If VarType( Right ) = vbString Then
			StdCompare = StrComp( Left, Right, Param )
		End If
	ElseIf IsEmpty( Left ) Then
		If IsEmpty( Right ) Then
			StdCompare = 0
		Else
			StdCompare = 1
		End IF
	ElseIf VarType( Left ) = VarType( Right ) Then
		If Left = Right Then
			StdCompare = 0
		ElseIf Left > Right Then
			StdCompare = 1
		End If
	Else
		Error
	End If
End Function


 
'*************************************************************************
'  <<< [NameCompare] >>> 
'*************************************************************************
Function  NameCompare( Left, Right, Param )
	NameCompare = -1

	If IsObject( Left ) Then
		If IsObject( Right ) Then
			If g_Vers("CutPropertyM") Then
				NameCompare = StdCompare( Left.Name, Right.Name, Param )
			Else
				NameCompare = StdCompare( Left.m_Name, Right.m_Name, Param )
			End If
		End If
	ElseIf not IsObject( Right ) Then
		NameCompare = 0
	Else
		NameCompare = 1
	End If
End Function


 
'***********************************************************************
'* Function: DelegateCompare
'***********************************************************************
Function  DelegateCompare( in_Left, in_Right, in_Parameter )
	DelegateCompare = StdCompare( in_Left.Delegate,  in_Right.Delegate,  in_Parameter )
End Function


 
'********************************************************************************
'  <<< [GetNumberRegEx] >>> 
'********************************************************************************
Function  GetNumberRegEx()
	If IsEmpty( g_NumberRegEx ) Then
		Set g_NumberRegEx = CreateObject( "VBScript.RegExp" )
		g_NumberRegEx.Global = True
		g_NumberRegEx.Pattern = "(0*)([1-9][0-9]*)|0+"
	End If
	Set GetNumberRegEx = g_NumberRegEx
End Function

Dim  g_NumberRegEx


 
'********************************************************************************
'  <<< [NumStringCompare] >>> 
'********************************************************************************
Function  NumStringCompare( in_StringA, in_StringB, Opt )
	Set re = GetNumberRegEx()
	Set matches_A = re.Execute( in_StringA )
	Set matches_B = re.Execute( in_StringB )
	compare_option = StrCompOption( Opt )
	position = 1

	For i=0  To  matches_A.Count - 1
		If i >= matches_B.Count Then _
			Exit For

		Set match_A = matches_A(i)
		Set match_B = matches_B(i)
		part_A = Mid( in_StringA, position, match_A.FirstIndex - position + 1 ) +"0"
		part_B = Mid( in_StringB, position, match_B.FirstIndex - position + 1 ) +"0"
			'// 最後に追加する 0 は、長いほうの文字と数字を比較するため。 たとえば、
			'// in_StringA = "ab55", part_A = "ab0"
			'// in_StringB = "abcd", part_B = "abcd0" ... in_StringA < in_StringB
			'// in_StringB = "ab!d", part_B = "ab!d0" ... in_StringA > in_StringB

		NumStringCompare = StrComp( part_A,  part_B,  compare_option )
		If NumStringCompare <> 0 Then _
			Exit For

		NumStringCompare = Len( match_A.SubMatches(1) ) - Len( match_B.SubMatches(1) )
		If NumStringCompare <> 0 Then _
			Exit For

		NumStringCompare = StrComp( match_A.SubMatches(1),  match_B.SubMatches(1),  compare_option )
		If NumStringCompare <> 0 Then _
			Exit For

		NumStringCompare = Len( match_B.SubMatches(0) ) - Len( match_A.SubMatches(0) )
		If NumStringCompare <> 0 Then _
			Exit For

		position = match_A.FirstIndex + 1 + Len( match_A.Value )
		NumStringCompare = Empty
	Next

	If IsEmpty( NumStringCompare ) Then
		If matches_A.Count <= i Then
			part_A = Mid( in_StringA, position )
		Else
			Set match_A = matches_A(i)
			part_A = Mid( in_StringA, position, match_A.FirstIndex - position + 1 ) +"0"
		End If
		If matches_B.Count <= i Then
			part_B = Mid( in_StringB, position )
		Else
			Set match_B = matches_B(i)
			part_B = Mid( in_StringB, position, match_B.FirstIndex - position + 1 ) +"0"
		End If
		NumStringCompare = StrComp( part_A, part_B, compare_option )
	End If

	If IsReverseSortOption( Opt ) Then _
		NumStringCompare = - NumStringCompare
End Function


 
'*************************************************************************
'  <<< [NumStringNameCompare] >>> 
'*************************************************************************
Function  NumStringNameCompare( Left, Right, Param )
	If g_Vers("CutPropertyM") Then
		NumStringNameCompare = NumStringCompare( Left.Name, Right.Name, Param )
	Else
		NumStringNameCompare = NumStringCompare( Left.m_Name, Right.m_Name, Param )
	End If
End Function


 
'*************************************************************************
'  <<< [LengthCompare] >>> 
'*************************************************************************
Function  LengthCompare( Left, Right, Param )
	LengthCompare = -1

	If VarType( Left ) = vbString Then
		LengthCompare = ( Len( Left ) - Len( Right ) )
		If IsNumeric( Param ) Then
			If Param < 0 Then  LengthCompare = -LengthCompare
		End If
	Else
		Error
	End If
End Function


 
'*************************************************************************
'  <<< [LengthNameCompare] >>> 
'*************************************************************************
Function  LengthNameCompare( Left, Right, Param )
	If g_Vers("CutPropertyM") Then
		LengthNameCompare = LengthCompare( Left.Name, Right.Name, Param )
	Else
		LengthNameCompare = LengthCompare( Left.m_Name, Right.m_Name, Param )
	End If
End Function


 
'*************************************************************************
'  <<< [PathCompare] >>> 
'*************************************************************************
Function  PathCompare( Left, Right, ByVal Param )
	PathCompare = -1
	If IsEmpty( Param ) Then  Param = +1

	If VarType( Left ) = vbString Then
		left_2  = Left
		right_2 = Right
		For Each  symbol  In Array( "\", "/", "*", "." )
			left_2  = Replace( left_2,  symbol, vbTab )
			right_2 = Replace( right_2, symbol, vbTab )
				'// Tab is smaller than other character.
		Next

		PathCompare = NumStringCompare( left_2,  right_2,  Param )
	Else
		Error
	End If
End Function


 
'*************************************************************************
'  <<< [PathNameCompare] >>> 
'*************************************************************************
Function  PathNameCompare( Left, Right, Param )
	If g_Vers("CutPropertyM") Then
		PathNameCompare = PathCompare( Left.Name, Right.Name, Param )
	Else
		PathNameCompare = PathCompare( Left.m_Name, Right.m_Name, Param )
	End If
End Function


 
'*************************************************************************
'* Function: ParentPathCompare
'*************************************************************************
Function  ParentPathCompare( in_Left,  in_Right,  in_Param )
	If in_Param > 0 Then
		ParentPathCompare = ParentPathCompare( in_Right,  in_Left,  -1 )
		Exit Function
	End If

	If StrCompHeadOf( in_Right,  GetPathWithSeparator( in_Left ),  Empty ) = 0 Then
		ParentPathCompare = +1
	Else
		ParentPathCompare = 0
	End If
End Function


 
'***********************************************************************
'* Function: NoCompareFunction
'***********************************************************************
Function  NoCompareFunction( in_Left, in_Right, in_Parameter )
	NoCompareFunction = in_Parameter
End Function


 
'***********************************************************************
'* Function: IsReverseSortOption
'***********************************************************************
Function  IsReverseSortOption( in_Option )
	If not IsObject( in_Option ) Then _
		IsReverseSortOption = ( CInt( in_Option ) < 0 )
End Function


 
'*************************************************************************
'  <<< [CInt2] >>> 
' - no exception
'*************************************************************************
Function  CInt2( v )
	Dim  en, ed

	ErrCheck : On Error Resume Next
		CInt2 = CLng( v )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = 13 Then  '// if sym is not number
		CInt2 = 0
	ElseIf en <> 0 Then  Err.Raise en,,ed  End If
End Function


 
'***********************************************************************
'* Function: AlignString
'***********************************************************************
Function  AlignString( in_InputData,  in_MinimumLength,  in_FillingCharacter,  in_ValueIfOver )
	a_string = CStr( in_InputData )
	a_string_length = Len( a_string )
	If in_MinimumLength >= 0 Then
		min_length = in_MinimumLength
	Else
		min_length = - in_MinimumLength
	End If

	If a_string_length <= min_length Then
		filling_string = String( min_length - a_string_length,  in_FillingCharacter )
		If in_MinimumLength >= 0 Then
			AlignString = filling_string + a_string
		Else
			AlignString = a_string + filling_string
		End If
	Else
		If IsEmpty( in_ValueIfOver ) Then
			AlignString = a_string
		Else
			AlignString = in_ValueIfOver
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [Trim2] >>> 
'*************************************************************************
Function  Trim2( v )
	Trim2 = LTrim2( RTrim2( v ) )
End Function


 
'*************************************************************************
'  <<< [LTrim2] >>> 
'*************************************************************************
Function  LTrim2( v )
	Dim  i

	For i = 1 To Len( v )
		Select Case  Mid( v, i, 1 )
			Case  " ", vbTab, vbCR, vbLF
			Case Else  Exit For
		End Select
	Next
	LTrim2 = Mid( v, i )
End Function


 
'*************************************************************************
'  <<< [RTrim2] >>> 
'*************************************************************************
Function  RTrim2( v )
	Dim  i

	For i = Len( v ) To 1 Step -1
		Select Case  Mid( v, i, 1 )
			Case  " ", vbTab, vbCR, vbLF
			Case Else  Exit For
		End Select
	Next
	RTrim2 = Left( v, i )
End Function


 
'*************************************************************************
'  <<< [sprintf] >>> 
'*************************************************************************
Function  sprintf( in_Format,  in_Parameters )

	'// Example: "before %d after"
	'//           ^p1    ^p2
	'//                   ^p3
	out = ""
	p3_over = Len( in_Format ) + 1
	parameter_index = 0

	p1 = 1
	Do
		p2 = InStr( p1,  in_Format,  "%" )
		If p2 = 0 Then _
			Exit Do


		out = out + Mid( in_Format,  p1,  p2 - p1 )


		p3 = p3_over
		For Each  last_character  In  Array( "s", "d", "X", "x" )
			p3a = InStr( p2,  in_Format,  last_character )
			If p3a >= 1 Then
				If p3a < p3 Then _
					p3 = p3a
			End If
		Next
		If p3 = p3_over Then
			Raise  1,  "<ERROR msg=""Not supported C printf Format"" format="""+ in_Format +"""/>"
		End If


		Select Case  Mid( in_Format,  p3,  1 )

			Case  "s", "d"
				value = CStr( in_Parameters( parameter_index ) )

			Case  "X"
				value = Hex( in_Parameters( parameter_index ) )

			Case  "x"
				value = LCase( Hex( in_Parameters( parameter_index ) ) )
		End Select


		If p2 + 1 = p3 Then
			out = out + value

		Else
			p2 = p2 + 1
			c2 = Mid( in_Format,  p2,  1 )

			If c2 = "-" Then
				flag = -1
				p2 = p2 + 1
				c2 = Mid( in_Format,  p2,  1 )
			Else
				flag = +1
			End If

			If c2 = "0" Then
				filling = "0"
				p2 = p2 + 1
			Else
				filling = " "
			End If

			length_ = CInt( Mid( in_Format,  p2,  p3 - p2 ) ) * flag


			out = out + AlignString( value,  length_,  filling,  Empty )

		End If

		parameter_index = parameter_index + 1
		p1 = p3 + 1
	Loop

	sprintf = out + Mid( in_Format,  p1 )
End Function


 
'*************************************************************************
'  <<< [sscanf] >>> 
'*************************************************************************
Function  sscanf( in_String,  in_Format )
	Dim  percent_pos_in_format,  start_tag,  end_tag,  start_pos,  end_pos,  type_


	'//=== get percent_pos_in_format and type_
	percent_pos_in_format = InStr( in_Format,  "%s" )
	If percent_pos_in_format > 0 Then
		type_ = "%s"
	Else
		percent_pos_in_format = InStr( in_Format,  "%d" )
		If percent_pos_in_format > 0 Then
			type_ = "%d"
		Else
			Error
		End If
	End If


	'//=== search in String
	start_tag = Left( in_Format,  percent_pos_in_format - 1 )
	end_tag   = Mid(  in_Format,  percent_pos_in_format + 2 )

	start_pos = InStr( in_String,  start_tag )
	If start_pos = 0 Then  Raise  E_NotFoundSymbol, "<ERROR msg=""見つかりません"" format="""+ in_Format +"""/>"
	start_pos = start_pos + percent_pos_in_format - 1

	If end_tag <> "" Then
		end_pos = InStr( start_pos,  in_String,  end_tag )
		If end_pos = 0 Then  Raise  E_NotFoundSymbol, "<ERROR msg=""見つかりません"" format="""+ in_Format +"""/>"
	Else
		end_pos = Len( in_String ) + 1
	End If


	'//=== pickup
	sscanf = Mid( in_String,  start_pos,  end_pos - start_pos )

	If type_ = "%d" Then  sscanf = CInt2( sscanf )
End Function


 
'*************************************************************************
'  <<< [ScanFromTemplate] >>> 
'*************************************************************************
Function  ScanFromTemplate( ScanString, TemplateString, KeywordArray, Option_ )
	Set ScanFromTemplate = ScanFromTemplate_Sub( Empty, _
		ScanString, TemplateString, KeywordArray, 1, True, _
		IsBitSet( Option_, g_VBS_Lib.WithDollarVariable ) )
End Function


Function  ScanFromTemplate_Sub( out, ScanString, TemplateString, KeywordArray, in_out_Position,_
		IsErrorNotFoundFirstText, IsReplaceEscapeDollarVariable )

	If IsEmpty( out ) Then _
		Set out = CreateObject( "Scripting.Dictionary" )
	template_text_position = 1
	msg_1 = "置き換える対象に、テンプレートの内容が含まれていません"

	If UBound( KeywordArray ) = -1 Then
		Set ScanFromTemplate_Sub = out
		Exit Function
	End If


	'// Set "template_text", "template_text_length"
	ReDim  template_text(        UBound( KeywordArray ) + 1 )
	ReDim  template_text_length( UBound( KeywordArray ) + 1 )
	For keyword_num = 0  To UBound( KeywordArray )
		template_keyword_position = InStr( template_text_position,_
			TemplateString, KeywordArray( keyword_num ) )
		If template_keyword_position = 0 Then
			If InStr( TemplateString, KeywordArray( keyword_num ) ) > 0 Then
				Raise  1, "<ERROR msg=""キーワードの順番を変えてください"""+_
					" keyword_1="""& KeywordArray( keyword_num - 1 ) &""""+_
					" keyword_2="""& KeywordArray( keyword_num ) &"""/>"
			Else
				Raise  1, "<ERROR msg=""テンプレートの中にキーワードが見つかりません"""+_
					" keyword="""& KeywordArray( keyword_num ) &"""/>"
			End If
		End If
		template_text( keyword_num ) = Mid( TemplateString, template_text_position, _
			template_keyword_position - template_text_position )
		If IsReplaceEscapeDollarVariable Then
			template_text( keyword_num ) = Replace( template_text( keyword_num ), "$\{", "${" )
			template_text( keyword_num ) = Replace( template_text( keyword_num ), "$\\", "$\" )
		End If
		template_text_length( keyword_num ) = Len( template_text( keyword_num ) )

		template_text_position = template_keyword_position + Len( KeywordArray( keyword_num ) )
	Next
	template_text( keyword_num ) = Mid( TemplateString, template_text_position )
	If IsReplaceEscapeDollarVariable Then
		template_text( keyword_num ) = Replace( template_text( keyword_num ), "$\{", "${" )
		template_text( keyword_num ) = Replace( template_text( keyword_num ), "$\\", "$\" )
	End If
	template_text_length( keyword_num ) = Len( template_text( keyword_num ) )


	'// Special Case
	If KeywordArray( 0 ) = TemplateString Then
		out( KeywordArray( 0 ) ) = ScanString
		in_out_Position = Len( ScanString )
		Set ScanFromTemplate_Sub = out
		Exit Function
	End If


	'// Update "in_out_Position" : Search "template_text"( last )
	p = in_out_Position
	For keyword_num = 0  To UBound( KeywordArray ) + 1
		p = InStr( p, ScanString, template_text( keyword_num ) )
		If p = 0 Then
			If IsErrorNotFoundFirstText Then
				Raise  1, "<ERROR msg="""+ msg_1 +"""/>"
			Else
				Set ScanFromTemplate_Sub = Nothing
				Exit Function
			End If
		End If
		p = p + template_text_length( keyword_num )
	Next
	in_out_Position = p


	'// Set "out" : 前方検索する。 最も短いマッチをスキャンするため
	p2 = in_out_Position - template_text_length( UBound( KeywordArray ) + 1 )
	For keyword_num = UBound( KeywordArray )  To 0  Step -1
		n = template_text_length( keyword_num )

		p1 = InStrRev( ScanString, template_text( keyword_num ), p2 - 1 )
		out( KeywordArray( keyword_num ) ) = Mid( ScanString,  p1 + n, p2 - p1 - n )

		p2 = p1
	Next


	'// Set "out"( first ), "out"( last )
	If StrCompHeadOf( TemplateString, KeywordArray( 0 ), g_VBS_Lib.CaseSensitive ) = 0 Then
		out( KeywordArray( 0 ) ) = Left( ScanString, p1 )
	End If
	If UBound( KeywordArray ) >= 1 Then
		If StrCompLastOf( TemplateString, KeywordArray( UBound( KeywordArray ) ), _
				g_VBS_Lib.CaseSensitive ) = 0 Then
			value = Mid( ScanString, in_out_Position )
			out( KeywordArray( UBound( KeywordArray ) ) ) = value
			in_out_Position = Len( value )
		End If
	End If


	Set ScanFromTemplate_Sub = out
End Function


 
'*************************************************************************
'  <<< [ScanMultipleFromTemplate] >>> 
'*************************************************************************
Sub  ScanMultipleFromTemplate( ScanString, TemplateString, KeywordArray, Option_, out_Scaned )
	Set scaned_array = new ArrayClass
	position = 1
	If IsArray( KeywordArray ) Then
		Do
			Set scaned = ScanFromTemplate_Sub( Empty, ScanString, TemplateString, _
				KeywordArray, position, False, False )  '//(in/out) position

			If scaned is Nothing Then _
				Exit Do

			scaned_array.Add  scaned
		Loop
	Else
		keyword_array = Array( KeywordArray )
		Do
			Set scaned = ScanFromTemplate_Sub( Empty, ScanString, TemplateString, _
				keyword_array, position, False, False )  '//(in/out) position

			If scaned is Nothing Then _
				Exit Do

			For Each  value  In scaned.Items
				scaned_array.Add  value
			Next
		Loop
	End If
	out_Scaned = scaned_array.Items
End Sub


 
'*************************************************************************
'  <<< [InStrEx] >>> 
'*************************************************************************
Function  InStrEx( WholeString, ByVal Keyword, ByVal StartIndex, Opt )
	Dim  pos,  pos1, keyword_num
	Dim  c : Set c = g_VBS_Lib
	Dim  case_sensitive : case_sensitive = StrCompOption( Opt and c.CaseSensitive )
	Dim  is_reverse : is_reverse = ( ( Opt and c.Rev ) <> 0 )
	Dim  keyword_len,  keyword_lens

	If StartIndex = 0 Then
		If is_reverse Then  StartIndex = -1  Else  StartIndex = 1
	End If
	whole_string_length = Len( WholeString )


	'// Set "Keyword" array, "keyword_len" array
	If IsArray( Keyword ) Then
		ReDim  keyword_lens( UBound( Keyword ) )
		For keyword_num = 0  To UBound( Keyword )
			keyword_lens( keyword_num ) = Len( Keyword( keyword_num ) )
		Next
	Else
		keyword_lens = Array( Len( Keyword ) )
		Keyword = Array( Keyword )
	End If


	Do
		'// Set "pos" : Search
		If is_reverse Then
			pos = 0
			For keyword_num = 0  To UBound( Keyword )
				pos1 = InStrRev( WholeString, Keyword(keyword_num), StartIndex, case_sensitive )
				If pos1 > pos Then  pos = pos1 : keyword_len = keyword_lens( keyword_num )
			Next
			If pos = 0 Then  InStrEx = 0 : Exit Function
		Else
			pos = whole_string_length + 1
			For keyword_num = 0  To UBound( Keyword )
				pos1 = InStr( StartIndex, WholeString, Keyword(keyword_num), case_sensitive )
				If pos1 <> 0 Then  If pos1 < pos Then  pos = pos1 : keyword_len = keyword_lens( keyword_num )
			Next
			If pos = whole_string_length + 1 Then  InStrEx = 0 : Exit Function
		End If


		'// Check by "c.WholeWord", "c.LineHead", "c.LineTail"
		is_match = True
		If (Opt and c.WholeWord) Then
			If not IsWholeWord( WholeString, pos, keyword_len ) Then _
				is_match = False
		End If
		If (Opt and c.LineHead) Then
			If pos >= 3 Then
				If Mid( WholeString, pos - 2, 2 ) <> vbCRLF Then _
					is_match = False
			ElseIf pos = 2 Then
				is_match = False
			End If
		End If
		If (Opt and c.LineTail) Then
			If pos + keyword_len <= whole_string_length - 1 Then
				If Mid( WholeString, pos + keyword_len, 2 ) <> vbCRLF Then _
					is_match = False
			ElseIf pos + keyword_len = whole_string_length Then
				is_match = False
			End If
		End If
		If is_match Then _
			Exit Do


		'// Set next "StartIndex"
		If is_reverse Then
			StartIndex = pos - 1
		Else
			StartIndex = pos + 1
		End If
	Loop
	If Opt and c.LastNextPos Then  pos = pos + keyword_len
	InStrEx = pos
End Function


 
'*************************************************************************
'  <<< [IsWholeWord] >>> 
'*************************************************************************
Function  IsWholeWord( WholeString, StartIndex, SubWordLen )
	Dim  i, ch

	IsWholeWord = False
	For i=1 To 2
		If i = 1 Then
			If StartIndex <= 1 Then
				ch = 0
			Else
				ch = Asc( Mid( WholeString, StartIndex - 1, 1 ) )
			End If
		Else
			If StartIndex + SubWordLen > Len( WholeString ) Then
				ch = 0
			Else
				ch = Asc( Mid( WholeString, StartIndex + SubWordLen, 1 ) )
			End If
		End If

		If ch < &h30 Then
		ElseIf ch <= &h39 Then
			Exit Function
		ElseIf ch <  &h41 Then
		ElseIf ch <= &h5A Then
			Exit Function
		ElseIf ch <  &h61 Then
		ElseIf ch <= &h7A Then
			Exit Function
		End If
	Next
	IsWholeWord = True
End Function


 
'*************************************************************************
'  <<< [InStrLast] >>> 
'*************************************************************************
Function  InStrLast( Str, Keyword )
	Dim  i
	i = InStr( Str, Keyword )
	If i = 0 Then
		InStrLast = 0
	Else
		InStrLast = i + Len( Keyword )
	End If
End Function


 
'*************************************************************************
'  <<< [IsPlusIntOrZeroString] >>> 
'*************************************************************************
Function  IsPlusIntOrZeroString( aString )
	Dim  i, c

	For i=1 To Len( aString )
		c = Asc( Mid( aString, i, 1 ) )
		If c < &h30  or  c > &h39  Then  '// c<'0' or c>'9'
			IsPlusIntOrZeroString = False
			Exit Function
		End If
	Next
	IsPlusIntOrZeroString = True
End Function


 
'*************************************************************************
'  <<< [MeltQuot] >>> 
'*************************************************************************
Function  MeltQuot( Line, in_out_Start )
	Dim  i, j, c


	'//=== Skip to "
	i = in_out_Start
	Do
		c = Mid( Line, i, 1 )
		If c = "" Then  in_out_Start = 0 : Exit Function
		If c = """"  Then Exit Do
		i = i + 1
	Loop
	j = i + 1


	'//=== Search the end of "
	i = j
	Do
		c = Mid( Line, i, 1 )
		If c = "" Then  in_out_Start = 0 : Exit Do
		If c = """"  Then  in_out_Start = i + 1 : Exit Do
		i = i + 1
	Loop


	'//=== Get the string
	MeltQuot = Mid( Line, j, i - j )

End Function


 
'*************************************************************************
'  <<< [CreateGuid] >>> 
'*************************************************************************
Dim  g_TypeLib

Function  CreateGuid()
	If g_TestModeFlags and F_NotRandom Then
		g_TypeLib = g_TypeLib + 1
		CreateGuid = "00000000-0000-0000-0000-" & Right( "000000000000" & g_TypeLib, 12 )
	Else
		If IsEmpty( g_TypeLib ) Then  Set g_TypeLib = CreateObject("Scriptlet.TypeLib")
		CreateGuid = Mid( g_TypeLib.Guid, 2, 36 )
	End IF
End Function


 
'*************************************************************************
'  <<< [new_RegExp] >>> 
'*************************************************************************
Function  new_RegExp( Pattern, IsCaseSensitive )
	Set re = CreateObject("VBScript.RegExp")
	re.Pattern = Pattern
	re.MultiLine = True
	re.Global = True
	re.IgnoreCase = not IsCaseSensitive
	Set new_RegExp = re
End Function


 
'*************************************************************************
'  <<< [FindStringLines] >>> 
'*************************************************************************
Function  FindStringLines( InputString, ByVal RegExpObject, Option_ )

	If VarType( RegExpObject ) = vbString Then
		Set re = CreateObject("VBScript.RegExp")
		re.Pattern = RegExpObject
	Else
		Set re = RegExpObject
	End If

	If VarType( Option_ ) = vbBoolean Then
		is_match = Option_
	Else
		is_match = True
	End IF

	FindStringLines = ""

	left_ = 1
	Do
		right_ = InStr( left_, InputString, vbLF )
		If right_ = 0 Then
			line = Mid( InputString, left_ )
		Else
			line = Mid( InputString, left_, right_ - left_ + 1 )
		End If

		If re.Test( line ) = is_match Then
			FindStringLines = FindStringLines + line
		End If

		If right_ = 0 Then _
			Exit Do

		left_ = right_ + 1
	Loop
End Function


 
'*************************************************************************
'  <<< [SortStringLines] >>> 
'*************************************************************************
Function  SortStringLines( in_InputString,  in_IsDuplicated )

	'// Set "lines"
	ReDim  lines(-1)
	lines_fast_ubound = UBound( lines )

	left_ = 1
	Do
		'// Set "line_object"
		Set line_object = new NameOnlyClass

		right_ = InStr( left_, in_InputString, vbLF )
		If right_ = 0 Then

			'// Exit
			If left_ > Len( in_InputString ) Then _
				Exit Do

			'// Set "line_feed"
			right1 = InStr( in_InputString,  vbLF )
			If right1 = 0 Then
				SortStringLines = in_InputString
				Exit Function
			End If
			line_feed = vbLF
			If right1 >= 2 Then
				If Mid( in_InputString,  right1 - 1,  1 ) = vbCR Then
					line_feed = vbCRLF
				End If
			End If

			'// ...
			line_object.Name = Mid( in_InputString,  left_ ) + line_feed
		Else
			line_object.Name = Mid( in_InputString,  left_,  right_ - left_ + 1 )
		End If


		'// Add to "lines"
		If UBound( lines ) <= lines_fast_ubound Then _
			ReDim Preserve  lines( ( lines_fast_ubound + 100 ) * 4 )
		lines_fast_ubound = lines_fast_ubound + 1
		Set lines( lines_fast_ubound ) = line_object


		'// Exit
		If right_ = 0 Then _
			Exit Do

		left_ = right_ + 1
	Loop
	ReDim Preserve  lines( lines_fast_ubound )


	'// ...
	QuickSort  lines, 0, UBound( lines ), GetRef( "NameCompare" ), Empty


	'// Make return value
	If in_IsDuplicated Then
		For Each  line_object  In lines
			SortStringLines = SortStringLines + line_object.Name
		Next
	Else
		For Each  line_object  In lines
			line = line_object.Name
			If Right( line, 2 ) <> vbCRLF Then _
				line = Left( line,  Len( line ) - 1 ) + vbCRLF

			If line <> previous_line Then
				SortStringLines = SortStringLines + line_object.Name
				previous_line = line
			End If
		Next
	End If
End Function


 
'*************************************************************************
'  <<< [ReplaceTextFile] >>> 
'*************************************************************************
Class  ReplaceItem
	Public  Src
	Public  Dst
End Class

Sub  new_ReplaceItem( objs, n )
	ThisIsOldSpec
	new_ReplaceItem_array  objs, n
End Sub

Sub  new_ReplaceItem_array( objs, n )
	Dim i:ReDim objs(n-1):For i=0 To n-1:Set objs(i)=new ReplaceItem :Next : ErrCheck
End Sub

Sub  ReplaceTextFile( SrcPath, TmpDstPath, bDstWillBeExist, ReplaceList, Opt )
	echo  ">ReplaceTextFile  """ & SrcPath & """, """ & TmpDstPath & """, " & bDstWillBeExist
	Dim rep, item, line, b

	b = False
	Set rep = StartReplace( SrcPath, TmpDstPath, bDstWillBeExist )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine
		For Each  item  In ReplaceList
			If InStr( line, item.Src ) > 0 Then  b = True
			line = Replace( line, item.Src, item.Dst )
		Next
		rep.w.WriteLine  line
	Loop
	If b Then
		rep.Finish
	Else
		rep.ExitFinish  Empty
	End If
End Sub


 
'*************************************************************************
'  <<< [OpenForReplace] >>> 
'*************************************************************************
Function  OpenForReplace( SrcPath, DstPath )
	echo  ">OpenForReplace  """& SrcPath &""", """& DstPath &""""
	AssertExist  SrcPath
	Set OpenForReplace = new ReplaceTextFile1 : Set o = OpenForReplace
	o.DstPath = DstPath : If IsEmpty( DstPath ) Then  o.DstPath = SrcPath
	o.Text = ReadFile( SrcPath )
	o.CS = AnalyzeCharacterCodeSet( SrcPath )
	o.IsSaveInTerminate = Empty
End Function


Class  ReplaceTextFile1
	Public  DstPath
	Public  Text
	Public  CS  '// CharacterCodeSet
	Public  IsSaveInTerminate

	Public Sub  Replace( FromText, ToText )  '//[ReplaceTextFile1::Replace]
		If IsObject( FromText ) Then  '// RegExp
			Me.Text = FromText.Replace( Me.Text, ToText )
		Else
			If InStr( ToText, FromText ) > 0 Then  '// if FromText is part of ToText
				If InStr( Me.Text, ToText ) > 0 Then  Exit Sub
			End If
			Me.Text = ReplaceTextFile1_replace( Me.Text, FromText, ToText )
		End If
	End Sub


	Public Sub  ReplaceRange( StartOfFromText, EndOfFromText, ToText )  '//[ReplaceTextFile1::ReplaceRange]
		start_pos = InStr( Me.Text, StartOfFromText )
		If start_pos = 0 Then  Exit Sub

		end_pos = InStr( start_pos + Len( StartOfFromText ),  Me.Text,  EndOfFromText )
		If end_pos = 0 Then  Raise  E_NotFoundSymbol, _
			"<ERROR msg=""終了タグが見つかりません"" tag="""+ EndOfFromText +"""/>"

		Me.Text = Left( Me.Text, start_pos - 1 ) + ToText + Mid( Me.Text, end_pos + Len( EndOfFromText ) )
	End Sub


	Public Sub  Close()
		If Err.Number = 0  and  g_Err2.Number = 0 Then
			Set ec = new EchoOff
			Set cs_ = new_TextFileCharSetStack( Me.CS )
			CreateFile  Me.DstPath,  Me.Text
		End If
	End Sub


	Private Sub  Class_Terminate()
		If IsEmpty( Me.IsSaveInTerminate ) Then _
			Me.IsSaveInTerminate = ( Err.Number = 0 )
		If Me.IsSaveInTerminate Then
			Me.Close
		End If
	End Sub
End Class


Function  ReplaceTextFile1_replace( Text, From, To_ )
	ReplaceTextFile1_replace = Replace( Text, From, To_ )
End Function


 
'*************************************************************************
'  <<< [StartReplace] >>> 
'*************************************************************************
Function  StartReplace( SrcPath, TmpDstPath, IsDstWillBeExist )
	echo  ">StartReplace  """ & SrcPath & """, """ & TmpDstPath & """, " & IsDstWillBeExist
	Dim  ec : Set ec = new EchoOff : ErrCheck
	Dim  m : Set m = new StartReplaceObj : ErrCheck
	Dim  ls

	If IsEmpty( g_FileOptions.LineSeparator ) Then
		Set ls = new_TextFileLineSeparatorStack( g_VBS_Lib.KeepLineSeparators )
	End If
	m.Init1  SrcPath, TmpDstPath, IsDstWillBeExist
	Set StartReplace = m
End Function


 
'*************************************************************************
'  <<< [StartReplace2] >>> 
'*************************************************************************
Function  StartReplace2( SrcPath, MidPath, Flags, TmpDstPath, bDstWillBeExist )
	echo  ">StartReplace2  """ & SrcPath & """, """ & MidPath & """, """ & TmpDstPath & """, " & bDstWillBeExist
	Dim  ec : Set ec = new EchoOff : ErrCheck
	Dim  m : Set m = new StartReplaceObj : ErrCheck
	m.Init2  SrcPath, MidPath, Flags, TmpDstPath, bDstWillBeExist
	Set StartReplace2 = m
End Function


Dim  F_Txt2BinTxt : F_Txt2BinTxt = 2


Class  StartReplaceObj
	Public  SrcPath           '// as string
	Public  TmpDstPath        '// as string
	Public  IsDstWillBeExist  '// as boolean

	Public  MidPath      '// as string
	Public  Flags        '// as bitfield

	Public  r  '// as TextStream of SrcPath
	Public  w  '// as TextStream of TmpDstPath

	Private  IsFinished


'// [StartReplaceObj::Init1]
Public Sub  Init1( SrcPath, TmpDstPath, IsDstWillBeExist )
	Dim  en, ed, n_retry
	Dim  ec : Set ec = new EchoOff : ErrCheck
	Dim  c : Set c = g_VBS_Lib

	If IsDstWillBeExist = c.DstIsBackUp Then
		copy_ren  SrcPath, TmpDstPath
		Me.SrcPath = TmpDstPath
		Me.TmpDstPath = SrcPath
	Else
		Me.SrcPath = SrcPath
		Me.TmpDstPath = TmpDstPath
	End If
	Me.IsDstWillBeExist = IsDstWillBeExist

	Set Me.r = OpenForRead( Me.SrcPath )

	Dim  cs : Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( Me.SrcPath ) )
	Set Me.w = OpenForWrite( Me.TmpDstPath, Empty )
	If g_FileOptions.LineSeparator = g_VBS_Lib.KeepLineSeparators Then  If ReadLineSeparator( Me.SrcPath ) = vbLF Then _
		Me.w.LineSeparator = vbLF
End Sub


'// [StartReplaceObj::Init2]
Public Sub  Init2( SrcPath, MidPath, Flags, TmpDstPath, IsDstWillBeExist )
	Init1  SrcPath, MidPath, IsDstWillBeExist
	Me.MidPath = MidPath
	Me.TmpDstPath = TmpDstPath
	Me.Flags = Flags or 1
End Sub


'// [StartReplaceObj::Finish]
Public Sub  Finish()
	Dim  ec : Set ec = new EchoOff : ErrCheck
	Me.r = Empty
	Me.w = Empty

	If not IsEmpty( Me.MidPath ) Then
		If Me.Flags and F_Txt2BinTxt Then
			Txt2BinTxt  Me.MidPath, Me.TmpDstPath
		Else
			copy_ren  Me.MidPath, Me.TmpDstPath
		End If
		del  Me.MidPath
	End If

	If Me.IsDstWillBeExist = False Then
		copy_ren  Me.TmpDstPath, Me.SrcPath
		del   Me.TmpDstPath
	End If
	IsFinished = True  '// Me.IsFinished
End Sub


'// [StartReplaceObj::ExitFinish]
Public Sub  ExitFinish( Opt )
	IsFinished = True  '// Me.IsFinished
	Class_Terminate
	If not IsEmpty( Me.MidPath ) Then  del  Me.MidPath
	del  Me.TmpDstPath
End Sub


'// [StartReplaceObj::Class_Terminate]
Private Sub  Class_Terminate()
	Dim  en,ed : en = Err.Number : ed = Err.Description
	Dim  c : Set c = g_VBS_Lib
	On Error Resume Next  ' This clears the error
		Me.r = Empty
		Me.w = Empty
		If en <> 0 and en <> 21 and  not IsFinished Then  '// Me.IsFinished
			If Me.IsDstWillBeExist = c.DstIsBackUp Then
				copy_ren  Me.SrcPath, Me.TmpDstPath
				del  Me.SrcPath
			Else
				del  Me.TmpDstPath
			End If
		End If
		ErrorCheckInTerminate  en
	If en = 0 and not IsFinished Then  NotCallFinish  '// Me.IsFinished
	On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed
End Sub


End Class


 
'*************************************************************************
'  <<< [SplitLineAndCRLF] >>> 
'*************************************************************************
Sub  SplitLineAndCRLF( in_LineAndCRLF,  out_Line,  out_CRLF )
	If Right( in_LineAndCRLF, 2 ) = vbCRLF Then
		out_Line = Left( in_LineAndCRLF,  Len( in_LineAndCRLF ) - 2 )
		out_CRLF = vbCRLF
	ElseIf Right( in_LineAndCRLF,  1 ) = vbLF Then
		out_Line = Left( in_LineAndCRLF,  Len( in_LineAndCRLF ) - 1 )
		out_CRLF = vbLF
	Else
		out_Line = in_LineAndCRLF
		out_CRLF = ""
	End If
End Sub


 
'*************************************************************************
'  <<< [PassThroughLineFilters] >>> 
'*************************************************************************
Sub  PassThroughLineFilters( SrcPath, TmpDstPath, IsDstWillBeExist, Opt, FilterArray )
	Dim rep, line, check_line
	Dim is_not

	ThisIsOldSpec  '// Use "FindStringLines"

	echo  ">PassThroughLineFilters  """+ SrcPath +""", """& TmpDstPath &""""
	Dim  ec : Set ec = new EchoOff

	If IsEmpty( Opt ) Then  is_not = False  Else  is_not = not Opt

	Set rep = StartReplace( SrcPath, TmpDstPath, IsDstWillBeExist )
	Do Until rep.r.AtEndOfStream
		line = rep.r.ReadLine()

		If not is_not Then
			For Each  check_line  In FilterArray
				If InStr( line, check_line ) > 0 Then
					rep.w.WriteLine  line
					Exit For
				End IF
			Next
		Else
			For Each  check_line  In FilterArray
				If InStr( line, check_line ) > 0 Then  Exit For
			Next
			If IsEmpty( check_line ) Then _
				rep.w.WriteLine  line
		End If
	Loop
	rep.Finish
End Sub


 
'*************************************************************************
'  <<< [g_FileOptions] >>> 
'*************************************************************************
Dim  g_FileOptions
Class  FileOptionsClass
	Public Property Get  CharSet : CharSet = m_CharSet : End Property  '// as lower case string.  ADODB.Stream.Charset
	Public Property Get  CharSetEx : CharSetEx = m_CharSetEx : End Property  '// as Empty, c.UTF_8_No_BOM
	Public Property Get  LineSeparator : LineSeparator = m_LineSeparator : End Property  '// as ADODBConsts.Keep
	Public Property Get  IsSafeFileUpdate : IsSafeFileUpdate = m_IsSafeFileUpdate : End Property  '// as boolean

	Private  m_CharSet
	Private  m_CharSetEx
	Private  m_LineSeparator
	Private  m_IsSafeFileUpdate

	Public Sub  SetCharSetPrivate(x,y) : m_CharSet = x : m_CharSetEx = y : End Sub
	Public Sub  SetLineSeparatorPrivate(x) : m_LineSeparator = x : End Sub
	Public Sub  SetIsSafeFileUpdatePrivate(x) : m_IsSafeFileUpdate = x : End Sub
End Class


 
'*************************************************************************
'  <<< [new_TextFileCharSetStack] >>> 
'*************************************************************************
Function  new_TextFileCharSetStack( CharSet )
	Set new_TextFileCharSetStack = new TextFileCharSetStack
	new_TextFileCharSetStack.Set_  CharSet
End Function

Class  TextFileCharSetStack
	Public  m_Prev, m_PrevEx
	Private Sub  Class_Initialize() : m_Prev = g_FileOptions.CharSet : m_PrevEx = g_FileOptions.CharSetEx : End Sub
	Public  Sub  Set_( ByVal CharSet )
		Dim  c : Set c = g_VBS_Lib
		If CharSet = c.Unicode      Then  CharSet = "unicode"
		If CharSet = c.UTF_8        Then  CharSet = "utf-8"
		If CharSet = c.UTF_8_No_BOM Then  CharSet = "utf-8-no-bom"
		If CharSet = c.Shift_JIS    Then  CharSet = "shift_jis"
		If CharSet = c.EUC_JP       Then  CharSet = "euc_jp"
		If CharSet = c.ISO_2022_JP  Then  CharSet = "ISO-2022-JP"
		If CharSet = c.No_BOM       Then  CharSet = "shift_jis"

		If VarType( CharSet ) <> vbString Then  CharSet = Empty
		Select Case  LCase( CharSet )
			Case "utf-8-no-bom" : g_FileOptions.SetCharSetPrivate  "utf-8", c.UTF_8_No_BOM
			Case ""   : g_FileOptions.SetCharSetPrivate  Empty, Empty
			Case Else : g_FileOptions.SetCharSetPrivate  LCase( CharSet ), Empty
		End Select
	End Sub
	Private Sub Class_Terminate : g_FileOptions.SetCharSetPrivate  m_Prev, m_PrevEx : End Sub
End Class


 
'*************************************************************************
'  <<< [new_TextFileLineSeparatorStack] >>> 
'*************************************************************************
Function  new_TextFileLineSeparatorStack( LineSeparator )
	Set new_TextFileLineSeparatorStack = new TextFileLineSeparatorStack
	new_TextFileLineSeparatorStack.Set_  LineSeparator
End Function

Class  TextFileLineSeparatorStack
	Public  m_Prev
	Private Sub  Class_Initialize() : m_Prev = g_FileOptions.LineSeparator : End Sub
	Public  Sub  Set_( ByVal LineSeparator )
		Dim  c : Set c = g_VBS_Lib
		If LineSeparator = vbCRLF  Then  LineSeparator = c.CRLF
		If LineSeparator = vbLF    Then  LineSeparator = c.LF

		g_FileOptions.SetLineSeparatorPrivate  LineSeparator
	End Sub
	Private Sub Class_Terminate : g_FileOptions.SetLineSeparatorPrivate  m_Prev : End Sub
End Class


 
'*************************************************************************
'  <<< [new_IsSafeFileUpdateStack] >>> 
'*************************************************************************
Function  new_IsSafeFileUpdateStack( IsEnabled )
	Set new_IsSafeFileUpdateStack = new IsSafeFileUpdateStack
	new_IsSafeFileUpdateStack.Set_  IsEnabled
End Function

Class  IsSafeFileUpdateStack
	Public  m_Prev
	Private Sub  Class_Initialize() : m_Prev = g_FileOptions.IsSafeFileUpdate : End Sub
	Public  Sub  Set_( IsEnabled )
		g_FileOptions.SetIsSafeFileUpdatePrivate  IsEnabled
	End Sub
	Private Sub Class_Terminate : g_FileOptions.SetIsSafeFileUpdatePrivate  m_Prev : End Sub
End Class


 
'*************************************************************************
'  <<< [ConvertBinaryEmulated] >>> 
'*************************************************************************
Sub  ConvertBinaryEmulated( SrcPath, TmpDstPath, bDstWillBeExist, ExpectedBeforePath, ExpectedAfterPath )
	If not fc( SrcPath, ExpectedBeforePath ) Then
		OpenFolder  GetParentFullPath( SrcPath )
		OpenFolder  GetParentFullPath( ExpectedBeforePath )
		Raise  1,"<ERROR msg='converting source file is not same' src='"+ XmlAttrA( SrcPath ) +_
			"' expected='"+ XmlAttrA( ExpectedBeforePath ) +"'/>"
	End If

	If bDstWillBeExist Then
		copy_ren  ExpectedAfterPath, TmpDstPath
	Else
		copy_ren  ExpectedAfterPath, SrcPath
	End If
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [ArrayClass] Class >>>> 
'-------------------------------------------------------------------------

Class  ArrayClass
	Public  Items '// as array

	Private Sub  Class_Initialize() : ReDim  Items( -1 ) : End Sub

	Public Default Property Get  Item( i )
		If IsEmpty( Me.ItemFunc ) Then  LetSet  Item, Items(i)  Else  LetSet  Item, Me.ItemFunc( Me.Items, i )
	End Property
	Public Property Let  Item( i, Value ) : Items(i) = Value : End Property
	Public Property Set  Item( i, Object ) : Set Items(i) = Object : End Property
	Public  ItemFunc  '// as Function ( Items as Array, Name as variant ) as variant

		Public Property Get  m_Array() : ThisIsOldSpec : m_Array = Items : End Property
		'//Public Property Get  m_Array(i) '// Can not define. then Me.m_Array(i) can not be used.


	Public Sub  ToEmpty()
		ReDim  Items( -1 )
	End Sub


	'// [ArrayClass::NewIterator]
	Public Function  NewIterator()
		Set NewIterator = new ArrayClassIterator : With NewIterator
			Set .Collection = Me
			.Index = -1
			.LastIndex = UBound( Items )
		End With
	End Function


	'// [ArrayClass::ReDim_]
	Public Sub  ReDim_( UBoundValue )
		ReDim Preserve  Items( UBoundValue )
	End Sub


	'// [ArrayClass::Add]
	Public Sub  Add( Elem )
		ReDim Preserve  Items( UBound(Items) + 1 )
		If IsObject( Elem ) Then
			Set Items( UBound(Items) ) = Elem
		Else
			Items( UBound(Items) ) = Elem
		End If
	End Sub


	'// [ArrayClass::AddNewObject]
	Public Function  AddNewObject( ClassName, ObjectName )
		Set AddNewObject = new_X( ClassName )
		Me.Push  AddNewObject
		If g_Vers("CutPropertyM") Then
			AddNewObject.Name = ObjectName
		Else
			AddNewObject.m_Name = ObjectName
		End If
	End Function


	'// [ArrayClass::Insert]
	Public Sub  Insert( i_Before, Elem )
		Dim  x, i
		If IsEmpty( i_Before ) Then
			Me.Add  Elem
		ElseIf i_Before = UBound(Items) + 1 Then
			Me.Add  Elem
		Else
			ReDim Preserve  Items( UBound(Items) + 1 )

			If IsObject( Items( i_Before ) ) Then
				For  x = UBound(Items) - 1  To  i_Before  Step  -1
					Set Items( x + 1 ) = Items( x )
				Next
				Set Items( i_Before ) = Elem
			Else
				For  x = UBound(Items) - 1  To  i_Before  Step  -1
					Items( x + 1 ) = Items( x )
				Next
				Items( i_Before ) = Elem
			End If
		End If
	End Sub


	'// [ArrayClass::Push]
	Public Sub  Push( Elem ) : Add  Elem : End Sub


	'// [ArrayClass::Pop]
	Public Function  Pop()
		If IsObject( Items( UBound(Items) ) ) Then
			Set Pop = Items( UBound(Items) )
		Else
			Pop = Items( UBound(Items) )
		End If
		ReDim Preserve  Items( UBound(Items) - 1 )
	End Function


	'// [ArrayClass::Remove]
	Public Sub  Remove( i, n )
		Dim  x
		If IsObject( Items(i) ) Then
			For x=i To UBound(Items) - n
				Set Items( x ) = Items( x + n )
			Next
		Else
			For x=i To UBound(Items) - n
				Items( x ) = Items( x + n )
			Next
		End If
		ReDim Preserve  Items( UBound(Items) - n )
	End Sub


	'// [ArrayClass::RemoveObject]
	Public Function  RemoveObject( a_Object )
		u = UBound( Items )
		For i=0 To u
			If Items(i) is a_Object Then
				Set RemoveObject = a_Object
				For j=i+1 To u
					Set Items(j-1) = Items(j)
				Next
				ReDim Preserve  Items(u-1)
				Exit Function
			End If
		Next
		Set RemoveObject = Nothing
	End Function


	'// [ArrayClass::RemoveMatched]
	Public Sub  RemoveMatched( in_Item,  in_CompareFunction,  in_ParameterOfCompareFunction, _
			in_IsErrorIfNotFound,  in_IsMultiRemove )

		If not in_IsMultiRemove Then
			i = Me.Search( in_Item,  in_CompareFunction,  in_ParameterOfCompareFunction,  0 )
			If in_IsErrorIfNotFound Then _
				If IsEmpty( i ) Then _
					Err.Raise  E_NotFoundSymbol
			Me.Remove  i, 1
		Else
			indexes = Me.Search( in_Item,  in_CompareFunction,  in_ParameterOfCompareFunction,  Empty )
			Me.RemoveByIndexes  indexes

			If in_IsErrorIfNotFound Then _
				If UBound( indexes ) = -1 Then _
					Err.Raise  E_NotFoundSymbol
		End If
	End Sub


	'// [ArrayClass::RemoveByIndexes]
	Public Sub  RemoveByIndexes( in_Indexes )
		For Each  an_index  In  in_Indexes
			Items( an_index ) = Empty
		Next

		Me.RemoveEmpty
	End Sub


	'// [ArrayClass::RemoveEmpty]
	Public Sub  RemoveEmpty()
		Dim  i, j, u : u = UBound( Items )

		For i=0 To u
			If IsEmpty( Items(i) ) Then  j=i : Exit For
		Next
		If IsEmpty( j ) Then  Exit Sub

		For i=i+1 To u
			If not IsEmpty( Items(i) ) Then
				If IsObject( Items(i) ) Then
					Set Items(j) = Items(i)
				Else
					Items(j) = Items(i)
				End If
				j=j+1
			End If
		Next
		ReDim Preserve  Items(j-1)
	End Sub


	'// [ArrayClass::Search]
	Function  Search( in_KeyItem,  in_CompareFunction,  in_ParameterOfCompareFunction,  in_StartIndexOrEmpty )
		ReDim  new_array( UBound( Me.Items ) )
		k=0
		If IsEmpty( in_StartIndexOrEmpty ) Then
			i = 0
		Else
			i = in_StartIndexOrEmpty
		End If
		For i=i  To  UBound( new_array )
			If in_CompareFunction( Me.Items(i),  in_KeyItem,  in_ParameterOfCompareFunction ) = 0 Then
				If not IsEmpty( in_StartIndexOrEmpty ) Then
					Search = i
					Exit Function
				End If

				new_array(k) = i
				k=k+1
			End If
		Next
		If IsEmpty( in_StartIndexOrEmpty ) Then
			ReDim Preserve  new_array(k-1)
			Search = new_array
		End If
	End Function


	'// [ArrayClass::Count]
	Public Property Get  Count() : Count = UBound(Items) + 1 : End Property
	Public Property Get  Length() : Length = UBound(Items) + 1 : End Property
	Public Property Get  UBound_() : UBound_ = UBound(Items) : End Property

	Public Sub  Echo() : ThisIsOldSpec : WScript.Echo  xml : End Sub
	Public Property Get  Value() : ThisIsOldSpec : Value = xml : End Property


	'// [ArrayClass::xml]
	Public Property Get  xml() : xml = xml_sub(0) : CutLastOf xml, vbCRLF, Empty : End Property
	Public Function  xml_sub( Level )
		Dim  s, i

		s = GetTab( Level ) +"<ArrayClass count="""& Count &""">"+vbCRLF
		For i=0 To UBound( Items )
			s = s + GetTab( Level+1 )+ "<Item id="""& i &""">"& Trim( GetEchoStr_sub( Items(i), Level+1 ) )
			CutLastOf  s, vbCRLF, Empty
			s = s + "</Item>" +vbCRLF
		Next
		s = s + GetTab( Level ) +"</ArrayClass>"+ vbCRLF
		xml_sub = s
	End Function


	'// [ArrayClass::CSV]
	Public Property Get  CSV()
		CSV = CSVFrom( Me.Items )
	End Property


	'// [ArrayClass::AddCSV]
	Public Sub  AddCSV( CSV, Type_ )
		Dim  s, i : i = 1
		If Trim2( CSV ) = "" Then  Exit Sub
		Do
			s = MeltCSV( CSV, i )
			If IsEmpty( s ) Then
				Me.Add  Empty
			Else
				Select Case  Type_
					Case vbInteger:  Me.Add  CInt2( s )
					Case Else:       Me.Add  s
				End Select
			End If
			If i = 0 Then Exit Do
		Loop
	End Sub


	'// [ArrayClass::Code]
	Public Property Get  Code()
		Dim  i, n
		For Each i In Me.Items
			If not IsEmpty( Code ) Then  Code = Code +", _"+ vbCRLF
			If VarType( i ) = vbString Then
				Code = Code & """" & Replace( i, """", """""" ) & """"
			Else
				Code = Code & i
			End If
		Next
	End Property


	'// [ArrayClass::Copy]
	Public Sub  Copy( SrcArr )
		If IsArray( SrcArr ) Then
			Items = SrcArr
		ElseIf TypeName( SrcArr ) = "ArrayClass" Then
			Items = SrcArr.Items
		Else
			Err.Raise  1
		End If
	End Sub


	'// [ArrayClass::AddElems]
	Public Sub  AddElems( SrcArr )
		If IsArray( SrcArr ) Then
			AddArrElem  Items, SrcArr
		ElseIf TypeName( SrcArr ) = "ArrayClass" Then
			AddArrElem  Items, SrcArr.Items
		Else
			Me.Add  SrcArr
		End If
	End Sub


	'// [ArrayClass::LookUpDic]
	Public Function  LookUpDic( Key, Value )
		Dim  dic
		For Each dic  In Items
			If dic.Item( Key ) = Value Then  Set LookUpDic = dic : Exit Function
		Next
		Set LookUpDic = Nothing
	End Function
End Class


'*************************************************************************
'  <<< [new_ArrayClass] >>>
'*************************************************************************
Function  new_ArrayClass( a_Array )
	Set  new_ArrayClass = new ArrayClass
	new_ArrayClass.AddElems  a_Array
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [ArrayClassIterator] Class >>>> 
'-------------------------------------------------------------------------

Class  ArrayClassIterator
	Public  Collection ' as ArrayClass
	Public  Index ' as integer
	Public  LastIndex ' as integer

	Private Sub  Class_Initialize()
		Me.Index = -1
		Me.LastIndex = -1
	End Sub

	Public Function  GetNext()
		Me.Index = Me.Index + 1
		LetSet  GetNext, Me.Collection( Me.Index )
	End Function

	Public Function  HasNext()
		HasNext = ( Index < LastIndex )
	End Function

	Public Function  GetNextOrSentinel( Sentinel )
		Me.Index = Me.Index + 1
		If Index > LastIndex Then
			LetSet  GetNextOrSentinel, Sentinel
		Else
			LetSet  GetNextOrSentinel, Me.Collection( Me.Index )
		End If
	End Function
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [ArrayDictionary] Class >>>> 
'-------------------------------------------------------------------------

Class  ArrayDictionary

	Public  Dic  ' as Dictionary of ArrayClass

	Private Sub  Class_Initialize
		Set  Me.Dic = CreateObject("Scripting.Dictionary")
	End Sub

	Public Sub  ToEmpty
		Me.Dic.RemoveAll
	End Sub

	Public Sub  Add( key, item )
		Dim  dic_item

		If Me.Dic.Exists( key ) Then
			Me.Dic.Item( key ).Add  item
		Else
			Set  dic_item = new ArrayClass : ErrCheck
			dic_item.Add  item
			Me.Dic.Add  key, dic_item
		End If
	End Sub

	Public Function  Count
		Dim  i
		Count = 0
		For Each i in Me.Dic.Items()
			Count = Count + i.Count
		Next
	End Function

	Public Sub  Echo
		Dim  i, n

		WScript.Echo  "--- ArrayDictionary ------------------------------"
		WScript.Echo  "key  count = " & Me.Dic.Count

		WScript.Echo  "item count = " & Count

		For Each i in Me.Dic.Keys()
			WScript.Echo  "key=""" & i & """"
			WScript.Echo  Me.Dic.Item(i).xml
		Next
		WScript.Echo ""
	End Sub

End Class


 
'***********************************************************************
'* Function: BreadthFirstSearch
'***********************************************************************
Sub  BreadthFirstSearch( in_Array, in_FirstIndex, out_QueuedNodes, in_CompareFunction, ref_ParameterOfCompareFunction, _
	in_Option )

	If IsBitNotSet( in_Option, g_VBS_Lib.NotResetFoundFlag ) Then _
		ResetSearchDataOfGraphVertex  in_Array

	ReDim  out_QueuedNodes( UBound( in_Array ) )
	queued_index = 0
	out_QueuedNodes( 0 ) = in_FirstIndex
	Set vertex = in_Array( in_FirstIndex )
	vertex.ParentIndex = Null

	order = 0
	Do
		index = out_QueuedNodes( order )
		Set vertex = in_Array( index )

		If IsNull( vertex.ParentIndex ) Then
			parent = Empty
		Else
			Set parent = in_Array( vertex.ParentIndex )
		End If


		If not IsEmpty( in_CompareFunction ) Then
			r = in_CompareFunction( parent, vertex, ref_ParameterOfCompareFunction )
			If r = 0 Then _
				Exit Do
		End If


		For Each  adjacent_index  In  vertex.AdjacentIndexes
			Set adjacent_node = in_Array( adjacent_index )
			If IsEmpty( adjacent_node.ParentIndex ) Then
				queued_index = queued_index + 1
				out_QueuedNodes( queued_index ) = adjacent_index
				adjacent_node.ParentIndex = index
			End If
		Next

		order = order + 1
		If order > queued_index Then _
			Exit Do
	Loop

	ReDim Preserve  out_QueuedNodes( queued_index )
End Sub


 
'***********************************************************************
'* Function: SearchSubGraphs
'***********************************************************************
Function  SearchSubGraphs( in_Array, in_Empty )
	Set out = new ArrayClass
	ResetSearchDataOfGraphVertex  in_Array

	For  first_index = 0  To  UBound( in_Array )
		If IsEmpty( in_Array( first_index ).ParentIndex ) Then
			BreadthFirstSearch  in_Array,  first_index,  index_array,  Empty, Empty, _
				g_VBS_Lib.NotResetFoundFlag
			out.Add  index_array
		End If
	Next
	SearchSubGraphs = out.Items
End Function


 
'***********************************************************************
'* Function: DepthFirstSearch
'***********************************************************************
Sub  DepthFirstSearch( in_Array, in_FirstIndex, _
		in_CompareFunction, ref_ParameterOfCompareFunction, _
		in_Option )

	If IsBitNotSet( in_Option, g_VBS_Lib.NotResetFoundFlag ) Then _
		ResetSearchDataOfGraphVertex  in_Array

	ReDim  stack( UBound( in_Array ) )
	stacked_count = 1
	stack( 0 ) = in_FirstIndex
	Set vertex = in_Array( in_FirstIndex )
	vertex.ParentIndex = Null

	Do
		stacked_count = stacked_count - 1
		index = stack( stacked_count )
		Set vertex = in_Array( index )

		If IsNull( vertex.ParentIndex ) Then
			parent = Empty
		Else
			Set parent = in_Array( vertex.ParentIndex )
		End If


		If not IsEmpty( in_CompareFunction ) Then
			r = in_CompareFunction( parent, vertex, ref_ParameterOfCompareFunction )
			If r = 0 Then _
				Exit Do
		End If


		next_stacked_count_max = stacked_count + UBound( vertex.AdjacentIndexes ) + 1
		stacked_index = next_stacked_count_max
		For Each  adjacent_index  In  vertex.AdjacentIndexes
			Set adjacent_node = in_Array( adjacent_index )
			If IsEmpty( adjacent_node.ParentIndex ) Then
				stacked_index = stacked_index - 1
				stack( stacked_index ) = adjacent_index
				adjacent_node.ParentIndex = index
			End If
		Next
		If stacked_index = stacked_count Then
			stacked_count = next_stacked_count_max
		Else
			While  stacked_index < next_stacked_count_max
				stack( stacked_count ) = stack( stacked_index )

				stacked_count = stacked_count + 1
				stacked_index = stacked_index + 1
			WEnd
		End If

	Loop While  stacked_count >= 1
End Sub


 
'***********************************************************************
'* Function: GetDistanceInGraph
'***********************************************************************
Function  GetDistanceInGraph( in_Array, in_Index )
	index = in_Index
	level = 0
	Do
		index = in_Array( index ).ParentIndex
		If IsNull( index ) Then _
			Exit Do
		level = level + 1
	Loop
	GetDistanceInGraph = level
End Function


 
'***********************************************************************
'* Class: GraphVertexClass
'***********************************************************************
Class  GraphVertexClass
	Public  Item  '// as variant
	Public  Index '// as integer
	Public  AdjacentIndexes  '// as array of integer
	Public  Edges            '// as array of variant
	Public  ParentIndex  '// as integer or Empty (=not queued) or Null (=first vertex)

	Private Sub  Class_Initialize()
		Me.AdjacentIndexes = Array( )
		Me.Edges = Array( )
	End Sub

	Public Sub  AddToAdjacentIndexes( in_NewUBound, in_AdjacentIndex )
		ReDim Preserve  AdjacentIndexes( in_NewUBound )  '// Me.AdjacentIndexes
		Me.AdjacentIndexes( in_NewUBound ) = in_AdjacentIndex
	End Sub

	Public Sub  AddToEdges( in_NewUBound, in_EdgeObject )
		ReDim Preserve  Edges( in_NewUBound )  '// Me.Edges
		If IsObject( in_EdgeObject ) Then
			Set Me.Edges( in_NewUBound ) = in_EdgeObject
		Else
			Me.Edges( in_NewUBound ) = in_EdgeObject
		End If
	End Sub

	Public Function  GetEdge( in_TargetIndex, in_EdgeIfNotFound )
		For i=0 To UBound( Me.AdjacentIndexes )
			If Me.AdjacentIndexes( i ) = in_TargetIndex Then
				LetSet  GetEdge, Me.Edges( i )
				Exit Function
			End If
		Next
		LetSet GetEdge, in_EdgeIfNotFound
	End Function

	Public Sub  RemoveEdge( in_TargetIndex )
		Error  '// AdjacentIndexes の調整ができていません
		For i=0 To UBound( Me.AdjacentIndexes )
			If Me.AdjacentIndexes( i ) = in_TargetIndex Then
				i_ubound = UBound( Me.AdjacentIndexes )
				Me.AdjacentIndexes( i ) = Me.AdjacentIndexes( i_ubound )
				If IsObject( Me.Edges( i_ubound ) ) Then
					Set Me.Edges( i ) = Me.Edges( i_ubound )
				Else
					Me.Edges( i ) = Me.Edges( i_ubound )
				End If
				i_ubound = i_ubound - 1
				ReDim Preserve  AdjacentIndexes( i_ubound )  '// Me.AdjacentIndexes
				ReDim Preserve  Edges( i_ubound )  '// Me.Edges
				Exit Sub
			End If
		Next
	End Sub
End Class


 
'***********************************************************************
'* Function: GetDirectionIndex
'***********************************************************************
Function  GetDirectionIndex( in_TargetVertexIndex, in_OppositeVertexIndex )
	If in_TargetVertexIndex <= in_OppositeVertexIndex Then
		GetDirectionIndex = 0
	Else
		GetDirectionIndex = 1
	End If
End Function


 
'***********************************************************************
'* Function: CreateGraphVertex
'***********************************************************************
Function  CreateGraphVertex( in_out_Graph )
	Set CreateGraphVertex = new GraphVertexClass
	ReDim Preserve  in_out_Graph( UBound( in_out_Graph ) + 1 )
		'// in_out_Graph must be initialized by Array( )
	Set in_out_Graph( UBound( in_out_Graph ) ) = CreateGraphVertex
	CreateGraphVertex.Index = UBound( in_out_Graph )
End Function


 
'***********************************************************************
'* Function: ResetSearchDataOfGraphVertex
'***********************************************************************
Sub  ResetSearchDataOfGraphVertex( in_out_Graph )
	For Each  vertex  In  in_out_Graph
		vertex.ParentIndex = Empty
	Next
End Sub


 
'***********************************************************************
'* Function: SetEdgeInGraph
'***********************************************************************
Sub  SetEdgeInGraph( in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeObject )
	SetEdgeInGraphSub  in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeObject, False
End Sub


 
'***********************************************************************
'* Function: SetNDEdgeInGraph
'***********************************************************************
Sub  SetNDEdgeInGraph( in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeObject )
	If in_BaseIndex <= in_TargetIndex Then
		SetEdgeInGraphSub  in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeObject, True
	Else
		SetEdgeInGraphSub  in_out_Graph, in_TargetIndex, in_BaseIndex, in_EdgeObject, True
	End If
End Sub


 
'***********************************************************************
'* Function: SetEdgeInGraphSub
'***********************************************************************
Sub  SetEdgeInGraphSub( in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeObject, in_IsMutual )
	Set base_vertex   = in_out_Graph( in_BaseIndex )
	For i=0 To UBound( base_vertex.AdjacentIndexes )
		If base_vertex.AdjacentIndexes( i ) = in_TargetIndex Then
			If IsObject( in_EdgeObject ) Then
				Set base_vertex.Edges( i ) = in_EdgeObject
			Else
				base_vertex.Edges( i ) = in_EdgeObject
			End If
			Exit Sub
		End If
	Next

	'// New Edge
	base_vertex.AddToAdjacentIndexes    UBound( base_vertex.AdjacentIndexes ) + 1, in_TargetIndex
	base_vertex.AddToEdges    UBound( base_vertex.Edges )   + 1, in_EdgeObject

	If in_IsMutual Then
		Set target_vertex = in_out_Graph( in_TargetIndex )
		target_vertex.AddToAdjacentIndexes  UBound( target_vertex.AdjacentIndexes ) + 1, in_BaseIndex
		target_vertex.AddToEdges  UBound( target_vertex.Edges ) + 1, Empty
	End If
End Sub


 
'***********************************************************************
'* Function: GetEdgeInGraph
'***********************************************************************
Function  GetEdgeInGraph( in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeIfNotFound )
	Set base_vertex = in_out_Graph( in_BaseIndex )
	Set target_vertex = in_out_Graph( in_TargetIndex )  '// Check UBound
	LetSet  GetEdgeInGraph, base_vertex.GetEdge( in_TargetIndex, in_EdgeIfNotFound )
End Function


 
'***********************************************************************
'* Function: GetNDEdgeInGraph
'***********************************************************************
Function  GetNDEdgeInGraph( in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeIfNotFound )
	If in_BaseIndex <= in_TargetIndex Then
		LetSet GetNDEdgeInGraph, GetEdgeInGraph( in_out_Graph, in_BaseIndex, in_TargetIndex, in_EdgeIfNotFound )
	Else
		LetSet GetNDEdgeInGraph, GetEdgeInGraph( in_out_Graph, in_TargetIndex, in_BaseIndex, in_EdgeIfNotFound )
	End If
End Function


 
'***********************************************************************
'* Function: RemoveEdgeInGraph
'***********************************************************************
Sub  RemoveEdgeInGraph( in_out_Graph, in_BaseIndex, in_TargetIndex )
	Set base_vertex = in_out_Graph( in_BaseIndex )
	base_vertex.RemoveEdge  in_TargetIndex
End Sub


 
'***********************************************************************
'* Function: RemoveNDEdgeInGraph
'***********************************************************************
Sub  RemoveNDEdgeInGraph( in_out_Graph, in_BaseIndex, in_TargetIndex )
	If in_BaseIndex <= in_TargetIndex Then
		RemoveEdgeInGraph  in_out_Graph, in_BaseIndex, in_TargetIndex
	Else
		RemoveEdgeInGraph  in_out_Graph, in_TargetIndex, in_BaseIndex
	End If
End Sub


 
'*************************************************************************
'  <<< [TreeA_Class] >>> 
'*************************************************************************
Function  new_TreeA_Class( in_Item )
	Set new_TreeA_Class = new TreeA_Class
	Set new_TreeA_Class.p.Item = in_Item
End Function

Class  TreeA_Class
	Public  p  '// Root node as TreeA_NodeClass

	Private Sub  Class_Initialize()
		Set group = new LifeGroupClass
		group.AddHandle  Me, new TreeA_NodeClass
	End Sub

	Private Sub  Class_Terminate()
		If not IsEmpty( Me.p.LifeGroup.Group ) Then _
			Me.p.LifeGroup.Group.AddTerminated  Me.p
	End Sub

	Property Get  TreeNode() : Set TreeNode = Me.p : End Property

	Function  CreateNode() : Set CreateNode = Me.p.CreateNode() : End Function
	Function  AddNewNode( x ) : Set AddNewNode = Me.p.AddNewNode( x ) : End Function
	Property Get  ParentNode() : Set ParentNode = Nothing : End Property
	Property Get  ChildNodes( i ) : Set ChildNodes = Me.p.ChildNodes( i ) : End Property
	Property Get  ParentItems() : ParentItems = Me.p.ParentItems : End Property
	Property Get  ChildItems() : ChildItems = Me.p.ChildItems : End Property

	Property Get  Item() : Set Item = Me.p.Item : End Property
	Property Set  Item(x) : Set Me.p.Item = x : End Property

	Public Property Get  xml() : xml = p.xml : End Property
	Public Function  xml_sub( Level ) : xml_sub = p.xml_sub( Level ) : End Function
End Class


 
'*************************************************************************
'  <<< [TreeA_NodeClass] >>> 
'*************************************************************************
Class  TreeA_NodeClass
	Public  ParentNode  '// as TreeA_NodeClass
	Public  ChildNodes  '// as ArrayClass of TreeA_NodeClass
	Public  Item        '// as Object

	Public  LifeGroup   '// Root node only has "LifeGroup".

	Private Sub  Class_Initialize()
		Set ParentNode = Nothing
		Set Me.ChildNodes = new ArrayClass
		Set Me.Item = Nothing
	End Sub

	Public Sub  DestroyReferences()
		Me.ParentNode = Empty
		Me.ChildNodes = Empty
		Me.Item = Empty
	End Sub

	Property Get  TreeNode() : Set TreeNode = Me : End Property


	Function  AddNewNode( x )
		Set new_node = Me.CreateNode()
		Me.ChildNodes.Add  new_node
		Set new_node.ParentNode = Me
		Set new_node.Item = x
		Set AddNewNode = new_node
	End Function


	Function  CreateNode()  '// Not add to "ChildNodes" and "ParentNode"
		Set node = new TreeA_NodeClass
		Me.LifeGroup.Group.Add  node
		Set CreateNode = node
	End Function


	Property Get  ParentItems()
		Set an_array = new ArrayClass
		Set node = Me.ParentNode
		While  not node is Nothing
			an_array.Add  node.Item
			Set node = node.ParentNode
		WEnd
		ParentItems = an_array.Items
	End Property


	Property Get  ChildItems()
		Set an_array = new ArrayClass
		Me.EnumerateChildItems  an_array
		ChildItems = an_array.Items
	End Property
	Function  EnumerateChildItems( arg_Array )
		For Each  node  In  Me.ChildNodes.Items
			node.EnumerateChildItems  arg_Array
		Next
		arg_Array.Add  Me.Item
	End Function


	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		xml_sub = GetTab( Level )+ "<"+TypeName(Me)+">"

		xml_sub2 = GetEchoStr_sub( Item, Level )
		If InStr( xml_sub2, vbLF ) = Len( xml_sub2 ) Then
			xml_sub = xml_sub + Trim( xml_sub2 )
		Else
			xml_sub = xml_sub + vbCRLF + xml_sub2
		End If

		xml_sub2 = ""
		For Each  node  In  Me.ChildNodes.Items
			xml_sub2 = xml_sub2 + GetEchoStr_sub( node, Level )
		Next
		If xml_sub2 = "" Then
			CutLastOf  xml_sub, vbCRLF, Empty
		Else
			xml_sub = xml_sub + xml_sub2 + GetTab( Level )
		End If

		xml_sub = xml_sub +"</"+TypeName(Me)+">"+ vbCRLF
	End Function
End Class


 
'*************************************************************************
'  <<< [head] >>> 
'*************************************************************************
Function  head( Str, LineLength )
	Dim  pos : pos = 1
	Dim  line_num

	For line_num = 1  To LineLength
		pos = InStr( pos, Str, vbLF )
		If pos = 0 Then  head = Str : Exit For
		pos = pos + 1
	Next
	If line_num > LineLength Then  head = Left( Str, pos )

	'// cut last CR LF
	Do
		If Right( head, 2 ) = vbCRLF Then
			head = Left( head, Len( head ) - 2 )
		ElseIf Right( head, 1 ) = vbLF Then
			head = Left( head, Len( head ) - 1 )
		Else
			Exit Do
		End If
	Loop
End Function


 
'***********************************************************************
'* Function: GetLeftEndOfLinePosition
'***********************************************************************
Function  GetLeftEndOfLinePosition( in_Text, in_PositionInText )
	If in_PositionInText <= Len( in_Text ) Then
		start_position = in_PositionInText
	Else
		start_position = -1
	End If

	GetLeftEndOfLinePosition = InStrRev( in_Text,  vbLF,  start_position ) + 1
End Function


 
'***********************************************************************
'* Function: GetNextLinePosition
'***********************************************************************
Function  GetNextLinePosition( in_Text, in_PositionInText )
	pos = InStr( in_PositionInText, in_Text, vbLF ) + 1
	If pos = 1 Then
		GetNextLinePosition = 0
	ElseIf pos > Len( in_Text ) Then
		GetNextLinePosition = 0
	Else
		GetNextLinePosition = pos
	End If
End Function


 
'***********************************************************************
'* Function: GetPreviousLinePosition
'***********************************************************************
Function  GetPreviousLinePosition( in_Text, in_OverPositionInText )
	pos = in_OverPositionInText
	If pos >= 3 Then
		pos = InStrRev( in_Text, vbLF, pos - 2 ) + 1
	Else
		pos = pos - 1
	End If
	GetPreviousLinePosition = pos
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [StringStream] Class >>>> 
'-------------------------------------------------------------------------

Class  StringStream

	Public   Str, StrLen
	Public   NextLinePos
	Public   IsWithLineFeed
	Public   WritingLineFeed
	Public   ReadingLineFeed
	Private  m_ReadLine, m_WriteLine, m_bPrevIsWrite

	Private Sub  Class_Initialize()
		Me.IsWithLineFeed = False
		Me.WritingLineFeed = vbCRLF
		Me.ReadingLineFeed = vbLF
	End Sub

	Public Property Get Line()
		If m_bPrevIsWrite Then  Line = m_WriteLine  Else  Line = m_ReadLine
	End Property

	Public  Sub  SetString( Str )
		If Me.IsWithLineFeed  or  Me.ReadingLineFeed = vbCRLF Then
			Me.Str = Str
		Else
			Me.Str = Replace( Str, vbCRLF, vbLF ) '// for supporting vbCRLF and vbLF
		End If
		Me.StrLen = Len( Me.Str )
		Me.NextLinePos = 1
		m_ReadLine = 1
		m_WriteLine = 1
	End Sub

	Public Function  ReadLine()
		i = InStr( Me.NextLinePos, Me.Str, Me.ReadingLineFeed )
		If i > 0 Then
			If Me.IsWithLineFeed Then
				ReadLine = Mid( Me.Str, Me.NextLinePos, i - Me.NextLinePos + 1 )
			Else
				ReadLine = Mid( Me.Str, Me.NextLinePos, i - Me.NextLinePos )
			End If
			Me.NextLinePos = i + Len( Me.ReadingLineFeed )
			If Me.NextLinePos > Me.StrLen Then
				Me.Str = Empty
				Me.NextLinePos = Empty
			End If
		Else
			ReadLine = Mid( Me.Str, Me.NextLinePos )
			Me.Str = Empty
			Me.NextLinePos = Empty
		End If
		m_ReadLine = m_ReadLine + 1
	End Function

	Public Function  ReadAll()
		If not IsEmpty( Me.StrLen ) Then  Raise 1, "対応していません"
			'// SetString and RealAll is not supported. Because vbCR is lost.
		ReadAll = Me.Str
		Me.Str = Empty
	End Function

	Public Property Get AtEndOfStream : AtEndOfStream = IsEmpty( Me.Str ) : End Property
	Public Sub  Write( Str ) : Me.Str = Me.Str + Str : End Sub

	Public Sub  WriteLine( LineStr )
		Me.Str = Me.Str + LineStr + Me.WritingLineFeed
		m_WriteLine = m_WriteLine + 1
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [StrMatchKey] Class >>>> 
'-------------------------------------------------------------------------
Class  StrMatchKey

	Public Property Let  Keyword( s )
		m_Keyword = s
		m_LeftCount = InStr( s, "*" ) - 1
		If m_LeftCount > -1 Then
			m_LeftStr = Left( s, m_LeftCount )
			m_RightCount = Len( s ) - m_LeftCount - 1
			m_RightStr = Right( s, m_RightCount )
		Else
			m_LeftStr = Empty
			m_RightCount = Len( s )
			m_RightStr = s
		End If

		If InStr( m_LeftCount + 2, s, "*" ) > 0 Then _
			Raise  1,"* を複数指定することはできません"
	End Property

	Public Property Get  Keyword()
		Keyword = m_Keyword
	End Property


	Public Function  IsMatch( TestStr )
		'// m_Keyword must be low case
		IsMatch = False

		If LCase( Right( TestStr, m_RightCount ) ) = m_RightStr Then
			If m_LeftCount <= 0 Then
				If m_LeftCount = 0  or  Len( TestStr ) = m_RightCount Then
					IsMatch = True
				End If
			Else
				If LCase( Left( TestStr, m_LeftCount ) ) = m_LeftStr Then
					IsMatch = True
				End If
			End If
		End If
	End Function

	Public Function  IsMatchULCase( TestStr )
		IsMatchULCase = False

		If Right( TestStr, m_RightCount ) = m_RightStr Then
			If m_LeftCount <= 0 Then
				If m_LeftCount = 0  or  Len( TestStr ) = m_RightCount Then
					IsMatchULCase = True
				End If
			Else
				If Left( TestStr, m_LeftCount ) = m_LeftStr Then
					IsMatchULCase = True
				End If
			End If
		End If
	End Function

	Public Function  Test( TestStr )
		If IgnoreCase Then
			Test = Me.IsMatch( TestStr )
		Else
			Test = Me.IsMatchULCase( TestStr )
		End If
	End Function

	Public  m_Keyword
	Public  m_LeftCount
	Public  m_RightCount
	Public  m_LeftStr
	Public  m_RightStr
	Public  IgnoreCase
End Class


 
'*************************************************************************
'  <<< [StringReplaceSetClass] >>> 
'*************************************************************************
Class  StringReplaceSetClass

	Public  List
	Public  ReplaceCommand,  ReplaceRangeCommand
	Public  OneCommandLength

	Private Sub  Class_Initialize()
		ReDim  List(-1)
		Me.ReplaceCommand = 1
		Me.ReplaceRangeCommand = 2
		Me.OneCommandLength = 4
	End Sub


	Public Sub  Replace( FromText, ToText )
		u_bound = UBound( Me.List )
		ReDim Preserve  List( u_bound + Me.OneCommandLength )
		index = u_bound + 1
		Me.List( index + 0 ) = Me.ReplaceCommand
		Me.List( index + 1 ) = FromText
		Me.List( index + 2 ) = ToText
	End Sub


	Public Sub  ReplaceRange( StartOfFromText, EndOfFromText, ToText )
		u_bound = UBound( Me.List )
		ReDim Preserve  List( u_bound + Me.OneCommandLength )
		index = u_bound + 1
		Me.List( index + 0 ) = Me.ReplaceRangeCommand
		Me.List( index + 1 ) = StartOfFromText
		Me.List( index + 2 ) = EndOfFromText
		Me.List( index + 3 ) = ToText
	End Sub


	Public Function  DoReplace( InputText )
		text = InputText

		For index = 0  To UBound( Me.List )  Step Me.OneCommandLength
			Select Case  Me.List( index + 0 )

				Case  Me.ReplaceCommand
					FromText = Me.List( index + 1 )
					ToText   = Me.List( index + 2 )

					is_skip = False
					If InStr( ToText, FromText ) > 0 Then  '// if FromText is part of ToText
						If InStr( text, ToText ) > 0 Then
							is_skip = True
						End If
					End If
					If not is_skip Then _
						text = ReplaceTextFile1_replace( text, FromText, ToText )

				Case  Me.ReplaceRangeCommand
					StartOfFromText = Me.List( index + 1 )
					EndOfFromText   = Me.List( index + 2 )
					ToText          = Me.List( index + 3 )

					start_pos = InStr( text, StartOfFromText )
					If start_pos > 0 Then
						end_pos = InStr( start_pos + Len( StartOfFromText ),  text,  EndOfFromText )
						If end_pos = 0 Then  Raise  E_NotFoundSymbol, _
							"<ERROR msg=""終了タグが見つかりません"" tag="""+ EndOfFromText +"""/>"

						text = Left( text, start_pos - 1 ) + ToText + _
							Mid( text, end_pos + Len( EndOfFromText ) )
					End If

				Case Else
					Error
			End Select
		Next

		DoReplace = text
	End Function
End Class


 
'*************************************************************************
'  <<< [ToRegExpPattern] >>> 
'*************************************************************************
Function  ToRegExpPattern( NoEscapedString )
	ToRegExpPattern = ToOldRegExpPattern( NoEscapedString )
	ToRegExpPattern = Replace( ToRegExpPattern, "(", "\(" )
	ToRegExpPattern = Replace( ToRegExpPattern, ")", "\)" )
	ToRegExpPattern = Replace( ToRegExpPattern, "{", "\{" )
	ToRegExpPattern = Replace( ToRegExpPattern, "}", "\}" )
	ToRegExpPattern = Replace( ToRegExpPattern, "+", "\+" )
	ToRegExpPattern = Replace( ToRegExpPattern, "?", "\?" )
	ToRegExpPattern = Replace( ToRegExpPattern, "|", "\|" )
End Function


 
'*************************************************************************
'  <<< [ToOldRegExpPattern] >>> 
'*************************************************************************
Function  ToOldRegExpPattern( NoEscapedString )
	ToOldRegExpPattern = Replace( NoEscapedString,    "\", "\\" )
	ToOldRegExpPattern = Replace( ToOldRegExpPattern, ".", "\." )
	ToOldRegExpPattern = Replace( ToOldRegExpPattern, "$", "\$" )
	ToOldRegExpPattern = Replace( ToOldRegExpPattern, "^", "\^" )
	ToOldRegExpPattern = Replace( ToOldRegExpPattern, "[", "\[" )
	ToOldRegExpPattern = Replace( ToOldRegExpPattern, "]", "\]" )
	ToOldRegExpPattern = Replace( ToOldRegExpPattern, "*", "\*" )
End Function


 
'*************************************************************************
'  <<< [LenK] >>> 
'*************************************************************************
Function  LenK( Str )
	Dim  c, a, i, n_zen

	i = 1 : n_zen = 0
	Do
		c = Mid( Str, i, 1 )
		If c = "" Then  LenK = i - 1 + n_zen : Exit Function
		a = Asc( c )
		If a >= 256 or a < 0 Then  n_zen = n_zen + 1
		i = i + 1
	Loop
End Function


 
'*************************************************************************
'  <<< [CutRight] >>> 
'*************************************************************************
Function  CutRight( Str, Count )
	CutRight = Left( Str, Len( Str ) - Count )
End Function


 
'*************************************************************************
'  <<< [CutLastOf] >>> 
'*************************************************************************
Sub  CutLastOf( Str, LastStr, Opt )
	Dim  length : length = Len( LastStr )
	If StrComp( Right( Str, length ), LastStr, StrCompOption( Opt ) ) = 0 Then _
		Str = Left( Str, Len( Str ) - length )
End Sub


 
'*************************************************************************
'  <<< [StrCompHeadOf] >>> 
'*************************************************************************
Function  StrCompHeadOf( in_StringA,  in_StringB,  in_Option )
	Set c = g_VBS_Lib

	If IsBitNotSet( in_Option,  c.AsPath ) Then
		part_A = Left( in_StringA,  Len( in_StringB ) )

		strcmp_value = StrComp( part_A,  in_StringB,  StrCompOption( in_Option ) )

	Else  '// c.AsPath
		If IsEmpty( in_StringB ) Then
			strcmp_value = 1
		Else
			string_A = Replace( in_StringA, "\", "/" )
			string_B = Replace( in_StringB, "\", "/" )

			If string_A = "." Then  string_A = ""
			If string_B = "." Then  string_B = ""

			last_of_B = Right( string_B, 1 )
			Select Case  last_of_B
				Case  "/", "#" : is_last_of_B_separator = True
				Case Else      : is_last_of_B_separator = False
			End Select

			If not is_last_of_B_separator Then
				If Right( string_A, 1 ) = "/" Then _
					string_A = Left( string_A,  Len( string_A ) - 1 )
			End If
			length_B = Len( string_B )
			part_A = Left( string_A,  length_B )

			strcmp_value = StrComp( part_A,  string_B,  1 )
			If strcmp_value = 0 Then
				If not is_last_of_B_separator  and  string_B <> "" Then
					next_character = Mid( string_A,  length_B + 1,  1 )

					Select Case  next_character
						Case  "", "/", "#" : strcmp_value = 0
						Case Else          : strcmp_value = 1
					End Select
				End If
			End If
		End If
	End If

	StrCompHeadOf = strcmp_value
End Function



 
'*************************************************************************
'  <<< [StrCompLastOf] >>> 
'*************************************************************************
Function  StrCompLastOf( StrA, StrB, Opt )
	StrCompLastOf = StrComp( Right( StrA, Len(StrB) ), StrB, StrCompOption( Opt ) )
End Function


 
'*************************************************************************
'  <<< [StrCount] >>> 
'*************************************************************************
Function  StrCount( ByVal Str, ByVal Keyword, StartPos, Opt )
	Dim  pos, key_length

	If StrCompOption( Opt ) = vbTextCompare Then  '// Opt is c.CaseSensitive
		Str = LCase( Str ) : Keyword = LCase( Keyword )
	End If

	StrCount = 0
	key_length = Len( Keyword )
	pos = StartPos
	Do
		pos = InStr( pos, Str, Keyword )
		If pos = 0 Then  Exit Function
		StrCount = StrCount + 1
		pos = pos + key_length
	Loop
End Function


 
'*************************************************************************
'  <<< [StrCompOption] >>> 
'*************************************************************************
Function  StrCompOption( Opt )
	If VarType( Opt ) = vbInteger Then
		If Opt >= 0  and  ( Opt and  g_VBS_Lib.CaseSensitive ) <> 0  Then
			StrCompOption = vbBinaryCompare
		Else
			StrCompOption = vbTextCompare
		End If
	Else
		StrCompOption = vbTextCompare
	End If
End Function


 
'*************************************************************************
'  <<< [AddIfNotExist] >>> 
'*************************************************************************
Function  AddIfNotExist( WholeStr, AddStr, Separator, Opt )
	elements = Split( WholeStr, Separator )
	For Each element  In elements
		If StrComp( element, AddStr, StrCompOption( Opt ) ) = 0 Then
			AddIfNotExist = WholeStr
			Exit Function
		End If
	Next
	AddIfNotExist = AddStr + Separator + WholeStr
End Function


 
'********************************************************************************
'  <<< [TestableNow] >>> 
'********************************************************************************
Dim  g_TestableNow  '// as Date or Empty

Function  TestableNow()
	If IsEmpty( g_TestableNow ) Then
		TestableNow = Now()
	Else
		TestableNow = g_TestableNow
	End If
End Function


 
'********************************************************************************
'  <<< [new_TestableNow] >>> 
'********************************************************************************
Function  new_TestableNow( a_Date )
	Set new_TestableNow = new TestableNowClass
	g_TestableNow = a_Date
End Function

Class  TestableNowClass
	Private Sub  Class_Terminate()
		g_TestableNow = Empty
	End Sub
End Class


 
'*************************************************************************
'  <<< [IsTimeOnlyDate] >>> 
'*************************************************************************
Function  IsTimeOnlyDate( aDateTime )
	IsTimeOnlyDate = Year( aDateTime ) = 1899  and  Month( aDateTime ) = 12  and  Day( aDateTime ) = 30
End Function

 
'*************************************************************************
'  <<< [DateAddStr] >>> 
'*************************************************************************
Function  DateAddStr( BaseDate, Plus )
	Dim  i, i2, c, d, flag, num, unit, i_over

	DateAddStr = BaseDate
	i=1
	i_over = Len( Plus ) + 1

	'//=== Skip spaces
	While Mid( Plus, i, 1 ) = " " : i=i+1 : WEnd

	'//=== Get flag
	flag = +1
	c = Mid( Plus, i, 1 )
	If c = "+" Then
		i=i+1
	ElseIf c = "-" Then
		flag = -1 : i=i+1
	End If

	Do

		'//=== Skip spaces
		While Mid( Plus, i, 1 ) = " " : i=i+1 : WEnd

		If i = i_over Then  Exit Do

		c = Mid( Plus, i, 1 )
		i2 = i

		'//=== change flag
		Do
			If c = "-" Then
				flag = -1
			ElseIf c = "+" Then
				flag = +1
			Else
				Exit Do
			End If
			i2=i2+1 : c = Mid( Plus, i2, 1 )
		Loop
		i = i2

		'//=== Get number or "Z"(W3C-DTF UTC)
		While c >= "0" and c <= "9" : i2=i2+1 : c = Mid( Plus, i2, 1 ) : WEnd
		If i2 = i Then
			If c <> "Z" Then  Err.Raise 1002
			num = 0
		Else
			num = CInt( Mid( Plus, i, i2 - i ) )
			i = i2
		End If

		'//=== Skip spaces
		While Mid( Plus, i, 1 ) = " " : i=i+1 : WEnd

		'//=== Get unit
		c = Mid( Plus, i, 1 )
		i2 = i
		While (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c = ":" or c = "/")
			i2=i2+1 : c = Mid( Plus, i2, 1 )
		WEnd

		Select Case  LCase( Mid( Plus, i, i2 - i ) )
			Case "year",  "years"  : unit = "yyyy"
			Case "month", "months" : unit = "m"
			Case "day",   "days"   : unit = "d"
			Case "hour",  "hours"  : unit = "h"
			Case "minute","minutes","min": unit = "n"
			Case "second","seconds","sec": unit = "s"

			Case ":", "/", "-"
				unit = Mid( Plus, i, 1 )

				While (c >= "0" and c <= "9") or (c=unit) : i2=i2+1 : c = Mid( Plus, i2, 1 ) : WEnd
				d = CDate( num & Mid( Plus, i, i2-i ) )
				If unit = ":" Then
					DateAddStr = DateAdd( "h", flag * Hour(d),   DateAddStr )
					DateAddStr = DateAdd( "n", flag * Minute(d), DateAddStr )
					DateAddStr = DateAdd( "s", flag * Second(d), DateAddStr )
				Else
					DateAddStr = DateAdd( "m", flag * Month(d), DateAddStr )
					DateAddStr = DateAdd( "d", flag * Day(d),   DateAddStr )
				End If
				unit = Empty

			Case "z"  '// Do nothing
			Case Else  Err.Raise  1,,"単位がおかしい"
		End Select
		i = i2

		'//=== Add Date
		If not IsEmpty( unit ) Then _
			DateAddStr = DateAdd( unit, flag * num, DateAddStr )

	Loop
End Function
 
'***********************************************************************
'* Function: GetOldestDate
'***********************************************************************
Function  GetOldestDate()
	GetOldestDate = #100/1/1#
End Function


 
'*************************************************************************
'  <<< [W3CDTF] >>> 
'*************************************************************************
Function  W3CDTF( SourceTimeDate )
	If VarType( SourceTimeDate ) = vbString Then
		Dim  c, s, tzd

		'//=== string to Date
		s = Trim2( SourceTimeDate )
		If Mid( s, 5, 1 ) = "-" Then
			c = Mid( s, 11, 1 )
			If c = "T" or c = " " Then
				If Mid( s, 17, 1 ) = ":" Then
					W3CDTF = CDate( Left( s, 10 ) +" "+ Mid( s, 12, 8 ) )
					If Mid( s, 20, 1 ) = "." Then
						c = InStr( 21, s, "+" )
						If c = 0 Then  c = InStr( 21, s, "-" )
						If c = 0 Then  c = InStr( 21, s, "Z" )
						If c = 0 Then  Err.Raise 1002
						s = Mid( s, c )
					Else
						s = Mid( s, 20 )
					End If
				Else
					W3CDTF = CDate( Left( s, 10 ) +" "+ Mid( s, 12, 5 ) )
					s = Mid( s, 17 )
				End If
				If s <> TimeZoneDesignator( Empty ) Then
					W3CDTF = DateAddStr( W3CDTF, TimeZoneDesignator( Empty ) +"+"+ MinusTZD( s ) )
				End If
			Else
				W3CDTF = CDate( s )
			End If
		Else
			W3CDTF = CDate( s +"/1/1" )
		End If

	ElseIf VarType( SourceTimeDate ) = vbDate Then

		'//=== Date to string
		W3CDTF = Right( "000"& Year( SourceTimeDate ), 4 ) +"-"+ Right( "0"& Month( SourceTimeDate ), 2 ) +"-"+ _
			Right( "0"& Day(    SourceTimeDate ), 2 ) +"T"+ Right( "0"& Hour(   SourceTimeDate ), 2 ) +":"+ _
			Right( "0"& Minute( SourceTimeDate ), 2 ) +":"+ Right( "0"& Second( SourceTimeDate ), 2 ) + _
			TimeZoneDesignator( Empty )
	End If
End Function


 
'*************************************************************************
'  <<< [CDateFromEMailDate] >>> 
'*************************************************************************
Function  CDateFromEMailDate( DateString )
	'// e.g.) Date: Fri, 25 Oct 2013 16:07:30 +0900

	Const  num_0_day  = 0
	Const  num_2_year = 2
	Const  num_3_time = 3

	line = Trim( DateString )
	items = Split( line, " " )

	offset = 0
	If items( offset ) = "Date:" Then  offset = offset + 1
	If Right( items( offset ), 1 ) = "," Then  offset = offset + 1

	month_str = items( offset + 1 )
	month_num = GetMonthNumberFromString( month_str )

	time_zone_str = items( offset + 4 )
	time_zone_str = Left( time_zone_str, Len( time_zone_str ) - 2 ) +_
		":"+ Right( time_zone_str, 2 )

	string_of_W3CDTF = _
		items( offset + num_2_year ) +"-"+ _
		Right( "0" & month_num, 2 ) +"-"+ _
		Right( "0" & items( offset + num_0_day ), 2 ) +"T"+ _
		Right( "0"+ items( offset + num_3_time ), 8 ) + _
		time_zone_str
		'// e.g. "2001-02-02T01:15:00+09:00"

	CDateFromEMailDate = W3CDTF( string_of_W3CDTF )
End Function


 
'*************************************************************************
'  <<< [GetMonthNumberFromString] >>> 
'*************************************************************************
Function  GetMonthNumberFromString( Str )
	index = InStr( g_VBS_Lib_MonthStrings, Str )
	If index = 0 Then  Raise  E_NotFoundSymbol, ""
	If Mid( g_VBS_Lib_MonthStrings, index - 1, 1 ) <> "," Then  Raise  E_NotFoundSymbol, ""
	If Mid( g_VBS_Lib_MonthStrings, index + Len( Str ), 1 ) <> "," Then  Raise  E_NotFoundSymbol, ""
	GetMonthNumberFromString = ( index + 2 ) / 4
End Function
Dim  g_VBS_Lib_MonthStrings : g_VBS_Lib_MonthStrings = ",Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,"


 
'*************************************************************************
'  <<< [ConvertTimeZone] >>> 
'*************************************************************************
Function  ConvertTimeZone( DateTime, FromTZD, ByVal ToTZD )
	Dim  utc, local

	If IsEmpty( ToTZD ) Then  ToTZD = TimeZoneDesignator( Empty )

	'//=== convert W3CDTF
	If VarType( DateTime ) = vbString Then

		If Mid( FromTZD, 3, 1 ) = ":" Then  FromTZD = Left( FromTZD, 1 ) +"0"+ Mid( FromTZD, 2 ) '// +0:00 -> +00:00
		If Mid( ToTZD,   3, 1 ) = ":" Then  ToTZD   = Left( ToTZD,   1 ) +"0"+ Mid( ToTZD,   2 ) '// +0:00 -> +00:00

		If not IsEmpty( FromTZD ) Then
			If FromTZD <> Right( DateTime, Len( FromTZD ) ) Then
				Raise  1, "DateTime に W3CDTF を指定したときは FromTZD を Empty にするか、FromTZD を DateTime の TZD に合わせてください"
			End If
		End If

		local = W3CDTF( DateTime )
		utc = DateAddStr( local, MinusTZD( Empty ) )
		ConvertTimeZone = Left( W3CDTF( DateAddStr( utc, ToTZD ) ), 19 ) + ToTZD

	'//=== convert value as Date
	Else
		utc = DateAddStr( DateTime, MinusTZD( FromTZD ) )
		ConvertTimeZone = DateAddStr( utc, ToTZD )
	End If
End Function


 
'*************************************************************************
'  <<< [TimeZoneDesignator] >>> 
'*************************************************************************
Dim  g_TimeZoneDesignatorHere  '// as string

Function  TimeZoneDesignator( MinuteBias )
	If IsEmpty( MinuteBias ) Then
		If IsEmpty( g_TimeZoneDesignatorHere ) Then _
			g_TimeZoneDesignatorHere = TimeZoneDesignator( get_WMI( Empty, "Win32_TimeZone" ).Bias )
		TimeZoneDesignator = g_TimeZoneDesignatorHere
	Else
		If MinuteBias = 0 Then
			TimeZoneDesignator = "Z"
		ElseIf MinuteBias > 0 Then
			TimeZoneDesignator = "+" + Right( "0" & CInt( MinuteBias / 60 ), 2 ) +_
						":" + Right( "0" &   ( MinuteBias mod 60 ), 2 )
		Else
			TimeZoneDesignator = "-" + Right( "0" & CInt( -MinuteBias / 60 ), 2 ) +_
						":" + Right( "0" &   ( -MinuteBias mod 60 ), 2 )
		End If
	End If
End Function


 
'*************************************************************************
'  <<< [MinusTZD] >>> 
'*************************************************************************
Function  MinusTZD( MinuteBiasOrStr )
	If VarType( MinuteBiasOrStr ) = vbString Then
		Select Case  Left( MinuteBiasOrStr, 1 )
			Case  "-" : MinusTZD = "+" + Mid( MinuteBiasOrStr, 2 )
			Case  "Z" : MinusTZD = "Z"
			Case Else : MinusTZD = "-" + Mid( MinuteBiasOrStr, 2 )
		End Select
	Else
		MinusTZD = MinusTZD( TimeZoneDesignator( MinuteBiasOrStr ) )
	End If
End Function


 
'*************************************************************************
'  <<< [Bench] >>> 
'*************************************************************************
Dim  g_Bench_Elapseds  '// as array of Single
Dim  g_Bench_Counts  '// as array of integer
Dim  g_Bench_CurrentSectionNum  '// as integer
Dim  g_Bench_PrevTime  '// as Single

Sub  BenchStart()
	ReDim  g_Bench_Elapseds( 100 )
	ReDim  g_Bench_Counts( 100 )
	g_Bench_CurrentSectionNum = 0
	g_Bench_PrevTime = Timer()
End Sub


Sub  Bench( SectionNum )
	Dim  current_time : current_time = Timer()
	g_Bench_Elapseds( g_Bench_CurrentSectionNum ) = g_Bench_Elapseds( g_Bench_CurrentSectionNum ) +_
		current_time - g_Bench_PrevTime
	g_Bench_Counts( g_Bench_CurrentSectionNum ) = g_Bench_Counts( g_Bench_CurrentSectionNum ) + 1
	g_Bench_CurrentSectionNum = SectionNum
	g_Bench_PrevTime = current_time
End Sub


Sub  BenchEnd()
	Dim  i,  count,  elapsed,  max_section_num

	Bench  0

	count = 0
	elapsed = 0
	max_section_num = Empty
	For i=0 To UBound( g_Bench_Elapseds )
		elapsed = elapsed + g_Bench_Elapseds(i)
		count = count + g_Bench_Counts(i)
		If i > 0  and  not IsEmpty( g_Bench_Elapseds(i) ) Then
			If IsEmpty( max_section_num ) Then
				max_section_num = i
			ElseIf g_Bench_Elapseds(i) > g_Bench_Elapseds( max_section_num ) Then
				max_section_num = i
			End If
		End If
	Next

	echo_v  ""
	echo_v  "Benchmark Result:"
	echo_v  "Sampling Count = " & count
	echo_v  "Elapsed Time = " & elapsed & "(sec)"
	echo_v  "Max is Section " & max_section_num

	For i=1 To UBound( g_Bench_Elapseds )
		If not IsEmpty( g_Bench_Elapseds(i) ) Then
			echo_v  "Section " & i & ": "+ Right( "  " & g_Bench_Counts(i), 3 ) & "times   " &_
				 Right( "     " & FormatNumber( g_Bench_Elapseds(i), 3,,, False ), 10 ) & "(sec)"
		End If
	Next
End Sub


 
'*************************************************************************
'  <<< [g_VBS_Lib_ProgressTimerClass] >>> 
'  g_VBS_Lib.ProgressTimer
'*************************************************************************
Class  g_VBS_Lib_ProgressTimerClass
	Public  NextShowTime  '// as Date
	Public  Interval_msec  '// as integer
	Public  Count  '// as integer
	Public  MaxCount  '// as integer
	Public  ShowFormat  '// as string
	Public  NestLevel  '// as integer
	Public  ColumnCount  '// as integer

	Private Sub  Me_Initialize()
		Me.NextShowTime = Timer()
		Me.Interval_msec = 1000
		Me.NestLevel = 0
		Me.ColumnCount = 80
	End Sub

	Public Function  GetShouldShow()
		If IsEmpty( Me.NextShowTime ) Then _
			Me_Initialize

		now_time = Timer()
		If now_time >= Me.NextShowTime Then
			GetShouldShow = True

			While  now_time >= Me.NextShowTime
				Me.NextShowTime = Me.NextShowTime + Me.Interval_msec / 1000
			WEnd
		Else
			GetShouldShow = False
		End If
	End Function

	Public Sub  Start( in_ShowFormat, in_MaxCount, in_Interval_msec, in_Text )
		Me.NestLevel = Me.NestLevel + 1
		If Me.NestLevel >= 1 Then
			Me.Interval_msec = in_Interval_msec
			Me.Count = 0
			Me.MaxCount = in_MaxCount
			If in_ShowFormat = "" Then
				Me.ShowFormat = " ${Percent}% ${Count}/${MaxCount} ${Text}"
			Else
				Me.ShowFormat = in_ShowFormat
			End If
			Me.NextShowTime = Timer() + Me.Interval_msec / 1000
			If not IsEmpty( in_Text ) Then _
				Me.Show  in_Text
		End If
	End Sub

	Public Sub  End_( in_Text )
		Assert  Me.NestLevel >= 1
		Me.NestLevel = Me.NestLevel - 1
			If not IsEmpty( in_Text ) Then _
				Me.Show  in_Text
		If Me.NestLevel = 0 Then
		End If
		WScript.StdOut.Write  vbCRLF
	End Sub

	Public Sub  Plus( in_PlusCount, in_Text )
		Me.Count = Me.Count + in_PlusCount
		If Me.GetShouldShow() Then _
			Me.Show  in_Text
	End Sub

	Public Sub  Show( in_Text )
		a_string = Me.ShowFormat
		a_string = Replace( a_string, "${Count}", CStr( Me.Count ) )
		a_string = Replace( a_string, "${MaxCount}", CStr( Me.MaxCount ) )
		a_string = Replace( a_string, "${Text}", in_Text )
		If Me.MaxCount >= 1 Then
			a_string = Replace( a_string, "${Percent}", CStr( CInt( Me.Count * 100 / Me.MaxCount ) ) )
		End If
		WScript.StdOut.Write  String( ColumnCount - 1,  " " ) + vbCR
		WScript.StdOut.Write  Left( a_string,  ColumnCount - 1 ) + vbCR
	End Sub
End Class


 
'*************************************************************************
'  <<< [get_WMI] >>> 
' http://msdn.microsoft.com/en-us/library/aa384463(VS.85).aspx
'   Constructing the URI Prefix for WMI Classes
'*************************************************************************
Function  get_WMI( ByVal ComputerName, ClassName )
	Dim  objs, obj, en,ed
	Set  objs = get_SWbemServicesEx_cimv2( ComputerName ).ExecQuery( "Select * from "+ ClassName )

	If GetOSVersion() <= 5.1 Then
		ErrCheck : On Error Resume Next
			For Each obj  In objs : Set get_WMI = obj : Exit For : Next
		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If en = 424 Then  en = 0  '// If obj.Count = 0 Then en = 424
		If en <> 0 Then  Err.Raise en,,ed
	Else  '// Win7
		If objs.Count >= 1 Then  Set get_WMI = objs.ItemIndex(0)
	End If

	If not IsEmpty( get_WMI ) Then
		If get_WMI.Path_.Class <> ClassName Then  Err.Raise 424
	Else
		If IsEmpty( ComputerName ) Then  ComputerName = "."
		Set get_WMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & ComputerName & "\root\default:"+ ClassName )
	End If
End Function


 
'*************************************************************************
'  <<< [get_SWbemServicesEx_cimv2] >>> 
'*************************************************************************
Dim  g_SWbemServicesExs_cimv2  '// as Dictionary
Function   get_SWbemServicesEx_cimv2( ComputerName )
	Dim  computer_name : If IsEmpty( ComputerName ) Then  computer_name = "."  Else  computer_name = ComputerName
	If IsEmpty( g_SWbemServicesExs_cimv2 ) Then _
		Set g_SWbemServicesExs_cimv2 = CreateObject( "Scripting.Dictionary" )
	If g_SWbemServicesExs_cimv2.Exists( computer_name ) Then
		Set get_SWbemServicesEx_cimv2 = g_SWbemServicesExs_cimv2.Item( computer_name )
	Else
		Set get_SWbemServicesEx_cimv2 = GetObject("winmgmts:\\" & computer_name & "\root\cimv2")
		Set g_SWbemServicesExs_cimv2.Item( computer_name ) = get_SWbemServicesEx_cimv2
	End If
End Function


 
'*************************************************************************
'  <<< [SWbemObjectEx_xml_sub] >>> 
'*************************************************************************
Function  SWbemObjectEx_xml_sub( m, Level )
	Dim  member

	SWbemObjectEx_xml_sub = GetTab(Level)+ "<"+ m.Path_.Class +" Server='"+ m.Path_.Server +_
		"' TypeName='SWbemObjectEx' Service='WMI'"+ vbCRLF
	For Each member  In m.Properties_
		SWbemObjectEx_xml_sub = SWbemObjectEx_xml_sub + GetTab(Level+1)+ member.Name +"='"& member.Value &"'"+vbCRLF
	Next
	SWbemObjectEx_xml_sub = SWbemObjectEx_xml_sub + GetTab(Level)+ "/>"+ vbCRLF
End Function


 
'*************************************************************************
'  <<< [IRegExp2_xml_sub] >>> 
'*************************************************************************
Function  IRegExp2_xml_sub( m, Level )
	IRegExp2_xml_sub = m.Pattern
End Function


 
'*-------------------------------------------------------------------------*
'* ### <<<< System (safe part) >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [Shutdown] >>> 
'*************************************************************************
Sub  Shutdown( ByVal Operation, ByVal CountDownTimeSec )
	Const PowerOff       = "PowerOff"
	Const PowerOffHybrid = "PowerOffHybrid"
	Const Reboot         = "Reboot"
	Const Hibernate      = "Hibernate"
	Const Sleep          = "Sleep"
	Const Standby        = "Standby"

	Dim  box_vbs_template : box_vbs_template = g_vbslib_ver_folder +"SetSuspendState\ShutdownMsgBox.vbs"
	Dim  suspend_exe : suspend_exe = g_vbslib_ver_folder +"SetSuspendState\SetSuspendState.exe"
	Dim  box_vbs : box_vbs = GetTempPath( "ShutdownMsgBox.vbs" )
	Dim  box_out : box_out = g_fs.GetParentFolderName( box_vbs ) +"\"+ g_fs.GetBaseName( box_vbs ) +"_out.txt"

	If IsEmpty( Operation ) Then
		If IsDefined( "Setting_getShutdownOperation" ) Then
			Operation = Setting_getShutdownOperation()
		Else
			Operation = PowerOff
		End If
	End IF
	If IsEmpty( CountDownTimeSec ) Then
		If IsDefined( "Setting_getShutdownCountDownTimeSec" ) Then
			CountDownTimeSec = Setting_getShutdownCountDownTimeSec()
		Else
			CountDownTimeSec = 60
		End If
	End IF


	echo  ">shutdown "+ Operation +", "& CountDownTimeSec

	If Operation = "PowerOff"  and  GetOSVersion() >= 6.2 Then
		If RegRead( "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power\HiberbootEnabled" ) _
				= 1 Then
			Operation = PowerOffHybrid
		End If
	End If

	Dim  op, op2, str1, str2, i, r
	Select Case  Operation
		Case  PowerOff  : op = " /s" : str1 = "電源を切ります（シャットダウン）"
			str2 = "電源を切っています（シャットダウン）"
		Case  PowerOffHybrid  : op = " /s /hybrid" : str1 = "電源を切ります（シャットダウン）"
			str2 = "電源を切っています（シャットダウン）"
		Case  Reboot    : op = " /r" : str1 = "再起動します"
			str2 = "再起動しています"
		Case  Hibernate : op = " /h" : str1 = "電源を切ります（ハイバネーション）"
			str2 = "電源を切っています（ハイバネーション）"
		Case  Sleep     : op2 = "/sleep"   : str1 = "スリープします"
			str2 = "スリープに入っています"
		Case  Standby   : op2 = "/standby" : str1 = "スタンバイ状態にします"
			str2 = "スタンバイ状態にしています"
		Case Else  Error
	End Select


	'//=== Count down
	If CountDownTimeSec > 0 Then
		Dim  ec : Set ec = new EchoOff
		del   box_out
		copy_ren  box_vbs_template, box_vbs
		ec = Empty

		i =  CountDownTimeSec & "秒後に、"+ str1 +"。"
		start  "wscript """+ box_vbs +""" """+ i + """ """+ WScript.ScriptName +""" "& CountDownTimeSec

		For i=CountDownTimeSec To 1 Step -1
			echo_v  i  :  WScript.Sleep  1000
			r = ReadFile( box_out )
			If r <> "" Then
				If r = "1"+vbCRLF  or  r = "-1"+vbCRLF Then  Exit For
				Set ec = new EchoOff : del  box_out :  del  box_vbs
				Raise 1, "<ERROR msg='ユーザーによりキャンセルされました'/>"
			End If
		Next
		echo_v  0
		Set ec = new EchoOff
		del  box_out :  del  box_vbs
	Else
		CountDownTimeSec = 0
		Set ec = new EchoOff
	End If


	'//=== Shutdown
	If Operation = Hibernate Then
		If not exist( suspend_exe ) Then
			If GetOSVersion() >= 6 Then
				g_sh.Run  "shutdown /h"
			Else
				Raise 1,"<ERROR msg='ファイルが見つかりません' path='"+suspend_exe+"'/>"
			End If
		Else
			g_sh.Run  """"+ suspend_exe + """ 1"
		End If
	ElseIf not IsEmpty( op ) Then
		g_sh.Run  "shutdown"+ op +" /f /t 5 /c """+ str2 +""""  '// 5 is wait for finish this for piped program
	Else
		If not exist( suspend_exe ) Then  Raise 1,"<ERROR msg='ファイルが見つかりません' path='"+suspend_exe+"'/>"
		g_sh.Run  """"+ suspend_exe + """ 0"
	End If


	'//=== Shutdown message
	echo_v  str2 +"..."
End Sub


 
'*************************************************************************
'  <<< [RegRead] >>> 
'*************************************************************************
Function  RegRead( Path )
	Dim  e
	If TryStart(e) Then  On Error Resume Next
		RegRead = g_sh.RegRead( Path )
	If TryEnd Then  On Error GoTo 0
	If e.Num = E_PathNotFound or e.Num = E_WIN32_FILE_NOT_FOUND Then
		e.Clear
	End If
	If e.Num <> 0 Then  e.Raise
End Function


 
'*************************************************************************
'  <<< [RegReadEx] >>> 
'*************************************************************************
Function RegReadEx( Path, RegType )
	GetRegRootKeyAndStepPath  Path, root_key, step_path  '//[out] root_key, step_path

	Set nv = CreateObject( "WbemScripting.SWbemNamedValueSet" )
	Set locator = CreateObject( "Wbemscripting.SWbemLocator" )

	nv.Add  "__ProviderArchitecture", RegType
	Set reg = locator.ConnectServer( "", "root\default", "", "", , , , nv ).Get( "StdRegProv" )

	Set in_params = reg.Methods_( "GetStringValue" ).InParameters
	in_params.hDefKey = root_key
	in_params.sSubKeyName = g_fs.GetParentFolderName( step_path )
	in_params.sValueName = g_fs.GetFileName( step_path )

	Set out_params = reg.ExecMethod_( "GetStringValue", in_params, , nv )

	RegReadEx = out_params.sValue
	If IsNull( RegReadEx ) Then  RegReadEx = Empty
End Function


 
'*************************************************************************
'  <<< [RegEnumKeys] >>> 
'*************************************************************************
Sub  RegEnumKeys( Path, out_Keys, Opt )
	Dim    keys, key, i, root_key, step_path, i_step_path

	If IsEmpty( g_StdRegProv ) Then _
		Set g_StdRegProv = GetObject("winmgmts:{impersonationLevel=impersonate}!root/default:StdRegProv")

	GetRegRootKeyAndStepPath  Path, root_key, step_path  '//[out] root_key, step_path

	Set keys = new ArrayClass
	RegEnumKeys_sub  Path, root_key, step_path, keys  '//[out] keys

	If not IsEmpty( Opt ) Then

		i_step_path = InStr( Path, "\" ) + 1
		i = 0
		Do
			If i > keys.UBound_ Then  Exit Do
			RegEnumKeys_sub  keys(i), root_key, Mid( keys(i), i_step_path ), keys  '//[out] keys
			i=i+1
		Loop
	End If

	out_Keys = keys.Items
End Sub


Sub  RegEnumKeys_sub( AbsPath, RootKey, StepPath, in_out_Keys )
	Dim  key_names, key_name

	g_StdRegProv.EnumKey  RootKey, StepPath, key_names  '//[out] key_names
	If IsNull( key_names ) Then  ReDim  key_names(-1)

	For Each key_name  In key_names
		in_out_Keys.Add  AbsPath +"\"+ key_name
	Next
End Sub


Sub  GetRegRootKeyAndStepPath( AbsPath, out_RootKey, out_StepPath )
	Dim  i

	i = InStr( AbsPath, "\" )
	If i = 0 Then  RaiseRegPathNotFound  AbsPath
	Select Case  Left( AbsPath, i - 1 )
		Case "HKEY_CLASSES_ROOT"   : out_RootKey = &h80000000
		Case "HKEY_CURRENT_USER"   : out_RootKey = &h80000001
		Case "HKEY_LOCAL_MACHINE"  : out_RootKey = &h80000002
		Case "HKEY_USERS"          : out_RootKey = &h80000003
		Case "HKEY_PERFORMANCE_DATA":out_RootKey = &h80000004
		Case "HKEY_CURRENT_CONFIG" : out_RootKey = &h80000005
		Case "HKEY_DYN_DATA"       : out_RootKey = &h80000006
		Case Else : RaiseRegPathNotFound  AbsPath
	End Select

	out_StepPath = Mid( AbsPath, i + 1 )
End Sub


Sub  RaiseRegPathNotFound( Path )
	Raise  E_PathNotFound, "<ERROR msg=""指定したパスがレジストリにありません"" path="""+ Path +"""/>"
End Sub

 
'*************************************************************************
'  <<< [RegEnumValues] >>> 
'*************************************************************************
Class  RegValueName
	Public  Name
	Public  Type_
End Class


Sub  RegEnumValues( Path, out_Values )
	Dim  reg, i, root_key, step_path, names, types

	If IsEmpty( g_StdRegProv ) Then _
		Set g_StdRegProv = GetObject("winmgmts:{impersonationLevel=impersonate}!root/default:StdRegProv")

	GetRegRootKeyAndStepPath  Path, root_key, step_path  '//[out] root_key, step_path

	g_StdRegProv.EnumValues  root_key, step_path, names, types
	If IsNull( names ) Then  ReDim  out_Values(-1) : Exit Sub

	ReDim  out_Values( UBound( names ) )
	For i=0 To UBound( names )

		Set  out_Values(i) = new RegValueName : ErrCheck

		out_Values(i).Name = names(i)

		Select Case  types(i)
			Case 1 : out_Values(i).Type_ = "REG_SZ"
			Case 2 : out_Values(i).Type_ = "REG_EXPAND_SZ"
			Case 3 : out_Values(i).Type_ = "REG_BINARY"
			Case 4 : out_Values(i).Type_ = "REG_DWORD"
			Case 7 : out_Values(i).Type_ = "REG_MULTI_SZ"
		End Select
	Next
End Sub


 
'*************************************************************************
'  <<< [RegExists] >>> 
'*************************************************************************
Function  RegExists( Path )
	Dim en,ed
	Const  E_PathNotFound = &h80070002

	ErrCheck : On Error Resume Next
		g_sh.RegRead  Path
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_PathNotFound Then  RegExists = False : Exit Function
	If en <> 0 Then  Err.Raise en,,ed
	RegExists = True
End Function


 
'********************************************************************************
'  <<< [IsRegEmptyKey] >>> 
'********************************************************************************
Function  IsRegEmptyKey( in_Key )
	Assert  Right( in_Key, 1 ) <> "\"
	If RegExists( in_Key +"\" ) Then
		RegEnumKeys  in_Key,  keys,  Empty  '// Set "keys"
		RegEnumValues  in_Key,  values  '// Set "values"
		IsRegEmptyKey = ( UBound( keys ) = -1  and  UBound( values ) = -1 )
	Else
		IsRegEmptyKey = False
	End If
End Function


 
'*************************************************************************
'  <<< [LoadReg] >>> 
'*************************************************************************
Function  LoadReg( PathOrStr, Opt )
	Set LoadReg = new RegFileClass

	If VarType( Opt ) = vbString Then
		LoadReg.m_InterestKeys = Array( Opt )
		LoadReg.ReadFile  PathOrStr
	ElseIf IsArray( Opt ) Then
		LoadReg.m_InterestKeys = Opt
		LoadReg.ReadFile  PathOrStr
	ElseIf Opt and g_VBS_Lib.StringData Then
		Dim  f : Set f = new StringStream
		f.SetString  Opt
		LoadReg.ParseReg  f
	Else
		LoadReg.ReadFile  PathOrStr
	End If
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [RegFileClass] Class >>>> 
'-------------------------------------------------------------------------
Class  RegFileClass

	Dim  m_Variables ' as Dictionary. key=registory key and variable name, value=value
	Function  RegRead( Path ) : RegRead = m_Variables.Item( Path ) : End Function

	Dim  m_InterestKeys ' as Array of string

	Private Sub  Class_Initialize
		Set m_Variables = CreateObject( "Scripting.Dictionary" )
	End Sub


 
'*************************************************************************
'  <<< [RegFileClass::ReadFile] >>> 
'*************************************************************************
Sub  ReadFile( Path )
	Me.ParseReg  OpenForRead( Path )
End Sub

Sub  ParseReg( Stream )
	Dim  line, i, current_key, name, type_name, value, b_enabled

	b_enabled = IsEmpty( m_InterestKeys )

	Do Until  Stream.AtEndOfStream
		line = Stream.ReadLine()

		If Left( line, 1 ) = "[" Then
			current_key = Trim2( Mid( line, 2 ) ) : CutLastOf  current_key, "]", Empty

			'// Set b_enabled
			If not IsEmpty( m_InterestKeys ) Then
				b_enabled = False
				For Each i  In m_InterestKeys
					If i = current_key Then  b_enabled = True : Exit For
				Next
			End If

		ElseIf b_enabled Then
			i = InStr( line, "=" )
			If i > 0 Then  line = Left( line, i-1 ) +" "+ Mid( line, i+1 )

			i = 1
			name = MeltCmdLine( line, i )
			If i > 0 Then
				type_name = "dword:"
				i = InStr( i, line, type_name )
				If i > 0 Then
					i = i + Len( type_name )
					m_Variables.Item( current_key +"\"+ name ) = CLng( "&h" + Mid( line, i ) )
				End If
			End If
		End If
	Loop
End Sub


 
End Class 


 
'*************************************************************************
'  <<< [LoadEnvVars] >>> 
'*************************************************************************
Sub  LoadEnvVars( Path_ofSetCommandLog, Option_ )
	Dim  f, line, key, b, i, envs
	Dim  c : Set c = g_VBS_Lib

	If TypeName( Option_ ) = "Dictionary" Then
		Set envs = Option_
		envs.RemoveAll
	Else
		Set envs = g_sh.Environment( "Process" )
		If (Option_ and c.Append) = 0 Then  ClearEnvVars
	End If

	If VarType( Path_ofSetCommandLog ) = vbString Then
		echo  ">LoadEnvVars  """+ Path_ofSetCommandLog +""""
		Dim  ec : Set ec = new EchoOff

		Set f = OpenForRead( Path_ofSetCommandLog )
		Do Until  f.AtEndOfStream
			line = f.ReadLine()
			i = InStr( line, "=" )
			envs.Item( Trim2( Left( line, i-1 ) ) ) = Mid( line, i+1 )
		Loop

	Else

		For Each key  In Path_ofSetCommandLog.Keys
			envs.Item( key ) = Path_ofSetCommandLog.Item( key )
		Next

	End If
End Sub


 
'*************************************************************************
'  <<< [ClearEnvVars] >>> 
'*************************************************************************
Sub  ClearEnvVars()
	echo  ">ClearEnvVars"

	Dim    envs : Set envs = g_sh.Environment( "Process" )
	ReDim  symbols( envs.Count - 1 )

	If not IsEmpty( g_CurrentVarStackSub ) Then
		For Each  env_line  In envs
			index_of_equal = InStr( env_line, "=" )
			If index_of_equal >= 2 Then
				env_name = Left( env_line, index_of_equal - 1 )
				env_value = Mid( env_line, index_of_equal + 1 )
				g_CurrentVarStackSub.SetPrevValue1_IfNotExist  env_name, env_value
			End If
		Next
	End If


	'//=== Listup variables
	Dim  line, i, n
	n = -1
	For Each line  In envs
		i = InStr( line, "=" )
		If i >= 2 Then
			n=n+1
			symbols( n ) = Left( line, i-1 )
		End If
	Next


	'//=== for all ADODB.Stream objects, when environment variables was removed
	Set g_ADODB_Stream_Cache = CreateObject( "ADODB.Stream" )


	'//=== Remove variables
	ReDim Preserve  symbols( n )
	For Each line  In symbols
		envs.Remove  line
	Next
End Sub

Dim g_ADODB_Stream_Cache


 
'*************************************************************************
'  <<< [SetVarInBatchFile] >>> 
'*************************************************************************
Sub  SetVarInBatchFile( Path, Symbol, Value )
	Set ec = new EchoOff

	AssertExist( Path )
	text = ReadFile( Path )


	Set re = CreateObject("VBScript.RegExp")
	re.IgnoreCase = True
	re.MultiLine = True
	re.Pattern = "^ *set *"+ ToRegExpPattern( Symbol ) +"="

	Set matches = re.Execute( text )
	If matches.Count = 0 Then
		Raise  E_NotFoundSymbol, "<ERROR msg=""指定した環境変数は存在しません"" var="""+_
			Symbol +""" path="""+ GetFullPath( Path, Empty ) +"""/>"
	End If

	Set match = matches(0)
	equal_position = match.FirstIndex + match.Length

	end_of_line = InStr( equal_position, text, vbCRLF )

	text = Left( text, equal_position ) & Value & Mid( text, end_of_line )


	CreateFile  Path, text
End Sub


 
'*************************************************************************
'  <<< [GetPythonInstallPath] >>> 
'*************************************************************************
Dim  g_PythonExePath
Dim  g_TargetPythonVersionMin
Dim  g_TargetPythonVersionMax

Function  GetPythonInstallPath()
	If IsEmpty( g_PythonExePath ) Then
		Dim  keys,  keys_tmp,  key,  ver,  best_ver,  python_ver_key

		Set keys = new ArrayClass
		RegEnumKeys  "HKEY_LOCAL_MACHINE\SOFTWARE\Python\PythonCore", keys_tmp, Empty
		keys.AddElems  keys_tmp
		RegEnumKeys  "HKEY_CURRENT_USER\SOFTWARE\Python\PythonCore", keys_tmp, Empty
		keys.AddElems  keys_tmp

		For Each key  In keys.Items
			If RegExists( key +"\InstallPath\" ) Then
				ver = CSng( g_fs.GetFileName( key ) )

				If not IsEmpty( g_TargetPythonVersionMin ) Then
					If ver < g_TargetPythonVersionMin Then  ver = Empty
				End If
				If not IsEmpty( g_TargetPythonVersionMax ) Then
					If ver > g_TargetPythonVersionMax Then  ver = Empty
				End If
				If not IsEmpty( ver ) Then
					If ver > best_ver Then  best_ver = ver : python_ver_key = key
				End If
			End If
			'// メモ：アンインストールしても key +"\Modules\" は残っています
		Next

		If IsEmpty( best_ver ) Then _
			Raise  1, "Python がレジストリに登録されていません。"

		g_PythonExePath = RegRead( python_ver_key +"\InstallPath\" )
		CutLastOf  g_PythonExePath, "\", Empty
	End If
	GetPythonInstallPath = g_PythonExePath
End Function


 
'*************************************************************************
'  <<< [IsInstallPython] >>> 
'*************************************************************************
Dim  g_IsInstallPython

Function  IsInstallPython()
	If IsEmpty( g_IsInstallPython ) Then
		Dim  path,  e

		If TryStart(e) Then  On Error Resume Next
			path = GetPythonInstallPath()
		If TryEnd Then  On Error GoTo 0
		g_IsInstallPython = ( e.num = 0 )
		e.Clear
	End If
	IsInstallPython = g_IsInstallPython
End Function


 
'*************************************************************************
'  <<< [SetTargetPythonVersion] >>> 
'*************************************************************************
Sub  SetTargetPythonVersion( MinVer, MaxVer )
	g_PythonExePath = Empty
	g_IsInstallPython = Empty
	g_TargetPythonVersionMin = MinVer
	g_TargetPythonVersionMax = MaxVer
End Sub


 
'*************************************************************************
'  <<< [GetPerlVersion] >>> 
'*************************************************************************
Function  GetPerlVersion( Options )
	temporary_path = GetTempPath( "GetPerlVersion.txt" )
	Set ec = new EchoOff

	If TryStart(e) Then  On Error Resume Next

		RunProg  "perl -v", temporary_path

	If TryEnd Then  On Error GoTo 0
	If e.num = &h80070002  Then
		perl_exe = Setting_getPerlPath()
		If not exist( perl_exe ) Then
			Raise  e.num, "Perl が見つからないか Perl に Path が通っていません。"+_
				"Strawberry Perl や Active Perl などをインストールしてください。"
		End If
		e.Clear

		set_ "PATH", AddIfNotExist( env("%PATH%"), _
			g_fs.GetParentFolderName( perl_exe ), ";", Empty )
		RunProg  "perl -v", temporary_path
	End If
	If e.num <> 0 Then  e.Raise

	Set numbers = ScanFromTemplate( ReadFile( temporary_path ), _
		"This is perl ${Major}, version ${Minor}, subversion ${Sub} (", _
		Array( "${Major}", "${Minor}", "${Sub}" ), Empty )
	GetPerlVersion = numbers("${Major}") +"."+ _
		numbers("${Minor}") +"."+ numbers("${Sub}")

	del  temporary_path
End Function


 
'*-------------------------------------------------------------------------*
'* ### <<<< Error, Err2 >>>> 
'*-------------------------------------------------------------------------*


 
'*************************************************************************
'  <<< [Finish] >>> 
'*************************************************************************
Sub  Finish()
	ThisIsOldSpec
	Stop:WScript.Quit  9
End Sub


 
'*************************************************************************
'  <<< [Error] >>> 
'*************************************************************************
Sub  Error()
	Raise  1,"General Error"
End Sub


 
'*************************************************************************
'  <<< [OrError] Stop:OrError >>> 
'*************************************************************************
Sub  OrError()
	If g_debug <= 0 Then
		If Err.Number <> 0  or  g_Err2.Number <> 0 Then _
			g_Err2.Clear

		Raise  1,"Stop:OrError"
	End If
End Sub


 
'*************************************************************************
'  <<< [Warning] >>> 
'*************************************************************************

'//[g_WarningMSec]
g_WarningMSec = 300

Sub  Warning( Description )
	echo_v  "<WARNING msg="""& Description &"""/>"
	Sleep  g_WarningMSec
	Err.Raise  E_TestPass
End Sub


 
'*************************************************************************
'  <<< [Assert] >>> 
'*************************************************************************
Sub  Assert( Condition )
	If Condition Then '// This is not same behavior as "If not Condition Then Fail"
	Else
		Fail
	End If
End Sub


 
'*************************************************************************
'  <<< [AssertExist] >>> 
'*************************************************************************
Sub  AssertExist( Path )
	path_string = GetFilePathString( Path )
	Set c = g_VBS_Lib
	If not exist_ex( path_string, c.CaseSensitive ) Then
		If IsFullPath( path_string ) Then
			s = path_string
		Else
			s = path_string +""""+ vbCRLF +" full_path="""+ GetFullPath( path_string, Empty )
		End If

		If exist( path_string ) Then
			echo_v  "<WARNING msg=""大文字小文字が異なります"" call="""+ s + """"+ vbCRLF +_
				" name="""+ GetCaseSensitiveFullPath( path_string ) +"""/>"
		Else
			Raise  E_PathNotFound, _
				"<ERROR msg=""ファイルまたはフォルダーが見つかりません"" path="""+ s +"""/>"
		End If
	End If
End Sub


 
'*************************************************************************
'  <<< [Assert2Exist] >>> 
'*************************************************************************
Sub  Assert2Exist( in_PathA, in_PathB )
	Set c = g_VBS_Lib
	path_string_A = GetFilePathString( in_PathA )
	path_string_B = GetFilePathString( in_PathB )
	not_exist = ""

	For Each  path_string  In  Array( path_string_A,  path_string_B )

		If not exist_ex( path_string, c.CaseSensitive ) Then
			If IsFullPath( path_string ) Then
				s = path_string
			Else
				s = path_string +""""+ vbCRLF +" full_path="""+ GetFullPath( path_string, Empty )
			End If

			If exist( path_string ) Then
				echo_v  "<WARNING msg=""大文字小文字が異なります"" call="""+ s + """"+ vbCRLF +_
					" name="""+ GetCaseSensitiveFullPath( path_string ) +"""/>"
			Else
				If path_string = path_string_A Then
					not_exist = "A"
				Else
					If not_exist = "" Then
						not_exist = "B"
					Else
						not_exist = "A,B"
					End If
				End If
			End If
		End If
	Next
	If not_exist <> "" Then

		Raise  E_PathNotFound, _
			"<ERROR msg=""片方または両方のファイルまたはフォルダーが見つかりません"""+ vbCRLF + _
				" path_A="""+ GetFullPath( path_string_A, Empty ) +""""+ vbCRLF + _
				" path_B="""+ GetFullPath( path_string_B, Empty ) +""""+ vbCRLF + _
				" not_exist="""+ not_exist +"""/>"
	End If
End Sub


 
'***********************************************************************
'* Function: AssertFullPath
'***********************************************************************
Sub  AssertFullPath( in_Path,  in_NameOfPath )
	If not IsFullPath( in_Path ) Then
		Raise  E_PathNotFound, _
			"<ERROR msg=""フル パスを設定してください。可能ならフル パスの先頭は変数にしてください。""  name="""+ _
			XmlAttr( in_NameOfPath ) +"""  path="""+ XmlAttr( in_Path ) +"""/>"
	End If
End Sub


 
'*************************************************************************
'  <<< [AssertValue] >>> 
'*************************************************************************
Sub  AssertValue( Name, Value, PassValue, CompareOption )
	If IsArray( PassValue ) Then
		AssertValue_sub  Name, Value, PassValue, CompareOption
	Else
		AssertValue_sub  Name, Value, Array( PassValue ), CompareOption
	End If
End Sub

Sub  AssertValue_sub( Name, ByVal Value, PassValues, CompareOption )
	Dim  value2, pass_value, i
	Dim  c : Set c = g_VBS_Lib
	Dim  b_case_sensitive : b_case_sensitive = ( ( CompareOption and c.CaseSensitive ) <> 0 )


	'//=== get value
	If IsObject( Value ) Then
		If Value Is c.EnvVar Then  Value = GetVar( Name )
	End If


	If CompareOption and c.Range Then

		'//=== compare value range
		value2 = CInt2( Value )
		For i=0 To UBound( PassValues ) Step 2
			If value2 >= CInt2( PassValues( i ) ) and  value2 <= CInt2( PassValues( i+1 ) ) Then  Exit Sub
		Next

	Else

		'//=== compare a value or values
		If not b_case_sensitive Then  value2 = LCase( Value )  Else  value2 = Value
		For Each pass_value  In PassValues
			If b_case_sensitive Then
				If value2 = pass_value Then  Exit Sub
			Else
				If value2 = LCase( pass_value ) Then  Exit Sub
			End If
		Next
	End If
	ErrorValue  Name, Value
End Sub


 
'*************************************************************************
'  <<< [AssertD_TypeName] >>> 
'    Asserts type name for debug configuration
'*************************************************************************
Sub  AssertD_TypeName( in_Value, in_ExpectedTypeName )
	If g_is_debug Then
		If TypeName( in_Value ) <> in_ExpectedTypeName Then
			Raise  1, "<ERROR msg=""型チェックに失敗しました。""  type="""+ GetEchoStr( in_Value ) + _
				"""  expected="""+ in_ExpectedTypeName +"""/>"
		End If
	End If
End Sub


 
'*************************************************************************
'  <<< [ErrorValue] >>> 
'*************************************************************************
Sub  ErrorValue( Name, Value )
	Raise  1, "<ERROR msg=""値が想定外です"" name="""+ Name + """ now_value="""& Value &"""/>"
End Sub


 
'*************************************************************************
'  <<< [Err2] >>> 
'*************************************************************************
Class Err2

	Public  Num           ' Err.Number
	Public  Property Get  Number() : Number = Num : End Property
	Public  Property Let  Number(x) : Num = x : End Property
	Public  Desc          ' Err.Description (Error Message)
	Public  Property Get  Description() : Description = Desc : End Property
	Public  Property Let  Description(x) : Desc = x : End Property
	Public  Source       ' Err.Source
	Public  Queue        ' as string
	Public  ChildProcess_CallID  ' as ArrayClass of integer. g_InterProcess.ProcessCallID in Error
	Public  ErrID        ' count of (num <> 0) in each first Copy after Clear
	Public  RaiseID      ' count of (num <> 0) in Copy
	Public  CopiedErrID  ' as integer
	Public  Prev         ' as Err2
	Public  Break_ChildProcess_CallID  ' as array of integer
	Public  BreakErrID   ' as integer
	Public  BreakRaiseID ' as integer
	Public  a_NestPos       ' as NestPos
	Public  BreakNestPos    ' as Array of integer
	Public  ErrNestPos      ' as Array of integer
	Public  PrevErrNestPos  ' as Array of integer

	Private Sub  Class_Initialize()
		Me.Num = 0 : Me.Desc = "" : Me.Queue = ""
		Me.ErrID = 0 : Me.RaiseID = 0 : Set Me.ChildProcess_CallID = new ArrayClass
		Me.BreakErrID = 0 : Me.BreakRaiseID = 0 : Set Me.Break_ChildProcess_CallID = new ArrayClass
		Set Me.a_NestPos = new NestPos
		Me.BreakNestPos = Array( )
		Me.ErrNestPos = Array( )
		Me.PrevErrNestPos = Array( )
	End Sub

	Public Sub  OnSuccessFinish()
		If Err.Number = 0 and Me.Num <> 0 Then
			echo  Me.ErrStr
			Me.Clear

			On Error Resume Next
			Err.Raise  1,, "<ERROR msg='エラー処理の途中で終了しました。Err2.Clear または再 Raise してください'/>"
			Me.Copy  Err
			Me.ErrID = Me.ErrID - 0.5
			If get_ChildProcess() is Nothing  Then
				echo  g_ConnectDebugMsgV5 + vbCRLF +String( 70, "-" )+ vbCRLF + _
					""""+ WScript.ScriptName +""" /g_debug:"& Me.ErrID & vbCRLF + String( 70, "-" )
			Else
				If Me.ChildProcess_CallID.UBound_ = -1 Then
					Me.ChildProcess_CallID.Copy  g_InterProcess.ProcessCallID
					Me.ChildProcess_CallID.Pop
				End If
			End If
		ElseIf Err.Number <> 0 Then
			Me.PrevErrNestPos = Me.a_NestPos.PosArr
		End If
	End Sub

	Public Sub  OnErrorFinish()
		If Err.Number <> 0 and Me.Num = 0 Then  Me.Copy Err
		If Me.Num <> 0 Then
			If get_ChildProcess() is Nothing  Then
				echo  Me.GetDebugHintPart()
			Else
				If Me.ChildProcess_CallID.UBound_ = -1 Then
					Me.ChildProcess_CallID.Copy  g_InterProcess.ProcessCallID
					Me.ChildProcess_CallID.Pop
				End If
			End If
		End If
	End Sub

	Public Sub  Copy( err )
		Me.Num = err.Number
		Me.Desc = err.Description
		Me.Source = err.Source
		If Me.Num <> 0 Then
			Me.RaiseID = Me.RaiseID + 1 : If Me.RaiseID = 1 Then Me.ErrID = Me.ErrID + 1
			If UBound( Me.ErrNestPos ) = -1 Then  Me.ErrNestPos = Me.a_NestPos.PosArr
		End If
	End Sub

	Public Sub  CopyAndClear( out_Err2Copy )
		Set out_Err2Copy = new Err2
		out_Err2Copy.Copy  Me
		If Me.num <> 0 Then _
			Me.CopiedErrID = Me.ErrID
		Me.Clear
	End Sub

	Public Sub  EnqueueAndClear()
		If Me.Num = 0 Then  Exit Sub
		Dim  s : s = Me.ErrStr()
		s = Left( s, Len( s ) - 2 ) + " g_debug='"& Me.ErrID
		Dim  tree, process : GetDebugHintData  tree, process
		If not IsEmpty( tree ) Then  s = s +"' g_debug_tree='Array( "& tree &" )"
		If not IsEmpty( process ) Then  s = s +"' g_debug_process='"& process
		s = s + "'/>"
		Me.Queue = Me.Queue + s + vbCRLF
		Me.Clear
	End Sub

	Public Function  DequeueAll()
		DequeueAll = Me.Queue
		Me.Queue = ""
	End Function

	Public Function  GetErrStr() : ThisIsOldSpec : GetErrStr = Me.ErrStr : End Function
	Public Property Get  ErrStr() : ErrStr = GetRef("GetErrStr")( Me.Num, Me.Desc ) : End Property

	Public Property Get  DebugHint()
		DebugHint = Me.GetDebugHintPart()
		DebugHint = DebugHint + vbCRLF + GetRef("GetErrStr")( Me.Num, Me.Desc )
	End Property

	Public Function  GetDebugHintPart()
		Dim  tree, process : GetDebugHintData  tree, process

		GetDebugHintPart = g_ConnectDebugMsgV5 + vbCRLF +String( 70, "-" )+ vbCRLF + _
			""""+ WScript.ScriptName +""" /g_debug:"& Me.ErrID
		If not IsEmpty( tree ) Then _
			GetDebugHintPart = GetDebugHintPart +","& Replace( tree, " ", "" )
		If not IsEmpty( process ) Then _
			GetDebugHintPart = GetDebugHintPart +";"& process

		If Me.CopiedErrID = Me.ErrID - 1  and  not IsEmpty( Me.CopiedErrID ) Then _
			GetDebugHintPart = GetDebugHintPart + vbCRLF +_
			"'//エラーが発生した場所を知るには、CopyAndClear する前に Raise してください。"
		GetDebugHintPart = GetDebugHintPart + vbCRLF + String( 70, "-" )
	End Function

	Public Sub  GetDebugHintData( out_Tree, out_Process )
		If UBound( Me.ErrNestPos ) >= 0  and  UBound( Me.PrevErrNestPos ) >= 0  Then
			Dim  i, tree
			For i=0 To UBound( Me.ErrNestPos ) - 1
				If Me.ErrNestPos(i) <> Me.PrevErrNestPos(i) Then  Exit For
			Next
			If i > 0 Then
				tree = Me.ErrNestPos : ReDim Preserve  tree(i-1)
				out_Tree = ""
				For i=0 To UBound( tree )
					out_Tree = out_Tree & tree(i) &", "
				Next
				CutLastOf  out_Tree, ", ", Empty
			End If
		End If
		If Me.ChildProcess_CallID.UBound_ = 0 Then
			out_Process = Me.ChildProcess_CallID(0)
		ElseIf Me.ChildProcess_CallID.UBound_ >= 1 Then
			out_Process = Me.ChildProcess_CallID.CSV
		End If
	End Sub

	Public Sub OverRaise( e_num, e_desc )
		Me.Num = e_num : Me.Desc = e_desc : Me.Raise
	End Sub

	Public Sub  Raise()
		If Me.Num = 0 Then
			Err.Raise  1
				'// エラーは発生していません。
				'// デバッガーを使って呼び出し元を確認してください。
		Else
			Err.Raise Me.Num, Me.Source, Me.Desc  '// 前のエラーを再度投げる。
			 '// デバッガーを使って呼び出し元を確認してください。
			 '// SetupVbslibParameters 関数の中に "g_debug" = 1 (=Me.Num) or (=Me.Num+0.5) を記述してください。
		End If
	End Sub

	Public Sub  Clear()
		If Me.Num <> 0 Then
			Me.PrevErrNestPos = Me.ErrNestPos
			Me.Num = 0 : Me.Desc = "" : Me.RaiseID = 0 : Me.ChildProcess_CallID.ToEmpty
			Me.ErrNestPos = Array( )
			Me.Prev = Empty
			'//echo_v "<TryStartEnd func='Err2:Clear' prev_err_nest_pos='"& UBound( Me.PrevErrNestPos ) &"'/>"
		End If
	End Sub


	Property Get  xml()
		xml = "<"+ TypeName( Me ) +" number="""& Me.Num &""" description="""+_
			XmlAttr( Me.Desc ) +""" source="""+ XmlAttr( Me.Source ) +""" err_id="""& Me.ErrID &_
			""" raise_id="""& Me.RaiseID &""" sub_process_call_id="""+ Me.ChildProcess_CallID.CSV +_
			""" break_err_id="""& Me.BreakErrID &""" break_raise_id="""& Me.BreakRaiseID &_
			""" break_sub_process_call_id="""+ Me.Break_ChildProcess_CallID.CSV +_
			""" a_nest_pos="""+ CSVFrom( Me.a_NestPos.PosArr ) +""" break_nest_pos="""+ CSVFrom( Me.BreakNestPos ) +_
			""" err_nest_pos="""+ CSVFrom( Me.ErrNestPos ) +""" prev_err_nest_pos="""+ CSVFrom( Me.PrevErrNestPos ) +"""/>"
	End Property

	Public Sub  loadXML( XmlObject )
		Me.Num = CInt2( XmlObject.getAttribute( "number" ) )
		Me.Desc = XmlObject.getAttribute( "description" )
		Me.Source = XmlObject.getAttribute( "source" )
		Me.ErrID = CSng( XmlObject.getAttribute( "err_id" ) )
		Me.RaiseID = CInt2( XmlObject.getAttribute( "raise_id" ) )
		Me.ChildProcess_CallID.ToEmpty
		Me.ChildProcess_CallID.AddCSV  XmlObject.getAttribute( "sub_process_call_id" ), vbInteger
		Me.BreakErrID = CSng( XmlObject.getAttribute( "break_err_id" ) )
		Me.BreakRaiseID = CInt2( XmlObject.getAttribute( "break_raise_id" ) )
		Me.Break_ChildProcess_CallID.ToEmpty
		Me.Break_ChildProcess_CallID.AddCSV  XmlObject.getAttribute( "break_sub_process_call_id" ), vbInteger
		Me.a_NestPos.PosArr = ArrayFromCSV_Int( XmlObject.getAttribute( "a_nest_pos" ) )
		Me.BreakNestPos = ArrayFromCSV_Int( XmlObject.getAttribute( "break_nest_pos" ) )
		Me.ErrNestPos = ArrayFromCSV_Int( XmlObject.getAttribute( "err_nest_pos" ) )
		Me.PrevErrNestPos = ArrayFromCSV_Int( XmlObject.getAttribute( "prev_err_nest_pos" ) )
	End Sub


'// Err2 has_interface_of InterProcessData
	Public Sub  OnCallInParent( a_ParentProcess )   : a_ParentProcess.m_OutFile.WriteLine Me.xml : End Sub
	Public Sub  OnReturnInChild( a_ChildProcess )   :  a_ChildProcess.m_OutFile.WriteLine Me.xml : End Sub
	Public Sub  OnReturnInParent( a_ParentProcess ) : Me.loadXML  a_ParentProcess.m_InXML.selectSingleNode( TypeName(Me) ) : End Sub
End Class


 
'*************************************************************************
'  <<< [Raise] >>> 
'*************************************************************************
Sub  Raise( ErrNum, Description )
	Dim  e : Set e = g_Err2

	If g_is_debug Then  Set e.Prev = new Err2 : e.Prev.Copy  e

	e.Num = ErrNum
	e.Source = "ERROR"
	e.Desc = Description
	e.RaiseID = e.RaiseID + 1 : If e.RaiseID = 1 Then e.ErrID = e.ErrID + 1

	Err.Raise  e.Num, e.Source, e.Desc
			'// g_debug > 0 のとき（On Error Resume Next していないとき）は、
			'// ここで標準エラー出力（コマンドプロンプト・ウィンドウなど）に
			'// エラーメッセージが出力されます。 vbslib の Pass 関数のときでも、
			'// C:\Folder\Sample.vbs(0, 1) ERROR: Pass. のように出力されます。
End Sub

Dim  g_IsDefinedRaise : g_IsDefinedRaise = True


 
'*************************************************************************
'  <<< [SetErrBreak] >>> 
'*************************************************************************
Sub  SetErrBreak( ErrID, RaiseID )
	g_Err2.BreakErrID = ErrID
	g_Err2.BreakRaiseID = RaiseID
End Sub


 
'*************************************************************************
'  <<< [NestPos] >>> 
'*************************************************************************
Class  NestPos
	Public  PosArr

	Private Sub Class_Initialize()
		Redim  PosArr(0)
		PosArr(0) = 0
	End Sub

	Public Sub  Start()
		Dim  u : u = UBound( PosArr )
		PosArr(u) = PosArr(u) + 1
		Redim Preserve  PosArr(u+1)
		PosArr(u+1) = 0
	End Sub

	Public Sub  End_()
		Redim Preserve  PosArr( UBound( PosArr ) - 1 )
	End Sub
End Class


 
'*************************************************************************
'  <<< [NotCallFinish] >>> 
'*************************************************************************
Sub  NotCallFinish()
	Err.Raise  1,,"<ERROR msg=""Not call Finish""/>"
End Sub


 
'*************************************************************************
'  <<< [ErrorCheckInTerminate] >>> 
'*************************************************************************
Sub  ErrorCheckInTerminate( ErrNumberAtStartOfClassTerminate )
	If ( Err.Number <> 0  and _
	     Err.Number <> 21 )  and _
	   ( ErrNumberAtStartOfClassTerminate = 0  or _
	     ErrNumberAtStartOfClassTerminate = 21 ) Then
		echo_v  GetErrStr( Err.Number, Err.Description + " in Class_Terminate" )
		Stop
		If g_is_cscript_exe  and  not g_IsAutoTest Then  Pause
		ErrNumberAtStartOfClassTerminate = Err.Number
	End If
End Sub


 
'*************************************************************************
'  <<< [TryStart] >>> 
'*************************************************************************
Function TryStart( e )
	Dim  i, b
	Set  e = g_Err2

	If Err.Number <> 0 or e.Num <> 0 Then
		Stop  '// ここで、１つ前のエラーを確認してください。
		Raise  1,"<ERROR msg=""エラーが発生しているときに TryStart は呼べません。 "+_
			"TryStart のドキュメントを参照してください。"">" +vbCRLF+_
			e.Desc +vbCRLF +"</ERROR>"
	End If

	e.a_NestPos.Start

	If IsEmpty( e.BreakErrID ) Then
		TryStart = True
	Else

		'//=== g_debug_tree (=e.BreakNestPos)
		b=( not IsEmpty( e.BreakNestPos ) )  'and
		If b Then b=( UBound( e.a_NestPos.PosArr ) <= UBound( e.BreakNestPos ) + 1 )
		If b Then
			For i=0 To UBound( e.a_NestPos.PosArr ) - 1
				If e.BreakNestPos(i) <> e.a_NestPos.PosArr(i) Then  Exit For
			Next
			If i = UBound( e.a_NestPos.PosArr ) Then
				TryStart = False
			Else
				TryStart = True
			End If

		'//=== g_debug (=e.BreakErrID)
		Else
			If e.ErrID = e.BreakErrID - 1 Then
				TryStart = False
			Else
				TryStart = True
			End If
		End If
	End If

'//echo_v  e.xml
'//echo_v  "<TryStartEnd func='TryStart' nest='"& UBound( e.a_NestPos.PosArr ) &"' return='"& TryStart &"'/>"
End Function


 
'*************************************************************************
'  <<< [Trying] >>> 
'*************************************************************************
Function Trying()
	Trying = (Err.Number=0)
	If not Trying Then
		If g_Err2.ErrID = g_Err2.BreakErrID - 1.5 Then _
			Stop  '// デバッガーを使って呼び出し元を確認してください。
	End If
End Function


 
'*************************************************************************
'  <<< [TryEnd] >>> 
'*************************************************************************
Function TryEnd()
' Do not have parameters.
' Because "If TryEnd(e) Then On Error Goto 0" cannot get error, if e is not Dim.

	Dim  e : Set e = g_Err2

	If Err.Number <> 0 Then
		e.Copy Err

		If e.ErrID = e.BreakErrID Then
			TryEnd = False
		Else
			TryEnd = True
		End If

		If e.ErrID = e.BreakErrID - 0.5 Then  Stop
			'// [g_debug+0.5] デバッガーを使って呼び出し元を確認してください。
	Else
		If g_Err2.Num <> 0 Then _
			echo  "<WARNING msg=""ここの TryEnd より内部の TryEnd でキャッチしたエラーは、内部で g_Err2.Clear するか、再度エラーを発生させる必要があります""/>"
		TryEnd = True
	End If

	e.a_NestPos.End_

'//echo_v  e.xml
'//echo_v  "<TryStartEnd func='TryEnd' nest='"& (UBound( e.a_NestPos.PosArr )+1) &"' return='"& TryEnd &"'/>"
'//If IsSameArray( e.a_NestPos.PosArr, Array( 1,1,2,1,1 ) ) Then  Stop
End Function


 
'*************************************************************************
'  <<< [ErrCheck] >>> 
'*************************************************************************
Sub  ErrCheck()
	If Err.Number <> 0 Then  If g_Err2.Num = 0  Then  g_Err2.Copy Err : g_Err2.Raise
End Sub


 
'*************************************************************************
'  <<< [chk_exist_in_lib] >>> 
' comment
'  - If there is not path in vbslib folder, raise error of E_FileNotExist.
'*************************************************************************
Sub  chk_exist_in_lib( ByVal path )
	If not exist( g_vbslib_ver_folder + path ) Then  Err.Raise  E_FileNotExist,, _
		"Not found """ + g_vbslib_ver_folder + path + """"
End  Sub


 
'***********************************************************************
'* Variable: g_FileWatcher
'***********************************************************************
Dim  g_FileWatcher  '// as FileWatcherClass


 
'***********************************************************************
'* Function: FileWatcher_setNewFile
'***********************************************************************
Sub  FileWatcher_setNewFile()
	If IsEmpty( g_FileWatcher ) Then
		Set g_FileWatcher = new FileWatcherClass
		g_FileWatcher.InitializeStep2  "ReplaceSteps"
	End If
	g_FileWatcher.SetNewFile
End Sub


 
'***********************************************************************
'* Function: FileWatcher_copyAFileToTheLog
'***********************************************************************
Sub  FileWatcher_copyAFileToTheLog( in_WatchingPath )
	If IsEmpty( g_FileWatcher ) Then
		Set g_FileWatcher = new FileWatcherClass
		g_FileWatcher.InitializeStep2  "ReplaceSteps"
	End If
	g_FileWatcher.CopyAFileToTheLog  in_WatchingPath
End Sub


 
'***********************************************************************
'* Class: FileWatcherClass
'***********************************************************************
Class  FileWatcherClass
	Public  LogFolderFullPath
	Public  StartStepNum
	Public  NextStepNum


'***********************************************************************
'* Function: InitializeStep2
'*
'* Name Space:
'*    FileWatcherClass::InitializeStep2
'***********************************************************************
Public Sub  InitializeStep2( in_LogFolderName )
	Me.LogFolderFullPath = GetTempPath( in_LogFolderName )
	Me.StartStepNum = 1
	Me.NextStepNum = 1

	del  Me.LogFolderFullPath
	echo_v  "FileWatcher >> "+ Me.LogFolderFullPath
End Sub


 
'***********************************************************************
'* Function: CopyAFileToTheLog
'*
'* Name Space:
'*    FileWatcherClass::CopyAFileToTheLog
'***********************************************************************
Public Sub  CopyAFileToTheLog( in_Path )
	Assert  not IsEmpty( Me.LogFolderFullPath )

	extension = g_fs.GetExtensionName( in_Path )
	num_3_keta = 3

	If Me.NextStepNum = Me.StartStepNum Then
		num_of_before = GetNumWithZeroAtLeft( Me.NextStepNum,     num_3_keta, Empty )
		num_of_after  = GetNumWithZeroAtLeft( Me.NextStepNum + 1, num_3_keta, Empty )
		file_name = "StepNum_"+ num_of_before +"_to_"+ num_of_after +"."+ extension

		copy_ren _
			in_Path, _
			Me.LogFolderFullPath +"\Before\"+ file_name
	Else
		num_of_before = GetNumWithZeroAtLeft( Me.NextStepNum - 1, num_3_keta, Empty )
		num_of_after  = GetNumWithZeroAtLeft( Me.NextStepNum,     num_3_keta, Empty )
		file_name = "StepNum_"+ num_of_before +"_to_"+ num_of_after +"."+ extension

		echo_v  "FileWatcher >> "+ Me.LogFolderFullPath
		echo_v  "FileWatcher >> "+ file_name

		If Me.NextStepNum >= Me.StartStepNum + 2 Then
			num_of_after  = num_of_before
			num_of_before = GetNumWithZeroAtLeft( Me.NextStepNum - 2, num_3_keta, Empty )
			old_file_name = "StepNum_"+ num_of_before +"_to_"+ num_of_after +"."+ extension

			copy_ren _
				Me.LogFolderFullPath +"\After_\"+ old_file_name, _
				Me.LogFolderFullPath +"\Before\"+ file_name
		End If

		copy_ren _
			in_Path, _
			Me.LogFolderFullPath +"\After_\"+ file_name
	End If

	Me.NextStepNum = Me.NextStepNum + 1
End Sub


 
'***********************************************************************
'* Function: SetNewFile
'*
'* Name Space:
'*    FileWatcherClass::SetNewFile
'***********************************************************************
Public Sub  SetNewFile()
	Me.StartStepNum = Me.NextStepNum
End Sub


 
'//* Section: End_of_Class
End Class


 
'*************************************************************************
'  <<< [SetStartSectionTree] >>> 
'*************************************************************************
Sub  SetStartSectionTree( ByVal Sections )
	If VarType( Sections ) = vbString Then
		Sections = Replace( Sections, ",", " >" )
		echo  ">SetStartSectionTree  "+ Sections
		Sections = Replace( Sections, ">", "," )
	Else
		echo  ">SetStartSectionTree  "+ Replace( GetEchoStr( Sections ), ",", " >" )
	End If
	If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
	If not IsArray( Sections ) Then  If Sections = "" Then  Exit Sub

	Dim g : Set g = g_SkipSectionGlobal
	Dim  arr : arr = g.CurrentSectionNames.Items
	If IsArray( Sections ) Then
		AddArrElem  arr, Sections
	Else
		AddArrElem  arr, ArrayFromCSV( Sections )
	End If

	g.SelectedSectionTree = arr
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [SectionTree] Class >>>> 
'-------------------------------------------------------------------------
Class  SectionTree
	Public  SkipSectionA    '// as SkipSection
	Public  LevelOnCreated  '// as integer
	Public  IsStartRetTrue  '// as boolean

	Private Sub  Class_Initialize()
		Set Me.SkipSectionA = new SkipSection
		If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
		Dim g : Set g = g_SkipSectionGlobal
		g.IsEcho = False
		Me.LevelOnCreated = g.CurrentLevel
		Me.IsStartRetTrue = False
	End Sub

	Private Sub  Class_Terminate()
		Dim g : Set g = g_SkipSectionGlobal

		If Err.Number <> 0 Then
			Dim  s, n
			For Each  n  In g.CurrentSectionNames.Items : s = s + n + " >> " : Next
			If not IsEmpty( s ) Then
				echo  ""
				echo  "SectionTree >> " + Left( s, Len(s)-4 ) +" >> ERROR"
			End If
		End If

		While  g.CurrentLevel > Me.LevelOnCreated
			Me.End_
		WEnd
	End Sub

	Function  Start( Label )  '// [SectionTree::Start]
		Dim g : Set g = g_SkipSectionGlobal
		g.CurrentSectionNames.Add  Label
		Start = Me.SkipSectionA.Start()
		Me.IsStartRetTrue = Start
		If Start Then
			Dim  s, n
			For Each  n  In g.CurrentSectionNames.Items : s = s + n + " > " : Next
			echo  ""
			echo  "SectionTree >> " + Left( s, Len(s)-3 )
			echo  "<Section tree="""+ g.CurrentSectionNames.CSV +""">"
			g.OnStart  g.CallbackObject
		End If
		If not Start Then  g.CurrentLevel = g.CurrentLevel + 1
	End Function

	Sub  End_()  '// [SectionTree::End_]
		Dim g : Set g = g_SkipSectionGlobal
		g.CurrentSectionNames.Pop
		Me.SkipSectionA.End_
		If Me.IsStartRetTrue Then  echo  "</Section>"
	End Sub

	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		Dim g : Set g = g_SkipSectionGlobal
		xml_sub = GetTab(Level)+ "<"+TypeName(Me)+_
			" CurrentSectionNames="""+ XmlAttrA( g.CurrentSectionNames.CSV ) +"""/>"+ vbCRLF
	End Function
End Class



 
'-------------------------------------------------------------------------
' ### <<<< [SkipSection] Class >>>> 
'-------------------------------------------------------------------------
Dim  g_SkipSectionGlobal

'//[SkipSectionGlobal]
Class  SkipSectionGlobal
	Public  CurrentLevel        '// as integer. -1=root
	Public  CurrentSecNums      '// as ArrayClass of integer
	Public  CurrentSectionNames '// as ArrayClass of string
	Public  SkipToSecNums       '// as ArrayClass of integer
	Public  SelectedSectionTree '// as array of string
	Public  BreakSecNums        '// as ArrayClass of integer
	Public  IsEcho              '// as boolean
	Public  IsDontPause         '// as boolean
	Public  OnStart             '// as function( Me.CallbackObject )
	Public  CallbackObject      '// as variant

	Private Sub  Class_Initialize()
		Me.CurrentLevel = -1
		Set Me.CurrentSecNums = new ArrayClass : Me.CurrentSecNums.Add  0
		Set Me.CurrentSectionNames = new ArrayClass
		Set Me.SkipToSecNums  = new ArrayClass
		Me.SelectedSectionTree = Array( )
		Set Me.BreakSecNums   = new ArrayClass
		Me.IsEcho = True
		Me.IsDontPause = False
		Set Me.OnStart = GetRef( "DefaultFunction" )
	End Sub
End Class


Function  NotSkipSection()
	ThisIsOldSpec
	Dim  section : Set section = new SkipSection : ErrCheck : section.IsNoCheck = True
	If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
	Dim  g : Set g = g_SkipSectionGlobal
	If g.CurrentLevel >= 0 Then  section.End_
	NotSkipSection = section.Start()
End Function


Sub  SkipToSection( Section )
	If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
	Dim  g : Set g = g_SkipSectionGlobal
	g.SkipToSecNums.ToEmpty
	g.SkipToSecNums.AddElems  Section
End Sub


Sub  SetBreakAtSection( Num )
	If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
	Dim  g : Set g = g_SkipSectionGlobal
	g.BreakSecNums.ToEmpty
	g.BreakSecNums.AddElems  Num
End Sub


'//[GetSkipSectionGlobal]
Function  GetSkipSectionGlobal()
	If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
	Set GetSkipSectionGlobal = g_SkipSectionGlobal
End Function


Class  SkipSection
	Public  StartLevel
	Public  IsNoCheck
	Public  IsStartSection
	Public  SelectedEndCount  '// as integer

	Private Sub  Class_Initialize()
		If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
		Me.StartLevel = g_SkipSectionGlobal.CurrentLevel
		Me.IsStartSection = False
		Me.SelectedEndCount = 0
	End Sub

	Private Sub  Class_Terminate()
		If Me.IsNoCheck Then  Exit Sub
		Dim  en,ed : en = Err.Number : ed = Err.Description
		On Error Resume Next  '// This clears error

		If en=0 or en=21 Then
			If g_SkipSectionGlobal.CurrentLevel <> Me.StartLevel Then
				Raise 1,"<ERROR msg=""SkipSection::Start と SkipSection::End_ の対応関係がおかしい""/>"
			ElseIf Me.SelectedEndCount = 0 Then
				If UBound( g_SkipSectionGlobal.SelectedSectionTree ) >= 0 Then
					Raise 1,"<ERROR msg=""セクションが１つも実行されていないか Pass していません""/>"
					g_SkipSectionGlobal.SelectedSectionTree = Array( )
				End If
			End If
		End If

		ErrorCheckInTerminate  en
		On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
	End Sub

	Function  Start()  '// [SkipSection::Start]
		Dim  i, n, g : Set g = g_SkipSectionGlobal

		g.CurrentLevel = g.CurrentLevel + 1
		If g.CurrentSecNums.UBound_ < g.CurrentLevel + 1  Then  g.CurrentSecNums.Add  0
		g.CurrentSecNums( g.CurrentLevel ) = g.CurrentSecNums( g.CurrentLevel ) + 1
		g.CurrentSecNums( g.CurrentLevel + 1 ) = 0

		If g.SkipToSecNums.UBound_ >= 0 Then
			If g.SkipToSecNums.UBound_ < g.CurrentLevel Then _
				n =  g.SkipToSecNums.UBound_  Else  n = g.CurrentLevel
			For i=0 To n
			 If g.CurrentSecNums(i) > g.SkipToSecNums(i) Then  i = n + 1 : Exit For
			 If g.CurrentSecNums(i) < g.SkipToSecNums(i) Then  Exit For
			Next
			Start = ( i > n )
			If not Start Then  g.CurrentLevel = g.CurrentLevel - 1
		ElseIf UBound( g.SelectedSectionTree ) >= 0 Then
			n = g.CurrentLevel
			For i=0 To n
			 If g.CurrentSectionNames(i) <> g.SelectedSectionTree(i) Then  Exit For
			Next
			Start = ( i > n )
			If not Start Then  g.CurrentLevel = g.CurrentLevel - 1
		Else
			Start = True
		End If

		If Start Then
			n = CStr( g.CurrentSecNums(0) )
			For i=1 To g.CurrentLevel : n = n +","& g.CurrentSecNums(i) : Next
			If g.CurrentLevel >= 1 Then  n = "Array("+ n +")"
			If g.IsEcho Then  echo  "<Section num='"+ n +"'>"
		End If

		If g.BreakSecNums.UBound_ >= 0 Then
			If g.BreakSecNums.UBound_ = g.CurrentLevel Then
				For i=0 To g.CurrentLevel
					If g.CurrentSecNums(i) <> g.BreakSecNums(i) Then  Exit For
				Next
				If i = g.BreakSecNums.Count Then  Stop  '// Look at caller function
			End If
		End If

		Me.IsStartSection = Start
	End Function

	Sub  End_()  '// [SkipSection::End_]
		If IsEmpty( g_SkipSectionGlobal ) Then  Set g_SkipSectionGlobal = new SkipSectionGlobal
		Dim  g : Set g = g_SkipSectionGlobal
		If g.IsEcho Then  echo  "</Section>"
		If g.CurrentLevel < 0 Then _
			Raise 1, "<ERROR msg=""SkipSection::End_ に対応する Start が無いか、End_ を呼び出す位置が End If の直前ではありません""/>"
		g.CurrentLevel = g.CurrentLevel - 1

		If Me.IsStartSection Then
			Me.SelectedEndCount = Me.SelectedEndCount + 1
			Me.IsStartSection = False
			If Err.Number = 0  and  g.CurrentLevel + 1 = UBound( g.SelectedSectionTree ) Then
				echo  "SetStartSectionTree で設定したセクションが終了しました"
				If not g_IsAutoTest Then  Pause
				g.SelectedSectionTree = Array( )
			End If
		End If
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [FinObj] Class >>>> 
'-------------------------------------------------------------------------
Class  FinObj
	Public  m_Vars  ' as Dictionay
	Public  m_FinallyFunc

	Private Sub Class_Initialize
		Set m_Vars = CreateObject("Scripting.Dictionary")
	End Sub

	Public Sub  SetFunc( FuncName )
		Set m_FinallyFunc = GetRef( FuncName )
	End Sub

	Public Sub  SetVar( Name, Var )
		If IsObject( Var ) Then  Set m_Vars.Item( Name ) = Var _
		Else                         m_Vars.Item( Name ) = Var
	End Sub

	Private Sub Class_Terminate()
		If not IsEmpty( m_FinallyFunc ) Then
			Dim  en, ed : en = Err.Number : ed = Err.Description
			m_FinallyFunc  m_Vars
			ErrorCheckInTerminate  en
		End If
	End Sub
End Class


 
