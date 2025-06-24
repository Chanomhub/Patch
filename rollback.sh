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

if [ ! -d "$backup_dir" ]; then
    echo "[ERROR] Backup directory not found"
    exit 1
fi

echo "Restoring from $backup_dir..."

# กู้คืนไฟล์
if [ -d "$backup_dir/data" ]; then
    rm -rf "data" 2>/dev/null
    cp -r "$backup_dir/data" .
    echo "- Data restored"
fi

if [ -d "$backup_dir/save" ]; then
    rm -rf "save" 2>/dev/null
    cp -r "$backup_dir/save" .
    echo "- Save files restored"
fi

if [ -f "$backup_dir/config.rpgmvp" ]; then
    cp "$backup_dir/config.rpgmvp" .
    echo "- Config restored"
fi

echo
echo "[SUCCESS] Rollback completed successfully"
echo
read -p "Press Enter to continue..."
