# RPGM Git Scripts - Complete Data Only Fix

**Repository:** https://git.chanomhub.online/Mochi/HJ063  
**User:** Mochi  
**Server:** git.chanomhub.online

## 🚨 สำหรับปัญหาที่เกิดขึ้น:

**ปัญหา:** Repository ติดตามไฟล์ที่ไม่ต้องการ (www/icon/, www/text/, www/data2/, etc.)

**วิธีแก้ด่วน:**
1. รัน **quick-fix.bat** 
2. หรือใช้คำสั่งใน command prompt:

`atch
cd "path\to\your\game\folder"
# Copy quick-fix.bat ไปใส่ในโฟลเดอร์เกม แล้วรัน
quick-fix.bat
`

## 📁 ไฟล์ที่สร้าง:

### สำหรับนักพัฒนา:
1. **git-setup.bat** - ตั้งค่า repository (strict data only)
2. **create-patch.bat** - สร้าง patch (เฉพาะ data)
3. **quick-fix.bat** - 🔥 **แก้ปัญหาปัจจุบัน**
4. **status-checker.bat** - ตรวจสอบสถานะ

### สำหรับผู้เล่น:
1. **update.bat** - อัปเดตเกม

## ✅ จุดเด่นของเวอร์ชัน Fixed:

✅ **Strict Data Only** - เฉพาะ data/ และ www/data/ เท่านั้น  
✅ **ไม่ติดตาม** - www/icon/, www/text/, www/data2/, www/data_*, *.bat  
✅ **ขนาดเล็ก** - Repository มีขนาดเล็กสุด  
✅ **แก้ปัญหาปัจจุบัน** - มี quick-fix.bat  
✅ **ป้องกันข้อผิดพลาด** - .gitignore เข้มงวด  
✅ **Variables Fixed** - ไม่มี placeholder variables แล้ว

## 🎯 โฟลเดอร์ที่จะติดตาม:

### ✅ ติดตาม:
- data/ - ข้อมูลเกมหลัก
- www/data/ - ข้อมูลเกม (NW.js version)
- .gitignore - การตั้งค่า
- README.md - คู่มือ

### ❌ ไม่ติดตาม:
- www/icon/ - ไอคอน
- www/text/ - ข้อความ
- www/data2/ - ข้อมูลสำรอง
- www/data_* - ข้อมูลสำรองทุกชนิด
- *.bat - ไฟล์ script
- save/ - ไฟล์เซฟ
- *.exe, *.dll - ไฟล์รัน

## 🔧 วิธีแก้ปัญหาปัจจุบัน:

### วิธีที่ 1: ใช้ quick-fix.bat
1. Copy quick-fix.bat ไปยังโฟลเดอร์เกม
2. Double-click รัน
3. ใส่ชื่อ patch (เช่น "th1")
4. เสร็จ!

### วิธีที่ 2: Manual Command
`atch
# สร้าง .gitignore ใหม่
echo # Ignore everything > .gitignore
echo /* >> .gitignore
echo www/* >> .gitignore
echo !.gitignore >> .gitignore
echo !data/ >> .gitignore
echo !www/data/ >> .gitignore

# ลบ cache และเพิ่มใหม่
git rm -r --cached .
git add .gitignore
git add data/
git add www/data/

# Commit และ push
git commit -m "Data Patch: th1 (cleaned up)"
git push origin main
`

## 📋 การใช้งานปกติ:

1. **ครั้งแรก:** รัน git-setup.bat
2. **แก้ไขข้อมูล:** แก้ไขไฟล์ใน data/ หรือ www/data/
3. **สร้าง patch:** รัน create-patch.bat
4. **ผู้เล่นอัปเดต:** รัน update.bat

## 🌐 Repository Configuration:

- **URL:** https://git.chanomhub.online/Mochi/HJ063
- **User:** Mochi
- **Server:** git.chanomhub.online
- **Clone Command:** git clone https://Mochi@git.chanomhub.online/Mochi/HJ063.git

## 🔧 Git Commands (Manual):

`ash
# Clone repository
git clone https://Mochi@git.chanomhub.online/Mochi/HJ063.git

# Add remote (if needed)
git remote add origin https://Mochi@git.chanomhub.online/Mochi/HJ063.git

# Check status
git status

# Create patch
git add data/ www/data/
git commit -m "Data Patch: [patch_name]"
git push origin main
`

**หมายเหตุ:** เวอร์ชันนี้แก้ปัญหา variable substitution แล้ว ไม่มี placeholder variables เหลืออยู่ในไฟล์ .bat