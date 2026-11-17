import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/utils/format_date/format_date.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
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

  Future<bool> deleteUser(String username) async {
    final response = await http.post(
      Uri.parse(tURLdeleteUser),
      body: {'token': tSecretAPIKey, 'username': username},
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['success'] == true;
    } else {
      throw Exception('ลบไม่สำเร็จ: ${response.statusCode}');
    }
  }

  void _confirmDelete(BuildContext context, String username) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบบัญชีผู้ใช้งาน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('คุณต้องการลบบัญชีผู้ใช้งาน "$username" ใช่หรือไม่?'),
            const SizedBox(height: 16),
            const Text(
              'พิมพ์คำว่า "delete" เพื่อยืนยัน:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: textController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.trim().toLowerCase() == 'delete') {
                Navigator.pop(ctx); // ปิด dialog
                bool success = await deleteUser(username);
                if (!context.mounted) return;
                if (success) {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('สำเร็จ'),
                      content: const Text('ลบบัญชีผู้ใช้สำเร็จ'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // ปิด AlertDialog
                          },
                          child: const Text('ตกลง'),
                        ),
                      ],
                    ),
                  );

                  await _logOut();
                  clearUsersList();

                  // ปิดหน้าจอหลังจากทำงานเสร็จ
                  if (!context.mounted) return;
                  Phoenix.rebirth(context);
                  /*Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyApp()), // แทนที่หน้าเดิม
                  );*/
                } else {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('ผิดพลาด'),
                      content: const Text('เกิดข้อผิดพลาดในการลบ'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ตกลง'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('คำเตือน'),
                    content: const Text('กรุณาพิมพ์คำว่า "delete" เพื่อยืนยัน'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('ตกลง'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      body: {'token': tSecretAPIKey, 'username': tmpUser},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

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
      body: {'token': tSecretAPIKey, 'username': tmpUser},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

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
      body: {'token': tSecretAPIKey},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

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
      body: {'token': tSecretAPIKey, 'username': tmpUser},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

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

        Users? users = snapshot.data!;
        final isAdmin = users.levelAccess == '1';
        return Container(
          color: adaptivePageColor(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeaderCard(users: users, isAdmin: isAdmin),
                const SizedBox(height: TSizes.md),
                _SectionCard(
                  title: 'ข้อมูลโปรไฟล์',
                  children: [
                    TProfileMenu(
                      icon: Icons.person_outline,
                      onPressed: () {},
                      title: 'ชื่อผู้ใช้งาน',
                      value: users.username,
                    ),
                    TProfileMenu(
                      icon: Icons.badge_outlined,
                      onPressed: () {},
                      title: 'ชื่อ',
                      value:
                          '${users.firstNameid}${users.firstName} ${users.lastName}',
                    ),
                    TProfileMenu(
                      icon: Icons.email_outlined,
                      onPressed: () {},
                      title: 'E-mail',
                      value: users.email,
                    ),
                    TProfileMenu(
                      icon: Icons.cake_outlined,
                      onPressed: () {},
                      title: 'วัน/เดือน/ปีเกิด',
                      value: formatDate.formatDate(users.birthDate),
                    ),
                    TProfileMenu(
                      icon: Icons.record_voice_over_outlined,
                      onPressed: () {},
                      title: 'เสียงอ่าน',
                      value: users.voiceChoice,
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.md),
                _SectionCard(
                  title: 'กิจกรรมของฉัน',
                  children: [
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
                  ],
                ),
                const SizedBox(height: TSizes.md),
                _SectionCard(
                  title: 'การตั้งค่าบัญชี',
                  children: [
                    _ActionButton(
                      icon: Icons.record_voice_over_outlined,
                      label: 'กำหนดเสียงอ่าน',
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SetVoice(
                              tmpUser:
                                  users.username, // ส่งค่า tmpUser ไปที่ dialog
                            );
                          },
                        ).then((newVoiceChoice) async {
                          if (newVoiceChoice == null) return;
                          // อัปเดตผ่าน UserProvider เพื่อให้ทั้งแอป (AppBar ฯลฯ)
                          // เห็นค่าใหม่ทันที ไม่ต้อง logout/รีสตาร์ทแอป
                          users.voiceChoice = newVoiceChoice;
                          // ignore: use_build_context_synchronously
                          context.read<UserProvider>().updateVoiceChoice(
                            newVoiceChoice,
                          );
                          setState(() {
                            _usersFuture = Future.value(users);
                          });
                        });
                      },
                    ),
                    const SizedBox(height: TSizes.sm),
                    _ActionButton(
                      icon: Icons.lock_outline,
                      label: 'เปลี่ยนรหัสผ่าน',
                      onPressed: () async {
                        final value = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const ChangePasswordDialog();
                          },
                        );
                        if (!context.mounted) return;
                        if (value == true) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: TSizes.md),
                  _SectionCard(
                    title: 'เครื่องมือผู้ดูแลระบบ',
                    children: [
                      TProfileMenuFuture(
                        icon: Icons.groups_outlined,
                        onPressed: () {},
                        title: 'จำนวนสมาชิกทั้งหมด [User]',
                        valueFuture: _logUserSum(),
                      ),
                      const SizedBox(height: TSizes.sm),
                      _ActionButton(
                        icon: Icons.groups_outlined,
                        label: 'แสดงสมาชิกทั้งหมด',
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
                      ),
                      const SizedBox(height: TSizes.sm),
                      _ActionButton(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'แสดงรายชื่อ Admin',
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
                      ),
                      const SizedBox(height: TSizes.sm),
                      _ActionButton(
                        icon: Icons.how_to_reg_outlined,
                        label: 'กำหนดผู้มีสิทธิ์ยืนยันการแก้ไขเสียงอ่าน',
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
                      ),
                      const SizedBox(height: TSizes.sm),
                      _ActionButton(
                        icon: Icons.hourglass_empty,
                        label: null,
                        labelWidget: const ShowButtonMember(),
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
                      ),
                      const SizedBox(height: TSizes.sm),
                      _ActionButton(
                        icon: Icons.fact_check_outlined,
                        label: 'แสดง Log Admin',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserActivityLogPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: TSizes.md),
                _SectionCard(
                  title: 'บัญชีผู้ใช้งาน',
                  titleColor: TColors.error,
                  children: [
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: 'ลบบัญชีผู้ใช้งาน',
                      danger: true,
                      onPressed: () async {
                        Users? users = await getUsersList();
                        String tmpUser = 'guest';
                        if (users != null) {
                          tmpUser = users.username;
                        }

                        // ignore: use_build_context_synchronously
                        _confirmDelete(context, tmpUser);
                      },
                    ),
                    const SizedBox(height: TSizes.sm),
                    _ActionButton(
                      icon: Icons.logout,
                      label: 'ออกจากระบบ',
                      outlined: true,
                      onPressed: () async {
                        await _logOut();
                        clearUsersList();
                        // ignore: use_build_context_synchronously
                        Phoenix.rebirth(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// การ์ดส่วนหัวโปรไฟล์: อวตาร + ชื่อผู้ใช้ + อีเมล + ป้าย Admin (ถ้ามีสิทธิ์)
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.users, required this.isAdmin});

  final Users users;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final initial = users.username.isNotEmpty
        ? users.username[0].toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: adaptiveSurfaceColor(context),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: TColors.buttonPrimary,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: TSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        users.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: adaptiveTextColor(context),
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.buttonPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TColors.buttonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  users.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: adaptiveTextColor(context).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// การ์ดเนื้อหาแบบเว็บ: หัวข้อ + เส้นคั่นบางๆ + รายการลูก
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.titleColor,
  });

  final String title;
  final List<Widget> children;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: adaptiveSurfaceColor(context),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TSectionHeading(title: title, textColor: titleColor),
          const SizedBox(height: 4),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ปุ่มการทำงานแบบเต็มความกว้าง ไอคอน+ข้อความ ใช้สไตล์เดียวกันทั้งการ์ด
// แทนปุ่มสีส้ม/แดงเดิมที่ไม่ยึดธีมแอป
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.label,
    this.labelWidget,
    this.danger = false,
    this.outlined = false,
  });

  final IconData icon;
  final String? label;
  final Widget? labelWidget;
  final VoidCallback onPressed;
  final bool danger;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final color = danger ? TColors.error : TColors.buttonPrimary;
    final child =
        labelWidget ??
        Text(
          label ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: adaptiveTextColor(context),
            side: BorderSide(
              color: adaptiveTextColor(context).withValues(alpha: 0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TSizes.buttonRadius),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.buttonRadius),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: child,
      ),
    );
  }
}

class ShowButtonMember extends StatelessWidget {
  const ShowButtonMember({super.key});

  Future<String> _logRegisFutureSum() async {
    final response = await http.post(
      Uri.parse(tURLWaitconfirmUser),
      body: {'token': tSecretAPIKey},
    );

    if (response.statusCode == 200) {
      var json = response.body;
      var jsonResponse = jsonDecode(json);

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
          return const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(
              'แสดงข้อมูลสมาชิก [รอยืนยัน ${snapshot.data} ท่าน]',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: snapshot.data == '0'
                    ? FontWeight.w500
                    : FontWeight.w700,
              ),
            );
          }
        }
      },
    );
  }
}
