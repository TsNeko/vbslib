Option Explicit 

Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()

	Dim  s, a,b,c,d, arr_obj
	ReDim  arr(4)

	s = "<ObjToXMLのテスト>" + vbCRLF

	Set a = new ClassA
	a.Name = "InstanceA"
	a.DefinePath = "C:\ClassA.vbs"
	s = s + ObjToXML( Empty, a, Empty ) + vbCRLF

	Set b = new ClassB
	s = s + ObjToXML( Empty, b, Empty ) + vbCRLF

	Set c = new ClassC
	s = s + ObjToXML( Empty, c, Empty ) + vbCRLF

	Set d = new ClassD
	s = s + ObjToXML( Empty, d, Empty ) + vbCRLF

	Set arr(1) = a
	Set arr(2) = b
	Set arr(3) = c
	Set arr(4) = d
	s = s + ObjToXML( "Array", arr, Empty ) + vbCRLF

	Set arr_obj = new ArrayClass
	arr_obj.Add  a
	arr_obj.Add  b
	arr_obj.Add  c
	arr_obj.Add  d
	s = s + ObjToXML( "ArrayClass", arr_obj, Empty ) + vbCRLF

	s = s + "</ObjToXMLのテスト>"

	Dim  cs : Set cs = new_TextFileCharSetStack( "unicode" )
	CreateFile  "Out_ObjToXML.xml", s

	Pass
End Sub


Class  ClassA
	Public  Name ' as string
	Public  DefinePath ' as string
End Class

Class  ClassB
	Public  Property Get  Name() ' as string
		Name = "InstanceB"
	End Property
End Class

Class  ClassC
	Public  Property Get  DefinePath() ' as string
		DefinePath = "C:\ClassC.vbs"
	End Property
End Class

Class  ClassD
	Public  PropertyX
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


 
