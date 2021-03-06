'-------------------------------------------------------------------------
' ### <<<< [ClassN] Class >>>> 
'-------------------------------------------------------------------------
'// Class  ClassN  has_interface_of ClassI

Function  ClassN_getTrueName()
  Dim  ret : ret = GetVar( "ClassN" )
  If IsEmpty( ret ) Then
    If GetVar( "ClassN_getTrueName_delegate" ) Then
      ret = g_ClassN_getTrueName.CallFunction0() : SetVar "ClassN", ret
    Else
      ret = "ClassC" : SetVar "ClassN", ret
    End If
  End If
  ClassN_getTrueName = ret
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [ClassC] Class >>>> 
'-------------------------------------------------------------------------
'// Class  ClassC  has_interface_of ClassI

Dim  g_ClassC

Function    get_ClassC()
  If IsEmpty( g_ClassC ) Then _
    Set g_ClassC = new ClassC
  Set get_ClassC =   g_ClassC
      get_ClassC.Name="ClassC"
End Function


Class ClassC
  Public  Name
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  '--- Name is factory pattern.
  Private Sub  Class_Initialize() : Name = TypeName(Me) : End Sub

  Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

  Public  Value
  Public Function  Method1() : Method1 = "ClassC.Method1" : End Function
End Class


 
