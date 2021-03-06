Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( "1","T_TestCaseData", "2","T_SetReadTestCase", _
			"3","T_BaseTestCaseData" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_TestCaseData] >>> 
'********************************************************************************
Sub  T_TestCaseData( Opt, AppKey )
	Dim  x, y, mix, i, j

	'// set up

	'// Test Main
	Dim xx      : Set xx      = ReadTestCase( "T_TestCaseData.xml", Empty )
	Dim cases_x : Set cases_x = ReadTestCase( "T_TestCaseData.xml", "T_TestCaseData_1" )
	Dim cases_y : Set cases_y = ReadTestCase( "T_TestCaseData.xml", "T_TestCaseData_2" )
	Set mix = CreateObject( "Scripting.Dictionary" )


	'// check
	j = 0
	For Each y  In cases_y.Items
		i = 0
		For Each x  In cases_x.Items
			Dic_add  x, xx  '// 共通データ xx を、ループ変数 b に追加する
			mix.RemoveAll : Dic_add  mix, x : Dic_add  mix, y  '// クロス・ケース
			mix("i") = i : mix("j") = j  '// スクリプトからデータを追加する
			T_TestCaseData_main  Opt, AppKey, mix
			i=i+1
		Next
		j=j+1
	Next

	'// clean

	Pass
End Sub


Sub  T_TestCaseData_main( Opt, AppKey, x )
	'// set up
	'// ( T_TestCaseData_1,  T_TestCaseData_2 )
	Dim input_data_array     : input_data_array     = Array( "123", "ABCDE" )
	Dim answer_array         : answer_array         = Array( "ans1.txt", "ans2.txt" )
	Dim current_folder_array : current_folder_array = Array( "", "Data" )
	Dim step_path_array      : step_path_array      = Array( "Data\", "" )

	'// Test Main

	'// check
	echo  x
	Assert  x("InputData")     = input_data_array( x("i") )
	Assert  x("Answer")        = answer_array( x("i") )
	Assert  x("CurrentFolder") = current_folder_array( x("j") )
	Assert  x("StepPath")      = step_path_array( x("j") )
	Assert  x("CommonData1") = "Sample.exe"
	Assert  IsEmpty( x("Unknown") )

	'// clean
End Sub


 
'********************************************************************************
'  <<< [T_SetReadTestCase] >>> 
'********************************************************************************
Sub  T_SetReadTestCase( Opt, AppKey )
	Dim cases1, x,  e, e2
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()


	'//=== SetReadTestCase の基本

	'// set up

	'// Test Main
	SetReadTestCase  "T_TestCaseData.xml", "T_TestCaseData_1", "InputData = '123'"
	Set cases1 = ReadTestCase( "T_TestCaseData.xml", "T_TestCaseData_1" )

	'// check
	Assert  cases1.Count = 1
	For Each x  In cases1.Items
		echo  x( "Answer" )
		Assert  x( "Answer" ) = "ans1.txt"
	Next

	'// clean
	SetReadTestCase  "T_TestCaseData.xml", "T_TestCaseData_1", Empty


	'//=== ２つ目の SubCase にマッチする場合

	'// set up

	'// Test Main
	SetReadTestCase  "T_TestCaseData.xml", "T_TestCaseData_1", "InputData = 'ABCDE'"
	Set cases1 = ReadTestCase( "T_TestCaseData.xml", "T_TestCaseData_1" )

	'// check
	Assert  cases1.Count = 1
	For Each x  In cases1.Items
		echo  x( "Answer" )
		Assert  x( "Answer" ) = "ans2.txt"
	Next

	'// clean
	SetReadTestCase  "T_TestCaseData.xml", "T_TestCaseData_1", Empty


	'//=== SubCase にマッチしない場合

	'// set up

	'// Test Main
	SetReadTestCase  "T_TestCaseData.xml", "T_TestCaseData_1", "InputData = 'NotFound'"

	If TryStart(e) Then  On Error Resume Next

		Set cases1 = ReadTestCase( "T_TestCaseData.xml", "T_TestCaseData_1" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2

	'// check
	echo    "Next is Error Test"
	echo    e2.desc
	Assert  e2.num <> 0


	'//=== SetReadTestCase のリセット

	'// set up

	'// Test Main
	SetReadTestCase  "T_TestCaseData.xml", "T_TestCaseData_1", "InputData = 'NotFound'"
	SetReadTestCase  "T_TestCaseData.xml", "T_TestCaseData_1", Empty
	Set cases1 = ReadTestCase( "T_TestCaseData.xml", "T_TestCaseData_1" )

	'// check
	Assert  cases1.Count = 2


	'//=== aggregate した先の SubCase にマッチする場合

	'// set up

	'// Test Main
	SetReadTestCase  "T_TestCaseData.xml", "T_AggregateTestCaseData_1", "name = '7'"
	Set cases1 = ReadTestCase( "T_TestCaseData.xml", "T_AggregateTestCaseData_1" )

	'// check
	Assert  cases1.Count = 1
	For Each x  In cases1.Items
		echo  x( "attr" )
		Assert  x( "attr" ) = "value7"
	Next


	'//=== aggregate する TestCase で、SubCase にマッチしない場合

	'// set up

	'// Test Main
	SetReadTestCase  "T_TestCaseData.xml", "T_AggregateTestCaseData_1", "name = '99'"

	If TryStart(e) Then  On Error Resume Next

		Set cases1 = ReadTestCase( "T_TestCaseData.xml", "T_AggregateTestCaseData_1" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2

	'// check
	echo    "Next is Error Test"
	echo    e2.desc
	Assert  e2.num <> 0

	'// clean
	SetReadTestCase  "T_TestCaseData.xml", "T_AggregateTestCaseData_1", Empty


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_BaseTestCaseData] >>> 
'********************************************************************************
Sub  T_BaseTestCaseData( Opt, AppKey )
	Dim  x, cases, e, e2, i

	'// base_data 属性を使って、継承するタグを指定するケース、オーバーライドするケース
	Set cases = ReadTestCase( "T_TestCaseData.xml", "T_BaseTestCaseData_1" )
	echo    cases(0)
	Assert  cases(0).Item( "name" ) = "1a"
	Assert  cases(0).Item( "a" )  = "1"
	Assert  cases(0).Item( "ab" ) = "1"
	Assert  cases(0).Item( "b" )  = "2"


	'// base_data 属性を使って、多重継承するケース、孫継承するケース
	Set cases = ReadTestCase( "T_TestCaseData.xml", "T_BaseTestCaseData_2" )
	echo    cases(1)
	Assert  cases(1).Item( "name" ) = "2a"
	Assert  cases(1).Item( "a" )    = "1"
	Assert  cases(1).Item( "b" )    = "2"
	Assert  cases(1).Item( "c" )    = "3"
	Assert  cases(1).Item( "d" )    = "4"
	Assert  cases(1).Item( "ab" )   = "1"
	Assert  cases(1).Item( "cd" )   = "3"
	Assert  cases(1).Item( "bcd" )  = "2"
	Assert  cases(1).Item( "abcd" ) = "1"
	Assert  cases(1).Item( "bd" )   = "2"


	'// base_data 属性を使って、別のファイルから継承するケース
	Set cases = ReadTestCase( "T_TestCaseData.xml", "T_BaseTestCaseData_3" )
	echo    cases(0)
	Assert  cases(0).Item( "name" )  = "3a"
	Assert  cases(0).Item( "a" )  = "1"
	Assert  cases(0).Item( "ab" ) = "1"
	Assert  cases(0).Item( "b" )  = "2"


	'// TestCases タグ（ルート・タグ）の base_data 属性を使うケース
	Set x = ReadTestCase( "T_TestCaseData\sub\T_TestCaseData2.xml", Empty )
	Assert  x( "name" )  = "common"
	Assert  x( "bcd" ) = "3"
	Assert  x( "cd" )  = "3"
	Assert  x( "d" )   = "4"


	'// base_data 属性に親フォルダーを探す指定（"..."）をするケースと、
	'// TestCases タグ（グループタグ）の base_data 属性から継承するケース
	Set cases = ReadTestCase( "T_TestCaseData\sub\T_TestCaseData2.xml", "T_BaseTestCaseData_11" )
	echo    cases(0)
	Assert  cases(0).Item( "name" )  = "11a"
	Assert  cases(0).Item( "a" )   = "1"
	Assert  cases(0).Item( "ab" )  = "1"
	Assert  cases(0).Item( "b" )   = "2"
	Assert  cases(0).Item( "bcd" ) = "2"
	Assert  cases(0).Item( "cd" )  = "3"
	Assert  cases(0).Item( "d" )   = "4"


	'// base_data 属性が循環参照エラーしているケース
	If TryStart(e) Then  On Error Resume Next

		Set cases = ReadTestCase( "T_TestCaseData.xml", "T_BaseTestCaseData_Cyclic" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo_r  e2.desc, ""
	Assert  e2.num <> 0


	'// plus_attr 属性を使って、値を CSV 形式で追加していくケース
	Set cases = ReadTestCase( "T_TestCaseData\sub\T_TestCaseData2.xml", "T_BaseTestCaseData_22" )
	echo    cases(0)
	Assert  cases(0).Item( "name") = "22a"
	Assert  cases(0).Item( "ab" )  = "1"     '// 子をオーバーライドする
	Assert  cases(0).Item( "Ab" )  = "1, 2"  '// 子も追加する
	Assert  cases(0).Item( "ad" )  = "1"
	Assert  cases(0).Item( "Ad" )  = "1, 4"  '// 共通の子も追加する（？）
	Assert  cases(0).Item( "bc" )  = "2"     '// 継承元に追加指定が無いときは、共通の属性も追加しない（？）
	Assert  cases(0).Item( "Bc" )  = "2, 3"

	Assert  cases(0).Item( "abcd" )= "1"
	Assert  cases(0).Item( "abCd" )= "1"
	Assert  cases(0).Item( "aBcd" )= "1"
	Assert  cases(0).Item( "Abcd" )= "1, 2"  '// "bc" と同じ
	Assert  cases(0).Item( "AbCd" )= "1, 2"
	Assert  cases(0).Item( "ABcd" )= "1, 2, 3"

	Assert  cases(0).Item( "acd" ) = "1"
	Assert  cases(0).Item( "aCd" ) = "1"
	Assert  cases(0).Item( "Acd" ) = "1, 3"     '// 共通の属性も追加するが、それはこをオーバーライドしている
	Assert  cases(0).Item( "ACd" ) = "1, 3, 4"  '// 共通の属性も追加し、その子も追加する

	Assert  cases(0).Item( "bcd" ) = "2"
	Assert  cases(0).Item( "Bcd" ) = "2, 3"
	Assert  cases(0).Item( "bCd" ) = "2"
	Assert  cases(0).Item( "BCd" ) = "2, 3, 4"  '// 正解は不明（？）

	Assert  cases(0).Item( "cd" )  = "3"     '// 共通の子をオーバーライドした共通の属性
	Assert  cases(0).Item( "Cd" )  = "3, 4"  '// 共通の子も追加する

	Assert  cases(0).Item( "d" )   = "4"


	'// aggregate 属性を使って、SubCase タグ（子のタグ）を追加していくケース
	Set cases = ReadTestCase( "T_TestCaseData.xml", "T_AggregateTestCaseData_1" )
	echo  cases
	Assert  cases.Count = 8
	For i=0 To cases.UBound_
		Assert  cases(i).Item( "name" ) = CStr( i+1 )
		Assert  cases(i).Item( "attr" ) = "value" & (i+1)
	Next


	'// aggregate 属性が循環参照エラーしているケース
	If TryStart(e) Then  On Error Resume Next

		Set cases = ReadTestCase( "T_TestCaseData.xml", "T_AggregateTestCaseData_Cyclic_1A" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    "Next is Error Test"
	echo    e2.desc
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


 
