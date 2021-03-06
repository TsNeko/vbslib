Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	If WScript.Arguments.Named.Item("Validate") Then _
		g_bNeedValidateDelegate = True

	get_ObjectsFromFile  "objs\*.vbs", "ClassI", objs '// [out] objs

	For Each obj in objs
		out = out + obj.xml + vbCRLF
	Next

	If g_bNeedValidateDelegate Then
		For Each obj in objs
			obj.Validate  F_ValidateOnlyDelegate
		Next

		For Each obj in objs
			out = out + obj.xml + vbCRLF
		Next
	End If

	echo  out
	Set cs = new_TextFileCharSetStack( "unicode" )
	CreateFile  "out.xml", "<P>"+vbCRLF+ out +"</P>"

	Pass
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [ClassI] Class >>>> 
'-------------------------------------------------------------------------
Class ClassI  '// defined_as_interface
	Public  Name
	Public  TrueName
	'--- Name is factory pattern.

	Public Sub  Validate( Flags ) : End Sub
	Public  DefineInfo
	Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

	Public  Value
	Public Function  Method1() : End Function
End Class


Function  ClassI_getXML( m )
	ClassI_getXML = "<ClassI Name='" + m.Name + "' TrueName='" + m.TrueName +_
		"' DefinePath='" + g_fs.GetFileName( m.DefineInfo.FullPath ) + _
		"' TypeName='" + TypeName( m ) + _
		"' Method1_ret='" + m.Method1() + "' Value='" & m.Value & "'/>"
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [ClassI_Delegator] Class >>>> 
'-------------------------------------------------------------------------
'// Class  ClassI_Delegator  has_interface_of NameDelegator and ClassI

Class ClassI_Delegator
	Public  Name
	Public Property Get  TrueName() : TrueName = NameDelegator_getTrueName( Me ) : End Property
	Public  m_Delegate ' as ClassA or ClassB or string(before validated)
	'--- Name is factory pattern.

	Public Sub  Validate( Flags ) : NameDelegator_validate  Me, Flags : End Sub
	Public Property Get  DefineInfo() : Set DefineInfo = m_Delegate.DefineInfo : End Property
	Public Property Get  xml() : xml = NameDelegator_getXML( Me ) : End Property

	Public Property Let  Value( v ) : m_Delegate.Value = v : End Property
	Public Property Get  Value( )   : Value = m_Delegate.Value : End Property
	Public Function  Method1() : Method1 = m_Delegate.Method1() : End Function
End Class


Function  new_ClassI_Delegator()
	Set  new_ClassI_Delegator = new ClassI_Delegator
End Function


 







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


 
