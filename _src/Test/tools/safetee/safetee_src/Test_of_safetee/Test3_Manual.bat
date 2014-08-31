@echo 次は、4, 7, 12 を出力した後に、それぞれ１秒待ちます。
@echo ^>ChildProcess\ChildProcess.exe ^| more
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe | more
@echo -----------------------------
@echo 次は、4, 7, 12 を出力した後に、それぞれ１秒待ちます。
@echo ^>ChildProcess\ChildProcess.exe ^| ..\..\safetee.exe -o Test3_out.txt
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe | ..\..\safetee.exe -o Test3_out.txt
@echo -----------------------------
@echo 今実行したときに標準出力（奇数）はファイルにも出力されているはずです。
@echo ^>type Test3_out.txt
@pause
@echo -----------------------------
@type Test3_out.txt
@echo -----------------------------
fc Test3_out.txt Test3_ans.txt
@if errorlevel 1  echo エラー：Test3_out.txt が期待した内容と違います。

@echo 次は、4, 7, 12 を出力した後に、それぞれ１秒待ちます。
@echo ^>..\..\safetee.exe -o Test3_out2.txt -cmd ChildProcess\ChildProcess.exe param1 /param2
@pause
@echo -----------------------------
..\..\safetee.exe -o Test3_out2.txt -cmd ChildProcess\ChildProcess.exe param1 /param2
@echo -----------------------------
@echo 今実行したときに標準出力はファイルにも出力されているはずです。
@echo ^>type Test3_out2.txt
@pause
@echo -----------------------------
@type Test3_out2.txt
@echo -----------------------------
fc Test3_out2.txt Test3_ans2.txt
@if errorlevel 1  echo エラー：Test3_out2.txt が期待した内容と違います。
@pause
del  Test3_out.txt
del  Test3_out2.txt
