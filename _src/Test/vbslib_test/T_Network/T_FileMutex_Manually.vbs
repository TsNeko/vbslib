Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_FileMutex_1",_
			"2","T_FileMutex_TimeOut",_
			"3","T_AssertExist_UNC" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_FileMutex_1] >>> 
'********************************************************************************
Sub  T_FileMutex_1( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	Set c = g_VBS_Lib

	'// Set "machine"
	Set ec = new EchoOff
	Set mutex = LockByFileMutex( ".\_Mutex.txt", 0 )
	If not mutex is Nothing Then
		machine = "A"
	Else
		machine = "B"
	End If
	mutex = Empty
	ec = Empty


	echo  "これは、PC-"+ machine +" です。"
	echo  ""
	echo  "g_sh.CurrentDirectory = """+ g_sh.CurrentDirectory +""""
	echo  "g_vbslib_folder = """+ g_vbslib_folder +""""
	echo  ""
	echo  "=== Test of PC-A -> PC-B ==="
	echo  ""
	If machine = "A" Then
		Set mutex = LockByFileMutex( ".\_Mutex.txt", c.Forever )
		AssertExist  ".\_Mutex.txt"
		echo  "ロック中です。"
		echo_line
		echo  "PC-A> PC-B で、PC-A と同じスクリプトを起動してください。"
		echo_line
		echo  "つづいて、ロックを解除します。"
		Pause
	End If
	If machine = "B" Then
		echo_line
		echo  "PC-B> ロック解除を待っていることを確認してください。 "+_
			"確認したら PC-A でロックを解除してください。"
		echo_line

		Set mutex = LockByFileMutex( ".\_Mutex.txt", c.Forever )
		AssertExist  ".\_Mutex.txt"
		echo  "ロック中です。"
		echo_line
		echo  "PC-B> PC-A で再度ロックしてください。"
		echo_line
		echo  ""
		echo  "=== Test of PC-B -> PC-A ==="
		echo  ""
		echo  "つづいて、ロックを解除します。"
		Pause
	End If
	If machine = "A" Then
		mutex = Empty
		echo  "ロックを解除しました。"
		echo_line
		echo  "PC-A> PC-B がロック中になったことを確認してください。"
		echo_line
		echo  ""
		echo  "=== Test of PC-B -> PC-A ==="
		echo  ""
		echo  "つづいて、再度ロックをしようとします。"
		Pause
		echo_line
		echo  "PC-A> ロックの完了待ちをしていることを確認したら、PC-B でロックを解除してください。"
		echo_line
		Set mutex = LockByFileMutex( ".\_Mutex.txt", c.Forever )
		echo  "ロック中です"
	End If
	mutex = Empty
	echo  "ロックを解除しました"
	If machine = "A" Then
		Assert  not exist( ".\_Mutex.txt" )
	End If

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_FileMutex_TimeOut] >>> 
'********************************************************************************
Sub  T_FileMutex_TimeOut( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	Set c = g_VBS_Lib


	'// Set "machine"
	echo  "先に起動した PC が PC-A、後に起動した PC が PC-B です。"
	echo  "1) PC-A"
	echo  "2) PC-B"
	Select Case  Input( "1 or 2>" )
		Case  "1" : machine = "A"
		Case  "2" : machine = "B"
		Case Else  Error
	End Select


	echo  "これは、PC-"+ machine +" です。"
	echo  ""
	If machine = "A" Then
		echo_line
		echo  "PC-A> PC-B で、PC-A と同じスクリプトを起動してください。"
		echo_line
		echo  "つづいて、ロックを開始しようとします。" +_
			"３秒後にタイムアウト・エラーになることを確認してください。"
		Pause
	End If
	If machine = "B" Then
		Set mutex = LockByFileMutex( ".\_Mutex2.txt", c.Forever )
		AssertExist  ".\_Mutex2.txt"
		echo  "ロック中です。"
		echo_line
		echo  "PC-B> PC-A でロックを開始してください。"
		echo_line
		Pause
	End If
	If machine = "A" Then
		If TryStart(e) Then  On Error Resume Next

			Set mutex = LockByFileMutex( ".\_Mutex2.txt", 3000 )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num = E_TimeOut

		echo_line
		echo  "PC-A> PC-B のスクリプトの続き（終了）を実行してください。"
		echo_line
		Pause
	End If
	mutex = Empty
	echo  "ロックを解除しました"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_AssertExist_UNC] >>> 
'********************************************************************************
Sub  T_AssertExist_UNC( Opt, AppKey )
	Set c = g_VBS_Lib

	AssertExist  ".\"+ WScript.ScriptName
	Assert  not exist_ex( ".\"+ UCase( WScript.ScriptName ), c.CaseSensitive )
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


 
