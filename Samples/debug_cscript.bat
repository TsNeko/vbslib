REM === Attach to Just In Time debugger
REM   このバッチ・ファイルをダブルクリックすると、ここのフォルダーにある .vbs ファイルを cscript.exe でデバッグします。
REM   .vbs ファイルをこのバッチファイルにドラッグ＆ドロップすると、その .vbs ファイルを cscript.exe でデバッグします。

for %%i in (*.vbs) do set debug_script_path=%%i
if not "%~1"=="" for %%i in ("%~1") do cd "%%~di%%~pi" & set debug_script_path=%%~ni%%~xi
start "" cscript //x "%debug_script_path%"
 
