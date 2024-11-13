import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';

class LogSpeechScreen extends StatefulWidget {
  final String username;
  const LogSpeechScreen({super.key, required this.username});

  @override
  State<LogSpeechScreen> createState() => _LogSpeechScreenState();
}

class _LogSpeechScreenState extends State<LogSpeechScreen> {
  List<dynamic> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;

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
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataSpeech();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _handleAddData() {
    // ทำการ setState() เพื่ออัปเดตข้อมูลใหม่
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      loadingTitle = false;
      pageTitle = 1;
      _fetchDataSpeech();
    });
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !_scrollControllerTitle.position.outOfRange) {
      _fetchDataSpeech();
    }
  }

  Future<void> _fetchDataSpeech() async {
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
        Uri.parse(tURLshowlogSpeechWithUser),
        body: {
          'token': tSecretAPIKey,
          'username': tmpUser,
          'page': pageTitle.toString(),
          'searchText': _searchText,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['message'];
          setState(() {
            loadedRecordsTitle += newData.length;
            dataTitle.addAll(newData);
            loadingTitle = false;
            pageTitle++;
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

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ไม่สามารถแก้ไขได้'),
          content: const Text(
              'คำนี้มีการยืนยันการอ่านออกเสียงจากสมาชิกแล้ว ไม่สามารถแก้ไขได้'),
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

  Future<void> _fetchDeleteSpeakConfirm(String words) async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }
    final response = await http.post(
      Uri.parse(tURLdelSpeakConfirm),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
        'words': words,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'ลบข้อมูลเรียบร้อยแล้ว');
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const SizedBox(width: 10),
              // TextField สำหรับกรอกข้อมูลค้นหา
              Expanded(
                child: TextField(
                  controller: _controlSearchText,
                  decoration: const InputDecoration(
                    labelText: 'กรอกข้อมูลการค้นหา',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                      _handleAddData();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: NotificationListener(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _fetchDataSpeech();
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollControllerTitle,
              itemCount: loadedRecordsTitle + 1,
              itemBuilder: (context, index) {
                if (index == loadedRecordsTitle) {
                  // แสดง loading indicator ขณะที่กำลังโหลดข้อมูลเพิ่มเติม
                  return loadingTitle
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                } else {
                  // ดึงข้อมูลแต่ละ record มาแสดง
                  final record = dataTitle[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      child: ATextDiskplayMedium(text: '${index + 1}'),
                    ),
                    title: ATextTitleMedium(
                        text: 'คำที่ระบบน่าจะอ่านผิด : ${record['words']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'คำอ่าน : ',
                                style: TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.grey),
                              ),
                              TextSpan(
                                text: '${record['words_speak']}',
                                style: const TextStyle(
                                    fontFamily: 'THSarabunNew',
                                    fontSize: 24,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () async {
                                LoadingDialog.show(context);
                                String txtTitle = record['words_speak'];
                                String namesave = record['words']
                                    .trim()
                                    .replaceAll(RegExp(r'\s+'), '');

                                String filename = 'tmp-$namesave';
                                await audioPlayerManager.playAudio(
                                    '4', filename, txtTitle);
                                // ignore: use_build_context_synchronously
                                LoadingDialog.hide(context);
                                // การเล่นเสียง ใช้ AudioPlayerManager
                              },
                              child: Icon(
                                Icons.volume_up,
                                size: 20,
                                color:
                                    Colors.blue[300], // Change color as needed
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () async {
                                if (record['words_comfirm'] > 0) {
                                  _showConfirmationDialog(context);
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return EditDialog(
                                        incorrectWord:
                                            record['words'], // ค่าตัวอย่าง
                                        correctPronunciation: record[
                                            'words_speak'], // ค่าตัวอย่าง
                                      );
                                    },
                                  ).then((result) {
                                    _handleAddData();
                                  });
                                }
                              },
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color:
                                    Colors.blue[300], // Change color as needed
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () async {
                                bool? confirm =
                                    await _showConfirmDialog(context);
                                if (confirm!) {
                                  await _fetchDeleteSpeakConfirm(
                                      record['words']);
                                  _handleAddData();
                                }
                              },
                              child: Icon(
                                Icons.delete,
                                size: 20,
                                color:
                                    Colors.blue[300], // Change color as needed
                              ),
                            ),
                          ],
                        ),
                        // Text("Username: ${record['username'] ?? 'ไม่ระบุ'}"),
                        // Text("Length: ${record['words_length']}"),
                        // Text("Date Added/Edited: ${record['words_dataaddedit']}"),
                        // Text("Comments: ${record['comments'] ?? 'ไม่มี'}"),
                        // Text(
                        //     "Success: ${record['speak_suscess'] == 1 ? 'Yes' : 'No'}"),
                        const Divider(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
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
    _incorrectWordController =
        TextEditingController(text: widget.incorrectWord);
    _correctPronunciationController =
        TextEditingController(text: widget.correctPronunciation);
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
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

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
            style: const TextStyle(
              fontFamily: 'THSarabunNew',
              fontSize: 24,
            ),
            controller: _incorrectWordController,
            validator: (value) {
              if (value!.isEmpty) {
                return 'โปรดป้อนคำต้นฉบับ';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'คำต้นฉบับ',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
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
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () async {
            LoadingDialog.show(context);
            String txtTitle = _correctPronunciationController.text;
            String namesave = _incorrectWordController.text
                .trim()
                .replaceAll(RegExp(r'\s+'), '');

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
          child: const Text('ยกเลิก',
              style: TextStyle(
                fontFamily: 'THSarabunNew',
                fontSize: 22,
              )),
        ),
        // ปุ่ม "บันทึก"
        TextButton(
          onPressed: _saveEditData,
          child: const Text(
            'บันทึก',
            style: TextStyle(
              fontFamily: 'THSarabunNew',
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }
}
