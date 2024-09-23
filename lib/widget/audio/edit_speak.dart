import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:http/http.dart' as http;

class EditSpeakScreen extends StatefulWidget {
  final String comments;
  const EditSpeakScreen({super.key, required this.comments});

  @override
  State<EditSpeakScreen> createState() => _EditSpeakScreenState();
}

class _EditSpeakScreenState extends State<EditSpeakScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController text1Controller = TextEditingController();
  TextEditingController text2Controller = TextEditingController();
  TextEditingController text3Controller = TextEditingController();
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  String messageFromApi = '';
  bool chkUpdate = false;
  @override
  void initState() {
    super.initState();
    text3Controller.text = widget.comments;
  }

  @override
  void dispose() {
    text1Controller.dispose();
    text2Controller.dispose();
    text3Controller.dispose();
    audioPlayerManager.dispose();
    super.dispose();
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการดำเนินการ'),
          content: const Text('คุณต้องการบันทึกข้อมูล?'),
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  style: const TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 24,
                  ),
                  controller: text1Controller,
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
                ),
                TextFormField(
                  style: const TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 24,
                  ),
                  controller: text2Controller,
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
                TextFormField(
                  controller: text3Controller,
                  validator: (value) {
                    if (value!.isEmpty) {
                      text3Controller.text = '-';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'หมายเหตุ',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Text('')),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey),
                        side: MaterialStateProperty.all<BorderSide>(
                            BorderSide.none),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          LoadingDialog.show(context);
                          String txtTitle = text2Controller.text;
                          String namesave = text1Controller.text
                              .trim()
                              .replaceAll(RegExp(r'\s+'), '');

                          String filename = 'tmp-$namesave';
                          await audioPlayerManager.playAudio(
                              '4', filename, txtTitle);
                          // ignore: use_build_context_synchronously
                          LoadingDialog.hide(context);
                        }
                      },
                      child:
                          const ATextDiskplayMedium(text: ' ทดสอบเสียงอ่าน '),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        side: MaterialStateProperty.all<BorderSide>(
                            BorderSide.none),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool? confirm =
                              await _showConfirmationDialog(context);
                          if (confirm!) {
                            bool saveLogSpeechSuscess = await saveLogSpeech();
                            if (saveLogSpeechSuscess) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                                ),
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('เกิดข้อผิดพลาด $messageFromApi'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const ATextDiskplayMedium(text: ' บันทึก '),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        side: MaterialStateProperty.all<BorderSide>(
                            BorderSide.none),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const ATextDiskplayMedium(text: ' ยกเลิก '),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> saveLogSpeech() async {
    try {
      Users? users = await getUsersList();
      if (users == null) {
        messageFromApi = 'กรุณาเข้าสู่ระบบก่อน';
        return false;
      }
      var client = http.Client();
      var uri = Uri.parse(tURLlogSpeechSave);
      var data = {
        'token': tSecretAPIKey,
        'username': users.username,
        'words': text1Controller.text,
        'words_speak': text2Controller.text,
        'comments': text3Controller.text,
      };

      var response = await client.post(
        uri,
        body: data,
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));
        messageFromApi = decodedJson['message'];
        return decodedJson['success'];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in logEditSave: $e');
      messageFromApi = '$e';
      return false;
    }

    return false;
  }
}
