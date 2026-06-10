@echo off
call "%~dp0scripts\beforestart.bat"
echo sibauticash> .\config\opened.txt
call "%~dp0scripts\shibshell.bat"