Sub  Main( Opt, AppKey )
	T_LazyDictionaryMini_1  Opt, AppKey
	T_LazyDictionaryMini_XML  Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_LazyDictionaryMini_1
'***********************************************************************
Sub  T_LazyDictionaryMini_1( Opt, AppKey )

	'// Set up
	Set g = new LazyDictionaryClass
	g("${RootPath}") = "C:\FolderA"
	g("${Target}") = "${RootPath}\Target"

	'// Test Main, Check
	Assert  g("${RootPath}") = "C:\FolderA"
	Assert  g("${Target}")   = "C:\FolderA\Target"


	'//==== 環境変数
	Set g = new LazyDictionaryClass
	Assert  g("${USERPROFILE}\Desktop") = g_sh.SpecialFolders( "Desktop" )

End Sub


 
'***********************************************************************
'* Function: T_LazyDictionaryMini_XML
'***********************************************************************
Sub  T_LazyDictionaryMini_XML( Opt, AppKey )

	path = "Files\T_LazyDictionaryXML.xml"
	Set root = LoadXML( path, Empty )

	Set variables = LoadVariableInXML( root, path )

	Assert  variables( "${Var1}") = "ABC"
	Assert  variables( "${Var3}DEF") = "XYZDEF"
	Assert  variables( "${FullPath2}") = g_sh.CurrentDirectory +"\Files\XYZ"
	Assert  variables( "${FullPath3}") = g_sh.ExpandEnvironmentStrings( "%ProgramFiles%" )
	Assert  variables( "${FullPath6}") = g_fs.GetAbsolutePathName( "..\.." )

End Sub


 
'***********************************************************************
'* Function: include
'***********************************************************************
Sub  include( in_Path )
	Set f = g_fs.OpenTextFile( in_Path,,,-2 )
	ExecuteGlobal  f.ReadAll()
End Sub


 
'***********************************************************************
'* Section: Calls Main
'***********************************************************************
Set  g_sh = WScript.CreateObject( "WScript.Shell" )
Set  g_fs = CreateObject( "Scripting.FileSystemObject" )

include  "..\..\..\..\scriptlib\vbslib\vbslib_mini.vbs"

Main  Empty, Empty


WScript.Echo  "Pass."
WScript.Quit  21
