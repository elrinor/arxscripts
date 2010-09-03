@echo off
set name=%1
set dir=%2
set name=%name:"=%
set dir=%dir:"=%

if "%name%" == "" goto USAGE
if "%dir%" == "" goto USAGE

rmdir "%name%"
mklink /J "%name%" "%dir%"
goto :EOF

:USAGE
echo dlink - make directory symbolic link
echo.
echo USAGE:
echo   dlink link target
