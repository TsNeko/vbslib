@echo off
if     "%ProgramFiles(x86)%" == ""  set cscript=cscript
if not "%ProgramFiles(x86)%" == ""  set cscript=%windir%\SysWOW64\cscript.exe

%cscript% //nologo "..\..\vbslib Prompt.vbs" st "" "" "" /AutoExit:800
