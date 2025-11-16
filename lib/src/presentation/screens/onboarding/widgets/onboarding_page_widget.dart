import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/onboarding_data.dart';
import 'package:flutter_whatsapp_clon/src/data/models/onboarding_model.dart';

class OnboardingPageWidget extends StatefulWidget {
  final OnboardingModel pageData;
  final bool isActive;

  const OnboardingPageWidget({
    super.key,
    required this.pageData,
    required this.isActive,
  });

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Configure animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scaleController.forward();
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(OnboardingPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _resetAndStartAnimations();
    }
  }

  void _resetAndStartAnimations() {
    _scaleController.reset();
    _fadeController.reset();
    _slideController.reset();
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      OnboardingData.getIconData(widget.pageData.iconData),
                      size: 80,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                widget.pageData.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
                    ),
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: size.width * 0.8),
                    child: Text(
                      widget.pageData.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
          // const SizedBox(height: 82),
        ],
      ),
    );
  }
}
