Option Explicit 


Class  MainWork
	Public  MainInterface  '// "main", "main2", "main_old"
	Public  Code           '// as string
	Public  g_debug_Code   '// as string. ex. "g_debug = 0"
	Public  Is_g_Vers_OldMain '// as boolean

	Public  IsManualTest  '// as boolean
End Class


Sub  Main( )
	Dim  e, e2  ' as Err2
	Dim  is_exist_vbslib : is_exist_vbslib = IsDefined( "Raise" )
	Dim w_ : If is_exist_vbslib Then  Set w_=AppKey.NewWritable( "." ).Enable()

	Dim  w : Set w = new MainWork
	Dim  mains : mains = Array( "main2", "main", "main_old" )
	Dim  main_inf

	w.IsManualTest = ArgumentExist( "ManualTest" )



	'// call MakeMainScriptFile : normal run
	For Each main_inf  In mains
		w.MainInterface     = main_inf
		w.Code              = "WScript.Echo  ""Hello, world!"""
		w.g_debug_Code      = "g_debug = 0"
		w.Is_g_Vers_OldMain = False
		MakeMainScriptFile  w, "MainSrc.vbs", "Main_tmp.vbs"
		RunProg  "cscript //nologo  Main_tmp.vbs", ""
	Next


	'// Case of Raise 1
	For Each main_inf  In mains
		echo  " ((( 未知の実行時エラーです。 ))) "
		w.MainInterface     = main_inf
		w.Code              = "Err.Raise  1"
		w.g_debug_Code      = "g_debug = 0"
		w.Is_g_Vers_OldMain = False
		MakeMainScriptFile  w, "MainSrc.vbs", "Main_tmp.vbs"
		If is_exist_vbslib Then  If TryStart(e) Then  On Error Resume Next

			echo    vbCRLF+"Next is Error Test"
			RunProg  "cscript //nologo  Main_tmp.vbs  /ChildProcess:0", ""

		If is_exist_vbslib Then
			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2
			echo    "Next is Error Test"
			echo    GetErrStr( e2.num, e2.desc )
			Assert  e2.num = 1
		End If
	Next


	'// Case of Stop at Raise 1
	If w.IsManualTest Then
	 For Each main_inf  In mains
		echo  " ((( 未知の実行時エラーです。 ))) "
		w.MainInterface     = main_inf
		w.Code              = "Err.Raise  1  '// ここでブレークすること"
		w.g_debug_Code      = "g_debug = 1"
		w.Is_g_Vers_OldMain = ( main_inf = "main_old" )
		MakeMainScriptFile  w, "MainSrc.vbs", "Main_tmp.vbs"
		echo_v  "--------------------------------------------------------"
		echo_v  "> "+ w.MainInterface +" 版のテスト : 一般エラー"
		echo_v  "デバッガが起動します。"
		echo_v  "「ここでブレークすること」と書かれたソースでブレークすること"
		echo_v  "確認したら、スクリプトのウィンドウを閉じてください。"
		pause
		If is_exist_vbslib Then  If TryStart(e) Then  On Error Resume Next
			RunProg  "cscript //nologo  Main_tmp.vbs  /ChildProcess:0", ""
		If is_exist_vbslib Then  If TryEnd Then  On Error GoTo 0: e.Clear
	 Next
	End If


	'// Case of 引数の数が一致していません （main の引数の構成が違うときの対処と重複するエラー）
	For Each main_inf  In mains
		echo  " ((( 引数の数が一致していませんエラー ))) "
		w.MainInterface     = main_inf
		w.Code              = "NotMatch  ""BadParamCount"""
		w.g_debug_Code      = "g_debug = 0"
		w.Is_g_Vers_OldMain = False
		If is_exist_vbslib Then  If TryStart(e) Then  On Error Resume Next

			MakeMainScriptFile  w, "MainSrc.vbs", "Main_tmp.vbs"
			RunProg  "cscript //nologo  Main_tmp.vbs  /ChildProcess:0", ""

		If is_exist_vbslib Then
			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2
			echo    "Next is Error Test"
			echo    GetErrStr( e2.num, e2.desc )
			Assert  e2.num = 450
		End If
	Next


	'// Case of Stop at 引数の数が一致していませんエラー
	If w.IsManualTest Then
	 For Each main_inf  In mains
		echo  " ((( 引数の数が一致していませんエラー ))) "
		w.MainInterface     = main_inf
		w.Code              = "NotMatch  ""BadParamCount""  '// ここでブレークすること"
		w.g_debug_Code      = "g_debug = 1"
		w.Is_g_Vers_OldMain = ( main_inf = "main_old" )
		MakeMainScriptFile  w, "MainSrc.vbs", "Main_tmp.vbs"
		echo_v  "--------------------------------------------------------"
		echo_v  "> "+ w.MainInterface +" 版のテスト : 引数の数が一致していませんエラー"
		echo_v  "デバッガが起動します。"
		echo_v  "「ここでブレークすること」と書かれたソースでブレークすること"
		echo_v  "確認したら、スクリプトのウィンドウを閉じてください。"
		pause
		If is_exist_vbslib Then  If TryStart(e) Then  On Error Resume Next
			RunProg  "cscript //nologo  Main_tmp.vbs  /ChildProcess:0", ""
		If is_exist_vbslib Then  If TryEnd Then  On Error GoTo 0 : e.Clear
	 Next

		w.MainInterface     = "main_old"
		w.Code              = "NotMatch  ""BadParamCount""  '// ここでブレークすること"
		w.g_debug_Code      = "g_debug = 1"
		w.Is_g_Vers_OldMain = False
		MakeMainScriptFile  w, "MainSrc.vbs", "Main_tmp.vbs"
		echo_v  "--------------------------------------------------------"
		echo_v  "> "+ w.MainInterface +" 版のテスト : 引数なし main で g_Vers(""OldMain"") なし"
		echo_v  "デバッガが起動します。"
		echo_v  "引数あり main を呼び出す部分でブレークして、ソースに g_Vers(""OldMain"") のガイドにがあること"
		echo_v  "確認したら、スクリプトのウィンドウを閉じてください。"
		pause
		If is_exist_vbslib Then  If TryStart(e) Then  On Error Resume Next
			RunProg  "cscript //nologo  Main_tmp.vbs  /ChildProcess:0", ""
		If is_exist_vbslib Then  If TryEnd Then  On Error GoTo 0 : e.Clear
	End If


	If is_exist_vbslib Then  Pass  : Else  echo_v  "Pass."
End Sub


 
'*************************************************************************
'  <<< [MakeMainScriptFile] >>> 
'*************************************************************************
Sub  MakeMainScriptFile( w, SrcPath, DstPath )
	Dim  text

	text = ReadFile( SrcPath )

	Select Case  w.MainInterface

		Case  "main"
			text = Replace( text, "Sub  Main( )",_
				"Sub  Main( Opt, AppKey )" )

		Case  "main2"
			text = Replace( text, "Sub  Main( )",_
				"Sub  main2( Opt, AppKey )" )
	End Select

	text = Replace( text, "'//[code]", w.Code )

	text = Replace( text, "g_debug = 0",  w.g_debug_Code )

	If w.Is_g_Vers_OldMain Then _
		text = Replace( text,  "'// g_Vers(""OldMain"") = 1",  "g_Vers(""OldMain"") = 1" )

	CreateFileW  DstPath, text
End Sub


 
'// copy from vbslib_mini.vbs ==============================================

Function  ArgumentExist( name )
	Dim  key
	For Each key in WScript.Arguments.Named
		If key = name  Then  ArgumentExist = True : Exit Function
	Next
	ArgumentExist = False
End Function


 
Sub  Pause()
	echo_v  "続行するには Enter キーを押してください . . ."
	WScript.StdIn.ReadLine
End Sub


 
Function  RunProg( cmdline, stdout_stderr_redirect )
	Dim  ex : Set ex = g_sh.Exec( cmdline )
	echo_v  ">RunProg  "+ cmdline
	RunProg = WaitForFinishAndRedirect( ex, stdout_stderr_redirect )
	echo_v  ""
End Function


 
Function  WaitForFinishAndRedirect( ex, path )
	Do While ex.Status = 0
		Do Until ex.StdOut.AtEndOfStream : echo_v  ex.StdOut.ReadLine : Loop
		Do Until ex.StdErr.AtEndOfStream : echo_v  ex.StdErr.ReadLine : Loop
	Loop
	Do Until ex.StdOut.AtEndOfStream : echo_v  ex.StdOut.ReadLine : Loop
	Do Until ex.StdErr.AtEndOfStream : echo_v  ex.StdErr.ReadLine : Loop
	WaitForFinishAndRedirect = ex.ExitCode
End Function


 
Function  ReadFile( Path )
	Dim f: Set f = g_fs.OpenTextFile( Path, 1, False, -2 )
	ReadFile = f.ReadAll()
End Function


 
Sub  CreateFile( Path, Text )
	Dim f: Set f = g_fs.CreateTextFile( Path, True, False )
	f.Write  Text
End Sub


 
Sub  CreateFileW( Path, Text )
	Dim f: Set f = g_fs.CreateTextFile( Path, True, True )
	f.Write  Text
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


 
