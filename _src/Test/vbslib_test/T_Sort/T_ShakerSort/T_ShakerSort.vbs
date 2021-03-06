Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_ShakerSort1",_
			"2","T_ShakerSort_ArrayClass",_
			"3","T_ShakerSortDicByKey",_
			"4","T_ShakerSortDicByKeyCompare",_
			"5","T_SortByPath",_
			"6","T_SortByParentPath",_
			"7","T_ReverseDictionary",_
			"8","T_CompareOption" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_ShakerSort1] >>> 
'********************************************************************************
Sub  T_ShakerSort1( Opt, AppKey )
	Dim  TestName, TestParamPath, f

	EchoTestStart  "T_ShakerSort"

	Redim  arr(8)
	Set arr(0) = new ClassA : arr(0).id = 1000 : arr(0).data = 2
	Set arr(1) = new ClassA : arr(1).id = 500  : arr(1).data = 1
	Set arr(2) = new ClassA : arr(2).id = 1000 : arr(2).data = 3
	Set arr(3) = new ClassA : arr(3).id = 1000 : arr(3).data = 4
	Set arr(4) = new ClassA : arr(4).id = 1000 : arr(4).data = 5
	Set arr(5) = new ClassA : arr(5).id = 1000 : arr(5).data = 6
	Set arr(6) = new ClassA : arr(6).id = 1000 : arr(6).data = 7
	Set arr(7) = new ClassA : arr(7).id = 1000 : arr(7).data = 8
	Set arr(8) = new ClassA : arr(8).id = 1000 : arr(8).data = 9
	ShakerSort  arr, 0, 8, GetRef("CmpFunc1"), Empty
	CheckSorted2  arr, 0, 8

	Redim  arr(5)
	Set arr(1) = new ClassA : arr(1).id = 6 : arr(1).data = 5
	Set arr(2) = new ClassA : arr(2).id = 3 : arr(2).data = 2
	Set arr(3) = new ClassA : arr(3).id = 4 : arr(3).data = 3
	Set arr(4) = new ClassA : arr(4).id = 4 : arr(4).data = 4
	Set arr(5) = new ClassA : arr(5).id = 1 : arr(5).data = 1
	ShakerSort  arr, 1, 5, GetRef("CmpFunc1"), Empty
	CheckSorted2  arr, 1, 5

	Redim  arr(2)
	Set arr(0) = new ClassA : arr(0).id = 1 : arr(0).data = 1
	Set arr(1) = new ClassA : arr(1).id = 1 : arr(1).data = 2
	Set arr(2) = new ClassA : arr(2).id = 1 : arr(2).data = 3
	ShakerSort  arr, 0, 2, GetRef("CmpFunc1"), Empty
	CheckSorted2  arr, 0, 2

	Redim  arr(8)
	Set arr(0) = new ClassA : arr(0).id = 9 : arr(0).data = 9
	Set arr(1) = new ClassA : arr(1).id = 8 : arr(1).data = 8
	Set arr(2) = new ClassA : arr(2).id = 7 : arr(2).data = 7
	Set arr(3) = new ClassA : arr(3).id = 6 : arr(3).data = 6
	Set arr(4) = new ClassA : arr(4).id = 5 : arr(4).data = 5
	Set arr(5) = new ClassA : arr(5).id = 4 : arr(5).data = 4
	Set arr(6) = new ClassA : arr(6).id = 3 : arr(6).data = 3
	Set arr(7) = new ClassA : arr(7).id = 2 : arr(7).data = 2
	Set arr(8) = new ClassA : arr(8).id = 1 : arr(8).data = 1
	ShakerSort  arr, 0, 8, GetRef("CmpFunc1"), Empty
	CheckSorted2  arr, 0, 8
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ShakerSort_ArrayClass] >>> 
'********************************************************************************
Sub  T_ShakerSort_ArrayClass( Opt, AppKey )
	Dim  arr : Set arr = new ArrayClass

	arr.Add  new ClassA : arr(0).id = 9 : arr(0).data = 9
	arr.Add  new ClassA : arr(1).id = 1 : arr(1).data = 1
	ShakerSort  arr, 0, 1, GetRef("CmpFunc1"), Empty
	CheckSorted2  arr, 0, 1
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ShakerSortDicByKey] >>> 
'********************************************************************************
Sub  T_ShakerSortDicByKey( Opt, AppKey )
	Set dic = CreateObject( "Scripting.Dictionary" )

	Set obj = new ClassA :  obj.id = 2 :  Set dic( "C" ) = obj
	Set obj = new ClassA :  obj.id = 0 :  Set dic( "A" ) = obj
	Set obj = new ClassA :  obj.id = 1 :  Set dic( "B" ) = obj
	Set obj = new ClassA :  obj.id = 4 :  Set dic( "E" ) = obj
	Set obj = new ClassA :  obj.id = 3 :  Set dic( "D" ) = obj

	ShakerSortDicByKey  dic

	answer = Array( "A", "B", "C", "D", "E" )

	echo_line
	i = 0
	For Each  key  In dic.Keys
		Assert  key = answer( i )
		Assert  dic( key ).id = i
		i = i + 1
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ShakerSortDicByKeyCompare] >>> 
'********************************************************************************
Sub  T_ShakerSortDicByKeyCompare( Opt, AppKey )
	Set dic = CreateObject( "Scripting.Dictionary" )

	Set obj = new ClassA :  obj.id = 2 :  Set dic( "10" )  = obj
	Set obj = new ClassA :  obj.id = 0 :  Set dic( "0" )   = obj
	Set obj = new ClassA :  obj.id = 1 :  Set dic( "2" )   = obj
	Set obj = new ClassA :  obj.id = 4 :  Set dic( "A30" ) = obj
	Set obj = new ClassA :  obj.id = 3 :  Set dic( "A7" )  = obj

	ShakerSortDicByKeyCompare  dic, GetRef( "NumStringCompare" ), Empty

	answer = Array( "0", "2", "10", "A7", "A30" )

	echo_line
	i = 0
	For Each  key  In dic.Keys
		Assert  key = answer( i )
		Assert  dic( key ).id = i
		i = i + 1
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SortByPath] >>> 
'********************************************************************************
Sub  T_SortByPath( Opt, AppKey )
	c_reverse = -1

	arr = ArrayToNameOnlyClassArray( Array( "F", "EE\!", "EE\*", "EE", "E!E", "E\F", "E" ) )
	ShakerSort  arr, 0, UBound( arr ), GetRef("PathNameCompare"), Empty
	arr = NameOnlyClassArrayToArray( arr )
	Assert  IsSameArray( arr, Array( "E", "E\F", "E!E", "EE", "EE\*", "EE\!", "F" ) )

	'// ピリオドとアスタリスク
	arr = ArrayToNameOnlyClassArray( Array( "!.txt", ".emacs", "*.txt", ".", ".txt" ) )
	ShakerSort  arr, 0, UBound( arr ), GetRef("PathNameCompare"), Empty
	arr2 = NameOnlyClassArrayToArray( arr )
	Assert  IsSameArray( arr2, Array( ".", "*.txt", ".emacs", ".txt", "!.txt" ) )

	ShakerSort  arr, 0, UBound( arr ), GetRef("PathNameCompare"),  c_reverse
	ReverseObjectArray  arr, arr2  '// Set "arr2"
	arr2 = NameOnlyClassArrayToArray( arr2 )
	Assert  IsSameArray( arr2, Array( ".", "*.txt", ".emacs", ".txt", "!.txt" ) )

	'// 同じ要素があるとき
	arr = ArrayToNameOnlyClassArray( Array( "F", "EE\F", "EE", "E\F", "E", "F", "EE\F", "EE", "E\F", "E" ) )
	ShakerSort  arr, 0, UBound( arr ), GetRef("PathNameCompare"), Empty
	arr = NameOnlyClassArrayToArray( arr )
	Assert  IsSameArray( arr, Array( "E", "E", "E\F", "E\F", "EE", "EE", "EE\F", "EE\F", "F", "F" ) )

	'// 逆順にするとき
	arr = ArrayToNameOnlyClassArray( Array( "E", "E\F", "E!F", "EE", "EE\F", "F" ) )
	ShakerSort  arr, 0, UBound( arr ), GetRef("PathNameCompare"),  c_reverse
	ReverseObjectArray  arr,  arr2
	arr = NameOnlyClassArrayToArray( arr2 )
	Assert  IsSameArray( arr, Array( "E", "E\F", "E!F", "EE", "EE\F", "F" ) )

	'// Option = -1
	arr = ArrayToNameOnlyClassArray( Array( "6", "55\6", "55", "5\6", "5", "6", "55\6", "55", "5\6", "5" ) )
	ShakerSort  arr,  0,  UBound( arr ),  GetRef("PathNameCompare"),  -1
	ReverseObjectArray  arr,  arr2
	arr = NameOnlyClassArrayToArray( arr2 )
	Assert  IsSameArray( arr, Array( "5", "5", "5\6", "5\6", "6", "6", "55", "55", "55\6", "55\6" ) )

	'// 数字があるとき
	arr = ArrayToNameOnlyClassArray( Array( "6", "55\6", "55", "5\6", "5", "6", "55\6", "55", "5\6", "5" ) )
	ShakerSort  arr,  0,  UBound( arr ),  GetRef("PathNameCompare"),  Empty
	arr = NameOnlyClassArrayToArray( arr )
	Assert  IsSameArray( arr, Array( "5", "5", "5\6", "5\6", "6", "6", "55", "55", "55\6", "55\6" ) )

	'// バグ ケース
	path_A = "phone_3_s.gif"
	path_B = "phone_s.gif"
	path_C = "phone3_b.gif"
	Assert  PathCompare( path_B, path_C, Empty ) < 0
	Assert  PathCompare( path_A, path_B, Empty ) < 0
	Assert  PathCompare( path_A, path_C, Empty ) < 0

	path_A = "ph1one_3_s.gif"
	path_B = "ph1one_s.gif"
	path_C = "ph1one3_b.gif"
	Assert  PathCompare( path_B, path_C, Empty ) < 0
	Assert  PathCompare( path_A, path_B, Empty ) < 0
	Assert  PathCompare( path_A, path_C, Empty ) < 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SortByParentPath] >>> 
'********************************************************************************
Sub  T_SortByParentPath( Opt, AppKey )
	reverse = -1
	Set dummy = new NameOnlyClass

	Set dic = Dic_addFromArray( Empty, Array( _
		"a", "a\1", "aa", "b", "b\1", "b\1\2", "c\1", "c" ),  dummy )
	ShakerSortDicByKeyCompare  dic,  GetRef( "ParentPathCompare" ),  reverse
	DicKeyToArr  dic,  arr  '// Set "arr"
	Assert  IsSameArray( arr,  Array( _
		"a\1", "a", "aa", "b\1\2", "b\1", "b", "c\1", "c" ) )

	Set dic = Dic_addFromArray( Empty, Array( _
		"a", "a\1", "aa", "b", "b\1", "b\1\2", "c\1", "c" ),  dummy )
	ShakerSortDicByKeyCompare  dic,  GetRef( "ParentPathCompare" ),  +1
	DicKeyToArr  dic,  arr  '// Set "arr"
	Assert  IsSameArray( arr,  Array( _
		"a", "a\1", "aa", "b", "b\1", "b\1\2", "c", "c\1" ) )
End Sub


 
'********************************************************************************
'  <<< [T_ReverseDictionary] >>> 
'********************************************************************************
Sub  T_ReverseDictionary( Opt, AppKey )

	'// Set up
	Set dic = CreateObject( "Scripting.Dictionary" )

	dic( "10" )  = 4
	dic( "0" )   = 3
	dic( "2" )   = 2
	dic( "A30" ) = 1
	dic( "A7" )  = 0

	'// Test Main
	ReverseDictionary  dic

	'// Check
	answer = Array( "A7", "A30", "2", "0", "10" )

	echo_line
	i = 0
	For Each  key  In dic.Keys
		Assert  key = answer( i )
		Assert  dic( key ) = i
		i = i + 1
	Next



	'// Set up
	Set dic = CreateObject( "Scripting.Dictionary" )

	Set obj = new ClassA :  obj.id = 4 :  Set dic( "10" )  = obj
	Set obj = new ClassA :  obj.id = 3 :  Set dic( "0" )   = obj
	Set obj = new ClassA :  obj.id = 2 :  Set dic( "2" )   = obj
	Set obj = new ClassA :  obj.id = 1 :  Set dic( "A30" ) = obj
	Set obj = new ClassA :  obj.id = 0 :  Set dic( "A7" )  = obj

	'// Test Main
	ReverseDictionary  dic

	'// Check
	answer = Array( "A7", "A30", "2", "0", "10" )

	echo_line
	i = 0
	For Each  key  In dic.Keys
		Assert  key = answer( i )
		Assert  dic( key ).id = i
		i = i + 1
	Next



	'// Test Main
	Set dic = CreateObject( "Scripting.Dictionary" )
	ReverseDictionary  dic

	'// Check
	Assert  dic.Count = 0

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CompareOption] >>> 
'********************************************************************************
Sub  T_CompareOption( Opt, AppKey )
	Set c = g_VBS_Lib

	Assert  StrCompOption( Empty ) = vbTextCompare
	Assert  StrCompOption( c.CaseSensitive ) = vbBinaryCompare
	Assert  StrCompOption( -1 ) = vbTextCompare
	Assert  StrCompOption( 0  ) = vbTextCompare
	Assert  StrCompOption( +1 ) = vbTextCompare
	Assert  StrCompOption( "" ) = vbTextCompare
	Assert  StrCompOption( c )  = vbTextCompare

	Assert  not IsReverseSortOption( Empty )
	Assert  not IsReverseSortOption( c.CaseSensitive )
	Assert      IsReverseSortOption( -1 )
	Assert  not IsReverseSortOption( 0 )
	Assert  not IsReverseSortOption( +1 )
	Assert  not IsReverseSortOption( c )

	Pass
End Sub


 
'********************************************************************************
'  <<< [ClassA] >>>
'********************************************************************************
Class  ClassA : Public id : Public data : End Class


 
'********************************************************************************
'  <<< [CmpFunc1] >>> 
'********************************************************************************
Function  CmpFunc1( left, right, param )
	CmpFunc1 = left.id - right.id    '// 降順なら right.id - left.id
End Function


 
'********************************************************************************
'  <<< [CheckSorted2] >>> 
'********************************************************************************
Sub  CheckSorted2( Arr, iStart, iLast )
	Dim  i, key, s, b

	echo  "CheckSorted"
	key = Arr(iStart).data : b = False
	For i=iStart To iLast
		s="" : If Arr(i).data < key Then  s = " (Fail)" : b = True
		echo  "("&i&") " & Arr(i).id & ", " & Arr(i).data & s
		key = Arr(i).data
	Next

	If b Then  Sleep 1000 : Fail
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


 
