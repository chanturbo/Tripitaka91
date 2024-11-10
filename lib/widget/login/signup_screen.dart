import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/text_strings.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';
import 'package:tripitaka91/utils/validators/validation.dart';
import 'package:tripitaka91/widget/login/loading_dialog.dart';
import 'package:tripitaka91/widget/login/login.dart';
import 'package:intl/intl.dart';
import 'package:tripitaka91/widget/login/member_tab_show.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Users users;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _firstNameIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(TTexts.createAccount),
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
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(),
                _inputFields(context),
                _loginInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          TTexts.createAccount,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(TTexts.detailGetStart),
      ],
    );
  }

  Widget _inputFields(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            hintText: TTexts.username,
            prefixIcon: Icons.person,
            controller: _userNameController,
            validator: TValidator.validateUserName,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            hintText: TTexts.email,
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            validator: TValidator.validateEmail,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            hintText: TTexts.firstNameId,
            prefixIcon: Icons.person,
            controller: _firstNameIdController,
            validator: TValidator.validateFirstId,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            hintText: TTexts.firstName,
            prefixIcon: Icons.person,
            controller: _firstNameController,
            validator: TValidator.validateFirstName,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            hintText: TTexts.lastName,
            prefixIcon: Icons.person,
            controller: _lastNameController,
            validator: TValidator.validateLastName,
          ),
          const SizedBox(height: 10),
          TextFormField(
            validator: TValidator.validateDob,
            controller: _dobController,
            readOnly: true, // ทำให้เป็น readonly
            onTap: () async {
              DateTime selectedDate = DateTime.now();

              // แสดง DatePicker
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              // ตรวจสอบวันที่ที่เลือก
              if (pickedDate != null && pickedDate != selectedDate) {
                setState(() {
                  _dobController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                });
              }
            },
            decoration: InputDecoration(
              hintText: TTexts.dateOfBirth,
              hintStyle:
                  const TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            hintText: TTexts.password,
            prefixIcon: Icons.password_outlined,
            controller: _passwordController,
            validator: TValidator.validatePassword,
            obscureText: true,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            hintText: TTexts.passwordConfirm,
            prefixIcon: Icons.password_outlined,
            controller: _passwordConfirmController,
            validator: (value) => TValidator.validatePasswordMatch(
                _passwordConfirmController.text, _passwordController.text),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Perform data submission
                bool loginResult =
                    await loginUser(_userNameController.text, tSecretAPIKey);
                if (loginResult) {
                  // ignore: use_build_context_synchronously
                  showCustomDialog(context);
                } else {
                  // แสดง process dialog ระหว่างตรวจสอบข้อมูลกับ Server API
                  // ignore: use_build_context_synchronously
                  LoadingDialog.show(context);

                  // เรียก API เพื่อตรวจสอบข้อมูล (ในตัวอย่างนี้จะใช้ Future.delayed แทน)
                  // เช่นเปลี่ยนเป็น await apiService.login(username, password);
                  await Future.delayed(const Duration(seconds: 1));

                  // ปิด process dialog
                  users = createUserModel();
                  saveValueCorrect(int.parse('0'));
                  bool loginSucess = await saveUser(users, tSecretAPIKey);
                  // ignore: use_build_context_synchronously
                  LoadingDialog.hide(context);
                  if (loginSucess) {
                    saveUsersList(users);
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MemberTabShow(
                                indexShow: 0,
                              )),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              TTexts.signUp,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Users createUserModel() {
    return Users(
      username: _userNameController.text,
      password: _passwordController.text,
      firstNameid: _firstNameIdController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      birthDate: DateTime.parse(
          _dobController.text), // ตัวอย่าง, ให้แปลงจาก String เป็น DateTime
      email: _emailController.text,
      voiceChoice: "เสียงผู้ชาย",
      active: '0',
      levelAccess: "2",
      permissionVoice: '0',
      counterWordcorrec: "0",
      permissionLogEdit: '0',
    );
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // สร้าง AlertDialog
        return AlertDialog(
          title: const Text('รายงาน'),
          content: Text(
              'มีข้อมูลชื่อผู้ใช้งาน ${_userNameController.text} นี้อยู่แล้ว \nกรุณาเข้าสู่ระบบ.'),
          actions: [
            TextButton(
              onPressed: () {
                // ปิด Dialog
                Navigator.of(context).pop();
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> saveUser(Users users, String token) async {
    try {
      var client = http.Client();
      var uri = Uri.parse(tURLchkSaveUser);
      var data = {
        'username': users.username,
        'password': users.password,
        'first_nameid': users.firstNameid,
        'first_name': users.firstName,
        'last_name': users.lastName,
        'dateofbirth': users.birthDate.toIso8601String(),
        'email': users.email,
        'token': token,
      };

      var response = await client.post(
        uri,
        body: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in saveUser: $e');
    }

    return false;
  }

  Future<bool> loginUser(String userEmail, String token) async {
    try {
      var client = http.Client();
      var uri = Uri.parse(tURLchkUserPass);
      var data = {
        'identifier': userEmail,
        'token': token,
      };

      var response = await client.post(
        uri,
        body: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in loginUser: $e');
    }

    return false;
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    TextEditingController? controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
        fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
        filled: true,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _loginInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(TTexts.readyAccount),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(TTexts.signIn),
        ),
      ],
    );
  }
}
