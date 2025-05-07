import 'package:findsafe/controllers/theme_controller.dart';
import 'package:findsafe/screens/splashscreen.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/background_worker_simple.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  AppLogger.init();
  final logger = AppLogger.getLogger('main');
  logger.info('Starting FindSafe app');

  try {
    // Initialize services
    logger.info('Initializing background service');
    await initializeBackgroundService();

    // Initialize theme controller
    logger.info('Initializing theme controller');
    Get.put(ThemeController());

    // Set preferred orientations
    logger.info('Setting preferred orientations');
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(MyApp());
  } catch (e, stackTrace) {
    logger.severe('Error during app initialization', e, stackTrace);
    rethrow;
  }
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
