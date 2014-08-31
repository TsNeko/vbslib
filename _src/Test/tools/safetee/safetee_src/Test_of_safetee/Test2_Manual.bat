@echo 1,2,..,12 という順番には表示されません。
@echo これは期待された動作ではありませんが、対策も見つかっていません。
@echo パイプがあるときは、パイプの前のプログラムが fflush するか終了するまで、出力が行われません。
@echo 標準出力と標準エラー出力が 2^>1 で標準出力にまとめられても、順番通りに出力されません。
@echo 次は、8 を出力したときに、２秒待ちます。
@echo ^>ChildProcess\ChildProcess.exe 2^>^&1 ^| more
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe 2>&1 | more
@echo -----------------------------
@echo 今実行した more と同じタイミングで同じ内容が表示されること。
@echo ^>ChildProcess\ChildProcess.exe 2^>^&1 ^| ..\..\safetee.exe -o Test2_out.txt
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe 2>&1 | ..\..\safetee.exe -o Test2_out.txt
@echo -----------------------------
@echo 今実行したときに標準出力はファイルにも出力されていること。ファイルの内容を表示します。
@echo 標準エラー出力は標準出力にリダイレクトされているので、ファイルの内容は表示内容と同じはずです。
@echo ^>type Test2_out.txt
@pause
@echo -----------------------------
@type Test2_out.txt
@echo -----------------------------
fc Test2_out.txt Test2_ans.txt
@if errorlevel 1  echo エラー：Test2_out.txt が期待した内容と違います。
@pause
del  Test2_out.txt
