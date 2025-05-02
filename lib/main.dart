import 'package:findsafe/controllers/theme_controller.dart';
import 'package:findsafe/screens/splashscreen.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/background_worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initializeBackgroundService();

  // Initialize theme controller
  Get.put(ThemeController());

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FindSafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: const SplashScreen(),
      defaultTransition: Transition.fade,
    );
  }
}
