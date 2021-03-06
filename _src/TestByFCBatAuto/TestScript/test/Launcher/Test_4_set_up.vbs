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


out = "T_LauncherSynErr_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ""
file.WriteLine  "WSH のデバッガーがインストールされていれば、スクリプト・ファイルへのショートカットを作成、プロパティ - リンク先に、下記の /g_debug オプションを追加、ショートカットから起動すると、問題がある場所で停止します。"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  """T_LauncherSynErr.vbs"" /g_debug:1"
file.WriteLine  "----------------------------------------------------------------------"
file.WriteLine  "<ERROR err_number='1' err_description='cscript でエラーが発生しました'/>"
file.WriteLine  ""+ base +"\TargetSynErr.vbs(2, 2) Microsoft VBScript コンパイル エラー: ステートメントがありません。"
file.WriteLine  ""
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
