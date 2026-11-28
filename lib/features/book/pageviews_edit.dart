import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/book_tri91.dart';
import 'package:tripitaka91/utils/models/ip_address.dart';
import 'package:tripitaka91/utils/models/log_edit.dart';
import 'package:tripitaka91/utils/models/log_edit_save.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
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

  // ชิปสถานะทรงเดียวกับที่ใช้ในแท็บ "รายการแจ้งคำผิดคำถูก" หน้าสมาชิก
  // (lib/widget/login/show_logedit_save.dart) เพื่อให้ดูเป็นระบบเดียวกัน
  Widget _statusChip(bool isFixed) {
    final Color color = isFixed ? TColors.success : TColors.buttonPrimary;
    final String label = isFixed
        ? 'แก้ไขข้อมูลเรียบร้อยแล้ว'
        : 'อยู่ในกระบวนการแก้ไขข้อมูล';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งแก้ไขคำที่น่าจะผิดคำที่น่าจะถูก')),
      body: FutureBuilder<List<BookTri91>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            final List<BookTri91> data = snapshot.data!;
            // จอกว้าง (แท็บเล็ต/เดสก์ท็อป): ขยายความกว้างสูงสุดของเนื้อหา และ
            // เอาช่อง "คำที่น่าจะผิด/คำที่น่าจะถูก" มาวางแถวเดียวกับบล็อกเนื้อหา
            // แทนที่จะวางไว้ด้านล่างเหมือนจอมือถือ
            final bool isWideScreen = MediaQuery.of(context).size.width >= 900;
            return Container(
              color: adaptivePageColor(context),
              // จำกัดความกว้างเนื้อหาไว้ (700 บนจอแคบ, 1000 บนจอกว้าง) แล้ว
              // Center เหมือนหน้าอ่านหนังสือ (pageviews_html.dart) กันฟอร์มยืด
              // เต็มจอจนดูกว้างเกินไป
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWideScreen ? 1000 : 700,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: adaptiveSurfaceColor(context),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(14),
                          ),
                        ),
                        child: Text(
                          'เนื้อหา เล่ม ${widget.bookId} หน้า ${widget.pageId}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: adaptiveTextColor(context),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            BookTri91 book = data[index];

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
                                .where(
                                  (log) =>
                                      log.tripitaka91Page == targetPage &&
                                      log.tripitaka91User == widget.username,
                                )
                                .toList();

                            List<Logedit> resultAll = widget.logEdit
                                .where(
                                  (log) => log.tripitaka91Page == targetPage,
                                )
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
                            controllersList[index][0].text = book.bookLines
                                .toString();
                            controllersList[index][6].text = book.bookDetail;

                            // บรรทัดว่างเปล่า (ไม่มีเนื้อหา ไม่มีเลขบรรทัด) ไม่มีอะไร
                            // ให้แสดง/แก้ไข เลยไม่ต้องสร้างการ์ดให้ดูรก
                            if (book.bookDetail == 'LineNull' &&
                                book.bookLines == 0) {
                              return const SizedBox.shrink();
                            }

                            final bool isConfirmed =
                                controllersList[index][4].text == 'C';
                            final bool isFixed =
                                controllersList[index][5].text == 'C';

                            // สีป้ายเลขบรรทัดแบบเดียวกับ _buildIndexBadge ในแท็บ
                            // "รายการแจ้งคำผิดคำถูก" หน้าสมาชิก: เทา = ยังไม่มีคน
                            // แจ้ง/แก้ไขได้อยู่, น้ำเงิน = กำลังดำเนินการ, เขียว =
                            // แก้ไขเรียบร้อยแล้ว
                            final Color badgeColor = !isConfirmed
                                ? Colors.grey
                                : isFixed
                                ? TColors.success
                                : TColors.buttonPrimary;

                            final bool showFields =
                                book.bookLines != 0 && !isConfirmed;
                            // จอกว้างพอ และมีทั้งเนื้อหาและฟอร์มให้แก้ไข: เอาช่อง
                            // คำที่น่าจะผิด/ถูก มาเรียงแถวเดียวกับบล็อกเนื้อหาแทน
                            // การวางไว้ด้านล่างแบบจอแคบ
                            final bool inlineFieldsWithContent =
                                isWideScreen &&
                                showFields &&
                                book.bookDetail != 'LineNull';

                            final Widget wordIncorrectField = TextFormField(
                              controller: controllersList[index][1],
                              decoration: const InputDecoration(
                                labelText: 'คำที่น่าจะผิด',
                                labelStyle: TextStyle(
                                  fontFamily: 'THSarabunNew',
                                  fontSize: 18,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                fontFamily: 'THSarabunNew',
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            );
                            final Widget wordCorrectField = TextFormField(
                              controller: controllersList[index][2],
                              decoration: const InputDecoration(
                                labelText: 'คำที่น่าจะถูก',
                                labelStyle: TextStyle(
                                  fontFamily: 'THSarabunNew',
                                  fontSize: 18,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                fontFamily: 'THSarabunNew',
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: adaptiveSurfaceColor(context),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isConfirmed) ...[
                                    Row(
                                      children: [
                                        const Spacer(),
                                        _statusChip(isFixed),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  // ป้ายเลขบรรทัดอยู่แถวเดียวกับบล็อกคำพูดต้นฉบับ
                                  // (ไม่ใช่แถวแยกด้านบนเหมือนเดิม) ส่วนบล็อกคำพูด
                                  // แยกจากฟอร์มด้านล่างด้วยพื้นหลังโทนอ่อนกว่าการ์ด
                                  // + เส้นขอบซ้ายสีเดียวกับป้ายเลขบรรทัด บนจอกว้าง
                                  // ช่องคำที่น่าจะผิด/ถูก จะมาต่อแถวเดียวกันนี้เลย
                                  if (book.bookDetail != 'LineNull')
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (book.bookLines != 0) ...[
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: badgeColor,
                                            foregroundColor: Colors.white,
                                            child: Text(
                                              '${book.bookLines}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Expanded(
                                          flex: inlineFieldsWithContent ? 3 : 1,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: adaptivePageColor(context),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border(
                                                left: BorderSide(
                                                  color: badgeColor,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                            child: SelectableText(
                                              book.bookDetail,
                                              style: const TextStyle(
                                                fontFamily: 'THSarabunNew',
                                                fontSize: 24,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (inlineFieldsWithContent) ...[
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: wordIncorrectField,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: wordCorrectField,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    )
                                  else if (book.bookLines != 0)
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: badgeColor,
                                      foregroundColor: Colors.white,
                                      child: Text(
                                        '${book.bookLines}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  if (showFields) ...[
                                    const SizedBox(height: 10),
                                    if (!inlineFieldsWithContent) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: wordIncorrectField),
                                          const SizedBox(width: 10),
                                          Expanded(child: wordCorrectField),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    TextFormField(
                                      controller: controllersList[index][3],
                                      decoration: const InputDecoration(
                                        labelText: 'หมายเหตุ (ถ้ามี)',
                                        labelStyle: TextStyle(
                                          fontFamily: 'THSarabunNew',
                                          fontSize: 16,
                                        ),
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'THSarabunNew',
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
      bookTri91 = (await RemoteServiceBookTri91().getBookTri91(
        widget.bookId,
        widget.pageId,
        tSecretAPIKey,
      ))!;
      return bookTri91;
    } catch (e) {
      // ในกรณีที่เกิดข้อผิดพลาดในการเรียก API
      throw 'Failed to load books: $e';
    }
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
      padding: const EdgeInsets.all(8),
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: Colors.white,
          side: const BorderSide(color: TColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.save),
        label: const Text('บันทึกข้อมูล'),
        onPressed: () async {
          // ignore: unused_local_variable
          String comments = '-';
          List<LogeditSave> allLogeditData = [];
          DateTime now = DateTime.now();
          String formattedDateTime = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(now);
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
              showCustomDialog(
                context,
                'กรุณาป้อนคำที่น่าจะผิด บรรทัดที่ ${controllersList[i][0].text}',
              );
              return;
            } else if ((controllersList[i][1].text != '') &&
                (controllersList[i][2].text == '')) {
              showCustomDialog(
                context,
                'กรุณาป้อนคำที่น่าจะถูก บรรทัดที่ ${controllersList[i][0].text}',
              );
              return;
            }

            //   print('Controllers List $i:');
            //   for (int j = 0; j < controllersList[i].length; j++) {
            //     print('  Controller $j: ${controllersList[i][j].text}');
            //   }
          }
          if (allLogeditData.isNotEmpty) {
            String jsonData = logeditSaveToJson(allLogeditData);
            bool saveLogEditSuscess = await saveLogEditUser(
              jsonData,
              tSecretAPIKey,
            );
            if (saveLogEditSuscess) {
              //print('JSON Data: $saveLogEditSuscess');
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(context, true);
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลได้')),
              );
            }
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'กรุณาป้อนคำที่น่าจะผิด คำที่น่าจะถูกก่อนบันทึกข้อมูล',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<bool> saveLogEditUser(String jsonData, String token) async {
    try {
      var client = http.Client();
      var uri = Uri.parse(tURLlogEditSave);
      var data = {'json_data': jsonData, 'token': token};

      var response = await client.post(uri, body: data);

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
