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
