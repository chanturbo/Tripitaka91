import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/pageviews/pageviews.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';

class SearchShowPages extends StatefulWidget {
  final String title;
  final String wordSearch;
  final String bookid;
  final bool isM;

  const SearchShowPages({
    super.key,
    required this.title,
    required this.wordSearch,
    required this.bookid,
    required this.isM,
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

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollController.addListener(_scrollListener);
    _fetchDataTri91();
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
      _fetchDataTri91();
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
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

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

  @override
  Widget build(BuildContext context) {
    String wordHilight = widget.wordSearch;
    RegExp regex = RegExp(r'\s+');
    List<String> outputList = wordHilight.split(regex);

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
            _fetchDataTri91();
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
                    text: textTitleReplace.extractText(data[index]),
                    terms: outputList,
                    textStyle: TextStyle(
                        fontSize: widget.isM ? 18.0 : 16.0,
                        color: Colors.black),
                  ),
                  subtitle: Row(
                    children: [
                      InkWell(
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
                      ),
                      // const SizedBox(width: 10),
                      // InkWell(
                      //   onTap: () async {},
                      //   child: Icon(
                      //     Icons.share,
                      //     size: 16,
                      //     color: Colors.blue[300],
                      //   ),
                      // ),
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
                        builder: (context) => Tri91PageView(
                          triBookid: textTitleReplace.getBookId(data[index]),
                          triPageid: int.parse(
                              textTitleReplace.getPageId(data[index])),
                          triBookline: textTitleReplace.getLineId(data[index]),
                          chkSearch: widget.wordSearch,
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
