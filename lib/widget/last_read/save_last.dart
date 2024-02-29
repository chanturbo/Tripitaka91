import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';

Future<bool> saveBookAccessList(int booklast, int pagelast) async {
  Users? users = await getUsersList();
  if (users == null) {
    return false;
  } else {
    var data = {
      'token': tSecretAPIKey,
      "action": "save",
      'username': users.username,
      'book_last_access': booklast.toString(),
      'page_last_access': pagelast.toString(),
    };

    final response = await http.post(
      Uri.parse(tURLLogReads),
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      bool successValue = decodedJson['success'];
      if (successValue) {
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('เกิดข้อผิดพลาดในการเชื่อมต่อกับ API');
      //return dummyDataList;
    }
  }
}
