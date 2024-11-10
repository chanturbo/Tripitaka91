import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/book_tri91.dart';
import 'package:tripitaka91/utils/models/last_book_access.dart';
import 'package:tripitaka91/utils/models/log_edit.dart';
import 'dart:convert';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/sounds_getlink.dart';
import 'package:tripitaka91/utils/models/totalsearchtitle.dart';
import 'package:tripitaka91/utils/models/totalsearchtri.dart';
import 'package:tripitaka91/utils/models/tri91_bookall.dart';
import 'package:tripitaka91/utils/models/tri91_booksearch.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';

class RemoteServiceRandTitle {
  Future<List<RandTitle>?> getRandTitle() async {
    var client = http.Client();
    var uri = Uri.parse(tURLrandom);
    var response = await client.post(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(
          utf8.decode(json.runes.toList())); // เพิ่ม utf8.decode ที่นี่
      var unicodeJson = jsonEncode(decodedJson);
      return randTitleFromJson(unicodeJson);
    }
    return null;
  }
}

class RemoteServiceUserCheck {
  Future<Users?> getUser(String email, String password, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLuserChk);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'email': email,
      'password': password,
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      var unicodeJson = jsonEncode(decodedJson);
      return usersFromJson(unicodeJson);
    }

    return null;
  }
}

class RemoteServiceTriBook91 {
  Future<List<Tri91BookSearch>?> getTriBook91(
      String bookId, String bookEnd, String wordSearch, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLbooktri91SearchSub);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'bookid': bookId,
      'bookidend': bookEnd,
      'wordsearch': wordSearch.replaceAll(' ', '%'),
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      var unicodeJson = jsonEncode(decodedJson);
      return tri91BookSearchFromJson(unicodeJson);
    }

    return null;
  }
}

class RemoteServiceLogEdit {
  Future<List<Logedit>?> getLogEdit(String bookId, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLshowlogedit);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'bookid': bookId,
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      var unicodeJson = jsonEncode(decodedJson);
      return logeditFromJson(unicodeJson);
    }

    return null;
  }
}

class RemoteServiceTitle {
  Future<List<RandTitle>?> getTitle(String bookId, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLtitle);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'bookid': bookId,
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;

      try {
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

        if (jsonResponse['success'] == true) {
          var message = jsonResponse['message'];
          // เปลี่ยนเป็นการส่งค่า message เพื่อให้สามารถดึงข้อมูลตรงนี้ได้
          return randTitleFromJson(jsonEncode(message));
        } else {
          return null;
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error parsing JSON: $e');
        return null;
      }
    }
    return null;
  }
}

class RemoteServiceTri91SearchTotal {
  Future<TotalTitleSearchTri?> getBookTri91(
      String bookId, String bookEnd, String wordSearch, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLbooktri91Search);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'bookid': bookId,
      'bookidend': bookEnd,
      'wordsearch': wordSearch.replaceAll(' ', '%'),
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      // var unicodeJson = jsonEncode(decodedJson);

      // ตรวจสอบว่ามีข้อมูลหรือไม่
      var total = decodedJson['total_records'];
      var detail = decodedJson['detail_records'];
      if (decodedJson != null && decodedJson['total_records'] != null) {
        // return totalTitleSearchFromJson(unicodeJson);
        if (total == '-1') {
          return TotalTitleSearchTri(totalRecords: 0, detailRecords: '-');
        } else {
          return TotalTitleSearchTri(
              totalRecords: int.parse(total), detailRecords: detail);
        }
      } else {
        // ไม่พบข้อมูล
        return TotalTitleSearchTri(totalRecords: 0, detailRecords: '-');
      }
    }
    return null;
  }
}

class RemoteServiceTitleSearchTotal {
  Future<TotalTitleSearch?> getTitle(String wordSearch, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLtitleSearchTotal);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'wordsearch': wordSearch.replaceAll(' ', '%'),
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      // var unicodeJson = jsonEncode(decodedJson);

      // ตรวจสอบว่ามีข้อมูลหรือไม่
      var total = decodedJson['total_records'];
      if (decodedJson != null && decodedJson['total_records'] != null) {
        return TotalTitleSearch(totalRecords: int.parse(total));
        // return totalTitleSearchFromJson(unicodeJson);
      } else {
        // ไม่พบข้อมูล
        return TotalTitleSearch(totalRecords: 0);
      }
    }

    return null;
  }
}

class RemoteServiceDictSearchTotal {
  Future<TotalTitleSearch?> getTitle(String wordSearch, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLdictSearch);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'wordsearch': wordSearch.replaceAll(' ', '%'),
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      // var unicodeJson = jsonEncode(decodedJson);
      // print(unicodeJson);
      // ตรวจสอบว่ามีข้อมูลหรือไม่
      var total = decodedJson['total_records'];
      if (decodedJson != null && decodedJson['total_records'] != null) {
        return TotalTitleSearch(totalRecords: int.parse(total));
        // return totalTitleSearchFromJson(unicodeJson);
      } else {
        // ไม่พบข้อมูล
        return TotalTitleSearch(totalRecords: 0);
      }
    }

    return null;
  }
}

class RemoteServiceDictbtSearchTotal {
  Future<TotalTitleSearch?> getTitle(String wordSearch, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLdictbtSearch);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'wordsearch': wordSearch.replaceAll(' ', '%'),
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      // var unicodeJson = jsonEncode(decodedJson);

      // ตรวจสอบว่ามีข้อมูลหรือไม่
      var total = decodedJson['total_records'];
      if (decodedJson != null && decodedJson['total_records'] != null) {
        return TotalTitleSearch(totalRecords: int.parse(total));
        // return totalTitleSearchFromJson(unicodeJson);
      } else {
        // ไม่พบข้อมูล
        return TotalTitleSearch(totalRecords: 0);
      }
    }

    return null;
  }
}

class RemoteServiceSoundsGetLink {
  Future<List<SoundsGetLink>?> getLink(
      String title, String filename, String speechText, String token) async {
    var client = http.Client();
    Users? users = await getUsersList();

    var uri = users?.voiceChoice == 'เสียงผู้หญิง'
        ? Uri.parse(tURLSoundsGetLink)
        : Uri.parse(tURLSoundsGetLinkM);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'title': title,
      'file_name': filename,
      'text_to_read': speechText,
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      return [SoundsGetLink.fromJson(decodedJson)];
    }

    return null;
  }
}

class RemoteServiceTitleShow {
  Future<List<RandTitle>?> getTitle(String wordSearch, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLtitleShow);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'wordsearch': wordSearch.replaceAll(' ', '%'),
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      var unicodeJson = jsonEncode(decodedJson);
      return randTitleFromJson(unicodeJson);
    }

    return null;
  }
}

class RemoteServiceTitleSearch {
  Future<List<RandTitle>?> getTitle(String wordSearch, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLtitleSearch);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'wordsearch': wordSearch.replaceAll(' ', '%'),
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      var unicodeJson = jsonEncode(decodedJson);
      // print(unicodeJson);
      return randTitleFromJson(unicodeJson);
    }
    return null;
  }
}

class RemoteServiceBookTri91Html {
  Future<List<BookTri91>?> getBookTri91(
      String bookId, String pageId, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLbooktri91Html);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'bookid': bookId,
      'pageid': pageId,
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      var unicodeJson = jsonEncode(decodedJson);
      //print(unicodeJson);
      return bookTri91FromJson(unicodeJson);
    }

    return null;
  }
}

class RemoteServiceBookTri91 {
  Future<List<BookTri91>?> getBookTri91(
      String bookId, String pageId, String token) async {
    var client = http.Client();
    var uri = Uri.parse(tURLbooktri91);

    // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
    var data = {
      'bookid': bookId,
      'pageid': pageId,
      'token': token,
    };

    // สร้าง request แบบ POST พร้อมส่งข้อมูล
    var response = await client.post(
      uri,
      body: data,
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      var unicodeJson = jsonEncode(decodedJson);
      //print(unicodeJson);
      return bookTri91FromJson(unicodeJson);
    }

    return null;
  }
}

class RemoteServiceBookTri91All {
  Future<List<Tri91BookAll>?> getBookTri91All(
      String bookId, String token) async {
    try {
      var client = http.Client();
      var uri = Uri.parse(tURLbooktri91All);

      // สร้าง Map ที่มีข้อมูลที่ต้องการส่งไปด้วย
      var data = {
        'bookid': bookId,
        'token': token,
      };

      // สร้าง request แบบ POST พร้อมส่งข้อมูล
      var response = await client.post(
        uri,
        body: data,
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
        var unicodeJson = jsonEncode(decodedJson);
        return tri91BookAllFromJson(unicodeJson);
      } else {
        // จัดการข้อผิดพลาดที่เกิดขึ้นในกรณี response ไม่ได้รับสถานะ 200
        // ignore: avoid_print
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // จัดการข้อผิดพลาดที่เกิดขึ้นในกรณีอื่น ๆ
      // ignore: avoid_print
      print('Error: $e');
      return null;
    }
  }
}

class GetLastRead {
  static List<LastBookAccess> generateDummyData() {
    List<LastBookAccess> dummyDataList = [];
    DateTime now = DateTime.now();
    // DateTime yesterday = now.subtract(const Duration(days: 1));
    for (int bookId = 1; bookId <= 91; bookId++) {
      dummyDataList.add(
        LastBookAccess(
          username: 'guest',
          timeLastAccess: now,
          bookLastAccess: bookId,
          pageLastAccess: 1,
        ),
      );
    }
    return dummyDataList;
  }

  static List<LastBookAccess> generateDummyDataFromDB(DateTime datetime) {
    List<LastBookAccess> dummyDataList = [];
    for (int bookId = 1; bookId <= 91; bookId++) {
      dummyDataList.add(
        LastBookAccess(
          username: 'guest',
          timeLastAccess: datetime,
          bookLastAccess: bookId,
          pageLastAccess: 1,
        ),
      );
    }
    return dummyDataList;
  }

  Future<List<LastBookAccess>> fetchLastBookAccessList() async {
    List<LastBookAccess> dummyDataList = generateDummyData();
    Users? users = await getUsersList();
    if (users == null) {
      final response = await http.post(
        Uri.parse(tURLLogReads),
        body: {
          "token": tSecretAPIKey,
          "action": "read",
          "username": 'guest',
          "json_data": "{}",
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
        // var unicodeJson = jsonEncode(decodedJson);
        // print(unicodeJson);

        bool successValue = decodedJson['success'];
        var data = decodedJson['data'];
        // print(data);

        if (successValue) {
          List<LastBookAccess> lastBookAccessList = List<LastBookAccess>.from(
            data.map((item) => LastBookAccess(
                  username: item['username'],
                  timeLastAccess: DateTime.parse(item['time_last_access']),
                  bookLastAccess: item['book_last_access'],
                  pageLastAccess: item['page_last_access'],
                )),
          );

          if (lastBookAccessList.isNotEmpty) {
            dummyDataList =
                generateDummyDataFromDB(lastBookAccessList[0].timeLastAccess);

            // for (var lastBookAccess in lastBookAccessList) {
            //   print('Time Last Access: ${lastBookAccess.timeLastAccess}');
            // }
            // print(lastBookAccessList.length);
            //print('showcase');
            // List<LastBookAccessSuccess> lastBookAccessList =
            //     lastBookAccessSuccessFromJson(decodedJson);
            // if (lastBookAccessList.isNotEmpty) {
            for (var lastBookAccessSuccess in lastBookAccessList) {
              // print(lastBookAccessSuccess.bookLastAccess);
              for (var lastBookAccess1 in dummyDataList) {
                if (lastBookAccess1.bookLastAccess ==
                    lastBookAccessSuccess.bookLastAccess) {
                  lastBookAccess1.pageLastAccess =
                      lastBookAccessSuccess.pageLastAccess;
                  lastBookAccess1.timeLastAccess =
                      lastBookAccessSuccess.timeLastAccess;
                  break;
                }
              }
            }
            // for (var lastBookAccess in dummyDataList) {
            //   print('Time Last Access: ${lastBookAccess.timeLastAccess}');
            // }
            dummyDataList
                .sort((a, b) => b.timeLastAccess.compareTo(a.timeLastAccess));
            // // ตรวจสอบข้อมูลที่ได้
            // for (var lastBookAccess in dummyDataList) {
            //   print('Time Last Access: ${lastBookAccess.timeLastAccess}');
            // }
            return dummyDataList;
          } else {
            return dummyDataList;
          }
        } else {
          return dummyDataList;
        }
      } else {
        return dummyDataList;
        //throw Exception('เกิดข้อผิดพลาดในการเชื่อมต่อกับ API');
      }
    } else {
      final response = await http.post(
        Uri.parse(tURLLogReads),
        body: {
          "token": tSecretAPIKey,
          "action": "read",
          "username": users.username,
          "json_data": "{}",
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
        // var unicodeJson = jsonEncode(decodedJson);
        // print(unicodeJson);

        bool successValue = decodedJson['success'];
        var data = decodedJson['data'];
        // print(data);

        if (successValue) {
          List<LastBookAccess> lastBookAccessList = List<LastBookAccess>.from(
            data.map((item) => LastBookAccess(
                  username: item['username'],
                  timeLastAccess: DateTime.parse(item['time_last_access']),
                  bookLastAccess: item['book_last_access'],
                  pageLastAccess: item['page_last_access'],
                )),
          );

          if (lastBookAccessList.isNotEmpty) {
            dummyDataList =
                generateDummyDataFromDB(lastBookAccessList[0].timeLastAccess);

            // for (var lastBookAccess in lastBookAccessList) {
            //   print('Time Last Access: ${lastBookAccess.timeLastAccess}');
            // }
            // print(lastBookAccessList.length);
            //print('showcase');
            // List<LastBookAccessSuccess> lastBookAccessList =
            //     lastBookAccessSuccessFromJson(decodedJson);
            // if (lastBookAccessList.isNotEmpty) {
            for (var lastBookAccessSuccess in lastBookAccessList) {
              // print(lastBookAccessSuccess.bookLastAccess);
              for (var lastBookAccess1 in dummyDataList) {
                if (lastBookAccess1.bookLastAccess ==
                    lastBookAccessSuccess.bookLastAccess) {
                  lastBookAccess1.pageLastAccess =
                      lastBookAccessSuccess.pageLastAccess;
                  lastBookAccess1.timeLastAccess =
                      lastBookAccessSuccess.timeLastAccess;
                  break;
                }
              }
            }
            // for (var lastBookAccess in dummyDataList) {
            //   print('Time Last Access: ${lastBookAccess.timeLastAccess}');
            // }
            dummyDataList
                .sort((a, b) => b.timeLastAccess.compareTo(a.timeLastAccess));
            // // ตรวจสอบข้อมูลที่ได้
            // for (var lastBookAccess in dummyDataList) {
            //   print('Time Last Access: ${lastBookAccess.timeLastAccess}');
            // }
            return dummyDataList;
          } else {
            return dummyDataList;
          }
        } else {
          return dummyDataList;
        }
      } else {
        return dummyDataList;
        //throw Exception('เกิดข้อผิดพลาดในการเชื่อมต่อกับ API');
      }
    }
  }
}
