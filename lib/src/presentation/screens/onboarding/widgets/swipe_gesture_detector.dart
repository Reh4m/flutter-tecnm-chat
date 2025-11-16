import 'package:flutter/material.dart';

class SwipeGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onTap;

  const SwipeGestureDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (details) {
        if (details.delta.dx > 10) {
          onSwipeRight?.call();
        } else if (details.delta.dx < -10) {
          onSwipeLeft?.call();
        }
      },
      child: child,
    );
  }
}
