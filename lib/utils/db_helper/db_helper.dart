import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert'; // เพิ่มการนำเข้าเพื่อใช้ jsonEncode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tripitaka91/utils/models/book_tri91.dart';
import 'package:tripitaka91/utils/models/last_book_access.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/utils/models/showlog_search.dart';
import 'package:tripitaka91/utils/models/totalsearchtitle.dart';
import 'package:tripitaka91/utils/models/totalsearchtri.dart';
import 'package:tripitaka91/utils/models/tri91_bookall.dart';

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

  Future<void> replaceMultipleWordsInTitle(
    Map<String, String> replacements,
  ) async {
    final db = await database;

    for (var entry in replacements.entries) {
      await db.rawUpdate(
        '''
      UPDATE tripitaka91_91title
      SET tripitaka91_title = REPLACE(tripitaka91_title, ?, ?)
      WHERE tripitaka91_title LIKE ?
      ''',
        [entry.key, entry.value, '%${entry.key}%'], // แทนที่คำเก่าด้วยคำใหม่
      );
    }
  }

  Future<List<String>> fetchDictAll(
    String wordsearch,
    int startFrom,
    int recordsPerPage,
  ) async {
    final db = await database;

    // สร้าง query แบบ dynamic ตามเงื่อนไขของ wordsearch
    String? whereClause;
    List<String> whereArgs = [];

    if (wordsearch == '...') {
      // กรณีไม่มีการค้นหาเฉพาะเจาะจง (เหมือนใน PHP)
      whereClause = null;
    } else {
      // ใช้ WHERE clause พร้อม LIKE filter และเงื่อนไขเพิ่มเติม
      whereClause = 'buddic_word LIKE ?';
      whereArgs.add('%$wordsearch%');

      if (wordsearch == 'ฐ') {
        // กรณีตัวอักษรพิเศษ 'ฐ'
        whereClause += ' OR buddic_word LIKE ?';
        whereArgs.add('%');
      } else if (wordsearch == 'ญ') {
        // กรณีตัวอักษรพิเศษ 'ญ'
        whereClause += ' OR buddic_word LIKE ?';
        whereArgs.add('%');
      }

      // เพิ่มการค้นหาตามตัวนำหน้าอื่นๆ (เ แ โ ไ ใ)
      whereClause +=
          ' OR buddic_word LIKE ? OR buddic_word LIKE ? '
          'OR buddic_word LIKE ? OR buddic_word LIKE ? '
          'OR buddic_word LIKE ?';
      whereArgs.addAll([
        'เ$wordsearch%',
        'แ$wordsearch%',
        'โ$wordsearch%',
        'ไ$wordsearch%',
        'ใ$wordsearch%',
      ]);
    }

    // Query the database with WHERE, ORDER, and LIMIT conditions
    final List<Map<String, dynamic>> result = await db.query(
      'tripitaka91_dict',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'buddic_word',
      limit: recordsPerPage,
      offset: startFrom,
    );

    // Convert the result to a list of formatted strings
    List<String> response = result.map((row) {
      return '${row['buddic_word']}|${row['buddic_detail']}';
    }).toList();

    return response;
  }

  Future<List<BookTri91>?> getBookTri91(String bookId, String pageId) async {
    final db = await database;

    // Query the SQLite database
    final List<Map<String, dynamic>> result = await db.query(
      'tripitaka91_91book_line',
      where: 'book_id = ? AND book_pages = ?',
      whereArgs: [int.parse(bookId), int.parse(pageId)],
      orderBy: 'book_line',
    );

    // Check if the result is not empty and return parsed data
    if (result.isNotEmpty) {
      return result.map((json) => BookTri91.fromJson(json)).toList();
    } else {
      // print('ไม่พบข้อมูล');
      return null;
    }
  }

  // ฟังก์ชันในการดึงข้อมูลตาม keywords
  Future<List<String>> fetchDataDict(String result) async {
    final db = await database; // ดึงฐานข้อมูลที่ใช้งานอยู่
    List<String> results = [];

    // Split keywords by comma and trim each one
    List<String> keywords = result.split(',').map((e) => e.trim()).toList();

    // Use a SQL query to select data based on the keywords
    String keywordsPlaceholders = keywords.map((_) => '?').join(',');
    final query =
        '''
      SELECT buddic_word, buddic_detail 
      FROM tripitaka91_dict 
      WHERE buddic_word IN ($keywordsPlaceholders)
    ''';

    final rows = await db.rawQuery(query, keywords);

    if (rows.isNotEmpty) {
      results = rows.map((row) {
        return '${row['buddic_word']}|${row['buddic_detail']}';
      }).toList();
    } else {
      results.add('ไม่พบข้อมูล');
    }

    return results;
  }

  Future<void> deleteSearchHistory(String keyword) async {
    final db = await database; // ดึงฐานข้อมูลที่ใช้งานอยู่

    // สร้างคำสั่งลบข้อมูล
    await db.delete(
      'tripitaka91_stat_search', // ชื่อของตาราง
      where: 'keywords = ?', // เงื่อนไขที่ใช้ในการลบ
      whereArgs: [keyword], // ค่าที่ใช้ในเงื่อนไข
    );
  }

  Future<List<Tri91BookAll>?> getBookTri91All(String bookId) async {
    final db = await database;
    try {
      // Query ข้อมูลจากตาราง SQLite
      final List<Map<String, dynamic>> result = await db.query(
        'tripitaka91_91title_1',
        where: 'book_ids = ?',
        whereArgs: [bookId],
      );

      // หากมีข้อมูลในผลลัพธ์ ให้แปลงเป็น JSON แล้วไปใช้ tri91BookAllFromJson
      if (result.isNotEmpty) {
        return tri91BookAllFromJson(jsonEncode(result));
      } else {
        return null;
      }
    } catch (e) {
      // จัดการข้อผิดพลาดในกรณีเกิด Exception
      // ignore: avoid_print
      print('Error retrieving data from SQLite: $e');
      return null;
    }
  }

  Future<List<RandTitle>?> getTitle(String bookId) async {
    final db = await database;
    try {
      // คำสั่ง SQL สำหรับเลือกข้อมูลจากตาราง โดยใช้การกรอง
      final List<Map<String, dynamic>> result = await db.query(
        'tripitaka91_91title',
        where: 'tripitaka91_code = ?',
        whereArgs: [bookId],
        orderBy: 'tripitaka91_no',
      );

      // เช็คว่ามีข้อมูลหรือไม่
      if (result.isNotEmpty) {
        // แปลงข้อมูลที่ได้จาก SQLite เป็น JSON แล้วไปเรียกใช้ randTitleFromJson
        return randTitleFromJson(jsonEncode(result));
      } else {
        return null;
      }
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาดในระหว่างการดึงข้อมูล
      // ignore: avoid_print
      print('Error retrieving data from SQLite: $e');
      return null;
    }
  }

  String arabicToThaiNumbers(String input) {
    const Map<String, String> arabicToThai = {
      '0': '๐',
      '1': '๑',
      '2': '๒',
      '3': '๓',
      '4': '๔',
      '5': '๕',
      '6': '๖',
      '7': '๗',
      '8': '๘',
      '9': '๙',
    };

    return input.split('').map((char) => arabicToThai[char] ?? char).join();
  }

  Future<List<String>> fetchTri91(
    int bookid,
    String wordsearch,
    int startFrom,
    int recordsPerPage,
  ) async {
    final db = await database;

    String wordsearchThai = arabicToThaiNumbers(wordsearch);

    // Query ข้อมูลหลักจาก tripitaka91_91book_line
    final List<Map<String, dynamic>> result = await db.query(
      'tripitaka91_91book_line',
      where: 'book_id = ? AND (book_detail LIKE ? OR book_detail LIKE ?)',
      whereArgs: [
        bookid,
        '%$wordsearch%',
        '%$wordsearchThai%',
      ], // ค้นหาทั้งสองแบบ
      limit: recordsPerPage,
      offset: startFrom,
    );

    List<String> response = [];

    for (var row in result) {
      // คำนวณบรรทัดก่อนหน้าและบรรทัดถัดไป
      int lineBefore = row['book_lines'] - 1;
      int lineAfter = row['book_lines'] + 1;

      // Query ข้อมูลบรรทัดก่อนหน้า
      Map<String, dynamic>? rowBefore = (await db.query(
        'tripitaka91_91book_line',
        where: 'book_id = ? AND book_pages = ? AND book_lines = ?',
        whereArgs: [bookid, row['book_pages'], lineBefore],
        limit: 1,
      )).firstOrNull;

      // Query ข้อมูลบรรทัดถัดไป
      Map<String, dynamic>? rowAfter = (await db.query(
        'tripitaka91_91book_line',
        where: 'book_id = ? AND book_pages = ? AND book_lines = ?',
        whereArgs: [bookid, row['book_pages'], lineAfter],
        limit: 1,
      )).firstOrNull;

      // รวมบรรทัดก่อนหน้า ข้อมูลปัจจุบัน และบรรทัดถัดไป
      String strBefore = rowBefore?['book_detail'] ?? '';
      String strAfter = rowAfter?['book_detail'] ?? '';
      String cleanedString =
          '$strBefore${row['book_detail']}$strAfter|${row['book_id']}|${row['book_pages']}|${row['book_lines']}';

      response.add(
        cleanedString
            .replaceAll('LineNull', '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim(),
      );
    }

    return response;
  }

  Future<List<String>> fetchDict(
    String wordsearch,
    int startFrom,
    int recordsPerPage,
  ) async {
    final db = await database;

    // Query with LIKE filter, ORDER, and LIMIT for tripitaka91_dict
    final List<Map<String, dynamic>> result = await db.query(
      'tripitaka91_dict',
      where: 'buddic_word LIKE ?',
      whereArgs: ['%$wordsearch%'],
      orderBy: 'buddic_word',
      limit: recordsPerPage,
      offset: startFrom,
    );

    // Convert the result to a list of formatted strings
    List<String> response = [];
    for (var rowTitle in result) {
      String cleanedString =
          '${rowTitle['buddic_word']}|${rowTitle['buddic_detail']}';
      response.add(cleanedString);
    }

    return response;
  }

  Future<TotalTitleSearchTri> getBook91SearchSet3(String wordsearch) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
      '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [wordsearch.replaceAll('%', ' ')],
    );

    int total = 0;
    // สร้าง List สำหรับเก็บข้อมูลของแต่ละเล่ม
    Map<String, int> bookDetails = {};

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set1 อยู่ใน jsonData หรือไม่
      if (jsonData.containsKey("set3") && jsonData["set3"] is Map) {
        Map<String, dynamic> set1Data = jsonData["set3"];

        // วนลูปดึงข้อมูลเฉพาะเล่มและหมายเลขกำกับ ไม่รวม key 'รวม'
        set1Data.forEach((key, value) {
          if (key == 'set3') {
            value.forEach((subKey, subValue) {
              if (subKey != 'รวม') {
                bookDetails[subKey] = subValue;
              } else {
                total = subValue;
              }
            });
          }
        });
      }
    }
    String formattedString = bookDetails.entries
        .map((entry) => '${entry.key.replaceAll('เล่ม ', '')}#${entry.value}')
        .join('|');

    return TotalTitleSearchTri(
      totalRecords: total,
      detailRecords: formattedString,
    );
  }

  Future<TotalTitleSearchTri> getBook91SearchSet2(String wordsearch) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
      '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [wordsearch.replaceAll('%', ' ')],
    );

    int total = 0;
    // สร้าง List สำหรับเก็บข้อมูลของแต่ละเล่ม
    Map<String, int> bookDetails = {};

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set1 อยู่ใน jsonData หรือไม่
      if (jsonData.containsKey("set2") && jsonData["set2"] is Map) {
        Map<String, dynamic> set1Data = jsonData["set2"];

        // วนลูปดึงข้อมูลเฉพาะเล่มและหมายเลขกำกับ ไม่รวม key 'รวม'
        set1Data.forEach((key, value) {
          if (key == 'set2') {
            value.forEach((subKey, subValue) {
              if (subKey != 'รวม') {
                bookDetails[subKey] = subValue;
              } else {
                total = subValue;
              }
            });
          }
        });
      }
    }
    String formattedString = bookDetails.entries
        .map((entry) => '${entry.key.replaceAll('เล่ม ', '')}#${entry.value}')
        .join('|');

    return TotalTitleSearchTri(
      totalRecords: total,
      detailRecords: formattedString,
    );
  }

  Future<TotalTitleSearchTri> getBook91SearchSet1(String wordsearch) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
      '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [wordsearch.replaceAll('%', ' ')],
    );

    int total = 0;
    // สร้าง List สำหรับเก็บข้อมูลของแต่ละเล่ม
    Map<String, int> bookDetails = {};

    // print('set 1 x = ${x.length}');

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set1 อยู่ใน jsonData หรือไม่
      if (jsonData.containsKey("set1") && jsonData["set1"] is Map) {
        Map<String, dynamic> set1Data = jsonData["set1"];

        // วนลูปดึงข้อมูลเฉพาะเล่มและหมายเลขกำกับ ไม่รวม key 'รวม'
        set1Data.forEach((key, value) {
          if (key == 'set1') {
            value.forEach((subKey, subValue) {
              if (subKey != 'รวม') {
                bookDetails[subKey] = subValue;
              } else {
                total = subValue;
              }
            });
          }
        });
      }
    }
    String formattedString = bookDetails.entries
        .map((entry) => '${entry.key.replaceAll('เล่ม ', '')}#${entry.value}')
        .join('|');

    return TotalTitleSearchTri(
      totalRecords: total,
      detailRecords: formattedString,
    );
  }

  Future<List<String>> fetchTitlesInBook(
    String bookid,
    int startFrom,
    int recordsPerPage,
  ) async {
    final db = await database;

    // Query with LIKE filter, ORDER, and LIMIT
    final List<Map<String, dynamic>> result = await db.query(
      'tripitaka91_91title',
      where: 'tripitaka91_code = ?',
      whereArgs: [bookid],
      orderBy: 'tripitaka91_no',
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

  Future<List<String>> fetchTitlesDetail(
    String wordsearch,
    int startFrom,
    int recordsPerPage,
  ) async {
    final db = await database;

    // Query with LIKE filter, ORDER, and LIMIT
    final List<Map<String, dynamic>> result = await db.query(
      'tripitaka91_91title',
      where: 'tripitaka91_detail LIKE ?',
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

  Future<List<String>> fetchTitles(
    String wordsearch,
    int startFrom,
    int recordsPerPage,
  ) async {
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

  // ฟังก์ชัน getBooks91_1SearchCount - ปรับปรุงการตรวจสอบข้อมูล
  Future<TotalTitleSearchTri> getBooks91_1SearchCount(
    String wordsearch, {
    required int bookid,
    required int bookidend,
  }) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
      '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [wordsearch.replaceAll('%', ' ')],
    );

    bool needToSearch = true; // ตัวแปรกำหนดว่าต้องค้นหาใหม่หรือไม่

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set1 อยู่ใน jsonData หรือไม่ (โครงสร้างแบบซ้อน)
      if (jsonData.containsKey("set1") &&
          jsonData["set1"] is Map &&
          jsonData["set1"].containsKey("set1") &&
          jsonData["set1"]["set1"] is Map) {
        Map<String, dynamic> set1Data = jsonData["set1"]["set1"];

        // ตรวจสอบว่ามีข้อมูลครบทุกเล่มในช่วงที่ค้นหาหรือไม่
        bool hasAllDataInRange = true;
        List<int> missingBooks = [];

        for (int i = bookid; i <= bookidend; i++) {
          if (!set1Data.containsKey("$i")) {
            hasAllDataInRange = false;
            missingBooks.add(i);
          }
        }

        // ถ้ามีข้อมูลครบทุกเล่มในช่วงที่ต้องการแล้ว
        if (hasAllDataInRange) {
          // คำนวณผลรวมเฉพาะเล่มในช่วงที่ต้องการ
          int totalInRange = 0;
          List<String> detailParts = [];

          for (int i = bookid; i <= bookidend; i++) {
            if (set1Data.containsKey("$i") && set1Data["$i"] is int) {
              int count = set1Data["$i"] as int;
              totalInRange += count;
              // เพิ่มข้อมูลในรูปแบบ "เล่ม#จำนวน"
              detailParts.add("$i#$count");
            }
          }

          // รวมข้อมูลด้วย |
          String detailRecords = detailParts.join('|');

          print(
            'พบข้อมูลครบในฐานข้อมูลแล้ว (เล่ม $bookid-$bookidend): $totalInRange รายการ',
          );
          print('detailRecords: $detailRecords');
          needToSearch = false; // ไม่ต้องค้นหาใหม่

          return TotalTitleSearchTri(
            totalRecords: totalInRange,
            detailRecords: detailRecords,
          );
        } else if (!hasAllDataInRange) {
          print('ข้อมูลไม่ครบ ขาดเล่ม: $missingBooks - จะค้นหาใหม่');
          needToSearch = true; // ต้องค้นหาใหม่
        }
      }
    }

    // ถ้าต้องค้นหาใหม่ (ไม่มีข้อมูลหรือข้อมูลไม่ครบ)
    if (needToSearch) {
      print('กำลังค้นหาข้อมูล เล่ม $bookid-$bookidend...');

      // แปลงเลขอารบิกใน wordsearch เป็นเลขไทย
      String wordsearchThai = arabicToThaiNumbers(wordsearch);

      String txtquery = """
  SELECT book_id, COUNT(*) as total_records, 
         GROUP_CONCAT(book_detail, ', ') as detail_records
  FROM tripitaka91_91book_line 
  WHERE book_id BETWEEN ? AND ? 
        AND (book_detail LIKE ? OR book_detail LIKE ?) 
  GROUP BY book_id
""";

      List<Map<String, dynamic>> list = await dbClient.rawQuery(txtquery, [
        bookid,
        bookidend,
        '%$wordsearch%',
        '%$wordsearchThai%',
      ]);

      // สร้าง jsonData สำหรับเก็บผลลัพธ์ (รูปแบบเดิม)
      Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

      // รวมค่าของ total_records
      int totalRecordsSum = 0;
      List<String> detailParts = [];

      // เพิ่มข้อมูลทุกเล่มในช่วงที่ค้นหา (รวมทั้งเล่มที่ไม่มีข้อมูล = 0)
      for (int i = bookid; i <= bookidend; i++) {
        bool found = false;
        for (var record in list) {
          if (record["book_id"] == i) {
            found = true;
            int totalRecords = (record["total_records"] as int?) ?? 0;

            // เพิ่มข้อมูลลงใน jsonData
            jsonData["set1"]["$i"] = totalRecords;
            totalRecordsSum += totalRecords;

            // เพิ่มข้อมูลในรูปแบบ "เล่ม#จำนวน"
            detailParts.add("$i#$totalRecords");
            break;
          }
        }

        // ถ้าไม่พบข้อมูลในเล่มนี้ ให้เพิ่มค่า 0
        if (!found) {
          jsonData["set1"]["$i"] = 0;
          detailParts.add("$i#0");
        }
      }

      jsonData["set1"]["รวม"] = totalRecordsSum;

      // บันทึกลง SharedPreferences ก่อน
      saveDataSet(wordsearch.replaceAll('%', '-'), '1', jsonData);

      print('set1 batch ($bookid-$bookidend) = $jsonData');

      // บันทึกข้อมูลลงในฐานข้อมูล (จะรวมกับข้อมูลเดิม)
      await saveHisSearchSet1_3(wordsearch.replaceAll('%', ' '), jsonData, '1');

      // รวมข้อมูลด้วย |
      String detailRecordsFormatted = detailParts.join('|');

      // สร้าง TotalTitleSearchTri ด้วยค่ารวมทั้งหมด
      TotalTitleSearchTri result = TotalTitleSearchTri(
        totalRecords: totalRecordsSum,
        detailRecords: detailRecordsFormatted,
      );

      return result;
    }

    // กรณีที่ไม่ควรเกิดขึ้น (fallback)
    return TotalTitleSearchTri(totalRecords: 0, detailRecords: '');
  }

  // ฟังก์ชัน getBooks91_2SearchCount - ปรับปรุงการตรวจสอบข้อมูล
  Future<TotalTitleSearchTri> getBooks91_2SearchCount(
    String wordsearch, {
    required int bookid,
    required int bookidend,
  }) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
      '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [wordsearch.replaceAll('%', ' ')],
    );

    bool needToSearch = true; // ตัวแปรกำหนดว่าต้องค้นหาใหม่หรือไม่

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set2 อยู่ใน jsonData หรือไม่ (โครงสร้างแบบซ้อน)
      if (jsonData.containsKey("set2") &&
          jsonData["set2"] is Map &&
          jsonData["set2"].containsKey("set2") &&
          jsonData["set2"]["set2"] is Map) {
        Map<String, dynamic> set2Data = jsonData["set2"]["set2"];

        // ตรวจสอบว่ามีข้อมูลครบทุกเล่มในช่วงที่ค้นหาหรือไม่
        bool hasAllDataInRange = true;
        List<int> missingBooks = [];

        for (int i = bookid; i <= bookidend; i++) {
          if (!set2Data.containsKey("$i")) {
            hasAllDataInRange = false;
            missingBooks.add(i);
          }
        }

        // ถ้ามีข้อมูลครบทุกเล่มในช่วงที่ต้องการแล้ว
        if (hasAllDataInRange) {
          // คำนวณผลรวมเฉพาะเล่มในช่วงที่ต้องการ
          int totalInRange = 0;
          List<String> detailParts = [];

          for (int i = bookid; i <= bookidend; i++) {
            if (set2Data.containsKey("$i") && set2Data["$i"] is int) {
              int count = set2Data["$i"] as int;
              totalInRange += count;
              // เพิ่มข้อมูลในรูปแบบ "เล่ม#จำนวน"
              detailParts.add("$i#$count");
            }
          }

          // รวมข้อมูลด้วย |
          String detailRecords = detailParts.join('|');

          print(
            'พบข้อมูลครบในฐานข้อมูลแล้ว (เล่ม $bookid-$bookidend): $totalInRange รายการ',
          );
          print('detailRecords: $detailRecords');
          needToSearch = false; // ไม่ต้องค้นหาใหม่

          return TotalTitleSearchTri(
            totalRecords: totalInRange,
            detailRecords: detailRecords,
          );
        } else if (!hasAllDataInRange) {
          print('ข้อมูลไม่ครบ ขาดเล่ม: $missingBooks - จะค้นหาใหม่');
          needToSearch = true; // ต้องค้นหาใหม่
        }
      }
    }

    // ถ้าต้องค้นหาใหม่ (ไม่มีข้อมูลหรือข้อมูลไม่ครบ)
    if (needToSearch) {
      print('กำลังค้นหาข้อมูล เล่ม $bookid-$bookidend...');

      // แปลงเลขอารบิกใน wordsearch เป็นเลขไทย
      String wordsearchThai = arabicToThaiNumbers(wordsearch);

      String txtquery = """
  SELECT book_id, COUNT(*) as total_records, 
         GROUP_CONCAT(book_detail, ', ') as detail_records
  FROM tripitaka91_91book_line 
  WHERE book_id BETWEEN ? AND ? 
        AND (book_detail LIKE ? OR book_detail LIKE ?) 
  GROUP BY book_id
""";

      List<Map<String, dynamic>> list = await dbClient.rawQuery(txtquery, [
        bookid,
        bookidend,
        '%$wordsearch%',
        '%$wordsearchThai%',
      ]);

      // สร้าง jsonData สำหรับเก็บผลลัพธ์ (รูปแบบเดิม)
      Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

      // รวมค่าของ total_records
      int totalRecordsSum = 0;
      List<String> detailParts = [];

      // เพิ่มข้อมูลทุกเล่มในช่วงที่ค้นหา (รวมทั้งเล่มที่ไม่มีข้อมูล = 0)
      for (int i = bookid; i <= bookidend; i++) {
        bool found = false;
        for (var record in list) {
          if (record["book_id"] == i) {
            found = true;
            int totalRecords = (record["total_records"] as int?) ?? 0;

            // เพิ่มข้อมูลลงใน jsonData (เปลี่ยนเป็น set2)
            jsonData["set2"]["$i"] = totalRecords;
            totalRecordsSum += totalRecords;

            // เพิ่มข้อมูลในรูปแบบ "เล่ม#จำนวน"
            detailParts.add("$i#$totalRecords");
            break;
          }
        }

        // ถ้าไม่พบข้อมูลในเล่มนี้ ให้เพิ่มค่า 0
        if (!found) {
          jsonData["set2"]["$i"] = 0;
          detailParts.add("$i#0");
        }
      }

      jsonData["set2"]["รวม"] = totalRecordsSum;

      // บันทึกลง SharedPreferences ก่อน (เปลี่ยนเป็น set2)
      saveDataSet(wordsearch.replaceAll('%', '-'), '2', jsonData);

      print('set2 batch ($bookid-$bookidend) = $jsonData');

      // บันทึกข้อมูลลงในฐานข้อมูล (จะรวมกับข้อมูลเดิม) (เปลี่ยนเป็น set2)
      await saveHisSearchSet1_3(wordsearch.replaceAll('%', ' '), jsonData, '2');

      // รวมข้อมูลด้วย |
      String detailRecordsFormatted = detailParts.join('|');

      // สร้าง TotalTitleSearchTri ด้วยค่ารวมทั้งหมด
      TotalTitleSearchTri result = TotalTitleSearchTri(
        totalRecords: totalRecordsSum,
        detailRecords: detailRecordsFormatted,
      );

      return result;
    }

    // กรณีที่ไม่ควรเกิดขึ้น (fallback)
    return TotalTitleSearchTri(totalRecords: 0, detailRecords: '');
  }

  // ฟังก์ชัน getBooks91_3SearchCount - ปรับปรุงการตรวจสอบข้อมูล
  Future<TotalTitleSearchTri> getBooks91_3SearchCount(
    String wordsearch, {
    required int bookid,
    required int bookidend,
  }) async {
    final dbClient = await database;

    // Query เพื่อดึงข้อมูล JSON ในฟิลด์ tmp_1 ตาม keyword ที่ต้องการ
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
      '''SELECT tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [wordsearch.replaceAll('%', ' ')],
    );

    bool needToSearch = true; // ตัวแปรกำหนดว่าต้องค้นหาใหม่หรือไม่

    if (x.isNotEmpty) {
      // แปลงข้อมูล tmp_1 จาก String เป็น Map
      Map<String, dynamic> jsonData = jsonDecode(x[0]["tmp_1"]);

      // ตรวจสอบว่ามี set3 อยู่ใน jsonData หรือไม่ (โครงสร้างแบบซ้อน)
      if (jsonData.containsKey("set3") &&
          jsonData["set3"] is Map &&
          jsonData["set3"].containsKey("set3") &&
          jsonData["set3"]["set3"] is Map) {
        Map<String, dynamic> set3Data = jsonData["set3"]["set3"];

        // ตรวจสอบว่ามีข้อมูลครบทุกเล่มในช่วงที่ค้นหาหรือไม่
        bool hasAllDataInRange = true;
        List<int> missingBooks = [];

        for (int i = bookid; i <= bookidend; i++) {
          if (!set3Data.containsKey("$i")) {
            hasAllDataInRange = false;
            missingBooks.add(i);
          }
        }

        // ถ้ามีข้อมูลครบทุกเล่มในช่วงที่ต้องการแล้ว
        if (hasAllDataInRange) {
          // คำนวณผลรวมเฉพาะเล่มในช่วงที่ต้องการ
          int totalInRange = 0;
          List<String> detailParts = [];

          for (int i = bookid; i <= bookidend; i++) {
            if (set3Data.containsKey("$i") && set3Data["$i"] is int) {
              int count = set3Data["$i"] as int;
              totalInRange += count;
              // เพิ่มข้อมูลในรูปแบบ "เล่ม#จำนวน"
              detailParts.add("$i#$count");
            }
          }

          // รวมข้อมูลด้วย |
          String detailRecords = detailParts.join('|');

          print(
            'พบข้อมูลครบในฐานข้อมูลแล้ว (เล่ม $bookid-$bookidend): $totalInRange รายการ',
          );
          print('detailRecords: $detailRecords');
          needToSearch = false; // ไม่ต้องค้นหาใหม่

          return TotalTitleSearchTri(
            totalRecords: totalInRange,
            detailRecords: detailRecords,
          );
        } else if (!hasAllDataInRange) {
          print('ข้อมูลไม่ครบ ขาดเล่ม: $missingBooks - จะค้นหาใหม่');
          needToSearch = true; // ต้องค้นหาใหม่
        }
      }
    }

    // ถ้าต้องค้นหาใหม่ (ไม่มีข้อมูลหรือข้อมูลไม่ครบ)
    if (needToSearch) {
      print('กำลังค้นหาข้อมูล เล่ม $bookid-$bookidend...');

      // แปลงเลขอารบิกใน wordsearch เป็นเลขไทย
      String wordsearchThai = arabicToThaiNumbers(wordsearch);

      String txtquery = """
  SELECT book_id, COUNT(*) as total_records, 
         GROUP_CONCAT(book_detail, ', ') as detail_records
  FROM tripitaka91_91book_line 
  WHERE book_id BETWEEN ? AND ? 
        AND (book_detail LIKE ? OR book_detail LIKE ?) 
  GROUP BY book_id
""";

      List<Map<String, dynamic>> list = await dbClient.rawQuery(txtquery, [
        bookid,
        bookidend,
        '%$wordsearch%',
        '%$wordsearchThai%',
      ]);

      // สร้าง jsonData สำหรับเก็บผลลัพธ์ (รูปแบบเดิม)
      Map<String, dynamic> jsonData = {"set1": {}, "set2": {}, "set3": {}};

      // รวมค่าของ total_records
      int totalRecordsSum = 0;
      List<String> detailParts = [];

      // เพิ่มข้อมูลทุกเล่มในช่วงที่ค้นหา (รวมทั้งเล่มที่ไม่มีข้อมูล = 0)
      for (int i = bookid; i <= bookidend; i++) {
        bool found = false;
        for (var record in list) {
          if (record["book_id"] == i) {
            found = true;
            int totalRecords = (record["total_records"] as int?) ?? 0;

            // เพิ่มข้อมูลลงใน jsonData (เปลี่ยนเป็น set3)
            jsonData["set3"]["$i"] = totalRecords;
            totalRecordsSum += totalRecords;

            // เพิ่มข้อมูลในรูปแบบ "เล่ม#จำนวน"
            detailParts.add("$i#$totalRecords");
            break;
          }
        }

        // ถ้าไม่พบข้อมูลในเล่มนี้ ให้เพิ่มค่า 0
        if (!found) {
          jsonData["set3"]["$i"] = 0;
          detailParts.add("$i#0");
        }
      }

      jsonData["set3"]["รวม"] = totalRecordsSum;

      // บันทึกลง SharedPreferences ก่อน (เปลี่ยนเป็น set3)
      saveDataSet(wordsearch.replaceAll('%', '-'), '3', jsonData);

      print('set3 batch ($bookid-$bookidend) = $jsonData');

      // บันทึกข้อมูลลงในฐานข้อมูล (จะรวมกับข้อมูลเดิม) (เปลี่ยนเป็น set3)
      await saveHisSearchSet1_3(wordsearch.replaceAll('%', ' '), jsonData, '3');

      // รวมข้อมูลด้วย |
      String detailRecordsFormatted = detailParts.join('|');

      // สร้าง TotalTitleSearchTri ด้วยค่ารวมทั้งหมด
      TotalTitleSearchTri result = TotalTitleSearchTri(
        totalRecords: totalRecordsSum,
        detailRecords: detailRecordsFormatted,
      );

      return result;
    }

    // กรณีที่ไม่ควรเกิดขึ้น (fallback)
    return TotalTitleSearchTri(totalRecords: 0, detailRecords: '');
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
    String query,
    Map<String, dynamic> jsonData,
  ) async {
    final dbClient = await database; // ใช้ database ผ่าน DatabaseHelper

    // ตรวจสอบว่าคีย์เวิร์ดนี้มีในฐานข้อมูลหรือไม่
    final result = await dbClient.rawQuery(
      '''SELECT keywords, tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [query],
    );

    // สร้างวันที่ปัจจุบันในรูปแบบที่ต้องการ
    final dateTime =
        '${DateTime.now().year + 543}-${DateFormat('MM-dd HH:mm:ss').format(DateTime.now())}';
    final jsonString = jsonEncode(jsonData);

    if (result.isEmpty) {
      // เพิ่มข้อมูลใหม่ถ้าไม่มีคีย์เวิร์ดในฐานข้อมูล
      await dbClient.rawInsert(
        '''INSERT INTO tripitaka91_stat_search (keywords, last_search, tmp_1) VALUES (?, ?, ?)''',
        [query, dateTime, jsonString],
      );
    } else {
      // ตรวจสอบและอัปเดตข้อมูล tmp_1
      final tmp1String = result.first['tmp_1'] as String;
      bool isValidMap;

      try {
        isValidMap = jsonDecode(tmp1String) is Map<String, dynamic>;
      } catch (_) {
        isValidMap = false;
      }

      if (isValidMap) {
        await dbClient.rawUpdate(
          '''UPDATE tripitaka91_stat_search SET last_search = ? WHERE keywords = ?''',
          [dateTime, query],
        );
      } else {
        // ลบข้อมูลที่ไม่ถูกต้องแล้วเพิ่มใหม่
        await dbClient.rawDelete(
          '''DELETE FROM tripitaka91_stat_search WHERE keywords = ?''',
          [query],
        );
        await dbClient.rawInsert(
          '''INSERT INTO tripitaka91_stat_search (keywords, last_search, tmp_1) VALUES (?, ?, ?)''',
          [query, dateTime, jsonString],
        );
      }
    }
  }

  // ฟังก์ชัน saveHisSearchSet1_3 - ปรับให้รองรับการสะสมข้อมูล
  Future<void> saveHisSearchSet1_3(
    String query,
    Map<String, dynamic> newSetData,
    String setNo,
  ) async {
    final dbClient = await database;

    String strPrefs = query.replaceAll(' ', '-');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ตรวจสอบว่าคีย์เวิร์ดนี้มีในฐานข้อมูลแล้วหรือไม่
    List<Map<String, dynamic>> x = await dbClient.rawQuery(
      '''SELECT keywords, tmp_1 FROM tripitaka91_stat_search WHERE keywords = ?''',
      [query],
    );

    int result = x.length;

    // สร้างวันที่ปัจจุบันในรูปแบบที่ต้องการ
    final df = DateFormat('MM-dd HH:mm:ss');
    String thYear = (DateTime.now().year + 543).toString();
    String dateTime = '$thYear-${df.format(DateTime.now())}';

    // สร้างโครงสร้างเริ่มต้นของ jsonData (2 ชั้น)
    Map<String, dynamic> jsonData = {
      "set1": {"set1": {}, "set2": {}, "set3": {}},
      "set2": {"set1": {}, "set2": {}, "set3": {}},
      "set3": {"set1": {}, "set2": {}, "set3": {}},
    };

    if (result > 0) {
      // ดึงข้อมูล tmp_1 ที่มีอยู่แล้วจากฐานข้อมูล
      String existingJsonString = x[0]["tmp_1"];
      dynamic existingDataDynamic = jsonDecode(existingJsonString);

      // แปลงเป็น Map<String, dynamic> อย่างถูกต้อง
      Map<String, dynamic> existingData = Map<String, dynamic>.from(
        existingDataDynamic,
      );

      // รวมข้อมูลเดิมทั้งหมดเข้ามาก่อน (เก็บทุก set ไว้)
      jsonData = existingData;

      // ตรวจสอบและสร้างโครงสร้างถ้ายังไม่มี
      if (jsonData["set$setNo"] is! Map) {
        jsonData["set$setNo"] = {"set1": {}, "set2": {}, "set3": {}};
      } else {
        // แปลง Map ที่มีอยู่ให้เป็น Map<String, dynamic>
        jsonData["set$setNo"] = Map<String, dynamic>.from(
          jsonData["set$setNo"],
        );
      }

      // ตรวจสอบ set ย่อยทั้งหมด
      for (String subSet in ["set1", "set2", "set3"]) {
        if (jsonData["set$setNo"][subSet] is! Map) {
          jsonData["set$setNo"][subSet] = {};
        } else {
          jsonData["set$setNo"][subSet] = Map<String, dynamic>.from(
            jsonData["set$setNo"][subSet],
          );
        }
      }
    }

    // ดึงข้อมูลจาก SharedPreferences ของแต่ละ set
    String? set_1 = prefs.getString('${strPrefs}1');
    String? set_2 = prefs.getString('${strPrefs}2');
    String? set_3 = prefs.getString('${strPrefs}3');

    // อัพเดทข้อมูลจาก newSetData ที่ส่งเข้ามา
    if (newSetData.containsKey("set$setNo")) {
      Map<String, dynamic> currentData = Map<String, dynamic>.from(
        jsonData["set$setNo"]["set$setNo"],
      );
      Map<String, dynamic> newData = Map<String, dynamic>.from(
        newSetData["set$setNo"],
      );

      // เพิ่มข้อมูลใหม่เข้าไป (ยกเว้น key "รวม")
      newData.forEach((key, value) {
        if (key != "รวม") {
          currentData[key] = value;
        }
      });

      // คำนวณค่ารวมใหม่ทั้งหมด
      int finalTotal = 0;
      currentData.forEach((k, v) {
        if (k != "รวม" && v is int) {
          finalTotal += v;
        }
      });

      currentData["รวม"] = finalTotal;
      jsonData["set$setNo"]["set$setNo"] = currentData;
    }

    // รวมข้อมูลจาก SharedPreferences ของ set อื่นๆ (ถ้ามี)
    if (setNo == '1') {
      if (set_2 != null) {
        try {
          dynamic jsonSet2Dynamic = jsonDecode(set_2);
          Map<String, dynamic> jsonSet2 = Map<String, dynamic>.from(
            jsonSet2Dynamic,
          );

          if (jsonSet2.containsKey("set2") &&
              jsonSet2["set2"] is Map &&
              jsonSet2["set2"]["set2"] is Map) {
            Map<String, dynamic> existingSet2 = Map<String, dynamic>.from(
              jsonData["set2"]["set2"],
            );
            Map<String, dynamic> newSet2 = Map<String, dynamic>.from(
              jsonSet2["set2"]["set2"],
            );

            newSet2.forEach((key, value) {
              if (!existingSet2.containsKey(key)) {
                existingSet2[key] = value;
              }
            });

            jsonData["set2"]["set2"] = existingSet2;
          }
        } catch (e) {
          print('Error decoding set2: $e');
        }
      }
      if (set_3 != null) {
        try {
          dynamic jsonSet3Dynamic = jsonDecode(set_3);
          Map<String, dynamic> jsonSet3 = Map<String, dynamic>.from(
            jsonSet3Dynamic,
          );

          if (jsonSet3.containsKey("set3") &&
              jsonSet3["set3"] is Map &&
              jsonSet3["set3"]["set3"] is Map) {
            Map<String, dynamic> existingSet3 = Map<String, dynamic>.from(
              jsonData["set3"]["set3"],
            );
            Map<String, dynamic> newSet3 = Map<String, dynamic>.from(
              jsonSet3["set3"]["set3"],
            );

            newSet3.forEach((key, value) {
              if (!existingSet3.containsKey(key)) {
                existingSet3[key] = value;
              }
            });

            jsonData["set3"]["set3"] = existingSet3;
          }
        } catch (e) {
          print('Error decoding set3: $e');
        }
      }
    } else if (setNo == '2') {
      if (set_1 != null) {
        try {
          dynamic jsonSet1Dynamic = jsonDecode(set_1);
          Map<String, dynamic> jsonSet1 = Map<String, dynamic>.from(
            jsonSet1Dynamic,
          );

          if (jsonSet1.containsKey("set1") &&
              jsonSet1["set1"] is Map &&
              jsonSet1["set1"]["set1"] is Map) {
            Map<String, dynamic> existingSet1 = Map<String, dynamic>.from(
              jsonData["set1"]["set1"],
            );
            Map<String, dynamic> newSet1 = Map<String, dynamic>.from(
              jsonSet1["set1"]["set1"],
            );

            newSet1.forEach((key, value) {
              if (!existingSet1.containsKey(key)) {
                existingSet1[key] = value;
              }
            });

            jsonData["set1"]["set1"] = existingSet1;
          }
        } catch (e) {
          print('Error decoding set1: $e');
        }
      }
      if (set_3 != null) {
        try {
          dynamic jsonSet3Dynamic = jsonDecode(set_3);
          Map<String, dynamic> jsonSet3 = Map<String, dynamic>.from(
            jsonSet3Dynamic,
          );

          if (jsonSet3.containsKey("set3") &&
              jsonSet3["set3"] is Map &&
              jsonSet3["set3"]["set3"] is Map) {
            Map<String, dynamic> existingSet3 = Map<String, dynamic>.from(
              jsonData["set3"]["set3"],
            );
            Map<String, dynamic> newSet3 = Map<String, dynamic>.from(
              jsonSet3["set3"]["set3"],
            );

            newSet3.forEach((key, value) {
              if (!existingSet3.containsKey(key)) {
                existingSet3[key] = value;
              }
            });

            jsonData["set3"]["set3"] = existingSet3;
          }
        } catch (e) {
          print('Error decoding set3: $e');
        }
      }
    } else {
      if (set_1 != null) {
        try {
          dynamic jsonSet1Dynamic = jsonDecode(set_1);
          Map<String, dynamic> jsonSet1 = Map<String, dynamic>.from(
            jsonSet1Dynamic,
          );

          if (jsonSet1.containsKey("set1") &&
              jsonSet1["set1"] is Map &&
              jsonSet1["set1"]["set1"] is Map) {
            Map<String, dynamic> existingSet1 = Map<String, dynamic>.from(
              jsonData["set1"]["set1"],
            );
            Map<String, dynamic> newSet1 = Map<String, dynamic>.from(
              jsonSet1["set1"]["set1"],
            );

            newSet1.forEach((key, value) {
              if (!existingSet1.containsKey(key)) {
                existingSet1[key] = value;
              }
            });

            jsonData["set1"]["set1"] = existingSet1;
          }
        } catch (e) {
          print('Error decoding set1: $e');
        }
      }
      if (set_2 != null) {
        try {
          dynamic jsonSet2Dynamic = jsonDecode(set_2);
          Map<String, dynamic> jsonSet2 = Map<String, dynamic>.from(
            jsonSet2Dynamic,
          );

          if (jsonSet2.containsKey("set2") &&
              jsonSet2["set2"] is Map &&
              jsonSet2["set2"]["set2"] is Map) {
            Map<String, dynamic> existingSet2 = Map<String, dynamic>.from(
              jsonData["set2"]["set2"],
            );
            Map<String, dynamic> newSet2 = Map<String, dynamic>.from(
              jsonSet2["set2"]["set2"],
            );

            newSet2.forEach((key, value) {
              if (!existingSet2.containsKey(key)) {
                existingSet2[key] = value;
              }
            });

            jsonData["set2"]["set2"] = existingSet2;
          }
        } catch (e) {
          print('Error decoding set2: $e');
        }
      }
    }

    // แปลง jsonData เป็น JSON string
    String jsonString = jsonEncode(jsonData);
    print('jsonData = $jsonData');

    if (result == 0) {
      await dbClient.rawInsert(
        '''INSERT INTO tripitaka91_stat_search (keywords, last_search, tmp_1) 
     VALUES (?, ?, ?)''',
        [query, dateTime, jsonString],
      );
    } else {
      await dbClient.rawUpdate(
        '''UPDATE tripitaka91_stat_search 
     SET last_search = ?, tmp_1 = ? 
     WHERE keywords = ?''',
        [dateTime, jsonString, query],
      );
    }
  }

  // ฟังก์ชัน saveDataSet - ปรับให้รองรับโครงสร้างซ้อน 2 ชั้น
  void saveDataSet(
    String nameSet,
    String setNo,
    Map<String, dynamic> dataSet,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // สร้างโครงสร้างแบบซ้อน 2 ชั้น
    Map<String, dynamic> fullStructure = {
      "set1": {"set1": {}, "set2": {}, "set3": {}},
      "set2": {"set1": {}, "set2": {}, "set3": {}},
      "set3": {"set1": {}, "set2": {}, "set3": {}},
    };

    // วางข้อมูลที่ส่งเข้ามาในตำแหน่งที่ถูกต้อง
    if (dataSet.containsKey("set$setNo")) {
      fullStructure["set$setNo"]["set$setNo"] = dataSet["set$setNo"];
    }

    String jsonData = jsonEncode(fullStructure);
    await prefs.setString('$nameSet$setNo', jsonData);
  }

  Future<List<LogSearch>> fetchSearchHistoryFromDB() async {
    final dbClient = await database; // เรียกใช้ database ผ่าน DatabaseHelper

    // ใช้ string interpolation สำหรับการสร้าง query
    var res = await dbClient.rawQuery(
      '''SELECT keywords as keyword, last_search 
       FROM tripitaka91_stat_search 
       ORDER BY last_search DESC ''',
    );

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

    String sql =
        '''
    UPDATE tripitaka91_91title_1 
    SET book_last_access = '$dateTime', 
        book_last_pages = $bookpage, 
        book_last_line = 1 
    WHERE book_ids = $bookid
  ''';
    // print('SQL => $sql');
    await dbClient.rawUpdate(sql);
  }

  Future<List<RandTitle>?> getRandTitleDB() async {
    // เรียกใช้ฟังก์ชัน โดยกำหนดหลายคำที่ต้องการแทนที่
    Map<String, String> replacements = {"": "-", "": "\"", "": "\""};
    await replaceMultipleWordsInTitle(replacements);

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
            int.tryParse(record["book_last_pages"]?.toString() ?? '1') ?? 1,
      );
    }).toList();
  }

  Future<List<LastBookAccess>> getLastReadWithBook(String bookid) async {
    final db = await database;
    final result = await db.query(
      'tripitaka91_91title_1',
      where: 'book_ids = ?', // กำหนดเงื่อนไขให้เท่ากับ bookid
      whereArgs: [bookid], // ส่งค่า bookid เป็น whereArgs
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
            int.tryParse(record["book_last_pages"]?.toString() ?? '1') ?? 1,
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
