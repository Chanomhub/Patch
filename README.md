# RPGM Git Management Scripts

สคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM ที่รองรับการแปลและจัดการ Patch อย่างเป็นระบบ

## ไฟล์ที่สร้าง:

### สำหรับ Developer:
- **git-setup-developer.bat** - ตั้งค่า Git Repository เริ่มต้น
- **create-patch-developer.bat** - สร้าง Patch ใหม่จากการเปลี่ยนแปลง

### สำหรับ User (แจกเฉพาะไฟล์เหล่านี้):
- **update.bat / update.sh** - อัพเดทเกมและ Patch ล่าสุด
- **rollback.bat / rollback.sh** - กู้คืน Save files จาก Backup อัตโนมัติ

## วิธีการใช้งาน:

### Developer:
1. วางไฟล์เกมในโฟลเดอร์เดียวกับ `git-setup-developer.bat`
2. รัน `git-setup-developer.bat` เพื่อเริ่มต้น Git Repository
3. อัพโหลดไฟล์เกมเข้า Git ตามต้องการ
4. ใช้ `create-patch-developer.bat` เพื่อสร้าง Patch ใหม่จากการเปลี่ยนแปลง
5. **แจกเฉพาะไฟล์ `update.bat/sh` และ `rollback.bat/sh` ให้ User**

### User:
1. ดาวน์โหลดเกมพร้อมไฟล์ `update.bat/sh`
2. รัน `update.bat/sh` เพื่อรับอัพเดทและ Patch ล่าสุด
3. หากเกมมีปัญหาหลังอัพเดท รัน `rollback.bat/sh` เพื่อกู้คืน Save files

## คุณสมบัติ:

- ✅ ผู้ใช้ไม่ต้องมีความรู้เรื่อง Git
- ✅ สำรอง Save files อัตโนมัติก่อนอัพเดท
- ✅ Patch ถูกจัดการแยกจากเกมหลัก
- ✅ กู้คืน Save files ได้หากเกิดปัญหา
- ✅ อัพเดทไฟล์เกมโดยไม่ลบ Save เดิม
- ✅ รองรับ Windows, Linux และ macOS

## หมายเหตุสำคัญ:

- **`git-setup-developer.bat` และ `create-patch-developer.bat` ใช้เฉพาะ Developer เท่านั้น**
- **User ควรได้รับเฉพาะไฟล์ `update` และ `rollback` เท่านั้น**
- User **ไม่ต้องยุ่งกับ Git หรือ Repository โดยตรง**

## ปัญหาที่อาจเจอใน Windows:

หากไม่สามารถรันสคริปต์ `.ps1` ได้ และแสดงข้อความว่า script ถูกบล็อก:

### วิธีแก้ (แนะนำแบบปลอดภัย):

1. เปิด PowerShell ด้วยสิทธิ์ Administrator
2. รันคำสั่ง:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
