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


out = "TestForA_ans.txt"
is_unicode = False
If g_fs.FileExists( out ) Then  g_fs.DeleteFile  out
Set file = g_fs.CreateTextFile( out, True, is_unicode )

file.WriteLine  ">SetWritableMode  F_ErrIfWarn"
file.WriteLine  "--------------------------------------------------------"
file.WriteLine  "Test Prompt [ALL]"
file.WriteLine  "   test vbs = T_TestScNameSub\TestForA.vbs"
file.WriteLine  "   base folder = "+ base +""
file.WriteLine  "1. テスト内容を選ぶ (current test = ALL)"
file.WriteLine  "2. テストを開始する（3～7を実行する）"
file.WriteLine  "3. | サブ・フォルダーを含めて、Test_build 関数を呼び出す"
file.WriteLine  "4. | サブ・フォルダーを含めて、Test_setup 関数を呼び出す"
file.WriteLine  "5. | サブ・フォルダーを含めて、Test_start 関数を呼び出す"
file.WriteLine  "6. | サブ・フォルダーを含めて、Test_check 関数を呼び出す"
file.WriteLine  "7. | サブ・フォルダーを含めて、Test_clean 関数を呼び出す"
file.WriteLine  "8. デバッグ・モードを変更する (debug script=False, target=False)"
file.WriteLine  "88.Fail したフォルダーを開く"
file.WriteLine  "89.次に Fail したフォルダーを開く"
file.WriteLine  "9. 終了"
file.WriteLine  "Select number>1"
file.WriteLine  "--------------------------------------------------------"
file.WriteLine  "Test symbol list:"
file.WriteLine  "  0) ALL (default)"
file.WriteLine  "  1) T_TestScName"
file.WriteLine  "  2) T_TestScNameSub"
file.WriteLine  "Input test number or symbol or ""ALL"" or ""order"">"
file.WriteLine  "--------------------------------------------------------"
file.WriteLine  "Test Prompt [ALL]"
file.WriteLine  "   base folder = "+ base +""
file.WriteLine  "1. テスト内容を選ぶ (current test = ALL)"
file.WriteLine  "2. テストを開始する（3～7を実行する）"
file.WriteLine  "3. | サブ・フォルダーを含めて、Test_build 関数を呼び出す"
file.WriteLine  "4. | サブ・フォルダーを含めて、Test_setup 関数を呼び出す"
file.WriteLine  "5. | サブ・フォルダーを含めて、Test_start 関数を呼び出す"
file.WriteLine  "6. | サブ・フォルダーを含めて、Test_check 関数を呼び出す"
file.WriteLine  "7. | サブ・フォルダーを含めて、Test_clean 関数を呼び出す"
file.WriteLine  "8. デバッグ・モードを変更する (debug script=False, target=False)"
file.WriteLine  "88.Fail したフォルダーを開く"
file.WriteLine  "89.次に Fail したフォルダーを開く"
file.WriteLine  "9. 終了"
file.WriteLine  "Select number>9"
file.WriteLine  "--------------------------------------------------------"
file = Empty


WScript.Echo  "Done."
WScript.Quit  21
