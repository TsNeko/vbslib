Option Explicit 

Dim  g_Vers

Function  Setting_getIncludePathes( IncludeType )
  ReDim  pathes(2)
         pathes(0) = "sample_lib.vbs"

  If not IsEmpty(g_Vers) Then  IncludeType = g_Vers.Item( "IncludeType" )

  If not IsEmpty( IncludeType ) Then
    If IncludeType = "ex" Then
       pathes(1) = "test\sample_lib_ex.vbs"
    ElseIf IncludeType = "T_SynErr" Then
       pathes(1) = "test\sample_lib_synerr.vbs"
    ElseIf IncludeType = "T_IncErr2" Then
       pathes(1) = "test\sample_lib_inc_err.vbs"
    ElseIf IncludeType = "T_Vbslib" Then
       pathes(1) = "test\vbslib.vbs"
    ElseIf IncludeType = "T_Finalize" Then
       pathes(1) = "test\T_Finalize_lib1.vbs"
       pathes(2) = "test\T_Finalize_lib2.vbs"
    ElseIf IncludeType = "T_Finalize2" Then
       pathes(1) = "test\T_Finalize_lib2.vbs"
       pathes(2) = "test\T_Finalize_lib1.vbs"
    End If
  End If

  Setting_getIncludePathes = pathes
End Function


 
