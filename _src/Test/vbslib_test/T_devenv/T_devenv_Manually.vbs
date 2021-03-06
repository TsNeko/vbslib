Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	g_CUI.SetAutoKeysFromMainArg
'// SetStartSectionTree  "T_DevEnv_Upgrade_vs2010_Release"

	EchoTestStart  "T_devenv_Manually"

	echo  "インストール済みの Visual Studio のバージョンについては、ビルド＆クリーンのエラーが"+_
		"出ないこと。 インストールしていないバージョンについては (T_devenv_Manually) に続いて"+_
		"エラーメッセージが出ること"
	pause

	T_DevEnv  "vs2013"
	T_DevEnv  "vs2012"
	T_DevEnv  "vs2010"
	T_DevEnv  "vs2008"
	T_DevEnv  "vs2005"
	Pass
End Sub


 
Sub  T_DevEnv( DevVer )
	Set c = g_VBS_Lib
	Set section = new SectionTree
	Set v_= new VarStack
	configurations = Array( "Release", "Debug" )

	'// Set up
	del  "sample sln original"
	del  "sample sln"
	unzip  "Files\sample sln.zip", "sample sln", Empty
	copy   "sample sln\*", "sample sln original"


	'//=== Test : build
	For Each configuration  In configurations
		If section.Start( "T_DevEnv_Build_"+ DevVer +"_"+ configuration ) Then
			del  "sample sln\"+ configuration
			If TryStart(e) Then  On Error Resume Next
				devenv_build  "sample sln\return_"+ DevVer +".sln", configuration
			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2

			If e2.num = 0 Then
				Assert  exist("sample sln\"+ configuration +"\return.exe")
			ElseIf e2.num = c.NotInstalled Then
				echo  "(T_devenv_Manually) "+ e2.desc
			Else
				e2.Raise
			End If
		End If : section.End_
	Next


	'//=== Test : rebuild
	Set built_configurations = new ArrayClass
	For Each configuration  In configurations
		If section.Start( "T_DevEnv_Rebuild_"+ DevVer +"_"+ configuration ) Then
			del  "sample sln\"+ configuration
			If TryStart(e) Then  On Error Resume Next
				devenv_rebuild  "sample sln\return_"+ DevVer +".sln", configuration
			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2

			If e2.num = 0 Then
				AssertExist  "sample sln\"+ configuration +"\return.exe"

				built_configurations.Add  configuration
				For Each old_configuration  In built_configurations.Items
					AssertExist  "sample sln\"+ old_configuration +"\return.exe"
				Next
			ElseIf e2.num = c.NotInstalled Then
				echo  "(T_devenv_Manually) "+ e2.desc
			Else
				e2.Raise
			End If
		End If : section.End_
	Next


	'//=== Test : clean
	If section.Start( "T_DevEnv_Clean_"+ DevVer ) Then

		If TryStart(e) Then  On Error Resume Next
			devenv_clean "sample sln\return_"+ DevVer +".sln"
		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2

		If e2.num = 0 Then
			Assert  fc( "sample sln", "sample sln original" )
		ElseIf e2.num = c.NotInstalled Then
			echo  "(T_devenv_Manually) "+ e2.desc
		Else
			e2.Raise
		End If
	End If : section.End_


	'//=== Test : upgrade
	If DevVer <> "vs2005" Then
	For Each configuration  In configurations
		If section.Start( "T_DevEnv_Upgrade_"+ DevVer +"_"+ configuration ) Then

			'// Set up
			del  "sample sln"
			copy   "sample sln original\*", "sample sln"

			SaveEnvVars  envs, Empty
			set_  "devenv_ver_name", DevVer


			'// Test Main
			If TryStart(e) Then  On Error Resume Next
				devenv_upgrade  "sample sln\return_vs2005.sln", configuration
			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2

			'// Check
			If e2.num = 0 Then
				devenv_build  "sample sln\return_vs2005.sln", configuration

				AssertExist  "sample sln\"+ configuration +"\return.exe"
			ElseIf e2.num = c.NotInstalled Then
				echo  "(T_devenv_Manually) "+ e2.desc
			Else
				e2.Raise
			End If

			'// Clean
			LoadEnvVars  envs, Empty
		End If : section.End_
	Next
	End If


	'// Clean
	del  "sample sln original"
	del  "sample sln"
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

  
