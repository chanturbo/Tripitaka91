import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/common/circular_icon_button.dart';
import 'package:tripitaka91/widget/common/index_badge.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';

class LogSpeechScreen extends StatefulWidget {
  final String username;
  const LogSpeechScreen({super.key, required this.username});

  @override
  State<LogSpeechScreen> createState() => _LogSpeechScreenState();
}

class _LogSpeechScreenState extends State<LogSpeechScreen> {
  List<dynamic> dataTitle = [];
  bool loadingTitle = false;
  int pageTitle = 1;
  int loadedRecordsTitle = 0;
  bool _isListView = false;
  final ScrollController _scrollControllerTitle = ScrollController();

  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  List<dynamic> dataUser = [];
  List<dynamic> dataUserCurrect = [];
  // ignore: unused_field
  String _searchText = ''; // ข้อความที่ใช้กรอกค้นหา
  final TextEditingController _controlSearchText = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  // รีเฟรชข้อมูลทั้งหมดใหม่ตั้งแต่หน้า 1 (ใช้หลังแก้ไข/ลบ หรือเปลี่ยนคำค้นหา)
  void _handleAddData() {
    setState(() {
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
      Uri.parse(tURLshowlogSpeechWithUser),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'page': pageTitle.toString(),
        'searchText': _searchText,
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

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ไม่สามารถแก้ไขได้'),
          content: const Text(
            'คำนี้มีการยืนยันการอ่านออกเสียงจากสมาชิกแล้ว ไม่สามารถแก้ไขได้',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
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

  Future<void> _fetchDeleteSpeakConfirm(String words) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLdelSpeakConfirm),
      body: {'token': tSecretAPIKey, 'username': tmpUser, 'words': words},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'ลบข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _playRecordAudio(dynamic record) async {
    LoadingDialog.show(context);
    String txtTitle = record['words_speak'];
    String namesave = record['words'].trim().replaceAll(RegExp(r'\s+'), '');

    String filename = 'tmp-$namesave';
    await audioPlayerManager.playAudio('4', filename, txtTitle);
    // ignore: use_build_context_synchronously
    LoadingDialog.hide(context);
  }

  void _editRecord(dynamic record) {
    if (record['words_comfirm'] > 0) {
      _showConfirmationDialog(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditDialog(
            incorrectWord: record['words'],
            correctPronunciation: record['words_speak'],
          );
        },
      ).then((result) {
        _handleAddData();
      });
    }
  }

  Future<void> _deleteRecord(dynamic record) async {
    bool? confirm = await _showConfirmDialog(context);
    if (confirm == true) {
      await _fetchDeleteSpeakConfirm(record['words']);
      _handleAddData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: adaptivePageColor(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controlSearchText,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'ค้นหาคำที่แจ้ง...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _searchText = value;
                      _handleAddData();
                    },
                  ),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      return _isListView
                          ? _buildListRow(context, record, index)
                          : _buildCard(context, record, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, dynamic record, int index) {
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
          IndexBadge(index: index + 1, radius: 15),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'คำที่ระบบน่าจะอ่านผิด: ${record['words']}',
                  style: TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: adaptiveTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'คำอ่าน: ',
                        style: TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 20,
                          color: adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                      TextSpan(
                        text: '${record['words_speak']}',
                        style: const TextStyle(
                          fontFamily: 'THSarabunNew',
                          fontSize: 20,
                          color: TColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.volume_up,
                      color: Colors.blue[300]!,
                      onTap: () => _playRecordAudio(record),
                    ),
                    CircularIconButton(
                      icon: Icons.edit,
                      color: Colors.blue[300]!,
                      onTap: () => _editRecord(record),
                    ),
                    CircularIconButton(
                      icon: Icons.delete,
                      color: Colors.blue[300]!,
                      onTap: () => _deleteRecord(record),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // แถวแบบย่อ (โหมดลิสต์): บรรทัดเดียวต่อรายการ เพื่อให้เห็นข้อมูลได้เยอะขึ้น
  // ส่วนปุ่มจัดการรวมไว้ในเมนู ⋮ แทนการกางไอคอนแยก
  Widget _buildListRow(BuildContext context, dynamic record, int index) {
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
          IndexBadge(index: index + 1, radius: 13),
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
                      fontFamily: 'THSarabunNew',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: adaptiveTextColor(context),
                    ),
                  ),
                  TextSpan(
                    text: '  →  ',
                    style: TextStyle(
                      fontSize: 16,
                      color: adaptiveTextColor(context).withValues(alpha: 0.4),
                    ),
                  ),
                  TextSpan(
                    text: '${record['words_speak']}',
                    style: const TextStyle(
                      fontFamily: 'THSarabunNew',
                      fontSize: 22,
                      color: TColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          CircularIconButton(
            icon: Icons.volume_up,
            size: 18,
            color: Colors.blue[300]!,
            onTap: () => _playRecordAudio(record),
          ),
          CircularIconButton(
            icon: Icons.edit,
            size: 18,
            color: Colors.blue[300]!,
            onTap: () => _editRecord(record),
          ),
          CircularIconButton(
            icon: Icons.delete,
            size: 18,
            color: Colors.blue[300]!,
            onTap: () => _deleteRecord(record),
          ),
        ],
      ),
    );
  }

}

class EditDialog extends StatefulWidget {
  final String incorrectWord;
  final String correctPronunciation;

  // Constructor ที่รับค่า incorrectWord และ correctPronunciation
  const EditDialog({
    super.key,
    required this.incorrectWord,
    required this.correctPronunciation,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  // ตัวแปรสำหรับเก็บค่า TextField
  late TextEditingController _incorrectWordController;
  late TextEditingController _correctPronunciationController;
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นให้กับ TextEditingController จากค่าที่รับมาจาก constructor
    _incorrectWordController = TextEditingController(
      text: widget.incorrectWord,
    );
    _correctPronunciationController = TextEditingController(
      text: widget.correctPronunciation,
    );
  }

  Future<void> _fetchEditSpeakConfirm(String words, String wordSpeak) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLeditSpeakConfirm),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'words': words,
        'words_speak': wordSpeak,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'แก้ไขข้อมูลเรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
        // print('HTTP Error: ${response.statusCode}');
        // print('${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูล
  void _saveEditData() async {
    String incorrectWord = _incorrectWordController.text;
    String correctPronunciation = _correctPronunciationController.text;
    await _fetchEditSpeakConfirm(incorrectWord, correctPronunciation);
    // แสดงค่าที่กรอกในฟิลด์ (สามารถทำการบันทึกข้อมูลได้ที่นี่)
    // print('Incorrect Word: $incorrectWord');
    // print('Correct Pronunciation: $correctPronunciation');

    // ปิด Dialog เมื่อบันทึกเสร็จ
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(true);
  }

  // ฟังก์ชันสำหรับยกเลิก
  void _cancel() {
    // ปิด Dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('แก้ไขข้อมูล'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            readOnly: true,
            style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
            controller: _incorrectWordController,
            validator: (value) {
              if (value!.isEmpty) {
                return 'โปรดป้อนคำต้นฉบับ';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'คำต้นฉบับ',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) async {},
          ),
          TextFormField(
            style: const TextStyle(
              fontFamily: 'THSarabunNew',
              fontSize: 24,
              color: Colors.red,
            ),
            controller: _correctPronunciationController,
            validator: (value) {
              if (value!.isEmpty) {
                return 'โปรดป้อนคำอ่าน';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'คำอ่าน',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () async {
            LoadingDialog.show(context);
            String txtTitle = _correctPronunciationController.text;
            String namesave = _incorrectWordController.text.trim().replaceAll(
              RegExp(r'\s+'),
              '',
            );

            String filename = 'tmp-$namesave';
            await audioPlayerManager.playAudio('4', filename, txtTitle);
            // ignore: use_build_context_synchronously
            LoadingDialog.hide(context);
            // การเล่นเสียง ใช้ AudioPlayerManager
          },
          child: Icon(
            Icons.volume_up,
            size: 20,
            color: Colors.blue[300], // Change color as needed
          ),
        ),
        // ปุ่ม "ยกเลิก"
        TextButton(
          onPressed: _cancel,
          child: const Text(
            'ยกเลิก',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 22),
          ),
        ),
        // ปุ่ม "บันทึก"
        TextButton(
          onPressed: _saveEditData,
          child: const Text(
            'บันทึก',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 22),
          ),
        ),
      ],
    );
  }
}
