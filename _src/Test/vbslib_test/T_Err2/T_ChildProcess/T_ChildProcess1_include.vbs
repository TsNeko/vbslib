Option Explicit 

Class  SampleClass
	Public  Name    ' as string
	Public  Value   ' as integer
	Public  Value2  ' as string

	Property Get  xml() : xml = "<"+ TypeName( Me ) +" name='"+ XmlAttr( Me.Name ) + _
		 "' value='"& Me.Value &"' value2='"& Me.Value2 &"'/>"
	End Property
	Public Sub  loadXML( XmlObject )
		Me.Name   = XmlObject.getAttribute( "name" )
		Me.Value  = CInt2( XmlObject.getAttribute( "value" ) )
		Me.Value2 = XmlObject.getAttribute( "value2" )
	End Sub
End Class

Function  new_SampleClass()
	Set new_SampleClass = new SampleClass
End Function


 
