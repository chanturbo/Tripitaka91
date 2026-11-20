import 'package:flutter/widgets.dart';

/// Non-web platforms never render Google's web button widget.
Widget buildWebGoogleSignInButton() => const SizedBox.shrink();
