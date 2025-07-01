@echo off
chcp 65001 >nul
title RPGM Quick Fix - Data Only (Improved)
echo ============================================
echo     RPGM Quick Fix - Data Only
echo ============================================
echo This will fix your current repository to track only data files
echo.

if not exist ".git" (
    echo [ERROR] Not a Git repository
    echo Run git-setup.bat first
    pause
    exit /b 1
)

echo Step 1: Creating strict .gitignore...
(
echo # ============================================
echo # RPGM STRICT DATA ONLY - Ignore Everything
echo # ============================================
echo # Ignore everything at root
echo /*
echo # Ignore everything in www
echo www/*
echo.
echo # ============================================
echo # ALLOW ONLY THESE FILES/FOLDERS
echo # ============================================
echo # Essential files
echo !.gitignore
echo !README.md
echo.
echo # Data folders only
echo !data/
echo !www/data/
echo.
echo # ============================================
echo # FORCE IGNORE UNWANTED FOLDERS
echo # ============================================
echo www/js/
echo www/css/
echo www/img/
echo www/audio/
echo www/fonts/
echo www/movies/
echo www/icon/
echo www/text/
echo www/data2/
echo www/data_*/
echo save/
echo config.rpgmvp
echo *.exe
echo *.dll
echo node_modules/
echo .vscode/
echo .idea/
echo *.log
echo *.tmp
echo backup_*/
) > .gitignore
echo ? .gitignore created

echo.
echo Step 2: Clearing Git cache...
git rm -r --cached . >nul 2>&1
echo ? Git cache cleared

echo.
echo Step 3: Adding only allowed files...
git add .gitignore
echo ? Added: .gitignore

REM Add only data folders if they exist
if exist "data\" (
    git add data/
    echo ? Added: data/
)

if exist "www\data\" (
    git add www/data/ 2>nul
    echo ? Added: www/data/
)

echo.
echo Step 4: Checking what will be committed...
echo ----------------------------------------

REM Count files to avoid long output
for /f %%i in ('git --no-pager diff --cached --name-only ^| find /c /v ""') do set file_count=%%i

if %file_count% gtr 20 (
    echo Total files to commit: %file_count%
    echo.
    echo First 10 files:
    git --no-pager diff --cached --name-only | head -10
    echo ... and %file_count% more files
) else (
    echo Files to commit:
    git --no-pager diff --cached --name-only
)

echo ----------------------------------------
echo.

set /p "patch_name=Enter patch name (e.g., th1): "
if "%patch_name%"=="" (
    echo [ERROR] Patch name required
    pause
    exit /b 1
)

echo.
echo Step 5: Committing data-only changes...
git commit -m "Data Patch: %patch_name% (fixed to data-only)"

if errorlevel 1 (
    echo [ERROR] Commit failed
    pause
    exit /b 1
)
echo ? Commit successful

echo.
echo Step 6: Pushing to remote...
git push origin main

if errorlevel 1 (
    echo [WARNING] Push failed - check network/repository
    pause
    exit /b 1
)
echo ? Push successful

echo.
echo ============================================
echo [SUCCESS] Repository fixed and patch '%patch_name%' created!
echo ============================================
echo ? Repository now tracks only data folders
echo ? Unwanted folders (www/icon/, www/text/, etc.) are now ignored
echo ? Total files committed: %file_count%
echo.
pause