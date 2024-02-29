import 'package:flutter/material.dart';
import 'package:tripitaka91/widget/auto_text/auto_text.dart';
import 'package:tripitaka91/widget/right_clipper/left_clipper.dart';
import 'package:tripitaka91/widget/right_clipper/right_clipper.dart';

class ScrollControlButton extends StatelessWidget {
  final ScrollController scrollController;
  final double offset;
  final String buttonText;
  final bool isLeftButton;
  final Color color;
  const ScrollControlButton(
      {super.key,
      required this.scrollController,
      required this.offset,
      required this.buttonText,
      required this.isLeftButton,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: ClipPath(
        clipper: isLeftButton
            ? LeftTriangleRectangleClipper()
            : RightTriangleRectangleClipper(),
        child: InkWell(
          onTap: () {
            final newOffset = isLeftButton
                ? scrollController.offset - offset
                : scrollController.offset + offset;

            scrollController.animateTo(
              newOffset,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            );
          },
          child: Container(
            width: 60.0,
            height: 25.0,
            color: color,
            child: Center(
              child: ATextDiskplaySmall(
                text: buttonText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
