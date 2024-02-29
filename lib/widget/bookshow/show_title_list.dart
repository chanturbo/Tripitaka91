import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/pageviews/pageviews.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

class SearchShowPagesTitleList extends StatefulWidget {
  final String bookid;
  final bool isMobile;
  const SearchShowPagesTitleList(
      {super.key, required this.bookid, required this.isMobile});

  @override
  State<SearchShowPagesTitleList> createState() =>
      _SearchShowPagesTitleListState();
}

class _SearchShowPagesTitleListState extends State<SearchShowPagesTitleList> {
  List<String> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollControllerTitle = ScrollController();

  AudioPlayerManager audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataTitle();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !_scrollControllerTitle.position.outOfRange) {
      _fetchDataTitle();
    }
  }

  Future<void> _fetchDataTitle() async {
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
        Uri.parse(tURLtitleShowInPage),
        body: {
          'bookid': widget.bookid,
          'token': tSecretAPIKey,
          'username': tmpUser,
          'page': pageTitle.toString(),
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

        if (jsonResponse['success'] == true) {
          List<String> newData = List<String>.from(jsonResponse['message']);
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

  Widget _showText(String title, String mark) {
    if (mark == 'TRUE') {
      return Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.red),
      );
    } else {
      return ATextTitleMedium(
        text: title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _fetchDataTitle();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollControllerTitle,
          itemCount: loadedRecordsTitle + 1,
          itemBuilder: (context, index) {
            if (index == loadedRecordsTitle) {
              return loadingTitle
                  ? const Center(child: CircularProgressIndicator())
                  : (loadedRecordsTitle == 0)
                      ? SizedBox(
                          child: Column(
                            children: [
                              Center(
                                child: ATextTitleLarge(
                                    text:
                                        'เล่ม ${widget.bookid} ไม่พบหัวข้อธรรมสำหรับแสดงผล'),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Center(
                                child: ATextTitleLarge(
                                    text:
                                        'กรุณาคลิกที่ปุ่มเปิดหน้าที่อ่านล่าสุด'),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
            }
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    child: ATextDiskplayMedium(text: '${index + 1}'),
                  ),
                  title: _showText(
                    '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ',
                    textTitleReplace.getMark(dataTitle[index]),
                  ),
                  // title: ATextTitleMedium(
                  //   text:
                  //       '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ',
                  // ),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              LoadingDialog.show(context);
                              String bookIds =
                                  textTitleReplace.getBookId(dataTitle[index]);
                              String pageId =
                                  textTitleReplace.getPageId(dataTitle[index]);
                              String bookLine =
                                  textTitleReplace.getLineId(dataTitle[index]);
                              String noTitleCate =
                                  textTitleReplace.getCate(dataTitle[index]);
                              String noTitle =
                                  textTitleReplace.getNo(dataTitle[index]);

                              String txtTitle = textTitleReplace.replaceText(
                                  textTitleReplace
                                      .extractText(dataTitle[index]),
                                  textTitleReplace
                                      .getBookBlue(dataTitle[index]));

                              String filename = noTitleCate.replaceAll('.', '');
                              filename =
                                  '$filename-$noTitle-$bookIds-$pageId-$bookLine';
                              await audioPlayerManager.playAudio(
                                  '1', filename, txtTitle);

                              // ignore: use_build_context_synchronously
                              LoadingDialog.hide(context);
                            },
                            child: Icon(
                              Icons.volume_up,
                              size: widget.isMobile ? 25 : 20,
                              color: Colors.blue[300],
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
                              String bookIds =
                                  textTitleReplace.getBookId(dataTitle[index]);
                              String pageId =
                                  textTitleReplace.getPageId(dataTitle[index]);
                              String bookLine =
                                  textTitleReplace.getLineId(dataTitle[index]);
                              String txtTitle =
                                  '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ';
                              txtTitle +=
                                  'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                              await Share.share(
                                  '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm',
                                  subject: 'สรุปหัวข้อธรรมจากพระไตรปิฎก');
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
                              String bookIds =
                                  textTitleReplace.getBookId(dataTitle[index]);
                              String pageId =
                                  textTitleReplace.getPageId(dataTitle[index]);
                              String bookLine =
                                  textTitleReplace.getLineId(dataTitle[index]);
                              String txtTitle =
                                  '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ';
                              txtTitle +=
                                  'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                              Clipboard.setData(
                                ClipboardData(
                                    text:
                                        '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm'),
                              );
                              _showSnackbar(
                                  context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                            },
                            child: Icon(
                              Icons.copy,
                              size: widget.isMobile ? 21 : 16,
                              color: Colors.blue[300],
                            ),
                          ),
                          const Expanded(
                            child: SizedBox(
                              child: Text(''),
                            ),
                          ),
                          widget.isMobile
                              ? const Text('')
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: ClipPath(
                                    clipper: DoubleTriangleRectangleClipper(),
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      color: Colors.blue[900],
                                      child: ATextLabelSmall(
                                        text:
                                            '${textTitleReplace.extractRemainingText(dataTitle[index])} ',
                                      ),
                                    ),
                                  ),
                                ),
                          widget.isMobile
                              ? const Text('')
                              : const SizedBox(width: 10),
                          widget.isMobile
                              ? const Text('')
                              : Align(
                                  alignment: Alignment.centerRight,
                                  child: ClipPath(
                                    clipper: DoubleTriangleRectangleClipper(),
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      color:
                                          Colors.red, // Change color as needed
                                      child: Center(
                                        child: ATextLabelSmall(
                                          text:
                                              'เล่มสีแดง ${textTitleReplace.getBookRed(dataTitle[index])}', // Access widget property
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      Row(
                        children: [
                          widget.isMobile
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: ClipPath(
                                    clipper: DoubleTriangleRectangleClipper(),
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      color: Colors.blue[900],
                                      child: ATextLabelSmall(
                                        text:
                                            '${textTitleReplace.extractRemainingText(dataTitle[index])} ',
                                      ),
                                    ),
                                  ),
                                )
                              : const Text(''),
                          widget.isMobile
                              ? const SizedBox(width: 10)
                              : const Text(''),
                          widget.isMobile
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: ClipPath(
                                    clipper: DoubleTriangleRectangleClipper(),
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      color:
                                          Colors.red, // Change color as needed
                                      child: Center(
                                        child: ATextLabelSmall(
                                          text:
                                              'เล่มสีแดง ${textTitleReplace.getBookRed(dataTitle[index])}', // Access widget property
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const Text(''),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    audioPlayerManager.stop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Tri91PageView(
                          triBookid:
                              textTitleReplace.getBookId(dataTitle[index]),
                          triPageid: int.parse(
                              textTitleReplace.getPageId(dataTitle[index])),
                          triBookline:
                              textTitleReplace.getLineId(dataTitle[index]),
                          chkSearch: '',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
