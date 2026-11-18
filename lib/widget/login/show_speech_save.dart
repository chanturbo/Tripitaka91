import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/common/circular_icon_button.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';

class ShowSpeechSave extends StatefulWidget {
  const ShowSpeechSave({super.key});

  @override
  State<ShowSpeechSave> createState() => _ShowSpeechSaveState();
}

class _ShowSpeechSaveState extends State<ShowSpeechSave> {
  List<dynamic> dataTitle = [];
  bool loadingTitle = false;
  int pageTitle = 1;
  int loadedRecordsTitle = 0;
  bool _isListView = false;
  late TextTitleReplace textTitleReplace;
  late String opt = '0';
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  List<dynamic> dataUser = [];
  List<dynamic> dataUserCurrect = [];
  final ScrollController _scrollControllerTitle = ScrollController();

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _fetchDataSpeech();
    _scrollControllerTitle.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollControllerTitle.removeListener(_scrollListener);
    _scrollControllerTitle.dispose();
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !loadingTitle) {
      _fetchDataSpeech();
    }
  }

  // เปลี่ยนตัวกรอง (ยังไม่ยืนยัน/ยืนยันแล้ว/แก้ไขแล้ว) แล้วโหลดชุดข้อมูลใหม่ตั้งแต่หน้า 1
  // เพราะเปลี่ยนตัวกรองคือเปลี่ยนชุดข้อมูลทั้งหมด
  void _changeFilter(String newOpt) {
    setState(() {
      opt = newOpt;
      dataTitle = [];
      loadedRecordsTitle = 0;
      pageTitle = 1;
    });
    _fetchDataSpeech();
  }

  Future<void> _fetchDataSpeech() async {
    setState(() {
      loadingTitle = true;
    });

    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }

    final response = await http.post(
      Uri.parse(tURLshowlogSpeechWithAll),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'page': pageTitle.toString(),
        'opt': opt,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        setState(() {
          dataTitle.addAll(newData);
          loadedRecordsTitle = dataTitle.length;
          pageTitle++;
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
      setState(() {
        loadingTitle = false;
      });
    }
  }

  Future<void> _fetchUpdateInsertDataSpeakConfirm(String words) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLupdateSpeakConfirm),
      body: {'token': tSecretAPIKey, 'username': tmpUser, 'words': words},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        _changeFilter('1');
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

  Future<void> _fetchSpeakConfirmSuscess(String words, String wordspeak) async {
    final response = await http.post(
      Uri.parse(tURLsuscessSpeakConfirm),
      body: {
        'token': tSecretAPIKey,
        'wordsearch': words,
        'book_speak': '{$words:$wordspeak}',
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        _changeFilter('2');
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'บันทึกการแก้ไขข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchDataUser(String words) async {
    final response = await http.post(
      Uri.parse(tURLtitleUserInPageSpeak),
      body: {'token': tSecretAPIKey, 'words': words},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        dataUser.clear();
        dataUser.addAll(newData);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDialogUser(BuildContext context, String title, String words) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUser(words),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataUser.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: TColors.buttonPrimary,
                              foregroundColor: Colors.white,
                              child: Text('${index + 1}'),
                            ),
                            title: ATextTitleMedium(
                              text:
                                  '${dataUser[index]['first_nameid']}${dataUser[index]['firstName']}  ${dataUser[index]['lastName']}',
                            ),
                            subtitle: ATextLabelMedium(
                              text:
                                  'วันที่ยืนยัน ${dataUser[index]['tripitaka91_dateconfirm_local']}',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              // Data is still being fetched, show loading indicator or whatever you want
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<void> _fetchDataUserCorrect(String words) async {
    final response = await http.post(
      Uri.parse(tURLtitleUserInPageCorrectSpeak),
      body: {'token': tSecretAPIKey, 'words': words},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        List<dynamic> newData = jsonResponse['message'];
        dataUserCurrect.clear();
        dataUserCurrect.addAll(newData);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showDialogUserCorrect(
    BuildContext context,
    String title,
    String words,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: _fetchDataUserCorrect(words),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Data has been fetched, show the dialog
              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataUserCurrect.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: TColors.buttonPrimary,
                              foregroundColor: Colors.white,
                              child: Text('${index + 1}'),
                            ),
                            title: ATextTitleMedium(
                              text:
                                  '${dataUserCurrect[index]['first_nameid']}${dataUserCurrect[index]['firstName']}  ${dataUserCurrect[index]['lastName']}',
                            ),
                            subtitle: ATextLabelMedium(
                              text:
                                  'วันที่เพิ่มข้อมูล ${dataUserCurrect[index]['tripitaka91_dateadd_local']}',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              // Data is still being fetched, show loading indicator or whatever you want
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("แจ้งเตือน"),
          content: const Text("คุณยังไม่ได้รับสิทธิ์การยืนยันการอ่านออกเสียง"),
          actions: <Widget>[
            TextButton(
              child: const Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                Navigator.of(
                  context,
                ).pop(false); // ปิดหน้าต่างและส่งค่า false กลับ
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(true); // ปิดหน้าต่างและส่งค่า true กลับ
              },
              child: const Text(' ยืนยัน '),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playAudioRecord(dynamic record) async {
    LoadingDialog.show(context);
    String txtTitle = '${record['words_speak']}';
    String namesave = '${record['words']}'.trim().replaceAll(
      RegExp(r'\s+'),
      '',
    );

    String filename = 'tmp-$namesave';
    await audioPlayerManager.playAudio('4', filename, txtTitle);
    // ignore: use_build_context_synchronously
    LoadingDialog.hide(context);
  }

  Future<void> _confirmInsertTap(BuildContext context, dynamic record) async {
    Users? users = await getUsersList();
    if (!context.mounted) return;
    if (users?.permissionVoice == '0') {
      showPermissionDialog(context);
      return;
    }
    bool? confirm = await _showConfirmationDialog(context);
    if (confirm == true) {
      await _fetchUpdateInsertDataSpeakConfirm('${record['words']}');
    }
  }

  Future<void> _confirmEditSuccessTap(
    BuildContext context,
    dynamic record,
  ) async {
    Users? users = await getUsersList();
    if (!context.mounted) return;
    String tmpLevel = users?.levelAccess ?? '2';
    if (tmpLevel != '1') {
      _showSnackbar(context, 'คุณยังไม่ได้รับสิทธิ์ยืนยันการแก้ไขข้อมูล');
      return;
    }
    bool? confirm = await _showConfirmationDialog(context);
    if (!context.mounted) return;
    if (confirm == true) {
      LoadingDialog.show(context);
      await _fetchSpeakConfirmSuscess(
        '${record['words']}',
        '${record['words_speak']}',
      );
      if (!context.mounted) return;
      LoadingDialog.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: adaptivePageColor(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(child: _buildFilterToggle(context)),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isListView ? Icons.view_agenda_outlined : Icons.view_list,
                  ),
                  tooltip: _isListView ? 'แสดงแบบการ์ด' : 'แสดงแบบลิสต์',
                  onPressed: () {
                    setState(() => _isListView = !_isListView);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: dataTitle.isEmpty
                ? Center(
                    child: Text(
                      loadingTitle ? 'กำลังโหลด...' : 'ไม่พบข้อมูล',
                      style: TextStyle(
                        color: adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollControllerTitle,
                    padding: const EdgeInsets.all(12),
                    itemCount: loadedRecordsTitle + (loadingTitle ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= loadedRecordsTitle) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        );
                      }
                      final record = dataTitle[index];
                      final userTmp = record['username'];
                      return _isListView
                          ? _buildListRow(context, record, index, userTmp)
                          : _buildCard(context, record, index, userTmp);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // แถบปุ่มเลือกตัวกรอง (ยังไม่ยืนยัน/ยืนยันแล้ว/แก้ไขแล้ว) — เดิมมีโค้ดซ้ำกัน
  // สองจุด (แสดงเฉพาะตอนรายการแรกหรือตอนไม่มีข้อมูล) รวมเป็นแถบเดียวที่
  // แสดงตลอดเวลาแทน
  Widget _buildFilterToggle(BuildContext context) {
    Widget buildButton(String value, String label) {
      final selected = opt == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ElevatedButton(
          onPressed: () => _changeFilter(value),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              selected ? TColors.buttonPrimary : adaptiveSurfaceColor(context),
            ),
            foregroundColor: WidgetStateProperty.all<Color>(
              selected ? Colors.white : adaptiveTextColor(context),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: adaptiveBorderColor(context)),
              ),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildButton('0', 'ยังไม่ยืนยัน'),
          buildButton('1', 'ยืนยันแล้ว'),
          buildButton('2', 'แก้ไขแล้ว'),
        ],
      ),
    );
  }

  Widget _buildIndexBadge(dynamic record, int index) {
    final color = record['speak_suscess'] == 1
        ? TColors.success
        : opt == '0'
        ? Colors.grey
        : TColors.buttonPrimary;
    return CircleAvatar(
      radius: 15,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: Text(
        '${index + 1}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // ชิปสถานะ/การกระทำแบบย่อ ใช้แทน ClipPath สามเหลี่ยมคู่แบบเดิม
  Widget _buildTag(String text, Color color, {VoidCallback? onTap}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
    if (onTap == null) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: chip,
    );
  }

  // รายการชิปสถานะ/การกระทำ ขึ้นกับตัวกรองปัจจุบัน (opt) และสถานะของรายการ
  List<Widget> _buildStatusTags(BuildContext context, dynamic record) {
    if (opt == '0') {
      return [
        _buildTag(
          'ยืนยันข้อมูล',
          TColors.buttonPrimary,
          onTap: () => _confirmInsertTap(context, record),
        ),
        _buildTag(
          'สมาชิกยืนยันแล้ว ${record['words_comfirm']} ท่าน',
          TColors.success,
          onTap: () => _showDialogUser(
            context,
            'รายชื่อสมาชิกที่ยืนยันแล้ว',
            '${record['words']}',
          ),
        ),
      ];
    } else if (opt == '1') {
      return [
        _buildTag(
          'สมาชิกที่ยืนยันแล้ว ${record['words_comfirm']} ท่าน',
          TColors.success,
          onTap: () => _showDialogUser(
            context,
            'รายชื่อสมาชิกที่ยืนยันแล้ว',
            '${record['words']}',
          ),
        ),
      ];
    }
    // opt == '2'
    final Widget primaryTag;
    if (record['speak_suscess'] == 1) {
      primaryTag = _buildTag('ข้อมูลถูกแก้ไขเรียบร้อยแล้ว', TColors.success);
    } else if (record['words_comfirm'] >= tSpeakNum) {
      primaryTag = _buildTag(
        'ยืนยันการแก้ไขข้อมูล',
        TColors.buttonPrimary,
        onTap: () => _confirmEditSuccessTap(context, record),
      );
    } else {
      primaryTag = _buildTag(
        'รอสมาชิกยืนยันครบ $tSpeakNum ท่าน',
        TColors.warning,
      );
    }
    return [
      primaryTag,
      _buildTag(
        'สมาชิกที่ยืนยัน ${record['words_comfirm']} ท่าน',
        TColors.success,
        onTap: () => _showDialogUser(
          context,
          'รายชื่อสมาชิกที่ยืนยันแล้ว',
          '${record['words']}',
        ),
      ),
    ];
  }

  Widget _buildCard(
    BuildContext context,
    dynamic record,
    int index,
    String userTmp,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: adaptiveSurfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIndexBadge(record, index),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'คำที่ระบบน่าจะอ่านผิด: ',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 20,
                          color: adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      TextSpan(
                        text: '${record['words']}\n',
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 20,
                          color: TColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: 'คำอ่าน: ',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 20,
                          color: adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      TextSpan(
                        text: '${record['words_speak']}',
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 20,
                          color: TColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CircularIconButton(
                      icon: Icons.volume_up,
                      color: Colors.blue[300]!,
                      onTap: () => _playAudioRecord(record),
                    ),
                    ..._buildStatusTags(context, record),
                  ],
                ),
                if ('${record['comments'] ?? ''}'.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  Text(
                    'หมายเหตุ ${record['comments']}',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 18,
                      color: adaptiveTextColor(context).withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _buildTag(
                  'แจ้งโดย: $userTmp',
                  TColors.primary1,
                  onTap: () => _showDialogUserCorrect(
                    context,
                    'รายชื่อสมาชิกที่แจ้งคำที่น่าจะอ่านผิด/คำที่น่าจะอ่านถูก',
                    '${record['words']}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // แถวแบบย่อ (โหมดลิสต์): บรรทัดเดียวต่อรายการ + ชิปสรุปสถานะ + เมนู ⋮
  // รวมการกระทำทั้งหมดไว้ (ต่างจากการ์ดที่กางชิปทุกตัวให้เห็น)
  Widget _buildListRow(
    BuildContext context,
    dynamic record,
    int index,
    String userTmp,
  ) {
    // ชิปแรกของ _buildStatusTags คือชิปหลักของสถานะนี้เสมอ (ยืนยันข้อมูล /
    // ยืนยันการแก้ไขข้อมูล / หรือสถานะอ่านอย่างเดียวถ้ากดไม่ได้) ใช้ตัวเดียวกับ
    // การ์ด เพื่อให้ปุ่มยืนยันข้อมูลโผล่มาในแถวเลย ไม่ต้องซ่อนในเมนู ⋮
    final primaryTag = _buildStatusTags(context, record).first;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: adaptiveSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIndexBadge(record, index),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${record['words']}',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: adaptiveTextColor(context),
                    ),
                  ),
                  TextSpan(
                    text: '  →  ',
                    style: TextStyle(
                      fontSize: 14,
                      color: adaptiveTextColor(context).withValues(alpha: 0.4),
                    ),
                  ),
                  TextSpan(
                    text: '${record['words_speak']}',
                    style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 20,
                      color: TColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          primaryTag,
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: adaptiveTextColor(context).withValues(alpha: 0.6),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'listen',
                child: ListTile(
                  leading: Icon(Icons.volume_up),
                  title: Text('ฟังเสียง'),
                ),
              ),
              const PopupMenuItem(
                value: 'confirmedUsers',
                child: ListTile(
                  leading: Icon(Icons.group_outlined),
                  title: Text('ดูรายชื่อผู้ยืนยัน'),
                ),
              ),
              const PopupMenuItem(
                value: 'reporter',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('ดูรายชื่อผู้แจ้ง'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'listen':
                  _playAudioRecord(record);
                  break;
                case 'confirmedUsers':
                  _showDialogUser(
                    context,
                    'รายชื่อสมาชิกที่ยืนยันแล้ว',
                    '${record['words']}',
                  );
                  break;
                case 'reporter':
                  _showDialogUserCorrect(
                    context,
                    'รายชื่อสมาชิกที่แจ้งคำที่น่าจะอ่านผิด/คำที่น่าจะอ่านถูก',
                    '${record['words']}',
                  );
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
