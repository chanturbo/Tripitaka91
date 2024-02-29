import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'usersList';
    final value = prefs.getString(key);

    if (value != null) {
      // ถ้ามีข้อมูลใน SharedPreferences แสดงว่ามีการเข้าสู่ระบบ
      // เรียกไปที่หน้า Member
      // ignore: use_build_context_synchronously
      return true;
    } else {
      // ถ้าไม่มีข้อมูลใน SharedPreferences แสดงว่ายังไม่ได้เข้าสู่ระบบ
      // คุณสามารถทำอะไรก็ตามตามที่คุณต้องการที่นี่
      // ignore: use_build_context_synchronously
      return false;
    }
  }
}
