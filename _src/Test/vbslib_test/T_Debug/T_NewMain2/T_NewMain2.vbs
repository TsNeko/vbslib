Option Explicit 


Class  MainWork
	Public  MainInterface  '// "main2", "Main", "main_old"
	Public  Code           '// as string
	Public  g_debug_Code   '// as string. ex. "g_debug = 0"
	Public  Is_g_Vers_OldMain '// as boolean

	Public  IsManualTest  '// as boolean
End Class


Sub  Main( Opt, AppKey )
	Dim  e, e2  ' as Err2
	Dim  is_exist_vbslib : is_exist_vbslib = IsDefined( "Raise" )
	Dim w_ : If is_exist_vbslib Then  Set w_=AppKey.NewWritable( "." ).Enable()

	Dim  w : Set w = new MainWork
	Dim  mains : mains = Array( "main2", "Main", "main_old" )
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


	'// Case of 引数の数が違いますエラー （main の引数の構成が違うときの対処と重複するエラー）
	For Each main_inf  In mains
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


	'// Case of Stop at 引数の数が違いますエラー
	If w.IsManualTest Then
	 For Each main_inf  In mains
		w.MainInterface     = main_inf
		w.Code              = "NotMatch  ""BadParamCount""  '// ここでブレークすること"
		w.g_debug_Code      = "g_debug = 1"
		w.Is_g_Vers_OldMain = ( main_inf = "main_old" )
		MakeMainScriptFile  w, "MainSrc.vbs", "Main_tmp.vbs"
		echo_v  "--------------------------------------------------------"
		echo_v  "> "+ w.MainInterface +" 版のテスト : 引数の数が違いますエラー"
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



Sub  MakeMainScriptFile( w, SrcPath, DstPath )
	Dim  text

	text = ReadFile( SrcPath )

	Select Case  w.MainInterface

		Case  "Main"
			text = Replace( text, "Sub  main( )",_
				"Sub  Main( Opt, AppKey )" )
			Assert  InStr( text, "Main(" ) > 0

		Case  "main2"
			text = Replace( text, "Sub  main( )",_
				"Sub  main2( Opt, AppKey )" )
			Assert  InStr( text, "main2(" ) > 0
	End Select

	text = Replace( text, "'//[code]", w.Code )

	text = Replace( text, "g_debug = 0",  w.g_debug_Code )

	If w.Is_g_Vers_OldMain Then
		text = Replace( text,  "'// g_Vers(""OldMain"") = 1",  "g_Vers(""OldMain"") = 1" )
		Assert  InStr( text, "'// g_Vers(""OldMain"") = 1" ) = 0
		Assert  InStr( text,     "g_Vers(""OldMain"") = 1" ) > 0
	End If

	CreateFile  DstPath, text
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

  
