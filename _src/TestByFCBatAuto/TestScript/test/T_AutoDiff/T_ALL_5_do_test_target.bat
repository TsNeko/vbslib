@echo off 
REM
REM  Test by comparing stdout and stderr (FCBat style)
REM
if "%1"=="" cmd /K "%0" /wnd

if exist T_ALL_result.txt  del T_ALL_result.txt

set T=T_Sample
echo ((( [%T%] )))

REM ( cscript //nologo %T%.vbs 2>&1 ) > %T%_log.txt
echo -------->Log1.txt
echo abc>>Log1.txt
echo -------->>Log1.txt
fc Log1.txt ans\Ans1.txt
if errorlevel 1  echo Fail in %T%.vbs>> T_ALL_result.txt&goto :last_of_test

:last_of_test
set T=
echo Test log compare ...>> T_ALL_result.txt
if not errorlevel 1 echo Pass.>> T_ALL_result.txt
if     errorlevel 1 echo Fail.>> T_ALL_result.txt
type T_ALL_result.txt

 
