Option Explicit 

Function  Setting_getIncludePathes( IncludeType )
  If IncludeType = "DuplicateInVbsLibFolder" Then
    Setting_getIncludePathes = Array(_
      "sample_lib.vbs",_
      "Duplicate1.vbs",_
      "Duplicate2.vbs",_
    Empty )
  Else
    Setting_getIncludePathes = Array(_
      "sample_lib.vbs",_
      "Duplicate1.vbs",_
    Empty )
  End If
End Function

 
