@echo off
chcp 65001 >nul
title Game Updater
echo ============================================
echo        Game Updater
echo ============================================

git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not installed
    pause
    exit /b 1
)

if not exist ".git" (
    echo Connecting to repository...
    git init
    git remote add origin https://Mochi@git.chanomhub.online/Mochi/HJ063.git
    git fetch origin
    git checkout -b main origin/main
)

echo Creating backup...
set "backup=backup_%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%%time:~3,2%"
set "backup=%backup: =0%"
mkdir "%backup%" 2>nul

if exist "save" xcopy "save" "%backup%\save\" /E /I /Q >nul 2>&1
if exist "www\save" xcopy "www\save" "%backup%\www_save\" /E /I /Q >nul 2>&1
if exist "config.rpgmvp" copy "config.rpgmvp" "%backup%\" >nul 2>&1
if exist "www\config.rpgmvp" copy "www\config.rpgmvp" "%backup%\www_config.rpgmvp" >nul 2>&1

echo Downloading updates...
git pull origin main
if errorlevel 1 (
    echo [ERROR] Update failed
    pause
    exit /b 1
)

echo Restoring saves...
if exist "%backup%\save" (
    if exist "save" rmdir /s /q "save"
    xcopy "%backup%\save" "save\" /E /I /Q >nul 2>&1
)
if exist "%backup%\www_save" (
    if exist "www\save" rmdir /s /q "www\save"
    xcopy "%backup%\www_save" "www\save\" /E /I /Q >nul 2>&1
)
if exist "%backup%\config.rpgmvp" copy "%backup%\config.rpgmvp" . >nul 2>&1
if exist "%backup%\www_config.rpgmvp" copy "%backup%\www_config.rpgmvp" "www\config.rpgmvp" >nul 2>&1

echo.
echo [SUCCESS] Update completed
echo Backup: %backup%
echo.
pause
