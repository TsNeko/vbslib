Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_AssertFC",_
			"2","T_Diff1" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_AssertFC
'***********************************************************************
Sub  T_AssertFC( Opt, AppKey )

	echo  "次の AssertFC では、Diff ツールが開かないこと。"
	Pause

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		g_Vers("AssertFC_Diff") = False
		AssertFC  "1_sjis_crlf.txt", "2_sjis_crlf.txt"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "1_sjis_crlf.txt" ) > 0
	Assert  InStr( e2.desc, "2_sjis_crlf.txt" ) > 0
	Assert  e2.num <> 0



	echo  "次の AssertFC では、Diff ツールが開くこと。"
	Pause

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		g_Vers("AssertFC_Diff") = Empty
		AssertFC  "1_sjis_crlf.txt", "2_sjis_crlf.txt"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "1_sjis_crlf.txt" ) > 0
	Assert  InStr( e2.desc, "2_sjis_crlf.txt" ) > 0
	Assert  e2.num <> 0

	Pass
End Sub


 
'***********************************************************************
'* Function: T_Diff1
'***********************************************************************
Sub  T_Diff1( Opt, AppKey )
	Set g = new LazyDictionaryClass
	g("${f}") = "OtherFiles\T_AssertFC"
	vbs_path = SearchParent( "vbslib Prompt.vbs" )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Diff1_Clip3"


	'//===========================================================
	If section.Start( "T_Diff1" ) Then

	echo  ""
	echo  "Error was raised."
	echo  "と"
	echo  "Error is raised."
	echo  "を比較する diff ツールが起動すること。"
	Pause

	RunProg  "cscript  //nologo  """+ vbs_path +"""  diff1  "+ _
		g("${f}\Base.txt  2  ${f}\Char2.txt  2  \"),  g_VBS_Lib.NotEchoStartCommand

	End If : section.End_


	'//===========================================================
	If section.Start( "T_Diff1_Clip" ) Then

	echo  ""
	echo  "Error was raised."
	echo  "と"
	echo  "Error is raised."
	echo  "を比較する diff ツールが起動すること。"
	Pause

	SetTextToClipboard  "Error was raised."+ vbCRLF + "Error is raised."
	RunProg  "cscript  //nologo  """+ vbs_path +"""  Diff1  "+ _
		"""""  \",  g_VBS_Lib.NotEchoStartCommand

	End If : section.End_


	'//===========================================================
	If section.Start( "T_Diff1_Clip3" ) Then

	echo  ""
	echo  "Error was raised."
	echo  "Error is raised."
	echo  "をそれぞれコピーして、比較する diff ツールが起動すること。 続けて、"
	echo  "Error will be raised."
	echo  "をコピーして、Error was raised. と比較する diff ツールが起動すること。"
	Pause

	SetTextToClipboard  Empty
	RunProg  "cscript  //nologo  """+ vbs_path +"""  Diff1  ",  g_VBS_Lib.NotEchoStartCommand

	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: T_DiffTag
'***********************************************************************
Sub  T_DiffTag( Opt, AppKey )
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
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 2
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
