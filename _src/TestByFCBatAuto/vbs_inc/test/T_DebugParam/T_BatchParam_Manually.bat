@echo off 


REM ************************************************************
echo ((( [T_BatchParam_debug] )))
REM ************************************************************
echo �f�o�b�K�[���N�����܂��B
echo ���̂܂܎��s���āA�G���[���o�Ȃ��ŏI�����邱�ƁB
pause
cscript //nologo //x T_BatchParam_Target.vbs T_BatchParam_1 A "" /opt1:2 "B C"
echo Finished T_BatchParam_debug.
pause


REM ************************************************************
echo ((( [T_BatchParam_debug_2] )))
REM ************************************************************
echo �f�o�b�K�[���N�����܂��B
echo ���̂܂܎��s���āA�G���[���o�Ȃ��ŏI�����邱�ƁB
pause
T_BatchParam_Target.vbs T_BatchParam_1 A "" /opt1:2 "B C" /g_debug:1
REM wscript //x T_BatchParam_Target.vbs T_BatchParam_1 A "" /opt1:2 "B C" /g_debug:1
echo Finished T_BatchParam_debug_2.
pause


echo Pass.
pause


