'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************

Dim  g_SrcPath
Dim  g_vbslib_sudo_Path
     g_vbslib_sudo_Path = g_SrcPath


'********************************************************************************
'  <<< [sudo] >>>
'********************************************************************************
Function  sudo( cmdlines, OperationName, stdout_stderr_redirect )
	Dim  s, s2, s3, option_, b, b_cscript, b_debug, b_uac, b_admin, admin_name

	b_uac = ( GetOsVersion() >= 6.0 )
	b_admin = CurrentUserIsAdminGroup()


	b_cscript = ( InStr( cmdlines, "cscript" ) > 0 )

	If b_cscript  or  InStr( cmdlines, "wscript" ) > 0 Then
		option_ = " /admin:1"
	Else
		option_ = ""
	End If

	If b_uac  or  not b_admin Then

		echo_flush

		If b_uac Then
			s = """管理者権限ランチャー (sudo.exe)"""
		Else
			Raise  1, "<ERROR msg=""管理者権限が必要な処理があります。管理者に実行を依頼してください。""/>"

			s = "管理者"
		End If

		s2 = "詳細情報１："+vbCRLF+ GetCmdLine() +vbCRLF+vbCRLF+_
		     "詳細情報２："+vbCRLF+ g_sh.CurrentDirectory +">"+vbCRLF+ cmdlines
		If not b_uac Then
			admin_name = GetAdminName()
			s2 = s2 +vbCRLF+vbCRLF+ "管理者アカウント名： "+ admin_name
		End If

		If g_CommandPrompt = 0 Then  s3 = "下"  Else  s3 = "上"


		If 0 Then
			If g_CommandPrompt <> 0 Then  echo_line : echo s2

			echo_line
			echo  vbCRLF+"[ UAC（ユーザーアカウント制御）予告 ]" +vbCRLF+vbCRLF+_
				"プログラム名１： "+ WScript.ScriptName +" （詳細は"+ s3 +"記）"+vbCRLF+vbCRLF+_
				"プログラム名２： "+ s +vbCRLF+vbCRLF+_
				"現在実行中の上記 "+ WScript.ScriptName +" は、このコンピューターに変更を加えるため、"+_
				" "+ s3 +"記、詳細情報２ と "+ s +" を使って管理者権限を要求します。 この要求により、UAC（ユーザーアカウント制御）の"+_
				"ウィンドウが表示されます。 現在実行中の "+ WScript.ScriptName +" に心当たりがなかったり"+_
				"怪しいサイトから入手したときは、"+_
				"拒否してください。（ウィンドウを閉じてください） また、次回、この予告メッセージが"+_
				"なく、いきなり "+ s +" から管理者権限を要求されたときも拒否してください。"

			If g_CommandPrompt = 0 Then  echo_line : echo s2
		Else
			echo_line
			If b_uac Then
				echo  "[ UAC（ユーザーアカウント制御）予告（詳細） ]" +vbCRLF
			Else
				echo  "[ 管理者アカウント切り替え予告（詳細） ]" +vbCRLF
			End If
			echo s2
		End If

		echo ""
		echo_line
		If b_uac Then
			echo  "[ UAC（ユーザーアカウント制御）予告 ]"
		Else
			echo  "[ 管理者アカウント切り替え予告 ]"
		End If
		echo  vbCRLF+ "『"+ Trim( Replace( OperationName, vbCRLF, "" ) ) +"』という処理の続きを "+s+" から実行します。"+vbCRLF+_
			"これが、あなたがしようとしている処理と異なるときや、あいまいな処理名のときは、終了してください。"+vbCRLF
		pause
		echo_line
	End If


	If b_cscript Then
		echo  ">sudo  "+ cmdlines
		Dim  ec : Set ec = new EchoOff

		b_debug = InStr( cmdlines, "//x " )

		If b_debug Then

			If b_uac Then
				g_sh.Run  """"+ g_vbslib_ver_folder +"sudo\sudo.exe"" cmd /C "+ cmdlines + option_ +" /debug:1",, True
			ElseIf not g_is_admin Then
				g_sh.Run  "runas /user:" + admin_name + " """ + Replace( cmdlines, """", "\""" ) + option_ +" /debug:1""",, True
			Else
				g_sh.Run  "cmd /C "+ cmdlines + option_ +" /debug:1",, True
			End If
			sudo = 1

		Else

			Dim  bat_path : bat_path = GetTempPath( "sudo_RunBat_*.bat" )  '// &if とすると、errorlevel が設定されないため
			Dim  ret_path : ret_path = GetTempPath( "sudo_RunBatRet_*.txt" )  '// errorlevel は cmd /C の返り値にならないため

			Dim  f : Set f = OpenForWrite( bat_path, Empty )
			f.WriteLine  cmdlines + option_
			f.WriteLine  "@if not ""%errorlevel%""==""21"" pause"
			f.WriteLine  "@echo %errorlevel% > """+ ret_path +""""
			f = Empty

			CreateFile  ret_path, "1"  '// default value

			If b_uac Then
				g_sh.Run  """"+ g_vbslib_ver_folder +"sudo\sudo.exe"" cmd /C """+ bat_path +"""",, True
			ElseIf not b_admin Then

				Error

''        g_sh.Run  "runas /user:" + admin_name + " ""cmd /K (pause&cd \"""+_
''          Replace( g_sh.CurrentDirectory, "\", "\\" ) +"\""&\""" +_
''          Replace( bat_path, "\", "\\" ) + "\""&pause)""",, True
			Else
				g_sh.Run  "cmd /C """+ bat_path +"""",, True
			End If

			sudo = CInt( ReadFile( ret_path ) )

			del  ret_path
			del  bat_path

		End If
		ec = Empty
	Else
		sudo = g_sh.Run( """"+ g_vbslib_ver_folder +"sudo\sudo.exe"" "+ cmdlines + option_,, True )
	End If

	If b_uac Then
		echo_line
		echo  vbCRLF+"管理者権限で行う処理が完了しました。"+vbCRLF
		Sleep  2000
		echo_line
	End If

	If b_cscript Then
		If sudo <> 21 Then
			s = "<ERROR exit_code="""& sudo &""" command="""& XmlAttr( cmdlines ) &"""/>"
			If sudo = 0 Then  sudo = 1
			Raise  sudo, s
		End IF
	End If
End Function


 
'********************************************************************************
'  <<< [sudo_del_copy] >>>
'********************************************************************************
Sub  sudo_del_copy( in_SudoScriptPath, in_OperationName, in_SourceFullPath, in_DestinationFullPath, in_out_Options )
	Set c = get_SudoConsts()

	ParseOptionArguments  in_out_Options

	is_elevate = Empty
	If in_out_Options("integer") = c.AlreadySuperUser Then
		is_elevate = False
	ElseIf StrCompHeadOf( in_DestinationFullPath, env("%ProgramFiles%"), Empty ) = 0  or _
			StrCompHeadOf( in_DestinationFullPath, env("%ProgramW6432%"), Empty ) = 0 Then
		is_elevate = True
	Else
		is_elevate = False
	End If

	If is_elevate Then
		script_path = in_SudoScriptPath
		Set file = OpenForWrite( script_path, Empty )
		file.WriteLine  "Sub  Main( Opt, AppKey )"
		file.WriteLine  "	Set c = get_SudoConsts()"
		file.WriteLine  ""
		file.WriteLine  "	source = """+ in_SourceFullPath +""""
		file.WriteLine  "	target = """+ in_DestinationFullPath +""""
		file.WriteLine  ""
		file.WriteLine  "	AppKey.SetWritableMode  F_IgnoreIfWarn"
		file.WriteLine  "	Set w_=AppKey.NewWritable( Array( "+ new_ArrayClass( _
			g_CurrentWritables.CurrentPathes ).Code + _
			" ) ).Enable()"
		file.WriteLine  "	AppKey.SetWritableMode  F_AskIfWarn"
		If IsEmpty( in_out_Options("ArrayClass") ) Then
			file.WriteLine  "	sudo_del_copy  """", """", source, target, c.AlreadySuperUser"
		Else
			file.WriteLine  "	sudo_del_copy  """", """", source, target, Array( c.AlreadySuperUser, _"
			file.WriteLine  "		new_ArrayClass( Array( "+ in_out_Options("ArrayClass").Code +" ) ) )"
		End If
		file.WriteLine  "End Sub"
		file.WriteLine  ""
		WriteVBSLibFooter  file, Empty
		file = Empty
		sudo  "cscript //nologo """+ script_path +"""", in_OperationName, ""
		Set ec = new EchoOff
		del  script_path
	Else
		Set ec = new EchoOff

		If IsEmpty( in_out_Options("ArrayClass") ) Then
			del   in_DestinationFullPath
		Else
			del   new_PathDictionaryClass_withRemove( in_DestinationFullPath, _
				in_out_Options("ArrayClass").Items, Nothing )
		End If

		copy  in_SourceFullPath +"\*", in_DestinationFullPath
	End If
End Sub


 
'*************************************************************************
'  <<< [get_SudoConsts] >>>
'*************************************************************************
Dim  g_SudoConsts

Function  get_SudoConsts()
	If IsEmpty( g_SudoConsts ) Then _
		Set g_SudoConsts = new SudoConsts
	Set get_SudoConsts = g_SudoConsts
End Function


Class  SudoConsts
	Public  AlreadySuperUser

	Private Sub  Class_Initialize()
		AlreadySuperUser = 1
	End Sub
End Class


 
