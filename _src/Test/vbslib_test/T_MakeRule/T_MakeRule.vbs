Sub  Main( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_MakeRule0",_
			"2","T_MakeRule1",_
			"3","T_MakeRule2A",_
			"4","T_MakeRule2B",_
			"5","T_MakeRule2C",_
			"6","T_MakeRule3A",_
			"7","T_MakeRule3B",_
			"8","T_MakeRule4",_
			"9","T_MakeRuleImplicit1" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_MakeRule0] >>> 
'*************************************************************************
Sub  T_MakeRule0( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.AddRule  new_T0_File1_txt_Rule()
	mk.Make
	del  "Work0\File1_only.txt"
	mk.Make
	mk.Make
	Pass
End Sub


Function  new_T0_File1_txt_Rule()
	Set new_T0_File1_txt_Rule = new MakeRule : With new_T0_File1_txt_Rule
		.Target = "Work0\File1_only.txt"
		.Sources = Array()
		Set .Command = GetRef("File1_only_txt_Command")
	End With
End Function
Sub  File1_only_txt_Command( Param, Rule )
	CreateFile  Rule.Target, ""
End Sub


 
'*************************************************************************
'  <<< [T_MakeRule1] >>> 
'*************************************************************************
Sub  T_MakeRule1( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.AddRule  new_File1_txt_Rule()
	mk.AddRule  new_File2_txt_Rule()
	mk.Make
	Pass
End Sub


Function  new_File1_txt_Rule()
	Set new_File1_txt_Rule = new MakeRule : With new_File1_txt_Rule
		.Target = "Files1\File1_old.txt"
		.Sources = Array( "Files1\File11_old.txt", "Files1\File12_new.txt" )
		Set .Command = GetRef("File1_txt_Command")
	End With
End Function
Sub  File1_txt_Command( Param, Rule )
	echo  Rule.Target
End Sub


Function  new_File2_txt_Rule()
	Set new_File2_txt_Rule = new MakeRule : With new_File2_txt_Rule
		.Target = "Files1\File2_new.txt"
		.Sources = Array( "Files1\File21_old.txt", "Files1\File22_new.txt" )
		Set .Command = GetRef("File2_txt_Command")
	End With
End Function
Sub  File2_txt_Command( Param, Rule )
	echo  Rule.Target
End Sub


 
'*************************************************************************
'  <<< [T_MakeRule2A] >>> 
'  <<< [T_MakeRule2B] >>>
'  <<< [T_MakeRule2C] >>>
'*************************************************************************
Sub  T_MakeRule2A( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.AddRule  new_T2_File1_txt_Rule()
	mk.AddRule  new_T2_File11_txt_Rule()
	mk.Make
	Pass
End Sub

Sub  T_MakeRule2B( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.AddRule  new_T2_File11_txt_Rule()
	mk.AddRule  new_T2_File1_txt_Rule()
	mk.Make
	Pass
End Sub

Sub  T_MakeRule2C( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.AddRule  new_T2_File11_txt_Rule()
	mk.AddRule  new_T2_File1_txt_Rule()
	mk.AddRule  new_T2_File2_txt_Rule()
	mk.Make
	Pass
End Sub


Function  new_T2_File2_txt_Rule()
	Set new_T2_File2_txt_Rule = new MakeRule : With new_T2_File2_txt_Rule
		.Target  =        "Files2\File2_nothing.txt"
		.Sources = Array( "Files2\File1_old.txt" )
		Set .Command = GetRef("Echo_Command")
	End With
End Function


Function  new_T2_File1_txt_Rule()
	Set new_T2_File1_txt_Rule = new MakeRule : With new_T2_File1_txt_Rule
		.Target  =        "Files2\File1_old.txt"
		.Sources = Array( "Files2\File11_old.txt" )
		Set .Command = GetRef("Echo_Command")
	End With
End Function


Function  new_T2_File11_txt_Rule()
	Set new_T2_File11_txt_Rule = new MakeRule : With new_T2_File11_txt_Rule
		.Target  =        "Files2\File11_old.txt"
		.Sources = Array( "Files2\File111_new.txt" )
		Set .Command = GetRef("Echo_Command")
	End With
End Function


 
'*************************************************************************
'  <<< [T_MakeRule3A] >>> 
'  <<< [T_MakeRule3B] >>>
'*************************************************************************
Sub  T_MakeRule3A( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.AddRule  new_T3_File1_txt_Rule()
	mk.Make
	Pass
End Sub


Sub  T_MakeRule3B( Opt, AppKey )
	copy  "Files3\*", "Files3_Work"

	Set mk = new MakeFileClass
	mk.AddRule  new_T3_File2_txt_Rule()
	mk.AddRule  new_T3_File21_txt_Rule()
	mk.AddRule  new_T3_File22_txt_Rule()
	mk.AddRule  new_T3_File23_txt_Rule()
	mk.Make

	del  "Files3_Work"
	Pass
End Sub


Function  new_T3_File1_txt_Rule()
	Set new_T3_File1_txt_Rule = new MakeRule : With new_T3_File1_txt_Rule
		.Target = "Files3\File1_old.txt"
		.Sources = Array( "Files3\File11_old.txt", "Files3\File12_new.txt",_
											"Files3\File13_newest.txt", "Files3\File0_no.txt" )
		Set .Command = GetRef("EchoNew_Command")
	End With
End Function


Function  new_T3_File2_txt_Rule()
	Set new_T3_File2_txt_Rule = new MakeRule : With new_T3_File2_txt_Rule
		.Target = "Files3_Work\File2_old.txt"
		.Sources = Array( "Files3_Work\File21_old.txt", "Files3_Work\File22_old.txt", "Files3_Work\File23_old.txt" )
		Set .Command = GetRef("EchoNew_Command")
	End With
End Function

Function  new_T3_File21_txt_Rule()
	Set new_T3_File21_txt_Rule = new MakeRule : With new_T3_File21_txt_Rule
		.Target = "Files3_Work\File21_old.txt"
		.Sources = Array( "Files3_Work\File211_old.txt" )
		Set .Command = GetRef("Copy_Command")
	End With
End Function

Function  new_T3_File22_txt_Rule()
	Set new_T3_File22_txt_Rule = new MakeRule : With new_T3_File22_txt_Rule
		.Target = "Files3_Work\File22_old.txt"
		.Sources = Array( "Files3_Work\File221_new.txt" )
		Set .Command = GetRef("Copy_Command")
	End With
End Function

Function  new_T3_File23_txt_Rule()
	Set new_T3_File23_txt_Rule = new MakeRule : With new_T3_File23_txt_Rule
		.Target = "Files3_Work\File23_old.txt"
		.Sources = Array( "Files3_Work\File231_newest.txt" )
		Set .Command = GetRef("Copy_Command")
	End With
End Function


 
'*************************************************************************
'  <<< [T_MakeRule4] >>> 
'*************************************************************************
Sub  T_MakeRule4( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.AddRule  new_T4_File1_txt_Rule_A()
	mk.AddRule  new_T4_File1_txt_Rule_B()
	mk.AddRule  new_T4_File2_txt_Rule_A()
	mk.AddRule  Array( new_T4_File2_txt_Rule_B(),  new_T4_File21_txt_Rule() )
	mk.Make
	Pass
End Sub


Function  new_T4_File1_txt_Rule_A()
	Set o = new MakeRule
		o.Target = "Files4\File1_old.txt"
		o.Sources = Array( "Files4\File11_new.txt" )
		o.Priority = 1
		Set o.Command = GetRef("Echo_Command")
	Set new_T4_File1_txt_Rule_A = o
End Function


Function  new_T4_File1_txt_Rule_B()
	Set o = new MakeRule
		o.Target = "Files4\File1_old.txt"
		o.Sources = Array( "Files4\File12_new.txt" )
		o.Priority = 2
		Set o.Command = GetRef("Echo_Command")
	Set new_T4_File1_txt_Rule_B = o
End Function


Function  new_T4_File2_txt_Rule_A()
	Set o = new MakeRule
		o.Target = "Files4\File2_old.txt"
		o.Sources = Array( "Files4\File21_old.txt" )
		o.Priority = 2
		Set o.Command = GetRef("Echo_Command")
	Set new_T4_File2_txt_Rule_A = o
End Function


Function  new_T4_File2_txt_Rule_B()
	Set o = new MakeRule
		o.Target = "Files4\File2_old.txt"
		o.Sources = Array( "Files4\File22_new.txt" )
		o.Priority = 1
		Set o.Command = GetRef("Echo_Command")
	Set new_T4_File2_txt_Rule_B = o
End Function


Function  new_T4_File21_txt_Rule()
	Set o = new MakeRule
		o.Target = "Files4\File21_old.txt"
		o.Sources = Array( "Files4\File211_new.txt" )
		Set o.Command = GetRef("Echo_Command")
	Set new_T4_File21_txt_Rule = o
End Function


 
'*************************************************************************
'  <<< [T_MakeRuleImplicit1] >>> 
'*************************************************************************
Sub  T_MakeRuleImplicit1( Opt, AppKey )
	Set mk = new MakeFileClass
	mk.Variables("${TargetFolder}") = "Files5\Target"
	mk.Variables("${SourceFolder}") = "Files5\Source"
	mk.AddRule  new_TI1_c_Rule()
	mk.AddRule  new_TI1_cpp_Rule()
	mk.Make

	echo_line

	Set ds = new CurDirStack
	pushd "Files5"
	mk.Variables("${TargetFolder}") = "Target\sub"
	mk.Variables("${SourceFolder}") = "Source\sub"
	mk.Make
	popd

	Pass
End Sub


Function  new_TI1_c_Rule()
	Set o = new MakeRule
		o.Target = "${TargetFolder}\*.obj"
		o.Sources = Array( "${SourceFolder}\*.c" )
		Set o.Command = GetRef("Echo_Command")
	Set new_TI1_c_Rule = o
End Function


Function  new_TI1_cpp_Rule()
	Set o = new MakeRule
		o.Target = "${TargetFolder}\*.obj"
		o.Sources = Array( "${SourceFolder}\*.cpp" )
		Set o.Command = GetRef("Echo_Command")
	Set new_TI1_cpp_Rule = o
End Function


 
'*************************************************************************
'  <<< [Echo_Command] >>> 
'*************************************************************************
Sub  Echo_Command( Param, Rule )
	echo  Rule.Target +", priority="& Rule.Priority &", sources="& _
		new_ArrayClass( Rule.Sources ).CSV
End Sub


 
'*************************************************************************
'  <<< [Copy_Command] >>> 
'*************************************************************************
Sub  Copy_Command( Param, Rule )
	copy_ren  Rule.Sources( 0 ), Rule.Target
End Sub


 
'*************************************************************************
'  <<< [EchoNew_Command] >>> 
'*************************************************************************
Sub  EchoNew_Command( Param, Rule )
	Dim  path

	echo  "newest>"
	echo  Rule.NewestSource

	echo  "allnew>"
	echo  Rule.AllNewSource

	echo  "compare1>"
	For Each path  In Rule.Sources
		echo  path +" = "& MakeRule_compare( Rule.Target, path )
	Next
End Sub


 







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
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
