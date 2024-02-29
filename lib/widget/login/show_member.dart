import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/format_date/format_date.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/change_password_dialog.dart';
import 'package:tripitaka91/widget/login/profile_menu.dart';
import 'package:tripitaka91/widget/login/profile_menu_speech.dart';
import 'package:tripitaka91/widget/login/section_heading.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/widget/login/show_userall.dart';

class MemberDisplay extends StatefulWidget {
  const MemberDisplay({super.key});

  @override
  State<MemberDisplay> createState() => _MemberDisplayState();
}

class _MemberDisplayState extends State<MemberDisplay> {
  late Future<Users?> _usersFuture;
  late FormatDate formatDate;
  int values = 0;

  @override
  void initState() {
    super.initState();
    _usersFuture = _getUser();
    formatDate = FormatDate();
    Future<int> valueCorrect = getValueCorrectFurture();
    valueCorrect.then((int value) {
      values = value;
    });
  }

  Future<Users?> _getUser() async {
    return getUsersList();
  }

  // Future<String> _logEditFutureSum() async {
  //   Users? users = await getUsersList();
  //   String tmpUser = 'guest';
  //   if (users != null) {
  //     tmpUser = users.username;
  //   }

  //   final response = await http.post(
  //     Uri.parse(tURLshowlogEditSum),
  //     body: {
  //       'token': tSecretAPIKey,
  //       'username': tmpUser,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     var json = response.body;
  //     var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

  //     if (jsonResponse['success'] == true) {
  //       // ถ้าสำเร็จ คืนค่าจำนวนรายการที่ได้จาก API
  //       return jsonResponse['total_logs'].toString();
  //     } else {
  //       // ถ้าไม่สำเร็จ คืนค่าว่าง
  //       return '';
  //     }
  //   } else {
  //     // ถ้าเกิด HTTP Error จะ throw Exception
  //     throw Exception('HTTP Error: ${response.statusCode}');
  //   }
  // }

  Future<String> _logSpeechFutureSum() async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }

    final response = await http.post(
      Uri.parse(tURLshowlogSpeechSum),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        // ถ้าสำเร็จ คืนค่าจำนวนรายการที่ได้จาก API
        return jsonResponse['total_logs'].toString();
      } else {
        // ถ้าไม่สำเร็จ คืนค่าว่าง
        return '';
      }
    } else {
      // ถ้าเกิด HTTP Error จะ throw Exception
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  Future<bool> _logOut() async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }

    final response = await http.post(
      Uri.parse(tURLlogOut),
      body: {
        'token': tSecretAPIKey,
        'username': tmpUser,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        // ถ้าสำเร็จ คืนค่าจำนวนรายการที่ได้จาก API
        return true;
      } else {
        // ถ้าไม่สำเร็จ คืนค่าว่าง
        return false;
      }
    } else {
      // ถ้าเกิด HTTP Error จะ throw Exception
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Users?>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
        }

        Users? users = snapshot.data;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const TSectionHeading(title: 'ข้อมูลโปรไฟล์'),
                TProfileMenu(
                    onPressed: () {},
                    title: 'ชื่อผู้ใช้งาน',
                    value: users!.username),
                TProfileMenu(
                    onPressed: () {},
                    title: 'ชื่อ',
                    value:
                        '${users.firstNameid}${users.firstName} ${users.lastName}'),
                // const SizedBox(height: 16),
                // const Divider(),
                // const SizedBox(height: 16),
                // const TSectionHeading(title: 'Personal Information'),
                // const SizedBox(height: 16),
                TProfileMenu(
                    onPressed: () {}, title: 'E-mail', value: users.email),
                TProfileMenu(
                  onPressed: () {},
                  title: 'วัน/เดือน/ปีเกิด',
                  value: formatDate.formatDate(users.birthDate),
                ),
                TProfileMenu(
                  onPressed: () {},
                  title: 'รายการแจ้งคำผิดคำถูก',
                  value: '$values รายการ',
                ),
                // TProfileMenuFuture(
                //   onPressed: () {},
                //   title: 'รายการแจ้งคำผิดคำถูก',
                //   valueFuture: _logEditFutureSum(),
                // ),
                TProfileMenuSpeechFuture(
                  onPressed: () {},
                  title: 'รายการแจ้งคำอ่าน',
                  valueFuture: _logSpeechFutureSum(),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orange),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const ChangePasswordDialog();
                      },
                    ).then((value) {
                      if (value == true) {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                  child: const ATextDiskplayMedium(
                    text: 'เปลี่ยนรหัสผ่าน',
                  ),
                ),

                users.levelAccess == '1'
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MyUserPage()),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(Colors
                                          .white), // กำหนดสีพื้นหลังเป็นสีขาว
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          18.0), // กำหนดขนาดของเส้นขอบ
                                      side: const BorderSide(
                                          color: Colors
                                              .black), // กำหนดสีของเส้นขอบ
                                    ),
                                  ),
                                ),
                                child: const ShowButtonMember(),
                              ),
                              const SizedBox(width: 20),
                              // ElevatedButton(
                              //   onPressed: () {},
                              //   style: ButtonStyle(
                              //     backgroundColor:
                              //         MaterialStateProperty.all<Color>(Colors
                              //             .white), // กำหนดสีพื้นหลังเป็นสีขาว
                              //     shape: MaterialStateProperty.all<
                              //         RoundedRectangleBorder>(
                              //       RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(
                              //             18.0), // กำหนดขนาดของเส้นขอบ
                              //         side: const BorderSide(
                              //             color: Colors
                              //                 .black), // กำหนดสีของเส้นขอบ
                              //       ),
                              //     ),
                              //   ),
                              //   child: const ATextLabelMedium(
                              //       text: ' แสดงข้อมูลที่ยืนยันแล้ว '),
                              // ),
                              // const SizedBox(width: 20),
                              // ElevatedButton(
                              //   onPressed: () {},
                              //   style: ButtonStyle(
                              //     backgroundColor:
                              //         MaterialStateProperty.all<Color>(Colors
                              //             .white), // กำหนดสีพื้นหลังเป็นสีขาว
                              //     shape: MaterialStateProperty.all<
                              //         RoundedRectangleBorder>(
                              //       RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(
                              //             18.0), // กำหนดขนาดของเส้นขอบ
                              //         side: const BorderSide(
                              //             color: Colors
                              //                 .black), // กำหนดสีของเส้นขอบ
                              //       ),
                              //     ),
                              //   ),
                              //   child: const ATextLabelMedium(
                              //       text: ' แสดงข้อมูลที่แก้ไขแล้ว '),
                              // ),
                            ],
                          ),
                        ],
                      )
                    : const Text(''),
                const Divider(),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () async {
                      await _logOut();
                      clearUsersList();
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // ปิดหน้าจอ
                    },
                    child: const ATextDiskplayMedium(
                      text: 'ออกจากระบบ',
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShowButtonMember extends StatelessWidget {
  const ShowButtonMember({super.key});

  Future<String> _logRegisFutureSum() async {
    final response = await http.post(
      Uri.parse(tURLWaitconfirmUser),
      body: {
        'token': tSecretAPIKey,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        // ถ้าสำเร็จ คืนค่าจำนวนรายการที่ได้จาก API
        return jsonResponse['total_logs'].toString();
      } else {
        // ถ้าไม่สำเร็จ คืนค่าว่าง
        return '0';
      }
    } else {
      // ถ้าเกิด HTTP Error จะ throw Exception
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _logRegisFutureSum(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // แสดง indicator ในระหว่างรอค่า
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ATextLabelMedium(
                text:
                    '   แสดงข้อมูลสมาชิก รอยืนยัน ${snapshot.data} ท่าน   '); // ใช้ค่าที่ได้จาก Future
          }
        }
      },
    );
  }
}
