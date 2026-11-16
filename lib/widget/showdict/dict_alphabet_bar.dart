import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';

// Letter picker for the dictionary pages: a horizontally scrollable row of
// Thai letters with a highlighted selection and prev/next nudge buttons,
// replacing the old plain blue circles + separate flag-shaped scroll buttons.
class DictAlphabetBar extends StatelessWidget {
  final ScrollController scrollController;
  final String selected;
  final ValueChanged<String> onSelect;

  const DictAlphabetBar({
    super.key,
    required this.scrollController,
    required this.selected,
    required this.onSelect,
  });

  void _scrollBy(double delta) {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.offset + delta,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = adaptiveTextColor(context).withValues(alpha: 0.12);
    final mutedColor = adaptiveTextColor(context).withValues(alpha: 0.6);

    return Container(
      height: 54,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: mutedColor),
            onPressed: () => _scrollBy(-200),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: thaikeyboard.length,
              itemBuilder: (context, index) {
                final letter = thaikeyboard[index];
                final isSelected = letter == selected;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 3,
                  ),
                  child: Material(
                    color: isSelected ? TColors.primary1 : Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => onSelect(letter),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : adaptiveTextColor(
                                      context,
                                    ).withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: mutedColor),
            onPressed: () => _scrollBy(200),
          ),
        ],
      ),
    );
  }
}
