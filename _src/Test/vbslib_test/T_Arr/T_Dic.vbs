Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1", "T_Dict",_
			"2", "T_DicAddObj",_
			"3", "T_DicAdd",_
			"4", "T_DicTable",_
			"5", "T_LookUpDicInArray",_
			"6", "T_DicArray",_
			"7", "T_DicKeyToCSV",_
			"8", "T_GetDicItem",_
			"9", "T_DicItemOfItem",_
			"10","T_IsSameDictionary",_
			"11","T_DictionaryClass" ))
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


	'//=== test of Dic_addElem

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


	'//=== test of Dic_add

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
	GetDicItem  dic, "key1", item  '//[out] item
	Assert  item = 1
	GetDicItem  dic, "self", item  '//[out] item
	Assert  item is dic
	GetDicItem  dic, "not_used_key", item  '//[out] item
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


 
'-------------------------------------------------------------------------
' ### <<<< [ClassA] Class >>>> 
'-------------------------------------------------------------------------
Class  ClassA
	Public  Name
	Public  Param
End Class

Function  new_ClassA() : Set new_ClassA = new ClassA : End Function


 







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

 
