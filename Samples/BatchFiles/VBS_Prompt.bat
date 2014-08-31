@echo off

call :GetParentPath %0
call :GetParentPath "%ret%"
call :GetParentPath "%ret%"
set vbslib_root=%ret%
cmd.exe /K cscript.exe //nologo "%vbslib_root%\vbslib Prompt.vbs" Prompt

goto :eof


:GetParentPath
set ret=%~dp1
set ret=%ret:~0,-1%
goto :eof
