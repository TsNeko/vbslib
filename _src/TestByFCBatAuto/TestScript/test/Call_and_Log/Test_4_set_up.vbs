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


out = "T_RunVBS_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ""+ base +"\T_RunVBS\Raise.vbs(24, 3) Microsoft VBScript 実行時エラー: 未知の実行時エラーです。"
file.WriteLine  ""
file.WriteLine  "Error in VBS Process (ErrorLevel=0, Expect=9) : "+ base +"\T_RunVBS\Raise.vbs"
file.WriteLine  ""+ base +"\T_RunVBS\RunErr.vbs(24, 3) Microsoft VBScript 実行時エラー: この変数は宣言されていません。: 's'"
file.WriteLine  ""
file.WriteLine  "Error in VBS Process (ErrorLevel=0, Expect=9) : "+ base +"\T_RunVBS\RunErr.vbs"
file.WriteLine  ""+ base +"\T_RunVBS\SynErr.vbs(2, 2) Microsoft VBScript コンパイル エラー: ステートメントがありません。"
file.WriteLine  ""
file.WriteLine  "Error in VBS Process (ErrorLevel=1, Expect=9) : "+ base +"\T_RunVBS\SynErr.vbs"
file.WriteLine  "入力エラー: スクリプト ファイル """+ base +"\T_RunVBS\NotFound.vbs"" が見つかりません。"
file.WriteLine  "Error in VBS Process (ErrorLevel=1, Expect=9) : "+ base +"\T_RunVBS\SynErr.vbs"
file.WriteLine  "Pass."
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
