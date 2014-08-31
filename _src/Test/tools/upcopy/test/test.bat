@echo off

set upcopy_bat=..\upcopy.bat
set timedate_exe=..\upcopy.bat.timedate.exe
if exist log.txt del log.txt
set e=0
set ee=0

REM ----- test of timedate.exe -----
%timedate_exe% t=now >_t.bat& call _t.bat& del _t.bat
echo t=%t%
%timedate_exe% up=update 412.txt >_t.bat& call _t.bat& del _t.bat
echo up=%up% >>log.txt
set t=
set up=


REM ----- test of xcopy -----
if exist a.txt del a.txt
if exist b.txt del b.txt

echo copy 410 a>>log.txt
copy 410.txt  a.txt>>log.txt

echo upcopy a to b>>log.txt
call %upcopy_bat%  a.txt b.txt>>log.txt
if not exist b.txt  echo ERROR>>log.txt

echo upcopy a to b>>log.txt
call %upcopy_bat%  "%cd%\a.txt" b.txt>>log.txt

echo copy 412 a>>log.txt
copy 412.txt  a.txt>>log.txt

echo upcopy a to b>>log.txt
call %upcopy_bat%  a.txt b.txt>>log.txt

echo upcopy a to b>>log.txt
call %upcopy_bat%  a.txt b.txt>>log.txt

echo copy 410 a>>log.txt
copy 410.txt  a.txt>>log.txt

echo upcopy a to b>>log.txt
call %upcopy_bat%  a.txt b.txt>>log.txt

echo upcopy c to b>>log.txt
call %upcopy_bat%  c.txt b.txt>>log.txt

type log.txt
echo ERROR count=%e%

if exist a.txt del a.txt
if exist b.txt del b.txt

REM // check -----------------
fc log.txt ans.txt
if not "%errorlevel%"=="0"  set /A ee=%ee%+1
if not "%e%"=="2"  set /A ee=%ee%+1

if     %ee%==0  echo Pass.
if not %ee%==0  echo Fail.
set e=
pause
goto :eof

