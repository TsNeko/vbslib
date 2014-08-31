@echo FCコマンドが実行されます。それによって違いが見つからないこと。
@echo ^>..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt -cmd ChildProcess\ChildProcess.exe
@pause
@echo -----------------------------
..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt -cmd ChildProcess\ChildProcess.exe
@echo -----------------------------
@echo 今実行したときに標準出力と標準エラーはファイルにも出力されているはずです。
@echo ^>type Test4_stdouterr.txt
@echo ^>type Test4_stderr.txt
@pause
@echo -----------------------------
type Test4_stdouterr.txt
@echo -----------------------------
fc Test4_stdouterr.txt Test4_stdouterr_ans.txt
@if errorlevel 1  echo エラー：Test4_stdouterr.txt が期待した内容と違います。
pause
@echo -----------------------------
type Test4_stderr.txt
@echo -----------------------------
fc Test4_stderr.txt Test4_stderr_ans.txt
@if errorlevel 1  echo エラー：Test4_stderr.txt が期待した内容と違います。

@echo エラー出力がないときは、ファイルを出力しません。
@echo ^>..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt ^< Test4_stdin2.txt
@pause
@del  Test4_stdouterr.txt
@del  Test4_stderr.txt
@echo -----------------------------
..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt -cmd ..\..\safetee.exe
@echo -----------------------------
fc Test4_stdouterr.txt Test4_stdouterr_ans2.txt
@if errorlevel 1  echo エラー：Test4_stderr.txt が期待した内容と違います。
@if exist Test4_stderr.txt  echo エラー：Test4_stderr.txt が存在します。
@pause
del  Test4_stdouterr.txt
del  Test4_stderr.txt
 
