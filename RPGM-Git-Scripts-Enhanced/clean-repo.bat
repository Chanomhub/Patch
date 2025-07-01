@echo off
chcp 65001 >nul
title Repository Cleaner
echo ============================================
echo      Repository Cleaner (Developer)
echo ============================================
echo WARNING: This will remove untracked files!
echo.

set /p "confirm=Continue? (y/N): "
if /i not "%confirm%"=="y" (
    echo Cancelled
    pause
    exit /b 0
)

echo.
echo Files to be removed:
git clean -n

echo.
set /p "final_confirm=Really delete these files? (y/N): "
if /i not "%final_confirm%"=="y" (
    echo Cancelled
    pause
    exit /b 0
)

echo Cleaning repository...
git clean -f

echo.
echo [SUCCESS] Repository cleaned
pause
