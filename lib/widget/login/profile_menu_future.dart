import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/sizes.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';

class TProfileMenuFuture extends StatelessWidget {
  const TProfileMenuFuture({
    super.key,
    required this.onPressed,
    required this.title,
    required this.valueFuture,
    this.icon = Icons.arrow_right,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String title;
  final Future<String> valueFuture; // แก้เป็น Future<String>

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: valueFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}');
        } else {
          final value = snapshot.data ?? '0';
          saveValueCorrect(int.parse(value));
          return GestureDetector(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: TSizes.spaceBtwItems / 1.5),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text(title,
                          style: Theme.of(context).textTheme.bodySmall)),
                  Expanded(
                    flex: 5,
                    child: Text('$value รายการ',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const Expanded(child: Text('')),
                  // Expanded(child: Icon(icon, size: 18)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
