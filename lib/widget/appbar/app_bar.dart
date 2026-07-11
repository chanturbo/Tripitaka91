import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/search/data_search_widget.dart';

class AppBarCustom extends StatefulWidget {
  final bool isTablet;
  final bool isDesktop;
  final bool online;
  const AppBarCustom({
    super.key,
    required this.isTablet,
    required this.isDesktop,
    required this.online,
  });

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();
}

class _AppBarCustomState extends State<AppBarCustom> {
  bool isLoggedIn = false;
  // Users? _usersData;
  int valueSpeech = 0; // ค่าเริ่มต้น
  int valueSelectSpeech = 0; // ค่าเริ่มต้น
  Users? usersChk;

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

  // Future<void> _checkLoginStatus() async {
  //   isLoggedIn = await _authService.checkLoginStatus();

  //   if (isLoggedIn) {
  //     // ignore: use_build_context_synchronously
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => const MemberTabShow(indexShow: 0)),
  //     );
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const LoginPage(),
  //       ),
  //     );
  //   }
  // }

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
            // valueSpeech == 0
            //     ? const Icon(Icons.app_registration, color: Colors.white)
            //     : widget.isDesktop == false && widget.isTablet == false
            //         ? const SizedBox.shrink()
            //         : const Icon(Icons.app_registration, color: Colors.white),
            // valueSpeech == 0
            //     ? const SizedBox(width: 8)
            //     : widget.isDesktop == false && widget.isTablet == false
            //         ? const SizedBox.shrink()
            //         : const SizedBox(width: 8),
            const SizedBox(width: 8),
            widget.online
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: () {
                      if (valueSpeech == 0) {
                        // แสดง AlertDialog เมื่อค่าเป็น 0
                        showDialog(
                          context: context,
                          builder: (context) {
                            bool isMaleVoice = true; // ค่าเริ่มต้นสำหรับเสียง
                            TextEditingController textController =
                                TextEditingController();
                            bool isInputValid = false;

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: const Text('แจ้งเตือน'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '     นี่คือเวอร์ชั่น ONLINE ในโหมดการอ่านออกเสียงหัวข้อธรรมและพระไตรปิฎก โดยใช้โปรแกรมอัตโนมัติในการอ่าน ซึ่งอาจทำให้การอ่านออกเสียงยังไม่ถูกต้อง ครบถ้วน สมบูรณ์ ดังนั้น ผู้ใช้งานควรใช้วิจารณญาณในการรับฟัง\n\nเลือกเสียงอ่าน',
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(height: 5),
                                        RadioGroup<bool>(
                                          groupValue: isMaleVoice,
                                          onChanged: (value) {
                                            setState(() {
                                              isMaleVoice = value!;
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              RadioListTile<bool>(
                                                title: const Text(
                                                    'เสียงผู้ชาย'),
                                                value: true,
                                              ),
                                              RadioListTile<bool>(
                                                title: const Text(
                                                    'เสียงผู้หญิง'),
                                                value: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: textController,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'พิมพ์ "ONLINE" เพื่อดำเนินการต่อ',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              isInputValid =
                                                  value.trim().toUpperCase() ==
                                                      "ONLINE";
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // ปิด Popup
                                      },
                                      child: const Text('ยกเลิก'),
                                    ),
                                    ElevatedButton(
                                      onPressed: isInputValid
                                          ? () {
                                              _toggleValueSpeech();
                                              isMaleVoice
                                                  ? _toggleValueBetaSpeech(0)
                                                  : _toggleValueBetaSpeech(1);
                                              Phoenix.rebirth(context);
                                              // Navigator.pop(
                                              //     context); // ปิด Popup
                                              // // ignore: use_build_context_synchronously
                                              // Navigator.pushAndRemoveUntil(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         const MyApp(),
                                              //   ),
                                              //   (route) => false,
                                              // );
                                            }
                                          : null, // ปิดใช้งานปุ่มถ้ายังไม่ได้ป้อน "ONLINE"
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isInputValid
                                            ? Colors.red
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                      child:
                                          const Text('ยอมรับและดำเนินการต่อ'),
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
                              title: const Text('ยืนยันการปิดเวอร์ชั่น ONLINE'),
                              content: const Text(
                                  'คุณต้องการปิดเวอร์ชั่น ONLINE ใช่หรือไม่?'),
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
                                    _toggleValueSpeech(); // เรียกใช้ Logic ปิดเวอร์ชั่น ONLINE
                                    Phoenix.rebirth(context);
                                    // Navigator.pushAndRemoveUntil(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => const MyApp(),
                                    //   ),
                                    //   (route) => false,
                                    // );
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
                        color: valueSpeech == 0
                            ? Colors.blue
                            : Colors.red, // สีพื้นหลัง
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ATextDiskplayMedium(
                            text: valueSpeech == 0
                                ? widget.isDesktop == false &&
                                        widget.isTablet == false
                                    ? "ONLINE"
                                    : widget.isDesktop == false &&
                                            widget.isTablet == true
                                        ? "เปิด ONLINE"
                                        : "เปิดเวอร์ชั่น ONLINE"
                                : widget.isDesktop == false &&
                                        widget.isTablet == false
                                    ? "OFFLINE"
                                    : widget.isDesktop == false &&
                                            widget.isTablet == true
                                        ? "ปิด ONLINE"
                                        : "ปิดเวอร์ชั่น ONLINE",
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate:
                      widget.isTablet == false && widget.isDesktop == false
                          ? DataSearch(
                              isM: true,
                              online: widget.online,
                            )
                          : DataSearch(
                              isM: false,
                              online: widget.online,
                            ),
                );
              },
              child: widget.isTablet == false && widget.isDesktop == false
                  ? const SizedBox.shrink()
                  : Container(
                      width: widget.isDesktop ? 580 : 300,
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
          ],
        ),
      ],
    );
  }
}
