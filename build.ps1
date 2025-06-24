# ============================================================================
# RPGM Git Management Scripts Generator - Fixed Version
# Generates scripts to manage Git repositories for RPG Maker games
# ============================================================================

Write-Host "=== RPGM Git Management Scripts Generator (Fixed) ===" -ForegroundColor Cyan
Write-Host "Generating scripts to manage Git repositories for RPG Maker games" -ForegroundColor Yellow

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
Write-Host "Note: git-setup is for Developers only; Users receive only update scripts" -ForegroundColor Yellow

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
# 1. Git Setup Script (.bat) - For Developers Only
# ============================================================================
$gitSetupBat = @"
@echo off
chcp 65001 >nul
title RPGM Git Setup (Developer Only)
echo ============================================
echo    RPGM Git Repository Setup
echo    *** FOR DEVELOPER USE ONLY ***
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

:: Create .gitignore for RPG Maker
echo Creating .gitignore for RPG Maker...
(
echo # RPG Maker Specific Files
echo *.exe
echo *.app
echo *.dll
echo www/
echo nwjs*/
echo Game.exe
echo *.log
echo.
echo # Save Files
echo save/
echo *.rpgsave
echo *.rpgmvo
echo config.rpgmvp
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
echo # Keep essential data
echo !data/
echo !img/
echo !audio/
echo !js/
echo !css/
echo !fonts/
echo !icon/
echo !movies/
echo data/System.json
) > .gitignore

:: Initialize Git repository
echo Initializing Git repository...
git init >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to initialize Git repository
    pause
    exit /b 1
)

:: Add remote origin
echo Adding remote repository...
git remote add origin https://$userName@$serverUrl/$userName/$repoName.git

:: Add essential files
echo Adding files to repository...
git add .gitignore data/ img/ audio/ js/ css/ fonts/ icon/ movies/ >nul 2>&1
git commit -m "Initial commit: RPG Maker game files" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to commit files
    pause
    exit /b 1
)

:: Create patches branch
git checkout -b patches >nul 2>&1
git checkout main >nul 2>&1

:: Push to remote
echo Pushing files to remote repository...
git push -u origin main >nul 2>&1
git push -u origin patches >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to push to remote repository
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Git repository setup completed
echo Repository URL: https://$serverUrl/$userName/$repoName
echo.
echo *** Distribute only update.bat/sh to Users ***
echo.
pause
"@

# ============================================================================
# 2. Update Script (.bat) - For Users
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
    git remote add origin https://$userName@$serverUrl/$userName/$repoName.git >nul 2>&1
    git fetch origin >nul 2>&1
    git checkout -b main origin/main >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to initialize repository
        pause
        exit /b 1
    )
    echo Repository connected
    echo.
)

:: Create backup before update
echo Creating backup before update...
set "BACKUP_DIR=backup_%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_DIR=%BACKUP_DIR: =0%"
mkdir "%BACKUP_DIR%" >nul 2>&1

:: Backup save and config files only
if exist "save" xcopy "save" "%BACKUP_DIR%\save\" /E /I /Q >nul 2>&1
if exist "config.rpgmvp" copy "config.rpgmvp" "%BACKUP_DIR%\" >nul 2>&1

echo Backup created: %BACKUP_DIR%

:: Fetch latest updates
echo Fetching updates from repository...
git fetch origin >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to fetch updates
    pause
    exit /b 1
)

:: Check for new patches
echo Checking for new patches...
git log HEAD..origin/patches --oneline > temp_patches.txt 2>nul
if exist temp_patches.txt (
    for /f "tokens=*" %%i in (temp_patches.txt) do (
        echo Found new patch: %%i
        set /p choice="Apply this patch? (Y/N): "
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
    pause
    exit /b 1
)

:: Restore save and config files
echo Restoring save files and config...
if exist "%BACKUP_DIR%\save" xcopy "%BACKUP_DIR%\save\" "save\" /E /I /Q >nul 2>&1
if exist "%BACKUP_DIR%\config.rpgmvp" copy "%BACKUP_DIR%\config.rpgmvp" . >nul 2>&1

echo.
echo [SUCCESS] Game updated successfully
echo Save files restored
echo.
pause
"@

# ============================================================================
# 3. Update Script (.sh) - For Users (Linux/macOS) - FIXED VERSION
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
    git init >/dev/null 2>&1
    git remote add origin https://{USERNAME}@{SERVERURL}/{USERNAME}/{REPONAME}.git >/dev/null 2>&1
    git fetch origin >/dev/null 2>&1
    git checkout -b main origin/main >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to initialize repository"
        exit 1
    fi
    echo "Repository connected"
    echo
fi

# Create backup before update
echo "Creating backup before update..."
BACKUP_DIR="backup_$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup save and config files only
if [ -d "save" ]; then
    cp -r "save" "$BACKUP_DIR/"
fi
if [ -f "config.rpgmvp" ]; then
    cp "config.rpgmvp" "$BACKUP_DIR/"
fi

echo "Backup created: $BACKUP_DIR"

# Fetch latest updates
echo "Fetching updates from repository..."
git fetch origin >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to fetch updates"
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
        git checkout patches >/dev/null 2>&1
        git pull origin patches >/dev/null 2>&1
        git checkout main >/dev/null 2>&1
        git merge patches --no-edit >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "[ERROR] Failed to apply patches"
            exit 1
        fi
        echo "[SUCCESS] Patches applied"
    fi
fi

# Pull main updates
echo "Pulling main updates..."
git pull origin main >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to pull main updates"
    exit 1
fi

# Restore save and config files
echo "Restoring save files and config..."
if [ -d "$BACKUP_DIR/save" ]; then
    rm -rf "save" >/dev/null 2>&1
    cp -r "$BACKUP_DIR/save" .
fi
if [ -f "$BACKUP_DIR/config.rpgmvp" ]; then
    cp "$BACKUP_DIR/config.rpgmvp" .
fi

echo
echo "[SUCCESS] Game updated successfully"
echo "Save files restored"
echo
read -p "Press Enter to continue..."
'@

# ============================================================================
# 4. Rollback Script (.bat) - For Users
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
dir backup_* /B 2>nul
if errorlevel 1 (
    echo No backups found
    pause
    exit /b 1
)
echo.

set /p backup_dir="Enter backup directory name to restore: "

if not exist "%backup_dir%" (
    echo [ERROR] Backup directory not found
    pause
    exit /b 1
)

echo Restoring from %backup_dir%...

:: Restore save and config files only
if exist "%backup_dir%\save" (
    rmdir /s /q "save" >nul 2>&1
    xcopy "%backup_dir%\save" "save\" /E /I /Q >nul 2>&1
    echo - Save files restored
)

if exist "%backup_dir%\config.rpgmvp" (
    copy "%backup_dir%\config.rpgmvp" . >nul 2>&1
    echo - Config restored
)

echo.
echo [SUCCESS] Rollback completed
echo Note: Game files remain at latest version
echo.
pause
"@

# ============================================================================
# 5. Rollback Script (.sh) - For Users (Linux/macOS) - FIXED VERSION
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
if ! ls -d backup_* 2>/dev/null; then
    echo "No backups found"
    exit 1
fi
echo

read -p "Enter backup directory name to restore: " backup_dir

if [ ! -d "$backup_dir" ]; then
    echo "[ERROR] Backup directory not found"
    exit 1
fi

echo "Restoring from $backup_dir..."

# Restore save and config files only
if [ -d "$backup_dir/save" ]; then
    rm -rf "save" >/dev/null 2>&1
    cp -r "$backup_dir/save" .
    echo "- Save files restored"
fi
if [ -f "$backup_dir/config.rpgmvp" ]; then
    cp "$backup_dir/config.rpgmvp" .
    echo "- Config restored"
fi

echo
echo "[SUCCESS] Rollback completed"
echo "Note: Game files remain at latest version"
echo
read -p "Press Enter to continue..."
'@

# ============================================================================
# 6. Patch Creator Script (.bat) - For Developers Only
# ============================================================================
$patchCreatorBat = @"
@echo off
chcp 65001 >nul
title RPGM Patch Creator (Developer Only)
echo ============================================
echo    RPGM Patch Creator
echo    *** FOR DEVELOPER USE ONLY ***
echo ============================================
echo.

set /p patch_name="Patch name (e.g., translation-fix-v1.1): "
set /p patch_desc="Patch description: "

echo Creating patch: %patch_name%

:: Switch to patches branch
git checkout patches >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to switch to patches branch
    pause
    exit /b 1
)

:: Add changes
git add data/ img/ audio/ css/ js/ fonts/ movies/ >nul 2>&1
git commit -m "Patch: %patch_name% - %patch_desc%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to commit patch
    pause
    exit /b 1
)

:: Create tag for patch
git tag -a "patch-%patch_name%" -m "%patch_desc%" >nul 2>&1

:: Push to remote
git push origin patches >nul 2>&1
git push origin "patch-%patch_name%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to push patch
    pause
    exit /b 1
)

:: Return to main branch
git checkout main >nul 2>&1

echo.
echo [SUCCESS] Patch '%patch_name%' created
echo Tag: patch-%patch_name%
echo Users can run update.bat/sh to apply this patch
echo.
pause
"@

# ============================================================================
# Generate All Files
# ============================================================================

try {
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
    Write-Host "✓ Linux/macOS scripts generated" -ForegroundColor Green

    # Generate README
    Write-Host "Generating README..." -ForegroundColor Gray
    $readme = @"
# RPGM Git Management Scripts

Scripts for managing Git repositories for RPG Maker games, supporting translation and patch management.

## Generated Files:

### For Developers:
- **git-setup-developer.bat** - Initializes the Git repository
- **create-patch-developer.bat** - Creates new patches

### For Users (Distribute these):
- **update.bat/sh** - Updates the game and applies patches
- **rollback.bat/sh** - Restores save files from backups

## Usage Instructions:

### Developers:
1. Run `git-setup-developer.bat` to create the repository
2. Upload game files to Git
3. Use `create-patch-developer.bat` to create patches
4. **Distribute only update.bat/sh and rollback.bat/sh to Users**

### Users:
1. Download the game + update.bat/sh
2. Run `update.bat/sh` to receive updates and patches
3. Run `rollback.bat/sh` to restore save files if needed

## Features:
- ✅ Users don't need Git knowledge
- ✅ Automatic save file backups before updates
- ✅ Separate patch management
- ✅ Save file restoration if issues occur
- ✅ Game files update while preserving save files
- ✅ Supports Windows and Linux/macOS

## Important:
- **git-setup and create-patch are for Developers only**
- **Users receive only update and rollback scripts**
- Users don't manage the repository themselves

Repository: https://$serverUrl/$userName/$repoName

## Real-World Usage:
1. **Developer**: Place RPG Maker game files in the same folder as git-setup-developer.bat and run it
2. **Distribute**: Copy update.bat/sh and rollback.bat/sh to Users along with the game
3. **User**: Run update.bat/sh to receive updates
"@

    $readme | Out-File -FilePath "$outputDir\README.md" -Encoding UTF8 -ErrorAction Stop
    Write-Host "✓ README generated" -ForegroundColor Green

    # Display generated files
    Write-Host "`n=== Generated Files ===" -ForegroundColor Green
    Get-ChildItem $outputDir | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 1)
        Write-Host "✓ $($_.Name) ($size KB)" -ForegroundColor White
    }

    Write-Host "`n=== Summary ===" -ForegroundColor Cyan
    Write-Host "Directory: $outputDir" -ForegroundColor White
    Write-Host "Repository: https://$serverUrl/$userName/$repoName" -ForegroundColor Yellow

    Write-Host "`n=== For Developers ===" -ForegroundColor Magenta
    Write-Host "- git-setup-developer.bat (Initialize Git repository)" -ForegroundColor White
    Write-Host "- create-patch-developer.bat (Create patches)" -ForegroundColor White

    Write-Host "`n=== For Users (Distribute these) ===" -ForegroundColor Green
    Write-Host "- update.bat/sh (Update game)" -ForegroundColor White
    Write-Host "- rollback.bat/sh (Restore save files)" -ForegroundColor White
    Write-Host "- README.md (Usage guide)" -ForegroundColor White

    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. [Developer] Place RPG Maker game files in the same folder as git-setup-developer.bat" -ForegroundColor White
    Write-Host "2. [Developer] Run git-setup-developer.bat" -ForegroundColor White
    Write-Host "3. [Developer] Distribute game + update.bat/sh to Users" -ForegroundColor White
    Write-Host "4. [User] Run update.bat/sh to receive updates" -ForegroundColor White

    # Open output directory
    Write-Host "`nOpening directory..." -ForegroundColor Gray
    Invoke-Item $outputDir

} catch {
    Write-Host "`n[ERROR] Failed to generate files:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nPlease check file write permissions and directory access" -ForegroundColor Yellow
}