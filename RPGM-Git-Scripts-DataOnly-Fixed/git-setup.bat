@echo off
chcp 65001 >nul
title RPGM Git Setup (Strict Data Only)
echo ============================================
echo   RPGM Git Setup - Strict Data Only
echo ============================================

:: Check if Git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not installed
    pause
    exit /b 1
)

:: Create strict .gitignore for data only
echo Creating strict .gitignore for data only...
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
echo # FORCE IGNORE COMMON UNWANTED FOLDERS
echo # ============================================
echo # Even if someone tries to add these
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

:: Initialize Git repository if not already initialized
if not exist ".git" (
    echo Initializing Git...
    git init
    git config user.name "Mochi"
    git config user.email "Mochi@example.com"
)

:: Add remote if not already set
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo Adding remote...
    git remote add origin https://Mochi@git.chanomhub.online/Mochi/HJ063.git
)

:: Add .gitignore first
echo Adding .gitignore first...
git add .gitignore

:: Check and add only data folders
set found_data=0

echo Checking for data folders...
if exist "data\" (
    echo Found: data/
    git add data/
    set found_data=1
)

if exist "www\data\" (
    echo Found: www/data/
    git add www/data/
    set found_data=1
)

:: Verify if files were staged
echo Verifying staged files...
git diff --cached --name-only
if errorlevel 1 (
    echo [WARNING] No files were staged!
    echo Current .gitignore contents:
    type .gitignore
    echo.
    echo Current directory contents:
    dir /b
    echo.
    echo [ERROR] Failed to add data/ or www/data/. Check .gitignore rules or directory structure.
    pause
    exit /b 1
)

if %found_data%==0 (
    echo [WARNING] No data folders found!
    echo Expected: data/ or www/data/
    echo Current directory contents:
    dir /b
    echo.
    echo Make sure you're in the correct game directory
    pause
    exit /b 1
)

:: Commit changes if there are any
git diff --cached --quiet
if errorlevel 1 (
    echo Committing initial data files...
    git commit -m "Initial commit: Data files only (strict)"
    
    echo Pushing to remote...
    git push -u origin main
    if errorlevel 1 (
        echo [WARNING] Push failed - check repository exists and credentials are correct
        pause
        exit /b 1
    )
) else (
    echo No changes to commit
)

echo.
echo [SUCCESS] Strict data-only setup completed
echo Repository: https://git.chanomhub.online/Mochi/HJ063
echo Only data/ and www/data/ will be tracked
echo.
pause