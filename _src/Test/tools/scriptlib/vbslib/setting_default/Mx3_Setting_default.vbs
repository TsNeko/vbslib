Option Explicit 


Sub  Setting_addRepository( Mxp, Symbol )
  Select Case  Symbol
    Case "Types" : Mxp.AddRepository  Symbol, Setting_getMixerLibFolder()+"\Types"
    Case "clib"  : Mxp.AddRepository  Symbol, Setting_getMixerLibFolder()+"\clib"
    Case Else : Mxp.RaiseRepSymbolError  Symbol
  End Select
End Sub


Function  Setting_getMixerLibFolder()
  echo_v  "Setting_getMixerLibFolder 関数を定義してください。"
  Sleep  300
  Err.Raise  E_TestPass
End Function


Sub  Mxp3_Setting( Mxp )
End Sub


 
