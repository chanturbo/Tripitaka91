// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/auth/authentication_service.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/login/login.dart';
import 'package:tripitaka91/widget/login/member_tab_show.dart';
import 'package:tripitaka91/widget/search/data_search_widget.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:universal_html/html.dart' as uhtml;

class AppBarCustom extends StatefulWidget {
  final bool isTablet;
  final bool isDesktop;

  const AppBarCustom(
      {super.key, required this.isTablet, required this.isDesktop});

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();
}

class _AppBarCustomState extends State<AppBarCustom> {
  final AuthenticationService _authService = AuthenticationService();
  bool isLoggedIn = false;
  // Users? _usersData;
  bool isMaleVoice = true; // ตั้งค่าเริ่มต้นเป็นเสียงชาย
  int valueSpeech = 0; // ค่าเริ่มต้น
  int valueSelectSpeech = 0; // ค่าเริ่มต้น

  @override
  void initState() {
    super.initState();
    _loadValueSpeech();
    // _getUser();
  }

  Future<void> _loadValueSpeech() async {
    final value = await getValueBetaFurture();
    setState(() {
      valueSpeech = value; // อัปเดตสถานะจากค่าที่โหลด
    });
  }

  Future<void> _toggleValueSpeech() async {
    final newValue = valueSpeech == 0 ? 1 : 0;
    saveValueBeta(newValue); // บันทึกค่าใหม่
    setState(() {
      valueSpeech = newValue; // อัปเดต UI
    });
  }

  Future<void> _toggleValueBetaSpeech(int newValue) async {
    saveValueBetaSpeech(newValue); // บันทึกค่าใหม่
  }

  Future<void> _checkLoginStatus() async {
    isLoggedIn = await _authService.checkLoginStatus();

    if (isLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MemberTabShow(indexShow: 0)),
      );
    } else {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  // void _getUser() async {
  //   _usersData = await getUsersList();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/tripitaka91_logo.png',
              fit: BoxFit.cover,
              height: 35,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate:
                      widget.isTablet == false && widget.isDesktop == false
                          ? DataSearch(isM: true)
                          : DataSearch(isM: false),
                );
              },
              child: widget.isTablet == false && widget.isDesktop == false
                  ? const SizedBox.shrink()
                  : Container(
                      width: widget.isDesktop ? 580 : 380,
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: TColors.grey),
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusLg),
                        color: TColors.textWhite,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.search,
                            color: TColors.black,
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Text(
                            'ค้นหา...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                if (valueSpeech == 0) {
                  // แสดง AlertDialog เมื่อค่าเป็น 0
                  showDialog(
                    context: context,
                    builder: (context) {
                      bool isMaleVoice = true; // ค่าเริ่มต้นสำหรับเสียง
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('แจ้งเตือน'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '     นี่คือเวอร์ชั่น Beta ในโหมดการอ่านออกเสียงหัวข้อธรรมและพระไตรปิฎก โดยใช้โปรแกรมอัตโนมัติในการอ่าน\nซึ่งอาจทำให้การอ่านออกเสียงไม่ถูกต้องหรือครบถ้วน กรุณาใช้วิจารณญาณในการรับฟัง\n\nเลือกเสียงอ่าน',
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 5),
                                RadioListTile<bool>(
                                  title: const Text('เสียงผู้ชาย'),
                                  value: true,
                                  groupValue: isMaleVoice,
                                  onChanged: (value) {
                                    setState(() {
                                      isMaleVoice = value!;
                                    });
                                  },
                                ),
                                RadioListTile<bool>(
                                  title: const Text('เสียงผู้หญิง'),
                                  value: false,
                                  groupValue: isMaleVoice,
                                  onChanged: (value) {
                                    setState(() {
                                      isMaleVoice = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // ปิด Popup
                                },
                                child: const Text('ยกเลิก'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _toggleValueSpeech();
                                  isMaleVoice
                                      ? _toggleValueBetaSpeech(0)
                                      : _toggleValueBetaSpeech(1);
                                  Navigator.pop(context); // ปิด Popup
                                  uhtml.window.location
                                      .reload(); // รีเฟรชหน้าเว็บทั้งหมด
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('ยอมรับและดำเนินการต่อ'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('ยืนยันการปิดระบบ BETA'),
                        content:
                            const Text('คุณต้องการปิดระบบ BETA ใช่หรือไม่?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // ปิด Dialog
                            },
                            child: const Text('ไม่ใช่'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // ปิด Dialog
                              _toggleValueSpeech(); // เรียกใช้ Logic ปิดระบบ BETA
                              uhtml.window.location.reload(); // รีเฟรชหน้าเว็บ
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('ใช่'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      valueSpeech == 0 ? Colors.blue : Colors.red, // สีพื้นหลัง
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.app_registration, color: Colors.white),
                    const SizedBox(width: 8),
                    ATextDiskplayMedium(
                      text:
                          valueSpeech == 0 ? "เวอร์ชั่น BETA" : "ปิดระบบ BETA",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _checkLoginStatus,
            ),
          ],
        ),
      ],
    );
  }
}
