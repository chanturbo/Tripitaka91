import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';

class TProfileMenu extends StatelessWidget {
  const TProfileMenu({
    super.key,
    required this.onPressed,
    required this.title,
    required this.value,
    this.icon = Icons.info_outline,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return TProfileInfoRow(icon: icon, title: title, value: Text(value));
  }
}

// Shared row layout used by TProfileMenu and the *Future variants: a small
// tinted icon badge, then label (muted, small) stacked above value (medium),
// matching a typical web settings-list row instead of the old 3-column Row.
class TProfileInfoRow extends StatelessWidget {
  const TProfileInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final mutedColor = adaptiveTextColor(context).withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TColors.buttonPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: TColors.buttonPrimary),
          ),
          const SizedBox(width: TSizes.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
                const SizedBox(height: 2),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: adaptiveTextColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                  child: value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
