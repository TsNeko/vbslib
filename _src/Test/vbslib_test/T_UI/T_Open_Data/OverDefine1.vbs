Function  Setting_getEditorCmdLine(i) 
  Dim  ret, paths

  If VarType( i ) = vbString Then
    ret = GetEditorCmdLine( i )
  ElseIf i = 0 Then
    ret =   "C:\Program Files\sakura\sakura.exe"
  ElseIf i = 1 Then
    ret = """C:\Program Files\sakura\sakura.exe"" ""%1"""
  ElseIf i = 2 Then
    ret = """C:\Program Files\sakura\sakura.exe"" -Y=%L ""%1"""
  ElseIf i = 3 Then
    ret = """C:\Program Files\sakura\sakura.exe"" ""%1"""
  End If
  Setting_getEditorCmdLine = ret
End Function

 
