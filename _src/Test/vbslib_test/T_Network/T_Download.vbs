Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_SetVirtualFileServer",_
			"2","T_SetVirtualFileServer_byXML",_
			"3","T_SetVirtualFileServer_Files",_
			"4","T_GetPercentURL" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SetVirtualFileServer] >>> 
'********************************************************************************
Sub  T_SetVirtualFileServer( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_SetVirtualFileServer_LocalFile"


	'//===========================================================
	If section.Start( "T_SetVirtualFileServer_Default" ) Then

	'// Set up
	del  "_work"
	CreateFile  "_work\downloaded2.xml", "BadData"  '// For overwrite test

	'// Test Main
	DownloadByHttp  "http://www.sage-p.com/test/t_setvirtualfileserver.xml",       "_work\downloaded1.xml"
	DownloadByHttp  "http://www.sage-p.com/test/files/t_setvirtualfileserver.xml", "_work\downloaded2.xml"

	'// Check
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "2.99"
	Assert  LoadXML( "_work\downloaded2.xml", Empty ).getAttribute( "version_number" ) = "3.07"

	'// Clean
	SetVirtualFileServer  Empty, Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_SetVirtualFileServer_LocalFile" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	SetVirtualFileServer  "http://www.sage-p.com/test", GetFullPath( "VirtualFileServer", Empty )
	DownloadByHttp  "http://www.sage-p.com/test/t_setvirtualfileserver.xml", "_work\downloaded2.xml"
	DownloadByHttp  "http://www.sage-p.com/test/files/t_setvirtualfileserver.xml", "_work\downloaded3.xml"

	'// Check
	Assert  LoadXML( "_work\downloaded2.xml", Empty ).getAttribute( "version_number" ) = "2.99.Local"
	Assert  LoadXML( "_work\downloaded3.xml", Empty ).getAttribute( "version_number" ) = "3.07.Local"


	'// Test Main : Case of Other Local File, Case of Last "/", Case of Overwrite
	SetVirtualFileServer  "http://www.sage-p.com/other/", GetFullPath( "VirtualFileServer\Files", Empty ) +"\"
	DownloadByHttp  "http://www.sage-p.com/other/t_setvirtualfileserver.xml", "_work\downloaded2.xml"

	'// Check
	Assert  LoadXML( "_work\downloaded2.xml", Empty ).getAttribute( "version_number" ) = "3.07.Local"

	'// Clean
	SetVirtualFileServer  Empty, Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_SetVirtualFileServer_Empty" ) Then

	'// Set up
	SetVirtualFileServer  "http://www.sage-p.com/test", GetFullPath( "VirtualFileServer", Empty )

	'// Test Main
	SetVirtualFileServer  Empty, Empty

	'// Check
	DownloadByHttp  "http://www.sage-p.com/test/t_setvirtualfileserver.xml", "_work\downloaded2.xml"
	Assert  LoadXML( "_work\downloaded2.xml", Empty ).getAttribute( "version_number" ) = "2.99"

	'// Set up
	del  "_work"
	SetVirtualFileServer  "http://www.sage-p.com/test",       GetFullPath( "VirtualFileServer", Empty )
	SetVirtualFileServer  "http://www.sage-p.com/test/other", GetFullPath( "VirtualFileServer", Empty )

	'// Test Main
	SetVirtualFileServer  "http://www.sage-p.com/test", Empty

	'// Check
	DownloadByHttp  "http://www.sage-p.com/test/t_setvirtualfileserver.xml",       "_work\downloaded3.xml"
	DownloadByHttp  "http://www.sage-p.com/test/other/t_setvirtualfileserver.xml", "_work\downloaded4.xml"
	Assert  LoadXML( "_work\downloaded3.xml", Empty ).getAttribute( "version_number" ) = "2.99"
	Assert  LoadXML( "_work\downloaded4.xml", Empty ).getAttribute( "version_number" ) = "2.99.Local"

	'// Clean
	SetVirtualFileServer  Empty, Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_SetVirtualFileServer_OtherFolderInServer" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	SetVirtualFileServer  "http://www.sage-p.com/other", "http://www.sage-p.com/test"
	DownloadByHttp  "http://www.sage-p.com/other/t_setvirtualfileserver.xml", "_work\downloaded1.xml"

	'// Check
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "2.99"


	'// Test Main : Case of Last "/"
	SetVirtualFileServer  "http://www.sage-p.com/", "http://www.sage-p.com/test/files/"
	DownloadByHttp  "http://www.sage-p.com/t_setvirtualfileserver.xml", "_work\downloaded1.xml"

	'// Check
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "3.07"

	'// Clean
	SetVirtualFileServer  Empty, Empty

	End If : section.End_


	'//===========================================================
	If section.Start( "T_SetVirtualFileServer_SortURL" ) Then

	'// Set up
	del  "_work"

	'// Test Main
	SetVirtualFileServer  "http://www.sage-p.com/",     GetFullPath( "VirtualFileServer\Files", Empty ) +"\"
	SetVirtualFileServer  "http://www.sage-p.com/test", "VirtualFileServer"
	SetVirtualFileServer  "http://www.sage-p.com/test/files/", Empty
	DownloadByHttp  "http://www.sage-p.com/test/t_setvirtualfileserver.xml",       "_work\downloaded1.xml"
	DownloadByHttp  "http://www.sage-p.com/test/files/t_setvirtualfileserver.xml", "_work\downloaded2.xml"

	'// Check
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "2.99.Local"
	Assert  LoadXML( "_work\downloaded2.xml", Empty ).getAttribute( "version_number" ) = "3.07"

	'// Clean
	SetVirtualFileServer  Empty, Empty

	End If : section.End_


	'// Clean
	del  "_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SetVirtualFileServer_byXML] >>> 
'********************************************************************************
Sub  T_SetVirtualFileServer_byXML( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()

	'// Set up
	del  "_work"

	'// Test Main
	SetVirtualFileServer_byXML  "Files\T_SetVirtualFileServer_byXML.xml"

	'// Check
	DownloadByHttp  "http://www.sage-p.com/t_setvirtualfileserver.xml", "_work\downloaded1.xml"
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "2.99"

	DownloadByHttp  "http://www.sage-p.com/test/t_setvirtualfileserver.xml", "_work\downloaded1.xml"
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "2.99.Local"

	DownloadByHttp  "http://www.sage-p.com/test/files/t_setvirtualfileserver.xml", "_work\downloaded1.xml"
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "3.07"


	'// Test Main
	SetVirtualFileServer_byXML  GetVar("%__NotDefinedEnvironmentValue%")

	'// Check
	DownloadByHttp  "http://www.sage-p.com/test/t_setvirtualfileserver.xml", "_work\downloaded1.xml"
	Assert  LoadXML( "_work\downloaded1.xml", Empty ).getAttribute( "version_number" ) = "2.99"

	'// Clean
	del  "_work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SetVirtualFileServer_Files] >>> 
'********************************************************************************
Sub  T_SetVirtualFileServer_Files( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	T_SetVirtualFileServer_Files_Sub  False
End Sub

Sub  T_SetVirtualFileServer_Files_Sub( IsRealServer )
	Set sv = get_VirtualServerAtLocal()

	For Each download_count  In Array( 1, 2, 5, 8, 9, 10 )

		'// Set up
		del  "_work"

		ReDim  urls( download_count - 1 )
		For i=1 To download_count
			urls(i-1) = "http://www.sage-p.com/test/files/file"& i &".txt"

			If i mod 2 = 0 Then _
				sv.m_Delays( urls(i-1) ) = 1000
		Next

		If not IsRealServer Then
			SetVirtualFileServer  "http://www.sage-p.com/test/files", _
				GetFullPath( "VirtualFileServer\Files", Empty )
		End If


		'// Test Main
		DownloadByHttp  urls, "_work"


		'// Check
		For i=1 To download_count
			text = ReadFile( "_work\file"& i &".txt" )
			Assert  text = CStr( i ) + vbLF
		Next


		'// Clean
		del  "_work"
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SetVirtualFileServer_Files_Manually] >>> 
'********************************************************************************
Sub  T_SetVirtualFileServer_Files_Manually( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()
	T_SetVirtualFileServer_Files_Sub  True
End Sub


 
'********************************************************************************
'  <<< [T_GetPercentURL] >>> 
'********************************************************************************
Sub  T_GetPercentURL( Opt, AppKey )
	For Each  t  In DicTable( Array( _
		"String",  "URL",  Empty, _
		"http://www.sage-p.com/download file.html", _
		"http://www.sage-p.com/download%20file.html", _
		_
		"http://www.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.sage-p.com/0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.html", _
		"http://www.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.sage-p.com/0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.html", _
		_
		"http://!""$%&'()*+,-.:;<=>@[]^_`{|}~\", _
		"http://%21%22%24%25%26%27%28%29%2A%2B%2C-.:%3B%3C%3D%3E%40%5B%5D%5E_%60%7B%7C%7D~/", _
		_
		"ftp://example.com/!""$%&'()*+,-.:;<=>@[]^_`{|}~", _
		"ftp://example.com/%21%22%24%25%26%27%28%29%2A%2B%2C-.:%3B%3C%3D%3E%40%5B%5D%5E_%60%7B%7C%7D~", _
		_
		"https://example.com/?q=a&!""$%&'()*+,-.:;<=>@[]^_`{|}~:/?", _
		"https://example.com/?q=a&!%22$%25&'()*+,-.:;%3C=%3E@%5B%5D%5E_%60%7B%7C%7D~:/?", _
		_
		"https://example.com/a.html#!""$%&'()*+,-.:;<=>@[]^_`{|}~:/?#", _
		"https://example.com/a.html#!%22$%25&'()*+,-.:;%3C=%3E@%5B%5D%5E_%60%7B%7C%7D~:/?%23", _
		_
		"https://example.com/?q#!""$%&'()*+,-.:;<=>@[]^_`{|}~:/?#", _
		"https://example.com/?q#!%22$%25&'()*+,-.:;%3C=%3E@%5B%5D%5E_%60%7B%7C%7D~:/?%23", _
		_
		"StepPath-100%.html", _
		"StepPath-100%25.html" ) )


		a_URL = GetPercentURL( t("String") )
		Assert  a_URL = t("URL")

		a_string = DecodePercentURL( t("URL") )
		answer = Replace( t("String"), "\", "/" )
		Assert  a_string = answer
	Next

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

 
