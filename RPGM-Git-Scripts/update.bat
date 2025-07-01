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
    
    git remote add origin https://Mochi@git.chanomhub.online/Mochi/HJ063.git >nul 2>&1
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
