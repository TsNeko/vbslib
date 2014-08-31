@echo テスト用・子プロセス ChildProcess.exe の実行内容を確認してください。
@echo 標準出力と標準エラー出力に交互に出力しますが、1,2,...,12 と順番に表示されます。
@echo 8 を出力したら _fflush を呼び出しています。
@echo 4, 8, 12 を出力したら １秒待っています。
@echo ^>ChildProcess\ChildProcess.exe
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe
@echo -----------------------------
pause
