Option Explicit 

Sub  Main( Opt, AppKey )
	Dim  c : Set c = g_VBS_Lib
	echo  "Enter のみ：クリップボードの内容を変換"
	Dim  path : path = InputPath( "変換するファイル >", c.CheckFileExists or c.UseArgument1 or c.AllowEnterOnly )
	Dim  w_:Set w_=AppKey.NewWritable( path ).Enable()
	Dim  rep, line, cr_lf, pos

	Dim  is_clip : is_clip = False
	If path = "" Then  path = GetPathOfClipboardText() : is_clip = True

	Set rep = StartReplace( path, GetTempPath("Replace_*.txt"), c.DstIsBackUp )
	Do Until rep.r.AtEndOfStream
		SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf

		line = Replace( line, """", """""" )

'//		If Left( line, 1 ) = "(" Then
'//			line = Mid( line, 2 )
'//			pos = InStr( line, ")" )
'//			line = Left( line, pos - 1 ) + Mid( line, pos + 1 )
'//		End If
		If Left( line, 4 ) = "echo" Then  line = Mid( line, 6 )
		line = "file.WriteLine  """+ line +""""
		line = Replace( line, ">>%out%", "" )
		line = Replace( line, "^>", ">" )
		line = Replace( line, "^<", "<" )
		line = Replace( line, "^|", "|" )
		line = Replace( line, "%base%", """+ base +""" )

		rep.w.WriteLine  line + cr_lf
	Loop
	rep.w.WriteLine  "file = Empty" + cr_lf
	rep.Finish

	If is_clip Then
		SetTextToClipboard  ReadFile( path )
		del  path
	Else
		start  GetEditorCmdLine( path )
	End If
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


 
