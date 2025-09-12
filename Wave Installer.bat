@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ===================== ELEVATE IF NEEDED =====================
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Requesting admin rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "TargetDir=C:\WaveSetup"
set "InstallerPath=%TargetDir%\Wave-Setup.exe"

:: ===================== MAIN MENU =====================
:mainmenu
cls
title Wave Installer (RedFox)
echo ==================================================
echo              RedFox Wave Installer
echo ==================================================
echo [1] Install Wave 
echo [2] Auto Fix Runtimes 
echo [3] Install Roblox Bootstrapper
echo [X] Exit
echo ==================================================
set /p "MAINCHOICE=Choose option: "

if /I "%MAINCHOICE%"=="1" goto install_wave
if /I "%MAINCHOICE%"=="2" goto Auto_Fix_Runtimes
if /I "%MAINCHOICE%"=="3" goto boot_menu
if /I "%MAINCHOICE%"=="X" exit /b
goto mainmenu

:: ===================== Auto Fix Runtimes =====================
:Auto_Fix_Runtimes
cls
echo ===================== Auto fix Runtimes =====================
echo.
echo ===================== .NET DESKTOP RUNTIMES =====================
echo [*] Downloading .NET 9 Desktop Runtime...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet9.exe'"
if exist "%TargetDir%\dotnet9.exe" start /wait "" "%TargetDir%\dotnet9.exe" /install /quiet /norestart

echo [*] Downloading .NET 8 Desktop Runtime...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet8.exe'"
if exist "%TargetDir%\dotnet8.exe" start /wait "" "%TargetDir%\dotnet8.exe" /install /quiet /norestart

echo [*] Downloading .NET 6 Desktop Runtime...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet6.exe'"
if exist "%TargetDir%\dotnet6.exe" start /wait "" "%TargetDir%\dotnet6.exe" /install /quiet /norestart

echo [Success] .NET runtimes installed.

echo.
echo ===================== VC++ REDISTS =====================
echo [Downloading] VC++ x86 
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -OutFile '%TargetDir%\vcredist_x86.exe'"
if exist "%TargetDir%\vcredist_x86.exe" start /wait "" "%TargetDir%\vcredist_x86.exe" /install /quiet /norestart
echo [Downloading] VC++ x64
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TargetDir%\vcredist_x64.exe'"
if exist "%TargetDir%\vcredist_x64.exe" start /wait "" "%TargetDir%\vcredist_x64.exe" /install /quiet /norestart
echo [Success] VC++ installed.

echo.
echo ===================== NODE.JS LTS =====================
echo [Downloading] Node.JS LTS
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\nodejs.msi'"
if exist "%TargetDir%\nodejs.msi" start /wait msiexec /i "%TargetDir%\nodejs.msi" /quiet /norestart

echo [Success] Node.js installed.

echo.
echo Press any key to go back to mainmenu
pause >nul
goto mainmenu

:: ===================== WAVE FULL INSTALL =====================
:install_wave
cls
echo ===================== CLEANUP =====================
echo [*] Cleaning up old Wave / Bootstrapper / Roblox...
taskkill /f /im "Wave-Setup.exe" >nul 2>&1
taskkill /f /im "Wave.exe" >nul 2>&1
taskkill /f /im "Bloxstrap.exe" >nul 2>&1
taskkill /f /im "Fishstrap.exe" >nul 2>&1
taskkill /f /im "Roblox.exe" >nul 2>&1
rmdir /s /q "%LOCALAPPDATA%\Wave" 2>nul
rmdir /s /q "C:\WaveSetup" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Bloxstrap" 2>nul
rmdir /s /q "C:\Bloxstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Fishstrap" 2>nul
rmdir /s /q "C:\Fishstrap" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Roblox" 2>nul
rmdir /s /q "C:\Roblox" 2>nul
echo [Success] Cleanup done.

:: Recreate folder after cleanup
if not exist "%TargetDir%" mkdir "%TargetDir%"

echo.
echo ===================== SECURITY EXCLUSIONS =====================
set "WavePath=%LOCALAPPDATA%\Wave"
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%TargetDir%'; Add-MpPreference -ExclusionPath '%WavePath%'; Add-MpPreference -ExclusionProcess '%TargetDir%\Wave-Setup.exe'; Add-MpPreference -ExclusionProcess '%WavePath%\Wave.dll'; Add-MpPreference -ExclusionProcess '%WavePath%\Wave.exe'" 2>nul
echo [Success] Defender exclusions added.

echo.
echo ===================== .NET DESKTOP RUNTIMES =====================
echo [*] Downloading .NET 9 Desktop Runtime...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet9.exe'"
if exist "%TargetDir%\dotnet9.exe" start /wait "" "%TargetDir%\dotnet9.exe" /install /quiet /norestart

echo [*] Downloading .NET 8 Desktop Runtime...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet8.exe'"
if exist "%TargetDir%\dotnet8.exe" start /wait "" "%TargetDir%\dotnet8.exe" /install /quiet /norestart

echo [*] Downloading .NET 6 Desktop Runtime...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe' -OutFile '%TargetDir%\dotnet6.exe'"
if exist "%TargetDir%\dotnet6.exe" start /wait "" "%TargetDir%\dotnet6.exe" /install /quiet /norestart

echo [Success] .NET runtimes installed.

echo.
echo ===================== VC++ REDISTS =====================
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -OutFile '%TargetDir%\vcredist_x86.exe'"
if exist "%TargetDir%\vcredist_x86.exe" start /wait "" "%TargetDir%\vcredist_x86.exe" /install /quiet /norestart

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TargetDir%\vcredist_x64.exe'"
if exist "%TargetDir%\vcredist_x64.exe" start /wait "" "%TargetDir%\vcredist_x64.exe" /install /quiet /norestart

echo [Success] VC++ installed.

echo.
echo ===================== NODE.JS LTS =====================
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi' -OutFile '%TargetDir%\nodejs.msi'"
if exist "%TargetDir%\nodejs.msi" start /wait msiexec /i "%TargetDir%\nodejs.msi" /quiet /norestart

echo [Success] Node.js installed.

echo.
echo ===================== WAVE SETUP =====================
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://cdn.wavify.cc/v3/WaveBootstrapper.exe' -OutFile '%InstallerPath%'"
if not exist "%InstallerPath%" (
    echo [Error] Failed to download Wave-Setup.exe
    pause
    goto mainmenu
)
echo [Success] Wave-Setup downloaded.

powershell -NoProfile -Command "$p = Start-Process -FilePath '%InstallerPath%' -Verb RunAs -PassThru; Start-Sleep -Seconds 2; try{$p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High}catch{}"
echo [Success] Wave installed.

pause
cls
goto mainmenu

:: ===================== BOOTSTRAPPER MENU =====================
:boot_menu
cls
echo ================== Roblox Bootstrapper ==================
echo [1] Bloxstrap v2.9.1  (official)
echo [2] Fishstrap v2.9.1.2
echo [3] MTX-Bloxstrap-Installer-2.9.0
echo [B] Back to main menu
echo =========================================================
set "BOOT_EXE=%TargetDir%\Bootstrapper.exe"
set /p "CHOICE=Select option: "

if /I "%CHOICE%"=="1" (
    set "BOOT_NAME=Bloxstrap v2.9.1"
    set "BOOT_URL=https://github.com/bloxstraplabs/bloxstrap/releases/download/v2.9.1/Bloxstrap-v2.9.1.exe"
    goto dl_boot
)
if /I "%CHOICE%"=="2" (
    set "BOOT_NAME=Fishstrap v2.9.1.2"
    set "BOOT_URL=https://github.com/fishstrap/fishstrap/releases/download/v2.9.1.2/Fishstrap-v2.9.1.2.exe"
    goto dl_boot
)
if /I "%CHOICE%"=="3" (
    set "BOOT_NAME=MTX-Bloxstrap-Installer-2.9.0"
    set "BOOT_URL=https://github.com/Syr0nix/-MTX/releases/download/MTX/MTX-Bloxstrap-Installer-2.9.0.exe"
    goto dl_boot
)
if /I "%CHOICE%"=="B" goto mainmenu
goto boot_menu

:dl_boot
echo [*] Downloading %BOOT_NAME% ...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%BOOT_URL%' -OutFile '%BOOT_EXE%'"
if exist "%BOOT_EXE%" (
    echo [Success] %BOOT_NAME% downloaded.
    powershell -NoProfile -Command "Start-Process -FilePath '%BOOT_EXE%' -Verb RunAs"
) else (
    echo [Error] Failed to download %BOOT_NAME%.
)
pause
goto boot_menu
