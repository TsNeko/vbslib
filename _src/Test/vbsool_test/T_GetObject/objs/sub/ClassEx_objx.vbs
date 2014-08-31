Option Explicit 

Dim  g_SrcPath

Class  ClassEx_vbs : Public FullPath : End Class
Dim  g_ClassEx_vbs
Set  g_ClassEx_vbs =_
   new ClassEx_vbs
With g_ClassEx_vbs
  .FullPath = g_SrcPath
End With



Sub  get_StaticObjects( InterfaceName, out_Obj )
  If IsEmpty( InterfaceName ) or  InterfaceName = "ClassI" Then
    Set  out_Obj = get_ClassEx()
  End If
End Sub


'-------------------------------------------------------------------------
' ### <<<< [ClassEx] Class >>>>
'-------------------------------------------------------------------------
Dim  g_ClassEx

Function    get_ClassEx()  '// has_interface_of ClassI
  If IsEmpty( g_ClassEx ) Then _
    Set g_ClassEx = new ClassEx
  Set get_ClassEx =   g_ClassEx
End Function


Class ClassEx  '// has_interface_of ClassI
  Public  Property Get  Name()     : Name     = TypeName(Me) : End Property
  Public  Property Get  TrueName() : TrueName = TypeName(Me) : End Property
  Public Sub  Validate() : End Sub
  '--- Name is factory pattern.

  Public Property Get  DefineInfo() : Set DefineInfo = g_ClassEx_vbs : End Property

  Public  Value
  Public Function  Method1() : Method1 = "ClassEx.Method1" : End Function
End Class


 
