echo off 

pushd 1
call a.bat
popd
if not %r%==0 echo Fail. & set r=1 & goto :eof_

pushd 2
call a.bat
popd
if not %r%==0 echo Fail. & set r=1 & goto :eof_

pushd 3
call a.bat
popd
if not %r%==0 echo Fail. & set r=1 & goto :eof_

pushd 4
call a.bat
popd
if not %r%==0 echo Fail. & set r=1 & goto :eof_

pushd 5
call a.bat
popd
if not %r%==0 echo Fail. & set r=1 & goto :eof_

pushd 6
call a.bat
popd
if not %r%==0 echo Fail. & set r=1 & goto :eof_

set r=0 & echo Pass.
 
:eof_
pause
