import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tripitaka91/utils/connectivity/check_internet_connection.dart';

/// Re-probes connectivity when the user taps the OFFLINE indicator. If the
/// connection is back, restarts the app (Phoenix.rebirth) so `online` gets
/// re-threaded correctly everywhere it was already captured at construction
/// time — a plain setState() here wouldn't reach those widgets. If still
/// offline, just tells the user so.
Future<void> refreshConnectivityAndRebirthIfOnline(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('กำลังตรวจสอบการเชื่อมต่ออินเทอร์เน็ต...')),
  );

  final isOnline = await checkInternetConnection();

  if (!context.mounted) return;

  if (isOnline) {
    Phoenix.rebirth(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ยังไม่มีการเชื่อมต่ออินเทอร์เน็ต (OFFLINE)'),
      ),
    );
  }
}
