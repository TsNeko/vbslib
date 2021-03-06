Sub  Main( Opt, AppKey )
	g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )

	Set obj = new ClassA

	obj.PropA    = 1   '// static  defined property
	obj("PropB") = 12  '// dynamic defined property
	obj("PropC") = "ABC"
	Set obj("PropD") = new ClassA

	echo  "PropA = "& obj.PropA
	echo  "PropB = "& obj("PropB")
	echo  "PropC = "& obj("PropC")
	echo  "PropD = "& obj("PropD").Value

	echo  ""
	echo  "Keys:"
	For Each item  In obj.Keys  '// obj.Keys is standard. But obj.m_Dic.Keys is faster.
		echo  item
	Next

	echo  ""
	echo  "Items:"
	For Each item  In obj.Items  '// obj.Items is standard. But obj.m_Dic.Items is faster.
		If IsObject( item ) Then
			echo  item.Value
		Else
			echo  item
		End If
	Next


	echo  ""
	Set objL = new ClassL
	obj.SetEventCaller  objL
	objL.TriggerEventX

	obj.UnsetEventCaller  objL
	objL.TriggerEventX
End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [ClassA] Class : Event responder >>>> 
'-------------------------------------------------------------------------

Class ClassA
	Public  PropA  '// Static defined property

	Public Property Get  Value() : Value = "ClassA Object" : End Property



	'//=== Dynamic defined property : Item, Items, Keys
	Public Default Property Get  Item( Name ) : LetSet  Item, m_Dic( Name ) : End Property
	Public Property Let  Item( Name, Value ) : m_Dic( Name ) = Value : End Property
	Public Property Set  Item( Name, Object ) : Set m_Dic( Name ) = Object : End Property

	Public Property Get  Keys()  : Keys  = m_Dic.Keys  : End Property
	Public Property Get  Items() : Items = m_Dic.Items : End Property

	Public m_Dic  ' as Dictionary
	Private Sub  Class_Initialize()
		Set m_Dic = CreateObject( "Scripting.Dictionary" )
		m_Dic.CompareMode = 1  '// NotCaseSensitive
	End Sub

	Public Sub  SetEventCaller( Caller )
		Caller.OnEventX.Add  GetRef( "ClassA_onEventX" ), Me, 1000
	End Sub

	Public Sub  UnsetEventCaller( Caller )
		Caller.OnEventX.Remove  Me
	End Sub

	Public Sub  OnEventX( Caller, Args )
		echo  "Called ClassA::OnEventX"
	End Sub
End Class

Sub  ClassA_onEventX( Me_, Caller, Args ) : Me_.OnEventX  Caller, Args : End Sub


 
'-------------------------------------------------------------------------
' ### <<<< [ClassL] Class : Event caller >>>> 
'-------------------------------------------------------------------------

Class ClassL
	Public  OnEventX  '// as EventRespondersClass

	Private Sub  Class_Initialize()
		Set Me.OnEventX = new EventRespondersClass
	End Sub

	Public Sub  TriggerEventX()
		echo  "TriggerEventX"
		Me.OnEventX.Calls  Me, Empty
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


 
