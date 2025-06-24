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
