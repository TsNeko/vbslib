@echo off
REM Character Encoding: "WHITE SQUARE" U+25A1 is □.
call :SetVariables "%~0"
set install_command=%not_close%  %cscript% //nologo "%vbslib_root%\_src\Test\tools\T_ModuleAssort2\T_ModuleAssort2.vbs"  ModuleAssort2_Installer


%install_command%  1_Open\Test.xml.proja  Project-B\02


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


<AR>
あは
</AR>
