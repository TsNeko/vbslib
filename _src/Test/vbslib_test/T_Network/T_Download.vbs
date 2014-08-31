Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_SetVirtualFileServer",_
			"2","T_SetVirtualFileServer_Files",_
			"3","T_GetPercentURL" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_SetVirtualFileServer] >>> 
'********************************************************************************
Sub  T_SetVirtualFileServer( Opt, AppKey )
	Set w_=AppKey.NewWritable( "work" ).Enable()

	'// Set up
	del  "work"

	'// Test Main
	SetVirtualFileServer  "http://www.sage-p.com/update", GetFullPath( "VirtualFileServer", Empty )
	DownloadByHttp  "http://www.sage-p.com/update/snapnote_full_new_version.xml", "work\downloaded.xml"

	'// Check
	Set root = LoadXML( "work\downloaded.xml", Empty )
	If IsNull( root.getAttribute( "version_number" ) ) Then  Fail
	If root.getAttribute( "version_number" ) <> "2.99" Then  Fail

	'// Clean
	del  "work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SetVirtualFileServer_Files] >>> 
'********************************************************************************
Sub  T_SetVirtualFileServer_Files( Opt, AppKey )
	Set w_=AppKey.NewWritable( "work" ).Enable()
	T_SetVirtualFileServer_Files_Sub  False
End Sub

Sub  T_SetVirtualFileServer_Files_Sub( IsRealServer )
	Set sv = get_VirtualServerAtLocal()

	For Each download_count  In Array( 1, 2, 5, 8, 9, 10 )

		'// Set up
		del  "work"

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
		DownloadByHttp  urls, "work"


		'// Check
		For i=1 To download_count
			text = ReadFile( "work\file"& i &".txt" )
			Assert  text = CStr( i ) + vbLF
		Next


		'// Clean
		del  "work"
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_SetVirtualFileServer_Files_Manually] >>> 
'********************************************************************************
Sub  T_SetVirtualFileServer_Files_Manually( Opt, AppKey )
	Set w_=AppKey.NewWritable( "work" ).Enable()
	T_SetVirtualFileServer_Files_Sub  True
End Sub


 
'********************************************************************************
'  <<< [T_GetPercentURL] >>> 
'********************************************************************************
Sub  T_GetPercentURL( Opt, AppKey )
	If GetPercentURL( "http://www.sage-p.com/download file.html" ) <> _
										"http://www.sage-p.com/download%20file.html" Then  Fail
	If GetPercentURL( "ftp://example.com/!""#$&'()*+,-.:;<=>[\]^_`{|}~" ) <> _
										"ftp://example.com/!%22%23$&'()*+,-.:;%3C=%3E%5B%5C%5D%5E_%60%7B%7C%7D~" Then  Fail
	Pass
End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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

 
