Option Explicit 

' VBSTestTarget
' Copyright (c) 2008, T's-Neko
' All rights reserved. 3-clause BSD license.


Dim  g_VBSTestTarget


'Function  InitializeModule
'  Set  g_VBSTestTarget = New VBSTestTarget
'End Function
'Dim  g_InitializeModule
'Set  g_InitializeModule = GetRef( "InitializeModule" )

Const  Err_TestPass = 21
Const  Err_TestSkip = 22
Const  Err_TestFail = 23

Class AppKeyClass : Public Sub SetKey( x ) : End Sub : End Class

 
'********************************************************************************
'  <<< [EchoTestStart] >>> 
'********************************************************************************
Sub  EchoTestStart( TestSymbol )
  WScript.Echo  "((( ["+TestSymbol+"] )))"
End Sub


'********************************************************************************
'  <<< [Pass] >>>
'********************************************************************************
Sub Pass
  WScript.Quit  Err_TestPass
End Sub


'********************************************************************************
'  <<< [Fail] >>>
'********************************************************************************
Sub  Fail()
  WScript.Quit  Err_TestFail
End Sub


'********************************************************************************
'  <<< [Skip] >>>
'********************************************************************************
Public Sub  Skip()
  WScript.Quit  Err_TestSkip
End Sub

 
