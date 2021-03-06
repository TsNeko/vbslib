Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Switches" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_Switches
'***********************************************************************
Sub  T_Switches( Opt, AppKey )
	w_=Empty : Set w_=AppKey.NewWritable( "_work" ).Enable()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Switches_NotFound"


	For Each  is_prompt  In  Array( False, True )
	For Each  t  In DicTable( Array( _
		"AB_Before",  "XYZ_Before",  "AB_After",  "XYZ_After",   Empty, _
		"A",          "X",           "B",         "Y", _
		"B",          "Y",           "A",         "X", _
		"A",          "X",           "B",         "Z", _
		"B",          "Z",           "A",         "X" ) )


		a = t("AB_Before")
		x = t("XYZ_Before")
		b = t("AB_After")
		y = t("XYZ_After")
	If section.Start( "T_Switches_"+ a + x +"_"+ b + y ) Then


		'// Set up
		del  "_work"
		copy_ren  "T_Switches\Switches.trans",     "_work\Switches.trans"
		copy_ren  "T_Switches\File",               "_work\File"
		copy_ren  "T_Switches\Text1"+a+x+".txt",   "_work\Text1.txt"
		copy_ren  "T_Switches\Text2"+a+".txt",     "_work\Text2.txt"
		If x <> "Z" Then
			copy_ren  "T_Switches\File\File"+x+".txt", "_work\File.txt"
			copy_ren  "T_Switches\File\Folder"+x,      "_work\Folder"
		End If

		OpenForReplace( "_work\Switches.trans", Empty ).Replace _
			"<SwitchNow  target_set_names=""SetB, SetY""/>", _
			"<SwitchNow  target_set_names=""Set"+b+", Set"+y+"""/>"

		'// Test Main
		If not is_prompt Then
			Set switches = new SwitchesClass
			switches.IsEnabledReversibleError = False
			switches.Load  "_work\Switches.trans"
			Set w_=AppKey.NewWritable( switches.GetWritableFolders() ).Enable()
			switches.Run  Empty
		Else
			RunProg  "cscript  //nologo  """+ prompt_vbs +_
				"""  Switches  ""_work\Switches.trans"" Do Exit", ""
		End If

		'// Check
		AssertFC    "_work\Text1.txt",  "T_Switches\Text1"+b+y+".txt"
		AssertFC    "_work\Text2.txt",  "T_Switches\Text2"+b+".txt"
		If y <> "Z" Then
			AssertFC    "_work\File.txt",   "T_Switches\File\File"+y+".txt"
			Assert  fc( "_work\Folder",     "T_Switches\File\Folder"+y )
		Else
			Assert  not exist( "_work\File.txt" )
			Assert  not exist( "_work\Folder" )
		End IF

		'// Clean
		w_=Empty : Set w_=AppKey.NewWritable( "_work" ).Enable()
		del  "_work"

	End If : section.End_
	Next
	Next


	For Each  is_prompt  In  Array( False, True )
	For Each  t  In DicTable( Array( _
		"Case",       "trans_FileName",     "Measage",   Empty, _
		"NotFound",   "NotFoundText.trans", "不明", _
		"NotSetName", "NotSetName.trans",   "NotDefinedSetA" ) )

	If section.Start( "T_Switches_"+ t("Case") ) Then

		'// Set up
		del  "_work"
		copy_ren  "T_Switches\Error\"+ t("trans_FileName"), "_work\Switches.trans"
		copy_ren  "T_Switches\Text1AX.txt", "_work\Text1.txt"


		'// Test Main
		If not is_prompt Then
			Set switches = new SwitchesClass
			switches.IsEnabledReversibleError = False
			switches.Load  "_work\Switches.trans"
			Set w_=AppKey.NewWritable( switches.GetWritableFolders() ).Enable()

			'// Error Handling Test
			echo  vbCRLF+"Next is Error Test"
			If TryStart(e) Then  On Error Resume Next

				switches.Run  Empty

			If TryEnd Then  On Error GoTo 0
			switches = Empty
			e.CopyAndClear  e2  '//[out] e2
			echo    e2.desc
			Assert  InStr( e2.desc, t("Measage") ) > 0
			Assert  e2.num <> 0

		Else

			'// Error Handling Test
			echo  vbCRLF+"Next is Error Test"
			If TryStart(e) Then  On Error Resume Next

				RunProg  "cscript  //nologo  """+ prompt_vbs +_
					"""  Switches  ""_work\Switches.trans"" Do Exit", "_work\_out.txt"

			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2
			echo    e2.desc
			Assert  InStr( e2.desc, t("Measage") ) > 0
			Assert  e2.num <> 0

		End If


		'// Check
		Assert  IsSameBinaryFile( "_work\Text1.txt", "T_Switches\Text1AX.txt", Empty )


		'// Clean
		w_=Empty : Set w_=AppKey.NewWritable( "_work" ).Enable()
		del  "_work"

	End If : section.End_
	Next
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


 
