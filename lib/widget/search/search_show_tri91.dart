import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/pageviews/pageviews_html.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/img_service/shared_image_book.dart';
import 'package:tripitaka91/widget/volume_helper/volume_helper.dart';

class SearchShowPages extends StatefulWidget {
  final String title;
  final String wordSearch;
  final String bookid;
  final bool isM;
  final String catalog;
  final bool online;

  const SearchShowPages({
    super.key,
    required this.title,
    required this.wordSearch,
    required this.bookid,
    required this.isM,
    required this.catalog,
    required this.online,
  });

  @override
  State<SearchShowPages> createState() => _SearchShowPagesState();
}

class _SearchShowPagesState extends State<SearchShowPages> {
  List<String> data = [];
  int loadedRecords = 0;
  bool loading = false;
  int page = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollController = ScrollController();

  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  final SharedImageBook sharedImageGenerator = SharedImageBook();
  final volumeHelper = VolumeHelper();
  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollController.addListener(_scrollListener);
    widget.online ? _fetchDataTri91() : _fetchDataTri91DB();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      widget.online ? _fetchDataTri91() : _fetchDataTri91DB();
    }
  }

  Future<void> _fetchDataTri91DB() async {
    int recordsPerPage = 10; // จำนวนข้อมูลที่ต้องการดึงต่อหน้า
    if (!loading) {
      setState(() {
        loading = true;
      });

      try {
        // ดึงข้อมูลจาก SQLite โดยใช้ fetchTri91
        List<String> newData = await DatabaseHelper().fetchTri91(
          int.parse(widget.bookid),
          widget.wordSearch.replaceAll(' ', '%'),
          (page - 1) * recordsPerPage,
          recordsPerPage,
        );

        setState(() {
          loadedRecords += newData.length;
          data.addAll(newData);
          loading = false;
          page++;
        });
      } catch (e) {
        // จัดการข้อผิดพลาดในกรณีเกิดข้อผิดพลาด
        // ignore: avoid_print
        print('Database Error: $e');
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _fetchDataTri91() async {
    if (!loading) {
      setState(() {
        loading = true;
      });

      Users? users = await getUsersList();
      String tmpUser = 'guest';
      if (users != null) {
        tmpUser = users.username;
      }

      final response = await http.post(
        Uri.parse(tURLShowSearchTri),
        body: {
          'bookid': widget.bookid,
          'wordsearch': widget.wordSearch.replaceAll(' ', '%'),
          'token': tSecretAPIKey,
          'username': tmpUser,
          'page': page.toString(),
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          List<String> newData = List<String>.from(jsonResponse['message']);
          setState(() {
            loadedRecords += newData.length;
            data.addAll(newData);
            loading = false;
            page++;
          });
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
          setState(() {
            loading = false;
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
      '9': '๙'
    };
    return input.split('').map((char) => arabicToThai[char] ?? char).join();
  }

  @override
  Widget build(BuildContext context) {
    String wordHilight = widget.wordSearch;
    RegExp regex = RegExp(r'\s+');
    List<String> finalList = wordHilight.split(regex);

// เพิ่มเลขไทยเข้าไป ถ้าพบเลขอารบิกในคำ
    List<String> outputList = finalList.expand((word) {
      String thaiNumber = arabicToThaiNumbers(word);
      return (thaiNumber != word) ? [word, thaiNumber] : [word];
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: ATextDiskplayMedium(
            text: 'ค้นหาคำว่า \'${widget.wordSearch}\' จาก ${widget.title}'),
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (ScrollEndNotification scrollInfo) {
          if (_scrollController.offset >=
                  _scrollController.position.maxScrollExtent &&
              !_scrollController.position.outOfRange) {
            widget.online ? _fetchDataTri91() : _fetchDataTri91DB();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: loadedRecords + (loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == loadedRecords) {
              return loading
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
                        ? textTitleReplace.extractText(data[index])
                        : '[${widget.catalog} เล่ม ${textTitleReplace.getBookId(data[index])} หน้า ${textTitleReplace.getPageId(data[index])} บรรทัด ${textTitleReplace.getLineId(data[index])}]\n${textTitleReplace.extractText(data[index])}',
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
                  subtitle: Row(
                    children: [
                      widget.online || volumeHelper.showVolume
                          ? InkWell(
                              onTap: () async {
                                LoadingDialog.show(context);
                                String bookIds =
                                    textTitleReplace.getBookId(data[index]);
                                String pageId =
                                    textTitleReplace.getPageId(data[index]);
                                String bookLine =
                                    textTitleReplace.getLineId(data[index]);
                                String txtTitle =
                                    textTitleReplace.extractText(data[index]);
                                String filename = '$bookIds-$pageId-$bookLine';
                                await audioPlayerManager.playAudio(
                                    '2', filename, txtTitle);
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
                              textTitleReplace.getBookId(data[index]);
                          String pageId =
                              textTitleReplace.getPageId(data[index]);
                          String bookLine =
                              textTitleReplace.getLineId(data[index]);
                          String txtTitle =
                              textTitleReplace.extractText(data[index]);
                          sharedImageGenerator.generateAndShare(
                            context: context,
                            bookTitle: txtTitle.replaceAll('', ''),
                            bookid: bookIds,
                            pageid: pageId.toString(),
                            lineid: bookLine,
                          );
                        },
                        child: Icon(
                          Icons.share,
                          size: widget.isM ? 21 : 16,
                          color: Colors.blue[300],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          String bookIds =
                              textTitleReplace.getBookId(data[index]);
                          String pageId =
                              textTitleReplace.getPageId(data[index]);
                          String bookLine =
                              textTitleReplace.getLineId(data[index]);
                          String txtTitle =
                              '${textTitleReplace.extractText(data[index])} เล่ม $bookIds หน้า $pageId บรรทัด $bookLine';
                          Clipboard.setData(
                            ClipboardData(
                                text:
                                    '$txtTitle อ่านรายละเอียด -> $tURLmain$bookIds-$pageId-$bookLine.htm'),
                          );
                          _showSnackbar(context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ClipPath(
                          clipper: DoubleTriangleRectangleClipper(),
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            color: Colors.blue[900],
                            child: ATextLabelSmall(
                              text: textTitleReplace
                                  .extractRemainingText(data[index]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    audioPlayerManager.stop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Tri91PageViewHtml(
                          triBookid: textTitleReplace.getBookId(data[index]),
                          triPageid: int.parse(
                              textTitleReplace.getPageId(data[index])),
                          triBookline: textTitleReplace.getLineId(data[index]),
                          chkSearch: widget.wordSearch,
                          isMobile: widget.isM,
                          online: widget.online,
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
