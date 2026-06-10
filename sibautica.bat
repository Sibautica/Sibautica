@echo off
setlocal enabledelayedexpansion

rem --- wykryj czy skrypt został uruchomiony z otwartego terminala ---
echo %CMDCMDLINE% | find /i "/c" >nul
set FROM_CMD=%errorlevel%
call "%~dp0scripts\beforestart.bat"
rem --- jeśli uruchomiono z terminala → odpal sibauticash ---
if %FROM_CMD%==1 (
    call "%~dp0sibauticash.bat"
    goto :eof
)

rem --- jeśli kliknięto w Explorer → odpal sibauticama ---
call "%~dp0sibauticama.bat"
