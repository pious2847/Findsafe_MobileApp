// ignore_for_file: library_private_types_in_public_api
import 'package:findsafe/constants/custom_bottom_nav.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:findsafe/screens/onboarding.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _authenticateAndNavigate();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _authenticateAndNavigate() async {
    try {
      await authenticatePage();

      // Navigation delay
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final bool showHome = prefs.getBool('showHome') ?? false;

      if (!mounted) return;

      Get.off(
        () => showHome ? const CustomBottomNav() : const Onbording(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } catch (e) {
      debugPrint("Navigation error: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppTheme.darkBackgroundColor : Colors.white;
    final textColor =
        isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
    final subtitleColor = isDarkMode
        ? AppTheme.darkTextSecondaryColor
        : AppTheme.textSecondaryColor;
    final accentColor =
        isDarkMode ? AppTheme.darkAccentColor : AppTheme.accentColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animation
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Lottie.asset(
                          'assets/svg/circleloading.json',
                          width: 180,
                          height: 180,
                          animate: true,
                          repeat: true,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // App name with gradient
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.accentColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'FindSafe',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // The color is replaced by the gradient
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tagline
                      Text(
                        'Secure and Locate',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Track and protect your devices anywhere',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: subtitleColor,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(accentColor),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
