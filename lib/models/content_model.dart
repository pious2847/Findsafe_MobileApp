class OnboardingContent {
  String image;
  String title;
  String description;

  OnboardingContent(
      {required this.image, required this.title, required this.description});
}

List<OnboardingContent> contents = [
  OnboardingContent(
      title: 'Security and Privacy',
      image: 'assets/svg/mobile_secure.svg',
      description:
          "Protect your data and ensure your privacy with our secure solutions. Stay safe and secure with our innovative features."),
  OnboardingContent(
      title: 'Device Tracking',
      image: 'assets/svg/navigation.svg',
      description:
          "Effortlessly locate your device and stay connected wherever you go. Track your device's location with ease."),
  OnboardingContent(
      title: 'User Profiles',
      image: 'assets/svg/profile.svg',
      description:
          "Create and customize your profile to personalize your experience and connect with others safely."),
];
