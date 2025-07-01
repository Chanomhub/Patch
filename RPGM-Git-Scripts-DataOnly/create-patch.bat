@echo off
chcp 65001 >nul
title Data Only Patch Creator
echo ============================================
echo    Data Only Patch Creator (Developer)
echo ============================================

if not exist ".git" (
    echo [ERROR] Not a Git repository
    echo Run git-setup.bat first
    pause
    exit /b 1
)

echo Current repository status:
echo ----------------------------------------
git status --porcelain

echo.
echo Checking for changes in data folders...

REM Check if data folders exist and have changes
set has_changes=0

if exist "data\" (
    git status --porcelain data/ | findstr . >nul
    if not errorlevel 1 set has_changes=1
)

if exist "www\data\" (
    git status --porcelain www/data/ | findstr . >nul
    if not errorlevel 1 set has_changes=1
)

if %has_changes%==0 (
    echo [ERROR] No changes detected in data folders
    echo Make changes to your data files first
    echo Checking if data folders exist...
    if exist "data\" echo - data/ folder exists
    if exist "www\data\" echo - www/data/ folder exists
    if not exist "data\" if not exist "www\data\" echo - No data folders found
    echo.
    pause
    exit /b 1
)

set /p "patch_name=Patch name: "
set /p "patch_desc=Description (optional): "

if "%patch_name%"=="" (
    echo [ERROR] Patch name required
    pause
    exit /b 1
)

echo.
echo Adding data files to commit...

REM Add only data folders
if exist "data\" (
    git add data/
    echo Added data/
)

if exist "www\data\" (
    git add www/data/
    echo Added www/data/
)

REM Show what will be committed
echo.
echo Files to be committed:
git diff --cached --name-only

REM Final check for staged changes
git diff --cached --quiet
if not errorlevel 1 (
    echo [ERROR] No data changes staged for commit
    echo Make sure you have modified files in data/ or www/data/
    echo.
    echo Debug info:
    echo Current directory: %CD%
    if exist "data\" dir data\ /b
    if exist "www\data\" dir www\data\ /b
    pause
    exit /b 1
)

echo.
echo Creating data patch...
if "%patch_desc%"=="" (
    git commit -m "Data Patch: %patch_name%"
) else (
    git commit -m "Data Patch: %patch_name% - %patch_desc%"
)

if errorlevel 1 (
    echo [ERROR] Commit failed
    pause
    exit /b 1
)

git tag "data-patch-%patch_name%"

echo Pushing data patch...
git push origin main
if errorlevel 1 (
    echo [WARNING] Push to main failed
)

git push origin "data-patch-%patch_name%"
if errorlevel 1 (
    echo [WARNING] Tag push failed
)

echo.
echo [SUCCESS] Data patch '%patch_name%' created successfully!
echo Only data folder changes were included
echo Users can run update.bat to get this patch
echo.
pause
