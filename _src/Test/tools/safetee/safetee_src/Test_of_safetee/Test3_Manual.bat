@echo ���́A4, 7, 12 ���o�͂�����ɁA���ꂼ��P�b�҂��܂��B
@echo ^>ChildProcess\ChildProcess.exe ^| more
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe | more
@echo -----------------------------
@echo ���́A4, 7, 12 ���o�͂�����ɁA���ꂼ��P�b�҂��܂��B
@echo ^>ChildProcess\ChildProcess.exe ^| ..\..\safetee.exe -o Test3_out.txt
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe | ..\..\safetee.exe -o Test3_out.txt
@echo -----------------------------
@echo �����s�����Ƃ��ɕW���o�́i��j�̓t�@�C���ɂ��o�͂���Ă���͂��ł��B
@echo ^>type Test3_out.txt
@pause
@echo -----------------------------
@type Test3_out.txt
@echo -----------------------------
fc Test3_out.txt Test3_ans.txt
@if errorlevel 1  echo �G���[�FTest3_out.txt �����҂������e�ƈႢ�܂��B

@echo ���́A4, 7, 12 ���o�͂�����ɁA���ꂼ��P�b�҂��܂��B
@echo ^>..\..\safetee.exe -o Test3_out2.txt -cmd ChildProcess\ChildProcess.exe param1 /param2
@pause
@echo -----------------------------
..\..\safetee.exe -o Test3_out2.txt -cmd ChildProcess\ChildProcess.exe param1 /param2
@echo -----------------------------
@echo �����s�����Ƃ��ɕW���o�͂̓t�@�C���ɂ��o�͂���Ă���͂��ł��B
@echo ^>type Test3_out2.txt
@pause
@echo -----------------------------
@type Test3_out2.txt
@echo -----------------------------
fc Test3_out2.txt Test3_ans2.txt
@if errorlevel 1  echo �G���[�FTest3_out2.txt �����҂������e�ƈႢ�܂��B
@pause
del  Test3_out.txt
del  Test3_out2.txt
