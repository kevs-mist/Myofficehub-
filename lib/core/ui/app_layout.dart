import 'package:flutter/widgets.dart';

/// Shared layout tokens to keep spacing consistent across screens.
class AppLayout {
  AppLayout._();

  static const double gutter = 16;
  static const double screenPadding = 24;
  static const double screenPaddingWide = 32;

  static const EdgeInsets screenInsets = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );

  static const EdgeInsets screenInsetsWide = EdgeInsets.symmetric(
    horizontal: screenPaddingWide,
  );

  static const SizedBox v8 = SizedBox(height: 8);
  static const SizedBox v12 = SizedBox(height: 12);
  static const SizedBox v16 = SizedBox(height: 16);
  static const SizedBox v24 = SizedBox(height: 24);
  static const SizedBox v32 = SizedBox(height: 32);
  static const SizedBox v40 = SizedBox(height: 40);
  static const SizedBox v48 = SizedBox(height: 48);
  static const SizedBox v60 = SizedBox(height: 60);
}

