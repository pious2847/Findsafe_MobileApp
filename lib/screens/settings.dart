import 'package:findsafe/controllers/language_controller.dart';
import 'package:findsafe/controllers/notification_controller.dart';
import 'package:findsafe/controllers/privacy_controller.dart';
import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/controllers/theme_controller.dart';
import 'package:findsafe/screens/about.dart';
import 'package:findsafe/screens/notification_settings.dart';
import 'package:findsafe/screens/security_wrapper.dart';
import 'package:findsafe/service/background_location_service.dart';
import 'package:findsafe/services/location_permission_service.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/toast_messages.dart';
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecurityWrapperScreen(),
                      ),
                    );
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
                Obx(() => SettingsSwitch(
                      title: 'Two-Factor Authentication',
                      subtitle:
                          'Add an extra layer of security to your account',
                      icon: Iconsax.security_safe,
                      value: _securityController.twoFactorAuthEnabled,
                      onChanged: (value) {
                        if (value) {
                          // Check if either PIN or biometric is enabled
                          _securityController
                              .toggleTwoFactorAuth(value, context)
                              .then((success) {
                            if (success) {
                              CustomToast.show(
                                context: context,
                                message: 'Two-factor authentication enabled',
                                type: ToastType.success,
                                position: ToastPosition.top,
                              );
                            }
                          });
                        } else {
                          _securityController.toggleTwoFactorAuth(
                              value, context);
                        }
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

            // Location Permissions
            SettingsCard(
              title: 'Location Permissions',
              children: [
                FutureBuilder<String>(
                  future: BackgroundLocationService.getPermissionStatus(),
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? 'Loading...';
                    final isAlways = status.contains('Always');

                    return SettingsItem(
                      title: 'Location Access',
                      subtitle: status,
                      icon: Iconsax.location,
                      trailing: Icon(
                        isAlways ? Iconsax.tick_circle : Iconsax.warning_2,
                        color: isAlways ? Colors.green : Colors.orange,
                      ),
                      onTap: () async {
                        // Request proper location permissions
                        try {
                          final result = await LocationPermissionService.requestLocationPermissions(context);
                          if (context.mounted) {
                            LocationPermissionService.showPermissionToast(context, result);
                            setState(() {}); // Refresh the UI
                          }
                        } catch (e) {
                          if (context.mounted) {
                            CustomToast.show(
                              context: context,
                              message: 'Error requesting permissions: $e',
                              type: ToastType.error,
                              position: ToastPosition.top,
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),

            // Background Service Status
            SettingsCard(
              title: 'Background Location Service',
              children: [
                SettingsItem(
                  title: 'Service Status',
                  subtitle: BackgroundLocationService.isInitialized
                      ? 'Running'
                      : 'Stopped',
                  icon: Iconsax.location,
                  trailing: Icon(
                    BackgroundLocationService.isInitialized
                        ? Iconsax.tick_circle
                        : Iconsax.close_circle,
                    color: BackgroundLocationService.isInitialized
                        ? Colors.green
                        : Colors.red,
                  ),
                  onTap: () async {
                    // Toggle service
                    try {
                      if (BackgroundLocationService.isInitialized) {
                        await BackgroundLocationService.stop();
                        if (context.mounted) {
                          CustomToast.show(
                            context: context,
                            message: 'Background service stopped',
                            type: ToastType.info,
                            position: ToastPosition.top,
                          );
                        }
                      } else {
                        await BackgroundLocationService.start();
                        if (context.mounted) {
                          CustomToast.show(
                            context: context,
                            message: 'Background service started',
                            type: ToastType.success,
                            position: ToastPosition.top,
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomToast.show(
                          context: context,
                          message: 'Error: $e',
                          type: ToastType.error,
                          position: ToastPosition.top,
                        );
                      }
                    }
                  },
                ),
                SettingsItem(
                  title: 'Update Location Now',
                  subtitle: 'Manually trigger location update',
                  icon: Iconsax.refresh,
                  onTap: () async {
                    try {
                      await BackgroundLocationService.updateLocationNow();
                      if (context.mounted) {
                        CustomToast.show(
                          context: context,
                          message: 'Location update triggered',
                          type: ToastType.success,
                          position: ToastPosition.top,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomToast.show(
                          context: context,
                          message: 'Failed to update location: $e',
                          type: ToastType.error,
                          position: ToastPosition.top,
                        );
                      }
                    }
                  },
                ),
                SettingsItem(
                  title: 'Restart Service',
                  subtitle: 'Restart background location tracking',
                  icon: Iconsax.refresh_circle,
                  onTap: () async {
                    try {
                      await BackgroundLocationService.restart();
                      if (context.mounted) {
                        CustomToast.show(
                          context: context,
                          message: 'Background service restarted',
                          type: ToastType.success,
                          position: ToastPosition.top,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomToast.show(
                          context: context,
                          message: 'Failed to restart service: $e',
                          type: ToastType.error,
                          position: ToastPosition.top,
                        );
                      }
                    }
                  },
                ),
              ],
            ),

            // About settings
            SettingsCard(
              title: 'About',
              children: [
                SettingsItem(
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  icon: Iconsax.shield_tick,
                  onTap: () {
                    _launchURL('https://findsafe.com/privacy-policy');
                  },
                ),
                SettingsItem(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  icon: Iconsax.document_text,
                  onTap: () {
                    _launchURL('https://findsafe.com/terms-of-service');
                  },
                ),
                SettingsItem(
                  title: 'Rate Us',
                  subtitle: 'Share your feedback on the app store',
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
                  subtitle: 'Learn more about the app and its features',
                  icon: Iconsax.info_circle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
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

            const SizedBox(height: 85),
          ],
        ),
      ),
    );
  }
}
