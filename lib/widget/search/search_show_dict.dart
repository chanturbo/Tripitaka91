import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';

class SearchShowPagesDict extends StatefulWidget {
  final String wordSearch;
  final bool isM;

  const SearchShowPagesDict(
      {super.key, required this.wordSearch, required this.isM});

  @override
  State<SearchShowPagesDict> createState() => _SearchShowPagesDictState();
}

class _SearchShowPagesDictState extends State<SearchShowPagesDict> {
  List<String> dataDict = [];
  int loadedRecordsDict = 0;
  bool loadingDict = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollControllerDict = ScrollController();

  AudioPlayerManager audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollControllerDict.addListener(_scrollListener);
    _fetchDataDict();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollControllerDict.offset >=
            _scrollControllerDict.position.maxScrollExtent &&
        !_scrollControllerDict.position.outOfRange) {
      _fetchDataDict();
    }
  }

  Future<void> _fetchDataDict() async {
    if (!loadingDict) {
      setState(() {
        loadingDict = true;
      });

      Users? users = await getUsersList();
      String tmpUser = 'guest';
      if (users != null) {
        tmpUser = users.username;
      }

      final response = await http.post(
        Uri.parse(tURLtitleDict),
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
            loadedRecordsDict += newData.length;
            dataDict.addAll(newData);
            loadingDict = false;
            pageTitle++;
          });
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
          setState(() {
            loadingDict = false;
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
            _fetchDataDict();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollControllerDict,
          itemCount: loadedRecordsDict + 1,
          itemBuilder: (context, index) {
            if (index == loadedRecordsDict) {
              return loadingDict
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
                    text:
                        '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}',
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
                          size: widget.isM ? 25 : 20,
                          color: Colors.blue[300],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          String txtTitle =
                              '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                          txtTitle += ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์';
                          await Share.share(txtTitle,
                              subject: 'พจนานุกรม ฉบับประมวลศัพท์');
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
                          String txtTitle =
                              '${textTitleReplace.getWordDict(dataDict[index])}\n${textTitleReplace.getWordDictDetail(dataDict[index])}';
                          txtTitle +=
                              ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์ รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต)';
                          Clipboard.setData(
                            ClipboardData(text: txtTitle),
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
                    ],
                  ),
                  onTap: () {},
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
