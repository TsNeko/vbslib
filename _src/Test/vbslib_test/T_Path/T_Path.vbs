Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1", "T_GetStepPath",_
			"2", "T_GetFullPath",_
			"3", "T_NormalizePath",_
			"4", "T_IsFullPath",_
			"5", "T_GetRootSeparatorPosition",_
			"6", "T_GetTagJumpParams",_
			"7", "T_AddLastOfFileName",_
			"8", "T_GetCommonParentFolderPath",_
			"9", "T_GetCommonSubPath",_
			"10","T_GetIdentifiableFileNames",_
			"11","T_GetParentFoldersName",_
			"12","T_ReplaceRootPath",_
			"13","T_ReplaceParentPath",_
			"14","T_IsMovablePathToPath",_
			"15","T_SplitPathToSubFolderSign",_
			"16","T_GetPathWithSeparator",_
			"17","T_TextFileExtension",_
			"18","T_GetEditorCmdLine",_
			"19","T_ExistenceCache",_
			"91","T_SearchParent" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_GetStepPath
'***********************************************************************
Sub  T_GetStepPath( Opt, AppKey )
	Assert GetStepPath( "C:\folder\file.txt", "c:\folder" ) = "file.txt"
	Assert GetStepPath( "C:\folder\file.txt", "c:\folder\" ) = "file.txt"
	Assert GetStepPath( "C:\folder\file.txt", "c:\folder\sub" ) = "..\file.txt"
	Assert GetStepPath( "C:\folder\file.txt", "c:\" ) = "folder\file.txt"
	Assert GetStepPath( "C:\folder", "c:\folder" ) = "."
	Assert GetStepPath( "C:\folder", "c:\folder\sub" ) = ".."
	Assert GetStepPath( "C:\", "c:\folder\sub" ) = "..\.."
	Assert GetStepPath( "C:\fold", "c:\folder" ) = "..\fold"
	Assert GetStepPath( "C:\folder", "c:\fold" ) = "..\folder"
	Assert GetStepPath( "C:\folderA\file.txt", "c:\folderB\sub" ) = "..\..\folderA\file.txt"
	Assert GetStepPath( "http://www.a.com/folder/file.txt", "http://www.a.com/folder/" ) = "file.txt"
	Assert GetStepPath( "http://www.a.com/folder/file.txt", "http://www.a.com/" ) = "folder/file.txt"
	Assert IsNull( GetStepPath( Null, "C:\folder" ) )
	Assert IsEmpty( GetStepPath( Empty, "C:\folder" ) )
	Assert GetStepPath( "C:\A\F\.", "C:\A" ) = "F"

	'// Old bug case
	Assert GetStepPath( GetFullPath( "..\sub", Empty ), Empty ) = "..\sub"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetFullPath
'***********************************************************************
Sub  T_GetFullPath( Opt, AppKey )
	Assert GetFullPath( "file.txt", "C:\folder"  ) = "C:\folder\file.txt"
	Assert GetFullPath( "file.txt", "C:\folder\" ) = "C:\folder\file.txt"
	Assert GetFullPath( "..\file.txt", "C:\folder" ) = "C:\file.txt"
	Assert GetFullPath( "..\..\file.txt", "C:\folder" ) = "C:\..\file.txt"
	Assert GetFullPath( "..\file.txt", "C:\folder\sub"  ) = "C:\folder\file.txt"
	Assert GetFullPath( "..\file.txt", "C:\folder\sub\" ) = "C:\folder\file.txt"
	Assert GetFullPath( "sub\..\..\file.txt", "C:\folder" ) = "C:\file.txt"
	Assert GetFullPath( "..", "C:\folder\sub" ) = "C:\folder"
	Assert GetFullPath( "..\..", "C:\folder\sub" ) = "C:\"
	Assert GetFullPath( "C:\", "C:\folder" ) = "C:\"
	Assert GetFullPath( "../file.txt", "http://www.sample.com/folder/" ) = "http://www.sample.com/file.txt"
	Assert GetFullPath( "..", "http://www.sample.com/folder/" ) = "http://www.sample.com/"
	Assert GetFullPath( "../..", "http://www.sample.com/folder/sub" ) = "http://www.sample.com/"
	Assert GetFullPath( "../..", "http://www.sample.com/folder/" ) = "http://www.sample.com/.."
	Assert GetFullPath( "../../file.txt", "http://www.sample.com/folder/" ) = "http://www.sample.com/../file.txt"
	Assert GetFullPath( "http://www.sample.com/folder/", "C:\folderA" ) = "http://www.sample.com/folder/"
	Assert GetFullPath( "ftp://www.sample.com/folder/", "C:\folderA" ) = "ftp://www.sample.com/folder/"
	Assert GetFullPath( "sub/file", "/home/user1" ) = "/home/user1/sub/file"
	Assert GetFullPath( "../user2", "/home/user1" ) = "/home/user2"
	Assert GetFullPath( "/usr/local", "/home/user1" ) = "/usr/local"
	Assert GetFullPath( "..", "\\pc01\root\file.txt" ) = "\\pc01\root\"
	Assert GetFullPath( "..\..", "\\pc01\root\file.txt" ) = "\\pc01\root\.."
	Assert GetFullPath( "\\pc01\folder\file.txt", "C:\folderA" ) = "\\pc01\folder\file.txt"
	Assert GetFullPath( "a", Empty ) = g_sh.CurrentDirectory+"\a"
	Assert GetFullPath( "C:\folderA\file1.txt", "C:\folderB" ) = "C:\folderA\file1.txt"
	Assert GetFullPath( "C:\folderA\.", "C:\folderB" ) = "C:\folderA"
	Assert GetFullPath( ".", Empty ) = g_sh.CurrentDirectory
	Assert IsNull( GetFullPath( Null, "C:\folder" ) )
	Assert IsEmpty( GetFullPath( Empty, "C:\folder" ) )
	Assert IsEmpty( GetFullPath( Empty, Empty ) )

	Assert GetFullPath( "t_path.vbs", Empty ) = g_sh.CurrentDirectory +"\t_path.vbs"
	Assert GetCaseSensitiveFullPath( "t_path.vbs" ) = g_sh.CurrentDirectory +"\T_Path.vbs"
	Assert GetCaseSensitiveFullPath( "notfound.txt" ) = g_sh.CurrentDirectory +"\notfound.txt"

	Assert  GetFullPath( "...\System32", "C:\Windows\System32" ) = "C:\Windows\System32"
	Assert  GetFullPath( "...\Windows",  "C:\Windows\System32" ) = "C:\Windows"

	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		GetFullPath  "file.txt", ".."
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc  '// 2nd argument must be absolute path
	Assert  e2.num = E_Others
	Pass
End Sub


 
'***********************************************************************
'* Function: T_NormalizePath
'***********************************************************************
Sub  T_NormalizePath( Opt, AppKey )
	Assert  NormalizePath( "C:\folder\..\file.txt" ) = "C:\file.txt"
	Assert  NormalizePath( "C:\folder\..\a" ) = "C:\a"
	Assert  NormalizePath( "C:\folder\.\a" ) = "C:\folder\a"
	Assert  NormalizePath( "C:\folder\sub\..\..\a" ) = "C:\a"
	Assert  NormalizePath( "C:\folder\sub\.." ) = "C:\folder"
	Assert  NormalizePath( "C:\folder\.." ) = "C:\"
	Assert  NormalizePath( "C:\.." ) = "C:\.."
	Assert  NormalizePath( "C:\.\a" ) = "C:\a"
	Assert  NormalizePath( "C:\a\." ) = "C:\a"
	Assert  NormalizePath( "C:\folder\" ) = "C:\folder"
	Assert  NormalizePath( "C:\folder" )  = "C:\folder"
	Assert  NormalizePath( "C:\" )        = "C:\"
	Assert  NormalizePath( "\" )          = "\"

	Assert  NormalizePath( "folder" )         = "folder"
	Assert  NormalizePath( ".\folder" )       = "folder"
	Assert  NormalizePath( "..\folder" )      = "..\folder"
	Assert  NormalizePath( ".\folder\.." )    = "."
	Assert  NormalizePath( ".\folder\..\a" )  = "a"
	Assert  NormalizePath( ".\folder\..\.." ) = ".."

	Assert  NormalizePath( "http://example.com/folder/../a" ) = "http://example.com/a"
	Assert  NormalizePath( "http://example.com/folder/./a" ) = "http://example.com/folder/a"
	Assert  NormalizePath( "http://example.com/folder/sub/../../a" ) = "http://example.com/a"
	Assert  NormalizePath( "http://example.com/folder/sub/.." ) = "http://example.com/folder"
	Assert  NormalizePath( "http://example.com/folder/.." ) = "http://example.com/"
	Assert  NormalizePath( "http://example.com/.." ) = "http://example.com/.."
	Assert  NormalizePath( "http://example.com/./a" ) = "http://example.com/a"
	Assert  NormalizePath( "http://example.com/a/." ) = "http://example.com/a"
	Assert  NormalizePath( "http://example.com/folder" )  = "http://example.com/folder"
	Assert  NormalizePath( "http://example.com/folder/" ) = "http://example.com/folder/"

	Assert  NormalizePath( "\\pc01\root\folder\..\a" )        = "\\pc01\root\a"
	Assert  NormalizePath( "\\pc01\root\folder\.\a" )         = "\\pc01\root\folder\a"
	Assert  NormalizePath( "\\pc01\root\folder\sub\..\..\a" ) = "\\pc01\root\a"
	Assert  NormalizePath( "\\pc01\root\folder\sub\.." )      = "\\pc01\root\folder"
	Assert  NormalizePath( "\\pc01\root\folder\.." )          = "\\pc01\root\"
	Assert  NormalizePath( "\\pc01\root\.." )     = "\\pc01\root\.."
	Assert  NormalizePath( "\\pc01\root\..\a" )   = "\\pc01\root\..\a"
	Assert  NormalizePath( "\\pc01\root\.\a" )    = "\\pc01\root\a"
	Assert  NormalizePath( "\\pc01\root\a\." )    = "\\pc01\root\a"
	Assert  NormalizePath( "\\pc01\root\folder" ) = "\\pc01\root\folder"

	Assert  NormalizePath( "\\example.com\root\folder\..\a" )        = "\\example.com\root\a"
	Assert  NormalizePath( "\\example.com\root\folder\.\a" )         = "\\example.com\root\folder\a"
	Assert  NormalizePath( "\\example.com\root\folder\sub\..\..\a" ) = "\\example.com\root\a"
	Assert  NormalizePath( "\\example.com\root\folder\sub\.." )      = "\\example.com\root\folder"
	Assert  NormalizePath( "\\example.com\root\folder\.." )          = "\\example.com\root\"
	Assert  NormalizePath( "\\example.com\root\.." )     = "\\example.com\root\.."
	Assert  NormalizePath( "\\example.com\root\..\a" )   = "\\example.com\root\..\a"
	Assert  NormalizePath( "\\example.com\root\.\a" )    = "\\example.com\root\a"
	Assert  NormalizePath( "\\example.com\root\a\." )    = "\\example.com\root\a"
	Assert  NormalizePath( "\\example.com\root\folder" ) = "\\example.com\root\folder"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_IsFullPath
'***********************************************************************
Sub  T_IsFullPath( Opt, AppKey )
	Assert      IsFullPath( "C:\folder" )
	Assert      IsFullPath( "\\pc01\folder" )
	Assert  not IsFullPath( "folder\file.txt" )
	Assert  not IsFullPath( "folder#C:\folder" )
	Assert      IsFullPath( "http://www.sample.com/" )
	Assert      IsFullPath( "http://www.sample.com:80/" )
	Assert      IsFullPath( "/home/user1" )
	Assert  not IsFullPath( "home/user1" )
	Assert      IsFullPath( "/home/user1/file.txt:10" )
	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetRootSeparatorPosition
'***********************************************************************
Sub  T_GetRootSeparatorPosition( Opt, AppKey )
	Assert  GetRootSeparatorPosition( "C:\File" ) = 3
	Assert  GetRootSeparatorPosition( "\File" ) = 1
	Assert  GetRootSeparatorPosition( "File" ) = 0
	Assert  GetRootSeparatorPosition( "\\PC01\Folder\File" ) = 14
	Assert  GetRootSeparatorPosition( "http://www.example.com/" ) = 23
	Assert  GetRootSeparatorPosition( "../File" ) = 0
	Assert  GetRootSeparatorPosition( "../Sub/File" ) = 0
	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetPathWithSeparator
'***********************************************************************
Sub  T_GetPathWithSeparator( Opt, AppKey )
	Assert  GetPathWithSeparator( "C:\BaseFolder" ) = "C:\BaseFolder\"
	Assert  GetPathWithSeparator( "C:\" )           = "C:\"
	Assert  GetPathWithSeparator( "" )              = ""
	Assert  GetPathWithSeparator( "." )             = ""
	Assert  GetPathWithSeparator( ".." )            = "..\"
	Assert  GetPathWithSeparator( "folder" )        = "folder\"
	Assert  GetPathWithSeparator( "folder/sub" )    = "folder/sub/"
	Assert  GetPathWithSeparator( "http://www.example.com/fo" ) = "http://www.example.com/fo/"
	Assert  GetPathWithSeparator( "http://www.example.com/" )   = "http://www.example.com/"
	Pass
End Sub


 
'***********************************************************************
'* Function: T_SplitPathToSubFolderSign
'***********************************************************************
Sub  T_SplitPathToSubFolderSign( Opt, AppKey )

	For Each  t  In DicTable( Array( _
		"Num", "Input",               "Output",            "Sign", "IsFolder",  Empty, _
		1,     "C:\Folder\.\log.txt", "C:\Folder\log.txt", ".",    False, _
		2,     "C:\Folder\*\log.txt", "C:\Folder\log.txt", "*",    False, _
		3,     "C:\Folder\*\*.txt",   "C:\Folder\*.txt",   "*",    False, _
		4,     "C:\Folder\log.txt",   "C:\Folder\log.txt", "",     False, _
		5,     "C:\Folder\*.txt",     "C:\Folder\*.txt",   "",     False, _
		6,     "C:\Folder\*",         "C:\Folder\*",       "",     False, _
		7,     "C:\Folder\*\*",       "C:\Folder\*",       "*",    False, _
		8,     "C:\Folder\.\*",       "C:\Folder\*",       ".",    False, _
		9,     "C:\.\Folder\",        "C:\Folder",         ".",    True, _
		10,    "C:\*\Folder\",        "C:\Folder",         "*",    True, _
		11,    "C:\Folder\",          "C:\Folder",         "",     True, _
		12,    "C:\Folder\.",         "C:\Folder",         "",     False, _
		13,    "C:\Folder\.\",        "C:\Folder",         "",     True, _
		14,    "C:\Folder\*",         "C:\Folder\*",       "",     False, _
		15,    "C:\Folder\*\",        "C:\Folder\*",       "",     True, _
		16,    "C:\Folder\*\*",       "C:\Folder\*",       "*",    False, _
		17,    "C:\Folder\*\*\",      "C:\Folder\*",       "*",    True, _
		18,    "C:\Folder\.\*",       "C:\Folder\*",       ".",    False, _
		19,    "C:\Folder\.\*\",      "C:\Folder\*",       ".",    True, _
		20,    "C:\",                 "C:\",               "",     True, _
		21,    "C:\.",                "C:\",               "",     False, _
		22,    "C:\.\",               "C:\",               "",     True, _
		23,    "C:\*",                "C:\*",              "",     False, _
		24,    "C:\*\",               "C:\*",              "",     True, _
		25,    "C:\*\*",              "C:\*",              "*",    False, _
		26,    "C:\*\*\",             "C:\*",              "*",    True, _
		27,    "C:\.\*",              "C:\*",              ".",    False, _
		28,    "C:\.\*\",             "C:\*",              ".",    True, _
		29,    "\",                   "\",                 "",     True, _
		30,    ".",                   ".",                 "",     False, _
		31,    ".\",                  ".",                 "",     True, _
		32,    "*",                   "*",                 "",     False, _
		33,    "..",                  "..",                "",     False, _
		34,    "..\",                 "..",                "",     True, _
		35,    "..\*",                "..\*",              "",     False, _
		36,    "*\file.txt",          "file.txt",          "*",    False, _
		37,    ".\file.txt",          "file.txt",          ".",    False, _
		38,    "fo\*\file.txt",       "fo\file.txt",       "*",    False, _
		39,    "fo\.\file.txt",       "fo\file.txt",       ".",    False  ) )


		'// Test
		path = t("Input")

		SplitPathToSubFolderSign  path, sign, is_folder, separator

		Assert  path = t("Output")
		Assert  sign = t("Sign")
		Assert  separator = "\"
		Assert  is_folder = t("IsFolder")


		'// Test : Separator = "/"
		path = Replace( t("Input"), "\", "/" )

		SplitPathToSubFolderSign  path, sign, is_folder, separator

		Assert  path = Replace( t("Output"), "\", "/" )
		Assert  sign = t("Sign")
		If InStr( t("Input"), "\" ) > 0 Then
			Assert  separator = "/"
		Else
			Assert  separator = "\"
		End If
		Assert  is_folder = t("IsFolder")
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetTagJumpParams
'***********************************************************************
Sub  T_GetTagJumpParams( Opt, AppKey )

	'//===========================================================
	'// Block: Bracket ( )

	Set j = GetTagJumpParams( "C:\folder\file1.txt(100)" )
	Assert  j.Path = "C:\folder\file1.txt"
	Assert  j.LineNum = 100
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "C:\folder\file1 (2).txt" )
	Assert  j.Path = "C:\folder\file1 (2).txt"
	Assert  IsEmpty( j.LineNum )
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "C:\folder\file1.txt(A)" )
	Assert  j.Path = "C:\folder\file1.txt(A)"
	Assert  IsEmpty( j.LineNum )
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "C:\folder\file1.txt" )
	Assert  j.Path = "C:\folder\file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "folder\file1.txt(100)" )
	Assert  j.Path = "folder\file1.txt"
	Assert  j.LineNum = 100
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "file1.txt(100)" )
	Assert  j.Path = "file1.txt"
	Assert  j.LineNum = 100
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "\\pc01.sample.com\folder\file1.txt(100)" )
	Assert  j.Path = "\\pc01.sample.com\folder\file1.txt"
	Assert  j.LineNum = 100
	Assert  IsEmpty( j.Keyword )


	'//===========================================================
	'// Block: Colon :

	Set j = GetTagJumpParams( "C:\folder\file1.txt:100" )
	Assert  j.Path = "C:\folder\file1.txt"
	Assert  j.LineNum = 100
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "C:\folder\file1.txt:A" )
	Assert  j.Path = "C:\folder\file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "A"

	Set j = GetTagJumpParams( "folder\file1.txt:100" )
	Assert  j.Path = "folder\file1.txt"
	Assert  j.LineNum = 100
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "file1.txt:100" )
	Assert  j.Path = "file1.txt"
	Assert  j.LineNum = 100
	Assert  IsEmpty( j.Keyword )


	'//===========================================================
	'// Block: Number #

	Set j = GetTagJumpParams( "C:\folder\file1.txt#100" )
	Assert  j.Path = "C:\folder\file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "100"

	Set j = GetTagJumpParams( "folder\file1.txt#100" )
	Assert  j.Path = "folder\file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "100"

	Set j = GetTagJumpParams( "folder\file1.txt#A" )
	Assert  j.Path = "folder\file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "A"

	Set j = GetTagJumpParams( "file1.txt#100" )
	Assert  j.Path = "file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "100"

	Set j = GetTagJumpParams( "#100" )
	Assert  j.Path = ""
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "100"

	Set j = GetTagJumpParams( "\\pc01.sample.com\folder\file1.txt#100" )
	Assert  j.Path = "\\pc01.sample.com\folder\file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "100"

	Set j = GetTagJumpParams( "file1.txt#//Comment" )
	Assert  j.Path = "file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "//Comment"

	Set j = GetTagJumpParams( "file1.txt#//Comment#2" )
	Assert  j.Path = "file1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "//Comment#2"


	'//===========================================================
	'// Block: Dollar ${ }

	Set j = GetTagJumpParams( "C:\Number${>#}1.txt" )  '// ${>#} は、# の escape sequence
	Assert  j.Path = "C:\Number#1.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  IsEmpty( j.Keyword )

	Set j = GetTagJumpParams( "C:\LineFeed.txt#Word${\n}" )
	Assert  j.Path = "C:\LineFeed.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  j.Keyword = "Word${\n}"
		'// ${ } の中の \ は、フォルダーの区切り記号にしない。
		'// ${\n} を改行文字に変換するとろこまではしない。

	Set j = GetTagJumpParams( "C:\VariableEscape$\{X}.txt" )
	Assert  j.Path = "C:\VariableEscape$\{X}.txt"
	Assert  IsEmpty( j.LineNum )
	Assert  IsEmpty( j.Keyword )

	Pass
End Sub


 
'***********************************************************************
'* Function: T_AddLastOfFileName
'***********************************************************************
Sub  T_AddLastOfFileName( Opt, AppKey )
	Assert  AddLastOfFileName( "file.txt", " (2)" )     = "file (2).txt"
	Assert  AddLastOfFileName( "file.txt", "123" )      = "file123.txt"
	Assert  AddLastOfFileName( "file.txt", "123." )     = "file123"
	Assert  AddLastOfFileName( "file.txt", "123.html" ) = "file123.html"
	Assert  AddLastOfFileName( "file.txt", ".html" )    = "file.html"
	Assert  AddLastOfFileName( "file.txt", "." )        = "file"
	Assert  AddLastOfFileName( "C:\Fo\file.txt", "123" )      = "C:\Fo\file123.txt"
	Assert  AddLastOfFileName( "C:\Fo\file.txt", "123.html" ) = "C:\Fo\file123.html"
	Assert  AddLastOfFileName( "C:\Fo\file.txt", ".html" )    = "C:\Fo\file.html"
	Assert  AddLastOfFileName( "C:\file.txt", "_2" ) = "C:\file_2.txt"
	Assert  AddLastOfFileName( "C:\file.txt", "." )  = "C:\file"
	Pass
End Sub


 
'***********************************************************************
'* Function: T_ExistenceCache
'***********************************************************************
Sub  T_ExistenceCache( Opt, AppKey )
If g_is_vbslib_for_fast_user Then
	Set section = new SectionTree
'//SetStartSectionTree  "T_Sample2"
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	If Left( g_sh.CurrentDirectory, 3 ) = "C:\" Then
		existence_C = 0
	Else
		existence_C = 2
	End If


	'//===========================================================
	If section.Start( "T_ExistenceCache_1" ) Then
	For Each  target  In  Array( "",  "\\",  GetFullPath( "T_ExistenceCache\4", Empty ),  "Disabled",  "CacheFile" )
	For Each  method  In  Array( "Exists", "FileExists", "FolderExists" )
		Set cache = new ExistenceCacheClass
		If target = "Disabled" Then
			cache.IsEnabled = False
		ElseIf target = "CacheFile" Then
			cache.TargetRootPath = ""
			cache.Load  "_work\cache.txt",  "."
		Else
			cache.TargetRootPath = target
		End If
		count_of_used_cache = 0

		For Each  t  In DicTable( Array( _
			"ID",  "Path",     "Exists", "FileExits", "FolderExits", "Existence", "Enumeration",  Empty, _
			1,     "1\A.txt",  False,    False,       False,         4,            0, _
			2,     "1\B.txt",  False,    False,       False,         0,            0, _
			3,     "1",        False,    False,       False,         0,            0, _
			4,     "2\A.txt",  False,    False,       False,         0,            1, _
			5,     "3\A.txt",  False,    False,       False,         3,            0, _
			6,     "3\B.txt",  True,     True,        False,         0,            1, _
			7,     "3\C.txt",  True,     True,        False,         0,            0, _
			8,     "3",        True,     False,       True,          0,            0, _
			9,     "4\A.txt",  True,     True,        False,         1,            0, _
			10,    "4\A.txt",  True,     True,        False,         0,            1, _
			11,    "4\A.txt",  True,     True,        False,         0,            0, _
			12,    "4\1\2",    True,     False,       True,          2,            0, _
			13,    "4\1\3",    False,    False,       False,         0,            1, _
			14,    "4\1\4\1",  False,    False,       False,         0,            0, _
			15,    "C:\",      True,     False,       True,    existence_C,        0, _
			16,    "C:\Windows", True,   False,       True,          0,            1, _
			17,    "C:\",      True,     False,       True,          0,            0, _
			18,    "A:\",      False,    False,       False,         2,            0, _
			19,  "\\Unknown\1\A.txt",    False,  False,  False,      3,            0, _
			20,  "\\Unknown\1\A.txt",    False,  False,  False,      0,            0, _
			21,  "\\Unknown\1\2\B.txt",  False,  False,  False,      0,            0 ) )

			'// Set up
			If not IsFullPath( t("Path") ) Then
				path = "T_ExistenceCache\"+ t("Path")
			Else
				path = t("Path")
			End If
			echo  CStr( t("ID") ) +"."+ path


			'// Test Main
			Select Case  method
				Case  "Exists" :       Assert  cache.Exists( path ) =       t("Exists")
				Case  "FileExists" :   Assert  cache.FileExists( path ) =   t("FileExits")
				Case  "FolderExists" : Assert  cache.FolderExists( path ) = t("FolderExits")
				Case Else : Error
			End Select


			'// Check
			Select Case  target
				Case "":           is_used_cache = True
				Case "\\":         is_used_cache = ( Left( t("Path"), 2 ) = "\\" ) '// UNC
				Case "Disabled":   is_used_cache = False
				Case "CacheFile":  is_used_cache = "InFile"
				Case Else :        is_used_cache = ( StrCompHeadOf( GetFullPath( path, Empty ),  target,  Empty ) = 0 )
			End Select

			If VarType( is_used_cache ) = vbBoolean Then
				If is_used_cache Then
					Assert  cache.CountOfCheckingExistence = t("Existence")
					Assert  cache.CountOfEnumeration = t("Enumeration")
					count_of_used_cache = count_of_used_cache + 1
				Else
					Assert  cache.CountOfCheckingExistence >= 1
					Assert  cache.CountOfEnumeration = 0
				End If
			Else
				Assert  is_used_cache = "InFile"
				Assert  cache.CountOfCheckingExistence = 0
				Assert  cache.CountOfEnumeration = 0
				count_of_used_cache = count_of_used_cache + 1
			End If

			'// Clean
			cache.CountOfCheckingExistence = 0
			cache.CountOfEnumeration = 0
		Next


		'// Check
		Select Case  target
			Case "":           Assert  count_of_used_cache = 21
			Case "\\":         Assert  count_of_used_cache =  3
			Case "Disabled":   Assert  count_of_used_cache =  0
			Case "CacheFile":  Assert  count_of_used_cache = 21
			Case Else :        Assert  count_of_used_cache =  6
		End Select

		If target = "" Then
			For i=0 To UBound( g_Coverage_ExistenceCacheClass )
				Assert  g_Coverage_ExistenceCacheClass(i)
			Next

			If method = "Exists" Then _
				cache.Save  "_work\cache.txt",  ".",  Empty
		End If
	Next
	Next
	del  "_work"
	End If : section.End_


	'//===========================================================
	If section.Start( "T_ExistenceCache_File" ) Then

		'// Test Main
		Set cache = new ExistenceCacheClass
		cache.TargetRootPath = ""
		cache.Exists  "T_ExistenceCache\3\B.txt"
		cache.Exists  "T_ExistenceCache\1\A.txt"
		cache.Save  "_work\sub\cache1.txt",  Empty,  "."
		cache.Save  "_work\sub\cache2.txt",  Empty,  ".."

		'// Check
		AssertFC  "_work\sub\cache1.txt",  "T_ExistenceCache\Answer\cache1.txt"
		AssertFC  "_work\sub\cache2.txt",  "T_ExistenceCache\Answer\cache2.txt"

		Set cache = new ExistenceCacheClass
		cache.Load  "_work\sub\cache1.txt",  Empty
		Assert      cache.Exists( "T_ExistenceCache\3\B.txt" )
		Assert  not cache.Exists( "T_ExistenceCache\1\A.txt" )

		'// Clean
		del  "_work"
	End If : section.End_

End If
	Pass
End Sub


 
'***********************************************************************
'* Function: T_SearchParent
'***********************************************************************
Sub  T_SearchParent( Opt, AppKey )
	Set ds_= new CurDirStack
	here = g_sh.CurrentDirectory
	cd  "Sub\Sub2"

	Assert  SearchParent(         "file1.txt" ) = here +"\Sub\Sub2\file1.txt"
	Assert  SearchParent(    "Sub2\file1.txt" ) = here +"\Sub\Sub2\file1.txt"
	Assert  SearchParent( "..\Sub2\file1.txt" ) = here +"\Sub\Sub2\file1.txt"
	Assert  IsEmpty( SearchParent(          "..\file1.txt" ) )
	Assert  IsEmpty( SearchParent( "..\nofolder\file1.txt" ) )

	Assert  SearchParent(         "*1.txt" ) = here +"\Sub\Sub2\file1.txt"
	Assert  SearchParent(    "Sub2\*1.txt" ) = here +"\Sub\Sub2\file1.txt"
	Assert  SearchParent( "..\Sub2\*1.txt" ) = here +"\Sub\Sub2\file1.txt"
	Assert  IsEmpty( SearchParent(          "..\*1.txt" ) )
	Assert  IsEmpty( SearchParent( "..\nofolder\*1.txt" ) )

	Assert  SearchParent(        "T_Path.vbs" ) = here +"\T_Path.vbs"
	Assert  SearchParent(     "..\T_Path.vbs" ) = here +"\T_Path.vbs"
	Assert  SearchParent(  "..\..\T_Path.vbs" ) = here +"\T_Path.vbs"
	Assert  SearchParent( here +"\T_Path.vbs" ) = here +"\T_Path.vbs"

	Assert  IsEmpty( SearchParent(        "nofile.txt" ) )
	Assert  IsEmpty( SearchParent(     "..\nofile.txt" ) )
	Assert  IsEmpty( SearchParent( here +"\nofile.txt" ) )

	cd  "C:\Windows\System32"
	Assert  SearchParent( "System32" ) = "C:\Windows\System32"
	Assert  SearchParent( "Windows" )  = "C:\Windows"

	If StrComp( Left( g_sh.ExpandEnvironmentStrings("%windir%"), 3 ), Left( here, 3 ) ) = 0 Then
		Assert  StrComp( SearchParent( "Windows" ), g_sh.ExpandEnvironmentStrings("%windir%"), 1 ) = 0
		cd "\"
		Assert  StrComp( SearchParent( "Windows" ), g_sh.ExpandEnvironmentStrings("%windir%"), 1 ) = 0
	Else
		echo  "%windir% のドライブで実行してください"
		Skip
	End If
	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetCommonParentFolderPath
'***********************************************************************
Sub  T_GetCommonParentFolderPath( Opt, AppKey )
	For Each  t  In DicTable( Array( _
		"ID", "PathA",              "PathB",               "Answer",      Empty, _
		1,    "C:\Folder\File.txt", "C:\Folder\FileB.txt", "C:\Folder\", _
		2,    "C:\Folder\File.txt", "C:\Folder\File.txt",  "C:\Folder\", _
		3,    "C:\A\B\File.txt",    "C:\A\B\File.txt",     "C:\A\B\", _
		4,    "C:\A\B\File.txt",    "C:\A\C\File.txt",     "C:\A\", _
		5,    "C:\A\B\File.txt",    "C:\A\C\File.txt",     "C:\A\", _
		6,    "C:\File.txt",        "C:\File.txt",         "C:\", _
		7,    "C:\A\File.txt",      "D:\A\File.txt",       "", _
		8,    Empty,                "D:\A\File.txt",       "D:\A\File.txt", _
		9,    "http://example.com/i",     "http://example.com/i", "http://example.com/", _
		10,   "http://www.example.com/i", "http://example.com/i", "http://"  ) )

		Assert  GetCommonParentFolderPath( t("PathA"),  t("PathB") ) = t("Answer")

		Assert  GetCommonParentFolderPath( _
			Replace( t("PathA"), "\", "/" ),  Replace( t("PathB"), "\", "/" ) ) = _
			Replace( t("Answer"), "\", "/" )
	Next
End Sub


 
'***********************************************************************
'* Function: T_GetCommonSubPath
'***********************************************************************
Sub  T_GetCommonSubPath( Opt, AppKey )
	For Each  t  In DicTable( Array( _
		"ID", "PathA",              "PathB",            "Answer",      Empty, _
		1,    "C:\A\B\File.txt",    "C:\A\B\File.txt",  "C:\A\B", _
		2,    "C:\A\C\File.txt",    "C:\B\C\File.txt",  "C", _
		3,    "C:\A\C\File.txt",    "C:\B\D\File.txt",  ""  ) )

		Assert  GetCommonSubPath( t("PathA"), t("PathB"), True ) = t("Answer")

		Assert  GetCommonSubPath( _
			g_fs.GetParentFolderName( t("PathA") ), _
			g_fs.GetParentFolderName( t("PathB") ),  False ) = t("Answer")
	Next

	Assert  GetCommonSubPath( "", "C:\A", False ) = ""
	Assert  GetCommonSubPath( "C:\A", "", False ) = ""

	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetIdentifiableFileNames
'***********************************************************************
Sub  T_GetIdentifiableFileNames( Opt, AppKey )
	sort_setting_back_up = g_Vers("ExpandWildcard_Sort")
	g_Vers("ExpandWildcard_Sort") = True

	For Each  t  In DicTable( Array( _
		"case_num",  "full_paths",  "id_file_names",  "full_paths_answer",  Empty, _
		1,_
			Array( _
				"C:\Folder\Sub\File1.txt", _
				"C:\Folder\Sub\File2.txt" ), _
			Array( _
				"File1.txt", _
				"File2.txt" ), _
			"same_as_full_paths", _
		2,_
			Array( _
				"C:\Folder\Sub1\File.txt", _
				"C:\Folder\Sub2\File.txt" ), _
			Array( _
				"Sub1\File.txt", _
				"Sub2\File.txt" ), _
			"same_as_full_paths", _
		3,_
			Array( _
				"C:\Folder1\Sub\File.txt", _
				"C:\Folder2\Sub\File.txt" ), _
			Array( _
				"Folder1\Sub\File.txt", _
				"Folder2\Sub\File.txt" ), _
			"same_as_full_paths", _
		4,_
			Array( _
				"C:\Folder\Sub1\FileA.txt", _
				"C:\Folder\Sub2\FileA.txt", _
				"C:\Folder\Sub2\FileB.txt" ), _
			Array( _
				"FileB.txt", _
				"Sub1\FileA.txt", _
				"Sub2\FileA.txt" ), _
			Array( _
				"C:\Folder\Sub2\FileB.txt", _
				"C:\Folder\Sub1\FileA.txt", _
				"C:\Folder\Sub2\FileA.txt" ), _
		5,_
			Array( _
				"C:\Folder1\SubA\File.txt", _
				"C:\Folder2\SubA\File.txt", _
				"C:\Folder2\SubB\File.txt" ), _
			Array( _
				"Folder1\SubA\File.txt", _
				"Folder2\SubA\File.txt", _
				"SubB\File.txt" ), _
			Array( _
				"C:\Folder1\SubA\File.txt", _
				"C:\Folder2\SubA\File.txt", _
				"C:\Folder2\SubB\File.txt" ), _
		6,_
			Array( _
				"C:\Folder1\SubA\File.txt", _
				"C:\Folder2\SubA\File.txt", _
				"C:\K\Folder2\SubA\File.txt", _
				"C:\Folder2\SubB\File.txt" ), _
			Array( _
				"C:\Folder2\SubA\File.txt", _
				"Folder1\SubA\File.txt", _
				"K\Folder2\SubA\File.txt", _
				"SubB\File.txt" ), _
			Array( _
				"C:\Folder2\SubA\File.txt", _
				"C:\Folder1\SubA\File.txt", _
				"C:\K\Folder2\SubA\File.txt", _
				"C:\Folder2\SubB\File.txt" ), _
		7,_
			Array( _
				"C:\Folder\Sub\File.txt", _
				"C:\Folder\Sub\File.txt" ), _
			Array( _
				"C:\Folder\Sub\File.txt" ), _
			Array( _
				"C:\Folder\Sub\File.txt" ), _
		8,_
			Array( _
				"C:\Folder\Sub\FileA.txt", _
				"C:\Folder\Sub\FileA.txt", _
				"C:\Folder\Sub\FileB.txt" ), _
			Array( _
				"C:\Folder\Sub\FileA.txt", _
				"FileB.txt" ), _
			Array( _
				"C:\Folder\Sub\FileA.txt", _
				"C:\Folder\Sub\FileB.txt" ) ) )

		If not IsArray( t("full_paths_answer") ) Then _
			If t("full_paths_answer") = "same_as_full_paths" Then _
				t("full_paths_answer") = t("full_paths")


		'// Test Main
		Set output = GetIdentifiableFileNames( t("full_paths") )


		'// Check
		Assert  IsSameArray( output.Keys, t("id_file_names") )
		Assert  IsSameArray( output.Items, t("full_paths_answer") )
	Next

	g_Vers("ExpandWildcard_Sort") = sort_setting_back_up
	Pass
End Sub


 
'***********************************************************************
'* Function: T_GetParentFoldersName
'***********************************************************************
Sub  T_GetParentFoldersName( Opt, AppKey )
	Set ds_= new CurDirStack
	here = g_sh.CurrentDirectory

	pushd  "Sub"
	Assert  GetParentFoldersName( "Sub2\file1.txt", 1, "/" ) = "Sub2"
	Assert  GetParentFoldersName( "Sub2\file1.txt", 2, "/" ) = "Sub/Sub2"
	Assert  GetParentFoldersName( "Sub2\file1.txt", 2, Empty ) = "Sub\Sub2"
	Assert  GetParentFoldersName( "Sub2\file1.txt", 2, "_" ) = "Sub_Sub2"
	popd
	pushd  "Sub\Sub2"
	Assert  GetParentFoldersName( ".", 1, "/" ) = "Sub"
	popd
	GetParentFoldersName  "Sub2\file1.txt", 9999, Empty  '// no error


	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		'// Level = 0 is invalid
		GetParentFoldersName  "Sub2\file1.txt", 0, Empty

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ReplaceRootPath
'***********************************************************************
Sub  T_ReplaceRootPath( Opt, AppKey )
	cur = g_sh.CurrentDirectory
	before = cur
	after = cur +"\after"

	Assert  ReplaceRootPath( "a.txt", before, after, True ) = after +"\a.txt"
	Assert  ReplaceRootPath( before +"\a.txt", before, after, True ) = after +"\a.txt"

	Assert  ReplaceRootPath( "a.txt", _
		Replace( before, "\", "/" ), Replace( after, "\", "/" ), True ) = _
		Replace( after, "\", "/" ) +"/a.txt"
	Assert  ReplaceRootPath( Replace( before, "\", "/" ) +"/a.txt", _
		Replace( before, "\", "/" ), Replace( after, "\", "/" ), True ) = _
		Replace( after, "\", "/" ) +"/a.txt"

	Assert  ReplaceRootPath( "sub\a.txt", before, after, True ) = after +"\sub\a.txt"
	Assert  ReplaceRootPath( before +"\sub\a.txt", before, after, True ) = after +"\sub\a.txt"

	Assert  ReplaceRootPath( "..\FolderC\a.txt", before, after, True ) = _
		after +"\_parent\FolderC\a.txt"
	Assert  ReplaceRootPath( GetFullPath( "..\FolderC\a.txt", before ), before, after, True ) = _
		after +"\_parent\FolderC\a.txt"

	Assert  ReplaceRootPath( "..\FolderC\a.txt", before, after, False ) = _
		GetParentFullPath( after ) +"\FolderC\a.txt"
	Assert  ReplaceRootPath( GetFullPath( "..\FolderC\a.txt", before ), before, after, False ) = _
		GetParentFullPath( after ) +"\FolderC\a.txt"

	Assert  ReplaceRootPath( "C:\a.txt", "C:\", "D:\", True ) = "D:\a.txt"
	Assert  ReplaceRootPath( "C:\sub\a.txt", "C:\", "D:\", True ) = "D:\sub\a.txt"
	Assert  ReplaceRootPath( "C:\a.txt", "C:\", "D:\sub", True ) = "D:\sub\a.txt"
	Assert  ReplaceRootPath( "C:\sub\a.txt", "C:\sub", "D:\", True ) = "D:\a.txt"

	Assert  GetParentFullPath( ReplaceRootPath( _
		"C:\FolderA\sub\a.txt", "C:\FolderA", "C:\FolderB", True ) ) = _
		"C:\FolderB\sub"

	Assert  ReplaceRootPath( ".", "C:\sub", "D:\a", True ) = "D:\a"
	Assert  ReplaceRootPath( ".", "C:\sub", "D:\", True ) = "D:\"


	For Each  t  In DicTable( Array( _
		"Before",  "BeforeRoot",  "AfterRoot",  "IsReplaceParent",  "ErrorKeywords",   Empty, _
		"C:\sub",  "D:\sub",      "E:\",        True,  Array( "C:\sub",  "D:\sub" ) ))

		'// Error Handling Test
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			ReplaceRootPath  t("Before"),  t("BeforeRoot"),  t("AfterRoot"),  t("IsReplaceParent")

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '// Set "e2"
		echo    e2.desc
		For Each  keyword  In  t("ErrorKeywords")
			Assert  InStr( e2.desc, keyword ) >= 1
		Next
		Assert  e2.num <> 0
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ReplaceParentPath
'***********************************************************************
Sub  T_ReplaceParentPath( Opt, AppKey )

	Assert  ReplaceParentPath( "..\..\folder", "..", "_parent" ) = "_parent\_parent\folder"
	Assert  ReplaceParentPath( "../../folder", "..", "_parent" ) = "_parent/_parent/folder"
	Assert  ReplaceParentPath( "_parent\_parent\folder", "_parent", ".." ) = "..\..\folder"
	Assert  ReplaceParentPath( "_parent/_parent/folder", "_parent", ".." ) = "../../folder"

	Assert  ReplaceParentPath( "..\..\folder\..\f", "..", "p" ) = "p\p\f"
	Assert  ReplaceParentPath( "../../folder/../f", "..", "p" ) = "p/p/f"
	Assert  ReplaceParentPath( "..\..\folder\..", "..", "p" ) = "p\p"
	Assert  ReplaceParentPath( "../../folder/..", "..", "p" ) = "p/p"
	Assert  ReplaceParentPath( "..\..\folder\..\..", "..", "p" ) = "p\p\p"
	Assert  ReplaceParentPath( "../../folder/../..", "..", "p" ) = "p/p/p"
	Assert  ReplaceParentPath( "..\..\sub\folder\..", "..", "p" ) = "p\p\sub"
	Assert  ReplaceParentPath( "../../sub/folder/..", "..", "p" ) = "p/p/sub"
	Assert  ReplaceParentPath( "..\folder", "..", "p" ) = "p\folder"
	Assert  ReplaceParentPath( "../folder", "..", "p" ) = "p/folder"
	Assert  ReplaceParentPath( "..\..", "..", "p" ) = "p\p"
	Assert  ReplaceParentPath( "../..", "..", "p" ) = "p/p"
	Assert  ReplaceParentPath( "..", "..", "p" ) = "p"
	Assert  ReplaceParentPath( "sub", "..", "p" ) = "sub"
	Assert  ReplaceParentPath( "sub\..", "..", "p" ) = "."
	Assert  ReplaceParentPath( "sub/..", "..", "p" ) = "."
	Assert  ReplaceParentPath( "C:\", "..", "p" ) = "C:\"
	Assert  ReplaceParentPath( "C:\..", "..", "p" ) = "C:\p"
	Assert  ReplaceParentPath( "C:\a\..\..\b", "..", "p" ) = "C:\p\b"
	Assert  ReplaceParentPath( "http://example.com/..", "..", "p" ) = "http://example.com/p"
	Assert  ReplaceParentPath( "http://example.com/../..", "..", "p" ) = "http://example.com/p/p"
	Assert  ReplaceParentPath( "http://example.com/a/..", "..", "p" ) = "http://example.com/"
	Assert  ReplaceParentPath( "http://example.com/a/../b", "..", "p" ) = "http://example.com/b"
	Assert  ReplaceParentPath( "http://example.com/a\..\b", "..", "p" ) = "http://example.com/b"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_TextFileExtension
'***********************************************************************
Sub  T_TextFileExtension( Opt, AppKey )
	Assert  g_Vers("TextFileExtension").Exists( "txt" )
	Assert  g_Vers("TextFileExtension").Exists( "TXT" )
	Assert  g_Vers("TextFileExtension").Exists( "c" )
	Assert  g_Vers("TextFileExtension").Exists( "C" )
	Assert  g_Vers("TextFileExtension").Exists( "h" )
	Assert  g_Vers("TextFileExtension").Exists( "cpp" )
	Assert  g_Vers("TextFileExtension").Exists( "svg" )
	Assert  not g_Vers("TextFileExtension").Exists( "jpg" )
	Assert  not g_Vers("TextFileExtension").Exists( "png" )
	Pass
End Sub


 
'***********************************************************************
'* Function: T_IsMovablePathToPath
'***********************************************************************
Sub  T_IsMovablePathToPath( Opt, AppKey )
	current_drive = UCase( Left( g_sh.CurrentDirectory, 1 ) )
	If current_drive = "C" Then
		other_drive = "D"
	Else
		other_drive = "C"
	End If

	For Each  is_folder  In Array( False, True )
		Assert      IsMovablePathToPath( "C:\file1.txt", "C:\file2.txt", is_folder )
		Assert  not IsMovablePathToPath( "C:\file1.txt", "D:\file2.txt", is_folder )
		Assert      IsMovablePathToPath( "C:/file1.txt", "C:/file2.txt", is_folder )
		Assert  not IsMovablePathToPath( "C:/file1.txt", "D:/file2.txt", is_folder )
		Assert      IsMovablePathToPath(    "file1.txt", current_drive +":\file2.txt", is_folder )
		Assert  not IsMovablePathToPath(    "file1.txt", other_drive   +":\file2.txt", is_folder )
		Assert      IsMovablePathToPath( current_drive +":\file1.txt",    "file2.txt", is_folder )
		Assert  not IsMovablePathToPath( other_drive   +":\file1.txt",    "file2.txt", is_folder )

		Assert      IsMovablePathToPath( "\\server\folder1\file1.txt", "\\server\folder1\file2.txt", is_folder )
		Assert  not IsMovablePathToPath( "\\server\folder1\file1.txt", "\\server\folder2\file2.txt", is_folder )
		Assert      IsMovablePathToPath( "//server/folder1/file1.txt", "//server/folder1/file2.txt", is_folder )
		Assert  not IsMovablePathToPath( "//server/folder1/file1.txt", "//server/folder2/file2.txt", is_folder )
		Assert      IsMovablePathToPath(       "C:\folder1\file1.txt",       "C:\folder2\file2.txt", is_folder )
		Assert  not IsMovablePathToPath( "C:\file1.txt", "\\server\folder1\file2.txt", is_folder )
		Assert  not IsMovablePathToPath(    "file1.txt", "\\server\folder1\file2.txt", is_folder )
		Assert  not IsMovablePathToPath( "\\server\folder1\file1.txt", "C:\file2.txt", is_folder )
		Assert  not IsMovablePathToPath( "\\server\folder1\file1.txt",    "file2.txt", is_folder )
	Next

	Assert      IsMovablePathToPath( "C:\file1.txt", "C:\", True )
	Assert  not IsMovablePathToPath( "C:\file1.txt", "D:\", True )

	Assert      IsMovablePathToPath( "\\server\folder1\file1.txt", "\\server\folder1", True )
	Assert  not IsMovablePathToPath( "\\server\folder1\file1.txt", "\\server\folder2", True )
End Sub


 
'***********************************************************************
'* Function: T_GetEditorCmdLine
'***********************************************************************
Sub  T_GetEditorCmdLine( Opt, AppKey )
	T_GetEditorCmdLineSub  "Files\File1.txt",         """exe"" "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt(10)",     """exe"" -Y=10 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt:10",      """exe"" -Y=10 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt#[Func1]", """exe"" -Y=2 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt:[Func1]", """exe"" -Y=2 "".\Files\File1.txt"""

	T_GetEditorCmdLineSub  GetFullPath( "Files\File1.txt", Empty ) +"#Class::Method", _
		"""exe"" -Y=4 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt#Object.Attribute", """exe"" -Y=5 "".\Files\File1.txt"""

	T_GetEditorCmdLineSub  "Files\File2_CR_LF.txt#Word${\n}", """exe"" -Y=2 "".\Files\File2_CR_LF.txt"""
	T_GetEditorCmdLineSub  "Files\File2_LF.txt#Word${\n}",    """exe"" -Y=2 "".\Files\File2_LF.txt"""
	T_GetEditorCmdLineSub  "Files\File2_CR_LF.txt#Word${\n}${+2}", """exe"" -Y=3 "".\Files\File2_CR_LF.txt"""
	T_GetEditorCmdLineSub  "Files\File2_LF.txt#Word${\n}${+2}",    """exe"" -Y=3 "".\Files\File2_LF.txt"""

	Pass
End Sub

Sub  T_GetEditorCmdLineSub( Path, Answer )
	editor_exe = Setting_getEditorCmdLine( 0 )
	command_line = GetEditorCmdLine( Path )
	command_line = Replace( command_line, editor_exe, "exe" )
	command_line = Replace( command_line, g_sh.CurrentDirectory, "." )
	echo  command_line
	Assert  command_line = Answer
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


 
