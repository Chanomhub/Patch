@echo off
chcp 65001 >nul
title Enhanced Patch Creator
echo ============================================
echo    Enhanced Patch Creator (Developer)
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
echo Checking for changes...

REM Check for untracked files first
git ls-files --others --exclude-standard | findstr . >nul
if not errorlevel 1 (
    echo [INFO] Found untracked files
    set has_untracked=1
) else (
    set has_untracked=0
)

REM Check for modified files
git diff-index --quiet HEAD
if errorlevel 1 (
    set has_modified=1
) else (
    set has_modified=0
)

if %has_untracked%==0 if %has_modified%==0 (
    echo [ERROR] No changes detected
    echo Make changes to your game files first
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
echo Adding files to commit...

REM Add all game-related files
if exist "data\" (
    git add data/
    echo Added data/
)
if exist "www\data\" (
    git add www/data/
    echo Added www/data/
)
if exist "img\" (
    git add img/
    echo Added img/
)
if exist "audio\" (
    git add audio/
    echo Added audio/
)
if exist "fonts\" (
    git add fonts/
    echo Added fonts/
)
if exist "movies\" (
    git add movies/
    echo Added movies/
)
if exist "js\" (
    git add js/
    echo Added js/
)
if exist "css\" (
    git add css/
    echo Added css/
)
if exist "www\img\" (
    git add www/img/
    echo Added www/img/
)
if exist "www\audio\" (
    git add www/audio/
    echo Added www/audio/
)
if exist "www\fonts\" (
    git add www/fonts/
    echo Added www/fonts/
)
if exist "www\js\" (
    git add www/js/
    echo Added www/js/
)
if exist "www\css\" (
    git add www/css/
    echo Added www/css/
)

REM Add other important files (force add if needed)
if exist "package.json" git add -f package.json
if exist "index.html" git add -f index.html
if exist "www\index.html" git add -f www/index.html

REM Show what will be committed
echo.
echo Files to be committed:
git diff --cached --name-only

REM Final check for staged changes
git diff --cached --quiet
if not errorlevel 1 (
    echo [ERROR] No changes staged for commit
    echo This shouldn't happen - please check manually
    pause
    exit /b 1
)

echo.
echo Creating patch...
if "%patch_desc%"=="" (
    git commit -m "Patch: %patch_name%"
) else (
    git commit -m "Patch: %patch_name% - %patch_desc%"
)

git tag "patch-%patch_name%"

echo Pushing patch...
git push origin main
git push origin "patch-%patch_name%"

echo.
echo [SUCCESS] Patch '%patch_name%' created successfully!
echo Users can run update.bat to get this patch
echo.
pause
