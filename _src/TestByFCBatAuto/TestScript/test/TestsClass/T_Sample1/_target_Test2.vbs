Option Explicit 


Sub  Test_current( tests )
  tests.Symbol = "Test2"
  tests.CurrentTestPriority = 950
End Sub


Sub  Test_build( tests )
  echo  "Test_build in Test2"
  Pass
End Sub


Sub  Test_setup( tests ) : Pass : End Sub
Sub  Test_start( tests ) : Pass : End Sub
Sub  Test_check( tests ) : Pass : End Sub
Sub  Test_clean( tests ) : Pass : End Sub


 
