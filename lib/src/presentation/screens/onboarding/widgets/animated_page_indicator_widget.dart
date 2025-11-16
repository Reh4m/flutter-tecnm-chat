import 'package:flutter/material.dart';

class AnimatedPageIndicatorWidget extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedPageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AnimatedPageIndicatorWidget> createState() =>
      _AnimatedPageIndicatorWidgetState();
}

class _AnimatedPageIndicatorWidgetState
    extends State<AnimatedPageIndicatorWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.totalPages,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          );
        }).toList();

    if (widget.currentPage < _controllers.length) {
      _controllers[widget.currentPage].forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedPageIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentPage != oldWidget.currentPage) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == widget.currentPage) {
        _controllers[i].forward();
      } else {
        _controllers[i].reverse();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.totalPages,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final isActive = widget.currentPage == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 8,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? (widget.activeColor ?? theme.colorScheme.primary)
                          : (widget.inactiveColor ??
                              theme.colorScheme.primary.withAlpha(50)),
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
