'// vbslib - VBScript ShortHand Library  ver4.90  Aug.17, 2014
'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_SrcPath
Dim  g_VisualStudio_Path
     g_VisualStudio_Path = g_SrcPath

Const  E_PathNotFound2 = &h80070002


 
'********************************************************************************
'  <<< [get_VisualStudioConsts] >>> 
'********************************************************************************
Dim  g_VisualStudioConsts

Function    get_VisualStudioConsts()
	If IsEmpty( g_VisualStudioConsts ) Then _
		Set g_VisualStudioConsts = new VisualStudioConsts : ErrCheck
	Set get_VisualStudioConsts = g_VisualStudioConsts
End Function


Class  VisualStudioConsts
	Public  MakeBackup
	Public  ProfessionalEdition, ExpressEdition

	Private Sub  Class_Initialize()
		MakeBackup = 1

		ProfessionalEdition = 2
		ExpressEdition = 1
	End Sub
End Class


 
'********************************************************************************
'  <<< [devenv_rebuild] Visual Studio command line build >>> 
'********************************************************************************
Sub  devenv_rebuild( sln_path, config )
	Set m = get_DevEnvObj()
	m.Rebuild  sln_path, config
End Sub

 
'********************************************************************************
'  <<< [devenv_build] Visual Studio command line build >>> 
'********************************************************************************
Sub  devenv_build( sln_path, config )
	Set m = get_DevEnvObj()
	m.Build  sln_path, config
End Sub

 
'********************************************************************************
'  <<< [devenv_clean] Visual Studio clean >>> 
'********************************************************************************
Sub  devenv_clean( sln )
	Set m = get_DevEnvObj()
	m.Clean  sln
End Sub

 
'********************************************************************************
'  <<< [devenv_upgrade] Upgrade Visual Studio solution files >>> 
'********************************************************************************
Sub  devenv_upgrade( SlnPath, Reserved )
	Set m = get_DevEnvObj()
	m.Upgrade  SlnPath, Reserved
End Sub

 
'********************************************************************************
'  <<< [get_DevEnvObj] >>> 
'********************************************************************************
Dim  g_DevEnvObj

Function    get_DevEnvObj()  '// has_interface_of ClassI
	If IsEmpty( g_DevEnvObj ) Then _
		Set g_DevEnvObj = new DevEnvObj : ErrCheck
	Set get_DevEnvObj =   g_DevEnvObj
End Function

 
'-------------------------------------------------------------------------
' ### <<<< [DevEnvObj] Class >>>> 
'-------------------------------------------------------------------------
Class  DevEnvObj

	Public  m_InstallDir2013  '// "C:\Program Files (x86)\Microsoft Visual Studio 12.0\"
	Public  m_InstallDir2012  '// "C:\Program Files (x86)\Microsoft Visual Studio 11.0\"
	Public  m_InstallDir2010
	Public  m_InstallDir2008
	Public  m_InstallDir2005
	'// vbslib var: devenv_ver_name

	Public  devenv_exe_2013
	Public  devenv_exe_2012
	Public  devenv_exe_2010
	Public  devenv_exe_2008
	Public  devenv_exe_2005

	Public  WDExpress_exe_2013
	Public  WDExpress_exe_2012
	Public  VCExpress_exe_2010
	Public  m_IsExpress2010


Private Sub  Class_Initialize()

	install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\12.0\"+_
		"InstallDir" )
	If IsEmpty( install_dir ) Then _
		install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\12.0\"+_
			"Setup\VS\ProductDir" )
	If not IsEmpty( install_dir ) Then
		Me.m_InstallDir2013 = install_dir

		If IsEmpty( GetVar( "devenv_ver_name" ) ) Then
			SetVar  "devenv_ver_name", "vs2013"
		End IF

		exe_path = install_dir + "devenv.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.devenv_exe_2013 = exe_path
		End If

		exe_path = install_dir + "Common7\IDE\WDExpress.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.WDExpress_exe_2013 = exe_path
		End If
	End If


	install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\11.0\"+_
		"InstallDir" )
	If IsEmpty( install_dir ) Then _
		install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\11.0\"+_
			"Setup\VS\ProductDir" )
	If not IsEmpty( install_dir ) Then
		Me.m_InstallDir2012 = install_dir

		If IsEmpty( GetVar( "devenv_ver_name" ) ) Then
			SetVar  "devenv_ver_name", "vs2012"
		End IF

		exe_path = install_dir + "devenv.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.devenv_exe_2012 = exe_path
		End If

		exe_path = install_dir + "Common7\IDE\WDExpress.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.WDExpress_exe_2012 = exe_path
		End If
	End If


	Me.m_IsExpress2010 = False
	install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\10.0\"+_
		 "InstallDir" )
	If IsEmpty( install_dir ) Then _
		install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\10.0\"+_
			 "Setup\Dbghelp_path" )  '// Common7\IDE\VCSExpress.exe
	If not IsEmpty( install_dir ) Then
		Me.m_InstallDir2010 = install_dir

		If IsEmpty( GetVar( "devenv_ver_name" ) ) Then
			SetVar  "devenv_ver_name", "vs2010"
		End IF

		exe_path = install_dir + "devenv.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.devenv_exe_2010 = exe_path
		End If

		exe_path = install_dir + "VCExpress.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.VCExpress_exe_2010 = exe_path
			Me.m_IsExpress2010 = True
		End If
	End If


	install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\9.0\"+_
		 "InstallDir" )
	If IsEmpty( install_dir ) Then _
		install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\9.0\"+_
			 "Setup\Dbghelp_path" )  '// Common7\IDE\VCSExpress.exe
	If not IsEmpty( install_dir ) Then
		Me.m_InstallDir2008 = install_dir

		If IsEmpty( GetVar( "devenv_ver_name" ) ) Then
			SetVar  "devenv_ver_name", "vs2008"
		End IF

		exe_path = install_dir + "devenv.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.devenv_exe_2008 = exe_path
		End If
	End If


	install_dir = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\8.0\"+_
		 "InstallDir" )
	If not IsEmpty( install_dir ) Then
		Me.m_InstallDir2005 = install_dir

		If IsEmpty( GetVar( "devenv_ver_name" ) ) Then
			SetVar  "devenv_ver_name", "vs2005"
		End IF

		exe_path = install_dir + "devenv.exe"
		If g_fs.FileExists( exe_path ) Then
			Me.devenv_exe_2005 = exe_path
		End If
	End If
End Sub


 
'********************************************************************************
'  <<< [DevEnvObj::Get_devenv_exe_Path] >>> 
'********************************************************************************
Public Sub  Get_devenv_exe_Path( SlnPath, out_ExePath, out_Edition, out_VSVerStr )
	Set c = g_VBS_Lib
	Set c_vs = get_VisualStudioConsts()
	Set devenv_obj = get_DevEnvObj


	'//=== Set "devenv_exe", "express_exe", "vs"
	GetSlnFileVersion  SlnPath, ver_num, is_express
	Select Case  ver_num
		Case  2013
			If IsEmpty( m_InstallDir2013 ) Then _
				Raise c.NotInstalled,"Visual Studio 2013 がインストールされていません"
			devenv_exe  = devenv_obj.devenv_exe_2013
			express_exe = devenv_obj.WDExpress_exe_2013
			vs = "vs2013"
		Case  2012
			If IsEmpty( m_InstallDir2012 ) Then _
				Raise c.NotInstalled,"Visual Studio 2012 がインストールされていません"
			devenv_exe  = devenv_obj.devenv_exe_2012
			express_exe = devenv_obj.WDExpress_exe_2012
			vs = "vs2012"
		Case  2010
			If IsEmpty( m_InstallDir2010 ) Then _
				Raise c.NotInstalled,"Visual Studio 2010 がインストールされていません"
			devenv_exe  = devenv_obj.devenv_exe_2010
			express_exe = devenv_obj.VCExpress_exe_2010
			vs = "vs2010"
		Case  2008
			If IsEmpty( m_InstallDir2008 ) Then
				If IsEmpty( m_InstallDir2010 ) Then
					Raise c.NotInstalled,"Visual Studio 2008 がインストールされていません"
				Else
					'//devenv_upgrade  SlnPath, Empty
					devenv_exe  = devenv_obj.devenv_exe_2010
					express_exe = devenv_obj.VCExpress_exe_2010
					vs = "vs2010"
				End If
			Else
				devenv_exe  = devenv_obj.devenv_exe_2008
				vs = "vs2008"
			End If
		Case  2005
			If IsEmpty( m_InstallDir2005 ) Then _
				Raise c.NotInstalled,"Visual Studio 2005 がインストールされていません"
			devenv_exe  = devenv_obj.devenv_exe_2005
			vs = "vs2005"
		Case Else
			Error
	End Select


	If not IsEmpty( devenv_exe ) Then
		out_ExePath = devenv_exe
		out_Edition = c_vs.ProfessionalEdition
	ElseIf not IsEmpty( express_exe ) Then
		out_ExePath = express_exe
		out_Edition = c_vs.ExpressEdition
	Else
		out_ExePath = Empty
		out_Edition = Empty
	End If


	out_VSVerStr = vs
End Sub


 
'********************************************************************************
'  <<< [DevEnvObj::devenv] >>> 
'********************************************************************************
Public Sub  devenv( SlnPath, param, config, EchoMessage )
	Me.Get_devenv_exe_Path  SlnPath, exe_path, Empty, vs
	Me.devenv_sub  exe_path, vs, param, config, EchoMessage
End Sub


 
'********************************************************************************
'  <<< [DevEnvObj::devenv_sub] >>> 
'********************************************************************************
Public Sub  devenv_sub( exe_path, vs, param, config, ByVal EchoMessage )
	If IsEmpty( exe_path ) Then _
		Raise  1, "devenv.exe が見つかりません。"

	If not IsEmpty( EchoMessage ) Then
		echo_v  g_sh.CurrentDirectory +">"
		echo_v  Replace( EchoMessage, "%vs%", vs )
	End If


	'//=== Build
	cmdline = """" + exe_path + """ " + param + " """ + config + """"
	r = g_sh.Run( cmdline,, True )

	If r <> 0 Then  Err.raise  E_BuildFail,,"devenv failed " + param + " in " + g_sh.CurrentDirectory
End Sub


 
'********************************************************************************
'  <<< [DevEnvObj::Rebuild] >>> 
'********************************************************************************
Public Sub  Rebuild( sln_path, config )
	Set c_vs = get_VisualStudioConsts()
	sln_path2 = env( sln_path )
	Me.Get_devenv_exe_Path  sln_path2, exe_path, edition, vs
	If edition <> c_vs.ExpressEdition Then
		Me.devenv  sln_path2, """" + sln_path2 + """ /rebuild", config, _
			">devenv.exe(%vs%) """+sln_path2+""" /rebuild "+config +vbCRLF+_
			" (if cl.exe was already run background by stop build, it may be fail.)"
	Else
		del  GetParentFullPath( sln_path2 ) +"\"+ config +"\*"

		Me.devenv  sln_path2, """" + sln_path2 + """ /build", config, _
			">devenv.exe(%vs%) """+sln_path2+""" /rebuild "+config +vbCRLF+_
			" (if cl.exe was already run background by stop build, it may be fail.)"
	End If
End Sub



 
'********************************************************************************
'  <<< [DevEnvObj::Build] >>> 
'********************************************************************************
Public Sub  Build( sln_path, config )
	sln_path2 = env( sln_path )
	Me.devenv  sln_path2, """" + sln_path2 + """ /build", config, _
		">devenv.exe(%vs%) """+sln_path2+""" /build "+config +vbCRLF+_
		" (if cl.exe was already run background by stop build, it may be fail.)"
End Sub


 
'********************************************************************************
'  <<< [DevEnvObj::Clean] >>> 
'********************************************************************************
Public Sub  Clean( sln_path )
	Set c_vs = get_VisualStudioConsts()
	Set ds_= new CurDirStack
	sln_path2 = env( sln_path )
	solution_dir = GetParentFullPath( sln_path2 )

	If not g_fs.FileExists( sln_path2 ) Then _
		Err.Raise  E_FileNotExist,,"Not found : " + sln_path2
	Set ec = new EchoOff


	'// devenv clean
	Me.Get_devenv_exe_Path  sln_path2, exe_path, edition, vs
	If edition <> c_vs.ExpressEdition Then
		Me.devenv_sub  exe_path, vs, """"+sln_path2+""" /clean", "Release", _
			">devenv.exe(%vs%) """+sln_path2+""" /clean"
		Me.devenv_sub  exe_path, vs, """"+sln_path2+""" /clean", "Debug", Empty
	End If


	'// In project folder
	Set sln = new VisualStudioSlnClass
	sln.Load  sln_path2
	For Each project  In sln.Projects.Items
		cd  g_fs.GetParentFolderName( GetFullPath( project.RelativePath, solution_dir ) )
		del "Release"
		del "Debug"
		del "*.user"
	Next

	'// In solution folder
	cd  solution_dir
	del "Release"
	del "Debug"
	del "*.ncb"
	del "*.suo"
End Sub


 
'********************************************************************************
'  <<< [DevEnvObj::Upgrade] >>> 
'********************************************************************************
Public Sub  Upgrade( SlnPath, Opt )
	sln_path2 = env( SlnPath )
	sln_folder = GetParentFullPath( sln_path2 )
	Set c = g_VBS_Lib

	vs = GetVar( "devenv_ver_name" )
	Select Case vs
		Case  "vs2013"
			install_dir = m_InstallDir2013
			del_names = Array( "_UpgradeReport_Files", "Backup", "*.sdf", "*.suo" )
		Case  "vs2012"
			install_dir = m_InstallDir2012
			del_names = Array( "_UpgradeReport_Files", "Backup", "*.sdf", "*.suo" )
		Case  "vs2010"
			install_dir = m_InstallDir2010
			del_names = Array( "_UpgradeReport_Files", "Backup", "*.old", "*.user", "*.suo", "UpgradeLog.XML" )
		Case  "vs2008"
			install_dir = m_InstallDir2008
			del_names = Array( "_UpgradeReport_Files", "Backup", "*.old", "*.user", "*.suo", "UpgradeLog.XML" )
		Case  "vs2005"
			install_dir = m_InstallDir2005
			del_names = Array( "_UpgradeReport_Files", "Backup", "*.old", "*.user", "*.suo", "UpgradeLog.XML" )
		Case Else
			Raise  c.NotInstalled,"Visual Studio がインストールされていません"
	End Select
	If IsEmpty( install_dir ) Then
		Raise  c.NotInstalled,"Visual Studio ("+ vs +") がインストールされていません"
	End If


	If IsEmpty( Opt ) Then
		For Each name  In del_names
			If exist( sln_folder +"\"+ name ) Then _
				Raise  1,"<ERROR msg=""Upgrade する前に手動で削除してください"" path="""+ name +"""/>"
		Next
	End If


	'//=== Get "devenv_exe" path
	echo_v  ">devenv.exe("+ vs +") """+sln_path2+""" /upgrade"
	devenv_exe = install_dir + "devenv.exe"
	If g_fs.FileExists( devenv_exe ) Then
		cmdline = """" + devenv_exe +""" """ + sln_path2 + """ /upgrade"

		r = RunProg( cmdline, "" )
		If r <> 0 Then  Err.raise E_BuildFail,, _
			"devenv failed in " + g_sh.CurrentDirectory
	Else
		vcupgrade_exe = install_dir + "..\Tools\vcupgrade.exe"
		If not g_fs.FileExists( vcupgrade_exe ) Then _
			vcupgrade_exe = install_dir + "Common7\Tools\vcupgrade.exe"

		If not g_fs.FileExists( vcupgrade_exe ) Then
			devenv_path = install_dir + "devenv.exe"
			Raise  1, devenv_path +" が見つかりません。"
		End If

		Set sln = new VisualStudioSlnClass : sln.Load  sln_path2
		For Each project  In sln.Projects.Items
			project_path = GetFullPath( project.RelativePath, sln_folder )
			cmdline = """" + vcupgrade_exe +""" """ + project_path + """"

			r = RunProg( cmdline, "nul" )
			If r <> 0 Then  Err.raise E_BuildFail,, _
				"vcupgrade failed in " + g_sh.CurrentDirectory
		Next
	End If


	If IsEmpty( Opt ) Then
		Set ec = new EchoOff
		For Each name  In del_names
			del  sln_folder +"\"+ name
		Next
	End If


	'//=== Upgrade *.sln file (Only VC++ project)
	If devenv_option = "" Then
		format_line_A = "Microsoft Visual Studio Solution File, Format Version "
		format_line_B = "# Visual Studio "
		Set versions_A = Dict(Array( "vs2005","9.00", "vs2008","10.00", "vs2010","11.00", _
			"vs2012","12.00", "vs2013","12.00" ))
		Set versions_B = Dict(Array( _
			"vs2005","# Visual Studio 2005", _
			"vs2008","# Visual Studio 2008", _
			"vs2010","# Visual C++ Express 2010", _
			"vs2012","# Visual Studio Express 2012 for Windows Desktop", _
			"vs2013","# Visual Studio Express 2013 for Windows Desktop" ))

		Set rep = StartReplace( SlnPath, GetTempPath("*.sln"), False )
		Do Until rep.r.AtEndOfStream
			SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf
			If InStr( line, format_line_A ) > 0 Then
				line = format_line_A + versions_A( vs )
			ElseIf InStr( line, format_line_B ) > 0 Then
				line = versions_B( vs )
			ElseIf InStr( line, "Project(""{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}"")" ) Then
				If vs <> "vs2005"  and  vs <> "vs2008" Then _
					line = Replace( line, ".vcproj""", ".vcxproj""" )
			End If
			rep.w.WriteLine  line + cr_lf
		Loop
		rep.Finish
	End If
End Sub


 
End Class 


 
'********************************************************************************
'  <<< [GetSlnFileVersion] >>> 
' - out_VersionNum : 2013, 2012, 2010, 2008, 2005
'********************************************************************************
Sub  GetSlnFileVersion( SlnPath, out_VersionNum, out_IsExpress )
	Set ec = new EchoOff

	Set f = OpenForRead( SlnPath )
	i=1
	Do Until  f.AtEndOfStream
		line = f.ReadLine()

		If InStr( line, "# Visual Studio Express" ) > 0 Then
			out_VersionNum = CInt( Mid( line, 25, 4 ) )
			out_IsExpress = True
			Exit Sub
		End If

		If InStr( line, "# Visual Studio" ) > 0 Then
			out_VersionNum = CInt( Mid( line, 17 ) )
			out_IsExpress = False
			Exit Sub
		End If

		If InStr( line, "# Visual C++ Express" ) > 0 Then
			out_VersionNum = CInt( Mid( line, 22 ) )
			out_IsExpress = True
			Exit Sub
		End If

		If i=10 Then Exit Do
		i=i+1
	Loop
	Raise  1,"<ERROR msg='.sln ファイルにバージョン情報が見つかりません'"+_
			" path='" + SlnPath + "'/>"
End Sub


 
'********************************************************************************
'  <<< [IsVisualStudioInstalled] >>> 
'********************************************************************************
Function  IsVisualStudioInstalled( ByVal VersionNum, IsExpress )
	Set devenv_obj = get_DevEnvObj

	VersionNum = GetVisualStudioVersionNum( VersionNum )

	If IsEmpty( VersionNum ) Then
		If IsEmpty( IsExpress ) Then
			IsVisualStudioInstalled = _
				not IsEmpty( devenv_obj.m_InstallDir2013 ) or _
				not IsEmpty( devenv_obj.m_InstallDir2012 ) or _
				not IsEmpty( devenv_obj.m_InstallDir2010 ) or _
				not IsEmpty( devenv_obj.m_InstallDir2008 ) or _
				not IsEmpty( devenv_obj.m_InstallDir2005 )
		ElseIf IsExpress Then
			IsVisualStudioInstalled = _
				not IsEmpty( devenv_obj.WDExpress_exe_2013 ) or _
				not IsEmpty( devenv_obj.WDExpress_exe_2012 ) or _
				not IsEmpty( devenv_obj.VCExpress_exe_2010 )
		Else
			IsVisualStudioInstalled = _
				not IsEmpty( devenv_obj.devenv_exe_2013 ) or _
				not IsEmpty( devenv_obj.devenv_exe_2012 ) or _
				not IsEmpty( devenv_obj.devenv_exe_2010 ) or _
				not IsEmpty( devenv_obj.devenv_exe_2008 ) or _
				not IsEmpty( devenv_obj.devenv_exe_2005 )
		End If
	Else
		Select Case  VersionNum
			Case  2013
				devenv_exe  = devenv_obj.devenv_exe_2013
				express_exe = devenv_obj.WDExpress_exe_2013
			Case  2012
				devenv_exe  = devenv_obj.devenv_exe_2012
				express_exe = devenv_obj.WDExpress_exe_2012
			Case  2010
				devenv_exe  = devenv_obj.devenv_exe_2010
				express_exe = devenv_obj.VCExpress_exe_2010
			Case  2008
				devenv_exe  = devenv_obj.devenv_exe_2008
			Case  2005
				devenv_exe  = devenv_obj.devenv_exe_2005
			Case Else
				Error
		End Select


		If IsEmpty( IsExpress ) Then
			IsVisualStudioInstalled = not IsEmpty( express_exe )  or  not IsEmpty( devenv_exe )
		ElseIf IsExpress Then
			IsVisualStudioInstalled = not IsEmpty( express_exe )
		Else
			IsVisualStudioInstalled = not IsEmpty( devenv_exe )
		End If
	End If
End Function


 
'********************************************************************************
'  <<< [GetVisualStudioVersionNum] >>> 
'********************************************************************************
Function  GetVisualStudioVersionNum( VersionString )
	If VarType( VersionString ) = vbString Then
		GetVisualStudioVersionNum = CInt( Mid( VersionString, 3 ) )
	Else
		GetVisualStudioVersionNum = VersionString
	End If
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [VisualStudioSlnClass] >>>> 
'-------------------------------------------------------------------------
Class  VisualStudioSlnClass
	Public  Projects  '// as ArrayClass of VisualStudioSlnProjectClass

	Private Sub  Class_Initialize()
		Me.Reset
	End Sub


 
'*************************************************************************
'  <<< [VisualStudioSlnClass::Reset] >>> 
'*************************************************************************
Sub  Reset()
	Set Me.Projects = new ArrayClass
End Sub


 
'*************************************************************************
'  <<< [VisualStudioSlnClass::Load] >>> 
'*************************************************************************
Sub  Load( SlnFilePath )
	Me.Reset

	Set file = OpenForRead( SlnFilePath )
	Do Until  file.AtEndOfStream
		line = file.ReadLine()
		If StrCompHeadOf( line, "Project(""{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}"")", Empty ) _
				= 0 Then

			Set proj = new VisualStudioSlnProjectClass
			Me.Projects.Add  proj

			values = Mid( line, InStr( line, "=" ) + 1 )

			position = 1
			proj.ProjectName  = MeltCSV( values, position )
			proj.RelativePath = MeltCSV( values, position )
			proj.ProjectGuid  = MeltCSV( values, position )
		End If
		If StrCompHeadOf( line, "Global", Empty ) = 0 Then _
			Exit Do
	Loop
End Sub


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [VisualStudioSlnProjectClass] >>>> 
'-------------------------------------------------------------------------
Class  VisualStudioSlnProjectClass
	Public  ProjectName   '// as string
	Public  RelativePath  '// as string
	Public  ProjectGuid   '// as string
End Class 


 
'********************************************************************************
'  <<< [DeleteProjectInVisualStudioSln] >>> 
'********************************************************************************
Sub  DeleteProjectInVisualStudioSln( SlnFilePath, ProjectName )

	echo  ">DeleteProjectInVisualStudioSln  """+ SlnFilePath +""", """+ ProjectName +""""
	Set ec = new EchoOff

	'// Set "cutting_project_GUID"
	Set sln = new VisualStudioSlnClass
	sln.Load  SlnFilePath
	cutting_project_GUID = Empty
	For Each  project  In sln.Projects.Items
		If project.ProjectName = ProjectName Then
			cutting_project_GUID = project.ProjectGuid
			Exit For
		End If
	Next
	If IsEmpty( cutting_project_GUID ) Then  Exit Sub  '// Delete nothing


	'// Initialize variables
	current_project_name = Empty
	current_project_GUID = Empty
	end_keyword_of_cutting_block = Empty
	is_in_project_dependencies = False
	is_written_project_dependencies = False
	is_in_project_configuration = False


	'// Replace in "SlnFilePath"
	Set rep = StartReplace( SlnFilePath, GetTempPath("*.txt"), False )
	Do Until rep.r.AtEndOfStream
		SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf

		'// Cut Project block
		If StrCompHeadOf( line, "Project(""{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}"")", Empty ) _
				= 0 Then

			'// Set "current_project_name", "current_project_GUID"
			values = Mid( line, InStr( line, "=" ) + 1 )
			position = 1
			current_project_name  = MeltCSV( values, position )
			dummy                 = MeltCSV( values, position )
			current_project_GUID  = MeltCSV( values, position )


			'// Cut Project block
			If current_project_name = ProjectName Then
				end_keyword_of_cutting_block = "EndProject"
			Else
				rep.w.WriteLine  line + cr_lf
			End If

		ElseIf not IsEmpty( end_keyword_of_cutting_block ) Then

			If line = end_keyword_of_cutting_block Then
				end_keyword_of_cutting_block = Empty
			End If


		'// Cut "(ProjectDependencies)"
		ElseIf line = "	ProjectSection(ProjectDependencies) = postProject" Then

			is_in_project_dependencies = True

		ElseIf line = "	EndProjectSection" Then

			If is_written_project_dependencies Then
				rep.w.WriteLine  line + cr_lf
				is_written_project_dependencies = False
			End If
			is_in_project_dependencies = False

		ElseIf is_in_project_dependencies Then

			If line = "		"+ cutting_project_GUID +" = "+ cutting_project_GUID Then
				'// not write
			Else
				If not is_written_project_dependencies Then
					rep.w.WriteLine  "	ProjectSection(ProjectDependencies) = postProject" +_
						cr_lf
					is_written_project_dependencies = True
				End If
				rep.w.WriteLine  line + cr_lf
			End If


		'// Cut "(ProjectConfigurationPlatforms)"
		ElseIf line = "	GlobalSection(ProjectConfigurationPlatforms) = postSolution" Then

			is_in_project_configuration = True
			rep.w.WriteLine  line + cr_lf

		ElseIf is_in_project_configuration Then
			If StrCompHeadOf( line, "		"+ cutting_project_GUID +".", Empty ) _
					= 0 Then
				'// not write
			Else
				rep.w.WriteLine  line + cr_lf
			End If

			If line = "	EndGlobalSection" Then
				is_in_project_configuration = False
			End If


		'// Write through
		Else
			rep.w.WriteLine  line + cr_lf
		End If
	Loop
	rep.Finish
End Sub


 
