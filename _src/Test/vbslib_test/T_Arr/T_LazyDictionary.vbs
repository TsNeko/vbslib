Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_LazyDictionary_1", _
			"2","T_LazyDictionary_DebugMode", _
			"3","T_LazyDictionary_Each", _
			"4","T_LazyDictionaryXML", _
			"5","T_LazyDictionaryEcho" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionary_1] >>> 
'********************************************************************************
Sub  T_LazyDictionary_1( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Env"


	'//==== 基本ケース
	If section.Start( "T_Basic" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${RootPath}") = "C:\FolderA"
	g("${Empty}") = Empty

	'// Test Main, Check
	Assert  g("${RootPath}") = "C:\FolderA"
	Assert  IsEmpty( g("${Empty}") )


	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		echo    g("${UndefinedKey}")

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "${UndefinedKey}" ) > 0
	Assert  e2.num <> 0


	End If : section.End_


	'//==== 値に変数の参照があるとき
	If section.Start( "T_Value" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${RootPath}") = "C:\Folder${Target}"
	g("${Target}") = "A"

	'// Test Main, Check
	echo    g("${RootPath}")
	Assert  g("${RootPath}") = "C:\FolderA"

	g("${Target}") = "B"
	echo    g("${RootPath}")
	Assert  g("${RootPath}") = "C:\FolderB"

	'// Test Main, Check
	g("${Target}") = True
	echo    g("${RootPath}")
	Assert  g("${RootPath}") = "C:\FolderTrue"

	'// Test Main, Check
	g("${RootPath2}") = "C:\Folder${Unknown}"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		echo    g("${RootPath2}")

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "${Unknown}" ) > 0
	Assert  e2.num <> 0

	End If : section.End_


	'//==== 変数名に変数の参照があるとき
	If section.Start( "T_VarName" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${RootPath}") = "${${Target}/RootPath}"
	g("${TargetA/RootPath}") = "C:\FolderA"
	g("${TargetB/RootPath}") = "C:\FolderB"

	'// Test Main, Check
	g("${Target}") = "TargetA"
	echo    g("${RootPath}")
	Assert  g("${RootPath}") = "C:\FolderA"

	g("${Target}") = "TargetB"
	echo    g("${RootPath}")
	Assert  g("${RootPath}") = "C:\FolderB"

	End If : section.End_


	'//==== 関数の代わりに使うとき
	If section.Start( "T_Func" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${RootPath( TargetA )}") = "C:\FolderA"
	g("${RootPath( TargetB )}") = "C:\FolderB"

	'// Test Main, Check
	target = "TargetA"
	echo    g("${RootPath( "+ target +" )}")
	Assert  g("${RootPath( "+ target +" )}") = "C:\FolderA"

	target = "TargetB"
	echo    g("${RootPath( "+ target +" )}")
	Assert  g("${RootPath( "+ target +" )}") = "C:\FolderB"


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		target = "Unknown"
		Assert  g("${RootPath( "+ target +" )}") = "C:\FolderA"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "${RootPath( Unknown )}" ) > 0
	Assert  e2.num <> 0

	End If : section.End_


	'//==== 参照時に式が指定されたとき
	If section.Start( "T_Formula" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${Var1}") = "1"
	g("${Var2}") = "2"

	'// Test Main, Check
	Assert  g("${Var1}+${Var2}") = "1+2"
	Assert  g("${Var${Var1}}") = "1"


	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		echo  g("${Var1}+${UndefinedKey2}")

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "${UndefinedKey2}" ) > 0
	Assert  e2.num <> 0

	End If : section.End_


	'//==== ${ } 形式ではない変数名ではないとき（異常系）
	If section.Start( "T_Func" ) Then

	'// Set up
	Set g = new LazyDictionaryClass

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	is_loop = True
	test_num = 1
	Do
		If TryStart(e) Then  On Error Resume Next

			Select Case  test_num
				Case 1:  g("$RootPath")     = "C:\FolderA"
				Case 2:  Set g("$RootPath") = new LazyDictionaryClass
				Case 3:  g.Add  "$RootPath",  "C:\FolderA"
				Case 4:  is_loop = False
			End Select

		If TryEnd Then  On Error GoTo 0
		If not is_loop Then  Exit Do

		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  InStr( e2.desc, "$RootPath" ) > 0
		Assert  e2.num <> 0

		test_num = test_num + 1
	Loop

	End If : section.End_


	'//==== 上書き禁止期間
	If section.Start( "T_ReadOnly" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g.ReadOnly = True
	g("${Var1}") = "1"
	g("${Var2}") = "1"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		g("${Var1}") = "1"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	End If : section.End_


	'//==== 無限ループ抑止
	If section.Start( "T_ExpandInfinite" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${Var1}") = "${Var2}"
	g("${Var2}") = "${Var1}"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		echo  g("${Var1}")
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	End If : section.End_


	'//==== 参照記号 ${ } のエスケープ
	If section.Start( "T_Escape" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${Var1}") = "x"
	g("${Var2}") = "${Var1},${Var1},$Var1,$\{Var1},$\\;"

	'// Test Main, Check
	Assert  g("${Var2}") = "x,x,$Var1,${Var1},$\;"

	End If : section.End_


	'//==== 参照記号 ${ } のエスケープ
	If section.Start( "T_Object" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	Set object_1 = g_sh
	Set object_2 = g_fs

	'// Test Main, Check
	Set g("${Obj1}") = object_1
	Set g("${Obj2}") = object_2
	g("${ToObj2}") = "${Obj2}"
	Assert  g("${Obj1}") Is g_sh
	Assert  g("${Obj2}") Is g_fs
	Assert  g("${ToObj2}") Is g_fs

	End If : section.End_


	'//==== 無いキーを削除
	If section.Start( "T_RemoveDouble" ) Then

	'// Set up
	Set g = new LazyDictionaryClass

	'// Test Main, Check
	g.Remove  "${Var1}"
	g.Remove  "${Var1}"

	End If : section.End_


	'//==== その他、標準辞書互換
	If section.Start( "T_Others" ) Then

	'// Set up
	Set g = new LazyDictionaryClass

	'// Test Main, Check
	Assert  g.Count = 0

	'// Set up
	g("${Var1}") = "x"
	g("${Var2}") = "y"
	g("${Var3}") = "z"

	'// Test Main, Check
	Assert  g.Count = 3

	'// Test Main, Check
	keys_answer  = Array( "${Var1}", "${Var2}", "${Var3}" )
	index = 0
	For Each  key  In  g.Keys
		Assert  key = keys_answer( index )
		index = index + 1
	Next

	'// Test Main, Check
	items_answer = Array( "x", "y", "z" )
	index = 0
	For Each  item  In  g.Items
		Assert  item = items_answer( index )
		index = index + 1
	Next

	'// Test Main
	g.Remove  "${Var2}"

	'// Check
	Assert      g.Exists( "${Var1}" )
	Assert  not g.Exists( "${Var2}" )
	Assert      g.Exists( "${Var3}" )

	'// Test Main
	g.RemoveAll

	'// Check
	Assert  not g.Exists( "${Var1}" )
	Assert  not g.Exists( "${Var3}" )

	End If : section.End_


	'//==== CompareMode
	If section.Start( "T_CompareMode" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${Var1}") = "x"
	g("${VAR1}") = "y"

	'// Test Main, Check
	Assert  g("${Var1}") = "x"
	Assert  g("${VAR1}") = "y"

	'// Set up
	Set g = new LazyDictionaryClass
	g.CompareMode = 1
	g("${Var1}") = "x"

	'// Test Main, Check
	Assert  g("${VAR1}") = "x"

	End If : section.End_


	'//==== 環境変数
	If section.Start( "T_Env" ) Then

	Set g = new LazyDictionaryClass
	Assert  g("${USERPROFILE}\Desktop") = g_sh.SpecialFolders( "Desktop" )

	End If : section.End_


	'// Clean
	'// Do Nothing

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionary_DebugMode] >>> 
'********************************************************************************
Sub  T_LazyDictionary_DebugMode( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_out.txt" ).Enable()

	'// Set up
	del  "_out.txt"

	'// Test Main
	RunProg  "cscript //nologo  T_LazyDictionary.vbs  T_LazyDictionary_DebugMode_Sub", "_out.txt"

	'// Check
	AssertFC  "_out.txt", "Files\T_LazyDictionary_DebugMode_Answer.txt"

	'// Clean
	del  "_out.txt"

	Pass
End Sub


 
Sub  T_LazyDictionary_DebugMode_Sub( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Array"


	'//==== 基本ケース
	If section.Start( "T_Basic" ) Then
	Set g = new LazyDictionaryClass
	g.DebugMode = True
	g("${RootPath}") = "C:\FolderA"
	Assert  g("${RootPath}") = "C:\FolderA"
	End If : section.End_


	'//==== 値に変数の参照があるとき
	If section.Start( "T_Value" ) Then
	Set g = new LazyDictionaryClass
	g.DebugMode = True
	g("${RootPath}") = "C:\Folder${Target}"

	g("${Target}") = "A"
	Assert  g("${RootPath}") = "C:\FolderA"

	g("${Target}") = "B"
	Assert  g("${RootPath}") = "C:\FolderB"
	End If : section.End_


	'//==== 変数名に変数の参照があるとき
	If section.Start( "T_VarName" ) Then
	Set g = new LazyDictionaryClass
	g.DebugMode = True
	g("${RootPath}") = "${${Target}/RootPath}"
	g("${TargetA/RootPath}") = "C:\FolderA"
	g("${TargetB/RootPath}") = "C:\FolderB"

	g("${Target}") = "TargetA"
	Assert  g("${RootPath}") = "C:\FolderA"

	g("${Target}") = "TargetB"
	Assert  g("${RootPath}") = "C:\FolderB"
	End If : section.End_


	'//==== 値に配列を入れて、各要素を動的参照する
	If section.Start( "T_Array" ) Then
	Set g = new LazyDictionaryClass
	g.DebugMode = True
	g("${Array}") = Array( "${${Target}/RootPath}/1", "${${Target}/RootPath}/2" )
	g("${TargetA/RootPath}") = "C:\FolderA"
	g("${Target}") = "TargetA"

	result = g("${Array}")
	Assert  IsSameArray( result, Array( "C:\FolderA/1", "C:\FolderA/2" ) )
	End If : section.End_


	'//==== 配列の加算、式（変数参照する前の値）を返す
	If section.Start( "T_AddArray2" ) Then
	Set g = new LazyDictionaryClass
	g.DebugMode = True
	g("${Array3}") = "${Array2}"
	g("${Array2}") = Array( "${Array1}", "${Var}/3", "${Var}/4", "${Var}/5" )
	g("${Array1}") = Array( "${Var}/1", "${Var}/2" )
	g("${Var}") = "x"
	result3 = g("${Array3}")
	End If : section.End_


	'//==== 参照記号 ${ } のエスケープ
	If section.Start( "T_Escape" ) Then
	Set g = new LazyDictionaryClass
	g.DebugMode = True
	g("${Var1}") = "x"
	g("${Var2}") = "${Var1},${Var1},$Var1,$\{Var1},$\\;"
	Assert  g("${Var2}") = "x,x,$Var1,${Var1},$\;"
	End If : section.End_

End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionary_Each] >>> 
'********************************************************************************
Sub  T_LazyDictionary_Each( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_AddArray2"


	'//==== 値に配列を入れて、各要素を動的参照する
	If section.Start( "T_Array" ) Then

	'// Set up
	Set g = new LazyDictionaryClass

	'// Test Main
	g("${Array}") = Array( "${${Target}/RootPath}/1", "${${Target}/RootPath}/2" )
	g("${TargetA/RootPath}") = "C:\FolderA"
	g("${Target}") = "TargetA"

	result = g("${Array}")

	'// Check
	Assert  IsSameArray( result, Array( "C:\FolderA/1", "C:\FolderA/2" ) )


	'// Set up
	Set g = new LazyDictionaryClass

	'// Test Main : 要素なし
	g("${Array}") = Array( )
	result = g("${Array}")

	'// Check
	Assert  UBound( result ) = -1


	'// Set up
	Set g = new LazyDictionaryClass

	'// Test Main : 間接参照
	g("${Array}") = Array( "1", "2" )
	g("${Array2}") = "${Array}"
	result = g("${Array2}")

	'// Check
	Assert  IsSameArray( result, Array( "1", "2" ) )

	End If : section.End_


	'//==== 配列の加算、式（変数参照する前の値）を返す
	If section.Start( "T_AddArray" ) Then

	'// Set up
	Set g = new LazyDictionaryClass

	'// Test Main
	g("${Array1}") = Array( "${Var}/1", "${Var}/2" )
	g("${Array2}") = Add( g.Formula("${Array1}"), Array( "${Var}/3", "${Var}/4", "${Var}/5" ) )
	g("${Var}") = "x"
	result = g("${Array2}")

	'// Check
	Assert  IsSameArray( result, Array( "x/1", "x/2", "x/3", "x/4", "x/5" ) )

	End If : section.End_

	If section.Start( "T_AddArray2" ) Then

	'// Set up
	Set g = new LazyDictionaryClass

	'// Test Main
	g("${Array3}") = "${Array2}"
	g("${Array2}") = Array( "${Array1}", "${Var}/3", "${Var}/4", "${Var}/5" )
	g("${Array1}") = Array( "${Var}/1", "${Var}/2" )
	g("${Var}") = "x"
	array1 = g("${Array1}")
	array2 = g("${Array2}")
	array3 = g("${Array3}")

	'// Check
	Assert  IsSameArray( array1, Array( "x/1", "x/2" ) )
	Assert  IsSameArray( array2, Array( "x/1", "x/2", "x/3", "x/4", "x/5" ) )
	Assert  IsSameArray( array3, Array( "x/1", "x/2", "x/3", "x/4", "x/5" ) )

	End If : section.End_


	'//==== 配列の変換
	If section.Start( "T_ArrayElements" ) Then

	'// Set up
	Set g = new LazyDictionaryClass
	g("${Workspace/Lib}")    = "FolderA"
	g("${Workspace/Sample}") = "FolderB" 

	'// Test Main, Check
	values1 = g.Each_( "${Workspace/${i}}", "${i}", Array( "Lib", "Sample" ) )
	Assert  IsSameArray( values1, Array( "FolderA", "FolderB" ) )

	formulas = g.EachFormula( "${Workspace/${i}}", "${i}", Array( "Lib", "Sample" ) )
	Assert  IsSameArray( formulas, Array( "${Workspace/Lib}", "${Workspace/Sample}" ) )

	values2 = g( formulas )
	Assert  IsSameArray( values2, values1 )

	End If : section.End_

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionaryXML] >>> 
'********************************************************************************
Sub  T_LazyDictionaryXML( Opt, AppKey )

	'// Set up
	Set root = LoadXML( "Files\T_LazyDictionaryXML.xml", Empty )
	data = root.selectSingleNode( "Data" ).getAttribute( "data" )

	'// Test Main
	Set variables = new_LazyDictionaryClass( root )
	data = variables( data )

	'// Check
	Assert  data = "ABCDEF"

	'// Clean
	'// Do Nothing

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionaryEcho] >>> 
'********************************************************************************
Sub  T_LazyDictionaryEcho( Opt, AppKey )
	Set g = new LazyDictionaryClass
	g("${Var1}") = "Value1"
	g("${Var2}") = "${Var1}-2"
	g("${Var3}") = Array( "3-1", "3-2" )

	'// g.Show

	text = g.xml
	Assert  text = _
		"<LazyDictionaryClass>"+ vbCRLF +_
		"${Var1} = ""Value1"""+ vbCRLF +_
		"${Var2} = ""${Var1}-2"" = ""Value1-2"""+ vbCRLF +_
		"${Var3} = <Array ubound=""1"">"+ vbCRLF +_
		"  <Item id=""0"">3-1</Item>"+ vbCRLF +_
		"  <Item id=""1"">3-2</Item>"+ vbCRLF +_
		"</Array>"+ vbCRLF +_
		"</LazyDictionaryClass>"

	Pass
End Sub


 








'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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


 
