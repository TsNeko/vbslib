@echo off

echo.
pushd  _Assort\Original
call  ..\ModuleAssortMini.bat  Assort  "Original"  "OriginalProject\01"  /no_input
popd

echo.
pushd  _Assort\Custom
call  ..\ModuleAssortMini.bat  Assort  "Custom"  "CustomProject\02"  /no_input
popd

echo.
echo All projects are assorted.
if not "%~1" == "/no_input" ( pause )
