'***********************************************************************
'* File: Sample.vbs
'*    説明
'*
'* - $Rev: $
'* - $Date::                         $
'*
'*
'* Call tree:
'* - <Main>
'* - | <SampleFunction>
'* - | | <SubSub>
'*
'* Data structure:
'* - <SampleClass>
'* - | <ChildClass> .Child
'* - | | <GrandChildClass> .GrandChild
'* - | | | <ListClass> < <ElementClass> > .Elements
'***********************************************************************

'***********************************************************************
'* Function: Main
'***********************************************************************
Sub  Main()
	ret = SampleFunction( new SampleClass, out )
End Sub


'***********************************************************************
'* Function: SampleFunction
'*    UTF-8 形式なら、日本語も書けます。(vbslib 版では Shift-JIS か BOM 付き各種 Unicode)
'*
'* Arguments:
'*    in_Source       - Input
'*    out_Destination - Output
'*
'* Return Value:
'*    Error Code. 0=No Error.
'*
'* Description:
'*    The output from <SampleFunction>.
'*
'* Example:
'*    > void  main() {}
'***********************************************************************
Function  SampleFunction( in_Source, out_Destination )
End Function


'***********************************************************************
'* Class: SampleClass
'*    This is a SampleClass. This line can be deleted.
'***********************************************************************
Class  SampleClass

    '* Variable: Duration_msec
    '*     See "TimerClass".
    Public  Duration_msec

    '* Variable: Reserved
    Public  Reserved

    '--------------------------------------------------------
    '* Group: Colors

    '* Variable: m_Color
    Private  m_Color
End Class


'* Section: Global

'***********************************************************************
'* Constants: SampleConstants
'*    SampleConstants
'*
'*    : SymbolA - 0
'*    : SymbolB - 1
'***********************************************************************
Const  SymbolA = 0
Const  SymbolB = 1


'***********************************************************************
'* Variable: g_GlobalVariable
'***********************************************************************
Dim  g_GlobalVariable
Set  g_GlobalVariable = new SampleClass





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


 
