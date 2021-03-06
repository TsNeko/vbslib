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


out = "T_CompileDebug1_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "下記のファイルを include したときにエラーが発生しました。"
file.WriteLine  """"+ base +"\scriptlib\vbslib\Duplicate2.vbs"""
file.WriteLine  "構文エラーではないときは、g_debug を設定している場所のすぐ下に、次のように記述すると、エラーが発生した場所が分かります。"
file.WriteLine  " g_is_compile_debug = 1"
file.WriteLine  ""
file.WriteLine  ""
file.WriteLine  "デバッガーを動かすときは、メイン・スクリプトの最後の g_debug を 1 に修正して再起動してください"
file.WriteLine  "<ERROR err_number='1041' err_description='名前が二重に定義されています。'/>"
file.WriteLine  base +"\T_CompileDebug1.vbs(0, 1) Microsoft VBScript 実行時エラー: 名前が二重に定義されています。"
file.WriteLine  ""
file = Empty


out = "T_CompileDebug2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "下記のファイルを include したときにエラーが発生しました。"
file.WriteLine  """"+ base +"\T_CompileDebug2_sub.vbs"""
file.WriteLine  "構文エラーではないときは、g_debug を設定している場所のすぐ下に、次のように記述すると、エラーが発生した場所が分かります。"
file.WriteLine  " g_is_compile_debug = 1"
file.WriteLine  ""
file.WriteLine  ""
file.WriteLine  "デバッガーを動かすときは、メイン・スクリプトの最後の g_debug を 1 に修正して再起動してください"
file.WriteLine  "<ERROR err_number='1041' err_description='名前が二重に定義されています。'/>"
file = Empty


out = "T_CompileDebug1_step2_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  "%MultiLine%"
file.WriteLine  "デバッガーを動かすときは、メイン・スクリプトの最後の g_debug を 1 に修正して再起動してください"
file.WriteLine  "<ERROR err_number='1041' err_description='名前が二重に定義されています。'/>"
file.WriteLine  ""+ base +"\T_CompileDebug1_step2.vbs(0, 1) Microsoft VBScript 実行時エラー: 名前が二重に定義されています。"
file.WriteLine  ""
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
