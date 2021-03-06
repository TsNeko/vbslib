g_SettingPath = "ReplaceTemplateSource.xml"

Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
	o.Lead = g_SettingPath
	Set o.MenuCaption = Dict(Array( _
		"1","置き換えを実行します [%name%]", _
		"2","置き換える前のテンプレートとマッチしていないファイルを一覧します [%name%]", _
		"3","置き換える前のテンプレートとマッチしていない行を調べます [%name%]", _
		"4","SearchOpen のリンク先アドレスを変換する [%name%]" ) )
	Set o.CommandReplace = Dict(Array( _
		"1","Replace", _
		"2","EchoOld", _
		"3","GetDifference", _
		"4","ReplaceSearchOpenBracketToND", _
		_
		"Replace","Template_replace", _
		"EchoOld","Template_echoOld", _
		"GetDifference","Template_getDifference", _
		"ReplaceSearchOpenBracketToND","ReplaceSearchOpenBracketToND_sth" ) )
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: Template_replace
'***********************************************************************
Sub  Template_replace( Opt, AppKey )
	Set c = g_VBS_Lib
	Set Me_ = new_ReplaceTemplateClass( g_SettingPath )
	Me_.SetTargetPath  GetFullPath( "Target", Empty )
	If Me_.TargetFolders.Count = 0 Then
		path = InputPath( "編集するファイル または フォルダー >", c.CheckFileExists or c.CheckFolderExists )
		Me_.SetTargetPath  path
	End If
	Set w_=AppKey.NewWritable( Me_.TargetFolders.FullPaths ).Enable()
	Me_.RunReplace
End Sub


 
'***********************************************************************
'* Function: Template_echoOld
'***********************************************************************
Sub  Template_echoOld( Opt, AppKey )
	new_ReplaceTemplateClass( g_SettingPath ).EchoOld
End Sub


 
'***********************************************************************
'* Function: Template_getDifference
'***********************************************************************
Sub  Template_getDifference( Opt, AppKey )
	new_ReplaceTemplateClass( g_SettingPath ).RunGetDifference
End Sub


 
'***********************************************************************
'* Function: ReplaceSearchOpenBracketToND_sth
'*    Replaces link target path of SearchOpen to Natural Docs format,
'***********************************************************************
Sub  ReplaceSearchOpenBracketToND_sth( Opt, AppKey )
	echo  "SearchOpen のリンク先アドレスを [ ] 形式から Natural Docs 形式に変換します。"
	to_replace_path = InputPath( "リンク先アドレスを変更するファイルのパス（★上書きします）>", _
		g_VBS_Lib.CheckFileExists )
	source_path = InputPath( "Natural Docs 形式に変換したソース ファイルのパス >", 0 )
	Set w_=AppKey.NewWritable( to_replace_path ).Enable()
	echo_line
	ReplaceSearchOpenBracketToND  to_replace_path,  source_path
End Sub


 
'***********************************************************************
'* Function: ReplaceSearchOpenBracketToND
'***********************************************************************
Sub  ReplaceSearchOpenBracketToND( in_ToReplacePath,  in_LinkTargetFileName )
	file_name = g_fs.GetFileName( in_LinkTargetFileName )
	Set re = CreateObject( "VBScript.RegExp" )
	re.Global = True

	echo  ">ReplaceSearchOpenBracketToND  """+ in_ToReplacePath +""", """+ file_name +""""
	Set ec = new EchoOff

	re.Pattern = "("+ ToRegExpPattern( file_name ) +")#\[([^\]]*)\]"

	OpenForReplace( in_ToReplacePath, Empty ).Replace  re, "$1#: $2"
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


 
