@echo off
if     "%ProgramFiles(x86)%" == ""  set cscript=cscript
if not "%ProgramFiles(x86)%" == ""  set cscript=%windir%\SysWOW64\cscript.exe

echo �o�b�`�t�@�C������ .vbs �����s���܂��B
echo �V�����E�B���h�E���J���Ȃ�����
pause

%cscript% //nologo  "sample_main_prompt.vbs"
%cscript% //nologo  "sample_main_prompt_close.vbs"
echo �I��
pause
