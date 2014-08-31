@echo off
if exist "%APPDATA%\Scripts" goto endif1
  echo [エラー] 次のフォルダが見つかりません。作成してください。
  echo %APPDATA%\Scripts
  pause
  goto :eof
:endif1
explorer  "%APPDATA%\Scripts"
