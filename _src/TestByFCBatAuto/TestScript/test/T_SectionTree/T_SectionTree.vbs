Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_SectionTree_1", _
			"2","T_SectionTree_2", _
			"3","T_SectionTree_0", _
			"4","T_SectionTree_Err", _
			"5","T_SectionTree_SetStart", _
			"6","T_SectionTree_SetStart2", _
			"7","T_SectionTree_SetStart3", _
			"8","T_SectionTree_SetStartMiss" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_1] >>> 
'********************************************************************************
Sub  T_SectionTree_1( Opt, AppKey )
	g_IsAutoTest = True
	T_SectionTree_1_Sub  Opt, AppKey
	T_SectionTree_1_Sub  Opt, AppKey  '// 2回目
	Pass
End Sub


Sub  T_SectionTree_1_Sub( Opt, AppKey )
	Dim  section
	Dim  head : head = "  "  '// "Class SectionTree"+vbCRLF+"  "

	Set section = new SectionTree
	Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""""/>"
	If section.Start( "Sec1" ) Then
		Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Sec1""/>"
	End If : section.End_
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_2] >>> 
'********************************************************************************
Sub  T_SectionTree_2( Opt, AppKey )
	Dim  section
	Dim  head : head = "  "  '// "Class SectionTree"+vbCRLF+"  "

	g_IsAutoTest = True

	Set section = new SectionTree
	Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""""/>"
	If section.Start( "Sec1" ) Then
		Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Sec1""/>"
	End If : section.End_
	If section.Start( "Sec2" ) Then
		Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Sec2""/>"
		If section.Start( "sub1" ) Then
			Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Sec2,sub1""/>"
			section.End_
		End If
		Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Sec2""/>"
	End If : section.End_
	Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""""/>"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_0] >>> 
'********************************************************************************
Sub  T_SectionTree_0( Opt, AppKey )
	T_SectionTree_0_Sub
	Pass
End Sub

Sub  T_SectionTree_0_Sub()
	Dim  section : Set section = new SectionTree

	'// Call "SectionTree::Class_Terminate" : No message of T_SectionTree_NoName
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_Err] >>> 
'********************************************************************************
Sub  T_SectionTree_Err( Opt, AppKey )
	Dim  section, e
	Dim  head : head = "  "  '// "Class SectionTree"+vbCRLF+"  "

	g_IsAutoTest = True

	Set section = new SectionTree
	If section.Start( "Main1" ) Then
		Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Main1""/>"

		If TryStart(e) Then  On Error Resume Next

			T_SectionTree_Err_sub

		If TryEnd Then  On Error GoTo 0
		If e.num = E_Others  Then  e.Clear
		If e.num <> 0 Then  e.Raise

		Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Main1""/>"
	End If : section.End_
	Pass
End Sub

Sub  T_SectionTree_Err_sub
	Dim  section
	Dim  head : head = "  "  '// "Class SectionTree"+vbCRLF+"  "

	Set section = new SectionTree
	If section.Start( "Sec1" ) Then
	End If : section.End_
	If section.Start( "Sec2" ) Then
		If section.Start( "sub1" ) Then
		End If : section.End_
		If section.Start( "sub2" ) Then
			Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Main1,Sec2,sub2""/>"
			Raise  1, "T_SectionTree_Err_sub"
		End If : section.End_
		If section.Start( "sub3" ) Then
		End If : section.End_
	End If : section.End_
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_SetStart] >>> 
'********************************************************************************
Sub  T_SectionTree_SetStart( Opt, AppKey )
	Dim  section, executed_count
	Dim  head : head = "  "  '// "Class SectionTree"+vbCRLF+"  "

	g_IsAutoTest = True

	executed_count = 0
	SetStartSectionTree  "Sec2, sub2"

	Set section = new SectionTree
	If section.Start( "Sec1" ) Then
		Error
	End If : section.End_
	If section.Start( "Sec2" ) Then
		If section.Start( "sub1" ) Then
			Error
		End If : section.End_
		If section.Start( "sub2" ) Then
			echo  section                             '// ここが開始セクション
			executed_count = executed_count + 1
		End If : section.End_   '// SetActiveSectionTree に Don't pause が無ければ、ここで pause する
		If section.Start( "sub3" ) Then
			echo  section                             '// 次のセクションも実行する
			executed_count = executed_count + 1
		End If : section.End_
		Assert  GetEchoStr( section ) = head+"<SectionTree CurrentSectionNames=""Sec2""/>"
	End If : section.End_
	Assert  executed_count = 2
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_SetStart2] >>> 
'********************************************************************************
Sub  T_SectionTree_SetStart2( Opt, AppKey )
	Dim  section,  is_pass

	g_IsAutoTest = True

	SetStartSectionTree  Array( "Sec2", "sub2" )  '  //############ Test Point
		'// test of using array

	Set section = new SectionTree
	If section.Start( "Sec1" ) Then
		Error
	End If : section.End_
	If section.Start( "Sec2" ) Then
		If section.Start( "sub1" ) Then
			Error
		End If : section.End_
		If section.Start( "sub2" ) Then
			echo  section
			is_pass = True
		End If : section.End_
		Assert  is_pass
		If section.Start( "sub3" ) Then
			echo  section
		End If : section.End_
	End If : section.End_
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_SetStart3] >>> 
' Call SetStartSectionTree in some sections.
'********************************************************************************
Sub  T_SectionTree_SetStart3( Opt, AppKey )
	Dim  section,  is_pass

	g_IsAutoTest = True

	Set section = new SectionTree
	is_pass = False
	If section.Start( "Sec1" ) Then
	End If : section.End_
	If section.Start( "Sec2" ) Then
		SetStartSectionTree  Array( "sub2" )  '  //############ Test Point
		If section.Start( "sub1" ) Then
			Error
		End If : section.End_
		If section.Start( "sub2" ) Then
			echo  section
			is_pass = True
		End If : section.End_
		Assert  is_pass
		If section.Start( "sub3" ) Then
			echo  section
		End If : section.End_
	End If : section.End_
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SectionTree_SetStartMiss] >>> 
'********************************************************************************
Sub  T_SectionTree_SetStartMiss( Opt, AppKey )
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		T_SectionTree_SetStartMiss_Sub

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0  and  e2.num <> 21
	Pass
End Sub


Sub  T_SectionTree_SetStartMiss_Sub()
	Dim  section,  is_pass

	g_IsAutoTest = True

	SetStartSectionTree  Array( "NotFound" )  '  //############ Test Point

	Set section = new SectionTree
	is_pass = False
	If section.Start( "Sec1" ) Then
	End If : section.End_
	echo  "Pass の後に、「セクションが１つも実行されていないか Pass していません」エラーになること。"
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


 
