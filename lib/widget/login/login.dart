import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/main.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/text_strings.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/models/users_login.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/widget/login/signup_screen.dart';
import 'package:url_launcher/link.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String msgLogin = 'ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง';
  late UsersLogin usersLogin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(TTexts.signIn),
          actions: [
            IconButton(
              color: TColors.white,
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              _inputField(context),
              _forgotPassword(context),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          TTexts.loginTitle,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(TTexts.loginSubTitle),
      ],
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
        ElevatedButton(
          onPressed: () {
            _login(context);
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            TTexts.signIn,
            style: TextStyle(fontSize: 20),
          ),
        )
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
        clearValueBeta();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MyApp()), // แทนที่หน้าเดิม
        );

        // // ignore: use_build_context_synchronously
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => const MemberTabShow(
        //             indexShow: 0,
        //           )),
        // );
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
          content: Text(msgLogin),
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
        var decodedJson = jsonDecode(utf8.decode(json.runes.toList()));

        if (decodedJson['user']['active'] == 0) {
          msgLogin =
              'บัญชีของคุณอยู่ระหว่างรอการยืนยันการสมัครสมาชิกจากผู้ดูแลระบบ';
          return false;
        } else {
          usersLogin = UsersLogin.fromJson(decodedJson);
          saveValueCorrect(int.parse(usersLogin.user.counterWordcorrec));
          return usersLogin.success;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in loginUser: $e');
    }
    msgLogin = 'ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง';
    return false;
  }

  void _showDialogResetPass(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แจ้งขอเปลี่ยนรหัสผ่าน'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('กรุณาส่งอีเมลไปยัง chanturbo@hotmail.com'),
              Text('หรือโทรติดต่อเบอร์ 0804655782 คุณชาญชัย'),
              Text('เพื่อขอเปลี่ยนรหัสผ่าน'),
              Text('หรือแจ้งในกลุ่ม Facebook ชื่อ Tripitaka91'),
            ],
          ),
          actions: [
            const Padding(padding: EdgeInsets.all(16.0)),
            Link(
              uri:
                  Uri.parse('https://www.facebook.com/groups/719264214834970/'),
              target: LinkTarget.blank,
              builder: (BuildContext ctx, FollowLink? openLink) {
                return TextButton.icon(
                  onPressed: openLink,
                  label: const Text('เข้ากลุ่ม Facebook'),
                  icon: const Icon(Icons.read_more),
                );
              },
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  _forgotPassword(context) {
    return TextButton(
        onPressed: () {
          _showDialogResetPass(context);
        },
        child: const Text(TTexts.forgetPassword));
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(TTexts.dontNotAccount),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: const Text(TTexts.signUp),
        )
      ],
    );
  }
}
