import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/constants/colors.dart';

// Adaptive stand-ins for the many places in this codebase that hardcode
// Colors.white/Colors.black as a "page surface" or "border on that surface"
// instead of reading from ThemeData, which made dark mode only partially
// take effect. Use these at call sites that need a surface/border color to
// flip with the theme; leave genuinely fixed colors (e.g. white text on a
// permanently-colored badge) alone.
Color adaptiveSurfaceColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? TColors.black
        : Colors.white;

Color adaptiveBorderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? TColors.white
        : Colors.black;

// Same light/dark flip as adaptiveBorderColor, named for its other common
// use: readable primary text that isn't sitting on a fixed-color badge.
Color adaptiveTextColor(BuildContext context) => adaptiveBorderColor(context);

// A page background one step away from adaptiveSurfaceColor, so a card using
// adaptiveSurfaceColor actually stands out instead of blending into a
// same-colour Scaffold (both resolved to white in light mode / the same dark
// grey in dark mode before this existed, which read as a flat, low-contrast
// "all white" screen). Use this as the Scaffold/body background behind
// card-based layouts; leave plain, non-card screens on the theme's own
// scaffoldBackgroundColor.
Color adaptivePageColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121212)
        : const Color(0xFFF2F3F5);
