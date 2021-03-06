Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_ChangeHeadSpaceToTab", _
			"2","T_GetStrHeadSpaceTabCount", _
			"3","T_ChangeMiddleSpaceToTab", _
			"4","T_ChangeSpaceToTab_sth" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_ChangeHeadSpaceToTab] >>> 
'*************************************************************************
Sub  T_ChangeHeadSpaceToTab( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	For Each t  In DicTable( Array( _
_
		"Operation",             "InputPath",  "TabSize", "AnswerPath", Empty, _
_
		"ChangeHeadSpaceToTab",  "Space2.txt",        2,  "Tab.txt", _
		"ChangeHeadSpaceToTab",  "Space2_lf.txt",     2,  "Tab_lf.txt", _
		"ChangeHeadSpaceToTab",  "Space2_U16.txt",    2,  "Tab_U16.txt", _
		"ChangeHeadSpaceToTab",  "Space2_lf_U16.txt", 2,  "Tab_lf_U16.txt", _
		"ChangeHeadSpaceToTab",  "Space2_U8.txt",     2,  "Tab_U8.txt", _
		"ChangeHeadSpaceToTab",  "Space2_lf_U8.txt",  2,  "Tab_lf_U8.txt", _
		"ChangeHeadSpaceToTab",  "Space4.txt",        4,  "Tab.txt", _
		"ChangeHeadSpaceToTab",  "Space3.txt",        2,  "Space3_toTab2.txt", _
_
		"ChangeHeadTabToSpace",  "Tab.txt",           2,  "Space2.txt", _
		"ChangeHeadTabToSpace",  "Tab_lf.txt",        2,  "Space2_lf.txt", _
		"ChangeHeadTabToSpace",  "Tab_U16.txt",       2,  "Space2_U16.txt", _
		"ChangeHeadTabToSpace",  "Tab_lf_U16.txt",    2,  "Space2_lf_U16.txt", _
		"ChangeHeadTabToSpace",  "Tab_U8.txt",        2,  "Space2_U8.txt", _
		"ChangeHeadTabToSpace",  "Tab_lf_U8.txt",     2,  "Space2_lf_U8.txt", _
		"ChangeHeadTabToSpace",  "Tab.txt",           4,  "Space4.txt", _
		"ChangeHeadTabToSpace",  "Space3_toTab2.txt", 2,  "Space3.txt" ) )

		echo  ">"+ t("Operation") +"  "+ t("InputPath")

		Set rep = StartReplace( t("InputPath"), "out.txt", True )
		If t("Operation") = "ChangeHeadSpaceToTab" Then
			ChangeHeadSpaceToTab  rep.r,  rep.w,  t("TabSize")
		Else
			ChangeHeadTabToSpace  rep.r,  rep.w,  t("TabSize")
		End If
		rep.Finish
		Assert IsSameBinaryFile( "out.txt",  t("AnswerPath"), Empty )
	Next
	del  "out.txt"
	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ChangeMiddleSpaceToTab] >>> 
'*************************************************************************
Sub  T_ChangeMiddleSpaceToTab( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	For Each t  In DicTable( Array( _
		"Operation",             "InputPath",  "TabSize", "AnswerPath", Empty, _
		"ChangeMiddleSpaceToTab", "Mid4.txt",         4,  "Mid4Tab.txt", _
		"ChangeMiddleTabToSpace", "Mid4.txt",         4,  "Mid4Space.txt" ) )

		echo  t("Operation")

		Set rep = StartReplace( t("InputPath"), "out.txt", True )
		Select Case  t("Operation")
			Case  "ChangeMiddleSpaceToTab"
				ChangeMiddleSpaceToTab  rep.r,  rep.w,  t("TabSize")

			Case  "ChangeMiddleTabToSpace"
				ChangeMiddleTabToSpace  rep.r,  rep.w,  t("TabSize")
		End Select
		rep.Finish
		Assert IsSameBinaryFile( "out.txt",  t("AnswerPath"), Empty )
	Next
	del  "out.txt"
	Pass
End Sub


 
'*************************************************************************
'  <<< [T_GetStrHeadSpaceTabCount] >>> 
'*************************************************************************
Sub  T_GetStrHeadSpaceTabCount( Opt, AppKey )
	For Each t  In DicTable( Array( _
		"Line", "TabSize", "Answer_x", "Answer_space_tab_count", Empty, _
		"x  ",         2,          0,      0, _
		" x  ",        2,          1,      1, _
		"  x",         2,          2,      2, _
		"^x",          2,          2,      1, _
		"^^ x",        4,          9,      3, _
		" ^x",         4,          4,      2 ))

		echo  t("Line")
		line = Replace( t("Line"), "^", vbTab )
		GetStrHeadSpaceTabCount  line, t("TabSize"),  x, space_tab_count
		Assert  x = t("Answer_x")
		Assert  space_tab_count = t("Answer_space_tab_count")
	Next
	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ChangeSpaceToTab_sth] >>> 
'*************************************************************************
Sub  T_ChangeSpaceToTab_sth( Opt, AppKey )
	prompt_path = SearchParent( "vbslib Prompt.vbs" )
	Set w_=AppKey.NewWritable( "." ).Enable()

	For Each t  In DicTable( Array( _
_
		"Parameters",             "InputPath",         "AnswerPath", Empty ,_
_
		"SpaceToTab NoChange 2",  "Space2.txt",        "Tab.txt",_
		"SpaceToTab NoChange 2",  "Space2_lf.txt",     "Tab_lf.txt", _
		"SpaceToTab NoChange 2",  "Space2_U16.txt",    "Tab_U16.txt", _
		"SpaceToTab NoChange 2",  "Space2_lf_U16.txt", "Tab_lf_U16.txt", _
		"SpaceToTab NoChange 2",  "Space2_U8.txt",     "Tab_U8.txt", _
		"SpaceToTab NoChange 2",  "Space2_lf_U8.txt",  "Tab_lf_U8.txt", _
_
		"TabToSpace NoChange 2",  "Tab.txt",           "Space2.txt",_
		"TabToSpace NoChange 2",  "Tab_lf.txt",        "Space2_lf.txt", _
		"TabToSpace NoChange 2",  "Tab_U16.txt",       "Space2_U16.txt", _
		"TabToSpace NoChange 2",  "Tab_lf_U16.txt",    "Space2_lf_U16.txt", _
		"TabToSpace NoChange 2",  "Tab_U8.txt",        "Space2_U8.txt", _
		"TabToSpace NoChange 2",  "Tab_lf_U8.txt",     "Space2_lf_U8.txt", _
_
		"NoChange TabToSpace 4",  "Mid4.txt",          "Mid4Space.txt",_
		"NoChange SpaceToTab 4",  "Mid4.txt",          "Mid4Tab.txt" ) )


		r= RunProg( "cscript """+ prompt_path +""" SpaceToTab "+ t("Parameters") +" """+_
			GetFullPath( t("InputPath"), Empty ) +""" /Out:"""+ GetFullPath( "out.txt", Empty )+"""", "" )
		CheckTestErrLevel  r
		AssertFC  "out.txt", t("AnswerPath")
	Next
	del  "out.txt"
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
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
