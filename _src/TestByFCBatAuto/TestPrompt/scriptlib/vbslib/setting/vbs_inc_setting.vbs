Option Explicit 

Function  Setting_getIncludePathes( IncludeType )
    ReDim  pathes(2)
           pathes(0) = "vbslib.vbs"
           pathes(1) = "TestScript.vbs"
           pathes(2) = "TestPrompt.vbs"
  Setting_getIncludePathes = pathes
End Function
 
