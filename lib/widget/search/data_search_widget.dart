import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/showlog_search.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/search/data_search.dart';
import 'package:tripitaka91/widget/search/search_page.dart';

class DataSearch extends SearchDelegate<String> {
  final bool isM; // เพิ่มพารามิเตอร์ isM ใน constructor
  DataSearch({required this.isM});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // ตรวจสอบว่า query มีค่าหรือไม่
    if (query.isNotEmpty) {
      // ทำการค้นหาข้อมูลจาก API และแสดงผลลัพธ์ในหน้าใหม่ (TabBar)
      // โดยใช้ Navigator.push เพื่อเปิดหน้าใหม่
      Future.delayed(Duration.zero, () {
        close(context, '');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPages(
              title: query,
              isM: isM,
            ),
          ),
        );
      });
    }
    // ถ้า query ว่างเปล่า ให้ไม่ทำอะไร
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // สร้างข้อเสนอจาก query
    if (query.isEmpty) {
      // ถ้า query ว่างเปล่า ดึงประวัติการค้นหาจาก PHP API
      // และแสดงผลลัพธ์ที่ได้ใน ListView.builder
      return FutureBuilder(
        future:
            fetchSearchHistoryFromAPI(), // เรียกฟังก์ชันดึงประวัติการค้นหาจาก API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            final suggestionList = wordsearch
                .where((element) =>
                    element.toLowerCase().startsWith(query.toLowerCase()))
                .toList();
            return ListView.builder(
              itemCount: suggestionList.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  query = suggestionList[index];
                  showResults(context);
                },
                leading: const Icon(Icons.access_time),
                title: isM
                    ? ATextTitleMedium18(text: suggestionList[index])
                    : ATextTitleMedium(text: suggestionList[index]),
              ),
            );
          } else {
            List<LogSearch>? searchHistory = snapshot.data;
            // return Text('num ${searchHistory?[0].keyword}');
            return ListView.builder(
              itemCount: searchHistory?.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  query = searchHistory[index].keyword;
                  showResults(context);
                },
                leading: const Icon(Icons.access_time),
                title: ATextTitleMedium(text: searchHistory![index].keyword),
              ),
            );
          }
        },
      );
    } else {
      final suggestionList = wordsearch
          .where((element) =>
              element.toLowerCase().startsWith(query.toLowerCase()))
          .toList();

      return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
            onTap: () {
              if (index < suggestionList.length) {
                query = suggestionList[index];
                Future.delayed(Duration.zero, () {
                  close(context, '');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchPages(
                        title: query,
                        isM: isM,
                      ),
                    ),
                  );
                });
              }
            },
            leading: const Icon(Icons.access_time),
            title: ATextTitleMedium(text: suggestionList[index])),
      );
    }
  }

  Future<List<LogSearch>> fetchSearchHistoryFromAPI() async {
    List<LogSearch> dummyDataList = [];
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLLogSearch),
      body: {
        "token": tSecretAPIKey,
        "action": "read",
        "username": tmpUser,
        "json_data": "{}",
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
      bool successValue = decodedJson['success'];
      var data = decodedJson['data'];
      // print(data);

      if (successValue) {
        for (var item in data) {
          try {
            String username = item['username'];
            String keyword = item['keyword'];
            int count = item['count'];
            DateTime timestamp = DateTime.parse(item['timestamp']);

            LogSearch logSearch = LogSearch(
              username: username,
              keyword: keyword,
              count: count,
              timestamp: timestamp,
            );
            dummyDataList.add(logSearch);
          } catch (e) {
            // ignore: avoid_print
            print('Error processing data: $e');
          }
        }
        // print(dummyDataList.length);
        return dummyDataList;
      } else {
        return dummyDataList;
      }
      //   dummyDataList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      //   return dummyDataList;
      // } else {
      //   return dummyDataList;
      // }
    } else {
      throw Exception('เกิดข้อผิดพลาดในการเชื่อมต่อกับ API');
      //return dummyDataList;
    }
  }
}
