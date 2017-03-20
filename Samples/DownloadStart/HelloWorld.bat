@echo off
REM Character Encoding: "WHITE SQUARE" U+25A1 is  .
echo ‹N“®’†...

set current=%cd%\
set main_vbs_path=%current%scriptlib\Main.vbs
set scriptlib_zip_path=%current%scriptlib\scriptlib.zip

for /f %%a in ('powershell -Command "Write-host (-join( (Get-Date).ToString(\"yyMMdd\"), \"\\\", (Get-Item %main_vbs_path%).LastWriteTime.ToString(\"yyyy-MM-ddTHH:mm:ss\")))"') do set work_path=%%a
set work_path=%work_path::=;%
set work_path=%USERPROFILE%\AppData\Local\Temp\Report\%work_path%
if exist "%work_path%" goto :endif_1
	mkdir  "%work_path%-downloading"
	copy  "%main_vbs_path%"  "%work_path%-downloading" > nul
	copy  "%scriptlib_zip_path%"  "%work_path%-downloading" > nul
	move  "%work_path%-downloading"  "%work_path%" > nul
:endif_1

call :GetFileName  "%main_vbs_path%"
set main_vbs_name=%return_value%

cscript //nologo  "%work_path%\%main_vbs_name%"
if not "%errorlevel%"=="21" ( pause )
pause

goto :eof


:GetFileName
	set return_value=%~nx1
goto :eof
