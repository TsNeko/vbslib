Option Explicit 

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim    r
	Const  state_path = "T_ChildProcessIDNest_Work.txt"

	Select Case  ReadFile( state_path )

	 Case  "10"
		With g_InterProcess
			echo  "(SubSub) ProcessCallID = " & .ProcessCallID.CSV
			If .ProcessCallID.UBound_ <> 2 Then  Fail
			If .ProcessCallID(0) <> 1 Then  Fail
			If .ProcessCallID(1) <> 1 Then  Fail
			If .ProcessCallID(2) <> 0 Then  Fail
		End With
		Pass

	 Case  "11"
		With g_InterProcess
			echo  "(SubSub) ProcessCallID = " & .ProcessCallID.CSV
			If .ProcessCallID.UBound_ <> 2 Then  Fail
			If .ProcessCallID(0) <> 1 Then  Fail
			If .ProcessCallID(1) <> 2 Then  Fail
			If .ProcessCallID(2) <> 0 Then  Fail
		End With
		Pass

	 Case  "20"
		With g_InterProcess
			echo  "(SubSub) ProcessCallID = " & .ProcessCallID.CSV
			If .ProcessCallID.UBound_ <> 2 Then  Fail
			If .ProcessCallID(0) <> 2 Then  Fail
			If .ProcessCallID(1) <> 1 Then  Fail
			If .ProcessCallID(2) <> 0 Then  Fail
		End With
		undefined_variable

	 Case  "Manual"
		undefined_variable

	 Case  "31"
		undefined_variable  '// T_ChildProcessIDNest_Level_1

	 Case  "41"

	 Case  "42"
		CreateFile  state_path, "421"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSubSub.vbs", "" )
		CheckTestErrLevel  r

	End Select
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

 
