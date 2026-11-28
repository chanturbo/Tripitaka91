import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Flutter ไม่เปิดให้ ListView แนวนอนเลื่อนด้วยการหมุนล้อเมาส์ (แนวตั้ง) หรือ
/// ลากด้วยเมาส์ค้างบนเดสก์ท็อป/เว็บโดยอัตโนมัติ (ต้องกด Shift ถึงจะหมุนล้อเลื่อน
/// ได้ และลากได้เฉพาะด้วยนิ้ว/stylus) widget นี้ครอบ ListView แนวนอนเพื่อเปิดทั้ง
/// สองอย่างนั้นเพิ่มจากปุ่มเลื่อน/การลากด้วยนิ้วที่มีอยู่เดิม
class HorizontalMouseScroll extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  const HorizontalMouseScroll({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && controller.hasClients) {
          final double delta = event.scrollDelta.dy != 0
              ? event.scrollDelta.dy
              : event.scrollDelta.dx;
          final double newOffset = (controller.offset + delta).clamp(
            controller.position.minScrollExtent,
            controller.position.maxScrollExtent,
          );
          controller.jumpTo(newOffset);
        }
      },
      child: ScrollConfiguration(
        behavior: _MouseDragScrollBehavior(),
        child: child,
      ),
    );
  }
}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
