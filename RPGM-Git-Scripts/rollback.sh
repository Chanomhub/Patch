#!/bin/bash
# RPGM Rollback Tool for Linux/macOS

echo "============================================"
echo "        RPGM Rollback Tool"
echo "============================================"
echo

# List available backups
echo "Available backups:"
echo
backup_found=false
if ls -d backup_* 2>/dev/null; then
    backup_found=true
fi

if [ "$backup_found" = false ]; then
    echo "No backups found"
    echo "Run update.sh first to create backups"
    exit 1
fi
echo

read -p "Enter backup directory name to restore: " backup_dir

if [ ! -d "$backup_dir" ]; then
    echo "[ERROR] Backup directory '$backup_dir' not found"
    exit 1
fi

echo "Restoring from $backup_dir..."
restore_count=0

# Restore save and config files only
if [ -d "$backup_dir/save" ]; then
    rm -rf "save" >/dev/null 2>&1
    cp -r "$backup_dir/save" .
    echo "- Save files restored (save/)"
    ((restore_count++))
fi
if [ -d "$backup_dir/www_save/save" ]; then
    rm -rf "www/save" >/dev/null 2>&1
    mkdir -p "www"
    cp -r "$backup_dir/www_save/save" "www/"
    echo "- Save files restored (www/save/)"
    ((restore_count++))
fi
if [ -f "$backup_dir/config.rpgmvp" ]; then
    cp "$backup_dir/config.rpgmvp" .
    echo "- Config restored (config.rpgmvp)"
    ((restore_count++))
fi
if [ -f "$backup_dir/www_config.rpgmvp" ]; then
    cp "$backup_dir/www_config.rpgmvp" "www/config.rpgmvp"
    echo "- Config restored (www/config.rpgmvp)"
    ((restore_count++))
fi

echo
if [ $restore_count -gt 0 ]; then
    echo "[SUCCESS] Rollback completed - $restore_count items restored"
else
    echo "[WARNING] No files were restored from this backup"
fi
echo "Note: Game data files remain at latest version"
echo
read -p "Press Enter to continue..."
