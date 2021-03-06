Option Explicit 

Sub  Main()
	T_Err2_ErrBlock_NoErr
	T_Err2_ErrBlock_Err
	T_Err2_ExitResumeNext
	T_Err2_Echo_NoErr
	T_Err2_Echo_Err
	T_Err2_Trying
	T_Err2_CopyAndClear
	T_Err2_EnqueueAndClear
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Err2_ErrBlock_NoErr] >>> 
'********************************************************************************
Sub T_Err2_ErrBlock_NoErr()
	Dim  b,e

	EchoTestStart  "T_Err2_ErrBlock_NoErr"

	b = False
	If TryStart(e) Then  On Error Resume Next
		'undefined_variable
	If TryEnd Then  On Error GoTo 0
	If e.num<>0 Then
		b = True
	End If
	If b Then  Error
End Sub


 
'********************************************************************************
'  <<< [T_Err2_ErrBlock_Err] >>> 
'********************************************************************************
Sub T_Err2_ErrBlock_Err()
	Dim  b,e

	EchoTestStart  "T_Err2_ErrBlock_Err"

	b = False
	If TryStart(e) Then  On Error Resume Next
		undefined_variable
	If TryEnd Then  On Error GoTo 0
	If e.num<>0 Then
		b = True
	End If
	If Not b Then  Error
	e.Clear
End Sub


 
'********************************************************************************
'  <<< [T_Err2_ExitResumeNext] >>> 
'********************************************************************************
Sub T_Err2_ExitResumeNext()

	EchoTestStart  "T_Err2_ExitResumeNext"

	On Error Resume Next
		T_Err2_ExitResumeNext_sub
	On Error GoTo 0

	g_Err2.Clear
End Sub

Sub T_Err2_ExitResumeNext_sub()
	Dim  b,e

	b = False
	If TryStart(e) Then  On Error Resume Next
		undefined_variable
	If TryEnd Then  On Error GoTo 0
	If e.num<>0 Then
		b = True
	End If
	undefined_variable
	Error
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Echo_NoErr] >>> 
'********************************************************************************
Sub T_Err2_Echo_NoErr()
	Dim e

	EchoTestStart  "T_Err2_Echo_NoErr"

	If TryStart(e) Then  On Error Resume Next
		' T_Err2_ExitResumeNext_sub
	If TryEnd Then  On Error GoTo 0
	echo  e.ErrStr
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Echo_Err] >>> 
'********************************************************************************
Sub T_Err2_Echo_Err()
	Dim e

	EchoTestStart  "T_Err2_Echo_Err"

	If TryStart(e) Then  On Error Resume Next
		T_Err2_ExitResumeNext_sub
	If TryEnd Then  On Error GoTo 0
	echo  e.ErrStr
	e.Clear
End Sub


 
'********************************************************************************
'  <<< [T_Err2_Trying] >>> 
'********************************************************************************
Sub T_Err2_Trying()
	Dim  chk1, chk2, en, e

	EchoTestStart  "T_Err2_Trying"

	chk1 = 0
	chk2 = 0
	If TryStart(e) Then  On Error Resume Next
		If Trying Then  chk1 = 1
		If Trying Then  chk2 = 1
		If Trying Then  undefined_variable
		en = Err.Number  ' for check
		If Trying Then  chk2 = 2
	If TryEnd Then  On Error GoTo 0

	If chk1<>1 or chk2<>1 Then Error
	If e.num=0 or e.num <> en Then Error
	e.Clear
End Sub

 
'********************************************************************************
'  <<< [T_Err2_CopyAndClear] >>> 
'********************************************************************************
Sub  T_Err2_CopyAndClear()
	Dim  e, e2  ' as Err2
	Dim  copied

	EchoTestStart  "T_Err2_CopyAndClear"

	If TryStart(e) Then  On Error Resume Next
		Err.Raise  1,, "SomeError"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2  '//################### Test Point
	If InStr( e2.desc, "SomeError" ) = 0 Then  Fail


	If TryStart(e) Then  On Error Resume Next
		T_Err2_CopyAndClear_sub  copied
	If TryEnd Then  On Error GoTo 0
	If e.Num = 0 Then  Fail
	If InStr( e.desc, "SomeError" ) = 0 Then  Fail
	e.Clear
	If not ( copied = True ) Then  Fail
End Sub


Sub  T_Err2_CopyAndClear_sub( out_Copied )
	Dim  e, e2  ' as Err2

	If TryStart(e) Then  On Error Resume Next
		Err.Raise  1,, "SomeError"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2

	out_Copied = True
	e2.Raise  '//##################################### Test Point
End Sub

 
'********************************************************************************
'  <<< [T_Err2_EnqueueAndClear] >>> 
'********************************************************************************
Sub  T_Err2_EnqueueAndClear()
	Dim  e  ' as Err2
	Dim  s

	EchoTestStart  "T_Err2_EnqueueAndClear"

	If TryStart(e) Then  On Error Resume Next
		Err.Raise  1,, "Error1"
	If TryEnd Then  On Error GoTo 0
	e.EnqueueAndClear  '//################### Test Point

	Assert  e.num = 0

	If TryStart(e) Then  On Error Resume Next
		Err.Raise  1,, "IngoredError"
	If TryEnd Then  On Error GoTo 0
	e.Clear

	e.EnqueueAndClear  '//################### Test Point : not enqueue if no error


	If TryStart(e) Then  On Error Resume Next
		T_Err2_EnqueueAndClear_sub
	If TryEnd Then  On Error GoTo 0
	e.EnqueueAndClear

	Assert  e.num = 0

	s = e.DequeueAll()
	Assert  s = _
		"<ERROR err_number='1' err_description='Error1' g_debug='8'/>"+vbCRLF+_
		"<ERROR err_number='500' err_description='この変数は宣言されていません。' g_debug='11' g_debug_tree='Array( 11 )'/>"+vbCRLF

	s = e.DequeueAll()
	Assert  s = ""
End Sub


Sub  T_Err2_EnqueueAndClear_sub()
	Dim  e

	If TryStart(e) Then  On Error Resume Next
		a  '// not dim variable
	If TryEnd Then  On Error GoTo 0
	e.Clear

	If TryStart(e) Then  On Error Resume Next
		a  '// not dim variable
	If TryEnd Then  On Error GoTo 0
	e.EnqueueAndClear  '//################### Test Point
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
	g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
