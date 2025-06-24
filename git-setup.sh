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
~$*

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
git remote add origin https://admin@git.chanomhub.online/admin/ทดสอบ.git

# เพิ่มไฟล์สำคัญเข้า Git
echo "Adding files to repository..."
git add .
git commit -m "Initial commit: RPGM game files"

# สร้าง branch สำหรับ patches
git checkout -b patches
git checkout main

echo
echo "[SUCCESS] Git Repository setup completed"
echo "Repository URL: https://git.chanomhub.online/admin/ทดสอบ"
echo
read -p "Press Enter to continue..."
