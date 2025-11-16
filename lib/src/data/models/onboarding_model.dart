class OnboardingModel {
  final String title;
  final String description;
  final String iconData;
  final String? animationAsset;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.iconData,
    this.animationAsset,
  });
}
