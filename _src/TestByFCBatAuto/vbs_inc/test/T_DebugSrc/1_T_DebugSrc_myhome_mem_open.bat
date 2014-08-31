@echo off
if not "%myhome_mem%"=="" goto endif2
  echo [エラー] 環境変数 %%myhome_mem%% が定義されていません。
  echo 例：set myhome_mem=C:\home\mem_cache
  pause
  goto :eof
:endif2
if exist "%myhome_mem%\prog\scriptlib\setting_mem" goto endif1
  echo [エラー] 次のフォルダが見つかりません。
  echo %%myhome_mem%%\prog\scriptlib\setting_mem から環境変数を展開した
  echo %myhome_mem%\prog\scriptlib\setting_mem
  pause
  goto :eof
:endif1
explorer  "%myhome_mem%\prog\scriptlib\setting_mem"
