Option Explicit 

Dim  g_SrcPath

Class  ClassC_vbs : Public FullPath : End Class
Dim  g_ClassC_vbs
Set  g_ClassC_vbs =_
   new ClassC_vbs
With g_ClassC_vbs
  .FullPath = g_SrcPath
End With



Sub  get_StaticObjects( InterfaceName, out_Obj )
  If IsEmpty( InterfaceName ) or  InterfaceName = "ClassI" Then
    Set  out_Obj = get_ClassC()
  End If
End Sub


'-------------------------------------------------------------------------
' ### <<<< [ClassC] Class >>>>
'-------------------------------------------------------------------------
Dim  g_ClassC

Function    get_ClassC()  '// has_interface_of ClassI
  If IsEmpty( g_ClassC ) Then _
    Set g_ClassC = new ClassC
  Set get_ClassC =   g_ClassC
End Function


Class ClassC  '// has_interface_of ClassI
  Public  Property Get  Name()     : Name     = TypeName(Me) : End Property
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  Public Sub  Validate() : End Sub
  '--- Name is factory pattern.

  Public Property Get  DefineInfo() : Set DefineInfo = g_ClassC_vbs : End Property

  Public  Value
  Public Function  Method1() : Method1 = "ClassC.Method1" : End Function
End Class


 
