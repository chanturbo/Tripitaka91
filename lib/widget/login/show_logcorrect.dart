import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/auto_text/text_span.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class LogEditScreen extends StatefulWidget {
  final String username;
  const LogEditScreen({super.key, required this.username});

  @override
  State<LogEditScreen> createState() => _LogEditScreenState();
}

class _LogEditScreenState extends State<LogEditScreen> {
  late int _currentPage;
  int values = 0;
  int pageSplit = 50;

  @override
  void initState() {
    super.initState();
    _currentPage = 1; // กำหนดหน้าเริ่มต้น

    Future<int> valueCorrect = getValueCorrectFurture();
    valueCorrect.then((int value) {
      values = value;
    });
  }

  void _loadNextPage() {
    setState(() {
      double result = values / pageSplit;
      int itemCount = result.ceil();
      if (_currentPage < itemCount) {
        _currentPage++; // เพิ่มหน้า
      }
    });
  }

  void _loadBackPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

  Future<List<dynamic>> __logEditFuture() async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }

    final response = await http.post(
      Uri.parse(tURLshowlogEditWithUser),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'page': _currentPage.toString(),
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        // ดึงข้อมูล logedit ออกมาจาก jsonResponse
        // var unicodeJson = jsonEncode(jsonResponse['message']);
        // print(unicodeJson);
        List<dynamic> messages = jsonResponse['message'];

        // ใช้ loop เพื่อแสดงผลข้อมูล
        // for (var message in messages) {
        // print('ID: ${message['tripitaka91_book']}');
        // print('Content: ${message['tripitaka91_wordincorrect']}');
        // print('----------------');
        // }

        // return logeditFromJson(unicodeJson);
        return messages;
      } else {
        // ถ้าไม่สำเร็จ จะส่งข้อมูลว่างกลับไป
        return [];
      }
    } else {
      // ถ้าเกิด HTTP Error จะ throw Exception
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  void fetchDataAndShowDialog(String bookid, String pageid, String lineid,
      String comments, BuildContext context) async {
    try {
      final messages = await fetchData(bookid, pageid, lineid);
      if (messages.isEmpty) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ไม่พบข้อมูล'),
              content: const Text('ไม่พบข้อมูลที่คุณค้นหา'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );
      } else {
        // ใส่โค้ดที่ต้องการแสดงผลเมื่อมีข้อมูลที่ได้จาก fetchData ที่ไม่ว่าง
        // print('พบข้อมูล: ${messages[0]['book_detail']}');
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.5,
              child: SizedBox.expand(
                child: AlertDialog(
                  title: const Text(
                    'รายละเอียด',
                    style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.normal,
                        color: Colors.blue),
                  ),
                  content: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '${messages[0]['book_detail']}',
                            style: const TextStyle(
                                fontFamily: 'THSarabunNew',
                                fontSize: 26,
                                color: Colors.red),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'หมายเหตุ $comments',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('ตกลง'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('เกิดข้อผิดพลาด'),
            content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<List<dynamic>> fetchData(
      String bookid, String pageid, String lineid) async {
    final response = await http.post(
      Uri.parse(tURLbooktri91Line),
      body: {
        'token': tSecretAPIKey,
        'bookid': bookid,
        'pageid': pageid,
        'lineid': lineid,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));
      // print(jsonResponse);
      if (jsonResponse['success'] == true) {
        // print(jsonResponse['message'].toString());
        List<dynamic> messages = jsonResponse['message'];
        return messages;
      } else {
        // ถ้าไม่สำเร็จ คืนค่าว่าง
        return [];
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: __logEditFuture(),
      builder: (context, AsyncSnapshot<List<dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
            );
          } else {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('ไม่พบข้อมูล'),
              );
            } else {
              return ListView.builder(
                itemCount: values > pageSplit
                    ? snapshot.data!.length + 1
                    : snapshot.data!.length,
                // itemCount: snapshot.data!.length + 1,
                itemBuilder: (context, index) {
                  if (index < snapshot.data!.length) {
                    return Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              const ATextTitleMedium(text: 'คำที่น่าจะผิด: '),
                              Expanded(
                                  child: ATextTitleMediumColor(
                                      color: Colors.red,
                                      text:
                                          '${snapshot.data![index]['tripitaka91_wordincorrect']}')),
                              const ATextTitleMedium(text: 'คำที่น่าจะถูก: '),
                              Expanded(
                                  child: ATextTitleMediumColor(
                                      color: Colors.red,
                                      text:
                                          '${snapshot.data![index]['tripitaka91_wordcorrect']}')),
                            ],
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  ATextLabelLarge(
                                      text:
                                          'เล่ม: ${snapshot.data![index]['tripitaka91_book']} หน้า: ${snapshot.data![index]['tripitaka91_page']} บรรทัด: ${snapshot.data![index]['tripitaka91_line']}'
                                              .toString()),
                                  // ATextTitleSmallTHColor(
                                  //     color: Colors.grey,
                                  //     text:
                                  //         ' [ ${snapshot.data![index]['book_detail_old']} ]'),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    txtSpanHighlight(
                                        (snapshot.data![index]
                                                ['tripitaka91_wordincorrect'])
                                            .split(','),
                                        '${snapshot.data![index]['book_detail_old']}')
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              snapshot.data![index]['book_suscess'] == 1
                                  ? ClipPath(
                                      clipper: DoubleTriangleRectangleClipper(),
                                      child: Container(
                                        padding: const EdgeInsets.all(3.0),
                                        color: Colors.green,
                                        child: const ATextLabelMediumColor(
                                            color: Colors.white,
                                            text:
                                                ' หมายเหตุ ข้อมูลถูกแก้ไขเรียบร้อยแล้ว '),
                                      ),
                                    )
                                  : snapshot.data![index]['book_confirm'] > 0
                                      ? ClipPath(
                                          clipper:
                                              DoubleTriangleRectangleClipper(),
                                          child: Container(
                                            padding: const EdgeInsets.all(3.0),
                                            color: Colors.yellow,
                                            child: const ATextLabelMediumColor(
                                                color: Colors.black,
                                                text:
                                                    ' หมายเหตุ อยู่ในกระบวนการแก้ไขข้อมูล '),
                                          ),
                                        )
                                      : const Text(''),
                            ],
                          ),
                          // -> ${snapshot.data![index]['book_detail']}
                        ),
                        const Divider(),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        const Expanded(child: Text('')),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: _loadBackPage, // เรียกใช้เมธอดเมื่อกดปุ่ม
                          child:
                              const ATextDiskplayMedium(text: ' <-ก่อนหน้า '),
                        ),
                        const Text('  '),
                        popupMenu(values as double),
                        const Text('  '),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: _loadNextPage, // เรียกใช้เมธอดเมื่อกดปุ่ม
                          child:
                              const ATextDiskplayMedium(text: ' หน้าถัดไป-> '),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          }
        }
      },
    );
  }

  Widget popupMenu(double data) {
    double result = data / pageSplit;
    int itemCount = result.ceil();
    return PopupMenuButton<int>(
      itemBuilder: (context) {
        List<PopupMenuEntry<int>> list = [];
        for (int i = 1; i <= itemCount; i++) {
          list.add(
            PopupMenuItem<int>(
              value: i,
              child: Text('$i'),
            ),
          );
        }
        return list;
      },
      onSelected: (value) {
        // ทำอะไรก็ตามเมื่อเลือกเมนู
        setState(() {
          _currentPage = value; // เพิ่มหน้า
        });
      },
    );
  }
}
