Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_OpenForReplaceXML_Manually",_
			"2","T_OpenForReplaceXML_Err_Manually" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplaceXML_Manually] >>> 
'********************************************************************************
Sub  T_OpenForReplaceXML_Manually( Opt, AppKey )
	Dim  xml
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	echo_line
	EchoTestStart  "T_OpenForReplaceXML_Manually1"
	echo  "次の「変更の確認」で表示される XPath の一覧に、"+_
		".../Test2/... が無いことを確認したら、続行してください。 "
	pause
	echo_line

	copy_ren  "sample5.xml", "out.xml"
	Set xml = OpenForReplaceXML( "out.xml", Empty )
	xml.Write  "/Root/Tests/Test1/@attr1", "1"
	xml.Write  "/Root/Tests/Test2/@attr1", "0"
	xml.Write  "/Root/Tests/Test3/@attr1", "3"
	xml.IsUserConfirm = True
	xml = Empty

	If not fc( "out.xml", "XmlWrite_ans5.xml" ) Then  Fail
	del  "out.xml"


	echo_line
	EchoTestStart  "T_OpenForReplaceXML_Manually2"
	echo  "XML ファイルを修正しようとしますが、変更前後の値が同じケースを実施します。"
	echo  "変更することをユーザに確認されないこと。"
	pause
	echo_line

	copy_ren  "sample5.xml", "out.xml"
	Set xml = OpenForReplaceXML( "out.xml", Empty )
	xml.Write  "/Root/Tests/Test2/@attr1", "0"
	xml.IsUserConfirm = True
	xml = Empty

	If not fc( "out.xml", "sample5.xml" ) Then  Fail
	del  "out.xml"
End Sub


 
'********************************************************************************
'  <<< [T_OpenForReplaceXML_Err_Manually] >>> 
'********************************************************************************
Sub  T_OpenForReplaceXML_Err_Manually( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	echo  "エラー 70 で Pause されること。"
	Pause

	'// Set up
	mkdir  "tmp"
	del    "tmp\*"


	'// Test Main
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		T_OpenForReplaceXML_Err_Sub

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = 70


	'// Clean
	del  "tmp"

	Pass
End Sub


Sub  T_OpenForReplaceXML_Err_Sub()
	Set xml = OpenForReplaceXML( "sample1.xml", "tmp" )  '// "tmp" is not able to overwrite
	xml.Write  "./Tests/@tmp", "1"
	xml = Empty
	echo  "デストラクタ（xml = Empty など）でエラーがあっても、どうしても続きが実行されてしまうのは、"+_
		"VBScript の仕様。 エラーが消えてしまう On Error Resume Next の前に、"+_
		"ErrCheck を記述することで、発見だけはできるようにする。"
	ErrCheck : Fail  '// Fail は、On Error Resume Next の代わり
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


 
