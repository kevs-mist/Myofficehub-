import 'package:flutter/material.dart';

import 'background_shapes.dart';

/// Standard app background (animated shapes) used across screens.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundShapes(),
        child,
      ],
    );
  }
}

