 ((( sudo.exe Application )))

Call CreateProcess Win32 API with requireAdministrator.
sudo.exe waits for finish a child process in batch file.
IShellDispatch2::ShellExecute Verb="RunAs" is not waiting for.

This is free soft for Windows Vista/7.

If sudo.exe itself is not reliable, delete sudo.exe.


>echo test > C:\echo_out.txt
Access denied (fail)


>sudo.exe cmd /c "echo test > C:\echo_out.txt"
(success, if you accepted UAC prompt)


*WARNING*
Accept UAC prompt only after starting install or update by the reliable program.
Select "refuse" once, if UAC prompt was appeared SUDDENLY.



sudo.exe は、バッチファイルなどを『管理者として実行する』ときに使います。

もし、sudo.exe 自体が信頼できないなら、sudo.exe を削除してください。

*警告*
ユーザーアカウント制御(UAC)のウィンドウで許可していいのは、信頼のおける
プログラムからインストールやアップデートを開始した直後だけです。
ユーザーアカウント制御のウィンドウが突然、現れたら、一度は拒否しましょう。

------------------------------------------------------------------
T's-Neko    http://www.sage-p.com/

