import 'dart:io';

import 'package:flutter/foundation.dart';

/// iOS/macOS use "ONLINE"; Android, Windows, and web all keep the legacy
/// "BETA" wording. kIsWeb must short-circuit first — dart:io's Platform
/// throws on web instead of returning false.
final String kOnlineModeLabel = !kIsWeb && (Platform.isIOS || Platform.isMacOS)
    ? 'ONLINE'
    : 'BETA';
