Function  Setting_getEditorCmdLine(i) 
  Dim  ret

  If VarType( i ) = vbString Then
    ret = GetEditorCmdLine( i )
  ElseIf i = 0 Then
    ret = g_sh.ExpandEnvironmentStrings( "%WinDir%\notepad.exe" )
  End If
  Setting_getEditorCmdLine = ret
End Function

 
