:Fix_Module_Error
cls
echo [*] Fixing Wave Module...
echo.

set "MODULE_URL=https://github.com/Syr0nix/FixWave/raw/main/Wave%%20Module.zip"
set "ZIP_NAME=Wave_Module.zip"
set "DEST_DIR=%LOCALAPPDATA%"

if not exist "%DEST_DIR%" (
    echo [ERROR] Could not resolve LOCALAPPDATA.
    pause
    goto mainmenu
)

echo [*] Downloading module to: "%DEST_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Invoke-WebRequest -Uri '%MODULE_URL%' -OutFile '%DEST_DIR%\%ZIP_NAME%'"

if not exist "%DEST_DIR%\%ZIP_NAME%" (
    echo [ERROR] Download failed.
    pause
    goto mainmenu
)

echo [*] Extracting module into: "%DEST_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Expand-Archive -Force '%DEST_DIR%\%ZIP_NAME%' '%DEST_DIR%'"

echo [*] Cleaning up zip...
del "%DEST_DIR%\%ZIP_NAME%" >nul 2>&1

echo.
echo [✓] Module installed to: "%DEST_DIR%"
timeout /t 2 >nul
goto mainmenu
