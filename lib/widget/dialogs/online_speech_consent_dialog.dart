import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/providers/online_speech_provider.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';

/// Shows the online read-aloud disclaimer + voice-selection dialog and, if
/// the user confirms, persists valueSpeech=1 and the chosen voice.
/// Returns true if the user confirmed, false if they cancelled the dialog.
Future<bool> showOnlineSpeechConsentDialog(BuildContext context) async {
  bool confirmed = false;
  await showDialog(
    context: context,
    builder: (context) {
      bool isMaleVoice = true; // ค่าเริ่มต้นสำหรับเสียง
      bool acknowledged = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('การอ่านออกเสียงแบบออนไลน์'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'การอ่านออกเสียงหัวข้อธรรมและพระไตรปิฎกในโหมดนี้ใช้โปรแกรมอ่านออกเสียงอัตโนมัติ ซึ่งอาจอ่านออกเสียงไม่ถูกต้องครบถ้วนสมบูรณ์ในบางคำ กรุณาใช้วิจารณญาณในการรับฟัง',
                  ),
                  const SizedBox(height: 12),
                  const Text('เลือกเสียงอ่าน'),
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
                          title: const Text('เสียงผู้ชาย'),
                          value: true,
                        ),
                        RadioListTile<bool>(
                          title: const Text('เสียงผู้หญิง'),
                          value: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: acknowledged,
                    onChanged: (value) {
                      setState(() {
                        acknowledged = value ?? false;
                      });
                    },
                    title: const Text('ฉันเข้าใจและยอมรับเงื่อนไขข้างต้น'),
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
                onPressed: acknowledged
                    ? () async {
                        // ignore: use_build_context_synchronously
                        await context.read<OnlineSpeechProvider>().acknowledge(
                          isMaleVoice ? 0 : 1,
                        );
                        confirmed = true;
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    : null, // ปิดใช้งานปุ่มถ้ายังไม่ได้ติ๊กยอมรับ
                child: const Text('ยอมรับและดำเนินการต่อ'),
              ),
            ],
          );
        },
      );
    },
  );
  return confirmed;
}

/// Ensures the user has acknowledged the ONLINE read-aloud disclaimer before
/// an audio action proceeds. Returns true immediately if already logged in
/// (an account already implies consent — see AppBarCustom) or already
/// acknowledged on this device; otherwise shows the consent dialog and
/// returns whether the user confirmed it.
Future<bool> ensureOnlineSpeechConsent(BuildContext context) async {
  if (context.read<UserProvider>().isLoggedIn) return true;
  if (context.read<OnlineSpeechProvider>().isAcknowledged) return true;
  return showOnlineSpeechConsentDialog(context);
}
