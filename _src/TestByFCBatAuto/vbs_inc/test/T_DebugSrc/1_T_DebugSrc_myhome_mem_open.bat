@echo off
if not "%myhome_mem%"=="" goto endif2
  echo [�G���[] ���ϐ� %%myhome_mem%% ����`����Ă��܂���B
  echo ��Fset myhome_mem=C:\home\mem_cache
  pause
  goto :eof
:endif2
if exist "%myhome_mem%\prog\scriptlib\setting_mem" goto endif1
  echo [�G���[] ���̃t�H���_��������܂���B
  echo %%myhome_mem%%\prog\scriptlib\setting_mem ������ϐ���W�J����
  echo %myhome_mem%\prog\scriptlib\setting_mem
  pause
  goto :eof
:endif1
explorer  "%myhome_mem%\prog\scriptlib\setting_mem"
