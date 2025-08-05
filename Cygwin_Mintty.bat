@echo off
setlocal EnableDelayedExpansion

if "%*" NEQ "" (cd /d %*)

set TERM=
set HOME=/home/jaeho_s.lee

!CYG.B!mintty.exe --dir . -i /Cygwin-Terminal.ico -

exit /b