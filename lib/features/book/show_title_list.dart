import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/img_service/shared_image_generator.dart';
import 'package:tripitaka91/utils/launch_url/launch_url.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/audio/edit_speak.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/common/circular_icon_button.dart';
import 'package:tripitaka91/widget/dialogs/edit_dhamma_topic_dialog.dart';
import 'package:tripitaka91/widget/dialogs/online_speech_consent_dialog.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/features/book/pageviews_html.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/volume_helper/volume_helper.dart';

class SearchShowPagesTitleList extends StatefulWidget {
  final String bookid;
  final bool isMobile;
  final bool online;
  const SearchShowPagesTitleList({
    super.key,
    required this.bookid,
    required this.isMobile,
    required this.online,
  });

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
  final SharedImageGenerator sharedImageGenerator = SharedImageGenerator();
  final SharedImageLocal sharedImageLocal = SharedImageLocal();
  final volumeHelper = VolumeHelper();

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollControllerTitle.addListener(_scrollListener);
    widget.online ? _fetchDataTitle() : _fetchDataTitleInBook();
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
      widget.online ? _fetchDataTitle() : _fetchDataTitleInBook();
    }
  }

  Future<void> _fetchDataTitleInBook() async {
    int recordsPerPage = 10;
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      try {
        List<String> newData = await DatabaseHelper().fetchTitlesInBook(
          widget.bookid,
          (pageTitle - 1) * recordsPerPage,
          recordsPerPage,
        );

        setState(() {
          loadedRecordsTitle += newData.length;
          dataTitle.addAll(newData);
          loadingTitle = false;
          pageTitle++;
        });
      } catch (e) {
        // ignore: avoid_print
        print('Database Error: $e');
        setState(() {
          loadingTitle = false;
        });
      }
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
        var jsonResponse = jsonDecode(json);

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
    final double titleFontSize = widget.isMobile ? 18.0 : 15.0;
    if (mark == 'TRUE') {
      return SubstringHighlight(
        text: title,
        term: title,
        textStyle: TextStyle(fontFamily: 'Sarabun', fontSize: titleFontSize),
      );
    } else {
      return Text(
        title,
        style: TextStyle(fontFamily: 'Sarabun', fontSize: titleFontSize),
      );
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
      onSaved: () {
        dataTitle = [];
        loadedRecordsTitle = 0;
        loadingTitle = false;
        pageTitle = 1;
        widget.online ? _fetchDataTitle() : _fetchDataTitleInBook();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ UserProvider แทนการ getUsersList() ครั้งเดียวใน initState เดิม
    // เพื่อให้ปุ่มแก้ไข/แจ้งอ่านอัปเดตทันทีหลัง login
    final usersChk = context.watch<UserProvider>().user;
    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            widget.online ? _fetchDataTitle() : _fetchDataTitleInBook();
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
                                  'เล่ม ${widget.bookid} ไม่พบหัวข้อธรรมสำหรับแสดงผล',
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Center(
                            child: ATextTitleLarge(
                              text: 'กรุณาคลิกที่ปุ่มเปิดหน้าที่อ่านล่าสุด',
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            }
            return Column(
              children: [
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  minVerticalPadding: 0,
                  contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  leading: CircleAvatar(
                    radius: widget.isMobile ? 14 : 17,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.online || volumeHelper.showVolume)
                            CircularIconButton(
                              icon: Icons.volume_up,
                              size: widget.isMobile ? 25 : 20,
                              color: Colors.blue[300]!,
                              onTap: () async {
                                if (!await ensureOnlineSpeechConsent(context)) {
                                  return;
                                }
                                // ignore: use_build_context_synchronously
                                LoadingDialog.show(context);
                                String bookIds = textTitleReplace.getBookId(
                                  dataTitle[index],
                                );
                                String pageId = textTitleReplace.getPageId(
                                  dataTitle[index],
                                );
                                String bookLine = textTitleReplace.getLineId(
                                  dataTitle[index],
                                );
                                String noTitleCate = textTitleReplace.getCate(
                                  dataTitle[index],
                                );
                                String noTitle = textTitleReplace.getNo(
                                  dataTitle[index],
                                );

                                String txtTitle = textTitleReplace.replaceText(
                                  textTitleReplace.extractText(
                                    dataTitle[index],
                                  ),
                                  textTitleReplace.getBookBlue(
                                    dataTitle[index],
                                  ),
                                );

                                String filename = noTitleCate.replaceAll(
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
                            ),
                          CircularIconButton(
                            icon: Icons.share,
                            size: widget.isMobile ? 21 : 16,
                            color: Colors.blue[300]!,
                            onTap: () async {
                              String bookIds = textTitleReplace.getBookId(
                                dataTitle[index],
                              );
                              String pageId = textTitleReplace.getPageId(
                                dataTitle[index],
                              );
                              String bookLine = textTitleReplace.getLineId(
                                dataTitle[index],
                              );
                              String txtTitle =
                                  '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ';
                              sharedImageGenerator.generateAndShare(
                                context: context,
                                bookTitle: txtTitle.replaceAll('', ''),
                                bookid: bookIds,
                                pageid: pageId.toString(),
                                lineid: bookLine,
                                bookBlue: textTitleReplace.getBookBlue(
                                  dataTitle[index],
                                ),
                                bookRed: textTitleReplace.getBookRed(
                                  dataTitle[index],
                                ),
                              );
                            },
                          ),
                          CircularIconButton(
                            icon: Icons.language,
                            size: widget.isMobile ? 21 : 16,
                            color: Colors.blue[300]!,
                            onTap: () async {
                              String bookIds = textTitleReplace.getBookId(
                                dataTitle[index],
                              );
                              String pageId = textTitleReplace.getPageId(
                                dataTitle[index],
                              );
                              String bookLine = textTitleReplace.getLineId(
                                dataTitle[index],
                              );
                              await openLinkInNewTab(
                                '$tURLmain$bookIds-$pageId-$bookLine.htm',
                              );
                            },
                          ),
                          CircularIconButton(
                            icon: Icons.copy,
                            size: widget.isMobile ? 21 : 16,
                            color: Colors.blue[300]!,
                            onTap: () async {
                              String bookIds = textTitleReplace.getBookId(
                                dataTitle[index],
                              );
                              String pageId = textTitleReplace.getPageId(
                                dataTitle[index],
                              );
                              String bookLine = textTitleReplace.getLineId(
                                dataTitle[index],
                              );
                              String txtTitle =
                                  '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ';
                              txtTitle +=
                                  'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm',
                                ),
                              );
                              _showSnackbar(
                                context,
                                'คัดลอกข้อมูลเรียบร้อยแล้ว',
                              );
                            },
                          ),
                          if (usersChk != null && usersChk.levelAccess == '1')
                            CircularIconButton(
                              icon: Icons.edit,
                              size: widget.isMobile ? 21 : 16,
                              color: Colors.blue[300]!,
                              onTap: () {
                                _showInputDialog(
                                  context,
                                  textTitleReplace.extractText(
                                    dataTitle[index],
                                  ),
                                  textTitleReplace.getNo(dataTitle[index]),
                                  textTitleReplace.getCate(dataTitle[index]),
                                );
                              },
                            ),
                          if (usersChk != null)
                            CircularIconButton(
                              icon: Icons.record_voice_over,
                              size: widget.isMobile ? 21 : 16,
                              color: Colors.blue[300]!,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: const EdgeInsets.all(5),
                                      title: const Text('แจ้งการอ่านออกเสียง'),
                                      content: const SizedBox(
                                        width: double.maxFinite,
                                        child: EditSpeakScreen(comments: '-'),
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
                              },
                            ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                child: Row(
                                  children: [
                                    ClipPath(
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
                                    const SizedBox(width: 10),
                                    ClipPath(
                                      clipper: DoubleTriangleRectangleClipper(),
                                      child: Container(
                                        padding: const EdgeInsets.all(3.0),
                                        color: Colors
                                            .red, // Change color as needed
                                        child: Center(
                                          child: ATextLabelSmall(
                                            text:
                                                'เล่มสีแดง ${textTitleReplace.getBookRed(dataTitle[index])}', // Access widget property
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    audioPlayerManager.stop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Tri91PageViewHtml(
                          triBookid: textTitleReplace.getBookId(
                            dataTitle[index],
                          ),
                          triPageid: int.parse(
                            textTitleReplace.getPageId(dataTitle[index]),
                          ),
                          triBookline: textTitleReplace.getLineId(
                            dataTitle[index],
                          ),
                          chkSearch: '',
                          isMobile: widget.isMobile,
                          online: widget.online,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 0.6,
                  indent: 12,
                  endIndent: 12,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
