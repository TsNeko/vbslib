Dim  g_SrcPath
Dim  g_PC_setting_default_Path
     g_PC_setting_default_Path = g_SrcPath


 
'*************************************************************************
'  <<< [g_Vers("TextFileExtension")] >>> 
'*************************************************************************
Set g_Vers("TextFileExtension") = Dic_addFromArray( Empty, Array( _
	"txt", _
	"c", "h", "cpp", "hpp", "asm", "s", "vbs", "js", "py", "rb", _
	"ini", "log", _
	"html", "htm", "xml", "svg" ), True )


 
'*************************************************************************
'  <<< [Setting_getEditorCmdLine] >>> 
'*************************************************************************
Function  Setting_getEditorCmdLine( i )
	Dim  ret, exe, paths, prog_fo

	If VarType( i ) = vbString Then
		ret = GetEditorCmdLine( i )  '// i is PathAndName
	Else
		prog_fo = g_sh.ExpandEnvironmentStrings( "%ProgramFiles%" )

		'// set a.exe path at first element, if you test a.exe
		paths = Array( _
			prog_fo +"\search_open\search_open.exe", _
			prog_fo +"\sakura\sakura.exe", _
			"R:\home\mem_cache\prog\sakura\sakura_R\sakura.exe", _
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
		prog_fo +"\TortoiseSVN\bin\TortoiseMerge.exe", _
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
'  <<< [Setting_getFolderDiffCmdLine] >>> 
'*************************************************************************
Function  Setting_getFolderDiffCmdLine( ByVal i )
	prog_fo = g_sh.ExpandEnvironmentStrings( "%ProgramFiles%" )

	If i >= 30  and  i <= 37 Then
		bit_flags = i Mod 10
		i = Fix( i / 10 )
	End If


	paths = Array( _
		prog_fo +"\MasterManager\master2\master2.exe", _
		g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\MasterManager\master2\master2.exe" ), _
		prog_fo +"\DF\DF.exe" )

	exe = GetExistPathInSetting( paths, "Setting_getFolderDiffCmdLine" )
	Select Case g_fs.GetFileName( exe )
	 Case "master2.exe"
		If not IsEmpty( bit_flags ) Then
			option_string = " -e="+ CStr( bit_flags )
		Else
			option_string = ""
		End If

		If i = 0 Then  ret = exe
		If i = 2 Then  ret = """"+ exe +""" -2 ""%1"" ""%2"""
		If i = 3 Then  ret = """"+ exe +""" -3 ""%1"" ""%2"" ""%3"""+ option_string
	 Case Else
		If i = 0 Then  ret = exe
		If i = 2 Then  ret = """"+ exe +""" ""%1"" ""%2"""
		If i = 3 Then  ret = """"+ exe +""" ""%1"" ""%2"" ""%3"""
	End Select

	Setting_getFolderDiffCmdLine = ret
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
'  <<< [Setting_getDiffPath] >>> 
'*************************************************************************
Function  Setting_getDiffPath()
	Setting_getDiffPath = GetExistPathInSetting( Array( _
		g_vbslib_folder +"GPL\GnuWin\bin\diff.exe" ), _
		"Setting_getDiffPath" )
End Function


 
'*************************************************************************
'  <<< [Setting_getDiff3Path] >>> 
'*************************************************************************
Function  Setting_getDiff3Path()
	Setting_getDiff3Path = GetExistPathInSetting( Array( _
		g_vbslib_folder +"GPL\GnuWin\bin\diff3.exe" ), _
		"Setting_getDiff3Path" )
End Function


 
'*************************************************************************
'  <<< [Setting_getPatchPath] >>> 
'*************************************************************************
Function  Setting_getPatchPath()
	Setting_getPatchPath = GetExistPathInSetting( Array( _
		g_vbslib_folder +"GPL\GnuWin\bin\p_atch.exe" ), _
		"Setting_getPatchPath" )
End Function


 
'*************************************************************************
'  <<< [Setting_getPerlPath] >>> 
'*************************************************************************
Function  Setting_getPerlPath()
	Setting_getPerlPath = GetExistPathInSetting( Array( _
		g_vbslib_folder +"perl\bin\perl.exe", _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\perl-strawberry-perl\perl\bin\perl.exe" ), _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles(x86)%\perl-strawberry-perl\perl\bin\perl.exe" ), _
		"C:\Strawberry\perl\bin\perl.exe" ), _
		"Setting_getPerlPath" )
End Function


 
'*************************************************************************
'  <<< [Setting_getNaturalDocsPerlPath] >>> 
'*************************************************************************
Function  Setting_getNaturalDocsPerlPath()
	Setting_getNaturalDocsPerlPath = GetExistPathInSetting( Array( _
		g_vbslib_folder +"GPL\NaturalDocs\NaturalDocs", _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\NaturalDocs\NaturalDocs" ), _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles(x86)%\NaturalDocs\NaturalDocs" ) ), _
		"Setting_getNaturalDocsPerlPath" )
End Function


 
'*************************************************************************
'  <<< [g_Vers("NaturalDocsExtension")] >>> 
'*************************************************************************
Set g_Vers("NaturalDocsExtension") = Dic_addFromArray( Empty, Array( _
	"h", "c", "hpp", "cpp", "java", "php", "py", "vb", "vbs", _
	"pas", "ada", "js", "rb", "tcl", _
	"sfl", "cfm", "asr", "cfc", "ddd", "did", "ufl", _
	"asm", "s", "f", "F90", "F95", "for", "r", _
	"txt" ), True )


 
'*************************************************************************
'  <<< [Setting_getDoxygenPath] >>> 
'*************************************************************************
Function  Setting_getDoxygenPath()
	Setting_getDoxygenPath = GetExistPathInSetting( Array( _
		g_vbslib_folder +"GPL\Doxygen\bin\doxygen.exe", _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\doxygen\bin\doxygen.exe" ), _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles(x86)%\doxygen\bin\doxygen.exe" ) ), _
		"Setting_getDoxygenPath" )
End Function


 
'*************************************************************************
'  <<< [g_Vers("doxygenExtension")] >>> 
'*************************************************************************
Set g_Vers("doxygenExtension") = Dic_addFromArray( Empty, Array( _
	"h", "c", "hpp", "cpp", "java", "php", "py", _
	"f", "F90", "F95", "for", "d" ), True )


 
'*************************************************************************
'  <<< [Setting_get7zExePath] >>> 
'*************************************************************************
Function  Setting_get7zExePath()
	Setting_get7zExePath = GetExistPathInSetting( Array( _
		g_vbslib_folder +"GPL\7-Zip\7z.exe", _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\7-Zip\7z.exe" ), _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles(x86)%\7-Zip\7z.exe" ) ), _
		"Setting_get7zExePath" )
End Function


 
'*************************************************************************
'  <<< [Setting_getSnapNotePath] >>> 
'*************************************************************************
Function  Setting_getSnapNotePath()
	Setting_getSnapNotePath = GetExistPathInSetting( Array( _
		g_vbslib_folder +"Proprietary\SnapNote\Snap Note.exe", _
		g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\SnapNote\SnapNote\Snap Note.exe" ), _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\Snap Note\Snap Note.exe" ) ), _
		"Setting_getSnapNotePath" )
End Function


 
