@echo off
cd /d "%~dp0"
echo ============================================================
echo   PrusaSlicer Plugin: Gridfinity Drawer Optimizer
echo ============================================================

set PS_EXE=D:\3D\PrusaSlicer\PrusaSlicer-3.0.0-alpha13\PrusaSlicer.exe
set PRIV_KEY=D:\3d\prusaslicer\keys\private_key.pem
set TARGET_DIR=%APPDATA%\PrusaSlicer3-dev\lua\io.github.3dems.gridfinity-generator

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

echo Copiando archivos minimos limpios...
copy /Y "manifest.json" "%TARGET_DIR%\" >nul
copy /Y "main.lua" "%TARGET_DIR%\" >nul

if exist "%PRIV_KEY%" (
    echo Firmando plugin con clave privada...
    "%PS_EXE%" plugin sign -f -P "%PRIV_KEY%" "%TARGET_DIR%"
) else (
    echo [WARNING] Clave privada no encontrada en %PRIV_KEY%
)

echo.
echo ============================================================
echo   [OK] Plugin actualizado y firmado en PrusaSlicer con exito
echo ============================================================
echo.
pause
