@echo off
chcp 65001 >nul
title RPGM Git Setup (Developer Only) - FIXED
echo ============================================
echo    RPGM Git Repository Setup
echo    *** FOR DEVELOPER USE ONLY ***
echo    *** Only data folder is included ***
echo ============================================
echo.

:: Check if Git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed
    echo Please install Git from https://git-scm.com/
    pause
    exit /b 1
)

:: Get current directory info
echo Current directory: %CD%
echo.

:: Check current Git status
echo Checking Git repository status...
if exist ".git" (
    echo Git repository already exists
    echo Current branches:
    git branch -a
    echo.
    echo Current status:
    git status --short
    echo.
) else (
    echo No Git repository found, will create new one
)

:: Get user input if not already configured
for /f "tokens=*" %%i in ('git config --global user.name 2^>nul') do set "git_user=%%i"
for /f "tokens=*" %%i in ('git config --global user.email 2^>nul') do set "git_email=%%i"

if "%git_user%"=="" (
    set /p "git_user=Enter your Git username: "
    git config --global user.name "%git_user%"
)
if "%git_email%"=="" (
    set /p "git_email=Enter your Git email: "
    git config --global user.email "%git_email%"
)

echo Using Git user: %git_user% (%git_email%)
echo.

:: Create .gitignore for RPG Maker
echo Creating/updating .gitignore for RPG Maker...
(
echo # RPG Maker Specific Files
echo *.exe
echo *.app
echo *.dll
echo www/*
echo !www/data/
echo nwjs*/
echo Game.exe
echo *.log
echo.
echo # Save Files
echo save/
echo *.rpgsave
echo *.rpgmvo
echo config.rpgmvp
echo www/save/
echo www/config.rpgmvp
echo.
echo # System Files
echo Thumbs.db
echo .DS_Store
echo desktop.ini
echo.
echo # Temporary Files
echo *.tmp
echo *.temp
echo ~$*
echo.
echo # Node modules
echo node_modules/
echo.
echo # Management Scripts (keep local, don't version)
echo git-setup*.bat
echo create-patch*.bat
echo quick-fix.bat
echo.
echo # Keep essential data
echo !data/
echo !www/data/
echo !data/*.json
echo !www/data/*.json
echo # Exclude System.json from versioning (contains system-specific paths)
echo data/System.json
echo www/data/System.json
) > .gitignore

:: Initialize Git repository if not already initialized
if not exist ".git" (
    echo Initializing Git repository...
    git init >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to initialize Git repository
        pause
        exit /b 1
    )
    echo ? Git repository initialized
) else (
    echo ? Git repository already exists
)

:: Determine the default branch name
for /f "tokens=*" %%i in ('git symbolic-ref --short HEAD 2^>nul') do set "current_branch=%%i"
if "%current_branch%"=="" (
    :: No commits yet, check what the default branch will be
    for /f "tokens=*" %%i in ('git config --get init.defaultBranch 2^>nul') do set "default_branch=%%i"
    if "%default_branch%"=="" set "default_branch=master"
    echo No commits yet, will use default branch: %default_branch%
) else (
    set "default_branch=%current_branch%"
    echo Current branch: %default_branch%
)

:: Add remote repository (check if it exists first)
set /p "repo_url=Enter your Git repository URL (e.g., https://username@git.example.com/user/repo.git): "
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo Adding remote repository...
    git remote add origin "%repo_url%"
    if errorlevel 1 (
        echo [ERROR] Failed to add remote repository
        echo Please check the URL format
        pause
        exit /b 1
    )
    echo ? Remote repository added
) else (
    echo Remote repository already configured
    for /f "tokens=*" %%i in ('git remote get-url origin') do echo Current remote: %%i
    set /p "change_remote=Change remote URL? (Y/N): "
    if /i "%change_remote%"=="Y" (
        git remote set-url origin "%repo_url%"
        echo ? Remote repository updated
    )
)

:: Add data folder only
echo Adding data folder to repository...
set "files_added=false"
if exist "data\" (
    git add data/ >nul 2>&1
    if not errorlevel 1 (
        echo ? Added data/ folder
        set "files_added=true"
    ) else (
        echo [WARNING] Failed to add data/ folder (may be empty or have issues)
    )
) else if exist "www\data\" (
    git add www/data/ >nul 2>&1
    if not errorlevel 1 (
        echo ? Added www/data/ folder
        set "files_added=true"
    ) else (
        echo [WARNING] Failed to add www/data/ folder (may be empty or have issues)
    )
) else (
    echo [ERROR] No data folder found in project root or www/
    echo Please ensure your RPG Maker project has a data/ folder
    echo Looking for:
    echo   - %CD%\data\
    echo   - %CD%\www\data\
    pause
    exit /b 1
)

:: Add .gitignore
git add .gitignore >nul 2>&1

:: Check if there are changes to commit
git diff --cached --quiet >nul 2>&1
if errorlevel 1 (
    echo Committing initial files...
    git commit -m "Initial commit: RPG Maker data files and configuration" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to commit files
        echo This might be due to:
        echo - Git user/email not configured
        echo - File permission issues
        echo - Empty data folder
        pause
        exit /b 1
    )
    echo ? Initial commit created
    
    :: Set the default branch name if we just made the first commit
    if "%current_branch%"=="" (
        git branch -M %default_branch% >nul 2>&1
        echo ? Set default branch to %default_branch%
    )
) else (
    echo No new changes to commit (files may already be committed)
)

:: Create patches branch if it doesn't exist
git show-ref --verify --quiet refs/heads/patches >nul 2>&1
if errorlevel 1 (
    echo Creating patches branch...
    git checkout -b patches >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to create patches branch
        pause
        exit /b 1
    )
    git checkout %default_branch% >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Failed to return to %default_branch% branch
    )
    echo ? Patches branch created
) else (
    echo ? Patches branch already exists
)

:: Push to remote repository
echo Pushing to remote repository...
echo Pushing %default_branch% branch...
git push -u origin %default_branch% >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to push %default_branch% branch
    echo This might be because:
    echo - Repository doesn't exist on remote server
    echo - Authentication failed
    echo - Network connection issues
    echo.
    echo You may need to:
    echo 1. Create the repository on your Git server first
    echo 2. Check your credentials
    echo 3. Verify network connectivity
    echo.
    echo Try pushing manually with: git push -u origin %default_branch%
) else (
    echo ? %default_branch% branch pushed successfully
)

echo Pushing patches branch...
git push -u origin patches >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to push patches branch
    echo This is usually normal for initial setup
) else (
    echo ? Patches branch pushed successfully
)

echo.
echo ============================================
echo [SUCCESS] Git repository setup completed!
echo ============================================
echo.
echo Repository configured:
for /f "tokens=*" %%i in ('git remote get-url origin 2^>nul') do echo Remote URL: %%i
echo Default branch: %default_branch%
echo Data folder: %files_added%
echo.
echo Files in repository:
git ls-files
echo.
echo *** IMPORTANT FOR DEVELOPERS ***
echo - Only distribute update.bat/sh and rollback.bat/sh to users
echo - Keep git-setup and create-patch scripts for yourself
echo - Users don't need Git knowledge to receive updates
echo.
echo Next steps:
echo 1. Make changes to your data files
echo 2. Use create-patch-developer.bat to create patches
echo 3. Users will receive updates via update.bat/sh
echo.
pause
