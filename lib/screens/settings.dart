import 'package:findsafe/controllers/language_controller.dart';
import 'package:findsafe/controllers/notification_controller.dart';
import 'package:findsafe/controllers/privacy_controller.dart';
import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/controllers/theme_controller.dart';
import 'package:findsafe/screens/notification_settings.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/language_selector.dart';
import 'package:findsafe/widgets/premium_card.dart';
import 'package:findsafe/widgets/settings_card.dart';
import 'package:findsafe/widgets/settings_item.dart';
import 'package:findsafe/widgets/settings_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final void Function(int) onPageChanged;

  const SettingsPage({super.key, required this.onPageChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeController _themeController;
  late LanguageController _languageController;
  late NotificationController _notificationController;
  late PrivacyController _privacyController;
  late SecurityController _securityController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers if they don't exist
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }
    if (!Get.isRegistered<LanguageController>()) {
      Get.put(LanguageController());
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    if (!Get.isRegistered<PrivacyController>()) {
      Get.put(PrivacyController());
    }
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }

    _themeController = Get.find<ThemeController>();
    _languageController = Get.find<LanguageController>();
    _notificationController = Get.find<NotificationController>();
    _privacyController = Get.find<PrivacyController>();
    _securityController = Get.find<SecurityController>();

    // Make sure controllers are properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This ensures the UI updates after controllers are fully initialized
    });
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => LanguageSelector(
        languages: _languageController.supportedLanguages,
        selectedLanguageCode: _languageController.selectedLanguageCode,
        onLanguageSelected: (code) {
          _languageController.changeLanguage(code);
        },
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium card
            PremiumCard(
              title: 'Upgrade to Premium',
              description:
                  'Get unlimited access to all features and remove ads',
              buttonText: 'Upgrade Now',
              onButtonPressed: () {
                // Handle premium upgrade
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium upgrade coming soon!')),
                );
              },
              features: const [
                'Unlimited device tracking',
                'Advanced security features',
                'Priority customer support',
                'No advertisements',
                'Extended location history',
              ],
            ),

            // Appearance settings
            SettingsCard(
              title: 'Appearance',
              children: [
                // Theme setting
                Obx(() => SettingsSwitch(
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme throughout the app',
                      icon: Iconsax.moon,
                      value: _themeController.isDarkMode,
                      onChanged: (value) {
                        _themeController.toggleTheme();
                      },
                    )),

                // Language setting
                Obx(() => SettingsItem(
                      title: 'Language',
                      subtitle:
                          '${_languageController.selectedLanguage.flagEmoji} ${_languageController.selectedLanguage.name}',
                      icon: Iconsax.language_square,
                      onTap: _showLanguageSelector,
                    )),
              ],
            ),

            // Notification settings
            SettingsCard(
              title: 'Notifications',
              children: [
                SettingsItem(
                  title: 'Notification Settings',
                  subtitle: 'Manage all notification preferences',
                  icon: Iconsax.notification_bing,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                Obx(() => SettingsSwitch(
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts on your device',
                      icon: Iconsax.notification,
                      value: _notificationController.pushNotificationsEnabled,
                      onChanged: (value) {
                        _notificationController.togglePushNotifications(value);
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'Email Notifications',
                      subtitle: 'Receive alerts via email',
                      icon: Iconsax.message,
                      value: _notificationController.emailNotificationsEnabled,
                      onChanged: (value) {
                        _notificationController.toggleEmailNotifications(value);
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'Location Alerts',
                      subtitle:
                          'Get notified when a device enters or leaves a zone',
                      icon: Iconsax.location,
                      value: _notificationController.locationAlertsEnabled,
                      onChanged: (value) {
                        _notificationController.toggleLocationAlerts(value);
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'Device Offline Alerts',
                      subtitle: 'Get notified when a device goes offline',
                      icon: Iconsax.wifi,
                      value: _notificationController.deviceOfflineAlertsEnabled,
                      onChanged: (value) {
                        _notificationController
                            .toggleDeviceOfflineAlerts(value);
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'Battery Alerts',
                      subtitle: 'Get notified when a device battery is low',
                      icon: Iconsax.battery_charging,
                      value: _notificationController.batteryAlertsEnabled,
                      onChanged: (value) {
                        _notificationController.toggleBatteryAlerts(value);
                      },
                    )),
              ],
            ),

            // Security settings
            SettingsCard(
              title: 'Security',
              children: [
                SettingsItem(
                  title: 'Security Settings',
                  subtitle: 'Manage app security and authentication',
                  icon: Iconsax.shield_security,
                  onTap: () {
                    widget.onPageChanged(5);
                  },
                ),
                Obx(() => SettingsSwitch(
                      title: 'Biometric Authentication',
                      subtitle: 'Use fingerprint or face ID to unlock the app',
                      icon: Iconsax.finger_scan,
                      value: _securityController.biometricAuthEnabled,
                      onChanged: (value) {
                        _securityController.toggleBiometricAuth(value);
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'PIN Code',
                      subtitle: 'Require PIN code to access the app',
                      icon: Iconsax.password_check,
                      value: _securityController.pinCodeEnabled,
                      onChanged: (value) {
                        _securityController.togglePinCode(value);
                      },
                    )),
              ],
            ),

            // Privacy settings
            SettingsCard(
              title: 'Privacy',
              children: [
                Obx(() => SettingsSwitch(
                      title: 'Location Sharing',
                      subtitle: 'Allow the app to share your location',
                      icon: Iconsax.location_tick,
                      value: _privacyController.locationSharingEnabled,
                      onChanged: (value) {
                        _privacyController.toggleLocationSharing(value);
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'Data Collection',
                      subtitle: 'Allow the app to collect usage data',
                      icon: Iconsax.data,
                      value: _privacyController.dataCollectionEnabled,
                      onChanged: (value) {
                        _privacyController.toggleDataCollection(value);
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'Analytics',
                      subtitle:
                          'Allow the app to send anonymous usage statistics',
                      icon: Iconsax.chart,
                      value: _privacyController.analyticsEnabled,
                      onChanged: (value) {
                        _privacyController.toggleAnalytics(value);
                      },
                    )),
              ],
            ),

            // About settings
            SettingsCard(
              title: 'About',
              children: [
                SettingsItem(
                  title: 'Privacy Policy',
                  icon: Iconsax.shield_tick,
                  onTap: () {
                    _launchURL('https://findsafe.com/privacy-policy');
                  },
                ),
                SettingsItem(
                  title: 'Terms of Service',
                  icon: Iconsax.document_text,
                  onTap: () {
                    _launchURL('https://findsafe.com/terms-of-service');
                  },
                ),
                SettingsItem(
                  title: 'Rate Us',
                  icon: Iconsax.star,
                  onTap: () {
                    // Open app store rating
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Rate us feature coming soon!')),
                    );
                  },
                ),
                SettingsItem(
                  title: 'About FindSafe',
                  icon: Iconsax.info_circle,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'FindSafe',
                      applicationVersion: '1.0.0',
                      applicationIcon: Image.asset(
                        'assets/images/logo.png',
                        width: 50,
                        height: 50,
                      ),
                      applicationLegalese:
                          '© 2023 FindSafe. All rights reserved.',
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'FindSafe is a device tracking application that helps you keep track of your devices and loved ones.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            // Account settings
            SettingsCard(
              title: 'Account',
              children: [
                SettingsItem(
                  title: 'Delete Account',
                  icon: Iconsax.trash,
                  isDestructive: true,
                  onTap: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                          'Are you sure you want to delete your account? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Account deletion is not implemented yet')),
                              );
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            // Version info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0 (Build 100)',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
