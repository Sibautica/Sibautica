@echo off
setlocal enabledelayedexpansion

:: katalog, w którym znajduje się skrypt
set "SCRIPT_DIR=%~dp0"

:: ścieżka do lokalnego configu
set "LOCAL_CFG_DIR=%SCRIPT_DIR%"
set "LOCAL_CFG=%LOCAL_CFG_DIR%\wezterm.lua"

:: upewnij się że katalog scripts istnieje
if not exist "%LOCAL_CFG_DIR%" (
    mkdir "%LOCAL_CFG_DIR%"
)

:: ustaw kodowanie na UTF-8
chcp 65001 >nul

:: generuj lokalny plik wezterm.lua
(
echo return {
echo ^  default_prog = {
echo ^    "cmd.exe", "/k",
echo ^    "%SCRIPT_DIR:\=/%shibshell.bat"
echo ^  },
echo }
) > "%LOCAL_CFG%"

echo wygenerowano lokalny config: %LOCAL_CFG%
echo default_prog ustawiony na: %SCRIPT_DIR%scripts\shibshell.bat

echo.


:: uruchom wezterm z tym configiem
"%SCRIPT_DIR%..\terminal\wezterm.exe" --config-file "%LOCAL_CFG%"

endlocal
exit 