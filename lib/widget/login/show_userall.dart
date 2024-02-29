import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/profile_user.dart';

class MyUserPage extends StatefulWidget {
  const MyUserPage({super.key});

  @override
  State<MyUserPage> createState() => _MyUserPageState();
}

class _MyUserPageState extends State<MyUserPage> {
  List<dynamic> dataTitle = [];
  int loadedRecordsTitle = 0;
  bool loadingTitle = false;
  int pageTitle = 1;
  late TextTitleReplace textTitleReplace;
  final ScrollController _scrollControllerTitle = ScrollController();
  late String opt = '0';
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    textTitleReplace = TextTitleReplace();
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataUser();
  }

  @override
  void dispose() {
    audioPlayerManager.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollControllerTitle.offset >=
            _scrollControllerTitle.position.maxScrollExtent &&
        !_scrollControllerTitle.position.outOfRange) {
      _fetchDataUser();
    }
  }

  void _handleAddData() {
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      loadingTitle = false;
      pageTitle = 1;
      _fetchDataUser();
    });
  }

  Future<void> _fetchDataUser() async {
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      final response = await http.post(
        Uri.parse(tURLshowUser),
        body: {
          'token': tSecretAPIKey,
          'page': pageTitle.toString(),
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['users'];
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

  Future<void> _fetchConfirmRegis(String user) async {
    final response = await http.post(
      Uri.parse(tURLconfirmUser),
      body: {
        'token': tSecretAPIKey,
        'email': user,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'ยืนยันการสมัครสมาชิก $user เรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchResetPass(String user) async {
    final response = await http.post(
      Uri.parse(tURLresetUserPass),
      body: {
        'token': tSecretAPIKey,
        'email': user,
        'password': 'password',
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        _handleAddData();
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'รีเซตรหัสผ่านของ $user เรียบร้อยแล้ว');
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar(context, '${jsonResponse['message']}');
      }
    } else {
      // ignore: avoid_print
      print('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const ATextDiskplayMedium(text: 'แสดงข้อมูลผู้ใช้งานทั้งหมด')),
      body: NotificationListener(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _fetchDataUser();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollControllerTitle,
          itemCount: loadedRecordsTitle + 1,
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
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TUserMenu(
                          title: 'ชื่อผู้ใช้งาน',
                          value: '${dataTitle[index]['username']}'),
                      TUserMenu(
                          title: 'ชื่อ-นามสกุล',
                          value:
                              '${dataTitle[index]['first_nameid']}${dataTitle[index]['firstName']} ${dataTitle[index]['lastName']}'),
                      TUserMenu(
                          title: 'อีเมล',
                          value: '${dataTitle[index]['email']}'),
                      TUserMenu(
                          title: 'วันเดือนปีเกิด',
                          value: '${dataTitle[index]['birthDate']}'),
                    ],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              bool? confirm =
                                  await _showConfirmationDialog(context);
                              if (confirm!) {
                                // await _fetchUpdateInsertDataCorrect(
                                //     inputData, bookid, bookpage, bookline);
                                // ignore: use_build_context_synchronously
                                await _fetchResetPass(
                                    '${dataTitle[index]['username']}');
                              }
                            },
                            child: const SizedBox(
                              width: 150,
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  ATextTitleSmall(
                                    text: ' รีเซตรหัสผ่าน...',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          dataTitle[index]['active'] == 0
                              ? InkWell(
                                  onTap: () async {
                                    bool? confirm =
                                        await _showConfirmationDialog(context);
                                    if (confirm!) {
                                      // await _fetchUpdateInsertDataCorrect(
                                      //     inputData, bookid, bookpage, bookline);
                                      // ignore: use_build_context_synchronously
                                      await _fetchConfirmRegis(
                                          '${dataTitle[index]['username']}');
                                    }
                                  },
                                  child: const SizedBox(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        ATextTitleSmall(
                                          text: ' ยืนยันการสมัคร ',
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const Text(''),
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     dataTitle[index]['level_access'] == 2
                      //         ? InkWell(
                      //             onTap: () async {
                      //               bool? confirm =
                      //                   await _showConfirmationDialog(context);
                      //               if (confirm!) {
                      //                 // await _fetchUpdateInsertDataCorrect(
                      //                 //     inputData, bookid, bookpage, bookline);
                      //                 // ignore: use_build_context_synchronously
                      //                 await _fetchConfirmRegis(
                      //                     '${dataTitle[index]['username']}');
                      //               }
                      //             },
                      //             child: const SizedBox(
                      //               width: 250,
                      //               child: Row(
                      //                 children: [
                      //                   Icon(Icons.edit),
                      //                   ATextTitleSmall(
                      //                     text: 'กำหนดสิทธิ์เป็น Admin',
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           )
                      //         : const Text(''),
                      //   ],
                      // ),
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
