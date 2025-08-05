@echo off
setlocal EnableDelayedExpansion

if "%*" NEQ "" (cd /d %*)

set TERM=
set HOME=/home/jaeho_s.lee
!CYG.B!bash.exe --login -i

exit /b