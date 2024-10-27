import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert'; // เพิ่มการนำเข้าเพื่อใช้ jsonEncode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tripitaka91/utils/models/last_book_access.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/showlog_search.dart';
import 'package:tripitaka91/utils/models/totalsearchtitle.dart';
import 'package:tripitaka91/utils/models/totalsearchtri.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // ดึง dbPath จาก SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final dbPath = prefs.getString('dbPath') ?? '';

    if (dbPath.isEmpty) {
      throw Exception("Database path is not set in SharedPreferences.");
    }

    return await openDatabase(
      dbPath,
      version: 1,
      // onCreate: (db, version) {
      //   return db.execute(
      //     'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT)',
      //   );
      // },
    );
  }

  Future<List<String>> fetchTitles(
      String wordsearch, int startFrom, int recordsPerPage) async {
    final db = await database;

    // Query with LIKE filter, ORDER, and LIMIT
    final List<Map<String, dynamic>> result = await db.query(
      'tripitaka91_91title',
      where: 'tripitaka91_title LIKE ?',
      whereArgs: ['%$wordsearch%'],
      orderBy: 'tripitaka91_book',
      limit: recordsPerPage,
      offset: startFrom,
    );

    List<String> response = [];
    for (var rowTitle in result) {
      String cleanedString =
          '${rowTitle['tripitaka91_title']}|${rowTitle['tripitaka91_book']}|${rowTitle['tripitaka91_page']}|'
          '${rowTitle['tripitaka91_line']}|${rowTitle['tripitaka91_book_red']}|${rowTitle['tripitaka91_code']}|'
          '${rowTitle['tripitaka91_no']}|${rowTitle['tripitaka91_mark']}|${rowTitle['tripitaka91_group']}|'
          '${rowTitle['tripitaka91_category']}|${rowTitle['tripitaka91_detail']}';
      response.add(cleanedString);
    }

    return response;
  }

  Future<TotalTitleSearchTri> getBooks91_1SearchCount(String wordsearch,
      {int bookid = 1, int bookidend = 10}) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
        '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
        [wordsearch.replaceAll('%', ' ')]);

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set1 อยู่ใน jsonData หรือไม่
      if (jsonData.containsKey("set1") && jsonData["set1"] is Map) {
        Map<String, dynamic> set1Data = jsonData["set1"];

        // Print ข้อมูลทั้งหมดใน set1Data
        // print("ข้อมูลทั้งหมดใน set1Data: $set1Data");

        int total = 0;
        bool chkReturn = false;
        // แสดงค่าทั้งหมดที่อยู่ใน set1Data ทีละคู่
        set1Data.forEach((key, value) {
          if (key == 'set1') {
            // ตรวจสอบว่า value เป็น Map หรือไม่
            if (value is Map) {
              // แยกค่า key 'รวม' ถ้ามี
              if (value.containsKey("รวม")) {
                chkReturn = true;
                total = value["รวม"] as int;
              }
            }
          }
        });

        if (chkReturn) {
          return TotalTitleSearchTri(
            totalRecords: total,
            detailRecords: '-',
          );
        }
      }
    }

    String txtquery = """
    SELECT book_id, COUNT(*) as total_records, GROUP_CONCAT(book_detail, ', ') as detail_records
    FROM tripitaka91_91book_line 
    WHERE book_id BETWEEN ? AND ? AND book_detail LIKE ? 
    GROUP BY book_id
  """;

    List<Map<String, dynamic>> list = await dbClient.rawQuery(
      txtquery,
      [bookid, bookidend, '%$wordsearch%'],
    );

    // สร้าง jsonData สำหรับเก็บผลลัพธ์
    Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

    // รวมค่าของ total_records และ detail_records จากทุกเรคอร์ด
    int totalRecordsSum = 0;
    String combinedDetails = '';

    for (var record in list) {
      int totalRecords = (record["total_records"] as int?) ?? 0;
      if (combinedDetails.isNotEmpty) combinedDetails += ', ';
      combinedDetails += (record["detail_records"] as String?) ?? '';

      // เพิ่มข้อมูลลงใน jsonData ถ้าค่า totalRecords ไม่เป็น 0
      if (totalRecords > 0) {
        jsonData["set1"]["เล่ม ${record["book_id"]}"] = totalRecords;
        totalRecordsSum += totalRecords;
      }
    }

    jsonData["set1"]["รวม"] = totalRecordsSum;

    // สร้าง TotalTitleSearchTri ด้วยค่ารวมทั้งหมด
    TotalTitleSearchTri result = TotalTitleSearchTri(
      totalRecords: totalRecordsSum,
      detailRecords: combinedDetails,
    );
    // print('set1${jsonData["set1"]["รวม"]}');
    // บันทึกข้อมูลลงในฐานข้อมูล
    await saveHisSearchSet1_3(wordsearch.replaceAll('%', ' '), jsonData, '1');

    return result;
  }

  Future<TotalTitleSearchTri> getBooks91_2SearchCount(String wordsearch,
      {int bookid = 11, int bookidend = 74}) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
        '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
        [wordsearch.replaceAll('%', ' ')]);

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set1 อยู่ใน jsonData หรือไม่
      if (jsonData.containsKey("set2") && jsonData["set2"] is Map) {
        Map<String, dynamic> set1Data = jsonData["set2"];

        // Print ข้อมูลทั้งหมดใน set1Data
        // print("ข้อมูลทั้งหมดใน set1Data: $set1Data");

        int total = 0;
        bool chkReturn = false;
        // แสดงค่าทั้งหมดที่อยู่ใน set1Data ทีละคู่
        set1Data.forEach((key, value) {
          if (key == 'set2') {
            // ตรวจสอบว่า value เป็น Map หรือไม่
            if (value is Map) {
              // แยกค่า key 'รวม' ถ้ามี
              if (value.containsKey("รวม")) {
                chkReturn = true;
                total = value["รวม"] as int;
              }
            }
          }
        });

        if (chkReturn) {
          return TotalTitleSearchTri(
            totalRecords: total,
            detailRecords: '-',
          );
        }
      }
    }

    String txtquery = """
    SELECT book_id, COUNT(*) as total_records, GROUP_CONCAT(book_detail, ', ') as detail_records
    FROM tripitaka91_91book_line 
    WHERE book_id BETWEEN ? AND ? AND book_detail LIKE ? 
    GROUP BY book_id
  """;

    List<Map<String, dynamic>> list = await dbClient.rawQuery(
      txtquery,
      [bookid, bookidend, '%$wordsearch%'],
    );

    // สร้าง jsonData สำหรับเก็บผลลัพธ์
    Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

    // รวมค่าของ total_records และ detail_records จากทุกเรคอร์ด
    int totalRecordsSum = 0;
    String combinedDetails = '';

    for (var record in list) {
      int totalRecords = (record["total_records"] as int?) ?? 0;
      if (combinedDetails.isNotEmpty) combinedDetails += ', ';
      combinedDetails += (record["detail_records"] as String?) ?? '';

      // เพิ่มข้อมูลลงใน jsonData ถ้าค่า totalRecords ไม่เป็น 0
      if (totalRecords > 0) {
        jsonData["set2"]["เล่ม ${record["book_id"]}"] = totalRecords;
        totalRecordsSum += totalRecords;
      }
    }

    jsonData["set2"]["รวม"] = totalRecordsSum;

    // สร้าง TotalTitleSearchTri ด้วยค่ารวมทั้งหมด
    TotalTitleSearchTri result = TotalTitleSearchTri(
      totalRecords: totalRecordsSum,
      detailRecords: combinedDetails,
    );

    // บันทึกข้อมูลลงในฐานข้อมูล
    await saveHisSearchSet1_3(wordsearch.replaceAll('%', ' '), jsonData, '2');

    return result;
  }

  Future<TotalTitleSearchTri> getBooks91_3SearchCount(String wordsearch,
      {int bookid = 75, int bookidend = 91}) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
        '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
        [wordsearch.replaceAll('%', ' ')]);

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set1 อยู่ใน jsonData หรือไม่
      if (jsonData.containsKey("set3") && jsonData["set3"] is Map) {
        Map<String, dynamic> set1Data = jsonData["set3"];

        // Print ข้อมูลทั้งหมดใน set1Data
        // print("ข้อมูลทั้งหมดใน set1Data: $set1Data");

        int total = 0;
        bool chkReturn = false;
        // แสดงค่าทั้งหมดที่อยู่ใน set1Data ทีละคู่
        set1Data.forEach((key, value) {
          if (key == 'set3') {
            // ตรวจสอบว่า value เป็น Map หรือไม่
            if (value is Map) {
              // แยกค่า key 'รวม' ถ้ามี
              if (value.containsKey("รวม")) {
                chkReturn = true;
                total = value["รวม"] as int;
              }
            }
          }
        });

        if (chkReturn) {
          return TotalTitleSearchTri(
            totalRecords: total,
            detailRecords: '-',
          );
        }
      }
    }

    String txtquery = """
    SELECT book_id, COUNT(*) as total_records, GROUP_CONCAT(book_detail, ', ') as detail_records
    FROM tripitaka91_91book_line 
    WHERE book_id BETWEEN ? AND ? AND book_detail LIKE ? 
    GROUP BY book_id
  """;

    List<Map<String, dynamic>> list = await dbClient.rawQuery(
      txtquery,
      [bookid, bookidend, '%$wordsearch%'],
    );

    // สร้าง jsonData สำหรับเก็บผลลัพธ์
    Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

    // รวมค่าของ total_records และ detail_records จากทุกเรคอร์ด
    int totalRecordsSum = 0;
    String combinedDetails = '';

    for (var record in list) {
      int totalRecords = (record["total_records"] as int?) ?? 0;
      if (combinedDetails.isNotEmpty) combinedDetails += ', ';
      combinedDetails += (record["detail_records"] as String?) ?? '';

      // เพิ่มข้อมูลลงใน jsonData ถ้าค่า totalRecords ไม่เป็น 0
      if (totalRecords > 0) {
        jsonData["set3"]["เล่ม ${record["book_id"]}"] = totalRecords;
        totalRecordsSum += totalRecords;
      }
    }

    jsonData["set3"]["รวม"] = totalRecordsSum;

    // สร้าง TotalTitleSearchTri ด้วยค่ารวมทั้งหมด
    TotalTitleSearchTri result = TotalTitleSearchTri(
      totalRecords: totalRecordsSum,
      detailRecords: combinedDetails,
    );

    // บันทึกข้อมูลลงในฐานข้อมูล
    // await saveHisSearchSet1_3(wordsearch.replaceAll('%', ' '), jsonData, '3');

    return result;
  }

  Future<TotalTitleSearch> getTri91TitleSearchDB(String query) async {
    var dbClient = await database;
    String txtquery =
        "SELECT * FROM tripitaka91_91title WHERE tripitaka91_title LIKE '%$query%'";
    List<Map<String, dynamic>> list = await dbClient.rawQuery(txtquery);

    // สร้างอินสแตนซ์ของ TotalTitleSearch โดยระบุจำนวน totalRecords จากขนาดของ list
    return TotalTitleSearch(totalRecords: list.length);
  }

  Future<TotalTitleSearch> getTriDictSearchDB(String query) async {
    var dbClient = await database;
    String txtquery =
        "SELECT * FROM tripitaka91_dict WHERE buddic_opt = '1' AND buddic_word LIKE '%$query%'";
    List<Map<String, dynamic>> list = await dbClient.rawQuery(txtquery);

    // สร้างอินสแตนซ์ของ TotalTitleSearch โดยระบุจำนวน totalRecords จากขนาดของ list
    return TotalTitleSearch(totalRecords: list.length);
  }

  Future<TotalTitleSearch> getTriDictBtSearchDB(String query) async {
    return TotalTitleSearch(totalRecords: 0);
  }

  Future<void> saveHisSearch(
      String query, Map<String, dynamic> jsonData) async {
    final dbClient = await database; // ใช้ database ผ่าน DatabaseHelper

    // ตรวจสอบว่าคีย์เวิร์ดนี้มีในฐานข้อมูลแล้วหรือไม่
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
        '''SELECT keywords, tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
        [query]);

    int result = x.length;

    // สร้างวันที่ปัจจุบันในรูปแบบที่ต้องการ
    final df = DateFormat('MM-dd HH:mm:ss');
    String thYear = (DateTime.now().year + 543).toString();
    String dateTime = '$thYear-${df.format(DateTime.now())}';

    // แปลง jsonData เป็น JSON string
    String jsonString = jsonEncode(jsonData);

    if (result == 0) {
      // ถ้ายังไม่มีคีย์เวิร์ดนี้ในฐานข้อมูล ให้เพิ่มเข้าไป
      await dbClient.rawUpdate(
          '''INSERT INTO tripitaka91_stat_search (keywords, last_search, tmp_1) 
         VALUES (?, ?, ?)''', [query, dateTime, jsonString]);
    } else {
      // String tmp1Data = x[0]['tmp_1'] ?? 'ไม่มีข้อมูลใน tmp_1';
      // print('ฐานข้อมูล tmp_1: $tmp1Data');

      // ถ้ามีแล้ว ให้ปรับปรุงวันที่และข้อมูล JSON ของคีย์เวิร์ดนี้
      await dbClient.rawUpdate('''UPDATE tripitaka91_stat_search 
         SET last_search = ? 
         WHERE keywords = ? ''', [dateTime, query]);
    }
  }

  Future<void> saveHisSearchSet1_3(
      String query, Map<String, dynamic> newSetData, String setNo) async {
    final dbClient = await database;

    // ตรวจสอบว่าคีย์เวิร์ดนี้มีในฐานข้อมูลแล้วหรือไม่
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
        '''SELECT keywords, tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
        [query]);

    int result = x.length;

    // สร้างวันที่ปัจจุบันในรูปแบบที่ต้องการ
    final df = DateFormat('MM-dd HH:mm:ss');
    String thYear = (DateTime.now().year + 543).toString();
    String dateTime = '$thYear-${df.format(DateTime.now())}';

    // สร้างโครงสร้างเริ่มต้นของ jsonData
    Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

    if (result > 0) {
      // ดึงข้อมูล tmp_1 ที่มีอยู่แล้ว และแปลงเป็น Map
      String existingJsonString = x[0]["tmp_1"];
      // print(existingJsonString);
      jsonData = jsonDecode(existingJsonString);

      // ตรวจสอบว่า jsonData["set$setNo"] เป็น Map หรือไม่
      if (jsonData["set$setNo"] is! Map) {
        jsonData["set$setNo"] = {}; // ถ้าไม่ใช่ Map ให้ตั้งค่าใหม่เป็น Map
      }

      // อัปเดตข้อมูลใน set ที่ต้องการ
      jsonData["set$setNo"] = newSetData;
    } else {
      // ถ้าไม่มีข้อมูลในฐานข้อมูล ให้สร้าง jsonData ใหม่เฉพาะ set
      jsonData["set$setNo"] = newSetData;
    }

    // แปลง jsonData เป็น JSON string
    String jsonString = jsonEncode(jsonData);

    if (result == 0) {
      // ถ้ายังไม่มีคีย์เวิร์ดนี้ในฐานข้อมูล ให้เพิ่มเข้าไป
      await dbClient.rawUpdate(
        '''INSERT INTO tripitaka91_stat_search (keywords, last_search, tmp_1) 
         VALUES (?, ?, ?)''',
        [query, dateTime, jsonString],
      );
    } else {
      // ถ้ามีแล้ว ให้ปรับปรุงวันที่และข้อมูล JSON ของคีย์เวิร์ดนี้
      await dbClient.rawUpdate(
        '''UPDATE tripitaka91_stat_search 
         SET last_search = ?, tmp_1 = ? 
         WHERE keywords = ?''',
        [dateTime, jsonString, query],
      );
    }
  }

  Future<List<LogSearch>> fetchSearchHistoryFromDB() async {
    final dbClient = await database; // เรียกใช้ database ผ่าน DatabaseHelper

    // ใช้ string interpolation สำหรับการสร้าง query
    var res =
        await dbClient.rawQuery('''SELECT keywords as keyword, last_search 
       FROM tripitaka91_stat_search 
       ORDER BY last_search DESC ''');

    // แปลงผลลัพธ์เป็นรายการของ LogSearch
    List<LogSearch> listHisSearch = res.isNotEmpty
        ? res.map((c) {
            // กำหนดค่า timestamp และตรวจสอบว่ามีค่าสำหรับการแปลงเป็น DateTime หรือไม่
            String? timestampStr = c['last_search'] as String?;
            DateTime timestamp = timestampStr != null
                ? DateTime.parse(timestampStr)
                : DateTime.now(); // กำหนดค่า default ในกรณีที่ null

            return LogSearch(
              username: 'guest',
              keyword: c['keyword'] as String,
              count: 0,
              timestamp: timestamp,
            );
          }).toList()
        : [];

    return listHisSearch;
  }

  Future<void> saveBookOpenLast(int bookid, int bookpage) async {
    final dbClient = await database; // เรียกใช้ database ผ่าน DatabaseHelper
    final df = DateFormat('MM-dd HH:mm:ss');
    String thYear = (DateTime.now().year + 543).toString();
    String dateTime = '$thYear-${df.format(DateTime.now())}';

    String sql = '''
    UPDATE tripitaka91_91title_1 
    SET book_last_access = '$dateTime', 
        book_last_pages = $bookpage, 
        book_last_line = 1 
    WHERE book_ids = $bookid
  ''';

    await dbClient.rawUpdate(sql);
  }

  Future<List<RandTitle>?> getRandTitleDB() async {
    final db = await database;
    final result = await db.query(
      'tripitaka91_91title',
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (result.isNotEmpty) {
      // แปลงข้อมูลใน result ให้เป็น List<RandTitle>
      return result.map((json) => RandTitle.fromJson(json)).toList();
    }
    return null;
  }

  Future<List<LastBookAccess>> getLastReadDB() async {
    final db = await database;
    final result = await db.query(
      'tripitaka91_91title_1',
      where:
          'book_ids IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10) OR (book_ids BETWEEN 11 AND 91)',
      orderBy: 'book_last_access DESC',
    );

    return result.map((record) {
      return LastBookAccess(
        username: "guest", // ใช้ค่า default เป็น "guest"
        timeLastAccess:
            DateTime.tryParse(record["book_last_access"]?.toString() ?? "") ??
                DateTime.now(),
        bookLastAccess:
            int.tryParse(record["book_ids"]?.toString() ?? '1') ?? 1,
        pageLastAccess:
            int.tryParse(record["book_last_page"]?.toString() ?? '1') ?? 1,
      );
    }).toList();
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items');
  }
}
