// ฟังก์ชันเก็บข้อมูล usersList ลงใน SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripitaka91/utils/models/users.dart';

void saveUsersList(Users users) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'usersList';
  final value = usersToJson(users);
  prefs.setString(key, value);
}

// ฟังก์ชันดึงข้อมูล usersList จาก SharedPreferences
Future<Users?> getUsersList() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'usersList';
  final value = prefs.getString(key);
  if (value != null) {
    return usersFromJson(value);
  } else {
    return null;
  }
}

void clearUsersList() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'usersList';
  prefs.remove(key); // ลบข้อมูลที่เก็บใน SharedPreferences ด้วย key
}
