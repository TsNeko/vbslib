@echo off
if exist "%APPDATA%\Scripts" goto endif1
  echo [�G���[] ���̃t�H���_��������܂���B�쐬���Ă��������B
  echo %APPDATA%\Scripts
  pause
  goto :eof
:endif1
explorer  "%APPDATA%\Scripts"
