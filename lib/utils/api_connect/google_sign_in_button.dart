import 'package:flutter/widgets.dart';

import 'google_sign_in_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_button_web.dart' as impl;

/// Renders Google's real "Sign in with Google" button on web, and an empty
/// box on every other platform (where the normal custom button + authenticate()
/// flow is used instead).
class GoogleSignInWebButton extends StatelessWidget {
  const GoogleSignInWebButton({super.key});

  @override
  Widget build(BuildContext context) => impl.buildWebGoogleSignInButton();
}
