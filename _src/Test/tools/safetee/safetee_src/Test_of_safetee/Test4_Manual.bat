@echo FC�R�}���h�����s����܂��B����ɂ���ĈႢ��������Ȃ����ƁB
@echo ^>..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt -cmd ChildProcess\ChildProcess.exe
@pause
@echo -----------------------------
..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt -cmd ChildProcess\ChildProcess.exe
@echo -----------------------------
@echo �����s�����Ƃ��ɕW���o�͂ƕW���G���[�̓t�@�C���ɂ��o�͂���Ă���͂��ł��B
@echo ^>type Test4_stdouterr.txt
@echo ^>type Test4_stderr.txt
@pause
@echo -----------------------------
type Test4_stdouterr.txt
@echo -----------------------------
fc Test4_stdouterr.txt Test4_stdouterr_ans.txt
@if errorlevel 1  echo �G���[�FTest4_stdouterr.txt �����҂������e�ƈႢ�܂��B
pause
@echo -----------------------------
type Test4_stderr.txt
@echo -----------------------------
fc Test4_stderr.txt Test4_stderr_ans.txt
@if errorlevel 1  echo �G���[�FTest4_stderr.txt �����҂������e�ƈႢ�܂��B

@echo �G���[�o�͂��Ȃ��Ƃ��́A�t�@�C�����o�͂��܂���B
@echo ^>..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt ^< Test4_stdin2.txt
@pause
@del  Test4_stdouterr.txt
@del  Test4_stderr.txt
@echo -----------------------------
..\..\safetee.exe -oe Test4_stdouterr.txt -e Test4_stderr.txt -cmd ..\..\safetee.exe
@echo -----------------------------
fc Test4_stdouterr.txt Test4_stdouterr_ans2.txt
@if errorlevel 1  echo �G���[�FTest4_stderr.txt �����҂������e�ƈႢ�܂��B
@if exist Test4_stderr.txt  echo �G���[�FTest4_stderr.txt �����݂��܂��B
@pause
del  Test4_stdouterr.txt
del  Test4_stderr.txt
 
