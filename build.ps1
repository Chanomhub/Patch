# ============================================================================
# RPGM Git Management Scripts Generator
# สร้างสคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM
# ============================================================================

Write-Host "=== RPGM Git Management Scripts Generator ===" -ForegroundColor Cyan
Write-Host "สร้างสคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM" -ForegroundColor Yellow

# รับข้อมูลจากผู้ใช้
$repoName = Read-Host "ชื่อ Repository (เช่น my-rpgm-game)"
$serverUrl = "git.chanomhub.online"
$userName = Read-Host "Username สำหรับ Git"

Write-Host "`nกำลังสร้างไฟล์สคริปต์..." -ForegroundColor Green

# ============================================================================
# 1. Git Setup Script (.bat)
# ============================================================================
$gitSetupBat = @"
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
echo ~`$*
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
git remote add origin https://${userName}@${serverUrl}/${userName}/${repoName}.git

:: เพิ่มไฟล์สำคัญเข้า Git
echo เพิ่มไฟล์เข้า Repository...
git add .
git commit -m "Initial commit: RPGM game files"

:: สร้าง branch สำหรับ patches
git checkout -b patches
git checkout main

echo.
echo [SUCCESS] Git Repository ตั้งค่าเสร็จสิ้น
echo Repository URL: https://${serverUrl}/${userName}/${repoName}
echo.
pause
"@

# ============================================================================
# 2. Git Setup Script (.sh)
# ============================================================================
$gitSetupSh = @"
#!/bin/bash
# RPGM Git Setup Script for Linux/macOS

echo "============================================"
echo "    RPGM Git Repository Setup"
echo "============================================"
echo

# ตรวจสอบว่ามี Git หรือไม่
if ! command -v git &> /dev/null; then
    echo "[ERROR] Git is not installed"
    echo "Please install Git first"
    exit 1
fi

# สร้าง .gitignore สำหรับ RPGM
echo "Creating .gitignore for RPGM..."
cat > .gitignore << 'EOF'
# RPGM Specific Files
*.exe
*.app
*.dll
www/
nwjs*/
Game.exe
*.log

# Save Files
save/
*.rpgsave
*.rpgmvo
config.rpgmvp

# System Files
Thumbs.db
.DS_Store
desktop.ini

# Temporary Files
*.tmp
*.temp
~`$*

# Node modules (if any)
node_modules/

# Keep only essential data
!data/
!img/
!audio/
!js/
!css/
!fonts/
!icon/
!movies/
data/System.json
EOF

# เริ่มต้น Git Repository
echo "Initializing Git Repository..."
git init

# เพิ่ม remote origin
echo "Adding Remote Repository..."
git remote add origin https://${userName}@${serverUrl}/${userName}/${repoName}.git

# เพิ่มไฟล์สำคัญเข้า Git
echo "Adding files to repository..."
git add .
git commit -m "Initial commit: RPGM game files"

# สร้าง branch สำหรับ patches
git checkout -b patches
git checkout main

echo
echo "[SUCCESS] Git Repository setup completed"
echo "Repository URL: https://${serverUrl}/${userName}/${repoName}"
echo
read -p "Press Enter to continue..."
"@

# ============================================================================
# 3. Update Script (.bat)
# ============================================================================
$updateBat = @"
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
"@

# ============================================================================
# 4. Update Script (.sh)
# ============================================================================
$updateSh = @"
#!/bin/bash
# RPGM Game Updater Script for Linux/macOS

echo "============================================"
echo "        RPGM Game Updater"
echo "============================================"
echo

# สร้างสำรองข้อมูลก่อนอัพเดท
echo "Creating backup before update..."
BACKUP_DIR="backup_`$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "`$BACKUP_DIR"

# สำรองไฟล์ data และ save
if [ -d "data" ]; then
    cp -r "data" "`$BACKUP_DIR/"
fi
if [ -d "save" ]; then
    cp -r "save" "`$BACKUP_DIR/"
fi
if [ -f "config.rpgmvp" ]; then
    cp "config.rpgmvp" "`$BACKUP_DIR/"
fi

echo "Backup created: `$BACKUP_DIR"

# ดึงข้อมูลล่าสุดจาก Git
echo "Fetching updates from repository..."
git fetch origin

# ตรวจสอบว่ามี patch ใหม่หรือไม่
NEW_PATCHES=`$(git log HEAD..origin/patches --oneline 2>/dev/null)
if [ ! -z "`$NEW_PATCHES" ]; then
    echo "Found new patches:"
    echo "`$NEW_PATCHES"
    read -p "Do you want to install these patches? (y/N): " choice
    if [[ `$choice =~ ^[Yy]`$ ]]; then
        echo "Installing patches..."
        git checkout patches
        git pull origin patches
        git checkout main
        git merge patches
        echo "[SUCCESS] Patches installed"
    fi
fi

# ดึงอัพเดทหลัก
echo "Pulling main updates..."
git pull origin main

echo
echo "[SUCCESS] Game updated successfully"
echo "Backup location: `$BACKUP_DIR"
echo
read -p "Press Enter to continue..."
"@

# ============================================================================
# 5. Rollback Script (.bat)
# ============================================================================
$rollbackBat = @"
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
"@

# ============================================================================
# 6. Rollback Script (.sh)
# ============================================================================
$rollbackSh = @"
#!/bin/bash
# RPGM Rollback Tool for Linux/macOS

echo "============================================"
echo "        RPGM Rollback Tool"
echo "============================================"
echo

# แสดงรายการ backup ที่มี
echo "Available backups:"
echo
ls -d backup_* 2>/dev/null
echo

read -p "Enter backup directory name to restore: " backup_dir

if [ ! -d "`$backup_dir" ]; then
    echo "[ERROR] Backup directory not found"
    exit 1
fi

echo "Restoring from `$backup_dir..."

# กู้คืนไฟล์
if [ -d "`$backup_dir/data" ]; then
    rm -rf "data" 2>/dev/null
    cp -r "`$backup_dir/data" .
    echo "- Data restored"
fi

if [ -d "`$backup_dir/save" ]; then
    rm -rf "save" 2>/dev/null
    cp -r "`$backup_dir/save" .
    echo "- Save files restored"
fi

if [ -f "`$backup_dir/config.rpgmvp" ]; then
    cp "`$backup_dir/config.rpgmvp" .
    echo "- Config restored"
fi

echo
echo "[SUCCESS] Rollback completed successfully"
echo
read -p "Press Enter to continue..."
"@

# ============================================================================
# 7. Patch Creator Script (.bat)
# ============================================================================
$patchCreatorBat = @"
@echo off
chcp 65001
title RPGM Patch Creator
echo ============================================
echo        RPGM Patch Creator
echo ============================================
echo.

set /p patch_name="ชื่อ Patch (เช่น translation-fix-v1.1): "
set /p patch_desc="คำอธิบาย Patch: "

echo กำลังสร้าง Patch: %patch_name%

:: สลับไป patches branch
git checkout patches

:: เพิ่มการเปลี่ยนแปลง
git add data/ img/ audio/ css/ js/ fonts/
git commit -m "Patch: %patch_name% - %patch_desc%"

:: สร้าง tag สำหรับ patch
git tag -a "patch-%patch_name%" -m "%patch_desc%"

:: push ไป remote
git push origin patches
git push origin "patch-%patch_name%"

:: กลับไป main branch
git checkout main

echo.
echo [SUCCESS] Patch '%patch_name%' สร้างเสร็จสิ้น
echo Tag: patch-%patch_name%
echo.
pause
"@

# ============================================================================
# สร้างไฟล์ทั้งหมด
# ============================================================================

# สร้าง Windows Batch Files
$gitSetupBat | Out-File -FilePath "git-setup.bat" -Encoding UTF8
$updateBat | Out-File -FilePath "update.bat" -Encoding UTF8
$rollbackBat | Out-File -FilePath "rollback.bat" -Encoding UTF8
$patchCreatorBat | Out-File -FilePath "create-patch.bat" -Encoding UTF8

# สร้าง Linux/macOS Shell Scripts
$gitSetupSh | Out-File -FilePath "git-setup.sh" -Encoding UTF8
$updateSh | Out-File -FilePath "update.sh" -Encoding UTF8
$rollbackSh | Out-File -FilePath "rollback.sh" -Encoding UTF8

# สร้าง README
$readme = @"
# RPGM Git Management Scripts

สคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM ที่รองรับการแปลและจัดการ Patch

## ไฟล์ที่สร้าง:

### Windows (.bat)
- **git-setup.bat** - ตั้งค่า Git Repository เริ่มต้น
- **update.bat** - อัพเดทเกมและ Patch
- **rollback.bat** - กู้คืนข้อมูลจาก Backup
- **create-patch.bat** - สร้าง Patch ใหม่

### Linux/macOS (.sh)
- **git-setup.sh** - ตั้งค่า Git Repository เริ่มต้น
- **update.sh** - อัพเดทเกมและ Patch
- **rollback.sh** - กู้คืนข้อมูลจาก Backup

## การใช้งาน:

1. **เริ่มต้น**: รันไฟล์ git-setup เพื่อตั้งค่า Repository
2. **อัพเดท**: รันไฟล์ update เพื่อดึง Patch และอัพเดทใหม่
3. **สร้าง Patch**: รันไฟล์ create-patch เพื่อสร้าง Patch ใหม่
4. **กู้คืน**: รันไฟล์ rollback หากมีปัญหา

## คุณสมบัติ:

- ✅ รองรับไฟล์ RPGM เฉพาะที่จำเป็น
- ✅ สำรองข้อมูลอัตโนมัติก่อนอัพเดท
- ✅ จัดการ Patch แยกต่างหาก
- ✅ กู้คืนข้อมูลได้หากมีปัญหา
- ✅ รองรับทั้ง Windows และ Linux/macOS

Repository: https://${serverUrl}/${userName}/${repoName}
"@

$readme | Out-File -FilePath "README.md" -Encoding UTF8

# ให้สิทธิ์ execute สำหรับ shell scripts (ถ้าอยู่ใน Linux/macOS)
if ($IsLinux -or $IsMacOS) {
    chmod +x git-setup.sh update.sh rollback.sh
}

Write-Host "`n=== สร้างไฟล์เสร็จสิ้น ===" -ForegroundColor Green
Write-Host "Repository: https://$serverUrl/$userName/$repoName" -ForegroundColor Cyan
Write-Host "`nไฟล์ที่สร้าง:" -ForegroundColor Yellow
Write-Host "- git-setup.bat/sh (ตั้งค่า Git)" -ForegroundColor White
Write-Host "- update.bat/sh (อัพเดทเกม)" -ForegroundColor White
Write-Host "- rollback.bat/sh (กู้คืนข้อมูล)" -ForegroundColor White
Write-Host "- create-patch.bat (สร้าง Patch)" -ForegroundColor White
Write-Host "- README.md (คู่มือการใช้งาน)" -ForegroundColor White

Write-Host "`nขั้นตอนถัดไป:" -ForegroundColor Magenta
Write-Host "1. รันไฟล์ git-setup เพื่อเริ่มต้น" -ForegroundColor White
Write-Host "2. ใส่ไฟล์ RPGM ลงในโฟลเดอร์" -ForegroundColor White
Write-Host "3. ใช้ update เพื่อดึงอัพเดท" -ForegroundColor White
Write-Host "4. ใช้ create-patch เพื่อสร้าง Patch ใหม่" -ForegroundColor White