#!/bin/bash
# RPGM Game Updater Script for Linux/macOS

echo "============================================"
echo "        RPGM Game Updater"
echo "============================================"
echo

# Check if Git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] Git is not installed"
    echo "Please install Git first:"
    echo "- Ubuntu/Debian: sudo apt install git"
    echo "- macOS: brew install git"
    echo "- Or contact developer for manual update files"
    exit 1
fi

# Check if it's a Git repository
if [ ! -d ".git" ]; then
    echo "Initializing Git repository for updates..."
    if ! git init >/dev/null 2>&1; then
        echo "[ERROR] Failed to initialize Git repository"
        exit 1
    fi
    
    if ! git remote add origin https://Mochi@git.chanomhub.online/Mochi/HJ063.git >/dev/null 2>&1; then
        echo "[ERROR] Failed to add remote repository"
        exit 1
    fi
    
    if ! git fetch origin >/dev/null 2>&1; then
        echo "[ERROR] Failed to fetch from remote repository"
        echo "Please check your internet connection and repository access"
        exit 1
    fi
    
    if ! git checkout -b main origin/main >/dev/null 2>&1; then
        echo "[ERROR] Failed to checkout main branch"
        exit 1
    fi
    echo "Repository connected successfully"
    echo
fi

# Create backup before update
echo "Creating backup before update..."
BACKUP_DIR="backup_$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup save and config files only
backup_created=false
if [ -d "save" ]; then
    cp -r "save" "$BACKUP_DIR/"
    echo "Backed up save/ folder"
    backup_created=true
fi
if [ -d "www/save" ]; then
    mkdir -p "$BACKUP_DIR/www_save"
    cp -r "www/save" "$BACKUP_DIR/www_save/"
    echo "Backed up www/save/ folder"
    backup_created=true
fi
if [ -f "config.rpgmvp" ]; then
    cp "config.rpgmvp" "$BACKUP_DIR/"
    echo "Backed up config.rpgmvp"
    backup_created=true
fi
if [ -f "www/config.rpgmvp" ]; then
    cp "www/config.rpgmvp" "$BACKUP_DIR/www_config.rpgmvp"
    echo "Backed up www/config.rpgmvp"
    backup_created=true
fi

if [ "$backup_created" = true ]; then
    echo "Backup created: $BACKUP_DIR"
else
    echo "No save files found to backup"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

# Fetch latest updates
echo "Fetching updates from repository..."
if ! git fetch origin >/dev/null 2>&1; then
    echo "[ERROR] Failed to fetch updates"
    echo "Please check your internet connection"
    exit 1
fi

# Check for new patches
echo "Checking for new patches..."
NEW_PATCHES=$(git log HEAD..origin/patches --oneline 2>/dev/null)
if [ -n "$NEW_PATCHES" ]; then
    echo "Found new patches:"
    echo "$NEW_PATCHES"
    read -p "Apply these patches? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        echo "Applying patches..."
        if ! git checkout patches >/dev/null 2>&1 ||
           ! git pull origin patches >/dev/null 2>&1 ||
           ! git checkout main >/dev/null 2>&1 ||
           ! git merge patches --no-edit >/dev/null 2>&1; then
            echo "[ERROR] Failed to apply patches"
            exit 1
        fi
        echo "[SUCCESS] Patches applied"
    fi
fi

# Pull main updates
echo "Pulling main updates..."
if ! git pull origin main >/dev/null 2>&1; then
    echo "[ERROR] Failed to pull main updates"
    echo "There may be conflicts or connection issues"
    exit 1
fi

# Restore save and config files
if [ "$backup_created" = true ]; then
    echo "Restoring save files and config..."
    if [ -d "$BACKUP_DIR/save" ]; then
        rm -rf "save" >/dev/null 2>&1
        cp -r "$BACKUP_DIR/save" .
        echo "Restored save/ folder"
    fi
    if [ -d "$BACKUP_DIR/www_save/save" ]; then
        rm -rf "www/save" >/dev/null 2>&1
        mkdir -p "www"
        cp -r "$BACKUP_DIR/www_save/save" "www/"
        echo "Restored www/save/ folder"
    fi
    if [ -f "$BACKUP_DIR/config.rpgmvp" ]; then
        cp "$BACKUP_DIR/config.rpgmvp" .
        echo "Restored config.rpgmvp"
    fi
    if [ -f "$BACKUP_DIR/www_config.rpgmvp" ]; then
        cp "$BACKUP_DIR/www_config.rpgmvp" "www/config.rpgmvp"
        echo "Restored www/config.rpgmvp"
    fi
fi

echo
echo "[SUCCESS] Game updated successfully"
if [ "$backup_created" = true ]; then
    echo "Save files restored from backup"
fi
echo
read -p "Press Enter to continue..."
