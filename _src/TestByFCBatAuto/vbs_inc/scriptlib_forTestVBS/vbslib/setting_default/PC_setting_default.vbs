Option Explicit 

Dim  g_SrcPath
Dim  g_PC_setting_default_Path
     g_PC_setting_default_Path = g_SrcPath


 
'*************************************************************************
'  <<< [g_Vers("TextFileExtension")] >>> 
'*************************************************************************
Set g_Vers("TextFileExtension") = Dic_addFromArray( Empty, Array( _
	"txt", _
	"c", "h", "cpp", "hpp", "vbs", "js", "py", "rb", _
	"ini", "log", _
	"html", "htm", "xml", "svg" ), True )


 
'*************************************************************************
'  <<< [Setting_getEditorCmdLine] >>> 
'*************************************************************************
Function  Setting_getEditorCmdLine( i )
	Dim  ret, exe, paths, prog_fo

	If VarType( i ) = vbString Then
		ret = GetSearchOpenCmdLine( i )  '// i is PathAndName
	Else
		prog_fo = g_sh.ExpandEnvironmentStrings( "%ProgramFiles%" )

		'// set a.exe path at first element, if you test a.exe
		paths = Array( _
			prog_fo +"\search_open\search_open.exe", _
			prog_fo +"\sakura\sakura.exe", _
			g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\sakura\sakura\sakura.exe" ), _
			prog_fo+"\xyzzy\xyzzy.exe", _
			prog_fo+"\Apsaly\Apsaly.exe", _
			prog_fo+"\TeraPad\TeraPad.exe", _
			prog_fo+"\Notepad++\notepad++.exe", _
			prog_fo +"\EmEditor\EmEditor.exe", _
			prog_fo +"\WZ EDITOR 6\wzeditor.exe", _
			prog_fo +"\Hidemaru\Hidemaru.exe", _
			prog_fo +"\K2Editor\K2Editor.exe", _
			g_sh.ExpandEnvironmentStrings( "%WinDir%\notepad.exe" ) )
		exe = GetExistPathInSetting( paths, "Setting_getEditorCmdLine" )

		If i = 0 Then
			ret = exe
		ElseIf i = 1 Then
			ret = """"+ exe +""" ""%1"""
		ElseIf i = 2 Then
			Select Case  g_fs.GetFileName( exe )
				Case "sakura.exe"    : ret = """"+ exe +""" -Y=%L ""%1"""
				Case "xyzzy.exe"     : ret = """"+ exe +""" ""%1"" -g %L"
				Case "TeraPad.exe"   : ret = """"+ exe +""" /jl=%L ""%1"""
				Case "notepad++.exe" : ret = """"+ exe +""" -n%L ""%1"""
				Case "EmEditor.exe"  : ret = """"+ exe +""" ""%1"" /l %L"
				Case "Apsaly.exe", "wzeditor.exe", "Hidemaru.exe", "K2Editor.exe"
				                       ret = """"+ exe +""" /j%L ""%1"""
				Case Else            : ret = """"+ exe +""" ""%1"""
			End Select
		ElseIf i = 3 Then
			Select Case  g_fs.GetFileName( exe )
				Case "search_open.exe" : ret = """"+ exe +""" ""%1#%2"""
				Case "wzeditor.exe"    : ret = """"+ exe +""" ""%1"" -top -search(""%2"")"
				Case Else              : ret = """"+ exe +""" ""%1"""
			End Select
		End If
	End If
	Setting_getEditorCmdLine = ret
End Function


 
'*************************************************************************
'  <<< [Setting_getDiffCmdLine] >>> 
'*************************************************************************
Function  Setting_getDiffCmdLine( i )
	Dim  ret, exe, exe3, windiff_exe, paths, fo, subfo, prog_fo

	'//=== get path of windiff
	prog_fo = g_sh.ExpandEnvironmentStrings( "%ProgramFiles%" )
	fo = prog_fo +"\Microsoft SDKs\Windows"
	windiff_exe = Empty
	If g_fs.FolderExists( fo ) Then
		For Each subfo  In g_fs.GetFolder( fo ).SubFolders  '// subfo as Folder
			windiff_exe = fo +"\"+ subfo.Name + "\Bin\WinDiff.exe"
			If g_fs.FileExists( windiff_exe ) Then  Exit For
			windiff_exe = Empty
		Next
	End If


	'//=== search path of exe file
	'// set a.exe path at first element, if you test a.exe
	paths = Array( _
		prog_fo +"\Rekisa\Rekisa.exe", _
		g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\Rekisa\Rekisa\Rekisa.exe" ), _
		prog_fo +"\WinMerge\WinMergeU.exe", _
		prog_fo +"\DF\DF.exe", _
		prog_fo +"\EmEditor\EmEditor.exe", _
		windiff_exe, _
		g_sh.ExpandEnvironmentStrings( "%windir%\notepad.exe" ) )
	exe = GetExistPathInSetting( paths, "Setting_getDiffCmdLine" )


	'//=== make parameters
	Select Case g_fs.GetFileName( exe )
	 Case "Rekisa.exe"
		If i = 0 Then  ret = exe
		If i = 2 Then  ret = """"+ exe +""" ""%1"" ""%2"""
		If i = 3 Then  ret = """"+ exe +""" ""%1"" ""%2"" ""%3"""
		If i = 21 Then ret = """"+ exe +""" -Y+1=%L -ActiveFile=""%1"" ""%1"" ""%2"""
		If i = 22 Then ret = """"+ exe +""" -Y+1=%L -ActiveFile=""%2"" ""%1"" ""%2"""
		If i = 31 Then ret = """"+ exe +""" -Y+1=%L -ActiveFile=""%1"" ""%1"" ""%2"" ""%3"""
		If i = 32 Then ret = """"+ exe +""" -Y+1=%L -ActiveFile=""%2"" ""%1"" ""%2"" ""%3"""
		If i = 33 Then ret = """"+ exe +""" -Y+1=%L -ActiveFile=""%3"" ""%1"" ""%2"" ""%3"""
	 Case "WinMergeU.exe"
		If i = 0 Then  ret = exe
		If i = 2 or i = 21 or i = 22 Then  ret = """"+ exe +""" /u ""%1"" ""%2"""
		If i = 3 or i = 31 or i = 32 or i = 32 Then  ret = """"+ exe +""" /u ""%1"" ""%2"" ""%3"""
	 Case "EmEditor.exe"
		If i = 0 Then  ret = exe
		If i = 2 or i = 21 or i = 22 Then  ret = """"+ exe +""" ""%1"" ""%2"""
		If i = 3 or i = 31 or i = 32 or i = 32 Then  ret = """"+ exe +""" ""%1"" ""%2"" ""%3"""
	 Case "notepad.exe"  '// not found diff tool
		ret = GetDiffCmdLine_DefaultParams( i, "\?InCurrentProcessFunc\DiffCUI_InCurrentProcess" )
	 Case Else
		If i = 0 Then  ret = exe
		If i = 2 or i = 21 or i = 22 Then  ret = """"+ exe +""" ""%1"" ""%2"""
	End Select
	Setting_getDiffCmdLine = ret
End Function


 
'*************************************************************************
'  <<< [DiffCUI_InCurrentProcess] >>> 
'*************************************************************************
Function  DiffCUI_InCurrentProcess( CommandLine )
	Dim  i, s, args, labels

	i = 1
	s = MeltCmdLine( CommandLine, i )  '// exe name
	args = Mid( CommandLine, i )

	If StrCompHeadOf( args, "/Labels:", Empty ) = 0 Then
		s = MeltCmdLine( args, i )  '// s = labels option
		labels = ArrayFromCSV( Mid( s, InStr( s, ":" ) + 1 ) )
		args = Mid( args, i )
	End If

	DiffCUI  ArrayFromCmdLineWithoutOpt( args, Empty ), labels
	DiffCUI_InCurrentProcess = 0
End Function


 
'*************************************************************************
'  <<< [Setting_openFolder] >>> 
'*************************************************************************
Sub  Setting_openFolder( Path )
	echo  ">Open folder """ + Path + """"
	If GetOSVersion = 6.0 Then
		echo "Open folder need Sleep on Vista..."
		Sleep(500)
	End If

	If g_fs.FolderExists( Path ) Then
		g_sh.Run "explorer """ + Path + """"
	ElseIf g_fs.FileExists( Path ) Then
		g_sh.Run "explorer /SELECT, """ + Path + """"
	Else
		Err.Raise  1,, """" + Path + """ が見つかりません。"
	End If

End Sub


 
'*************************************************************************
'  <<< [Setting_getNaturalDocsPerlPath] >>> 
'*************************************************************************
Function  Setting_getNaturalDocsPerlPath()
	Setting_getNaturalDocsPerlPath = GetExistPathInSetting( Array( _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\NaturalDocs\NaturalDocs" ) ), _
		"Setting_getNaturalDocsPerlPath" )
End Function


 
