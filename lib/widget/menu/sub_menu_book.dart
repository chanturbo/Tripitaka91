import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/features/book/bookshow_title.dart';

class SubMenuExpansionTile extends StatelessWidget {
  final String titleText;
  final List<String> menuList;
  final int bookAdd;
  final bool isTablet;
  final bool isDesktop;
  final bool online;
  final Color accentColor;

  const SubMenuExpansionTile({
    super.key,
    required this.titleText,
    required this.menuList,
    required this.bookAdd,
    required this.isTablet,
    required this.isDesktop,
    required this.online,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = adaptiveTextColor(context).withValues(alpha: 0.12);
    final mutedColor = adaptiveTextColor(context).withValues(alpha: 0.45);
    final iconTint = Color.alphaBlend(
      accentColor.withValues(alpha: 0.14),
      adaptiveSurfaceColor(context),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Material(
        color: adaptiveSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            childrenPadding: const EdgeInsets.fromLTRB(14, 2, 10, 8),
            iconColor: mutedColor,
            collapsedIconColor: mutedColor,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: iconTint,
              child: Icon(
                Icons.menu_book_outlined,
                color: accentColor,
                size: 14,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: AResponsiveTitleText(
                    text: titleText,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${menuList.length} เล่ม',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
            children: menuList.map((item) {
              final index = menuList.indexOf(item);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: AResponsiveTitleText(
                  text: item,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookShowTitle(
                        triBookid: (index + bookAdd).toString(),
                        chkSearch: '',
                        isMobile: (!isTablet && !isDesktop) ? true : isTablet,
                        online: online,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
