@echo off
chcp 65001 >nul
title RPGM Quick Fix - Fixed GitIgnore Rules
echo ============================================
echo   RPGM Quick Fix - Fixed GitIgnore Rules
echo ============================================

if not exist ".git" (
    echo [ERROR] Not a Git repository
    echo Run git-setup.bat first
    pause
    exit /b 1
)

echo Step 1: Creating FIXED .gitignore...
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
) > .gitignore
echo ? Fixed .gitignore created

echo.
echo Step 2: Clearing Git cache...
git rm -r --cached . >nul 2>&1
echo ? Git cache cleared

echo.
echo Step 3: Adding files with fixed rules...
git add .gitignore
echo ? Added: .gitignore

REM Add data folders with force flag to override gitignore
if exist "data\" (
    git add data/
    echo ? Added: data/
)

if exist "www\data\" (
    git add -f www/data/
    echo ? Added: www/data/ (with force)
)

echo.
echo Step 4: Verifying staged files...
echo ----------------------------------------
git diff --cached --name-only | findstr /c:"data/" >nul
if errorlevel 1 (
    echo [ERROR] No data files staged! Check directory structure.
    pause
    exit /b 1
)

for /f %%i in ('git diff --cached --name-only ^| find /c /v ""') do set file_count=%%i
echo Total files to commit: %file_count%
echo ----------------------------------------

set /p "patch_name=Enter patch name (e.g., th1): "
if "%patch_name%"=="" (
    echo [ERROR] Patch name required
    pause
    exit /b 1
)

echo.
echo Step 5: Committing fixed data-only repository...
git commit -m "Data Patch: %patch_name% (fixed gitignore rules)"

if errorlevel 1 (
    echo [ERROR] Commit failed
    pause
    exit /b 1
)

echo.
echo Step 6: Pushing to remote...
git push origin main

if errorlevel 1 (
    echo [WARNING] Push failed - check network/repository
    pause
    exit /b 1
)

echo.
echo ============================================
echo [SUCCESS] Repository fixed! Patch '%patch_name%' created
echo ============================================
echo ? GitIgnore rules fixed - www/data/ now works
echo ? Repository tracks only data folders
echo ? Files committed: %file_count%
echo.
pause