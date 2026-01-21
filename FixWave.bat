@echo off
setlocal EnableExtensions EnableDelayedExpansion

::  Copyright (c) 2026 RedFox
::  All rights reserved.
::
::  Unauthorized copying, modification, or redistribution
::  of this script, in whole or in part, is strictly prohibited.

:: ===================== DESKTOP GITHUB AUTO-UPDATE =====================

set "CURRENT_VER=2.3.2"

set "RAW_VER=https://raw.githubusercontent.com/Syr0nix/FixWave/main/version.txt"
set "RAW_BAT=https://raw.githubusercontent.com/Syr0nix/FixWave/main/FixWave.bat"

:: Get Desktop path (works even with OneDrive)
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%D"

set "NEWFILE=%DESKTOP%\FixWave.bat"

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

:: ===================== CLEANUP VERSION MARKER FILES =====================
del "%DESKTOP%\version.txt" >nul 2>&1

:: Delete common marker names (current + latest)
del "%DESKTOP%\%LATEST_VER%" >nul 2>&1
del "%DESKTOP%\%CURRENT_VER%" >nul 2>&1

:: Delete any leftover "1.2.3" style marker files on Desktop (no extension)
for /f "delims=" %%F in ('dir /b "%DESKTOP%" ^| findstr /R "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"') do (
    del "%DESKTOP%\%%F" >nul 2>&1
)

:: Cleanup junk
del "%DESKTOP%\version.txt" >nul 2>&1

echo [UPDATE] Update applied successfully.
echo [UPDATE] Relaunching...
start "" "%~f0"
exit /b

:after_update
:: ===================== END AUTO-UPDATE =======================

title RedFox Wave Installer - v2.0
color 0B

:: ===================== ENABLE ANSI COLORS =====================
set "WINMAJOR="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command ^
  "$v=[Environment]::OSVersion.Version.Major; if($v){$v}"`
) do set "WINMAJOR=%%V"

if defined WINMAJOR (
    for /f "delims=0123456789" %%Z in ("%WINMAJOR%") do set "WINMAJOR="
)

if defined WINMAJOR if %WINMAJOR% GEQ 10 (
    reg query "HKCU\Console" >nul 2>&1 || reg add "HKCU\Console" >nul
    reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)


:: ===================== ELEVATE IF NEEDED =====================
set "SELF=%~f0"

NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ ! ] Requesting admin rights...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Start-Process -FilePath '%SELF%' -Verb RunAs -ArgumentList @('-elevated')"
    exit /b
)

if /I "%~1"=="-elevated" shift


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
echo ^|                         REDFOX WAVE INSTALLER                            ^|
echo ^|                      (Install. Repair. Move on.)                         ^|
echo ^|             Copyright (c) 2026 RedFox All rights reserved.               ^|
echo +==========================================================================+
echo ^| [1] Install Wave                                                         ^|
echo ^| [2] Fix Module Error                                                     ^|
echo ^| [3] Fix loader Error / Initializing Issue                                ^|
echo ^| [4] Fix Dependencies (Reinstalls files needed to run wave)               ^|
echo ^| [5] Fix Failed to Generate HWID - Invalid Class                          ^|
echo ^| [6] Fix Invalid License / Expired License Error                          ^|
echo ^| [7] Install Cloudflare WARP (VPN/ISP Bypass)                             ^|
echo ^| [8] Whitelist Wave to Anti-Virus (Defender)                              ^|
echo ^| [9] Install Roblox Bootstrapper                                          ^|
echo +==========================================================================+
echo ^| [X] Exit                                                                 ^|
echo +==========================================================================+
echo.
set /p "MAINCHOICE=Choose option: "

if /I "%MAINCHOICE%"=="1" goto install_wave
if /I "%MAINCHOICE%"=="2" goto Fix_Module_Error
if /I "%MAINCHOICE%"=="3" goto Loader_fix
if /I "%MAINCHOICE%"=="4" goto Auto_Fix_Runtimes
if /I "%MAINCHOICE%"=="5" goto Auto_Fix_HWID
if /I "%MAINCHOICE%"=="6" goto TIME_DNS_FIX
if /I "%MAINCHOICE%"=="7" goto install_warp
if /I "%MAINCHOICE%"=="8" goto DEFENDER_EXCLUSIONS
if /I "%MAINCHOICE%"=="9" goto boot_menu
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
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Admin rights required.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList @('-elevated')"
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


:DEFENDER_EXCLUSIONS
cls
:: Ensure variables exist no matter where we came from
set "WAVE_INSTALL=C:\WaveSetup"
set "WAVE_DIR=%LOCALAPPDATA%\Wave"
set "WAVE_WEBVIEW=%LOCALAPPDATA%\Wave.WebView2"

echo [+] Adding Windows Defender exclusions:
echo     %WAVE_INSTALL%
echo     %WAVE_DIR%
echo     %WAVE_WEBVIEW%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try { ^
  Add-MpPreference -ExclusionPath '%WAVE_INSTALL%' -ErrorAction Stop; ^
  Add-MpPreference -ExclusionPath '%WAVE_DIR%' -ErrorAction Stop; ^
  Add-MpPreference -ExclusionPath '%WAVE_WEBVIEW%' -ErrorAction Stop; ^
  Write-Host '[OK] Exclusions added.' ^
} catch { ^
  Write-Host '[FAIL]' $_.Exception.Message ^
  exit 1 ^
}"

if %errorlevel% neq 0 (
  echo.
  echo [!] Defender exclusions failed.
  echo     - If you are using a stripped Windows build, Defender cmdlets may be missing.
  echo     - If Tamper Protection is on, exclusions may be blocked.
  pause
  goto mainmenu
)

echo.
echo [+] All Defender exclusions applied!
pause
goto mainmenu

:Fix_Module_Error
cls
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Admin rights required.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList @('-elevated')"
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

echo [*] Fixing Wave Module...
echo.

set "MODULE_URL=https://github.com/Syr0nix/FixWave/releases/download/Module/KjstrpRGru2V.k8.8K6.75bW.8.q6Z8h2G7PjG6.H.Gjt4pz692XU7JRYW4B3tPm.zip"
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

:Loader_fix
cls
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Admin rights required.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList @('-elevated')"
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

powershell -NoProfile -Command ^
"Add-MpPreference -ExclusionPath '%WAVE_INSTALL%' -ErrorAction SilentlyContinue; ^
 Add-MpPreference -ExclusionPath '%WAVE_DIR%' -ErrorAction SilentlyContinue; ^
 Add-MpPreference -ExclusionPath '%WAVE_WEBVIEW%' -ErrorAction SilentlyContinue"

echo [+] Defender exclusions applied.
echo.

echo [*] Fixing Wave Loader...
echo.

:: ===================== KILL WAVE PROCESSES =====================
echo [*] Stopping Wave processes...
taskkill /f /im Wave.exe >nul 2>&1
taskkill /f /im msedgewebview2.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
timeout /t 2 >nul

:: ===================== DOWNLOAD LOADER ZIP =====================
set "WAVE_LOADER_DIR=%LOCALAPPDATA%\wave"
set "ZIP_URL=https://github.com/Syr0nix/FixWave/releases/download/Module/aD.Y.j83B68yeBne2S7P6qmy9n3q.r76D534v5xjETjsNuJQMKx.KAx6Re9.apae.zip"
set "ZIP_PATH=%TEMP%\Loader.zip"

if not exist "%WAVE_LOADER_DIR%" mkdir "%WAVE_LOADER_DIR%"

echo [*] Downloading Loader.zip...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try { ^
  Invoke-WebRequest -UseBasicParsing -Uri '%ZIP_URL%' -OutFile '%ZIP_PATH%' -ErrorAction Stop; ^
  exit 0 ^
} catch { ^
  Write-Host '[ERROR] Download failed:' $_.Exception.Message; ^
  exit 1 ^
}"

if errorlevel 1 (
    echo [ERROR] Failed to download Loader.zip
    echo        URL:  %ZIP_URL%
    echo        Path: %ZIP_PATH%
    pause
    goto mainmenu
)

if not exist "%ZIP_PATH%" (
    echo [ERROR] Download reported success but file is missing.
    echo        Path: %ZIP_PATH%
    pause
    goto mainmenu
)

for %%A in ("%ZIP_PATH%") do echo [*] Downloaded bytes: %%~zA
echo.

:: ===================== EXTRACT LOADER =====================
echo [*] Extracting Loader...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try { ^
  Expand-Archive -Force '%ZIP_PATH%' '%WAVE_LOADER_DIR%' -ErrorAction Stop; ^
  exit 0 ^
} catch { ^
  Write-Host '[ERROR] Extract failed:' $_.Exception.Message; ^
  exit 1 ^
}"

del "%ZIP_PATH%" >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Extraction failed.
    pause
    goto mainmenu
)

:: Find Loader.exe even if it extracted into a subfolder
set "FOUND_LOADER="
for /r "%WAVE_LOADER_DIR%" %%F in (Loader.exe) do (
    set "FOUND_LOADER=%%F"
    goto :LoaderFound
)

:LoaderFound
if defined FOUND_LOADER (
    echo [+] Loader installed: "%FOUND_LOADER%"
) else (
    echo [ERROR] Loader.exe not found after extraction.
    echo [*] Files containing "loader" under "%WAVE_LOADER_DIR%":
    dir /s /b "%WAVE_LOADER_DIR%" | findstr /i "loader"
    pause
    goto mainmenu
)

echo.

:: ===================== LAUNCH WAVE =====================
if exist "%USERPROFILE%\Desktop\wave.lnk" (
    echo     - Found Desktop shortcut
    start "" "%USERPROFILE%\Desktop\wave.lnk"
    goto :LoaderLaunchDone
)

if exist "%USERPROFILE%\Desktop\wave.exe" (
    echo     - Found Desktop exe
    start "" "%USERPROFILE%\Desktop\wave.exe"
    goto :LoaderLaunchDone
)

if exist "%USERPROFILE%\Downloads\wave.exe" (
    echo     - Found Downloads exe
    start "" "%USERPROFILE%\Downloads\wave.exe"
    goto :LoaderLaunchDone
)

if exist "%USERPROFILE%\WaveSetup\Wave.exe" (
    echo     - Found WaveSetup exe
    start "" "%USERPROFILE%\WaveSetup\Wave.exe"
    goto :LoaderLaunchDone
)

if exist "%LOCALAPPDATA%\wave\wave.exe" (
    echo     - Found LocalAppData exe
    start "" "%LOCALAPPDATA%\wave\wave.exe"
    goto :LoaderLaunchDone
)

echo [WARN] Wave.exe not found.
pause
goto mainmenu

:LoaderLaunchDone
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

:: ===================== TIME_CLOCK_SYNC + FLUSH_DNS =====================
:TIME_DNS_FIX
cls
color 0B

echo ==========================================
echo   Time Clock Sync + DNS Flush
echo ==========================================
echo.

:: ===================== TIME SYNC =====================
echo [1/3] Enabling Windows Time service...
sc config w32time start= auto >nul 2>&1
net start w32time >nul 2>&1

echo [2/3] Forcing time resync...
w32tm /resync /force >nul 2>&1

:: Fallback (some stripped OS builds need this)
powershell -NoProfile -Command "Set-Date (Get-Date)" >nul 2>&1

echo [+] Time synchronization complete.
echo.

:: ===================== DNS FLUSH =====================
echo [3/3] Flushing DNS cache...
ipconfig /flushdns

echo.
echo ==========================================
echo   Fix complete.
echo   If license errors persist, reboot.
echo ==========================================
echo.

pause
goto mainmenu


:: ===================== AUTO_FIX_HWID (REBOOT ONLY IF NEEDED) =====================
:Auto_Fix_HWID
cls
set "NEED_REBOOT=0"

echo ==========================================
echo   Auto Fix HWID - WMI Repair Tool
echo ==========================================
echo.

:: ---- Test UUID (modern, no WMIC) ----
echo [1] Testing HWID via CIM...
powershell -NoProfile -Command ^
"$u=(Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID; ^
 if($u){Write-Host '[OK] UUID:' $u; exit 0} else {exit 1}"

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [*] HWID is already working. No fix needed.
    pause
    goto mainmenu
)

echo [!] HWID failed. Starting repair...
echo.

:: ---- Verify / salvage repository ----
echo [2] Verifying WMI repository...
winmgmt /verifyrepository | find /I "inconsistent" >nul
IF %ERRORLEVEL% EQU 0 (
    echo [!] Repository inconsistent. Salvaging...
    winmgmt /salvagerepository
    set "NEED_REBOOT=1"
) ELSE (
    echo [OK] Repository appears consistent (still may be missing classes).
)

:: ---- Re-test after salvage ----
echo.
echo [3] Re-testing HWID after salvage...
powershell -NoProfile -Command ^
"$u=(Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID; ^
 if($u){Write-Host '[OK] UUID:' $u; exit 0} else {exit 1}"

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [*] Fixed without rebuild.
    echo.
    if "%NEED_REBOOT%"=="1" (
        echo [!] Recommended: reboot to fully reload WMI providers.
        choice /C YN /N /M "Reboot now? (Y/N): "
        if errorlevel 2 goto mainmenu
        shutdown /r /t 5 /c "Auto Fix HWID - Rebooting to finalize WMI repair"
        exit /b
    ) else (
        pause
        goto mainmenu
    )
)

:: ---- Rebuild WMI safely (only if still broken) ----
echo.
echo [4] Rebuilding WMI repository (safe rename)...
set "NEED_REBOOT=1"

net stop winmgmt /y >nul 2>&1
if exist "%windir%\System32\wbem\Repository" (
    ren "%windir%\System32\wbem\Repository" Repository.old_%RANDOM%
)
net start winmgmt >nul 2>&1

:: ---- Repair system files ----
echo.
echo [5] Repairing system files (DISM + SFC)...
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow

:: ---- Re-register WMI ----
echo.
echo [6] Re-registering WMI components...
cd /d %windir%\System32\wbem
for %%i in (*.dll) do regsvr32 /s %%i
for %%i in (*.mof *.mfl) do mofcomp %%i

echo.
echo ==========================================
echo   Repair complete.
echo   Reboot is REQUIRED to finish.
echo ==========================================
echo.

choice /C YN /N /M "Reboot now? (Y/N): "
if errorlevel 2 goto mainmenu

shutdown /r /t 5 /c "Auto Fix HWID - Completing WMI repair"
exit /b

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
