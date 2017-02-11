@echo off
rem ********************************************************************
rem * File: Assort_ProjectOld.bat
rem ********************************************************************

call :Assort
if errorlevel 1 ( echo ERROR! & pause & exit /b )
pause
exit


rem ********************************************************************
rem * Function: Assort
rem ********************************************************************
:Assort
	echo === Assort to modiules batch from ProjectOld ===
	echo.
	set work_path=..\ProjectOld
	echo Input work_path=%work_path%
	if not exist "%work_path%" ( echo Not found "%work_path%" & pause & goto :eof )
	pause

	cscript  //nologo  "..\_Modules\_Fragments\ModuleAssortMini.vbs" ^
		Assort  "..\_Modules\_Fragments\Projects.xml.proja" ^
		"Project\01"  "%work_path%"
goto :eof


rem ********************************************************************
rem * Function: ChechOut
rem ********************************************************************
:ChechOut
	echo === Ckeck out batch of ProjectOld ===
	echo Enter only: ..\ProjectOld
	set /p output_path=Output Path^>
	if "%output_path%" == ""  set output_path=..\ProjectOld

	cscript  //nologo  "..\_Modules\_Fragments\ModuleAssortMini.vbs" ^
		ChechOut  "..\_Modules\_Fragments\Projects.xml.proja" ^
		"Project\01"  "%output_path%"
goto :eof


