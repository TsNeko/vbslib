Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()


	'// テスト中にクラスを定義するため、複数のテストを１つのプロセスで実施することはできません

	Set o = new InputCommandOpt
	Set o.CommandReplace = Dict(Array( _
		"1","T_NewModule",_
		"2","T_IncludeObjs1",_
		"3","T_IncludeObjs1b",_
		"4","T_IncludeObjs1c",_
		"5","T_IncludeObjsWilacard",_
		"6","T_IncludeObjsGetFuncs",_
		"7","T_IncludeObjsMulti",_
		"8","T_IncludeObjsMulti_NoWild",_
		"9","T_IncludeObjsEmptyArray" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_NewModule] >>> 
'********************************************************************************
Sub  T_NewModule( Opt, AppKey )
	Set  obj = get_ObjectFromFile( "objs\ClassA_obj.vbs", "ClassA" )
	If TypeName( obj ) <> "ClassA" Then  Fail
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjs1] >>> 
'********************************************************************************
Sub  T_IncludeObjs1( Opt, AppKey )
	include  "objs\*_obj.vbs"
	TestOfNewObj
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjs1b] >>> 
'********************************************************************************
Sub  T_IncludeObjs1b( Opt, AppKey )
	include  "objs"
	TestOfNewObj
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjs1c] >>> 
'********************************************************************************
Sub  T_IncludeObjs1c( Opt, AppKey )
	include_objs  "objs", Empty, Empty
	TestOfNewObj
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjsWilacard] >>> 
'********************************************************************************
Sub  T_IncludeObjsWilacard( Opt, AppKey )

	'// Test Main
	get_ObjectsFromFile  "objs\*_obj.vbs", "ClassI", objs '// [out] objs

	'// check
	CheckObjsClassName  objs, Array( "ClassA", "ClassB", "ClassC", "ClassD" )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjsGetFuncs] >>> 
'********************************************************************************
Sub  T_IncludeObjsGetFuncs( Opt, AppKey )

	'// Test Main
	include_objs  "objs\*_obj.vbs", Empty, get_funcs '// [out] get_funcs
	get_ObjectsFromFile  get_funcs, "ClassI", objs '// [out] objs

	'// check
	CheckObjsClassName  objs, Array( "ClassA", "ClassB", "ClassC", "ClassD" )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjsMulti] >>> 
'********************************************************************************
Sub  T_IncludeObjsMulti( Opt, AppKey )

	'// Test Main
	include_objs  Array( "objs\*_obj.vbs", "objs\*_objx.vbs" ), Empty, get_funcs '// [out] get_funcs
	get_ObjectsFromFile  get_funcs, "ClassI", objs '// [out] objs

	'// check
	CheckObjsClassName  objs, Array( "ClassA", "ClassB", "ClassC", "ClassD", "ClassEx" )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjsMulti_NoWild] >>> 
'********************************************************************************
Sub  T_IncludeObjsMulti_NoWild( Opt, AppKey )

	'// Test Main
	include_objs  Array( "objs\ClassA_obj.vbs", "objs\No_obj.vbs" ), Empty, get_funcs '// [out] get_funcs
	get_ObjectsFromFile  get_funcs, "ClassI", objs '// [out] objs

	'// check
	CheckObjsClassName  objs, Array( "ClassA" )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IncludeObjsEmptyArray] >>> 
'********************************************************************************
Sub  T_IncludeObjsEmptyArray( Opt, AppKey )

	'// Test Main
	include_objs  Array(  ), Empty, get_funcs '// [out] get_funcs
	get_ObjectsFromFile  get_funcs, "ClassI", objs '// [out] objs

	'// check
	CheckObjsClassName  objs, Array( )

	Pass
End Sub


 
'********************************************************************************
'  <<< [TestOfNewObj] >>> 
'********************************************************************************
Sub  TestOfNewObj()

	Set obj = new ClassA
	Set obj = get_ClassA()
	Set obj = get_Object( "ClassA" )
	Set obj = new ClassB
	Set obj = get_ClassB()
	Set obj = get_Object( "ClassB" )
	Set obj = new ClassC
	Set obj = get_ClassC()
	Set obj = get_Object( "ClassC" )
	Set obj = new ClassD
	Set obj = get_ClassD()
	Set obj = get_Object( "ClassD" )
End Sub


 
'********************************************************************************
'  <<< [CheckObjsClassName] >>> 
'********************************************************************************
Sub  CheckObjsClassName( Objs, ByVal AnsClassNames )

	For Each obj  In Objs
		For i=0 To UBound( AnsClassNames )
			If TypeName( obj ) = AnsClassNames(i) Then  AnsClassNames(i) = ""
		Next
	Next

	For i=0 To UBound( AnsClassNames )
		If AnsClassNames(i)<>"" Then  Fail
	Next
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


 
