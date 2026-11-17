@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM ===================== SELLER SETTINGS (edit these lines only) =====================
REM Do not use & ^ % ! ( ) or quotes inside BRAND or SUPPORT. They break batch files.
set "BRAND=Five Apps"
set "SUPPORT=the person who supplied this package"
set "APPS=Google.Chrome VideoLAN.VLC 7zip.7zip Zoom.Zoom Notepad++.Notepad++"
set "MIN_GB=5"
REM ===================================================================================
set "LOG=%TEMP%\5-apps-install-log.txt"
set "STATE=%LOCALAPPDATA%\FiveApps"
set "DONEFILE=%STATE%\installed-by-us.txt"
set "DRY="
if /i "%~1"=="/dryrun" set "DRY=1"
if not "%~1"=="" if /i not "%~1"=="/dryrun" if /i not "%~1"=="/undo" (
  echo Unknown option. Run this file with no options, or with /dryrun or /undo.
  pause
  exit /b 1
)
if defined DRY (
  echo Five Apps - preview only. No apps, files or settings will be changed.
  for %%A in (%APPS%) do echo   Would check and install %%A from the winget source.
  echo An actual install needs internet, App Installer and Windows administrator approval.
  exit /b 0
)

title %BRAND% - App Installer
set "DESKTOP=%USERPROFILE%\Desktop"
chcp 65001 >nul
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; [Environment]::GetFolderPath('Desktop')"`) do set "DESKTOP=%%D"
if not exist "%DESKTOP%" mkdir "%DESKTOP%" >nul 2>&1
if not exist "%DESKTOP%" set "DESKTOP=%TEMP%"
set "REPORT=%DESKTOP%\5-Apps-Install-Report.txt"

REM ---- Step 0: get permission (Windows will show one Yes/No box) ----
fltmc >nul 2>&1
if errorlevel 1 (
  echo Asking Windows for permission - please click Yes on the next box...
  set "SELF=%~f0"
  set "ARG1=%~1"
  if "%~1"=="" (
    powershell -NoProfile -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
  ) else (
    powershell -NoProfile -Command "Start-Process -FilePath $env:SELF -ArgumentList $env:ARG1 -Verb RunAs"
  )
  if errorlevel 1 (
    echo.
    echo   Windows did not give permission, so nothing was installed.
    echo   Please open the file again and click Yes on the permission box.
    echo.
    pause
  )
  exit /b
)

if /i "%~1"=="/undo" goto :undo

cls
echo ================================================
echo   %BRAND% - installing your apps
echo   Keep this window open. It takes a few minutes.
echo ================================================
echo.
if not exist "%STATE%" mkdir "%STATE%" >nul 2>&1
if not exist "%STATE%" (
  echo Cannot create the install record folder. No apps were installed.
  pause
  exit /b 1
)
>"%STATE%\write-check.tmp" echo FiveApps
if errorlevel 1 (
  echo Cannot write install records. No apps were installed.
  pause
  exit /b 1
)
del "%STATE%\write-check.tmp" >nul 2>&1
>"%LOG%" echo Started %date% %time%
>"%REPORT%" echo %BRAND% - install report  (%date% %time%)
>>"%REPORT%" echo ------------------------------------------------

REM ---- Step 1: check the PC before touching anything ----
echo [1/3] Checking your PC...
powershell -NoProfile -Command "if([Environment]::OSVersion.Version.Build -lt 17763){exit 1}"
if errorlevel 1 (
  call :stop "This needs Windows 10 (version 1809) or newer. Please update Windows and run this again."
  exit /b 1
)
powershell -NoProfile -Command "if((Get-PSDrive -Name $env:SystemDrive.TrimEnd(':')).Free/1GB -lt %MIN_GB%){exit 1}"
if errorlevel 1 (
  call :stop "Not enough free space. Please free up at least %MIN_GB% GB on your C: drive and run this again."
  exit /b 1
)
curl.exe -fs -m 10 -o nul https://www.msftconnecttest.com/connecttest.txt
if errorlevel 1 (
  call :stop "Could not reach the internet. Check your connection, date and time, and any VPN or proxy, then run this again."
  exit /b 1
)
echo       PC check passed.

REM ---- Step 2: require the official Windows installer engine ----
where winget >nul 2>&1
if errorlevel 1 (
  call :stop "Update Microsoft App Installer from Microsoft Store, then run this again."
  exit /b 1
)

REM ---- Step 3: install each app, verify it, retry if needed ----
echo [2/3] Installing apps...
set /a FAILS=0
for %%A in (%APPS%) do (
  if not defined RECORD_FAILED call :install %%A
)
echo.
echo [3/3] Writing your report...
>>"%REPORT%" echo ------------------------------------------------
if !FAILS! gtr 0 (
  >>"%REPORT%" echo Some apps need attention ^(!FAILS! failed^). Share this report with %SUPPORT%
  echo.
  echo Finished, but some apps need attention ^(!FAILS! failed^).
  echo Please share the report on your Desktop with %SUPPORT%
) else (
  if defined DRY (
    >>"%REPORT%" echo Dry run only - nothing was installed.
    echo.
    echo Dry run finished. Nothing was installed.
  ) else (
    >>"%REPORT%" echo Everything installed and checked.
    echo.
    echo All done. Every app was installed and checked.
    echo You can close this window and open your apps from the Start menu.
  )
)
echo A report was saved to: %REPORT%
echo.
pause
if !FAILS! gtr 0 exit /b 1
exit /b 0

:install
set "ID=%~1"
set "RESULT="
if defined DRY (
  echo   [dry run] would install %ID%
  >>"%REPORT%" echo %ID% - dry run, nothing installed
  exit /b 0
)
winget list --id "%ID%" -e --accept-source-agreements >nul 2>&1
if !errorlevel! equ 0 (
  set "RESULT=Already on this PC (left untouched)"
  goto :install_done
)
if not !errorlevel! equ -1978335212 (
  set "RESULT=FAILED: could not safely check existing apps"
  set /a FAILS+=1
  goto :install_done
)
set /a TRY=0
:retry
set /a TRY+=1
echo   Installing %ID% (attempt !TRY! of 3)...
winget install --id "%ID%" -e --source winget --silent --accept-package-agreements --accept-source-agreements --disable-interactivity >>"%LOG%" 2>&1
set "WRC=!errorlevel!"
winget list --id "%ID%" -e --accept-source-agreements >nul 2>&1
if !errorlevel! equ 0 (
  set "RESULT=Installed and verified"
  >>"%DONEFILE%" echo %ID%
  if errorlevel 1 (
    set "RESULT=FAILED: installed but record could not be saved. Remove manually using Windows Installed apps."
    set "RECORD_FAILED=1"
    set /a FAILS+=1
  )
  goto :install_done
)
if !TRY! lss 3 (
  winget source update >>"%LOG%" 2>&1
  timeout /t 5 /nobreak >nul
  goto :retry
)
set "RESULT=FAILED after 3 attempts (code !WRC!)"
set /a FAILS+=1
:install_done
echo   %ID%: !RESULT!
>>"%REPORT%" echo %ID% - !RESULT!
exit /b 0

:stop
echo.
echo   PROBLEM: %~1
echo   Nothing was changed on your PC.
echo   Need help? Contact %SUPPORT%
echo.
>>"%REPORT%" echo STOPPED: %~1
pause
exit /b 1

:undo
if not exist "%DONEFILE%" (
  echo Nothing to undo. No apps were installed by this installer.
  pause
  exit /b 0
)
where winget >nul 2>&1
if errorlevel 1 (
  echo Windows installer engine not found, so nothing was removed.
  pause
  exit /b 1
)
REM Validate the entire ledger as data before CMD expands any line as syntax.
powershell -NoProfile -Command "$allowed=$env:APPS -split ' '; $rows=@(Get-Content -LiteralPath $env:DONEFILE -ErrorAction Stop); if($rows.Count -gt 5){exit 1}; foreach($row in $rows){if($allowed -cnotcontains $row){exit 1}}"
if errorlevel 1 (
  echo Install records are invalid. Undo stopped without removing apps.
  pause
  exit /b 1
)
echo Removing only the apps this installer added...
set /a UFAIL=0
set "KEEPFILE=%STATE%\still-installed.txt"
if exist "%KEEPFILE%" del "%KEEPFILE%" >nul 2>&1
if exist "%KEEPFILE%" (
  echo Cannot prepare undo records. Nothing was removed.
  pause
  exit /b 1
)
for /f "usebackq delims=" %%A in ("%DONEFILE%") do (
  set "OK="
  for %%W in (%APPS%) do if /i "%%W"=="%%A" set "OK=1"
  if defined OK (
    echo   Removing %%A ...
    winget uninstall --id "%%A" -e --silent --disable-interactivity --accept-source-agreements >>"%LOG%" 2>&1
    winget list --id "%%A" -e --accept-source-agreements >nul 2>&1
    set "VERIFY_RC=!errorlevel!"
    if not !VERIFY_RC! equ -1978335212 (
      echo   Could not remove %%A. Close it if it is open and run this again.
      >>"%KEEPFILE%" echo %%A
      if errorlevel 1 exit /b 1
      set /a UFAIL+=1
    )
  ) else (
    >>"%KEEPFILE%" echo %%A
    if errorlevel 1 exit /b 1
    set /a UFAIL+=1
  )
)
if !UFAIL! gtr 0 (
  move /y "%KEEPFILE%" "%DONEFILE%" >nul
  if errorlevel 1 exit /b 1
  echo.
  echo Finished, but !UFAIL! could not be removed. Run this again after closing them.
) else (
  del "%DONEFILE%" >nul 2>&1
  if exist "%DONEFILE%" exit /b 1
  echo Done. Apps you already had before were not touched.
)
pause
if !UFAIL! gtr 0 exit /b 1
exit /b 0
