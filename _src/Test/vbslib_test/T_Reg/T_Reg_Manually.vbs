Dim g_g : Sub GetMainSetting( g ) : If not IsEmpty(g_g) Then Set g=g_g : Exit Sub
	Set g=CreateObject("Scripting.Dictionary") : Set g_g=g


	'[Setting]
	'==============================================================================
	g("TestRegPath_CURRENT_USER") = "HKEY_CURRENT_USER\Software\_Test"
	g("TestRegFileExt")           = "aqx"
	'==============================================================================
End Sub


Sub  Main( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_RegWriteRead",_
			"2","T_RegExport",_
			"3","T_FileAssocOpen",_
			"4","T_FileAssocVerb" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_RegWriteRead] >>> 
'********************************************************************************
Sub  T_RegWriteRead( Opt, AppKey )
	GetMainSetting  g
	base = g("TestRegPath_CURRENT_USER")

	g_Vers("CutPropertyM") = True


	RegDelete  base +"\"
	RegEnumValues  base, values : Assert  UBound( values ) = -1
	RegEnumKeys  base, keys, Empty : Assert  UBound( keys ) = -1


	RegWrite  base +"\Sample1", "Value1", "REG_SZ"
	Assert  RegRead( base +"\Sample1" ) = "Value1"

	RegWrite  base +"\Sample2", &h100, "REG_DWORD"
	Assert  RegRead( base +"\Sample2" ) = &h100


	RegEnumValues  base +"\", values
	Assert  UBound( values ) = 1
	Assert  values(0).Name  = "Sample1"
	Assert  values(0).Type_ = "REG_SZ"
	Assert  values(1).Name  = "Sample2"
	Assert  values(1).Type_ = "REG_DWORD"

	RegEnumValues  base, values
	Assert  UBound( values ) = 1
	Assert  values(0).Name  = "Sample1"
	Assert  values(0).Type_ = "REG_SZ"
	Assert  values(1).Name  = "Sample2"
	Assert  values(1).Type_ = "REG_DWORD"


	RegWrite  base +"\Sample1", Empty, Empty
	RegWrite  base +"\Sample2", Empty, Empty

	RegEnumValues  base, values
	Assert  UBound( values ) = -1

	RegEnumValues  base+"\NotFound", values
	Assert  UBound( values ) = -1

	RegEnumKeys  base, keys, Empty
	Assert  UBound( keys ) = -1


	RegWrite  base +"\Sample1", "Value1", Empty
	Assert  RegRead( base +"\Sample1" ) = "Value1"

	RegWrite  base +"\Sample1", &h100, Empty
	Assert  RegRead( base +"\Sample1" ) = &h100

	RegWrite  base +"\Sub\", "Value1", Empty
	Assert  RegRead( base +"\Sub\" ) = "Value1"
	Assert  IsEmpty( RegRead( base +"\Sub" ) )

	RegWrite  base +"\Sub\Sub2\Sample3", "Value1", Empty
	Assert  RegRead( base +"\Sub\Sub2\Sample3" ) = "Value1"

	RegWrite  base +"\Sub\Sub4\Sample5\", "Value5", Empty
	Assert  RegRead( base +"\Sub\Sub4\Sample5\" ) = "Value5"

	RegEnumKeys  base, keys, Empty
	Assert  UBound( keys ) = 0
	Assert  keys(0) = base +"\Sub"

	RegEnumKeys  base, keys, F_SubFolder
	Assert  UBound( keys ) = 3
	Assert  keys(0) = base +"\Sub"
	Assert  keys(1) = base +"\Sub\Sub2"
	Assert  keys(2) = base +"\Sub\Sub4"
	Assert  keys(3) = base +"\Sub\Sub4\Sample5"


	RegWrite  base +"\Sample1", Empty, Empty
	Assert  IsEmpty( RegRead( base +"\Sample1" ) )
	Assert  IsEmpty( RegRead( base +"\SampleNotFound" ) )

	RegDelete  base +"\"
	Assert  IsEmpty( RegRead( base +"\Sub\Sub2\Sample3" ) )
	Assert  IsEmpty( RegRead( base +"\" ) )

	RegDelete  base +"\"  '// キーがないとき

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_RegExport] >>> 
'********************************************************************************
Sub  T_RegExport( Opt, AppKey )
	GetMainSetting  g
	base = g("TestRegPath_CURRENT_USER")

	RegWrite  base +"\Sample", "Value1", "REG_SZ"
	If not RegExists( base +"\" ) Then  Fail
	If not RegExists( base +"\Sample" ) Then  Fail
	If     RegExists( base +"\Sample\" ) Then  Fail

	RegExport  base,     "Reg_out1.reg", Empty
	RegExport  base+"\", "Reg_out2.reg", Empty

	g_sh.RegDelete  base +"\"
	If RegExists( base +"\" ) Then  Fail

	If not fc( "Reg_out1.reg", "Reg_ans.reg" ) Then  Fail
	If not fc( "Reg_out2.reg", "Reg_ans.reg" ) Then  Fail
	del  "Reg_out1.reg"
	del  "Reg_out2.reg"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_FileAssocOpen] >>> 
'********************************************************************************
Sub  T_FileAssocOpen( Opt, AppKey )
	GetMainSetting  g
	Set c = get_FileAssocConsts()
	Set section = new SectionTree
	windows8_version = 6.2
	ext = g("TestRegFileExt")
'//SetStartSectionTree  "T_FileAssocOpen_OS_Exe"

	g_Vers("CutPropertyM") = True


	echo  ""
	echo  "このテストは、Windows XP, Windows 7, Windows 8 で実施してください。"
	echo  ""

	If section.Start( "T_FileAssocOpen_1" ) Then

	echo  "テストのために ."+ ext +" ファイルの関連付けに関するレジストリを変更します。"
	Pause
	echo_line


	RegDelete  c.FileExts +"\."+ ext +"\UserChoice\"

	echo  "0) T_FileAssocData."+ ext +" ファイルをダブルクリックしてください。"
	echo  "プログラムの選択をするウィンドウが開くことを確認してください。"
	echo  "開いたら、キャンセルしてください。"
	Pause
	echo_line


	'//===
	echo  "1) ."+ ext +" ファイルから T_FileAssocProg1.exe を起動する関連付けをインストールしました。"
	echo_line

	InstallRegistryFileOpen  "."+ ext, "T_FileAssocProg1.exe", True

	echo  "T_FileAssocData."+ ext +" ファイルをダブルクリックしてください。"
	echo  "T_FileAssocProg1.exe から起動していることを確認してください。"
	Pause
	echo_line


	'//===
	echo  "2) ."+ ext +" ファイルから T_FileAssocProg2.exe を起動する関連付けをインストールしますが、"+_
				"ダブルクリックしても T_FileAssocProg1.exe が起動するようにしました。"
	echo_line

	InstallRegistryFileOpen  ext, "T_FileAssocProg2.exe", False

	If GetOSVersion() >= windows8_version Then
		echo  "T_FileAssocData."+ ext +" ファイルを右クリックして [ プログラムから開く > "+_
			"既定のプログラムの選択 > すべての ."+ ext +" ファイルでこのアプリを使う ] のチェックを外し、"+ _
			"[ T_FileAssocProg2.exe ] を選んで、T_FileAssocProg2.exe から起動していることを確認してください。"
	Else
		echo  "T_FileAssocData."+ ext +" ファイルを右クリックして [ プログラムから開く > "+_
			"T_FileAssocProg2 ] を選んで、T_FileAssocProg2.exe から起動していることを確認してください。"
	End If
	echo  "T_FileAssocData."+ ext +" ファイルをダブルクリックして T_FileAssocProg1.exe "+_
				"から起動していることを確認してください。"
	Pause
	echo_line


	'//===
	echo  "3) ."+ ext +" ファイルから T_FileAssocProg2.exe を起動する関連付けをインストールしました。"
	echo_line

	InstallRegistryFileOpen  "."+ ext, "T_FileAssocProg2.exe", True

	echo  "T_FileAssocData."+ ext +" ファイルをダブルクリックしてください。"
	If GetOSVersion() >= windows8_version Then
		echo  "T_FileAssocProg1.exe か T_FileAssocProg2.exe を選ぶウィンドウが開くことを確認してください。"
	Else
		echo  "T_FileAssocProg2.exe から起動していることを確認してください。"
	End If
	Pause
	echo_line


	'//===
	echo  "4) ."+ ext +" ファイルに関連付けられている T_FileAssocProg2.exe アンインストールしました。"
	echo_line

	UninstallRegistryFileOpen  "."+ ext, "T_FileAssocProg2.exe"

	echo  "T_FileAssocData."+ ext +" ファイルをダブルクリックしてください。"
	If GetOSVersion() >= windows8_version Then
		echo  "T_FileAssocProg1.exe から起動していることを確認してください。"
	Else
		echo  "プログラムの選択をするウィンドウが開き、T_FileAssocProg1.exe が選べることを確認してください。"
		echo  "「選択したプログラムをいつも使う」チェックをはずしてから選んでください。"
	End If
	Pause
	echo_line


	'//===
	echo  "5) 次のテストの準備として、."+ ext +_
		" ファイルから T_FileAssocProg2.exe を起動する関連付けをインストールしました。"
	echo_line

	InstallRegistryFileOpen  "."+ ext, "T_FileAssocProg2.exe", True

	echo  "T_FileAssocData."+ ext +" ファイルをダブルクリックしてください。"
	If GetOSVersion() >= windows8_version Then
		echo  "T_FileAssocProg1.exe か T_FileAssocProg2.exe を選ぶウィンドウが開くことを確認してください。"
	Else
		echo  "T_FileAssocProg2.exe から起動していることを確認してください。"
	End If
	Pause
	echo_line


	'//===
	echo  "6) 関連付けられていない T_FileAssocProg1.exe アンインストールしました。"
	echo_line

	UninstallRegistryFileOpen  ext, "T_FileAssocProg1.exe"

	echo  "T_FileAssocData."+ ext +" ファイルをダブルクリックしてください。"
	echo  "T_FileAssocProg2.exe から起動していることを確認してください。"
	Pause
	echo_line


	'//===
	echo  "7) T_FileAssocProg2.exe アンインストールしました。"
	echo_line

	UninstallRegistryFileOpen  "."+ ext, "T_FileAssocProg2.exe"

	echo  "レジストリ・エディタ(regedit) を開いて、最新の情報に更新して、次のキーが無いことをチェックしてください。"
	echo  "HKEY_CLASSES_ROOT\.aqx\"
	echo  "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.aqx\"
	echo  "続きは、上記の確認をとってから行ってください。"
	echo  "T_FileAssocData."+ ext +" ファイルをダブルクリックしてください。"
	echo  "プログラムの選択をするウィンドウが開くことを確認してください。"

	Pause
	echo_line

	End If : section.End_


	'//=== Windows の実行ファイルと関連付けるケース

	If section.Start( "T_FileAssocOpen_OS_Exe" ) Then

		ext = "trans"
		prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
		command_line = GetCScriptGUI_CommandLine( "//nologo """+ prompt_vbs +_
			""" TranslateTest ""%1"" """"" )

		echo  "テストのために ."+ ext +" ファイルの関連付けに関するレジストリを変更します。"
		Pause


		'//===
		InstallRegistryFileOpenCommand  ext, "TranslateTest", command_line, True

		echo_line
		echo  "1) .trans ファイルの関連付けを設定しました。"
		echo_line
		echo  ".trans ファイルをダブルクリックして、「英訳のテストをします。」と表示されること。"
		Pause

		UninstallRegistryFileOpenCommand  ext, "TranslateTest"

		echo_line
		echo  "2) .trans ファイルの関連付けを解除しました。"
		echo_line

		echo  ".trans ファイルをダブルクリックして、"+_
			"プログラムの選択をするウィンドウが開くことを確認してください。"
		Pause


		'// Clean
		key = Input( ".trans ファイルに関連付けして終了しますか [Y/N]" )
		If key="y"  or  key="Y" Then
			InstallRegistryFileOpenCommand  "trans", "TranslateTest", command_line, True
		End If

	End If : section.End_

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_FileAssocVerb] >>> 
'********************************************************************************
Sub  T_FileAssocVerb( Opt, AppKey )
	GetMainSetting  g
	exe = GetFullPath( "T_FileAssocProg1.exe", Empty )
	ext = "reg"  '// debug: g("TestRegFileExt")
	is_set_open = False  '// debug: True

	g_Vers("CutPropertyM") = True

	echo  "テストのために ."+ ext +" ファイルの関連付けに関するレジストリを変更します。"
	Pause
	echo_line


	'//===
	echo  "1) T_FileAssocProg1.exe を起動する ."+ ext +" ファイルの右クリック・メニュー項目をインストールします。"
	Pause
	echo_line

	If is_set_open Then  InstallRegistryFileOpen  "."+ ext, "T_FileAssocProg2.exe", True
	prog_id = RegReadExtProgID( ext )
	Assert  prog_id = RegReadExtProgID( "."+ ext )

	InstallRegistryFileVerb  prog_id, "T_FileAssocVerb", "テスト(&T)", """"+ exe +""" ""%1"""

	echo  "T_FileAssocData."+ ext +" ファイルを右クリックして、「テスト(T)」を選択してください。"
	echo  "T_FileAssocProg1.exe から起動していることを確認してください。"
	Pause
	echo_line


	'//===
	echo  "2) ."+ ext +" ファイルの右クリック・メニュー項目をアンインストールします。"
	Pause
	echo_line

	UninstallRegistryFileVerb  prog_id, "T_FileAssocVerb"

	echo  "T_FileAssocData."+ ext +" ファイルを右クリックして、「テスト(T)」が無いことを確認してください。"
	Pause
	echo_line

	If is_set_open Then  UninstallRegistryFileOpen  "."+ ext, "T_FileAssocProg2.exe"


	'//===
	echo  "3) T_FileAssocProg1.exe を起動する全ファイルの右クリック・メニュー項目をインストールします。"
	Pause
	echo_line

	InstallRegistryFileVerb    "*", "T_FileAssocVerb", "テスト(&T)", """"+ exe +""" ""%1"""

	echo  "任意の2種類のファイルをそれぞれ右クリックして、「テスト(T)」を選択してください。"
	echo  "T_FileAssocProg1.exe から起動していることを確認してください。"
	Pause
	echo_line


	'//===
	echo  "4) 全ファイルの右クリック・メニュー項目をアンインストールします。"
	Pause
	echo_line

	UninstallRegistryFileVerb  "*", "T_FileAssocVerb"

	echo  "2種類のファイルをそれぞれ右クリックして、「テスト(T)」が無いことを確認してください。"
	Pause
	echo_line

	Pass
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


 
