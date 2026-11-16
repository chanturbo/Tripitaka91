import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';

// Muted numbered circle for list rows (dictionary entries, book topics),
// replacing the old solid Colors.blue[900] CircleAvatar.
class IndexBadge extends StatelessWidget {
  final int index;
  final double radius;

  const IndexBadge({super.key, required this.index, this.radius = 15});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: adaptiveTextColor(context).withValues(alpha: 0.08),
      child: Text(
        '$index',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: adaptiveTextColor(context).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
