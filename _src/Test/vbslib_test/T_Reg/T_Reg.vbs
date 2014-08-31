Option Explicit 

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Reg1",_
			"2","T_RegFile" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Reg1] >>> 
'********************************************************************************
Sub  T_Reg1( Opt, AppKey )
	Dim  keys, values, s, i, flags


	'//=== keys = Enum Keys
	RegEnumKeys  "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion", keys, Empty

	flags = 0
	For Each  s In keys
		If InStr( s, "\Explorer"  ) > 0 Then  flags = flags or 1
		If InStr( s, "\Uninstall" ) > 0 Then  flags = flags or 2
	Next
	If flags <> 3 Then  Fail


	'//=== values = Enum Values
	RegEnumValues  "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup", values

	flags = 0 : i = 0
	For Each  s In values
		If s.Name = "BootDir"              and  s.Type_ = "REG_SZ"        Then  flags = flags or 1
		If s.Name = "CDInstall"            and  s.Type_ = "REG_DWORD"     Then  flags = flags or 1
		If s.Name = "DriverCachePath"      and  s.Type_ = "REG_EXPAND_SZ" Then  flags = flags or 2
		If s.Name = "Installation Sources" and  s.Type_ = "REG_MULTI_SZ"  Then  flags = flags or 4
		If s.Name = "PrivateHash"          and  s.Type_ = "REG_BINARY"    Then  flags = flags or 8
		If s.Name = "LogLevel"             and  s.Type_ = "REG_DWORD"     Then  flags = flags or 16
		i = i + 1
	Next
	If flags <> 15   and flags <> 31  and  flags <> 17 and  flags <> 21 Then  Fail
		'// 15=XP, 17=Win7, 21=Win8
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_RegFile] >>> 
'********************************************************************************
Sub  T_RegFile( Opt, AppKey )
	Dim    e, f
	Const  test_fname = "T_RegFile_copy.reg"


	'//======= TestCase(1): Random Write
	copy_ren  "T_RegFileU.reg", test_fname
	Set f = OpenForRegFile( test_fname )
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test2\Sample2", "WriteSample", "REG_SZ"
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test\Sample1", &h14, "REG_DWORD"
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test2\", "Default2X", "REG_SZ"
	f = Empty
	If not fc( test_fname, "T_RegFileU_ans1.reg" ) Then  Fail


	'//======= TestCase(2): Random Read Write
	copy_ren  "T_RegFileU.reg", test_fname
	Set f = OpenForRegFile( test_fname )
	If f.RegRead( "HKEY_CURRENT_USER\Software\_Test2\Sample2" ) <> &h20 Then  Fail
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test2\Sample2", "WriteSample", "REG_SZ"
	If f.RegRead( "HKEY_CURRENT_USER\Software\_Test2\Sample2" ) <> "WriteSample" Then  Fail
	If f.RegRead( "HKEY_CURRENT_USER\Software\_Test\Sample1" ) <> "Value1" Then  Fail
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test\Sample1", &h14, "REG_DWORD"
	If f.RegRead( "HKEY_CURRENT_USER\Software\_Test\Sample1" ) <> &h14 Then  Fail
	If f.RegRead( "HKEY_CURRENT_USER\Software\_Test2\" ) <> "Default2" Then  Fail
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test2\", "Default2X", "REG_SZ"
	If f.RegRead( "HKEY_CURRENT_USER\Software\_Test2\" ) <> "Default2X" Then  Fail
	f = Empty
	If not fc( test_fname, "T_RegFileU_ans1.reg" ) Then  Fail


	'//======= TestCase(3): Add and Remove
	copy_ren  "T_RegFileU.reg", test_fname
	Set f = OpenForRegFile( test_fname )
	If not IsEmpty( f.RegRead( "HKEY_CURRENT_USER\Software\_Test2\Sample2X" ) ) Then  Fail
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test2\Sample2X", "WriteSample", "REG_SZ"
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test\Sample1", Empty, Empty
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test3\Sample3", "Value31", "REG_SZ"
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test3\", "Value30", "REG_SZ"
	If f.RegRead( "HKEY_CURRENT_USER\Software\_Test2\Sample2X" ) <> "WriteSample" Then  Fail
	If not IsEmpty( f.RegRead( "HKEY_CURRENT_USER\Software\_Test\Sample1" ) ) Then  Fail
	f = Empty
	If not fc( test_fname, "T_RegFileU_ans3.reg" ) Then  Fail


	'//======= TestCase(4)a: Error
	copy_ren  "T_RegFileU.reg", test_fname
	If TryStart(e) Then  On Error Resume Next
		T_RegFile_ErrSub  test_fname
	If TryEnd Then  On Error GoTo 0
	e.Clear
	If not fc( test_fname, "T_RegFileU.reg" ) Then  Fail


	del  test_fname
	Pass
End Sub


Sub  T_RegFile_ErrSub( test_fname )
	'//======= TestCase(4)b: Error
	copy_ren  "T_RegFileU.reg", test_fname
	Dim  f : Set f = OpenForRegFile( test_fname )
	f.RegWrite  "HKEY_CURRENT_USER\Software\_Test2\Sample2X", "WriteSample", "REG_SZ"
	UnknownObj.ErrMethod
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


 
