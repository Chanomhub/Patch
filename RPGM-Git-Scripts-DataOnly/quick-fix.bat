@echo off
chcp 65001 >nul
title Quick Data Fix
echo ============================================
echo        Quick Data Fix
echo ============================================
echo This will add only data files to your repository
echo.

if not exist ".git" (
    echo [ERROR] Not a Git repository
    echo Run git-setup.bat first
    pause
    exit /b 1
)

echo Current status:
git status --porcelain

echo.
set /p "patch_name=Patch name (e.g., th1): "

if "%patch_name%"=="" (
    echo [ERROR] Patch name required
    pause
    exit /b 1
)

echo.
echo Adding data files...

if exist "data\" (
    git add data/
    echo Added data/
)

if exist "www\data\" (
    git add www/data/
    echo Added www/data/
)

echo.
echo What will be committed:
git diff --cached --name-only

echo.
set /p "confirm=Create patch '%patch_name%'? (y/n): "
if /i not "%confirm%"=="y" (
    echo Cancelled
    pause
    exit /b 0
)

git commit -m "Data Patch: %patch_name%"
git push origin main

echo.
echo [SUCCESS] Data patch '%patch_name%' created!
echo.
pause
