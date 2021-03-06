Sub  Main( Opt, AppKey )
	SaveEnvVars  g_DefaultEnvVars, Empty  '//[out] g_DefaultEnvVars
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_Var1", _
			"2","T_Var2",_
			"3","T_VarStack", _
			"4","T_LoadEnvVars", _
			"5","T_VarArray", _
			"6","T_VarSpecial", _
			"7","T_LetSet", _
			"8","T_ParseOptionArguments", _
			"9","T_IsBitSet" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub

Dim  g_DefaultEnvVars  '// variables at starting process


 
'********************************************************************************
'  <<< [T_Var1] SetVar >>> 
'********************************************************************************
Sub  T_Var1( Opt, AppKey )
	Dim  e, value, o

	'//=== 定義していない変数
	If not IsEmpty( GetVar( "Foo1" ) ) Then  Fail
	If not IsEmpty( GetVar( "%Foo1%" ) ) Then  Fail

	If TryStart(e) Then  On Error Resume Next
		echo  env( "%Foo1%" )
	If TryEnd Then  On Error GoTo 0
	If e.num = E_NotFoundSymbol  Then  e.Clear
	If e.num <> 0 Then  e.Raise

	'//=== 基本テスト、数値
	SetVar  "Foo1", 1
	If GetVar( "Foo1" ) <> 1 Then  Fail
	If GetVar( "%Foo1%" ) <> 1 Then  Fail
	SetVar  "Foo1", Empty

	'//=== オブジェクト
	Set o = CreateObject( "Scripting.Dictionary" )
	SetVar  "FooObj", o
	If not GetVar( "FooObj" ) Is o Then  Fail
	SetVar  "FooObj", Empty

	'//=== OS が定義する環境変数
	If GetVar( "windir" ) <> g_sh.ExpandEnvironmentStrings( "%windir%" ) Then  Fail

	'//=== %1
	Assert  env("a%1") = "a%1"

	'//=== %%
	Assert  env("a%%x") = "a%x"

	'//=== Empty
	If not IsEmpty( env( Empty ) ) Then  Fail

	'//=== 変数の識別、変数を未定義に戻す
	SetVar  "Foo2", 2
	SetVar  "Foo1", Empty
	If not IsEmpty( GetVar( "Foo1" ) ) Then  Fail
	SetVar  "Foo1", Empty  '// re-Empty
	If GetVar( "Foo2" ) <> 2 Then  Fail

	SetVar  "Foo2", ""
	If GetVar( "Foo2" ) <> "" Then  Fail
	SetVar  "Foo1", Empty
	SetVar  "Foo2", Empty

	'//=== SetVar と env の共有
	SetVar  "Foo1", 1
	If env( "_%Foo1%_data" ) <> "_1_data" Then  Fail
	SetVar  "Foo1", Empty

	'//=== OS が定義する環境変数を上書きする
	value = env( "%OS%" )
	SetVar  "OS", "Windows_XX"
	If env( "_%OS%_%windir%_" ) <> g_sh.ExpandEnvironmentStrings( "_Windows_XX_%windir%_" ) Then  Fail

	'//=== 複数の環境変数を同時に指定したときに、片方の変数が未定義のとき
	If TryStart(e) Then  On Error Resume Next
		echo  env( "_%Foo1%_%unknown%_" )
	If TryEnd Then  On Error GoTo 0
	If e.num = E_NotFoundSymbol  Then  e.Clear
	If e.num <> 0 Then  e.Raise

	'//=== % が１つだけのとき
	If TryStart(e) Then  On Error Resume Next
		echo  env( "%NotFoundEnd" )
	If TryEnd Then  On Error GoTo 0
	If e.num = E_NotFoundSymbol  and  InStr( e.desc, "%NotFoundEnd" ) > 0  Then  e.Clear
	If e.num <> 0 Then  e.Raise

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Var2] set_ >>> 
'********************************************************************************
Sub  T_Var2( Opt, AppKey )
	Dim  e, value

	'//=== not defined var
	If not IsEmpty( GetVar( "Foo1" ) ) Then  Fail

	If TryStart(e) Then  On Error Resume Next
		echo  env( "%Foo1%" )
	If TryEnd Then  On Error GoTo 0
	If e.num = E_NotFoundSymbol  Then  e.Clear
	If e.num <> 0 Then  e.Raise

	'//=== Basic and Number
	set_  "Foo1", 1
	If GetVar( "Foo1" ) <> 1 Then  Fail
	set_  "Foo1", Empty

	'//=== OS defined var
	If GetVar( "windir" ) <> g_sh.ExpandEnvironmentStrings( "%windir%" ) Then  Fail

	'//=== Empty
	If not IsEmpty( env( Empty ) ) Then  Fail

	'//=== identify, reset
	set_  "Foo2", 2
	set_  "Foo1", Empty
	If not IsEmpty( GetVar( "Foo1" ) ) Then  Fail
	set_  "Foo1", Empty  '// re-Empty
	If GetVar( "Foo2" ) <> "2" Then  Fail

	set_  "Foo2", ""
	If GetVar( "Foo2" ) <> "" Then  Fail

	set_  "Foo1", Empty
	set_  "Foo2", Empty

	'//=== env using GetVar
	set_  "Foo1", 1
	If env( "_%Foo1%_data" ) <> "_1_data" Then  Fail
	set_  "Foo1", Empty

	'//=== overwrite OS var
	value = env( "%OS%" )
	set_  "OS", "Windows_XX"
	If env( "_%OS%_%windir%_" ) <> g_sh.ExpandEnvironmentStrings( "_Windows_XX_%windir%_" ) Then  Fail

	'//=== not defined var in multi var
	If TryStart(e) Then  On Error Resume Next
		echo  env( "_%Foo1%_%unknown%_" )
	If TryEnd Then  On Error GoTo 0
	If e.num = E_NotFoundSymbol  Then  e.Clear
	If e.num <> 0 Then  e.Raise
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_VarStack] >>> 
'********************************************************************************
Sub  T_VarStack( Opt, AppKey )
	Dim v_, v2_


	'//==== Level 1

	set_ "Foo2", "2"
	set_ "Foo4",  4

	Set v_ = new VarStack

		set_   "Foo1", "1"
		set_   "Foo2", "2a"
		SetVar "Foo3",  3
		SetVar "Foo4",  44

	v_ = Empty

	If GetVar( "Foo1" ) <> ""  Then  Fail
	If GetVar( "Foo2" ) <> "2" Then  Fail
	If not IsEmpty( GetVar( "Foo3" ) ) Then  Fail
	If GetVar( "Foo4" ) <> 4   Then  Fail

	set_   "Foo1", Empty
	set_   "Foo2", Empty
	SetVar "Foo3", Empty
	SetVar "Foo4", Empty


	'//==== Level 2

	set_ "Foo2", "2"
	set_ "Foo4",  4

	Set v_ = new VarStack

		set_   "Foo1", "1"
		set_   "Foo2", "2a"
		SetVar "Foo3",  3
		SetVar "Foo4",  44

		Set v2_ = new VarStack

			If GetVar( "Foo1" ) <> "1"  Then  Fail
			If GetVar( "Foo2" ) <> "2a" Then  Fail
			If GetVar( "Foo3" ) <>  3   Then  Fail
			If GetVar( "Foo4" ) <>  44  Then  Fail

			set_   "Foo1", "1b"
			set_   "Foo2", "2b"
			SetVar "Foo3",  333
			SetVar "Foo4",  444
			If GetVar( "Foo1" ) <> "1b" Then  Fail
			If GetVar( "Foo2" ) <> "2b" Then  Fail
			If GetVar( "Foo3" ) <>  333 Then  Fail
			If GetVar( "Foo4" ) <>  444 Then  Fail

		v2_ = Empty

		If GetVar( "Foo1" ) <> "1"  Then  Fail
		If GetVar( "Foo2" ) <> "2a" Then  Fail
		If GetVar( "Foo3" ) <>  3   Then  Fail
		If GetVar( "Foo4" ) <>  44  Then  Fail

	v_ = Empty

	If GetVar( "Foo1" ) <> ""  Then  Fail
	If GetVar( "Foo2" ) <> "2" Then  Fail
	If not IsEmpty( GetVar( "Foo3" ) ) Then  Fail
	If GetVar( "Foo4" ) <> 4   Then  Fail

	set_   "Foo1", Empty
	set_   "Foo2", Empty
	SetVar "Foo3", Empty
	SetVar "Foo4", Empty


	'//==== [T_g_Vers_Stack]
	Set v_ = new VarStack
		g_Vers( "Vers1" ) = 1
		Set v2_ = new VarStack
			g_Vers( "Vers1" ) = 2
			If g_Vers( "Vers1" ) <> 2 Then  Fail
		v2_ = Empty
		If g_Vers( "Vers1" ) <> 1 Then  Fail
	v_ = Empty
	If g_Vers.Exists( "Vers1" ) Then  Fail


	'//=== Case of "ClearEnvVars" in "VarStack"

	'// Set up
	Set envs = new ArrayClass
	For Each  env_line  In g_sh.Environment( "Process" )
		envs.Add env_line
	Next

	'// Test Main
	Set v_ = new VarStack
		Set envs0 = g_sh.Environment( "Process" )
		ClearEnvVars

		Set envs0 = g_sh.Environment( "Process" )
		For Each  env_line  In g_sh.Environment( "Process" )
			Assert  Left( env_line, 1 ) = "="
		Next
	v_ = Empty

	'// Check
	Set envs2 = new ArrayClass
	For Each  env_line  In g_sh.Environment( "Process" )
		envs2.Add env_line
	Next
	Assert  IsSameArray( envs, envs2 )


	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LoadEnvVars] >>> 
'********************************************************************************
Sub  T_LoadEnvVars( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Const  sample_path  = "settings_sample.txt"
	Const  settings_out = "settings_out.txt"

	Dim  n,  env_set,  cannot_clear_env_count,  name
	Dim  c : Set c = g_VBS_Lib
	Dim  envs : Set envs = g_sh.Environment( "Process" )


	'//=== Get "cannot_clear_env_count"
	ClearEnvVars
	cannot_clear_env_count = envs.Count



	'//=== Case of "LoadEnvVars  dictionary, Empty"
	'//=== Load default (at starting process) environment variables

	'// Set up
	set_  "NotCleared", "1"

	'// Test Main
	LoadEnvVars  g_DefaultEnvVars, Empty

	'// Check
	Assert  IsEmpty( GetVar( "NotCleared" ) )
	Assert  envs.Count = g_DefaultEnvVars.Count + cannot_clear_env_count



	'//=== Case of "LoadEnvVars  path, Empty"
	'//=== Load environment variables from file "sample_path"

	'// Set up
	Dim f : Set f = g_fs.CreateTextFile( sample_path, True, False )
	For Each name  In g_DefaultEnvVars.Keys
		f.WriteLine  name +"="+ g_DefaultEnvVars.Item( name )
	Next
	f.WriteLine  "var_a=1"
	f.WriteLine  "VAR_B=BB"
	f = Empty

	'// Test Main
	LoadEnvVars  sample_path, Empty

	'// Check
	Assert  envs.Count = g_DefaultEnvVars.Count + cannot_clear_env_count + 2
	Assert  envs.Item( "var_a" ) = "1"
	Assert  envs.Item( "VAR_B" ) = "BB"

	'// Clean
	LoadEnvVars  g_DefaultEnvVars, Empty



	'//=== Case of "LoadEnvVars  path, dictionary"
	'//=== Set "env_set" from file

	'// Test Main
	Set env_set = CreateObject( "Scripting.Dictionary" )
	env_set.Item( "Other" ) = "1"  '// This will be unset
	LoadEnvVars  sample_path, env_set

	'// Check
	Assert  envs.Count = g_DefaultEnvVars.Count + cannot_clear_env_count
	Assert  env_set.Count = g_DefaultEnvVars.Count + 2
	Assert  env_set.Item( "var_a" ) = "1"
	Assert  env_set.Item( "VAR_B" ) = "BB"



	'//=== Case of "SaveEnvVars  path, Empty"
	'//=== Save environment variables to a file

	'// Set up
	LoadEnvVars  sample_path, Empty

	'// Test Main
	SaveEnvVars  settings_out, Empty

	'// Check
	LoadEnvVars  g_DefaultEnvVars, Empty  '// Reset
	LoadEnvVars  settings_out, Empty
	Assert  envs.Count = g_DefaultEnvVars.Count + cannot_clear_env_count + 2
	Assert  envs.Item( "var_a" ) = "1"
	Assert  envs.Item( "VAR_B" ) = "BB"



	'//=== Case of "SaveEnvVars  dictionary, Empty"
	'//=== Get "env_set" dictionary having environment variables

	'// Test Main
	env_set = Empty
	SaveEnvVars  env_set, Empty
	echo  env_set

	'// Check
	Assert  env_set.Count = g_DefaultEnvVars.Count + 2
	Assert  env_set.Item( "var_a" ) = "1"
	Assert  env_set.Item( "VAR_B" ) = "BB"



	'// Clean
	LoadEnvVars  g_DefaultEnvVars, Empty


	del  sample_path
	del  settings_out
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_VarArray] >>> 
'********************************************************************************
Sub  T_VarArray( Opt, AppKey )
	Dim  section : Set section = new SectionTree

	'// Set up common variable
	SetVar  "VarA", 1
	SetVar  "VarB", 2


	'// Value is array
	SetVar  "VarC", Array( "X%VarA%X", "X%VarB%X" )
	If section.Start( "T_VarArray_env" ) Then
		echo  env("%VarC%")
		Assert IsSameArray( env("%VarC%"), Array( "X1X", "X2X" ) )
	End If : section.End_

	If section.Start( "T_VarArray_GetVar" ) Then
		echo  GetVar( "VarC" )
		Assert IsSameArray( GetVar("VarC"), Array( "X%VarA%X", "X%VarB%X" ) )
	End If : section.End_

	If section.Start( "T_VarArray_env_ArrAndStr_Err" ) Then
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next
			echo  env( "%VarC%Str" )
		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0
	End If : section.End_


	'// Parameter is array
	If section.Start( "T_VarArray_env2" ) Then
		echo  env( Array( "X%VarA%X", "X%VarB%X" ) )
		Assert IsSameArray( env( Array( "X%VarA%X", "X%VarB%X") ), Array( "X1X", "X2X" ) )
	End If : section.End_


	'// Value is array : Not found environment variable
	SetVar  "VarD", Array( "%VarA%", "%NotFound%" )
	If section.Start( "T_VarArray_env_NotFoundInArrayValueError" ) Then
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next
			echo  env( Array( "%VarD%" ) )
		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0
	End If : section.End_


	'// Parameter is array : Not found environment variable
	SetVar  "VarD", Array( 1, 2 )
	If section.Start( "T_VarArray_env_NotFoundInArrayParamError" ) Then
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next
			echo  env( Array( "%VarD%", "%NotFound%" ) )
		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0
	End If : section.End_

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_VarSpecial] >>> 
'********************************************************************************
Sub  T_VarSpecial( Opt, AppKey )

	Assert  env( "%XML_File(T_VarXML.xml#/Root/Tag)%" ) = "The text"
	Assert  env( "%XML_File(T_VarXML.xml#/Root/Tag/@attr)%" ) = "value"

	SetVar  "TestXML_Path", "T_VarXML.xml"
	Assert  env( "%XML_File(%TestXML_Path%#/Root/Tag)%" ) = "The text"

	Assert  env( "%SpecialFolders(MyDocuments)%\a" ) = _
		g_sh.SpecialFolders( "MyDocuments" ) +"\a"

	Assert  env( env( "%XML_File(%TestXML_Path%#/Root/MyDocA)%" ) ) = _
		g_sh.SpecialFolders( "MyDocuments" ) +"\a"

	Assert  IsSameArray( env( "%ArrayFromXML_File(T_VarXML.xml#/Root/ArrayA)%" ), _
		Array( "Value[0]", "Value[1]", "Value[2]" ) )

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LetSet] >>> 
'********************************************************************************
Sub  T_LetSet( Opt, AppKey )
	Set object = CreateObject( "Scripting.Dictionary" )
	ReDim  arr(1)

	LetSet  object2, object
	Assert  object2 Is object

	Set object2 = new NameOnlyClass
	LetSet  object2.Name, "NewName"
	'// Assert  object_2.Name = "NewName"  '// Cannot do it

	LetSet  var, 1
	Assert  var = 1

	LetSetWithBracket  arr, 0, "AA"
	LetSetWithBracket  arr, 1, "BB"
	Assert  arr(0) = "AA"
	Assert  arr(1) = "BB"

	LetSetWithBracket  object, "a", "AA"
	LetSetWithBracket  object, "b", "BB"
	Assert  object("a") = "AA"
	Assert  object("b") = "BB"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ParseOptionArguments] >>> 
'********************************************************************************
Sub  T_ParseOptionArguments( Opt, AppKey )
	Set section = new SectionTree
	Set object_1 = new NameOnlyClass
	Set object_2 = new ArrayClass


	'// Set up
	options = Array( 123, "ABC", object_1, 1.1, object_2 )

	For i = 1 To 2
	If section.Start( "T_ParseOptionArguments_"& i ) Then

		'// Test Main
		ParseOptionArguments  options
			'// When i = 2, Re-changes

		'// Check
		Assert  options( "inteGER" ) = 123
		Assert  options( "floAT" )   = 1.1
		Assert  options( "string" )  = "ABC"
		Assert  options( "NameOnlyClass" ) Is object_1
		Assert  options( "ArrayClass" )    Is object_2

	End If : section.End_
	Next


	If section.Start( "T_ParseOptionArguments_Types" ) Then
	For Each  t  In DicTable( Array( _
		"TestCase",  "Var",  Empty, _
		"Empty",     Empty, _
		"Integer",   123, _
		"Object",    object_1, _
		"Boolean",   True ) )

		'// Set up
		LetSet  options, t("Var")

		'// Test Main
		ParseOptionArguments  options

		'// Check
		Select Case  t("TestCase")
			Case "Empty"   : Assert  options.Count = 0
			Case "Integer" : Assert  options("Integer") = t("Var")
			Case "Object"  : Assert  options("NameOnlyClass") Is t("Var")
			Case "Boolean" : Assert  options("Boolean") = t("Var")
			Case Else : Error
		End Select
	Next
	End If : section.End_

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_IsBitSet] >>> 
'********************************************************************************
Sub  T_IsBitSet( Opt, AppKey )
	Set c = get_SampleConsts()

	Assert  T_IsBitSet_Sub( c.Bit0 ) = "ABb"
	Assert  T_IsBitSet_Sub( c.Bit1 ) = "Bab"
	Assert  T_IsBitSet_Sub( c.Bit0 or c.Bit1 ) = "ABC"
	Assert  T_IsBitSet_Sub( 0 ) = "abc"
	Assert  T_IsBitSet_Sub( Empty ) = "abc"

	Assert  Hex( c.Bit0 ) = "1"
	Assert  Hex( c.Bit1 ) = "2"
	Assert  Hex( c.Bit2 ) = "4"
	Assert  Hex( c.Bit3 ) = "8"
	Assert  Hex( c.Bit4 ) = "10"
	Assert  Hex( c.Bit5 ) = "20"
	Assert  Hex( c.Bit6 ) = "40"
	Assert  Hex( c.Bit7 ) = "80"
	Assert  Hex( c.Bit8 )  = "100"
	Assert  Hex( c.Bit9 )  = "200"
	Assert  Hex( c.Bit10 ) = "400"
	Assert  Hex( c.Bit11 ) = "800"
	Assert  Hex( c.Bit12 ) = "1000"
	Assert  Hex( c.Bit13 ) = "2000"
	Assert  Hex( c.Bit14 ) = "4000"
	Assert  Hex( c.Bit15 ) = "8000"
	Assert  Hex( c.Bit16 ) = "10000"
	Assert  Hex( c.Bit17 ) = "20000"
	Assert  Hex( c.Bit18 ) = "40000"
	Assert  Hex( c.Bit19 ) = "80000"
	Assert  Hex( c.Bit20 ) = "100000"
	Assert  Hex( c.Bit21 ) = "200000"
	Assert  Hex( c.Bit22 ) = "400000"
	Assert  Hex( c.Bit23 ) = "800000"
	Assert  Hex( c.Bit24 ) = "1000000"
	Assert  Hex( c.Bit25 ) = "2000000"
	Assert  Hex( c.Bit26 ) = "4000000"
	Assert  Hex( c.Bit27 ) = "8000000"
	Assert  Hex( c.Bit28 ) = "10000000"
	Assert  Hex( c.Bit29 ) = "20000000"
	Assert  Hex( c.Bit30 ) = "40000000"
	Assert  Hex( c.Bit31 ) = "80000000"

	Pass
End Sub

Function  T_IsBitSet_Sub( BitFlags )
	Set c = get_SampleConsts()
	s = ""
	If IsBitSet(        BitFlags, c.Bit0           ) Then  s = s + "A"
	If IsAnyBitsSet(    BitFlags, c.Bit0 or c.Bit1 ) Then  s = s + "B"
	If IsAllBitsSet(    BitFlags, c.Bit0 or c.Bit1 ) Then  s = s + "C"
	If IsBitNotSet(     BitFlags, c.Bit0           ) Then  s = s + "a"
	If IsAnyBitsNotSet( BitFlags, c.Bit0 or c.Bit1 ) Then  s = s + "b"
	If IsAllBitsNotSet( BitFlags, c.Bit0 or c.Bit1 ) Then  s = s + "c"
	T_IsBitSet_Sub = s
End Function


 
'*************************************************************************
'  <<< [get_SampleConsts] >>>
'*************************************************************************
Dim  g_SampleConsts

Function  get_SampleConsts()
	If IsEmpty( g_SampleConsts ) Then _
		Set g_SampleConsts = new SampleConsts
	Set get_SampleConsts = g_SampleConsts
End Function

Class  SampleConsts
	Public  Bit0, Bit1, Bit2, Bit3, Bit4, Bit5, Bit6, Bit7, Bit8, Bit9
	Public  Bit10, Bit11, Bit12, Bit13, Bit14, Bit15, Bit16, Bit17, Bit18, Bit19
	Public  Bit20, Bit21, Bit22, Bit23, Bit24, Bit25, Bit26, Bit27, Bit28, Bit29
	Public  Bit30, Bit31

	Private Sub  Class_Initialize()
		Bit0  = &h0001
		Bit1  = &h0002
		Bit2  = &h0004
		Bit3  = &h0008
		Bit4  = &h0010
		Bit5  = &h0020
		Bit6  = &h0040
		Bit7  = &h0080
		Bit8  = &h0100
		Bit9  = &h0200
		Bit10 = &h0400
		Bit11 = &h0800
		Bit12 = &h1000
		Bit13 = &h2000
		Bit14 = &h4000
		Bit15 = CLng("&h8000")
		Bit16 = &h00010000
		Bit17 = &h00020000
		Bit18 = &h00040000
		Bit19 = &h00080000
		Bit20 = &h00100000
		Bit21 = &h00200000
		Bit22 = &h00400000
		Bit23 = &h00800000
		Bit24 = &h01000000
		Bit25 = &h02000000
		Bit26 = &h04000000
		Bit27 = &h08000000
		Bit28 = &h10000000
		Bit29 = &h20000000
		Bit30 = &h40000000
		Bit31 = &h80000000
	End Sub

	Public Function  ToStr( Number )
		Select Case  Number
			Case Bit0 : ToStr = "Bit0"
			Case Bit1 : ToStr = "Bit1"
			'// ...
		End Select
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
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
