@echo off
call :SetVariables "%~0"

%close_at_end%  %cscript% //nologo "%vbslib_root%\vbslib Prompt.vbs"  %1 %2 %3 %4 %5 /pause

goto :eof


REM ********************************************************************
REM  Function: SetVariables
REM ********************************************************************
:SetVariables
if     "%ProgramFiles(x86)%" == ""  set cscript=cscript
if not "%ProgramFiles(x86)%" == ""  set cscript=%windir%\SysWOW64\cscript.exe

set close_at_end=
set not_close=cmd.exe /K

call :GetParentPath "%~1"
call :GetParentPath "%ret%"
call :GetParentPath "%ret%"
set vbslib_root=%ret%

goto :eof


REM ********************************************************************
REM  Function: GetParentPath
REM ********************************************************************
:GetParentPath
set ret=%~dp1
set ret=%ret:~0,-1%
goto :eof
