#!/bin/bash
# RPGM Game Updater Script for Linux/macOS

echo "============================================"
echo "        RPGM Game Updater"
echo "============================================"
echo

# สร้างสำรองข้อมูลก่อนอัพเดท
echo "Creating backup before update..."
BACKUP_DIR="backup_$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "$BACKUP_DIR"

# สำรองไฟล์ data และ save
if [ -d "data" ]; then
    cp -r "data" "$BACKUP_DIR/"
fi
if [ -d "save" ]; then
    cp -r "save" "$BACKUP_DIR/"
fi
if [ -f "config.rpgmvp" ]; then
    cp "config.rpgmvp" "$BACKUP_DIR/"
fi

echo "Backup created: $BACKUP_DIR"

# ดึงข้อมูลล่าสุดจาก Git
echo "Fetching updates from repository..."
git fetch origin

# ตรวจสอบว่ามี patch ใหม่หรือไม่
NEW_PATCHES=$(git log HEAD..origin/patches --oneline 2>/dev/null)
if [ ! -z "$NEW_PATCHES" ]; then
    echo "Found new patches:"
    echo "$NEW_PATCHES"
    read -p "Do you want to install these patches? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
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
echo "Backup location: $BACKUP_DIR"
echo
read -p "Press Enter to continue..."
