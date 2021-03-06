Dim g_g : Sub GetMainSetting( g ) : If not IsEmpty(g_g) Then Set g=g_g : Exit Sub
	Set g=CreateObject("Scripting.Dictionary") : Set g_g=g

	'[Setting]
	'==============================================================================
	g("ExeName")            = "vbslib_helper"
	g("PartnersCopyFolder") = "PartnersCopy"
	g("IncludePath")        = g("PartnersCopyFolder") +"\Include"
	g("LibPath")            = g("PartnersCopyFolder") +"\Lib"
	g("ReadMePath")         = g("PartnersCopyFolder") +"\Readme"
	'==============================================================================
End Sub
Sub  Mxp3_DebugSetting( mxp )
    mxp.DebugMode_DependedSymbol = "malloc_redirected_clib"
End Sub


Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  g : GetMainSetting  g

	Dim  mxp : Set mxp = new Mxp_Proj

	Dim  e  ' as Err2
	If TryStart(e) Then  On Error Resume Next

		Setting_addRepository  mxp, "Types"

	If TryEnd Then  On Error GoTo 0
	If e.num = E_PathNotFound  Then
		echo  "<WARNING msg=""Module Mixer is not installed in this PC.""/>"
		Sleep  2000
		Skip
	End If
	If e.num <> 0 Then  e.Raise



	mxp.AddWorkFile  "clib.h", "CHead_Type"
	mxp.AddWorkFile  "clib.c", "C_Type"
	mxp.AddWorkFolder  g("IncludePath"), "Include_Type"
	mxp.AddWorkFolder  g("LibPath"), "Lib_Type"
	mxp.AddWorkFolder  g("ReadMePath"), "Readme_Type"
	mxp.SetProj  g("ExeName"), "Mxp_ProjType_VisualStudioWin32"

	Setting_addRepository  mxp, "clib"

DebugTools.Uses
HeapLog_clib.Uses
	OpenConsole_clib.Uses
	Error4_str_stdio.Uses
	printf_i.Uses
	stdio_h.Uses
	'// Error4_str_msgbox.Uses
	Error4_str.Uses
	printf_to_file.Uses

	FileTime.Uses
	StrT_Malloc_clib.Uses
	PointerType_clib.Uses
	ShakerSort_clib.Uses
	Set4.Uses
	AA_Tree_clib.Uses
	SearchString_clib.Uses
	C_LanguageCommentToken_clib.Uses
	ParseXML2_clib.Uses
	NaturalComment_clib.Uses
	IniFile2_Str.Uses
	FileT_Write.Uses
	stdlib_h.Uses
	FileT_ReadAll_clib.Uses
	CutIfdef_clib.Uses
	CloseHandle_clib.Uses
	crtdbg_h.Uses
	FileT_Write.Uses
	CommandLineWin.Uses

	mxp.Run
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

 
