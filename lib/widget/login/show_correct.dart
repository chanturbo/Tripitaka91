import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/login/show_logcorrect.dart';

class ShowCorrect extends StatefulWidget {
  const ShowCorrect({super.key});

  @override
  State<ShowCorrect> createState() => _ShowCorrectState();
}

class _ShowCorrectState extends State<ShowCorrect> {
  Users? _usersData;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    _usersData = await getUsersList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _usersData != null
          ? LogEditScreen(username: _usersData!.username)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
