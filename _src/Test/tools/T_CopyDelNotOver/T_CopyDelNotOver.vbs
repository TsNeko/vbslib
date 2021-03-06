Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_CopyNotOverwriteFileNoMenu",_
			"2","T_CopyNotOverwriteFile",_
			"3","T_CopyNotOverwriteFileForce",_
			"4","T_DeleteFileExistsNoMenu",_
			"5","T_DeleteFileExists",_
			"6","T_DeleteFileExistsForce",_
			"7","T_DeleteFileSameOnly",_
			"8","T_DeleteFileExistsSubSub" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_CopyNotOverwriteFileNoMenu] >>> 
'********************************************************************************
Sub  T_CopyNotOverwriteFileNoMenu( Opt, AppKey )
	T_CopyNotOverwriteFileSub  Opt, AppKey, False, False
End Sub


 
'********************************************************************************
'  <<< [T_CopyNotOverwriteFile] >>> 
'********************************************************************************
Sub  T_CopyNotOverwriteFile( Opt, AppKey )
	T_CopyNotOverwriteFileSub  Opt, AppKey, True, False
End Sub


 
'********************************************************************************
'  <<< [T_CopyNotOverwriteFileForce] >>> 
'********************************************************************************
Sub  T_CopyNotOverwriteFileForce( Opt, AppKey )
	T_CopyNotOverwriteFileSub  Opt, AppKey, True, True
End Sub


Sub  T_CopyNotOverwriteFileSub( Opt, AppKey, IsMenu, IsForce )
	Set w_=AppKey.NewWritable( "work" ).Enable()

	'// Set up (1)
	del  "work"
	copy  "Files\*", "work"

	If IsMenu  and  not IsForce Then _
		set_input  "99."


	'// Test Main (1)
	Set o = new CopyNotOverwriteFileClass
	o.SourcePath       = "work\Source"
	o.DestinationPath  = "work\Destination"
	o.SynchronizedPath = "work\Synchronized"


	'// Set up (2)
	If not IsMenu Then
		Set ec = new EchoOff
		For Each fo  In Array( o.SourcePath, o.DestinationPath, o.SynchronizedPath, _
			o.SourcePath+"\Sub", o.DestinationPath+"\Sub", o.SynchronizedPath+"\Sub" )

			For Each file_name  In Array( "Del.txt", "DiffDst.bin", "DiffDst.txt",_
				"DiffDstNoSyn.txt", "DiffSrcNoSyn.txt" )

				del  GetFullPath( file_name, GetFullPath( fo, Empty ) )
			Next
		Next
		ec = Empty
	End If


	'// Test Main (2)
	If IsForce Then
		o.CopyForce
	Else
		o.Copy
	End If


	'// Check
	If IsMenu Then
		If IsForce Then
			ans_path = "CopyAnswer"
		Else
			ans_path = Empty
		End If
	Else
		ans_path = "CopyAnswerNoMenu"
	End If
	If not IsEmpty( ans_path ) Then
		Assert  fc( "work\Destination",  ans_path +"\Destination" )
		Assert  fc( "work\Synchronized", ans_path +"\Synchronized" )
	End If


	'// Clean
	del  "work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_DeleteFileExistsNoMenu] >>> 
'********************************************************************************
Sub  T_DeleteFileExistsNoMenu( Opt, AppKey )
	T_DeleteFileExistsSub  Opt, AppKey, False, False, False
End Sub


 
'********************************************************************************
'  <<< [T_DeleteFileExists] >>> 
'********************************************************************************
Sub  T_DeleteFileExists( Opt, AppKey )
	T_DeleteFileExistsSub  Opt, AppKey, True, False, False
End Sub


 
'********************************************************************************
'  <<< [T_DeleteFileExistsForce] >>> 
'********************************************************************************
Sub  T_DeleteFileExistsForce( Opt, AppKey )
	T_DeleteFileExistsSub  Opt, AppKey, True, True, False
End Sub


'********************************************************************************
'  <<< [T_DeleteFileSameOnly] >>> 
'********************************************************************************
Sub  T_DeleteFileSameOnly( Opt, AppKey )
	T_DeleteFileExistsSub  Opt, AppKey, True, False, True
End Sub


Sub  T_DeleteFileExistsSub( Opt, AppKey, IsMenuCase, IsForce, IsSameOnly )
	Set w_=AppKey.NewWritable( "work" ).Enable()

	'// Set up (1)
	g_Vers("CutPropertyM") = True
	del  "work"
	copy  "Files\*", "work"

	If IsMenuCase  and  not IsForce  and not IsSameOnly Then _
		set_input  "99."


	'// Test Main (1)
	Set o = new DeleteSameFileClass
	o.SourcePath       = "work\Source"
	o.DestinationPath  = "work\Destination"
	o.SynchronizedPath = "work\Synchronized"


	'// Set up (2)
	If not IsMenuCase Then
		Set ec = new EchoOff
		For Each fo  In Array( o.SourcePath, o.DestinationPath, o.SynchronizedPath,_
			o.SourcePath+"\Sub", o.DestinationPath+"\Sub", o.SynchronizedPath+"\Sub" )

			For Each file_name  In Array( "Del.txt", "DiffDst.bin", "DiffDst.txt",_
				"DiffSrc.txt", "DiffDstNoSyn.txt", "DiffSrcNoSyn.txt" )

				del  GetFullPath( file_name, GetFullPath( fo, Empty ) )
			Next
		Next
		ec = Empty
	End If


	'// Test Main (2)
	If IsForce Then
		o.DeleteForce
	ElseIf IsSameOnly Then
		o.DeleteSameOnly
	Else
		o.Delete
	End If


	'// Check
	If IsMenuCase Then
		If IsForce Then
			ans_path = "DelAnswer"
		ElseIf IsSameOnly Then
			ans_path = "DelAnswerSameOny"
		Else
			ans_path = Empty
		End If
	Else
		ans_path = "DelAnswer"
	End If
	If not IsEmpty( ans_path ) Then
		If g_fs.FolderExists( ans_path +"\Destination" ) Then
			Assert  fc( "work\Destination",  ans_path +"\Destination" )
		Else
			Assert  not g_fs.FolderExists( "work\Destination" )
		End If

		If g_fs.FolderExists( ans_path +"\Synchronized" ) Then
			Assert  fc( "work\Synchronized", ans_path +"\Synchronized" )
		Else
			Assert  not g_fs.FolderExists( "work\Synchronized" )
		End If
	End If


	'// Clean
	del  "work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_DeleteFileExistsSubSub] >>> 
'********************************************************************************
Sub  T_DeleteFileExistsSubSub( Opt, AppKey )
	Set w_=AppKey.NewWritable( "work" ).Enable()

	'// Set up
	g_Vers("CutPropertyM") = True
	del  "work"
	copy  "Files_SubSub\*", "work"

	Set o = new CopyNotOverwriteFileClass
	o.SourcePath       = "work\Source"
	o.DestinationPath  = "work\Destination"
	o.SynchronizedPath = "work\Synchronized"
	o.Copy


	'// Test Main
	Set o = new DeleteSameFileClass
	o.SourcePath       = "work\Source"
	o.DestinationPath  = "work\Destination"
	o.SynchronizedPath = "work\Synchronized"
	o.Delete


	'// Check
	Assert  not exist( "work\Destination" )
	Assert  not exist( "work\Synchronized" )

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


 
