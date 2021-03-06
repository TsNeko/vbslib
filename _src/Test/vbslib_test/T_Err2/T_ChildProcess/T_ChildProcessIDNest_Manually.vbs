Option Explicit 

Dim  g_SampleLib

Sub  Main( Opt, AppKey )

	echo  "T_ChildProcessIDNest_SubSub.vbs で発生するエラーでブレークすることを g_MainPath で確認してください。"
	Pause


	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim    r, o
	Dim    e  ' as Err2
	Dim    err2_xml
	Const  state_path = "T_ChildProcessIDNest_Work.txt"


	Set o = g_InterProcess
		echo  "ProcessCallID = " & o.ProcessCallID.CSV
		If o.ProcessCallID.UBound_ <> 0 Then  Fail
		If o.ProcessCallID(0) <> 0 Then  Fail
	o = Empty

	CreateFile  state_path, "0"
	r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_Sub.vbs", "" ) '//################ Test Point
	CheckTestErrLevel  r



	Set o = g_InterProcess
		echo  "ProcessCallID = " & o.ProcessCallID.CSV
		If o.ProcessCallID.UBound_ <> 0 Then  Fail
		If o.ProcessCallID(0) <> 1 Then  Fail
	o = Empty

	CreateFile  state_path, "1"
	If TryStart(e) Then  On Error Resume Next
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_Sub.vbs", "" ) '//################ Test Point
	If TryEnd Then  On Error GoTo 0

	Set err2_xml = LoadXML( e.xml, F_Str )
	If err2_xml.tagName <> "Err2" Then  Fail
	If err2_xml.getAttribute( "number" ) <> "500" Then  Fail
	If err2_xml.getAttribute( "sub_process_call_id" ) <> "2,1" Then  Fail
	e.Clear



	Set o = g_InterProcess
		echo  "ProcessCallID = " & o.ProcessCallID.CSV
		If o.ProcessCallID.UBound_ <> 0 Then  Fail
		If o.ProcessCallID(0) <> 2 Then  Fail
	o = Empty



	If WScript.ScriptName = "T_ChildProcessIDNest_Manually.vbs" Then

		CreateFile  state_path, "Manual"
		r= RunProg( "cscript.exe //nologo T_ChildProcessIDNest_Sub.vbs", "" ) '//################ Test Point
		CheckTestErrLevel  r

	End IF

	del  state_path
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
	g_debug = 5
g_debug_process = Array(3,1)
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
