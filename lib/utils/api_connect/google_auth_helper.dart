import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';

/// บาง wrapper เล็กๆ รอบ GoogleSignIn.instance (API ของ google_sign_in v7+)
/// เพื่อให้ login_dialog.dart/login.dart เรียกใช้ง่ายๆ แค่ "ขอ ID token" โดยไม่ต้องรู้
/// รายละเอียดเรื่อง initialize()/authenticate() ของ plugin
class GoogleAuthHelper {
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    // google_sign_in_web (ใช้บนเว็บ) ไม่รองรับ serverClientId เลย (assert เป็น null
    // เสมอ) และต้องใช้ clientId แทน — ส่วนแพลตฟอร์มอื่น (Android/iOS) ใช้ serverClientId
    // ตามเดิมเพื่อให้ aud ของ ID token ตรงกับฝั่ง backend
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? tGoogleWebClientId : null,
      serverClientId: kIsWeb ? null : tGoogleWebClientId,
    );
    _initialized = true;
  }

  /// ต้องเรียกก่อนแสดงปุ่ม Google จริงบนเว็บ (GoogleSignInWebButton) เพื่อให้ GIS SDK
  /// พร้อมใช้งานก่อนผู้ใช้กด
  static Future<void> ensureInitializedForWeb() => _ensureInitialized();

  /// สตรีมผลลัพธ์การ sign-in บนเว็บ — เพราะปุ่มจริงของ Google (renderButton) ไม่มี
  /// Future ให้ await ตรงๆ แบบ authenticate() ผลลัพธ์จะมาทางสตรีมนี้แทนหลังผู้ใช้
  /// เลือกบัญชีในป๊อปอัพของ Google แล้ว คืน null เมื่อ sign-out
  static Stream<String?> get webIdTokenStream {
    return GoogleSignIn.instance.authenticationEvents.map((event) {
      return switch (event) {
        GoogleSignInAuthenticationEventSignIn(:final user) =>
          user.authentication.idToken,
        GoogleSignInAuthenticationEventSignOut() => null,
      };
    });
  }

  /// เปิดหน้า sign-in ของ Google แล้วคืน ID token (JWT) สำหรับส่งต่อให้ backend
  /// ตรวจสอบ คืน null ถ้าผู้ใช้กดยกเลิกหรือเกิดข้อผิดพลาด (ใช้บน Android/iOS —
  /// บนเว็บ authenticate() ไม่รองรับ ต้องใช้ GoogleSignInWebButton + webIdTokenStream แทน)
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

/// ตัวช่วยสำหรับหน้า login (web) ที่ต้องแสดงปุ่ม Google จริง (GoogleSignInWebButton)
/// แล้วรอผลผ่าน [GoogleAuthHelper.webIdTokenStream] — รวม initState/dispose ที่เคย
/// ก็อปปี้ซ้ำกันใน login.dart และ login_dialog.dart ไว้ที่เดียว พร้อมป้องกัน race
/// condition ที่ widget อาจถูก dispose ไปแล้วก่อนที่ ensureInitializedForWeb() จะเสร็จ
/// (ซึ่งจะทำให้ subscription ถูกสร้างขึ้นหลัง dispose แล้วไม่มีใคร cancel ให้)
class GoogleWebAuthListener {
  GoogleWebAuthListener(this._onIdToken);

  final void Function(String idToken) _onIdToken;
  StreamSubscription<String?>? _sub;
  bool _disposed = false;

  /// เรียกใน initState() ของหน้า login — ไม่มีผลใดๆ นอกเว็บ
  void start() {
    if (!kIsWeb) return;
    GoogleAuthHelper.ensureInitializedForWeb().then((_) {
      if (_disposed) return;
      _sub = GoogleAuthHelper.webIdTokenStream.listen((idToken) {
        if (idToken != null) _onIdToken(idToken);
      });
    });
  }

  /// เรียกใน dispose() ของหน้า login
  void dispose() {
    _disposed = true;
    _sub?.cancel();
  }
}
