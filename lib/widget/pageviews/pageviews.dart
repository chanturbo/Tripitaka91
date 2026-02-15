import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/models/book_tri91.dart';
import 'package:tripitaka91/utils/models/log_edit.dart';
import 'package:tripitaka91/utils/models/tri91_bookall.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/audio/edit_speak.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/widget/last_read/save_last.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/login/login_dialog.dart';
import 'package:tripitaka91/widget/login/show_logedit_save_with_page.dart';
import 'package:tripitaka91/widget/pageviews/pageviews_edit.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';

class Tri91PageViewHtml1 extends StatefulWidget {
  final String triBookid;
  final int triPageid;
  final String triBookline;
  final String chkSearch;
  final bool isMobile;
  final bool online;

  const Tri91PageViewHtml1({
    super.key,
    required this.triBookid,
    required this.triPageid,
    required this.triBookline,
    required this.chkSearch,
    required this.isMobile,
    required this.online,
  });

  @override
  State<Tri91PageViewHtml1> createState() => _Tri91PageViewHtml1State();
}

class _Tri91PageViewHtml1State extends State<Tri91PageViewHtml1> {
  late List<RandTitle> randTitle = [];
  late List<BookTri91> bookTri91 = [];
  late List<Tri91BookAll> tri91BookAll = [];
  late List<Logedit> logEdit = [];
  double _currentSliderValue = 0;
  int pageChanged = 0;
  late PageController pageController;

  late String triCatage = 'โหลดข้อมูล...';
  late String triTitle = 'โหลดข้อมูล...';
  late String bookBlue = 'โหลดข้อมูล...';
  late String bookRed = 'โหลดข้อมูล...';
  late int numRecord = 0;
  late int numPageAll = 1;
  late int bookid = 1;
  late int pageids = widget.triPageid;
  late int bookLine = 1;
  late String bookTitleTri91 = '';
  late int tribookline = 0;
  late String txtShowEmpty = 'โหลดข้อมูล...';
  final ScrollController _scrollControllerListTitle = ScrollController();

  List<String> currentPlaylist = [];
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  AudioPlayerManager audioPlayerManagerTitle = AudioPlayerManager();
  Users? users;

  List<List<TextEditingController>> controllersList = [];

  final TextTitleReplace textReplacer = TextTitleReplace();
  // bool isDrawerOpen = false;
  late List<String> uniqueItems;
  List<String> dataDict = [];
  late TextTitleReplace textTitleReplace;

  int triBookLineRead = 1;

  late InAppWebViewController webViewController;

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getUser();
    // _currentSliderValue = widget.triPageid as double;
    getDataTitle();
    _getLogEdit();
    getBookTri91All();

    pageController =
        PageController(initialPage: widget.triPageid, viewportFraction: 1.0);
    textTitleReplace = TextTitleReplace();
    uniqueItems = [];
  }

  @override
  void dispose() {
    saveLastRead();
    audioPlayerManager.dispose();
    audioPlayerManagerTitle.dispose();
    super.dispose();
  }

  Future<void> _getUser() async {
    users = await getUsersList();
  }

  void saveLastRead() async {
    bool chk =
        await saveBookAccessList(int.parse(widget.triBookid), pageChanged);
    if (chk) {}
  }

  Future<void> _getLogEdit() async {
    try {
      logEdit = await RemoteServiceLogEdit()
              .getLogEdit(widget.triBookid, tSecretAPIKey) ??
          [];
    } catch (e) {
      // ignore: avoid_print
      print('Error occurred: $e');
    }
  }

  void getBookTri91All() async {
    try {
      tri91BookAll = await RemoteServiceBookTri91All()
              .getBookTri91All(widget.triBookid, tSecretAPIKey) ??
          [];
      if (tri91BookAll.isNotEmpty) {
        setState(() {
          numPageAll = tri91BookAll[0].bookPagesTotal;
          bookTitleTri91 = tri91BookAll[0].bookTitleTri;
          _currentSliderValue = widget.triPageid.toDouble();
          pageChanged = widget.triPageid;
          tribookline = int.parse(widget.triBookline);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('getBookTri91All : Error occurred: $e');
      // Show a user-friendly error message if needed
    }
  }

  void getDataTitle() async {
    try {
      randTitle = await RemoteServiceTitle()
              .getTitle(widget.triBookid, tSecretAPIKey) ??
          [];

      if (randTitle.isNotEmpty) {
        setState(() {
          bookid = randTitle[0].tripitaka91Book;
          numRecord = randTitle.length;
        });
      } else {
        setState(() {
          bookid = int.parse(widget.triBookid);
          triCatage = 'โหลดข้อมูล...';
          triTitle = 'โหลดข้อมูล...';
          bookBlue = 'โหลดข้อมูล...';
          bookRed = 'โหลดข้อมูล...';
          txtShowEmpty = 'ไม่มีหัวข้อธรรมสำหรับแสดงผล';
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('getDataTitle : Error occurred: $e');
      // Show a user-friendly error message if needed
    }
  }

  // void toggleDrawer() {
  //   setState(() {
  //     isDrawerOpen = !isDrawerOpen;
  //   });
  // }

  List<String> removeDuplicatesAndDash(String dictTmp) {
    List<String> items = dictTmp.split(',');
    Set<String> uniqueSet = <String>{};

    for (String item in items) {
      String trimmedItem = item.trim();
      if (trimmedItem.isNotEmpty && trimmedItem != '-') {
        uniqueSet.add(trimmedItem);
      }
    }

    return uniqueSet.toList();
  }

  void _showDialogDict(BuildContext context, String result, bool isM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataDict(result),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                contentPadding: const EdgeInsets.all(5),
                title: const Text('คำศัพท์ที่ตรวจพบในหน้านี้'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataDict.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Card(
                          margin: const EdgeInsets.all(5),
                          color: Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                // leading: CircleAvatar(
                                //   backgroundColor: Colors.blue[900],
                                //   foregroundColor: Colors.white,
                                //   child: ATextDiskplayMedium(text: '${index + 1}'),
                                // ),
                                title: isM
                                    ? ATextTitleMedium18(
                                        text:
                                            '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}',
                                      )
                                    : ATextTitleMedium(
                                        text:
                                            '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}',
                                      ),
                                subtitle: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        LoadingDialog.show(context);
                                        String txtTitle =
                                            '${textTitleReplace.getWordDict(dataDict[index])} - ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                                        String namesave = textTitleReplace
                                            .getWordDict(dataDict[index])
                                            .trim()
                                            .replaceAll(RegExp(r'\s+'), '');

                                        String filename = 'dict-$namesave';
                                        await audioPlayerManager.playAudio(
                                            '3', filename, txtTitle);
                                        // ignore: use_build_context_synchronously
                                        LoadingDialog.hide(context);
                                      },
                                      child: Icon(
                                        Icons.volume_up,
                                        size: isM ? 25 : 20,
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () async {
                                        String txtTitle =
                                            '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                                        txtTitle +=
                                            ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์';
                                        await Share.share(txtTitle,
                                            subject:
                                                'พจนานุกรม ฉบับประมวลศัพท์');
                                      },
                                      child: Icon(
                                        Icons.share,
                                        size: isM ? 21 : 16,
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () async {
                                        String txtTitle =
                                            '${textTitleReplace.getWordDict(dataDict[index])}\n${textTitleReplace.getWordDictDetail(dataDict[index])}';
                                        txtTitle +=
                                            ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์ รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต)';
                                        Clipboard.setData(
                                          ClipboardData(text: txtTitle),
                                        );
                                        _showSnackbar(context,
                                            'คัดลอกข้อมูลเรียบร้อยแล้ว');
                                      },
                                      child: Icon(
                                        Icons.copy,
                                        size: isM ? 21 : 16,
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        child: Text(''),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {},
                              ),
                            ],
                          ),
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
                    child: const Text('ปิด'),
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

  void _showDialogTitle(BuildContext context, bool isM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          title: const Text('สารบัญหัวข้อธรรม'),
          content: (numRecord == 0)
              ? SizedBox(
                  width: double.maxFinite,
                  child: Text(txtShowEmpty),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    controller: _scrollControllerListTitle,
                    itemCount: numRecord,
                    itemBuilder: (context, index) {
                      return titleCardSub(
                        randTitle.isEmpty
                            ? triTitle
                            : randTitle[index].tripitaka91Title,
                        randTitle.isEmpty
                            ? bookBlue
                            : randTitle[index].tripitaka91BookBlue,
                        randTitle.isEmpty
                            ? bookRed
                            : randTitle[index].tripitaka91BookRed,
                        randTitle.isEmpty
                            ? bookid.toString()
                            : randTitle[index].tripitaka91Book.toString(),
                        randTitle.isEmpty
                            ? pageids
                            : randTitle[index].tripitaka91Page,
                        randTitle.isEmpty
                            ? bookLine.toString()
                            : randTitle[index].tripitaka91Line.toString(),
                        randTitle.isEmpty
                            ? "FALSE"
                            : randTitle[index].tripitaka91Mark,
                        randTitle.isEmpty
                            ? 0
                            : randTitle[index].tripitaka91Code,
                        randTitle.isEmpty ? 0 : randTitle[index].tripitaka91No,
                        isM,
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchDataDict(String result) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }

    final response = await http.post(
      Uri.parse(tURLtitleDictInPage),
      body: {
        'wordsearch': result,
        'token': tSecretAPIKey,
        'username': tmpUser,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        List<String> newData = List<String>.from(jsonResponse['message']);
        dataDict.clear();
        dataDict.addAll(newData);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showInputDialog(BuildContext context, String initialText,
      String tripitaka91No, String tripitaka91Code) {
    final TextEditingController textController =
        TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          title: const Text(
            'แก้ไขข้อมูลหัวข้อธรรม (สำหรับ Admin เท่านั้น)',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
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
                if (users != null) {
                  // ทำสิ่งที่ต้องการเมื่อกดปุ่มบันทึกข้อมูล
                  String inputData = textController.text;
                  if (inputData == '') {
                    _showSnackbar(context, 'กรุณาป้อนข้อมูลให้ครบถ้วน');
                  } else {
                    // อาจทำการใช้ข้อมูลที่ป้อนเข้ามาต่อไป
                    // print(
                    //     'ข้อมูลที่ป้อน: $inputData เล่ม $bookid หน้า $bookpage บรรทัด $bookline');
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm!) {
                      await _fetchUpdateTitle(
                          inputData, tripitaka91No, tripitaka91Code);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(); // ปิดหน้าต่าง
                    }
                  }
                } else {
                  _showSnackbar(context, 'กรุณาเข้าสู่ระบบก่อน');
                  Navigator.of(context).pop(); // ปิดหน้าต่าง
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

  Future<void> _fetchUpdateTitle(
      String initialText, String tripitaka91No, String tripitaka91Code) async {
    final response = await http.post(
      Uri.parse(tURLtitleEdit),
      body: {
        'token': tSecretAPIKey,
        'tripitaka91no': tripitaka91No,
        'tripitaka91code': tripitaka91Code,
        'titledetail': initialText,
        'username': users!.username,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        getDataTitle();
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
      appBar: buildAppBar(),
      body: Stack(
        children: [
          ResponsiveLayoutClass(
            mobileView: buildBodyMobile(),
            tabletView: buildBodyTablet(),
            desktopView: buildBody(),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: ATextDiskplayMedium(text: '(เล่ม $bookid) $bookTitleTri91'),
      actions: [
        IconButton(
          icon: const Tooltip(
            message: 'แจ้งคำผิดคำถูก', // ข้อความ Tooltip
            child: Icon(
              Icons.edit,
              color: Colors.white, // สีไอคอนเป็นสีขาว
            ),
          ),
          onPressed: () {
            if (users != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageViewEdit(
                      bookId: widget.triBookid,
                      pageId: pageChanged.toString(),
                      username: users!.username,
                      logEdit: logEdit,
                    ),
                  )).then((value) {
                if (value != null && value == true) {
                  // หลังจากกลับมาจาก NextPage และค่าที่ส่งกลับมาคือ true
                  // ทำสิ่งที่คุณต้องการทำต่อได้ที่นี่
                  // print('Returned with true');
                  setState(() {
                    _getLogEdit();
                  });
                }
              });
            } else {
              // String mgr = 'กรุณาเข้าสู่ระบบก่อน';
              chkLoginStatus(context);
            }
          },
        ),
        IconButton(
          icon: const Tooltip(
            message: 'ยืนยันการแก้ไขคำผิดคำถูก', // ข้อความ Tooltip
            child: Icon(
              Icons.spellcheck,
              color: Colors.white, // สีไอคอนเป็นสีขาว
            ),
          ),
          onPressed: () {
            if (users != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowCorrectSaveWithPage(
                      bookid: widget.triBookid,
                      pageid: pageChanged.toString(),
                    ),
                  )).then((value) {
                if (value != null && value == true) {
                  // หลังจากกลับมาจาก NextPage และค่าที่ส่งกลับมาคือ true
                  // ทำสิ่งที่คุณต้องการทำต่อได้ที่นี่
                  // print('Returned with true');
                  setState(() {
                    _getLogEdit();
                  });
                }
              });
            } else {
              // String mgr = 'กรุณาเข้าสู่ระบบก่อน';
              chkLoginStatus(context);
            }
          },
        ),
        IconButton(
          icon: const Tooltip(
            message: 'แจ้งการอ่านออกเสียง', // ข้อความ Tooltip
            child: Icon(
              Icons.record_voice_over,
              color: Colors.white, // สีไอคอนเป็นสีขาว
            ),
          ),
          onPressed: () {
            if (users != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSpeakScreen(
                    comments: 'เล่ม $bookid หน้า $pageChanged',
                  ),
                ),
              );
            } else {
              // String mgr = 'กรุณาเข้าสู่ระบบก่อน';
              chkLoginStatus(context);
            }
          },
        ),
      ],
    );
  }

  Widget buildBodyMobile() {
    return Row(
      children: [
        pageview(true, false),
      ],
    );
  }

  Widget buildBodyTablet() {
    return Row(
      children: [
        (numRecord == 0)
            ? Container(
                alignment: Alignment.topCenter,
                width: 250.0,
                color: Colors.white,
                child: Text(txtShowEmpty),
              )
            : Container(
                width: 250.0,
                color: Colors.white,
                child: ListView.builder(
                  controller: _scrollControllerListTitle,
                  itemCount: numRecord,
                  itemBuilder: (context, index) {
                    return titleCardSub(
                      randTitle.isEmpty
                          ? triTitle
                          : randTitle[index].tripitaka91Title,
                      randTitle.isEmpty
                          ? bookBlue
                          : randTitle[index].tripitaka91BookBlue,
                      randTitle.isEmpty
                          ? bookRed
                          : randTitle[index].tripitaka91BookRed,
                      randTitle.isEmpty
                          ? bookid.toString()
                          : randTitle[index].tripitaka91Book.toString(),
                      randTitle.isEmpty
                          ? pageids
                          : randTitle[index].tripitaka91Page,
                      randTitle.isEmpty
                          ? bookLine.toString()
                          : randTitle[index].tripitaka91Line.toString(),
                      randTitle.isEmpty
                          ? "FALSE"
                          : randTitle[index].tripitaka91Mark,
                      randTitle.isEmpty ? 0 : randTitle[index].tripitaka91Code,
                      randTitle.isEmpty ? 0 : randTitle[index].tripitaka91No,
                      false,
                    );
                  },
                ),
              ),
        pageview(false, true),
      ],
    );
  }

  Widget buildBody() {
    return Row(
      children: [
        (numRecord == 0)
            ? Container(
                alignment: Alignment.topCenter,
                width: 350.0,
                color: Colors.white,
                child: Text(txtShowEmpty),
              )
            : Container(
                width: 350.0,
                color: Colors.white,
                child: ListView.builder(
                  controller: _scrollControllerListTitle,
                  itemCount: numRecord,
                  itemBuilder: (context, index) {
                    return titleCardSub(
                      randTitle.isEmpty
                          ? triTitle
                          : randTitle[index].tripitaka91Title,
                      randTitle.isEmpty
                          ? bookBlue
                          : randTitle[index].tripitaka91BookBlue,
                      randTitle.isEmpty
                          ? bookRed
                          : randTitle[index].tripitaka91BookRed,
                      randTitle.isEmpty
                          ? bookid.toString()
                          : randTitle[index].tripitaka91Book.toString(),
                      randTitle.isEmpty
                          ? pageids
                          : randTitle[index].tripitaka91Page,
                      randTitle.isEmpty
                          ? bookLine.toString()
                          : randTitle[index].tripitaka91Line.toString(),
                      randTitle.isEmpty
                          ? "FALSE"
                          : randTitle[index].tripitaka91Mark,
                      randTitle.isEmpty ? 0 : randTitle[index].tripitaka91Code,
                      randTitle.isEmpty ? 0 : randTitle[index].tripitaka91No,
                      false,
                    );
                  },
                ),
              ),
        pageview(false, false),
      ],
    );
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget titleCardSub(
      String triTitle,
      String bookBlue,
      String bookRed,
      String bookIds,
      int pageId,
      String bookLine,
      String mark,
      double noTitleCate,
      int noTitle,
      bool isMobile) {
    String wordSearch = widget.chkSearch;
    RegExp regex = RegExp(r'\s+');
    List<String> outputList = wordSearch.split(regex);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Card(
        margin: const EdgeInsets.all(5),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              onTap: () {
                if (isMobile) Navigator.of(context).pop();
                setState(() {
                  audioPlayerManager.stop();
                  audioPlayerManagerTitle.stop();
                  currentPlaylist.clear();
                  tribookline = int.parse(bookLine);
                  pageids = pageId;
                  pageChanged = pageId.toInt();
                  pageController.animateToPage(pageChanged,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.bounceInOut);
                  _currentSliderValue = pageId.toDouble();
                  triBookLineRead = tribookline;
                });
              },
              title: (mark == 'FALSE')
                  ? SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle: TextStyle(
                          letterSpacing: 0.2,
                          fontSize: isMobile ? 18.0 : 16.0,
                          color: Colors.black),
                    )
                  : SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle: TextStyle(
                          letterSpacing: 0.2,
                          fontSize: isMobile ? 18.0 : 16.0,
                          color: Colors.red),
                      textStyleHighlight: const TextStyle(color: Colors.black),
                    ),
              subtitle: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      LoadingDialog.show(context);
                      String txtTitle =
                          textReplacer.replaceText(triTitle, bookBlue);

                      String filename =
                          noTitleCate.toString().replaceAll('.', '');
                      filename =
                          '$filename-$noTitle-$bookIds-$pageId-$bookLine';
                      await audioPlayerManager.playAudio(
                          '1', filename, txtTitle);
                      // ignore: use_build_context_synchronously
                      LoadingDialog.hide(context);
                    },
                    child: Icon(
                      Icons.volume_up,
                      size: isMobile ? 25 : 20,
                      color: Colors.blue[300], // Change color as needed
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      String txtTitle =
                          textReplacer.replaceText(triTitle, bookBlue);
                      txtTitle +=
                          'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                      await Share.share(
                          '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm',
                          subject: 'สรุปหัวข้อธรรมจากพระไตรปิฎก');
                    },
                    child: Icon(
                      Icons.share,
                      size: isMobile ? 21 : 16,
                      color: Colors.blue[300], // Change color as needed
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      String txtTitle =
                          textReplacer.replaceText(triTitle, bookBlue);
                      txtTitle +=
                          'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                      Clipboard.setData(
                        ClipboardData(
                            text:
                                '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm'),
                      );
                      _showSnackbar(context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                    },
                    child: Icon(
                      Icons.copy,
                      size: isMobile ? 21 : 16,
                      color: Colors.blue[300], // Change color as needed
                    ),
                  ),
                  (users != null) && (users?.levelAccess == '1')
                      ? const SizedBox(width: 10)
                      : const SizedBox.shrink(),
                  (users != null) && (users?.levelAccess == '1')
                      ? InkWell(
                          onTap: () async {
                            _showInputDialog(
                              context,
                              triTitle,
                              noTitle.toString(),
                              noTitleCate.toString(),
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            size: isMobile ? 21 : 16,
                            color: Colors.blue[300],
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void chkLoginStatus(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPageDialog(),
        )).then((value) {
      if (value != null && value == true) {
        // หลังจากกลับมาจาก NextPage และค่าที่ส่งกลับมาคือ true
        // ทำสิ่งที่คุณต้องการทำต่อได้ที่นี่
        // print('Returned with true');
        setState(() {
          _getUser();
        });
      }
    });

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return SizedBox.expand(
    //       child: AlertDialog(
    //         shape: const RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(32.0))),
    //         contentPadding: const EdgeInsets.only(top: 10.0),
    //         backgroundColor: Colors.white,
    //         title: const Text('เข้าสู่ระบบ'),
    //         content: const LoginPageDialog(),
    //         actions: <Widget>[
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: const Text('ปิดหน้าจอ'),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // ).then((value) {
    //   if (value == true) {
    //     // อัปเดตตัวแปร users หรือ refresh หน้าจอ
    //     _getUser();
    //   }
    // });
  }

  Widget pageview(bool isMobile, bool isTable) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              pageChanged == 0
                  ? const Text('')
                  : IconButton(
                      tooltip: 'อ่านออกเสียง',
                      icon: const Icon(Icons.volume_up),
                      color: TColors.secondary,
                      onPressed: () async {
                        if (currentPlaylist.isNotEmpty) {
                          LoadingDialog.show(context);
                          currentPlaylist.clear();
                          String txtDetail = '';
                          triBookLineRead = 1;
                          String filename = '${widget.triBookid}-$pageids-1';
                          if (bookTri91.isNotEmpty) {
                            if (bookTri91[0].bookPages != pageChanged) {
                              LoadingDialog.hide(context);
                              _showSnackbar(
                                  context, 'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง');
                              setState(() {});
                              return;
                            }
                            triBookLineRead = 1;
                            filename =
                                '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-1';

                            for (var book in bookTri91) {
                              if (book.bookLines != 0) {
                                if (book.bookPages == pageids) {
                                  if (book.bookLines >= tribookline) {
                                    String modifiedBookDetail = book.bookDetail
                                        .trimRight()
                                        .replaceAll('.', '');
                                    txtDetail += modifiedBookDetail;
                                    filename =
                                        '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-$tribookline';
                                  }
                                } else {
                                  String modifiedBookDetail = book.bookDetail
                                      .trimRight()
                                      .replaceAll('.', '');
                                  txtDetail += modifiedBookDetail;
                                }
                              }
                            }

                            currentPlaylist.add(txtDetail);
                            await audioPlayerManager.playAudio(
                                '0', filename, txtDetail);
                          }
                          // ignore: use_build_context_synchronously
                          LoadingDialog.hide(context);
                        } else {
                          LoadingDialog.show(context);
                          currentPlaylist.clear();
                          String txtDetail = '';
                          triBookLineRead = 1;
                          String filename = '${widget.triBookid}-$pageids-1';
                          if (bookTri91.isNotEmpty) {
                            if (bookTri91[0].bookPages != pageChanged) {
                              LoadingDialog.hide(context);
                              _showSnackbar(
                                  context, 'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง');
                              setState(() {});
                              return;
                            }
                            triBookLineRead = 1;
                            filename =
                                '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-1';

                            for (var book in bookTri91) {
                              if (book.bookLines != 0) {
                                if (book.bookPages == pageids) {
                                  if (book.bookLines >= tribookline) {
                                    String modifiedBookDetail = book.bookDetail
                                        .trimRight()
                                        .replaceAll('.', '');
                                    txtDetail += modifiedBookDetail;
                                    triBookLineRead = tribookline;
                                    filename =
                                        '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-$tribookline';
                                  }
                                } else {
                                  String modifiedBookDetail = book.bookDetail
                                      .trimRight()
                                      .replaceAll('.', '');
                                  txtDetail += modifiedBookDetail;
                                }
                              }
                            }
                            currentPlaylist.add(txtDetail);
                            setState(() {});
                            await audioPlayerManager.playAudio(
                                '0', filename, txtDetail);
                          }
                          // ignore: use_build_context_synchronously
                          LoadingDialog.hide(context);
                        }
                      },
                    ),
              pageChanged == 0
                  ? const ATextLabelMedium(text: '   หน้า')
                  : const Text(''),
              pageChanged == 0
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          bottom: 13, // ระยะห่างจากด้านล่าง
                          child: Text(
                            '1',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.circle_outlined),
                          onPressed: () async {
                            audioPlayerManager.pause();
                            setState(() {
                              if (audioPlayerManager.chkStatePlay()) {
                                audioPlayerManager.stop();
                              }
                            });
                            String filename = '0-1-1';
                            String txtDetail = 'คำนำ1';
                            await audioPlayerManager.playAudio(
                                '0', filename, txtDetail);
                          },
                        ),
                      ],
                    )
                  : const Text(''),
              pageChanged == 0
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          bottom: 13, // ระยะห่างจากด้านล่าง
                          child: Text(
                            '2',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.circle_outlined),
                          onPressed: () async {
                            audioPlayerManager.pause();
                            setState(() {
                              if (audioPlayerManager.chkStatePlay()) {
                                audioPlayerManager.stop();
                              }
                            });
                            String filename = '0-1-2';
                            String txtDetail = 'คำนำ2';
                            await audioPlayerManager.playAudio(
                                '0', filename, txtDetail);
                          },
                        ),
                      ],
                    )
                  : const Text(''),
              pageChanged == 0
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          bottom: 13, // ระยะห่างจากด้านล่าง
                          child: Text(
                            '3',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.circle_outlined),
                          onPressed: () async {
                            audioPlayerManager.pause();
                            setState(() {
                              if (audioPlayerManager.chkStatePlay()) {
                                audioPlayerManager.stop();
                              }
                            });
                            String filename = '0-1-3';
                            String txtDetail = 'คำนำ3';
                            await audioPlayerManager.playAudio(
                                '0', filename, txtDetail);
                          },
                        ),
                      ],
                    )
                  : const Text(''),
              pageChanged == 0
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          bottom: 13, // ระยะห่างจากด้านล่าง
                          child: Text(
                            '4',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.circle_outlined),
                          onPressed: () async {
                            audioPlayerManager.pause();
                            setState(() {
                              if (audioPlayerManager.chkStatePlay()) {
                                audioPlayerManager.stop();
                              }
                            });
                            String filename = '0-1-4';
                            String txtDetail = 'คำนำ4';
                            await audioPlayerManager.playAudio(
                                '0', filename, txtDetail);
                          },
                        ),
                      ],
                    )
                  : const Text(''),
              pageChanged == 0
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          bottom: 13, // ระยะห่างจากด้านล่าง
                          child: Text(
                            '5',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.circle_outlined),
                          onPressed: () async {
                            audioPlayerManager.pause();
                            setState(() {
                              if (audioPlayerManager.chkStatePlay()) {
                                audioPlayerManager.stop();
                              }
                            });
                            String filename = '0-1-5';
                            String txtDetail = 'คำนำ5';
                            await audioPlayerManager.playAudio(
                                '0', filename, txtDetail);
                          },
                        ),
                      ],
                    )
                  : const Text(''),
              pageChanged == 0
                  ? IconButton(
                      tooltip: 'หยุดชั่วคราว',
                      icon: const Icon(Icons.pause),
                      onPressed: () {
                        audioPlayerManager.pause();
                      },
                    )
                  : currentPlaylist.isEmpty
                      ? const Icon(
                          Icons.stop,
                          color: Colors.grey,
                        )
                      : IconButton(
                          tooltip: 'หยุดชั่วคราว',
                          icon: const Icon(Icons.pause),
                          onPressed: () {
                            audioPlayerManager.pause();
                          },
                        ),
              const Expanded(
                child: Text(''),
              ),
              pageChanged == 0
                  ? const Text('')
                  : isMobile
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.blue),
                            ),
                            child: const ATextDiskplaySmall(
                                text: 'สารบัญหัวข้อธรรม'),
                            onPressed: () {
                              _showDialogTitle(context, true);
                            },
                          ),
                        )
                      : const Text(''),
              pageChanged == 0
                  ? const Text('')
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.blue),
                        ),
                        child: const ATextDiskplaySmall(text: 'พจนานุกรม'),
                        onPressed: () async {
                          if (bookTri91.isNotEmpty) {
                            // print(
                            //     'bookPageds ${bookTri91[0].bookPages} pageChanged : $pageChanged');
                            if (bookTri91[0].bookPages != pageChanged) {
                              // LoadingDialog.hide(context);
                              _showSnackbar(
                                  context, 'กรุณากดปุ่มพจนานุกรมอีกครั้ง');
                              return;
                            }

                            String dictTmp = '';
                            for (var book in bookTri91) {
                              dictTmp += '${book.bookDict!},';
                            }

                            if (dictTmp.isNotEmpty) {
                              dictTmp =
                                  dictTmp.substring(0, dictTmp.length - 1);
                              uniqueItems = removeDuplicatesAndDash(dictTmp);
                              uniqueItems
                                  .sort((a, b) => a.length.compareTo(b.length));

                              String result = uniqueItems.join(',');

                              _showDialogDict(context, result, isMobile);
                            } else {
                              _showSnackbar(context, 'ไม่พบข้อมูลคำศัพท์');
                            }

                            // toggleDrawer();
                          }
                        },
                      ),
                    ),
            ],
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width - 20.0,
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              // child: showPageView(bookid.toString()),
              child: numPageAll == 1
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PageView.builder(
                      // scrollDirection: Axis.vertical,
                      pageSnapping: true,
                      clipBehavior: Clip.none,
                      physics: const BouncingScrollPhysics(),
                      controller: pageController,
                      itemCount: numPageAll + 1,
                      onPageChanged: (index) {
                        setState(() {
                          audioPlayerManagerTitle.stop();
                          audioPlayerManager.stop();
                          currentPlaylist.clear();
                          pageChanged = index;
                          _currentSliderValue = index + 1;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          child: showPage(
                              index.toString(), tribookline, isMobile, isTable),
                        );
                      },
                    ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (pageChanged > 0) {
                    audioPlayerManager.stop();
                    audioPlayerManagerTitle.stop();
                    currentPlaylist.clear();
                    pageController.animateToPage(
                      --pageChanged,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.bounceInOut,
                    );
                  }
                },
              ),
              Expanded(
                child: Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: numPageAll + 1,
                  divisions: numPageAll + 1,
                  label: _currentSliderValue.round() == 0
                      ? 'คำนำ'
                      : _currentSliderValue
                          .round()
                          .toString(), // แสดง 'คำนำ' ถ้าเป็นหน้า 0
                  onChanged: (double value) {
                    setState(
                      () {
                        audioPlayerManager.stop();
                        audioPlayerManagerTitle.stop();
                        currentPlaylist.clear();
                        if (value > numPageAll) {
                          value--;
                        }
                        pageChanged = value.toInt();
                        pageController.animateToPage(value.toInt(),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.bounceInOut);
                        _currentSliderValue = value;
                      },
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  //print('pageChanged:$pageChanged numPageAll$numPageAll');
                  if (pageChanged < (numPageAll)) {
                    audioPlayerManager.stop();
                    audioPlayerManagerTitle.stop();
                    currentPlaylist.clear();
                    pageController.animateToPage(
                      ++pageChanged,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.bounceInOut,
                    );
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: ATextTitleMedium(
                    text: 'หน้า ${pageChanged.toString()}/$numPageAll'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showPage(String pageShow, int triLine, bool isMobile, bool isTable) {
    return FutureBuilder<List<BookTri91>?>(
      future: RemoteServiceBookTri91Html()
          .getBookTri91(widget.triBookid.toString(), pageShow, tSecretAPIKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: ATextTitleMedium(text: 'Error: ${snapshot.error}'),
          );
        } else {
          // สร้าง Container เพื่อแสดงข้อมูล
          bookTri91 = snapshot.data ?? [];
          String keyword_ = widget.chkSearch.replaceAll(" ", "%");

          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                  url: WebUri(int.parse(pageShow) == pageids
                      ? widget.chkSearch != ''
                          ? 'https://news.tripitaka91.com/tripitaka91_app.php?book=${widget.triBookid}&page=$pageShow&line=$tribookline&keyword=$keyword_'
                          : 'https://news.tripitaka91.com/tripitaka91_app.php?book=${widget.triBookid}&page=$pageShow&line=$tribookline'
                      : widget.chkSearch != ''
                          ? 'https://news.tripitaka91.com/tripitaka91_app.php?book=${widget.triBookid}&page=$pageShow&keyword=$keyword_'
                          : 'https://news.tripitaka91.com/tripitaka91_app.php?book=${widget.triBookid}&page=$pageShow')),
            ),
          );
        }
      },
    );
  }
}
