@echo off
chcp 65001
title RPGM Game Updater
echo ============================================
echo        RPGM Game Updater
echo ============================================
echo.

:: สร้างสำรองข้อมูลก่อนอัพเดท
echo สร้างสำรองข้อมูลก่อนอัพเดท...
set BACKUP_DIR=backup_%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set BACKUP_DIR=%BACKUP_DIR: =0%
mkdir "%BACKUP_DIR%" 2>nul

:: สำรองไฟล์ data และ save
if exist "data" xcopy "data" "%BACKUP_DIR%\data\" /E /I /Q
if exist "save" xcopy "save" "%BACKUP_DIR%\save\" /E /I /Q
if exist "config.rpgmvp" copy "config.rpgmvp" "%BACKUP_DIR%\" >nul

echo Backup created: %BACKUP_DIR%

:: ดึงข้อมูลล่าสุดจาก Git
echo ดึงข้อมูลอัพเดทจาก Repository...
git fetch origin

:: ตรวจสอบว่ามี patch ใหม่หรือไม่
git log HEAD..origin/patches --oneline > temp_patches.txt
if %errorlevel% == 0 (
    for /f %%i in (temp_patches.txt) do (
        echo พบ Patch ใหม่: %%i
        set /p choice="ต้องการติดตั้ง Patch นี้หรือไม่? (Y/N): "
        if /i "!choice!"=="Y" (
            echo กำลังติดตั้ง Patch...
            git checkout patches
            git pull origin patches
            git checkout main
            git merge patches
            echo [SUCCESS] Patch ติดตั้งเสร็จสิ้น
        )
    )
)
del temp_patches.txt 2>nul

:: ดึงอัพเดทหลัก
echo ดึงอัพเดทหลัก...
git pull origin main

echo.
echo [SUCCESS] อัพเดทเกมเสร็จสิ้น
echo Backup location: %BACKUP_DIR%
echo.
pause
