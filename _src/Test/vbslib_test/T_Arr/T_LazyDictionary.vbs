Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_LazyDictionary_1", _
			"2","T_LazyDictionary_DebugMode", _
			"3","T_LazyDictionary_Each", _
			"4","T_LazyDictionaryXML", _
			"5","T_LazyDictionaryEcho", _
			"6","T_LazyDictionaryReverse", _
			"7","T_LazyDictionaryCSV", _
			"8","T_LazyDictionaryFunction", _
			"9","T_EvaluateByVariableXML_sth" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionary_1] >>> 
'********************************************************************************
Sub  T_LazyDictionary_1( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Others"


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
	Assert  InStr( e2.desc, "${RootPath()}" ) > 0
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


	'//==== AddDictionary
	If section.Start( "T_AddDictionary" ) Then

	'// Set up
	Set g1 = new LazyDictionaryClass
	g1("${Var1}") = "x${Var2}"

	Set g2 = new LazyDictionaryClass
	g2("${Var2}") = "y"
	g2("${Var3}") = "X${Var2}"

	'// Test Main
	g1.AddDictionary  g2

	'// Check
	Assert  g1("${Var1}") = "xy"

	g1("${Var2}") = "z"
	Assert  g1("${Var1}") = "xz"
	Assert  g1("${Var3}") = "Xz"

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

	'// Test Main, Check
	Assert  IsEmpty( g( Null ) )

	'// Set up
	g("${Var1}") = Null
	Assert  IsEmpty( g("${Var1}") )

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
	Set section = new SectionTree
'//SetStartSectionTree  "T_LazyDictionaryXML_Local"

	'//===========================================================
	If section.Start( "T_LazyDictionaryXML_1" ) Then

	'// Set up
	Set root = LoadXML( "Files\T_LazyDictionaryXML.xml", Empty )
	data = root.selectSingleNode( "Data" ).getAttribute( "data" )

	'// Test Main
	Set variables = LoadVariableInXML( root, Empty )
	data = variables( data )

	'// Check
	Assert  data = "ABCDEF"


	For Each  file_path  In  Array( _
			"Files\T_LazyDictionaryXML.xml", _
			GetFullPath( "Files\T_LazyDictionaryXML.xml", Empty ) )

		'// Set up
		Set xml = new FilePathClass
		xml.FilePath = "Files\T_LazyDictionaryXML.xml"
		Set xml.Text = LoadXML( xml.FilePath, Empty )

		'// Test Main
		Set variables = LoadVariableInXML( xml.Text,  xml.FilePath )

		out_string = variables( "${FullPath1}" )
		answer = GetFullPath( "_NotFound.txt", Empty )
		Assert  out_string = answer

		out_string = variables( "${FullPath2}" )
		answer = GetFullPath( "Files\XYZ", Empty )
		Assert  out_string = answer

		out_string = variables( "${FullPath3}" )
		answer = env( "%ProgramFiles%" )
		Assert  out_string = answer

		out_string = variables( "${FullPath4}" )
		answer = GetFullPath( "..\_NotFound.txt", Empty )
		Assert  out_string = answer

		out_string = variables( "${FullPath5}" )
		answer = GetFullPath( "..\..\..\Test\Test.vbs", Empty )
		Assert  out_string = answer

		out_string = variables( "${FullPath6}" )
		answer = GetFullPath( "..\..\..\Test", Empty )
		Assert  out_string = answer

		Assert  g_Vers( TypeName( variables ) ) >= 2
		Assert  variables.Formula( "${FullPath1}" ) = "..\_NotFound.txt"
		Assert  variables.Formula( "${FullPath2}" ) = "${Var3}"
		Assert  variables.Formula( "${FullPath3}" ) = "${ProgramFiles}"
		Assert  variables.Formula( "${FullPath4}" ) = "..\..\_NotFound.txt"
		Assert  variables.Formula( "${FullPath5}" ) = "...\Test\Test.vbs"
		Assert  variables.Formula( "${FullPath6}" ) = "...\Test"
	Next


	'// Clean
	'// Do Nothing


	'// Formula

	'// Set up
	Set t = CreateObject( "Scripting.Dictionary" )
	t("C:\Folder") = GetFullPath( "Files\Folder", Empty )
	Set w_= AppKey.NewWritable( "_out.xml" ).Enable()

	'// Test Main
	path = t("C:\Folder")+"\Sub\Setting.xml"
	base_path = GetParentFullPath( path )
	Set root = LoadXML( path, Empty )

	Set g = LoadVariableInXML( root, path )

	Assert  g.Formula("${FullPath1}") = "..\ABC"
	Assert  g("${FullPath1}")         = t("C:\Folder")+"\ABC"
	Assert  g.Formula("${StepPath}")  = "..\ABC"
	Assert  g.Formula("${ABC}")       = "ABC"
	Assert  g.Formula("${FullPath2}") = "${FullPath1}\File.txt"
	Assert  g.Formula("${FullPath3}") = "${StepPath}\File.txt"
	Assert  g("${FullPath3}")         = t("C:\Folder")+"\Sub\..\ABC\File.txt"

	Set file = OpenForWrite( "_out.xml",  g_VBS_Lib.UTF_8 )
	file.WriteLine  "<?xml version=""1.0"" encoding=""UTF-8""?>"
	file.WriteLine  "<Root>"
	file.WriteLine  ""

	For Each  variable_name  In  Array( "${FullPath1}", "${StepPath}", "${ABC}", "${FullPath2}", "${FullPath3}" )
		If g.Type_( variable_name ) = "" Then
			file.WriteLine  "<Variable  name="""+ variable_name +"""  value="""+ _
				g.Formula( variable_name ) +"""/>"
		Else
			file.WriteLine  "<Variable  name="""+ variable_name +"""  value="""+ _
				g.Formula( variable_name ) +"""  type="""+ g.Type_( variable_name ) +"""/>"
		End If
	Next
	file.WriteLine  ""
	file.WriteLine  "</Root>"
	file = Empty

	'// Check
	AssertFC  "_out.xml",  "Files\Folder\Sub\Setting.xml"

	'// Clean
	del  "_out.xml"

	End If : section.End_



	'//===========================================================
	If section.Start( "T_LazyDictionaryXML_Local" ) Then

	'// Set up
	path = "Files\T_LazyDictionaryXML_Local.xml"
	Set root = LoadXML( path, Empty )
	Set global_variables = LoadVariableInXML( root, path )
	parent_path = GetParentFullPath( path )

	'// Test Main
	Set variables = LoadLocalVariableInXML( root.selectSingleNode( _
		"//Current" ),  global_variables,  path )

	'// Check
	values = variables( "${Local2C}, ${Local2D}, ${Local1A}, ${Local1B}, ${Local0A}, ${Local0B}, "+ _
		"${GlobalA}, ${GlobalB}, ${SameName}, ${Path}" )
	Assert  values = "L2C, L2D, L1A, L1B, L0A, L0B, GA, GB, L2, "+ parent_path +"\G-Full"

	Assert  variables( "${ProjectRoot}" ) = GetFullPath( "ProjectD",  parent_path )

	For Each  name  In  Array( "${Local3A}", "${Local2A}", "${Local2E}", "${Local1C}" )
		Assert  not  variables.Exists( name )
	Next

	For Each  name  In  Array( "${GlobalA}" )  '// Test of checking "variables.Exists"
		Assert  variables.Exists( name )
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_LazyDictionaryXML_LocalExample" ) Then

	For Each  project_name  In  Array( "A", "B", "C" )

		'// Set up
		path = "Files\T_LazyDictionaryXML_Local.xml"
		Set root = LoadXML( path, Empty )
		Set global_variables = LoadVariableInXML( root, path )

		'// Test Main
		Set project_tag = root.selectSingleNode( "Example/Tree/Project"+ project_name )
		Set variables = LoadLocalVariableInXML( project_tag,  global_variables,  path )

		path = project_tag.getAttribute( "path" )
		path = variables( path )

		'// Check
		Assert  path = project_name + project_name +".txt"

	Next

	End If : section.End_


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


 
'********************************************************************************
'  <<< [T_LazyDictionaryReverse] >>> 
'********************************************************************************
Sub  T_LazyDictionaryReverse( Opt, AppKey )
	Set g = new LazyDictionaryClass
	g("${A}") = "AAA"
	g("${B}") = "BB"
	Assert  g.EvaluateReverse( "1AAA2BB3AAA4" ) = "1${A}2${B}3${A}4"

	Set g = new LazyDictionaryClass
	g("${A3}") = "AAA"
	g("${A4}") = "AAAA"
	g("${A2}") = "AA"
	Assert  g.EvaluateReverse( "AAAA" ) = "${A4}"

	Set g = new LazyDictionaryClass
	g("${ShortPart}") = "Folder"
	g("${XA}") = "X:\FolderA"
	g("${XB}") = "X:\FolderB"
	g("${LongPart}") = "FolderA\FileLongLong"
	g("${Extension}") = ".txt"
	Assert  g.GetStepPath( "X:\FolderA\FileLongLong", "X:\" ) = "${XA}\FileLongLong"
	Assert  g.GetStepPath( "C:\FolderA\FileLongLong", "C:\" ) = "${LongPart}"
	Assert  g.GetStepPath( "C:\FolderB", "C:\" ) = "${ShortPart}B"
	Assert  g.GetStepPath( "C:\Sub\FolderB", "C:\Sub" ) = "${ShortPart}B"
	Assert  g.GetStepPath( "C:\Step", "C:\" ) = "Step"
	Assert  g.GetStepPath( "C:\Sub\Step", "C:\Sub" ) = "Step"
	Assert  g.GetStepPath( "C:\Sub\Step", "C:\" ) = "Sub\Step"
	Assert  g.GetStepPath( "C:\FolderA\File.txt", "C:\FolderA" ) = "File${Extension}"
	Assert  g.GetFullPath( "File.txt", "${XA}" ) = "X:\FolderA\File.txt"
	Assert  g.GetFullPath( "${XB}\File.txt", "${XA}" ) = "X:\FolderB\File.txt"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	For Each  value  In  Array( Empty, "StepPath" )
		If not IsEmpty( value ) Then
			g("${A}") = value
		Else
			g.Remove  "${A}"
		End If
		If TryStart(e) Then  On Error Resume Next

			echo  g.GetFullPath( "File.txt", "${A}" )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"
		echo    e2.desc
		Assert  e2.num <> 0
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionaryCSV] >>> 
'********************************************************************************
Sub  T_LazyDictionaryCSV( Opt, AppKey )

	Set g = new LazyDictionaryClass
	g("${F}") = "C:\Fo"

	Assert  g("${ToCSV( %02d, 1, 3 )}") = "01, 02, 03"
	Assert  g("${ToCSV( ${F} (%d), 0, 2 )}") = "C:\Fo (0), C:\Fo (1), C:\Fo (2)"
	Assert  g("${ToCSV( %d, 5, 2 )}") = "5, 4, 3, 2"
	Assert  g("Num = ${ToCSV( %d, 1, 1 )}.") = "Num = 1."

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionaryFunction] >>> 
'********************************************************************************
Sub  T_LazyDictionaryFunction( Opt, AppKey )

	Set g = new LazyDictionaryClass

	Set g("${GetObject()}") = GetRef( "T_LazyDictionaryFunction_GetObject" )

	Assert  g("${GetObject( a,""b"",c )}").Name = " a,""b"",c "

	Set g("${FuncA()}") = GetRef( "T_LazyDictionaryFunction_FuncA" )

	Assert  g("before  ${FuncA( a,""b"",c )}  after") = _
		"before  ( A,""B"",C )  after"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_LazyDictionaryFunction_FuncA] >>> 
'    A sub routine of T_LazyDictionaryFunction.
'********************************************************************************
Function  T_LazyDictionaryFunction_FuncA( ref_Dictionary,  in_FunctionName,  in_Parameter )
	Assert  in_FunctionName = "${FuncA()}"
	T_LazyDictionaryFunction_FuncA = "("+ UCase( in_Parameter ) +")"
End Function


 
'********************************************************************************
'  <<< [T_LazyDictionaryFunction_GetObject] >>> 
'    A sub routine of T_LazyDictionaryFunction.
'********************************************************************************
Function  T_LazyDictionaryFunction_GetObject( ref_Dictionary,  in_FunctionName,  in_Parameter )
	Assert  in_FunctionName = "${GetObject()}"
	Set T_LazyDictionaryFunction_GetObject = new_NameOnlyClass( in_Parameter, Empty )
End Function


 
'********************************************************************************
'  <<< [T_EvaluateByVariableXML_sth] >>> 
'********************************************************************************
Sub  T_EvaluateByVariableXML_sth( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_Replacing.txt" ).Enable()
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )

	copy_ren  "Files\TextBefore.txt", "_Replacing.txt"
	SetTextToClipboard  "${Var1}"

	RunProg  "cscript //nologo  """+ prompt_vbs +"""  EvaluateByVariableXML  "+ _
		"Files\T_LazyDictionaryXML.xml  _Replacing.txt  """"  Quit", ""

	AssertFC  "_Replacing.txt", "Files\TextAfter.txt"

	del  "_Replacing.txt"

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


 
