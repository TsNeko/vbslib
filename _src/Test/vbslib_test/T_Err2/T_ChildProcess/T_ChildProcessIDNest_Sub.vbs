Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	Const  state_path = "T_ChildProcessIDNest_Work.txt"

	Select Case  ReadFile( state_path )

	 Case  "0"

		Set o = g_InterProcess
			echo  "(Sub) ProcessCallID = " & o.ProcessCallID.CSV
			If o.ProcessCallID.UBound_ <> 1 Then  Fail
			If o.ProcessCallID(0) <> 1 Then  Fail
			If o.ProcessCallID(1) <> 0 Then  Fail
		o = Empty

		CreateFile  state_path, "10"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSub.vbs", "" )
		CheckTestErrLevel  r

		Set o = g_InterProcess
			echo  "(Sub) ProcessCallID = " & o.ProcessCallID.CSV
			If o.ProcessCallID.UBound_ <> 1 Then  Fail
			If o.ProcessCallID(0) <> 1 Then  Fail
			If o.ProcessCallID(1) <> 1 Then  Fail
		o = Empty

		CreateFile  state_path, "11"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSub.vbs", "" )
		CheckTestErrLevel  r

		Set o = g_InterProcess
			echo  "(Sub) ProcessCallID = " & o.ProcessCallID.CSV
			If o.ProcessCallID.UBound_ <> 1 Then  Fail
			If o.ProcessCallID(0) <> 1 Then  Fail
			If o.ProcessCallID(1) <> 2 Then  Fail
		o = Empty
		Pass


	 Case  "1"

		Set o = g_InterProcess
			echo  "(Sub) ProcessCallID = " & o.ProcessCallID.CSV
			If o.ProcessCallID.UBound_ <> 1 Then  Fail
			If o.ProcessCallID(0) <> 2 Then  Fail
			If o.ProcessCallID(1) <> 0 Then  Fail
		o = Empty

		CreateFile  state_path, "20"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSub.vbs", "" )
		CheckTestErrLevel  r

		Set o = g_InterProcess
			echo  "(Sub) SampleCallID = " & o.ProcessCallID.CSV
			If o.SampleCallID.UBound_ <> 1 Then  Fail
			If o.SampleCallID(0) <> 2 Then  Fail
			If o.SampleCallID(1) <> 1 Then  Fail
		o = Empty
		Pass


	 Case  "Manual"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSub.vbs", "" )
		CheckTestErrLevel  r
		Pass


	 Case  "3"
		CreateFile  state_path, "31"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSub.vbs", "" )
		CheckTestErrLevel  r
		Pass


	 Case  "4"
		CreateFile  state_path, "41"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSub.vbs", "" )
		CheckTestErrLevel  r

		CreateFile  state_path, "42"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_SubSub.vbs", "" )
		CheckTestErrLevel  r
		Pass


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

 
