Option Explicit 

Function  Setting_getDiffCmdLine(i)
  Dim  ret, exe
  exe = "C:\Program Files\Diff\Diff.exe"
  If i = 0 Then  ret = exe
  If i = 2 Then  ret = """" + exe + """ ""%1"" ""%2"""
  If i = 3 Then  ret = """" + exe + """ ""%1"" ""%2"" ""%3"""
  Setting_getDiffCmdLine = ret
End Function
 
