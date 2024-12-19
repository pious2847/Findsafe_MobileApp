// ignore_for_file: library_private_types_in_public_api
import 'package:findsafe/constants/custom_bottom_nav.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:findsafe/screens/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    authenticatePage();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Run animation only once instead of repeating
    _animationController.forward();
    // Navigation delay
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return; // Add mounted check

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool showHome = prefs.getBool('showHome') ?? false;

      if (!mounted) return; // Add mounted check before navigation

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              showHome ? const CustomBottomNav() : const Onbording(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Remove gradient background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // In splashscreen.dart, within the build method
              Lottie.asset(
                'assets/svg/loading.json',
                width: 200,
                height: 200,
                animate: true,
                controller: _animationController,
                repeat: false, // Don't repeat the animation
                onLoaded: (composition) {
                  _animationController.duration = composition.duration;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Secure and Locate',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 27,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                'track your missing or stolen phone',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

Future<void> authenticatePage() async {
  try {
    if (!mounted) return;
    
    final userData = await getUserDataFromLocalStorage();
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    if (userData['userId'] != null && userData['isLoggedIn'] == true) {
      await prefs.setBool('showHome', true);
    } else {
      await prefs.setBool('showHome', false);
    }
  } catch (e) {
    debugPrint("Authentication error: $e");
  }
}
}
