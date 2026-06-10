@echo off
call "%~dp0scripts\beforestart.bat"
rem --- wykryj czy skrypt został uruchomiony przez kliknięcie ---
echo sibauticama> .\config\opened.txt
echo %CMDCMDLINE% | find /i "/c" >nul
set CLICKED=%errorlevel%

powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0scripts\start.ps1"

rem --- jeśli NIE wpisano go ręcznie w CMD, to zamknij okno ---
if %CLICKED%==1 exit
