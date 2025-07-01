# 🎮 RPGM Git Management Scripts

สคริปต์สำหรับจัดการ Git Repository ของเกม **RPG Maker** รองรับการแปลและ Patch อย่างเป็นระบบ ใช้งานง่ายทั้ง Developer และ User!

## 📂 ไฟล์ที่เกี่ยวข้อง

### 🛠️ สำหรับ Developer
- **`git-setup-developer.bat`** - ตั้งค่า Git Repository เริ่มต้น
- **`create-patch-developer.bat`** - สร้าง Patch จากการเปลี่ยนแปลง

### 🎮 สำหรับ User
- **`update.bat` / `update.sh`** - อัพเดทเกมและ Patch ล่าสุด
- **`rollback.bat` / `rollback.sh`** - กู้คืน Save files จาก Backup

## 🚀 วิธีใช้งาน

### 🛠️ Developer
1. วางไฟล์เกมในโฟลเดอร์เดียวกับ `git-setup-developer.bat`
2. รัน `git-setup-developer.bat` เพื่อตั้งค่า Repository
3. อัพโหลดไฟล์เกมไปยัง Git
4. รัน `create-patch-developer.bat` เพื่อสร้าง Patch
5. แจกเฉพาะ `update.bat/sh` และ `rollback.bat/sh` ให้ User

### 🎮 User
1. ดาวน์โหลดเกมพร้อม `update.bat/sh` และ `rollback.bat/sh`
2. รัน `update.bat` หรือ `update.sh` เพื่ออัพเดท
3. หากมีปัญหา รัน `rollback.bat` หรือ `rollback.sh` เพื่อกู้คืน

## ✨ คุณสมบัติ
- [x] ผู้ใช้ไม่ต้องรู้จัก Git
- [x] สำรอง Save files อัตโนมัติ
- [x] จัดการ Patch แยกจากเกมหลัก
- [x] กู้คืน Save files ได้
- [x] อัพเดทโดยไม่ลบ Save เดิม
- [x] รองรับ Windows, Linux, macOS

## ⚠️ หมายเหตุ
- **Developer**: ใช้ `git-setup-developer.bat` และ `create-patch-developer.bat` เฉพาะ Developer  
- **User**: ใช้เฉพาะ `update.bat/sh` และ `rollback.bat/sh`

## 🛑 แก้ปัญหา Windows
หากสคริปต์ `.ps1` ถูกบล็อก:
1. เปิด PowerShell ด้วยสิทธิ์ Admin
2. รัน:
   ```powershell
   Set-ExecutionPolicy -Force RemoteSigned -Scope CurrentUser
