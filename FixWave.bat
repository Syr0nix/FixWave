@echo off
setlocal EnableExtensions EnableDelayedExpansion
@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ===================== GITHUB AUTO-UPDATE =====================
set "APP_NAME=RedFox Wave Installer"
set "CURRENT_VER=2.0.0"

set "GH_USER=Syr0nix"
set "GH_REPO=FixWave"
set "GH_BRANCH=main"

:: EXACT filename of this script in the repo
:: Example: FixWave.bat
set "GH_BAT_PATH=FixWave.bat"

set "RAW_BASE=https://raw.githubusercontent.com/%GH_USER%/%GH_REPO%/%GH_BRANCH%"
set "VER_URL=%RAW_BASE%/version.txt"
set "BAT_URL=%RAW_BASE%/%GH_BAT_PATH%"

:: Allow --noupdate flag
echo %* | find /I "--noupdate" >nul && goto :after_update

for /f "usebackq delims=" %%V in (`
  powershell -NoProfile -Command ^
  "try { (Invoke-WebRequest -UseBasicParsing '%VER_URL%').Content.Trim() } catch { '' }"
`) do set "LATEST_VER=%%V"

if not defined LATEST_VER goto :after_update
if "%LATEST_VER%"=="%CURRENT_VER%" goto :after_update

echo.
echo [*] %APP_NAME% update available: %CURRENT_VER% -> %LATEST_VER%
echo [*] Downloading update from GitHub...

set "TMP_NEW=%TEMP%\%~n0.update.bat"
powershell -NoProfile -Command ^
  "Invoke-WebRequest -UseBasicParsing '%BAT_URL%' -OutFile '%TMP_NEW%'" || goto :after_update

:: Self-replace safely
set "TARGET=%~f0"
set "SWAP=%TEMP%\rf_update_swap.cmd"
(
  echo @echo off
  echo ping 127.0.0.1 -n 2 ^>nul
  echo copy /y "%TMP_NEW%" "%TARGET%" ^>nul
  echo start "" "%TARGET%"
  echo del "%TMP_NEW%" ^>nul
  echo del "%%~f0" ^>nul
) > "%SWAP%"

echo [*] Applying update...
start "" /min "%SWAP%"
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
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
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
echo ^| [1] Install Wave 2                                                         ^|
echo ^| [2] Install Wave (VPS mode only works with some VPS)                     ^|
echo ^| [3] Install Cloudflare WARP (VPN/ISP Bypass)                             ^|
echo ^| [4] Wave Manual Inject (OutDated)                                        ^|
echo ^| [5] Auto Fix Dependencies (Reinstalls files needed to run wave)          ^|
echo ^| [6] Fix Desktop Path Error (OutDated)                                    ^|
echo ^| [7] (Disabled) Defender Tweaks (not needed)                              ^|
echo ^| [8] Install Roblox Bootstrapper                                          ^|
echo ^| [X] Exit                                                                 ^|
echo +==========================================================================+
echo.
set /p "MAINCHOICE=Choose option: "

if /I "%MAINCHOICE%"=="1" goto install_wave
if /I "%MAINCHOICE%"=="2" goto install_Wave_For_Vps
if /I "%MAINCHOICE%"=="3" goto install_warp
if /I "%MAINCHOICE%"=="4" goto manual_inject
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

:: ===================== VPS MODE =====================
:install_Wave_For_Vps
cls
echo +==========================================================================+
echo ^|                         VPS / SERVER MODE                                ^|
echo +==========================================================================+
echo.
echo [*] Performing cleanup and installing dependencies...
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
if not exist "%TargetDir%" mkdir "%TargetDir%"
if not exist "%LOCALAPPDATA%\Wave" mkdir "%LOCALAPPDATA%\Wave"
if not exist "%LOCALAPPDATA%\Wave\Tabs" mkdir "%LOCALAPPDATA%\Wave\Tabs"
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet9.exe'"
if exist "%TargetDir%\dotnet9.exe" start /wait "" "%TargetDir%\dotnet9.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TargetDir%\vc.exe'"
if exist "%TargetDir%\vc.exe" start /wait "" "%TargetDir%\vc.exe" /install /quiet /norestart
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\node.msi'"
if exist "%TargetDir%\node.msi" start /wait msiexec /i "%TargetDir%\node.msi" /quiet /norestart
echo [*] Downloading Wave.exe...
powershell -NoProfile -Command "Invoke-WebRequest -Uri \"%WaveURL%\" -OutFile \"%InstallerPath%\""
if exist "%InstallerPath%" (
    echo [Success] Wave.exe ready. Run manually as Admin.
) else (
    echo [Error] Download failed.
)
pause
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

:: ===================== WAVE MANUAL INJECT =====================
:manual_inject
cls
echo +==========================================================================+
echo ^|                       WAVE MANUAL INJECT                                 ^|
echo +==========================================================================+
echo.
setlocal EnableDelayedExpansion
set "WaveBin=%LOCALAPPDATA%\Wave\bin"
for /f "delims=" %%D in ('dir "%WaveBin%\version-*" /b /ad /o:-d 2^>nul') do set "LatestVer=%%D" & goto gotVer
:gotVer
if not defined LatestVer (
    echo [Error] No Wave version found.
    pause
    endlocal
    goto mainmenu
)
set "CM=%WaveBin%\!LatestVer!\ClientManager.exe"
if not exist "!CM!" (
    echo [Error] ClientManager not found.
    pause
    endlocal
    goto mainmenu
)
echo [*] Launching ClientManager...
powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c start ""ClientManager"" /high """"!CM!""""' -Verb RunAs"
echo [Success] Launched.
pause
endlocal
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
