Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_IsSameArray",_
			"2","T_IsSameArrayOutOfOrder",_
			"3","T_Arr1",_
			"4","T_ArrClass",_
			"5","T_ArrIter",_
			"6","T_AddNewObj",_
			"7","T_ArrayDic1",_
			"8","T_ArrayCustom",_
			"9","T_AddToFastUBound_Speed",_
			"10","T_AddArray",_
			"11","T_FlatArray",_
			"12","T_RemoveObjectsByNames" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_IsSameArray] >>> 
'*************************************************************************
Sub  T_IsSameArray( Opt, AppKey )
	Assert      IsSameArray( Array( 1, 2 ),  Array( 1, 2 ) )
	Assert  not IsSameArray( Array( 1, 2 ),  Array( 2, 1 ) )
	Assert  not IsSameArray( Array( 1, 2 ),  Array( 1 ) )
	Assert  not IsSameArray( Array( 1, 2 ),  Array( 1, 2, 3 ) )

	Assert      IsSameArray( new_ArrayClass( Array( 1, 2 ) ),  new_ArrayClass( Array( 1, 2 ) ) )
	Assert  not IsSameArray( new_ArrayClass( Array( 1, 2 ) ),  new_ArrayClass( Array( 2, 1 ) ) )
	Assert  not IsSameArray( new_ArrayClass( Array( 1, 2 ) ),  new_ArrayClass( Array( 1 ) ) )
	Assert  not IsSameArray( new_ArrayClass( Array( 1, 2 ) ),  new_ArrayClass( Array( 1, 2, 3 ) ) )

	Assert      IsSameArray( Array( 1 ),  Array( 1 ) )
	Assert      IsSameArray( Array(   ),  Array(   ) )
	Assert  not IsSameArray( Array(   ),  Array( 1 ) )
	Assert  not IsSameArray( Array( 1 ),  Array(   ) )

	Assert      IsSameArray( Empty,  Empty )
	Assert  not IsSameArray( Empty,  Array( 1 ) )

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_IsSameArrayOutOfOrder] >>> 
'*************************************************************************
Sub  T_IsSameArrayOutOfOrder( Opt, AppKey )
	Assert      IsSameArrayOutOfOrder( Array( 1, 2 ),  Array( 1, 2 ), Empty )
	Assert      IsSameArrayOutOfOrder( Array( 1, 2 ),  Array( 2, 1 ), Empty )
	Assert  not IsSameArrayOutOfOrder( Array( 1, 2 ),  Array( 1 ), Empty )
	Assert  not IsSameArrayOutOfOrder( Array( 1, 2 ),  Array( 1, 2, 3 ), Empty )

	Assert      IsSameArrayOutOfOrder( Array( 1 ),  Array( 1 ), Empty )
	Assert      IsSameArrayOutOfOrder( Array(   ),  Array(   ), Empty )
	Assert  not IsSameArrayOutOfOrder( Array(   ),  Array( 1 ), Empty )
	Assert  not IsSameArrayOutOfOrder( Array( 1 ),  Array(   ), Empty )

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_Arr1] >>> 
'*************************************************************************
Sub  T_Arr1( Opt, AppKey )

	'//===
	Set a = new ArrayClass
	WScript.Echo "count = " & a.Count
	a.Add 1
	a.Add 2
	WScript.Echo  "count = " & a.Count
	WScript.Echo  GetEchoStr( a )
	echo  a
	echo  a(0)
	a(0) = 3
	echo  a(0)

	'//===
	echo  Array( 4, 8 )

	ReDim  a(0) : a(0) = 2
	AddArrElem  a, Array( 3, 4 )
	echo  a

	'//===
	Set a = new ArrayClass
	a.push  3
	a.AddElems  Array( 4, 5 )
	echo  a

	'//=== Test of set object
	Set a(0) = new ArrayClass

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ArrClass] >>> 
'*************************************************************************
Sub  T_ArrClass( Opt, AppKey )

	Set arr = new ArrayClass
	WScript.Echo "count = " & arr.Count
	Set elem = new TestElem
	elem.Num1 = 11
	elem.Num2 = 12
	arr.Add elem
	elem.Num1 = 21
	elem.Num2 = 22
	arr.Add elem
	WScript.Echo "count = " & arr.Count
	echo  arr

	Set arr = new ArrayClass
	arr.ReDim_ 3
	Assert  UBound( arr.Items ) = 3
	Assert  arr.UBound_ = 3


	'//----------------------------------------------------------
	EchoTestStart  "T_ArrClass_Remove"

	Set arr = new_ArrayClass( Array( 0, 1, 2, 3, 4, 5, 6 ) )
	arr.Remove  1, 2
	Assert  IsSameArray( arr.Items, Array( 0, 3, 4, 5, 6 ) )

	Set arr = new_ArrayClass( Array( 0, 1, 2, 3, 4, 5, 6 ) )
	arr.Remove  0, 4
	Assert  IsSameArray( arr.Items, Array( 4, 5, 6 ) )

	Set arr = new_ArrayClass( Array( 0, 1, 2, 3, 4, 5, 6 ) )
	arr.Remove  5, 2
	Assert  IsSameArray( arr.Items, Array( 0, 1, 2, 3, 4 ) )


	'//----------------------------------------------------------
	EchoTestStart  "T_ArrClass_RemoveEmpty"

	Set arr = new_ArrayClass( Array( 0, Empty, 2, Empty, Empty, 5 ) )
	arr.RemoveEmpty
	Assert  IsSameArray( arr.Items, Array( 0, 2, 5 ) )

	Set arr = new_ArrayClass( Array( Empty, Empty, Empty ) )
	arr.RemoveEmpty
	Assert  arr.Count = 0

	Set obj = CreateObject( "Scripting.Dictionary" )
	Set arr = new_ArrayClass( Array( 0, Empty, 2, Empty, Empty, obj ) )
	arr.RemoveEmpty
	Assert  arr(0) = 0
	Assert  arr(1) = 2
	Assert  arr(2) Is obj

	Pass
End Sub

 
'*************************************************************************
'  <<< [T_ArrIter] >>> 
'*************************************************************************
Sub  T_ArrIter( Opt, AppKey )

	Set a = new ArrayClass
	T_ArrIter_sub  a

	Set elem = new TestElem : elem.Num1 = 1 : a.Add elem
	T_ArrIter_sub  a

	Set elem = new TestElem : elem.Num1 = 2 : a.Add elem
	T_ArrIter_sub  a

	Set sentinel = new TestElem : sentinel.Num1 = -1


	'//=== Sentinel
	Set iter = a.NewIterator()
	echo  "---"
	While iter.HasNext()
		echo  iter.GetNextOrSentinel( sentinel ).Num1
	WEnd
	echo  iter.GetNextOrSentinel( sentinel ).Num1
	echo  "---"



	'//=== Double iterators
	Set iter1 = a.NewIterator()
	Set iter2 = a.NewIterator()
	echo  "---"
	While iter1.HasNext()
		echo  iter1.GetNext().Num1 &", "& iter2.GetNext().Num1
	WEnd
	echo  "---"


	'//=== Elemet is not Object
	Set a = new ArrayClass
	a.Add 1
	echo  "---"
	Set iter = a.NewIterator()
	While iter.HasNext
		echo  iter.GetNext()
	WEnd
	echo  "---"

	Pass
End Sub


Sub  T_ArrIter_sub( a )
	Dim  iter, elem

	echo  "---"
	Set iter = a.NewIterator()
	While iter.HasNext
		Set elem = iter.GetNext()
		echo  elem.Num1
	WEnd
	echo  "---"
End Sub

 
'*************************************************************************
'  <<< [T_AddNewObj] >>> 
'*************************************************************************
Sub  T_AddNewObj( Opt, AppKey )
	Set arr = new ArrayClass

	Set o = arr.AddNewObject( "ClassA", "ObjectA" )
	o.Param = 1

	Set o = arr.AddNewObject( "ClassA", "ObjectB" )
	o.Param = 2
	Set o2 = o

	If arr.Count <> 2 Then  Fail
	If arr(0).Param <> 1 Then  Fail
	If arr(1).Param <> 2 Then  Fail

	Set o = arr.AddNewObject( "ClassA", "ObjectC" )
	o.Param = 3

	Set o = arr.AddNewObject( "ClassA", "ObjectD" )
	o.Param = 4

	Set r = arr.RemoveObject( o2 )

	Assert  arr.Count = 3
	Assert  arr(0).Param = 1
	Assert  arr(1).Param = 3
	Assert  arr(2).Param = 4
	Assert  r is o2

	Set r = arr.RemoveObject( o2 )

	Assert  arr.Count = 3
	Assert  arr(0).Param = 1
	Assert  arr(1).Param = 3
	Assert  arr(2).Param = 4
	Assert  r is Nothing


	'//===============

	Set arr = new_ArrayClass( Array( 1, 2, 3 ) )
	Assert  arr.Count = 3
	Assert  arr(0) = 1
	Assert  arr(1) = 2
	Assert  arr(2) = 3

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ArrayDic1] >>> 
'*************************************************************************
Sub  T_ArrayDic1( Opt, AppKey )

	'//=== add items by duplicated key
	Set dic = New ArrayDictionary
	dic.Add  "key1", "item11"
	dic.Add  "key1", "item12"
	dic.Add  "key1", "item13"
	dic.Add  "key2", "item21"
	dic.Echo

	WScript.Echo  "count = " & dic.Count
	For Each j in dic.Dic.Items() : For Each i in j.Items
		WScript.Echo  i
	Next : Next
	WScript.Echo  ""


	'//=== empty
	dic.ToEmpty
	dic.Add  "key1", "item11"

	WScript.Echo  "count = " & dic.Count
	For Each j in dic.Dic.Items() : For Each i in j.Items
		WScript.Echo  i
	Next : Next
	WScript.Echo  ""

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ArrayCustom] >>> 
'*************************************************************************
Sub  T_ArrayCustom( Opt, AppKey )
	Set arr = new ArrayClass

	arr.AddNewObject( "ClassA", "A" ).Param = 10
	arr.AddNewObject( "ClassA", "B" ).Param = 20
	arr.AddNewObject( "ClassA", "C" ).Param = 30

	Set arr.ItemFunc = GetRef( "ClassA_getItem" )

	Assert  arr( "A" ).Param = 10
	Assert  arr( "B" ).Param = 20
	Assert  arr( 0 ).Param = 10

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_AddToFastUBound_Speed] >>> 
'*************************************************************************
Sub  T_AddToFastUBound_Speed( Opt, AppKey )
	Const  n = 100000


	'//=== pre ReDim
	ReDim arr(-1)
	t0 = Timer
	ReDim Preserve  arr( n )
	For i=0 To n
		arr( i ) = i
	Next
	t1 = Timer - t0
	WScript.Echo  FormatNumber( t1, 3 ) & "(sec)"  '// 0.031(sec)

	Assert  UBound( arr ) = n
	For i=0 To n : Assert arr( i ) = i : Next


	'//=== ReDim each add
	ReDim arr(-1)
	t0 = Timer
	For i=0 To n
		ReDim Preserve  arr( UBound( arr ) + 1 )
		arr( UBound( arr ) ) = i
	Next
	t1 = Timer - t0
	WScript.Echo  FormatNumber( t1, 3 ) & "(sec)"  '// 0.688(sec)

	Assert  UBound( arr ) = n
	For i=0 To n : Assert arr( i ) = i : Next


	'//=== arr_fast_ubound : +1
	ReDim arr(-1)
	t0 = Timer
	arr_fast_ubound = UBound( arr )
	For i=0 To n
		If UBound(arr) <= arr_fast_ubound Then _
			ReDim Preserve  arr( ( arr_fast_ubound + 100 ) * 4 )
		arr_fast_ubound = arr_fast_ubound + 1

		arr( arr_fast_ubound ) = i
	Next
	ReDim Preserve  arr( arr_fast_ubound )
	t1 = Timer - t0
	WScript.Echo  FormatNumber( t1, 3 ) & "(sec)"  '// 0.125(sec)

	Assert  UBound( arr ) = n
	For i=0 To n : Assert arr( i ) = i : Next


	'//=== arr_fast_ubound : +plus
	ReDim arr(-1)
	plus = +1
	t0 = Timer
	arr_fast_ubound = UBound( arr )
	For i=0 To n
		If UBound(arr) < arr_fast_ubound + plus Then _
			ReDim Preserve  arr( ( arr_fast_ubound + plus + 100 ) * 4 )
		arr_fast_ubound = arr_fast_ubound + plus

		arr( arr_fast_ubound ) = i
	Next
	ReDim Preserve  arr( arr_fast_ubound )
	t1 = Timer - t0
	WScript.Echo  FormatNumber( t1, 3 ) & "(sec)"  '// 0.172(sec)

	Assert  UBound( arr ) = n
	For i=0 To n : Assert arr( i ) = i : Next


	'//=== ArrayClassFastUBound
	Set arrc = new ArrayClassFastUBound
	arrc.StartFastUBound
	t0 = Timer
	For i=0 To n
		arrc.AddToFastUBound  i
	Next
	arrc.EndFastUBound
	t1 = Timer - t0
	WScript.Echo  FormatNumber( t1, 3 ) & "(sec)"  '// 0.766(sec)

	Assert  UBound( arrc.Items ) = n
	For i=0 To n : Assert arrc.Items( i ) = i : Next
End Sub


 
'*************************************************************************
'  <<< [T_AddArray] >>> 
'*************************************************************************
Sub  T_AddArray( Opt, AppKey )
	Assert  IsSameArray( Add( Array( "1", "2" ), Array( "3", "4", "5" ) ), _
		Array( "1", "2", "3", "4", "5" ) )

	Assert  IsSameArray( Add( Array( ), Array( "a" ) ), _
		Array( "a" ) )

	Assert  IsSameArray( Add( Array( "a" ), Array( ) ), _
		Array( "a" ) )

	Assert  IsSameArray( Add( Array(  ), Array( ) ), _
		Array( ) )

	Assert  Add( 1, 2 ) = 3

	Assert  Add( "A", "B" ) = "AB"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_FlatArray] >>> 
'*************************************************************************
Sub  T_FlatArray( Opt, AppKey )

	'// Set up
	input_array = Array( "a", "b", Array( "ca", "cb" ), "d", Array( "ea", "eb" ) )

	'// Test Main
	FlatArray  out_array, input_array

	'// Check
	Assert  IsSameArray( out_array, Array( "a", "b", "ca", "cb", "d", "ea", "eb" ) )


	'// Set up
	out_array = input_array

	'// Test Main
	FlatArray  out_array, out_array

	'// Check
	Assert  IsSameArray( out_array, Array( "a", "b", "ca", "cb", "d", "ea", "eb" ) )


	'// Set up
	input_array = Array( Array( "a", "b" ) )
	out_array = input_array

	'// Test Main
	FlatArray  out_array, out_array

	'// Check
	Assert  IsSameArray( out_array, Array( "a", "b" ) )

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_RemoveObjectsByNames] >>> 
'*************************************************************************
Sub  T_RemoveObjectsByNames( Opt, AppKey )
	Set object_b    = new NameOnlyClass : object_b.Name    = "b"
	Set object_c    = new NameOnlyClass : object_c.Name    = "c"
	Set object_null = new NameOnlyClass : object_null.Name = ""
	objects = Array( object_c, object_null, object_b )

	Set re_a = CreateObject("VBScript.RegExp") : re_a.Pattern = ".\.a"
	Set re_b = CreateObject("VBScript.RegExp") : re_b.Pattern = ".\.b"

	For Each  t  In DicTable( Array( _
		"Num", "Array",                 "Key",          "Answer",  Empty, _
		0,     Array( "a", "b", "c" ),  "b",            Array( "a", "c" ), _
		1,     Array( "a", "b", "c" ),  "",             Array( "a", "b", "c" ), _
		2,     Array( "a", "b", "c" ),  Array("b","c"), Array( "a" ), _
		3,     Array( ),                "b",            Array( ), _
		4,     Array( "a" ),            "a",            Array( ), _
		5,     Array( "a", "b", "c" ),  object_b,       Array( "a", "c" ), _
		6,     Array( "a", "b", "c" ),  object_null,    Array( "a", "b", "c" ), _
		7,     Array( "a", "b", "c" ),  objects,        Array( "a" ), _
		8,     Array( "a.a", "b.a", "c.c" ), re_a,                Array( "c.c" ), _
		9,     Array( "a.a", "c.c", "b.b" ), Array( re_a, re_b ), Array( "c.c" ) ))

		arr = ArrayToNameOnlyClassArray( t("Array") )

		RemoveObjectsByNames  arr, t("Key")

		arr = NameOnlyClassArrayToArray( arr )
		Assert  IsSameArray( arr, t("Answer") )
	Next

	Pass
End Sub



 
'-------------------------------------------------------------------------
' ### <<<< [ArrayClassFastUBound] Class >>>> 
'-------------------------------------------------------------------------
Class  ArrayClassFastUBound
	Public  Items '// as array
	Public  FastUBound   '// as Empty or integer
	Private Sub  Class_Initialize() : ReDim  Items( -1 ) : End Sub

	Public Sub  StartFastUBound()
		Me.FastUBound = UBound( Items )
	End Sub

	Public Sub  EndFastUBound()
		ReDim Preserve  Items( Me.FastUBound )
		Me.FastUBound = Empty
	End Sub

	Public Sub  AddToFastUBound( Elem )
		If UBound(Items) <= FastUBound Then _
			ReDim Preserve  Items( ( FastUBound + 100 ) * 4 )
		FastUBound = FastUBound + 1

		Items( FastUBound ) = Elem
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [ClassA] Class >>>> 
'-------------------------------------------------------------------------

Class ClassA
	Public  Name
	Public  Param
End Class

Function  new_ClassA() : Set new_ClassA = new ClassA : End Function

Function  ClassA_getItem( Items, Name )
	Dim  s
	If IsNumeric( Name ) Then
		Set ClassA_getItem = Items( Name )
	Else
		For Each s  In Items
			If s.Name = Name Then  Set ClassA_getItem = s : Exit Function
		Next
	End If
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [TestElem] Class >>>> 
'-------------------------------------------------------------------------

Class TestElem
	Public  Num1
	Public  Num2
	Public Property Get  xml():xml=xml_sub(0):CutLastOf xml,vbCRLF,Empty:End Property
	Public Function  xml_sub( Level )
		xml_sub = "<TestElem Num1=""" & Me.Num1 & """ Num2=""" & Me.Num2 &"""/>"
	End Function

End Class


 







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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
