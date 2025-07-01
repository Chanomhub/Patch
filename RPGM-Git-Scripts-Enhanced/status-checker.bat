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
