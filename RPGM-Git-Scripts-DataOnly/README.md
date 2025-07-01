# RPGM Git Scripts - Data Only Version

## สำหรับปัญหาปัจจุบันของคุณ:

รัน **quick-fix.bat** หรือใช้คำสั่ง:
`atch
git add www/data/
git commit -m "Data Patch: th1"
git push origin main
`

## ไฟล์ที่สร้าง:

### สำหรับนักพัฒนา:
1. **git-setup.bat** - ตั้งค่า repository (เฉพาะ data)
2. **create-patch.bat** - สร้าง patch (เฉพาะ data)
3. **status-checker.bat** - ตรวจสอบสถานะ
4. **quick-fix.bat** - แก้ปัญหาด่วน

### สำหรับผู้เล่น:
1. **update.bat** - อัปเดตเกม

## จุดเด่นของเวอร์ชัน Data Only:

✅ **ติดตามเฉพาะไฟล์ data** - ไม่เอาไฟล์อื่นๆ ที่ไม่จำเป็น
✅ **ขนาดเล็ก** - Repository จะมีขนาดเล็กกว่ามาก
✅ **รวดเร็ว** - อัปเดตและ push ได้เร็วขึ้น
✅ **ง่ายต่อการใช้งาน** - เฉพาะไฟล์ที่จำเป็นเท่านั้น

## โครงสร้างโฟลเดอร์ที่รองรับ:

- data/ - สำหรับ RPG Maker MV/MZ
- www/data/ - สำหรับ RPG Maker MV/MZ (NW.js)

## การใช้งาน:

1. รัน git-setup.bat ครั้งแรก
2. แก้ไขไฟล์ใน data/
3. รัน create-patch.bat เพื่อสร้าง patch
4. ผู้เล่นรัน update.bat เพื่ออัปเดต

Repository: https://git.chanomhub.online/Mochi/HJ063
