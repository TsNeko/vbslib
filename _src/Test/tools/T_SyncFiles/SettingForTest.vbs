Option Explicit 

Dim  g_SrcPath
Dim  g_SettingForTest_Path
		 g_SettingForTest_Path = g_SrcPath


 
'*************************************************************************
'  <<< [Setting_getEditorCmdLine] redirect for test >>> 
'*************************************************************************
Function  Setting_getEditorCmdLine( i )
	Dim  ret

	If GetVar( "Setting_getEditorCmdLine" ) = "EchoOpenEditorLog" Then
		If VarType( i ) = vbString Then
			ret = GetEditorCmdLine( i )  '// i is PathAndName
		Else
			ret = GetEditorCmdLine_DefaultParams( i, "\?InCurrentProcessFunc\EchoOpenEditorLog", "-Y=%L ""%1""" )
		End If
	ElseIf GetVar( "Setting_getEditorCmdLine" ) = "ArgsLog" Then
		If VarType( i ) = vbString Then
			ret = GetEditorCmdLine( i )  '// i is PathAndName
		Else
			ret = GetEditorCmdLine_DefaultParams( i, """"+ g_vbslib_ver_folder +"ArgsLog.exe""  EditorForTest.exe", "-Y=%L ""%1""" )
		End If
	Else
		Setting_getEditorCmdLine = g_Setting_getEditorCmdLine.CallFunction1( i )
	End If
	Setting_getEditorCmdLine = ret
End Function


 
'*************************************************************************
'  <<< [Setting_getDiffCmdLine] redirect for test >>> 
'*************************************************************************
Function  Setting_getDiffCmdLine( i )
	If GetVar( "Setting_getDiffCmdLine" ) = "ArgsLog" Then
		Setting_getDiffCmdLine = GetDiffCmdLine_DefaultParams( i, """"+ g_vbslib_ver_folder +"ArgsLog.exe""  DiffForTest.exe" )
	ElseIf GetVar( "Setting_getDiffCmdLine" ) = "DiffCUI" Then
		Setting_getDiffCmdLine = GetDiffCmdLine_DefaultParams( i, "\?InCurrentProcessFunc\DiffCUI_InCurrentProcess" )
	Else
		Setting_getDiffCmdLine = g_Setting_getDiffCmdLine.CallFunction1( i )
	End If
End Function


 
'*************************************************************************
'  <<< [Setting_getFolderDiffCmdLine] redirect for test >>> 
'*************************************************************************
Function  Setting_getFolderDiffCmdLine( i )
	If GetVar( "Setting_getFolderDiffCmdLine" ) = "ArgsLog" Then
		Setting_getFolderDiffCmdLine = GetDiffCmdLine_DefaultParams( i, """"+ g_vbslib_ver_folder +"ArgsLog.exe""  FolderDiffDummy.exe" )
	ElseIf GetVar( "Setting_getFolderDiffCmdLine" ) = "DiffCUI" Then
		Setting_getFolderDiffCmdLine = GetDiffCmdLine_DefaultParams( i, "\?InCurrentProcessFunc\DiffCUI_InCurrentProcess" )
	Else
		Setting_getFolderDiffCmdLine = g_Setting_getFolderDiffCmdLine.CallFunction1( i )
	End If
End Function


 
'*************************************************************************
'  <<< [Setting_openFolder] redirect for test >>> 
'*************************************************************************
Sub  Setting_openFolder( in_Path )
	If GetVar( "Setting_openFolder" ) = "echo" Then
		echo  "Setting_openFolder """+ in_Path +""""
	ElseIf GetVar( "Setting_openFolder" ) = "echo_v" Then
		echo_v  "Setting_openFolder """+ in_Path +""""
	Else
		g_Setting_openFolder.CallSub1  in_Path
	End If
End Sub


 
'*************************************************************************
'  <<< [start] redirect for test >>> 
'*************************************************************************
Sub  start( cmdline )  '// This is for order of multi ArgsLog.exe output
	Dim  i, s : i = 1
	Dim  exe_path : exe_path = MeltCmdLine( cmdline, i )

	If g_fs.GetFileName( exe_path ) = "ArgsLog.exe" Then
		echo  ">start  "+ cmdline
		Dim ec : Set ec = new EchoOff
		RunProg  cmdline, ""  '// because start function can not wait to finish ArgsLog.exe
	Else
		g_start.CallSub1  cmdline
	End If
End Sub


 
