Option Explicit 

Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_EachCopy1", "2","T_EachMove1" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_EachCopy1] >>> 
'********************************************************************************
Sub  T_EachCopy1( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( Array( "out", "data2" ) ).Enable()
	T_EachCopyMove1  "CallForEach_copy"
	Pass
End Sub


Sub  T_EachCopyMove1( FuncName )
	Dim  e  ' as Err2
	Dim  arr


	'//=== CallForEach_copy
	T_EachCopyMove1_reset
	CallForEach2  GetRef( FuncName ), _
		Array( "data2\src1.txt", "data2\src2\*", "data2\src4" ), _
		".", "out"

	If not exist( "out\data2\src1.txt" ) Then  Fail
	If not exist( "out\data2\src2\src2.txt" ) Then  Fail
	If not exist( "out\data2\src2\sub\src2_sub.txt" ) Then  Fail
	If not exist( "out\data2\src4\src2\src2.txt" ) Then  Fail
	If not exist( "out\data2\src4\src2\sub\src2_sub.txt" ) Then  Fail


	'//=== ワイルドカードがあるとき
	T_EachCopyMove1_reset
	CallForEach2  GetRef( FuncName ), _
		Array( "data2\src*.txt" ), ".", "out"

	If not exist( "out\data2\src1.txt" ) Then  Fail
	If not exist( "out\data2\src2.txt" ) Then  Fail


	'//=== ファイル名だけのとき
	T_EachCopyMove1_reset
	pushd  "data2"
	CallForEach2  GetRef( FuncName ), "src1.txt", ".", "..\out"
	popd
	If not exist( "out\src1.txt" ) Then  Fail


	'//=== "" のとき
	T_EachCopyMove1_reset
	CallForEach2  GetRef( FuncName ), "", ".", "..\out"
	If exist( "out" ) Then  Fail


	'//=== ArrayClass の中に Array があるとき（正しいエラーメッセージが出ること）

	'//=== Error Handling Test
	echo  vbCRLF+"Next is Error Test"

	T_EachCopyMove1_reset
	Set arr = new ArrayClass
	arr.Add  Array( "data2\src1.txt", "data2\src2\*" )

	If TryStart(e) Then  On Error Resume Next
		CallForEach2  GetRef( FuncName ), arr.Items, ".", "out"
	If TryEnd Then  On Error GoTo 0
	echo  e.desc
	If InStr( e.desc, "ファイル名が文字列型になっていません" ) = 0 Then  Fail
	If e.num <> 13 Then  Fail
	e.Clear


	T_EachCopyMove1_reset
End Sub


Sub  T_EachCopyMove1_reset()
	Dim ec : Set ec = new EchoOff
	del  "data2"
	copy "data\*", "data2"
	del  "out"
End Sub


 
'********************************************************************************
'  <<< [T_EachMove1] >>> 
'********************************************************************************
Sub  T_EachMove1( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( Array( "out", "data2" ) ).Enable()
	T_EachCopyMove1  "CallForEach_move"
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

 
