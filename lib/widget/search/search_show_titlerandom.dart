import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:substring_highlight/substring_highlight.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/img_service/shared_image_generator.dart';
import 'package:tripitaka91/utils/models/tripitaka91_random.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/features/book/pageviews_html.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/volume_helper/volume_helper.dart';

class SearchShowPagesTitleRandom extends StatefulWidget {
  final String wordSearch;
  final bool isM;
  final bool online;

  const SearchShowPagesTitleRandom({
    super.key,
    required this.wordSearch,
    required this.isM,
    required this.online,
  });

  @override
  State<SearchShowPagesTitleRandom> createState() =>
      _SearchShowPagesTitleRandomState();
}

class _SearchShowPagesTitleRandomState
    extends State<SearchShowPagesTitleRandom> {
  List<TripitakaResult> dataTitleRandom = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;

  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  final SharedImageGenerator sharedImageGenerator = SharedImageGenerator();
  final volumeHelper = VolumeHelper();

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();

    _fetchDataTitle();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
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
        Uri.parse(tURLtitleSearchRandom),
        body: {
          'wordsearch': widget.wordSearch.replaceAll(' ', '%'),
          'token': tSecretAPIKey,
          'username': tmpUser,
          'page': pageTitle.toString(),
        },
      );

      if (response.statusCode == 200) {
        var responseBody = response.body;
        var jsonResponse = json.decode(responseBody);

        if (jsonResponse['success'] == true) {
          List<TripitakaResult> newData = (jsonResponse['message'] as List)
              .map((item) => TripitakaResult.fromJson(item))
              .toList();

          setState(() {
            loadedRecordsTitle = newData.length;
            dataTitleRandom.addAll(newData);
            loadingTitle = false;
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
      body: ListView.builder(
        itemCount: loadedRecordsTitle,
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
                      ? dataTitleRandom[index].content
                      : '[เล่ม ${dataTitleRandom[index].tripitakaBook} หน้า ${dataTitleRandom[index].tripitakaPage} บรรทัด ${dataTitleRandom[index].tripitakaLine}]\n${dataTitleRandom[index].content}',
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
                      color: adaptiveTextColor(context)),
                ),
                subtitle: Column(
                  children: [
                    Row(
                      children: [
                        widget.online || volumeHelper.showVolume
                            ? InkWell(
                                onTap: () async {
                                  LoadingDialog.show(context);
                                  String bookIds = dataTitleRandom[index]
                                      .tripitakaBook
                                      .toString();
                                  String pageId = dataTitleRandom[index]
                                      .tripitakaPage
                                      .toString();
                                  String bookLine = dataTitleRandom[index]
                                      .tripitakaLine
                                      .toString();
                                  String noTitleCate = dataTitleRandom[index]
                                      .tripitakaCode
                                      .toString();
                                  String noTitle = dataTitleRandom[index]
                                      .tripitakaNo
                                      .toString();
                                  String txtTitle =
                                      dataTitleRandom[index].content;
                                  String filename =
                                      noTitleCate.replaceAll('.', '');
                                  filename =
                                      '$filename-$noTitle-$bookIds-$pageId-$bookLine-s';
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
                                dataTitleRandom[index].tripitakaBook.toString();
                            String pageId =
                                dataTitleRandom[index].tripitakaPage.toString();
                            String bookLine =
                                dataTitleRandom[index].tripitakaLine.toString();
                            String txtTitle = dataTitleRandom[index].content;
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
                                          'เล่ม ${dataTitleRandom[index].tripitakaBook} หน้า ${dataTitleRandom[index].tripitakaPage} บรรทัด ${dataTitleRandom[index].tripitakaLine}',
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
                                          'เล่ม ${dataTitleRandom[index].tripitakaBook} หน้า ${dataTitleRandom[index].tripitakaPage} บรรทัด ${dataTitleRandom[index].tripitakaLine}',
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
                  if ((dataTitleRandom[index].tripitakaBook == 0) ||
                      (dataTitleRandom[index].content == "กฎหมายทั่วไป")) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Tri91PageViewHtml(
                          triBookid: '1',
                          triPageid: 0,
                          triBookline:
                              dataTitleRandom[index].tripitakaLine.toString(),
                          chkSearch: widget.wordSearch,
                          isMobile: widget.isM,
                          online: true,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Tri91PageViewHtml(
                          triBookid:
                              dataTitleRandom[index].tripitakaBook.toString(),
                          triPageid: dataTitleRandom[index].tripitakaPage,
                          triBookline:
                              dataTitleRandom[index].tripitakaLine.toString(),
                          chkSearch: widget.wordSearch,
                          isMobile: widget.isM,
                          online: true,
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
    );
  }
}
