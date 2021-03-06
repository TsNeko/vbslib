Sub  Main( Opt, AppKey )

	'// set_ "devenv_ver_name", "vs2005"

	If not IsVisualStudioInstalled( GetVisualStudioVersionNum( GetVar("%devenv_ver_name%") ),_
		Empty ) Then
			Exit Sub
	End If

	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_devenv_build",_
			"2","T_devenv_build_MultiFolder",_
			"3","T_devenv_upgrade",_
			"4","T_devenv_SlnLoad",_
			"5","T_devenv_DeleteProjectsInSln" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_devenv_build
'***********************************************************************
Sub  T_devenv_build( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	del  "sample sln"
	unzip  "Files\sample sln.zip", "sample sln", Empty

	'// Test Main and check
	devenv_clean  "sample sln\return_%devenv_ver_name%.sln"
	Assert  not exist(env("sample sln\%devenv_platform%Release\return.exe"))
	Assert  not exist(env("sample sln\%devenv_platform%Debug\return.exe"))

	If CInt( Mid( env("%devenv_ver_name%"), 3 ) ) >= 2015 Then
		For Each  platform_value  In  Array( "", "x64\" )
			platform_back_up = env("%devenv_platform%")
			set_ "devenv_platform",  platform_value
			devenv_build  "sample sln\return_%devenv_ver_name%.sln", "Release"
			Assert      exist("sample sln\"+ platform_value +"Release\return.exe")
			Assert  not exist("sample sln\"+ platform_value +"Debug\return.exe")
			set_ "devenv_platform",  platform_back_up
		Next
	End IF

	devenv_build  "sample sln\return_%devenv_ver_name%.sln", "Release"
	Assert      exist(env("sample sln\%devenv_platform%Release\return.exe"))
	Assert  not exist(env("sample sln\%devenv_platform%Debug\return.exe"))

	devenv_rebuild  "sample sln\return_%devenv_ver_name%.sln", "Debug"
	Assert      exist(env("sample sln\%devenv_platform%Release\return.exe"))  '// "Debug" rebuild does not delete "Release"
	Assert      exist(env("sample sln\%devenv_platform%Debug\return.exe"))

	devenv_clean  "sample sln\return_%devenv_ver_name%.sln"
	Set folder = g_fs.GetFolder( "sample sln" )
	Assert  folder.SubFolders.Count = 0

	'// Clean
	del  "sample sln"

	Pass
End Sub


 
'********************************************************************************
'* Function: T_devenv_build_MultiFolder
'*    「ソリューションのディレクトリを作成する」にチェックを入れたプロジェクト・ファイル
'********************************************************************************
Sub  T_devenv_build_MultiFolder( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	'// Set up
	del  "sample sln2"
	unzip  "Files\sample sln2.zip", "sample sln2", Empty

	'// Test Main and check
	devenv_clean  "sample sln2\return_%devenv_ver_name%.sln"
	Assert  not exist(env("sample sln2\%devenv_platform%Release\return.exe"))
	Assert  not exist(env("sample sln2\%devenv_platform%Debug\return.exe"))

	devenv_build  "sample sln2\return_%devenv_ver_name%.sln", "Release"
	Assert      exist(env("sample sln2\%devenv_platform%Release\return.exe"))
	Assert  not exist(env("sample sln2\%devenv_platform%Debug\return.exe"))

	devenv_rebuild  "sample sln2\return_%devenv_ver_name%.sln", "Debug"
	Assert      exist(env("sample sln2\%devenv_platform%Release\return.exe"))
	Assert      exist(env("sample sln2\%devenv_platform%Debug\return.exe"))

	devenv_clean  "sample sln2\return_%devenv_ver_name%.sln"
	Assert  not exist(env("sample sln2\%devenv_platform%Release"))
	Assert  not exist(env("sample sln2\%devenv_platform%Debug"))
	Assert  not exist(env("sample sln2\sub\%devenv_platform%Release"))
	Assert  not exist(env("sample sln2\sub\%devenv_platform%Debug"))

	'// Clean
	del  "sample sln2"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_devenv_upgrade
'***********************************************************************
Sub  T_devenv_upgrade( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	get_DevEnvObj
	If GetVar( "%devenv_ver_name%" ) >= "vs2008"  and  GetVar( "%devenv_ver_name%" ) <= "vs2010" Then


		'// Set up
		del  "sample sln"
		unzip  "Files\sample sln.zip", "sample sln", Empty

		If False Then
			versions = Array( "vs2005", "vs2008", "vs2010", "vs2012", "vs2013", "vs2015" )
			For i=1 To UBound( versions )
				If GetVar( "%devenv_ver_name%" ) = versions(i) Then
					previous_version = versions(i-1)
					Exit For
				End If
			Next
		Else
			previous_version = "vs2005"
		End If

		'// Test Main
		devenv_upgrade  "sample sln\return_"+ previous_version +".sln", Empty

		'// Check
		devenv_rebuild  "sample sln\return_"+ previous_version +".sln", "Debug"
		If not exist(env("sample sln\%devenv_platform%Debug\return.exe"))   Then  Fail

		'// Clean
		del  "sample sln"
	Else
		Skip
	End If

	Pass
End Sub


 
'***********************************************************************
'* Function: T_devenv_SlnLoad
'***********************************************************************
Sub  T_devenv_SlnLoad( Opt, AppKey )

	'// Set up

	'// Test Main
	Set sln = new VisualStudioSlnClass
	sln.Load  "Files\T_devenv_SlnLoad.sln"


	'// Check
	Assert  sln.Projects(0).ProjectGuid  = "{D7A04ABE-CAB4-4762-9696-127E76EA35B3}"
	Assert  sln.Projects(0).ProjectName  = "Sample_Test_PC"
	Assert  sln.Projects(0).RelativePath = "Project_PC\Sample_Test_PC.vcproj"

	Assert  sln.Projects(1).ProjectGuid  = "{DC8354D9-AFDD-405C-AC41-249AF1B6D759}"
	Assert  sln.Projects(1).ProjectName  = "Sample"
	Assert  sln.Projects(1).RelativePath = "..\src_PC\Project_PC\Sample.vcproj"

	Assert  sln.Projects.Count = 5


	Assert  sln.ConfigurationPlatforms(0).Configuration = "Debug"
	Assert  sln.ConfigurationPlatforms(0).Platform = "Win32"

	Assert  sln.ConfigurationPlatforms(1).Configuration = "Release"
	Assert  sln.ConfigurationPlatforms(1).Platform = "Win32"

	Assert  sln.ConfigurationPlatforms.Count = 2


	'// Clean

	Pass
End Sub


 
'***********************************************************************
'* Function: T_devenv_DeleteProjectsInSln
'***********************************************************************
Sub  T_devenv_DeleteProjectsInSln( Opt, AppKey )
	Set w_=AppKey.NewWritable( "work" ).Enable()
	sln_path = "work\T_devenv_SlnLoad.sln"

	'// Set up
	del  "work"
	copy  "Files\T_devenv_SlnLoad.sln", "work"


	'// Test Main
	DeleteProjectInVisualStudioSln  sln_path, "Sample"
	DeleteProjectInVisualStudioSln  sln_path, "SampleS"
	DeleteProjectInVisualStudioSln  sln_path, "Sample_SampleLib"
	DeleteProjectInVisualStudioSln  sln_path, "Sample"

	'// Check
	AssertFC  sln_path, "Files\T_devenv_DeleteProjectsInSln_Answer.sln"

	'// Clean
	del  "work"

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


 
