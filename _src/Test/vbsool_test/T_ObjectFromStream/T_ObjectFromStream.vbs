Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	Set o = new InputCommandOpt
	o.Lead = "起動するたびに１つのテストしか実行できません。"
	Set o.CommandReplace = Dict(Array( _
		"1","T_ObjectFromStream_1",_
		"2","T_ObjectsFromStream_1" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_ObjectFromStream_1] >>> 
'********************************************************************************
Sub  T_ObjectFromStream_1( Opt, AppKey )
	Const  xml_doc = "<A><SampleClass name='A' value='3'/><SampleClass name='B' value='5'/></A>"

	include  "T_ObjectFromStream_include.vbs"

	Set xml = LoadXML( xml_doc, F_Str )
	new_ObjectFromStream  obj, "SampleClass[@name='A']", xml
	If TypeName( obj ) <> "SampleClass" Then  Fail
	If obj.m_Value <> 3 Then  Fail


	new_ObjectFromStream  obj, "SampleClass[@name='A']", "<Nothing/>"
	If not IsEmpty( obj ) Then  Fail


	new_ObjectFromStream  obj, "SampleClass", xml
	If TypeName( obj ) <> "SampleClass" Then  Fail
	If obj.m_Value <> 3 Then  Fail


	new_ObjectFromStream  obj, "SampleClass[@name='B']", xml_doc
	If TypeName( obj ) <> "SampleClass" Then  Fail
	If obj.m_Value <> 5 Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ObjectsFromStream_1] >>> 
'********************************************************************************
Sub  T_ObjectsFromStream_1( Opt, AppKey )
	Const  xml_doc = "<A><SampleClass name='A' value='3'/><SampleClass name='B' value='5'/></A>"

	include  "T_ObjectFromStream_include.vbs"

	Set xml = LoadXML( xml_doc, F_Str )
	new_ObjectsFromStream  objs, "SampleClass[@name='A']", xml
	If TypeName( objs(0) ) <> "SampleClass" Then  Fail
	If objs(0).m_Value <> 3 Then  Fail
	If UBound( objs ) <> 0 Then  Fail


	new_ObjectsFromStream  objs, "SampleClass[@name='A']", "<Nothing/>"
	If UBound( objs ) <> -1 Then  Fail


	new_ObjectsFromStream  objs, "SampleClass", xml
	If TypeName( objs(0) ) <> "SampleClass" Then  Fail
	If objs(0).m_Value <> 3 Then  Fail
	If TypeName( objs(1) ) <> "SampleClass" Then  Fail
	If objs(1).m_Value <> 5 Then  Fail
	If UBound( objs ) <> 1 Then  Fail


	new_ObjectsFromStream  objs, "SampleClass[@name='B']", xml_doc
	If TypeName( objs(0) ) <> "SampleClass" Then  Fail
	If objs(0).m_Value <> 5 Then  Fail
	If UBound( objs ) <> 0 Then  Fail

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


 
