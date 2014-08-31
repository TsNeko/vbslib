Option Explicit 

Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_MeltCmdLine",_
			"2","T_ArrayFromCmdLine",_
			"3","T_DicFromCmdLineOpt",_
			"4","T_ArrayFromBashCmdLine",_
			"5","T_ModifyCmdLineOpt",_
			"6","T_CmdLineFromStr",_
			"7","T_CommandLineOption" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_MeltCmdLine] >>> 
'********************************************************************************
Sub  T_MeltCmdLine( Opt, AppKey )
	Dim  i, s, line

	line = "abc def  ghi  "" jkl ""   ""mno"" p"
	i = 1

	s = MeltCmdLine( line, i )
	If s <> "abc" Then Fail
	If i <> 5 Then Fail

	s = MeltCmdLine( line, i )
	If s <> "def" Then Fail
	If i <> 10 Then Fail

	s = MeltCmdLine( line, i )
	If s <> "ghi" Then Fail
	If i <> 15 Then Fail

	s = MeltCmdLine( line, i )
	If s <> " jkl " Then Fail
	If i <> 25 Then Fail

	s = MeltCmdLine( line, i )
	If s <> "mno" Then Fail
	If i <> 31 Then Fail

	s = MeltCmdLine( line, i )
	If s <> "p" Then Fail
	If i <> 0 Then Fail

	Pass
End Sub

 
'********************************************************************************
'  <<< [T_ArrayFromCmdLine] >>> 
'********************************************************************************
Sub  T_ArrayFromCmdLine( Opt, AppKey )
	T_ArrayFromCmdLine_main _
		"Sample.exe ""file (1).txt"" /opt1:2", _
		Array( "Sample.exe", "file (1).txt", "/opt1:2" )

	T_ArrayFromCmdLine_main _
		"abc ""def ghi""  ""j k", _
		Array( "abc", "def ghi", "j k" )

	T_ArrayFromCmdLine_main _
		"  abc""def"" ab""c d""ef  ", _
		Array( "abcdef", "abc def" )

	T_ArrayFromCmdLine_main _
		"ab\""cd ""12\""34""", _
		Array( "ab""cd", "12""34" )

	T_ArrayFromCmdLine_main _
		"\\pc\n", _
		Array( "\\pc\n" )

	T_ArrayFromCmdLine_main _
		"\"" \\\"" \\\\\"" \\""a b"" \\\\""c d""", _
		Array( """", "\""", "\\""", "\a b", "\\c d" )

	T_ArrayFromCmdLine_main _
		"""\"" \\\"" \\\\\"" \\""a b"" \\\\""c d""", _
		Array( """ \"" \\"" \a", "b \\c", "d" )

	T_ArrayFromCmdLine_main _
		"\\Sample.exe\file.txt /opt1:""2""x ""x\""x"" x\\""x"" ""x\\\""x"" ""a", _
		Array( "\\Sample.exe\file.txt", "/opt1:2x", "x""x", "x\x", "x\""x", "a" )

	Pass
End Sub


Sub  T_ArrayFromCmdLine_main( CmdLine, AnsArray )
	Dim  i, arr

	echo  CmdLine
	arr = ArrayFromCmdLine( CmdLine )
	For i=0 To UBound( arr ) : echo i &") "& arr(i) : Next
	Assert  IsSameArray( arr, AnsArray )
End Sub


 
'********************************************************************************
'  <<< [T_DicFromCmdLineOpt] >>> 
'********************************************************************************
Sub  T_DicFromCmdLineOpt( Opt, AppKey )
	Dim  cmdline,  params


	'//=== Test main
	cmdline = _
		"Value0 -TouchTouchA -Space SpaceA -Equal=EqualA -Colon:ColonA -Multi=MultiA -Multi MultiB -Flag Value1 Value2"

	Set params = DicFromCmdLineOpt( cmdline,_
		Array( "-Touch", "-Space:", "-Equal", "-Colon", "-Multi::", "-Flag", "-NoFlag" ) )
	echo  params

	Assert  IsSameArray( params( "no name" ), Array( "Value0", "Value1", "Value2" ) )
	Assert  params( "-Touch" ) = "TouchA"
	Assert  params( "-Space:" ) = "SpaceA"
	Assert  params( "-Equal" ) = "EqualA"
	Assert  params( "-Colon" ) = "ColonA"
	Assert  params( "-Flag" ) = True
	Assert  params( "-Flag" )
	Assert  not params( "-NoFlag" )
	Assert  IsEmpty( params( "-NoFlag" ) )
	Assert  IsSameArray( params( "-Multi::" ), Array( "MultiA", "MultiB" ) )


	'//=== /option, --option
	cmdline = "/Slash --HifnHifn"

	Set params = DicFromCmdLineOpt( cmdline, Array( "/Slash", "--HifnHifn" ) )
	echo  params

	Assert  params( "/Slash" ) = True
	Assert  params( "--HifnHifn" ) = True

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_ArrayFromBashCmdLine] >>> 
'********************************************************************************
Sub  T_ArrayFromBashCmdLine( Opt, AppKey )
	T_ArrayFromBashCmdLine_main _
		"Sample.exe ""file (1).txt"" -b 1 --opt1=2", _
		Array( "Sample.exe", "file (1).txt", "-b", "1", "--opt1=2" )

	T_ArrayFromBashCmdLine_main  "Sample.exe ""\\ \\\""""",  Array( "Sample.exe", "\ \""" )

	Dim  i
	i = 1
	Assert  MeltBashCmdLine( """\\ \\\""""", i ) = "\ \"""

	Pass
End Sub


Sub  T_ArrayFromBashCmdLine_main( CmdLine, AnsArray )
	Dim  i, arr

	echo  CmdLine
	arr = ArrayFromBashCmdLine( CmdLine )
	For i=0 To UBound( arr ) : echo i &") "& arr(i) : Next
	Assert  IsSameArray( arr, AnsArray )
End Sub


 
'********************************************************************************
'  <<< [T_ModifyCmdLineOpt] >>> 
'********************************************************************************
Sub  T_ModifyCmdLineOpt( Opt, AppKey )
	Dim  new_cmdline

	'// add new option
	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2:ValueA Value1", "-Add", "-Add:Value" )
	Assert  new_cmdline ="-Add:Value -Opt1 -Opt2:ValueA Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2:ValueA Value1", "-Add:", "-Add Value" )
	Assert  new_cmdline ="-Add Value -Opt1 -Opt2:ValueA Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2:ValueA Value1", "-Add", "-AddValue" )
	Assert  new_cmdline = "-AddValue -Opt1 -Opt2:ValueA Value1"


	'// modify option
	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2:ValueA Value1", "-Opt1", "-Opt1" )
	Assert  new_cmdline =           "-Opt1 -Opt2:ValueA Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2:ValueA Value1", "-Opt2", "-Opt2:Modify" )
	Assert  new_cmdline =           "-Opt1 -Opt2:Modify Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2=ValueA Value1", "-Opt2", "-Opt2=Modify" )
	Assert  new_cmdline =           "-Opt1 -Opt2=Modify Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2 ValueA Value1", "-Opt2:", "-Opt2 Modify" )
	Assert  new_cmdline =           "-Opt1 -Opt2 Modify Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2ValueA Value1", "-Opt2", "-Opt2Modify" )
	Assert  new_cmdline =           "-Opt1 -Opt2Modify Value1"


	'// delete option
	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2:ValueA Value1", "-Opt1", Empty )
	Assert  new_cmdline =                 "-Opt2:ValueA Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2:ValueA Value1", "-Opt2", Empty )
	Assert  new_cmdline =           "-Opt1 Value1"

	new_cmdline = ModifyCmdLineOpt( "-Opt1 -Opt2 ValueA Value1", "-Opt2:", Empty )
	Assert  new_cmdline =           "-Opt1 Value1"


	'// multi value option
	new_cmdline = ModifyCmdLineOpt(    "-MultiValueA -MultiValueB Value1", "-Multi::", "-MultiValueC" )
	Assert  new_cmdline = "-MultiValueC -MultiValueA -MultiValueB Value1"

	new_cmdline = ModifyCmdLineOpt(     "-Multi ValueA -Multi ValueB Value1", "-Multi::", "-Multi ValueC" )
	Assert  new_cmdline = "-Multi ValueC -Multi ValueA -Multi ValueB Value1"

	new_cmdline = ModifyCmdLineOpt( "-MultiValueA -MultiValueB Value1", "-Multi::ValueB", "-MultiValueC" )
	Assert  new_cmdline =           "-MultiValueA -MultiValueC Value1"

	new_cmdline = ModifyCmdLineOpt( "-Multi ValueA -Multi ValueB Value1", "-Multi::ValueB", "-Multi ValueC" )
	Assert  new_cmdline =           "-Multi ValueA -Multi ValueC Value1"

	new_cmdline = ModifyCmdLineOpt( "-MultiValueA -MultiValueB Value1", "-Multi::ValueB", Empty )
	Assert  new_cmdline =           "-MultiValueA Value1"

	new_cmdline = ModifyCmdLineOpt( "-Multi ValueA -Multi ValueB Value1", "-Multi::ValueB", Empty )
	Assert  new_cmdline =           "-Multi ValueA Value1"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CmdLineFromStr] >>> 
'********************************************************************************
Sub  T_CmdLineFromStr( Opt, AppKey )
	Dim cmd

	cmd = CmdLineFromStr( Array( "findstr", "/C:""quot and space""", "*" ) )
	Assert  cmd = "findstr ""/C:\""quot and space\"""" *"

	cmd = CmdLineFromStr( "\""a \ \\z" )
	Assert  cmd =  """\\\""a \ \\z"""

	cmd = CmdLineFromStr( Array( "Program Files", "\<abc\>", "^" ) )
	Assert  cmd =  """Program Files"" ""\<abc\>"" ""^"""

	cmd = CmdLineFromStr( Array( "findstr", "a|b", "*" ) )
	Assert  cmd =  "findstr ""a|b"" *"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_CommandLineOption] >>> 
'********************************************************************************
Sub  T_CommandLineOption( Opt, AppKey )
	Assert  GetCommandLineOptionName( "/OptionA:12" ) = "OptionA"
	Assert  GetCommandLineOptionName( "/OptionB" ) = "OptionB"

	Assert  GetCommandLineOptionValue( "/OptionA:12" ) = "12"
	Assert  GetCommandLineOptionValue( "/OptionA:""C:\Program Files""" ) = "C:\Program Files"
	Assert  GetCommandLineOptionValue( "/OptionA" ) = ""
	Pass
End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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


 
