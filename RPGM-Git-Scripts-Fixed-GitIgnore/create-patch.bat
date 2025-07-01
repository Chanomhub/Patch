@echo off
chcp 65001 >nul
title Data Patch Creator (Fixed GitIgnore)
echo ============================================
echo   Data Patch Creator (Fixed GitIgnore)
echo   Repository: Mochi/HJ063
echo ============================================

if not exist ".git" (
    echo [ERROR] Not a Git repository
    echo Run git-setup.bat first
    pause
    exit /b 1
)

echo Checking for data changes...
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
    pause
    exit /b 0
)

set /p "patch_name=Patch name: "
if "%patch_name%"=="" (
    echo [ERROR] Patch name required
    pause
    exit /b 1
)

echo Adding data files...
if exist "data\" git add data/
if exist "www\data\" git add -f www/data/

echo Files to be committed:
git diff --cached --name-only

set /p "confirm=Create patch '%patch_name%'? (y/n): "
if /i not "%confirm%"=="y" (
    echo Cancelled
    pause
    exit /b 0
)

git commit -m "Data Patch: %patch_name%"
git tag "data-patch-%patch_name%"

echo Pushing patch...
git push origin main
git push origin "data-patch-%patch_name%"

echo.
echo [SUCCESS] Patch '%patch_name%' created!
echo Repository: https://git.chanomhub.online/Mochi/HJ063
echo.
pause