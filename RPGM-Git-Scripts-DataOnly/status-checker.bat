@echo off
chcp 65001 >nul
title Git Status Checker
echo ============================================
echo         Git Status Checker
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
echo Data Folder Status:
echo ----------------------------------------
if exist "data\" (
    echo Data folder exists: data/
    git status --porcelain data/
) else (
    echo No data/ folder found
)

if exist "www\data\" (
    echo Data folder exists: www/data/
    git status --porcelain www/data/
) else (
    echo No www/data/ folder found
)

echo.
echo Recent Commits:
echo ----------------------------------------
git log --oneline -5

echo.
echo Available Tags:
echo ----------------------------------------
git tag -l

echo.
echo Remote Information:
echo ----------------------------------------
git remote -v

echo.
pause
