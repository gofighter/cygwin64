@echo off
setlocal EnableDelayedExpansion

set HOME=/home/jaeho_s.lee

call :MakeLinkFile bash
call :MakeLinkFile mintty

exit /b

:MakeLinkFile
set target=%1.exe

REM set PATH="/usr/local/bin:/usr/bin${PATH:+:${PATH}}" 
REM %CYG.B%bash.exe --login  -c "pwd && ln -s /bin/!target! /usr/local/bin/!target!"

%CYG.B%bash.exe -c "[[ -f /usr/local/bin/!target! ]] || /usr/bin/ln -s /bin/!target! /usr/local/bin/!target!"

exit /b