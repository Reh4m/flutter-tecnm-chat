import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _hasSeenOnboarding = false;

  OnboardingProvider(this.prefs) {
    _loadOnboardingStatus();
  }

  PageController get pageController => _pageController;
  int get currentPage => _currentPage;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  // Check if it's the last page
  bool get isLastPage => _currentPage == 3;

  Future<void> _loadOnboardingStatus() async {
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    notifyListeners();
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> nextPage() async {
    if (_currentPage < 3) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> goToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> completeOnboarding() async {
    await prefs.setBool('has_seen_onboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await prefs.setBool('has_seen_onboarding', false);
    _hasSeenOnboarding = false;
    _currentPage = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
