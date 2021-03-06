Dim g_g : Sub GetMainSetting( g ) : If not IsEmpty(g_g) Then Set g=g_g : Exit Sub
	Set g=CreateObject("Scripting.Dictionary") : Set g_g=g


	'[Setting]
	'==============================================================================
	g("TranslateRoot") = "..\..\..\scriptlib"
		'// テストとサンプルは、翻訳していません。
	'==============================================================================
End Sub

Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
	Set o.CommandReplace = Dict(Array(_
		"1","TranslateTest",_
		"2","Translate",_
		"3","CheckNoSyntaxError",_
		"4","CheckEnglishOnly",_
		_
		"TranslateTest","TranslateTest_sth",_
		"Translate","Translate_sth",_
		"CheckEnglishOnly","CheckEnglishOnly_sth" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [TranslateTest_sth] >>> 
'********************************************************************************
Sub  TranslateTest_sth( Opt, AppKey )
	GetMainSetting  g
	Set c = g_VBS_Lib
	is_main_folder = False
	the_error = get_ToolsLibConsts().E_NotEnglishChar
	is_error = False
	Set w_= AppKey.NewWritable( g("TranslateRoot") ).Enable()

	echo  "英訳したときに日本語が残っていないかチェックします。"
	echo  "処理対象フォルダー："""+ GetFullPath( g("TranslateRoot"), Empty ) +""""

	ExpandWildcard  g("TranslateRoot") +"\*.trans", _
		c.File or c.SubFolder or c.AbsPath, folder, paths
	For Each path  In paths
		If TryStart(e) Then  On Error Resume Next

			echo  ""
			TranslateTest  path, "JP", "EN", ""

		If TryEnd Then  On Error GoTo 0
		If e.num = the_error  Then
			echo_v  e.Description
			is_error = True
			e.Clear
		End If
		If e.num <> 0 Then  e.Raise

		If InStr( path, "sample_lib.trans" ) > 0 Then  is_main_folder = True
	Next
	If is_error Then  echo_v "" : Raise  the_error, "Not English character exists"
	Assert  is_main_folder

	echo  "チェックしました。"
	Pass
End Sub


 
'********************************************************************************
'  <<< [Translate_sth] >>> 
'********************************************************************************
Sub  Translate_sth( Opt, AppKey )
	GetMainSetting  g
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( g("TranslateRoot") ).Enable()

	echo  "★必要なら、バックアップを取ってください。"
	echo  "処理対象フォルダー（★上書きします）："""+ GetFullPath( g("TranslateRoot"), Empty ) +""""
	key = Input( "英訳します。よろしいですか。[Y/N]" )
	If key<>"y" and key<>"Y" Then   Exit Sub  ' ... Cancel

	ExpandWildcard  g("TranslateRoot") +"\*.trans", c.File or c.SubFolder or c.AbsPath, folder, paths
	For Each path  In paths
		Translate  path, "JP", "EN"
	Next
	echo  "英訳しました。"
	Pass
End Sub


 
'********************************************************************************
'  <<< [CheckEnglishOnly_sth] >>> 
'********************************************************************************
Sub  CheckEnglishOnly_sth( Opt, AppKey )
	GetMainSetting  g

	CheckEnglishOnly_exe = g_vbslib_ver_folder +"CheckEnglishOnly\CheckEnglishOnly.exe"
	RunProg  """"+ CheckEnglishOnly_exe +""" /Folder:"""+ g("TranslateRoot") +""" /Setting:CheckEnglishOnly_Setting.ini", ""
	Pass
End Sub


 
'********************************************************************************
'  <<< [CheckNoSyntaxError] >>> 
'********************************************************************************
Sub  CheckNoSyntaxError( Opt, AppKey )
	GetMainSetting  g
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( "_out.txt" ).Enable()

	echo  "英訳した vbslib が文法エラーにならないかチェックします。"
	echo  "処理対象フォルダー："""+ GetFullPath( g("TranslateRoot"), Empty ) +""""

	ExpandWildcard  g("TranslateRoot") +"\*.vbs", _
		c.File or c.SubFolder or c.AbsPath, folder, paths
	For Each path  In paths
		echo  path
		r= g_sh.Run( "cscript //nologo  """+ path +"""",, True )
		Assert  r = 0
	Next
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


 
