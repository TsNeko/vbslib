Option Explicit 

Dim  g_SrcPath

Class  ClassB_vbs : Public FullPath : End Class
Dim  g_ClassB_vbs
Set  g_ClassB_vbs =_
   new ClassB_vbs
With g_ClassB_vbs
  .FullPath = g_SrcPath
End With



Sub  get_StaticObjects( InterfaceName, out_Obj )
  If IsEmpty( InterfaceName ) or  InterfaceName = "ClassI" Then
    Set  out_Obj = get_ClassB()
  End If
End Sub


'-------------------------------------------------------------------------
' ### <<<< [ClassB] Class >>>>
'-------------------------------------------------------------------------
Dim  g_ClassB

Function    get_ClassB()  '// has_interface_of ClassI
  If IsEmpty( g_ClassB ) Then _
    Set g_ClassB = new ClassB
  Set get_ClassB =   g_ClassB
End Function


Class ClassB  '// has_interface_of ClassI
  Public  Property Get  Name()     : Name     = TypeName(Me) : End Property
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  Public Sub  Validate( Flags ) : End Sub
  '--- Name is factory pattern.

  Public Property Get  DefineInfo() : Set DefineInfo = g_ClassB_vbs : End Property
  Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

  Public  Value
  Public Function  Method1() : Method1 = "ClassB.Method1" : End Function
End Class


 
