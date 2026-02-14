import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/text_strings.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/models/users_login.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';

class LoginPageDialog extends StatefulWidget {
  const LoginPageDialog({super.key});

  @override
  State<LoginPageDialog> createState() => _LoginPageDialogState();
}

class _LoginPageDialogState extends State<LoginPageDialog> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late UsersLogin usersLogin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // appBar: AppBar(
          //   title: const Text(TTexts.signIn),
          //   actions: [
          //     IconButton(
          //       color: TColors.white,
          //       icon: const Icon(Icons.close),
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //     ),
          //   ],
          // ),
          body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // จัดให้อยู่กลางแกนแนวนอน
          mainAxisAlignment:
              MainAxisAlignment.center, // จัดให้อยู่กลางแกนแนวตั้ง
          children: [
            _inputField(context),
          ],
        ),
      )),
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: TTexts.username,
            hintStyle:
                const TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
          autofillHints: const [AutofillHints.username], // เพิ่มบรรทัดนี้
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: TTexts.password,
            hintStyle:
                const TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
          autofillHints: const [AutofillHints.password], // เพิ่มบรรทัดนี้
        ),
        const SizedBox(height: 10),
        Center(
          child: Row(
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () {
                  _login(context);
                },
                child: const ATextDiskplayMedium(
                  text: ' เข้าสู่ระบบ ',
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const ATextDiskplayMedium(
                  text: ' ยกเลิก ',
                ),
              ),
            ],
          ),
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     _login(context);
        //   },
        //   style: ElevatedButton.styleFrom(
        //     shape: const StadiumBorder(),
        //     padding: const EdgeInsets.symmetric(vertical: 16),
        //   ),
        //   child: const Text(
        //     TTexts.signIn,
        //     style: TextStyle(fontSize: 20),
        //   ),
        // )
      ],
    );
  }

  Future<void> _login(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(TTexts.enterUserNamePassword),
        ),
      );
    } else {
      bool chkLogin = await loginUser(username, password, tSecretAPIKey);
      if (chkLogin) {
        saveUsersList(createUserModel());
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เข้าสู่ระบบเรียบร้อยแล้ว'),
          ),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true); // เมื่อปิด dialog ให้ส่งค่า true กลับไป
      } else {
        // ignore: use_build_context_synchronously
        await showCustomDialog(context);
      }
    }
  }

  Future<void> showCustomDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('รายงาน'),
          content: const Text('ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Users createUserModel() {
    return Users(
      username: usersLogin.user.username,
      password: usersLogin.user.password,
      firstNameid: usersLogin.user.firstNameid,
      firstName: usersLogin.user.firstName,
      lastName: usersLogin.user.lastName,
      birthDate: DateTime.parse(usersLogin.user.birthDate.toString()),
      email: usersLogin.user.email,
      voiceChoice: usersLogin.user.voiceChoice,
      active: usersLogin.user.active.toString(),
      levelAccess: usersLogin.user.levelAccess.toString(),
      permissionVoice: usersLogin.user.permissionVoice.toString(),
      counterWordcorrec: usersLogin.user.counterWordcorrec,
      permissionLogEdit: usersLogin.user.permissionLogEdit.toString(),
    );
  }

  Future<bool> loginUser(
      String userEmail, String password, String token) async {
    try {
      var client = http.Client();
      var uri = Uri.parse(tURLuserChk);
      var data = {
        'identifier': userEmail,
        'password': password,
        'token': token,
      };

      var response = await client.post(
        uri,
        body: data,
      );

      if (response.statusCode == 200) {
        var json = response.body;
        var decodedJson = jsonDecode(json); 
        // print('print ${decodedJson['user']['level_access']}');
        usersLogin = UsersLogin.fromJson(decodedJson);
        saveValueCorrect(int.parse(usersLogin.user.counterWordcorrec));
        return usersLogin.success;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in loginUser: $e');
    }

    return false;
  }
}
