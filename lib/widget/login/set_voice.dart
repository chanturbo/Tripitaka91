import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';

class SetVoice extends StatefulWidget {
  final String tmpUser;
  const SetVoice({super.key, required this.tmpUser});

  @override
  State<SetVoice> createState() => _SetVoiceState();
}

class _SetVoiceState extends State<SetVoice> {
  String selectedVoice = 'เสียงผู้ชาย'; // ค่าเริ่มต้นเป็นเสียงผู้ชาย

  Future<void> _fetchConfirmVoiceChoice(String voiceChoice) async {
    try {
      final response = await http.post(
        Uri.parse(tURLconfirmVoiceChoice),
        body: {
          'token': tSecretAPIKey,
          'user': widget.tmpUser,
          'voice_choice': voiceChoice, // เพิ่มการส่งค่า level (opt)
        },
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var jsonResponse = jsonDecode(json);

        if (jsonResponse['success'] == true) {
          // ignore: use_build_context_synchronously
          _showSnackbar(context, 'กำหนดเสียงอ่านเรียบร้อยแล้ว');
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

  void _showSnackbar(BuildContext context, String info) {
    final snackBar = SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เปลี่ยนเสียงอ่าน'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('เสียงผู้ชาย'),
              value: 'เสียงผู้ชาย',
              groupValue: selectedVoice,
              onChanged: (value) {
                setState(() {
                  selectedVoice = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('เสียงผู้หญิง'),
              value: 'เสียงผู้หญิง',
              groupValue: selectedVoice,
              onChanged: (value) {
                setState(() {
                  selectedVoice = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _fetchConfirmVoiceChoice(selectedVoice);
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(true);
          },
          child: const Text('ยืนยันเปลี่ยนเสียงอ่าน'),
        ),
      ],
    );
  }
}
