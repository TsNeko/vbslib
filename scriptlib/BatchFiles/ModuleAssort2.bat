@echo off
REM Character Encoding: "WHITE SQUARE" U+25A1 is □.
REM Debugging path may be depended on code page of command prompt and this file.
call :SetVariables "%~0"
rem set assort_vbs=%vbslib_root%\_src\Test\tools\T_ModuleAssort2\T_ModuleAssort2.vbs

if     "%~1" == ""  %not_close%  %cscript% //nologo "%vbslib_root%\vbslib Prompt.vbs"  ModuleAssort2  "C:\  .proja"  /g_debug_:1
if not "%~1" == ""  %not_close%  %cscript% //nologo "%vbslib_root%\vbslib Prompt.vbs"  ModuleAssort2  %1 %2 %3 %4 %5 %6 %7 %8 %9

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

