import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as web_only;

/// google_sign_in_web does not support authenticate() — it requires
/// rendering Google's own Sign-In button (Google Identity Services), which
/// shows its own account-picker popup when tapped.
Widget buildWebGoogleSignInButton() => web_only.renderButton();
