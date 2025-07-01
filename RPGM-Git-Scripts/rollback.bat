@echo off
chcp 65001 >nul
title RPGM Rollback Tool
echo ============================================
echo        RPGM Rollback Tool
echo ============================================
echo.

:: List available backups
echo Available backups:
echo.
set "backup_found=false"
for /d %%i in (backup_*) do (
    echo   %%i
    set "backup_found=true"
)

if "%backup_found%"=="false" (
    echo No backups found
    echo Run update.bat first to create backups
    pause
    exit /b 1
)
echo.

set /p "backup_dir=Enter backup directory name to restore: "

if not exist "%backup_dir%" (
    echo [ERROR] Backup directory '%backup_dir%' not found
    pause
    exit /b 1
)

echo Restoring from %backup_dir%...
set "restore_count=0"

:: Restore save and config files only
if exist "%backup_dir%\save" (
    if exist "save" rmdir /s /q "save" >nul 2>&1
    xcopy "%backup_dir%\save" "save\" /E /I /Q >nul 2>&1
    echo - Save files restored (save/)
    set /a restore_count+=1
)
if exist "%backup_dir%\www_save" (
    if exist "www\save" rmdir /s /q "www\save" >nul 2>&1
    xcopy "%backup_dir%\www_save" "www\save\" /E /I /Q >nul 2>&1
    echo - Save files restored (www/save/)
    set /a restore_count+=1
)
if exist "%backup_dir%\config.rpgmvp" (
    copy "%backup_dir%\config.rpgmvp" . >nul 2>&1
    echo - Config restored (config.rpgmvp)
    set /a restore_count+=1
)
if exist "%backup_dir%\www_config.rpgmvp" (
    copy "%backup_dir%\www_config.rpgmvp" "www\config.rpgmvp" >nul 2>&1
    echo - Config restored (www/config.rpgmvp)
    set /a restore_count+=1
)

echo.
if %restore_count% gtr 0 (
    echo [SUCCESS] Rollback completed - %restore_count% items restored
) else (
    echo [WARNING] No files were restored from this backup
)
echo Note: Game data files remain at latest version
echo.
pause
