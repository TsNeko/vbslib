Class  SampleClass
	Public  m_Name  ' as string
	Public  m_Value ' as integer

	Property Get  xml() : xml = "<"+ TypeName( Me ) +" name='"+ XmlAttr( m_Name ) + _
		 "' value='"& m_Value &"'/>"
	End Property
	Public Sub  loadXML( XmlObject )
		m_Name  = XmlObject.getAttribute( "name" )
		m_Value = CInt2( XmlObject.getAttribute( "value" ) )
	End Sub
End Class

Function  new_SampleClass()
	Set new_SampleClass = new SampleClass
End Function


 
