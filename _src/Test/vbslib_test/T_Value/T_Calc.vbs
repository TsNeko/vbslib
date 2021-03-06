Option Explicit 

Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( "1","T_Calc" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Calc] >>> 
'********************************************************************************
Sub  T_Calc( Opt, AppKey )
	Dim  e, e2  ' as Err2
	Dim vars : Set vars = CreateObject( "Scripting.Dictionary" )
	Dim  formula, answer

	'//=== 基本ケース
	vars.RemoveAll
	vars.Item( "a" ) = 2
	formula = "a + 3"
	echo  vars
	echo  formula
	answer = CalculateVariables( formula, vars )
	echo    answer
	Assert  answer = 5


	'//=== 複数の変数、値が文字列型の数値
	vars.RemoveAll
	vars.Item( "a" ) = "3"
	vars.Item( "b" ) = "4"
	formula = "a + b"
	echo  vars
	echo  formula
	answer = CalculateVariables( formula, vars )
	echo    answer
	Assert  answer = 7


	'//=== 値がオブジェクト
	Dim dic : Set dic = CreateObject( "Scripting.Dictionary" )
	dic.Item( "item1" ) = 1
	vars.RemoveAll
	Set vars.Item( "dic" ) = dic
	formula = "dic(""item1"") + 2"
	echo  vars
	echo  formula
	answer = CalculateVariables( formula, vars )
	echo    answer
	Assert  answer = 3


	'//=== 変数なし
	formula = "1 + 2"
	echo  "No vars"
	echo  formula
	answer = CalculateVariables( formula, Empty )
	echo    answer
	Assert  answer = 3


	'//=== 16進数
	formula = "a + 0x10 + 0x21"
	vars.RemoveAll
	vars.Item( "a" ) = 2
	echo  vars
	echo  formula
	answer = CalculateVariables( formula, vars )
	echo    answer
	Assert  answer = &h33


	'//=== 変数の値が変数の参照
	vars.RemoveAll
	vars.Item( "a" ) = "b"
	vars.Item( "b" ) = 2
	formula = "a + b"
	echo  vars
	echo  formula
	answer = CalculateVariables( formula, vars )
	echo    answer
	Assert  answer = 4


	'//=== 変数の値が変数の参照を含む計算式
	vars.RemoveAll
	vars.Item( "a" ) = "b + 1"
	vars.Item( "b" ) = 2
	vars.Item( "c" ) = "b + 2"
	formula = "a + b + c"
	echo  vars
	echo  formula
	answer = CalculateVariables( formula, vars )
	echo    answer
	Assert  answer = 9


	'//=== 変数の値が循環参照しているとき、エラーにする
	vars.RemoveAll
	vars.Item( "a" ) = "b + 1"
	vars.Item( "b" ) = "a + 1"
	formula = "a + b"
	echo  vars
	echo  formula

	If TryStart(e) Then  On Error Resume Next
		answer = CalculateVariables( formula, vars )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo_r  e2.desc, ""
	Assert  e2.num <> 0

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

 
