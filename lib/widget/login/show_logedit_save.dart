import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/auto_text/text_span.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';

class ShowCorrectSave extends StatefulWidget {
  const ShowCorrectSave({super.key});

  @override
  State<ShowCorrectSave> createState() => _ShowCorrectSaveState();
}

class _ShowCorrectSaveState extends State<ShowCorrectSave> {
  List<dynamic> dataTitle = [];
  bool loadingTitle = false;
  int pageTitle = 1;
  int loadedRecordsTitle = 0;
  bool _isListView = false;
  late String opt = '0';
  List<dynamic> dataUser = [];
  List<dynamic> dataUserCurrect = [];
  final ScrollController _scrollControllerTitle = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDataCorrect();
    _scrollControllerTitle.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollControllerTitle.removeListener(_scrollListener);
    _scrollControllerTitle.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !loadingTitle) {
      _fetchDataCorrect();
    }
  }

  // เปลี่ยนตัวกรอง (ยังไม่ยืนยัน/ยืนยันแล้ว/แก้ไขแล้ว) แล้วโหลดชุดข้อมูลใหม่ตั้งแต่หน้า 1
  void _changeFilter(String newOpt) {
    setState(() {
      opt = newOpt;
      dataTitle = [];
      loadedRecordsTitle = 0;
      pageTitle = 1;
    });
    _fetchDataCorrect();
  }

  // รีเฟรชชุดข้อมูลปัจจุบันใหม่ตั้งแต่หน้า 1 (ใช้หลังเพิ่ม/ยืนยัน/แก้ไขข้อมูล)
  void _handleAddData() {
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      pageTitle = 1;
    });
    _fetchDataCorrect();
  }

  Future<void> _fetchDataCorrect() async {
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      Users? users = await getUsersList();
      String tmpUser = 'guest';
      if (users != null) {
        tmpUser = users.username;
      }
      final response = await http.post(
        Uri.parse(tURLshowlogEditWithAll),
        body: {
          'token': tSecretAPIKey,
          'username': tmpUser,
          'page': pageTitle.toString(),
          'opt': opt,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['message'];
          setState(() {
            dataTitle.addAll(newData);
            loadedRecordsTitle = dataTitle.length;
            pageTitle++;
            loadingTitle = false;
          });
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
          setState(() {
            loadingTitle = false;
          });
        }
      } else {
        // ignore: avoid_print
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          loadingTitle = false;
        });
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

  Future<void> _fetchUpdateInsertDataCorrect(
    String initialText,
    String bookid,
    String bookpage,
    String bookline,
  ) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLupdateLogEdit),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'bookid': bookid,
        'bookpage': bookpage,
        'bookline': bookline,
        'bookdetail': initialText,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        opt = '1';
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchUpdateInsertDataCorrectConfirm(
    String bookid,
    String bookpage,
    String bookline,
  ) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLupdateLogEditConfirm),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'bookid': bookid,
        'bookpage': bookpage,
        'bookline': bookline,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        opt = '1';
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchDataUser(
    String bookid,
    String bookpage,
    String bookline,
  ) async {
    final response = await http.post(
      Uri.parse(tURLtitleUserInPage),
      body: {
        'token': tSecretAPIKey,
        'bookid': bookid,
        'bookpage': bookpage,
        'bookline': bookline,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        dataUser.clear();
        dataUser.addAll(newData);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDialogUser(
    BuildContext context,
    String title,
    String bookid,
    String bookpage,
    String bookline,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUser(bookid, bookpage, bookline),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final screenSize = MediaQuery.of(context).size;
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: (screenSize.width * 0.8).clamp(0, 400),
                  height: (screenSize.height * 0.5).clamp(200, 500),
                  child: ListView.builder(
                    itemCount: dataUser.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: TColors.buttonPrimary,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}'),
                        ),
                        title: ATextTitleMedium(
                          text:
                              '${dataUser[index]['first_nameid']}${dataUser[index]['firstName']}  ${dataUser[index]['lastName']}',
                        ),
                        subtitle: ATextLabelMedium(
                          text:
                              'วันที่ยืนยัน ${dataUser[index]['tripitaka91_dateconfirm_local']}',
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<void> _fetchDataUserCorrect(
    String bookid,
    String bookpage,
    String bookline,
  ) async {
    final response = await http.post(
      Uri.parse(tURLtitleUserInPageCorrect),
      body: {
        'token': tSecretAPIKey,
        'bookid': bookid,
        'bookpage': bookpage,
        'bookline': bookline,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        dataUserCurrect.clear();
        dataUserCurrect.addAll(newData);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDialogUserCorrect(
    BuildContext context,
    String title,
    String bookid,
    String bookpage,
    String bookline,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUserCorrect(bookid, bookpage, bookline),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final screenSize = MediaQuery.of(context).size;
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: (screenSize.width * 0.8).clamp(0, 400),
                  height: (screenSize.height * 0.5).clamp(200, 500),
                  child: ListView.builder(
                    itemCount: dataUserCurrect.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: TColors.buttonPrimary,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}'),
                        ),
                        title: ATextTitleMedium(
                          text:
                              '${dataUserCurrect[index]['first_nameid']}${dataUserCurrect[index]['firstName']}  ${dataUserCurrect[index]['lastName']}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ATextLabelMedium(
                              text:
                                  'วันที่เพิ่มข้อมูล ${dataUserCurrect[index]['tripitaka91_dateadd_local']}',
                            ),
                            if ('${dataUserCurrect[index]['tripitaka91_wordincorrect'] ?? ''}'
                                    .trim()
                                    .isNotEmpty ||
                                '${dataUserCurrect[index]['tripitaka91_wordcorrect'] ?? ''}'
                                    .trim()
                                    .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'คำที่น่าจะผิด: ${dataUserCurrect[index]['tripitaka91_wordincorrect'] ?? ''}    '
                                  'คำที่น่าจะถูก: ${dataUserCurrect[index]['tripitaka91_wordcorrect'] ?? ''}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            if ('${dataUserCurrect[index]['tripitaka91_wordcorrectcomment'] ?? ''}'
                                .trim()
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'หมายเหตุ: ${dataUserCurrect[index]['tripitaka91_wordcorrectcomment']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<void> _fetchConfirmSuscess(
    String bookid,
    String bookpage,
    String bookline,
  ) async {
    final username = context.read<UserProvider>().user?.username ?? 'guest';
    final response = await http.post(
      Uri.parse(tURLsuscessCorrectConfirm),
      body: {
        'token': tSecretAPIKey,
        'username': username,
        'bookid': bookid,
        'bookpage': bookpage,
        'bookline': bookline,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        opt = '2';
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกการแก้ไขข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  // แจ้งว่าการแก้ไขที่ถูกนำไปใช้แล้ว (booksuscess==1) ไม่ถูกต้อง
  // ใช้ context.read<UserProvider>() แทน getUsersList() เดิม ตาม pattern ใหม่
  // ที่ใช้ใน lib/features/book/pageviews_html.dart
  Future<void> _fetchSubmitDispute(
    String bookid,
    String bookpage,
    String bookline,
    String comment,
  ) async {
    final username = context.read<UserProvider>().user?.username ?? 'guest';
    final response = await http.post(
      Uri.parse(tURLsaveLogEditDispute),
      body: {
        'token': tSecretAPIKey,
        'username': username,
        'bookid': bookid,
        'bookpage': bookpage,
        'bookline': bookline,
        'comment': comment,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        _showSnackbar(context, '${jsonResponse['message']}');
      } else {
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDisputeDialog(
    BuildContext context,
    String bookid,
    String bookpage,
    String bookline,
  ) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          title: const Text(
            'แจ้งว่าการแก้ไขนี้ไม่ถูกต้อง',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
          ),
          content: TextFormField(
            style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 26),
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'ระบุเหตุผลที่คิดว่าการแก้ไขนี้ไม่ถูกต้อง',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                if (comment.isEmpty) {
                  _showSnackbar(context, 'กรุณาระบุเหตุผล');
                  return;
                }
                await _fetchSubmitDispute(bookid, bookpage, bookline, comment);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text(
                ' ส่งข้อโต้แย้ง ',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInputDialog(
    BuildContext context,
    String correctWord,
    String initialText,
    String bookid,
    String bookpage,
    String bookline,
  ) {
    final TextEditingController textController = TextEditingController(
      text: initialText,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          title: SubstringHighlight(
            text: 'ระบุข้อความที่น่าจะถูก [ $correctWord ]',
            term: correctWord,
            textStyle: const TextStyle(
              fontFamily: 'THSarabunNew',
              fontSize: 24,
            ),
          ),
          content: TextFormField(
            style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 26),
            controller: textController,
            decoration: const InputDecoration(hintText: 'กรอกข้อมูลที่นี่'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String inputData = textController.text;
                if (inputData == initialText) {
                  _showSnackbar(context, 'กรุณาระบุข้อความที่น่าจะถูก');
                } else {
                  bool? confirm = await _showConfirmationDialog(context);
                  if (confirm!) {
                    await _fetchUpdateInsertDataCorrect(
                      inputData,
                      bookid,
                      bookpage,
                      bookline,
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text(
                ' บันทึกข้อมูล ',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการดำเนินการ'),
          content: const Text('คุณต้องการดำเนินการต่อ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(false); // ปิดหน้าต่างและส่งค่า false กลับ
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(true); // ปิดหน้าต่างและส่งค่า true กลับ
              },
              child: const Text(' ยืนยัน '),
            ),
          ],
        );
      },
    );
  }

  void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("แจ้งเตือน"),
          content: const Text("คุณยังไม่ได้รับสิทธิ์การยืนยันการแก้ไขข้อมูล"),
          actions: <Widget>[
            TextButton(
              child: const Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmInsertTap(
    BuildContext context,
    String bookid,
    String bookpage,
    String bookline,
  ) async {
    Users? users = await getUsersList();
    if (!context.mounted) return;
    if (users?.permissionLogEdit == '0') {
      showPermissionDialog(context);
      return;
    }
    bool? confirm = await _showConfirmationDialog(context);
    if (confirm == true) {
      await _fetchUpdateInsertDataCorrectConfirm(bookid, bookpage, bookline);
    }
  }

  Future<void> _confirmEditSuccessTap(
    BuildContext context,
    String bookid,
    String bookpage,
    String bookline,
  ) async {
    Users? users = await getUsersList();
    if (!context.mounted) return;
    String tmpLevel = users?.levelAccess ?? '2';
    if (tmpLevel != '1') {
      _showSnackbar(context, 'คุณยังไม่ได้รับสิทธิ์ยืนยันการแก้ไขข้อมูล');
      return;
    }
    bool? confirm = await _showConfirmationDialog(context);
    if (!context.mounted) return;
    if (confirm == true) {
      LoadingDialog.show(context);
      await _fetchConfirmSuscess(bookid, bookpage, bookline);
      if (!context.mounted) return;
      LoadingDialog.hide(context);
    }
  }

  // ชิปสถานะ/การกระทำแบบย่อ ใช้แทน ClipPath สามเหลี่ยมคู่แบบเดิม
  Widget _buildTag(String text, Color color, {VoidCallback? onTap}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
    if (onTap == null) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: chip,
    );
  }

  Widget _buildIndexBadge(dynamic record, {double radius = 15}) {
    final color = record['bookconfirm'] == 0
        ? Colors.grey
        : record['booksuscess'] == 0
        ? TColors.buttonPrimary
        : TColors.success;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: const Icon(Icons.edit_note, size: 16),
    );
  }

  // รายการชิปสถานะ/การกระทำ ขึ้นกับตัวกรองปัจจุบัน (opt) และสถานะของรายการ
  // ชิปแรกในลิสต์คือชิปหลักของสถานะนี้เสมอ
  List<Widget> _buildStatusTags(BuildContext context, dynamic record) {
    final bookid = '${record['tripitaka91_book']}';
    final bookpage = '${record['tripitaka91_page']}';
    final bookline = '${record['tripitaka91_line']}';

    if (record['detail_new'] == null) {
      return [
        _buildTag(
          'เพิ่มข้อความที่น่าจะถูก...',
          TColors.buttonPrimary,
          onTap: () => _showInputDialog(
            context,
            '${record['wordcorrect']}',
            '${record['detail_old']}',
            bookid,
            bookpage,
            bookline,
          ),
        ),
      ];
    }

    if (opt == '0') {
      return [
        _buildTag(
          'ยืนยันข้อมูล',
          TColors.buttonPrimary,
          onTap: () => _confirmInsertTap(context, bookid, bookpage, bookline),
        ),
        _buildTag(
          'สมาชิกยืนยันแล้ว ${record['bookconfirm']} ท่าน',
          TColors.success,
          onTap: () => _showDialogUser(
            context,
            'รายชื่อสมาชิกที่ยืนยันแล้ว',
            bookid,
            bookpage,
            bookline,
          ),
        ),
      ];
    } else if (opt == '1') {
      return [
        _buildTag(
          'สมาชิกที่ยืนยันแล้ว ${record['bookconfirm']} ท่าน',
          TColors.success,
          onTap: () => _showDialogUser(
            context,
            'รายชื่อสมาชิกที่ยืนยันแล้ว',
            bookid,
            bookpage,
            bookline,
          ),
        ),
      ];
    }
    // opt == '2'
    final Widget primaryTag;
    if (record['booksuscess'] == 1) {
      primaryTag = _buildTag('ข้อมูลถูกแก้ไขเรียบร้อยแล้ว', TColors.success);
    } else if (record['bookconfirm'] >= tCorrectNum) {
      primaryTag = _buildTag(
        'ยืนยันการแก้ไขข้อมูล',
        TColors.buttonPrimary,
        onTap: () =>
            _confirmEditSuccessTap(context, bookid, bookpage, bookline),
      );
    } else {
      primaryTag = _buildTag(
        'รอสมาชิกยืนยันครบ $tCorrectNum ท่าน',
        TColors.warning,
      );
    }
    return [
      primaryTag,
      _buildTag(
        'สมาชิกที่ยืนยัน ${record['bookconfirm']} ท่าน',
        TColors.success,
        onTap: () => _showDialogUser(
          context,
          'รายชื่อสมาชิกที่ยืนยันแล้ว',
          bookid,
          bookpage,
          bookline,
        ),
      ),
      if (record['booksuscess'] == 1)
        _buildTag(
          'แจ้งว่าการแก้ไขนี้ไม่ถูกต้อง',
          TColors.error,
          onTap: () => _showDisputeDialog(context, bookid, bookpage, bookline),
        ),
    ];
  }

  Widget _buildCard(BuildContext context, dynamic record, int index) {
    String userTmp = '${record['users']}'.replaceAll(',', ', ');
    final comment = '${record['wordcorrectcomment'] ?? ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIndexBadge(record),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เล่ม ${record['tripitaka91_book']} หน้า ${record['tripitaka91_page']} บรรทัด ${record['tripitaka91_line']}',
                  style: TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 18,
                    color: adaptiveTextColor(context).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'คำที่น่าจะผิด: ',
                        style: TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 20,
                          color: adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      TextSpan(
                        text: '${record['wordincorrect']}',
                        style: const TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 20,
                          color: TColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'คำที่น่าจะถูก: ',
                        style: TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 20,
                          color: adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      TextSpan(
                        text: '${record['wordcorrect']}',
                        style: const TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 20,
                          color: TColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'ข้อความเดิม: ',
                        style: TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 18,
                          color: adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      txtSpanHighlight(
                        ('${record['wordincorrect']}').split(','),
                        '${record['detail_old']}',
                      ),
                    ],
                  ),
                ),
                if (record['detail_new'] != null) ...[
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ข้อความที่แก้ไข: ',
                          style: TextStyle(
                            fontFamily: 'THSarabunNew',
                            fontSize: 18,
                            color: adaptiveTextColor(
                              context,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        txtSpanHighlight(
                          ('${record['wordcorrect']}').split(','),
                          '${record['detail_new']}',
                          color: Colors.green[200]!,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _buildStatusTags(context, record),
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  Text(
                    'หมายเหตุ $comment',
                    style: TextStyle(
                      fontFamily: 'THSarabunNew',
                      fontSize: 18,
                      color: adaptiveTextColor(context).withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _buildTag(
                  'แจ้งโดย: $userTmp',
                  TColors.primary1,
                  onTap: () => _showDialogUserCorrect(
                    context,
                    'รายชื่อสมาชิกที่แจ้งคำที่น่าจะผิด/คำที่น่าจะถูก',
                    '${record['tripitaka91_book']}',
                    '${record['tripitaka91_page']}',
                    '${record['tripitaka91_line']}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // แถวแบบย่อ (โหมดลิสต์): บรรทัดเดียวต่อรายการ + ชิปสรุปสถานะ + เมนู ⋮
  Widget _buildListRow(BuildContext context, dynamic record, int index) {
    // ชิปแรกของ _buildStatusTags คือชิปหลักของสถานะนี้เสมอ ใช้ตัวเดียวกับการ์ด
    // เพื่อให้ปุ่มยืนยันข้อมูล/เพิ่มข้อความที่น่าจะถูก โผล่มาในแถวเลย ไม่ต้องซ่อนในเมนู ⋮
    final primaryTag = _buildStatusTags(context, record).first;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: adaptiveSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIndexBadge(record, radius: 13),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${record['wordincorrect']}',
                    style: const TextStyle(
                      fontFamily: 'THSarabunNew',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: TColors.error,
                    ),
                  ),
                  TextSpan(
                    text: '  →  ',
                    style: TextStyle(
                      fontSize: 14,
                      color: adaptiveTextColor(context).withValues(alpha: 0.4),
                    ),
                  ),
                  TextSpan(
                    text: '${record['wordcorrect']}',
                    style: const TextStyle(
                      fontFamily: 'THSarabunNew',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: TColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          primaryTag,
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: adaptiveTextColor(context).withValues(alpha: 0.6),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'confirmedUsers',
                child: ListTile(
                  leading: Icon(Icons.group_outlined),
                  title: Text('ดูรายชื่อผู้ยืนยัน'),
                ),
              ),
              const PopupMenuItem(
                value: 'reporter',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('ดูรายชื่อผู้แจ้ง'),
                ),
              ),
              const PopupMenuItem(
                value: 'detail',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('ดูข้อความเต็ม'),
                ),
              ),
              if (record['booksuscess'] == 1)
                const PopupMenuItem(
                  value: 'dispute',
                  child: ListTile(
                    leading: Icon(Icons.report_gmailerrorred_outlined),
                    title: Text('แจ้งว่าการแก้ไขนี้ไม่ถูกต้อง'),
                  ),
                ),
            ],
            onSelected: (value) {
              final bookid = '${record['tripitaka91_book']}';
              final bookpage = '${record['tripitaka91_page']}';
              final bookline = '${record['tripitaka91_line']}';
              switch (value) {
                case 'confirmedUsers':
                  _showDialogUser(
                    context,
                    'รายชื่อสมาชิกที่ยืนยันแล้ว',
                    bookid,
                    bookpage,
                    bookline,
                  );
                  break;
                case 'reporter':
                  _showDialogUserCorrect(
                    context,
                    'รายชื่อสมาชิกที่แจ้งคำที่น่าจะผิด/คำที่น่าจะถูก',
                    bookid,
                    bookpage,
                    bookline,
                  );
                  break;
                case 'detail':
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('รายละเอียด'),
                      content: SingleChildScrollView(
                        child: _buildCard(context, record, index),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('ปิด'),
                        ),
                      ],
                    ),
                  );
                  break;
                case 'dispute':
                  _showDisputeDialog(context, bookid, bookpage, bookline);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: adaptivePageColor(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(child: _buildFilterToggle(context)),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isListView ? Icons.view_agenda_outlined : Icons.view_list,
                  ),
                  tooltip: _isListView ? 'แสดงแบบการ์ด' : 'แสดงแบบลิสต์',
                  onPressed: () {
                    setState(() => _isListView = !_isListView);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: dataTitle.isEmpty
                ? Center(
                    child: Text(
                      loadingTitle ? 'กำลังโหลด...' : 'ไม่พบข้อมูล',
                      style: TextStyle(
                        color: adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollControllerTitle,
                    padding: const EdgeInsets.all(12),
                    itemCount: loadedRecordsTitle + (loadingTitle ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= loadedRecordsTitle) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        );
                      }
                      final record = dataTitle[index];
                      return _isListView
                          ? _buildListRow(context, record, index)
                          : _buildCard(context, record, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // แถบปุ่มเลือกตัวกรอง (ยังไม่ยืนยัน/ยืนยันแล้ว/แก้ไขแล้ว)
  Widget _buildFilterToggle(BuildContext context) {
    Widget buildButton(String value, String label) {
      final selected = opt == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ElevatedButton(
          onPressed: () => _changeFilter(value),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              selected ? TColors.buttonPrimary : adaptiveSurfaceColor(context),
            ),
            foregroundColor: WidgetStateProperty.all<Color>(
              selected ? Colors.white : adaptiveTextColor(context),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: adaptiveBorderColor(context)),
              ),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildButton('0', 'ยังไม่ยืนยัน'),
          buildButton('1', 'ยืนยันแล้ว'),
          buildButton('2', 'แก้ไขแล้ว'),
        ],
      ),
    );
  }
}
