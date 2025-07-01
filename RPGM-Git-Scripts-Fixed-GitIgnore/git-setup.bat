@echo off
chcp 65001 >nul
title RPGM Git Setup (Fixed GitIgnore Rules)
echo ============================================
echo   RPGM Git Setup - Fixed GitIgnore Rules
echo ============================================

:: Check if Git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not installed
    pause
    exit /b 1
)

:: Create FIXED .gitignore - Allow www/data/ first, then deny www/*
echo Creating FIXED .gitignore...
(
echo # ============================================
echo # RPGM DATA ONLY - FIXED GITIGNORE RULES
echo # ============================================
echo # README: Order matters! Allow specific paths first
echo.
echo # ============================================
echo # ALLOW THESE FIRST ^(before broader ignores^)
echo # ============================================
echo # Essential files
echo !/.gitignore
echo !/README.md
echo.
echo # Data folders - ALLOW THESE FIRST
echo !/data/
echo !/www/data/
echo.
echo # ============================================
echo # THEN IGNORE EVERYTHING ELSE
echo # ============================================
echo # Ignore most root files
echo /*.exe
echo /*.dll
echo /*.bat
echo /*.log
echo /*.tmp
echo /package.json
echo /package-lock.json
echo /node_modules/
echo /save/
echo /config.rpgmvp
echo.
echo # Ignore specific www subfolders
echo /www/js/
echo /www/css/
echo /www/img/
echo /www/audio/
echo /www/fonts/
echo /www/movies/
echo /www/icon/
echo /www/text/
echo /www/data2/
echo /www/data_*/
echo /www/save/
echo /www/config.rpgmvp
echo /www/*.exe
echo /www/*.dll
echo /www/*.bat
echo.
echo # Development folders
echo /.vscode/
echo /.idea/
echo /backup_*/
echo /.git/
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

:: Check and add data folders with force flag
set found_data=0

echo Checking for data folders...
if exist "data\" (
    echo Found: data/
    git add data/
    set found_data=1
)

if exist "www\data\" (
    echo Found: www/data/
    git add -f www/data/
    set found_data=1
)

:: Verify staged files
echo Verifying staged files...
git diff --cached --name-only
if errorlevel 1 (
    echo [WARNING] No files were staged!
    pause
    exit /b 1
)

if %found_data%==0 (
    echo [WARNING] No data folders found!
    echo Expected: data/ or www/data/
    echo Current directory contents:
    dir /b
    pause
    exit /b 1
)

:: Commit changes
git diff --cached --quiet
if errorlevel 1 (
    echo Committing initial data files...
    git commit -m "Initial commit: Data files only (fixed gitignore)"
    
    echo Pushing to remote...
    git push -u origin main
    if errorlevel 1 (
        echo [WARNING] Push failed - check repository exists and credentials
        pause
        exit /b 1
    )
) else (
    echo No changes to commit
)

echo.
echo [SUCCESS] Setup completed with fixed .gitignore rules
echo Repository: https://git.chanomhub.online/Mochi/HJ063
echo Data folders are now properly tracked
echo.
pause