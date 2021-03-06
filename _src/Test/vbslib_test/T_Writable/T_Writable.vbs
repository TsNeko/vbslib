Option Explicit 

Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Writable",_
			"2","T_MultiWritable",_
			"3","T_Writable_Empty",_
			"4","T_InPath",_
			"5","T_CompareLetterCase",_
			"6","T_CheckVariableFunctions",_
			"7","T_CheckOSFolder",_
			"8","T_TempWritable1",_
			"9","T_TempWritable2",_
			"10","T_TempWritable_Updating" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [SetupTest] >>> 
'********************************************************************************
Sub  SetupTest( AppKey )
	Dim w_:Set w_= AppKey.NewWritable( "." ).Enable()
	del "work"
	If exist("work") Then Fail
	mkdir "work"
	If not exist("work") Then Fail
	del "work"
	del "work2"
	del "work3"
	del "work4"
	del "work5"
	w_ = Empty
End Sub


 
'********************************************************************************
'  <<< [T_Writable] >>> 
'********************************************************************************
Sub  T_Writable( Opt, AppKey )
	Dim  w_, f, fo, e
	Dim  i, n : n = 9
	SetupTest  AppKey

	'// Setup
	Dim  desktop : desktop = g_sh.SpecialFolders( "Desktop" )
	For i=1 To n
		fo = desktop+"\_test_of_vbslib\" & i
		Set w_= AppKey.NewWritable( fo ).Enable()
		del  fo
		w_ = Empty
	Next
	fo = desktop+"\_test_of_vbslib"
	Set w_= AppKey.NewWritable( fo ).Enable()
	del  fo
	w_ = Empty


If 1 Then

	'// Main
	AppKey.SetWritableMode  F_ErrIfWarn
	Set w_= AppKey.NewWritable( desktop+"\_test_of_vbslib\*" ).Enable()
	i = 0


	'// mkdir level 1
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	mkdir  fo  '// Add new writable  '//##################################### Test Point
	If not exist( fo ) Then  Fail
	mkdir  fo  '// すでにフォルダは存在するが、新たに追加された Writable になっているので、警告は表示されない
	del  fo  '// 新たに追加された Writable のパスなので警告は表示されない


	'// mkdir level 2
	AppKey.SetWritableMode  F_ErrIfWarn
	Set w_= AppKey.NewWritable( desktop+"\_test_of_vbslib\*" ).Enable()
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	mkdir  fo + "\sub"  '// Add new writable  '//##################################### Test Point
	If not exist( fo + "\sub" ) Then  Fail
	del  fo  '// 新たに追加された Writable のパスなので警告は表示されない


	'// copy(1)
	AppKey.SetWritableMode  F_ErrIfWarn
	Set w_= AppKey.NewWritable( desktop+"\_test_of_vbslib\*" ).Enable()
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	copy_ren  "Test.vbs", fo + "\Test.vbs"  '//##################################### Test Point
	If not exist( fo +"\Test.vbs" ) Then  Fail
	del  fo +"\Test.vbs"

	copy  "Test.vbs", fo +"\SrcCopy"
	move_ren  fo +"\SrcCopy\Test.vbs", fo +"\Test.vbs"  '//##################################### Test Point
	If not exist( fo +"\Test.vbs" ) Then  Fail
	del  fo  '// 新たに追加された Writable のパスなので警告は表示されない


	'// copy(2)
	AppKey.SetWritableMode  F_ErrIfWarn
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	Set w_= AppKey.NewWritable( fo ).Enable()
	copy  "Test.vbs", fo +"\SrcCopy"
	copy  "T_Writable.vbs", fo +"\SrcCopy"

	Set w_= AppKey.NewWritable( fo +"\Test.vbs" ).Enable()
	copy  "Test.vbs", fo  '//##################################### Test Point
	If not exist( fo +"\Test.vbs" ) Then  Fail
	del  fo +"\Test.vbs"

	If TryStart(e) Then  On Error Resume Next
		copy  "T_Writable.vbs", fo  '//################################ Test Point
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo +"T_Writable.vbs" ) Then  Fail

	Set w_= AppKey.NewWritable( Array( fo +"\Test.vbs", fo +"\SrcCopy\Test.vbs" ) ).Enable()
	move  fo +"\SrcCopy\Test.vbs", fo  '//##################################### Test Point
	If not exist( fo +"\Test.vbs" ) Then  Fail

	If TryStart(e) Then  On Error Resume Next
		move  fo +"\SrcCopy\T_Writable.vbs", fo  '//################################ Test Point
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo +"T_Writable.vbs" ) Then  Fail

	Set w_= AppKey.NewWritable( fo ).Enable()
	del  fo
	w_ = Empty
End If


	'// copy(3)
	AppKey.SetWritableMode  F_ErrIfWarn
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	Set w_= AppKey.NewWritable( fo +"\FolderA" ).Enable()
	CreateFile  fo +"\FolderA\FolderB\File1.txt", "File1"
	CreateFile  fo +"\FolderA\FolderC\File1.txt", "File1"
	Set w_= AppKey.NewWritable( fo +"\FolderB" ).Enable()

	copy  fo +"\FolderA\FolderB", fo  '  //##################################### Test Point
	If not exist( fo +"\FolderB\File1.txt" ) Then  Fail
	del  fo +"\FolderB"

	move  fo +"\FolderA\FolderB", fo  '  //##################################### Test Point
	If not exist( fo +"\FolderB\File1.txt" ) Then  Fail

	If TryStart(e) Then  On Error Resume Next
		copy  fo +"\FolderA\FolderC", fo  '//################################ Test Point
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo +"\FolderC" ) Then  Fail

	If TryStart(e) Then  On Error Resume Next
		move  fo +"\FolderA\FolderC", fo  '//################################ Test Point
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo +"\FolderC" ) Then  Fail

	Set w_= AppKey.NewWritable( fo ).Enable()
	del  fo
	w_ = Empty


	'// OpenForWrite
	AppKey.SetWritableMode  F_ErrIfWarn
	Set w_= AppKey.NewWritable( desktop+"\_test_of_vbslib\*" ).Enable()
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	Set f = OpenForWrite( fo+"\a.txt", Empty )  '// Add new writable  '//##################################### Test Point
	f.WriteLine  "ABC"
	f = Empty
	If not exist( fo + "\a.txt" ) Then  Fail
	del  fo  '// 新たに追加された Writable のパスなので警告は表示されない


	'// CreateFile (1)
	AppKey.SetWritableMode  F_ErrIfWarn
	Set w_= AppKey.NewWritable( desktop+"\_test_of_vbslib\*" ).Enable()
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	CreateFile  fo+"\a.txt", "ABC"  '// Add new writable  '//##################################### Test Point
	If not exist( fo + "\a.txt" ) Then  Fail
	del  fo  '// 新たに追加された Writable のパスなので警告は表示されない


	'// CreateFile (2)
	AppKey.SetWritableMode  F_ErrIfWarn
	f = desktop+"\T_CreateFile.txt"
	Set w_= AppKey.NewWritable( f ).Enable()
	CreateFile  f, "ABC"  '//##################################### Test Point
	If not exist( f ) Then  Fail
	del  f


	'//===========================================================
	'// Last "\*"
	'// already exist ... error
	'// mkdir already exist ... error

	'// Set up
	AppKey.SetWritableMode  F_ErrIfWarn
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	Set w_= AppKey.NewWritable( fo ).Enable()
	mkdir  fo
	CreateFile  fo + "\a.txt", "ABC"

	'// Test Main & Check
	Set w_= AppKey.NewWritable( desktop+"\_test_of_vbslib\*" ).Enable()
	If TryStart(e) Then  On Error Resume Next
		CreateFile  fo + "\a.txt", "ABC"  '// 既存のフォルダーならエラーになる
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	echo  "[ERROR] " + e.Description
	If InStr( e.Description, "NOT NEW" ) = 0 Then  Fail
	e.Clear

	'// Test Main & Check
	i = i + 1
	fo = desktop+"\_test_of_vbslib\" & i
	CreateFile  fo + "\a.txt", "ABC"  '// 新しいフォルダーならエラーにならない

	'// Clean
	Set w_= AppKey.NewWritable( fo ).Enable()
	del  fo
	w_ = Empty


	'//===========================================================
	'// Out of new writable ... error

	fo = desktop+"\_test_of_vbslib0"  '// out of Writable


	'// mkdir
	If TryStart(e) Then  On Error Resume Next
		mkdir  fo  '// Fail to add new writable  //################## Test Point
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo ) Then  Fail


	'// copy
	If TryStart(e) Then  On Error Resume Next
		copy  "Test.vbs", fo  '// Fail to add new writable
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo ) Then  Fail


	'// OpenForWrite
	If TryStart(e) Then  On Error Resume Next
		Set f = OpenForWrite( fo+"\a.txt", Empty )  '// Fail to add new writable  //################## Test Point
		f = Empty
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo ) Then  Fail


	'// CreateFile
	If TryStart(e) Then  On Error Resume Next
		CreateFile  fo+"\a.txt", "ABC"  '// Fail to add new writable  //################## Test Point
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( fo ) Then  Fail


	'// Finalize
	If i <> n Then  Fail
		'// n は、i に合わせてください

	w_ = Empty

	fo = desktop+"\_test_of_vbslib"
	Set w_= AppKey.NewWritable( fo ).Enable()
	del  fo
	w_ = Empty

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_MultiWritable] >>> 
'********************************************************************************
Sub  T_MultiWritable( Opt, AppKey )
	Dim  w_
	SetupTest  AppKey

	SetWritableMode  F_ErrIfWarn

	ReDim  works(1) : works(0)="work3" : works(1)="work4"
	If not AppKey.InPath( works, "." ) Then  Fail
	Set w_= AppKey.NewWritable( works ).Enable()

	T_MultiWritable_sub

	w_ = Empty

	Dim  wr : Set wr = new ArrayClass
	wr.add  "work3"
	wr.add  "work4"
	Set w_= AppKey.NewWritable( wr ).Enable()

	T_MultiWritable_sub

	w_ = Empty

	Pass
End Sub


Sub  T_MultiWritable_sub()
	Dim  f, e

	f = "work3"
	del  f
	If exist( f ) Then  Fail
	mkdir  f
	If not exist( f ) Then  Fail
	CreateFile  f+"\test.txt", "test"
	If not exist( f+"\test.txt") Then  Fail
	del  f
	If exist( f ) Then  Fail

	f = "work4"
	del    f : If exist( f ) Then  Fail
	mkdir  f : If not exist(f) Then  Fail
	del    f : If exist( f ) Then  Fail

	If TryStart(e) Then  On Error Resume Next
		mkdir  "work7"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	If InStr( e.Description, "NOT NEW" ) > 0 Then  Fail
	e.Clear

	If TryStart(e) Then  On Error Resume Next
		mkdir  "work3p"  '// work3 + p
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
End Sub


 
'********************************************************************************
'  <<< [T_Writable_Empty] >>> 
'********************************************************************************
Sub  T_Writable_Empty( Opt, AppKey )
	Dim  w_, e
	SetupTest  AppKey

	SetWritableMode  F_ErrIfWarn

	Set w_= AppKey.NewWritable( Array( "work", Empty ) ).Enable()
	CreateFile  "work\test.txt", "writable"

	If TryStart(e) Then  On Error Resume Next
		CreateFile  "test.txt", "writable"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_InPath] >>> 
'********************************************************************************
Sub  T_InPath( Opt, AppKey )
	SetupTest  AppKey

	Dim  c, w
	c = "folder1"
	w = "folder1"
	If not AppKey.InPath( c, w ) Then  Fail

	c = "folder1"
	w = "folder"
	If AppKey.InPath( c, w ) Then  Fail

	Dim cs, ws : ReDim  cs(1), ws(1)
	cs(0) = "folder1" : cs(1) = "folder2"
	ws(0) = "folder1" : ws(1) = "folder2"
	If not AppKey.InPath( cs, ws ) Then  Fail
	cs(1) = "folder"
	If AppKey.InPath( cs, ws ) Then  Fail

	Set c = new ArrayClass :  Set w = new ArrayClass
	c.Add "folder1" : c.Add "folder2"
	w.Add "folder1" : w.Add "folder2"
	If not AppKey.InPath( c, w ) Then  Fail
	c(1) = "folder"
	If AppKey.InPath( c, w ) Then  Fail

	ReDim ws(1)
	c = "folder1"
	ws(0) = "folder1" : ws(1) = "folder2"
	If not AppKey.InPath( c, ws ) Then  Fail

	ReDim  cs(1)
	cs(0) = "folder1" : cs(1) = "folder1\sub"
	w = "folder1"
	If not AppKey.InPath( cs, w ) Then  Fail
	cs(1) = "folder"
	If AppKey.InPath( cs, w ) Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CompareLetterCase] >>> 
'********************************************************************************
Sub  T_CompareLetterCase( Opt, AppKey )
	Dim  f
	SetupTest  AppKey

	'// Compare path by case of big letter and small letter

	Dim w_:Set w_= AppKey.NewWritable( "folder3" ).Enable()
	del  "folder3"
	mkdir  "fOlDer3"
	del  "folder3"
	w_ = Empty


	Set w_= AppKey.NewWritable( "folder3" ).Enable()
	del  "folder3"
	Set f = OpenForWrite( "fOLder3\_test_file.txt", Empty )
	f.WriteLine  "abc"
	f = Empty
	del  "folder3"
	w_ = Empty

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CheckVariableFunctions] >>> 
'********************************************************************************
Sub  T_CheckVariableFunctions( Opt, AppKey )
	Dim  e, f, w_
	SetupTest  AppKey

	Set w_= AppKey.NewWritable( "work5" ).Enable()
	del  "work5"
	w_ = Empty

	AppKey.SetWritableMode  F_ErrIfWarn

	echo "Test of CreateFile"
	If TryStart(e) Then  On Error Resume Next
		CreateFile  "work5\test.txt", "test"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear

	echo "Test of copy"
	If TryStart(e) Then  On Error Resume Next
		copy "T_Writable.vbs", "data2"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear

	echo "Test of move(1)"
	Set w_= AppKey.NewWritable( "work4" ).Enable()
	CreateFile  "work4\MoveTest.txt", "test"
	If TryStart(e) Then  On Error Resume Next
		move  "work4\MoveTest.txt", "work5"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	del "work4"
	w_=Empty

	echo "Test of move(2)"
	Set w_= AppKey.NewWritable( "work4" ).Enable()
	CreateFile  "work4\MoveTest.txt", "test"
	Set w_= AppKey.NewWritable( "work5" ).Enable()  '// work4 is not writable
	If TryStart(e) Then  On Error Resume Next
		move  "work4\MoveTest.txt", "work5"
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
	If exist( "work5" ) Then  Fail

	Set w_= AppKey.NewWritable( "work4" ).Enable()
	del  "work4"
	CreateFile  "work4\a.txt", "test"
	CreateFile  "work4\sub\a.txt", "test"
	Set w_= AppKey.NewWritable( "work4\sub" ).Enable()

 If 0 Then '[DEBUG_SKIP]********
 End If '[DEBUG_SKIP]********

		echo "Test of del"
		del  "work4\sub"
		del  "work5"  '// no delete item
		If TryStart(e) Then  On Error Resume Next
			del  "work4"
		If TryEnd Then  On Error GoTo 0
		If e.num <> E_OutOfWritable  Then Fail
		e.Clear
		If not exist("work4") Then  Fail
		CreateFile  "work4\sub\a.txt", "test"

		echo "Test of ren"
		If TryStart(e) Then  On Error Resume Next
			ren  "work4\a.txt", "b.txt"
		If TryEnd Then  On Error GoTo 0
		If e.num <> E_OutOfWritable  Then Fail
		e.Clear
		If not exist("work4\a.txt") Then  Fail

		echo "Test of del_subfolder"
		del_subfolder  "work4\sub"
		If TryStart(e) Then  On Error Resume Next
			del_subfolder  "work4"
		If TryEnd Then  On Error GoTo 0
		If e.num <> E_OutOfWritable  Then Fail
		e.Clear
		If not exist("work4") Then  Fail
		CreateFile  "work4\sub\a.txt", "test"

		echo "Test of del_to_trashbox"
		del_to_trashbox  "work4\sub"
		If TryStart(e) Then  On Error Resume Next
			del_to_trashbox  "work4"
		If TryEnd Then  On Error GoTo 0
		If e.num <> E_OutOfWritable  Then Fail
		e.Clear
		If not exist("work4") Then  Fail
		CreateFile  "work4\sub\a.txt", "test"

		echo "Test of OpenForWrite"
		Set  f = OpenForWrite( "work4\sub\b.txt", Empty )
		f = Empty
		del  "work4\sub\b.txt"
		If TryStart(e) Then  On Error Resume Next
			Set f = OpenForWrite( "work4\b.txt", Empty )
		If TryEnd Then  On Error GoTo 0
		If e.num <> E_OutOfWritable  Then Fail
		e.Clear
		f = Empty
		If exist("work4\b.txt") Then  Fail

	Set w_= AppKey.NewWritable( "work4" ).Enable()
	del "work4"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CheckOSFolder] >>> 
'********************************************************************************
Sub  T_CheckOSFolder( Opt, AppKey )
	Dim  path
	SetupTest  AppKey

	SetWritableMode  F_ErrIfWarn

	T_CheckOSFolder_sub  AppKey, env( "%windir%" )
	T_CheckOSFolder_sub  AppKey, env( "%windir%\system32" )
	T_CheckOSFolder_sub  AppKey, env( "%ProgramFiles%" )
	T_CheckOSFolder_sub  AppKey, env( "%ProgramFiles%\abc" )
	T_CheckOSFolder_sub  AppKey, env( "%APPDATA%" )
	T_CheckOSFolder_sub  AppKey, env( "%APPDATA%\abc" )
	If GetOSVersion() >= 6.0 Then
		T_CheckOSFolder_sub  AppKey, env( "%LOCALAPPDATA%" )
		T_CheckOSFolder_sub  AppKey, env( "%LOCALAPPDATA%\abc" )
	Else
		T_CheckOSFolder_sub  AppKey, env( "%APPDATA%" )
		T_CheckOSFolder_sub  AppKey, env( "%APPDATA%\abc" )
	End If

	T_CheckOSFolder_sub  AppKey, Array( "C:\home\abcdefg", env( "%windir%" ) )

	path = Left( env("%windir%"), 3 ) '// Do not writable OS folder containing folder
	If Mid( path, 2 ) <> ":\" Then  Fail
	T_CheckOSFolder_sub  AppKey, env( path )

	Pass
End Sub


Sub  T_CheckOSFolder_sub( AppKey, Path )
	Dim  e

	If TryStart(e) Then  On Error Resume Next
		Set w_= AppKey.NewWritable( Path ).Enable()
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then Fail
	e.Clear
End Sub


 
'********************************************************************************
'  <<< [T_TempWritable1] >>> 
'********************************************************************************
Sub  T_TempWritable1( Opt, AppKey )
	SetupTest  AppKey
	SetWritableMode  F_ErrIfWarn
	Dim  path : path = env( "%Temp%\Report\T_TempWritable\file.txt" )
	mkdir  path
	del    path
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TempWritable2] >>> 
'********************************************************************************
Sub  T_TempWritable2( Opt, AppKey )
	SetupTest  AppKey
	SetWritableMode  F_ErrIfWarn
	Dim  path : path = env( "%Temp%\Report\T_TempWritable\file.txt" )
	Dim w_:Set w_=AppKey.NewWritable( GetParentFullPath( path ) ).Enable()
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_TempWritable_Updating] >>> 
'********************************************************************************
Sub  T_TempWritable_Updating( Opt, AppKey )
	copy_ren  "T_Writable.vbs",  "T_Writable.vbs.updating"
	del  "T_Writable.vbs.updating"
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


 
