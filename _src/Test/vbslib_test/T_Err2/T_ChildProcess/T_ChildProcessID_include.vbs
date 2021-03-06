Option Explicit 

'-------------------------------------------------------------------------
' ### <<<< [SampleLibClass] Class >>>>
'-------------------------------------------------------------------------
Class  SampleLibClass  '// has_interface_of InterProcessData
	Public  SampleCallID
	Public  SampleUserData

	Property Get  xml() : xml = "<"+ TypeName( Me ) +" call_id='"& Me.SampleCallID & _
		 "' user_data='"+ XmlAttr( Me.SampleUserData ) +"'/>"
	End Property

	Public Sub  loadXML( XmlObject )
		Me.SampleCallID = CInt2( XmlObject.getAttribute( "call_id" ) )
		Me.SampleUserData = XmlObject.getAttribute( "user_data" )
	End Sub

	Public Sub  OnCallInParent( a_ParentProcess )
		Me.SampleCallID   = g_InterProcess.ProcessCallID(0)
		Me.SampleUserData = g_InterProcess.InterProcessUserData
		a_ParentProcess.m_OutFile.WriteLine  Me.xml
	End Sub

	Public Sub  OnReturnInChild( a_ChildProcess )
		Me.SampleCallID   = g_InterProcess.ProcessCallID(0)
		Me.SampleUserData = g_InterProcess.InterProcessUserData
		a_ChildProcess.m_OutFile.WriteLine Me.xml
	End Sub

	Public Sub  OnReturnInParent( a_ParentProcess )
		loadXML  a_ParentProcess.m_InXML.selectSingleNode( TypeName(Me) )
		If Me.SampleCallID   <> g_InterProcess.ProcessCallID(0)   Then  Fail
		If Me.SampleUserData <> g_InterProcess.InterProcessUserData Then  Fail
	End Sub
End Class

Function  new_SampleLibClass()
	Set new_SampleLibClass = new SampleLibClass
End Function

 
'-------------------------------------------------------------------------
' ### <<<< [SampleClass] Class >>>> 
'-------------------------------------------------------------------------
Class  SampleClass  '// has_interface_of InterProcessData
	Public  SampleCallID
	Public  SampleUserData

	Property Get  xml() : xml = "<"+ TypeName( Me ) +" call_id='"& Me.SampleCallID &"' user_data='"& Me.SampleUserData &"'/>" : End Property
	Public Sub  loadXML( XmlObject )
		Me.SampleCallID = XmlObject.getAttribute( "call_id" )
		Me.SampleUserData = CInt2( XmlObject.getAttribute( "user_data" ) )
	End Sub
End Class

Function  new_SampleClass()
	Set new_SampleClass = new SampleClass
End Function


 
