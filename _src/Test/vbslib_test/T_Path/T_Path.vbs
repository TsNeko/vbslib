Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_GetStepPath",_
			"2","T_GetFullPath",_
			"3","T_NormalizePath",_
			"4","T_IsFullPath",_
			"5","T_GetRootSeparatorPosition",_
			"6","T_GetTagJumpParams",_
			"7","T_AddLastOfFileName",_
			"8","T_GetParentFoldersName",_
			"9","T_ReplaceParentPath",_
			"10","T_IsMovablePathToPath",_
			"11","T_SplitPathToSubFolderSign",_
			"12","T_GetPathWithSeparator",_
			"13","T_TextFileExtension",_
			"14","T_GetEditorCmdLine",_
			"91","T_SearchParent" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_GetStepPath] >>> 
'*************************************************************************
Sub  T_GetStepPath( Opt, AppKey )
	Assert GetStepPath( "C:\folder\file.txt", "c:\folder" ) = "file.txt"
	Assert GetStepPath( "C:\folder\file.txt", "c:\folder\" ) = "file.txt"
	Assert GetStepPath( "C:\folder\file.txt", "c:\folder\sub" ) = "..\file.txt"
	Assert GetStepPath( "C:\folder\file.txt", "c:\" ) = "folder\file.txt"
	Assert GetStepPath( "C:\folder", "c:\folder" ) = "."
	Assert GetStepPath( "C:\folder", "c:\folder\sub" ) = ".."
	Assert GetStepPath( "C:\", "c:\folder\sub" ) = "..\.."
	Assert GetStepPath( "C:\folderA\file.txt", "c:\folderB\sub" ) = "..\..\folderA\file.txt"
	Assert GetStepPath( "http://www.a.com/folder/file.txt", "http://www.a.com/folder/" ) = "file.txt"
	Assert GetStepPath( "http://www.a.com/folder/file.txt", "http://www.a.com/" ) = "folder/file.txt"
	Assert IsNull( GetStepPath( Null, "C:\folder" ) )
	Assert IsEmpty( GetStepPath( Empty, "C:\folder" ) )
	Pass
End Sub


 
'*************************************************************************
'  <<< [T_GetFullPath] >>> 
'*************************************************************************
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


	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		GetFullPath  "file.txt", ".."
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc  '// 2nd argument must be absolute path
	Assert  e2.num = E_Others
	Pass
End Sub


 
'*************************************************************************
'  <<< [T_NormalizePath] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_IsFullPath] >>> 
'*************************************************************************
Sub  T_IsFullPath( Opt, AppKey )
	Assert      IsFullPath( "C:\folder" )
	Assert      IsFullPath( "\\pc01\folder" )
	Assert  not IsFullPath( "folder\file.txt" )
	Assert      IsFullPath( "http://www.sample.com/" )
	Assert      IsFullPath( "http://www.sample.com:80/" )
	Assert      IsFullPath( "/home/user1" )
	Assert  not IsFullPath( "home/user1" )
	Assert      IsFullPath( "/home/user1/file.txt:10" )
	Pass
End Sub


 
'*************************************************************************
'  <<< [T_GetRootSeparatorPosition] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_GetPathWithSeparator] >>> 
'*************************************************************************
Sub  T_GetPathWithSeparator( Opt, AppKey )
	Assert  GetPathWithSeparator( "C:\BaseFolder" ) = "C:\BaseFolder\"
	Assert  GetPathWithSeparator( "C:\" )           = "C:\"
	Assert  GetPathWithSeparator( "http://www.example.com/fo" ) = "http://www.example.com/fo/"
	Assert  GetPathWithSeparator( "http://www.example.com/" )   = "http://www.example.com/"
	Pass
End Sub


 
'*************************************************************************
'  <<< [T_SplitPathToSubFolderSign] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_GetTagJumpParams] >>> 
'*************************************************************************
Sub  T_GetTagJumpParams( Opt, AppKey )
	Set j = GetTagJumpParams( "C:\folder\file1.txt(100)" )
	Assert  j.Path = "C:\folder\file1.txt"
	Assert  j.LineNum = 100
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

	Pass
End Sub


 
'*************************************************************************
'  <<< [T_AddLastOfFileName] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_SearchParent] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_GetParentFoldersName] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_ReplaceParentPath] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_TextFileExtension] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_IsMovablePathToPath] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [T_GetEditorCmdLine] >>> 
'*************************************************************************
Sub  T_GetEditorCmdLine( Opt, AppKey )
	T_GetEditorCmdLineSub  "Files\File1.txt",         """exe"" "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt(10)",     """exe"" -Y=10 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt:10",      """exe"" -Y=10 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt#[Func1]", """exe"" -Y=2 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt:[Func1]", """exe"" -Y=2 "".\Files\File1.txt"""

	T_GetEditorCmdLineSub  GetFullPath( "Files\File1.txt", Empty ) +"#Class::Method", _
		"""exe"" -Y=4 "".\Files\File1.txt"""
	T_GetEditorCmdLineSub  "Files\File1.txt#Object.Attribute", """exe"" -Y=5 "".\Files\File1.txt"""

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
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
