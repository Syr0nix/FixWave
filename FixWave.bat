@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ===================== DESKTOP GITHUB AUTO-UPDATE =====================

set "CURRENT_VER=2.1.9"

set "RAW_VER=https://raw.githubusercontent.com/Syr0nix/FixWave/main/version.txt"
set "RAW_BAT=https://raw.githubusercontent.com/Syr0nix/FixWave/main/FixWave.bat"

:: Get Desktop path (works even with OneDrive)
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%D"

set "NEWFILE=%DESKTOP%\FixWave.new.bat"

:: ===================== READ LATEST VERSION =====================
set "LATEST_VER="
for /f "usebackq delims=" %%V in (`
  powershell -NoProfile -Command ^
  "try { (Invoke-WebRequest -UseBasicParsing '%RAW_VER%').Content.Trim() } catch { '' }"
`) do set "LATEST_VER=%%V"

if not defined LATEST_VER goto :after_update
if "%LATEST_VER%"=="%CURRENT_VER%" goto :after_update

echo [UPDATE] %CURRENT_VER% -> %LATEST_VER%
echo [UPDATE] Downloading new version...

powershell -NoProfile -Command ^
  "Invoke-WebRequest -UseBasicParsing '%RAW_BAT%' -OutFile '%NEWFILE%'"

if not exist "%NEWFILE%" (
    echo [UPDATE][FAIL] Download blocked
    pause
    goto :after_update
)

:: ===================== REPLACE SELF =====================
copy /y "%NEWFILE%" "%~f0" >nul
del "%NEWFILE%" >nul

:: Cleanup junk
del "%DESKTOP%\version.txt" >nul 2>&1

echo [UPDATE] Update applied successfully.
echo [UPDATE] Relaunching...
start "" "%~f0"
exit /b

:after_update
:: ===================== END AUTO-UPDATE =====================

title RedFox Wave Installer - v2.0 (Dec 2025)
color 0B

:: ===================== ENABLE ANSI COLORS =====================
for /f "tokens=2 delims=:." %%a in ('ver') do set "ver=%%a"
if %ver% GEQ 10 (
    reg query HKCU\Console 1>nul 2>nul || reg add HKCU\Console >nul
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul
)

:: ===================== ELEVATE IF NEEDED =====================
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ ! ] Requesting admin rights...
      powershell -NoProfile -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ===================== GLOBALS =====================
set "TargetDir=C:\WaveSetup"
set "InstallerPath=%TargetDir%\Wave.exe"
set "WaveURL=https://getwave.gg/downloads/Wave.exe"

goto mainmenu

:: ===================== CREATE DESKTOP SHORTCUT =====================
:CreateDesktopShortcut
set "SC_TARGET=%~1"
set "SC_NAME=%~2"

if not exist "%SC_TARGET%" (
    echo [Error] Target missing: "%SC_TARGET%"
    pause
    goto :eof
)

for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESK=%%D"
set "LNK=%DESK%\%SC_NAME%.lnk"

echo [*] Desktop resolved to: "%DESK%"
echo [*] Creating shortcut: "%LNK%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut('%LNK%'); $s.TargetPath='%SC_TARGET%'; $s.WorkingDirectory=(Split-Path '%SC_TARGET%'); $s.IconLocation='%SC_TARGET%,0'; $s.Save()"

if exist "%LNK%" (
    echo [Success] Shortcut created!
) else (
    echo [Error] Shortcut not found at "%LNK%"
)
goto :eof


:: ===================== MAIN MENU =====================
:mainmenu
cls
echo.
echo +==========================================================================+
echo ^|                    REDFOX WAVE INSTALLER v2.0                            ^|
echo ^|                       (December 2025 Update)                             ^|
echo +==========================================================================+
echo ^| [1] Install Wave                                                         ^|
echo ^| [2] Fix Module Error                                                     ^|
echo ^| [3] Install Cloudflare WARP (VPN/ISP Bypass)                             ^|
echo ^| [4] Whitelist Wave to Anti-Virus (Defender)                              ^|
echo ^| [5] Auto Fix Dependencies (Reinstalls files needed to run wave)          ^|
echo ^| [6] Fix Desktop Path Error (OutDated)                                    ^|
echo ^| [7] (Disabled) Defender Tweaks (not needed)                              ^|
echo ^| [8] Install Roblox Bootstrapper                                          ^|
echo ^| [X] Exit                                                                 ^|
echo +==========================================================================+
echo.
set /p "MAINCHOICE=Choose option: "

if /I "%MAINCHOICE%"=="1" goto install_wave
if /I "%MAINCHOICE%"=="2" goto Fix_Module_Error
if /I "%MAINCHOICE%"=="3" goto install_warp
if /I "%MAINCHOICE%"=="4" goto DEFENDER_EXCLUSIONS
if /I "%MAINCHOICE%"=="5" goto Auto_Fix_Runtimes
if /I "%MAINCHOICE%"=="6" goto Auto_Fix_Error
if /I "%MAINCHOICE%"=="7" goto remove_dcontrol
if /I "%MAINCHOICE%"=="8" goto boot_menu
if /I "%MAINCHOICE%"=="X" exit /b
echo Invalid choice. Try again.
timeout /t 2 >nul
goto mainmenu

:: ===================== WAVE FULL INSTALL =====================
:install_wave
cls
echo +==========================================================================+
echo ^|                          INSTALLING WAVE                                 ^|
echo +==========================================================================+
echo.
echo [*] Cleaning up old files...
taskkill /f /im "Wave.exe" >nul 2>&1
taskkill /f /im "Wave-Setup.exe" >nul 2>&1
taskkill /f /im "Bloxstrap.exe" >nul 2>&1
taskkill /f /im "Fishstrap.exe" >nul 2>&1
taskkill /f /im "Roblox.exe" >nul 2>&1

rmdir /s /q "%LOCALAPPDATA%\Wave.WebView2" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Wave" 2>nul
rmdir /s /q "%TargetDir%" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Bloxstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Fishstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Roblox" 2>nul

echo [Success] Cleanup complete.
if not exist "%TargetDir%" mkdir "%TargetDir%"
if not exist "%LOCALAPPDATA%\Wave" mkdir "%LOCALAPPDATA%\Wave"
if not exist "%LOCALAPPDATA%\Wave\Tabs" mkdir "%LOCALAPPDATA%\Wave\Tabs"

echo.
echo [*] Installing dependencies...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet9.exe'"
if exist "%TargetDir%\dotnet9.exe" start /wait "" "%TargetDir%\dotnet9.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet8.exe'"
if exist "%TargetDir%\dotnet8.exe" start /wait "" "%TargetDir%\dotnet8.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet6.exe'"
if exist "%TargetDir%\dotnet6.exe" start /wait "" "%TargetDir%\dotnet6.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -OutFile '%TargetDir%\vcx86.exe'"
if exist "%TargetDir%\vcx86.exe" start /wait "" "%TargetDir%\vcx86.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TargetDir%\vcx64.exe'"
if exist "%TargetDir%\vcx64.exe" start /wait "" "%TargetDir%\vcx64.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/b92958c6-ae36-4efa-aafe-569fced953a5/1654639ef3b20eb576174c1cc200f33a/windowsdesktop-runtime-3.1.32-win-x64.exe' -OutFile '%TargetDir%\dotnet3.1.32.exe'" >nul 2>&1
if exist "%TargetDir%\dotnet3.1.32.exe" (
    echo Installing .NET 3.1.32...
    start /wait "" "%TargetDir%\dotnet3.1.32.exe" /install /quiet /norestart
)
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\node.msi'"
if exist "%TargetDir%\node.msi" start /wait msiexec /i "%TargetDir%\node.msi" /quiet /norestart

echo [Success] Dependencies installed.

echo.
echo [*] Downloading Wave.exe...
powershell -NoProfile -Command "Invoke-WebRequest -Uri \"%WaveURL%\" -OutFile \"%InstallerPath%\""
if not exist "%InstallerPath%" (
    echo [Error] Download failed. Check internet.
    pause
    goto mainmenu
)
echo [Success] Wave.exe downloaded.
echo.
echo [*] Creating desktop shortcut...
call :CreateDesktopShortcut "%InstallerPath%" "Wave"

echo.
echo [*] Launching Wave.exe...
powershell -NoProfile -Command "Start-Process -FilePath \"%InstallerPath%\" -Verb RunAs"
echo [Success] Wave launched!
timeout /t 4 >nul

echo.
echo +==========================================================================+
echo ^|                NEXT: CHOOSE A ROBLOX BOOTSTRAPPER                        ^|
echo +==========================================================================+
goto boot_menu

:Fix_Module_Error
cls
echo [*] Fixing Wave Module...
echo.

set "MODULE_URL=https://github.com/Syr0nix/FixWave/releases/download/Module/Wave_Module.zip"
set "ZIP_NAME=Wave_Module.zip"
set "DEST_DIR=%LOCALAPPDATA%"

set "WAVE_DIR=%DEST_DIR%\Wave"
set "WV2_DIR=%DEST_DIR%\Wave.WebView2"

echo [*] Target folder: "%DEST_DIR%"
echo.

:: ===================== KILL WAVE PROCESSES =====================
echo [*] Stopping Wave processes...

taskkill /f /im Wave.exe >nul 2>&1
taskkill /f /im msedgewebview2.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1

timeout /t 2 >nul

:: ===================== CLEAN OLD FILES =====================
echo [*] Removing old Wave folders...

if exist "%WAVE_DIR%" (
    echo     - Deleting "%WAVE_DIR%"
    rmdir /s /q "%WAVE_DIR%"
)

if exist "%WV2_DIR%" (
    echo     - Deleting "%WV2_DIR%"
    rmdir /s /q "%WV2_DIR%"
)

:: ===================== VERIFY DELETE =====================
if exist "%WAVE_DIR%" (
    echo [ERROR] Failed to delete "%WAVE_DIR%"
    pause
    goto mainmenu
)

if exist "%WV2_DIR%" (
    echo [ERROR] Failed to delete "%WV2_DIR%"
    pause
    goto mainmenu
)

echo [*] Cleanup complete.
echo.

:: ===================== DOWNLOAD MODULE =====================
echo [*] Downloading module...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Invoke-WebRequest -Uri '%MODULE_URL%' -OutFile '%DEST_DIR%\%ZIP_NAME%'"

if not exist "%DEST_DIR%\%ZIP_NAME%" (
    echo [ERROR] Download failed.
    pause
    goto mainmenu
)

:: ===================== EXTRACT MODULE =====================
echo [*] Extracting module...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Expand-Archive -Force '%DEST_DIR%\%ZIP_NAME%' '%DEST_DIR%'"

:: ===================== CLEAN ZIP =====================
del "%DEST_DIR%\%ZIP_NAME%" >nul 2>&1

echo.
echo [*] Wave module fixed successfully.
echo [*] Launching Wave...

set "WAVE_EXE="

:: ===================== DESKTOP =====================
if exist "%USERPROFILE%\Desktop\wave.lnk" (
    echo     - Found Desktop shortcut
    start "" "%USERPROFILE%\Desktop\wave.lnk"
    goto :LaunchDone
)

if exist "%USERPROFILE%\Desktop\wave.exe" (
    echo     - Found Desktop exe
    start "" "%USERPROFILE%\Desktop\wave.exe"
    goto :LaunchDone
)

:: ===================== DOWNLOADS =====================
if exist "%USERPROFILE%\Downloads\wave.exe" (
    echo     - Found Downloads exe
    start "" "%USERPROFILE%\Downloads\wave.exe"
    goto :LaunchDone
)

:: ===================== WAVESETUP =====================
if exist "%USERPROFILE%\WaveSetup\Wave.exe" (
    echo     - Found WaveSetup exe
    start "" "%USERPROFILE%\WaveSetup\Wave.exe"
    goto :LaunchDone
)

echo [WARN] Wave.exe not found in expected locations.
echo        Please launch Wave manually.
timeout /t 3 >nul
goto mainmenu

:LaunchDone
echo [*] Wave launched successfully.
timeout /t 2 >nul
goto mainmenu


:: ===================== INSTALL CLOUDFLARE WARP =====================
:install_warp
cls
echo +==========================================================================+
echo ^|                  INSTALLING CLOUDFLARE WARP (VPN)                        ^|
echo +==========================================================================+
echo.
if not exist "%TargetDir%" mkdir "%TargetDir%"
echo [*] Downloading...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi' -OutFile '%TargetDir%\warp.msi'"
if not exist "%TargetDir%\warp.msi" (
    echo [Error] Download failed.
    pause
    goto mainmenu
)
echo [*] Installing...
start /wait msiexec /i "%TargetDir%\warp.msi" /quiet /norestart
set "WarpCliPath=%ProgramFiles%\Cloudflare\Cloudflare WARP\warp-cli.exe"
if exist "%WarpCliPath%" (
    "%WarpCliPath%" registration new >nul
    "%WarpCliPath%" mode warp >nul
    "%WarpCliPath%" connect >nul
    echo [Success] WARP connected!
) else (
    echo [Error] Installed but cli missing.
)
pause
goto mainmenu

:: ===================== AUTO FIX RUNTIMES =====================
:Auto_Fix_Runtimes
cls
echo +==========================================================================+
echo ^|                     AUTO FIX DEPENDENCIES                                ^|
echo +==========================================================================+
echo.
if not exist "%TargetDir%" mkdir "%TargetDir%"
echo [*] Removing NODE_OPTIONS...
set "FOUND=0"
reg query "HKCU\Environment" /v NODE_OPTIONS >nul 2>&1
if %errorlevel%==0 (
    reg delete "HKCU\Environment" /F /V NODE_OPTIONS >nul
    echo [+] Removed from User.
    set "FOUND=1"
)
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v NODE_OPTIONS >nul 2>&1
if %errorlevel%==0 (
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V NODE_OPTIONS >nul
    echo [+] Removed from System.
    set "FOUND=1"
)
if %FOUND%==0 echo [!] Not found.
echo.
echo [*] Reinstalling runtimes...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet9.exe'"
if exist "%TargetDir%\dotnet9.exe" start /wait "" "%TargetDir%\dotnet9.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet8.exe'"
if exist "%TargetDir%\dotnet8.exe" start /wait "" "%TargetDir%\dotnet8.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet6.exe'"
if exist "%TargetDir%\dotnet6.exe" start /wait "" "%TargetDir%\dotnet6.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -OutFile '%TargetDir%\vcx86.exe'"
if exist "%TargetDir%\vcx86.exe" start /wait "" "%TargetDir%\vcx86.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TargetDir%\vcx64.exe'"
if exist "%TargetDir%\vcx64.exe" start /wait "" "%TargetDir%\vcx64.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/b92958c6-ae36-4efa-aafe-569fced953a5/1654639ef3b20eb576174c1cc200f33a/windowsdesktop-runtime-3.1.32-win-x64.exe' -OutFile '%TargetDir%\dotnet3.1.32.exe'" >nul 2>&1
if exist "%TargetDir%\dotnet3.1.32.exe" (
    echo Installing .NET 3.1.32...
    start /wait "" "%TargetDir%\dotnet3.1.32.exe" /install /quiet /norestart
)
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\node.msi'"
if exist "%TargetDir%\node.msi" start /wait msiexec /i "%TargetDir%\node.msi" /quiet /norestart
echo [Success] Repair complete.
pause
goto mainmenu

:: ===================== AUTO FIX DESKTOP ERROR =====================
:Auto_Fix_Error
cls
echo +==========================================================================+
echo ^|                     FIXING DESKTOP PATH ERROR                            ^|
echo +==========================================================================+
echo.
for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul') do set "DesktopPath=%%B"
if /I "%DesktopPath%" NEQ "%%USERPROFILE%%\Desktop" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop /t REG_EXPAND_SZ /d %%USERPROFILE%%\Desktop /f >nul
    echo [Success] Fixed.
) else echo [OK] Already correct.
echo Restarting in 5 seconds...
timeout /t 5 >nul
shutdown /r /t 0

:: ===================== DEFENDER_EXCLUSIONS =====================
:DEFENDER_EXCLUSIONS
cls
title Wave Installer - Defender Whitelist

NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Admin rights required.
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ---- Paths to whitelist ----
set "WAVE_INSTALL=C:\WaveSetup"
set "WAVE_DIR=%LOCALAPPDATA%\Wave"
set "WAVE_WEBVIEW=%LOCALAPPDATA%\Wave.WebView2"

echo [+] Adding Windows Defender exclusions:
echo     %WAVE_INSTALL%
echo     %WAVE_DIR%
echo     %WAVE_WEBVIEW%
echo.

:: ---- Apply exclusions (idempotent) ----
powershell -NoProfile -Command ^
"Add-MpPreference -ExclusionPath '%WAVE_INSTALL%' -ErrorAction SilentlyContinue; ^
 Add-MpPreference -ExclusionPath '%WAVE_DIR%' -ErrorAction SilentlyContinue; ^
 Add-MpPreference -ExclusionPath '%WAVE_WEBVIEW%' -ErrorAction SilentlyContinue"

echo [+] Defender exclusions applied.
echo.
pause
goto mainmenu

:: ===================== DEFENDER INFO =====================
:remove_dcontrol
cls
echo +==========================================================================+
echo ^|                        WINDOWS DEFENDER INFO                             ^|
echo +==========================================================================+
echo.
echo [Disabled] No tweaks.
echo Run in Admin CMD:
echo sfc /scannow
echo DISM /Online /Cleanup-Image /RestoreHealth
pause
goto mainmenu

:: ===================== BOOTSTRAPPER MENU =====================
:boot_menu
cls
echo +==========================================================================+
echo ^|                     ROBLOX BOOTSTRAPPER MENU                             ^|
echo +==========================================================================+
echo.
echo [1] Bloxstrap v2.9.1 (official - recommended)
echo [2] Fishstrap v2.9.1.2 (FPS unlocker)
echo [3] MTX-Bloxstrap-Installer-2.9.0 (advanced)
echo [B] Back to main menu
echo.
set /p "CHOICE=Select: "
set "BOOT_NAME="
set "BOOT_URL="
if /I "%CHOICE%"=="1" (
    set "BOOT_NAME=Bloxstrap v2.9.1"
    set "BOOT_URL=https://github.com/bloxstraplabs/bloxstrap/releases/download/v2.9.1/Bloxstrap-v2.9.1.exe"
)
if /I "%CHOICE%"=="2" (
    set "BOOT_NAME=Fishstrap v2.9.1.2"
    set "BOOT_URL=https://github.com/fishstrap/fishstrap/releases/download/v2.9.1.2/Fishstrap-v2.9.1.2.exe"
)
if /I "%CHOICE%"=="3" (
    set "BOOT_NAME=MTX-Bloxstrap-Installer-2.9.0"
    set "BOOT_URL=https://github.com/Syr0nix/-MTX/releases/download/MTX/MTX-Bloxstrap-Installer-2.9.0.exe"
)
if /I "%CHOICE%"=="B" goto mainmenu
if not defined BOOT_NAME goto boot_menu

if not exist "%TargetDir%\Boot" mkdir "%TargetDir%\Boot"
set "BOOT_EXE=%TargetDir%\Boot\%BOOT_NAME%.exe"
echo.
echo [*] Downloading %BOOT_NAME%...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%BOOT_URL%' -OutFile '%BOOT_EXE%'"
if exist "%BOOT_EXE%" (
    echo [Success] Downloaded.
    powershell -NoProfile -Command "Start-Process -FilePath '%BOOT_EXE%' -Verb RunAs"
) else (
    echo [Error] Failed.
)
echo.
echo Saved in C:\WaveSetup\Boot
pause

goto mainmenu





