import 'package:flutter/material.dart';

class OnboardingProgressWidget extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final Duration animationDuration;

  const OnboardingProgressWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OnboardingProgressWidget> createState() =>
      _OnboardingProgressWidgetState();
}

class _OnboardingProgressWidgetState extends State<OnboardingProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.currentStep / widget.totalSteps,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(OnboardingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.currentStep / widget.totalSteps,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
