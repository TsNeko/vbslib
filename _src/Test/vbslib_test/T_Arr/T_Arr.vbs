Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"0","T_IsSame",_
			"1","T_IsSameArray",_
			"2","T_IsSameArrayOutOfOrder",_
			"3","T_IsSameArrayEx",_
			"4","T_Arr1",_
			"5","T_ArrayClass",_
			"6","T_ArrIter",_
			"7","T_AddNewObj",_
			"8","T_ArrayDic1",_
			"9","T_ArrayCustom",_
			"10","T_AddToFastUBound_Speed",_
			"11","T_AddArray",_
			"12","T_FlatArray",_
			"13","T_RemoveObjectsByNames",_
			"14","T_ReverseObjectArray" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_IsSame] >>> 
'*************************************************************************
Sub  T_IsSame( Opt, AppKey )
	Assert      IsSame( Empty, Empty )
	Assert  not IsSame( Empty, "" )
	Assert  not IsSame( "", Empty )
	Assert      IsSame( Null, Null )
	Assert  not IsSame( Null, "" )
	Assert  not IsSame( "", Null )
	Assert      IsSame( Nothing, Nothing )
	Assert  not IsSame( Nothing, Null )
	Assert  not IsSame( Null, Nothing )
	Assert      IsSame( 1, 1 )
	Assert  not IsSame( 1, 2 )
	Assert      IsSame( "A", "A" )
	Assert  not IsSame( "A", "a" )
	Pass
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
'  <<< [T_IsSameArrayEx] >>> 
'*************************************************************************
Sub  T_IsSameArrayEx( Opt, AppKey )

	Assert      IsSameArrayEx( Array( 1, 2 ),  Array( 1, 2 ), Empty )
	Assert  not IsSameArrayEx( Array( 1, 2 ),  Array( 2, 1 ), Empty )
	Assert  not IsSameArrayEx( Array( 1, 2 ),  Array( 1 ), Empty )
	Assert  not IsSameArrayEx( Array( 1, 2 ),  Array( 1, 2, 3 ), Empty )

	Set option_ = new IsSameArrayExOptionClass
	option_.IsOutOfOrder = True
	Assert      IsSameArrayEx( Array( 1, 2 ),  Array( 1, 2 ), option_ )
	Assert      IsSameArrayEx( Array( 1, 2 ),  Array( 2, 1 ), option_ )
	Assert  not IsSameArrayEx( Array( 1, 2 ),  Array( 1 ), option_ )
	Assert  not IsSameArrayEx( Array( 1, 2 ),  Array( 1, 2, 3 ), option_ )

	option_.IsOutOfOrder = False
	Set option_.CompareFunction = GetRef( "NameCompare" )
	Assert      IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "1", 2 ), new_NameOnlyClass( "2", 2 ) ), option_ )
	Assert  not IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "2", 2 ), new_NameOnlyClass( "1", 2 ) ), option_ )
	Assert  not IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "1", 2 ) ), option_ )
	Assert  not IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "1", 2 ), new_NameOnlyClass( "2", 0 ), new_NameOnlyClass( "3", 0 ) ), option_ )

If False Then  '// Not supported
	option_.IsOutOfOrder = True
	Set option_.CompareFunction = GetRef( "NameCompare" )
	Assert      IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "1", 2 ), new_NameOnlyClass( "2", 2 ) ), option_ )
	Assert      IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "2", 2 ), new_NameOnlyClass( "1", 2 ) ), option_ )
	Assert  not IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "1", 2 ) ), option_ )
	Assert  not IsSameArrayEx( _
		Array( new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ) ), _
		Array( new_NameOnlyClass( "1", 2 ), new_NameOnlyClass( "2", 0 ), new_NameOnlyClass( "3", 0 ) ), option_ )
End If

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
'  <<< [T_ArrayClass] >>> 
'*************************************************************************
Sub  T_ArrayClass( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_ArrayClass_CSV"
	Set option_ = new IsSameArrayExOptionClass

	If section.Start( "T_ArrayClass" ) Then

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

	End If : section.End_


	'//----------------------------------------------------------
	If section.Start( "T_ArrayClass_Insert" ) Then

	Set arr = new_ArrayClass( Array( 0, 1, 2, 3 ) )
	arr.Insert  0, 6
	arr.Insert  2, 7
	arr.Insert  Empty, 8
	arr.Insert  7, 9
	Assert  IsSameArray( arr.Items, Array( 6, 0, 7, 1, 2, 3, 8, 9 ) )


	Set arr = new_ArrayClass( Array( ) )
	arr.Insert  0, 4
	Assert  IsSameArray( arr.Items, Array( 4 ) )


	objects = Array( new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA(), _
		new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA() )

	Set arr = new_ArrayClass( Array( objects( 0 ), objects( 1 ), objects( 2 ), objects( 3 ) ) )
	arr.Insert  0, objects( 6 )
	arr.Insert  2, objects( 7 )
	arr.Insert  Empty, objects( 8 )
	arr.Insert  7, objects( 9 )
	index = Array( 6, 0, 7, 1, 2, 3, 8, 9 )
	For  i = 0  To  UBound( index )
		Assert  arr( i ) is objects( index( i ) )
	Next

	End If : section.End_


	'//----------------------------------------------------------
	If section.Start( "T_ArrayClass_Search" ) Then

	Set arr = new_ArrayClass( Array( _
			new_NameOnlyClass( "1", 0 ), new_NameOnlyClass( "2", 0 ), _
			new_NameOnlyClass( "3", 2 ), new_NameOnlyClass( "1", 2 ) ) )
	Set not_member = new_NameOnlyClass( "9", 0 )

	Assert  arr.Search( arr(0), GetRef( "NameCompare" ), Empty, 0 ) = 0
	Assert  arr.Search( arr(0), GetRef( "NameCompare" ), Empty, 1 ) = 3
	Assert  IsSameArray( arr.Search( arr(3), GetRef( "NameCompare" ), Empty, Empty ), _
		Array( 0, 3 ) )
	Assert  IsEmpty( arr.Search( not_member, GetRef( "NameCompare" ), Empty, 0 ) )
	Assert  UBound( arr.Search( not_member, GetRef( "NameCompare" ), Empty, Empty ) ) = -1

	End If : section.End_


	'//----------------------------------------------------------
	If section.Start( "T_ArrayClass_Remove" ) Then

	Set arr = new_ArrayClass( Array( 0, 1, 2, 3, 4, 5, 6 ) )
	arr.Remove  1, 2
	Assert  IsSameArray( arr.Items, Array( 0, 3, 4, 5, 6 ) )

	Set arr = new_ArrayClass( Array( 0, 1, 2, 3, 4, 5, 6 ) )
	arr.Remove  0, 4
	Assert  IsSameArray( arr.Items, Array( 4, 5, 6 ) )

	Set arr = new_ArrayClass( Array( 0, 1, 2, 3, 4, 5, 6 ) )
	arr.Remove  5, 2
	Assert  IsSameArray( arr.Items, Array( 0, 1, 2, 3, 4 ) )

	End If : section.End_


	'//----------------------------------------------------------
	If section.Start( "T_ArrayClass_RemoveEmpty" ) Then

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

	End If : section.End_


	'//----------------------------------------------------------
	If section.Start( "T_ArrayClass_RemoveByIndexes" ) Then

	Set  an_array = new_ArrayClass( Array( "A", "B", "C", "D" ) )
	an_array.RemoveByIndexes  Array( 1, 3 )
	Assert  IsSameArray( an_array,  Array( "A", "C" ) )

	Set  an_array = new_ArrayClass( Array( "A", "B", "C", "D" ) )
	an_array.RemoveByIndexes  Array( 0, 1, 2, 3 )
	Assert  IsSameArray( an_array,  Array( ) )

	Set  an_array = new_ArrayClass( Array( ) )
	an_array.RemoveByIndexes  Array( )
	Assert  IsSameArray( an_array,  Array( ) )


	objects = Array( new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA(), _
		new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA(), new_ClassA() )
	option_.IsOutOfOrder = False
	Set option_.CompareFunction = GetRef( "StdCompare" )

	Set an_array = new_ArrayClass( Array( objects( 0 ), objects( 1 ), objects( 2 ), objects( 3 ) ) )
	an_array.RemoveByIndexes  Array( 1, 3 )
	Assert      IsSameArrayEx( an_array,  Array( objects( 0 ), objects( 2 ) ),  option_ )
	Assert  not IsSameArrayEx( an_array,  Array( objects( 1 ), objects( 2 ) ),  option_ )

	End If : section.End_


	'//----------------------------------------------------------
	If section.Start( "T_ArrayClass_CSV" ) Then

	a_CSV = new_ArrayClass( Array( 0, 1, 2 ) ).CSV
	Assert  a_CSV = "0,1,2"

	a_CSV = new_ArrayClass( Array( 1 ) ).CSV
	Assert  a_CSV = "1"

	a_CSV = new_ArrayClass( Array( ) ).CSV
	Assert  a_CSV = ""

	a_CSV = new_ArrayClass( Array( "A", "B" ) ).CSV
	Assert  a_CSV = "A,B"

	End If : section.End_


	'//----------------------------------------------------------
	If section.Start( "T_ArrayClass_Code" ) Then

	a_Code = new_ArrayClass( Array( "A", "B", "C" ) ).Code
	Assert  a_Code = """A"", _"+ vbCRLF +"""B"", _"+ vbCRLF +"""C"""

	a_Code = new_ArrayClass( Array( 0, 1, 2 ) ).Code
	Assert  a_Code = "0, _"+ vbCRLF +"1, _"+ vbCRLF +"2"

	a_Code = new_ArrayClass( Array( "A" ) ).Code
	Assert  a_Code = """A"""

	a_Code = new_ArrayClass( Array( ) ).Code
	Assert  a_Code = ""

	a_Code = new_ArrayClass( Array( """A" ) ).Code
	Assert  a_Code = """""""A"""

	End If : section.End_


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
	WScript.Echo  "1. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.016(sec)

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
	WScript.Echo  "2. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.152(sec)

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
	WScript.Echo  "3. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.043(sec)

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
	WScript.Echo  "4. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.055(sec)

	Assert  UBound( arr ) = n
	For i=0 To n : Assert arr( i ) = i : Next


	'//=== ArrayClass
	Set arrc = new ArrayClass
	t0 = Timer
	For i=0 To n
		arrc.Add  i
	Next
	t1 = Timer - t0
	WScript.Echo  "5. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.273(sec)

	Assert  UBound( arrc.Items ) = n
	For i=0 To n : Assert arrc.Items( i ) = i : Next


	'//=== ArrayFastClass
	Set arrc = new ArrayFastClass
	arrc.StartToAddFast
	t0 = Timer
	For i=0 To n
		arrc.AddFast  i
	Next
	arrc.EndToAddFast
	t1 = Timer - t0
	WScript.Echo  "6. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.133(sec)

	Assert  UBound( arrc.Items ) = n
	For i=0 To n : Assert arrc.Items( i ) = i : Next


	'//=== Dictionary
	Set arrc = CreateObject( "Scripting.Dictionary" )
	t0 = Timer
	For i=0 To n
		arrc.Add  i, Empty
	Next
	t1 = Timer - t0
	WScript.Echo  "7. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.215(sec)

	Assert  arrc.Count = n + 1
	i=0 : For Each  an_item  In  arrc.Keys  :  Assert  an_item = i  :  i=i+1  :  Next


	'//=== FastListATestClass
If False Then  '// This code raises exception
	Set arrc = new FastListATestClass
	t0 = Timer
	For i=0 To n
		arrc.AddNotObject  i
	Next
	t1 = Timer - t0
	WScript.Echo  "8. "+ FormatNumber( t1, 3 ) & "(sec)"  '// 0.387(sec)

	Assert  arrc.Count = n + 1
	i = n  :  Set element = arrc.First  :  Do Until  element is Nothing
		Assert element.Item = i
		Set element = element.Next_  :  i=i-1
	Loop
End If
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
		9,     Array( "a.a", "c.c", "b.b" ), Array( re_a, re_b ), Array( "c.c" ), _
		10,    Array( "5","1","2","3","4" ), Array( "5","3","4" ), Array( "1","2" ) ))

		arr = ArrayToNameOnlyClassArray( t("Array") )

		RemoveObjectsByNames  arr, t("Key")

		arr = NameOnlyClassArrayToArray( arr )
		Assert  IsSameArray( arr, t("Answer") )
	Next

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ReverseObjectArray] >>> 
'*************************************************************************
Sub  T_ReverseObjectArray( Opt, AppKey )
	Set object_a    = new NameOnlyClass : object_a.Name = "a"
	Set object_b    = new NameOnlyClass : object_b.Name = "b"
	Set object_c    = new NameOnlyClass : object_c.Name = "c"

	ReverseObjectArray  Array( object_a, object_b, object_c ), out_array
	Assert  IsSameArray( NameOnlyClassArrayToArray( out_array ),  Array( "c", "b", "a" ) )

	ReverseObjectArray  Array( object_a, object_b ), out_array
	Assert  IsSameArray( NameOnlyClassArrayToArray( out_array ),  Array( "b", "a" ) )

	ReverseObjectArray  Array( object_a ), out_array
	Assert  IsSameArray( NameOnlyClassArrayToArray( out_array ),  Array( "a" ) )

	ReverseObjectArray  Array( ), out_array
	Assert  IsSameArray( out_array,  Array( ) )

	Set a_array = new_ArrayClass( Array( object_a, object_b ) )
	ReverseObjectArray  a_array.Items,  a_array
	Assert  IsSameArray( NameOnlyClassArrayToArray( a_array ),  Array( "b", "a" ) )


	Reverse_COM_ObjectArray  new_ArrayClass( Array( object_a, object_b, object_c ) ), out_array
	Assert  IsSameArray( NameOnlyClassArrayToArray( out_array ),  Array( "c", "b", "a" ) )


	Pass
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [ArrayFastClass] Class >>>> 
'-------------------------------------------------------------------------
Class  ArrayFastClass
	Public   Items '// as array
	Private  Me_UBoundForFast   '// as Empty or integer
	Private Sub  Class_Initialize() : ReDim  Items( -1 ) : End Sub

	Public Sub  StartToAddFast()
		Me_UBoundForFast = UBound( Items )
	End Sub

	Public Sub  EndToAddFast()
		ReDim Preserve  Items( Me_UBoundForFast )
		Me_UBoundForFast = Empty
	End Sub

	Public Sub  AddFast( in_Element )
		If UBound(Items) <= Me_UBoundForFast Then _
			ReDim Preserve  Items( ( Me_UBoundForFast + 100 ) * 4 )
		Me_UBoundForFast = Me_UBoundForFast + 1

		Items( Me_UBoundForFast ) = in_Element
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [FastListATestClass] >>>> 
'-------------------------------------------------------------------------
Class  FastListATestClass
	Private  Me_First  '// as FastListElementTestClass

	Private Sub  Class_Initialize()
		Set Me_First = Nothing
	End Sub

	Public Property Get  First()
		Set First = Me_First
	End Property

	Public Property Get  Count()
		Set element = Me_First
		count = 0
		Do Until  element is Nothing
			Set element = element.Next_
			count = count + 1
		Loop
		Count = count
	End Property

	Public Sub  AddNotObject( in_AddingItem )
		Set element = new FastListElementTestClass
		element.Item = in_AddingItem
		Set element.Next_ = Me_First
		Set Me_First = element
	End Sub
End Class

Class  FastListElementTestClass
	Public  Item
	Public  Next_
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [FastListBTestClass] >>>> 
'-------------------------------------------------------------------------
Class  FastListBTestClass
	Private  Me_First  '// as FastListElementTestClass
	Private  Me_Last   '// as FastListElementTestClass

	Private Sub  Class_Initialize()
		Set Me_First = new FastListElementTestClass
		Set Me_Last = Me_First
		Set Me_Last.Next_ = Nothing
	End Sub

	Public Property Get  First()
		Set First = Me_First.Next
	End Property

	Public Property Get  Count()
		Set element = Me_First.Next
		count = 0
		Do Until  element is Nothing
			Set element = element.Next
			count = count + 1
		Loop
		Count = count
	End Property

	Public Sub  AddNotObject( in_AddingItem )
		Set element = new FastListElementTestClass
		If IsEmpty( Me_First ) Then
			Set Me_First = element
		Else
			Set Me_Last.Next_ = element
		End If
		element.Item = in_AddingItem
		Set Me_Last = element
		Set Me_Last.Next_ = Nothing
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

 
