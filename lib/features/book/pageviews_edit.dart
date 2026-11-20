import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/book_tri91.dart';
import 'package:tripitaka91/utils/models/ip_address.dart';
import 'package:tripitaka91/utils/models/log_edit.dart';
import 'package:tripitaka91/utils/models/log_edit_save.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PageViewEdit extends StatefulWidget {
  final String bookId;
  final String pageId;
  final String username;
  final List<Logedit> logEdit;

  const PageViewEdit({
    super.key,
    required this.bookId,
    required this.pageId,
    required this.username,
    required this.logEdit,
  });

  @override
  State<PageViewEdit> createState() => _PageViewEditState();
}

class _PageViewEditState extends State<PageViewEdit> {
  late List<BookTri91> bookTri91 = [];
  List<List<TextEditingController>> controllersList = [];
  late List<IPAddress> ipAddress = [];
  String ip = '-';

  Future<String> getIPAddress(String token) async {
    final response = await http.post(
      Uri.parse(tURLgetIP),
      body: {'token': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ipAddress = IPAddress.fromJson(data);
      ip = ipAddress.ipAddress;
      return ipAddress.ipAddress;
    } else {
      // สามารถ throw exception หรือ return string ที่บอกว่ามีข้อผิดพลาดได้
      throw Exception('Failed to get IP address: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getIPAddress(tSecretAPIKey);
  }

  @override
  void dispose() {
    // อย่าลืม dispose controllers เมื่อไม่ได้ใช้งาน
    for (var controllers in controllersList) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งแก้ไขคำที่น่าจะผิดคำที่น่าจะถูก')),
      body: FutureBuilder<List<BookTri91>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical, // กำหนดเลื่อนแนวตั้ง
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // กำหนดเลื่อนแนวนอน
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        '[เนื้อหา เล่ม ${widget.bookId} หน้า ${widget.pageId}]',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        '[บรรทัด]',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        '[คำที่น่าจะผิด]',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        '[คำที่น่าจะถูก]',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        '[หมายเหตุ]',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: snapshot.data!.asMap().entries.map<DataRow>((entry) {
                    int index = entry.key;
                    BookTri91 book = entry.value;

                    // ตรวจสอบว่า controllersList มีข้อมูลหรือไม่
                    if (controllersList.length <= index) {
                      // ถ้าไม่มี, สร้าง controllers สำหรับแถวนี้
                      controllersList.add([
                        TextEditingController(),
                        TextEditingController(),
                        TextEditingController(),
                        TextEditingController(),
                        TextEditingController(),
                        TextEditingController(),
                        TextEditingController(),
                      ]);
                    }
                    int targetPage = int.parse(widget.pageId);
                    List<Logedit> result = widget.logEdit
                        .where((log) =>
                            log.tripitaka91Page == targetPage &&
                            log.tripitaka91User == widget.username)
                        .toList();
                    // print('result : ${result.length}');

                    List<Logedit> resultAll = widget.logEdit
                        .where((log) => log.tripitaka91Page == targetPage)
                        .toList();
                    for (Logedit logAll in resultAll) {
                      if (logAll.tripitaka91Line == book.bookLines) {
                        if (logAll.bookConfirm > 0) {
                          controllersList[index][4].text = 'C';
                        }
                        if (logAll.bookSuscess == 1) {
                          controllersList[index][5].text = 'C';
                        }
                      }
                    }
                    // print('resultAll : ${resultAll.length}');

                    for (Logedit log in result) {
                      if (log.tripitaka91Line == book.bookLines) {
                        controllersList[index][1].text =
                            log.tripitaka91Wordincorrect;
                        controllersList[index][2].text =
                            log.tripitaka91Wordcorrect;
                        controllersList[index][3].text =
                            log.tripitaka91Wordcorrectcomment;
                      }
                    }
                    controllersList[index][0].text = book.bookLines.toString();
                    controllersList[index][6].text = book.bookDetail;
                    return DataRow(
                      cells: [
                        DataCell(
                          book.bookDetail != 'LineNull'
                              ? SelectableText(
                                  book.bookDetail,
                                  style: const TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24.0,
                                  ),
                                )
                              : const Text(''),
                        ),
                        DataCell(
                          book.bookLines != 0
                              ? Text(
                                  book.bookLines.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24.0,
                                  ),
                                )
                              : const Text(''),
                        ),
                        controllersList[index][4].text != 'C'
                            ? DataCell(
                                book.bookLines != 0
                                    ? TextFormField(
                                        controller: controllersList[index][1],
                                        style: const TextStyle(
                                          fontFamily: 'THSarabunNew',
                                          fontSize: 24.0,
                                        ),
                                      )
                                    : const Text(''),
                              )
                            : controllersList[index][5].text != 'C'
                                ? const DataCell(
                                    Text(
                                      'อยู่ในกระบวนการแก้ไขข้อมูลแล้ว',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  )
                                : const DataCell(Text(
                                    'มีการแก้ไขข้อมูลแล้ว',
                                    style: TextStyle(color: Colors.green),
                                  )),
                        controllersList[index][4].text == 'C'
                            ? const DataCell(Text(''))
                            : DataCell(book.bookLines != 0
                                ? TextFormField(
                                    controller: controllersList[index][2],
                                    style: const TextStyle(
                                      fontFamily: 'THSarabunNew',
                                      fontSize: 24.0,
                                    ),
                                  )
                                : const Text('')),
                        controllersList[index][4].text == 'C'
                            ? const DataCell(Text(''))
                            : DataCell(
                                book.bookLines != 0
                                    ? TextFormField(
                                        controller: controllersList[index][3],
                                        style: const TextStyle(
                                          fontFamily: 'THSarabunNew',
                                          fontSize: 24.0,
                                        ),
                                      )
                                    : const Text(''),
                              ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          } else {
            // กรณีอื่น ๆ ที่ไม่ได้ถูกครอบด้วย if ข้างต้น
            return const SizedBox(); // หรือสามารถให้ว่างไว้ก็ได้
          }
        },
      ),
      bottomNavigationBar: buildBottomAppBar(),
    );
  }

  Future<List<BookTri91>> fetchBooks() async {
    try {
      // ในกรณีที่ API สำเร็จ
      bookTri91 = (await RemoteServiceBookTri91()
          .getBookTri91(widget.bookId, widget.pageId, tSecretAPIKey))!;
      return bookTri91;
    } catch (e) {
      // ในกรณีที่เกิดข้อผิดพลาดในการเรียก API
      throw 'Failed to load books: $e';
    }
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
      padding: const EdgeInsets.all(5),
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: TColors.primary,
          side: const BorderSide(color: TColors.primary),
        ),
        onPressed: () async {
          // ignore: unused_local_variable
          String comments = '-';
          List<LogeditSave> allLogeditData = [];
          DateTime now = DateTime.now();
          String formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
          DateTime dateTimeFromString = DateTime.parse(formattedDateTime);
          String formattedDate = DateFormat('yyyy-MM-dd').format(now);
          DateTime dateFromString = DateTime.parse(formattedDate);

          for (int i = 0; i < controllersList.length; i++) {
            if ((controllersList[i][1].text != '') &&
                (controllersList[i][2].text != '')) {
              if (controllersList[i][3].text != '') {
                comments = controllersList[i][3].text;
              }
              LogeditSave logeditData = LogeditSave(
                tripitaka91Book: int.parse(widget.bookId),
                tripitaka91Page: int.parse(widget.pageId),
                tripitaka91Line: int.parse(controllersList[i][0].text),
                tripitaka91Detail: controllersList[i][6].text,
                tripitaka91Wordincorrect: controllersList[i][1].text,
                tripitaka91Wordcorrect: controllersList[i][2].text,
                tripitaka91Wordcorrectcomment: comments,
                tripitaka91Wordsum: 1,
                tripitaka91User: widget.username,
                tripitaka91Dateadd: dateTimeFromString,
                tripitaka91Dateadd1: dateFromString,
                tripitaka91Dateedit: dateTimeFromString,
                tripitaka91Dateedit1: dateFromString,
                tripitaka91Ip: ip,
              );
              allLogeditData.add(logeditData);
            } else if ((controllersList[i][1].text == '') &&
                (controllersList[i][2].text != '')) {
              showCustomDialog(context,
                  'กรุณาป้อนคำที่น่าจะผิด บรรทัดที่ ${controllersList[i][0].text}');
              return;
            } else if ((controllersList[i][1].text != '') &&
                (controllersList[i][2].text == '')) {
              showCustomDialog(context,
                  'กรุณาป้อนคำที่น่าจะถูก บรรทัดที่ ${controllersList[i][0].text}');
              return;
            }

            //   print('Controllers List $i:');
            //   for (int j = 0; j < controllersList[i].length; j++) {
            //     print('  Controller $j: ${controllersList[i][j].text}');
            //   }
          }
          if (allLogeditData.isNotEmpty) {
            String jsonData = logeditSaveToJson(allLogeditData);
            bool saveLogEditSuscess =
                await saveLogEditUser(jsonData, tSecretAPIKey);
            if (saveLogEditSuscess) {
              //print('JSON Data: $saveLogEditSuscess');
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                ),
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(context, true);
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ไม่สามารถบันทึกข้อมูลได้'),
                ),
              );
            }
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'กรุณาป้อนคำที่น่าจะผิด คำที่น่าจะถูกก่อนบันทึกข้อมูล'),
              ),
            );
          }
        },
        child: const ATextDiskplayLarge(text: ' [บันทึกข้อมูล] '),
      ),
    );
  }

  Future<bool> saveLogEditUser(String jsonData, String token) async {
    try {
      var client = http.Client();
      var uri = Uri.parse(tURLlogEditSave);
      var data = {
        'json_data': jsonData,
        'token': token,
      };

      var response = await client.post(
        uri,
        body: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in logEditSave: $e');
    }

    return false;
  }

  void showCustomDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // สร้าง AlertDialog
        return AlertDialog(
          title: const Text('รายงาน'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                // ปิด Dialog
                Navigator.of(context).pop();
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }
}
