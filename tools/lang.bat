@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ------------------------------
:: NORMALIZACJA ŚCIEŻEK
:: ------------------------------
set "SCRIPT_DIR=%~dp0"

call :Normalize "%SCRIPT_DIR%..\config\lang.txt" LANG_FILE
call :Normalize "%SCRIPT_DIR%..\other\loc1.txt" LOC1_FILE
call :Normalize "%SCRIPT_DIR%..\other\loc2.txt" LOC2_FILE
call :Normalize "%SCRIPT_DIR%..\other\loc3.txt" LOC3_FILE
call :Normalize "%SCRIPT_DIR%..\other\loc6.txt" LOC6_FILE
call :Normalize "%SCRIPT_DIR%..\other\langlist.txt" LANG_LIST
set /p LANGUAGE=<"%LANG_FILE%"
:: ------------------------------
:: TRYB USTAWIANIA JĘZYKA
:: ------------------------------
if not "%~1"=="" (
    call :SetLang "%~1"
    exit /b
)

:: ------------------------------
:: TRYB INFORMACYJNY
:: ------------------------------
call :ShowInfo
exit /b


:: ============================================================
:: FUNKCJE
:: ============================================================

:: ------------------------------
:: Normalize path (usuwa .. i daje pełną ścieżkę)
:: ------------------------------
:Normalize
for %%i in (%1) do set "%2=%%~fi"
exit /b


:: ------------------------------
:: Pobierz tekst z pliku locX
:: :GetText plik klucz zmienna
:: ------------------------------
:GetText
set "FILE=%~1"
set "KEY=%~2"
set "OUTVAR=%~3"
set "VALUE="

for /f "usebackq tokens=1,* delims= " %%a in ("%FILE%") do (
    if /i "%%a"=="!KEY!" (
        set "VALUE=%%b"
    )
)

if "!VALUE!"=="" (
    :: fallback do en
    for /f "usebackq tokens=1,* delims= " %%a in ("%FILE%") do (
        if /i "%%a"=="en" (
            set "VALUE=%%b"
        )
    )
)

set "%OUTVAR%=%VALUE%"
exit /b


:: ------------------------------
:: Ustaw język
:: ------------------------------
:SetLang
set "ARG=%~1"
set "FOUND="

:: 1. skrót języka
for /f "usebackq tokens=1,* delims= " %%a in ("%LANG_LIST%") do (
    if /i "%%a"=="!ARG!" set "FOUND=%%a"
)

:: 2. pełna nazwa
if "!FOUND!"=="" (
    for /f "usebackq tokens=1,* delims= " %%a in ("%LANG_LIST%") do (
        if /i "%%b"=="!ARG!" set "FOUND=%%a"
    )
)

:: 3. jeśli znaleziono
if not "!FOUND!"=="" (
    echo !FOUND!>"%LANG_FILE%"
    call :GetText "%LOC3_FILE%" "!FOUND!" MSG
    echo !MSG!: !FOUND!
    exit /b
)

:: 4. jeśli nie znaleziono — błąd
call :GetText "%LOC6_FILE%" !LANGUAGE! ERR
echo !ERR!: %ARG%
exit /b


:: ------------------------------
:: Wyświetl informacje o języku
:: ------------------------------
:ShowInfo


call :GetText "%LOC1_FILE%" "%LANGUAGE%" OUTPUT
call :GetText "%LOC2_FILE%" "%LANGUAGE%" LIST_HEADER

:: pełna nazwa języka
set "LANG_FULL=Unknown"
for /f "usebackq tokens=1,* delims= " %%a in ("%LANG_LIST%") do (
    if /i "%%a"=="%LANGUAGE%" set "LANG_FULL=%%b"
)

echo !OUTPUT!: !LANG_FULL! (!LANGUAGE!)
echo.
echo !LIST_HEADER!:
echo.

for /f "usebackq tokens=1,* delims= " %%a in ("%LANG_LIST%") do echo %%b
exit /b
