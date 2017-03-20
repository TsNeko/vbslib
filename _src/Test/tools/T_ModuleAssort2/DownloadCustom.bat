@echo off
REM Character Encoding: "WHITE SQUARE" U+25A1 is □.
call :SetVariables "%~0"
set download_command=%not_close%  %cscript% //nologo "%vbslib_root%\_src\Test\tools\T_ModuleAssort2\T_ModuleAssort2.vbs"  ModuleAssort2


%download_command%  /EchoOff  ""  Download  7_Release\3_1_Publish\PubExpected  /MD5List:Modules\MD5List.txt


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
