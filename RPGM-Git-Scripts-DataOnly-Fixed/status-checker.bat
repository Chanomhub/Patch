@echo off
chcp 65001 >nul
title Git Status Checker (Data Only)
echo ============================================
echo      Git Status Checker (Data Only)
echo      Repository: Mochi/HJ063
echo ============================================

if not exist ".git" (
    echo [ERROR] Not a Git repository
    pause
    exit /b 1
)

echo Repository Status:
echo ----------------------------------------
git status

echo.
echo Data Folder Analysis:
echo ----------------------------------------
if exist "data\" (
    echo ? data/ folder exists
    for /f %%i in ('git status --porcelain data/ ^| find /c /v ""') do set data_changes=%%i
    if !data_changes! gtr 0 (
        echo   - Has !data_changes! changes
        git status --porcelain data/
    ) else (
        echo   - No changes
    )
) else (
    echo ? data/ folder not found
)

if exist "www\data\" (
    echo ? www/data/ folder exists
    for /f %%i in ('git status --porcelain www/data/ ^| find /c /v ""') do set wwwdata_changes=%%i
    if !wwwdata_changes! gtr 0 (
        echo   - Has !wwwdata_changes! changes
        git status --porcelain www/data/
    ) else (
        echo   - No changes
    )
) else (
    echo ? www/data/ folder not found
)

echo.
echo Ignored Folders (should not be tracked):
echo ----------------------------------------
if exist "www\icon\" echo ? www/icon/ - correctly ignored
if exist "www\text\" echo ? www/text/ - correctly ignored
if exist "www\data2\" echo ? www/data2/ - correctly ignored
if exist "www\data_bK\" echo ? www/data_bK/ - correctly ignored

echo.
echo Recent Commits:
echo ----------------------------------------
git log --oneline -5

echo.
echo Remote Status:
echo ----------------------------------------
git remote -v
git status --porcelain | find /c /v "" >nul
if errorlevel 1 (
    echo ? Working directory clean
) else (
    echo ? Working directory has changes
)

echo.
echo Repository URL: https://git.chanomhub.online/Mochi/HJ063
pause