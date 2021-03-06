Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()

	Set obj = get_Object( "ClassN" )
	obj.Value = 11
	out = out + obj.xml + vbCRLF

	Set obj = get_Object( "ClassA" )
	out = out + obj.xml + vbCRLF

	SetVar  "ClassN", "ClassB"

	Set obj = get_Object( "ClassN" )
	obj.Value = 12
	out = out + obj.xml + vbCRLF

	Set obj = get_Object( "ClassN" ) '// Get ClassB again
	out = out + obj.xml + vbCRLF

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

	Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

	Public  Value
	Public Function  Method1() : End Function
End Class


Function  ClassI_getXML( m )
	ClassI_getXML = "<ClassI Name='" + m.Name + "' TrueName='" + m.TrueName +_
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

	Public Property Get  xml() : xml = NameDelegator_getXML( Me ) : End Property

	Public Property Let  Value( v ) : m_Delegate.Value = v : End Property
	Public Property Get  Value( )   : Value = m_Delegate.Value : End Property
	Public Function  Method1() : Method1 = m_Delegate.Method1() : End Function
End Class


Function  new_ClassI_Delegator()
	Set  new_ClassI_Delegator = new ClassI_Delegator
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [ClassN] Class >>>> 
'-------------------------------------------------------------------------
'// Class  ClassN  has_interface_of ClassI

Function    get_ClassN()
	Set get_ClassN = get_NameDelegator( "ClassN", ClassN_getTrueName(), "ClassI" )
End Function

Function  ClassN_getTrueName()
	ret = GetVar( "ClassN" )
	If IsEmpty( ret ) Then
		'// default is ClassA fixed
		ret = "ClassA" : SetVar "ClassN", ret
	End If
	ClassN_getTrueName = ret
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [ClassA] Class >>>> 
'-------------------------------------------------------------------------
'// Class  ClassA  has_interface_of ClassI

Dim  g_ClassA

Function    get_ClassA()
	If IsEmpty( g_ClassA ) Then _
		Set g_ClassA = new ClassA
	Set get_ClassA =   g_ClassA
End Function


Class ClassA
	Public  Property Get  Name()     : Name     = TypeName(Me) : End Property
	Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
	'--- Name is factory pattern.

	Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

	Public  Value
	Public Function  Method1() : Method1 = "ClassA.Method1" : End Function
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [ClassB] Class >>>> 
'-------------------------------------------------------------------------
'// Class  ClassB  has_interface_of ClassI

Dim  g_ClassB

Function    get_ClassB()
	If IsEmpty( g_ClassB ) Then _
		Set g_ClassB = new ClassB
	Set get_ClassB =   g_ClassB
End Function


Class ClassB
	Public  Name
	Public  TrueName
	'--- Name is factory pattern.

	Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

	Public  Value

	Private Sub  Class_Initialize() : Me.Name = "ClassB" : Me.TrueName = "ClassB" : End Sub
	Public Function  Method1() : Method1 = "ClassB.Method1" : End Function
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


 
