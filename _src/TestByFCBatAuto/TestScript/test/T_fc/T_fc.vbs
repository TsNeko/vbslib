Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	test_in_file
	test_in_folder
End Sub


 
'********************************************************************************
'  <<< [test_in_file] >>>
'********************************************************************************
Sub  test_in_file
	fo = "contents\"
	out1 = "T_fc_r_fi_log_1.txt"
	out  = "T_fc_r_fi_log.txt"
	del  out

	r= fc_r( fo+"TxtA.txt", fo+"TxtA.txt", out1 ) : cat Array( out, out1 ), out
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc_r( fo+"TxtA.txt", fo+"TxtB.txt", out1 ) : cat Array( out, out1 ), out
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"TxtA.txt", fo+"TxtA.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"TxtA.txt", fo+"TxtA2.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"TxtA.txt", fo+"TxtB.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"TxtB.txt", fo+"TxtA.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"TxtA.txt", fo+"TxtAA.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"TxtAA.txt", fo+"TxtA.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"BinA.bin", fo+"BinA.bin" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"BinA.bin", fo+"BinA2.bin" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"BinA.bin", fo+"BinB.bin" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"BinB.bin", fo+"BinA.bin" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"BinA.bin", fo+"BinAA.bin" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"BinAA.bin", fo+"BinA.bin" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"Not_Found.txt", fo+"TxtA.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"TxtA.txt", fo+"Not_Found.txt" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	del  out1
End Sub


'********************************************************************************
'  <<< [test_in_folder] >>>
'********************************************************************************
Sub test_in_folder()
	fo = ""
	out1 = "T_fc_r_fo_log_1.txt"
	out  = "T_fc_r_fo_log.txt"
	del  out

	r= fc( fo+"same_A", fo+"same_A" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"same_A", fo+"same_B" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"subcontents_A", fo+"subcontents_B" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"file_n_A", fo+"file_n_B" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"file_n_B", fo+"file_n_A" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"folder_n_A", fo+"folder_n_B" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	r= fc( fo+"folder_n_B", fo+"folder_n_A" )
	echo_r  "return = " & r, out1 : cat Array( out, out1 ), out

	del  out1
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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
