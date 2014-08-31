Option Explicit 

Dim  g_SrcPath

Class  ClassD_vbs : Public FullPath : End Class
Dim  g_ClassD_vbs
Set  g_ClassD_vbs =_
   new ClassD_vbs
With g_ClassD_vbs
  .FullPath = g_SrcPath
End With



Sub  get_StaticObjects( InterfaceName, out_Obj )
  If IsEmpty( InterfaceName ) or  InterfaceName = "ClassI" Then
    Set  out_Obj = get_ClassD()
  End If
End Sub


'-------------------------------------------------------------------------
' ### <<<< [ClassD] Class >>>>
'-------------------------------------------------------------------------
Dim  g_ClassD

Function    get_ClassD()  '// has_interface_of ClassI
  If IsEmpty( g_ClassD ) Then _
    Set g_ClassD = new ClassD
  Set get_ClassD =   g_ClassD
End Function


Class ClassD  '// has_interface_of ClassI
  Public  Property Get  Name()     : Name     = TypeName(Me) : End Property
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  Public Sub  Validate() : End Sub
  '--- Name is factory pattern.

  Public Property Get  DefineInfo() : Set DefineInfo = g_ClassD_vbs : End Property

  Public  Value
  Public Function  Method1() : Method1 = "ClassD.Method1" : End Function
End Class


 
