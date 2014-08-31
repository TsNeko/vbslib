@echo offs

REM -----------------
:upcopy
set timedate_exe="%~0.timedate.exe"
%timedate_exe% upd1=update %1 >_t.bat& call _t.bat& del _t.bat
if "%upd1%"=="" echo [ERROR] not found %1&set /A e=%e%+1&goto :eof
%timedate_exe% upd2=update %2 >_t.bat& call _t.bat& del _t.bat
if "%upd2%"=="" copy %1 %2 &set upd1=&goto :eof
if "%upd1%" gtr "%upd2%"  copy %1 %2
if "%upd1%" lss "%upd2%"  echo [WARNING] %2 is newer than %1&set /A e=%e%+1
set upd1=& set upd2=
goto :eof
 
