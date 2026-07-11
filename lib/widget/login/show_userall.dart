import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/play_audio/audio_manager.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/profile_user.dart';

class MyUserPage extends StatefulWidget {
  final String filterType;
  final String totalMember;
  const MyUserPage({
    super.key,
    required this.filterType,
    required this.totalMember,
  });

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
  String _filterType = 'ชื่อทั้งหมด'; // ตัวเลือกการกรองเริ่มต้น
  // ignore: unused_field
  String _searchText = ''; // ข้อความที่ใช้กรอกค้นหา
  final TextEditingController _controlSearchText = TextEditingController();
  String tmpUser = '';

  @override
  void initState() {
    super.initState();
    _filterType = widget.filterType;
    textTitleReplace = TextTitleReplace();
    _scrollControllerTitle.addListener(_scrollListener);
    _fetchDataUser(_filterType, _searchText);
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
      _fetchDataUser(_filterType, _searchText);
    }
  }

  void _handleAddData() {
    setState(() {
      dataTitle = [];
      loadedRecordsTitle = 0;
      loadingTitle = false;
      pageTitle = 1;
      _fetchDataUser(_filterType, _searchText);
    });
  }

  Future<void> _fetchDataUser(String? filter, String? searchText) async {
    if (!loadingTitle) {
      setState(() {
        loadingTitle = true;
      });

      tmpUser = (await getUsersList())?.username ?? 'guest';

      final response = await http.post(
        Uri.parse(tURLshowUser),
        body: {
          'token': tSecretAPIKey,
          'page': pageTitle.toString(),
          'filter': filter,
          'searchText': ?searchText,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          List<dynamic> newData = jsonResponse['users'];
          setState(() {
            loadedRecordsTitle += newData.length;
            dataTitle.addAll(newData);
            loadingTitle = false;
            pageTitle++;
          });
        } else {
          // print(jsonResponse['message']);
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

  Future<void> _fetchConfirmVoice(String user, String level) async {
    try {
      final response = await http.post(
        Uri.parse(tURLconfirmVoice),
        body: {
          'token': tSecretAPIKey,
          'email': user,
          'level': level, // เพิ่มการส่งค่า level (opt)
          'email_process': tmpUser,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          _handleAddData();
          // ignore: use_build_context_synchronously
          _showSnackbar(context, 'กำหนดสิทธิ์ยืนยันเสียงอ่านเรียบร้อยแล้ว');
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'เกิดข้อผิดพลาดใน HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error: $e');
      // ignore: use_build_context_synchronously
      _showSnackbar(context, 'เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> _fetchConfirmAdmin(String user, String level) async {
    try {
      final response = await http.post(
        Uri.parse(tURLconfirmAdmin),
        body: {
          'token': tSecretAPIKey,
          'email': user,
          'level': level, // เพิ่มการส่งค่า level (opt)
          'email_process': tmpUser,
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          _handleAddData();
          // ignore: use_build_context_synchronously
          _showSnackbar(context, 'ยืนยันการเป็น Admin $user เรียบร้อยแล้ว');
        } else {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, '${jsonResponse['message']}');
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
        // ignore: use_build_context_synchronously
        _showSnackbar(context, 'เกิดข้อผิดพลาดใน HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error: $e');
      // ignore: use_build_context_synchronously
      _showSnackbar(context, 'เกิดข้อผิดพลาด: $e');
    }
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
      var jsonResponse = jsonDecode(json);

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
      var jsonResponse = jsonDecode(json);

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
        title: ATextDiskplayMedium(
            text: 'ผู้ใช้งานทั้งหมด [${widget.totalMember} ราย]'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Dropdown สำหรับเลือกการกรอง
                DropdownButton<String>(
                  value: _filterType,
                  items: <String>[
                    'ชื่อทั้งหมด',
                    'Admin',
                    'รอการยืนยัน',
                    'ผู้มีสิทธิ์ยืนยันเสียงอ่าน'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('แสดง $value'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _filterType = newValue!;
                      _searchText = '';
                      _controlSearchText.clear;
                      _handleAddData();
                    });
                  },
                ),
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _fetchDataUser(_filterType, _searchText);
                }
                return false;
              },
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0), // เพิ่ม padding ด้านบน
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
                              InkWell(
                                onTap: () async {
                                  String txtTitle =
                                      '${dataTitle[index]['email']}';
                                  Clipboard.setData(
                                    ClipboardData(text: txtTitle),
                                  );
                                  _showSnackbar(
                                      context, 'คัดลอกข้อมูลเรียบร้อยแล้ว');
                                },
                                child: Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: Colors
                                      .blue[300], // Change color as needed
                                ),
                              ),
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
                                          await _showConfirmationDialog(
                                              context);
                                      if (confirm!) {
                                        await _fetchResetPass(
                                            '${dataTitle[index]['username']}');
                                      }
                                    },
                                    child: const SizedBox(
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
                                                await _showConfirmationDialog(
                                                    context);
                                            if (confirm!) {
                                              await _fetchConfirmRegis(
                                                  '${dataTitle[index]['username']}');
                                            }
                                          },
                                          child: const SizedBox(
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
                              Row(
                                children: [
                                  dataTitle[index]['permission_voice'] == 0
                                      ? InkWell(
                                          onTap: () async {
                                            bool? confirm =
                                                await _showConfirmationDialog(
                                                    context);
                                            if (confirm!) {
                                              await _fetchConfirmVoice(
                                                '${dataTitle[index]['username']}',
                                                '1',
                                              );
                                            }
                                          },
                                          child: const SizedBox(
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                ATextTitleSmall(
                                                  text:
                                                      ' กำหนดสิทธิ์ยืนยืนเสียงอ่าน ',
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : dataTitle[index]['permission_voice'] ==
                                              1
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '[ บัญชีนี้ได้รับอนุมัติให้ยืนยันการอ่านออกเสียงแล้ว ]',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          color: Colors.red),
                                                  textAlign: TextAlign.left,
                                                ),
                                                dataTitle[index]['username'] !=
                                                        tmpUser
                                                    ? InkWell(
                                                        onTap: () async {
                                                          bool? confirm =
                                                              await _showConfirmationDialog(
                                                                  context);
                                                          if (confirm!) {
                                                            await _fetchConfirmVoice(
                                                              '${dataTitle[index]['username']}',
                                                              '0',
                                                            );
                                                          }
                                                        },
                                                        child: const SizedBox(
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.edit),
                                                              ATextTitleSmall(
                                                                text:
                                                                    'ยกเลิกสิทธิ์ยืนยันการอ่านออกเสียง',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink()
                                              ],
                                            )
                                          : const Text(''),
                                ],
                              ),
                              Row(
                                children: [
                                  dataTitle[index]['level_access'] == 2
                                      ? InkWell(
                                          onTap: () async {
                                            bool? confirm =
                                                await _showConfirmationDialog(
                                                    context);
                                            if (confirm!) {
                                              await _fetchConfirmAdmin(
                                                  '${dataTitle[index]['username']}',
                                                  '1');
                                            }
                                          },
                                          child: const SizedBox(
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                ATextTitleSmall(
                                                  text: 'กำหนดสิทธิ์เป็น Admin',
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : dataTitle[index]['level_access'] == 1
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '[ บัญชีนี้มีสถานะเป็น Admin ]',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          color: Colors.red),
                                                  textAlign: TextAlign.left,
                                                ),
                                                dataTitle[index]['username'] !=
                                                        tmpUser
                                                    ? InkWell(
                                                        onTap: () async {
                                                          bool? confirm =
                                                              await _showConfirmationDialog(
                                                                  context);
                                                          if (confirm!) {
                                                            await _fetchConfirmAdmin(
                                                                '${dataTitle[index]['username']}',
                                                                '2');
                                                          }
                                                        },
                                                        child: const SizedBox(
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.edit),
                                                              ATextTitleSmall(
                                                                text:
                                                                    'ยกเลิกสิทธิ์เป็น Admin',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink()
                                              ],
                                            )
                                          : const Text(''),
                                ],
                              ),
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
            ),
          ),
        ],
      ),
    );
  }
}
