Option Explicit 

' vbs_inc.vbs for Version Test

Sub  echo( Str )
  WScript.Echo  Str
End Sub

Function  ResumePush
End Function

Function  ResumePop
  WScript.Quit  21
End Function

Function  IsDefined( Symbol )
  Dim en

  On Error Resume Next
    Call GetRef( Symbol )
  en = Err.Number : On Error GoTo 0

  IsDefined = ( en <> 5 )
End Function
 
