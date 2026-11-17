# แผนงาน: เข้าสู่ระบบด้วย Google

สถานะ: **หยุดพักไว้** — รอผู้ใช้ตั้งค่า Google Cloud Console (ขั้นที่ 1) ก่อนถึงจะเริ่มเขียนโค้ดต่อได้

## เป้าหมาย

เพิ่มการเข้าสู่ระบบด้วย Google ให้แอป Tripitaka91 นอกเหนือจาก username/password เดิม โดย:
- ใช้ username ที่ตรงกับอีเมลของบัญชี Google มาประมวลผล
- ถ้ายังไม่มี user นี้ในระบบ ให้สร้างใหม่ทันที ไม่ต้องรอยืนยัน
- ทุกครั้งที่เข้าสู่ระบบ ให้แสดงผ่านหน้าจอ Dialog (เหมือนที่ใช้งานอยู่ตอนนี้)

## โปรเจกต์อ้างอิงที่ศึกษาไว้

`D:\WebTripitaka91\DharmaTimeStamp` — เว็บ PHP ที่มีระบบ Google login อยู่แล้ว (`web/src/auth.php`, `web/public/auth/google_login.php`)

**Pattern ที่นำมาใช้ได้:**
- ยืนยัน Google ID token ฝั่งเซิร์ฟเวอร์ผ่าน `https://oauth2.googleapis.com/tokeninfo?id_token=...` (เรียก HTTPS ตรง ไม่ต้องติดตั้ง JWT library)
- เช็ค `aud` ของ token ให้ตรงกับ Client ID ของเราเอง, เช็ค `email_verified` และ `exp`
- Upsert user ด้วย email ทันที (`INSERT ... ON DUPLICATE KEY UPDATE`) ไม่ต้องรอ confirm

**ส่วนที่ใช้ตรงๆ ไม่ได้:** หน้าเว็บใช้ Google Identity Services JS SDK (เบราว์เซอร์เท่านั้น) — แอปเราเป็น Flutter mobile/desktop ต้องใช้ native SDK (`google_sign_in` package) แทน

## การตัดสินใจที่ยืนยันแล้วกับผู้ใช้

1. **แพลตฟอร์ม**: ทำ Android/iOS ก่อน (มี native Google Sign-In รองรับเต็มรูปแบบ) — Windows desktop ไม่มี native SDK อย่างเป็นทางการ ต้องใช้ browser+redirect ซึ่งซับซ้อนกว่า จึง**เว้นไว้ทำทีหลัง**
2. **OAuth credential**: ต้องสร้าง Google Cloud project ของ Tripitaka91 เอง (ยังไม่มี) ห้ามใช้ client_secret ของโปรเจกต์ DharmaTimeStamp
3. **PHP endpoint ใหม่บน tripitaka91.com**: Claude Code ไม่มีสิทธิ์เข้าถึง server โดยตรง → จะ**เขียนไฟล์ PHP เก็บไว้ให้ผู้ใช้เอาไปอัปโหลดเอง**

## ขั้นตอนที่ต้องทำ (ลำดับ)

### ขั้นที่ 1 — ผู้ใช้ทำเอง (ยังไม่เสร็จ)
ตั้งค่าใน [Google Cloud Console](https://console.cloud.google.com):
1. สร้างโปรเจกต์ใหม่ชื่อ "Tripitaka91" (แยกจาก DharmaTimeStamp)
2. ตั้งค่า **OAuth consent screen** (External, ใส่ email ผู้ทดสอบถ้ายังไม่ publish)
3. สร้าง OAuth client ID 3 ตัวที่ **Credentials**:
   - **Android** — package name `com.tripitaka91.tripitaka91` + SHA-1 fingerprint (ดูได้จาก `./gradlew signingReport` ในโฟลเดอร์ `android/`)
   - **iOS** — Bundle ID ของแอป
   - **Web application** — ไม่ได้ใช้ตรงในแอป แต่ต้องมีไว้ใช้เป็น `serverClientId` เพื่อให้ ID token มี `aud` ที่ backend PHP เช็คได้แน่นอน
4. ส่ง **Web client ID** ให้ Claude เพื่อใส่ในโค้ด

### ขั้นที่ 2 — Claude ทำต่อ (ยังไม่เริ่ม รอขั้นที่ 1)
1. เพิ่ม `google_sign_in` package ใน `pubspec.yaml`
2. แก้ [lib/widget/login/login_dialog.dart](lib/widget/login/login_dialog.dart) เพิ่มปุ่ม "เข้าสู่ระบบด้วย Google" ข้างฟอร์มเดิม → เรียก native sign-in → ส่ง ID token ไปยัง endpoint ใหม่ → parse ผลลัพธ์แบบเดียวกับ `RemoteServiceUserCheck.getUser()` เดิม
3. เขียนไฟล์ `google_login.php` (pattern จาก `auth.php`/`google_login.php` ของโปรเจกต์อ้างอิง) ให้ผู้ใช้เอาไปวางบน server เอง — ต้องคืน JSON ให้ตรงกับ shape ของ [lib/utils/models/users.dart](lib/utils/models/users.dart) (`Users.fromJson`)
4. แจ้งว่าต้องเพิ่ม column อะไรใน DB บ้าง (เช่น `google_sub`) ให้ผู้ใช้ไปทำเองฝั่ง database

## ไฟล์ที่เกี่ยวข้องในโปรเจกต์นี้ (อ้างอิงไว้)

- `lib/utils/constants/api_constants.dart` — รายการ URL endpoint ปัจจุบัน (`tURLuserChk` ใช้ email+password login อยู่แล้ว)
- `lib/utils/api_connect/remote_service.dart` — `RemoteServiceUserCheck.getUser(email, password, token)`
- `lib/utils/models/users.dart` — โครงสร้างข้อมูล user ที่ต้องคืนให้ตรง
- `lib/widget/login/login_dialog.dart` — dialog เข้าสู่ระบบที่เปิดทุกครั้ง (จุดที่จะเพิ่มปุ่ม Google)
- `lib/widget/login/login.dart`, `lib/widget/login/signup_screen.dart` — หน้าเข้าสู่ระบบ/สมัครสมาชิกแบบเต็มจอ (ของเดิม ไม่ใช่ dialog)
