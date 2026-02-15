import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาป้อนรหัสผ่านให้ครบถ้วน.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณายืนยันรหัสใหม่.';
    }
    if (value != _newPasswordController.text) {
      return 'รหัสผ่านใหม่ไม่ตรงกัน.';
    }
    return null;
  }

  Future<void> _changePassword() async {
    // Validate password fields
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Users? users = await getUsersList();
    String tmpUser = 'guest';
    if (users != null) {
      tmpUser = users.username;
    }

    const String url = tURLuserChangePass;
    final response = await http.post(Uri.parse(url), body: {
      'token': tSecretAPIKey,
      'email': tmpUser,
      'old_password': _oldPasswordController.text,
      'new_password': _newPasswordController.text,
    });

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      // Handle success
      var json = response.body;
      var jsonResponse = jsonDecode(json);

      if (jsonResponse['success'] == true) {
        // ถ้าสำเร็จ คืนค่าจำนวนรายการที่ได้จาก API
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')));
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true);

        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: const Text('เปลี่ยนรหัสผ่านสำเร็จ'),
        //       content: Text(jsonResponse['message']),
        //       actions: [
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //           child: const Text('OK'),
        //         ),
        //       ],
        //     );
        //   },
        // );
      } else {
        // ถ้าไม่สำเร็จ คืนค่าว่าง
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('เปลี่ยนรหัสผ่านไม่สำเร็จ'),
              content: Text(jsonResponse['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle error
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(responseData['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เปลี่ยนรหัสผ่าน'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(labelText: 'รหัสเดิม'),
              obscureText: true,
              validator: _validatePassword,
            ),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'รหัสใหม่'),
              obscureText: true,
              validator: _validatePassword,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'ยืนยันรหัสใหม่'),
              obscureText: true,
              validator: _validateConfirmPassword,
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
          onPressed: () {
            _changePassword();
          },
          child: const Text('เปลี่ยนรหัสผ่าน'),
        ),
      ],
    );
  }
}
