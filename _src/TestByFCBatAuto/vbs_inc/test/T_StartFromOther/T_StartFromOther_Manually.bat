@echo off 
REM
REM  Test by comparing stdout and stderr (FCBat style)
REM

if exist T_ALL_result.txt  del T_ALL_result.txt
if "%1"=="" cmd /K "%0" /wnd
set CL=cscript %2 //nologo

echo カレント・ディレクトリと、g_start_in_path のテストを行います。
echo デバッガーが起動するので、デバッガー上でスクリプトを実行してください。
echo スクリプトが終了したら、ウィンドウを閉じてください。
echo その後の自動チェックで Fail にならないことを確認してください。
pause

set T=T_StartFromOther_Manually
echo ^<^<^< [%T%] ^>^>^>

REM === Test Main
pushd T_StartFromOther
( %CL% ..\%T%_sub.vbs %3 2>&1 ) > ..\%T%_log.txt
popd


REM === check
fc %T%_ans.txt %T%_log.txt
if errorlevel 1  echo Fail in %T%.vbs>> T_ALL_result.txt&goto :last_of_test
fc %T%_out_ans.txt %T%_out.txt
if errorlevel 1  echo Fail in %T%.vbs>> T_ALL_result.txt&goto :last_of_test
del T_StartFromOther\%T%_out.txt


:last_of_test
set T=
set CL=
echo Test log compare ...>> T_ALL_result.txt
if not errorlevel 1 echo Pass.>> T_ALL_result.txt
if     errorlevel 1 echo Fail.>> T_ALL_result.txt
type T_ALL_result.txt

 
