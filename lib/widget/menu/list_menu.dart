import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';
import 'package:tripitaka91/utils/theme/theme_helpers.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/info/info.dart';
import 'package:tripitaka91/widget/menu/data_menu.dart';
import 'package:tripitaka91/widget/menu/sub_menu_book.dart';
import 'package:tripitaka91/widget/menu/sub_menu_title.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dict.dart';
import 'package:tripitaka91/widget/showdict/dictshow_dictbt.dart';
import 'package:url_launcher/url_launcher.dart';

// Accent colors for the three piṭaka categories. Chosen dark enough to hold
// 4.5:1 contrast for the white badge/icon text drawn on top of them.
const Color _kVinayaAccent = Color(0xFF1F3A5F);
const Color _kSuttaAccent = Color(0xFF1E6F5C);
const Color _kAbhidhammaAccent = Color(0xFF6B2E5C);
const Color _kYoutubeAccent = Color(0xFFB3261E);

class ListMenu extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;
  final bool online;
  const ListMenu({
    super.key,
    required this.isTablet,
    required this.isDesktop,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 10),
        const _MenuSectionLabel(
          text: 'หมวดพระไตรปิฎก',
        ),
        SubMenuExpansionTile(
          titleText: 'พระวินัยปิฎก',
          menuList: book_1,
          bookAdd: 1,
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
          accentColor: _kVinayaAccent,
        ),
        SubMenuExpansionTile(
          titleText: 'พระสุตตันตปิฎก',
          menuList: book_2,
          bookAdd: 11,
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
          accentColor: _kSuttaAccent,
        ),
        SubMenuExpansionTile(
          titleText: 'พระอภิธรรมปิฎก',
          menuList: book_3,
          bookAdd: 75,
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
          accentColor: _kAbhidhammaAccent,
        ),
        const SizedBox(height: 12),
        const _MenuSectionLabel(
          text: 'หมวดสื่อเสริมจาก YouTube',
        ),
        _MenuLinkTile(
          icon: Icons.play_arrow,
          titleText: 'สรุปหัวข้อธรรมจาก YouTube',
          description:
              'ค้นหาและสรุปหัวข้อธรรมที่เคยบรรยายใน YouTube พร้อมลิงก์กระโดดไปยังช่วงเวลาที่กล่าวถึงโดยตรง',
          isTablet: isTablet,
          isDesktop: isDesktop,
          accentColor: _kYoutubeAccent,
          onTap: () async {
            final uri = Uri.parse('http://localhost:8081/');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
        const SizedBox(height: 12),
        const _MenuSectionLabel(
          text: 'หมวดหัวข้อธรรมสำคัญ',
        ),
        SubMenuNoIconExpansionTile(
          titleText: '1.รวมชุดข้อมูลและหัวข้อพระไตรปิฎก',
          menuList: menu_9_1,
          menuMain: "9.1",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '2.หลักสูตรอินเตอร์เน็ต',
          menuList: menu_9_2,
          menuMain: "9.2",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '3.แก้ข้อกล่าวหาของสังคมด้วยคำสอนของพระพุทธเจ้า',
          menuList: menu_9_3,
          menuMain: "9.3",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '4.หัวข้อวัตถุในพระพุทธศาสนาที่ถูกต้อง',
          menuList: menu_9_4,
          menuMain: "9.4",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '5.หนังสือความประพฤติของพระ',
          menuList: menu_9_5,
          menuMain: "9.5",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '6.หัวข้อพระวินัยปิฎก และอรรถกถาแปล-พุทธทำนาย',
          menuList: menu_9_6,
          menuMain: "9.6",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '7.การประกาศ และระเบียบวัด',
          menuList: menu_9_7,
          menuMain: "9.7",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '8.ข้อมูลประกอบเพิ่มเติม แก้ข้อกล่าวหาสังคม',
          menuList: menu_9_8,
          menuMain: "9.8",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        SubMenuNoIconExpansionTile(
          titleText: '9.ข้อมูลพระไตรปิฎก กับเหตุการณ์ปัจจุบัน',
          menuList: menu_9_9,
          menuMain: "9.9",
          isTablet: isTablet,
          isDesktop: isDesktop,
          online: online,
        ),
        const SizedBox(height: 12),
        const _MenuSectionLabel(
          text: 'พจนานุกรม',
        ),
        _MenuNavTile(
          icon: Icons.menu_book_outlined,
          text: 'พจนานุกรม ฉบับประมวลศัพท์',
          isTablet: isTablet,
          isDesktop: isDesktop,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DictShowTitle(
                  online: online,
                ),
              ),
            );
          },
        ),
        online
            ? _MenuNavTile(
                icon: Icons.translate_outlined,
                text: 'พจนานุกรม ไทย-บาลี',
                isTablet: isTablet,
                isDesktop: isDesktop,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DictbtShowTitle(
                        online: online,
                      ),
                    ),
                  );
                },
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 12),
        const _MenuSectionLabel(
          text: 'เกี่ยวกับโปรแกรม',
        ),
        _MenuNavTile(
          icon: Icons.info_outline,
          text: 'เกี่ยวกับโปรแกรม',
          isTablet: isTablet,
          isDesktop: isDesktop,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TripitakaInfoWidget(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Section header used throughout the drawer in place of the old orange
// flag-shaped banner: a short accent bar plus a muted, letter-spaced label.
class _MenuSectionLabel extends StatelessWidget {
  final String text;

  const _MenuSectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: TColors.primary1,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: adaptiveTextColor(context).withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// Plain navigation row (dictionary / about): a quiet icon beside the title,
// no card or badge, matching the rest of the drawer's light-touch styling.
class _MenuNavTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onTap;

  const _MenuNavTile({
    required this.icon,
    required this.text,
    required this.isTablet,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      leading: Icon(
        icon,
        size: 18,
        color: adaptiveTextColor(context).withValues(alpha: 0.55),
      ),
      title: AResponsiveTitleText(
        text: text,
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      onTap: onTap,
    );
  }
}

// Single-tap link tile styled the same as SubMenuExpansionTile's collapsed
// row (bordered card, tinted icon badge, accent color) so an external link
// like the YouTube dharma-summary tool reads as part of the same "หมวด
// พระไตรปิฎก" family of tiles instead of a one-off banner. Unlike
// SubMenuExpansionTile, it has no children to expand — onTap fires directly.
class _MenuLinkTile extends StatelessWidget {
  final IconData icon;
  final String titleText;
  final String description;
  final bool isTablet;
  final bool isDesktop;
  final Color accentColor;
  final VoidCallback onTap;

  const _MenuLinkTile({
    required this.icon,
    required this.titleText,
    required this.description,
    required this.isTablet,
    required this.isDesktop,
    required this.accentColor,
    required this.onTap,
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: iconTint,
            child: Icon(icon, color: accentColor, size: 14),
          ),
          title: AResponsiveTitleText(
            text: titleText,
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
          subtitle: Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: mutedColor),
          ),
          trailing: Icon(Icons.open_in_new, color: mutedColor, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
