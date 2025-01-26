import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/img_service/shared_image_generator.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/utils/video/video_utils.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/pageviews/pageviews_html.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/widget/volume_helper/volume_helper.dart';

class SearchShowPagesTitle extends StatefulWidget {
  final String wordSearch;
  final bool isM;
  final bool online;

  const SearchShowPagesTitle({
    super.key,
    required this.wordSearch,
    required this.isM,
    required this.online,
  });

  @override
  State<SearchShowPagesTitle> createState() => _SearchShowPagesTitleState();
}

class _SearchShowPagesTitleState extends State<SearchShowPagesTitle> {
  List<String> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollControllerTitle = ScrollController();

  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  final SharedImageGenerator sharedImageGenerator = SharedImageGenerator();
  final SharedImageLocal sharedImageLocal = SharedImageLocal();
  final VideoGenerator videoGenerator = VideoGenerator();
  final volumeHelper = VolumeHelper();
  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollControllerTitle.addListener(_scrollListener);
    widget.online ? _fetchDataTitle() : _fetchDataTitleDB();
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
      widget.online ? _fetchDataTitle() : _fetchDataTitleDB();
    }
  }

  Future<void> _fetchDataTitleDB() async {
    int recordsPerPage = 10;
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      try {
        List<String> newData = await DatabaseHelper().fetchTitles(
          widget.wordSearch.replaceAll(' ', '%'),
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
        Uri.parse(tURLtitleSearch),
        body: {
          'wordsearch': widget.wordSearch.replaceAll(' ', '%'),
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

  @override
  Widget build(BuildContext context) {
    String wordHilight = widget.wordSearch;
    RegExp regex = RegExp(r'\s+');
    List<String> outputList = wordHilight.split(regex);

    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            widget.online ? _fetchDataTitle() : _fetchDataTitleDB();
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
                  title: SubstringHighlight(
                    text: widget.isM
                        ? textTitleReplace
                            .extractText(dataTitle[index])
                            .replaceAll(
                                textTitleReplace.getBookBlue(dataTitle[index]),
                                '')
                        : textTitleReplace.getCategory(dataTitle[index]) ==
                                'รวมหัวข้อธรรมสำคัญ 91เล่ม'
                            ? '[${textTitleReplace.getCategory(dataTitle[index])} - ${textTitleReplace.getDetail(dataTitle[index])}]\n${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')}'
                            : '[${textTitleReplace.getCategory(dataTitle[index])} เล่ม ${textTitleReplace.getBookId(dataTitle[index])} หน้า ${textTitleReplace.getPageId(dataTitle[index])} บรรทัด ${textTitleReplace.getLineId(dataTitle[index])}]\n${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')}',
                    terms: outputList,
                    textStyle: TextStyle(
                        fontFamily: widget.isM
                            ? 'Roboto'
                            : kIsWeb
                                ? 'THSarabunNew'
                                : 'Roboto',
                        fontSize: widget.isM
                            ? 18.0
                            : kIsWeb
                                ? 24.0
                                : 16.0,
                        color: Colors.black),
                  ),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          widget.online || volumeHelper.showVolume
                              ? InkWell(
                                  onTap: () async {
                                    LoadingDialog.show(context);
                                    String bookIds = textTitleReplace
                                        .getBookId(dataTitle[index]);
                                    String pageId = textTitleReplace
                                        .getPageId(dataTitle[index]);
                                    String bookLine = textTitleReplace
                                        .getLineId(dataTitle[index]);
                                    String noTitleCate = textTitleReplace
                                        .getCate(dataTitle[index]);
                                    String noTitle = textTitleReplace
                                        .getNo(dataTitle[index]);

                                    String txtTitle =
                                        textTitleReplace.replaceText(
                                            textTitleReplace
                                                .extractText(dataTitle[index]),
                                            textTitleReplace
                                                .getBookBlue(dataTitle[index]));

                                    String filename =
                                        noTitleCate.replaceAll('.', '');
                                    filename =
                                        '$filename-$noTitle-$bookIds-$pageId-$bookLine';
                                    await audioPlayerManager.playAudio(
                                        '1', filename, txtTitle);
                                    // ignore: use_build_context_synchronously
                                    LoadingDialog.hide(context);
                                  },
                                  child: Icon(
                                    Icons.volume_up,
                                    size: widget.isM ? 25 : 20,
                                    color: Colors.blue[300],
                                  ),
                                )
                              : const Text(''),
                          widget.online || volumeHelper.showVolume
                              ? const SizedBox(width: 10)
                              : const SizedBox.shrink(),
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
                              // txtTitle +=
                              //     'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                              // await Share.share(
                              //     '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm',
                              //     subject: 'สรุปหัวข้อธรรมจากพระไตรปิฎก');

                              sharedImageGenerator.generateAndShare(
                                context: context,
                                bookTitle: txtTitle.replaceAll('', ''),
                                bookid: bookIds,
                                pageid: pageId.toString(),
                                lineid: bookLine,
                                bookBlue: textTitleReplace
                                    .getBookBlue(dataTitle[index]),
                                bookRed: textTitleReplace
                                    .getBookRed(dataTitle[index]),
                              );
                            },
                            child: Icon(
                              Icons.share,
                              size: widget.isM ? 21 : 16,
                              color: Colors.blue[300],
                            ),
                          ),
                          const SizedBox(width: 10),
                          widget.online
                              ? InkWell(
                                  onTap: () async {
                                    LoadingDialog.show(context);
                                    String bookIds = textTitleReplace
                                        .getBookId(dataTitle[index]);
                                    String pageId = textTitleReplace
                                        .getPageId(dataTitle[index]);
                                    String bookLine = textTitleReplace
                                        .getLineId(dataTitle[index]);
                                    String noTitleCate = textTitleReplace
                                        .getCate(dataTitle[index]);
                                    String noTitle = textTitleReplace
                                        .getNo(dataTitle[index]);

                                    String txtTitle =
                                        textTitleReplace.replaceText(
                                            textTitleReplace
                                                .extractText(dataTitle[index]),
                                            textTitleReplace
                                                .getBookBlue(dataTitle[index]));

                                    String filename =
                                        noTitleCate.replaceAll('.', '');
                                    filename =
                                        '$filename-$noTitle-$bookIds-$pageId-$bookLine';
                                    String? urlMp3 = await audioPlayerManager
                                        .createAudio('1', filename, txtTitle);
                                    if (urlMp3 != null) {
                                      String bookIds = textTitleReplace
                                          .getBookId(dataTitle[index]);
                                      String pageId = textTitleReplace
                                          .getPageId(dataTitle[index]);
                                      String bookLine = textTitleReplace
                                          .getLineId(dataTitle[index]);
                                      String txtTitle =
                                          '${textTitleReplace.extractText(dataTitle[index]).replaceAll(textTitleReplace.getBookBlue(dataTitle[index]), '')} ';

                                      final String? imagePath =
                                          // ignore: use_build_context_synchronously
                                          await sharedImageLocal
                                              .generateAndSave(
                                        context: context,
                                        bookTitle: txtTitle.replaceAll('', ''),
                                        bookid: bookIds,
                                        pageid: pageId.toString(),
                                        lineid: bookLine,
                                        bookBlue: textTitleReplace
                                            .getBookBlue(dataTitle[index]),
                                        bookRed: textTitleReplace
                                            .getBookRed(dataTitle[index]),
                                      );

                                      if (imagePath != null) {
                                        // print('Image saved at $imagePath');
                                        await videoGenerator
                                            .generateAndSaveVideo(
                                                imagePath, urlMp3);
                                        // ignore: use_build_context_synchronously
                                        _showSnackbar(context,
                                            'บันทึกวิดีโอสำเร็จในแกลเลอรี่.');
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        _showSnackbar(context,
                                            'ไม่สามารถบันทึกไฟล์รูปภาพได้.');
                                      }
                                    } else {
                                      // ถ้า url เป็น null สามารถจัดการได้ตามที่ต้องการ
                                      // ignore: use_build_context_synchronously
                                      _showSnackbar(
                                          context, "ไม่สามารถสร้าง URL ได้.");
                                    }
                                    // ignore: use_build_context_synchronously
                                    LoadingDialog.hide(context);
                                  },
                                  child: Icon(
                                    Icons.videocam,
                                    size: widget.isM ? 23 : 18,
                                    color: Colors
                                        .blue[300], // Change color as needed
                                  ),
                                )
                              : const Text(''),
                          widget.online
                              ? const SizedBox(width: 10)
                              : const SizedBox.shrink(),
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
                              size: widget.isM ? 21 : 16,
                              color: Colors.blue[300],
                            ),
                          ),
                          const Expanded(
                            child: SizedBox(
                              child: Text(''),
                            ),
                          ),
                          widget.isM
                              ? const SizedBox.shrink()
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
                          const SizedBox(width: 10),
                          widget.isM
                              ? const SizedBox.shrink()
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
                      widget.isM
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
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
                                const SizedBox(width: 10),
                                Align(
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
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  onTap: () {
                    audioPlayerManager.stop();
                    if (textTitleReplace.getBookId(dataTitle[index]) == '0') {
                      _showSnackbar(context,
                          'กรุณาดูรายละเอียดในหัวข้อหนังสือแนะนำ หนังสืออุทิศบุญที่ได้ผล หน้า 68');
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Tri91PageViewHtml(
                            triBookid:
                                textTitleReplace.getBookId(dataTitle[index]),
                            triPageid: int.parse(
                                textTitleReplace.getPageId(dataTitle[index])),
                            triBookline:
                                textTitleReplace.getLineId(dataTitle[index]),
                            chkSearch: widget.wordSearch,
                            isMobile: widget.isM,
                            online: widget.online,
                          ),
                        ),
                      );
                    }
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
