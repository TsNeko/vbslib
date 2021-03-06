Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_CheckEnglishOnly",_
			"2","T_MakeSettingForCheckEnglish",_
			"3","T_CheckEnglishOnly_EnglishOnly",_
			"4","T_CheckEnglishOnly_EmptySetting",_
			"5","T_CheckEnglishOnly_ReadError",_
			"6","T_CheckEnglishOnly_sth" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_CheckEnglishOnly] >>> 
'********************************************************************************
Sub  T_CheckEnglishOnly( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"


	'//===========================================================
	'// Case of "IsRaiseError = False" in ".ini" file
	If section.Start( "T_CheckEnglishOnly_NotRaise" ) Then


	'// Test Main
	Set founds = CheckEnglishOnly( "T_CheckEnglishOnly", _
		"T_CheckEnglishOnly\SettingForCheckEnglish_NotRaise.ini" )


	'// Check
	QuickSort  founds, 0, founds.UBound_, GetRef("T_CheckEnglishOnly_sort"), Empty

	For Each file  In founds.Items
		For Each found  In file.NotEnglishItems.Items
			echo  file.Path +"("& found.LineNum  &"): "+ found.NotEnglishText
		Next
	Next
	Assert  founds.Count = 3

	Assert  founds(0).Path = "KanjiInUnicode.txt"
	Assert  founds(0).NotEnglishItems.Count = 2

	Set found = founds(0).NotEnglishItems(0)
	Assert  found.LineNum = 2
	Assert  found.NotEnglishText = "漢字"

	Set found = founds(0).NotEnglishItems(1)
	Assert  found.LineNum = 4
	Assert  found.NotEnglishText = "です。"


	Assert  founds(1).Path = "SJisInAscii.txt"
	Assert  founds(1).NotEnglishItems.Count = 2

	Set found = founds(1).NotEnglishItems(0)
	Assert  found.LineNum = 2
	Assert  found.NotEnglishText = "シフトJIS"

	Set found = founds(1).NotEnglishItems(1)
	Assert  found.LineNum = 4
	Assert  found.NotEnglishText = "です。"


	Assert  founds(2).Path = "sub\KanjiInUnicode.txt"
	Assert  founds(2).NotEnglishItems.Count = 2

	Set found = founds(2).NotEnglishItems(0)
	Assert  found.LineNum = 2
	Assert  found.NotEnglishText = "漢字"

	Set found = founds(2).NotEnglishItems(1)
	Assert  found.LineNum = 4
	Assert  found.NotEnglishText = "です。"

	End If : section.End_


	'//===========================================================
	'// Error Message Test
	If section.Start( "T_CheckEnglishOnly_Raise" ) Then

	Set w_= AppKey.NewWritable( "_log.txt" ).Enable()

	If TryStart(e) Then  On Error Resume Next

		RunProg  "cscript //nologo  T_CheckEnglishOnly.vbs  T_CheckEnglishOnly_Main", "_log.txt"

	If TryEnd Then  On Error GoTo 0
	If e.num = 1  Then e.Clear
	If e.num <> 0 Then  e.Raise

	AssertFC  "_log.txt",  "LogAnswer\T_CheckEnglishOnly_Raise.txt"
	del  "_log.txt"

	End If : section.End_


	'//===========================================================
	'// Error Message Test
	If section.Start( "T_CheckEnglishOnly_Raise2" ) Then

	Set w_= AppKey.NewWritable( "_log.txt" ).Enable()

	If TryStart(e) Then  On Error Resume Next

		RunProg  "cscript //nologo  T_CheckEnglishOnly.vbs  T_CheckEnglishOnly_Main2", "_log.txt"

	If TryEnd Then  On Error GoTo 0
	If e.num = 1  Then e.Clear
	If e.num <> 0 Then  e.Raise

	AssertFC  "_log.txt",  "LogAnswer\T_CheckEnglishOnly_Raise2.txt"
	del  "_log.txt"

	End If : section.End_


	Pass
End Sub


Sub  T_CheckEnglishOnly_Main( Opt, AppKey )
	Set founds = CheckEnglishOnly( "T_CheckEnglishOnly", _
		"T_CheckEnglishOnly\SettingForCheckEnglish.ini" )
	Pass
End Sub


Sub  T_CheckEnglishOnly_Main2( Opt, AppKey )
	Set founds = CheckEnglishOnly( "T_CheckEnglishOnly", _
		"T_CheckEnglishOnly2\SettingForCheckEnglish.ini" )
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CheckEnglishOnly_sort] >>> 
'********************************************************************************
Function  T_CheckEnglishOnly_sort( in_Left, in_Right, in_Empty )
    T_CheckEnglishOnly_sort = StrComp( in_Left.Path, in_Right.Path )
End Function


 
'********************************************************************************
'  <<< [T_MakeSettingForCheckEnglish] >>> 
'********************************************************************************
Sub  T_MakeSettingForCheckEnglish( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_CheckEnglishOnly.ini" ).Enable()

	'// Set up

	'// Test Main
	MakeSettingForCheckEnglish  "_CheckEnglishOnly.ini",_
		Array( "T_Translate\T_Translate1.trans", "T_Translate\T_Translate_MultiTarget.trans" )

	'// Check
	AssertFC  "_CheckEnglishOnly.ini", "LogAnswer\T_MakeSettingForCheckEnglish_ans.txt"

	'// Clean
	del  "_CheckEnglishOnly.ini"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CheckEnglishOnly_EnglishOnly] >>> 
'********************************************************************************
Sub  T_CheckEnglishOnly_EnglishOnly( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()

	'// Set up
	del   "_work"
	copy  "T_CheckEnglishOnly\AsciiOnly.txt", "_work"

	'// Test Main
	Set founds = CheckEnglishOnly( "_work", Empty )

	'// Check
	Assert  founds.Count = 0

	'// Clean
	del   "_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CheckEnglishOnly_EmptySetting] >>> 
'********************************************************************************
Sub  T_CheckEnglishOnly_EmptySetting( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()

	'// Set up
	del   "_work"
	copy  "T_CheckEnglishOnly\SJisInAscii.txt", "_work"

	'// Test Main
	'// Check
	If TryStart(e) Then  On Error Resume Next

		CheckEnglishOnly  "_work", Empty

	If TryEnd Then  On Error GoTo 0
	If e.num = 1  Then e.Clear
	If e.num <> 0 Then  e.Raise

	'// Clean
	del   "_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CheckEnglishOnly_ReadError] >>> 
'********************************************************************************
Sub  T_CheckEnglishOnly_ReadError( Opt, AppKey )

	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set founds = CheckEnglishOnly( "T_CheckEnglishOnly", Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "CRT_Error.bin" ) > 0
	Assert  e2.num <> 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CheckEnglishOnly_sth] >>> 
'********************************************************************************
Sub  T_CheckEnglishOnly_sth( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_out.txt" ).Enable()

	'// Set up
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )

	'// Test Main
	r= RunProg( "cscript //nologo """+ prompt_vbs +""" CheckEnglishOnly  "+_
		"T_CheckEnglishOnly  T_CheckEnglishOnly\SettingForCheckEnglish.ini", _
		"_out.txt" )

	'// Check
	AssertFC  "_out.txt", "LogAnswer\T_CheckEnglishOnly_sth_ans.txt"

	'// Clean
	del  "_out.txt"

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


 
