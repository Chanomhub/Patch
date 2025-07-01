# ============================================================================
# RPGM Git Management Scripts Generator - Data-Only Version (FIXED)
# Generates scripts to manage Git repositories for RPG Maker games, including only the data folder
# ============================================================================

Write-Host "=== RPGM Git Management Scripts Generator (Data-Only) ===" -ForegroundColor Cyan
Write-Host "Generating scripts to manage Git repositories for RPG Maker games (data folder only)" -ForegroundColor Yellow

# Display current directory
$currentDir = Get-Location
Write-Host "Current directory: $currentDir" -ForegroundColor Gray

# Get user input
$repoName = Read-Host "Repository name (e.g., my-rpgm-game)"
$userName = Read-Host "Git username"

# Validate inputs
if ($repoName -match '[<>:"/\\|?*]' -or $userName -match '[<>:"/\\|?*]') {
    Write-Host "[ERROR] Repository name or username contains invalid characters" -ForegroundColor Red
    Write-Host "Use alphanumeric characters, hyphens, or underscores only" -ForegroundColor Yellow
    exit 1
}

$serverUrl = "git.chanomhub.online"

Write-Host "`nGenerating script files..." -ForegroundColor Green
Write-Host "Note: git-setup and create-patch are for Developers only; Users receive only update and rollback scripts" -ForegroundColor Yellow
Write-Host "Only the 'data' folder will be managed in the Git repository" -ForegroundColor Yellow

# Create output directory
$outputDir = "RPGM-Git-Scripts"
if (Test-Path $outputDir) {
    $confirm = Read-Host "Output directory '$outputDir' exists. Delete it? (Y/N)"
    if ($confirm -eq 'Y') {
        Remove-Item $outputDir -Recurse -Force -ErrorAction Stop
    } else {
        Write-Host "[ERROR] Operation aborted by user" -ForegroundColor Red
        exit 1
    }
}
New-Item -ItemType Directory -Path $outputDir -Force -ErrorAction Stop | Out-Null
Write-Host "Created directory: $outputDir" -ForegroundColor Gray

# ============================================================================
# 1. Git Setup Script (.bat) - For Developers Only - FIXED
# ============================================================================
$gitSetupBat = @"
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
    echo ✓ Git repository initialized
) else (
    echo ✓ Git repository already exists
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
    echo ✓ Remote repository added
) else (
    echo Remote repository already configured
    for /f "tokens=*" %%i in ('git remote get-url origin') do echo Current remote: %%i
    set /p "change_remote=Change remote URL? (Y/N): "
    if /i "%change_remote%"=="Y" (
        git remote set-url origin "%repo_url%"
        echo ✓ Remote repository updated
    )
)

:: Add data folder only
echo Adding data folder to repository...
set "files_added=false"
if exist "data\" (
    git add data/ >nul 2>&1
    if not errorlevel 1 (
        echo ✓ Added data/ folder
        set "files_added=true"
    ) else (
        echo [WARNING] Failed to add data/ folder (may be empty or have issues)
    )
) else if exist "www\data\" (
    git add www/data/ >nul 2>&1
    if not errorlevel 1 (
        echo ✓ Added www/data/ folder
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
    echo ✓ Initial commit created
    
    :: Set the default branch name if we just made the first commit
    if "%current_branch%"=="" (
        git branch -M %default_branch% >nul 2>&1
        echo ✓ Set default branch to %default_branch%
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
    echo ✓ Patches branch created
) else (
    echo ✓ Patches branch already exists
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
    echo ✓ %default_branch% branch pushed successfully
)

echo Pushing patches branch...
git push -u origin patches >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to push patches branch
    echo This is usually normal for initial setup
) else (
    echo ✓ Patches branch pushed successfully
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
"@

# ============================================================================
# 2. Update Script (.bat) - For Users - FIXED
# ============================================================================
$updateBat = @"
@echo off
chcp 65001 >nul
title RPGM Game Updater
echo ============================================
echo        RPGM Game Updater
echo ============================================
echo.

:: Check if Git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed
    echo Please install Git from https://git-scm.com/
    echo Or contact the developer for manual update files
    pause
    exit /b 1
)

:: Check if it's a Git repository
if not exist ".git" (
    echo Initializing Git repository for updates...
    git init >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to initialize Git repository
        pause
        exit /b 1
    )
    
    git remote add origin https://$userName@$serverUrl/$userName/$repoName.git >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to add remote repository
        pause
        exit /b 1
    )
    
    git fetch origin >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to fetch from remote repository
        echo Please check your internet connection and repository access
        pause
        exit /b 1
    )
    
    git checkout -b main origin/main >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to checkout main branch
        pause
        exit /b 1
    )
    echo Repository connected successfully
    echo.
)

:: Create backup before update
echo Creating backup before update...
set "timestamp=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "BACKUP_DIR=backup_%timestamp%"
mkdir "%BACKUP_DIR%" >nul 2>&1

:: Backup save and config files only
set "backup_created=false"
if exist "save" (
    xcopy "save" "%BACKUP_DIR%\save\" /E /I /Q >nul 2>&1
    echo Backed up save/ folder
    set "backup_created=true"
)
if exist "www\save" (
    xcopy "www\save" "%BACKUP_DIR%\www_save\" /E /I /Q >nul 2>&1
    echo Backed up www/save/ folder
    set "backup_created=true"
)
if exist "config.rpgmvp" (
    copy "config.rpgmvp" "%BACKUP_DIR%\" >nul 2>&1
    echo Backed up config.rpgmvp
    set "backup_created=true"
)
if exist "www\config.rpgmvp" (
    copy "www\config.rpgmvp" "%BACKUP_DIR%\www_config.rpgmvp" >nul 2>&1
    echo Backed up www/config.rpgmvp
    set "backup_created=true"
)

if "%backup_created%"=="true" (
    echo Backup created: %BACKUP_DIR%
) else (
    echo No save files found to backup
    rmdir "%BACKUP_DIR%" >nul 2>&1
)

:: Fetch latest updates
echo Fetching updates from repository...
git fetch origin >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to fetch updates
    echo Please check your internet connection
    pause
    exit /b 1
)

:: Check for new patches
echo Checking for new patches...
git log HEAD..origin/patches --oneline > temp_patches.txt 2>nul
if exist temp_patches.txt (
    for /f "tokens=*" %%i in (temp_patches.txt) do (
        echo Found new patch: %%i
        set /p "choice=Apply this patch? (Y/N): "
        if /i "!choice!"=="Y" (
            echo Applying patch...
            git checkout patches >nul 2>&1
            git pull origin patches >nul 2>&1
            git checkout main >nul 2>&1
            git merge patches --no-edit >nul 2>&1
            if errorlevel 1 (
                echo [ERROR] Failed to apply patch
                pause
                exit /b 1
            )
            echo [SUCCESS] Patch applied
            goto :patch_done
        )
    )
)
:patch_done
del temp_patches.txt 2>nul

:: Pull main updates
echo Pulling main updates...
git pull origin main >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to pull main updates
    echo There may be conflicts or connection issues
    pause
    exit /b 1
)

:: Restore save and config files
if "%backup_created%"=="true" (
    echo Restoring save files and config...
    if exist "%BACKUP_DIR%\save" (
        if exist "save" rmdir /s /q "save" >nul 2>&1
        xcopy "%BACKUP_DIR%\save" "save\" /E /I /Q >nul 2>&1
        echo Restored save/ folder
    )
    if exist "%BACKUP_DIR%\www_save" (
        if exist "www\save" rmdir /s /q "www\save" >nul 2>&1
        xcopy "%BACKUP_DIR%\www_save" "www\save\" /E /I /Q >nul 2>&1
        echo Restored www/save/ folder
    )
    if exist "%BACKUP_DIR%\config.rpgmvp" (
        copy "%BACKUP_DIR%\config.rpgmvp" . >nul 2>&1
        echo Restored config.rpgmvp
    )
    if exist "%BACKUP_DIR%\www_config.rpgmvp" (
        copy "%BACKUP_DIR%\www_config.rpgmvp" "www\config.rpgmvp" >nul 2>&1
        echo Restored www/config.rpgmvp
    )
)

echo.
echo [SUCCESS] Game updated successfully
if "%backup_created%"=="true" (
    echo Save files restored from backup
)
echo.
pause
"@

# ============================================================================
# 3. Update Script (.sh) - For Users (Linux/macOS) - FIXED
# ============================================================================
$updateSh = @'
#!/bin/bash
# RPGM Game Updater Script for Linux/macOS

echo "============================================"
echo "        RPGM Game Updater"
echo "============================================"
echo

# Check if Git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] Git is not installed"
    echo "Please install Git first:"
    echo "- Ubuntu/Debian: sudo apt install git"
    echo "- macOS: brew install git"
    echo "- Or contact developer for manual update files"
    exit 1
fi

# Check if it's a Git repository
if [ ! -d ".git" ]; then
    echo "Initializing Git repository for updates..."
    if ! git init >/dev/null 2>&1; then
        echo "[ERROR] Failed to initialize Git repository"
        exit 1
    fi
    
    if ! git remote add origin https://{USERNAME}@{SERVERURL}/{USERNAME}/{REPONAME}.git >/dev/null 2>&1; then
        echo "[ERROR] Failed to add remote repository"
        exit 1
    fi
    
    if ! git fetch origin >/dev/null 2>&1; then
        echo "[ERROR] Failed to fetch from remote repository"
        echo "Please check your internet connection and repository access"
        exit 1
    fi
    
    if ! git checkout -b main origin/main >/dev/null 2>&1; then
        echo "[ERROR] Failed to checkout main branch"
        exit 1
    fi
    echo "Repository connected successfully"
    echo
fi

# Create backup before update
echo "Creating backup before update..."
BACKUP_DIR="backup_$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup save and config files only
backup_created=false
if [ -d "save" ]; then
    cp -r "save" "$BACKUP_DIR/"
    echo "Backed up save/ folder"
    backup_created=true
fi
if [ -d "www/save" ]; then
    mkdir -p "$BACKUP_DIR/www_save"
    cp -r "www/save" "$BACKUP_DIR/www_save/"
    echo "Backed up www/save/ folder"
    backup_created=true
fi
if [ -f "config.rpgmvp" ]; then
    cp "config.rpgmvp" "$BACKUP_DIR/"
    echo "Backed up config.rpgmvp"
    backup_created=true
fi
if [ -f "www/config.rpgmvp" ]; then
    cp "www/config.rpgmvp" "$BACKUP_DIR/www_config.rpgmvp"
    echo "Backed up www/config.rpgmvp"
    backup_created=true
fi

if [ "$backup_created" = true ]; then
    echo "Backup created: $BACKUP_DIR"
else
    echo "No save files found to backup"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

# Fetch latest updates
echo "Fetching updates from repository..."
if ! git fetch origin >/dev/null 2>&1; then
    echo "[ERROR] Failed to fetch updates"
    echo "Please check your internet connection"
    exit 1
fi

# Check for new patches
echo "Checking for new patches..."
NEW_PATCHES=$(git log HEAD..origin/patches --oneline 2>/dev/null)
if [ -n "$NEW_PATCHES" ]; then
    echo "Found new patches:"
    echo "$NEW_PATCHES"
    read -p "Apply these patches? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        echo "Applying patches..."
        if ! git checkout patches >/dev/null 2>&1 ||
           ! git pull origin patches >/dev/null 2>&1 ||
           ! git checkout main >/dev/null 2>&1 ||
           ! git merge patches --no-edit >/dev/null 2>&1; then
            echo "[ERROR] Failed to apply patches"
            exit 1
        fi
        echo "[SUCCESS] Patches applied"
    fi
fi

# Pull main updates
echo "Pulling main updates..."
if ! git pull origin main >/dev/null 2>&1; then
    echo "[ERROR] Failed to pull main updates"
    echo "There may be conflicts or connection issues"
    exit 1
fi

# Restore save and config files
if [ "$backup_created" = true ]; then
    echo "Restoring save files and config..."
    if [ -d "$BACKUP_DIR/save" ]; then
        rm -rf "save" >/dev/null 2>&1
        cp -r "$BACKUP_DIR/save" .
        echo "Restored save/ folder"
    fi
    if [ -d "$BACKUP_DIR/www_save/save" ]; then
        rm -rf "www/save" >/dev/null 2>&1
        mkdir -p "www"
        cp -r "$BACKUP_DIR/www_save/save" "www/"
        echo "Restored www/save/ folder"
    fi
    if [ -f "$BACKUP_DIR/config.rpgmvp" ]; then
        cp "$BACKUP_DIR/config.rpgmvp" .
        echo "Restored config.rpgmvp"
    fi
    if [ -f "$BACKUP_DIR/www_config.rpgmvp" ]; then
        cp "$BACKUP_DIR/www_config.rpgmvp" "www/config.rpgmvp"
        echo "Restored www/config.rpgmvp"
    fi
fi

echo
echo "[SUCCESS] Game updated successfully"
if [ "$backup_created" = true ]; then
    echo "Save files restored from backup"
fi
echo
read -p "Press Enter to continue..."
'@

# ============================================================================
# 4. Rollback Script (.bat) - For Users - IMPROVED
# ============================================================================
$rollbackBat = @"
@echo off
chcp 65001 >nul
title RPGM Rollback Tool
echo ============================================
echo        RPGM Rollback Tool
echo ============================================
echo.

:: List available backups
echo Available backups:
echo.
set "backup_found=false"
for /d %%i in (backup_*) do (
    echo   %%i
    set "backup_found=true"
)

if "%backup_found%"=="false" (
    echo No backups found
    echo Run update.bat first to create backups
    pause
    exit /b 1
)
echo.

set /p "backup_dir=Enter backup directory name to restore: "

if not exist "%backup_dir%" (
    echo [ERROR] Backup directory '%backup_dir%' not found
    pause
    exit /b 1
)

echo Restoring from %backup_dir%...
set "restore_count=0"

:: Restore save and config files only
if exist "%backup_dir%\save" (
    if exist "save" rmdir /s /q "save" >nul 2>&1
    xcopy "%backup_dir%\save" "save\" /E /I /Q >nul 2>&1
    echo - Save files restored (save/)
    set /a restore_count+=1
)
if exist "%backup_dir%\www_save" (
    if exist "www\save" rmdir /s /q "www\save" >nul 2>&1
    xcopy "%backup_dir%\www_save" "www\save\" /E /I /Q >nul 2>&1
    echo - Save files restored (www/save/)
    set /a restore_count+=1
)
if exist "%backup_dir%\config.rpgmvp" (
    copy "%backup_dir%\config.rpgmvp" . >nul 2>&1
    echo - Config restored (config.rpgmvp)
    set /a restore_count+=1
)
if exist "%backup_dir%\www_config.rpgmvp" (
    copy "%backup_dir%\www_config.rpgmvp" "www\config.rpgmvp" >nul 2>&1
    echo - Config restored (www/config.rpgmvp)
    set /a restore_count+=1
)

echo.
if %restore_count% gtr 0 (
    echo [SUCCESS] Rollback completed - %restore_count% items restored
) else (
    echo [WARNING] No files were restored from this backup
)
echo Note: Game data files remain at latest version
echo.
pause
"@

# ============================================================================
# 5. Rollback Script (.sh) - For Users (Linux/macOS) - IMPROVED
# ============================================================================
$rollbackSh = @'
#!/bin/bash
# RPGM Rollback Tool for Linux/macOS

echo "============================================"
echo "        RPGM Rollback Tool"
echo "============================================"
echo

# List available backups
echo "Available backups:"
echo
backup_found=false
if ls -d backup_* 2>/dev/null; then
    backup_found=true
fi

if [ "$backup_found" = false ]; then
    echo "No backups found"
    echo "Run update.sh first to create backups"
    exit 1
fi
echo

read -p "Enter backup directory name to restore: " backup_dir

if [ ! -d "$backup_dir" ]; then
    echo "[ERROR] Backup directory '$backup_dir' not found"
    exit 1
fi

echo "Restoring from $backup_dir..."
restore_count=0

# Restore save and config files only
if [ -d "$backup_dir/save" ]; then
    rm -rf "save" >/dev/null 2>&1
    cp -r "$backup_dir/save" .
    echo "- Save files restored (save/)"
    ((restore_count++))
fi
if [ -d "$backup_dir/www_save/save" ]; then
    rm -rf "www/save" >/dev/null 2>&1
    mkdir -p "www"
    cp -r "$backup_dir/www_save/save" "www/"
    echo "- Save files restored (www/save/)"
    ((restore_count++))
fi
if [ -f "$backup_dir/config.rpgmvp" ]; then
    cp "$backup_dir/config.rpgmvp" .
    echo "- Config restored (config.rpgmvp)"
    ((restore_count++))
fi
if [ -f "$backup_dir/www_config.rpgmvp" ]; then
    cp "$backup_dir/www_config.rpgmvp" "www/config.rpgmvp"
    echo "- Config restored (www/config.rpgmvp)"
    ((restore_count++))
fi

echo
if [ $restore_count -gt 0 ]; then
    echo "[SUCCESS] Rollback completed - $restore_count items restored"
else
    echo "[WARNING] No files were restored from this backup"
fi
echo "Note: Game data files remain at latest version"
echo
read -p "Press Enter to continue..."
'@

# ============================================================================
# 6. Patch Creator Script (.bat) - For Developers Only - IMPROVED
# ============================================================================
$patchCreatorBat = @"
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
"@

# ============================================================================
# 7. README Content - UPDATED
# ============================================================================
$readme = @"
# RPGM Git Management Scripts (Data-Only) - Fixed Version

Scripts for managing Git repositories for RPG Maker games, including only the data folder for version control.

## Generated Files:

### For Developers:
- **git-setup-developer.bat** - Initializes the Git repository with only the data folder
- **create-patch-developer.bat** - Creates new patches for the data folder

### For Users (Distribute these):
- **update.bat/sh** - Updates the game data and applies patches
- **rollback.bat/sh** - Restores save files from backups

## Key Fixes Applied:

### Git Setup Script:
- ✅ Fixed "ossiers" typo (removed stray text)
- ✅ Added proper error handling for Git operations
- ✅ Fixed remote origin handling (checks if already exists)
- ✅ Improved commit logic (only commits if there are changes)
- ✅ Better branch management for patches

### Update Script:
- ✅ Enhanced error handling for all Git operations
- ✅ Improved backup timestamp generation
- ✅ Better handling of missing save files
- ✅ Fixed variable expansion issues
- ✅ Added validation for backup creation

### Linux/macOS Scripts:
- ✅ Fixed backup directory structure
- ✅ Improved error handling with proper exit codes
- ✅ Better conditional logic for file operations

## Usage Instructions:

### Developers:
1. Place your RPG Maker project files in the same directory as the scripts
2. Run `git-setup-developer.bat` to create the repository (only `data` or `www/data` is included)
3. Make changes to your game data files
4. Use `create-patch-developer.bat` to create patches for data changes
5. **Distribute only update.bat/sh and rollback.bat/sh to Users**

### Users:
1. Download the game files + update.bat/sh + rollback.bat/sh
2. Run `update.bat/sh` to receive data updates and patches
3. Run `rollback.bat/sh` to restore save files if needed

## Features:
- ✅ Users don't need Git knowledge
- ✅ Automatic save file backups before updates
- ✅ Separate patch management for data changes
- ✅ Save file restoration if issues occur
- ✅ Game data updates while preserving save files
- ✅ Supports Windows and Linux/macOS
- ✅ Flexible handling of `data` folder (root or `www/data`)
- ✅ Robust error handling and validation
- ✅ Proper handling of existing repositories

## Troubleshooting:

### Common Issues Fixed:
- **"ossiers" command not found** - Fixed typo in git-setup script
- **"remote origin already exists"** - Now checks before adding remote
- **Failed to commit files** - Only commits when there are actual changes
- **Backup restoration issues** - Improved file handling and validation

## Important Notes:
- **git-setup and create-patch are for Developers only**
- **Users receive only update and rollback scripts**
- Users don't manage the repository themselves
- Only the `data` folder (in project root or `www`) is included in the Git repository
- All scripts now include comprehensive error handling

Repository: https://$serverUrl/$userName/$repoName

## Real-World Usage:
1. **Developer**: Place RPG Maker game files in the same folder as git-setup-developer.bat and run it
2. **Distribute**: Copy update.bat/sh and rollback.bat/sh to Users along with the game
3. **User**: Run update.bat/sh to receive data updates
"@

# ============================================================================
# 8. Repository Cleanup Script (.bat) - For Developers
# ============================================================================
$quickFixBat = @"
@echo off
chcp 65001 >nul
title RPGM Repository Cleanup
echo ============================================
echo    RPGM Repository Cleanup Script
echo    Organizes your existing repository
echo ============================================
echo.

:: Check if we're in a Git repository
if not exist ".git" (
    echo [ERROR] Not in a Git repository
    pause
    exit /b 1
)

echo Current repository status:
git status --short

echo.
echo This script will:
echo 1. Add all the generated RPGM management scripts
echo 2. Update .gitignore to exclude management scripts from main branch
echo 3. Commit the current changes
echo 4. Create a clean state for your repository
echo.

set /p "continue=Continue? (Y/N): "
if /i not "%continue%"=="Y" (
    echo Operation cancelled
    pause
    exit /b 0
)

:: Update .gitignore to exclude management scripts but keep them locally
echo.
echo Updating .gitignore...
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
echo ~`$*
echo.
echo # Node modules
echo node_modules/
echo.
echo # Management Scripts (keep local, don't version)
echo git-setup*.bat
echo create-patch*.bat
echo quick-fix.bat
echo status-checker.bat
echo.
echo # Keep essential data
echo !data/
echo !www/data/
echo !data/*.json
echo !www/data/*.json
echo # Exclude System.json from versioning
echo data/System.json
echo www/data/System.json
) > .gitignore

:: Add user scripts and documentation (these SHOULD be versioned for distribution)
echo Adding user scripts and documentation...
git add update.bat update.sh rollback.bat rollback.sh README.md TROUBLESHOOTING.md

:: Add updated .gitignore
git add .gitignore

:: Check what will be committed
echo.
echo Files to be committed:
git diff --cached --name-only

echo.
set /p "commit_msg=Enter commit message (or press Enter for default): "
if "%commit_msg%"=="" set "commit_msg=Add RPGM management scripts and documentation"

:: Commit the changes
git commit -m "%commit_msg%"
if errorlevel 1 (
    echo [ERROR] Failed to commit changes
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Repository cleaned up successfully!
echo.
echo What was done:
echo ✓ Updated .gitignore to exclude developer-only scripts
echo ✓ Added user scripts (update.bat/sh, rollback.bat/sh) to version control
echo ✓ Added documentation (README.md, TROUBLESHOOTING.md)
echo ✓ Committed all changes
echo.
echo Next steps:
echo 1. Push changes: git push origin main
echo 2. Users can now get update/rollback scripts with: git pull
echo 3. Keep developer scripts (git-setup*, create-patch*) local only
echo.

:: Show final status
echo Current repository status:
git status --short

echo.
echo Repository structure:
echo [Versioned - Users get these:]
echo   ✓ data/ folder (game data)
echo   ✓ update.bat/sh (update scripts)
echo   ✓ rollback.bat/sh (rollback scripts) 
echo   ✓ README.md (documentation)
echo   ✓ TROUBLESHOOTING.md (help guide)
echo.
echo [Local only - Developers keep these:]
echo   ✓ git-setup*.bat (repository setup)
echo   ✓ create-patch*.bat (patch creation)
echo   ✓ status-checker.bat (debugging tools)
echo.
pause
"@



# ============================================================================
# Generate All Files
# ============================================================================

try {

    # Add to the Generate All Files section
    Write-Host "Generating Repository Cleanup script..." -ForegroundColor Gray
    $quickFixBat | Out-File -FilePath "$outputDir\quick-fix.bat" -Encoding OEM -ErrorAction Stop
    Write-Host "✓ Repository Cleanup script generated" -ForegroundColor Green

    # Generate Developer Scripts
    Write-Host "Generating Developer scripts..." -ForegroundColor Gray
    $gitSetupBat | Out-File -FilePath "$outputDir\git-setup-developer.bat" -Encoding OEM -ErrorAction Stop
    $patchCreatorBat | Out-File -FilePath "$outputDir\create-patch-developer.bat" -Encoding OEM -ErrorAction Stop
    Write-Host "✓ Developer scripts generated" -ForegroundColor Green

    # Generate User Scripts
    Write-Host "Generating User scripts..." -ForegroundColor Gray
    $updateBat | Out-File -FilePath "$outputDir\update.bat" -Encoding OEM -ErrorAction Stop
    $rollbackBat | Out-File -FilePath "$outputDir\rollback.bat" -Encoding OEM -ErrorAction Stop
    Write-Host "✓ User scripts (.bat) generated" -ForegroundColor Green

    # Generate Linux/macOS Scripts with proper variable substitution
    Write-Host "Generating Linux/macOS scripts..." -ForegroundColor Gray
    $updateShFixed = $updateSh -replace '\{USERNAME\}', $userName -replace '\{SERVERURL\}', $serverUrl -replace '\{REPONAME\}', $repoName
    $updateShFixed | Out-File -FilePath "$outputDir\update.sh" -Encoding UTF8 -ErrorAction Stop
    $rollbackSh | Out-File -FilePath "$outputDir\rollback.sh" -Encoding UTF8 -ErrorAction Stop
    
    # Make shell scripts executable (if on Unix-like system)
    if ($PSVersionTable.Platform -eq 'Unix') {
        chmod +x "$outputDir/update.sh"
        chmod +x "$outputDir/rollback.sh"
    }
    Write-Host "✓ Linux/macOS scripts generated" -ForegroundColor Green

    # Generate README
    Write-Host "Generating README..." -ForegroundColor Gray
    $readme | Out-File -FilePath "$outputDir\README.md" -Encoding UTF8 -ErrorAction Stop
    Write-Host "✓ README generated" -ForegroundColor Green

    # Generate additional troubleshooting guide
    Write-Host "Generating troubleshooting guide..." -ForegroundColor Gray
    $troubleshootingGuide = @"
# RPGM Git Scripts - Troubleshooting Guide

## Common Error Messages and Solutions

### "ossiers is not recognized as an internal or external command"
**Fixed in this version** - This was a typo in the original script.

### "error: remote origin already exists"
**Fixed in this version** - Script now checks if remote exists before adding it.

### "[ERROR] Failed to commit files"
**Causes:**
- No changes were made to the data folder
- Git user name/email not configured

**Solutions:**
1. Make sure you have actual changes in your data/ folder
2. Configure Git with:
   ```
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

### Repository Access Issues
**Symptoms:** Cannot push/pull from remote repository

**Solutions:**
1. Check internet connection
2. Verify repository URL is correct
3. Ensure you have access permissions to the repository
4. Try accessing the repository URL in a web browser

### Data Folder Not Found
**Error:** "No data folder found in project root or www/"

**Solutions:**
1. Ensure you're running the script from your RPG Maker project directory
2. Check that your project has either:
   - A `data/` folder in the root directory, OR
   - A `www/data/` folder (for web deployment)

### Backup Issues
**Symptoms:** Save files not restored after update

**Solutions:**
1. Check if backup directory exists (backup_YYYY-MM-DD_HHMMSS)
2. Manually copy files from backup directory if needed
3. Ensure you have write permissions in the game directory

## For Developers

### Setting Up Your Repository
1. Create an empty repository on your Git server first
2. Place the git-setup-developer.bat in your RPG Maker project root
3. Run the script - it will initialize everything

### Creating Patches
1. Make changes to your data files
2. Run create-patch-developer.bat
3. Give your patch a descriptive name
4. The patch will be available to users through update.bat/sh

## For Users

### First Time Setup
1. Extract the game files
2. Run update.bat/sh once to connect to the repository
3. The script will download the latest version

### Updating Your Game
1. Run update.bat/sh whenever you want to check for updates
2. Your save files are automatically backed up before updates
3. If something goes wrong, use rollback.bat/sh

### If Updates Fail
1. Check your internet connection
2. Contact the developer - they may need to fix repository issues
3. Use rollback.bat/sh to restore your save files

## Technical Details

### What Gets Backed Up
- save/ folder (player saves)
- www/save/ folder (web deployment saves)
- config.rpgmvp (game configuration)
- www/config.rpgmvp (web deployment config)

### What Gets Updated
- data/ folder contents (game data files)
- www/data/ folder contents (web deployment data)

### File Structure
```
Your Game Directory/
├── data/                  # Game data (updated by Git)
├── save/                  # Your saves (backed up, never updated)
├── config.rpgmvp         # Your config (backed up, never updated)
├── update.bat            # Update script
├── rollback.bat          # Rollback script
└── backup_*/             # Automatic backups
```

## Getting Help
If you continue to have issues:
1. Check that Git is properly installed
2. Make sure you have internet access
3. Contact the game developer with the specific error message
4. Include your operating system information
"@

    $troubleshootingGuide | Out-File -FilePath "$outputDir\TROUBLESHOOTING.md" -Encoding UTF8 -ErrorAction Stop
    Write-Host "✓ Troubleshooting guide generated" -ForegroundColor Green

    # Display generated files
    Write-Host "`n=== Generated Files ===" -ForegroundColor Green
    Get-ChildItem $outputDir | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 1)
        Write-Host "✓ $($_.Name) ($size KB)" -ForegroundColor White
    }

    Write-Host "`n=== Summary ===" -ForegroundColor Cyan
    Write-Host "Directory: $outputDir" -ForegroundColor White
    Write-Host "Repository: https://$serverUrl/$userName/$repoName" -ForegroundColor Yellow

    Write-Host "`n=== Key Fixes Applied ===" -ForegroundColor Magenta
    Write-Host "✅ Fixed 'ossiers' typo in git-setup script" -ForegroundColor Green
    Write-Host "✅ Added proper remote origin handling" -ForegroundColor Green
    Write-Host "✅ Improved error handling throughout" -ForegroundColor Green
    Write-Host "✅ Fixed commit logic (only commits changes)" -ForegroundColor Green
    Write-Host "✅ Enhanced backup and restore functionality" -ForegroundColor Green
    Write-Host "✅ Better validation and user feedback" -ForegroundColor Green

    Write-Host "`n=== For Developers ===" -ForegroundColor Magenta
    Write-Host "- git-setup-developer.bat (Initialize Git repository with data folder)" -ForegroundColor White
    Write-Host "- create-patch-developer.bat (Create patches for data folder)" -ForegroundColor White

    Write-Host "`n=== For Users (Distribute these) ===" -ForegroundColor Green
    Write-Host "- update.bat/sh (Update game data)" -ForegroundColor White
    Write-Host "- rollback.bat/sh (Restore save files)" -ForegroundColor White
    Write-Host "- README.md (Usage guide)" -ForegroundColor White
    Write-Host "- TROUBLESHOOTING.md (Problem solving guide)" -ForegroundColor White

    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. [Developer] Place RPG Maker game files in the same folder as git-setup-developer.bat" -ForegroundColor White
    Write-Host "2. [Developer] Configure Git user info if needed:" -ForegroundColor White
    Write-Host "   git config --global user.name `"Your Name`"" -ForegroundColor Gray
    Write-Host "   git config --global user.email `"your.email@example.com`"" -ForegroundColor Gray
    Write-Host "3. [Developer] Run git-setup-developer.bat" -ForegroundColor White
    Write-Host "4. [Developer] Distribute game + update.bat/sh + rollback.bat/sh to Users" -ForegroundColor White
    Write-Host "5. [User] Run update.bat/sh to receive data updates" -ForegroundColor White

    Write-Host "`n=== Problems Fixed ===" -ForegroundColor Red
    Write-Host "❌ Original: 'ossiers' command not found" -ForegroundColor Red
    Write-Host "✅ Fixed: Removed stray text from script" -ForegroundColor Green
    Write-Host "❌ Original: remote origin already exists error" -ForegroundColor Red
    Write-Host "✅ Fixed: Checks before adding remote" -ForegroundColor Green
    Write-Host "❌ Original: Failed to commit files" -ForegroundColor Red
    Write-Host "✅ Fixed: Only commits when changes exist" -ForegroundColor Green
    Write-Host "❌ Original: Poor error handling" -ForegroundColor Red
    Write-Host "✅ Fixed: Comprehensive error checking" -ForegroundColor Green

    # Open output directory
    Write-Host "`nOpening directory..." -ForegroundColor Gray
    if ($PSVersionTable.Platform -eq 'Win32NT' -or $PSVersionTable.PSEdition -eq 'Desktop') {
        Invoke-Item $outputDir
    } else {
        Write-Host "Generated files are in: $(Resolve-Path $outputDir)" -ForegroundColor Yellow
    }

} catch {
    Write-Host "`n[ERROR] Failed to generate files:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nPlease check file write permissions and directory access" -ForegroundColor Yellow
}