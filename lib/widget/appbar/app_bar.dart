import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/providers/online_speech_provider.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
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
    final logo = Image.asset(
      'assets/images/tripitaka91_logo.png',
      fit: BoxFit.contain,
      height: 35,
      alignment: Alignment.centerLeft,
    );

    // ปุ่มนี้ทำหน้าที่ "เปลี่ยนเสียงอ่าน" เท่านั้น ไม่ต้องมีสถานะ "เปิด
    // ONLINE/BETA" ซ้ำซ้อนอีก เพราะการยืนยันเปิดโหมดอ่านออกเสียงครั้งแรก
    // เกิดขึ้นเองอยู่แล้วผ่าน ensureOnlineSpeechConsent() ทันทีที่กดลำโพง
    // จุดไหนก็ได้ในแอป — ปุ่มจึงซ่อนไว้จนกว่าจะยืนยัน/login แล้วเท่านั้น
    final onlinePill = !widget.online || needsOnlineConsent
        ? const SizedBox.shrink()
        : Tooltip(
            message:
                'แตะเพื่อสลับเสียงอ่าน (ปัจจุบัน: ${isCurrentVoiceMale ? 'ชาย' : 'หญิง'})',
            child: InkWell(
              onTap: () => _switchVoice(user, speech),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.record_voice_over,
                      color: TColors.textWhite,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: ATextDiskplayMedium(
                        text:
                            'เปลี่ยนเสียงอ่าน (${isCurrentVoiceMale ? 'ชาย' : 'หญิง'})',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

    final searchBox = GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: DataSearch(isM: false, online: widget.online),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          border: Border.all(color: TColors.grey),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          color: adaptiveSurfaceColor(context),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 10),
            Icon(Icons.search, color: adaptiveTextColor(context)),
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
    );

    if (widget.isTablet == false && widget.isDesktop == false) {
      // มือถือ: ไม่มีช่องค้นหาแสดงใน AppBar (เข้าถึงผ่านทางอื่น) จึงยังคง
      // เป็น Row ธรรมดาแบบเดิม ไม่ต้องกันพื้นที่ฝั่งขวาไว้ถ่วงสมดุล
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 2, child: logo),
          const SizedBox(width: 8),
          Flexible(flex: 3, child: onlinePill),
          GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: DataSearch(isM: true, online: widget.online),
              );
            },
            child: const SizedBox.shrink(),
          ),
        ],
      );
    }

    // แท็บเล็ต/เดสก์ท็อป: โลโก้คงขนาดตามธรรมชาติเสมอ (ไม่ยืด/หด) ปุ่ม
    // เปลี่ยนเสียงอ่านก็เป็น non-flex เช่นกัน (ปกติซ่อนอยู่เป็น
    // SizedBox.shrink() จนกว่าจะ login/ยืนยัน ONLINE แล้ว เนื้อหาตอนแสดงจริง
    // ก็สั้น ไม่เสี่ยง overflow) — ตั้งใจไม่ห่อด้วย Flexible เพราะถ้าห่อ
    // มันจะไปแย่ง flex share เท่า ๆ กับ Expanded(searchBox) (ทั้งคู่ flex
    // default = 1) พื้นที่ที่ปุ่มนี้ไม่ได้ใช้ (ตอนซ่อนอยู่) จะถูกกันไว้เฉย ๆ
    // ไม่ถูกส่งต่อให้ช่องค้นหา ทำให้ช่องค้นหาได้แค่ครึ่งเดียวของพื้นที่จริง
    // แทนที่จะยืดเต็มไปจนชิดปุ่มสมาชิก (titleSpacing ของ AppBar ตั้งเป็น 0
    // อยู่แล้ว จึงไม่มีช่องว่างคั่นระหว่างช่องค้นหากับปุ่มสมาชิก)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo,
        const SizedBox(width: 8),
        onlinePill,
        const SizedBox(width: 10),
        Expanded(child: searchBox),
      ],
    );
  }
}
