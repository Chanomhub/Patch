# RPGM Git Scripts - Enhanced Fixed Version

## Quick Fix for Your Issue:
Your repository has untracked files. Run these commands in your project folder:

`ash
# Add all game files
git add .

# Commit them
git commit -m "Add all game files"

# Push to repository
git push origin main
`

Then you can use create-patch.bat normally.

## For Developers:
1. **git-setup.bat** - Initialize repository (improved .gitignore)
2. **create-patch.bat** - Create patches (now detects all changes)
3. **status-checker.bat** - Check repository status
4. **clean-repo.bat** - Clean untracked files

## For Users:
1. **update.bat** - Update game
2. **rollback.bat** - Restore saves

## What's Fixed:
✅ **Better change detection** - Finds untracked and modified files
✅ **Enhanced .gitignore** - Properly excludes system files
✅ **Status checker** - See what's in your repository  
✅ **Repository cleaner** - Remove unwanted files
✅ **Improved file adding** - Adds all game-related folders

## Your Current Issue:
The original script only looked for changes in data/ folder, but your repository has many untracked files that need to be added first.

Repository: https://git.chanomhub.online/Mochi/HJ063
