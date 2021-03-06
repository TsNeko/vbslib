Option Explicit 

Class  SampleClass  '// has_interface_of InterProcessData
	Public  SampleName  ' as string
	Public  SampleValue ' as integer

	Property Get  xml() : xml = "<"+ TypeName( Me ) +" name='"+ XmlAttr( Me.SampleName ) + _
		 "' value='"& Me.SampleValue &"'/>"
	End Property
	Public Sub  loadXML( XmlObject )
		Me.SampleName = XmlObject.getAttribute( "name" )
		Me.SampleValue = CInt2( XmlObject.getAttribute( "value" ) )
	End Sub

	Public Sub  OnCallInParent( a_ParentProcess ) : a_ParentProcess.m_OutFile.WriteLine Me.xml : End Sub
	Public Sub  OnReturnInChild( a_ChildProcess ) :  a_ChildProcess.m_OutFile.WriteLine Me.xml : End Sub
	Public Sub  OnReturnInParent( a_ParentProcess )
		loadXML  a_ParentProcess.m_InXML.selectSingleNode( TypeName(Me)+"[@name='"+ Me.SampleName +"']" )
	End Sub
End Class

Function  new_SampleClass()
	Set new_SampleClass = new SampleClass
End Function

 
