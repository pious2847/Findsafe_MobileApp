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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    authenticatePage();

    Future.delayed(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool showHome = prefs.getBool('showHome') ?? false;
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
              Lottie.asset(
                'assets/svg/loading.json',
                width: 200,
                height: 200,
                animate: true,
                controller: _animationController,
                reverse: _animation.value > 0.5,
                repeat: true,
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
      final userData = await getUserDataFromLocalStorage();
      final userId = userData['userId'];
      final isLoggedIn = userData['isLoggedIn'];
      if (userId != null && isLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('showHome', true);
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('showHome', false);
      }
    } catch (e) {
      print("Error occurred: $e");
      // Handle error, show toast or snackbar
    }
  }
}
