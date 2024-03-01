import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/pageviews/pageviews.dart';
import 'package:tripitaka91/widget/right_clipper/center_clipper.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
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
                    ),
                  ),
                );
              },
              title: widget.isMobile
                  ? Text(
                      widget.triTitle.replaceAll('', ''),
                      style: Theme.of(context).textTheme.titleMedium,
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
                widget.isMobile ? const Text('') : const SizedBox(width: 10),
                widget.isMobile
                    ? const Text('')
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
                widget.isMobile ? const Text('') : const SizedBox(width: 10),
                widget.isMobile
                    ? const Text('')
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
                : const Text(''),
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
