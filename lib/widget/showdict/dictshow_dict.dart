import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/scroll/scroll_button.dart';
import 'package:tripitaka91/widget/showdict/show_dict_list.dart';
import 'package:tripitaka91/widget/showdict/show_dict_list_2.dart';

class DictShowTitle extends StatefulWidget {
  final bool online;
  const DictShowTitle({
    super.key,
    required this.online,
  });

  @override
  State<DictShowTitle> createState() => _DictShowTitleState();
}

class _DictShowTitleState extends State<DictShowTitle> {
  String dictSarabun = '...';
  final ScrollController _scrollControllerListView = ScrollController();
  bool loadFirst = false;
  List<String> dataDict = [];
  late TextTitleReplace textTitleReplace;

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeDictSarabun(String newDictSarabun) {
    setState(() {
      dictSarabun = newDictSarabun;
      if (loadFirst) {
        loadFirst = false;
      } else {
        loadFirst = true;
      }
    });
  }

  Future<String> loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    // ประมวลผลข้อมูลจาก searchQuery และ title ตามความต้องการ
    return "Data loaded for and $dictSarabun";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ATextDiskplayMedium(
          text:
              'พจนานุกรม ฉบับประมวลศัพท์ รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต)',
        ),
      ),
      body: SizedBox(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double
                  .infinity, // กำหนดให้ Container มีความกว้างเท่ากับหน้าจอ
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ScrollControlButton(
                        scrollController: _scrollControllerListView,
                        offset: 150,
                        buttonText: '<-เลื่อน',
                        isLeftButton: true,
                        color: TColors.secondary,
                      ),
                      ScrollControlButton(
                        scrollController: _scrollControllerListView,
                        offset: 150,
                        buttonText: 'เลื่อน->',
                        isLeftButton: false,
                        color: TColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: ListView.builder(
                controller: _scrollControllerListView,
                scrollDirection: Axis.horizontal,
                itemCount: thaikeyboard.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: InkWell(
                      onTap: () {
                        changeDictSarabun(thaikeyboard[index].toString());
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 20,
                        child: ATextDiskplayMedium(
                          text: thaikeyboard[index].toString(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: dictSarabun == '...'
                    ? loadFirst
                        ? ShowPagesDictList(
                            wordSearch: dictSarabun,
                            online: widget.online,
                          )
                        : ShowPagesDictList2(
                            wordSearch: dictSarabun,
                            online: widget.online,
                          )
                    : loadFirst
                        ? ShowPagesDictList(
                            wordSearch: dictSarabun,
                            online: widget.online,
                          )
                        : ShowPagesDictList2(
                            wordSearch: dictSarabun,
                            online: widget.online,
                          )
                // : FutureBuilder(
                //     future: _fetchDataDict(),
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState ==
                //           ConnectionState.waiting) {
                //         return const Center(
                //           child: CircularProgressIndicator(),
                //         );
                //       } else if (snapshot.hasError) {
                //         return Center(
                //           child: Text('Error: ${snapshot.error}'),
                //         );
                //       } else {
                //         //print(snapshot.data?.length);

                //         return (snapshot.data?.length == null)
                //             ? const Center(
                //                 child: ATextTitleLarge(text: 'ไม่พบข้อมูล'))
                //             : ListView.builder(
                //                 shrinkWrap: true,
                //                 itemCount: dataDict.length,
                //                 itemBuilder:
                //                     (BuildContext context, int index) {
                //                   return Column(
                //                     children: [
                //                       ListTile(
                //                         leading: CircleAvatar(
                //                           backgroundColor: Colors.blue[900],
                //                           foregroundColor: Colors.white,
                //                           child: ATextDiskplayMedium(
                //                               text: '${index + 1}'),
                //                         ),
                //                         title: ATextTitleMedium(
                //                           text:
                //                               '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}',
                //                         ),
                //                         subtitle: Row(
                //                           children: [
                //                             InkWell(
                //                               onTap: () async {
                //                                 LoadingDialog.show(context);
                //                                 String txtTitle =
                //                                     '${textTitleReplace.getWordDict(dataDict[index])} - ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                //                                 String namesave =
                //                                     textTitleReplace
                //                                         .getWordDict(
                //                                             dataDict[index])
                //                                         .trim()
                //                                         .replaceAll(
                //                                             RegExp(r'\s+'),
                //                                             '');

                //                                 String filename =
                //                                     'dict-$namesave';
                //                                 await audioPlayerManager
                //                                     .playAudio('3', filename,
                //                                         txtTitle);
                //                                 // ignore: use_build_context_synchronously
                //                                 LoadingDialog.hide(context);
                //                               },
                //                               child: Icon(
                //                                 Icons.volume_up,
                //                                 size: 20,
                //                                 color: Colors.blue[300],
                //                               ),
                //                             ),
                //                             const SizedBox(width: 10),
                //                             InkWell(
                //                               onTap: () async {
                //                                 String txtTitle =
                //                                     '${textTitleReplace.getWordDict(dataDict[index])}\n- ${textTitleReplace.getWordDictDetail(dataDict[index])}';
                //                                 txtTitle +=
                //                                     ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์ รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต)';
                //                                 await Share.share(txtTitle,
                //                                     subject:
                //                                         'พจนานุกรม ฉบับประมวลศัพท์');
                //                               },
                //                               child: Icon(
                //                                 Icons.share,
                //                                 size: 16,
                //                                 color: Colors.blue[300],
                //                               ),
                //                             ),
                //                             const SizedBox(width: 10),
                //                             InkWell(
                //                               onTap: () async {
                //                                 String txtTitle =
                //                                     '${textTitleReplace.getWordDict(dataDict[index])}\n${textTitleReplace.getWordDictDetail(dataDict[index])}';
                //                                 txtTitle +=
                //                                     ' ข้อความจากพจนานุกรม ฉบับประมวลศัพท์ รวบรวมโดย พระพรหมคุณาภรณ์ (ป.อ. ปยุตฺโต)';
                //                                 Clipboard.setData(
                //                                   ClipboardData(
                //                                       text: txtTitle),
                //                                 );
                //                                 _showSnackbar(context,
                //                                     'คัดลอกข้อมูลเรียบร้อยแล้ว');
                //                               },
                //                               child: Icon(
                //                                 Icons.copy,
                //                                 size: 16,
                //                                 color: Colors.blue[300],
                //                               ),
                //                             ),
                //                             const Expanded(
                //                               child: SizedBox(
                //                                 child: Text(''),
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                         onTap: () {},
                //                       ),
                //                     ],
                //                   );
                //                 },
                //               );
                //       }
                //     },
                //   ),
                ),
          ],
        ),
      ),
    );
  }

  // Future<List<String>?> _fetchDataDict() async {
  //   audioPlayerManager.stop();
  //   Users? users = await getUsersList();
  //   String tmpUser = 'guest';
  //   if (users != null) {
  //     tmpUser = users.username;
  //   }

  //   final response = await http.post(
  //     Uri.parse(tURLtitleDictAll),
  //     body: {
  //       'wordsearch': dictSarabun,
  //       'token': tSecretAPIKey,
  //       'username': tmpUser,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     var json = response.body;
  //     var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

  //     if (jsonResponse['success'] == true) {
  //       dataDict = List<String>.from(jsonResponse['message']);
  //       return dataDict;
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       _showSnackbar(context, '${jsonResponse['message']}');
  //     }
  //   } else {
  //     // ignore: avoid_print
  //     print('HTTP Error: ${response.statusCode}');
  //   }
  //   return null;
  // }

  // void _showSnackbar(BuildContext context, String info) {
  //   final snackBar = SnackBar(
  //     content: Text(info),
  //     duration: const Duration(seconds: 1),
  //   );

  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }
}
