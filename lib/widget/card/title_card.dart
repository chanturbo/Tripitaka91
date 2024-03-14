import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:http/http.dart' as http;

class TitleCard extends StatefulWidget {
  final String triTitle;
  final String bookBlue;
  final String bookRed;
  final String bookIds;
  final String bookLine;
  final int pageId;
  final String noTitle;
  final String noTitleCate;
  final bool isMobile;

  const TitleCard({
    super.key,
    required this.triTitle,
    required this.bookBlue,
    required this.bookRed,
    required this.bookLine,
    required this.bookIds,
    required this.pageId,
    required this.noTitle,
    required this.noTitleCate,
    required this.isMobile,
  });

  @override
  State<TitleCard> createState() => _TitleCardState();
}

class _TitleCardState extends State<TitleCard> {
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  final TextTitleReplace textReplacer = TextTitleReplace();
  // final MyNotifier iconNotifier = MyNotifier(true);
  Users? usersChk;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    usersChk = await getUsersList();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _showInputDialog(BuildContext context, String initialText,
      String tripitaka91No, String tripitaka91Code) {
    final TextEditingController textController =
        TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          title: const Text(
            'แก้ไขข้อมูลหัวข้อธรรม (สำหรับ Admin เท่านั้น)',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
          ),
          content: TextFormField(
            style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 26),
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'กรอกข้อมูลที่นี่',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดหน้าต่าง
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usersChk != null) {
                  // ทำสิ่งที่ต้องการเมื่อกดปุ่มบันทึกข้อมูล
                  String inputData = textController.text;
                  if (inputData == '') {
                    _showSnackbar(context, 'กรุณาป้อนข้อมูลให้ครบถ้วน');
                  } else {
                    // อาจทำการใช้ข้อมูลที่ป้อนเข้ามาต่อไป
                    // print(
                    //     'ข้อมูลที่ป้อน: $inputData เล่ม $bookid หน้า $bookpage บรรทัด $bookline');
                    bool? confirm = await _showConfirmationDialog(context);
                    if (confirm!) {
                      await _fetchUpdateTitle(
                          inputData, tripitaka91No, tripitaka91Code);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(); // ปิดหน้าต่าง
                    }
                  }
                } else {
                  _showSnackbar(context, 'กรุณาเข้าสู่ระบบก่อน');
                  Navigator.of(context).pop(); // ปิดหน้าต่าง
                }
              },
              child: const Text(
                ' บันทึกข้อมูล ',
                style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchUpdateTitle(
      String initialText, String tripitaka91No, String tripitaka91Code) async {
    final response = await http.post(
      Uri.parse(tURLtitleEdit),
      body: {
        'token': tSecretAPIKey,
        'tripitaka91no': tripitaka91No,
        'tripitaka91code': tripitaka91Code,
        'titledetail': initialText,
        'username': usersChk!.username,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการดำเนินการ'),
          content: const Text('คุณต้องการดำเนินการต่อ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // ปิดหน้าต่างและส่งค่า false กลับ
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // ปิดหน้าต่างและส่งค่า true กลับ
              },
              child: const Text(' ยืนยัน '),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //final audioPlayerProvider = context.watch<AudioPlayerProvider>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              onTap: () {
                audioPlayerManager.stop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Tri91PageView(
                      triBookid: widget.bookIds,
                      triPageid: widget.pageId,
                      triBookline: widget.bookLine,
                      chkSearch: '',
                      isMobile: widget.isMobile,
                    ),
                  ),
                );
              },
              title: widget.isMobile
                  ? Text(
                      widget.triTitle.replaceAll('', ''),
                      style:
                          const TextStyle(fontFamily: 'Roboto', fontSize: 18),
                    )
                  : ATextTitleMedium(text: widget.triTitle.replaceAll('', '')),
            ),
            Container(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(width: 15),
                InkWell(
                  onTap: () async {
                    LoadingDialog.show(context);
                    String txtTitle = textReplacer.replaceText(
                        widget.triTitle, widget.bookBlue);

                    String filename = widget.noTitleCate.replaceAll('.', '');
                    filename =
                        '$filename-${widget.noTitle}-${widget.bookIds}-${widget.pageId}-${widget.bookLine}';
                    await audioPlayerManager.playAudio('1', filename, txtTitle);
                    // ignore: use_build_context_synchronously
                    LoadingDialog.hide(context);
                  },
                  child: Icon(
                    Icons.volume_up,
                    size: widget.isMobile ? 25 : 20,
                    color: Colors.blue[300], // Change color as needed
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    String txtTitle = textReplacer.replaceText(
                        widget.triTitle, widget.bookBlue);
                    txtTitle +=
                        'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม ${widget.bookIds} หน้า ${widget.pageId} บรรทัด ${widget.bookLine}';
                    await Share.share(
                        '$txtTitle อ่านรายละเอียด -> $tURLmain${widget.bookIds}-${widget.pageId}-${widget.bookLine}.htm',
                        subject: 'สรุปหัวข้อธรรมจากพระไตรปิฎก');
                  },
                  child: Icon(
                    Icons.share,
                    size: widget.isMobile ? 23 : 18,
                    color: Colors.blue[300], // Change color as needed
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    String txtTitle = textReplacer.replaceText(
                        widget.triTitle, widget.bookBlue);
                    txtTitle +=
                        'สรุปเนื้อความจากพระไตรปิฎก ฉบับ มมร. เล่ม ${widget.bookIds} หน้า ${widget.pageId} บรรทัด ${widget.bookLine}';
                    Clipboard.setData(
                      ClipboardData(
                          text:
                              '$txtTitle อ่านรายละเอียด -> $tURLmain${widget.bookIds}-${widget.pageId}-${widget.bookLine}.htm'),
                    );
                    _showSnackbar(context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                  },
                  child: Icon(
                    Icons.copy,
                    size: widget.isMobile ? 23 : 18,
                    color: Colors.blue[300], // Change color as needed
                  ),
                ),
                (usersChk != null) && (usersChk?.levelAccess == '1')
                    ? const SizedBox(width: 10)
                    : const SizedBox.shrink(),
                (usersChk != null) && (usersChk?.levelAccess == '1')
                    ? InkWell(
                        onTap: () async {
                          _showInputDialog(
                            context,
                            widget.triTitle,
                            widget.noTitle,
                            widget.noTitleCate,
                          );
                        },
                        child: Icon(
                          Icons.edit,
                          size: widget.isMobile ? 21 : 16,
                          color: Colors.blue[300],
                        ),
                      )
                    : const SizedBox.shrink(),
                widget.isMobile
                    ? const SizedBox.shrink()
                    : const SizedBox(width: 10),
                widget.isMobile
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: ClipPath(
                          clipper: DoubleTriangleRectangleClipper(),
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            color: Colors.blue, // Change color as needed
                            child: Center(
                              child: ATextLabelSmall(
                                text: 'เล่มสีน้ำเงิน ${widget.bookBlue}',
                              ),
                            ),
                          ),
                        ),
                      ),
                widget.isMobile
                    ? const SizedBox.shrink()
                    : const SizedBox(width: 10),
                widget.isMobile
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: ClipPath(
                          clipper: DoubleTriangleRectangleClipper(),
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            color: Colors.red, // Change color as needed
                            child: Center(
                              child: ATextLabelSmall(
                                text:
                                    'เล่มสีแดง ${widget.bookRed}', // Access widget property
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            widget.isMobile
                ? const SizedBox(height: 10)
                : const SizedBox.shrink(),
            widget.isMobile
                ? Row(
                    children: [
                      const SizedBox(width: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ClipPath(
                          clipper: DoubleTriangleRectangleClipper(),
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            color: Colors.blue, // Change color as needed
                            child: Center(
                              child: ATextDiskplaySmall(
                                  text: 'เล่มสีน้ำเงิน ${widget.bookBlue}'),
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
                            color: Colors.red, // Change color as needed
                            child: Center(
                              child: ATextDiskplaySmall(
                                  text: 'เล่มสีแดง ${widget.bookRed}'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
