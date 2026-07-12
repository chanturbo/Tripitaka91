import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripitaka91/utils/constants/online_label.dart';
import 'package:tripitaka91/utils/providers/online_speech_provider.dart';
import 'package:tripitaka91/utils/providers/user_provider.dart';

/// Shows the ONLINE read-aloud disclaimer + voice-selection dialog and, if
/// the user confirms, persists valueSpeech=1 and the chosen voice.
/// Returns true if the user confirmed, false if they cancelled the dialog.
Future<bool> showOnlineSpeechConsentDialog(BuildContext context) async {
  bool confirmed = false;
  await showDialog(
    context: context,
    builder: (context) {
      bool isMaleVoice = true; // ค่าเริ่มต้นสำหรับเสียง
      TextEditingController textController = TextEditingController();
      bool isInputValid = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('แจ้งเตือน'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '     นี่คือเวอร์ชั่น $kOnlineModeLabel ในโหมดการอ่านออกเสียงหัวข้อธรรมและพระไตรปิฎก โดยใช้โปรแกรมอัตโนมัติในการอ่าน ซึ่งอาจทำให้การอ่านออกเสียงยังไม่ถูกต้อง ครบถ้วน สมบูรณ์ ดังนั้น ผู้ใช้งานควรใช้วิจารณญาณในการรับฟัง\n\nเลือกเสียงอ่าน',
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
                  const SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: 'พิมพ์ "$kOnlineModeLabel" เพื่อดำเนินการต่อ',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        isInputValid =
                            value.trim().toUpperCase() == kOnlineModeLabel;
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
                    ? () async {
                        // ignore: use_build_context_synchronously
                        await context.read<OnlineSpeechProvider>().acknowledge(
                          isMaleVoice ? 0 : 1,
                        );
                        confirmed = true;
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    : null, // ปิดใช้งานปุ่มถ้ายังไม่ได้ป้อน "ONLINE"
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInputValid ? Colors.red : Colors.grey,
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
