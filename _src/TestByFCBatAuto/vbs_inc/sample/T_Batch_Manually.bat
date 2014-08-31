@echo off
if     "%ProgramFiles(x86)%" == ""  set cscript=cscript
if not "%ProgramFiles(x86)%" == ""  set cscript=%windir%\SysWOW64\cscript.exe

echo バッチファイルから .vbs を実行します。
echo 新しいウィンドウが開かないこと
pause

%cscript% //nologo  "sample_main_prompt.vbs"
%cscript% //nologo  "sample_main_prompt_close.vbs"
echo 終了
pause
