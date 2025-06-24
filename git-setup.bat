@echo off
chcp 65001
title RPGM Git Setup
echo ============================================
echo    RPGM Git Repository Setup
echo ============================================
echo.

:: ตรวจสอบว่ามี Git หรือไม่
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git ไม่ได้ติดตั้งในระบบ
    echo กรุณาติดตั้ง Git จาก https://git-scm.com/
    pause
    exit /b 1
)

:: สร้าง .gitignore สำหรับ RPGM
echo สร้าง .gitignore สำหรับ RPGM...
(
echo # RPGM Specific Files
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
echo ~$*
echo.
echo # Node modules (if any)
echo node_modules/
echo.
echo # Keep only essential data
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

:: เริ่มต้น Git Repository
echo เริ่มต้น Git Repository...
git init

:: เพิ่ม remote origin
echo เพิ่ม Remote Repository...
git remote add origin https://admin@git.chanomhub.online/admin/ทดสอบ.git

:: เพิ่มไฟล์สำคัญเข้า Git
echo เพิ่มไฟล์เข้า Repository...
git add .
git commit -m "Initial commit: RPGM game files"

:: สร้าง branch สำหรับ patches
git checkout -b patches
git checkout main

echo.
echo [SUCCESS] Git Repository ตั้งค่าเสร็จสิ้น
echo Repository URL: https://git.chanomhub.online/admin/ทดสอบ
echo.
pause
