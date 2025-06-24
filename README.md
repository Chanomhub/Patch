# RPGM Git Management Scripts

สคริปต์สำหรับจัดการ Git Repository สำหรับเกม RPGM ที่รองรับการแปลและจัดการ Patch

## ไฟล์ที่สร้าง:

### Windows (.bat)
- **git-setup.bat** - ตั้งค่า Git Repository เริ่มต้น
- **update.bat** - อัพเดทเกมและ Patch
- **rollback.bat** - กู้คืนข้อมูลจาก Backup
- **create-patch.bat** - สร้าง Patch ใหม่

### Linux/macOS (.sh)
- **git-setup.sh** - ตั้งค่า Git Repository เริ่มต้น
- **update.sh** - อัพเดทเกมและ Patch
- **rollback.sh** - กู้คืนข้อมูลจาก Backup

## การใช้งาน:

1. **เริ่มต้น**: รันไฟล์ git-setup เพื่อตั้งค่า Repository
2. **อัพเดท**: รันไฟล์ update เพื่อดึง Patch และอัพเดทใหม่
3. **สร้าง Patch**: รันไฟล์ create-patch เพื่อสร้าง Patch ใหม่
4. **กู้คืน**: รันไฟล์ rollback หากมีปัญหา

## คุณสมบัติ:

- ✅ รองรับไฟล์ RPGM เฉพาะที่จำเป็น
- ✅ สำรองข้อมูลอัตโนมัติก่อนอัพเดท
- ✅ จัดการ Patch แยกต่างหาก
- ✅ กู้คืนข้อมูลได้หากมีปัญหา
- ✅ รองรับทั้ง Windows และ Linux/macOS

Repository: https://git.chanomhub.online/admin/ทดสอบ
