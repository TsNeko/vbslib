Option Explicit 


Sub  Test_current( p )
End Sub


Sub  Test_build( p )
  echo p.Symbol+" - Test_build"
  Pass
End Sub


Sub  Test_setup( p )
  echo p.Symbol+" - Test_setup"
  Pass
End Sub


Sub  Test_start( p )
  echo p.Symbol+" - Test_start"
  ' Pass  '... no result
End Sub


Sub  Test_check( p )
  echo p.Symbol+" - Test_check"
  Fail
End Sub


Sub  Test_clean( p )
  echo p.Symbol+" - Test_clean"
  Skip
End Sub


 
