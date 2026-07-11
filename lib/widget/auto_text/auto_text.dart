import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ATextLabelLarge extends StatelessWidget {
  final String text;

  const ATextLabelLarge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}

class ATextLabelMedium extends StatelessWidget {
  final String text;

  const ATextLabelMedium({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class ATextLabelMediumColor extends StatelessWidget {
  final String text;
  final Color color; // เพิ่มพารามิเตอร์สำหรับระบุสี

  const ATextLabelMediumColor(
      {super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    );
  }
}

class ATextLabelSmall extends StatelessWidget {
  final String text;

  const ATextLabelSmall({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}

class ATextTitleLarge extends StatelessWidget {
  final String text;

  const ATextTitleLarge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class ATextTitleLargeTH extends StatelessWidget {
  final String text;

  const ATextTitleLargeTH({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 30),
      maxFontSize: 40,
      minFontSize: 26,
    );
  }
}

class ATextTitleMedium extends StatelessWidget {
  final String text;

  const ATextTitleMedium({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class ATextTitleMedium18 extends StatelessWidget {
  final String text;

  const ATextTitleMedium18({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
    );
  }
}

// Picks between the fixed-18px mobile title style and the themed
// titleMedium style based on the caller's isTablet/isDesktop flags, so call
// sites don't each have to repeat the same breakpoint ternary.
class AResponsiveTitleText extends StatelessWidget {
  final String text;
  final bool isTablet;
  final bool isDesktop;

  const AResponsiveTitleText({
    super.key,
    required this.text,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return (!isTablet && !isDesktop)
        ? ATextTitleMedium18(text: text)
        : ATextTitleMedium(text: text);
  }
}

class ATextTitleMediumColor extends StatelessWidget {
  final String text;
  final Color color; // เพิ่มพารามิเตอร์สำหรับระบุสี

  const ATextTitleMediumColor(
      {super.key, required this.text, required this.color}); // ปรับ constructor

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: color), // ใช้สีที่ระบุ
    );
  }
}

class ATextTitleMediumTH extends StatelessWidget {
  final String text;

  const ATextTitleMediumTH({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: const TextStyle(fontFamily: 'THSarabunNew', fontSize: 26),
      maxFontSize: 30,
      minFontSize: 16,
    );
  }
}

class ATextTitleMediumTHColors extends StatelessWidget {
  final String text;
  final Color color; // เพิ่มพารามิเตอร์สำหรับระบุสี

  const ATextTitleMediumTHColors(
      {super.key, required this.text, required this.color}); // ปรับ constructor

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 26, color: color),
      maxFontSize: 30,
      minFontSize: 16,
    );
  }
}

class ATextTitleSmall extends StatelessWidget {
  final String text;

  const ATextTitleSmall({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.titleSmall,
    );
  }
}

class ATextTitleSmallTHColor extends StatelessWidget {
  final String text;
  final Color color;

  const ATextTitleSmallTHColor(
      {super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: TextStyle(fontFamily: 'THSarabunNew', fontSize: 22, color: color),
      minFontSize: 8,
    );
  }
}

class ATextBodyLarge extends StatelessWidget {
  final String text;

  const ATextBodyLarge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class ATextBodyMedium extends StatelessWidget {
  final String text;

  const ATextBodyMedium({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class ATextBodySmall extends StatelessWidget {
  final String text;

  const ATextBodySmall({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class ATextDiskplayLarge extends StatelessWidget {
  final String text;

  const ATextDiskplayLarge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}

class ATextDiskplayLargeBlack extends StatelessWidget {
  final String text;

  const ATextDiskplayLargeBlack({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
          ),
    );
  }
}

class ATextDiskplayMedium extends StatelessWidget {
  final String text;

  const ATextDiskplayMedium({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.displayMedium,
    );
  }
}

class ATextDiskplaySmall extends StatelessWidget {
  final String text;

  const ATextDiskplaySmall({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(text, style: Theme.of(context).textTheme.displaySmall);
  }
}

class ATextDiskplaySmallBlack extends StatelessWidget {
  final String text;

  const ATextDiskplaySmallBlack({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
          ),
    );
  }
}

class ATextDiskplayLargeTH extends StatelessWidget {
  final String text;

  const ATextDiskplayLargeTH({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: const TextStyle(
        fontFamily: 'THSarabunNew',
        fontSize: 30,
      ),
      maxFontSize: 50,
      minFontSize: 16,
    );
  }
}

class ATextDiskplayMediumTH extends StatelessWidget {
  final String text;

  const ATextDiskplayMediumTH({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: const TextStyle(
          fontFamily: 'THSarabunNew', fontSize: 20, color: Colors.white),
      maxFontSize: 30,
      minFontSize: 14,
    );
  }
}
