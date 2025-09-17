@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ===================== ENABLE ANSI COLORS =====================
for /f "tokens=2 delims=:." %%a in ('ver') do set "ver=%%a"
if %ver% GEQ 10 (
    reg query HKCU\Console 1>nul 2>nul || reg add HKCU\Console >nul
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul
)

:: ===================== ELEVATE IF NEEDED =====================
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [93m[!][0m Requesting admin rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "TargetDir=C:\WaveSetup"
set "InstallerPath=%TargetDir%\Wave-Setup.exe"
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess '%~f0'"
:: ===================== MAIN MENU =====================
:mainmenu
cls
title Wave Installer (RedFox)
echo [96m==================================================[0m
echo         [96mRedFox Wave Installer/Repair Tool[0m
echo [96m==================================================[0m
echo [93m[1][0m Install Wave
echo [93m[2][0m Install Wave For VPS 
echo [93m[3][0m Install Cloudflare WARP VPN
echo [93m[4][0m Auto Fix Runtimes 
echo [93m[5][0m Auto Fix Volume Label Syntax Error
echo [93m[6][0m Install Roblox Bootstrapper
echo [91m[X][0m Exit
echo [96m==================================================[0m
set /p "MAINCHOICE=Choose option: "

if /I "%MAINCHOICE%"=="1" goto install_wave
if /I "%MAINCHOICE%"=="2" goto install_Wave_For_Vps
if /I "%MAINCHOICE%"=="3" goto install_warp
if /I "%MAINCHOICE%"=="4" goto Auto_Fix_Runtimes
if /I "%MAINCHOICE%"=="5" goto Auto_Fix_Error
if /I "%MAINCHOICE%"=="6" goto boot_menu
if /I "%MAINCHOICE%"=="X" exit /b
goto mainmenu

:: ===================== WAVE FULL INSTALL =====================
:install_wave
cls
echo [96m===================== CLEANUP =====================[0m
echo [93m[*][0m Removing old Wave / Bootstrapper / Roblox...
taskkill /f /im "Wave-Setup.exe" >nul 2>&1
taskkill /f /im "Wave.exe" >nul 2>&1
taskkill /f /im "Bloxstrap.exe" >nul 2>&1
taskkill /f /im "Fishstrap.exe" >nul 2>&1
taskkill /f /im "Roblox.exe" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Wave" 2>nul
rmdir /s /q "C:\WaveSetup" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Bloxstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Fishstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Roblox" 2>nul
echo [92m[Success][0m Cleanup done.

if not exist "%TargetDir%" mkdir "%TargetDir%"

echo.
echo [96m================= SECURITY EXCLUSIONS =================[0m
set "WavePath=%LOCALAPPDATA%\Wave"
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%TargetDir%'; Add-MpPreference -ExclusionPath '%WavePath%'; Add-MpPreference -ExclusionProcess '%TargetDir%\Wave-Setup.exe'; Add-MpPreference -ExclusionProcess '%WavePath%\Wave.exe'" 2>nul
echo [92m[Success][0m Defender exclusions added.

echo.
echo [96m================= DEPENDENCIES =================[0m
echo [93m[*][0m Installing .NET Runtimes, VC++ and Node.js...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet9.exe'"
if exist "%TargetDir%\dotnet9.exe" start /wait "" "%TargetDir%\dotnet9.exe" /install /quiet /norestart

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TargetDir%\vc.exe'"
if exist "%TargetDir%\vc.exe" start /wait "" "%TargetDir%\vc.exe" /install /quiet /norestart

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\node.msi'"
if exist "%TargetDir%\node.msi" start /wait msiexec /i "%TargetDir%\node.msi" /quiet /norestart

echo [92m[Success][0m Dependencies installed.

echo.
echo [96m================= WAVE SETUP =================[0m
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://cdn.wavify.cc/v3/WaveBootstrapper.exe' -OutFile '%InstallerPath%'"
if not exist "%InstallerPath%" (
    echo [91m[Error][0m Failed to download Wave-Setup.exe
    pause
    goto mainmenu
)
powershell -NoProfile -Command "Start-Process -FilePath '%InstallerPath%' -Verb RunAs"
echo [92m[Success][0m Wave installed.

echo.
echo [96m================= NEXT STEP =================[0m
echo Launching Bootstrapper menu now...
timeout /t 5
goto boot_menu

:: ===================== WAVE INSTALL (VPS MODE) =====================
:install_Wave_For_Vps
cls
echo [96m================= WAVE INSTALL (VPS MODE) =================[0m

echo [93m[*][0m Removing old Wave / Bootstrapper / Roblox...
taskkill /f /im "Wave-Setup.exe" >nul 2>&1
taskkill /f /im "Wave.exe" >nul 2>&1
taskkill /f /im "Bloxstrap.exe" >nul 2>&1
taskkill /f /im "Fishstrap.exe" >nul 2>&1
taskkill /f /im "Roblox.exe" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Wave" 2>nul
rmdir /s /q "C:\WaveSetup" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Bloxstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Fishstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Roblox" 2>nul
echo [92m[Success][0m Cleanup done.
if not exist "%TargetDir%" mkdir "%TargetDir%"

echo [93m[*][0m Installing runtimes and Node.js...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet9.exe'"
if exist "%TargetDir%\dotnet9.exe" start /wait "" "%TargetDir%\dotnet9.exe" /install /quiet /norestart

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TargetDir%\vc.exe'"
if exist "%TargetDir%\vc.exe" start /wait "" "%TargetDir%\vc.exe" /install /quiet /norestart

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\node.msi'"
if exist "%TargetDir%\node.msi" start /wait msiexec /i "%TargetDir%\node.msi" /quiet /norestart

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://cdn.wavify.cc/v3/WaveBootstrapper.exe' -OutFile '%InstallerPath%'"
if exist "%InstallerPath%" (
    powershell -NoProfile -Command "Start-Process -FilePath '%InstallerPath%' -Verb RunAs"
    echo [92m[Success][0m Wave installed.
) else (
    echo [91m[Error][0m Failed to download Wave-Setup.exe
)

echo.
echo [96m================= NEXT STEP =================[0m
echo Launching Bootstrapper menu now...
timeout /t 5
goto boot_menu

:: ===================== INSTALL CLOUDFLARE WARP =====================
:install_warp
cls
echo [96m================= INSTALLING CLOUDFLARE WARP =================[0m
if not exist "%TargetDir%" mkdir "%TargetDir%"

echo [93m[*][0m Downloading Cloudflare WARP...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi' -OutFile '%TargetDir%\warp.msi'"

if not exist "%TargetDir%\warp.msi" (
    echo [91m[Error][0m Failed to download WARP installer.
    pause
    goto mainmenu
)

echo [93m[*][0m Installing Cloudflare WARP...
start /wait msiexec /i "%TargetDir%\warp.msi" /quiet /norestart

set "WarpCliPath=%ProgramFiles%\Cloudflare\Cloudflare WARP\warp-cli.exe"
if not exist "%WarpCliPath%" (
    echo [91m[Error][0m warp-cli not found after install. Try rebooting.
    pause
    goto mainmenu
)

echo [93m[*][0m Configuring WARP...
"%WarpCliPath%" registration new
"%WarpCliPath%" mode warp
"%WarpCliPath%" connect

echo [92m[Success][0m Cloudflare WARP installed and connected!
pause
goto mainmenu


:: ===================== AUTO FIX RUNTIMES =====================
:Auto_Fix_Runtimes
cls
echo [96m================= AUTO FIX RUNTIMES =================[0m
if not exist "%TargetDir%" mkdir "%TargetDir%"

echo [93m[*][0m Installing .NET 6/8/9, VC++ x86/x64, Node.js...
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

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\node.msi'"
if exist "%TargetDir%\node.msi" start /wait msiexec /i "%TargetDir%\node.msi" /quiet /norestart

echo [92m[Success][0m Runtimes and dependencies reinstalled.
pause
goto mainmenu

:: ===================== AUTO FIX DESKTOP ERROR =====================
:Auto_Fix_Error
cls
echo [96m================= AUTO FIX DESKTOP KEY =================[0m

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop /t REG_EXPAND_SZ /d %%USERPROFILE%%\Desktop /f

echo [92m[Success][0m Desktop registry entry fixed.
echo Restarting your PC now...
timeout /t 5 /nobreak >nul
shutdown /r /t 0

:: ===================== BOOTSTRAPPER MENU =====================
:boot_menu
cls
echo [96m================= ROBLOX BOOTSTRAPPER =================[0m
echo [93m[1][0m Bloxstrap v2.9.1  (official)
echo [93m[2][0m Fishstrap v2.9.1.2
echo [93m[3][0m MTX-Bloxstrap-Installer-2.9.0
echo [91m[B][0m Back to main menu
echo [96m========================================================[0m
set /p "CHOICE=Select option: "

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

echo [93m[*][0m Downloading %BOOT_NAME%...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%BOOT_URL%' -OutFile '%BOOT_EXE%'"

if exist "%BOOT_EXE%" (
    echo [92m[Success][0m %BOOT_NAME% downloaded.
    powershell -NoProfile -Command "Start-Process -FilePath '%BOOT_EXE%' -Verb RunAs"
) else (
    echo [91m[Error][0m Failed to download %BOOT_NAME%.
)

echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainmenu
