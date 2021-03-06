Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Download1",_
			"2","T_SetVirtualFileServer_Files_Manually" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


Sub  T_Download1( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  e  ' as Err2

	'//=== download from recognized site
	EchoTestStart  "T_Download1"
	echo  "www.sage-p.com から xml ファイルをダウンロードします。"
	echo  "ファイアーウォールが反応するかもしれません"
	pause

	del  "downloaded.xml"
	DownloadByHttp  "http://www.sage-p.com/update/snapnote_full_new_version.xml", "downloaded.xml"

	Dim  root : Set root = LoadXML( "downloaded.xml", Empty )
	If IsNull( root.getAttribute( "version_number" ) ) Then  Fail


	del  "downloaded.xml"


	'//=== download from unrecognized site - Yes
	EchoTestStart  "T_UnregognizedSiteYes"
	echo  "ダウンロードの確認では、Y を入力してください"
	pause

	DownloadByHttp  "http://gigazine.net/", "downloaded.html"

	del  "downloaded.html"


	'//=== download from unrecognized site - No
	EchoTestStart  "T_UnregognizedSiteNo"
	echo  "ダウンロードの確認では、N を入力してください"
	pause

	If TryStart(e) Then  On Error Resume Next
		DownloadByHttp  "http://gigazine.net/", "downloaded.html"
	If TryEnd Then  On Error GoTo 0
	If e.num = 0 Then  Fail
	e.Clear

	del  "downloaded.html"


	'//=== download from unrecognized site - close
	EchoTestStart  "T_UnregognizedSiteNo"
	echo  "ダウンロードの確認では、ウィンドウを閉じてください"
	pause

	If TryStart(e) Then  On Error Resume Next
		DownloadByHttp  "http://gigazine.net/", "downloaded.html"
	If TryEnd Then  On Error GoTo 0
	If e.num = 0 Then  Fail
	e.Clear

	del  "downloaded.html"
	Pass
End Sub


 
Sub  T_SetVirtualFileServer_Files_Manually( Opt, AppKey )
	command = "cscript  T_Download.vbs  T_SetVirtualFileServer_Files_Manually"
	echo  "次のコマンドを実行します。"
	echo  ">"+ command
	Pause
	RunProg  command, ""
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
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
