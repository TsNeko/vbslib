Option Explicit 

Dim  g_ErrEmulate

Const  F_ErrInCaller = 1
Const  F_ErrInFinish = 2
Const  F_ErrInCancel = 4
Const  F_ErrInRelease = 8
Const  F_NotCallFinish = 16


Sub  Main()
	Dim  en,ed, s

	set_input ".........."

	For g_ErrEmulate = 0 To 31
		s = ""
		If g_ErrEmulate and F_ErrInCaller Then    s = s + "ErrInCaller, "
		If g_ErrEmulate and F_ErrInFinish Then    s = s + "ErrInFinish, "
		If g_ErrEmulate and F_ErrInCancel Then    s = s + "ErrInCancel, "
		If g_ErrEmulate and F_ErrInRelease Then   s = s + "ErrInRelease, "
		If g_ErrEmulate and F_NotCallFinish Then  s = s + "NotCallFinish, "
		echo  "-----------------"
		If s <> "" Then  s = Left( s, Len(s)-2 )
		echo  "g_ErrEmulate = "& g_ErrEmulate &" ( "+ s +" )"

		On Error Resume Next
			T_Finish
		en = Err.Number : ed = Err.Description : On Error GoTo 0
		If en <> 0 Then  WScript.Echo  "ERROR(" & en & ") " & ed
	Next
End Sub


 
'********************************************************************************
'  <<< [T_Finish] >>> 
'********************************************************************************
Sub  T_Finish()
	Dim  m : Set m = new ClassA

	If g_ErrEmulate and F_ErrInCaller Then   WScript.Echo "ERROR!" : Err.Raise 1,,"in Caller"

	If ( g_ErrEmulate and F_NotCallFinish ) = 0 Then  m.Finish
	WScript.Echo "After Finish"
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [ClassA] Class >>>> 
'-------------------------------------------------------------------------
Class  ClassA
	Private  m_bFinished

	Public Sub  Finish()
		WScript.Echo "Finish(1)"
		If g_ErrEmulate and F_ErrInFinish Then  WScript.Echo "ERROR!" : Err.Raise 1,,"in Finish"
		WScript.Echo "Finish(2)"
		m_bFinished = True
	End Sub

	Private Sub  Class_Terminate()
		Dim  en,ed : en = Err.Number : ed = Err.Description
		On Error Resume Next  '// This clears error

		If en=0 or en=21 Then
		Else
			WScript.Echo "Cancel"
			If g_ErrEmulate and F_ErrInCancel Then   WScript.Echo "ERROR!" : Err.Raise 1,,"in Cancel"
		End If
		WScript.Echo "Release"
		If g_ErrEmulate and F_ErrInRelease Then   WScript.Echo "ERROR!" : Err.Raise 1,,"in Release"
		If en = 0 and not m_bFinished Then  NotCallFinish

		ErrorCheckInTerminate  en
		On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
	End Sub

End Class


 







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

 
