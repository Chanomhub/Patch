# ============================================================================
# RPGM Git Management Scripts Generator - FIXED VERSION
# สร้างสคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM
# ============================================================================

Write-Host "=== RPGM Git Management Scripts Generator (Fixed) ===" -ForegroundColor Cyan
Write-Host "สร้างสคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM" -ForegroundColor Yellow

# แสดงโฟลเดอร์ปัจจุบัน
$currentDir = Get-Location
Write-Host "โฟลเดอร์ปัจจุบัน: $currentDir" -ForegroundColor Gray

# รับข้อมูลจากผู้ใช้
$repoName = Read-Host "ชื่อ Repository (เช่น my-rpgm-game)"
$serverUrl = "git.chanomhub.online"
$userName = Read-Host "Username สำหรับ Git"

Write-Host "`nกำลังสร้างไฟล์สคริปต์..." -ForegroundColor Green
Write-Host "Note: git-setup สำหรับ Developer เท่านั้น, User ได้รับแค่ update scripts" -ForegroundColor Yellow

# สร้างโฟลเดอร์สำหรับเก็บไฟล์ที่สร้าง
$outputDir = "RPGM-Git-Scripts"
if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
Write-Host "สร้างโฟลเดอร์: $outputDir" -ForegroundColor Gray

# ============================================================================
# 1. Git Setup Script (.bat) - สำหรับ Developer เท่านั้น
# ============================================================================
$gitSetupBat = @"
@echo off
chcp 65001
title RPGM Git Setup (Developer Only)
echo ============================================
echo    RPGM Git Repository Setup
echo    *** FOR DEVELOPER USE ONLY ***
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
echo # Node modules (if any^)
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

:: Push ไป remote
echo Push ไฟล์ขึ้น Remote Repository...
git push -u origin main
git push -u origin patches

echo.
echo [SUCCESS] Git Repository ตั้งค่าเสร็จสิ้น
echo Repository URL: https://${serverUrl}/${userName}/${repoName}
echo.
echo *** จากนี้แจกแค่ไฟล์ update.bat ให้ User ***
echo.
pause
"@

# ============================================================================
# 2. Update Script (.bat) - สำหรับ User
# ============================================================================
$updateBat = @"
@echo off
chcp 65001
title RPGM Game Updater
echo ============================================
echo        RPGM Game Updater
echo ============================================
echo.

:: ตรวจสอบว่ามี Git หรือไม่
git --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] กำลังดาวน์โหลด Portable Git...
    echo กรุณารอสักครู่...
    
    :: ดาวน์โหลด Portable Git (ถ้าต้องการ^)
    echo หากไม่สามารถอัพเดทได้ กรุณาติดตั้ง Git จาก:
    echo https://git-scm.com/
    echo.
    echo หรือติดต่อ Developer เพื่อขอไฟล์อัพเดทแบบ Manual
    pause
    exit /b 1
)

:: ตรวจสอบว่าเป็น Git Repository หรือไม่
if not exist ".git" (
    echo เริ่มต้น Git Repository สำหรับการอัพเดท...
    git init
    git remote add origin https://${userName}@${serverUrl}/${userName}/${repoName}.git
    git fetch origin
    git checkout -b main origin/main
    echo Repository เชื่อมต่อแล้ว
    echo.
)

:: สร้างสำรองข้อมูลก่อนอัพเดท
echo สร้างสำรองข้อมูลก่อนอัพเดท...
set BACKUP_DIR=backup_%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set BACKUP_DIR=%BACKUP_DIR: =0%
mkdir "%BACKUP_DIR%" 2>nul

:: สำรองไฟล์ save และ config เท่านั้น (ไม่สำรอง data เพราะจะถูกอัพเดท^)
if exist "save" xcopy "save" "%BACKUP_DIR%\save\" /E /I /Q
if exist "config.rpgmvp" copy "config.rpgmvp" "%BACKUP_DIR%\" >nul

echo Backup created: %BACKUP_DIR%

:: ดึงข้อมูลล่าสุดจาก Git
echo ดึงข้อมูลอัพเดทจาก Repository...
git fetch origin

:: ตรวจสอบว่ามี patch ใหม่หรือไม่
echo ตรวจสอบ Patch ใหม่...
git log HEAD..origin/patches --oneline > temp_patches.txt 2>nul
if exist temp_patches.txt (
    for /f "tokens=*" %%i in (temp_patches.txt^) do (
        echo พบ Patch ใหม่: %%i
        set /p choice="ต้องการติดตั้ง Patch นี้หรือไม่? (Y/N^): "
        if /i "!choice!"=="Y" (
            echo กำลังติดตั้ง Patch...
            git checkout patches 2>nul
            git pull origin patches 2>nul
            git checkout main
            git merge patches --no-edit
            echo [SUCCESS] Patch ติดตั้งเสร็จสิ้น
        )
        goto :patch_done
    )
)
:patch_done
del temp_patches.txt 2>nul

:: ดึงอัพเดทหลัก
echo ดึงอัพเดทหลัก...
git pull origin main

:: กู้คืนไฟล์ save และ config
echo กู้คืน Save files และ Config...
if exist "%BACKUP_DIR%\save" (
    xcopy "%BACKUP_DIR%\save\" "save\" /E /I /Q
)
if exist "%BACKUP_DIR%\config.rpgmvp" (
    copy "%BACKUP_DIR%\config.rpgmvp" . >nul
)

echo.
echo [SUCCESS] อัพเดทเกมเสร็จสิ้น
echo Save files ได้รับการกู้คืนแล้ว
echo.
pause
"@

# ============================================================================
# 3. Update Script (.sh) - สำหรับ User
# ============================================================================
$updateSh = @"
#!/bin/bash
# RPGM Game Updater Script for Linux/macOS

echo "============================================"
echo "        RPGM Game Updater"
echo "============================================"
echo

# ตรวจสอบว่ามี Git หรือไม่
if ! command -v git &> /dev/null; then
    echo "[ERROR] Git is not installed"
    echo "Please install Git first:"
    echo "- Ubuntu/Debian: sudo apt install git"
    echo "- macOS: brew install git"
    echo "- Or contact developer for manual update files"
    exit 1
fi

# ตรวจสอบว่าเป็น Git Repository หรือไม่
if [ ! -d ".git" ]; then
    echo "Initializing Git Repository for updates..."
    git init
    git remote add origin https://${userName}@${serverUrl}/${userName}/${repoName}.git
    git fetch origin
    git checkout -b main origin/main
    echo "Repository connected"
    echo
fi

# สร้างสำรองข้อมูลก่อนอัพเดท
echo "Creating backup before update..."
BACKUP_DIR="backup_`$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "`$BACKUP_DIR"

# สำรองไฟล์ save และ config เท่านั้น
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
echo "Checking for new patches..."
NEW_PATCHES=`$(git log HEAD..origin/patches --oneline 2>/dev/null)
if [ ! -z "`$NEW_PATCHES" ]; then
    echo "Found new patches:"
    echo "`$NEW_PATCHES"
    read -p "Do you want to install these patches? (y/N): " choice
    if [[ `$choice =~ ^[Yy]`$ ]]; then
        echo "Installing patches..."
        git checkout patches 2>/dev/null
        git pull origin patches 2>/dev/null
        git checkout main
        git merge patches --no-edit
        echo "[SUCCESS] Patches installed"
    fi
fi

# ดึงอัพเดทหลัก
echo "Pulling main updates..."
git pull origin main

# กู้คืนไฟล์ save และ config
echo "Restoring save files and config..."
if [ -d "`$BACKUP_DIR/save" ]; then
    cp -r "`$BACKUP_DIR/save" .
fi
if [ -f "`$BACKUP_DIR/config.rpgmvp" ]; then
    cp "`$BACKUP_DIR/config.rpgmvp" .
fi

echo
echo "[SUCCESS] Game updated successfully"
echo "Save files have been restored"
echo
read -p "Press Enter to continue..."
"@

# ============================================================================
# 4. Rollback Script (.bat) - สำหรับ User
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
if errorlevel 1 (
    echo ไม่พบ Backup files
    pause
    exit /b 1
)
echo.

set /p backup_dir="ชื่อโฟลเดอร์ Backup ที่ต้องการกู้คืน: "

if not exist "%backup_dir%" (
    echo [ERROR] ไม่พบโฟลเดอร์ Backup ที่ระบุ
    pause
    exit /b 1
)

echo กำลังกู้คืนข้อมูลจาก %backup_dir%...

:: กู้คืนไฟล์ save และ config เท่านั้น
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
echo หมายเหตุ: ไฟล์เกมจะไม่ถูกกู้คืน (ใช้เวอร์ชันล่าสุด^)
echo.
pause
"@

# ============================================================================
# 5. Rollback Script (.sh) - สำหรับ User
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
if ! ls -d backup_* 2>/dev/null; then
    echo "No backup files found"
    exit 1
fi
echo

read -p "Enter backup directory name to restore: " backup_dir

if [ ! -d "`$backup_dir" ]; then
    echo "[ERROR] Backup directory not found"
    exit 1
fi

echo "Restoring from `$backup_dir..."

# กู้คืนไฟล์ save และ config เท่านั้น
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
echo "Note: Game files remain at latest version"
echo
read -p "Press Enter to continue..."
"@

# ============================================================================
# 6. Patch Creator Script (.bat) - สำหรับ Developer เท่านั้น
# ============================================================================
$patchCreatorBat = @"
@echo off
chcp 65001
title RPGM Patch Creator (Developer Only)
echo ============================================
echo    RPGM Patch Creator
echo    *** FOR DEVELOPER USE ONLY ***
echo ============================================
echo.

set /p patch_name="ชื่อ Patch (เช่น translation-fix-v1.1^): "
set /p patch_desc="คำอธิบาย Patch: "

echo กำลังสร้าง Patch: %patch_name%

:: สลับไป patches branch
git checkout patches

:: เพิ่มการเปลี่ยนแปลง
git add data/ img/ audio/ css/ js/ fonts/ movies/
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
echo Users สามารถรัน update.bat เพื่อรับ Patch นี้
echo.
pause
"@

# ============================================================================
# สร้างไฟล์ทั้งหมด
# ============================================================================

try {
    # สร้าง Developer Scripts
    Write-Host "สร้างไฟล์ Developer scripts..." -ForegroundColor Gray
    $gitSetupBat | Out-File -FilePath "$outputDir\git-setup-developer.bat" -Encoding ASCII
    $patchCreatorBat | Out-File -FilePath "$outputDir\create-patch-developer.bat" -Encoding ASCII
    Write-Host "✓ Developer scripts สร้างเสร็จ" -ForegroundColor Green

    # สร้าง User Scripts
    Write-Host "สร้างไฟล์ User scripts..." -ForegroundColor Gray
    $updateBat | Out-File -FilePath "$outputDir\update.bat" -Encoding ASCII
    $rollbackBat | Out-File -FilePath "$outputDir\rollback.bat" -Encoding ASCII
    Write-Host "✓ User scripts (.bat) สร้างเสร็จ" -ForegroundColor Green

    # สร้าง Linux/macOS Scripts
    Write-Host "สร้างไฟล์ Linux/macOS scripts..." -ForegroundColor Gray
    $updateSh | Out-File -FilePath "$outputDir\update.sh" -Encoding UTF8
    $rollbackSh | Out-File -FilePath "$outputDir\rollback.sh" -Encoding UTF8
    Write-Host "✓ Linux/macOS scripts สร้างเสร็จ" -ForegroundColor Green

    # สร้าง README
    Write-Host "สร้างไฟล์ README..." -ForegroundColor Gray
    $readme = @"
# RPGM Git Management Scripts

สคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM ที่รองรับการแปลและจัดการ Patch

## ไฟล์ที่สร้าง:

### สำหรับ Developer:
- **git-setup-developer.bat** - ตั้งค่า Git Repository เริ่มต้น
- **create-patch-developer.bat** - สร้าง Patch ใหม่

### สำหรับ User (แจกไฟล์เหล่านี้):
- **update.bat/sh** - อัพเดทเกมและ Patch
- **rollback.bat/sh** - กู้คืน Save files จาก Backup

## วิธีการใช้งาน:

### Developer:
1. รัน `git-setup-developer.bat` เพื่อสร้าง Repository
2. อัพโหลดไฟล์เกมเข้า Git
3. ใช้ `create-patch-developer.bat` เพื่อสร้าง Patch
4. **แจกแค่ไฟล์ update.bat/sh และ rollback.bat/sh ให้ User**

### User:
1. ดาวน์โหลดเกม + ไฟล์ update.bat/sh
2. รัน `update.bat/sh` เพื่อรับอัพเดทและ Patch
3. รัน `rollback.bat/sh` หากต้องการกู้คืน Save files

## คุณสมบัติ:

- ✅ User ไม่ต้องมีความรู้เรื่อง Git
- ✅ สำรอง Save files อัตโนมัติก่อนอัพเดท
- ✅ จัดการ Patch แยกต่างหาก
- ✅ กู้คืน Save files ได้หากมีปัญหา
- ✅ ไฟล์เกมอัพเดทแต่ Save files ยังคงอยู่
- ✅ รองรับทั้ง Windows และ Linux/macOS

## สำคัญ:
- **git-setup และ create-patch สำหรับ Developer เท่านั้น**
- **User ได้รับแค่ update และ rollback scripts**
- User ไม่ต้องจัดการ Repository เอง

Repository: https://${serverUrl}/${userName}/${repoName}

## การใช้งานจริง:

1. **Developer**: วางไฟล์เกม RPGM ในโฟลเดอร์เดียวกับ git-setup-developer.bat แล้วรัน
2. **แจก**: คัดลอก update.bat และ rollback.bat ไปให้ User พร้อมกับเกม
3. **User**: รัน update.bat เมื่อต้องการอัพเดท
"@

    $readme | Out-File -FilePath "$outputDir\README.md" -Encoding UTF8
    Write-Host "✓ README สร้างเสร็จ" -ForegroundColor Green

    # แสดงรายการไฟล์ที่สร้าง
    Write-Host "`n=== ไฟล์ที่สร้างเสร็จแล้ว ===" -ForegroundColor Green
    Get-ChildItem $outputDir | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 1)
        Write-Host "✓ $($_.Name) ($size KB)" -ForegroundColor White
    }

    Write-Host "`n=== สรุป ===" -ForegroundColor Cyan
    Write-Host "โฟลเดอร์: $outputDir" -ForegroundColor White
    Write-Host "Repository: https://$serverUrl/$userName/$repoName" -ForegroundColor Yellow

    Write-Host "`n=== สำหรับ Developer ===" -ForegroundColor Magenta
    Write-Host "- git-setup-developer.bat (ตั้งค่า Git Repository)" -ForegroundColor White
    Write-Host "- create-patch-developer.bat (สร้าง Patch)" -ForegroundColor White

    Write-Host "`n=== สำหรับ User (แจกไฟล์เหล่านี้) ===" -ForegroundColor Green
    Write-Host "- update.bat/sh (อัพเดทเกม)" -ForegroundColor White
    Write-Host "- rollback.bat/sh (กู้คืน Save files)" -ForegroundColor White
    Write-Host "- README.md (คู่มือการใช้งาน)" -ForegroundColor White

    Write-Host "`nขั้นตอนถัดไป:" -ForegroundColor Yellow
    Write-Host "1. [Developer] นำไฟล์เกม RPGM มาใส่ในโฟลเดอร์เดียวกับ git-setup-developer.bat" -ForegroundColor White
    Write-Host "2. [Developer] รัน git-setup-developer.bat" -ForegroundColor White
    Write-Host "3. [Developer] แจกเกม + update.bat/sh ให้ User" -ForegroundColor White
    Write-Host "4. [User] รัน update.bat/sh เพื่อรับอัพเดท" -ForegroundColor White

    # เปิดโฟลเดอร์ที่สร้างไฟล์
    Write-Host "`nกำลังเปิดโฟลเดอร์..." -ForegroundColor Gray
    Invoke-Item $outputDir

} catch {
    Write-Host "`n[ERROR] เกิดข้อผิดพลาดในการสร้างไฟล์:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nกรุณาตรวจสอบสิทธิ์การเขียนไฟล์และโฟลเดอร์" -ForegroundColor Yellow
}