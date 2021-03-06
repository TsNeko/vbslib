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
' ### <<<< [ClassN] Class >>>> 
'-------------------------------------------------------------------------
'// Class  ClassN  has_interface_of ClassI

Function    get_ClassN()
  Set get_ClassN = get_Object( ClassN_getTrueName() )
  get_ClassN.Name = "ClassN"
End Function

Function  ClassN_getTrueName()
  Dim  ret : ret = GetVar( "ClassN" )
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
      get_ClassA.Name="ClassA"
End Function


Class ClassA
  Public  Name
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  '--- Name is factory pattern.
  Private Sub  Class_Initialize() : Name = TypeName(Me) : End Sub

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
      get_ClassB.Name="ClassB"
End Function


Class ClassB
  Public  Name
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  '--- Name is factory pattern.
  Private Sub  Class_Initialize() : Name = TypeName(Me) : End Sub

  Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

  Public  Value
  Public Function  Method1() : Method1 = "ClassB.Method1" : End Function
End Class


 
