import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tripitaka91/main.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/format_date/format_date.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/change_password_dialog.dart';
import 'package:tripitaka91/widget/login/profile_menu.dart';
import 'package:tripitaka91/widget/login/profile_menu_future.dart';
import 'package:tripitaka91/widget/login/profile_menu_speech.dart';
import 'package:tripitaka91/widget/login/section_heading.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/widget/login/set_voice.dart';
import 'package:tripitaka91/widget/login/show_userall.dart';
import 'package:tripitaka91/widget/login/user_activity_log.dart';

class MemberDisplay extends StatefulWidget {
  const MemberDisplay({super.key});

  @override
  State<MemberDisplay> createState() => _MemberDisplayState();
}

class _MemberDisplayState extends State<MemberDisplay> {
  late Future<Users?> _usersFuture;
  late FormatDate formatDate;
  int values = 0;
  String totalMembers = '0';

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

  Future<String> _logEditFutureSum() async {
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }

    final response = await http.post(
      Uri.parse(tURLshowlogEditSum),
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

  Future<String> _logUserSum() async {
    final response = await http.post(
      Uri.parse(tURLshowUserSum),
      body: {
        'token': tSecretAPIKey,
      },
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(utf8.decode(json.runes.toList()));

      if (jsonResponse['success'] == true) {
        // ถ้าสำเร็จ คืนค่าจำนวนรายการที่ได้จาก API
        totalMembers = jsonResponse['total_logs'].toString();
        return jsonResponse['total_logs'].toString();
      } else {
        // ถ้าไม่สำเร็จ คืนค่าว่าง
        totalMembers = '0';
        return '0';
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
                // TProfileMenu(
                //   onPressed: () {},
                //   title: 'รายการแจ้งคำผิดคำถูก',
                //   value: '$values รายการ',
                // ),
                TProfileMenuFuture(
                  onPressed: () {},
                  title: 'รายการแจ้งคำผิดคำถูก',
                  valueFuture: _logEditFutureSum(),
                ),
                TProfileMenuSpeechFuture(
                  onPressed: () {},
                  title: 'รายการแจ้งคำอ่าน',
                  valueFuture: _logSpeechFutureSum(),
                ),
                users.levelAccess == '1'
                    ? TProfileMenuFuture(
                        onPressed: () {},
                        title: 'จำนวนสมาชิกทั้งหมด [User]',
                        valueFuture: _logUserSum(),
                      )
                    : const SizedBox.shrink(),
                TProfileMenu(
                    onPressed: () {},
                    title: 'เสียงอ่าน',
                    value: users.voiceChoice),
                const SizedBox(height: 10),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.orange),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SetVoice(
                            tmpUser:
                                users.username); // ส่งค่า tmpUser ไปที่ dialog
                      },
                    ).then((value) async {
                      if (value == true) {
                        // ทำงาน async นอก setState()
                        await _logOut();
                        clearUsersList();

                        // ปิดหน้าจอหลังจากทำงานเสร็จ
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MyApp()), // แทนที่หน้าเดิม
                        );
                      }
                    });
                  },
                  child: const ATextDiskplayMedium(
                    text: 'กำหนดเสียงอ่าน',
                  ),
                ),

                const SizedBox(height: 10),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.orange),
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
                    ? const SizedBox(height: 10)
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.orange),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyUserPage(
                                totalMember: totalMembers,
                                filterType: 'ชื่อทั้งหมด',
                              ),
                            ),
                          );
                        },
                        child: const ATextDiskplayMedium(
                          text: 'แสดงสมาชิกทั้งหมด',
                        ),
                      )
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? const SizedBox(height: 10)
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.orange),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyUserPage(
                                totalMember: totalMembers,
                                filterType: 'Admin',
                              ),
                            ),
                          );
                        },
                        child: const ATextDiskplayMedium(
                          text: 'แสดงรายชื่อ Admin',
                        ),
                      )
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? const SizedBox(height: 10)
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.orange),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyUserPage(
                                totalMember: totalMembers,
                                filterType: 'ผู้มีสิทธิ์ยืนยันเสียงอ่าน',
                              ),
                            ),
                          );
                        },
                        child: const ATextDiskplayMedium(
                          text: 'กำหนดผู้มีสิทธิ์ยืนยันการแก้ไขเสียงอ่าน',
                        ),
                      )
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? const SizedBox(height: 10)
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.orange),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyUserPage(
                                totalMember: totalMembers,
                                filterType: 'รอการยืนยัน',
                              ),
                            ),
                          );
                        },
                        child: const ShowButtonMember())
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? const SizedBox(height: 10)
                    : const SizedBox.shrink(),
                users.levelAccess == '1'
                    ? TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.orange),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserActivityLogPage(),
                            ),
                          );
                        },
                        child: const ATextDiskplayMedium(
                          text: 'แสดง Log Admin',
                        ),
                      )
                    : const SizedBox.shrink(),
                const Divider(),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () async {
                      await _logOut();
                      clearUsersList();
                      // ignore: use_build_context_synchronously
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyApp(),
                        ),
                        (route) => false,
                      );
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const MyHomePage(
                      //           online: false)), // แทนที่หน้าเดิม
                      // );
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
            return snapshot.data == '0'
                ? ATextDiskplayMedium(
                    text:
                        '   แสดงข้อมูลสมาชิก [รอยืนยัน ${snapshot.data} ท่าน]   ')
                : ATextTitleMedium(
                    text:
                        '   แสดงข้อมูลสมาชิก [รอยืนยัน ${snapshot.data} ท่าน]   '); // ใช้ค่าที่ได้จาก Future
          }
        }
      },
    );
  }
}
