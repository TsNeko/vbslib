Option Explicit 

 
'-------------------------------------------------------------------------
' ### <<<< [MainWork] Class >>>> 
'-------------------------------------------------------------------------
Class  MainWork
  Public  DiffToolPath
  Public  OpenPositionY  '// as integer
  Public  OpenPositionYTarget  '// as integer 0,1,2
  Public  ComparePaths  '// as Array[0..2] of string

  Public  iMenu
  Public  c

  Private Sub  Class_Initialize()
    ReDim ComparePaths(2)
    Set Me.c = get_MainWorkConsts()
  End Sub
End Class

 
'********************************************************************************
'  <<< [get_MainWorkConsts] >>>
'********************************************************************************
Dim  g_MainWorkConsts

Function    get_MainWorkConsts()
  If IsEmpty( g_MainWorkConsts ) Then _
    Set g_MainWorkConsts = new MainWorkConsts
  Set get_MainWorkConsts =   g_MainWorkConsts
End Function


Class  MainWorkConsts
  Public  FileLabels

  Private Sub  Class_Initialize()
    FileLabels = Array( "FileA", "FileB", "FileC" )
  End Sub
End Class

 
Sub  Main( Opt, AppKey )
  Dim  w : Set w = new MainWork
  Dim  i, key, e

  w.DiffToolPath = WScript.Arguments.Named.Item( "DiffTool" )
  w.OpenPositionY = CInt2( WScript.Arguments.Named.Item( "Y" ) )
  w.OpenPositionYTarget = CInt2( WScript.Arguments.Named.Item( "YTarget" ) ) - 1

  For i=0 To WScript.Arguments.Unnamed.Count - 1
    w.ComparePaths(i) = WScript.Arguments.Unnamed(i)
    If i=2 Then Exit For
  Next

  Do
    echo_line
    echo  "[FileA] "+ w.ComparePaths(0)
    echo  "[FileB] "+ w.ComparePaths(1)
    If not IsEmpty( w.ComparePaths(2) ) Then  echo  "[FileC] "+ w.ComparePaths(2)
    If w.OpenPositionY > 0 Then _
      echo  "Look at line of "& w.OpenPositionY &" in "& w.c.FileLabels( w.OpenPositionYTarget )
    echo_line
    echo  "1. Start Diff FileA and FileB"
    echo  "2. Start Diff FileB and FileC"
    echo  "3. Start Diff FileA and FileC"
    echo  "9. Quit"
    If not IsEmpty( w.iMenu ) Then  echo "Enter のみのとき：" & w.iMenu
    key = input( "番号を選んでください >" )  '// または InputPath
    If key <> "" Then  w.iMenu = CInt2( key )
    echo_line

    If w.iMenu = 9 Then  Exit Do

    If TryStart(e) Then  On Error Resume Next
      Select Case  w.iMenu
        Case 1:  start  """"+ w.DiffToolPath +""" """+ w.ComparePaths(0) +""" """+ w.ComparePaths(1) +""""
        Case 2:  start  """"+ w.DiffToolPath +""" """+ w.ComparePaths(1) +""" """+ w.ComparePaths(2) +""""
        Case 3:  start  """"+ w.DiffToolPath +""" """+ w.ComparePaths(0) +""" """+ w.ComparePaths(2) +""""
      End Select
    If TryEnd Then  On Error GoTo 0
    If e.num <> 0 Then  echo  e.DebugHint : e.Clear
  Loop
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


 
