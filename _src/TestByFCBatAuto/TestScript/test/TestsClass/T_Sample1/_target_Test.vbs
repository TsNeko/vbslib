Option Explicit 


Sub  Test_current( p )
  Dim fs,f,cur

  Set fs = WScript.CreateObject( "Scripting.FileSystemObject" )
  Set f = fs.OpenTextFile( "SubSymbol.txt" )
  cur = Trim( f.ReadLine )
  p.SetCur  cur
  If p.CurrentTestPriority <> 900 Then
    echo "Current = " & cur
  End If
  p.CurrentTestPriority = 900
End Sub


Sub  Test_build( p )
  If p.IsCur("Sub1") Then  echo p.Symbol+" - Test_build Sub1"
  If p.IsCur("Sub2") Then  echo p.Symbol+" - Test_build Sub2"
  Pass
End Sub


Sub  Test_setup( p )
  If p.IsCur("Sub1") Then  echo p.Symbol+" - Test_setup Sub1"
  If p.IsCur("Sub2") Then  echo p.Symbol+" - Test_setup Sub2"
  Pass
End Sub


Sub  Test_start( p )
  If p.IsCur("Sub1") Then  echo p.Symbol+" - Test_start Sub1"
  If p.IsCur("Sub2") Then  echo p.Symbol+" - Test_start Sub2"
Stop
  ' Pass  '... no result
End Sub


Sub  Test_check( p )
  If p.IsCur("Sub1") Then  echo p.Symbol+" - Test_check Sub1"
  If p.IsCur("Sub2") Then  echo p.Symbol+" - Test_check Sub2"
  Pass
End Sub


Sub  Test_clean( p )
  If p.IsCur("Sub1") Then  echo p.Symbol+" - Test_clean Sub1"
  If p.IsCur("Sub2") Then  echo p.Symbol+" - Test_clean Sub2"
  Pass
End Sub


 
