import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/db_helper/json_book_0.dart';
import 'package:tripitaka91/utils/img_service/shared_image_generator.dart';
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

class Tri91PageViewHtml extends StatefulWidget {
  final String triBookid;
  final int triPageid;
  final String triBookline;
  final String chkSearch;
  final bool isMobile;
  final bool online;

  const Tri91PageViewHtml({
    super.key,
    required this.triBookid,
    required this.triPageid,
    required this.triBookline,
    required this.chkSearch,
    required this.isMobile,
    required this.online,
  });

  @override
  State<Tri91PageViewHtml> createState() => _Tri91PageViewHtmlState();
}

class _Tri91PageViewHtmlState extends State<Tri91PageViewHtml> {
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
  late int bookid = int.parse(widget.triBookid);
  late int pageids = widget.triPageid;
  late bool online = widget.online;
  late int bookLine = 1;
  late String bookTitleTri91 = '';
  late int tribookline = 0;
  late String txtShowEmpty = 'โหลดข้อมูล...';
  final ScrollController _scrollControllerListTitle = ScrollController();
  final ScrollController _scrollController = ScrollController();

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
  bool loadFirst = true;
  late Timer _timer;
  int triBookLineRead = 1;
  bool chkTimer = false;
  bool chkTimer2 = false;
  late InAppWebViewController webViewController;

  final SharedImageGenerator sharedImageGenerator = SharedImageGenerator();
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
    chkTimer = true;
  }

  void _onTimerFinished() {
    if (mounted) {
      double midpoint = _scrollController.position.maxScrollExtent / 2;
      double onepoint = _scrollController.position.maxScrollExtent / 4;
      double position1 = _scrollController.position.minScrollExtent;
      double position2 = _scrollController.position.minScrollExtent + onepoint;
      double position3 =
          _scrollController.position.minScrollExtent + (onepoint * 2);
      double position4 = _scrollController.position.maxScrollExtent;

      int line = int.parse(widget.triBookline);
      if (widget.isMobile) {
        if (line < 6) {
          midpoint = position1;
          if (line > 3) {
            midpoint = position1 + (onepoint / 2);
          }
        } else if (line < 12) {
          midpoint = position2;
          if (line > 9) {
            midpoint = position2 + (onepoint / 2);
          }
        } else if (line < 18) {
          midpoint = position3;
          if (line > 15) {
            midpoint = position3 + (onepoint / 2);
          }
        } else {
          midpoint = position4;
        }
      } else {
        if (line < 5) {
          midpoint = position1;
        } else if (line < 9) {
          midpoint = position2;
        } else if (line < 17) {
          midpoint = position3;
        } else {
          midpoint = position4;
        }
      }

      if ((_scrollController.positions.isNotEmpty) &&
          (_scrollController.hasClients)) {
        _scrollController.animateTo(
          midpoint,
          duration:
              const Duration(milliseconds: 500), // หรือค่าอื่น ๆ ตามต้องการ
          curve: Curves.easeOut, // หรือค่าอื่น ๆ ตามต้องการ
        );
      }
    }
  }

  void _onTimerFinished2() {
    if (mounted) {
      double midpoint = _scrollController.position.maxScrollExtent / 2;
      double onepoint = _scrollController.position.maxScrollExtent / 4;
      double position1 = _scrollController.position.minScrollExtent;
      double position2 = _scrollController.position.minScrollExtent + onepoint;
      double position3 =
          _scrollController.position.minScrollExtent + (onepoint * 2);
      double position4 = _scrollController.position.maxScrollExtent;

      int line = triBookLineRead;
      if (widget.isMobile) {
        if (line < 6) {
          midpoint = position1;
          if (line > 3) {
            midpoint = position1 + (onepoint / 2);
          }
        } else if (line < 12) {
          midpoint = position2;
          if (line > 9) {
            midpoint = position2 + (onepoint / 2);
          }
        } else if (line < 18) {
          midpoint = position3;
          if (line > 15) {
            midpoint = position3 + (onepoint / 2);
          }
        } else {
          midpoint = position4;
        }
      } else {
        if (line < 5) {
          midpoint = position1;
        } else if (line < 9) {
          midpoint = position2;
        } else if (line < 17) {
          midpoint = position3;
        } else {
          midpoint = position4;
        }
      }

      if ((_scrollController.positions.isNotEmpty) &&
          (_scrollController.hasClients)) {
        _scrollController.animateTo(
          midpoint,
          duration:
              const Duration(milliseconds: 500), // หรือค่าอื่น ๆ ตามต้องการ
          curve: Curves.easeOut, // หรือค่าอื่น ๆ ตามต้องการ
        );
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    saveLastRead();
    audioPlayerManager.dispose();
    audioPlayerManagerTitle.dispose();
    super.dispose();
  }

  Future<void> _getUser() async {
    users = await getUsersList();
  }

  void saveLastRead() async {
    online
        ? await saveBookAccessList(int.parse(widget.triBookid), pageChanged)
        : await dbHelper.saveBookOpenLast(
            int.parse(widget.triBookid), pageChanged);
  }

  Future<void> _getLogEdit() async {
    try {
      logEdit = widget.online
          ? await RemoteServiceLogEdit()
                  .getLogEdit(widget.triBookid, tSecretAPIKey) ??
              []
          : [];
    } catch (e) {
      // ignore: avoid_print
      print('Error occurred: $e');
    }
  }

  void getBookTri91All() async {
    try {
      tri91BookAll = (widget.online
          ? await RemoteServiceBookTri91All()
                  .getBookTri91All(widget.triBookid, tSecretAPIKey) ??
              []
          : await dbHelper.getBookTri91All(widget.triBookid))!;
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
      randTitle = (widget.online
          ? await RemoteServiceTitle()
                  .getTitle(widget.triBookid, tSecretAPIKey) ??
              []
          : await dbHelper.getTitle(widget.triBookid))!;

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
          future:
              widget.online ? _fetchDataDict(result) : _fetchDataDictDB(result),
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
                                    widget.online
                                        ? InkWell(
                                            onTap: () async {
                                              LoadingDialog.show(context);
                                              String txtTitle =
                                                  '${textTitleReplace.getWordDict(dataDict[index])} - ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                                              String namesave = textTitleReplace
                                                  .getWordDict(dataDict[index])
                                                  .trim()
                                                  .replaceAll(
                                                      RegExp(r'\s+'), '');

                                              String filename =
                                                  'dict-$namesave';
                                              await audioPlayerManager
                                                  .playAudio(
                                                      '3', filename, txtTitle);
                                              // ignore: use_build_context_synchronously
                                              LoadingDialog.hide(context);
                                            },
                                            child: Icon(
                                              Icons.volume_up,
                                              size: isM ? 25 : 20,
                                              color: Colors.blue[300],
                                            ),
                                          )
                                        : const Text(''),
                                    widget.online
                                        ? const SizedBox(width: 10)
                                        : const SizedBox.shrink(),
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

  Future<void> _fetchDataDictDB(String result) async {
    // ดึงข้อมูลผู้ใช้

    // ดึงข้อมูลจาก SQLite
    List<String> newData = await dbHelper.fetchDataDict(result);

    if (newData.isNotEmpty && newData[0] != 'ไม่พบข้อมูล') {
      dataDict.clear();
      dataDict.addAll(newData);
    } else {
      // ถ้าไม่พบข้อมูล ให้แสดง Snackbar แจ้งเตือน
      // ignore: use_build_context_synchronously
      _showSnackbar(context, 'ไม่พบข้อมูลสำหรับคำค้นหา: $result');
    }
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
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

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
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

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
          // buildBody(),
          // AnimatedDrawer(
          //   isDrawerOpen: isDrawerOpen,
          //   onToggleDrawer: toggleDrawer,
          //   isWidth: 350,
          //   pages: pageChanged.toString(),
          // ),
        ],
      ),
      //bottomNavigationBar: buildBottomAppBar(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: ATextDiskplayMedium(text: '(เล่ม $bookid) $bookTitleTri91'),
      actions: [
        InkWell(
          onTap: () async {
            String tmpLine = '1';
            if (pageChanged == pageids) {
              tmpLine = tribookline.toString();
            }
            await Clipboard.setData(
              ClipboardData(
                  text:
                      '$tURLmain${widget.triBookid}-$pageChanged-$tmpLine.htm'),
            );
            // ignore: use_build_context_synchronously
            _showSnackbar(context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
          },
          child: Icon(
            Icons.copy,
            size: widget.isMobile ? 25 : 18,
            color: Colors.white, // Change color as needed
          ),
        ),
        const Text('   '),
        InkWell(
          onTap: () async {
            String tmpLine = '1';
            if (pageChanged == pageids) {
              tmpLine = tribookline.toString();
            }
            await Share.share(
                '$tURLmain${widget.triBookid}-$pageChanged-$tmpLine.htm',
                subject: 'พระไตรปิฎก');
          },
          child: Icon(
            Icons.share,
            size: widget.isMobile ? 25 : 18,
            color: Colors.white, // Change color as needed
          ),
        ),
        const Text('   '),
        widget.online
            ? PopupMenuButton(
                icon: const Icon(
                  color: TColors.white,
                  Icons.edit,
                ),
                onSelected: (value) {
                  if (value == 'item1') {
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
                  } else if (value == 'item3') {
                    if (users != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(5),
                            title:
                                const Text('ยืนยันคำที่น่าจะผิดคำที่น่าจะถูก'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ShowCorrectSaveWithPage(
                                bookid: widget.triBookid,
                                pageid: pageChanged.toString(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _getLogEdit();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('ปิด'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // String mgr = 'กรุณาเข้าสู่ระบบก่อน';
                      chkLoginStatus(context);
                    }
                  } else if (value == 'item2') {
                    if (users != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(5),
                            title: const Text('แจ้งการอ่านออกเสียง'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: EditSpeakScreen(
                                comments: 'เล่ม $bookid หน้า $pageChanged',
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('ปิดหน้าจอ'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // String mgr = 'กรุณาเข้าสู่ระบบก่อน';
                      chkLoginStatus(context);
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  const PopupMenuItem(
                    value: 'item1',
                    child: Text('แจ้งคำผิดคำถูก'),
                  ),
                  const PopupMenuItem(
                    value: 'item3',
                    child: Text('ยืนยันการแก้ไขคำผิดคำถูก'),
                  ),
                  const PopupMenuItem(
                    value: 'item2',
                    child: Text('แจ้งการอ่านออกเสียง'),
                  ),
                ],
              )
            : const SizedBox.shrink()
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
                  chkTimer2 = true;
                });
              },
              title: (mark == 'FALSE')
                  ? SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle: TextStyle(
                          fontSize: isMobile ? 18.0 : 16.0,
                          color: Colors.black),
                    )
                  : SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle: TextStyle(
                          fontSize: isMobile ? 18.0 : 16.0, color: Colors.red),
                      textStyleHighlight: const TextStyle(color: Colors.black),
                    ),
              subtitle: Row(
                children: [
                  widget.online
                      ? InkWell(
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
                        )
                      : const Text(''),
                  widget.online
                      ? const SizedBox(width: 10)
                      : const SizedBox.shrink(),
                  InkWell(
                    onTap: () async {
                      String txtTitle =
                          textReplacer.replaceText(triTitle, bookBlue);
                      // txtTitle +=
                      //     'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                      // await Share.share(
                      //     '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm',
                      //     subject: 'สรุปหัวข้อธรรมจากพระไตรปิฎก');

                      sharedImageGenerator.generateAndShare(
                        context: context,
                        bookTitle: txtTitle,
                        bookid: bookIds,
                        pageid: pageId.toString(),
                        lineid: bookLine,
                        bookBlue: bookBlue,
                        bookRed: bookRed,
                      );
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox.expand(
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: const EdgeInsets.only(top: 10.0),
            backgroundColor: Colors.white,
            title: const Text('เข้าสู่ระบบ'),
            content: const LoginPageDialog(),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('ปิดหน้าจอ'),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value == true) {
        // อัปเดตตัวแปร users หรือ refresh หน้าจอ
        _getUser();
      }
    });
  }

  Widget pageview(bool isMobile, bool isTable) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              widget.online
                  ? pageChanged == 0
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
                              String filename =
                                  '${widget.triBookid}-$pageids-1';
                              if (bookTri91.isNotEmpty) {
                                if (bookTri91[0].bookPages != pageChanged) {
                                  LoadingDialog.hide(context);
                                  _showSnackbar(context,
                                      'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง');
                                  setState(() {
                                    chkTimer2 = true;
                                  });
                                  return;
                                }
                                triBookLineRead = 1;
                                filename =
                                    '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-1';

                                for (var book in bookTri91) {
                                  if (book.bookLines != 0) {
                                    if (book.bookPages == pageids) {
                                      if (book.bookLines >= tribookline) {
                                        String modifiedBookDetail = book
                                            .bookDetail
                                            .trimRight()
                                            .replaceAll('.', '');
                                        txtDetail += modifiedBookDetail;
                                        filename =
                                            '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-$tribookline';
                                      }
                                    } else {
                                      String modifiedBookDetail = book
                                          .bookDetail
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
                              String filename =
                                  '${widget.triBookid}-$pageids-1';
                              if (bookTri91.isNotEmpty) {
                                if (bookTri91[0].bookPages != pageChanged) {
                                  LoadingDialog.hide(context);
                                  _showSnackbar(context,
                                      'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง');
                                  setState(() {
                                    chkTimer2 = true;
                                  });
                                  return;
                                }
                                triBookLineRead = 1;
                                filename =
                                    '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-1';

                                for (var book in bookTri91) {
                                  if (book.bookLines != 0) {
                                    if (book.bookPages == pageids) {
                                      if (book.bookLines >= tribookline) {
                                        String modifiedBookDetail = book
                                            .bookDetail
                                            .trimRight()
                                            .replaceAll('.', '');
                                        txtDetail += modifiedBookDetail;
                                        triBookLineRead = tribookline;
                                        filename =
                                            '${bookTri91[0].bookId}-${bookTri91[0].bookPages}-$tribookline';
                                      }
                                    } else {
                                      String modifiedBookDetail = book
                                          .bookDetail
                                          .trimRight()
                                          .replaceAll('.', '');
                                      txtDetail += modifiedBookDetail;
                                    }
                                  }
                                }
                                currentPlaylist.add(txtDetail);
                                setState(() {
                                  chkTimer2 = true;
                                });
                                await audioPlayerManager.playAudio(
                                    '0', filename, txtDetail);
                              }
                              // ignore: use_build_context_synchronously
                              LoadingDialog.hide(context);
                            }
                          },
                        )
                  : const Text(''),
              widget.online
                  ? pageChanged == 0
                      ? const ATextLabelMedium(text: '   หน้า')
                      : const Text('')
                  : const Text(''),
              widget.online
                  ? pageChanged == 0
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
                      : const Text('')
                  : const Text(''),
              widget.online
                  ? pageChanged == 0
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
                      : const Text('')
                  : const Text(''),
              widget.online
                  ? pageChanged == 0
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
                      : const Text('')
                  : const Text(''),
              widget.online
                  ? pageChanged == 0
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
                      : const Text('')
                  : const Text(''),
              widget.online
                  ? pageChanged == 0
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
                      : const Text('')
                  : const Text(''),
              widget.online
                  ? pageChanged == 0
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
                            )
                  : const Text(''),
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
                                  MaterialStateProperty.all<Color>(Colors.blue),
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
                              MaterialStateProperty.all<Color>(Colors.blue),
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
                              setState(() {});
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
    if (loadFirst) {
      _getLogEdit();
      loadFirst = false;
    }

    return FutureBuilder<List<BookTri91>?>(
      future: widget.online
          ? RemoteServiceBookTri91().getBookTri91(
              widget.triBookid.toString(), pageShow, tSecretAPIKey)
          : dbHelper.getBookTri91(widget.triBookid, pageShow),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: ATextTitleMedium(text: 'Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (int.parse(pageShow) == 0) {
            List<dynamic> bookList = json.decode(jsonBookString);
            String htmlContent, snapText;
            htmlContent = """
<body>
<span style='font-weight:800;'></span>
""";

            for (int i = 0; i < bookList.length; i++) {
              snapText = bookList[i]['book_detail']
                  .toString()
                  .replaceAll('LineNull', '&nbsp;');
              snapText = snapText.replaceAll('     ', '&nbsp;');
              snapText = snapText.replaceAll('    ', '&nbsp;');
              snapText = snapText.replaceAll('   ', '&nbsp;');
              snapText = snapText.replaceAll('  ', '&nbsp;');
              snapText = snapText.replaceAll(' ', '&nbsp;');
              snapText = snapText.replaceAll('<  /B>', '');
              snapText = snapText.replaceAll('<  /SUP>', '');
              snapText = snapText.replaceAll('<  /SUP>', '');
              snapText = snapText.replaceAll('<  /H1>', '');
              snapText = snapText.replaceAll('<  /H2>', '');
              snapText = snapText.replaceAll('< /B>', '');
              snapText = snapText.replaceAll('< /H1>', '');
              snapText = snapText.replaceAll('< /H2>', '');
              snapText = snapText.replaceAll('<ฺฺB>', '');
              snapText = snapText.replaceAll('<ฺฺ/B>', '');
              snapText = snapText.replaceAll('</็H2>', '');
              snapText = snapText.replaceAll('<H/1>', '');
              snapText = snapText.replaceAll('</H2 >', '');
              snapText = snapText.replaceAll('</3 1>', '');
              snapText = snapText.replaceAll('</SUP', '');
              snapText = snapText.replaceAll('/SUP>', '');
              snapText = snapText.replaceAll('SUP>', '');
              snapText = snapText.replaceAll('</H >', '');
              snapText = snapText.replaceAll('/B>', '');
              snapText = snapText.replaceAll('</H4', '');
              snapText = snapText.replaceAll('</H3', '');
              snapText = snapText.replaceAll('</H2', '');
              snapText = snapText.replaceAll('</H1', '');
              snapText = snapText.replaceAll('</I', '');
              snapText = snapText.replaceAll('</B', '');
              snapText = snapText.replaceAll('H1>', '');
              snapText = snapText.replaceAll('B>', '');
              snapText = snapText.replaceAll('</', '');
              snapText = snapText.replaceAll('<', '');
              snapText = snapText.replaceAll('>', '');

              htmlContent = """$htmlContent<p>$snapText</p>
""";
            }

            htmlContent = """$htmlContent</body>
""";

            // or use HTML.toRichText()
            final TextSpan textSpan = HTML.toTextSpan(
              context,
              htmlContent,
              linksCallback: (dynamic link) {},
              // as name suggests, optionally set the default text style
              defaultTextStyle: TextStyle(
                  letterSpacing: 0.4,
                  color: HexColor('#475859'), //Colors.grey[700],
                  decoration: TextDecoration.none,
                  fontFamily: "THSarabunNew",
                  fontSize: 28),
              overrideStyle: <String, TextStyle>{
                'span': isMobile
                    ? const TextStyle(fontSize: 28)
                    : const TextStyle(fontSize: 26), //isMobile
                // ? const TextStyle(fontSize: 22)
                // : isTable
                //     ? const TextStyle(fontSize: 23)
                //     : const TextStyle(fontSize: 24),
                'p': isMobile
                    ? const TextStyle(fontSize: 28)
                    : const TextStyle(fontSize: 26),
                // : isTable
                //     ? const TextStyle(fontSize: 25)
                //     : const TextStyle(fontSize: 26),
                'a': const TextStyle(
                  fontSize: 26,
                  color: Color(0XFFd58512),
                  letterSpacing: 0,
                  decoration: TextDecoration.none,
                ),
                // specify any tag not just the supported ones,
                // and apply TextStyles to them and/override them
              },
            );

            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SelectableText.rich(
                  textSpan,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: -0.8),
                ),
              ),
            );
          } else {
            return const Center(
              child: ATextTitleMedium(
                  text: 'No data found'), // เพิ่มข้อความเมื่อไม่มีข้อมูล
            );
          }
        } else {
          // ใช้ snapshot.data! ที่ไม่เป็น null ได้อย่างปลอดภัย
          bookTri91 = snapshot.data!; // ใช้ ! เพราะมีการตรวจสอบแล้ว
          int targetPage = int.parse(pageShow);

          List<Logedit> result = logEdit
              .where((log) => log.tripitaka91Page == targetPage)
              .toList();

          String title = bookTitleTri91;
          String page = pageShow;
          String htmlContent, snapText;
          int triPage = int.parse(pageShow);
          if (triPage == 0) {
            htmlContent = """
<body>
<span style='font-weight:800;'></span>
""";
          } else {
            htmlContent = """
<body>
<span style='font-weight:800;'> $title หน้าที่ $page</span><br>
""";
          }

          for (int i = 0; i < snapshot.data!.length; i++) {
            snapText = snapshot.data![i].bookDetail
                .toString()
                .replaceAll('LineNull', '&nbsp;');
            snapText = snapText.replaceAll('     ', '&nbsp;');
            snapText = snapText.replaceAll('    ', '&nbsp;');
            snapText = snapText.replaceAll('   ', '&nbsp;');
            snapText = snapText.replaceAll('  ', '&nbsp;');
            snapText = snapText.replaceAll(' ', '&nbsp;');
            snapText = snapText.replaceAll('<  /B>', '');
            snapText = snapText.replaceAll('<  /SUP>', '');
            snapText = snapText.replaceAll('<  /SUP>', '');
            snapText = snapText.replaceAll('<  /H1>', '');
            snapText = snapText.replaceAll('<  /H2>', '');
            snapText = snapText.replaceAll('< /B>', '');
            snapText = snapText.replaceAll('< /H1>', '');
            snapText = snapText.replaceAll('< /H2>', '');
            snapText = snapText.replaceAll('<ฺฺB>', '');
            snapText = snapText.replaceAll('<ฺฺ/B>', '');
            snapText = snapText.replaceAll('</็H2>', '');
            snapText = snapText.replaceAll('<H/1>', '');
            snapText = snapText.replaceAll('</H2 >', '');
            snapText = snapText.replaceAll('</3 1>', '');
            snapText = snapText.replaceAll('</SUP', '');
            snapText = snapText.replaceAll('/SUP>', '');
            snapText = snapText.replaceAll('SUP>', '');
            snapText = snapText.replaceAll('</H >', '');
            snapText = snapText.replaceAll('/B>', '');
            snapText = snapText.replaceAll('</H4', '');
            snapText = snapText.replaceAll('</H3', '');
            snapText = snapText.replaceAll('</H2', '');
            snapText = snapText.replaceAll('</H1', '');
            snapText = snapText.replaceAll('</I', '');
            snapText = snapText.replaceAll('</B', '');
            snapText = snapText.replaceAll('H1>', '');
            snapText = snapText.replaceAll('B>', '');
            snapText = snapText.replaceAll('</', '');
            snapText = snapText.replaceAll('<', '');
            snapText = snapText.replaceAll('>', '');

            List<String> findWord = widget.chkSearch.split(' ');
            if (findWord.isNotEmpty) {
              for (var x = 0; x < findWord.length; x++) {
                if (findWord[x] != '') {
                  String b;
                  if (triLine > 0) {
                    if (snapshot.data?[i].bookLines == (triLine)) {
                      // if ((this.bgColor == '#6b6b6e') ||
                      //     (this.bgColor == '#121212')) {
                      //   b = "<span style='color:yellow'>";
                      //   b = "$b${findWord[x]}</span>";
                      // } else {
                      if (int.parse(pageShow) == pageids) {
                        b = "<span style=color:black>";
                        b = "$b${findWord[x]}</span>";
                      } else {
                        b = "<span style=color:red>";
                        b = "$b${findWord[x]}</span>";
                      }
                      // }
                    } else {
                      // if ((this.bgColor == '#6b6b6e') ||
                      //     (this.bgColor == '#121212')) {
                      //   b = "<span style='color:orange'>";
                      //   b = "$b${findWord[x]}</span>";
                      // } else {
                      b = "<span style=color:red>";
                      b = "$b${findWord[x]}</span>";
                      // }
                    }
                    // print('b = ${b}');
                    // print('snapText = ${snapText}');
                    // print('findWord[x] = ${findWord[x]}');
                    snapText = snapText.replaceAll(findWord[x].toString(), b);
                  }
                }
              }
            }

            String logEdit = '';
            int chkComfirm = 2;
            int chkSuscess = 2;
            bool chkLogShow = false;
            String lineOld = '';
            String lineNew = '';
            for (Logedit log in result) {
              if (log.tripitaka91Line == snapshot.data?[i].bookLines) {
                String wordIncorrect = log.tripitaka91Wordincorrect;
                String wordCorrect = log.tripitaka91Wordcorrect;
                String nameid = log.firstNameid;
                String firestName = log.firstName;
                String lastName = log.lastName;
                lineOld = log.bookDetailOld;
                lineNew = log.bookDetailNew;
                String tmpLog =
                    'คำที่น่าจะผิด: [$wordIncorrect] คำที่น่าจะถูก: [$wordCorrect] แจ้งโดย: $nameid$firestName $lastName\n';
                logEdit = '$logEdit$tmpLog';
                chkComfirm = log.bookConfirm;
                chkSuscess = log.bookSuscess;
                chkLogShow = true;
              }
            }
            if (chkLogShow) {
              if (chkSuscess == 1) {
                logEdit =
                    '$logEdit \nหมายเหตุ: {มีการแก้ไขข้อมูลเรียบร้อยแล้ว}\nข้อความเดิม: $lineOld\nข้อความที่แก้ไข: $lineNew';
                if (logEdit != '') {
                  logEdit = '<a href="$logEdit">[*]</a> ';
                }
              } else if (chkSuscess == 0) {
                if (chkComfirm == 0) {
                  logEdit = '$logEdit \nหมายเหตุ: [ยังไม่มีการแก้ไข]';
                } else {
                  lineOld = lineOld.replaceAll('"', '');
                  lineNew = lineNew.replaceAll('"', '');
                  logEdit =
                      '$logEdit \nหมายเหตุ: [อยู่ในกระบวนการแก้ไขข้อมูล]\nข้อความเดิม: $lineOld\nข้อความที่แก้ไข: $lineNew';
                }
                if (logEdit != '') {
                  logEdit = '<a href="$logEdit">[*]</a> ';
                }
              }
            }

            if (int.parse(pageShow) == pageids) {
              if (snapshot.data?[i].bookLines == (triLine)) {
                htmlContent =
                    """$htmlContent<p style='background-color:#d58512;'>
""";
                snapText = """<span style=color:white>$snapText</span>""";
              } else {
                htmlContent = """$htmlContent<p>
""";
              }
            } else {
              htmlContent = """$htmlContent<p>
""";
            }

            htmlContent = """$htmlContent$logEdit$snapText</p>
""";
          }

          htmlContent = """$htmlContent</body>
""";

          // or use HTML.toRichText()
          final TextSpan textSpan = HTML.toTextSpan(
            context,
            htmlContent,
            linksCallback: (dynamic link) {
              List<TextSpan> getWordSpans(String text) {
                List<TextSpan> spans = [];
                RegExp expBrackets = RegExp(r'\[([^\]]+)\]');
                RegExp expCurlyBraces = RegExp(r'\{([^}]+)\}');
                Iterable<RegExpMatch> matchesBrackets =
                    expBrackets.allMatches(text);
                Iterable<RegExpMatch> matchesCurlyBraces =
                    expCurlyBraces.allMatches(text);

                int previousEnd = 0;
                for (RegExpMatch matchBrackets in matchesBrackets) {
                  // Add the text before the match
                  spans.add(TextSpan(
                      text: text.substring(previousEnd, matchBrackets.start)));
                  // Add the matched text with custom style (สีแดงสำหรับ [])
                  spans.add(
                    TextSpan(
                      text: matchBrackets.group(1),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  );
                  previousEnd = matchBrackets.end;
                }

                // เพิ่มการเช็คสำหรับข้อความที่อยู่ใน {}
                for (RegExpMatch matchCurlyBraces in matchesCurlyBraces) {
                  // Add the text before the match
                  spans.add(TextSpan(
                      text:
                          text.substring(previousEnd, matchCurlyBraces.start)));
                  // Add the matched text with custom style (สีเขียวสำหรับ {})
                  spans.add(
                    TextSpan(
                      text: matchCurlyBraces.group(1),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  );
                  previousEnd = matchCurlyBraces.end;
                }

                // Add the remaining text after the last match (เพิ่มข้อความที่เหลือหลังจากการตรวจสอบครั้งสุดท้าย)
                if (previousEnd < text.length) {
                  spans.add(TextSpan(text: text.substring(previousEnd)));
                }

                return spans;
              }

              if (link is String) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('รายงาน'),
                      content: RichText(
                        text: TextSpan(
                          children: getWordSpans(link),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ปิดหน้าจอ'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            // as name suggests, optionally set the default text style
            defaultTextStyle: TextStyle(
                letterSpacing: 0.4,
                color: HexColor('#475859'), //Colors.grey[700],
                decoration: TextDecoration.none,
                fontFamily: "THSarabunNew",
                fontSize: 28),
            overrideStyle: <String, TextStyle>{
              'span': isMobile
                  ? const TextStyle(fontSize: 28)
                  : const TextStyle(fontSize: 26), //isMobile
              // ? const TextStyle(fontSize: 22)
              // : isTable
              //     ? const TextStyle(fontSize: 23)
              //     : const TextStyle(fontSize: 24),
              'p': isMobile
                  ? const TextStyle(fontSize: 28)
                  : const TextStyle(fontSize: 26),
              // : isTable
              //     ? const TextStyle(fontSize: 25)
              //     : const TextStyle(fontSize: 26),
              'a': const TextStyle(
                fontSize: 26,
                color: Color(0XFFd58512),
                letterSpacing: 0,
                decoration: TextDecoration.none,
              ),
              // specify any tag not just the supported ones,
              // and apply TextStyles to them and/override them
            },
          );
          if (chkTimer) {
            _timer = Timer(const Duration(seconds: 1), _onTimerFinished);
            chkTimer = false;
          } else if (chkTimer2) {
            _timer = Timer(const Duration(seconds: 1), _onTimerFinished2);
            chkTimer2 = false;
          }
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: SelectableText.rich(
                textSpan,
                textAlign: TextAlign.center,
                style: const TextStyle(height: -0.8),
              ),
            ),
          );
        }
      },
    );
  }
}
