@echo off

rem Go to system root to be sure that we're running native find, reg, etc...
pushd .
cd %SystemRoot%\system32

set command=%1
set variable=%2
set value=%3

if "%1" == "" goto USAGE
if "%2" == "" goto USAGE
if "%3" == "" goto USAGE

if "%command%" == "set" goto RUN
if NOT "%command%" == "app" (
	if NOT "%command%" == "pre" goto USAGE
)

rem strip any quotation marks off
set command=%command:"=%
set variable=%variable:"=%
set value=%value:"=%

rem Get old value
set oldvalue1=
set oldvalue2=
rem This works under win7
for /f "tokens=2,* delims= " %%j in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v %variable%') do (set oldvalue1=%%k)
rem This works under win xp, note that the \t character after delims= is *important*
for /f "tokens=3 delims=	" %%j in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v %variable%') do (set oldvalue2=%%j)

rem Under win7 oldvalue2 is empty, under win xp oldvalue1 may not be empty
set oldvalue=
if "%oldvalue2%" == "" (
  set oldvalue="%oldvalue1%"
) else (
  set oldvalue="%oldvalue2%"
)
rem Trickery with quotes and quote stripping is needed under win7
set oldvalue=%oldvalue:"=%

rem Check whether value is already in oldvalue.
set isinoldvalue=0
for /F %%j in ('echo "%oldvalue%;"  ^| find /C /I "%value%;"') do (set isinoldvalue=%%j)

if NOT %isinoldvalue% == 0 goto UNCHANGED
if "%command%" == "app" set value=%oldvalue%;%value%
if "%command%" == "pre" set value=%value%;%oldvalue%

:RUN
rem Change value.
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f /v %variable% /t REG_EXPAND_SZ /d "%value%"
start %~d0%~p0..\utils\EnvChange
goto END

:USAGE
echo env - environment variables modification script
echo.
echo USAGE: 
echo   env command variable value
echo.
echo possible commands:
echo   app     Appends the given value to a semicolon-separated list of values 
echo           stored in a given environment variable.
echo   pre     Same as app, but prepends.
echo   set     Sets the value of a given environment variable.
goto END

:UNCHANGED
echo Value already in list
goto END

:END
popd