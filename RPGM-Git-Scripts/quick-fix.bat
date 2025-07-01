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
echo ~$*
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
echo ? Updated .gitignore to exclude developer-only scripts
echo ? Added user scripts (update.bat/sh, rollback.bat/sh) to version control
echo ? Added documentation (README.md, TROUBLESHOOTING.md)
echo ? Committed all changes
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
echo   ? data/ folder (game data)
echo   ? update.bat/sh (update scripts)
echo   ? rollback.bat/sh (rollback scripts) 
echo   ? README.md (documentation)
echo   ? TROUBLESHOOTING.md (help guide)
echo.
echo [Local only - Developers keep these:]
echo   ? git-setup*.bat (repository setup)
echo   ? create-patch*.bat (patch creation)
echo   ? status-checker.bat (debugging tools)
echo.
pause
