import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
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
import 'package:tripitaka91/widget/pageviews/pageviews_edit.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';

class Tri91PageView extends StatefulWidget {
  final String triBookid;
  final int triPageid;
  final String triBookline;
  final String chkSearch;

  const Tri91PageView({
    super.key,
    required this.triBookid,
    required this.triPageid,
    required this.triBookline,
    required this.chkSearch,
  });

  @override
  State<Tri91PageView> createState() => _Tri91PageViewState();
}

class _Tri91PageViewState extends State<Tri91PageView> {
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

  void _showDialogDict(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataDict(result),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                title: const Text('คำศัพท์ที่ตรวจพบในหน้านี้'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataDict.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              child: ATextDiskplayMedium(text: '${index + 1}'),
                            ),
                            title: ATextTitleMedium(
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
                                    size: 20,
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
                                        subject: 'พจนานุกรม ฉบับประมวลศัพท์');
                                  },
                                  child: Icon(
                                    Icons.share,
                                    size: 16,
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
                                    _showSnackbar(
                                        context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 16,
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

  void _showDialogTitle(BuildContext context, bool isM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              child: const Text('Close'),
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
        PopupMenuButton(
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
                  ),
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
                    return FractionallySizedBox(
                      widthFactor: 0.6,
                      heightFactor: 0.6,
                      child: SizedBox.expand(
                        child: AlertDialog(
                          backgroundColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('แจ้งการอ่านออกเสียง'),
                          content: EditSpeakScreen(
                            comments: 'เล่ม $bookid หน้า $pageChanged',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('ปิดหน้าจอ'),
                            ),
                          ],
                        ),
                      ),
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
              value: 'item2',
              child: Text('แจ้งการอ่านออกเสียง'),
            ),
          ],
        )
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
      borderRadius: BorderRadius.circular(30.0),
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                });
              },
              title: (mark == 'FALSE')
                  ? SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle:
                          const TextStyle(fontSize: 16.0, color: Colors.black),
                    )
                  : SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle:
                          const TextStyle(fontSize: 16.0, color: Colors.red),
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
                      size: 20,
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
                      size: 16,
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
                      size: 16,
                      color: Colors.blue[300], // Change color as needed
                    ),
                  ),
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
        return FractionallySizedBox(
          widthFactor: 0.6,
          heightFactor: 0.6,
          child: SizedBox.expand(
            child: AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.zero,
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
                          String filename = '${widget.triBookid}-$pageids-1';
                          if (bookTri91.isNotEmpty) {
                            if (bookTri91[0].bookPages != pageChanged) {
                              LoadingDialog.hide(context);
                              _showSnackbar(
                                  context, 'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง');
                              setState(() {});
                              return;
                            }
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
                          String filename = '${widget.triBookid}-$pageids-1';
                          if (bookTri91.isNotEmpty) {
                            if (bookTri91[0].bookPages != pageChanged) {
                              LoadingDialog.hide(context);
                              _showSnackbar(
                                  context, 'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง');
                              setState(() {});
                              return;
                            }
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
              isMobile
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        child:
                            const ATextDiskplaySmall(text: 'สารบัญหัวข้อธรรม'),
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

                              _showDialogDict(context, result);
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
      future: RemoteServiceBookTri91()
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
                      b = "<span style=color:red>";
                      b = "$b${findWord[x]}</span>";
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
                    """$htmlContent<p style='background-color:yellow;'>
""";
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
                color: HexColor('#475859'), //Colors.grey[700],
                decoration: TextDecoration.none,
                fontFamily: "THSarabunNew",
                fontSize: 28),
            overrideStyle: <String, TextStyle>{
              'span': const TextStyle(fontSize: 24), //isMobile
              // ? const TextStyle(fontSize: 22)
              // : isTable
              //     ? const TextStyle(fontSize: 23)
              //     : const TextStyle(fontSize: 24),
              'p': isMobile
                  ? const TextStyle(fontSize: 30)
                  : const TextStyle(fontSize: 26),
              // : isTable
              //     ? const TextStyle(fontSize: 25)
              //     : const TextStyle(fontSize: 26),
              'a': const TextStyle(
                fontSize: 26,
                color: Colors.red,
                letterSpacing: 0,
                decoration: TextDecoration.none,
              ),
              // specify any tag not just the supported ones,
              // and apply TextStyles to them and/override them
            },
          );

          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SelectableText.rich(
              textSpan,
              textAlign: TextAlign.center,
              style: const TextStyle(height: -0.8),
            ),
          );
        }
      },
    );
  }
}
