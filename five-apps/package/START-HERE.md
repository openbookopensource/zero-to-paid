# Five Apps — test candidate

This package is for a disposable Windows test PC until real installation checks pass. It needs Windows 11, internet access, current Microsoft App Installer, an administrator account and at least 5 GB free space. Do not use it on a managed work PC without your IT team's permission.

1. Extract the ZIP into a folder. Review `Install-5-Apps.bat`. For a preview, open Command Prompt in that folder and run `Install-5-Apps.bat /dryrun`.
2. Double-click `Install-5-Apps.bat`. Approve Windows administrator access only if you trust the package. If Windows or your browser blocks the file, stop and ask the supplier; do not disable protection.
3. Read `5-Apps-Install-Report.txt` on your Desktop and open each app from Start. Keep the package for undo.

Includes Chrome (browser), VLC (media player), 7-Zip (archives), Zoom (meetings) and Notepad++ (text editor). The apps are free to obtain separately; some services or features can have charges. Installation accepts the packages' applicable licence agreements through winget; review those terms before running.

Already installed apps are skipped. No app upgrades are requested. Downloads come through the winget community source; publisher download locations vary. Windows and the apps can make their own network requests. This wrapper contains no telemetry or background service.

## Undo and help

Use the same Windows administrator account for installation and undo. Close the apps and double-click `Uninstall-5-Apps.bat`. Undo attempts to remove tracked additions only; it is not a backup and may remove app settings. Review the Windows Installed apps page afterwards. If an app was later removed and reinstalled independently, remove it from the tracked list before using undo, or uninstall manually instead.

The tracking file is `%LOCALAPPDATA%\FiveApps\installed-by-us.txt`. Do not edit it unless resolving a tracking problem. If installation fails, read the Desktop report. The diagnostic log is `%TEMP%\5-apps-install-log.txt`. Check logs for personal paths before sharing them with the person who supplied this package.

If winget is missing, update Microsoft App Installer through Microsoft Store and retry. If the network check fails, check the connection or ask IT about network policy. A partial install can leave some apps installed; rerun to check them again or use undo. No commercial support promise is made for this test candidate.
