@echo off
chcp 65001
title RPGM Rollback Tool
echo ============================================
echo        RPGM Rollback Tool
echo ============================================
echo.

:: แสดงรายการ backup ที่มี
echo รายการ Backup ที่มี:
echo.
dir backup_* /B 2>nul
echo.

set /p backup_dir="ชื่อโฟลเดอร์ Backup ที่ต้องการกู้คืน: "

if not exist "%backup_dir%" (
    echo [ERROR] ไม่พบโฟลเดอร์ Backup ที่ระบุ
    pause
    exit /b 1
)

echo กำลังกู้คืนข้อมูลจาก %backup_dir%...

:: กู้คืนไฟล์
if exist "%backup_dir%\data" (
    rmdir /s /q "data" 2>nul
    xcopy "%backup_dir%\data" "data\" /E /I /Q
    echo - กู้คืน data เสร็จสิ้น
)

if exist "%backup_dir%\save" (
    rmdir /s /q "save" 2>nul
    xcopy "%backup_dir%\save" "save\" /E /I /Q
    echo - กู้คืน save เสร็จสิ้น
)

if exist "%backup_dir%\config.rpgmvp" (
    copy "%backup_dir%\config.rpgmvp" . >nul
    echo - กู้คืน config เสร็จสิ้น
)

echo.
echo [SUCCESS] กู้คืนข้อมูลเสร็จสิ้น
echo.
pause
