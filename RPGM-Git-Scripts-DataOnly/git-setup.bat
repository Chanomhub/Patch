@echo off
chcp 65001 >nul
title RPGM Git Setup (Data Only)
echo ============================================
echo    RPGM Git Setup - Data Only Version
echo ============================================

git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not installed
    pause
    exit /b 1
)

echo Creating .gitignore...
(
echo # Executables and binaries
echo *.exe
echo *.app
echo *.dll
echo # NW.js runtime files
echo icudtl.dat
echo nw_*.pak
echo natives_blob.bin
echo snapshot_blob.bin
echo locales/
echo # Save files and config
echo save/
echo *.rpgsave
echo config.rpgmvp
echo # System files
echo Thumbs.db
echo .DS_Store
echo # Development files
echo node_modules/
echo debug.log
echo # Temporary/backup files
echo *.tmp
echo *.bak
echo backup_*/
echo # Ignore everything except data folders
echo # We only want to track data files
echo img/
echo audio/
echo fonts/
echo movies/
echo js/
echo css/
echo www/img/
echo www/audio/
echo www/fonts/
echo www/js/
echo www/css/
echo www/movies/
echo # Keep these files
echo !.gitignore
echo !*.bat
echo !README.md
echo # KEEP ONLY DATA FILES
echo # data/ folders are kept
echo # www/data/ folders are kept
) > .gitignore

if not exist ".git" (
    echo Initializing Git...
    git init
    git config user.name "Mochi"
    git config user.email "Mochi@example.com"
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo Adding remote...
    git remote add origin https://Mochi@git.chanomhub.online/Mochi/HJ063.git
)

echo Adding data files only...
git add .gitignore

REM Add only data folders
if exist "data\" (
    git add data/
    echo Added data/
)
if exist "www\data\" (
    git add www/data/
    echo Added www/data/
)

git diff --cached --quiet
if errorlevel 1 (
    echo Committing initial data files...
    git commit -m "Initial commit: Data files only"
    
    echo Pushing to remote...
    git push -u origin main
    if errorlevel 1 (
        echo [WARNING] Push failed - check repository exists
    )
) else (
    echo No data files to commit
    echo [INFO] Make sure you have data/ or www/data/ folders
)

echo.
echo [SUCCESS] Setup completed (Data Only)
echo Repository: https://git.chanomhub.online/Mochi/HJ063
echo Only data files will be tracked
echo.
pause
