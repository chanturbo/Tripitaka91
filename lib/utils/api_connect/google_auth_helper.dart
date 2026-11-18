import 'package:google_sign_in/google_sign_in.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';

/// บาง wrapper เล็กๆ รอบ GoogleSignIn.instance (API ของ google_sign_in v7+)
/// เพื่อให้ login_dialog.dart เรียกใช้ง่ายๆ แค่ "ขอ ID token" โดยไม่ต้องรู้
/// รายละเอียดเรื่อง initialize()/authenticate() ของ plugin
class GoogleAuthHelper {
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: tGoogleWebClientId);
    _initialized = true;
  }

  /// เปิดหน้า sign-in ของ Google แล้วคืน ID token (JWT) สำหรับส่งต่อให้ backend
  /// ตรวจสอบ คืน null ถ้าผู้ใช้กดยกเลิกหรือเกิดข้อผิดพลาด
  static Future<String?> signInAndGetIdToken() async {
    try {
      await _ensureInitialized();
      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } catch (e) {
      // ignore: avoid_print
      print('Error in GoogleAuthHelper.signInAndGetIdToken: $e');
      return null;
    }
  }
}
