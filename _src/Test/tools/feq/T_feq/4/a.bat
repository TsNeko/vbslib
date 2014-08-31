echo off
echo 4
call ..\common\setting.bat
if not exist %test_prog% echo echo (not found %test_prog%) & set r=1 & pause & goto :eof

%test_prog% a b
if not errorlevel 1 echo Fail. & set r=1 & goto :eof

set r=0 & echo Pass.

