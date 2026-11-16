import 'package:flutter/material.dart';

// Small circular tap target for inline row actions (volume/share/copy/edit),
// used wherever a bare Icon+InkWell needs a visible ripple and a touch
// target bigger than the icon's own bounding box.
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 17,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
