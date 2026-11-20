import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';

/// Admin-only "edit dhamma topic detail" dialog, shared by every screen that
/// lets an admin correct a title's detail text (previously copy-pasted
/// across bookshow_title.dart, show_title_sub.dart, pageviews_html.dart and
/// title_card.dart).
///
/// [onSaved] runs after a successful save (e.g. to refresh the caller's list).
Future<void> showEditDhammaTopicDialog({
  required BuildContext context,
  required String initialText,
  required String tripitaka91No,
  required String tripitaka91Code,
  VoidCallback? onSaved,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _EditDhammaTopicDialog(
      initialText: initialText,
      tripitaka91No: tripitaka91No,
      tripitaka91Code: tripitaka91Code,
      onSaved: onSaved,
    ),
  );
}

class _EditDhammaTopicDialog extends StatefulWidget {
  final String initialText;
  final String tripitaka91No;
  final String tripitaka91Code;
  final VoidCallback? onSaved;

  const _EditDhammaTopicDialog({
    required this.initialText,
    required this.tripitaka91No,
    required this.tripitaka91Code,
    this.onSaved,
  });

  @override
  State<_EditDhammaTopicDialog> createState() =>
      _EditDhammaTopicDialogState();
}

class _EditDhammaTopicDialogState extends State<_EditDhammaTopicDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );
  bool _saving = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'กรุณาป้อนข้อมูลให้ครบถ้วน');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      final usersChk = await getUsersList();
      if (usersChk == null) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _errorText = 'กรุณาเข้าสู่ระบบก่อน';
        });
        return;
      }

      final response = await http.post(
        Uri.parse(tURLtitleEdit),
        body: {
          'token': tSecretAPIKey,
          'tripitaka91no': widget.tripitaka91No,
          'tripitaka91code': widget.tripitaka91Code,
          'titledetail': text,
          'username': usersChk.username,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          // จับ ScaffoldMessenger ไว้ก่อน pop เพราะหลัง pop ไปแล้ว context ของ
          // dialog อาจถูก deactivate ทำให้ ScaffoldMessenger.of(context) ไม่ปลอดภัย
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          widget.onSaved?.call();
          messenger.showSnackBar(
            const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
          );
          return;
        }
        setState(() {
          _saving = false;
          _errorText = '${jsonResponse['message']}';
        });
      } else {
        setState(() {
          _saving = false;
          _errorText = 'เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ (${response.statusCode})';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = 'เกิดข้อผิดพลาด: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'แก้ไขหัวข้อธรรม',
              style: TextStyle(fontFamily: 'THSarabunNew'),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สำหรับแอดมินเท่านั้น',
              style: TextStyle(
                fontFamily: 'THSarabunNew',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              enabled: !_saving,
              style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 24),
              decoration: const InputDecoration(
                labelText: 'รายละเอียดหัวข้อธรรม',
                labelStyle: TextStyle(fontFamily: 'THSarabunNew'),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ).copyWith(errorText: _errorText),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'ยกเลิก',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 18),
          ),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save, size: 18),
          label: const Text(
            'บันทึก',
            style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 18),
          ),
        ),
      ],
    );
  }
}
