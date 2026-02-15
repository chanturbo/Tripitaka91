import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/auto_text/text_span.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class ShowCorrectSaveWithPage extends StatefulWidget {
  final String bookid;
  final String pageid;
  const ShowCorrectSaveWithPage(
      {super.key, required this.bookid, required this.pageid});

  @override
  State<ShowCorrectSaveWithPage> createState() =>
      _ShowCorrectSaveWithPageState();
}

class _ShowCorrectSaveWithPageState extends State<ShowCorrectSaveWithPage> {
  List<dynamic> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;

  late TextTitleReplace textTitleReplace;

  late String opt = '0';
  // AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  List<dynamic> dataUser = [];
  List<dynamic> dataUserCurrect = [];

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();

    _fetchDataCorrect();
  }

  @override
  void dispose() {
    // audioPlayerManager.dispose();
    super.dispose();
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
        Uri.parse(tURLshowlogEditWithPage),
        body: {
          'token': tSecretAPIKey,
          'username': tmpUser,
          'bookid': widget.bookid,
          'pageid': widget.pageid,
          'opt': opt,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['message'];
          setState(() {
            loadedRecordsTitle += newData.length;
            dataTitle.addAll(newData);
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

  void _handleAddData() {
    // ทำการ setState() เพื่ออัปเดตข้อมูลใหม่
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      loadingTitle = false;

      _fetchDataCorrect();
    });
  }

  Future<void> _fetchUpdateInsertDataCorrect(String initialText, String bookid,
      String bookpage, String bookline) async {
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
      String bookid, String bookpage, String bookline) async {
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
      String bookid, String bookpage, String bookline) async {
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

  Future<void> _fetchDataUserCorrect(
      String bookid, String bookpage, String bookline) async {
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

  Future<void> _fetchConfirmSuscess(
      String bookid, String bookpage, String bookline) async {
    final response = await http.post(
      Uri.parse(tURLsuscessCorrectConfirm),
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
        opt = '2';
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกการแก้ไขข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
        // print('HTTP Error: ${response.statusCode}');
        // print('${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDialogUser(BuildContext context, String title, String bookid,
      String bookpage, String bookline) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUser(bookid, bookpage, bookline),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataUser.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[900],
                              foregroundColor:
                                  const Color.fromARGB(255, 173, 137, 137),
                              child: ATextDiskplaySmall(text: '${index + 1}'),
                            ),
                            title: ATextTitleMedium(
                              text:
                                  '${dataUser[index]['first_nameid']}${dataUser[index]['firstName']}  ${dataUser[index]['lastName']}',
                            ),
                            subtitle: ATextLabelMedium(
                                text:
                                    'วันที่ยืนยัน ${dataUser[index]['tripitaka91_dateconfirm_local']}'),
                          ),
                        ],
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
              // Data is still being fetched, show loading indicator or whatever you want
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  void _showDialogUserCorrect(BuildContext context, String title, String bookid,
      String bookpage, String bookline) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUserCorrect(bookid, bookpage, bookline),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataUserCurrect.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[900],
                              foregroundColor:
                                  const Color.fromARGB(255, 173, 137, 137),
                              child: ATextDiskplaySmall(text: '${index + 1}'),
                            ),
                            title: ATextTitleMedium(
                              text:
                                  '${dataUserCurrect[index]['first_nameid']}${dataUserCurrect[index]['firstName']}  ${dataUserCurrect[index]['lastName']}',
                            ),
                            subtitle: ATextLabelMedium(
                                text:
                                    'วันที่เพิ่มข้อมูล ${dataUserCurrect[index]['tripitaka91_dateadd_local']}'),
                          ),
                        ],
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
              // Data is still being fetched, show loading indicator or whatever you want
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  void _showInputDialog(
      BuildContext context,
      String wordincorrect,
      String correctWord,
      String initialText,
      String bookid,
      String bookpage,
      String bookline) {
    final TextEditingController textController =
        TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'ข้อความที่น่าจะผิด : ',
                      style: TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 24,
                          color: Colors.grey),
                    ),
                    txtSpanHighlight(wordincorrect.split(','), initialText),
                    const TextSpan(
                      text: '\t\t\t\tคำที่น่าจะผิด : ',
                      style: TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 24,
                          color: Colors.grey),
                    ),
                    TextSpan(
                      text: '$wordincorrect\n',
                      style: const TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 24,
                          color: Colors.red),
                    ),
                  ],
                ),
              ),
              SubstringHighlight(
                text: 'ระบุข้อความที่น่าจะถูก [ $correctWord ]',
                term: correctWord,
                textStyle:
                    const TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ],
          ),
          content: TextFormField(
            style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 26),
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'กรอกข้อมูลที่นี่',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดหน้าต่าง
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // ทำสิ่งที่ต้องการเมื่อกดปุ่มบันทึกข้อมูล
                String inputData = textController.text;
                if (inputData == initialText) {
                  _showSnackbar(context, 'กรุณาระบุข้อความที่น่าจะถูก');
                } else {
                  // อาจทำการใช้ข้อมูลที่ป้อนเข้ามาต่อไป
                  // print(
                  //     'ข้อมูลที่ป้อน: $inputData เล่ม $bookid หน้า $bookpage บรรทัด $bookline');
                  bool? confirm = await _showConfirmationDialog(context);
                  if (confirm!) {
                    await _fetchUpdateInsertDataCorrect(
                        inputData, bookid, bookpage, bookline);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(); // ปิดหน้าต่าง
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
                Navigator.of(context)
                    .pop(false); // ปิดหน้าต่างและส่งค่า false กลับ
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // ปิดหน้าต่างและส่งค่า true กลับ
              },
              child: const Text(' ยืนยัน '),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.red), // กำหนดสีพื้นหลังเป็นสีขาว
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // กำหนดขนาดของเส้นขอบ
                  side: const BorderSide(
                      color: Colors.black), // กำหนดสีของเส้นขอบ
                ),
              ),
            ),
            child: const ATextLabelMediumColor(
                color: Colors.white, text: ' - [ X ] ปิดหน้าจอ -> '),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: loadedRecordsTitle + 1,
              itemBuilder: (context, index) {
                if (index == loadedRecordsTitle) {
                  // print('opt $opt');
                  // print('index  $index');
                  // print('loadedRecordsTitle $loadedRecordsTitle');
                  return loadingTitle
                      ? const Center(child: CircularProgressIndicator())
                      : loadedRecordsTitle == 0
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        opt = '0';
                                        _handleAddData();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<
                                            Color>(opt ==
                                                '0'
                                            ? Colors.orange
                                            : Colors
                                                .white), // กำหนดสีพื้นหลังเป็นสีขาว
                                        shape: WidgetStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                18.0), // กำหนดขนาดของเส้นขอบ
                                            side: const BorderSide(
                                                color: Colors
                                                    .black), // กำหนดสีของเส้นขอบ
                                          ),
                                        ),
                                      ),
                                      child: ATextLabelMediumColor(
                                          color: opt == '0'
                                              ? Colors.white
                                              : Colors.grey,
                                          text: ' แสดงข้อมูลที่ยังไม่ยืนยัน '),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        opt = '1';
                                        _handleAddData();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<
                                            Color>(opt ==
                                                '1'
                                            ? Colors.orange
                                            : Colors
                                                .white), // กำหนดสีพื้นหลังเป็นสีขาว
                                        shape: WidgetStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                18.0), // กำหนดขนาดของเส้นขอบ
                                            side: const BorderSide(
                                                color: Colors
                                                    .black), // กำหนดสีของเส้นขอบ
                                          ),
                                        ),
                                      ),
                                      child: ATextLabelMediumColor(
                                          color: opt == '1'
                                              ? Colors.white
                                              : Colors.grey,
                                          text: ' แสดงข้อมูลที่ยืนยันแล้ว '),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        opt = '2';
                                        _handleAddData();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<
                                            Color>(opt ==
                                                '2'
                                            ? Colors.orange
                                            : Colors
                                                .white), // กำหนดสีพื้นหลังเป็นสีขาว
                                        shape: WidgetStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                18.0), // กำหนดขนาดของเส้นขอบ
                                            side: const BorderSide(
                                                color: Colors
                                                    .black), // กำหนดสีของเส้นขอบ
                                          ),
                                        ),
                                      ),
                                      child: ATextLabelMediumColor(
                                          color: opt == '2'
                                              ? Colors.white
                                              : Colors.grey,
                                          text: ' แสดงข้อมูลที่แก้ไขแล้ว '),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox.shrink();
                }
                String userTmp = dataTitle[index]['users'];
                userTmp = userTmp.replaceAll(',', ', ');
                return Column(
                  children: [
                    if (index == 0) const SizedBox(height: 10),
                    if (index == 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              opt = '0';
                              _handleAddData();
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  opt == '0'
                                      ? Colors.orange
                                      : Colors
                                          .white), // กำหนดสีพื้นหลังเป็นสีขาว
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      18.0), // กำหนดขนาดของเส้นขอบ
                                  side: const BorderSide(
                                      color: Colors.black), // กำหนดสีของเส้นขอบ
                                ),
                              ),
                            ),
                            child: ATextLabelMediumColor(
                                color: opt == '0' ? Colors.white : Colors.grey,
                                text: ' แสดงข้อมูลที่ยังไม่ยืนยัน '),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              opt = '1';
                              _handleAddData();
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  opt == '1'
                                      ? Colors.orange
                                      : Colors
                                          .white), // กำหนดสีพื้นหลังเป็นสีขาว
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      18.0), // กำหนดขนาดของเส้นขอบ
                                  side: const BorderSide(
                                      color: Colors.black), // กำหนดสีของเส้นขอบ
                                ),
                              ),
                            ),
                            child: ATextLabelMediumColor(
                                color: opt == '1' ? Colors.white : Colors.grey,
                                text: ' แสดงข้อมูลที่ยืนยันแล้ว '),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              opt = '2';
                              _handleAddData();
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  opt == '2'
                                      ? Colors.orange
                                      : Colors
                                          .white), // กำหนดสีพื้นหลังเป็นสีขาว
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      18.0), // กำหนดขนาดของเส้นขอบ
                                  side: const BorderSide(
                                      color: Colors.black), // กำหนดสีของเส้นขอบ
                                ),
                              ),
                            ),
                            child: ATextLabelMediumColor(
                                color: opt == '2' ? Colors.white : Colors.grey,
                                text: ' แสดงข้อมูลที่แก้ไขแล้ว '),
                          ),
                        ],
                      ),
                    if (index == 0) const SizedBox(height: 10),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: dataTitle[index]['bookconfirm'] == 0
                            ? Colors.grey
                            : dataTitle[index]['booksuscess'] == 0
                                ? Colors.blue[900]
                                : Colors.green,
                        foregroundColor: Colors.white,
                        child: ATextDiskplayMedium(text: '${index + 1}'),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'ข้อความที่น่าจะผิด : ',
                                  style: TextStyle(
                                      fontFamily: 'THSarabunNew',
                                      fontSize: 24,
                                      color: Colors.grey),
                                ),
                                txtSpanHighlight(
                                    (dataTitle[index]['wordincorrect'])
                                        .split(','),
                                    '${dataTitle[index]['detail_old']}'),
                                const TextSpan(
                                  text: '\t\t\t\tคำที่น่าจะผิด : ',
                                  style: TextStyle(
                                      fontFamily: 'THSarabunNew',
                                      fontSize: 24,
                                      color: Colors.grey),
                                ),
                                TextSpan(
                                  text:
                                      '${dataTitle[index]['wordincorrect']}\n',
                                  style: const TextStyle(
                                      fontFamily: 'THSarabunNew',
                                      fontSize: 24,
                                      color: Colors.red),
                                ),
                                const TextSpan(
                                  text: 'ข้อความที่น่าจะถูก : ',
                                  style: TextStyle(
                                      fontFamily: 'THSarabunNew',
                                      fontSize: 24,
                                      color: Colors.grey),
                                ),
                                txtSpanHighlight(
                                    (dataTitle[index]['wordcorrect'])
                                        .split(','),
                                    '${dataTitle[index]['detail_new']}'),
                                const TextSpan(
                                  text: '\t\t\t\tคำที่น่าจะถูก : ',
                                  style: TextStyle(
                                      fontFamily: 'THSarabunNew',
                                      fontSize: 24,
                                      color: Colors.grey),
                                ),
                                TextSpan(
                                  text: '${dataTitle[index]['wordcorrect']}',
                                  style: const TextStyle(
                                      fontFamily: 'THSarabunNew',
                                      fontSize: 24,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          dataTitle[index]['detail_new'] == null
                              ? InkWell(
                                  onTap: () {
                                    _showInputDialog(
                                        context,
                                        '${dataTitle[index]['wordincorrect']}',
                                        '${dataTitle[index]['wordcorrect']}',
                                        '${dataTitle[index]['detail_old']}',
                                        '${dataTitle[index]['tripitaka91_book']}',
                                        '${dataTitle[index]['tripitaka91_page']}',
                                        '${dataTitle[index]['tripitaka91_line']}');
                                  },
                                  child: const SizedBox(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        Icon(Icons.add),
                                        ATextLabelLarge(
                                          text: 'เพิ่มข้อความที่น่าจะถูก...',
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : opt == '0'
                                  ? SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              bool? confirm =
                                                  await _showConfirmationDialog(
                                                      context);
                                              if (confirm!) {
                                                // print('ยืนยันข้อมูล');
                                                await _fetchUpdateInsertDataCorrectConfirm(
                                                    '${dataTitle[index]['tripitaka91_book']}',
                                                    '${dataTitle[index]['tripitaka91_page']}',
                                                    '${dataTitle[index]['tripitaka91_line']}');
                                              }
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: ClipPath(
                                                clipper:
                                                    DoubleTriangleRectangleClipper(),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  color: Colors.red,
                                                  child:
                                                      const ATextDiskplaySmall(
                                                          text: 'ยืนยันข้อมูล'),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _showDialogUser(
                                                  context,
                                                  'รายชื่อสมาชิกที่ยืนยันแล้ว',
                                                  '${dataTitle[index]['tripitaka91_book']}',
                                                  '${dataTitle[index]['tripitaka91_page']}',
                                                  '${dataTitle[index]['tripitaka91_line']}');
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: ClipPath(
                                                clipper:
                                                    DoubleTriangleRectangleClipper(),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  color: Colors.green,
                                                  child: ATextDiskplaySmall(
                                                      text:
                                                          'สมาชิกได้ยืนยันแล้ว ${dataTitle[index]['bookconfirm']} ท่าน'),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : opt == '1'
                                      ? InkWell(
                                          onTap: () {
                                            _showDialogUser(
                                                context,
                                                'รายชื่อสมาชิกที่ยืนยันแล้ว',
                                                '${dataTitle[index]['tripitaka91_book']}',
                                                '${dataTitle[index]['tripitaka91_page']}',
                                                '${dataTitle[index]['tripitaka91_line']}');
                                          },
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: ClipPath(
                                              clipper:
                                                  DoubleTriangleRectangleClipper(),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                color: Colors.green,
                                                child: ATextDiskplaySmall(
                                                    text:
                                                        'สมาชิกได้ยืนยันแล้ว ${dataTitle[index]['bookconfirm']} ท่าน'),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            const SizedBox(width: 10),
                                            dataTitle[index]['booksuscess'] == 1
                                                ? Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ClipPath(
                                                      clipper:
                                                          DoubleTriangleRectangleClipper(),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                        color: Colors.green,
                                                        child: const ATextLabelMediumColor(
                                                            color: Colors.white,
                                                            text:
                                                                ' ข้อมูลถูกแก้ไขเรียบร้อยแล้ว '),
                                                      ),
                                                    ),
                                                  )
                                                : dataTitle[index]
                                                            ['bookconfirm'] >=
                                                        tCorrectNum
                                                    ? InkWell(
                                                        onTap: () async {
                                                          Users? users =
                                                              await getUsersList();
                                                          String tmpLevel = '2';
                                                          if (users != null) {
                                                            tmpLevel = users
                                                                .levelAccess;
                                                          }
                                                          if (tmpLevel == '1') {
                                                            bool? confirm =
                                                                // ignore: use_build_context_synchronously
                                                                await _showConfirmationDialog(
                                                                    context);
                                                            if (confirm!) {
                                                              // ignore: use_build_context_synchronously
                                                              LoadingDialog
                                                                  .show(
                                                                      context);
                                                              await _fetchConfirmSuscess(
                                                                  '${dataTitle[index]['tripitaka91_book']}',
                                                                  '${dataTitle[index]['tripitaka91_page']}',
                                                                  '${dataTitle[index]['tripitaka91_line']}');
                                                              // ignore: use_build_context_synchronously
                                                              LoadingDialog
                                                                  .hide(
                                                                      context);
                                                              // print(
                                                              //     'ยืนยันการยืนแก้ไขข้อมูล');
                                                              // print('${dataTitle[index]['words']}');
                                                            }
                                                          } else {
                                                            // ignore: use_build_context_synchronously
                                                            _showSnackbar(
                                                                context,
                                                                'คุณยังไม่ได้รับสิทธิ์ยืนยันการแก้ไขข้อมูล');
                                                          }
                                                        },
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: ClipPath(
                                                            clipper:
                                                                DoubleTriangleRectangleClipper(),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
                                                              color: Colors.red,
                                                              child: const ATextDiskplaySmall(
                                                                  text:
                                                                      'ยืนยันการยืนแก้ไขข้อมูล'),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: ClipPath(
                                                          clipper:
                                                              DoubleTriangleRectangleClipper(),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            color:
                                                                Colors.yellow,
                                                            child: const ATextLabelMediumColor(
                                                                color: Colors
                                                                    .black,
                                                                text:
                                                                    ' รอสมาชิกยืนยันครบ $tCorrectNum ท่าน '),
                                                          ),
                                                        ),
                                                      ),
                                            const SizedBox(width: 10),
                                            InkWell(
                                              onTap: () {
                                                _showDialogUser(
                                                    context,
                                                    'รายชื่อสมาชิกที่ยืนยันแล้ว',
                                                    '${dataTitle[index]['tripitaka91_book']}',
                                                    '${dataTitle[index]['tripitaka91_page']}',
                                                    '${dataTitle[index]['tripitaka91_line']}');
                                              },
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: ClipPath(
                                                  clipper:
                                                      DoubleTriangleRectangleClipper(),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    color: Colors.green,
                                                    child: ATextDiskplaySmall(
                                                        text:
                                                            'สมาชิกที่ยืนยัน ${dataTitle[index]['bookconfirm']} ท่าน'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                          const Divider(),
                          ATextTitleSmallTHColor(
                              color: Colors.grey,
                              text:
                                  'เล่ม ${dataTitle[index]['tripitaka91_book']} หน้า ${dataTitle[index]['tripitaka91_page']} บรรทัด ${dataTitle[index]['tripitaka91_line']}\nหมายเหตุ : ${dataTitle[index]['wordcorrectcomment'] ?? '-'}'),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _showDialogUserCorrect(
                                  context,
                                  'รายชื่อสมาชิกที่แจ้งคำที่น่าจะผิด/คำที่น่าจะถูก',
                                  '${dataTitle[index]['tripitaka91_book']}',
                                  '${dataTitle[index]['tripitaka91_page']}',
                                  '${dataTitle[index]['tripitaka91_line']}');
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ClipPath(
                                clipper: DoubleTriangleRectangleClipper(),
                                child: Container(
                                  padding: const EdgeInsets.all(3.0),
                                  color: Colors.orange,
                                  child: ATextDiskplaySmall(
                                      text: 'แจ้งโดย : $userTmp'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // audioPlayerManager.stop();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => Tri91PageView(
                        //       triBookid:
                        //           textTitleReplace.getBookId(dataTitle[index]),
                        //       triPageid: int.parse(
                        //           textTitleReplace.getPageId(dataTitle[index])),
                        //       triBookline:
                        //           textTitleReplace.getLineId(dataTitle[index]),
                        //       chkSearch: widget.wordSearch,
                        //     ),
                        //   ),
                        // );
                      },
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
