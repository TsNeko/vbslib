Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1", "T_Dict",_
			"2", "T_DicAddObj",_
			"3", "T_DicAdd",_
			"4", "T_DicTable",_
			"5", "T_LookUpDicInArray",_
			"6", "T_DicArray",_
			"7", "T_DicArrayItem",_
			"8", "T_DicKeyToCSV",_
			"9", "T_GetDicItem",_
			"10","T_DicItemOfItem",_
			"11","T_IsSameDictionary",_
			"12","T_DictionaryClass",_
			"13","T_ObjectSetClass",_
			"14","T_LifeGroupClass",_
			"15","T_DestroyerClass" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_Dict] >>> 
'*************************************************************************
Sub  T_Dict( Opt, AppKey )
	Dim  dic

	EchoTestStart  "T_Dict"

	Set dic = Dict(Array( ))
	Assert  dic.Count = 0

	Set dic = Dict(Array( "Key1","Item1" ))
	Assert  dic.Count = 1
	Assert  dic.Item( "Key1" ) = "Item1"

	Set dic = Dict(Array( "Key1","Item1", "Key0" ))
	Assert  dic.Count = 1
	Assert  dic.Item( "Key1" ) = "Item1"
	Assert  not dic.Exists( "Key0" )

	Set dic = Dict(Array( "Key1","Item1", "Key2","Item2" ))
	Assert  dic.Count = 2
	Assert  dic.Item( "Key1" ) = "Item1"
	Assert  dic.Item( "Key2" ) = "Item2"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_DicAddObj] >>> 
'*************************************************************************
Sub  T_DicAddObj( Opt, AppKey )
	Dim  o, dic
	Set  dic = CreateObject( "Scripting.Dictionary" )

	EchoTestStart  "T_DicAddObj"


	g_Vers("CutPropertyM") = True

	Set o = Dic_addNewObject( dic, "ClassA", "ObjectA", True )
	o.Param = 1

	Set o = Dic_addNewObject( dic, "ClassA", "ObjectB", True )
	o.Param = 2

	Set o = Dic_addNewObject( dic, "ClassA", "ObjectA", True )
	o.Param = 3

	Assert  dic.Count = 2
	Assert  dic.Item( "ObjectA" ).Param = 3
	Assert  dic.Item( "ObjectB" ).Param = 2

	Dim  e  ' as Err2
	If TryStart(e) Then  On Error Resume Next
		Set o = Dic_addNewObject( dic, "ClassA", "ObjectA", False )
	If TryEnd Then  On Error GoTo 0
	Assert  e.num = E_AlreadyExist
	e.Clear

	Pass
End Sub
 
'*************************************************************************
'  <<< [T_DicAdd] >>> 
'*************************************************************************
Sub  T_DicAdd( Opt, AppKey )
	Dim  dic, obj1, obj2

	EchoTestStart  "T_DicAdd"

	g_Vers("CutPropertyM") = True

	Set  dic  = Dict(Array( "Key1","Item1", "Key2","Item2" ))
	Set  obj1 = new ClassA : obj1.Name="obj"
	Set  obj2 = new ClassA : obj2.Name="OBJ"


	'//=== Test of Dic_addElem

	Dic_addElem  dic, "Key3", "Item3"
	Assert  dic.Count = 3

	Dic_addElem  dic, "Key3", Empty
	Assert  dic.Count = 2

	Dic_addElem  dic, "Key2", "ITEMS"
	Assert  dic.Count = 2
	Assert  dic.Item( "Key2" ) = "ITEMS"

	Dic_addElem  dic, "Key2", obj1
	Assert  dic.Count = 2
	Assert  dic.Item( "Key2" ) is obj1

	Dic_addElem  dic, "Key2", "Item2"


	'//=== Test of Dic_add

	Dic_add  dic, Dict(Array( "Key2","ITEMS", "Key3","Item3" ))  '//[out] dic
	Assert  dic.Count = 3
	Assert  dic.Item( "Key1" ) = "Item1"
	Assert  dic.Item( "Key2" ) = "ITEMS"
	Assert  dic.Item( "Key3" ) = "Item3"

	Dic_add  dic, Dict(Array( "Key1",obj1, "Key2",obj2, "Key3",Empty, "Key4",Empty ))  '//[out] dic
	Assert  dic.Count = 2
	Assert  dic.Item( "Key1" ) is obj1
	Assert  dic.Item( "Key2" ) is obj2
	Assert  not dic.Exists( "Key3" )
	Assert  not dic.Exists( "Key4" )

	Dic_add  dic, Dict(Array( "Key1",obj2 ))  '//[out] dic
	Assert  dic.Count = 2
	Assert  dic.Item( "Key1" ) is obj2
	Assert  dic.Item( "Key2" ) is obj2

	Dic_add  dic, Dict(Array( "Key1","Item2", "Key1","Item2" ))  '//[out] dic

	dic = Empty
	Dic_add  dic, Dict(Array( "Key1","Item1", "Key2","Item2", "Key3",Empty ))  '//[out] dic
	Assert  dic.Count = 2
	Assert  dic.Item( "Key1" ) = "Item1"
	Assert  dic.Item( "Key2" ) = "Item2"


	'//=== test of Dic_sub

	Dic_sub  dic, _
		Dict(Array( "Key1","Item1", "Key2","ITEMS", "Key3","Item3" )), _
		Dict(Array( "Key1","Item1", "Key2","Item2", "Key4","Item4" )), Empty, Empty
		'//[out] dic
	Assert  dic.Count = 3
	Assert  dic.Item( "Key2" ) = "ITEMS"
	Assert  dic.Item( "Key3" ) = "Item3"
	Assert  IsEmpty( dic.Item( "Key4" ) )

	Dic_sub  dic, _
		Dict(Array( "Key1",obj1, "Key2",obj1, "Key3",obj1 )), _
		Dict(Array( "Key1",obj1, "Key2",obj2, "Key4",obj2 )), Empty, Empty
		'//[out] dic
	Assert  dic.Count = 3
	Assert  dic.Item( "Key2" ) is obj1
	Assert  dic.Item( "Key3" ) is obj1
	Assert  IsEmpty( dic.Item( "Key4" ) )

	Dic_sub  dic, _
		Dict(Array( "Key1",obj1, "Key2",obj1, "Key3",obj1 )), _
		Dict(Array( "Key1",obj1, "Key2",obj2, "Key4",obj2 )), GetRef("NameCompare"), 1
		'//[out] dic
	Assert  dic.Count = 2
	Assert  dic.Item( "Key3" ) is obj1
	Assert  IsEmpty( dic.Item( "Key4" ) )


	'//=== test of Dic_addPaths

	Set  dic  = Dict(Array( "C:\Folder\b.txt", 1, "C:\Folder\c.txt", 3 ))
	Dic_addPaths  dic, "C:\Folder", Array( "a.txt", "b.txt" ), 2
	Assert  dic.Count = 3
	Assert  dic( "C:\Folder\a.txt" ) = 2
	Assert  dic( "C:\Folder\b.txt" ) = 2
	Assert  dic( "C:\Folder\c.txt" ) = 3


	'//=== test of Dic_addElemOrError

	dic.RemoveAll
	Dic_addElemOrError  dic, "Key1", "Item1", "CollectionA"
	Dic_addElemOrError  dic, "Key2", "Item2", "CollectionA"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Dic_addElemOrError  dic, "Key2", "Item2", "CollectionA"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "Key2" ) >= 1
	Assert  InStr( e2.desc, "CollectionA" ) >= 1
	Assert  e2.num <> 0


	'//=== test of Dic_addUniqueKeyItem

	dic.RemoveAll
	Dic_addUniqueKeyItem  dic, "Key1", "Item1"
	Dic_addUniqueKeyItem  dic, "Key2", "Item2"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Dic_addUniqueKeyItem  dic, "Key2", "Item2"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "Key2" ) >= 1
	Assert  e2.num <> 0

	Pass
End Sub
 
'*************************************************************************
'  <<< [T_DicTable] >>> 
'*************************************************************************
Sub  T_DicTable( Opt, AppKey )
	Dim  t, table1, table2,  echo_ans


	'//=== Test of DicTable
	EchoTestStart  "T_DicTable"

	table1 = DicTable( Array( _
		"Item",  "Price",  "Number",   Empty, _
		"Book",     2000,         2, _
		"Pen",       100,        12, _
		"Eraser",     60,        10 ) )

	T_DicTable_check  table1

	echo_ans = _
		"<Dictionary count=""3"">{" +vbCRLF+_
		"  ""Item"" : ""Eraser""," +vbCRLF+_
		"  ""Price"" : 60," +vbCRLF+_
		"  ""Number"" : 10," +vbCRLF+_
		"}</Dictionary>"

	Set t = table1(2)
	Assert  GetEchoStr( t ) = echo_ans



	'//=== Test of DicTable : various value
	EchoTestStart  "T_DicTable_Various"
	Set  object = CreateObject( "Scripting.Dictionary" )

	table1 = DicTable( Array( _
		"String",  "Array",     "Object",   Empty, _
		"String1",  Array(1,2),  object, _
		"String2",  Array(2,3),  object ))

	Assert  table1(0)("String") = "String1"
	Assert  table1(0)("Array")(0)  = 1
	Assert  table1(0)("Array")(1)  = 2
	Assert  table1(0)("Object") Is object

	Assert  table1(1)("String") = "String2"
	Assert  table1(1)("Array")(0)  = 2
	Assert  table1(1)("Array")(1)  = 3
	Assert  table1(1)("Object") Is object



	'//=== Test of JoinDicTable
	EchoTestStart  "T_JoinDicTable_1"

	table1 = DicTable( Array( _
		"Item",  "Price",  Empty, _
		"Book",     2000, _
		"Pen",       100, _
		"Eraser",     60  ) )

	table2 = DicTable( Array( _
		"Item",  "Number",   Empty, _
		"Pen",         12, _
		"Book",         2, _
		"Eraser",      10 ) )

	table1 = JoinDicTable( table1, "Item", table2 )
	T_DicTable_check  table1



	'//=== test of JoinDicTable - outer join - table1 join table2
	EchoTestStart  "T_JoinDicTable_2A"

	table1 = DicTable( Array( _
		"Item",  "Price",  "Number",   Empty, _
		"Book",     2000,         2, _
		Empty,        71,        71 ) )

	table2 = DicTable( Array( _
		"Item",  "Price",  "Number",   Empty, _
		"Pen",       100,        12, _
		"Eraser",     60,        10, _
		Empty,        74,        74 ) )

	table1 = JoinDicTable( table1, "Item", table2 )
	T_DicTable_check  table1



	'//=== test of JoinDicTable - outer join - table1 join array data
	EchoTestStart  "T_JoinDicTable_2B"

	table1 = DicTable( Array( _
		"Item",  "Price",  "Number",   Empty, _
		"Book",     2000,         2, _
		Empty,        71,        71 ) )

	table1 = JoinDicTable( table1, "Item", Array( _
		"Item",  "Price",  "Number",   Empty, _
		"Pen",       100,        12, _
		"Eraser",     60,        10, _
		Empty,        74,        74 ))

	T_DicTable_check  table1

	Pass
End Sub


Sub  T_DicTable_check( table1 )
	Dim  t
	Assert  UBound( table1 ) = 2
	Set t = table1(0) :  Assert  t("Item") &" : "& t("Price") * t("Number") = "Book : 4000"
	Set t = table1(1) :  Assert  t("Item") &" : "& t("Price") * t("Number") = "Pen : 1200"
	Set t = table1(2) :  Assert  t("Item") &" : "& t("Price") * t("Number") = "Eraser : 600"
End Sub


 
'*************************************************************************
'  <<< [T_LookUpDicInArray] >>> 
'*************************************************************************
Sub  T_LookUpDicInArray( Opt, AppKey )
	Dim  dic1, dic2, arr

	Set  dic1 = CreateObject( "Scripting.Dictionary" )
	dic1.Item( "name" ) = "Item1"

	Set  dic2 = CreateObject( "Scripting.Dictionary" )
	dic2.Item( "name" ) = "Item2"

	Set arr = new_ArrayClass( Array( dic1, dic2 ) )

	Assert  arr.LookUpDic( "name", "Item1" ) Is dic1
	Assert  arr.LookUpDic( "name", "Item2" ) Is dic2
	Assert  arr.LookUpDic( "name", "Item0" ) Is Nothing

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_DicArray] >>> 
'*************************************************************************
Sub  T_DicArray( Opt, AppKey )
	Dim  dic, o1, o2

	Set dic = CreateObject( "Scripting.Dictionary" )

	Dic_addFromArray  dic, Array( "key1", "key2" ), True
	Assert  dic.Count = 2
	Assert  dic.Item( "key1" ) = True
	Assert  dic.Item( "key2" ) = True


	Set dic = CreateObject( "Scripting.Dictionary" )

	Dic_addFromArray  dic, Array( "key1", "key2" ), Array( 1, 2 )
	Assert  dic.Count = 2
	Assert  dic.Item( "key1" ) = 1
	Assert  dic.Item( "key2" ) = 2



	Set o1 = new ClassA
	Set o2 = new ClassA

	Set dic = CreateObject( "Scripting.Dictionary" )

	Dic_addFromArray  dic, Array( "key1", "key2" ), o1
	Assert  dic.Count = 2
	Assert  dic.Item( "key1" ) is o1
	Assert  dic.Item( "key2" ) is o1


	Set dic = CreateObject( "Scripting.Dictionary" )

	Dic_addFromArray  dic, Array( "key1", "key2" ), Array( o1, o2 )
	Assert  dic.Count = 2
	Assert  dic.Item( "key1" ) is o1
	Assert  dic.Item( "key2" ) is o2

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_DicArrayItem] >>> 
'*************************************************************************
Sub  T_DicArrayItem( Opt, AppKey )
	Set c = g_VBS_Lib

	'//===========================================================
	'// Block: T_DicArrayItem_1

	Set dic = CreateObject( "Scripting.Dictionary" )

	Dic_addInArrayItem  dic, "a", "A1"
	Assert  IsSameArray( dic("a"), Array( "A1" ) )

	Dic_addInArrayItem  dic, "a", "A2"
	Dic_addInArrayItem  dic, "a", "A2"
	Dic_addInArrayItem  dic, "a", "A3"
	Dic_addInArrayItem  dic, "a", "A3"
	Assert  IsSameArray( dic("a"), Array( "A1", "A2", "A2", "A3", "A3" ) )

	Dic_addInArrayItem  dic, "b", "B"
	Assert  IsSameArray( dic("b"), Array( "B" ) )

	Dic_removeInArrayItem  dic, "a", "A1", GetRef( "StdCompare" ), Empty, False, False
	Assert  IsSameArray( dic("a"), Array( "A2", "A2", "A3", "A3" ) )
	Dic_removeInArrayItem  dic, "a", "A2", GetRef( "StdCompare" ), Empty, False, False
	Assert  IsSameArray( dic("a"), Array( "A2", "A3", "A3" ) )
	Dic_removeInArrayItem  dic, "a", "A3", GetRef( "StdCompare" ), Empty, False, True
	Assert  IsSameArray( dic("a"), Array( "A2" ) )
	Dic_removeInArrayItem  dic, "a", "A2", GetRef( "StdCompare" ), Empty, False, True
	Assert  not dic.Exists("a")

	Dic_removeInArrayItem  dic, "b", "BadItem", GetRef( "StdCompare" ), Empty, False, True
	Assert  IsSameArray( dic("b"), Array( "B" ) )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Dic_removeInArrayItem  dic, "b", "BadItem", GetRef( "StdCompare" ), Empty, True, True

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_NotFoundSymbol


	Dic_removeInArrayItem  dic, "a", "BadKey", GetRef( "StdCompare" ), Empty, False, False

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Dic_removeInArrayItem  dic, "a", "BadKey", GetRef( "StdCompare" ), Empty, True, False

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_NotFoundSymbol


	Set object_A1 = new_NameOnlyClass( "object_A1", Empty )
	Set object_A2 = new_NameOnlyClass( "object_A2", Empty )
	Set object_A3 = new_NameOnlyClass( "object_A3", Empty )
	Set object_B  = new_NameOnlyClass( "object_B",  Empty )

	Dic_addInArrayItem  dic, "oA", object_A1
	Assert  dic("oA")(0) is object_A1
	Dic_addInArrayItem  dic, "oA", object_A2
	Assert  dic("oA")(1) is object_A2
	Dic_addInArrayItem  dic, "oA", object_A2
	Assert  dic("oA")(2) is object_A2
	Dic_addInArrayItem  dic, "oA", object_A3
	Assert  dic("oA")(3) is object_A3
	Dic_addInArrayItem  dic, "oA", object_A3
	Assert  dic("oA")(4) is object_A3
	Dic_addInArrayItem  dic, "oB", object_B
	Assert  dic("oB")(0) is object_B

	Dic_removeInArrayItem  dic, "oA", object_A1, GetRef( "StdCompare" ), Empty, False, False
	Dic_removeInArrayItem  dic, "oA", object_A2, GetRef( "StdCompare" ), Empty, False, False
	Dic_removeInArrayItem  dic, "oA", object_A3, GetRef( "StdCompare" ), Empty, False, True
	Assert  dic("oA")(0) is object_A2
	Dic_removeInArrayItem  dic, "oA", new_NameOnlyClass( "object_A2", Empty ), _
		GetRef( "NameCompare" ), Empty, False, False
	Assert  not dic.Exists("oA")


	'//===========================================================
	'// Block: Dic_searchInArrayItem

	Set dic = Dict( Array( "KeyA", new_ArrayClass( Array( "ItemA", "ItemB" ) ) ) )
	indexes = Dic_searchInArrayItem( dic, "KeyA", "itema", GetRef( "StdCompare" ), 1 )
	Assert  IsSameArray( indexes, Array( 0 ) )

	indexes = Dic_searchInArrayItem( dic, "KeyA", "itema", GetRef( "StdCompare" ), 0 )
	Assert  IsSameArray( indexes, Array( ) )

	indexes = Dic_searchInArrayItem( dic, "KeyB", "itema", GetRef( "StdCompare" ), 1 )
	Assert  IsSameArray( indexes, Array( ) )


	'//===========================================================
	'// Block: Dic_getCountInArrayItem

	Set dic = Dict( Array( "KeyA", new_ArrayClass( Array( "ItemA", "ItemB" ) ), _
		"KeyB", new_ArrayClass( Array( "ItemA" ) ) ) )
	Assert  Dic_getCountInArrayItem( dic ) = 3

	Set dic = Dict( Array( ) )
	Assert  Dic_getCountInArrayItem( dic ) = 0


	'//===========================================================
	'// Block: Dic_addExInArrayItem

	For Each  t  In DicTable( Array( _
		"AddingOption",  "ComparingOption",  "is_itema_",  "is_ItemA",  Empty, _
		c.ReplaceIfExist,  1,                True,         False, _
		c.IgnoreIfExist,   1,                False,        True, _
		c.AddAlways,       1,                True,         True, _
		c.ReplaceIfExist,  0,                True,         True, _
		c.IgnoreIfExist,   0,                True,         True ) )


		'// Set up
		Set dic = Dict( Array( "KeyA", new_ArrayClass( Array( "ItemA", "ItemB" ) ), _
			"KeyB", new_ArrayClass( Array( "ItemA" ) ) ) )

		'// Test Main
		Dic_addExInArrayItem  dic, "KeyA", "itema", GetRef( "StdCompare" ), t("ComparingOption"), _
			t("AddingOption")

		'// Check
		is_itema_= False
		is_ItemA = False
		For Each  an_item  In  dic( "KeyA" ).Items
			If an_item = "itema" Then _
				is_itema_= True
			If an_item = "ItemA" Then _
				is_ItemA = True
		Next
		Assert  is_itema_ = t("is_itema_")
		Assert  is_ItemA  = t("is_ItemA")
	Next


	'// Set up
	Set dic = Dict( Array( "KeyA", new_ArrayClass( Array( "ItemA", "ItemB" ) ), _
		"KeyB", new_ArrayClass( Array( "ItemA" ) ) ) )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Dic_addExInArrayItem  dic, "KeyA", "itema", GetRef( "StdCompare" ), 1, 0

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0


	'// Set up
	Set dic = Dict( Array( "KeyA", new_ArrayClass( Array( "ItemA", "ItemB" ) ), _
		"KeyB", new_ArrayClass( Array( "ItemA" ) ) ) )

	'// Test Main
	Dic_addExInArrayItem  dic, "KeyC", "itema", GetRef( "StdCompare" ), 1, c.IgnoreIfExist

	'// Check
	Assert  dic( "KeyC" )( 0 ) = "itema"

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_DicKeyToCSV] >>> 
'*************************************************************************
Sub  T_DicKeyToCSV( Opt, AppKey )
	Dim dic : Set  dic = CreateObject( "Scripting.Dictionary" )
	dic.Item( "Key1" ) = "Item1"
	dic.Item( "Key2" ) = "Item2"
	Assert  DicKeyToCSV( dic ) = "Key1,Key2"

	Pass
End Sub



 
'*************************************************************************
'  <<< [T_GetDicItem] >>> 
'*************************************************************************
Sub  T_GetDicItem( Opt, AppKey )
	Dim  dic, item, arr

	'//=== Test of DicItem
	Set dic = CreateObject( "Scripting.Dictionary" )
	Assert  IsEmpty( DicItem( dic, "not_used_key" ) )
	Assert  not dic.Exists( "not_used_key" )

	'//=== Test of GetDicItem
	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.Item( "key1" ) = 1
	Set dic.Item( "self" ) = dic
	GetDicItem  dic, "key1", item  '// Set "item"
	Assert  item = 1
	GetDicItem  dic, "self", item  '// Set "item"
	Assert  item is dic
	GetDicItem  dic, "not_used_key", item  '// Set "item"
	Assert  IsEmpty( item )
	Assert  not dic.Exists( "not_used_key" )

	'//=== Test of GetDicItemOrError
	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.Item( "key1" ) = 1
	Set dic.Item( "self" ) = dic
	GetDicItemOrError  dic, "key1", item, "DictionaryA"  '// Set "item"
	Assert  item = 1
	GetDicItemOrError  dic, "self", item, "DictionaryA"  '// Set "item"
	Assert  item is dic

	'// Error Handling Test
	item = Empty
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		GetDicItemOrError  dic, "not_used_key", item, "DictionaryA"  '// Set "item"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "not_used_key" ) >= 1
	Assert  InStr( e2.desc, "DictionaryA" ) >= 1
	Assert  e2.num <> 0

	Assert  IsEmpty( item )
	Assert  not dic.Exists( "not_used_key" )


	'//=== Test of GetDicItemAsArrayClass
	Set dic = CreateObject( "Scripting.Dictionary" )
	Set arr = GetDicItemAsArrayClass( dic, "key1" )
	arr.Add  4
	Assert  TypeName( arr ) = "ArrayClass"
	Assert  GetDicItemAsArrayClass( dic, "key1" ) is arr
	Set arr = GetDicItemAsArrayClass( dic, "key2" )
	Assert  TypeName( arr ) = "ArrayClass"
	Assert  arr.Count = 0
	Set arr = GetDicItemAsArrayClass( dic, "key1" )
	Assert  arr(0) = 4

	'//=== Test of GetDicItemByIndex
	Set dic = CreateObject( "Scripting.Dictionary" )
	dic( "key3" ) = 3
	dic( "key2" ) = 2
	dic( "key1" ) = 1
	GetDicItemByIndex  dic, 0, a_item : Assert  a_item = 3
	GetDicItemByIndex  dic, 1, a_item : Assert  a_item = 2
	GetDicItemByIndex  dic, 2, a_item : Assert  a_item = 1
	GetDicItemByIndex  dic, 3, a_item : Assert  IsEmpty( a_item )
	GetDicItemByIndex  dic,-1, a_item : Assert  IsEmpty( a_item )

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_DicItemOfItem] >>> 
'*************************************************************************
Sub  T_DicItemOfItem( Opt, AppKey )
	Dim  e, e2, dic

	Set  dic = CreateObject( "Scripting.Dictionary" )
	dic.Item( "Key1" ) = "$Key2"
	dic.Item( "Key2" ) = "Item2"
	dic.Item( "Key3" ) = "${Key2}"
	dic.Item( "Key4" ) = "%Key2%"
	Set dic.Item( "Key5" ) = dic

	Assert  DicItemOfItem( dic, "Key1" ) = "Item2"
	Assert  DicItemOfItem( dic, "Key2" ) = "Item2"
	Assert  DicItemOfItem( dic, "Key3" ) = "Item2"
	Assert  DicItemOfItem( dic, "Key4" ) = "Item2"
	Assert  DicItemOfItem( dic, "Key5" ) Is dic


	dic.Item( "Key6" ) = "$Unknown"

	If TryStart(e) Then  On Error Resume Next

		DicItemOfItem  dic, "Key6"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    "Next is Error Test"
	echo    e2.desc
	Assert  e2.num = E_NotFoundSymbol


	dic.Item( "Mutual" ) = "$Mutual2"
	dic.Item( "Mutual2" ) = "$Mutual"

	If TryStart(e) Then  On Error Resume Next

		DicItemOfItem  dic, "Mutual"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    "Next is Error Test"
	echo    e2.desc
	Assert  InStr( e2.desc, "循環参照しています" ) > 0

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_IsSameDictionary] >>> 
'*************************************************************************
Sub  T_IsSameDictionary( Opt, AppKey )
	Set c = g_VBS_Lib

	Assert  IsSameDictionary(_
		Dict(Array( "A", "1", "B", "2" )),_
		Dict(Array( "B", "2", "A", "1" )), Empty )

	Assert  not IsSameDictionary(_
		Dict(Array( "A", "1", "B", "2" )),_
		Dict(Array( "B", "2", "A", "2")), Empty )

	Assert  not IsSameDictionary(_
		Dict(Array( "A", "1", "B", "2", "C", "2" )),_
		Dict(Array( "B", "2", "A", "1")), Empty )

	Assert  IsSameDictionary(_
		Dict(Array( "A", "1", "B", "2", "C", "2" )),_
		Dict(Array( "B", "2", "A", "1" )), c.CompareOnlyExistB )

	Assert  not IsSameDictionary(_
		Dict(Array( )),_
		Dict(Array( "A", "1" )), Empty )

	Assert  not IsSameDictionary(_
		Dict(Array( "A", "1" )),_
		Dict(Array( )), Empty )

	Assert  IsSameDictionary(_
		Dict(Array( )),_
		Dict(Array( )), Empty )

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_DictionaryClass] >>> 
'*************************************************************************
Sub  T_DictionaryClass( Opt, AppKey )

	Set dic0 = CreateObject( "Scripting.Dictionary" )
	Set dic1 = new DictionaryClass
	Const  NotCaseSensitive = 1


	'//==== Test of .Item as default property

	'// Test Main
	dic1("Key1") = "A"
	dic1.Item("Key2") = "B"
	Set dic1("Key3") = dic0

	'// Check
	Assert  dic1.Item( "Key1" ) = "A"
	Assert  dic1( "Key2" ) = "B"
	Assert  dic1("Key3") is dic0

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		echo  dic1( "Key0" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = 9



	'//==== Test of .Add

	'// Test Main
	dic1.Add  "number", 1
	dic1.Add  "object", dic0

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		dic1.Add  "number", 1

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = 457

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		dic1.Add  "object", dic0

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = 457



	'//==== Test of .Keys, .Items, .Count, .RemoveAll

	'// Test Main
	dic1( "ForRemove"  ) = 1
	dic1( "ForRemove2" ) = 2
	dic1.RemoveAll

	'// Check
	Assert  dic1.Count = 0

	For Each key  In dic1.Keys
		Error
	Next

	For Each item  In dic1.Items
		Error
	Next


	'// Test Main
	dic1("Key1") = "A"

	'// Check
	Assert  dic1.Count = 1

	For Each key  In dic1.Keys
		Assert  key = "Key1"
	Next

	For Each item  In dic1.Items
		Assert  item = "A"
	Next


	'// Test Main
	dic1("Key1") = "AA"
	dic1("Key2") = "B"

	'// Check
	Assert  dic1.Count = 2

	answer = Array( "Key1", "Key2" )
	i = 0
	For Each key  In dic1.Keys
		Assert  key = answer(i)
		i = i + 1
	Next

	answer = Array( "AA", "B" )
	i = 0
	For Each item  In dic1.Items
		Assert  item = answer(i)
		i = i + 1
	Next



	'//==== Test of .Exists, .CompareMode

	'// Set up
	Set dic1 = new DictionaryClass
	dic1( "Sample" ) = "A"

	'// Test Main
	Assert      dic1.Exists( "Sample" )
	Assert not  dic1.Exists( "Sample1" )
	Assert not  dic1.Exists( "Sampl" )
	Assert not  dic1.Exists( "" )

	Assert  dic1.CompareMode = 0  '// Default .CompareMode
	Assert not  dic1.Exists( "sample" )

	Set dic1 = new DictionaryClass
	dic1.CompareMode = NotCaseSensitive
	dic1( "Sample" ) = "A"
	Assert      dic1.Exists( "sample" )


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		dic1.CompareMode = 0

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = 5



	'//==== Test of .Remove

	'// Set up
	Set dic1 = new DictionaryClass
	dic1( "Sample1" ) = "A"
	dic1( "Sample2" ) = "B"

	'// Test Main
	dic1.Remove  "Sample1"

	'// Check
	Assert  dic1.Count = 1

	For Each key  In dic1.Keys
		Assert  key = "Sample2"
	Next

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		dic1.Remove  "NotExist"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = CLng("&h802B")


	Pass
End Sub


 
'*************************************************************************
'  <<< [T_ObjectSetClass] >>> 
'*************************************************************************
Sub  T_ObjectSetClass( Opt, AppKey )
	Set  objects = new ObjectSetClass
	Set  a_object = new ClassA
	Set  b_object = new ClassA
	Set  c_object = new ClassA

	objects.Add  a_object
	objects.Add  b_object
	objects.Add  b_object

	Assert  objects.Count = 2

	objects.Remove  b_object

	Assert  objects.Count = 1
	Assert  objects.Exists( a_object )
	Assert  not objects.Exists( b_object )
	For Each object  In objects.Items
		object.Name = "1"
	Next
	Assert  a_object.Name = "1"
	Assert  IsEmpty( b_object.Name )
	a_object.Name = Empty


	objects.Add  b_object
	Assert  objects.Exists( a_object )
	Assert  objects.Exists( b_object )
	For Each object  In objects.Items
		object.Name = "1"
	Next
	Assert  a_object.Name = "1"
	Assert  b_object.Name = "1"
	a_object.Name = Empty
	b_object.Name = Empty


	objects.Add  c_object
	Assert  objects.Exists( a_object )
	Assert  objects.Exists( b_object )
	Assert  objects.Exists( c_object )
	For Each object  In objects.Items
		object.Name = "1"
	Next
	Assert  a_object.Name = "1"
	Assert  b_object.Name = "1"
	Assert  c_object.Name = "1"
	a_object.Name = Empty
	b_object.Name = Empty
	c_object.Name = Empty


	objects.RemoveAll

	Assert  objects.Count = 0
	Assert  not objects.Exists( a_object )
	Assert  not objects.Exists( b_object )

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_LifeGroupClass] >>> 
'*************************************************************************
Sub  T_LifeGroupClass( Opt, AppKey )

	g_LogString = ""
	T_LifeGroupClass_CaseA
	Assert  g_LogString = _
		"A1.Terminate"+ vbCRLF +_
		"A2.Terminate"+ vbCRLF

	g_LogString = ""
	Set object = T_LifeGroupClass_CaseB()
	g_LogString = g_LogString + "Return"+ vbCRLF
	object = Empty
	Assert  g_LogString = _
		"Return"+ vbCRLF +_
		"B1.Terminate"+ vbCRLF +_
		"B2.Terminate"+ vbCRLF

	g_LogString = ""
	Set object = T_LifeGroupClass_CaseC()
	g_LogString = g_LogString + "Return"+ vbCRLF
	object = Empty
	Assert  g_LogString = _
		"C1.Terminate"+ vbCRLF +_
		"C2.Terminate"+ vbCRLF +_
		"Return"+ vbCRLF +_
		"C3.Terminate"+ vbCRLF

	g_LogString = ""
	Set object = T_LifeGroupClass_CaseD()
	g_LogString = g_LogString + "Return"+ vbCRLF
	object = Empty
	Assert  g_LogString = _
		"Return"+ vbCRLF +_
		"D2.Terminate"+ vbCRLF +_
		"D1.Terminate"+ vbCRLF

	g_LogString = ""
	T_LifeGroupClass_CaseE()
	Assert  g_LogString = _
		"E1.Terminate"+ vbCRLF +_
		"E2.Terminate"+ vbCRLF

	g_LogString = ""
	T_LifeGroupClass_CaseF
	Assert  g_LogString = _
		"F1.Terminate"+ vbCRLF +_
		"F2.Terminate"+ vbCRLF +_
		"Empty"+ vbCRLF +_
		"F1.Terminate"+ vbCRLF +_
		"F2.Terminate"+ vbCRLF +_
		"Empty"+ vbCRLF

	Pass
End Sub


Sub  T_LifeGroupClass_CaseA()  '// 相互参照しているオブジェクトの削除
	Set a_handle = new GroupRootClass        : a_handle.p.Name = "A1"
	Set b_handle = a_handle.p.CreateMember() : b_handle.p.Name = "A2"
	Set a_handle.p.Reference = b_handle.p
	Set b_handle.p.Reference = a_handle.p
End Sub

Function  T_LifeGroupClass_CaseB()  '// ハンドルを返すとき
	Set a_handle = new GroupRootClass        : a_handle.p.Name = "B1"
	Set b_handle = a_handle.p.CreateMember() : b_handle.p.Name = "B2"
	Set a_handle.p.Reference = b_handle.p
	Set b_handle.p.Reference = a_handle.p
	Set T_LifeGroupClass_CaseB = b_handle
End Function

Function  T_LifeGroupClass_CaseC()  '// LefeGroup から外れるとき
	Set a_handle = new GroupRootClass        : a_handle.p.Name = "C1"
	Set b_handle = a_handle.p.CreateMember() : b_handle.p.Name = "C2"
	Set c_handle = a_handle.p.CreateMember() : c_handle.p.Name = "C3"
	a_handle.p.LifeGroup.Group.Remove  c_handle.p
	Set a_handle.p.Reference = b_handle.p
	Set b_handle.p.Reference = a_handle.p
	Set T_LifeGroupClass_CaseC = c_handle
End Function

Function  T_LifeGroupClass_CaseD()  '// ハンドルを複製するとき
	Set a_handle = new GroupRootClass        : a_handle.p.Name = "D1"
	Set b_handle = a_handle.p.CreateMember() : b_handle.p.Name = "D2"
	Set a_handle.p.Reference = b_handle.p
	Set b_handle.p.Reference = a_handle.p
	Set T_LifeGroupClass_CaseD = b_handle.p.GetReference()
End Function

Sub  T_LifeGroupClass_CaseE()  '// 所属オブジェクトの参照カウンターが 0 から 1 に戻るとき
	Set a_handle = new GroupRootClass        : a_handle.p.Name = "E1"
	Set b_handle = a_handle.p.CreateMember() : b_handle.p.Name = "E2"
	Set a_handle.p.Reference = b_handle.p
	Set b_handle.p.Reference = a_handle.p
	b_handle = Empty
	Set b_handle = a_handle.p.GetReference()
End Sub

Sub  T_LifeGroupClass_CaseF()  '// LefeGroup を再利用するとき
	For count = 1  To 2
		Set a_handle = new GroupRootClass        : a_handle.p.Name = "F1"
		Set b_handle = a_handle.p.CreateMember() : b_handle.p.Name = "F2"
		Set a_handle.p.Reference = b_handle.p
		Set b_handle.p.Reference = a_handle.p

		a_handle = Empty
		b_handle = Empty
		g_LogString = g_LogString + "Empty"+ vbCRLF
	Next
End Sub


 
'*************************************************************************
'  <<< [T_DestroyerClass] >>> 
'*************************************************************************
Sub  T_DestroyerClass( Opt, AppKey )

	g_LogString = ""
	T_DestroyerClass_Case1
	Assert  g_LogString = _
		"a.Terminate"+ vbCRLF +_
		"b.Terminate"+ vbCRLF


	g_LogString = ""
	T_DestroyerClass_Case2
	Assert  g_LogString = _
		"a.Terminate"+ vbCRLF +_
		"b.Terminate"+ vbCRLF +_
		"c.Terminate"+ vbCRLF


	g_LogString = ""
	T_DestroyerClass_Case3
	Assert  g_LogString = _
		"c.Terminate"+ vbCRLF +_
		"a.Terminate"+ vbCRLF +_
		"b.Terminate"+ vbCRLF


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		T_DestroyerClass_CaseError

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "DestroyerClass" ) > 0
	Assert  e2.num <> 0


	g_LogString = ""
	T_DestroyerClass_CaseLast
	Assert  g_LogString = ""


	Pass
End Sub


Sub  T_DestroyerClass_Case1()
	Set destroyer = new DestroyerClass
	Set a_object = new MutualClass : a_object.Name = "a" : destroyer.Add  a_object
	Set b_object = new MutualClass : b_object.Name = "b" : destroyer.Add  b_object
	Set a_object.Reference = b_object
	Set b_object.Reference = a_object
End Sub


Sub  T_DestroyerClass_Case2()
	Set destroyer = new DestroyerClass
	Set a_object = new MutualClass : a_object.Name = "a" : destroyer.Add  a_object
	Set b_object = new MutualClass : b_object.Name = "b" : destroyer.Add  b_object
	Set c_object = new MutualClass : c_object.Name = "c" : destroyer.Add  c_object
	Set a_object.Reference = b_object
	Set b_object.Reference = c_object
	Set c_object.Reference = a_object
End Sub


Sub  T_DestroyerClass_Case3()
	Set destroyer = new DestroyerClass
	Set a_object = new MutualClass : a_object.Name = "a" : destroyer.Add  a_object
	Set b_object = new MutualClass : b_object.Name = "b" : destroyer.Add  b_object
	Set c_object = new MutualClass : c_object.Name = "c" : destroyer.Add  c_object
	Set a_object.Reference = b_object
	Set b_object.Reference = b_object
	destroyer.Remove  c_object
	c_object.IsDestroyer = True
	c_object = Empty
End Sub


Sub  T_DestroyerClass_CaseError()
	Set a_object = new MutualClass : a_object.Name = "a"
	a_object = Empty
End Sub


Sub  T_DestroyerClass_CaseLast()
	Set a_object = new MutualClass : a_object.Name = "a"
	Set b_object = new MutualClass : b_object.Name = "b"
	Set a_object.Reference = b_object
	Set b_object.Reference = a_object
	a_object.IsDestroyer = True
	b_object.IsDestroyer = True
End Sub


Class  MutualClass
	Public  Name
	Public  Reference
	Public  IsDestroyer

	Private Sub  Class_Terminate()
		g_LogString = g_LogString + Me.Name +".Terminate"+ vbCRLF
		CheckUnderDestroyer  Me
	End Sub

	Public Sub  DestroyReferences()
		Me.Reference = Empty
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [ClassA] Class >>>> 
'-------------------------------------------------------------------------
Class  ClassA
	Public  Name
	Public  Param
End Class

Function  new_ClassA() : Set new_ClassA = new ClassA : End Function


 
'-------------------------------------------------------------------------
' ### <<<< [GroupRootClass] >>>> 
'-------------------------------------------------------------------------
Class  GroupRootClass
	Public  p  '// Target object of this handle

	Private Sub  Class_Initialize()
		Set group = new LifeGroupClass
		group.AddHandle  Me, new GroupRootBodyClass
	End Sub

	Private Sub  Class_Terminate()
		If not IsEmpty( Me.p.LifeGroup.Group ) Then _
			Me.p.LifeGroup.Group.AddTerminated  Me.p
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [GroupRootBodyClass] >>>> 
'-------------------------------------------------------------------------
Class  GroupRootBodyClass
	Public  Name
	Public  Reference

	Public  LifeGroup  '// Don't write except for LifeGroupClass

	Public Sub  DestroyReferences()
		Me.Reference = Empty
	End Sub

	Private Sub  Class_Terminate()
		g_LogString = g_LogString + Me.Name +".Terminate"+ vbCRLF
	End Sub

	Function  CreateMember()
		Set CreateMember = Me.LifeGroup.Group.Add( new GroupMemberClass )
	End Function

	Function  GetReference()
		Set GetReference = Me.LifeGroup.Group.Add( Me.Reference )
	End Function
End Class


'-------------------------------------------------------------------------
' ### <<<< [GroupMemberClass] >>>> 
'-------------------------------------------------------------------------
Class  GroupMemberClass
	Public  Name
	Public  Reference

	Public  LifeGroup  '// Don't write except for LifeGroupClass

	Public Sub  DestroyReferences()
		Me.Reference = Empty
	End Sub

	Private Sub  Class_Terminate()
		g_LogString = g_LogString + Me.Name +".Terminate"+ vbCRLF
	End Sub

	Function  GetReference()
		Set GetReference = Me.LifeGroup.Group.Add( Me.Reference )
	End Function
End Class


Dim  g_LogString


 







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

 
