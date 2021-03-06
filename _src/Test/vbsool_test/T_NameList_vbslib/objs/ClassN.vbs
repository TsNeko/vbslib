Option Explicit 

Dim  g_SrcPath

Class  ClassN_vbs : Public FullPath : End Class
Dim  g_ClassN_vbs
Set  g_ClassN_vbs =_
   new ClassN_vbs
With g_ClassN_vbs
  .FullPath = g_SrcPath
End With


Sub  get_StaticObjects( InterfaceName, out_Obj )
  If IsEmpty( InterfaceName ) or  InterfaceName = "ClassI" Then
    Set  out_Obj = get_ClassN()
  End If
End Sub


'-------------------------------------------------------------------------
' ### <<<< [ClassN] Class >>>>
'-------------------------------------------------------------------------
Function    get_ClassN()  '// has_interface_of ClassI
  Set get_ClassN = get_NameDelegator( "ClassN", ClassN_getTrueName(), "ClassI" )
End Function

Function  ClassN_getTrueName()
  Dim  ret
  ret = GetVar( "ClassN" )
  If IsEmpty( ret ) Then
    '// default is ClassA fixed
    ret = "ClassA" : SetVar "ClassN", ret
  End If
  ClassN_getTrueName = ret
End Function


 
