import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/app_constants.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/onboarding_data.dart';
import 'package:flutter_whatsapp_clon/src/presentation/config/themes/light_theme.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/onboarding_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/onboarding/widgets/animated_page_indicator_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/onboarding/widgets/floating_elements_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/onboarding/widgets/onboarding_page_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/onboarding/widgets/onboarding_progress_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/onboarding/widgets/swipe_gesture_detector.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _fadeController;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: LightTheme.cardBackgroundColor,
      end: LightTheme.cardBackgroundColor.withAlpha(50),
    ).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _backgroundController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleNext(OnboardingProvider provider) {
    HapticFeedback.lightImpact();
    if (provider.isLastPage) {
      _completeOnboarding(provider);
    } else {
      provider.nextPage();
    }
  }

  void _handlePrevious(OnboardingProvider provider) {
    HapticFeedback.lightImpact();
    provider.previousPage();
  }

  void _completeOnboarding(OnboardingProvider provider) {
    HapticFeedback.mediumImpact();

    _fadeController.reverse().then((_) {
      provider.completeOnboarding().then((_) {
        if (mounted) {
          context.go('/phone-sign-in');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<OnboardingProvider>(
        builder: (context, onboardingProvider, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    FloatingElementsWidget(
                      color: theme.colorScheme.primary,
                      elementCount: 15,
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildProgressBar(onboardingProvider),
                          const SizedBox(height: 20),
                          _buildHeader(theme, onboardingProvider),
                          Expanded(
                            child: SwipeGestureDetector(
                              onSwipeLeft: () {
                                if (!onboardingProvider.isLastPage) {
                                  onboardingProvider.nextPage();
                                }
                              },
                              onSwipeRight: () {
                                if (onboardingProvider.currentPage > 0) {
                                  onboardingProvider.previousPage();
                                }
                              },
                              child: _buildPageView(onboardingProvider),
                            ),
                          ),
                          _buildPageIndicator(onboardingProvider),
                          const SizedBox(height: 30),
                          _buildNavigationButtons(onboardingProvider),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(OnboardingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OnboardingProgressWidget(
        currentStep: provider.currentPage + 1,
        totalSteps: OnboardingData.pages.length,
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, OnboardingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppConstants.appName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(OnboardingProvider provider) {
    return PageView.builder(
      controller: provider.pageController,
      onPageChanged: (index) {
        HapticFeedback.selectionClick();
        provider.setCurrentPage(index);
      },
      itemCount: OnboardingData.pages.length,
      itemBuilder: (context, index) {
        return OnboardingPageWidget(
          pageData: OnboardingData.pages[index],
          isActive: provider.currentPage == index,
        );
      },
    );
  }

  Widget _buildPageIndicator(OnboardingProvider provider) {
    return AnimatedPageIndicatorWidget(
      currentPage: provider.currentPage,
      totalPages: OnboardingData.pages.length,
    );
  }

  Widget _buildNavigationButtons(OnboardingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: provider.currentPage > 0 ? 1.0 : 0.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: provider.currentPage > 0 ? null : 0,
              child:
                  provider.currentPage > 0
                      ? CustomButton(
                        text: 'Anterior',
                        onPressed: () => _handlePrevious(provider),
                        variant: ButtonVariant.outline,
                        height: 56,
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                      )
                      : const SizedBox.shrink(),
            ),
          ),

          if (provider.currentPage > 0) const SizedBox(width: 15),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: CustomButton(
              key: ValueKey(provider.isLastPage),
              text: provider.isLastPage ? 'Comenzar' : 'Siguiente',
              onPressed: () => _handleNext(provider),
              height: 56,
              icon: Icon(
                provider.isLastPage
                    ? Icons.rocket_launch
                    : Icons.arrow_forward_ios,
                size: 18,
              ),
              iconPosition: ButtonIconPosition.right,
            ),
          ),
        ],
      ),
    );
  }
}
