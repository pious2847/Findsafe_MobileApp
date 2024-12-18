class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent({required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Security and privacy',
    image: 'assets/svg/mobile_secure.svg',
    discription: "Protect your data and ensure your privacy with our secure solutions. Stay safe and secure with our innovative features."
  ),
  UnbordingContent(
    title: 'Device Tracking',
    image: 'assets/svg/navigation.svg',
    discription: "Effortlessly locate your device and stay connected wherever you go. Track your device's location with ease."
  ),
  
];