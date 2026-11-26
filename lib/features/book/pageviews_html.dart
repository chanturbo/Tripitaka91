import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/audio/edit_speak.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/utils/models/rand_title.dart';
import 'package:tripitaka91/widget/last_read/save_last.dart';
import 'package:tripitaka91/widget/dialogs/edit_dhamma_topic_dialog.dart';
import 'package:tripitaka91/widget/dialogs/online_speech_consent_dialog.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/login/login_dialog.dart';
import 'package:tripitaka91/widget/login/show_logedit_save_with_page.dart';
import 'package:tripitaka91/features/book/pageviews_edit.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/screen/respond_screen.dart';
import 'package:tripitaka91/widget/volume_helper/volume_helper.dart';

enum _WordReportStatus { pending, inProgress, fixed }

class _WordReportEntry {
  final String wordIncorrect;
  final String wordCorrect;
  final String reporterName;
  final String comment;

  const _WordReportEntry({
    required this.wordIncorrect,
    required this.wordCorrect,
    required this.reporterName,
    this.comment = '',
  });
}

class _WordReportInfo {
  final _WordReportStatus status;
  final List<_WordReportEntry> entries;
  final String? oldText;
  final String? newText;

  const _WordReportInfo({
    required this.status,
    required this.entries,
    this.oldText,
    this.newText,
  });
}

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
  final List<GestureRecognizer> _lineRecognizers = [];

  final SharedImageGenerator sharedImageGenerator = SharedImageGenerator();
  final SharedImageLocal sharedImageLocal = SharedImageLocal();

  final dbHelper = DatabaseHelper();
  final volumeHelper = VolumeHelper();
  double _fontSize = 24;
  bool _showLeftPanel = true;
  double scrollBookSearchIndexs1 = -1;
  String bgColor = '#ffffff';
  String fontColor = '#475859';

  @override
  void initState() {
    super.initState();
    _loadFontSize();
    // _currentSliderValue = widget.triPageid as double;
    getDataTitle();
    _getLogEdit();
    getBookTri91All();
    _loadShowLeftPanel();
    _loadColour();

    pageController = PageController(
      initialPage: widget.triPageid,
      viewportFraction: 1.0,
    );
    textTitleReplace = TextTitleReplace();
    uniqueItems = [];
    chkTimer = true;
  }

  Future<void> _loadColour() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bgColor = prefs.getString('color_bg') ?? '#ffffff';
      fontColor = prefs.getString('color_font') ?? '#475859';
    });
  }

  Future<void> _loadShowLeftPanel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showLeftPanel = prefs.getBool('showLeftPanel') ?? true;
    });
  }

  Future<void> _saveShowLeftPanel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showLeftPanel', _showLeftPanel);
  }

  void _scrollToSelectedIndex1() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollControllerListTitle.hasClients &&
          scrollBookSearchIndexs1 != -1) {
        _scrollControllerListTitle.animateTo(
          scrollBookSearchIndexs1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', _fontSize);
  }

  void _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    widget.isMobile
        ? setState(() {
            _fontSize = prefs.getDouble('fontSize') ?? 26;
          })
        : setState(() {
            _fontSize = prefs.getDouble('fontSize') ?? 24;
          });
  }

  void _onTimerFinished() {
    if (mounted && _scrollController.hasClients) {
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

      _scrollController.animateTo(
        midpoint,
        duration: const Duration(milliseconds: 500), // หรือค่าอื่น ๆ ตามต้องการ
        curve: Curves.easeOut, // หรือค่าอื่น ๆ ตามต้องการ
      );
    }
  }

  void _onTimerFinished2() {
    if (mounted && _scrollController.hasClients) {
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

      _scrollController.animateTo(
        midpoint,
        duration: const Duration(milliseconds: 500), // หรือค่าอื่น ๆ ตามต้องการ
        curve: Curves.easeOut, // หรือค่าอื่น ๆ ตามต้องการ
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    saveLastRead();
    audioPlayerManager.dispose();
    audioPlayerManagerTitle.dispose();
    for (final r in _lineRecognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void saveLastRead() async {
    online
        ? await saveBookAccessList(int.parse(widget.triBookid), pageChanged)
        : await dbHelper.saveBookOpenLast(
            int.parse(widget.triBookid),
            pageChanged,
          );
  }

  Future<void> _getLogEdit() async {
    try {
      logEdit = widget.online
          ? await RemoteServiceLogEdit().getLogEdit(
                  widget.triBookid,
                  tSecretAPIKey,
                ) ??
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
          ? await RemoteServiceBookTri91All().getBookTri91All(
                  widget.triBookid,
                  tSecretAPIKey,
                ) ??
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
          ? await RemoteServiceTitle().getTitle(
                  widget.triBookid,
                  tSecretAPIKey,
                ) ??
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

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Future<void> _setColour(int index) async {
    String newBgColor = '#ffffff';
    String newFontColor = '#475859';
    if (index == 0) {
      newBgColor = '#ffffff';
      newFontColor = '#475859';
    } else if (index == 1) {
      newBgColor = '#f8f1e4';
      newFontColor = '#475859';
    } else if (index == 2) {
      newBgColor = '#6b6b6e';
      newFontColor = '#ffffff';
    } else if (index == 3) {
      newBgColor = '#121212';
      newFontColor = '#ffffff';
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('color_bg', newBgColor);
    await prefs.setString('color_font', newFontColor);

    if (!mounted) return;
    setState(() {
      bgColor = newBgColor;
      fontColor = newFontColor;
    });
  }

  Future<int?> showAlertDialog(BuildContext context) {
    final listItems = List.generate(4, (i) => "คลิกเลือก");

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          contentPadding: const EdgeInsets.only(top: 10.0),
          content: SizedBox(
            width: 300.0,
            child: ListView.builder(
              itemCount: listItems.length,
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(index); // ส่ง index กลับ
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    color: index == 0
                        ? HexColor('#ffffff')
                        : index == 1
                        ? HexColor('#f8f1e4')
                        : index == 2
                        ? HexColor('#6b6b6e')
                        : HexColor('#121212'),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        listItems[index],
                        style: TextStyle(
                          fontSize: 24,
                          color: index == 0 || index == 1
                              ? HexColor('#6b6a6a')
                              : HexColor('#ffffff'),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDialogDict(BuildContext context, String result, bool isM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: widget.online
              ? _fetchDataDict(result)
              : _fetchDataDictDB(result),
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
                          color: adaptiveSurfaceColor(context),
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
                                    widget.online || volumeHelper.showVolume
                                        ? InkWell(
                                            onTap: () async {
                                              if (!await ensureOnlineSpeechConsent(
                                                context,
                                              )) {
                                                return;
                                              }
                                              // ignore: use_build_context_synchronously
                                              LoadingDialog.show(context);
                                              String txtTitle =
                                                  '${textTitleReplace.getWordDict(dataDict[index])} - ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                                              String namesave = textTitleReplace
                                                  .getWordDict(dataDict[index])
                                                  .trim()
                                                  .replaceAll(
                                                    RegExp(r'\s+'),
                                                    '',
                                                  );

                                              String filename =
                                                  'dict-$namesave';
                                              await audioPlayerManager
                                                  .playAudio(
                                                    '3',
                                                    filename,
                                                    txtTitle,
                                                  );
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
                                    widget.online || volumeHelper.showVolume
                                        ? const SizedBox(width: 10)
                                        : const SizedBox.shrink(),
                                    InkWell(
                                      onTap: () async {
                                        String txtTitle =
                                            '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                                        txtTitle +=
                                            ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์';
                                        await SharePlus.instance.share(
                                          ShareParams(
                                            text: txtTitle,
                                            subject:
                                                'พจนานุกรม ฉบับประมวลศัพท์',
                                          ),
                                        );
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
                                        _showSnackbar(
                                          context,
                                          'คัดลอกข้อมูลเรียบร้อยแล้ว',
                                        );
                                      },
                                      child: Icon(
                                        Icons.copy,
                                        size: isM ? 21 : 16,
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(child: Text('')),
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
              ? SizedBox(width: double.maxFinite, child: Text(txtShowEmpty))
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
      body: {'wordsearch': result, 'token': tSecretAPIKey, 'username': tmpUser},
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

  void _showInputDialog(
    BuildContext context,
    String initialText,
    String tripitaka91No,
    String tripitaka91Code,
  ) {
    showEditDhammaTopicDialog(
      context: context,
      initialText: initialText,
      tripitaka91No: tripitaka91No,
      tripitaka91Code: tripitaka91Code,
      onSaved: getDataTitle,
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
                text: '$tURLmain${widget.triBookid}-$pageChanged-$tmpLine.htm',
              ),
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
            await SharePlus.instance.share(
              ShareParams(
                text: '$tURLmain${widget.triBookid}-$pageChanged-$tmpLine.htm',
                subject: 'พระไตรปิฎก',
              ),
            );
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
                icon: const Icon(color: TColors.white, Icons.edit),
                onSelected: (value) {
                  // อ่านสดจาก UserProvider แทน field users เดิม กันค่าเก่าค้าง
                  // หลัง login/logout โดยไม่ได้สร้าง widget นี้ใหม่
                  final users = context.read<UserProvider>().user;
                  if (value == 'item1') {
                    if (users != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageViewEdit(
                            bookId: widget.triBookid,
                            pageId: pageChanged.toString(),
                            username: users.username,
                            logEdit: logEdit,
                          ),
                        ),
                      ).then((value) {
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
                            title: const Text(
                              'ยืนยันคำที่น่าจะผิดคำที่น่าจะถูก',
                            ),
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
                  // const PopupMenuItem(
                  //   value: 'item3',
                  //   child: Text('ยืนยันการแก้ไขคำผิดคำถูก'),
                  // ),
                  const PopupMenuItem(
                    value: 'item2',
                    child: Text('แจ้งการอ่านออกเสียง'),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget buildBodyMobile() {
    return Row(children: [pageview(true, false)]);
  }

  // ปุ่ม toggle ซ่อน/แสดงสารบัญ ระหว่างแผงสารบัญกับเนื้อหา ใช้ร่วมกันทั้ง
  // buildBodyTablet() และ buildBody() (เดิมโค้ดซ้ำกันทั้งสองที่)
  Widget _buildPanelToggle() {
    final lineColor = adaptiveBorderColor(context).withValues(alpha: 0.25);
    return Container(
      width: 25,
      color: adaptiveSurfaceColor(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 1, height: 100, color: lineColor),
            const SizedBox(height: 6),
            Tooltip(
              message: _showLeftPanel ? 'ซ่อนสารบัญ' : 'แสดงสารบัญ',
              child: Material(
                color: TColors.primary1,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    setState(() {
                      _showLeftPanel = !_showLeftPanel;
                    });
                    await _saveShowLeftPanel();
                    _scrollToSelectedIndex1();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _showLeftPanel
                          ? Icons.arrow_back_ios_new
                          : Icons.arrow_forward_ios,
                      size: 14,
                      color: TColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(width: 1, height: 100, color: lineColor),
          ],
        ),
      ),
    );
  }

  Widget buildBodyTablet() {
    return Row(
      children: [
        if (_showLeftPanel)
          (numRecord == 0)
              ? Container(
                  alignment: Alignment.topCenter,
                  width: 250.0,
                  color: hexToColor(bgColor),
                  child: Text(txtShowEmpty),
                )
              : Container(
                  width: 250.0,
                  color: hexToColor(bgColor),
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
                        false,
                      );
                    },
                  ),
                ),
        _buildPanelToggle(),
        pageview(false, true),
      ],
    );
  }

  Widget buildBody() {
    return Row(
      children: [
        if (_showLeftPanel)
          (numRecord == 0)
              ? Container(
                  alignment: Alignment.topCenter,
                  width: 350.0,
                  color: hexToColor(bgColor),
                  child: Text(txtShowEmpty),
                )
              : Container(
                  width: 350.0,
                  color: hexToColor(bgColor),
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
                        false,
                      );
                    },
                  ),
                ),
        _buildPanelToggle(),
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

  String arabicToThaiNumbers(String input) {
    const Map<String, String> arabicToThai = {
      '0': '๐',
      '1': '๑',
      '2': '๒',
      '3': '๓',
      '4': '๔',
      '5': '๕',
      '6': '๖',
      '7': '๗',
      '8': '๘',
      '9': '๙',
    };
    return input.split('').map((char) => arabicToThai[char] ?? char).join();
  }

  /// A line from `book_detail` should render bold (like the printed PDF's
  /// title/heading lines) if it still carries a legacy `<B>`/`<H1>`..`<H4>`
  /// tag, possibly garbled with stray characters from the old data import.
  /// `<SUP>`/`<I>` tags don't count.
  bool _isHeaderTaggedLine(String raw) {
    for (final match in RegExp(r'<[^>]*>').allMatches(raw)) {
      final core = match
          .group(0)!
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .toUpperCase();
      if (core == 'B' ||
          core == 'H1' ||
          core == 'H2' ||
          core == 'H3' ||
          core == 'H4') {
        return true;
      }
    }
    return false;
  }

  Widget _reportInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _reportInfoRowPair(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    const TextStyle labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label1: ', style: labelStyle),
            TextSpan(
              text: '$value1    ',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: '$label2: ', style: labelStyle),
            TextSpan(
              text: value2,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnotationDialog(BuildContext context, _WordReportInfo info) {
    final Color statusColor;
    final String statusLabel;
    switch (info.status) {
      case _WordReportStatus.fixed:
        statusColor = Colors.green;
        statusLabel = 'แก้ไขข้อมูลเรียบร้อยแล้ว';
        break;
      case _WordReportStatus.inProgress:
        statusColor = Colors.orange;
        statusLabel = 'อยู่ในกระบวนการแก้ไขข้อมูล';
        break;
      case _WordReportStatus.pending:
        statusColor = Colors.red;
        statusLabel = 'ยังไม่มีการแก้ไข';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: adaptiveSurfaceColor(context),
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          title: const Text(
            'รายงานคำที่น่าจะผิด',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: (screenSize.width * 0.85).clamp(0, 450),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 13.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < info.entries.length; i++) ...[
                    if (i > 0) const Divider(height: 14),
                    _reportInfoRowPair(
                      'คำที่น่าจะผิด',
                      info.entries[i].wordIncorrect,
                      'คำที่น่าจะถูก',
                      info.entries[i].wordCorrect,
                    ),
                    _reportInfoRow('แจ้งโดย', info.entries[i].reporterName),
                    // บางรายงาน (โดยเฉพาะที่คำที่น่าจะผิด/ถูกเว้นว่างหรือใส่แค่
                    // เครื่องหมาย) ผู้แจ้งเขียนคำอธิบายจริงไว้ในหมายเหตุแทน
                    // ถ้าไม่โชว์ส่วนนี้ด้วย กล่องจะดูเหมือนไม่มีข้อมูลเลย
                    if (info.entries[i].comment.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 2),
                        child: Text(
                          'หมายเหตุ: ${info.entries[i].comment.trim()}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                  if (info.oldText != null && info.newText != null) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'ข้อความเดิม',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SelectableText(
                      info.oldText!,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ข้อความที่แก้ไข',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SelectableText(
                      info.newText!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  /// เพิ่ม [text] ลงใน [target] เป็น TextSpan ปกติ ยกเว้นโทเค็นเชิงอรรถ ซึ่งจะถูก
  /// แปลงเป็นตัวเลขอ้างอิงขนาดเล็กและยกขึ้นเหนือบรรทัดจริง (superscript) ด้วย
  /// WidgetSpan โทเค็นที่รองรับมี 2 แบบ: `<sup>NNN</sup>` (แท็ก HTML ดิบที่ยังไม่ถูก
  /// ล้างออกจากข้อมูลบางเล่ม) และ `supNNNsup` (เศษที่เหลือจากการล้างแท็กในเล่มอื่น)
  void _appendTextWithFootnotes(
    List<InlineSpan> target,
    String text,
    TextStyle style,
  ) {
    final supRegex = RegExp(
      r'<sup>([๐-๙0-9]+)</sup>|sup([๐-๙0-9]+)sup',
      caseSensitive: false,
    );
    int last = 0;
    for (final m in supRegex.allMatches(text)) {
      if (m.start > last) {
        target.add(TextSpan(text: text.substring(last, m.start), style: style));
      }
      final number = m.group(1) ?? m.group(2);
      target.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Transform.translate(
            offset: const Offset(0, -4),
            child: Text(
              '[$number]',
              style: TextStyle(
                fontSize: _fontSize * 0.6,
                color: style.color,
                fontFamily: style.fontFamily,
              ),
            ),
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length) {
      target.add(TextSpan(text: text.substring(last), style: style));
    }
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
    bool isMobile,
  ) {
    String wordHilight = widget.chkSearch;
    RegExp regex = RegExp(r'\s+');
    List<String> finalList = wordHilight.split(regex);

    // เพิ่มเลขไทยเข้าไป ถ้าพบเลขอารบิกในคำ
    List<String> outputList = finalList.expand((word) {
      String thaiNumber = arabicToThaiNumbers(word);
      return (thaiNumber != word) ? [word, thaiNumber] : [word];
    }).toList();

    // ใช้ UserProvider แทน field users เดิม เพื่อให้ปุ่มแก้ไขอัปเดตทันทีหลัง login
    final users = context.watch<UserProvider>().user;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Card(
        margin: const EdgeInsets.all(5),
        color: hexToColor(bgColor),
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
                  pageController.animateToPage(
                    pageChanged,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.bounceInOut,
                  );
                  _currentSliderValue = pageId.toDouble();
                  triBookLineRead = tribookline;
                  chkTimer2 = true;
                  scrollBookSearchIndexs1 = _scrollControllerListTitle.offset;
                });
              },
              title: (mark == 'FALSE')
                  ? SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle: TextStyle(
                        fontSize: isMobile ? 18.0 : 16.0,
                        color: HexColor(fontColor),
                      ),
                    )
                  : SubstringHighlight(
                      text: triTitle,
                      terms: outputList,
                      textStyle: TextStyle(
                        fontSize: isMobile ? 18.0 : 16.0,
                        color: Colors.red,
                      ),
                      textStyleHighlight: TextStyle(color: HexColor(fontColor)),
                    ),
              subtitle: Row(
                children: [
                  widget.online || volumeHelper.showVolume
                      ? InkWell(
                          onTap: () async {
                            if (!await ensureOnlineSpeechConsent(context)) {
                              return;
                            }
                            // ignore: use_build_context_synchronously
                            LoadingDialog.show(context);
                            String txtTitle = textReplacer.replaceText(
                              triTitle,
                              bookBlue,
                            );

                            String filename = noTitleCate.toString().replaceAll(
                              '.',
                              '',
                            );
                            filename =
                                '$filename-$noTitle-$bookIds-$pageId-$bookLine';
                            await audioPlayerManager.playAudio(
                              '1',
                              filename,
                              txtTitle,
                            );
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
                  widget.online || volumeHelper.showVolume
                      ? const SizedBox(width: 10)
                      : const SizedBox.shrink(),
                  InkWell(
                    onTap: () async {
                      String txtTitle = textReplacer.replaceText(
                        triTitle,
                        bookBlue,
                      );
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
                  widget.online
                      ? const SizedBox(width: 10)
                      : const SizedBox.shrink(),
                  InkWell(
                    onTap: () async {
                      String txtTitle = textReplacer.replaceText(
                        triTitle,
                        bookBlue,
                      );
                      txtTitle +=
                          'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm',
                        ),
                      );
                      _showSnackbar(context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                    },
                    child: Icon(
                      Icons.copy,
                      size: isMobile ? 21 : 16,
                      color: Colors.blue[300], // Change color as needed
                    ),
                  ),
                  (users != null) && (users.levelAccess == '1')
                      ? const SizedBox(width: 10)
                      : const SizedBox.shrink(),
                  (users != null) && (users.levelAccess == '1')
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
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            contentPadding: const EdgeInsets.only(top: 10.0),
            backgroundColor: adaptiveSurfaceColor(context),
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
    );
    // ไม่ต้อง refresh users เองแล้ว เพราะ UserProvider ที่ login.dart อัปเดต
    // จะไหลมาอัปเดต UI ที่ watch ไว้ (buildAppBar/titleCardSub) ให้เองทันที
  }

  Widget pageview(bool isMobile, bool isTable) {
    return Expanded(
      child: Column(
        children: [
          Container(
            // width: MediaQuery.of(context).size.width - 20.0,
            margin: const EdgeInsets.all(1.0),
            padding: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: hexToColor(bgColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                widget.online || volumeHelper.showVolume
                    ? pageChanged == 0
                          ? const Text('')
                          : IconButton(
                              tooltip: 'อ่านออกเสียง',
                              icon: const Icon(Icons.volume_up),
                              color: TColors.secondary,
                              onPressed: () async {
                                if (!await ensureOnlineSpeechConsent(context)) {
                                  return;
                                }
                                if (!mounted) return;
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
                                      _showSnackbar(
                                        context,
                                        'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง',
                                      );
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
                                      '0',
                                      filename,
                                      txtDetail,
                                    );
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
                                      _showSnackbar(
                                        context,
                                        'กรุณากดปุ่มอ่านออกเสียงอีกครั้ง',
                                      );
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
                                      '0',
                                      filename,
                                      txtDetail,
                                    );
                                  }
                                  // ignore: use_build_context_synchronously
                                  LoadingDialog.hide(context);
                                }
                              },
                            )
                    : const Text(''),
                widget.online || volumeHelper.showVolume
                    ? pageChanged == 0
                          ? const ATextLabelMedium(text: '   หน้า')
                          : const Text('')
                    : const Text(''),
                widget.online || volumeHelper.showVolume
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
                                    if (!await ensureOnlineSpeechConsent(
                                      context,
                                    )) {
                                      return;
                                    }
                                    if (!mounted) return;
                                    audioPlayerManager.pause();
                                    setState(() {
                                      if (audioPlayerManager.chkStatePlay()) {
                                        audioPlayerManager.stop();
                                      }
                                    });
                                    String filename = '0-1-1';
                                    String txtDetail = 'คำนำ1';
                                    await audioPlayerManager.playAudio(
                                      '0',
                                      filename,
                                      txtDetail,
                                    );
                                  },
                                ),
                              ],
                            )
                          : const Text('')
                    : const Text(''),
                widget.online || volumeHelper.showVolume
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
                                    if (!await ensureOnlineSpeechConsent(
                                      context,
                                    )) {
                                      return;
                                    }
                                    if (!mounted) return;
                                    audioPlayerManager.pause();
                                    setState(() {
                                      if (audioPlayerManager.chkStatePlay()) {
                                        audioPlayerManager.stop();
                                      }
                                    });
                                    String filename = '0-1-2';
                                    String txtDetail = 'คำนำ2';
                                    await audioPlayerManager.playAudio(
                                      '0',
                                      filename,
                                      txtDetail,
                                    );
                                  },
                                ),
                              ],
                            )
                          : const Text('')
                    : const Text(''),
                widget.online || volumeHelper.showVolume
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
                                    if (!await ensureOnlineSpeechConsent(
                                      context,
                                    )) {
                                      return;
                                    }
                                    if (!mounted) return;
                                    audioPlayerManager.pause();
                                    setState(() {
                                      if (audioPlayerManager.chkStatePlay()) {
                                        audioPlayerManager.stop();
                                      }
                                    });
                                    String filename = '0-1-3';
                                    String txtDetail = 'คำนำ3';
                                    await audioPlayerManager.playAudio(
                                      '0',
                                      filename,
                                      txtDetail,
                                    );
                                  },
                                ),
                              ],
                            )
                          : const Text('')
                    : const Text(''),
                widget.online || volumeHelper.showVolume
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
                                    if (!await ensureOnlineSpeechConsent(
                                      context,
                                    )) {
                                      return;
                                    }
                                    if (!mounted) return;
                                    audioPlayerManager.pause();
                                    setState(() {
                                      if (audioPlayerManager.chkStatePlay()) {
                                        audioPlayerManager.stop();
                                      }
                                    });
                                    String filename = '0-1-4';
                                    String txtDetail = 'คำนำ4';
                                    await audioPlayerManager.playAudio(
                                      '0',
                                      filename,
                                      txtDetail,
                                    );
                                  },
                                ),
                              ],
                            )
                          : const Text('')
                    : const Text(''),
                widget.online || volumeHelper.showVolume
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
                                    if (!await ensureOnlineSpeechConsent(
                                      context,
                                    )) {
                                      return;
                                    }
                                    if (!mounted) return;
                                    audioPlayerManager.pause();
                                    setState(() {
                                      if (audioPlayerManager.chkStatePlay()) {
                                        audioPlayerManager.stop();
                                      }
                                    });
                                    String filename = '0-1-5';
                                    String txtDetail = 'คำนำ5';
                                    await audioPlayerManager.playAudio(
                                      '0',
                                      filename,
                                      txtDetail,
                                    );
                                  },
                                ),
                              ],
                            )
                          : const Text('')
                    : const Text(''),
                widget.online || volumeHelper.showVolume
                    ? pageChanged == 0
                          ? IconButton(
                              tooltip: 'หยุดชั่วคราว',
                              icon: const Icon(Icons.pause),
                              onPressed: () {
                                audioPlayerManager.pause();
                              },
                            )
                          : currentPlaylist.isEmpty
                          ? const Icon(Icons.stop, color: Colors.grey)
                          : IconButton(
                              tooltip: 'หยุดชั่วคราว',
                              icon: const Icon(Icons.pause),
                              onPressed: () {
                                audioPlayerManager.pause();
                              },
                            )
                    : const Text(''),
                const Expanded(child: Text('')),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  tooltip: 'เปลี่ยนสีพื้น',
                  onPressed: () async {
                    final selectedIndex = await showAlertDialog(context);
                    if (selectedIndex != null) {
                      await _setColour(selectedIndex);
                      // showAlertDialog already pops itself (via its own
                      // Navigator.pop(index) when an option is tapped), so
                      // popping again here was closing this reading page
                      // instead of the dialog — then the SnackBar call
                      // below crashed with "deactivated widget" on the
                      // now-popped page.
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('เปลี่ยนสีพื้นหลังแล้ว')),
                      );
                    }
                  },
                  color: Colors.blue,
                ),
                const SizedBox(width: 5),
                pageChanged == 0
                    ? const Text('')
                    : isMobile
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.blue,
                            ),
                          ),
                          child: const ATextDiskplaySmall(
                            text: 'สารบัญหัวข้อธรรม',
                          ),
                          onPressed: () {
                            _showDialogTitle(context, true);
                            _scrollToSelectedIndex1();
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
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.blue,
                            ),
                          ),
                          child: const ATextDiskplaySmall(text: 'พจนานุกรม'),
                          onPressed: () async {
                            if (bookTri91.isNotEmpty) {
                              // print(
                              //     'bookPageds ${bookTri91[0].bookPages} pageChanged : $pageChanged');
                              if (bookTri91[0].bookPages != pageChanged) {
                                // LoadingDialog.hide(context);
                                _showSnackbar(
                                  context,
                                  'กรุณากดปุ่มพจนานุกรมอีกครั้ง',
                                );
                                setState(() {});
                                return;
                              }

                              String dictTmp = '';
                              for (var book in bookTri91) {
                                dictTmp += '${book.bookDict!},';
                              }

                              if (dictTmp.isNotEmpty) {
                                dictTmp = dictTmp.substring(
                                  0,
                                  dictTmp.length - 1,
                                );
                                uniqueItems = removeDuplicatesAndDash(dictTmp);
                                uniqueItems.sort(
                                  (a, b) => a.length.compareTo(b.length),
                                );

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
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width - 20.0,
              margin: const EdgeInsets.all(1.0),
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: hexToColor(bgColor),
                border: Border.all(color: Colors.blue, width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              // child: showPageView(bookid.toString()),
              child: numPageAll == 1
                  ? const Center(child: CircularProgressIndicator())
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
                            index.toString(),
                            tribookline,
                            isMobile,
                            isTable,
                          ),
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
                    setState(() {
                      audioPlayerManager.stop();
                      audioPlayerManagerTitle.stop();
                      currentPlaylist.clear();
                      if (value > numPageAll) {
                        value--;
                      }
                      pageChanged = value.toInt();
                      pageController.animateToPage(
                        value.toInt(),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.bounceInOut,
                      );
                      _currentSliderValue = value;
                    });
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
              IconButton(
                onPressed: () {
                  setState(() {
                    _fontSize < 15 ? _fontSize = 15 : _fontSize -= 2;
                    _saveFontSize();
                  });
                },
                icon: const Icon(Icons.zoom_out), // หรือ Icons.remove
                tooltip: 'ลดขนาดตัวอักษร',
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _fontSize > 60 ? _fontSize = 60 : _fontSize += 2;
                    _saveFontSize();
                  });
                },
                icon: const Icon(Icons.zoom_in), // หรือ Icons.add
                tooltip: 'ขยายตัวอักษร',
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: ATextTitleMedium(
                  text: 'หน้า ${pageChanged.toString()}/$numPageAll',
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
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
              widget.triBookid.toString(),
              pageShow,
              tSecretAPIKey,
            )
          : dbHelper.getBookTri91(widget.triBookid, pageShow),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
              snapText = bookList[i]['book_detail'].toString().replaceAll(
                'LineNull',
                '&nbsp;',
              );
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
                fontSize: 28,
              ),
              overrideStyle: <String, TextStyle>{
                'span': isMobile
                    ? const TextStyle(fontSize: 28)
                    : const TextStyle(fontSize: 26),
                'p': isMobile
                    ? const TextStyle(fontSize: 28)
                    : const TextStyle(fontSize: 26),
                'b': TextStyle(fontWeight: FontWeight.w500),
                'strong': TextStyle(fontWeight: FontWeight.w500),
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
              width: double.infinity,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SelectableText.rich(
                  textSpan,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 0.1),
                ),
              ),
            );
          } else {
            return const Center(
              child: ATextTitleMedium(
                text: 'No data found',
              ), // เพิ่มข้อความเมื่อไม่มีข้อมูล
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
          int triPage = int.parse(pageShow);

          final TextStyle baseStyle = TextStyle(
            letterSpacing: 0.4,
            color: HexColor(fontColor),
            fontFamily: "THSarabunNew",
            fontSize: _fontSize,
          );

          for (final r in _lineRecognizers) {
            r.dispose();
          }
          _lineRecognizers.clear();

          final List<InlineSpan> pageSpans = [];

          // จอเล็ก (มือถือ) เท่านั้นที่ย่อช่องว่างซ้ำให้แคบลง จอใหญ่ (แท็บเล็ต/
          // เดสก์ท็อป) แสดงช่องว่างตามต้นฉบับเหมือนเดิม เพราะไม่ต้องตัดขึ้น
          // บรรทัดใหม่บ่อยอยู่แล้ว
          final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

          if (triPage != 0) {
            // ขยับหัวข้อไปทางขวาเพิ่มตามหมวด ตามที่ผู้ใช้ขอ เพราะหัวข้อบางหมวด
            // สั้นกว่าหมวดอื่นจนดูเยื้องซ้าย: พระวินัยปิฎก (เล่ม 1-10) และ
            // พระอภิธรรมปิฎก (เล่ม 75-91) ขยับ 10 เคาะ, พระสุตตันตปิฎก
            // (เล่ม 11-74) ขยับ 8 เคาะ
            final bool isVinayaPitaka = bookid >= 1 && bookid <= 10;
            final bool isSuttantaPitaka = bookid >= 11 && bookid <= 74;
            final bool isAbhidhammaPitaka = bookid >= 75 && bookid <= 91;
            // ใช้เฉพาะจอ Tablet/Desktop เท่านั้น ตัดออกบนมือถือ
            final int headerIndent = isSmallScreen
                ? 0
                : (isVinayaPitaka || isAbhidhammaPitaka)
                ? 10
                : isSuttantaPitaka
                ? 8
                : 0;
            // ใช้ WidgetSpan ความกว้างคงที่แทนการเคาะช่องว่างซ้ำ เพราะฟอนต์ตัวนี้
            // เป็น proportional font ความกว้างของอักขระเว้นวรรคไม่คงที่ตาม
            // fontSize/text scale ของอุปกรณ์ ทำให้การเยื้องคลาดเคลื่อนได้
            if (headerIndent > 0) {
              pageSpans.add(
                WidgetSpan(
                  child: SizedBox(width: headerIndent * _fontSize * 0.25),
                ),
              );
            }
            pageSpans.add(
              TextSpan(
                text: ' $title หน้าที่ $page\n',
                style: baseStyle.copyWith(fontWeight: FontWeight.w800),
              ),
            );
          }

          for (int i = 0; i < snapshot.data!.length; i++) {
            final String rawLine = snapshot.data![i].bookDetail.toString();
            final bool headerLine = _isHeaderTaggedLine(rawLine);

            // ลบแท็กเก่า/ที่เพี้ยนออก แต่ไม่แตะช่องว่าง
            // (Text ของ Flutter ไม่ยุบช่องว่างซ้ำแบบ HTML อยู่แล้ว จึงคงการเคาะวรรค/ย่อหน้าตามต้นฉบับได้)
            String snapText = rawLine == 'LineNull' ? '' : rawLine;
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

            // ต้นฉบับเว้นวรรคคั่นคำ/ย่อหน้าด้วยช่องว่างหลายตัว (3-8 ตัว) ซึ่งกว้าง
            // เกินไปเมื่อแสดงด้วยฟอนต์สัดส่วนบนจอแคบ ย่อให้เหลือ 2 ตัวเสมอ
            // (ยังเว้นกว้างกว่าช่องว่างปกติ พอสังเกตเห็นย่อหน้า/จุดคั่นได้)
            // จอใหญ่ไม่ต้องย่อ เพราะแสดงผลปกติดีอยู่แล้ว
            if (isSmallScreen) {
              snapText = snapText.replaceAll(RegExp(r' {2,}'), '  ');
            }

            // หมายเหตุ: โทเค็นเชิงอรรถ supNNNsup ยังคงอยู่ใน snapText เพื่อให้
            // _appendTextWithFootnotes ด้านล่างแปลงเป็นตัวเลขยกขึ้นจริงทีหลัง

            final bool isTriLineMatch =
                snapshot.data?[i].bookLines == (triLine);
            final bool isSavedPageView = int.parse(pageShow) == pageids;
            final bool applyCurrentLineBg = isSavedPageView && isTriLineMatch;

            String wordHilight = widget.chkSearch;
            RegExp regex = RegExp(r'\s+');
            List<String> finalList = wordHilight.split(regex);

            // เพิ่มเลขไทยเข้าไป ถ้าพบเลขอารบิกในคำ
            List<String> findWord = finalList
                .expand((word) {
                  String thaiNumber = arabicToThaiNumbers(word);
                  return (thaiNumber != word) ? [word, thaiNumber] : [word];
                })
                .where((w) => w.isNotEmpty)
                .toList();

            Color? highlightColor;
            if (findWord.isNotEmpty && triLine > 0) {
              if (isTriLineMatch) {
                highlightColor = isSavedPageView ? Colors.black : Colors.red;
              } else {
                highlightColor = Colors.red;
              }
            }

            TextStyle lineStyle = baseStyle;
            if (headerLine) {
              lineStyle = lineStyle.copyWith(fontWeight: FontWeight.w500);
            }
            if (applyCurrentLineBg) {
              lineStyle = lineStyle.copyWith(
                backgroundColor: const Color(0xFFd58512),
                color: Colors.white,
              );
            }

            final List<_WordReportEntry> reportEntries = [];
            int chkComfirm = 2;
            int chkSuscess = 2;
            bool chkLogShow = false;
            String lineOld = '';
            String lineNew = '';
            for (Logedit log in result) {
              if (log.tripitaka91Line == snapshot.data?[i].bookLines) {
                String nameid = log.firstNameid;
                lineOld = log.bookDetailOld;
                lineNew = log.bookDetailNew;

                DateTime dateAdd = log.tripitaka91Dateadd;
                DateTime targetDate1 = DateTime(2023, 11, 13); // วันที่เริ่มบวช
                // บวชถึงวันที่ 29 ส.ค. 2026 (รวมวันนั้นด้วย) จึงใช้ 30 ส.ค. เป็น
                // ขอบเขตบน (isBefore แบบ exclusive) — ตรงกับ tri91_process.php
                // บนเว็บไซต์หลังแก้ไขให้ตรงกัน
                DateTime targetDate2 = DateTime(2026, 8, 30);
                if (log.tripitaka91User == 'Rotor206') {
                  if (dateAdd.isBefore(targetDate1)) {
                    nameid = 'นาย';
                  } else if (dateAdd.isBefore(targetDate2)) {
                    nameid = 'พระ';
                  } else {
                    nameid = 'นาย';
                  }
                }

                reportEntries.add(
                  _WordReportEntry(
                    wordIncorrect: log.tripitaka91Wordincorrect,
                    wordCorrect: log.tripitaka91Wordcorrect,
                    reporterName: '$nameid${log.firstName} ${log.lastName}',
                    comment: log.tripitaka91Wordcorrectcomment,
                  ),
                );
                chkComfirm = log.bookConfirm;
                chkSuscess = log.bookSuscess;
                chkLogShow = true;
              }
            }

            _WordReportInfo? reportInfo;
            if (chkLogShow) {
              if (chkSuscess == 1) {
                reportInfo = _WordReportInfo(
                  status: _WordReportStatus.fixed,
                  entries: reportEntries,
                  oldText: lineOld,
                  newText: lineNew,
                );
              } else if (chkComfirm == 0) {
                reportInfo = _WordReportInfo(
                  status: _WordReportStatus.pending,
                  entries: reportEntries,
                );
              } else {
                reportInfo = _WordReportInfo(
                  status: _WordReportStatus.inProgress,
                  entries: reportEntries,
                  oldText: lineOld.replaceAll('"', ''),
                  newText: lineNew.replaceAll('"', ''),
                );
              }
            }

            if (reportInfo != null) {
              final info = reportInfo;
              final recognizer = TapGestureRecognizer()
                ..onTap = () => _showAnnotationDialog(context, info);
              _lineRecognizers.add(recognizer);
              pageSpans.add(
                TextSpan(
                  text: '[*] ',
                  // ใช้สีน้ำเงินแทนสีส้มเดิม เพราะสีส้มซ้ำกับพื้นหลังไฮไลต์
                  // บรรทัดปัจจุบัน (ตัวหนังสือ [*] จะกลมกลืนจนมองไม่เห็น)
                  style: lineStyle.copyWith(
                    fontSize: 26,
                    color: const Color(0xFF0D47A1),
                    letterSpacing: 0,
                  ),
                  recognizer: recognizer,
                ),
              );
            }

            // ไฮไลต์คำค้นหาในเนื้อหา (เชิงอรรถในแต่ละช่วงจะถูกแปลงเป็นตัวเลขยกขึ้นจริง)
            if (highlightColor != null && snapText.isNotEmpty) {
              final pattern = findWord.map(RegExp.escape).join('|');
              final wordRegex = RegExp(pattern);
              int last = 0;
              for (final m in wordRegex.allMatches(snapText)) {
                if (m.start > last) {
                  _appendTextWithFootnotes(
                    pageSpans,
                    snapText.substring(last, m.start),
                    lineStyle,
                  );
                }
                _appendTextWithFootnotes(
                  pageSpans,
                  snapText.substring(m.start, m.end),
                  lineStyle.copyWith(color: highlightColor),
                );
                last = m.end;
              }
              if (last < snapText.length) {
                _appendTextWithFootnotes(
                  pageSpans,
                  snapText.substring(last),
                  lineStyle,
                );
              }
            } else {
              _appendTextWithFootnotes(pageSpans, snapText, lineStyle);
            }

            pageSpans.add(TextSpan(text: '\n', style: lineStyle));
          }

          if (chkTimer) {
            _timer = Timer(const Duration(seconds: 1), _onTimerFinished);
            chkTimer = false;
          } else if (chkTimer2) {
            _timer = Timer(const Duration(seconds: 1), _onTimerFinished2);
            chkTimer2 = false;
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              // บังคับความกว้างให้เท่ากับพื้นที่จอจริงเสมอ กัน WidgetSpan
              // (เชิงอรรถที่ยกขึ้น) ทำให้ Flutter คำนวณความกว้างเนื้อหาแบบ
              // ไม่มีขอบเขตแล้วข้อความยาวล้นขอบจอแทนที่จะตัดขึ้นบรรทัดใหม่
              final double contentWidth = constraints.maxWidth > 700
                  ? 700
                  : constraints.maxWidth;
              return SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SelectableText.rich(
                        TextSpan(children: pageSpans),
                        textAlign: isSmallScreen
                            ? TextAlign.center
                            : TextAlign.left,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
