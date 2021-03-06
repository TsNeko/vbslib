Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_Wildcard1",_
			"2","T_WildcardSort",_
			"3","T_WildcardMulti",_
			"4","T_WildcardMultiRootFolder",_
			"5","T_StrMatchKey",_
			"6","T_ReplaceFileNameWildcard",_
			"7","T_WildcardAbsPath",_
			"8","T_WildcardArrayOfArray",_
			"9","T_ExpandWildcardNotFound",_
			"10","T_EnumFolderObjectDic",_
			"11","T_ToRegExpPattern",_
			"12","T_StringReplaceSet",_
			"13","T_StringReplaceSet_Range",_
			"14","T_MakeShortcutFiles",_
			"15","T_ReplaceShortcutFilesToFiles",_
			"16","T_FindStringLines",_
			"17","T_PathDictionary_1",_
			"18","T_PathDictionary_Wildcard",_
			"19","T_PathDictionary_OverSub",_
			"20","T_PathDictionary_XML",_
			"21","T_PathDictionaries_XML",_
			"22","T_Dic_addFilePaths",_
			"23","T_ArrayFromWildcard1",_
			"24","T_GetInputOutputFilePaths",_
			"25","T_PathNameRegularExpression",_
			"26","T_glob_1",_
			"27","T_IsMatchedWithWildcard",_
			"28","T_ArrayFromWildcard2",_
			"29","T_PathDictionaryDebug" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Wildcard1] >>> 
'- If debug, Run "T_Wildcard1_Main" command directly.
'********************************************************************************
Sub  T_Wildcard1( Opt, AppKey )
	Set w_= AppKey.NewWritable( "T_Wildcard1_log.txt" ).Enable()

	RunProg  "cscript //nologo T_Wildcard.vbs T_Wildcard1_Main", "T_Wildcard1_log.txt"

	AssertFC  "T_Wildcard1_log.txt",  "T_Wildcard1_ans.txt"
	del  "T_Wildcard1_log.txt"
	Pass
End Sub


Sub  T_Wildcard1_Main( Opt, AppKey )
	Set ds = new CurDirStack
If True Then
End If
	EchoExpandWildcard  "data\*.txt", "c.File", True
	EchoExpandWildcard  "data\f*", "c.File", True
	EchoExpandWildcard  "data\f*", "c.Folder", True
	EchoExpandWildcard  "data\*.txt", "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\fo*", "c.Folder or c.SubFolder", True
	EchoExpandWildcard  "data\t*", "c.File or c.Folder or c.SubFolder", True
	EchoExpandWildcard  "data\fo1\*", "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\nothing.txt", "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\no_folder\*", "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\f1.txt", "c.File", True
	EchoExpandWildcard  "data\f1.txt", "c.File", True  '// 2 times
	EchoExpandWildcard  "data\f1.txt", "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\fo1", "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\fo1", "c.Folder", True
	EchoExpandWildcard  "data\fo1", "c.Folder or c.SubFolder", True
	EchoExpandWildcard  "data\Fo1", "c.Folder or c.SubFolder", True
	EchoExpandWildcard  "data\*", "c.File or c.SubFolder or c.EmptyFolder", True
	pushd  "data\fo2"  '// Empty
	EchoExpandWildcard  "*", "c.File or c.SubFolder or c.EmptyFolder", True
	EchoExpandWildcard  "*.ext", "c.File or c.SubFolder or c.EmptyFolder", True
	popd

	'// SubFolderSign (Call "SplitPathToSubFolderSign" in "ExpandWildcard")
	EchoExpandWildcard  "data\f1.txt",   "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\*\f1.txt", "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\.\*.txt",  "c.File or c.SubFolder", True
	EchoExpandWildcard  "data\f1.txt",   "c.File", True
	EchoExpandWildcard  "data\*\f1.txt", "c.File", True
	EchoExpandWildcard  "data\.\*.txt",  "c.File", True
	pushd  "data"
	EchoExpandWildcard  "*\f1.txt", "c.File", True
	popd

	'// "SubFolderIfWildcard"
	EchoExpandWildcard  "data\f1.txt",   "c.File or c.SubFolderIfWildcard", True
	EchoExpandWildcard  "data\f1*.txt",    "c.File or c.SubFolderIfWildcard", True
	EchoExpandWildcard  "data\*\f1.txt", "c.File or c.SubFolderIfWildcard", True
	EchoExpandWildcard  "data\.\*.txt",  "c.File or c.SubFolderIfWildcard", True
	EchoExpandWildcard  "data\*\fo11.ex", "c.Folder or c.SubFolderIfWildcard", True
	EchoExpandWildcard  "data\NotFound", "c.Folder or c.File or c.SubFolderIfWildcard", False
	EchoExpandWildcard  "data\.\NotFound", "c.Folder or c.File or c.SubFolderIfWildcard", False
	EchoExpandWildcard  "data\fo1",   "c.File or c.SubFolderIfWildcard", True
	EchoExpandWildcard  "data\fo1\*", "c.File or c.SubFolderIfWildcard", True
	pushd  "data\fo1\fo1"
	EchoExpandWildcard  "..",         "c.File or c.SubFolderIfWildcard", True
	popd
	EchoExpandWildcard  "data\no_folder\*", "c.File or c.SubFolderIfWildcard", False

	Pass
End Sub


Sub  EchoExpandWildcard( Path, FlagsStr, IsNotError )
	Set c = g_VBS_Lib

	Set paths = new ArrayClass : paths.AddElems  Path

	echo_line
	echo "ExpandWildcard  "+ paths.CSV +"  ("+ FlagsStr +")"

	If IsNotError = False Then
		If TryStart(e) Then  On Error Resume Next
	End If

		If paths.Count = 1 Then
			ExpandWildcard  Path, Eval( FlagsStr ), folder, fnames
		Else
			ExpandWildcard  paths.Items, Eval( FlagsStr ), folder, fnames
		End If

	If IsNotError = False Then
		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num = E_PathNotFound
	End If


	echo  folder
	For Each fname in fnames
		echo  fname
	Next
End Sub


 
'***********************************************************************
'* Function: T_ArrayFromWildcard1
'***********************************************************************
Sub  T_ArrayFromWildcard1( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"  '// 一部のセクションだけ実行するときは有効にする

	'// Test of string or array
	If section.Start( "T_ArrayFromWildcard1" ) Then

	log_path = "T_ArrayFromWildcard1_log.txt"
	Set w_= AppKey.NewWritable( log_path ).Enable()

	RunProg  "cscript //nologo T_Wildcard.vbs T_ArrayFromWildcard1_Main", log_path

	AssertFC  log_path, "T_ArrayFromWildcard1_ans.txt"
	del  log_path

	End If : section.End_


	'// Test of PathDictionaryClass
	If section.Start( "T_ArrayFromWildcard1_Type" ) Then

	Set dic = new PathDictionaryClass
	Assert  ArrayFromWildcard( dic ) Is dic

	End If : section.End_


	Pass
End Sub

Sub  T_ArrayFromWildcard1_Main( Opt, AppKey )
	Set ds = new CurDirStack
If False Then
	Skip
End If
	T_EchoArrayFromWildcard_Sub  "data\.\*.txt", True
	T_EchoArrayFromWildcard_Sub  "data\.\f*", True
	T_EchoArrayFromWildcard_Sub  "data\.\f*\", True
	T_EchoArrayFromWildcard_Sub  "data\*.txt", True
	T_EchoArrayFromWildcard_Sub  "data\f*\", True
	T_EchoArrayFromWildcard_Sub  "data\fo1\*", True
	T_EchoArrayFromWildcard_Sub  "data\fo1", True
	T_EchoArrayFromWildcard_Sub  "data\fo1\", True
	T_EchoArrayFromWildcard_Sub  "data\*\fo1\", True
	T_EchoArrayFromWildcard_Sub  "data\*\fo11.ex\", True
	T_EchoArrayFromWildcard_Sub  "data\fo11.ex", False
	T_EchoArrayFromWildcard_Sub  "data\nothing.txt", False
	T_EchoArrayFromWildcard_Sub  "data\no_folder\*", False
	T_EchoArrayFromWildcard_Sub  "data\no_folder\", False
	T_EchoArrayFromWildcard_Sub  "data\f1.txt", True
	T_EchoArrayFromWildcard_Sub  "data\f1.txt", True
	T_EchoArrayFromWildcard_Sub  "data\*.hta", True
	T_EchoArrayFromWildcard_Sub  "data\*\f1.txt", True
	T_EchoArrayFromWildcard_Sub  "data\NotFound", False
	T_EchoArrayFromWildcard_Sub  "data\.\NotFound", False
	T_EchoArrayFromWildcard_Sub  "data\fo1\", True
	T_EchoArrayFromWildcard_Sub  "data\*\fo1\", True
	T_EchoArrayFromWildcard_Sub  "data\*\Fo1\", True
	T_EchoArrayFromWildcard_Sub  "data\*\", True
	T_EchoArrayFromWildcard_Sub  Array( "data\.\*.txt", "data\.\f*" ), True
	T_EchoArrayFromWildcard_Sub  "data\.\*.txt | data\.\f*", True
	T_EchoArrayFromWildcard_Sub  Array( "data\.\*.txt, data\.\f*", "data\fe\t*" ), True

	pushd  "data\fo1"
	T_EchoArrayFromWildcard_Sub  ".", True
	popd

	Pass
End Sub


Sub  T_EchoArrayFromWildcard_Sub( Path, IsNotError )
	Set paths = new ArrayClass : paths.AddElems  Path

	echo_line
	echo "ArrayFromWildcard  "+ paths.CSV

	If not IsNotError Then
		If TryStart(e) Then  On Error Resume Next
	End If


	For Each full_path in ArrayFromWildcard( Path ).FullPaths


		If not IsNotError Then  '// FullPaths でエラーになったら、ここに来て、Next でエラーになる
			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2
			echo    e2.desc
			Assert  e2.num = E_PathNotFound
			Exit Sub
		End If


		echo  full_path
	Next
End Sub


 
'***********************************************************************
'* Function: T_ArrayFromWildcard2
'***********************************************************************
Sub  T_ArrayFromWildcard2( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_ArrayFromWildcard2_SubFolderSymbol"


	'//===========================================================
	If section.Start( "T_ArrayFromWildcard2_StepPath" ) Then

	'// Test Main
	Set dic = ArrayFromWildcard2( "Files\1" )

	'// Check
	Assert  dic.BasePath = GetFullPath( "Files\1", Empty )
	Assert  IsSameArray( dic.FilePaths, Array( "A.txt", "B.txt", "C.ini", _
		"Except\A.txt", "Except\B.ini", "Sub\A.txt", "Sub\B.ini" ) )


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set dic = ArrayFromWildcard2( "Files\NotFound" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "Files\NotFound" ) >= 1
	Assert  e2.num <> 0

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ArrayFromWildcard2_Wildcard" ) Then

	'// Test Main
	Set dic = ArrayFromWildcard2( "Files\1\*.txt" )

	'// Check
	Assert  dic.BasePath = GetFullPath( "Files\1", Empty )
	Assert  IsSameArray( dic.FilePaths, Array( "A.txt", "B.txt", _
		"Except\A.txt", "Sub\A.txt" ) )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ArrayFromWildcard2_SubFolderSymbol" ) Then

	'// Test Main
	Set dic = ArrayFromWildcard2( "Files\1\*\A.txt" )

	'// Check
	Assert  dic.BasePath = GetFullPath( "Files\1", Empty )
	Assert  IsSameArray( dic.FilePaths, Array( "A.txt", "Except\A.txt", "Sub\A.txt" ) )


	'// Test Main
	Set dic = ArrayFromWildcard2( "data\*\fo1\" )

	'// Check
	Assert  dic.BasePath = GetFullPath( "data", Empty )
	Assert  IsSameArray( dic.FilePaths, Array( "fo1", "fo1\fo1" ) )
	Assert  IsSameArray( dic.FullPaths,  Array( _
		GetFullPath( "data\fo1", Empty ), _
		GetFullPath( "data\fo1\fo1", Empty ) ) )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ArrayFromWildcard2_Multi" ) Then
	base_path = GetFullPath( "Files\T_Multi", Empty )
	For Each  t  In DicTable( Array( _
		"Case",  "Paths",    "BasePathAnswer",   "PathsAnswer",   Empty, _
		0,  Array( ".", "." ),            ".",   Array( "." ), _
		1,  Array( "1.xml", "1.xml" ),    ".",   Array( "1.xml" ), _
		2,  Array( "A\2.xml", "1.xml" ),  ".",   Array( "A\2.xml", "1.xml" ), _
		3,  Array( "1.xml", "A\2.xml" ),   ".",  Array( "1.xml", "A\2.xml" ), _
		4,  Array( "A", "A" ),             "A",  Array( "." ), _
		5,  Array( "A\2.xml", "A" ),       "A",  Array( "2.xml", "." ), _
		6,  Array( "A\2.xml", "A\2.xml" ), "A",  Array( "2.xml" ), _
		7,  Array( "A\AA\3.xml", "A\AA\3B.xml" ), "A\AA",  Array( "3.xml", "3B.xml" ), _
		8,  Array( "A\AA\*\1", "A\2.xml" ),"A",  Array( "AA\*\1", "2.xml" ), _
		9,  Array( "A\*", "A\AA" ),        "A",  Array( "*", "AA" ), _
		10, Array( "..", ".", "A" ),       "..", Array( ".", "T_Multi", "T_Multi\A" ) ) )

		'// Set up
		ReDim  paths( UBound( t("Paths") ) )
		For i=0 To UBound( paths )
			paths(i) = GetFullPath( t("Paths")(i), base_path )
		Next

		'// Test Main
		Set dic = ArrayFromWildcard2( paths )

		'// Check
		Assert  dic.BasePath = GetFullPath( t("BasePathAnswer"), base_path )
		Assert  dic.Count = UBound( t("PathsAnswer") ) + 1
		For Each  path_answer  In  t("PathsAnswer")
			Assert  dic.Exists( path_answer )
		Next
	Next
	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: T_WildcardSort
'***********************************************************************
Sub  T_WildcardSort( Opt, AppKey )
	Dim w_:Set w_= AppKey.NewWritable( "work" ).Enable()
	Dim  folder, fname, fnames()

	g_Vers("CutPropertyM") = True
	g_Vers("ExpandWildcard_Sort") = True

	del    "work"
	mkdir  "work"
	CreateFile  "work\2.txt",  "2"
	CreateFile  "work\11.txt", "11"
	CreateFile  "work\3.txt",  "3"
	echo_line
	ExpandWildcard  "work\*.txt", F_File, folder, fnames
	Assert  IsSameArray( fnames, Array( "2.txt", "3.txt", "11.txt" ) )
	del    "work"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_WildcardMulti
'***********************************************************************
Sub  T_WildcardMulti( Opt, AppKey )
	Dim w_:Set w_= AppKey.NewWritable( "T_WildcardMulti_log.txt" ).Enable()
	RunProg  "cscript //nologo T_Wildcard.vbs T_WildcardMulti_Main", "T_WildcardMulti_log.txt"
	AssertFC  "T_WildcardMulti_log.txt",  "T_WildcardMulti_ans.txt"
	del  "T_WildcardMulti_log.txt"
	Pass
End Sub


Sub  T_WildcardMulti_Main( Opt, AppKey )
	EchoExpandWildcard  Array( "data\fo1\t1\*1.*", "data\fo1\t1\f3.svg" ), "F_File", True
	EchoExpandWildcard  Array( "data\fo1\fo1\*.txt", "data\fo1\t1\f3.*" ), "F_File", True
	EchoExpandWildcard  Array( "data\fo1\*.svg", "data\fo1\.\*.txt" ), _
		"F_File or F_Folder or c.SubFolderIfWildcard", True
	Pass
End Sub


 
'***********************************************************************
'* Function: T_WildcardMultiRootFolder
'***********************************************************************
Sub  T_WildcardMultiRootFolder( Opt, AppKey )
	Dim  folder, fnames(), fname
	Dim  fo, subfo, path1, path2

	Set fo = g_fs.GetFolder( env( "%ProgramFiles%" ) )
	For Each subfo in fo.SubFolders  '// subfo as Folder
		path1 = subfo.Path
		Exit For
	Next

	Set fo = g_fs.GetFolder( env( "%windir%" ) )
	For Each subfo in fo.SubFolders  '// subfo as Folder
		path2 = subfo.Path
		Exit For
	Next

	ExpandWildcard  Array( path1, path2 ), F_Folder, folder, fnames
	Assert  folder = env( "%SystemDrive%" )
	Assert  env( "%SystemDrive%" ) +"\"+ fnames(0) = path1
	Assert  env( "%SystemDrive%" ) +"\"+ fnames(1) = path2

	Pass
End Sub


 
'***********************************************************************
'* Function: T_WildcardAbsPath
'***********************************************************************
Sub  T_WildcardAbsPath( Opt, AppKey )
	Set g = g_VBS_Lib
	g_Vers("CutPropertyM") = True
	g_Vers("ExpandWildcard_Sort") = False
	current_dir = g_sh.CurrentDirectory

	'// Test Main
	ExpandWildcard  "data\fo1\t*", g.File or g.Folder or g.SubFolder or g.AbsPath, _
		folder, fnames

	'// Check
	Assert  IsEmpty( folder )

	fnames = ArrayToNameOnlyClassArray( fnames )
	QuickSort  fnames, 0, UBound( fnames ), GetRef("NameCompare"), StrCompOption( g.CaseSensitive )
	Assert  fnames(0).Name = current_dir +"\data\fo1\fo11.ex\t1.txt"
	Assert  fnames(1).Name = current_dir +"\data\fo1\t1"
	Assert  fnames(2).Name = current_dir +"\data\fo1\t1.txt"
	Assert  fnames(3).Name = current_dir +"\data\fo1\t1\t1.txt"
	Assert  UBound( fnames ) = 3

	Pass
End Sub


 
'***********************************************************************
'* Function: T_WildcardArrayOfArray
'***********************************************************************
Sub  T_WildcardArrayOfArray( Opt, AppKey )
	Set g = g_VBS_Lib
	g_Vers("CutPropertyM") = True
	g_Vers("ExpandWildcard_Sort") = False
	current_dir = g_sh.CurrentDirectory

	'// "g.ArrayOfArray" with "g.AbsPath"
	ExpandWildcard  Array( "data\fo1\t*", "data\fo1\t1\f*", "data\fo1\t1\t*" ), _
		g.File or g.Folder or g.SubFolder or g.AbsPath or g.ArrayOfArray, _
		Empty, fnames

	fnames_0 = ArrayToNameOnlyClassArray( fnames(0).Items )
	QuickSort  fnames_0, 0, UBound( fnames_0 ), GetRef("NameCompare"), StrCompOption( g.CaseSensitive )
	Assert  fnames_0(0).Name = current_dir +"\data\fo1\fo11.ex\t1.txt"
	Assert  fnames_0(1).Name = current_dir +"\data\fo1\t1"
	Assert  fnames_0(2).Name = current_dir +"\data\fo1\t1.txt"
	Assert  fnames_0(3).Name = current_dir +"\data\fo1\t1\t1.txt"

	fnames_1 = ArrayToNameOnlyClassArray( fnames(1).Items )
	QuickSort  fnames_1, 0, UBound( fnames_1 ), GetRef("NameCompare"), StrCompOption( g.CaseSensitive )
	Assert  fnames_1(0).Name = current_dir +"\data\fo1\t1\f1.txt"
	Assert  fnames_1(1).Name = current_dir +"\data\fo1\t1\f2.txt"
	Assert  fnames_1(2).Name = current_dir +"\data\fo1\t1\f3.svg"

	fnames_2 = ArrayToNameOnlyClassArray( fnames(2).Items )
	QuickSort  fnames_2, 0, UBound( fnames_2 ), GetRef("NameCompare"), StrCompOption( g.CaseSensitive )
	Assert  fnames_2(0).Name = current_dir +"\data\fo1\t1\t1.txt"


	'// "g.ArrayOfArray" without "g.AbsPath"
	ExpandWildcard  Array( "data\fo1\t*", "data\fo1\t1\f*", "data\fo1\t1\t*" ), _
		g.File or g.Folder or g.SubFolder or g.ArrayOfArray, _
		folder, fnames

	Assert  folder = current_dir +"\data\fo1"

	fnames_0 = ArrayToNameOnlyClassArray( fnames(0).Items )
	QuickSort  fnames_0, 0, UBound( fnames_0 ), GetRef("NameCompare"), StrCompOption( g.CaseSensitive )
	Assert  fnames_0(0).Name = "fo11.ex\t1.txt"
	Assert  fnames_0(1).Name = "t1"
	Assert  fnames_0(2).Name = "t1.txt"
	Assert  fnames_0(3).Name = "t1\t1.txt"

	fnames_1 = ArrayToNameOnlyClassArray( fnames(1).Items )
	QuickSort  fnames_1, 0, UBound( fnames_1 ), GetRef("NameCompare"), StrCompOption( g.CaseSensitive )
	Assert  fnames_1(0).Name = "t1\f1.txt"
	Assert  fnames_1(1).Name = "t1\f2.txt"
	Assert  fnames_1(2).Name = "t1\f3.svg"

	fnames_2 = ArrayToNameOnlyClassArray( fnames(2).Items )
	QuickSort  fnames_2, 0, UBound( fnames_2 ), GetRef("NameCompare"), StrCompOption( g.CaseSensitive )
	Assert  fnames_2(0).Name = "t1\t1.txt"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ExpandWildcardNotFound
'***********************************************************************
Sub  T_ExpandWildcardNotFound( Opt, AppKey )
	Set c = g_VBS_Lib

	ExpandWildcard  "data\*.not", c.File or c.SubFolder, folder, step_paths
	Assert  UBound( step_paths ) = -1


	'//=== Error Handling Test
	If TryStart(e) Then  On Error Resume Next

		ExpandWildcard  "NotFoundFolder\*", c.File or c.SubFolderIfWildcard, folder, step_paths

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_PathNotFound
	Assert  InStr( e2.desc, "NotFoundFolder\*" )


	'//=== Error Handling Test
	If TryStart(e) Then  On Error Resume Next

		ExpandWildcard  "data\NotFound.not", c.File or c.SubFolderIfWildcard, folder, step_paths

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num = E_PathNotFound
	Assert  InStr( e2.desc, "data\NotFound.not" )


	'//=== Case of "NoError"
	ExpandWildcard  "data\NotFound.not", c.File or c.Folder or c.SubFolderIfWildcard or c.NoError, _
		folder, step_paths
	Assert  UBound( step_paths ) = -1


	Pass
End Sub


 
'***********************************************************************
'* Function: T_PathNameRegularExpression
'***********************************************************************
Sub  T_PathNameRegularExpression( Opt, AppKey )
	Set re = get_PathNameRegularExpression()

	For Each  t  In DicTable( Array( _
		"Case",  "Path",  "Answer",   Empty, _
		1, "sub\a.txt",  Array( "sub\", "a.txt" ), _
		2, "sub2/a.txt\",  Array( "sub2/", "a.txt\" ), _
		3, "sub2\a.txt/",  Array( "sub2\", "a.txt/" ), _
		4, "a.txt",  Array( "a.txt" ), _
		5, "",  Array( ), _
		6, "\a.txt",  Array( "\", "a.txt" ), _
		7, "\\a.txt",  Array( "\", "\", "a.txt" ), _
		8, "http://www.example.com/~user/", _
			Array( "http:/", "/", "www.example.com/", "~user/" ) ))

		Set path_names = re.Execute( t("Path") )

		i_string = 0
		i_array = 0
		For Each  name  In path_names
			answer_name = t("Answer")( i_array )

			echo  name.FirstIndex &": "& name.Value

			Assert  name.FirstIndex = i_string
			Assert  name.Length = Len( answer_name )
			Assert  name.Value = answer_name

			i_string = i_string + Len( answer_name )
			i_array = i_array + 1
		Next
		Assert  i_array = UBound( t("Answer") ) + 1
	Next
	Pass
End Sub


 
'***********************************************************************
'* Function: T_glob_1
'***********************************************************************
Sub  T_glob_1( Opt, AppKey )
	Set w_= AppKey.NewWritable( "T_glob_1_log.txt" ).Enable()
	RunProg  "cscript //nologo  T_Wildcard.vbs  T_glob_1_Main", "T_glob_1_log.txt"
	AssertFC  "T_glob_1_log.txt",  "Files\T_glob_1_ans.txt"
	del  "T_glob_1_log.txt"
	Pass
End Sub

Sub  T_glob_1_Main( Opt, AppKey )
	cd  "Files\T_glob"
	For Each  wildcard  In Array( _
			"*", "*.txt", "s/*.txt", "s\*.txt", "?/*.txt", "*/*.txt",_
			"s/v/*.txt", "s\v\*.txt", "s/*/*.txt", "*/*/*.txt",_
			"[12].txt", "s/[12].txt", "[1-3].txt", "[!1].txt", "[!12].txt", _
			"[012].txt", "(1|2).txt" )
		echo_line
		echo  wildcard
		For Each  name  In  Expand_glob_Pattern( wildcard )
			echo  name
		Next
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_GitIgnore1
'***********************************************************************
Sub  T_GitIgnore1( Opt, AppKey )
	Set w_= AppKey.NewWritable( "T_GitIgnore1_log.txt" ).Enable()
	RunProg  "cscript //nologo  T_Wildcard.vbs  T_GitIgnore1_Main", "T_GitIgnore1_log.txt"
	AssertFC  "T_GitIgnore1_log.txt",  "Files\T_GitIgnore1_ans.txt"
	del  "T_GitIgnore1_log.txt"
	Pass
End Sub

Sub  T_GitIgnore1_Main( Opt, AppKey )
	cd  "Files\T_glob"
	For Each  wildcard  In Array( _
			"*", "*.txt", "s/*.txt", "s\*.txt", "?/*.txt", "*/*.txt",_
			"s/v/*.txt", "s\v\*.txt", "s/*/*.txt", "*/*/*.txt",_
			"[12].txt", "s/[12].txt", "[1-3].txt", "[!1].txt", "[!12].txt", _
			"[012].txt", "(1|2).txt" )
		echo_line
		echo  wildcard
		For Each  name  In  ExpandGitIgnorePattern( wildcard )
			echo  name
		Next
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_GitIgnore2
'***********************************************************************
Sub  T_GitIgnore2( Opt, AppKey )
	cd  "Files\T_glob"
Error
	For Each  wildcards  In Array( _
		Array( "", "" ), _
		Array( "", "" ) )

		echo_line
		echo  new_ArrayClass( wildcards ).CSV


	Next
	Pass
End Sub


 
'***********************************************************************
'* Function: T_IsMatchedWithWildcard
'***********************************************************************
Sub  T_IsMatchedWithWildcard( Opt, AppKey )
	Assert      IsMatchedWithWildcard( "a.txt", "*.txt" )
	Assert  not IsMatchedWithWildcard( "a.ini", "*.txt" )
	Assert      IsMatchedWithWildcard( "a.txt", "a.*" )
	Assert      IsMatchedWithWildcard( "C:\Folder\a.txt", "C:\Folder\*" )
	Assert  not IsMatchedWithWildcard( "C:\Direct\a.txt", "C:\Folder\*" )
	Assert      IsMatchedWithWildcard( "C:\Folder\a.txt", "C:\Folder\*.txt" )
	Assert  not IsMatchedWithWildcard( "C:\Folder\a.ini", "C:\Folder\*.txt" )
	Assert      IsMatchedWithWildcard( "C:\Folder\a.txt", "C:\Folder\a.txt" )
	Assert  not IsMatchedWithWildcard( "C:\Folder\a.ini", "C:\Folder\a.txt" )
	Assert      IsMatchedWithWildcard( "C:\Folder\abc.txt","C:\Folder\*b*.txt" )
	Assert  not IsMatchedWithWildcard( "C:\Folder\abc.txt","C:\Folder\*X*.txt" )
	Assert      IsMatchedWithWildcard( "C:\Folder\abc.txt","*.txt" )
	Assert      IsMatchedWithWildcard(    "Folder\abc.txt","*.txt" )
	Pass
End Sub


 
'***********************************************************************
'* Function: T_Wildcard_Speed
'***********************************************************************
Sub  T_Wildcard_Speed( Opt, AppKey )
	Set g = g_VBS_Lib

	echo  "*_types.vbs ファイルと *_module.vbs ファイルを検索する時間を、関数別に比較します。"
	echo  "ファイル キャッシュに乗せてから（１回検索してから）比較してください。"
	path = InputPath( "調べるフォルダー>", g.CheckFolderExists )


	'//=== ExpandWildcard
	t0 = Timer
	ExpandWildcard  Array( path+"\*_type.vbs", path+"\*_module.vbs" ), _
		g.File or g.Folder or g.SubFolder or g.ArrayOfArray, _
		folder, fnames
	t1 = Timer - t0
	WScript.Echo  "ExpandWildcard > " & FormatNumber( t1, 3 ) & "(sec)"   '// 0.172(sec)


	'//=== EnumFolderObject
	t0 = Timer
	Set fname_key_1 = new StrMatchKey
	fname_key_1.Keyword = LCase( "*_type.vbs" )

	Set fname_key_2 = new StrMatchKey
	fname_key_2.Keyword = LCase( "*_module.vbs" )

	EnumFolderObject  path, folders  '// [out] folders
	For Each fo  In folders  '// fo as Folder
		For Each fi  In fo.Files '// fi as File
			fname = fi.Name
			If fname_key_1.IsMatch( fname ) or fname_key_2.IsMatch( fname ) Then
			End If
		Next
	Next
	t1 = Timer - t0
	WScript.Echo  "EnumFolderObject > " & FormatNumber( t1, 3 ) & "(sec)"   '// 0.125(sec)


	'//=== ArrayFromWildcard
	t0 = Timer
	ArrayFromWildcard( Array( path+"\*\*_type.vbs", path+"\*\*_module.vbs" ) ).FullPaths
	t1 = Timer - t0
	WScript.Echo  "ArrayFromWildcard > " & FormatNumber( t1, 3 ) & "(sec)"   '// 0.297(sec)


	Pause
End Sub


 
'***********************************************************************
'* Function: T_StrMatchKey
'***********************************************************************
Sub  T_StrMatchKey( Opt, AppKey )
	Dim  key : Set key = new StrMatchKey

	key.Keyword = "*.txt"
	Assert     key.IsMatch( "a.txt" )
	Assert     key.IsMatch( "a.TXT" )
	Assert     key.IsMatch( ".txt" )
	Assert     key.IsMatch( "123.txt" )
	Assert     key.IsMatchULCase( "a.txt" )
	Assert not key.IsMatchULCase( "a.TXT" )
	Assert     key.IsMatchULCase( ".txt" )
	Assert     key.IsMatchULCase( "123.txt" )

	Assert not key.IsMatch( "123txt" )
	Assert not key.IsMatch( "123.tx" )
	Assert not key.IsMatch( "" )
	Assert not key.IsMatchULCase( "123txt" )
	Assert not key.IsMatchULCase( "123.tx" )
	Assert not key.IsMatchULCase( "" )


	key.Keyword = "sample*"
	Assert     key.IsMatch( "sample123" )
	Assert     key.IsMatch( "sample" )
	Assert     key.IsMatch( "SampleX" )
	Assert     key.IsMatchULCase( "sample123" )
	Assert     key.IsMatchULCase( "sample" )
	Assert not key.IsMatchULCase( "SampleX" )

	Assert not key.IsMatch( "Xsample" )
	Assert not key.IsMatch( "sampl" )
	Assert not key.IsMatch( "" )
	Assert not key.IsMatchULCase( "Xsample" )
	Assert not key.IsMatchULCase( "sampl" )
	Assert not key.IsMatchULCase( "" )


	key.Keyword = "a.txt"
	Assert     key.IsMatch( "a.txt" )
	Assert     key.IsMatch( "a.TXT" )
	Assert     key.IsMatch( "a.txt" )
	Assert not key.IsMatchULCase( "a.TXT" )

	Assert not key.IsMatch( "a.txtx" )
	Assert not key.IsMatch( "aa.txt" )
	Assert not key.IsMatch( ".txt" )
	Assert not key.IsMatchULCase( "a.txtx" )
	Assert not key.IsMatchULCase( "aa.txt" )
	Assert not key.IsMatchULCase( ".txt" )


	key.Keyword = "*"
	Assert     key.IsMatch( "a.txt" )
	Assert     key.IsMatch( "" )
	Assert     key.IsMatchULCase( "a.txt" )
	Assert     key.IsMatchULCase( "" )


	key.Keyword = ""
	Assert     key.IsMatch( "" )
	Assert     key.IsMatchULCase( "" )

	Assert not key.IsMatch( "a.txt" )
	Assert not key.IsMatchULCase( "a.txt" )

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ReplaceFileNameWildcard
'***********************************************************************
Sub  T_ReplaceFileNameWildcard( Opt, AppKey )

	'// left *
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*.txt", "Fo\*.ini" )     = "Fo\File.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "FO\*.TXT", "Fo\*.ini" )     = "Fo\File.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*.txt", "FFF\*.ini" )    = "FFF\File.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*.txt", "F\F\*.ini" )    = "F\F\File.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*.txt", "Fo\Sub\*.ini" ) = "Fo\Sub\File.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*.txt", "" ) = ""

	'// middle *
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\Fi*.txt", "Fo\*.ini" )      = "Fo\le.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "FO\FI*.TXT", "F\X*.ini" )      = "F\Xle.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\Fi*.txt", "F\X*.ini" )      = "F\Xle.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\Fi*.txt", "Fo\Sub\X*.ini" ) = "Fo\Sub\Xle.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\Fi*.txt", "" ) = ""

	'// right *
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\File.*", "Fo\FFF.*" )     = "Fo\FFF.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "FO\FILE.*", "F\FF\FFF.*" )   = "F\FF\FFF.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\File.*", "Fo\Sub\FFF.*" ) = "Fo\Sub\FFF.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*",      "Fo\Sub\*" )     = "Fo\Sub\File.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\FILE.*", "" ) = ""

	'// double *
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*le.*", "Fo\*FFF.*" )     = "Fo\FiFFF.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "FO\*LE.*", "F\F\*FFF.*" )    = "F\F\FiFFF.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*le.*", "Fo\Sub\*FFF.*" ) = "Fo\Sub\FiFFF.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*le.*", "" ) = ""

	'// no wildcard
	Assert  ReplaceFileNameWildcard( "Fo\File.txt",     "FO\FILE.txt", "F\F\FFF.ini" ) = "F\F\FFF.ini"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt",     "FO",          "FFF" )         = "FFF\File.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt",     "FO",          "FFF\sub" )     = "FFF\sub\File.txt"
	Assert  ReplaceFileNameWildcard( "Fo\Sub\File.txt", "FO\sub",      "FFF" )         = "FFF\File.txt"
	Assert  ReplaceFileNameWildcard( "Fo\File.txt",     "Fo\FILE.txt", "" ) = ""

	'// not match
	Assert  IsEmpty( ReplaceFileNameWildcard( "Fo\File.txt", "NotMatch.txt",      "Fo\*.ini" ) )
	Assert  IsEmpty( ReplaceFileNameWildcard( "Fo\File.txt", "NotMatch\File.txt", "Fo\*.ini" ) )
	Assert  IsEmpty( ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*NotMatch.txt",  "Fo\*.ini" ) )
	Assert  IsEmpty( ReplaceFileNameWildcard( "Fo\File.txt", "Fo\NotMatch*.txt",  "Fo\*.ini" ) )
	Assert  IsEmpty( ReplaceFileNameWildcard( "Fo\File.txt", "Fo\NotMatch.*",     "Fo\*.ini" ) )
	Assert  IsEmpty( ReplaceFileNameWildcard( "Fo\File.txt", "Fo\*NotMatch.*",    "Fo\*.ini" ) )

	'// from bug report
	Assert  IsEmpty( ReplaceFileNameWildcard( "LongFolder\File.txt", "F\*.txt", "F\*.ini" ) )
	Assert  IsEmpty( ReplaceFileNameWildcard( "File.txt", "Folder\*le.*", "Folder\*LE.*" ) )


	Dim  e, e2, t
	For Each  t  In  DicTable( Array( _
		 "Name",          "Str",             "FromStr",      "ToStr",   Empty, _
		 "T_Increase",    "Fo\BadWild.txt",  "Fo\*.txt",     "Fo\*.*", _
		 "T_FolderWild",  "Fo\File.txt",     "F*\File.txt",  "F*\File.txt", _
		 "T_Reduce1",     "Fo\File.txt",     "Fo\*le.*",     "F\F\*FFF.ini", _
		 "T_Reduce2",     "Fo\File.txt",     "Fo\*le.txt",   "F\F\FFF.ini" ) )

		If TryStart(e) Then  On Error Resume Next

			ReplaceFileNameWildcard  t("Str"), t("FromStr"), t("ToStr")

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo  e2.desc
		Assert  e2.num = 1
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_EnumFolderObjectDic
'***********************************************************************
Sub  T_EnumFolderObjectDic( Opt, AppKey )
	Set ds = new CurDirStack

	'//=== Case of basic

	For Each  is_current  In  Array( False, True )

		'// Set up
		If is_current Then _
			pushd  "data"

		'// Test Main
		If not is_current Then
			EnumFolderObjectDic  "data",  Empty,  folders
		Else
			EnumFolderObjectDic  ".",  Empty,  folders
		End If

		'// Check
		ShakerSort_fromDicKey  folders,  folders2,  Empty
		Assert  UBound( folders2 ) + 1 = 7
		Assert  folders2(0).Key = "."
		Assert  folders2(1).Key = "fe"
		Assert  folders2(2).Key = "fo1"
		Assert  folders2(3).Key = "fo1\fo1"
		Assert  folders2(4).Key = "fo1\fo11.ex"
		Assert  folders2(5).Key = "fo1\t1"
		Assert  folders2(6).Key = "fo2"

		'// Clean
	Next


	'//=== Case of not found at parameter 1

	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		EnumFolderObjectDic  "not_found", Empty, folders

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "not_found" ) > 0
	Assert  e2.num <> 0


	Pass
End Sub


 
'***********************************************************************
'* Function: T_ToRegExpPattern
'***********************************************************************
Sub  T_ToRegExpPattern( Opt, AppKey )

	Set re = CreateObject("VBScript.RegExp")

	For Each t  In DicTable( Array( _
		"Keyword",  "Text",   Empty, _
		"\a",       "b\ac", _
		"(a)",      "b(a)c", _
		"{a}",      "b{a}c", _
		"[a]",      "b[a]c", _
		".$^|*+?",  "--.$^|*+?" ) )

		re.Pattern = ToRegExpPattern( t("Keyword") )
		Set matches = re.Execute( t("Text") )
		echo  "match = "+ matches(0).Value
		Assert  matches(0).Value = t("Keyword")
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_StringReplaceSet
'***********************************************************************
Sub  T_StringReplaceSet( Opt, AppKey )

	'//=== Basic case

	input_text = _
		"***********"+ vbCRLF +_
		"from  abc  from"+ vbCRLF +_
		"****"+ vbCRLF +_
		"abc  from"+ vbCRLF +_
		"****"+ vbCRLF

	answer_text_1 = _
		"***********"+ vbCRLF +_
		"to  abc  to"+ vbCRLF +_
		"****"+ vbCRLF +_
		"abc  to"+ vbCRLF +_
		"****"+ vbCRLF

	Set op = new StringReplaceSetClass
	op.Replace  "from", "to"
	output_text = op.DoReplace( input_text )

	Assert  output_text = answer_text_1


	'//=== 二重展開をしないテスト : １行内

	answer_text_2 = _
		"***********"+ vbCRLF +_
		"from  abc  def  from"+ vbCRLF +_
		"****"+ vbCRLF +_
		"abc  def  from"+ vbCRLF +_
		"****"+ vbCRLF

	Set op = new StringReplaceSetClass
	op.Replace  "abc", "abc  def"
	output_text = op.DoReplace( input_text )

	Assert  output_text = answer_text_2


	'//=== 二重展開をしないテスト : 複数行

	answer_text_3 = _
		"***********"+ vbCRLF +_
		"from  abc  from"+ vbCRLF +_
		"-------"+ vbCRLF +_
		"****"+ vbCRLF +_
		"abc  from"+ vbCRLF +_
		"-------"+ vbCRLF +_
		"****"+ vbCRLF

	Set op = new StringReplaceSetClass
	op.Replace  "abc  from", "abc  from"+vbCRLF+"-------"
	output_text = op.DoReplace( input_text )

	Assert  output_text = answer_text_3


	'//=== Multi replace

	answer_text_4 = _
		"***********"+ vbCRLF +_
		"to  def  to"+ vbCRLF +_
		"****"+ vbCRLF +_
		"def  to"+ vbCRLF +_
		"****"+ vbCRLF

	Set op = new StringReplaceSetClass
	op.Replace  "from", "to"
	op.Replace  "abc", "def"
	output_text = op.DoReplace( input_text )

	Assert  output_text = answer_text_4


	Pass
End Sub


 
'***********************************************************************
'* Function: T_StringReplaceSet_Range
'***********************************************************************
Sub  T_StringReplaceSet_Range( Opt, AppKey )

	'//===

	input_text_1 = _
		"start"+ vbCRLF +_
		"abc<Replace>123</Replace>def"+ vbCRLF +_
		"end"+ vbCRLF

	answer_text_1 = _
		"start"+ vbCRLF +_
		"abc<Replace>456</Replace>def"+ vbCRLF +_
		"end"+ vbCRLF

	Set op = new StringReplaceSetClass
	op.ReplaceRange  "<Replace>", "</Replace>", "<Replace>456</Replace>"
	output_text = op.DoReplace( input_text_1 )

	Assert  output_text = answer_text_1


	'//===

	input_text_2 = _
		"start"+ vbCRLF +_
		"abc<Replace>123"+ vbCRLF +_
		"456"+ vbCRLF +_
		"789</Replace>def"+ vbCRLF +_
		"end"+ vbCRLF

	answer_text_2 = _
		"start"+ vbCRLF +_
		"abc<Replace>abc"+ vbCRLF +_
		"def"+ vbCRLF +_
		"ghi"+ vbCRLF +_
		"xyz</Replace>def"+ vbCRLF +_
		"end"+ vbCRLF

	Set op = new StringReplaceSetClass
	op.ReplaceRange  "<Replace>", "</Replace>", "<Replace>456</Replace>"
	output_text = op.DoReplace( input_text_2 )

	Assert  output_text = answer_text_1


	Set op = new StringReplaceSetClass
	op.ReplaceRange  "<Replace>", "</Replace>", _
		"<Replace>abc"+ vbCRLF +"def"+ vbCRLF +"ghi"+ vbCRLF +"xyz</Replace>"
	output_text = op.DoReplace( input_text_2 )

	Assert  output_text = answer_text_2


	If TryStart(e) Then  On Error Resume Next
		Set op = new StringReplaceSetClass
		op.ReplaceRange  "<Replace>", "</NotFound>", _
				"<Replace>abc"+ vbCRLF +"def"+ vbCRLF +"ghi"+ vbCRLF +"xyz</Replace>"
		output_text = op.DoReplace( input_text_2 )
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	If e2.num <> E_NotFoundSymbol Then  e2.Raise


	'//=== Multi replace

	input_text_3  = "abcdefg(1)[2]"
	answer_text_3 = "xxdey(8)[99]"

	Set op = new StringReplaceSetClass
	op.Replace  "abc", "xx"
	op.Replace  "fg", "y"
	op.ReplaceRange  "(", ")", "(8)"
	op.ReplaceRange  "[", "]", "[99]"
	output_text = op.DoReplace( input_text_3 )

	Assert  output_text = answer_text_3


	Pass
End Sub


 
'***********************************************************************
'* Function: T_MakeShortcutFiles
'***********************************************************************
Sub  T_MakeShortcutFiles( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( Array( "_work", "_work2" ) ).Enable()

	'// Set up
	del  "_work"
	del  "_work2"
	CreateFile  "_work\1.txt", "1"
	CreateFile  "_work\sub\2.txt", "2"


	'// Test of 1 file
	copy_ex  "_work\1.txt", "_work2", c.MakeShortcutFiles

	'// Check
	Assert  g_sh.CreateShortcut( "_work2\1.lnk" ).TargetPath = _
		GetFullPath( "_work\1.txt", Empty )

	'// Clean
	del  "_work2"


	'// Test of files
	copy_ex  "_work\*", "_work2", c.MakeShortcutFiles

	'// Check
	Assert  g_sh.CreateShortcut( "_work2\1.lnk" ).TargetPath = _
		GetFullPath( "_work\1.txt", Empty )
	Assert  g_sh.CreateShortcut( "_work2\sub\2.lnk" ).TargetPath = _
		GetFullPath( "_work\sub\2.txt", Empty )

	'// Clean
	del  "_work2"


	'// Clean
	del  "_work"
	del  "_work2"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ReplaceShortcutFilesToFiles
'***********************************************************************
Sub  T_ReplaceShortcutFilesToFiles( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_=AppKey.NewWritable( Array( "_work", "_work2" ) ).Enable()

	'// Set up
	del  "_work"
	del  "_work2"
	CreateFile  "_work\1.txt", "1"
	CreateFile  "_work\sub\2.txt", "2"
	copy_ex  "_work\*", "_work2", c.MakeShortcutFiles
	CreateFile  "_work2\sub\3.txt", "2"


	'// Test of files
	ReplaceShortcutFilesToFiles  "_work2", Empty


	'// Check
	Assert  ReadFile( "_work2\1.txt" ) = "1"
	Assert  ReadFile( "_work2\sub\2.txt" ) = "2"


	'// Clean
	del  "_work"
	del  "_work2"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ExceptByWildcard
'***********************************************************************
Sub  T_ExceptByWildcard( Opt, AppKey )
	Set c = g_VBS_Lib
	ExpandWildcard  "data\*", ""

	Pass
End Sub


 
'***********************************************************************
'* Function: T_FindStringLines
'***********************************************************************
Sub  T_FindStringLines( Opt, AppKey )
	Assert  FindStringLines( "abc"+ vbCRLF +"def", "ab", Empty ) = "abc"+ vbCRLF
	Assert  FindStringLines( "abc"+ vbCRLF +"def", "zxz", Empty ) = ""
	Assert  FindStringLines( "abc"+ vbCRLF +"def", "d.*f", Empty ) = "def"
	Assert  FindStringLines( "abc"+ vbCRLF +"def", ".*", Empty ) = "abc"+ vbCRLF +"def"
	Assert  FindStringLines( "abc"+ vbCRLF +"def", ".*", False ) = ""
	Assert  FindStringLines( "abc"+ vbCRLF +"def", "a", False ) = "def"

	Assert  SortStringLines( "b"+ vbCRLF +"a"+ vbCRLF,  False ) = "a"+ vbCRLF +"b"+ vbCRLF
	Assert  SortStringLines( "b"+ vbCRLF +"a",          False ) = "a"+ vbCRLF +"b"+ vbCRLF
	Assert  SortStringLines( "a"+ vbCRLF +"b",          False ) = "a"+ vbCRLF +"b"+ vbCRLF
	Assert  SortStringLines( "b"+ vbLF   +"a"+ vbCRLF,  False ) = "a"+ vbCRLF +"b"+ vbLF
	Assert  SortStringLines( "a"+ vbCRLF +"a"+ vbCRLF,  False ) = "a"+ vbCRLF
	Assert  SortStringLines( "a"+ vbLF   +"a"+ vbCRLF,  False ) = "a"+ vbLF
	Assert  SortStringLines( "a"+ vbCRLF +"a"+ vbCRLF,  True  ) = "a"+ vbCRLF +"a"+ vbCRLF
	Assert  SortStringLines( "a"+ vbLF   +"a"+ vbCRLF,  True  ) = "a"+ vbLF   +"a"+ vbCRLF


	lines0 = _
		"A [Filter]"+ vbCRLF +_
		"B"+ vbCRLF +_
		"C [Filter]"+ vbCRLF +_
		"B"+ vbCRLF +_
		"F [FILTER]"+ vbCRLF +_
		"B"+ vbCRLF +_
		"C [Filter]"

	lines = lines0
	lines = FindStringLines( lines, new_RegExp( "\[Filter\]", False ), True )
	lines = SortStringLines( lines, False )

	Assert  lines = _
		"A [Filter]"+ vbCRLF +_
		"C [Filter]"+ vbCRLF +_
		"F [FILTER]"+ vbCRLF

	lines = lines0
	lines = FindStringLines( lines, new_RegExp( "\[Filter\]", True ), True )
	lines = SortStringLines( lines, True )

	Assert  lines = _
		"A [Filter]"+ vbCRLF +_
		"C [Filter]"+ vbCRLF +_
		"C [Filter]"+ vbCRLF

	Pass
End Sub


 
'***********************************************************************
'* Function: T_PathDictionary_1
'***********************************************************************
Sub  T_PathDictionary_1( Opt, AppKey )
	Set  a_item = new NameOnlyClass : a_item.Name = "a_item"
	Set section = new SectionTree
'//SetStartSectionTree  "T_PathDictionary_WildcardExcepted"


	If section.Start( "T_PathDictionary_1" ) Then

	'// Test Main and Check
	Set  dic = new PathDictionaryClass
	Set  dic( "Files\1" ) = a_item
	keys = dic.Keys
	Assert  IsSameArray( keys, Array( "Files\1" ) )

	keys = dic.FilePaths
	keys_answer = Array( "Files\1\A.txt", "Files\1\B.txt", "Files\1\C.ini", _
		"Files\1\Except\A.txt", "Files\1\Except\B.ini", _
		"Files\1\Sub\A.txt", "Files\1\Sub\B.ini" )
	Assert  IsSameArray( keys,  keys_answer )
	For Each  key  In keys
		Assert  dic( key ) Is a_item
		Assert  dic.FileExists( key )
		Assert  dic.FileExists( GetFullPath( key, Empty ) )
	Next

	Assert  not dic.FileExists( "NotFound" )
	Assert  not dic.FileExists( GetFullPath( "NotFound", Empty ) )

	keys = dic.FolderPaths
	keys_answer = Array( "Files", "Files\1", "Files\1\Except", "Files\1\Sub" )
	Assert  IsSameArray( keys,  keys_answer )
	Assert      dic.FolderExists( "Files" )
	Assert  not dic.FolderExists( "NotFound" )
	Assert  not dic.FolderExists( "Files\1\A.txt" )
	Assert      dic.FolderExists( GetFullPath( "Files", Empty ) )
	Assert  not dic.FolderExists( GetFullPath( "NotFound", Empty ) )
	Assert  not dic.FolderExists( GetFullPath( "Files\1\A.txt", Empty ) )

	keys = dic.DeleteFolderPaths
	keys_answer = Array( "Files" )
	Assert  IsSameArray( keys,  keys_answer )
	Assert      dic.DeleteFolderExists( "Files" )
	Assert      dic.DeleteFolderExists( "Files\1" )
	Assert      dic.DeleteFolderExists( "Files\1\Sub" )
	Assert      dic.DeleteFolderExists( "Files\1\Except" )
	Assert  not dic.DeleteFolderExists( "NotFound" )
	Assert  not dic.DeleteFolderExists( "Files\1\A.txt" )
	Assert      dic.DeleteFolderExists( GetFullPath( "Files", Empty ) )
	Assert      dic.DeleteFolderExists( GetFullPath( "Files\1", Empty ) )
	Assert      dic.DeleteFolderExists( GetFullPath( "Files\1\Sub", Empty ) )
	Assert      dic.DeleteFolderExists( GetFullPath( "Files\1\Except", Empty ) )
	Assert  not dic.DeleteFolderExists( GetFullPath( "NotFound", Empty ) )
	Assert  not dic.DeleteFolderExists( GetFullPath( "Files\1\A.txt", Empty ) )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_NotFound" ) Then

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	Set  dic = new PathDictionaryClass
	If TryStart(e) Then  On Error Resume Next

		Set dummy = dic( "Unknown" )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "Unknown" ) > 0
	Assert  e2.num = 9


	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	Set  dic = new PathDictionaryClass
	Set dic( "Unknown" ) = a_item
	If TryStart(e) Then  On Error Resume Next

		dummy = dic.FilePaths

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "Unknown" ) > 0
	Assert  e2.num = E_PathNotFound


	'// Test Main : Check NoError
	Set  dic = new PathDictionaryClass
	dic.AddRemove  "Unknown"
	dic.AddRemove  "Unknown\*.txt"
	dummy = dic.FilePaths


	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_Wildcard1" ) Then

	'// Set up
	Set  dic = new PathDictionaryClass
	dic.BasePath = "Files\1"

	'// Test Main
	Set  dic( "*" ) = a_item

	'// Check
	Assert  IsSameArray( dic.FilePaths, Array( "A.txt", "B.txt", "C.ini", _
		"Except\A.txt", "Except\B.ini", "Sub\A.txt", "Sub\B.ini" ) )

	'// Set up
	dic.BasePath = "Files\1\Sub"

	'// Test Main
	Set  dic( "*" ) = a_item

	'// Check
	Assert  IsSameArray( dic.FilePaths, Array( "A.txt", "B.ini" ) )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_WildcardExcepted" ) Then

	'//=====
	'// Set up
	Set  dic = new PathDictionaryClass
	dic.BasePath = "Files\Project"

	'// Test Main
	Set       dic( "." ) = a_item
	dic.AddRemove  "*.obj"
	dic.AddRemove  "*\Debug\"

	'// Check
	keys = dic.FilePaths
	Assert  IsSameArray( keys, Array( _
		"A\A.txt", "B\A.txt", "C\C\A.txt", "MD5List.txt" ) )

	'//=====
	'// Set up
	Set  dic = new PathDictionaryClass
	dic.BasePath = "data"

	'// Test Main
	Set       dic( "*.svg" ) = a_item
	dic.AddRemove  "fo1\f3.svg"

	'// Check
	keys = dic.FilePaths
	Assert  IsSameArray( keys, Array( _
		"f3.svg", "fe\f3.svg", "fo1\fo11.ex\f3.svg", "fo1\t1\f3.svg" ) )

	'//=====
	'// Set up
	Set  dic = new PathDictionaryClass
	dic.BasePath = "data"

	'// Test Main
	Set       dic( "fo1\f3.svg" ) = a_item
	dic.AddRemove  "*.svg"

	'// Check
	Set  dic( "." ) = a_item
	dic.AddRemove  "*.txt"
	keys = dic.FilePaths
	Assert  IsSameArray( keys, Array( _
		"fo1\f3.svg" ) )

	'//=====
	'// Set up
	Set  dic = new PathDictionaryClass
	dic.BasePath = "data"

	'// Test Main
	Set       dic( "fo1" ) = a_item
	dic.AddRemove  "*.svg"

	'// Check
	Set  dic( "." ) = a_item
	dic.AddRemove  "*.txt"
	keys = dic.FilePaths
	Assert  IsSameArray( keys, Array( ) )

	'//=====
	'// Set up
	Set  dic = new PathDictionaryClass
	dic.BasePath = "data"

	'// Test Main
	Set       dic( "*.svg" ) = a_item
	dic.AddRemove  "fo1"
	dic.AddRemove  "fo1\t1\*.svg"

	'// Check
	keys = dic.FilePaths
	Assert  IsSameArray( keys, Array( _
		"f3.svg", "fe\f3.svg", "fo1\f3.svg", "fo1\fo11.ex\f3.svg" ) )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_Sorted" ) Then

	'// Set up
	Set  dic = new PathDictionaryClass
	dic.BasePath = "Files"
	Set  dic( "Files1B.xml" ) = a_item
	Set  dic( "Files1.xml" ) = a_item
	Set  dic( "1\A.txt" ) = a_item

	'// Test Main and Check
	Assert  IsSameArray( dic.FilePaths, Array( "1\A.txt", "Files1.xml", "Files1B.xml" ) )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_Zero" ) Then

	'// Test Main and Check
	Set  dic = new PathDictionaryClass
	Assert  UBound( dic.FilePaths ) = -1

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_SearchParent" ) Then

	'// Set up
	types = DicTable( Array( _
		"TypeName",     "IsDicFullPath",  "IsSearchKeyFullPath",   Empty, _
		_
		"Dictionary",          False,     False, _
		"Dictionary",          True,      False, _
		"Dictionary",          True,      True, _
		"PathDictionaryClass", False,     False, _
		"PathDictionaryClass", True,      False, _
		"PathDictionaryClass", True,      True ) )

	keys = Array( "File.txt", "123", "123\456" )

	cases = DicTable( Array( _
		"SearchKeyPath",  "AnswerPath",  Empty, _
		_
		"123\456\a.txt",  "123\456", _
		"123\X\a.txt",    "123", _
		"123\4567\a.txt", "123", _
		"1234\a.txt",     Empty, _
		"123",            Empty, _
		"a.txt",          Empty ) )

	For Each  t  In types

		'// Set up
		If t("TypeName") = "Dictionary" Then
			Set  dic = CreateObject( "Scripting.Dictionary" )

			If t("IsDicFullPath")  and  not t("IsSearchKeyFullPath") Then
				base_path = g_sh.CurrentDirectory
			Else
				base_path = Empty
			End If
		Else
			Set  dic = new PathDictionaryClass
			dic.BasePath = "."
		End If
		For Each  key  In keys
			Set dic( gs_GetFullPathOrNot( key, t("IsDicFullPath") ) ) = a_item
		Next
		For Each  cs  In cases

			'// Test Main and Check
			search_key_path = gs_GetFullPathOrNot( cs("SearchKeyPath"), t("IsSearchKeyFullPath") )
 			answer_path = gs_GetFullPathOrNot( cs("AnswerPath"), t("IsDicFullPath") )

			If t("TypeName") = "Dictionary" Then
				If IsEmpty( cs("AnswerPath") ) Then
					Assert  IsEmpty( Dic_searchParent( dic, base_path, search_key_path ) )
				Else
					Assert  Dic_searchParent( dic, base_path, search_key_path ) = answer_path
				End If
			Else
				If IsEmpty( cs("AnswerPath") ) Then
					Assert  IsEmpty( dic.SearchParent( search_key_path ) )
				Else
					Assert  dic.SearchParent( search_key_path ) = answer_path
				End If
			End If
		Next
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_SearchChildren" ) Then

	'// Set up
	types = DicTable( Array( _
		"IsDicFullPath",  "IsSearchKeyFullPath",   Empty, _
		_
		False,  False, _
		True,   False, _
		True,   True ) )

	keys = Array( "123\456", "123\456\File.txt" )

	cases = DicTable( Array( _
		"SearchKeyPath",  "AnswerPaths",  Empty, _
		_
		"123",      Array( "123\456", "123\456\File.txt" ), _
		"123\456",  Array( "123\456\File.txt" ), _
		"12",       Array( ) ) )

	For Each  t  In types

		'// Set up
		Set  dic = CreateObject( "Scripting.Dictionary" )
		For Each  key  In keys
			Set dic( gs_GetFullPathOrNot( key, t("IsDicFullPath") ) ) = a_item
		Next
		If t("IsDicFullPath")  and  not t("IsSearchKeyFullPath") Then
			base_path = g_sh.CurrentDirectory
		Else
			base_path = Empty
		End If

		For Each  cs  In cases

			'// Test Main
			search_key_path = gs_GetFullPathOrNot( cs("SearchKeyPath"), t("IsSearchKeyFullPath") )

			Dic_searchChildren  dic,  base_path,  search_key_path,  an_array,  Empty  '//(out)an_array


			'// Check
			If t("IsDicFullPath") Then
				ReDim  answer_paths( UBound( cs("AnswerPaths") ) )
				For index = 0  To UBound( answer_paths )
					answer_paths( index ) = GetFullPath( cs("AnswerPaths")( index ), Empty )
				Next
				Assert  IsSameArray( an_array, answer_paths )
			Else
				Assert  IsSameArray( an_array, cs("AnswerPaths") )
			End If
		Next
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_LeafPaths" ) Then

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		copy  "Files\1\*", "_work"
		mkdir  "_work\Empty"
		mkdir  "_work\Sub\Empty"
		Set  a_item = new NameOnlyClass : a_item.Name = "a_item"

		'// Test Main
		Set  dic = new PathDictionaryClass
		dic.BasePath = "_work"
		Set  dic( "Empty" ) = a_item
		Set  dic( "Sub" ) = a_item

		'// Check
		paths = dic.LeafPaths
		Assert  IsSameArray( paths, Array( "Empty\", "Sub\A.txt", "Sub\B.ini", "Sub\Empty\" ) )

		If False Then  '// Not supported yet
		For Each  path  In  dic.LeafPaths
			Assert  dic( path ) = a_item
		Next
		End If

		'// Clean
		del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_OldBugCase1" ) Then

		'// Set up
		Set w_= AppKey.NewWritable( "_work" ).Enable()
		del  "_work"
		mkdir  "_work"

		'// Test Main
		Set paths = new PathDictionaryClass
		paths.BasePath = "_work"
		Set paths( "*" ) = Nothing
		paths.AddRemove  "_FullSet.txt"

		'// Check
		Assert  UBound( paths.FilePaths ) = -1

		'// Clean
		del  "_work"

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_PathDictionary_Wildcard
'***********************************************************************
Sub  T_PathDictionary_Wildcard( Opt, AppKey )
	Set section = new SectionTree
	Set  a_item = new NameOnlyClass : a_item.Name = "a_item"

'//SetStartSectionTree  "T_Sample2"  '// 一部のセクションだけ実行するときは有効にする

	If section.Start( "T_PathDictionary_Wildcard_1" ) Then

		'// Test Main
		Set  dic = new PathDictionaryClass
		Set  dic( "Files\1\*\*.ini" ) = a_item

		'// Check
		keys = dic.FilePaths
		keys_answer = Array( "Files\1\C.ini", "Files\1\Except\B.ini", "Files\1\Sub\B.ini" )
		Assert  IsSameArray( keys,  keys_answer )
		For Each  key  In keys
			Assert  dic( key ) Is a_item
		Next


		'// Test Main
		Set  dic( "Files\1\Unknown.txt" ) = a_item

		'// Check
		If TryStart(e) Then  On Error Resume Next

			keys = dic.FilePaths

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num = E_PathNotFound

	End If : section.End_


	If section.Start( "T_PathDictionary_Wildcard_Keys" ) Then

		'// Test Main
		Set  dic = new PathDictionaryClass
		Set  dic( "Files\1\*\A.*" ) = a_item
		Set  dic( "Files\1\*\C.*" ) = a_item

		'// Check
		keys = dic.FilePaths
		keys_answer = Array( "Files\1\A.txt", "Files\1\C.ini", "Files\1\Except\A.txt", "Files\1\Sub\A.txt" )
		Assert  IsSameArray( keys,  keys_answer )

	End If : section.End_


	If section.Start( "T_PathDictionary_Wildcard_Dics" ) Then

		'// Test Main
		Set  dic = new PathDictionaryClass
		Set  dic( "Files\1\*\A.*" ) = a_item

		Set  dic_2 = new PathDictionaryClass
		Set  dic_2( "Files\1\*\C.*" ) = a_item

		Dic_add  dic,  dic_2

		'// Check
		keys = dic.FilePaths
		keys_answer = Array( "Files\1\A.txt", "Files\1\C.ini", "Files\1\Except\A.txt", "Files\1\Sub\A.txt" )
		Assert  IsSameArray( keys,  keys_answer )

	End If : section.End_


	Pass
End Sub


 
'***********************************************************************
'* Function: T_PathDictionary_OverSub
'***********************************************************************
Sub  T_PathDictionary_OverSub( Opt, AppKey )
	Set section = new SectionTree

'//SetStartSectionTree  "T_Sample2"  '// 一部のセクションだけ実行するときは有効にする
	Set  item_1 = new NameOnlyClass : item_1.Name = "item_1"
	Set  item_2 = new NameOnlyClass : item_2.Name = "item_2"


	If section.Start( "T_PathDictionary_OverSub_1" ) Then

	'// Test Main
	Set  dic = new PathDictionaryClass
	Set  dic( "Files\1\*\*.ini" ) = Nothing
	Set  dic( "Files\1" ) = item_1
	Set  dic( "Files\1\B.txt" ) = item_2

	'// Check
	keys = dic.FilePaths
	keys_answer = Array( "Files\1\A.txt", "Files\1\B.txt", "Files\1\C.ini", _
		"Files\1\Except\A.txt", "Files\1\Except\B.ini", _
		"Files\1\Sub\A.txt", "Files\1\Sub\B.ini" )
	Assert  IsSameArray( keys,  keys_answer )
	For Each  key  In keys
		If InStr( key, ".ini" ) > 0 Then
			Assert  dic( key ) Is Nothing
		ElseIf  key <> "Files\1\B.txt" Then
			Assert  dic( key ) Is item_1
		Else
			Assert  dic( key ) Is item_2
		End If
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_OverSub_2" ) Then

	'// Test Main
	Set  dic = new PathDictionaryClass
	dic.AddRemove  "*.ini"
	dic.AddRemove  "NotFound.doc"
	Set  dic( "Files\1" ) = item_1

	'// Check
	keys = dic.FilePaths
	keys_answer = Array( "Files\1\A.txt", "Files\1\B.txt", "Files\1\Except\A.txt", "Files\1\Sub\A.txt" )
	Assert  IsSameArray( keys,  keys_answer )
	For Each  key  In keys
		If InStr( key, "\B.txt" ) > 0 Then
		Else
			Assert  dic( key ) Is item_1
		End If
	Next
	For Each  key  In  dic.KeysEx( dic.ExceptRemoved )
		Assert  key = "Files\1"
	Next
	Assert  UBound( dic.KeysEx( dic.ExceptRemoved ) ) = 1 - 1

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_OverSub_3" ) Then

	'// Test Main
	Set  dic = new PathDictionaryClass
	dic.AddRemove  "Files\1\Sub"
	Set  dic( "Files\1" ) = item_1

	'// Check: "FilePaths"
	keys = dic.FilePaths
	keys_answer = Array( "Files\1\A.txt", "Files\1\B.txt", "Files\1\C.ini", _
		"Files\1\Except\A.txt", "Files\1\Except\B.ini" )
	Assert  IsSameArray( keys,  keys_answer )
	For Each  key  In keys
		Assert  dic( key ) Is item_1
	Next

	'// Check: "FolderPaths"
	keys = dic.FolderPaths
	keys_answer = Array( "Files", "Files\1", "Files\1\Except" )
	Assert  IsSameArray( keys,  keys_answer )
	Assert      dic.FolderExists( "Files" )
	Assert      dic.FolderExists( "Files\1" )
	Assert  not dic.FolderExists( "Files\1\Sub" )
	Assert      dic.FolderExists( "Files\1\Except" )
	Assert      dic.FolderExists( GetFullPath( "Files", Empty ) )
	Assert      dic.FolderExists( GetFullPath( "Files\1", Empty ) )
	Assert  not dic.FolderExists( GetFullPath( "Files\1\Sub", Empty ) )
	Assert      dic.FolderExists( GetFullPath( "Files\1\Except", Empty ) )

	'// Check: "DeleteFolderPaths"
	keys = dic.DeleteFolderPaths
	keys_answer = Array( "Files\1\Except" )
	Assert  IsSameArray( keys,  keys_answer )
	Assert  not dic.DeleteFolderExists( "Files" )
	Assert  not dic.DeleteFolderExists( "Files\1" )
	Assert  not dic.DeleteFolderExists( "Files\1\Sub" )
	Assert      dic.DeleteFolderExists( "Files\1\Except" )
	Assert  not dic.DeleteFolderExists( GetFullPath( "Files", Empty ) )
	Assert  not dic.DeleteFolderExists( GetFullPath( "Files\1", Empty ) )
	Assert  not dic.DeleteFolderExists( GetFullPath( "Files\1\Sub", Empty ) )
	Assert      dic.DeleteFolderExists( GetFullPath( "Files\1\Except", Empty ) )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_OverSub_4" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	del  "_work"
	copy  "Files\1", "_work"
	copy  "Files\Files1*", "_work"


	'// Test Main
	Set  dic = new PathDictionaryClass
	Set  dic( "_work" ) = item_1
	dic.AddRemove  "_work\1"
	Set  dic( "_work\1\Sub" ) = item_1

	'// Check: "FilePaths"
	keys = dic.FilePaths
	keys_answer = Array( "_work\1\Sub\A.txt", "_work\1\Sub\B.ini", _
		"_work\Files1.xml", "_work\Files1B.xml" )
	Assert  IsSameArray( keys,  keys_answer )
	For Each  key  In keys
		Assert  dic( key ) Is item_1
	Next

	'// Check: "FolderPaths"
	keys = dic.FolderPaths
	keys_answer = Array( "_work", "_work\1", "_work\1\Sub" )
	Assert  IsSameArray( keys,  keys_answer )
	Assert  dic( "_work" ) is item_1
	Assert  dic( "_work\1" ) is dic.RemovedObject
	Assert  dic( "_work\1\Sub" ) is item_1
	Assert      dic.FolderExists( "_work" )
	Assert      dic.FolderExists( "_work\1" )
	Assert      dic.FolderExists( "_work\1\Sub" )
	Assert  not dic.FolderExists( "_work\1\Except" )
	Assert      dic.FolderExists( GetFullPath( "_work", Empty ) )
	Assert      dic.FolderExists( GetFullPath( "_work\1", Empty ) )
	Assert      dic.FolderExists( GetFullPath( "_work\1\Sub", Empty ) )
	Assert  not dic.FolderExists( GetFullPath( "_work\1\Except", Empty ) )

	'// Check: "DeleteFolderPaths"
	keys = dic.DeleteFolderPaths
	keys_answer = Array( "_work\1\Sub" )
	Assert  IsSameArray( keys,  keys_answer )
	Assert  not dic.DeleteFolderExists( "_work" )
	Assert  not dic.DeleteFolderExists( "_work\1" )
	Assert      dic.DeleteFolderExists( "_work\1\Sub" )
	Assert  not dic.DeleteFolderExists( "_work\1\Except" )
	Assert  not dic.DeleteFolderExists( GetFullPath( "_work", Empty ) )
	Assert  not dic.DeleteFolderExists( GetFullPath( "_work\1", Empty ) )
	Assert      dic.DeleteFolderExists( GetFullPath( "_work\1\Sub", Empty ) )
	Assert  not dic.DeleteFolderExists( GetFullPath( "_work\1\Except", Empty ) )

	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_PathDictionary_XML
'***********************************************************************
Sub  T_PathDictionary_XML( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_PathDictionary_XML_PickUpCopy_Error3"


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_Files1_xml" ) Then

	'// Set up
	path_of_XML = "Files\Files1.xml"
	base_path = GetParentFullPath( path_of_XML )
	Set root = LoadXML( path_of_XML, Empty )

	'// Test Main
	Set dic = new_PathDictionaryClass_fromXML( root.selectNodes( "Folder" ), "path", base_path )

	'// Check
	keys = dic.FilePaths
	keys_answer = Array( "1\A.txt", "1\Sub\A.txt" )
	Assert  IsSameArray( keys,  keys_answer )
	For Each  key  In keys
		Assert  dic( key ).getAttribute( "attr" ) = "X"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_Files1B_xml" ) Then

	'// Set up
	path_of_XML = "Files\Files1B.xml"
	base_path = GetParentFullPath( path_of_XML )
	Set root = LoadXML( path_of_XML, Empty )

	'// Test Main
	Set dic = new_PathDictionaryClass_fromXML( root.selectNodes( "FolderB | FileB" ), "path_B", base_path )

	'// Check
	keys = dic.FilePaths
	keys_answer = Array( "1\A.txt", "1\Sub\A.txt", "Files1B.xml" )
	Assert  IsSameArray( keys,  keys_answer )
	For Each  key  In keys
		Assert  dic( key ).getAttribute( "attr" ) = "X"
	Next

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_FilesVarPath_xml" ) Then

	'// Set up
	path_of_XML = "Files\FilesVarPath.xml"
	base_path = GetParentFullPath( path_of_XML )
	Set root = LoadXML( path_of_XML, Empty )

	'// Test Main
	Set dic = new_PathDictionaryClass_fromXML( root.selectNodes( "FolderF | FileF" ), "path_F", base_path )

	'// Check
	keys = dic.FilePaths
	keys_answer = Array( base_path +"\1\A.txt", base_path +"\1\Sub\A.txt", _
		base_path +"\1\Sub\B.ini" )
	Assert  IsSameArray( keys,  keys_answer )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_NotFoundAttribute" ) Then

	'// Set up
	path_of_XML = "Files\Files1B.xml"
	base_path = GetParentFullPath( path_of_XML )
	Set root = LoadXML( path_of_XML, Empty )

	'// Test Main
	Set dic = new_PathDictionaryClass_fromXML( root.selectNodes( "FolderB" ), "unknown", base_path )

	'// Check
	Assert  UBound( dic.FilePaths ) = -1

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_PickUpCopy" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "Files\1_out" ).Enable()
	del  "Files_out"

	'// Test Main
	Set copy_ = OpenPickUpCopy( "Files\PickUpCopy1.xml" )
	Assert  copy_.GetDefaultSourcePath() = GetFullPath( "Files\1",  Empty )
	Assert  copy_.GetDefaultDestinationPath( Empty ) = GetFullPath( "Files\1_out",  Empty )
	copy_.Copy  Empty,  Empty,  Empty

	'// Check
	keys = ArrayFromWildcard2( "Files\1_out" ).FilePaths
	Assert  IsSameArray( keys, _
		Array( "A.txt", "B.txt", "Sub\A.txt" ) )

	'// Clean
	del  "Files\1_out"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_PickUpCopy2" ) Then

	'// Set up
	w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	'// Test Main
	Set copy_ = OpenPickUpCopy( "Files\PickUpCopy1.xml#2" )
	Assert  copy_.GetDefaultDestinationPath( "Files\1" ) = GetFullPath( "Files\1_out2",  Empty )
	copy_.Copy  Empty,  "_work",  Empty

	'// Check
	keys = ArrayFromWildcard2( "_work" ).LeafPaths
	Assert  IsSameArray( keys, _
		Array( "f1.txt", "fo2\" ) )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_PickUpCopy_RegExp" ) Then

	'// Set up
	w_=Empty : Set w_= AppKey.NewWritable( "Files\1_out" ).Enable()
	del  "Files\1_out"

	'// Test Main
	Set copy_ = OpenPickUpCopy( "Files\PickUpCopy1.xml#RegExp" )
	copy_.Copy  "Files\1",  Empty,  Empty

	'// Check
	keys = ArrayFromWildcard2( "Files\1_out" ).LeafPaths
	Assert  IsSameArray( keys, _
		Array( "Except\B.ini", "Sub\B.ini" ) )

	'// Clean
	del  "Files\1_out"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_PickUpCopy_FolderInSubFolder" ) Then

	'// Set up
	w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	'// Test Main
	Set copy_ = OpenPickUpCopy( "Files\PickUpCopy1.xml#folder_in_folder" )
	copy_.Copy  "data",  "_work",  Empty

	'// Check
	keys = ArrayFromWildcard2( "_work" ).FilePaths
	Assert  IsSameArray( keys, _
		Array( "f1.txt", "f2.txt", "f3.svg", "fe\f1.txt", "fe\f2.txt", "fe\f3.svg", _
		"fe\t1.txt", "t1.txt" ) )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_PickUpCopy_FolderInSubFolder2" ) Then

	'// Case of folder_in_folder2
	'// Set up
	w_=Empty : Set w_= AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	'// Test Main
	Set copy_ = OpenPickUpCopy( "Files\PickUpCopy1.xml#folder_in_folder2" )
	copy_.Copy  "data",  "_work",  Empty

	'// Check
	keys = ArrayFromWildcard2( "_work" ).FilePaths
	Assert  IsSameArray( keys, _
		Array( "f3.svg", "fe\f3.svg", "fo1\f3.svg", "fo1\fo11.ex\f3.svg" ) )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_PickUpCopy_ErrorOfNotFound" ) Then
	For Each  path  In  Array( _
			"Files\NotFound.xml", _
			"Files\PickUpCopy1.xml#errorNotFound" )

	    '// Error Handling Test
	   	echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			Set copy_ = OpenPickUpCopy( path )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"
		echo    e2.desc
		Assert  InStr( e2.desc,  GetFullPath( path, Empty ) ) >= 1
		Assert  e2.num <> 0

	Next
	End If : section.End_


	'//===========================================================
	w_=Empty : Set w_= AppKey.NewWritable( "Files\_work" ).Enable()
	For Each  t  In DicTable( Array( _
		"Case",  "Expected",   Empty, _
		"1",     "not found 1",         _
		"2",     Empty,        _
		"3",     "not found 3" ) )

	If section.Start( "T_PathDictionary_XML_PickUpCopy_Error"+ t("Case") ) Then

		setting_file_path = "Files\PickUpCopy1.xml#error"+ t("Case")
		Set copy_ = OpenPickUpCopy( setting_file_path )

	    '// Error Handling Test
	   	echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			copy_.Copy  Empty,  Empty,  Empty

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"

		If IsEmpty( t("Expected") ) Then
			Assert  e2.num = 0
		Else
			echo    e2.desc
			Assert  InStr( e2.desc, t("Expected") ) >= 1
			Assert  InStr( e2.desc, GetFullPath( setting_file_path, Empty ) ) >= 1
			Assert  e2.num <> 0
		End If

	End If : section.End_
	Next
	del  "Files\_work"


	'//===========================================================
	If section.Start( "T_PathDictionary_XML_PickUpCopyByString" ) Then

	'// Set up
	w_=Empty : Set w_= AppKey.NewWritable( "Files\1_out2" ).Enable()
	del  "Files\1_out2"

	'// Test Main
	Set copy_ = OpenPickUpCopy( new_FilePathForString( _
		"<PickUpCopy>"+ vbCRLF + _
		"    <File  path=""A.txt""/>"+ vbCRLF + _
		"</PickUpCopy>"+ vbCRLF ) )
	copy_.Copy  "Files\1",  "Files\1_out2",  Empty

	'// Check
	keys = ArrayFromWildcard2( "Files\1_out2" ).FilePaths
	Assert  IsSameArray( keys, _
		Array( "A.txt" ) )

	'// Clean
	del  "Files\1_out2"

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_PathDictionaries_XML
'***********************************************************************
Sub  T_PathDictionaries_XML( Opt, AppKey )

	'// Set up
	path_of_XML = "Files\Maps1.xml"
	base_path = GetParentFullPath( path_of_XML )
	Set root = LoadXML( path_of_XML, Empty )

	'// Test Main
	Set paths_maps = GetPathDictionariesFromXML( root.selectNodes( ".//Folder" ), "path", "map", base_path )

	'// Check
	Set keys_answer = Dict(Array( _
		"",     Array( "1\A.txt", "1\B.txt", "1\Sub\A.txt" ), _
		"MapY", Array( "1\A.txt", "1\B.txt", "1\Except\A.txt" ), _
		"MapZ", Array( "1\A.txt", "1\Sub\A.txt" ), _
		"MapA", Array( "1\A.txt" ) ))

	For Each  map_name  In  paths_maps.Keys
		keys = paths_maps( map_name ).FilePaths
		Assert  IsSameArray( keys,  keys_answer( map_name ) )

		If map_name <> "MapZ" Then  '// MapZ is not same attribte names
			If map_name = "" Then
				attribute_answer = "X"
			Else
				attribute_answer = Right( map_name, 1 )
			End If

			For Each  key  In keys
				Assert  paths_maps( map_name )( key ).getAttribute( "attr" ) = attribute_answer
			Next
		End If
	Next

	Assert  paths_maps( "" )( "1\A.txt" ).getAttribute( "attr" ) = "X"

	Assert  paths_maps( "MapZ" )( "1\Sub\A.txt" ).getAttribute( "attr" ) = "Z"
	Assert  paths_maps( "MapZ" )( "1\A.txt" ).getAttribute( "attr" ) = "Z2"


	Pass
End Sub


 
'***********************************************************************
'* Function: T_Dic_addFilePaths
'***********************************************************************
Sub  T_Dic_addFilePaths( Opt, AppKey )
	Set paths = new PathDictionaryClass
	paths.BasePath = "Files"

	Set tag = new_NameOnlyClass( "XML file", Empty )
	Set paths( "1\*\A.txt" ) = tag

	Set cproject_paths = Dic_addFilePaths_fromPathDirectory( Empty, 0, 0, Empty, _
		paths, tag )

	Assert  cproject_paths.Count = 3
	Assert  cproject_paths( GetFullPath( "Files\1\A.txt", Empty ) )(0) is tag
	Assert  cproject_paths( GetFullPath( "Files\1\Except\A.txt", Empty ) )(0) is tag
	Assert  cproject_paths( GetFullPath( "Files\1\Sub\A.txt", Empty ) )(0) is tag

	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetInputOutputFilePaths
'***********************************************************************
Sub  T_GetInputOutputFilePaths( Opt, AppKey )
	current = g_sh.CurrentDirectory
	tmp_path = GetTempPath( "Temporary.txt" )


	'// Set up
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	del  "_work"
	copy  "Files\1", "_work"
	copy  "Files\Files1*", "_work"


	'// Test Main
	pairs = GetInputOutputFilePaths( "Test.vbs", "b.txt", Empty )

	'// Check
	Assert  UBound( pairs ) = 0
	Assert  pairs(0).InputPath  = current +"\Test.vbs"
	Assert  pairs(0).OutputPath = current +"\b.txt"
	Assert  not pairs(0).IsOutputPathTemporary


	'// Test Main
	pairs = GetInputOutputFilePaths( "Test.vbs", Empty, "Temporary.txt" )

	'// Check
	Assert  UBound( pairs ) = 0
	Assert  pairs(0).InputPath = current +"\Test.vbs"
	Assert  pairs(0).OutputPath = tmp_path
	Assert  pairs(0).IsOutputPathTemporary


	'// Test Main
	pairs = GetInputOutputFilePaths( "Test.vbs", "_work\..\Test.vbs", "Temporary.txt" )

	'// Check
	Assert  UBound( pairs ) = 0
	Assert  pairs(0).InputPath = current +"\Test.vbs"
	Assert  pairs(0).OutputPath = tmp_path
	Assert  pairs(0).IsOutputPathTemporary


	'// Test Main
	pairs = GetInputOutputFilePaths( "_work\Files1.xml", "_work\Files1_out.xml", Empty )

	'// Check
	Assert  UBound( pairs ) = 0
	Assert  pairs(0).InputPath  = current +"\_work\Files1.xml"
	Assert  pairs(0).OutputPath = current +"\_work\Files1_out.xml"
	Assert  not pairs(0).IsOutputPathTemporary


	'// Test Main
	pairs = GetInputOutputFilePaths( "_work\1\*.ini", "Output", "Temporary.txt" )

	'// Check
	Assert  UBound( pairs ) = 2
	Assert  pairs(0).InputPath  = current +"\_work\1\C.ini"
	Assert  pairs(0).OutputPath = current + "\Output\C.ini"
	Assert  not pairs(0).IsOutputPathTemporary

	Assert  pairs(1).InputPath  = current +"\_work\1\Except\B.ini"
	Assert  pairs(1).OutputPath = current + "\Output\Except\B.ini"
	Assert  not pairs(1).IsOutputPathTemporary

	Assert  pairs(2).InputPath  = current +"\_work\1\Sub\B.ini"
	Assert  pairs(2).OutputPath = current + "\Output\Sub\B.ini"
	Assert  not pairs(2).IsOutputPathTemporary


	'// Test Main
	pairs = GetInputOutputFilePaths( "_work\1\Sub", "Output", "Temporary.txt" )

	'// Check
	Assert  UBound( pairs ) = 1
	Assert  pairs(0).InputPath  = current +"\_work\1\Sub\A.txt"
	Assert  pairs(0).OutputPath = current +"\Output\A.txt"
	Assert  not pairs(0).IsOutputPathTemporary

	Assert  pairs(1).InputPath  = current +"\_work\1\Sub\B.ini"
	Assert  pairs(1).OutputPath = current +"\Output\B.ini"
	Assert  not pairs(1).IsOutputPathTemporary


	'// Test Main
	pairs = GetInputOutputFilePaths( "_work\1\Sub", "_work\1\..\1\Sub", "Temporary.txt" )

	'// Check
	Assert  UBound( pairs ) = 1
	Assert  pairs(0).InputPath  = current +"\_work\1\Sub\A.txt"
	Assert  pairs(0).OutputPath = tmp_path
	Assert  pairs(0).IsOutputPathTemporary

	Assert  pairs(1).InputPath  = current +"\_work\1\Sub\B.ini"
	Assert  pairs(1).OutputPath = tmp_path
	Assert  pairs(1).IsOutputPathTemporary


	'// Test Main
	Set paths = new PathDictionaryClass
	Set paths( "_work\*.xml" ) = Nothing
	Set paths( "_work\*\C.ini" ) = Nothing
	pairs = GetInputOutputFilePaths( paths, Empty, "Temporary.txt" )

	'// Check
	Assert  UBound( pairs ) = 2
	Assert  pairs(0).InputPath  = current +"\_work\1\C.ini"
	Assert  pairs(0).OutputPath = tmp_path
	Assert  pairs(0).IsOutputPathTemporary

	Assert  pairs(1).InputPath  = current +"\_work\Files1.xml"
	Assert  pairs(1).OutputPath = tmp_path
	Assert  pairs(1).IsOutputPathTemporary

	Assert  pairs(2).InputPath  = current +"\_work\Files1B.xml"
	Assert  pairs(2).OutputPath = tmp_path
	Assert  pairs(2).IsOutputPathTemporary

	'// Clean
	del  "_work"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_PathDictionaryDebug
'***********************************************************************
Sub  T_PathDictionaryDebug( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_log.txt" ).Enable()
	del  "_log.txt"

	RunProg  "cscript //nologo "+ WScript.ScriptName +"  T_PathDictionaryDebug_Sub",  "_log.txt"

	If IsSameTextFile( "_log.txt", "Files\T_PathDictionaryDebug_TypeA.txt", Empty ) Then
		'// Pass
	ElseIf IsSameTextFile( "_log.txt", "Files\T_PathDictionaryDebug_TypeB.txt", Empty ) Then
		'// Pass
	Else
		Fail
	End If

	del  "_log.txt"
	Pass
End Sub


Sub  T_PathDictionaryDebug_Sub( Opt, AppKey )
	Set  a_item = new NameOnlyClass : a_item.Name = "a_item"
	Set w_= AppKey.NewWritable( "Files\_Files1.xml" ).Enable()
	Set ec = new EchoOff
	OpenForReplace( "Files\Files1.xml",  "Files\_Files1.xml" ).Replace _
		"<Root>",  "<Root><Debug  path_dictionary_scan_log=""yes""/>"

	echo_v  "-----------------------------------------------"
	Set  dic = new PathDictionaryClass

	dic.IsDebugLog = True
	Set       dic( "Files\1" ) = a_item
	dic.AddRemove  "Files\1\Except"
	dic.FilePaths

	echo_v  "-----------------------------------------------"
	path_of_XML = "Files\_Files1.xml"
	base_path = GetParentFullPath( path_of_XML )
	Set root = LoadXML( path_of_XML, Empty )

	Set dic = new_PathDictionaryClass_fromXML( root.selectNodes( "Folder" ), "path", base_path )
	dic.FilePaths

	del  "Files\_Files1.xml"
End Sub


 
'***********************************************************************
'* Function: gs_GetFullPathOrNot
'***********************************************************************
Function  gs_GetFullPathOrNot( in_StepPath, in_IsFullPath )
	If in_IsFullPath Then
		gs_GetFullPathOrNot = GetFullPath( in_StepPath, Empty )
	Else
		gs_GetFullPathOrNot = in_StepPath
	End If
End Function


 







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


 
