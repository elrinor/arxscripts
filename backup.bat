@echo off

set command=%1
set file=%2

if "%command%" == "" goto USAGE
if "%file%" == "" goto USAGE

if "%command%" == "-b" (
  set from=c:/
  set to=./c/
  goto COPY
)
if "%command%" == "-r" (
  set from=./c/
  set to=c:/
  goto COPY
)
goto USAGE

:COPY
for /f "eol= tokens=* delims= usebackq" %%i in (%file%) do call :BODY "%from%%%i" "%to%%%i"
goto :EOF

rem ---------------------------------------------------------------------------
:BODY
set src="%~d1%~p1%~n1%~x1"
set dst="%~d2%~p2%~n2%~x2"
set srcdir="%~d1%~p1"
set dstdir="%~d2%~p2"

if not exist %src% goto NOTFOUND

set tmp="TEMP_OMG_TEH_DRAMA.TXT"
dir %src% /B /A:D >%tmp% 2>&1
set dirout=nothing
for /f "tokens=* delims= usebackq" %%j in (%tmp%) do (set dirout=%%j)
del /F /Q %tmp%
if "%dirout%" == "File Not Found" goto COPYFILE
goto COPYDIR

:COPYDIR
echo COPYING DIR %src%
xcopy %src% %dst% /E /H /R /Y /I >NUL
goto :EOF

:COPYFILE
echo COPYING FILE %src%
if not exist %dstdir% mkdir %dstdir% >NUL
copy /Y %src% %dst% >NUL
goto :EOF

:NOTFOUND
echo NOT FOUND %src%
goto :EOF
rem ---------------------------------------------------------------------------

:USAGE
echo backup - backup script
echo.
echo USAGE: 
echo   backup command listfile
echo.
echo possible commands:
echo   -b      Copy files from drive C:/ to ./c/ folder
echo   -r      Copy files from ./c/ folder to drive C:/
goto :EOF

