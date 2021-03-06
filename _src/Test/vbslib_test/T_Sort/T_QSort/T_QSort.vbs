Sub  Main( Opt, AppKey )
	Dim  TestName, TestParamPath, f, n
	Dim  section : Set section = new SectionTree

'//SetStartSectionTree  "T_NumStringCompare"


	If section.Start( "T_QSort2A" ) Then

		n = 1
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 1
		Set arr(1) = new ClassA : arr(1).id = 2

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort2B" ) Then

		n = 1
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 2
		Set arr(1) = new ClassA : arr(1).id = 1

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort2N" ) Then

		n = 1
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = Null
		Set arr(1) = new ClassA : arr(1).id = Null


		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  InStr( e2.desc, "Null" ) > 0
		Assert  e2.num = 1

	End If : section.End_


	If section.Start( "T_QSort9" ) Then

		n = 8
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 1000
		Set arr(1) = new ClassA : arr(1).id = 500
		Set arr(2) = new ClassA : arr(2).id = 1000
		Set arr(3) = new ClassA : arr(3).id = 1000
		Set arr(4) = new ClassA : arr(4).id = 1000
		Set arr(5) = new ClassA : arr(5).id = 1000
		Set arr(6) = new ClassA : arr(6).id = 1000
		Set arr(7) = new ClassA : arr(7).id = 1000
		Set arr(8) = new ClassA : arr(8).id = 1000

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort34" ) Then

		n = 33
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 10
		Set arr(1) = new ClassA : arr(1).id = 4
		Set arr(2) = new ClassA : arr(2).id = 5
		Set arr(3) = new ClassA : arr(3).id = 6
		Set arr(4) = new ClassA : arr(4).id = 10
		Set arr(5) = new ClassA : arr(5).id = 10
		Set arr(6) = new ClassA : arr(6).id = 10
		Set arr(7) = new ClassA : arr(7).id = 10
		Set arr(8) = new ClassA : arr(8).id = 10
		Set arr(9) = new ClassA : arr(9).id = 10
		Set arr(10)= new ClassA :arr(10).id = 10
		Set arr(11)= new ClassA :arr(11).id = 10
		Set arr(12)= new ClassA :arr(12).id = 10
		Set arr(13)= new ClassA :arr(13).id = 10
		Set arr(14)= new ClassA :arr(14).id = 9
		Set arr(15)= new ClassA :arr(15).id = 9
		Set arr(16)= new ClassA :arr(16).id = 10
		Set arr(17)= new ClassA :arr(17).id = 10
		Set arr(18)= new ClassA :arr(18).id = 10
		Set arr(19)= new ClassA :arr(19).id = 10
		Set arr(20)= new ClassA :arr(20).id = 7
		Set arr(21)= new ClassA :arr(21).id = 10
		Set arr(22)= new ClassA :arr(22).id = 10
		Set arr(23)= new ClassA :arr(23).id = 8
		Set arr(24)= new ClassA :arr(24).id = 9
		Set arr(25)= new ClassA :arr(25).id = 10
		Set arr(26)= new ClassA :arr(26).id = 10
		Set arr(27)= new ClassA :arr(27).id = 9
		Set arr(28)= new ClassA :arr(28).id = 8
		Set arr(29)= new ClassA :arr(29).id = 10
		Set arr(30)= new ClassA :arr(30).id = 11
		Set arr(31)= new ClassA :arr(31).id = 10
		Set arr(32)= new ClassA :arr(32).id = 10
		Set arr(33)= new ClassA :arr(33).id = 10

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort12" ) Then

		n = 11
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 1000
		Set arr(1) = new ClassA : arr(1).id = 400
		Set arr(2) = new ClassA : arr(2).id = 500
		Set arr(3) = new ClassA : arr(3).id = 1000
		Set arr(4) = new ClassA : arr(4).id = 1000
		Set arr(5) = new ClassA : arr(5).id = 1000
		Set arr(6) = new ClassA : arr(6).id = 1000
		Set arr(7) = new ClassA : arr(7).id = 1000
		Set arr(8) = new ClassA : arr(8).id = 1000
		Set arr(9) = new ClassA : arr(9).id = 1000
		Set arr(10)= new ClassA :arr(10).id = 1000
		Set arr(11)= new ClassA :arr(11).id = 1000

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort16" ) Then

		n = 15
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 400
		Set arr(1) = new ClassA : arr(1).id = 500
		Set arr(2) = new ClassA : arr(2).id = 1000
		Set arr(3) = new ClassA : arr(3).id = 1000
		Set arr(4) = new ClassA : arr(4).id = 1000
		Set arr(5) = new ClassA : arr(5).id = 1000
		Set arr(6) = new ClassA : arr(6).id = 1000
		Set arr(7) = new ClassA : arr(7).id = 1000
		Set arr(8) = new ClassA : arr(8).id = 1000
		Set arr(9) = new ClassA : arr(9).id = 100
		Set arr(10)= new ClassA :arr(10).id = 200
		Set arr(11)= new ClassA :arr(11).id = 300
		Set arr(12)= new ClassA :arr(12).id = 400
		Set arr(13)= new ClassA :arr(13).id = 500
		Set arr(14)= new ClassA :arr(14).id = 600
		Set arr(15)= new ClassA :arr(15).id = 700

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort16a" ) Then

		n = 15
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = n-0
		Set arr(1) = new ClassA : arr(1).id = n-1
		Set arr(2) = new ClassA : arr(2).id = n-2
		Set arr(3) = new ClassA : arr(3).id = n-3
		Set arr(4) = new ClassA : arr(4).id = n-4
		Set arr(5) = new ClassA : arr(5).id = n-5
		Set arr(6) = new ClassA : arr(6).id = n-6
		Set arr(7) = new ClassA : arr(7).id = n-7
		Set arr(8) = new ClassA : arr(8).id = n-8
		Set arr(9) = new ClassA : arr(9).id = n-9
		Set arr(10)= new ClassA :arr(10).id = n-10
		Set arr(11)= new ClassA :arr(11).id = n-11
		Set arr(12)= new ClassA :arr(12).id = n-12
		Set arr(13)= new ClassA :arr(13).id = n-13
		Set arr(14)= new ClassA :arr(14).id = n-14
		Set arr(15)= new ClassA :arr(15).id = n-15

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort5" ) Then

		n = 4
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 400
		Set arr(1) = new ClassA : arr(1).id = 100
		Set arr(2) = new ClassA : arr(2).id = 200
		Set arr(3) = new ClassA : arr(3).id = 300
		Set arr(4) = new ClassA : arr(4).id = 400

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_QSort6" ) Then

		n = 5
		Redim  arr(n)
		Set arr(1) = new ClassA : arr(1).id = 6
		Set arr(2) = new ClassA : arr(2).id = 3
		Set arr(3) = new ClassA : arr(3).id = 4
		Set arr(4) = new ClassA : arr(4).id = 4
		Set arr(5) = new ClassA : arr(5).id = 1
		QuickSort  arr, 1, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 1, n

	End If : section.End_


	If section.Start( "T_QSort3" ) Then

		n = 2
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 1
		Set arr(1) = new ClassA : arr(1).id = 2
		Set arr(2) = new ClassA : arr(2).id = 3

		QuickSort  arr, 0, n, GetRef("CmpFunc1"), Empty
		CheckSorted  arr, 0, n

	End If : section.End_


	If section.Start( "T_CompareFunc" ) Then

		T_CompareFunc

	End If : section.End_


	If section.Start( "T_NumStringCompare" ) Then
		test_data = Array( "", "A", "A(", "A0", "A001", "A01", "A1", "A02", "a02a", "A2", _
			"A3", "A10", "A10.0", "A10.2.1", "A10.11.1", "AA", _
			"B", "B 2", "b 3", "B 4", "B-1", "B-2", _
			"C123456789012345", "C123456789012346" )

			'// Order of NumStringCompare is NOT same as order of file name.

		For i = 0  To UBound( test_data ) - 1
			Assert  NumStringCompare( test_data( i ), test_data( i+1 ), Empty ) < 0
			Assert  NumStringCompare( test_data( i+1 ), test_data( i ), Empty ) > 0
			Assert  NumStringCompare( test_data( i ),   test_data( i ), Empty ) = 0
		Next
	End If : section.End_


	If section.Start( "T_NumStringNameCompare" ) Then
		Set obj1 = new ClassB : obj1.Name = "A2"
		Set obj2 = new ClassB : obj2.Name = "A10"

		Assert  NumStringNameCompare( obj1, obj2, Empty ) < 0
		Assert  NumStringNameCompare( obj2, obj1, Empty ) > 0
	End If : section.End_


	If section.Start( "T_QSortAlwaysPlus" ) Then
		n = 1
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 2
		Set arr(1) = new ClassA : arr(1).id = 1


		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			QuickSort  arr, 0, n, GetRef("T_QSortAlwaysPlusFunc"), Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num = 1
	End If : section.End_


	If section.Start( "T_QSortAlwaysMinus" ) Then
		n = 1
		Redim  arr(n)
		Set arr(0) = new ClassA : arr(0).id = 2
		Set arr(1) = new ClassA : arr(1).id = 1


		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			QuickSort  arr, 0, n, GetRef("T_QSortAlwaysMinusFunc"), Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num = 1
	End If : section.End_


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CompareFunc] >>> 
'********************************************************************************
Sub  T_CompareFunc()
	Set section = new SectionTree


	Dim  obj1 : Set obj1 = new ClassB : obj1.Name = "A"
	Dim  obj2 : Set obj2 = new ClassB : obj2.Name = "a"


	If section.Start( "T_StdCompare" ) Then

		Assert  StdCompare( 1, 2, Empty ) < 0
		Assert  StdCompare( 1, 1, Empty ) = 0
		Assert  StdCompare( 2, 1, Empty ) > 0

		Assert  StdCompare( "A", "A", Empty ) = 0
		Assert  StdCompare( "A", "B", Empty ) < 0
		Assert  StdCompare( "BB","BA",Empty ) > 0
		Assert  StdCompare( "A", "a", 1 ) = 0
		Assert  StdCompare( "A", "b", 1 ) < 0
		Assert  StdCompare( "a", "B", 1 ) < 0

		Assert  StdCompare( obj1, obj1, Empty ) = 0
		Assert  StdCompare( obj1, obj2, Empty ) < 0

		Assert  StdCompare( Empty, Empty, Empty ) = 0
		Assert  StdCompare( Empty, obj1, Empty ) > 0
		Assert  StdCompare( obj1, Empty, Empty ) < 0

		Assert  StdCompare( CDate("2008/7/1"), CDate("2008/7/31"), Empty ) < 0

		Assert  StdCompare( obj1, "1", Empty ) < 0

	End If : section.End_


	If section.Start( "T_NameCompare" ) Then

		Assert  NameCompare( obj1, obj2, Empty ) <> 0
		Assert  NameCompare( obj1, obj2, 1 ) = 0
		Assert  NameCompare( obj1, "A", Empty ) < 0
		Assert  NameCompare( "A", obj2, Empty ) > 0

	End If : section.End_
End Sub


 
'********************************************************************************
'  <<< [ClassA] >>>
'********************************************************************************
Class  ClassA : Public id : End Class
Class  ClassB : Public Name : End Class


'********************************************************************************
'  <<< [CmpFunc1] >>>
'********************************************************************************
Function  CmpFunc1( left, right, param )
	CmpFunc1 = left.id - right.id    '// 降順なら right.id - left.id
End Function


'********************************************************************************
'  <<< [T_QSortAlwaysPlusFunc] >>>
'********************************************************************************
Function  T_QSortAlwaysPlusFunc( left, right, param )
	T_QSortAlwaysPlusFunc = 1
End Function


'********************************************************************************
'  <<< [T_QSortAlwaysMinusFunc] >>>
'********************************************************************************
Function  T_QSortAlwaysMinusFunc( left, right, param )
	T_QSortAlwaysMinusFunc = -1
End Function


'********************************************************************************
'  <<< [CheckSorted] >>>
'********************************************************************************
Sub  CheckSorted( Arr, iStart, iLast )
	Dim  i, key, s, b

	echo  "CheckSorted"
	key = Arr(iStart).id : b = False
	For i=iStart To iLast
		s="" : If Arr(i).id < key Then  s = " (Fail)" : b = True
		echo  "("&i&") " & Arr(i).id & s
		key = Arr(i).id
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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
