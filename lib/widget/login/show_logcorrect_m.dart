import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/auto_text/text_span.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class LogEditScreen extends StatefulWidget {
  const LogEditScreen({super.key});

  @override
  State<LogEditScreen> createState() => _LogEditScreenState();
}

class _LogEditScreenState extends State<LogEditScreen> {
  List<dynamic> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  final ScrollController _scrollControllerTitle = ScrollController();
  int? _selectedBook; // ประกาศตัวแปรเพื่อเก็บเลขเล่มที่ถูกเลือก

  @override
  void initState() {
    super.initState();
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataLogedit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleAddData() {
    // ทำการ setState() เพื่ออัปเดตข้อมูลใหม่
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      loadingTitle = false;
      pageTitle = 1;
      _fetchDataLogedit();
    });
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !_scrollControllerTitle.position.outOfRange) {
      _fetchDataLogedit();
    }
  }

  Future<void> _fetchDataLogedit() async {
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      Users? users = await getUsersList();
      String tmpUser = 'guest';
      if (users != null) {
        tmpUser = users.username;
      }
      String selectdBook = '0';
      if (_selectedBook != null) {
        selectdBook = _selectedBook.toString();
      }
      final response = await http.post(
        Uri.parse(tURLshowlogEditWithUser),
        body: {
          'token': tSecretAPIKey,
          'username': tmpUser,
          'book': selectdBook,
          'page': pageTitle.toString(),
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['message'];
          setState(() {
            loadedRecordsTitle += newData.length;
            dataTitle.addAll(newData);
            loadingTitle = false;
            pageTitle++;
          });
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
          setState(() {
            loadingTitle = false;
          });
        }
      } else {
        // ถ้าเกิด HTTP Error จะ throw Exception
        // ignore: avoid_print
        print('HTTP Error: ${response.statusCode}');
      }
    }
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const SizedBox(width: 10),
              // DropdownButton สำหรับเลือกเล่มหนังสือ
              Expanded(
                child: DropdownButton<int?>(
                  value: _selectedBook,
                  hint: const Text('เลือกเล่มหนังสือ'),
                  items: [
                    // เพิ่มตัวเลือก "เล่มทั้งหมด"
                    const DropdownMenuItem<int?>(
                      value: 0, // ค่าของ "เล่มทั้งหมด" จะเป็น null
                      child: Text('เล่มทั้งหมด'),
                    ),
                    ...List.generate(91, (index) {
                      int bookNumber = index + 1; // เลขเล่มที่ 1 ถึง 91
                      return DropdownMenuItem<int?>(
                        value: bookNumber,
                        child: Text('เล่มที่ $bookNumber'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBook = value; // อัพเดตค่าตัวแปรเมื่อเลือก
                      // print('_selectdBook $value');
                    });
                    _handleAddData(); // ฟังก์ชันที่จัดการกับการเลือก
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: NotificationListener(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _fetchDataLogedit();
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollControllerTitle,
              itemCount: loadedRecordsTitle + 1,
              itemBuilder: (context, index) {
                if (index == loadedRecordsTitle) {
                  // แสดง loading indicator ขณะที่กำลังโหลดข้อมูลเพิ่มเติม
                  return loadingTitle
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                } else {
                  // ดึงข้อมูลแต่ละ record มาแสดง
                  final record = dataTitle[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      child: ATextDiskplayMedium(text: '${index + 1}'),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'เล่ม: ${record['tripitaka91_book']} หน้า: ${record['tripitaka91_page']} บรรทัด: ${record['tripitaka91_line']}',
                                style: const TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'คำที่น่าจะผิด : ',
                                style: TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.grey),
                              ),
                              TextSpan(
                                text: '${record['tripitaka91_wordincorrect']}',
                                style: const TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'คำที่น่าจะถูก : ',
                                style: TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.grey),
                              ),
                              TextSpan(
                                text: '${record['tripitaka91_wordcorrect']}',
                                style: const TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'ข้อความเต็ม : ',
                                style: TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.grey),
                              ),
                              txtSpanHighlight(
                                  (record['tripitaka91_wordincorrect'])
                                      .split(','),
                                  '${record['book_detail_old']}')
                            ],
                          ),
                        ),
                        record['book_suscess'] == 1
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
                            : record['book_confirm'] > 0
                                ? ClipPath(
                                    clipper: DoubleTriangleRectangleClipper(),
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      color: Colors.yellow,
                                      child: const ATextLabelMediumColor(
                                          color: Colors.black,
                                          text:
                                              ' หมายเหตุ อยู่ในกระบวนการแก้ไขข้อมูล '),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                        const Divider(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
