Option Explicit 

Const  g_ArrayCount = 100000


Sub  Main( Opt, AppKey )
	Dim  t0, t1, arr

	echo  "g_ArrayCount = " & g_ArrayCount

	t0 = Timer
	ArrayOut  arr  '//[out] arr
	t1 = Timer - t0
	echo  "ArrayOut : " & FormatNumber( t1, 3 ) & "(sec)"

	t0 = Timer
	arr = ArrayReturn()
	t1 = Timer - t0
	echo  "ArrayReturn : " & FormatNumber( t1, 3 ) & "(sec)"

	t0 = Timer
	arr = ArrayReturnPreReDim()
	t1 = Timer - t0
	echo  "ArrayReturnPreReDim : " & FormatNumber( t1, 3 ) & "(sec)"

	t0 = Timer
	Set arr = ArrayClassReturn()
	t1 = Timer - t0
	echo  "ArrayClassReturn : " & FormatNumber( t1, 3 ) & "(sec)"

	t0 = Timer
	Set arr = ArrayClassReturnPreReDim()
	t1 = Timer - t0
	echo  "ArrayClassReturnPreReDim : " & FormatNumber( t1, 3 ) & "(sec)"

	t0 = Timer
	Set arr = ArrayClassArrayReturn()
	t1 = Timer - t0
	echo  "ArrayClassArrayReturn : " & FormatNumber( t1, 3 ) & "(sec)"

	t0 = Timer
	Set arr = ArrayClassArrayReturnPreReDim()
	t1 = Timer - t0
	echo  "ArrayClassArrayReturnPreReDim : " & FormatNumber( t1, 3 ) & "(sec)"

End Sub


Sub  ArrayOut( out_Array )
	Dim  i, arr

	ReDim  out_Array(-1)
	For i=0 To g_ArrayCount
		ReDim Preserve  out_Array( UBound( out_Array ) + 1 )
		out_Array( UBound( out_Array ) ) = i
	Next
End Sub


Function  ArrayReturn()
	Dim  i, arr

	ReDim  arr(-1)
	For i=0 To g_ArrayCount
		ReDim Preserve  arr( UBound( arr ) + 1 )
		arr( UBound( arr ) ) = i
	Next
	ArrayReturn = arr
End Function


Function  ArrayReturnPreReDim()
	Dim  i, arr

	ReDim  arr( g_ArrayCount )
	For i=0 To g_ArrayCount
		arr( i ) = i
	Next
	ArrayReturnPreReDim = arr
End Function


Function  ArrayClassReturn()
	Dim  i, arr

	Set arr = new ArrayClass
	For i=0 To g_ArrayCount
		arr.Add  i
	Next
	Set ArrayClassReturn = arr
End Function


Function  ArrayClassReturnPreReDim()
	Dim  i, arr

	Set arr = new ArrayClass
	arr.ReDim_  g_ArrayCount
	For i=0 To g_ArrayCount
		arr(i) = i
	Next
	Set ArrayClassReturnPreReDim = arr
End Function


Function  ArrayClassArrayReturn()
	Dim  i, arr, arr_obj

	ReDim  arr(-1)
	For i=0 To g_ArrayCount
		ReDim Preserve  arr( UBound( arr ) + 1 )
		arr( UBound( arr ) ) = i
	Next

	Set arr_obj = new ArrayClass
	arr_obj.Items = arr
	Set ArrayClassArrayReturn = arr_obj
End Function


Function  ArrayClassArrayReturnPreReDim()
	Dim  i, arr, arr_obj

	ReDim  arr( g_ArrayCount )
	For i=0 To g_ArrayCount
		arr( i ) = i
	Next

	Set arr_obj = new ArrayClass
	arr_obj.Items = arr
	Set ArrayClassArrayReturnPreReDim = arr_obj
End Function


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib include is provided under 3-clause BSD license.
'// Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_Vers : If IsEmpty( g_Vers ) Then
Set  g_Vers = CreateObject("Scripting.Dictionary") : g_Vers("vbslib") = 99.99
Dim  g_debug, g_debug_params, g_admin, g_vbslib_path, g_CommandPrompt, g_fs, g_sh, g_AppKey
Dim  g_MainPath, g_SrcPath, g_f, g_include_path, g_i, g_debug_tree, g_debug_process, g_is_compile_debug
Dim  g_is64bitWSH
g_SrcPath = WScript.ScriptFullName : g_MainPath = g_SrcPath
SetupVbslibParameters
Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject("WScript.Shell") : g_f = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
For g_i = 20 To 1 Step -1 : If g_fs.FileExists(g_vbslib_path) Then  Exit For
g_vbslib_path = "..\" + g_vbslib_path  : Next
If g_fs.FileExists(g_vbslib_path) Then  g_vbslib_path = g_fs.GetAbsolutePathName( g_vbslib_path )
g_sh.CurrentDirectory = g_f
If g_i=0 Then WScript.Echo "Not found " + g_fs.GetFileName( g_vbslib_path ) +vbCR+vbLF+_
	"Let's download vbslib and Copy scriptlib folder." : Stop : WScript.Quit 1
Set g_f = g_fs.OpenTextFile( g_vbslib_path,,,-2 ): Execute g_f.ReadAll() : g_f = Empty
If ResumePush Then  On Error Resume Next
	CallMainFromVbsLib
ResumePop : On Error GoTo 0
End If
'---------------------------------------------------------------------------------

Sub  SetupDebugTools()
	set_input  ""
	SetBreakByFName  Empty
	SetStartSectionTree  ""
End Sub

Sub  SetupVbslibParameters()
	'--- start of parameters for vbslib include -------------------------------
	g_Vers("vbslib") = 99.99
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 2
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
