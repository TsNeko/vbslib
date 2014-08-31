@echo off 


REM ************************************************************
echo ((( [T_BatchParam_debug] )))
REM ************************************************************
echo デバッガーが起動します。
echo そのまま実行して、エラーが出ないで終了すること。
pause
cscript //nologo //x T_BatchParam_Target.vbs T_BatchParam_1 A "" /opt1:2 "B C"
echo Finished T_BatchParam_debug.
pause


REM ************************************************************
echo ((( [T_BatchParam_debug_2] )))
REM ************************************************************
echo デバッガーが起動します。
echo そのまま実行して、エラーが出ないで終了すること。
pause
T_BatchParam_Target.vbs T_BatchParam_1 A "" /opt1:2 "B C" /g_debug:1
REM wscript //x T_BatchParam_Target.vbs T_BatchParam_1 A "" /opt1:2 "B C" /g_debug:1
echo Finished T_BatchParam_debug_2.
pause


echo Pass.
pause


