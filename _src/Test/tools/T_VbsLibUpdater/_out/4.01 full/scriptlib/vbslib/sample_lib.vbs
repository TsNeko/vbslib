Option Explicit 

Dim  g_SrcPath
Dim  g_SampleLib_Path
		 g_SampleLib_Path = g_SrcPath

Dim  g_SampleLib_param

Function  InitializeModule( ThisPath )
	g_SampleLib_param = 1
End Function
Dim g_InitializeModule: Set g_InitializeModule = GetRef( "InitializeModule" )

Function  FinalizeModule( ThisPath, Reason )
	g_SampleLib_param = -1
End Function
Dim g_FinalizeModule: Set g_FinalizeModule = GetRef( "FinalizeModule" )
Dim g_FinalizeLevel:      g_FinalizeLevel  = 100  ' If smaller, called early


Class AppKeyClass : Public Sub SetKey( x ) : End Sub : End Class


Function  SampleFunc
	SampleFunc = "SampleFunc"
End Function


Class  SampleClass
	Public  m_Member
	Private Sub Class_Initialize
		m_Member = "SampleClass"
	End Sub
End Class


Sub  echo( Message )
	WScript.Echo  Message
End Sub


Sub  Sleep( MiliSec )
	WScript.Sleep  MiliSec
End Sub

 
