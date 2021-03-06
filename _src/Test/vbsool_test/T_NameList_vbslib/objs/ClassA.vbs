Option Explicit 

Dim  g_SrcPath

Class  ClassA_vbs : Public FullPath : End Class
Dim  g_ClassA_vbs
Set  g_ClassA_vbs =_
   new ClassA_vbs
With g_ClassA_vbs
  .FullPath = g_SrcPath
End With


Sub  get_StaticObjects( InterfaceName, out_Obj )
  If IsEmpty( InterfaceName ) or  InterfaceName = "ClassI" Then
    Set  out_Obj = get_ClassA()
  End If
End Sub


'-------------------------------------------------------------------------
' ### <<<< [ClassA] Class >>>>
'-------------------------------------------------------------------------
Dim  g_ClassA

Function    get_ClassA()  '// has_interface_of ClassI
  If IsEmpty( g_ClassA ) Then _
    Set g_ClassA = new ClassA
  Set get_ClassA =   g_ClassA
End Function


Class ClassA  '// has_interface_of ClassI
  Public  Property Get  Name()     : Name     = TypeName(Me) : End Property
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  Public Sub  Validate( Flags ) : End Sub
  '--- Name is factory pattern.

  Public Property Get  DefineInfo() : Set DefineInfo = g_ClassA_vbs : End Property
  Public Property Get  xml() : xml = ClassI_getXML( Me ) : End Property

  Public  Value
  Public Function  Method1() : Method1 = "ClassA.Method1" : End Function
End Class


 
