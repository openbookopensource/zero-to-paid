@echo off
if not exist "%~dp0Install-5-Apps.bat" (
  echo Install-5-Apps.bat must be in the same folder as this file, with that exact name.
  echo Please put both files in one folder and try again.
  pause
  exit /b 1
)
call "%~dp0Install-5-Apps.bat" /undo
