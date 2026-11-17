import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/login/profile_menu.dart';

class TUserMenu extends StatelessWidget {
  const TUserMenu({
    super.key,
    required this.title,
    required this.value,
    this.icon = Icons.info_outline,
  });

  final IconData icon;

  final String title, value;

  @override
  Widget build(BuildContext context) {
    return TProfileInfoRow(icon: icon, title: title, value: Text(value));
  }
}
