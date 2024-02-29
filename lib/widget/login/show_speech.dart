import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/widget/login/show_logspeech.dart';

class ShowSpeech extends StatefulWidget {
  const ShowSpeech({super.key});

  @override
  State<ShowSpeech> createState() => _ShowSpeechState();
}

class _ShowSpeechState extends State<ShowSpeech> {
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
          ? LogSpeechScreen(username: _usersData!.username)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
