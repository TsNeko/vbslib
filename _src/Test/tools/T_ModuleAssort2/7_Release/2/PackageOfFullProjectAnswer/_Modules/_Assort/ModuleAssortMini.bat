@echo off
rem ********************************************************************
rem * File: ModuleAssortMini.bat
rem *
rem * Description:
rem *    ModuleAssortMini.bat uses batlib.
rem *
rem *    batlib - Batch File ShortHand Library  ver0.10  Dec.29, 2016
rem *    batlib is provided under 3-clause BSD license.
rem *    Copyright (C) 2016-2016 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
rem *
rem * Example:
rem *    > ModuleAssortMini.bat  Assort  "Project"  "ReleaseProject\01"
rem ********************************************************************

set echo_error_ID=0

call :%1  "%~2"  "%~3"  %4
if errorlevel 1 ( echo ^<%error_message%/^> & echo current echo_error_ID=%echo_error_ID% & pause & exit /b )
if not "%~4" == "/no_input" ( pause )
exit /b

:DebugBreak
	pause
exit /b


rem ********************************************************************
rem * Function: Assort
rem *
rem * Arguments:
rem *    "%~1" - Project tag name.
rem *    "%~2" - Project full name.
rem *    "%~3" - Option.
rem ********************************************************************
:Assort
	set project_name=%~1
	set project_full_name=%~2
	set option_=%~3

	rem // Set "work_path"
	call :SearchParent  "_Modules"
		if errorlevel 1 ( exit /b )
	call :GetParentPath  "%return_value%"
		if errorlevel 1 ( exit /b )
	set work_path=%return_value%\%project_name%

	rem // Set "vbs_lib"
	call :SearchParent  "_Modules\_Assort\ModuleAssortMini.vbs"
		if errorlevel 1 ( exit /b )
	set vbs_lib=%return_value%


	rem // Assort
	echo === Assort ===
	echo.
	echo work_path (input project) = %work_path%
	if not exist "%work_path%" ( echo Not found "%work_path%" & pause & goto :eof )
	if not "%option_%" == "/no_input" ( pause )
	echo.

	cscript  //nologo  "%vbs_lib%"  Assort  "Project.xml.proja" ^
		"%project_full_name%"  "%work_path%"
goto :eof


rem ********************************************************************
rem * Function: ChechOut
rem *
rem * Arguments:
rem *    "%~1" - Project tag name.
rem *    "%~2" - Project full name.
rem ********************************************************************
:ChechOut
	set project_name=%~1
	set project_full_name=%~2

	rem // Set "work_path"
	call :SearchParent  "_Modules"
		if errorlevel 1 ( exit /b )
	call :GetParentPath  "%return_value%"
		if errorlevel 1 ( exit /b )
	set work_path=%return_value%\%project_name%

	rem // Set "work_path_default"
	set work_path_default=%work_path%

	rem // Set "vbs_lib"
	call :SearchParent  "_Modules\_Assort\ModuleAssortMini.vbs"
		if errorlevel 1 ( exit /b )
	set vbs_lib=%return_value%


	rem // Ckeck Out
	echo === Ckeck Out ===
	echo Enter only: %work_path_default%
	set /p work_path=work_path (output project)^>
	if "%work_path%" == ""  set work_path=%work_path_default%

	cscript  //nologo  "%vbs_lib%"  ChechOut  "Project.xml.proja" ^
		"%project_full_name%"  "%work_path%"
goto :eof


rem ********************************************************************
rem * Section: batlib
rem ********************************************************************


rem ********************************************************************
rem * Function: Error
rem *
rem * Arguments:
rem *    "%~1" - Value of setting %errorlevel%.
rem *    "%~2" - Error message.
rem *
rem * Return Value:
rem *    %errorlevel% - %~1. Number type
rem *
rem * Description:
rem *    This sets %error_message% variable.
rem *    This adds %error_ID% variable.
rem *    This echos each command from %error_ID% was matched %echo_error_ID%.
rem ********************************************************************
:Error
	set /A error_ID = %error_ID% + 1

	set error_message=ERROR  errorlevel="%~1"  error_message="%~2"  error_ID="%error_ID%"
		rem // "echo %error_message%" cannot execute, if there are "<" and ">" of "<ERROR/>".

	if "%error_ID%" == "%echo_error_ID%"  (
		echo.
		echo ===============================================================================
		echo ^<%error_message%/^>
		call :DebugBreak
		echo.
		echo.
		echo on
	)

	exit /b %~1
goto :eof


rem ********************************************************************
rem * Function: ClearError
rem *
rem * Arguments:
rem *    None.
rem *
rem * Return Value:
rem *    None.
rem ********************************************************************
:ClearError
	set error_message=
	exit /b 0
goto :eof


rem ********************************************************************
rem * Function: GetParentPath
rem *
rem * Arguments:
rem *    "%~1" - Path.
rem *
rem * Return Value:
rem *    %return_value% - Parent full path of "%~1"
rem ********************************************************************
:GetParentPath
	set path_=%~1
	if "%path_%" == ""      ( call :Error 1 "Not found parent folder" & exit /b )
	if "%path_:~-1%" == ":" ( call :Error 1 "Not found parent folder" & exit /b )

	set path_=%~dp1
	set return_value=%path_:~0,-1%
goto :eof


rem ********************************************************************
rem * Function: SearchParent
rem *
rem * Arguments:
rem *    "%~1" - Step path.
rem *
rem * Return Value:
rem *    %return_value% - Full path
rem ********************************************************************
:SearchParent
	set step_path_=%~1
	if "%step_path_%" == "" ( call :Error 1 "Not found parent folder" & exit /b )

	set current_directory_=%cd%

	:SearchParent_1

		if exist "%current_directory_%\%step_path_%" (
			set return_value=%current_directory_%\%step_path_%
			goto :eof
		)

		if "%current_directory_%" == "" (
			set return_value=
			call :Error  1  "Not found %step_path_% in parents."
			exit /b
		)

		call :GetParentPath  "%current_directory_%"
			if errorlevel 1 ( exit /b )
		set current_directory_=%return_value%
	goto :SearchParent_1

goto :eof


