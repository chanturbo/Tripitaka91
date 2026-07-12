import 'dart:io';

/// Android keeps the legacy "BETA" wording for the online read-aloud mode;
/// iOS/macOS/Windows use "ONLINE".
final String kOnlineModeLabel = Platform.isAndroid ? 'BETA' : 'ONLINE';
