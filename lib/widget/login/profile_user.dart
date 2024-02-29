import 'package:flutter/material.dart';

class TUserMenu extends StatelessWidget {
  const TUserMenu({
    super.key,
    required this.title,
    required this.value,
    this.icon = Icons.arrow_right,
  });

  final IconData icon;

  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Text(title, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(
          flex: 5,
          child: Text(value,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis),
        ),
        const Expanded(child: Text('')),
        // Expanded(child: Icon(icon, size: 18)),
      ],
    );
  }
}
