@echo off
rem ********************************************************************
rem * File: Command.bat
rem ********************************************************************

call :SetVariables
call :Main %*
if errorlevel 1 ( echo ^<%error_message%/^> & pause & exit /b )
if "%~1" == "1"  ( exit /b 21 )
goto :eof


rem ********************************************************************
rem * Function: Main
rem *    Calls test functions.
rem ********************************************************************
:Main
	echo --- Command.bat %*
	if "%~1" == "2"  ( copy  Step2\01\A.txt  Step2\Work\A.txt )
	if "%~1" == "1"  ( copy  ..\Step1\01\A.txt  ..\Step1\Work\A.txt > nul )
goto :eof


rem ********************************************************************
rem * Function: SetVariables
rem ********************************************************************
:SetVariables
goto :eof


rem ********************************************************************
rem * Section: batlib
rem ********************************************************************


rem ********************************************************************
rem * Function: Error
rem *
rem * Arguments:
rem *    "%~1" - Value of setting %errorlevel%.
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


