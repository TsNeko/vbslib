Option Explicit 

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
	echo_v  "TestDefault> Setting_getEditorCmdLine( "+ CStr( i ) +" )"
	Setting_getEditorCmdLine = """"+ g_vbslib_ver_folder +"ArgsLog.exe""  editor  ""%1#%2"" -Y=%L"
End Function


 
'*************************************************************************
'  <<< [Setting_getDiffCmdLine] >>> 
'*************************************************************************
Function  Setting_getDiffCmdLine( i )
	echo_v  "TestDefault> Setting_getDiffCmdLine( "+ CStr( i ) +" )"
	Setting_getDiffCmdLine = """"+ g_vbslib_ver_folder +"ArgsLog.exe""  diff  ""%1""  ""%2""  ""%3"" -Y=%L"
End Function


 
'*************************************************************************
'  <<< [Setting_getFolderDiffCmdLine] >>> 
'*************************************************************************
Function  Setting_getFolderDiffCmdLine( ByVal i )
	echo_v  "TestDefault> Setting_getFolderDiffCmdLine( "+ CStr( i ) +" )"
	Setting_getFolderDiffCmdLine = """"+ g_vbslib_ver_folder +"ArgsLog.exe""  diff_fo  ""%1""  ""%2""  ""%3"""
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
	echo_v  "TestDefault> Open folder """ + Path + """"
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
		g_vbslib_folder +"GPL\GnuWin\bin\patch.exe" ), _
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
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\7-Zip\7z.exe" ), _
		g_sh.ExpandEnvironmentStrings( "C:\Program Files (x86)\7-Zip\7z.exe" ) ), _
		"Setting_get7zExePath" )
End Function


 
'*************************************************************************
'  <<< [Setting_getSnapNotePath] >>> 
'*************************************************************************
Function  Setting_getSnapNotePath()
	Setting_getSnapNotePath = GetExistPathInSetting( Array( _
		g_sh.ExpandEnvironmentStrings( "%myhome_mem%\prog\SnapNote\SnapNote\Snap Note.exe" ), _
		g_sh.ExpandEnvironmentStrings( "%ProgramFiles%\Snap Note\Snap Note.exe" ) ), _
		"Setting_getSnapNotePath" )
End Function


 
