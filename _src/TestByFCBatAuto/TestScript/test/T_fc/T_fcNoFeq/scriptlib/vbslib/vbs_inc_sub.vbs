'// vbs_inc_sub.vbs (Full path is in g_vbslib_path)

'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************


'// Set g_vbslib_path=(this script full path) and  g_vbslib_folder=(vbslib folder full path)  before including this script.


Dim  g_vbslib_path, g_vbslib_folder
Dim  g_vbslib_ver_folder
Dim  g_debug_vbs_inc, g_debug_params, g_is_compile_debug, g_compile_debug_dic, g_compile_debug_line
Dim  g_debug, g_is_debug, g_debug_tree, g_debug_process, g_debug_or_test, g_IncludePathes, g_CommandPrompt
Dim  g_verbose, g_debug_select
Dim  g_is_cscript_exe, g_admin, g_is_admin, g_is64bitWindows, g_is64bitWSH
Dim  g_sh, g_fs
Dim  g_f, g_i, g_err, g_path
Dim  g_start_in_path
Dim  g_ExitCode
Dim  g_SrcPath : g_SrcPath = g_vbslib_path
Dim  g_vbslib_var_break_symbol
Dim  g_FinalizeInModulesCaller
Dim  g_IsFinalizing
Dim  g_CUI, g_EchoCopyStream
Dim  g_IsDefinedRaise : g_IsDefinedRaise = False
ReDim  g_debug_var(10)  '//[g_debug_var]
Const  WScriptQuit_Num = &h8004FFFD  '// Err.Number by WScript.Quit

If IsEmpty(g_vbslib_path) Then _
	Err.Raise  1,,"vbs_inc needs other script using vbslib header"

'If IsEmpty(g_fs) Then  Set g_fs = CreateObject( "Scripting.FileSystemObject" )
'If IsEmpty(g_sh) Then  Set g_sh = WScript.CreateObject("WScript.Shell")

If IsEmpty(g_vbslib_folder) Then _
	g_vbslib_folder = g_fs.GetParentFolderName( g_vbslib_path )
g_vbslib_ver_folder = g_fs.GetParentFolderName( g_vbslib_path ) + "\"

g_start_in_path = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )

g_i = WScript.Arguments.Named("g_debug")
g_debug_vbs_inc = Not IsEmpty( WScript.Arguments.Named("debug") )
If IsEmpty( g_debug_or_test ) Then  g_debug_or_test = not IsEmpty( g_i )


'//=== Debug print command line parameters ....
If (not IsEmpty( g_i ) or g_debug_vbs_inc ) And (LCase( Right( WScript.FullName, 11 ) ) = "cscript.exe") Then
	echo_v  ">" + g_fs.GetFileName( WScript.FullName ) + " """ + WScript.ScriptFullName + """"
	echo_v  "g_start_in_path = " + g_start_in_path
	For g_i = 0 to WScript.Arguments.Count - 1
		echo_v  "Arguments("&g_i&") = """+ WScript.Arguments(g_i) + """"
	Next
	echo_v  "g_vbslib_path = " + g_vbslib_path
End If


'//=== change to command prompt ...
ChangeScriptMode


'//=== Setup to assist to debug the compile error
If not IsEmpty( g_is_compile_debug ) Then
	g_is_compile_debug = g_fs.GetParentFolderName( WScript.ScriptFullName ) +"\"+_
		g_fs.GetBaseName( WScript.ScriptFullName ) + "_compile_debug__.vbs"
	If g_fs.FileExists( g_is_compile_debug ) Then
		Err.Raise  1,, "<ERROR msg=""ファイルが存在するために、g_is_compile_debug の機能が使えません。"+_
			"削除してかまわない内容であるかテキスト・エディターで確認してください。"" path="""+ g_is_compile_debug +"""/>"
	End If
	Set g_compile_debug_dic = CreateObject( "Scripting.Dictionary" )
	Set g_f = g_fs.CreateTextFile( g_is_compile_debug, True, False )
	g_f.WriteLine  "Option Explicit "
	g_f.WriteLine  "'// このファイルは、vbslib の g_is_compile_debug 機能の内部処理に使う"+_
		"一時的なファイルですが、削除しても問題ありません。"
	g_f.WriteLine  "Err.Raise  1,,""コンパイルエラーを再現しようとしましたが発生しませんでした"""
	g_f = Empty
	CompileDebug_addScript  WScript.ScriptFullName, False
	CompileDebug_addScript  g_vbslib_path, False
End If

If not IsEmpty( g_Vers( "DuplicateErrorClassName" ) ) Then _
	DebugDuplicateError2  g_Vers( "DuplicateErrorClassName" )


'//=== Load setting script
If g_is_debug or g_debug_vbs_inc Then  echo_v ">include setting folders"
ReDim  g_vbslib_setting_paths( 0 )
g_vbslib_setting_paths( 0 ) = g_vbslib_ver_folder + "setting_default"

If g_sh.ExpandEnvironmentStrings( "%myhome_mem%" ) <> "%myhome_mem%" Then
	ReDim Preserve  g_vbslib_setting_paths( UBound( g_vbslib_setting_paths ) + 1 )
	g_vbslib_setting_paths( UBound( g_vbslib_setting_paths ) ) = _
		g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\scriptlib\setting_mem" )
End If

ReDim Preserve  g_vbslib_setting_paths( UBound( g_vbslib_setting_paths ) + 2 )
g_vbslib_setting_paths( UBound( g_vbslib_setting_paths ) - 1 ) = _
	g_sh.ExpandEnvironmentStrings( "%APPDATA%\Scripts" )
g_vbslib_setting_paths( UBound( g_vbslib_setting_paths ) ) = _
	g_vbslib_ver_folder + "setting"

For Each  g_path  In g_vbslib_setting_paths
	If g_fs.FolderExists( g_path ) Then
		For Each g_f in g_fs.GetFolder( g_path ).Files
			If LCase( g_fs.GetExtensionName( g_f.Path ) ) = "vbs" Then _
				include  g_f.Path
		Next
	End If
Next


'//=== variables of innitialize/finalize
Dim    g_InitializeModule
Redim  g_InitializeModules(-1)
Redim  g_InitializeModules_VBSPath(-1)

Set    g_FinalizeInModulesCaller = new FinalizeInModulesCaller
				 '// FinalizeInModulesCaller::Class_Terminate is called First.
Dim    g_FinalizeModule
Dim    g_FinalizeLevel
Redim  g_FinalizeModules(-1)
Redim  g_FinalizeLevels(-1)
Redim  g_FinalizeModules_VBSPath(-1)


'//=== read and execute g_IncludePathes( )
If not IsDefined( "Setting_getIncludePathes" ) Then _
	Err.Raise  1,,"Not defined ""Setting_getIncludePathes"" in vbs_inc_setting.vbs"

g_IncludePathes = Setting_getIncludePathes( g_Vers.Item("IncludeType") )

If g_is_debug or g_debug_vbs_inc Then  echo_v ">include libraries by g_IncludePathes in vbs_inc_setting.vbs"
For g_i = 0 To UBound( g_IncludePathes )
	If Not IsEmpty( g_IncludePathes(g_i) ) Then

		'//=== set default value
		g_InitializeModule = Empty
		g_FinalizeModule = Empty
		g_FinalizeLevel = 100

If True Then
		If not g_fs.FileExists( g_vbslib_ver_folder + g_IncludePathes(g_i) ) Then
			Err.Raise  507, "Include path " + _
				g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) ) + _
				" is not found. See " + g_vbslib_ver_folder + "vbs_inc_setting.vbs"
		End If

		'// Include from Setting_getIncludePathes() in vbs_inc_setting.vbs
		include  g_vbslib_ver_folder + g_IncludePathes(g_i)
Else

		If g_is_debug or g_debug_vbs_inc Then  echo_v ">include  """ + g_vbslib_ver_folder + g_IncludePathes(g_i) + """"


		'//=== read and execute g_IncludePathes(g_i)
		On Error Resume Next
			Set  g_f = g_fs.OpenTextFile( g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) ),,,-2 )
		g_err = Err.Number : On Error Goto 0

		If g_err <> 0 Then
			If g_err = 53 or g_err = 76 Then
				Err.Raise g_err, "Include path " + _
					g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) ) + _
					" is not found. See " + g_vbslib_ver_folder + "vbs_inc_setting.vbs"
			Else
				Err.Raise g_err
			End If
		End If

		g_SrcPath = g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) )

		If not g_is_debug Then
			On Error Resume Next
				Execute  g_f.ReadAll()
			g_err = Err.Number : On Error Goto 0
		Else
			Execute  "'// g_SrcPath=""" + g_SrcPath +""""+vbCRLF+ g_f.ReadAll()
		End If

		g_SrcPath = g_vbslib_path

		If g_err <> 0 Then
			If g_err = &h411 or g_err = &h3f7 or g_err = &h400 Then
				CompileDebug_guide  g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) )
				Err.Raise g_err
			Else
				Err.Raise g_err, "Error in including " + _
					g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) )
			End If
		End If
End If


		'//=== g_InitializeModules( ) <= g_InitializeModule
		'//=== g_InitializeModules_VBSPath( ) <= g_IncludePathes(g_i)
		If Not IsEmpty( g_InitializeModule ) Then
			Redim Preserve  g_InitializeModules( UBound( g_InitializeModules ) + 1 )
			Set  g_InitializeModules( UBound( g_InitializeModules ) ) = g_InitializeModule
			g_InitializeModule = Empty

			Redim Preserve  g_InitializeModules_VBSPath( UBound( g_InitializeModules_VBSPath ) + 1 )
			g_InitializeModules_VBSPath( UBound( g_InitializeModules_VBSPath ) ) = g_IncludePathes(g_i)
		End If


		'//=== g_FinalizeModules( ) <= g_FinalizeModule
		If Not IsEmpty( g_FinalizeModule ) Then
			Redim Preserve  g_FinalizeModules( UBound( g_FinalizeModules ) + 1 )
			Set  g_FinalizeModules( UBound( g_FinalizeModules ) ) = g_FinalizeModule
			g_FinalizeModule = Empty

			Redim Preserve  g_FinalizeModules_VBSPath( UBound( g_FinalizeModules_VBSPath ) + 1 )
			g_FinalizeModules_VBSPath( UBound( g_FinalizeModules_VBSPath ) ) = g_IncludePathes(g_i)

			Redim Preserve  g_FinalizeLevels( UBound( g_FinalizeLevels ) + 1 )
			g_FinalizeLevels( UBound( g_FinalizeLevels ) ) = g_FinalizeLevel
		End If

		If not IsEmpty( g_is_compile_debug ) Then  CompileDebug_addScript  g_vbslib_ver_folder + g_IncludePathes(g_i), False
	End If
Next


CallInitializeInModules


g_SrcPath = Empty
g_f = Empty


 
'***********************************************************************
'* Function: echo_v
'***********************************************************************
Sub  echo_v( in_Message )
	If g_CommandPrompt <> 0 Then
		WScript.Echo  in_Message
		If not IsEmpty( g_Test ) Then _
			g_Test.WriteLogLine  in_Message
		If not IsEmpty( g_EchoCopyStream ) Then _
			g_EchoCopyStream.WriteLine  in_Message
	End If
End Sub


 
'***********************************************************************
'* Function: CallMainFromVbsLib
'***********************************************************************
Sub  CallMainFromVbsLib()
	Set g_AppKey = new AppKeyClass
	Set option_ = CreateObject("Scripting.Dictionary")
	If WScript.Arguments.Named.Exists( "Main" ) Then
			function_name = WScript.Arguments.Named( "Main" )
			If not IsDefined( function_name ) Then
				Err.Raise  &h80041006,, "<ERROR msg=""Not found function name"" name="""+ _
					function_name +"""/>"
			End If
			Set main_function = GetRef( function_name )
			If g_debug Then en=en  Else  On Error Resume Next

				main_function  option_, g_AppKey.SetKey( new AppKeyClass )

			If g_debug Then en=en  Else  en = Err.Number : ed = Err.Description : On Error GoTo 0
	ElseIf IsDefined("main2") Then
			If g_debug Then en=en  Else  On Error Resume Next

				main2  option_, g_AppKey.SetKey( new AppKeyClass )

			If g_debug Then en=en  Else  en = Err.Number : ed = Err.Description : On Error GoTo 0
	Else
		Dim  en, ed
		If IsEmpty( g_Vers("OldMain") ) Then
			If g_debug Then en=en  Else  On Error Resume Next

				main  option_, g_AppKey.SetKey( new AppKeyClass )
					'// Main 関数の引数が１つも無い場合に、ここでエラーが出るときは、
					'// Main 関数に、引数 ( Opt, AppKey ) を追加するか、
					'// メイン・スクリプトの最後の g_Vers("OldMain") = 1 を有効にしてください。

			If g_debug Then en=en  Else  en = Err.Number : ed = Err.Description : On Error GoTo 0
			If en = 450 Then  g_Vers("OldMain") = True  '// not match arguments error
		End If
		If not IsEmpty( g_Vers("OldMain") ) Then
			If g_debug Then en=en  Else  On Error Resume Next

				main

			If g_debug Then en=en  Else  en = Err.Number : ed = Err.Description : On Error GoTo 0
		End If
	End If

	If en <> 0 Then
		Err.Raise  en,,ed
	End If
End Sub


 
'***********************************************************************
'* Function: ChangeScriptMode
'***********************************************************************
Sub  ChangeScriptMode()
	Dim  is_restart  '// is_restart connects to debugger or runs as admin
	Dim  envs : Set envs = g_sh.Environment( "Process" )
	Dim  os_ver : os_ver = GetOSVersion()
	Dim  sysWOW64_folder : sysWOW64_folder = g_sh.ExpandEnvironmentStrings( "%windir%\SysWOW64" )
	is_restart = False

	'//=== Set default
	If IsEmpty(g_debug) Then  g_debug = 0
	If IsEmpty(g_CommandPrompt) Then  g_CommandPrompt = True
	window_style = 1

	'//=== Get status
	g_is_cscript_exe = (LCase( Right( WScript.FullName, 11 ) ) = "cscript.exe")
	g_is_debug = not IsEmpty( WScript.Arguments.Named("debug") )
	g_is_admin = not IsEmpty( WScript.Arguments.Named("admin") )
	g_is64bitWindows = g_fs.FolderExists( sysWOW64_folder )
	is_32bitWSH = ( InStr( WScript.FullName, "\SysWOW64\" ) = 0 )
	If g_is64bitWindows Then
		If IsEmpty( g_is64bitWSH ) Then  g_is64bitWSH = False
	Else
		g_is64bitWSH = False
	End If


	'//=== Select debugger
	If g_debug_select = 1 Then
		If not g_is_cscript_exe Then
			key = MsgBox( "デバッガーに接続します。", vbOKCancel )
			If key = vbCancel Then  g_debug = 0
		Else
			If not g_is_debug Then  g_debug = 0  '// デバッガーに接続を要求しない
		End If
	End If


	'// g_debug, is_request_debugger
	i = WScript.Arguments.Named("g_debug")
	If not IsEmpty( i ) Then

		'// g_debug_process
		pos = InStr( i, ";" )
		If pos > 0 Then
			g_debug_process = Eval( "Array("+ Mid( i, pos + 1 ) +")" )
			i = Left( i, pos - 1 )
		End If

		'// g_debug, g_debug_tree
		value = Eval( "Array("+ i +")" )
		If UBound( value ) = 0 Then
			If i <> "0" Then  g_debug = Eval( i )
		Else
			pos = InStr( i, "," )
			g_debug = Eval( Left( i, pos - 1 ) )
			g_debug_tree = Eval( "Array("+ Mid( i, pos + 1 ) +")" )
		End If
	End If
	is_request_debugger = False
	If g_debug Then If g_debug <> -1 Then If IsEmpty( g_debug_process ) Then If not g_is_debug Then _
		is_request_debugger = True


	'// g_debug_tree option
	i = WScript.Arguments.Named("g_debug_tree")
	If not IsEmpty( i ) Then
		g_debug_tree = Eval( "Array("+ i +")" )
	End If


	'// is_close_at_finish
	If IsEmpty( WScript.Arguments.Named( "close" ) ) Then
		If (g_CommandPrompt and 4) = 4 Then window_style = 7
		If (g_CommandPrompt and 3) = 2 Then is_close_at_finish = False
		If (g_CommandPrompt and 3) = 1 Then is_close_at_finish = True
		If (g_CommandPrompt and 3) = 0 Then is_close_at_finish = False
	Else
		close_option_num = CInt( WScript.Arguments.Named( "close" ) )  '// close option
		If (close_option_num and 4) = 4 Then window_style = 7
		If (close_option_num and 3) = 2 Then is_close_at_finish = False
		If (close_option_num and 3) = 1 Then is_close_at_finish = True
		If (close_option_num and 3) = 0 Then is_close_at_finish = False
	End If
	g_admin = ( g_admin <> 0 )  '// Change to True or False


	'//=== cscript warning
	If g_sh.RegRead( "HKEY_CLASSES_ROOT\VBSFile\Shell\" ) = "Open2" Then
		MsgBox  "コマンドプロンプトで、cscript /H:wscript を実行してください。"+vbCRLF+_
			"現在の設定では文法エラーなどが発生したときにメッセージが見えません"
	End If


	'//=== Make command line
	directory = g_sh.CurrentDirectory
	If g_CommandPrompt > 0 Then
		If g_is64bitWindows  and  not g_is64bitWSH Then
			host_exe = sysWOW64_folder +"\cscript"
			cmd_exe  = sysWOW64_folder +"\cmd.exe"
		Else
			host_exe = "cscript"
			cmd_exe = envs.Item( "ComSpec" )
		End If

		If g_admin Then
			host = cmd_exe + " /v:on /K (cd /d """ + directory + """ & "+ _
				host_exe +" //nologo"
			host_end = ")"
		Else
			host = cmd_exe + " /v:on /K ("+ host_exe +" //nologo"
			host_end = ")"
		End If
	Else
		If g_is64bitWindows  and  not g_is64bitWSH Then
			host_exe = sysWOW64_folder +"\wscript"
		Else
			host_exe = "wscript"
		End If
		exe  = host_exe
		host = host_exe
		host_end = ""
	End If

	If is_request_debugger Then
		host_opt = " //x"
	Else
		host_opt = ""
	End If

	script = " """ + WScript.ScriptFullName + """"
	opt = ""

	params=""
	For i=0 To WScript.Arguments.Count - 1
		If ( InStr( WScript.Arguments(i), " " ) = 0  and  Trim(WScript.Arguments(i)) <> "" ) and _
			 InStr( WScript.Arguments(i), "(" ) = 0  and  InStr( WScript.Arguments(i), ")" ) = 0  Then
			params=params+" "+WScript.Arguments(i)
		Else
			params=params+" """+WScript.Arguments(i)+""""
		End If
	Next
	If not IsEmpty( g_debug_params ) Then  '// パラメーターを指定して再起動するかどうか
		If g_debug <> 0 Then
			params = params +" "+ g_debug_params
			If not g_is_debug Then  is_restart = True : Stop
			opt = opt + " /debug:1"
		End If
	End If

	If is_request_debugger Then
		If InStr( opt, "/debug:" ) = 0 Then  opt = opt + " /debug:1"
		If not g_is_debug Then  is_restart = True : Stop
	End If

	'// 64bit Windows で 32bit WSH に切り替える
	If g_is64bitWindows Then
		If is_32bitWSH  and  not g_is64bitWSH  and  not g_is_cscript_exe Then
			is_restart = True : Stop
		End If
	End If

	If ( g_admin ) and ( not g_is_admin ) Then  '// 管理者になる要求があるかどうか
		is_admin_user = CurrentUserIsAdminGroup()
		If not is_admin_user Then
			opt = opt + " /admin:1"
			is_restart = True : Stop
		Else
			g_is_admin = True
		End If
	End If

	If is_close_at_finish Then
		If not IsEmpty( WScript.Arguments.Named("SuccessRet") ) Then
			exit_cmd = " & if ""!errorlevel!""==""" & _
				CInt( WScript.Arguments.Named("SuccessRet") ) & """ exit"
		Else
			exit_cmd = " & if ""!errorlevel!""==""21"" exit"
		End If
	Else
		exit_cmd = ""
	End If

	If g_CommandPrompt > 0 Then
		If not g_is_cscript_exe Then  is_restart = True : Stop
	End If


	'//=== start sub process using command prompt or run as administrator
	If is_restart Then

		command_line = host + host_opt + script + params + opt + exit_cmd + host_end

		If g_admin Then
			If os_ver >= 6.0 Then
				If g_CommandPrompt = 0 Then
					s = """Microsoft Windows Based Script Host (wscript.exe)"""
				Else
					s = """Windows コマンド プロセッサ (cmd.exe)"""
				End If
				If MsgBox( "[ UAC（ユーザーアカウント制御）予告 ]" +vbCRLF+vbCRLF+_
					"プログラム名１： "+ s +vbCRLF+vbCRLF+_
					"プログラム名２： "+ WScript.ScriptName +vbCRLF+vbCRLF+_
					s +" から、"+ WScript.ScriptName +" を、管理者として起動します。" +vbCRLF+vbCRLF+_
					"今、起動した "+ WScript.ScriptName +" は、このコンピューターに変更を加えるため、"+ s +_
					" を管理者権限で起動することを今から要求します。 この要求により、UAC（ユーザーアカウント制御）"+_
					"のウィンドウが表示されます。 "+ WScript.ScriptName +" に心当たりがなかったり"+_
					"怪しいサイトから入手したときは、"+_
					"拒否してください。（ウィンドウを閉じてください） また、次回、この予告メッセージが"+_
					"なく、いきなり "+ s +" から管理者権限を要求されたときも拒否してください。"+_
					vbCRLF+vbCRLF+"詳細情報："+vbCRLF+ GetCmdLine(),_
						vbOKCancel, WScript.ScriptName ) = vbCancel Then  Stop : WScript.Quit  1
			Else
				admin_name = GetAdminName()
				If IsEmpty( admin_name ) Then
					If not is_admin_user Then
						MsgBox  "[ 管理者アカウント切り替え予告 ]" +vbCRLF+vbCRLF+_
							"プログラム名： "+ WScript.ScriptName +vbCRLF+vbCRLF+_
							"今、起動した "+ WScript.ScriptName +" は、このコンピューターに変更を加えるため、"+_
							"管理者として起動することを要求しましたが、管理者が登録されていません。"+ vbCRLF+vbCRLF+_
							"テキストエディタを使って下記の内容を """+ i +""" に作成するよう管理者に頼んでください。"+vbCRLF+vbCRLF+_
							"Function  Setting_getAdminUserName()"+vbCRLF+_
							"  Setting_getAdminUserName = ""Admin""  '// Admin を管理者のアカウント名に修正してください"+vbCRLF+_
							"End Function", vbOKOnly, WScript.ScriptName
						Stop : WScript.Quit  1
					End If
				Else
					If MsgBox( "[ 管理者アカウント切り替え予告 ]" +vbCRLF+vbCRLF+_
						"プログラム名： "+ WScript.ScriptName +vbCRLF+vbCRLF+_
						"管理者アカウント名： "+ admin_name +vbCRLF+vbCRLF+_
						WScript.ScriptName +" を、管理者として起動します。" +vbCRLF+vbCRLF+_
						"今、起動した "+ WScript.ScriptName +" は、このコンピューターに変更を加えるため、"+_
						"管理者として起動することを今から要求します。 この要求により、管理者のパスワードが"+_
						"要求されます。 "+ WScript.ScriptName +" に心当たりがなかったり"+_
						"怪しいサイトから入手したときは、"+_
						"拒否してください。（ウィンドウを閉じてください） また、次回、この予告メッセージが"+_
						"なく、いきなり管理者のパスワードが要求されたときも拒否してください。"+_
						vbCRLF+vbCRLF+"詳細情報："+vbCRLF+ GetCmdLine(), _
							vbOKCancel, WScript.ScriptName ) = vbCancel Then  Stop : WScript.Quit  1
				End If
			End If
		End If

		If g_admin and ( os_ver >= 6.0 ) Then

			'// Run as administrator on Windows Vista
			Dim  sh_ap
			Set  sh_ap = CreateObject( "Shell.Application" )


			sh_ap.ShellExecute  exe,  Mid( command_line,  Len(exe)+2 ), _
				directory,  "runas",  window_style


		Else

			'// Change to runas command
			If g_admin and not is_admin_user Then
				command_line = "runas /user:" + admin_name + " """ + _
					Replace( command_line, """", "\""" )+""""
			End If

			'// Run the command
			g_sh.CurrentDirectory = g_start_in_path
			Stop
			WScript.Sleep 100  '// avoid infinitly start explosion


			g_sh.Run  command_line,  window_style,  True


		End If

		Stop : WScript.Quit 0
	End If
End Sub


 
'***********************************************************************
'* Function: CallInitializeInModules
'***********************************************************************
Sub  CallInitializeInModules()
	Dim  i

	For i = 0 To UBound( g_InitializeModules )
		g_InitializeModules( i )( g_InitializeModules_VBSPath( i ) )
	Next
End Sub


 
'***********************************************************************
'* Function: CallFinalizeInModules
'***********************************************************************
Sub  CallFinalizeInModules( Reason )
	Dim  i, min_lv, min_over_lv, b
	Const  limit=999999999
	If g_IsFinalizing Then  Stop  '// Double call
	g_IsFinalizing = True

	min_over_lv = -limit
	Do
		min_lv = limit
		For i = 0 To UBound( g_FinalizeModules )
			If g_FinalizeLevels( i ) < min_lv And  g_FinalizeLevels( i ) > min_over_lv Then _
				min_lv = g_FinalizeLevels( i )
		Next
		If min_lv = limit Then Exit Do

		For i = 0 To UBound( g_FinalizeModules )
			If g_FinalizeLevels( i ) = min_lv Then _
				Call  g_FinalizeModules( i )( g_FinalizeModules_VBSPath( i ), Reason )
		Next
		min_over_lv = min_lv
	Loop

	If VarType( g_is_compile_debug ) = vbString  and  g_fs.FileExists( g_is_compile_debug ) Then
		g_fs.DeleteFile  g_is_compile_debug
		WScript.Echo  "<WARNING msh=""コンパイルエラーは発生しませんでした。g_is_compile_debug=1 を削除してください""/>"
	End If

	g_FinalizeInModulesCaller.m_bDisableCall = True


	Const  Pass_Num = 21, Skip_Num = 22, UserCancel_Num = 24
	Dim  exit_code

	If Err.Number = Pass_Num Then
		exit_code = Pass_Num
	ElseIf Err.Number = UserCancel_Num Then
		exit_code = UserCancel_Num
	ElseIf Err.Number = WScriptQuit_Num Then
		If g_is_debug Then  WScript.Echo  vbCRLF+"WScript.Quit が呼ばれました。しかし vbslib では Raise を呼ぶことを推奨します。"
		exit_code = "? (by WScript.Quit)"
	ElseIf Err.Number <> 0 Then
	 If IsEmpty( WScript.Arguments.Named.Item("ChildProcess") ) or _
	             WScript.Arguments.Named.Item("ChildProcess") = "0"  Then
		If not g_IsDefinedRaise Then
			echo_v  ""
			echo_v  "デバッガーを動かすときは、メイン・スクリプトの最後の g_debug を 1 に修正して再起動してください"
		End If
		If Left( Err.Description, 1 ) = "<" or Err.Number = Skip_Num Then
			WScript.Echo  Err.Description
		Else
			WScript.Echo  GetErrStr( Err.Number, Err.Description )
		End If
		If g_CommandPrompt = 1 Then

			If not IsEmpty( g_CUI ) Then
				While  Left( g_CUI.m_Auto_Keys, 1 ) <> ""  and _
				       Left( g_CUI.m_Auto_Keys, 1 ) <> "."
					g_CUI.m_Auto_Keys = Mid( g_CUI.m_Auto_Keys, 2 )
				WEnd
			End If

			b = False
			If not IsEmpty( g_CUI ) Then
				If Left( g_CUI.m_Auto_Keys, 1 ) = "." Then
					'//=== エラーの確認を自動入力する場合
					If not IsEmpty( WScript.Arguments.Named.Item("GUI_input") ) Then _
						WScript.StdOut.WriteLine  "<WARNING msg='エラーが発生したプロセスは起動したときのプロセスと異なります' current_vbs='" + _
							 WScript.ScriptFullName +"'/>"
					WScript.StdOut.Write  "終了するには Enter キーを押してください . . . "
					WScript.Sleep  2000
					g_CUI.m_Auto_Keys = Mid( g_CUI.m_Auto_Keys, 2 )
					b = True
				End If
			End If
			If not b Then
				If IsEmpty( WScript.Arguments.Named.Item("GUI_input") ) Then
					'// WScript.StdOut.Write  "終了するには Enter キーを押してください . . . "
					'// Wscript.StdIn.ReadLine
					'// 親プロセスが wscript.exe のときは、起動コマンドにある if "!errorlevel!"=="21" exit
					'// が動かないことで cmd.exe /K により止まるため、上記 ReadLine は不要。
					'// 親プロセスが cscript.exe のときや、子プロセスでは、確認をしない。
				Else
					'//=== エラーの確認を GUI でする場合
					WScript.StdOut.WriteLine  "<WARNING msg='エラーが発生したプロセスは起動したときのプロセスと異なります' current_vbs='" + _
							 WScript.ScriptFullName +"'/>"
					WScript.StdOut.Write  "終了するには Enter キーを押してください . . . "
					MsgBox  "終了するには Enter キーを押してください . . . "
				End If
			End If
		End If
	 End If
		exit_code = Err.Number
	Else
		exit_code = Pass_Num
		If not IsEmpty( g_ExitCode ) Then  exit_code = g_ExitCode
	End If

	If exit_code = Pass_Num Then
		If not IsEmpty( WScript.Arguments.Named("SuccessRet") ) Then _
			exit_code = CInt( WScript.Arguments.Named("SuccessRet") )
	End If

	If g_is_debug Then
		WScript.Echo  "exit code = " & exit_code & vbCRLF & _
		              "(but now exit code = 0 with debugger.)"
		If g_admin Then  pause2
		Exit Sub  '// WScript.Quit occurs unknown error with debugger
	ElseIf g_debug = -1 Then
		WScript.Echo  "<WARNING msg=""g_debug=-1 です。g_debug=0 に戻してください""/>"
	ElseIf g_debug_process > 0 Then
		WScript.Echo  "<WARNING msg=""g_debug_process > 0 です。/g_debug オプション、または、g_debug_process への代入を削除してください""/>"
	ElseIf Err.Number <> WScriptQuit_Num Then
		WScript.Quit  exit_code  ' If error was raised here, WSH-exe return is zero only.
		                         ' This code may raise Unbreakable error
	End If
End Sub


 
'***********************************************************************
'* Class: FinalizeInModulesCaller
'***********************************************************************
Class  FinalizeInModulesCaller
	Public  m_bDisableCall
	Private Sub  Class_Terminate()
		If IsEmpty( m_bDisableCall ) Then
			Const  Pass_Num = 21, Skip_Num = 22
			If Err.Number = Pass_Num  or  Err.Number = Skip_Num  or  Err.Number = WScriptQuit_Num Then
				CallFinalizeInModules  0
			Else
				CallFinalizeInModules  1
			End If
		End If
	End Sub

'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Function: pause2
'*    This is available before include vbslib.vbs
'***********************************************************************
Sub  pause2()
	If g_is_cscript_exe Then
		WScript.Echo  "続行するには Enter キーを押してください . . ."
		WScript.StdIn.ReadLine
	End If
End Sub


 
'***********************************************************************
'* Function: ResumePush
'***********************************************************************
Function  ResumePush()
	ResumePush = ( g_debug = 0 )
		'// If error occured, WSH process returns 0.
		'// ResumePop catches error for returning error code.
End Function


 
'***********************************************************************
'* Function: ResumePop
'***********************************************************************
Function  ResumePop()
	Const  Pass_Num = 21
	If Err.Number = 0 or Err.Number = Pass_Num Then
		CallFinalizeInModules  0
	Else
		CallFinalizeInModules  1
	End If
End Function


 
'***********************************************************************
'* Function: GetCmdLine
'***********************************************************************
Function  GetCmdLine()
	Dim  r
	GetCmdLine = """"+ WScript.ScriptFullName +""""
	For Each r  In WScript.Arguments
		GetCmdLine = GetCmdLine +" """+ r +""""
	Next
End Function


 
'***********************************************************************
'* Function: GetErrStr
'***********************************************************************
Function  GetErrStr( en, ed )
	If en = 0 Then
		GetErrStr = "no error"
	ElseIf en = 21 Then
		GetErrStr = "[Pass]"
	Else
		Dim  s

		If Left( ed, 6 ) = "<ERROR" Then  GetErrStr = ed : Exit Function

		s = Replace( ed, "&", "&amp;" )
		s = Replace( s,  "'", "&apos;" )
		s = Replace( s,  "<", "&lt;" )

		If en > 0 And en <= &h7FFF Then
			GetErrStr = "<ERROR err_number='" & en & "' err_description='" & s & "'/>"
		Else
			GetErrStr = "<ERROR err_number='0x" & Hex(en) & "' err_description='" & s & "'/>"
		End If
	End If
End Function


 
'***********************************************************************
'* Function: AppendErrorMessage
'***********************************************************************
Function  AppendErrorMessage( in_OldMessage,  in_Appending_XML_Attributes )
	If Right( in_OldMessage, 2 ) = "/>" Then
		AppendErrorMessage = Left( in_OldMessage,  Len( in_OldMessage ) - 2 ) + _
			" "+ in_Appending_XML_Attributes +"/>"
	Else
		AppendErrorMessage = "<ERROR msg="""+ XmlAttr( in_OldMessage ) +""" "+ _
			in_Appending_XML_Attributes +"/>"
	End If
End Function


 
'***********************************************************************
'* Function: LetSet
'***********************************************************************
Sub  LetSet( Out, In_ )
	If IsObject( In_ ) Then
		Set Out = In_
	Else
		Out = In_
	End If
End Sub


 
'***********************************************************************
'* Function: LetSetWithBracket
'***********************************************************************
Sub  LetSetWithBracket( Out, Index, In_ )
	If IsObject( In_ ) Then
		Set Out( Index ) = In_
	Else
		Out( Index ) = In_
	End If
End Sub


 
'***********************************************************************
'* Function: set_
'***********************************************************************
Sub  set_( Symbol, Value )
	echo  ">set_  """ + Symbol + """, """ & Value & """"

	If Symbol = g_vbslib_var_break_symbol Then  Stop  '// Look at then caller function using watch window of debugger

	Dim envs : Set envs = g_sh.Environment( "Process" )
	If not IsEmpty( g_CurrentVarStackSub ) Then _
		g_CurrentVarStackSub.SetPrevValue1_IfNotExist  Symbol, envs.Item( Symbol )
	If IsEmpty( Value ) Then
		envs.Item( Symbol ) = Value  '// avoid not defined Error before Windows XP
		envs.Remove  Symbol
	Else
		envs.Item( Symbol ) = Value
	End If

	If g_Vers.Exists( Symbol ) Then
		g_Vers.Remove  Symbol  '// for GetVar
	End If
End Sub


 
'***********************************************************************
'* Function: SetVar
'***********************************************************************
Sub  SetVar( Symbol, Value )
	If IsEmpty( Value ) Then
		echo  ">SetVar  """ + Symbol + """, Empty"
	ElseIf IsObject( Value ) Then
		echo  ">SetVar  """ + Symbol + """, ..."
	ElseIf IsArray( Value ) Then
		echo  ">SetVar  """ + Symbol + """, ..."
	Else
		echo  ">SetVar  """ + Symbol + """, """ & Value & """"
	End If

	If Symbol = g_vbslib_var_break_symbol Then  Stop  '// Look at then caller function using watch window of debugger
	If IsObject( Value ) Then
		Set g_Vers( Symbol ) = Value
	Else
		g_Vers( Symbol ) = Value
	End If
End Sub


 
'***********************************************************************
'* Function: GetVar
'***********************************************************************
Function  GetVar( Symbol )
	LetSet  GetVar, GetVarSub( Symbol, False )
End Function

Function  GetVarSub( ByVal Symbol, Is_env )
	If IsObject( g_Vers( Symbol ) ) Then
		Set GetVarSub = g_Vers( Symbol )
	Else
		GetVarSub = g_Vers( Symbol )
		If IsEmpty( GetVarSub ) Then
			Symbol = Replace( Symbol, "%", "" )
			GetVarSub = g_Vers( Symbol )
			If IsEmpty( GetVarSub ) Then _
				GetVarSub = g_sh.ExpandEnvironmentStrings( "%"+Symbol+"%" )
		End If
		If IsArray( GetVarSub ) Then
			If Is_env Then
				Dim  i, arr
				arr = GetVarSub
				For i=0 To UBound( arr )
					arr(i) = env( arr(i) )
				Next
				GetVarSub = arr
			End If
		Else
			If InStr( GetVarSub, "%" ) > 0 Then  GetVarSub = Empty
		End If
	End If

	If Symbol = g_vbslib_var_break_symbol Then  Stop  '// Look at then caller function using watch window of debugger
End Function


 
'***********************************************************************
'* Function: SetVarBreak
'***********************************************************************
Sub  SetVarBreak( Symbol, Opt )
	g_vbslib_var_break_symbol = Symbol

	Dim  sym2 : sym2 = "%"+Symbol+"%"
	Dim  value : value = g_sh.ExpandEnvironmentStrings( sym2 )
	If value <> sym2 Then _
		Stop  '// (Symbol) OS environment variable is already defined.

	value = g_Vers( Symbol )
	If not IsEmpty( value ) Then _
		Stop  '// (Symbol) vbslib variable is already defined.
End Sub


 
'***********************************************************************
'* Class: VarStack
'***********************************************************************
Class  VarStack
	Dim  m_PrevVarStackSub

	Private Sub Class_Initialize()
		If not IsEmpty( g_CurrentVarStackSub ) Then _
			Set m_PrevVarStackSub = g_CurrentVarStackSub

		Set g_CurrentVarStackSub = new VarStackSub
	End Sub

	Private Sub Class_Terminate()
		g_CurrentVarStackSub.Reset

		If not IsEmpty( m_PrevVarStackSub ) Then
			Set g_CurrentVarStackSub = m_PrevVarStackSub
		Else
			g_CurrentVarStackSub = Empty
		End If
	End Sub
End Class


Dim  g_CurrentVarStackSub


Class  VarStackSub

	Public  EnvVarStack ' as Dictionary : key=symbol, value=previous value
	Public  VersStack ' as Dictionary : key=symbol, value=previous value

	Private Sub Class_Initialize()
		Dim key

		Set Me.EnvVarStack = CreateObject( "Scripting.Dictionary" )

		Set Me.VersStack = CreateObject( "Scripting.Dictionary" )
		For Each key  In g_Vers.Keys
			If IsObject( g_Vers( key ) ) Then
				Set  Me.VersStack( key ) = g_Vers( key )
			Else
				Me.VersStack( key ) = g_Vers( key )
			End If
		Next
	End Sub

	Sub  SetPrevValue1_IfNotExist( Symbol, PrevValue )
		If Me.EnvVarStack.Exists( Symbol ) Then  Exit Sub
		Me.EnvVarStack.Item( Symbol ) = PrevValue
	End Sub

	Sub  Reset()
		Dim symbol, value, key
		Dim envs : Set envs = g_sh.Environment( "Process" )

		For Each symbol  In Me.EnvVarStack.Keys
			value = Me.EnvVarStack.Item( symbol )
			echo  ">set_  """ + symbol + """, """ & value & """"
			envs.Item( symbol ) = value
		Next
		Me.EnvVarStack.RemoveAll

		g_Vers.RemoveAll
		For Each key  In Me.VersStack.Keys
			If IsObject( Me.VersStack( key ) ) Then
				Set  g_Vers( key ) = Me.VersStack( key )
			Else
				g_Vers( key ) = Me.VersStack( key )
			End If
		Next
	End Sub
End Class


 
'***********************************************************************
'* Function: Dict
'***********************************************************************
Function  Dict( Elems )
	Dim  i, i_last
	Const  NotCaseSensitive = 1

	Set Dict = CreateObject( "Scripting.Dictionary" )
	Dict.CompareMode = NotCaseSensitive
	i_last = UBound( Elems )

	For i=1 To i_last Step 2
		If IsObject( Elems(i) ) Then
			Set Dict.Item( Elems(i-1) ) = Elems(i)
		Else
			Dict.Item( Elems(i-1) ) = Elems(i)
		End If
	Next
End Function


 
'***********************************************************************
'* Function: Dic_addFromArray
'***********************************************************************
Function  Dic_addFromArray( in_out_Dic, Keys, Items )
	Dim  key, i, item

	If IsEmpty( in_out_Dic ) Then _
		Set in_out_Dic = Dict(Array())

	If IsArray( Items ) Then
		For i = 0 To UBound( Keys )
			If IsObject( Items(i) ) Then
				Set  in_out_Dic.Item( Keys(i) ) = Items(i)  '// can not use LetSet
			Else
				in_out_Dic.Item( Keys(i) ) = Items(i)
			End If
		Next
	Else
		If IsObject( Items ) Then
			For Each key  In Keys
				Set in_out_Dic.Item( key ) = Items
			Next
		Else
			For Each key  In Keys
				in_out_Dic.Item( key ) = Items
			Next
		End IF
	End If

	Set Dic_addFromArray = in_out_Dic
End Function


 
'***********************************************************************
'* Function: IsDefined
'***********************************************************************
Function  IsDefined( Symbol )
	Dim en

	On Error Resume Next
		Call GetRef( Symbol )
	en = Err.Number : On Error GoTo 0

	IsDefined = ( en <> 5 )
End Function


 
'***********************************************************************
'* Function: ThisIsOldSpec
'***********************************************************************
Sub  ThisIsOldSpec()
	If g_bErrorOfOldSpec Then _
		Err.Raise  1,,"<ERROR msg=""将来無くなる機能が使われています""/>"
	If g_bNotCheckOldSpec Then  Exit Sub
	Stop : g_bNotCheckOldSpec = True
End Sub

Sub  SetErrorOfOldSpec()
	g_bErrorOfOldSpec = True
End Sub

Sub  SetNotErrorOfOldSpec()
	g_bErrorOfOldSpec = False
End Sub

Dim  g_bNotCheckOldSpec
Dim  g_bErrorOfOldSpec


 
'***********************************************************************
'* Function: CurrentUserIsAdminGroup
'***********************************************************************
Function  CurrentUserIsAdminGroup()
	If GetOSVersion() < 6.0 Then
		Dim  ex, user_name

		If 1 Then
			Set ex = g_sh.Exec( "net localgroup Administrators" )
			Do While ex.Status = 0 : WScript.Sleep 100 : Loop
			If IsEmpty( GetVar( "USERDOMAIN" ) ) Then
				user_name = g_sh.ExpandEnvironmentStrings( "%USERNAME%" )
			Else
				user_name = g_sh.ExpandEnvironmentStrings( "%USERDOMAIN%\%USERNAME%" )
			End If
			CurrentUserIsAdminGroup = False
			Do Until ex.StdOut.AtEndOfStream
				If ex.StdOut.ReadLine() = user_name Then  CurrentUserIsAdminGroup = True
			Loop
		Else
			Set ex = g_sh.Exec( "NET USER "+ g_sh.ExpandEnvironmentStrings( "%USERNAME%" ) )
			Do While ex.Status = 0 : WScript.Sleep 100 : Loop
			CurrentUserIsAdminGroup = False
			Do Until ex.StdOut.AtEndOfStream
				If InStr( ex.StdOut.ReadLine(), "*Administrators" ) > 0 Then  CurrentUserIsAdminGroup = True
			Loop
		End If
	Else
		Set ex = g_sh.Exec( "whoami /GROUPS /FO CSV" )
		text = ""
		Do While ex.Status = 0 : WScript.Sleep 100 : text = text + ex.StdOut.ReadAll() : Loop
		text = text + ex.StdOut.ReadAll()
		ex = Empty

		If InStr( text, "Mandatory Label\Medium Mandatory Level" ) > 0 Then
			CurrentUserIsAdminGroup = False
		ElseIf InStr( text, "Mandatory Label\High Mandatory Level" ) > 0 Then
			CurrentUserIsAdminGroup = True
		Else
			Error
		End If
	End If
End Function


 
'***********************************************************************
'* Function: GetAdminName
'***********************************************************************
Function  GetAdminName()
	Dim  i

	If IsDefined( "Setting_getAdminUserName" ) Then _
		GetAdminName = Setting_getAdminUserName() : Exit Function

	i = g_sh.ExpandEnvironmentStrings("%ProgramFiles%\vbslib\%USERNAME%\setting\account_setting.vbs")
	If g_fs.FileExists( i ) Then  include  i
	If IsDefined( "Setting_getAdminUserName" ) Then _
		GetAdminName = Setting_getAdminUserName()
End Function


 
'***********************************************************************
'* Function: GetOSVersion
'***********************************************************************
Function  GetOSVersion()
	If not IsEmpty( g_OSVersion ) Then  GetOSVersion = g_OSVersion : Exit Function

	'// Get OS Version from cimv2 of WMI
	Dim  cimv2 : Set cimv2 = GetObject( "winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	Dim  os : Set os = cimv2.ExecQuery( "SELECT * FROM Win32_OperatingSystem" )
	Dim  v, ver
	For Each v in os
		ver = v.Version
	Next
	cimv2 = Empty : os = Empty : v = Empty

	'// Cut build number
	Dim  i
	i = InStr( ver, "." )
	i = InStr( i+1, ver, "." )
	g_OSVersion  = CDbl( Left( ver, i-1 ) )
	GetOSVersion = g_OSVersion
End Function

Dim  g_OSVersion


 
'***********************************************************************
'* Function: Setting_getExistSettingPath
'***********************************************************************
Function  Setting_getExistSettingPath( StepPath )
	If InStr( StepPath, ".." ) > 0 Then  Err.Raise 1,, """.."" cannot be specified"

	For Each  path  In  g_vbslib_setting_paths
		full_path = path +"\"+ StepPath
		If exist( full_path ) Then _
			Setting_getExistSettingPath = full_path
	Next
End Function


 
'***********************************************************************
'* Function: GetExistPathInSetting
'***********************************************************************
Function  GetExistPathInSetting( Pathes, SettingFuncName )
	Dim  i, t
	For i=0 To UBound( Pathes )
		If g_fs.FileExists( Pathes(i) ) Then
			GetExistPathInSetting = g_fs.GetAbsolutePathName(Pathes(i))  '// set to same as Big/Little case
			Exit Function
		End If
	Next
	t = "" :  For i=0 To UBound( Pathes ) : t = t + vbCrLf + "  " + Pathes(i) : Next
	WScript.Echo  SettingFuncName + " で設定している以下のいずれかのファイルが見つかりません。" + _
	 " （参考：vbslib の説明書の setting フォルダー）" + t
	WScript.Sleep  1000
	GetExistPathInSetting = g_fs.GetAbsolutePathName(Pathes(0))
End Function


 
'***********************************************************************
'* Function: CheckSettingFunctionExists
'***********************************************************************
Sub  CheckSettingFunctionExists( FunctionName )
	If not IsDefined( FunctionName ) Then
		Raise  500, "<ERROR msg=""vbslib の setting フォルダーにある .vbs ファイルに"+_
			"関数が定義されていません。"" function="""+ FunctionName +"""/>"
	End If
End Sub


 
'***********************************************************************
'* Function: include
'***********************************************************************
Sub  include( ByVal path )
	Dim f, en,ed, current

	If g_is_debug or g_debug_vbs_inc or not IsEmpty( g_is_compile_debug ) Then _
		echo_v ">include  """ + path + """"

	path = g_sh.ExpandEnvironmentStrings( path )

	If InStr( path, "*" ) > 0    Then  include_objs  path, Empty, Empty : Exit Sub
	If g_fs.FolderExists( path ) Then  include_objs  path, Empty, Empty : Exit Sub

	current = g_sh.CurrentDirectory
	g_SrcPath = g_fs.GetAbsolutePathName( path )
	If path <> g_fs.GetFileName( path )  or  path = "" Then
		If not g_fs.FileExists( path ) Then _
			Err.Raise 2,, "<ERROR msg=""include に指定したファイルが見つかりません"" path=""" + path + """ current=""" + g_sh.CurrentDirectory +"""/>"
		g_sh.CurrentDirectory = g_fs.GetParentFolderName( g_fs.GetAbsolutePathName( path ) )
	End If

	If StrComp( g_Vers( "DuplicateErrorFilePath" ), g_SrcPath, 1 ) = 0  Then _
		DebugDuplicateError1  g_SrcPath

	On Error Resume Next
		Set f = g_fs.OpenTextFile( g_fs.GetFileName( path ),,,-2 )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 Then  Err.Raise en,,ed + " in include( " + path + " )"
	If not g_is_debug  and  not f.AtEndOfStream Then
		On Error Resume Next


			ExecuteGlobal  f.ReadAll()


			g_sh.CurrentDirectory = current
		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If en <> 0 Then
			CompileDebug_guide  g_SrcPath
			Err.Raise en,,ed
		End If
	Else


		If not  f.AtEndOfStream Then
			Dim  t : t = "'// g_SrcPath=""" + g_SrcPath +""""+vbCRLF+ f.ReadAll() : f.Close
			ExecuteGlobal t  '// ここでエラーになったら、g_SrcPath の値のファイルで構文エラーが発生しています。
		End If


		g_sh.CurrentDirectory = current
	End If


	If en <> 0 Then
		If en = &h411 or en = &h3f7 or en = &h400 Then
			CompileDebug_guide  g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) )
			Err.Raise en
		Else
			Err.Raise en, "Error in including " + _
				g_fs.GetAbsolutePathName( g_vbslib_ver_folder + g_IncludePathes(g_i) )
		End If
	End If


	If not IsEmpty( g_is_compile_debug ) Then  CompileDebug_addScript  path, False

	g_SrcPath = Empty
End Sub


 
'***********************************************************************
'* Function: Watch
'***********************************************************************
Sub  MARK( Label, out_Count )
	g_Vers( Label ) = g_Vers( Label ) + 1
	Wscript.StdOut.WriteLine  "<MARK label="""& Label &""" count="""& g_Vers( Label ) &"""/>"
	out_Count = g_Vers( Label )
End Sub

Function  WD( Expression )
	WD = "WD2  """+ Expression + """, "+ Expression +" :"
End Function

Function  WS( Expression )
	WS = "WS2  """+ Expression + """, "+ Expression +" :"
End Function

Function  WX( Expression )
	WX = "WX2  """+ Expression + """, "+ Expression +" :"
End Function

Sub  WD2( Label, Value )
	Wscript.StdOut.WriteLine  "<WATCH label="""& Label &""" value="""& Value &"""/>"
End Sub

Sub  WS2( Label, Value )
	Wscript.StdOut.WriteLine  "<WATCH label="""& Label &""" value="""& Value &"""/>"
End Sub

Sub  WX2( Label, Value )
	Wscript.StdOut.WriteLine  "<WATCH label="""& Label &""" value=""0x"& Hex( Value ) &"""/>"
End Sub


 
'***********************************************************************
'* Function: CompileDebug_addScript
'***********************************************************************
Sub  CompileDebug_addScript( Path, bLast )
	Dim  r, w, line, syms, sym, i_dim, i_dim_over, dims, b_in_sub
	Const  ForAppending = 8

	Set w = g_fs.OpenTextFile( g_is_compile_debug, ForAppending, True, -2 )
	w.WriteLine  "'=============================================================================="
	w.WriteLine  "'// "+ Path +" "
	w.WriteLine  "'=============================================================================="
	g_compile_debug_line = w.Line

	Set r = g_fs.OpenTextFile( Path,,,-2 )
	Do Until r.AtEndOfStream
		line = r.ReadLine()

		If InStr( line, "Option Explicit" ) > 0 Then  line = ""

		i_dim = InStr( line, "Dim " )
		If i_dim > 0  and  not b_in_sub Then
			i_dim_over = InStr( i_dim, line, ":" )
			If i_dim_over > 0 Then  dims = Mid( line, i_dim + 4, i_dim_over - i_dim - 5 )   Else  dims = Mid( line, i_dim + 4 )
			syms = Split( dims, "," )

			dims = ""
			For Each sym  In syms
				sym = Trim( sym )
				If not g_compile_debug_dic.Exists( sym ) Then
					If not bLast Then  g_compile_debug_dic.Item( sym ) = True
					dims = dims + sym + ", "
				End If
			Next
			If dims = "" Then
				If i_dim_over > 0 Then  line = Left( line, i_dim - 1 ) + Mid( line, i_dim_over + 1 ) _
				Else  line = Left( line, i_dim - 1 )
				If Trim( line ) = "" Then  line = ""
			Else
				dims = Left( dims, Len( dims ) - 2 )
				If i_dim_over > 0 Then  line = Left( line, i_dim - 1 ) +"Dim "+ dims +" :"+ Mid( line, i_dim_over + 1 ) _
				Else  line = Left( line, i_dim - 1 ) +"Dim "+ dims
			End If
		End If

		If InStr( LCase( line ), "sub "    ) > 0  Then  b_in_sub = True
		If InStr( LCase( line ), "end sub" ) > 0  Then  b_in_sub = False
		If InStr( LCase( line ), "function "    ) > 0  Then  b_in_sub = True
		If InStr( LCase( line ), "end function" ) > 0  Then  b_in_sub = False

		w.WriteLine  line
	Loop
End Sub


 
'***********************************************************************
'* Function: CompileDebug_guide
'***********************************************************************
Sub  CompileDebug_guide( Path )
	Dim  msg, i_line, i_column, i_comma, i_kakko

	If IsEmpty( g_is_compile_debug ) Then
		WScript.Echo  "下記のファイルを include したときにエラーが発生しました。"+ vbCRLF +_
			""""+ Path +""""+ vbCRLF +_
			"構文エラーではないときは、g_debug を設定している場所のすぐ下に、次のように記述すると、"+_
			"エラーが発生した場所が分かります。"+vbCRLF+_
			" g_is_compile_debug = 1"+vbCRLF
		Exit Sub
	End If

	CompileDebug_addScript  Path, True

	Dim  cmd : cmd = "cmd /C ( cscript //nologo """+ g_is_compile_debug +""" 2>&1 ) > """+ g_is_compile_debug+"_"""
	g_sh.Run  cmd, 7, True

	msg = g_fs.OpenTextFile( g_is_compile_debug+"_",,,-2 ).ReadLine()
	g_fs.DeleteFile  g_is_compile_debug+"_"
	g_fs.DeleteFile  g_is_compile_debug

	msg = Mid( msg, Len( g_is_compile_debug ) )
	i_comma = InStr( msg, "," )
	i_kakko = InStr( msg, ")" )
	i_line = CInt( Mid( msg, 3, i_comma - 3 ) ) - g_compile_debug_line + 1
	i_column = CInt( Mid( msg, i_comma+1, i_kakko - i_comma - 1 ) )
	msg = Mid( msg, i_kakko + 2 )

	WScript.Echo  Path &"("& i_line &", "& i_column &") "& msg
	WScript.Echo  ""
	If IsDefined( "Setting_getEditorCmdLine" )  and  i_line >= 1 Then _
		g_sh.Run  Setting_getEditorCmdLine( Path &"("& i_line &")" )
End Sub


 
'***********************************************************************
'* Function: DebugDuplicateError1
'***********************************************************************
Sub  DebugDuplicateError1( SrcPath )
	Dim file : Set file = g_fs.OpenTextFile( SrcPath,,,-2 )
	Dim class_names, line, pos,  class_name

	class_names = ""
	Do Until file.AtEndOfStream
		line = Trim( Replace( file.ReadLine(), vbTab, " " ) )
		If Left( line, 6 ) = "Class " Then
			pos = InStr( line, ":" )
			If pos > 0 Then  line = Left( line, pos - 1 )
			line = Replace( Mid( line, 6 ), " ", "" )
			class_names = class_names + line + vbLF
		End If
	Loop

	For Each class_name  In Split( class_names, vbLF )
		If class_name = "" Then  Exit For
		echo_v  "Checking Class "+ class_name
		ExecuteGlobal  "Class "+ class_name +" : End Class"
	Next

	If IsEmpty( g_Vers( "DuplicateError1st" ) ) Then
		echo_v  "DebugDuplicateError では問題が見つかりませんでした。"+_
			"ただし、この後、"+ SrcPath +" を include している可能性があります。"
		Stop
		g_Vers( "DuplicateError1st" ) = True
	Else
		Err.Raise  1,, "DebugDuplicateError では問題が見つかりませんでした。"
	End If
End Sub


 
'***********************************************************************
'* Function: DebugDuplicateError2
'***********************************************************************
Sub  DebugDuplicateError2( ClassName )
	Dim en,ed
	Const E_ClassNotDefined = 506

	On Error Resume Next
		ExecuteGlobal  "Dim g_Object : Set g_Object = new "+ ClassName
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	IF en <> E_ClassNotDefined Then  Err.Raise  1
End Sub


 
