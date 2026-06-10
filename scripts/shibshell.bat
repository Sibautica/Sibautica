@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

title Sibautica
cls

:: pobierz ścieżkę do katalogu skryptu
set "SCRIPT_DIR=%~dp0"

:: pliki lokalizacji
set "LANG_FILE=%SCRIPT_DIR%..\config\lang.txt"
set "LOC4_FILE=%SCRIPT_DIR%..\other\loc4.txt"
set "LOC5_FILE=%SCRIPT_DIR%..\other\loc5.txt"
set "OPENED_FILE=%SCRIPT_DIR%..\config\opened.txt"

:: wczytaj kod języka (np. pl)
set /p LANGUAGE=<"%LANG_FILE%"

:: domyślne teksty
set "WELCOME=Welcome to Sibautica!"
set "GOODBYE=Goodbye!"

:: --- Wczytaj powitanie z loc4.txt ---
for /f "usebackq tokens=1,* delims= " %%a in ("%LOC4_FILE%") do (
    if /i "%%a"=="%LANGUAGE%" (
        set "WELCOME=%%b"
    )
)

:: --- Wczytaj pożegnanie z loc5.txt ---
for /f "usebackq tokens=1,* delims= " %%a in ("%LOC5_FILE%") do (
    if /i "%%a"=="%LANGUAGE%" (
        set "GOODBYE=%%b"
    )
)

echo !WELCOME!
echo.

:: dodaj ../tools do PATH
set "TOOLS_PATH=%SCRIPT_DIR%..\tools"
set "PATH=!PATH!;%TOOLS_PATH%"

:: --- Wczytaj opened PRZED cmd /k ---
set /p opened=<"%OPENED_FILE%"

:: uruchom CMD w trybie interaktywnym z nowym PATH
cmd /k

:: --- Po wyjściu z cmd /k ---
echo !GOODBYE!
timeout /t 3 >nul

if /i "%opened%"=="sibauticama" (
    exit
) else (
    exit /b
)
