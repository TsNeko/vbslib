Option Explicit 

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Select Case  WScript.Arguments.Named.Item("Test")
		Case "T_ErrOnNew1"      : T_ErrOnNew1
		Case "T_ErrOnNewNext"   : T_ErrOnNewNext
		Case "T_ErrOnErr"       : T_ErrOnErr
		Case "T_ErrOnNewPass"   : T_ErrOnNewPass
		Case Else : T_ErrOnErr  '// for Debug
	End Select
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ErrOnNew1] >>> 
'********************************************************************************
Sub  T_ErrOnNew1()
	Dim  e
	If TryStart(e) Then  On Error Resume Next
		T_ErrOnNew1_sub
	If TryEnd Then  On Error GoTo 0
	If e.num <> 500 Then  Fail
	e.Clear
End Sub


Sub  T_ErrOnNew1_sub()
	Dim  obj : Set obj = new ErrClass : echo "skipped error" : ErrCheck
	Fail
End Sub


 
'********************************************************************************
'  <<< [T_ErrOnNewNext] >>> 
'********************************************************************************
Sub  T_ErrOnNewNext()
	Dim  e  ' as Err2
	If TryStart(e) Then  On Error Resume Next
		T_ErrOnNewNext_sub
	If TryEnd Then  On Error GoTo 0
	If e.num = 0  Then Fail
	If e.num = 500 Then  e.Clear
	If e.num <> 0 Then  e.Raise
End Sub


Sub  T_ErrOnNewNext_sub()
	Dim  obj : Set obj = new ErrClass : ErrCheck
	Fail
End Sub


 
'********************************************************************************
'  <<< [T_ErrOnErr] >>> 
'********************************************************************************
Sub  T_ErrOnErr()
	Dim  e  ' as Err2
	Dim  is_after_err_check

	If TryStart(e) Then  On Error Resume Next
		T_ErrOnErr_sub1_Error
		T_ErrOnErr_sub2_NoError  is_after_err_check
	If TryEnd Then  On Error GoTo 0
	If e.num = 0  Then Fail
	If e.num = 500 Then  e.Clear
	If e.num <> 0 Then  e.Raise
	If not ( is_after_err_check = True ) Then  Fail
End Sub


Sub  T_ErrOnErr_sub1_Error()
	Dim  obj : Set obj = new ErrClass : ErrCheck
	Fail
End Sub


Sub  T_ErrOnErr_sub2_NoError( out_IsAfterErrCheck )
	'// エラー発生状態では、On Error Resume Next で続きを実行できるように、ErrCheck で止めない
	Dim  obj : Set obj = new NormalClass : ErrCheck
	out_IsAfterErrCheck = True
End Sub


 
'********************************************************************************
'  <<< [T_ErrOnNewPass] >>> 
'********************************************************************************
Sub  T_ErrOnNewPass()
	Dim  en,ed

	On Error Resume Next
		T_ErrOnNewPass_sub1
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	echo  "en = "& en &"  (en=21 is Bad)"
	If en <> 4 Then  Fail
End Sub


Sub  T_ErrOnNewPass_sub1()
	T_ErrOnNewPass_sub2
	Err.Raise  1,, "Bad Error"
End Sub


Sub  T_ErrOnNewPass_sub2()
	Dim  obj
	Set  obj = new ErrOnNewPassClass
	Pass
End Sub


Class  ErrOnNewPassClass
	Private Sub  Class_Initialize()
		Err.Raise  4,, "Correct Error"
	End Sub
End Class

 
'-------------------------------------------------------------------------
' ### <<<< [ErrClass] Class >>>> 
'-------------------------------------------------------------------------
Class ErrClass
	Private Sub  Class_Initialize()
		NO_OBJ.ERROR
	End Sub
End Class

 
'-------------------------------------------------------------------------
' ### <<<< [NormalClass] Class >>>> 
'-------------------------------------------------------------------------
Class NormalClass
	Private Sub  Class_Initialize()
	End Sub
End Class


 







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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
