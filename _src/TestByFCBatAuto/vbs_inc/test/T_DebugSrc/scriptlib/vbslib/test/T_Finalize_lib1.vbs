Option Explicit 

Function  InitializeModule( ThisPath )
  WScript.Echo "InitializeModule 1"
End Function
Dim g_InitializeModule: Set g_InitializeModule = GetRef( "InitializeModule" )


Function  FinalizeModule( ThisPath, Reason )
  WScript.Echo "FinalizeModule 1"
End Function
Dim g_FinalizeModule: Set g_FinalizeModule = GetRef( "FinalizeModule" )
Dim g_FinalizeLevel:      g_FinalizeLevel  = 100  ' If smaller, called early

 
