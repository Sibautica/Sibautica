@echo off
setlocal enabledelayedexpansion

:: Ustal NODE_PATH jako absolutną ścieżkę do ..\nodejs\node.exe
call :Normalize "%~dp0..\nodejs\node.exe" NODE_PATH

:: Foldery ze skryptami .js
set "CLI_DIR=%~dp0..\cli"
set "OTHER_DIR=%~dp0..\other"

if "%~1"=="" (
    echo Uzycie: node <nazwa_skryptu> [argumenty...]
    exit /b 1
)

set "SCRIPT_NAME=%~1"
shift

:: Najpierw szukamy w ..\cli
set "SCRIPT_FILE=%CLI_DIR%\%SCRIPT_NAME%.js"

if not exist "%SCRIPT_FILE%" (
    :: Jeśli nie ma, próbujemy w ..\other
    set "SCRIPT_FILE=%OTHER_DIR%\%SCRIPT_NAME%.js"
)

:: Jeśli nadal nie ma — błąd
if not exist "%SCRIPT_FILE%" (
    echo Blad: nie znaleziono pliku "%SCRIPT_NAME%.js" ani w cli, ani w other.
    exit /b 1
)

"%NODE_PATH%" "%SCRIPT_FILE%" %*

endlocal
exit /b

:Normalize
for %%i in (%1) do set "%2=%%~fi"
exit /b
