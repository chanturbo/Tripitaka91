import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/dialogs/online_speech_consent_dialog.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/volume_helper/volume_helper.dart';

class ShowPagesDictList extends StatefulWidget {
  final String wordSearch;
  final bool online;
  const ShowPagesDictList({
    super.key,
    required this.wordSearch,
    required this.online,
  });

  @override
  State<ShowPagesDictList> createState() => _ShowPagesDictListState();
}

class _ShowPagesDictListState extends State<ShowPagesDictList> {
  List<String> dataDict = [];
  int loadedRecordsDict = 0;
  bool loadingDict = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollControllerDict = ScrollController();

  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  final volumeHelper = VolumeHelper();
  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollControllerDict.addListener(_scrollListener);
    widget.online ? _fetchDataDict() : _fetchDataDictDB();
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
      widget.online ? _fetchDataDict() : _fetchDataDictDB();
    }
  }

  Future<void> _fetchDataDictDB() async {
    int recordsPerPage = 10; // จำนวนข้อมูลที่ต้องการดึงต่อหน้า
    if (!loadingDict) {
      setState(() {
        loadingDict = true;
      });

      try {
        // ดึงข้อมูลจากฐานข้อมูล SQLite โดยใช้ fetchDict
        List<String> newData = await DatabaseHelper().fetchDictAll(
          widget.wordSearch.replaceAll(' ', '%'),
          (pageTitle - 1) * recordsPerPage,
          recordsPerPage,
        );

        setState(() {
          loadedRecordsDict += newData.length;
          dataDict.addAll(newData);
          loadingDict = false;
          pageTitle++;
        });
      } catch (e) {
        // จัดการกรณีเกิดข้อผิดพลาด
        // ignore: avoid_print
        print('Database Error: $e');
        setState(() {
          loadingDict = false;
        });
      }
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
        Uri.parse(tURLtitleDictAll),
        body: {
          'wordsearch': widget.wordSearch,
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
    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            widget.online ? _fetchDataDict() : _fetchDataDictDB();
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
                  : (loadedRecordsDict == 0)
                      ? SizedBox(
                          child: Center(
                            child: ATextTitleLarge(
                                text:
                                    'คำศัพท์หมวด \'${widget.wordSearch}\' ไม่พบข้อมูล'),
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
                  title: ATextTitleMediumTH(
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
                              ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์ รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต)';
                          await SharePlus.instance.share(ShareParams(
                              text: txtTitle,
                              subject: 'พจนานุกรม ฉบับประมวลศัพท์'));
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
                          _showSnackbar(context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
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
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
