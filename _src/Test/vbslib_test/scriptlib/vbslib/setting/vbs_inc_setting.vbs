Option Explicit 

Function  Setting_getIncludePathes( IncludeType )
  Dim  arr : arr = Array(_
    "vbslib.vbs",_
    "TestScript.vbs",_
    "TestPrompt.vbs",_
    "System.vbs",_
    "VisualStudio.vbs",_
    "Network.vbs",_
    "ToolsLib.vbs",_
    "zip\zip.vbs",_
    "sudo\sudo_lib.vbs",_
  Empty )

  If IncludeType = "no,System.vbs" Then
    Dim  i
    For i = 0 To UBound( arr )
      If arr( i ) = "System.vbs" Then _
        arr( i ) = Empty
    Next
  End If

  Setting_getIncludePathes = arr
End Function


 
