Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject( "WScript.Shell" )

If LCase( Right( WScript.FullName, 11 ) ) = "wscript.exe" Then
	CreateObject("WScript.Shell").Run _
		""""+g_sh.ExpandEnvironmentStrings( "%windir%" )+"\system32\cmd.exe"" /K "+_
		"cscript //nologo """+WScript.ScriptFullName+""""
	WScript.Quit  0
End If

base = g_fs.GetParentFolderName( WScript.ScriptFullName )
g_sh.CurrentDirectory = base
base = g_fs.GetParentFolderName( base )
base = g_fs.GetParentFolderName( base )
base = g_fs.GetParentFolderName( base )


out = "T_DupClass_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "下記のファイルを include したときにエラーが発生しました。"
file.WriteLine  """"+ base +"\vbs_inc\scriptlib\vbslib\sample_lib.vbs"""
file.WriteLine  "構文エラーではないときは、g_debug を設定している場所のすぐ下に、次のように記述すると、エラーが発生した場所が分かります。"
file.WriteLine  " g_is_compile_debug = 1"
file.WriteLine  ""
file.WriteLine  ""
file.WriteLine  "デバッガーを動かすときは、メイン・スクリプトの最後の g_debug を 1 に修正して再起動してください"
file.WriteLine  "<ERROR err_number='1041' err_description='名前が二重に定義されています。'/>"
file.WriteLine  base +"\vbs_inc\test\T_vbsinc\T_DupClass.vbs(0, 1) Microsoft VBScript 実行時エラー: 名前が二重に定義されています。"
file.WriteLine  ""
file = Empty


out = "T_IncErr2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ""+ base +"\vbs_inc\test\T_vbsinc\T_IncErr2.vbs(0, 1) Include path "+ base +"\vbs_inc\test\T_vbsinc\sample_lib_inc_err.vbs is not found. See "+ base +"\vbs_inc\vbslib\vbslib\setting\vbs_inc_setting.vbs: ファイルが見つかりません。"
file.WriteLine  ""
file = Empty


out = "T_SynErr_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "下記のファイルを include したときにエラーが発生しました。"
file.WriteLine  """"+ base +"\vbs_inc\scriptlib\vbslib\test\sample_lib_synerr.vbs"""
file.WriteLine  "構文エラーではないときは、g_debug を設定している場所のすぐ下に、次のように記述すると、エラーが発生した場所が分かります。"
file.WriteLine  " g_is_compile_debug = 1"
file.WriteLine  ""
file.WriteLine  ""
file.WriteLine  "デバッガーを動かすときは、メイン・スクリプトの最後の g_debug を 1 に修正して再起動してください"
file.WriteLine  "<ERROR err_number='1015' err_description='&apos;Function&apos; がありません。'/>"
file.WriteLine  ""+ base +"\vbs_inc\test\T_vbsinc\T_SynErr.vbs(0, 1) Microsoft VBScript 実行時エラー: 'Function' がありません。"
file.WriteLine  ""
file = Empty


out = "T_SynErr2\T_SynErr2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "下記のファイルを include したときにエラーが発生しました。"
file.WriteLine  """"+ base +"\vbs_inc\test\T_vbsinc\T_SynErr2\scriptlib\vbslib\setting\vbs_inc_setting.vbs"""
file.WriteLine  "構文エラーではないときは、g_debug を設定している場所のすぐ下に、次のように記述すると、エラーが発生した場所が分かります。"
file.WriteLine  " g_is_compile_debug = 1"
file.WriteLine  ""
file.WriteLine  ""+ base +"\vbs_inc\test\T_vbsinc\T_SynErr2\T_SynErr2.vbs(0, 1) Microsoft VBScript 実行時エラー: 'Function' がありません。"
file.WriteLine  ""
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
