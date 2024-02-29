import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';

class LogSpeechScreen extends StatefulWidget {
  final String username;
  const LogSpeechScreen({super.key, required this.username});

  @override
  State<LogSpeechScreen> createState() => _LogSpeechScreenState();
}

class _LogSpeechScreenState extends State<LogSpeechScreen> {
  late int _currentPage;
  int values = 0;
  int pageSplit = 50;
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    _currentPage = 1; // กำหนดหน้าเริ่มต้น

    Future<int> valueCorrect = getValueSpeechFurture();
    valueCorrect.then((int value) {
      values = value;
    });
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _loadNextPage() {
    setState(() {
      double result = values / pageSplit;
      int itemCount = result.ceil();
      if (_currentPage < itemCount) {
        _currentPage++; // เพิ่มหน้า
      }
    });
  }

  void _loadBackPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

  Future<List<dynamic>> _logSpeechFuture() async {
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
        'page': _currentPage.toString(),
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        List<dynamic> messages = jsonResponse['message'];
        return messages;
      } else {
        // ถ้าไม่สำเร็จ จะส่งข้อมูลว่างกลับไป
        return [];
      }
    } else {
      // ถ้าเกิด HTTP Error จะ throw Exception
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _logSpeechFuture(),
      builder: (context, AsyncSnapshot<List<dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
            );
          } else {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('ไม่พบข้อมูล'),
              );
            } else {
              return ListView.builder(
                itemCount: values > pageSplit
                    ? snapshot.data!.length + 1
                    : snapshot.data!.length,
                // itemCount: snapshot.data!.length + 1,
                itemBuilder: (context, index) {
                  if (index < snapshot.data!.length) {
                    return ListTile(
                      title: Row(
                        children: [
                          const ATextTitleMedium(text: 'คำต้นฉบับ: '),
                          Expanded(
                              child: ATextTitleMediumColor(
                                  color: Colors.red,
                                  text: '${snapshot.data![index]['words']}')),
                          const ATextTitleMedium(text: 'คำอ่าน: '),
                          Expanded(
                              child: ATextTitleMediumColor(
                                  color: Colors.red,
                                  text:
                                      '${snapshot.data![index]['words_speak']}')),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          const ATextLabelLarge(
                            text: 'หมายเหตุ',
                          ),
                          const Expanded(
                              child: ATextTitleMediumColor(
                                  color: Colors.red, text: ' -')),
                          const ATextTitleMedium(text: 'อ่าน: '),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                LoadingDialog.show(context);
                                String txtTitle =
                                    '${snapshot.data![index]['words_speak']}';
                                String namesave =
                                    '${snapshot.data![index]['words']}'
                                        .trim()
                                        .replaceAll(RegExp(r'\s+'), '');

                                String filename = 'tmp-$namesave';
                                await audioPlayerManager.playAudio(
                                    '4', filename, txtTitle);
                                // ignore: use_build_context_synchronously
                                LoadingDialog.hide(context);
                              },
                              child: Icon(
                                Icons.volume_up,
                                size: 20,
                                color:
                                    Colors.blue[300], // Change color as needed
                              ),
                            ),
                          ),
                        ],
                      ),

                      // -> ${snapshot.data![index]['book_detail']}
                    );
                  } else {
                    return Row(
                      children: [
                        const Expanded(child: Text('')),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: _loadBackPage, // เรียกใช้เมธอดเมื่อกดปุ่ม
                          child:
                              const ATextDiskplayMedium(text: ' <-ก่อนหน้า '),
                        ),
                        const Text('  '),
                        popupMenu(values as double),
                        const Text('  '),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: _loadNextPage, // เรียกใช้เมธอดเมื่อกดปุ่ม
                          child:
                              const ATextDiskplayMedium(text: ' หน้าถัดไป-> '),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          }
        }
      },
    );
  }

  Widget popupMenu(double data) {
    double result = data / pageSplit;
    int itemCount = result.ceil();
    return PopupMenuButton<int>(
      itemBuilder: (context) {
        List<PopupMenuEntry<int>> list = [];
        for (int i = 1; i <= itemCount; i++) {
          list.add(
            PopupMenuItem<int>(
              value: i,
              child: Text('$i'),
            ),
          );
        }
        return list;
      },
      onSelected: (value) {
        // ทำอะไรก็ตามเมื่อเลือกเมนู
        setState(() {
          _currentPage = value; // เพิ่มหน้า
        });
      },
    );
  }
}
