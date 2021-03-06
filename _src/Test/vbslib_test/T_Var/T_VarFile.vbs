Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( "1","T_VarFile1", "2","T_SetVarInBatchFile" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_VarFile1] >>> 
'********************************************************************************
Sub  T_VarFile1( Opt, AppKey )
	Dim  f, e
	Dim  file_path : file_path = "settings.txt"
	Dim  ans_path  : ans_path  = "settings_ans.txt"

	cd  g_fs.GetParentFolderName( WScript.ScriptFullName )
	Dim w_:Set w_=AppKey.NewWritable( Array( file_path, ans_path, "." ) ).Enable()

	EchoTestStart  "T_VarFile1"


	'//=== Test of set
	CreateFile  ans_path,  "Var_A=1" +vbCRLF+ "Var_B=ABC" +vbCRLF+ "Var_C= CDEF " +vbCRLF

	CreateFile  file_path, "Var_A=1" +vbCRLF+ "Var_C= CDEF " +vbCRLF+ " "+vbCRLF
	Set f = OpenForEnvVarsFile( file_path )
	f.set_ "Var_B", "ABC"  '//######################
	f = Empty
	If not fc( file_path, ans_path ) Then  Fail

	CreateFile  file_path, "Var_A=2" +vbCRLF+ "Var_B=ABC" +vbCRLF+ "Var_C= CDEF " +vbCRLF+ " "+vbCRLF
	Set f = OpenForEnvVarsFile( file_path )
	f.set_ "VAR_A", 1  '//###################### not change to upper case
	f = Empty
	If not fc( file_path, ans_path ) Then  Fail



	'//=== Test of select
	CreateFile  file_path, "Var_B=1" +vbCRLF+ "Var_C=1" +vbCRLF+ "Var_E=A" +vbCRLF
	CreateFile  ans_path,  "Var_A=1" +vbCRLF+ "Var_E=A" +vbCRLF
	Set f = OpenForEnvVarsFile( file_path )
	f.select_  "Var_A", 1, Array( "Var_A", "Var_B", "Var_C" ), Empty  '//######################
	f = Empty
	If not fc( file_path, ans_path ) Then  Fail

	CreateFile  file_path, "Var_A=1" +vbCRLF+ "Var_E=A" +vbCRLF
	CreateFile  ans_path,  "Var_A=B" +vbCRLF+ "Var_E=A" +vbCRLF
	Set f = OpenForEnvVarsFile( file_path )
	f.select_  "Var_A", "B", Array( "Var_A", "Var_B" ), Empty  '//######################
	f = Empty
	If not fc( file_path, ans_path ) Then  Fail

	CreateFile  file_path, "Var_A=1" +vbCRLF+ "Var_B=0" +vbCRLF+ "Var_C=0" +vbCRLF+ "Var_E=1" +vbCRLF
	CreateFile  ans_path,  "Var_A=0" +vbCRLF+ "Var_B=1" +vbCRLF+ "Var_C=0" +vbCRLF+ "Var_E=1" +vbCRLF
	Set f = OpenForEnvVarsFile( file_path )
	f.select_  "Var_B", 1, Array( "Var_A", "Var_B", "Var_C" ), 0  '//######################
	f = Empty
	If not fc( file_path, ans_path ) Then  Fail



	'//=== Test of writable
	CreateFile  file_path, "Var_A=1" +vbCRLF
	CreateFile  ans_path,  "Var_A=1" +vbCRLF
	w_ = Empty : SetWritableMode  F_ErrIfWarn
	If TryStart(e) Then  On Error Resume Next
		T_VarFileWritableErrSub  file_path
	If TryEnd Then  On Error GoTo 0
	If e.num <> E_OutOfWritable  Then  Fail
	e.Clear
	If not fc( file_path, ans_path ) Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_VarFileWritableErrSub] >>> 
'********************************************************************************
Sub  T_VarFileWritableErrSub( FilePath )
	Dim f : Set f = OpenForEnvVarsFile( FilePath )
	f.set_ "Var_B", "ABC"  '// Raise writable error here
End Sub


 
'********************************************************************************
'  <<< [T_SetVarInBatchFile] >>> 
'********************************************************************************
Sub  T_SetVarInBatchFile( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_settings_batch.bat" ).Enable()
	copy_ren  "settings_batch.bat", "_settings_batch.bat"
	SetVarInBatchFile  "_settings_batch.bat", "FIRST", 11
	SetVarInBatchFile  "_settings_batch.bat", "upperlowercase", "   lower"
	SetVarInBatchFile  "_settings_batch.bat", "SpaceAfter  ", "space?  "
	AssertFC  "_settings_batch.bat", "settings_batch_ans.bat"



	'//=== Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		SetVarInBatchFile  "_settings_batch.bat", "NotFound", "fresh!"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "NotFound" ) > 0
	Assert  e2.num <> 0

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

 
