# RPGM Git Management Scripts (Data-Only) - Fixed Version

Scripts for managing Git repositories for RPG Maker games, including only the data folder for version control.

## Generated Files:

### For Developers:
- **git-setup-developer.bat** - Initializes the Git repository with only the data folder
- **create-patch-developer.bat** - Creates new patches for the data folder

### For Users (Distribute these):
- **update.bat/sh** - Updates the game data and applies patches
- **rollback.bat/sh** - Restores save files from backups

## Key Fixes Applied:

### Git Setup Script:
- ✅ Fixed "ossiers" typo (removed stray text)
- ✅ Added proper error handling for Git operations
- ✅ Fixed remote origin handling (checks if already exists)
- ✅ Improved commit logic (only commits if there are changes)
- ✅ Better branch management for patches

### Update Script:
- ✅ Enhanced error handling for all Git operations
- ✅ Improved backup timestamp generation
- ✅ Better handling of missing save files
- ✅ Fixed variable expansion issues
- ✅ Added validation for backup creation

### Linux/macOS Scripts:
- ✅ Fixed backup directory structure
- ✅ Improved error handling with proper exit codes
- ✅ Better conditional logic for file operations

## Usage Instructions:

### Developers:
1. Place your RPG Maker project files in the same directory as the scripts
2. Run git-setup-developer.bat to create the repository (only data or www/data is included)
3. Make changes to your game data files
4. Use create-patch-developer.bat to create patches for data changes
5. **Distribute only update.bat/sh and rollback.bat/sh to Users**

### Users:
1. Download the game files + update.bat/sh + rollback.bat/sh
2. Run update.bat/sh to receive data updates and patches
3. Run ollback.bat/sh to restore save files if needed

## Features:
- ✅ Users don't need Git knowledge
- ✅ Automatic save file backups before updates
- ✅ Separate patch management for data changes
- ✅ Save file restoration if issues occur
- ✅ Game data updates while preserving save files
- ✅ Supports Windows and Linux/macOS
- ✅ Flexible handling of data folder (root or www/data)
- ✅ Robust error handling and validation
- ✅ Proper handling of existing repositories

## Troubleshooting:

### Common Issues Fixed:
- **"ossiers" command not found** - Fixed typo in git-setup script
- **"remote origin already exists"** - Now checks before adding remote
- **Failed to commit files** - Only commits when there are actual changes
- **Backup restoration issues** - Improved file handling and validation

## Important Notes:
- **git-setup and create-patch are for Developers only**
- **Users receive only update and rollback scripts**
- Users don't manage the repository themselves
- Only the data folder (in project root or www) is included in the Git repository
- All scripts now include comprehensive error handling

Repository: https://git.chanomhub.online/Mochi/HJ063

## Real-World Usage:
1. **Developer**: Place RPG Maker game files in the same folder as git-setup-developer.bat and run it
2. **Distribute**: Copy update.bat/sh and rollback.bat/sh to Users along with the game
3. **User**: Run update.bat/sh to receive data updates
