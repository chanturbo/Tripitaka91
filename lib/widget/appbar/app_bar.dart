import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/online_label.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/providers/online_speech_provider.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/dialogs/online_speech_consent_dialog.dart';
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
  // เมื่อ login อยู่ เสียงปัจจุบันมาจากบัญชี (user.voiceChoice) เสมอ
  // (ดู RemoteServiceSoundsGetLink.getLink) ไม่ใช่ค่าอุปกรณ์จาก speech
  bool _isCurrentVoiceMale(Users? user, OnlineSpeechProvider speech) =>
      user != null
      ? user.voiceChoice != 'เสียงผู้หญิง'
      : speech.voiceChoice == 0;

  // ผู้ใช้ที่ login อยู่ถือว่ายอมรับ ONLINE โดยปริยาย (มีบัญชี+ตั้งค่าเสียงจริงอยู่แล้ว)
  // ต้องยืนยัน disclaimer ก็ต่อเมื่อยังไม่ login และยังไม่เคยกดยอมรับในเครื่องนี้
  bool _needsOnlineConsent(Users? user, OnlineSpeechProvider speech) =>
      user == null && !speech.isAcknowledged;

  Future<void> _confirmVoiceChoice(Users user, String voiceChoice) async {
    final response = await http.post(
      Uri.parse(tURLconfirmVoiceChoice),
      body: {
        'token': tSecretAPIKey,
        'user': user.username,
        'voice_choice': voiceChoice,
      },
    );
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode != 200 || jsonResponse['success'] != true) {
      throw Exception(jsonResponse['message'] ?? 'เกิดข้อผิดพลาด');
    }
    // ignore: use_build_context_synchronously
    context.read<UserProvider>().updateVoiceChoice(voiceChoice);
  }

  Future<void> _switchVoice(Users? user, OnlineSpeechProvider speech) async {
    final newVoiceLabel = _isCurrentVoiceMale(user, speech)
        ? 'เสียงผู้หญิง'
        : 'เสียงผู้ชาย';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันเปลี่ยนเสียงอ่าน'),
          content: Text('ต้องการเปลี่ยนเป็น$newVoiceLabel ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    if (user != null) {
      try {
        await _confirmVoiceChoice(user, newVoiceLabel);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('กำหนดเสียงอ่านไม่สำเร็จ: $e')));
      }
    } else {
      await speech.setVoiceChoice(newVoiceLabel == 'เสียงผู้หญิง' ? 1 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final speech = context.watch<OnlineSpeechProvider>();
    final needsOnlineConsent = _needsOnlineConsent(user, speech);
    final isCurrentVoiceMale = _isCurrentVoiceMale(user, speech);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // สัดส่วนพื้นที่ทั้งแถวคิดจากเนื้อหาจริงของแต่ละส่วน ไม่ใช้ Spacer
            // เปล่าๆ อีกต่อไป (ของเดิมกิน flex:1 ไปเฉยๆ โดยไม่มีอะไรแสดง) —
            // โลโก้ (flex:2) ไม่ยืดเพราะ BoxFit.contain + ชิดซ้าย พื้นที่ส่วน
            // เกินจึงกลายเป็นช่องว่างก่อนถึงปุ่มเองอยู่แล้ว, ปุ่ม ONLINE/
            // เปลี่ยนเสียงอ่าน (flex:3) มีไอคอน+ข้อความต้องการพื้นที่มากกว่า,
            // ช่องค้นหา (flex:4 เฉพาะแท็บเล็ต/เดสก์ท็อป) เป็นองค์ประกอบหลัก
            // จึงได้พื้นที่มากที่สุด
            Flexible(
              flex: 2,
              child: Image.asset(
                'assets/images/tripitaka91_logo.png',
                fit: BoxFit.contain,
                height: 35,
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 3,
              child: !widget.online
                  ? const SizedBox.shrink()
                  : Tooltip(
                      message: needsOnlineConsent
                          ? 'เปิดโหมดอ่านออกเสียง $kOnlineModeLabel'
                          : 'แตะเพื่อสลับเสียงอ่าน (ปัจจุบัน: ${isCurrentVoiceMale ? 'ชาย' : 'หญิง'})',
                      child: InkWell(
                        onTap: () async {
                          if (needsOnlineConsent) {
                            // showOnlineSpeechConsentDialog บันทึกผ่าน
                            // OnlineSpeechProvider เอง ปุ่มนี้จะรีบิลด์เป็น
                            // "เปลี่ยนเสียงอ่าน" ทันทีจาก context.watch ด้านบน
                            // ไม่ต้อง Phoenix.rebirth() รีสตาร์ทแอปอีกแล้ว
                            await showOnlineSpeechConsentDialog(context);
                          } else {
                            _switchVoice(user, speech);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: needsOnlineConsent
                                ? TColors.info
                                : TColors.success, // สีพื้นหลัง
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                needsOnlineConsent
                                    ? Icons.podcasts_outlined
                                    : Icons.record_voice_over,
                                color: TColors.textWhite,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: ATextDiskplayMedium(
                                  text: needsOnlineConsent
                                      ? 'เปิด $kOnlineModeLabel'
                                      : 'เปลี่ยนเสียงอ่าน (${isCurrentVoiceMale ? 'ชาย' : 'หญิง'})',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            widget.isTablet == false && widget.isDesktop == false
                ? GestureDetector(
                    onTap: () {
                      showSearch(
                        context: context,
                        delegate: DataSearch(isM: true, online: widget.online),
                      );
                    },
                    child: const SizedBox.shrink(),
                  )
                : Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: DataSearch(
                            isM: false,
                            online: widget.online,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: TColors.grey),
                          borderRadius: BorderRadius.circular(
                            TSizes.cardRadiusLg,
                          ),
                          color: adaptiveSurfaceColor(context),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(width: 10),
                            Icon(
                              Icons.search,
                              color: adaptiveTextColor(context),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Flexible(
                              child: Text(
                                'ค้นหา...',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
