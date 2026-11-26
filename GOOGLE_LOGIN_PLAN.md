# แผนงาน: เข้าสู่ระบบด้วย Google

สถานะ: **เขียนโค้ดฝั่งแอปเสร็จแล้ว (ขั้นที่ 2.1–2.3)** — เหลือรอผู้ใช้ทำ 3 อย่างก่อนทดสอบได้จริง: (1) สร้าง Android OAuth client (package+SHA-1) และ iOS OAuth client ใน Console ให้ครบ, (2) เพิ่มคอลัมน์ `google_sub` ในตาราง `users`, (3) แก้ `public_site/workspace/google_login.php` ให้ต่อฐานข้อมูลจริงแล้วอัปโหลดขึ้นเซิร์ฟเวอร์ — ดูรายละเอียดขั้นที่ 3

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

### ขั้นที่ 1 — ผู้ใช้ทำเอง
ตั้งค่าใน [Google Cloud Console](https://console.cloud.google.com):
1. สร้างโปรเจกต์ใหม่ชื่อ "Tripitaka91" (แยกจาก DharmaTimeStamp) — **เสร็จแล้ว**
2. ตั้งค่า **OAuth consent screen** (External, ใส่ email ผู้ทดสอบถ้ายังไม่ publish)
3. สร้าง OAuth client ID ที่ **Credentials**:
   - **Web application** — **เสร็จแล้ว** ได้ Client ID มาแล้ว:
     `678536711643-1p9avbk9b8t9tu3r8i4f8crkn8ap566k.apps.googleusercontent.com`
     (ใส่ไว้เป็น `tGoogleWebClientId` ใน [lib/utils/constants/api_constants.dart](lib/utils/constants/api_constants.dart) แล้ว — ใช้เป็น `serverClientId` ตอนเรียก `GoogleSignIn.instance.initialize()` และฝั่ง PHP ก็เช็ค `aud` กับค่านี้)
   - **Android** — **ยังไม่ทำ** ต้องสร้าง client ประเภท Android โดยใส่ package name `com.tripitaka91.tripitaka91` + SHA-1 fingerprint (ดูได้จาก `./gradlew signingReport` ในโฟลเดอร์ `android/`) แม้โค้ด Dart จะไม่ต้องอ้างอิง client ID ตัวนี้ตรงๆ (ใช้แค่ `serverClientId`) แต่ Android ต้องมี client ID ประเภท Android จับคู่กับ package+SHA-1 ไว้ใน project เดียวกัน ไม่งั้น native sign-in จะปฏิเสธ
   - **iOS** — **ยังไม่ทำ** ต้องสร้าง client ประเภท iOS ด้วย Bundle ID ของแอป แล้วส่ง Client ID + ค่า `REVERSED_CLIENT_ID` ให้ Claude เพื่อใส่ใน `ios/Runner/Info.plist` (`GIDClientID` + `CFBundleURLTypes`) — ถ้ายังไม่ทำขั้นนี้ ปุ่ม Google login บน iOS จะยัง sign-in ไม่ได้ (Android ใช้งานได้ก่อนโดยไม่ต้องรอ)

### ขั้นที่ 2 — Claude ทำแล้ว (เสร็จ)
1. ✅ เพิ่ม `google_sign_in: ^7.2.0` ใน `pubspec.yaml` (รัน `flutter pub get` ผ่านแล้ว, `flutter analyze` ไม่มี error)
2. ✅ เพิ่ม `tURLgoogleLogin` และ `tGoogleWebClientId` ใน [lib/utils/constants/api_constants.dart](lib/utils/constants/api_constants.dart)
3. ✅ สร้าง [lib/utils/api_connect/google_auth_helper.dart](lib/utils/api_connect/google_auth_helper.dart) — wrapper รอบ `GoogleSignIn.instance` (API ใหม่ของ v7: `initialize()` ครั้งเดียว แล้ว `authenticate()` คืน `GoogleSignInAccount`, อ่าน ID token จาก `account.authentication.idToken`)
4. ✅ แก้ [lib/widget/login/login_dialog.dart](lib/widget/login/login_dialog.dart) เพิ่มปุ่ม "เข้าสู่ระบบด้วย Google" ใต้ฟอร์มเดิม → เรียก `GoogleAuthHelper.signInAndGetIdToken()` → POST `id_token` ไปที่ `tURLgoogleLogin` → parse ด้วย `UsersLogin.fromJson` (รูปแบบเดียวกับที่ `_login()`/`loginUser()` เดิมใช้อยู่ คือ `{success, message, user: {...}}`) → `UserProvider.setUser()` เหมือน login ปกติ
5. ✅ เขียนไฟล์ต้นแบบ [public_site/workspace/google_login.php](public_site/workspace/google_login.php) (pattern จาก `auth.php`/`google_login.php` ของโปรเจกต์อ้างอิง DharmaTimeStamp) — **ยังอัปโหลดขึ้นเซิร์ฟเวอร์ไม่ได้ทันที** เพราะ Claude ไม่รู้วิธีต่อฐานข้อมูลจริงของ `user_chk.php` (host/user/pass/ชื่อ DB) และไม่รู้ชื่อคอลัมน์ที่แท้จริงในตาราง `users` — จุดที่ต้องแก้ไขทั้งหมดมีคอมเมนต์ `TODO` กำกับไว้ในไฟล์แล้ว

### ขั้นที่ 3 — ผู้ใช้ทำต่อ (ก่อนทดสอบ Google login ได้จริง)
1. เพิ่มคอลัมน์ `google_sub` (VARCHAR) ในตาราง `users` บนฐานข้อมูลจริง — ใช้เก็บ Google account ID (`sub`) เพื่อผูกบัญชี
2. เปิด [public_site/workspace/google_login.php](public_site/workspace/google_login.php) แก้ส่วนที่คอมเมนต์ `TODO`:
   - ค่าเชื่อมต่อฐานข้อมูล (`DB_HOST`/`DB_NAME`/`DB_USER`/`DB_PASS`) หรือเปลี่ยนไปใช้ `require_once` ไฟล์ config ที่มีอยู่แล้วบนเซิร์ฟเวอร์
   - ชื่อคอลัมน์ในคำสั่ง SQL ให้ตรงกับตาราง `users` จริง (ไฟล์เขียนไว้โดยอ้างชื่อฟิลด์ตาม `Users`/`UsersLogin` model ในแอป ซึ่งอาจไม่ตรงกับชื่อคอลัมน์ DB 100%)
   - ค่า `level_access` เริ่มต้นของสมาชิกใหม่ (ตอนนี้ตั้งเป็น `2` ตาม default ใน `User.fromJson`)
3. อัปโหลด `google_login.php` ไปที่ `https://www.tripitaka91.com/workspace/google_login.php`
4. ทำขั้นที่ 1 ส่วน Android/iOS ที่เหลือให้ครบ (Android client + iOS client และแก้ Info.plist)
5. ทดสอบ: กดปุ่ม "เข้าสู่ระบบด้วย Google" ในแอป (Android ก่อน เพราะไม่ต้องรอ iOS client)

## ไฟล์ที่เกี่ยวข้องในโปรเจกต์นี้ (อ้างอิงไว้)

- `lib/utils/constants/api_constants.dart` — รายการ URL endpoint ปัจจุบัน + `tURLgoogleLogin`/`tGoogleWebClientId` ที่เพิ่มใหม่
- `lib/utils/api_connect/remote_service.dart` — `RemoteServiceUserCheck.getUser(email, password, token)` (ของเดิม ไม่ได้แก้)
- `lib/utils/api_connect/google_auth_helper.dart` — **ไฟล์ใหม่** wrapper รอบ `google_sign_in` package
- `lib/utils/models/users.dart`, `lib/utils/models/users_login.dart` — โครงสร้างข้อมูล user/response ที่ต้องคืนให้ตรง (`google_login.php` คืนรูปแบบเดียวกับ `UsersLogin`)
- `lib/widget/login/login_dialog.dart` — dialog เข้าสู่ระบบที่เปิดทุกครั้ง — เพิ่มปุ่ม Google + `_loginWithGoogle()`/`loginWithGoogle()` แล้ว
- `lib/widget/login/login.dart`, `lib/widget/login/signup_screen.dart` — หน้าเข้าสู่ระบบ/สมัครสมาชิกแบบเต็มจอ (ของเดิม ไม่ใช่ dialog — **ยังไม่ได้เพิ่มปุ่ม Google ที่นี่** เพราะผู้ใช้ตกลงให้ทำที่ dialog ก่อน)
- `public_site/workspace/google_login.php` — **ไฟล์ใหม่** ต้นแบบ endpoint ฝั่งเซิร์ฟเวอร์ ยังต้องแก้ค่า DB ก่อนอัปโหลดจริง (ดูขั้นที่ 3)
