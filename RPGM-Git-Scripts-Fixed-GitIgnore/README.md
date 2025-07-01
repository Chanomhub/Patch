# RPGM Git Scripts - Fixed GitIgnore Conflict

**Repository:** https://git.chanomhub.online/Mochi/HJ063  
**User:** Mochi  
**Fixed Issue:** GitIgnore rules conflict resolved

## 🚨 Problem Fixed:

**Previous Issue:** .gitignore was blocking www/data/ because it ignored www/* first

**Solution:** Reordered .gitignore rules to allow specific paths BEFORE broader ignores

## 🔧 Fixed GitIgnore Rules:

`gitignore
# ALLOW THESE FIRST (before broader ignores)
!/.gitignore
!/README.md
!/data/
!/www/data/

# THEN IGNORE EVERYTHING ELSE
/www/js/
/www/css/
/www/img/
/www/audio/
/www/fonts/
/www/movies/
/www/icon/
/www/text/
/www/data2/
/www/data_*/
# ... etc
`

## 📁 Generated Files:

1. **git-setup.bat** - Setup with fixed .gitignore
2. **quick-fix.bat** - Fix current repository
3. **create-patch.bat** - Create data patches
4. **README.md** - This documentation

## 🎯 What Gets Tracked:

### ✅ Tracked:
- data/ - Game data files
- www/data/ - Web version data files  
- .gitignore - Git configuration
- README.md - Documentation

### ❌ Ignored:
- www/icon/ - Icons
- www/text/ - Text files
- www/data2/ - Backup data
- www/js/, www/css/, www/img/ - Web assets
- *.exe, *.dll, *.bat - Executables and scripts
- save/ - Save files

## 🔥 Quick Fix Instructions:

1. Copy quick-fix.bat to your game folder
2. Run quick-fix.bat
3. Enter patch name when prompted
4. Done! Repository is now fixed

## 💡 Key Changes Made:

✅ **Fixed .gitignore order** - Allow specific paths before broad ignores  
✅ **Added -f flag** - Force add www/data/ to override gitignore  
✅ **Better error handling** - Check if files are actually staged  
✅ **Clearer output** - Show exactly what's being tracked  

## 🌐 Repository Info:

- **URL:** https://git.chanomhub.online/Mochi/HJ063
- **Clone:** git clone https://Mochi@git.chanomhub.online/Mochi/HJ063.git
- **Remote:** git remote add origin https://Mochi@git.chanomhub.online/Mochi/HJ063.git

## 🔧 Manual Commands (if needed):

`ash
# Create fixed .gitignore (order matters!)
echo "!/.gitignore" > .gitignore
echo "!/data/" >> .gitignore  
echo "!/www/data/" >> .gitignore
echo "/www/js/" >> .gitignore
echo "/www/css/" >> .gitignore
# ... add other ignore rules

# Clear cache and re-add
git rm -r --cached .
git add .gitignore
git add data/
git add -f www/data/  # Force add to override gitignore

# Commit and push
git commit -m "Fixed: Data-only repository"
git push origin main
`

**Note:** The -f flag forces Git to add www/data/ even if .gitignore rules would normally prevent it.