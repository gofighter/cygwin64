@echo off
setlocal EnableDelayedExpansion

if "%*" NEQ "" (cd /d %*)

set TERM=
set HOME=/home/jaeho_s.lee

!CYG.B!mintty.exe -i /Cygwin-Terminal.ico -

exit /b