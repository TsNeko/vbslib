Option Explicit 

Dim  g_out

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	ExecuteGlobal  "Function  FuncA0() : FuncA0 = 1 : End Function"
	If FuncA0() <> 1 Then  Fail
	ExecuteGlobal  "Dim  g_FuncA0 : FuncRedir_add  g_FuncA0, ""FuncA0"""
	ExecuteGlobal  "Function  FuncA0() : FuncA0 = 2 + g_FuncA0.CallFunction0() : End Function"
	If FuncA0() <> 3 Then  Fail
	ExecuteGlobal  "Dim  g_FuncA0 : FuncRedir_add  g_FuncA0, ""FuncA0"""
	ExecuteGlobal  "Function  FuncA0() : FuncA0 = 3 + g_FuncA0.CallFunction0() : End Function"
	If FuncA0() <> 6 Then  Fail

	ExecuteGlobal  "Function  FuncA1(n) : FuncA1 = n : End Function"
	If FuncA1(1) <> 1 Then  Fail
	ExecuteGlobal  "Dim  g_FuncA1 : FuncRedir_add  g_FuncA1, ""FuncA1"""
	ExecuteGlobal  "Function  FuncA1(n) : FuncA1 = 2 + g_FuncA1.CallFunction1(n) : End Function"
	If FuncA1(1) <> 3 Then  Fail
	ExecuteGlobal  "Dim  g_FuncA1 : FuncRedir_add  g_FuncA1, ""FuncA1"""
	ExecuteGlobal  "Function  FuncA1(n) : FuncA1 = 3 + g_FuncA1.CallFunction1(n) : End Function"
	If FuncA1(1) <> 6 Then  Fail

	ExecuteGlobal  "Function  FuncA2(a,b) : FuncA2 = a+2*b : End Function"
	If FuncA2(1,2) <> 5 Then  Fail
	ExecuteGlobal  "Dim  g_FuncA2 : FuncRedir_add  g_FuncA2, ""FuncA2"""
	ExecuteGlobal  "Function  FuncA2(a,b) : FuncA2 = 1 + g_FuncA2.CallFunction2(a,b) : End Function"
	If FuncA2(1,2) <> 6 Then  Fail

	ExecuteGlobal  "Function  FuncA3(a,b,c) : FuncA3 = a+2*b+c : End Function"
	If FuncA3(1,2,3) <> 8 Then  Fail
	ExecuteGlobal  "Dim  g_FuncA3 : FuncRedir_add  g_FuncA3, ""FuncA3"""
	ExecuteGlobal  "Function  FuncA3(a,b,c) : FuncA3 = 1 + g_FuncA3.CallFunction3(a,b,c) : End Function"
	If FuncA3(1,2,3) <> 9 Then  Fail

	ExecuteGlobal  "Function  FuncA4(a,b,c,d) : FuncA4 = a+2*b+c+3*d : End Function"
	If FuncA4(1,2,3,4) <> 20 Then  Fail
	ExecuteGlobal  "Dim  g_FuncA4 : FuncRedir_add  g_FuncA4, ""FuncA4"""
	ExecuteGlobal  "Function  FuncA4(a,b,c,d) : FuncA4 = 1 + g_FuncA4.CallFunction4(a,b,c,d) : End Function"
	If FuncA4(1,2,3,4) <> 21 Then  Fail


	g_out = 0
	ExecuteGlobal  "Sub  SubA0() : g_out = 1 : End Sub"
	SubA0 : If g_out <> 1 Then  Fail
	ExecuteGlobal  "Dim  g_SubA0 : FuncRedir_add  g_SubA0, ""SubA0"""
	ExecuteGlobal  "Sub  SubA0() : g_SubA0.CallSub0 : g_out = g_out + 2 : End Sub"
	SubA0 : If g_out <> 3 Then  Fail
	ExecuteGlobal  "Dim  g_SubA0 : FuncRedir_add  g_SubA0, ""SubA0"""
	ExecuteGlobal  "Sub  SubA0() : g_SubA0.CallSub0 : g_out = g_out + 3 : End Sub"
	SubA0 : If g_out <> 6 Then  Fail

	g_out = 0
	ExecuteGlobal  "Sub  SubA1(n) : g_out = n : End Sub"
	SubA1 1 : If g_out <> 1 Then  Fail
	ExecuteGlobal  "Dim  g_SubA1 : FuncRedir_add  g_SubA1, ""SubA1"""
	ExecuteGlobal  "Sub  SubA1(n) : g_SubA1.CallSub1 n : g_out = g_out + 2 : End Sub"
	SubA1 1 : If g_out <> 3 Then  Fail
	ExecuteGlobal  "Dim  g_SubA1 : FuncRedir_add  g_SubA1, ""SubA1"""
	ExecuteGlobal  "Sub  SubA1(n) : g_SubA1.CallSub1 n : g_out = g_out + 3 : End Sub"
	SubA1 1 : If g_out <> 6 Then  Fail

	g_out = 0
	ExecuteGlobal  "Sub  SubA2(a,b) : g_out = a+2*b : End Sub"
	SubA2 1,2 : If g_out <> 5 Then  Fail
	ExecuteGlobal  "Dim  g_SubA2 : FuncRedir_add  g_SubA2, ""SubA2"""
	ExecuteGlobal  "Sub  SubA2(a,b) : g_SubA2.CallSub2 a,b : g_out = g_out + 1 : End Sub"
	SubA2 1,2 : If g_out <> 6 Then  Fail

	g_out = 0
	ExecuteGlobal  "Sub  SubA3(a,b,c) : g_out = a+2*b+c : End Sub"
	SubA3 1,2,3 : If g_out <> 8 Then  Fail
	ExecuteGlobal  "Dim  g_SubA3 : FuncRedir_add  g_SubA3, ""SubA3"""
	ExecuteGlobal  "Sub  SubA3(a,b,c) : g_SubA3.CallSub3 a,b,c : g_out = g_out + 1 : End Sub"
	SubA3 1,2,3 : If g_out <> 9 Then  Fail

	g_out = 0
	ExecuteGlobal  "Sub  SubA4(a,b,c,d) : g_out = a+2*b+c+3*d : End Sub"
	SubA4 1,2,3,4 : If g_out <> 20 Then  Fail
	ExecuteGlobal  "Dim  g_SubA4 : FuncRedir_add  g_SubA4, ""SubA4"""
	ExecuteGlobal  "Sub  SubA4(a,b,c,d) : g_SubA4.CallSub4 a,b,c,d : g_out = g_out + 1 : End Sub"
	SubA4 1,2,3,4 : If g_out <> 21 Then  Fail

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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
