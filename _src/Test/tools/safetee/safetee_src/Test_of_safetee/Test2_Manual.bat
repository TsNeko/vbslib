@echo 1,2,..,12 �Ƃ������Ԃɂ͕\������܂���B
@echo ����͊��҂��ꂽ����ł͂���܂��񂪁A�΍���������Ă��܂���B
@echo �p�C�v������Ƃ��́A�p�C�v�̑O�̃v���O������ fflush ���邩�I������܂ŁA�o�͂��s���܂���B
@echo �W���o�͂ƕW���G���[�o�͂� 2^>1 �ŕW���o�͂ɂ܂Ƃ߂��Ă��A���Ԓʂ�ɏo�͂���܂���B
@echo ���́A8 ���o�͂����Ƃ��ɁA�Q�b�҂��܂��B
@echo ^>ChildProcess\ChildProcess.exe 2^>^&1 ^| more
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe 2>&1 | more
@echo -----------------------------
@echo �����s���� more �Ɠ����^�C�~���O�œ������e���\������邱�ƁB
@echo ^>ChildProcess\ChildProcess.exe 2^>^&1 ^| ..\..\safetee.exe -o Test2_out.txt
@pause
@echo -----------------------------
ChildProcess\ChildProcess.exe 2>&1 | ..\..\safetee.exe -o Test2_out.txt
@echo -----------------------------
@echo �����s�����Ƃ��ɕW���o�͂̓t�@�C���ɂ��o�͂���Ă��邱�ƁB�t�@�C���̓��e��\�����܂��B
@echo �W���G���[�o�͕͂W���o�͂Ƀ��_�C���N�g����Ă���̂ŁA�t�@�C���̓��e�͕\�����e�Ɠ����͂��ł��B
@echo ^>type Test2_out.txt
@pause
@echo -----------------------------
@type Test2_out.txt
@echo -----------------------------
fc Test2_out.txt Test2_ans.txt
@if errorlevel 1  echo �G���[�FTest2_out.txt �����҂������e�ƈႢ�܂��B
@pause
del  Test2_out.txt
