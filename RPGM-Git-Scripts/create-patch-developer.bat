@echo off
chcp 65001 >nul
title RPGM Patch Creator (Developer Only)
echo ============================================
echo    RPGM Patch Creator
echo    *** FOR DEVELOPER USE ONLY ***
echo    *** Only data folder is included ***
echo ============================================
echo.

:: Check if we're in a Git repository
if not exist ".git" (
    echo [ERROR] Not in a Git repository
    echo Please run git-setup-developer.bat first
    pause
    exit /b 1
)

set /p "patch_name=Patch name (e.g., translation-fix-v1.1): "
set /p "patch_desc=Patch description: "

:: Validate patch name
if "%patch_name%"=="" (
    echo [ERROR] Patch name cannot be empty
    pause
    exit /b 1
)

echo Creating patch: %patch_name%

:: Check if patches branch exists
git show-ref --verify --quiet refs/heads/patches
if errorlevel 1 (
    echo Creating patches branch...
    git checkout -b patches >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to create patches branch
        pause
        exit /b 1
    )
    git checkout main >nul 2>&1
)

:: Switch to patches branch
git checkout patches >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to switch to patches branch
    pause
    exit /b 1
)

:: Add changes for data folder only
echo Adding data folder to patch...
set "files_added=false"
if exist "data\" (
    git add data/ >nul 2>&1
    if not errorlevel 1 (
        echo Added data/ folder
        set "files_added=true"
    )
)
if exist "www\data\" (
    git add www/data/ >nul 2>&1
    if not errorlevel 1 (
        echo Added www/data/ folder
        set "files_added=true"
    )
)

if "%files_added%"=="false" (
    echo [ERROR] No data folder found or no changes to add
    git checkout main >nul 2>&1
    pause
    exit /b 1
)

:: Check if there are changes to commit
git diff --cached --quiet
if not errorlevel 1 (
    echo [ERROR] No changes to commit
    git checkout main >nul 2>&1
    pause
    exit /b 1
)

git commit -m "Patch: %patch_name% - %patch_desc%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to commit patch
    git checkout main >nul 2>&1
    pause
    exit /b 1
)

:: Create tag for patch
git tag -a "patch-%patch_name%" -m "%patch_desc%" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to create tag (may already exist)
)

:: Push to remote
echo Pushing patch to remote...
git push origin patches >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to push patches branch
)

git push origin "patch-%patch_name%" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to push patch tag
)

:: Return to main branch
git checkout main >nul 2>&1

echo.
echo [SUCCESS] Patch '%patch_name%' created successfully
echo Tag: patch-%patch_name%
echo Users can run update.bat/sh to apply this patch
echo.
pause
