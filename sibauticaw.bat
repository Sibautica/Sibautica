@echo off
call "%~dp0scripts\beforestart.bat"
echo sibauticama> .\config\opened.txt
call "%~dp0scripts\sibautica.bat" %1