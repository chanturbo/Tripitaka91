import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/common/circular_icon_button.dart';
import 'package:tripitaka91/widget/common/index_badge.dart';

// Shared row for one dictionary entry (word + definition + volume/share/copy
// actions), used by all four dict list variants (ฉบับประมวลศัพท์ and
// ไทย-บาลี, each with its own online/offline data source) so the four
// near-identical files stay visually in sync.
class DictEntryTile extends StatelessWidget {
  final int index;
  final String word;
  final String detail;
  final bool showAudioButton;
  final VoidCallback onPlayAudio;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const DictEntryTile({
    super.key,
    required this.index,
    required this.word,
    required this.detail,
    required this.showAudioButton,
    required this.onPlayAudio,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = adaptiveTextColor(context).withValues(alpha: 0.6);
    final borderColor = adaptiveTextColor(context).withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IndexBadge(index: index, radius: 13),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontFamily: 'THSarabunNew',
                    fontSize: 17,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (showAudioButton) ...[
                      CircularIconButton(
                        icon: Icons.volume_up_rounded,
                        color: Colors.blue[300]!,
                        onTap: onPlayAudio,
                      ),
                      const SizedBox(width: 4),
                    ],
                    CircularIconButton(
                      icon: Icons.ios_share_rounded,
                      color: Colors.blue[300]!,
                      onTap: onShare,
                    ),
                    const SizedBox(width: 4),
                    CircularIconButton(
                      icon: Icons.copy_rounded,
                      color: Colors.blue[300]!,
                      onTap: onCopy,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
