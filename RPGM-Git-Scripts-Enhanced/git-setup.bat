@echo off
chcp 65001 >nul
title RPGM Git Setup (Enhanced)
echo ============================================
echo    RPGM Git Setup (Developer Only)
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
echo # KEEP GAME FILES - Don't ignore these!
echo # data/ folders are kept
echo # img/ folders are kept  
echo # audio/ folders are kept
echo # fonts/ folders are kept
echo # js/ folders are kept
echo # css/ folders are kept
echo # movies/ folders are kept
echo # index.html files are kept
echo # package.json files are kept
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

echo Adding game files...
git add .gitignore

REM Add core game files
if exist "data\" git add data/
if exist "www\data\" git add www/data/
if exist "img\" git add img/
if exist "audio\" git add audio/
if exist "fonts\" git add fonts/
if exist "movies\" git add movies/
if exist "js\" git add js/
if exist "css\" git add css/
if exist "www\img\" git add www/img/
if exist "www\audio\" git add www/audio/
if exist "www\fonts\" git add www/fonts/
if exist "www\js\" git add www/js/
if exist "www\css\" git add www/css/

REM Add package.json and index.html if they exist
if exist "package.json" git add package.json
if exist "index.html" git add index.html
if exist "www\index.html" git add www/index.html

git diff --cached --quiet
if errorlevel 1 (
    echo Committing initial files...
    git commit -m "Initial commit: Game files"
    
    echo Pushing to remote...
    git push -u origin main
    if errorlevel 1 (
        echo [WARNING] Push failed - check repository exists
    )
) else (
    echo No changes to commit
    echo [INFO] Repository might already be set up
)

echo.
echo [SUCCESS] Setup completed
echo Repository: https://git.chanomhub.online/Mochi/HJ063
echo.
pause
