Option Explicit 

Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_BreakByFName",  "2","T_Watch" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_BreakByFName] >>> 
'********************************************************************************
Sub  T_BreakByFName( Opt, AppKey )
	Dim  f
	Dim w_:Set w_= AppKey.NewWritable( "_work" ).Enable()
	del  "_work"

	g_debug_or_test = 1
	SetBreakByFName  "file2.txt"


	'//=== OpenForWrite
	echo  "=== OpenForWrite _work\file1.txt"
	Set f = OpenForWrite( "_work\file1.txt", Empty )  '// Not Break
	f.WriteLine  "abc"
	f = Empty

	echo  "=== OpenForWrite _work\file2.txt"
	Set f = OpenForWrite( "_work\file2.txt", Empty )  '// Break
	f.WriteLine  "abc"
	f = Empty

	del  "_work\*"  '// Break
	del  "_work"  '// Not Break. Test on delete folder is after here.


	'//=== copy/move with wildcard
	echo  "=== copy data\* _work\copyed"         '( copyed\file1.txt, copyed\file2.txt )
	copy  "data\*", "_work\copyed"         '// Break

	echo  "=== move _work\copyed\* _work\moved"  '( moved\file1.txt, moved\file2.txt )
	move  "_work\copyed\*", "_work\moved"  '// Break

	echo  "=== del  _work\moved\file2.txt"       '( moved\file1.txt )
	del  "_work\moved\file2.txt"           '// Break

	echo  "=== copy  _work\moved\* _work\copyed" '( copyed\file1.txt, moved\file1.txt )
	copy  "_work\moved\*", "_work\copyed"  '// Not Break

	echo  "=== del _work\moved\file1.txt"        '( copyed\file1.txt )
	del  "_work\moved\file1.txt"           '// Not Break

	echo  "=== move  _work\copyed\* _work\moved" '( moved\file1.txt )
	move  "_work\copyed\*", "_work\moved"  '// Not Break

	del  "_work"  '// Not Break


	'//=== copy/move a folder
	echo  "=== copy data _work\copyed"
	copy  "data", "_work\copyed"              '// Break

	echo  "=== move _work\copyed\data _work\moved"
	move  "_work\copyed\data", "_work\moved"  '// Break

	echo  "=== del  _work\moved\data\file2.txt"
	del  "_work\moved\data\file2.txt"         '// Break

	echo  "=== copy  _work\moved\data _work\copyed"
	copy  "_work\moved\data", "_work\copyed"  '// Not Break

	echo  "=== del _work\moved\data"
	del  "_work\moved\data"                   '// Not Break

	echo  "=== move  _work\copyed\data _work\moved"
	move  "_work\copyed\data", "_work\moved"  '// Not Break

	del  "_work"                              '// Not Break


	'//=== CreateFile
	echo  "=== CreateFile  _work\file2.txt"
	CreateFile  "_work\file2.txt", "file2"  '// Break

	del  "_work"  '// Break


	'//=== ConvertToFullPath
	echo  "=== ConvertToFullPath data\file2.txt _work\file2.txt"
	ConvertToFullPath  "data\file2.txt", "_work\file2.txt"  '// Break

	del  "_work"  '// Break
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Watch] >>> 
'********************************************************************************
Sub  T_Watch( Opt, AppKey )
	Dim  a : a = 18
	Dim  s : s = "ABC"

	WD2  "a", a
	WS2  "a", "a"
	WX2  "a", a

	Execute WD("a")+WS("s")+WX("a")

	MARK  "a", 0
	MARK  "a", a
	If a <> 2 Then  Fail
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

 
