@echo off
REM Character Encoding: "WHITE SQUARE" U+25A1 is Å†.
call :SetVariables "%~0"
set download_command=%not_close%  %cscript% //nologo "%server_root%%relative_path%\T_ModuleAssort2.vbs"  ModuleAssort2

echo ãNìÆíÜÇ≈Ç∑ ...

%download_command%  /EchoOff  ""  Download  "%server_root%"  /MD5List:Modules\MD5List.txt  ""  /g_debug_:1


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
set server_root=%ret%
set relative_path=\scriptlib

set server_root=7_Release\3_1_Publish\PubExpected
set relative_path=

goto :eof


