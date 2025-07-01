# RPGM Git Scripts - Troubleshooting Guide

## Common Error Messages and Solutions

### "ossiers is not recognized as an internal or external command"
**Fixed in this version** - This was a typo in the original script.

### "error: remote origin already exists"
**Fixed in this version** - Script now checks if remote exists before adding it.

### "[ERROR] Failed to commit files"
**Causes:**
- No changes were made to the data folder
- Git user name/email not configured

**Solutions:**
1. Make sure you have actual changes in your data/ folder
2. Configure Git with:
   `
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   `

### Repository Access Issues
**Symptoms:** Cannot push/pull from remote repository

**Solutions:**
1. Check internet connection
2. Verify repository URL is correct
3. Ensure you have access permissions to the repository
4. Try accessing the repository URL in a web browser

### Data Folder Not Found
**Error:** "No data folder found in project root or www/"

**Solutions:**
1. Ensure you're running the script from your RPG Maker project directory
2. Check that your project has either:
   - A data/ folder in the root directory, OR
   - A www/data/ folder (for web deployment)

### Backup Issues
**Symptoms:** Save files not restored after update

**Solutions:**
1. Check if backup directory exists (backup_YYYY-MM-DD_HHMMSS)
2. Manually copy files from backup directory if needed
3. Ensure you have write permissions in the game directory

## For Developers

### Setting Up Your Repository
1. Create an empty repository on your Git server first
2. Place the git-setup-developer.bat in your RPG Maker project root
3. Run the script - it will initialize everything

### Creating Patches
1. Make changes to your data files
2. Run create-patch-developer.bat
3. Give your patch a descriptive name
4. The patch will be available to users through update.bat/sh

## For Users

### First Time Setup
1. Extract the game files
2. Run update.bat/sh once to connect to the repository
3. The script will download the latest version

### Updating Your Game
1. Run update.bat/sh whenever you want to check for updates
2. Your save files are automatically backed up before updates
3. If something goes wrong, use rollback.bat/sh

### If Updates Fail
1. Check your internet connection
2. Contact the developer - they may need to fix repository issues
3. Use rollback.bat/sh to restore your save files

## Technical Details

### What Gets Backed Up
- save/ folder (player saves)
- www/save/ folder (web deployment saves)
- config.rpgmvp (game configuration)
- www/config.rpgmvp (web deployment config)

### What Gets Updated
- data/ folder contents (game data files)
- www/data/ folder contents (web deployment data)

### File Structure
`
Your Game Directory/
├── data/                  # Game data (updated by Git)
├── save/                  # Your saves (backed up, never updated)
├── config.rpgmvp         # Your config (backed up, never updated)
├── update.bat            # Update script
├── rollback.bat          # Rollback script
└── backup_*/             # Automatic backups
`

## Getting Help
If you continue to have issues:
1. Check that Git is properly installed
2. Make sure you have internet access
3. Contact the game developer with the specific error message
4. Include your operating system information
