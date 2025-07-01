@echo off
chcp 65001 >nul
title Data Only Patch Creator (Strict)
echo ============================================
echo   Data Only Patch Creator (Strict)
echo   Repository: Mochi/HJ063
echo ============================================

if not exist ".git" (
    echo [ERROR] Not a Git repository
    echo Run git-setup.bat first
    pause
    exit /b 1
)

echo Checking for data changes...
echo ----------------------------------------

set has_changes=0

if exist "data\" (
    git status --porcelain data/ | findstr . >nul
    if not errorlevel 1 (
        echo Changes found in: data/
        set has_changes=1
    )
)

if exist "www\data\" (
    git status --porcelain www/data/ | findstr . >nul
    if not errorlevel 1 (
        echo Changes found in: www/data/
        set has_changes=1
    )
)

if %has_changes%==0 (
    echo [INFO] No changes in data folders
    echo Current data folders:
    if exist "data\" echo - data/ exists
    if exist "www\data\" echo - www/data/ exists
    if not exist "data\" if not exist "www\data\" echo - No data folders found
    echo.
    echo Make changes to your data files first
    pause
    exit /b 0
)

set /p "patch_name=Patch name: "
set /p "patch_desc=Description (optional): "

if "%patch_name%"=="" (
    echo [ERROR] Patch name required
    pause
    exit /b 1
)

echo.
echo Adding data files...

if exist "data\" (
    git add data/
    echo Added: data/
)

if exist "www\data\" (
    git add www/data/
    echo Added: www/data/
)

echo.
echo Files to be committed:
git diff --cached --name-only

echo.
set /p "confirm=Create patch '%patch_name%'? (y/n): "
if /i not "%confirm%"=="y" (
    echo Cancelled
    pause
    exit /b 0
)

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

echo Pushing patch...
git push origin main
git push origin "data-patch-%patch_name%"

echo.
echo [SUCCESS] Data patch '%patch_name%' created!
echo Repository: https://git.chanomhub.online/Mochi/HJ063
echo Only data folder changes were included
echo.
pause