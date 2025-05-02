import 'package:findsafe/controllers/notification_controller.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/settings_card.dart';
import 'package:findsafe/widgets/settings_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late NotificationController _notificationController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controller if it doesn't exist
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    
    _notificationController = Get.find<NotificationController>();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notification Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification types
            SettingsCard(
              title: 'Notification Types',
              children: [
                Obx(() => SettingsSwitch(
                  title: 'Geofence Alerts',
                  subtitle: 'Get notified when devices enter or exit geofences',
                  icon: Iconsax.radar,
                  value: _notificationController.geofenceNotificationsEnabled,
                  onChanged: (value) {
                    _notificationController.toggleGeofenceNotifications(value);
                  },
                )),
                Obx(() => SettingsSwitch(
                  title: 'Device Status',
                  subtitle: 'Get notified about device status changes',
                  icon: Iconsax.mobile,
                  value: _notificationController.deviceStatusNotificationsEnabled,
                  onChanged: (value) {
                    _notificationController.toggleDeviceStatusNotifications(value);
                  },
                )),
                Obx(() => SettingsSwitch(
                  title: 'Low Battery',
                  subtitle: 'Get notified when device battery is low',
                  icon: Iconsax.battery_empty1,
                  value: _notificationController.lowBatteryNotificationsEnabled,
                  onChanged: (value) {
                    _notificationController.toggleLowBatteryNotifications(value);
                  },
                )),
                Obx(() => SettingsSwitch(
                  title: 'Security Alerts',
                  subtitle: 'Get notified about security events',
                  icon: Iconsax.shield_security,
                  value: _notificationController.securityNotificationsEnabled,
                  onChanged: (value) {
                    _notificationController.toggleSecurityNotifications(value);
                  },
                )),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notification tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        color: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notification Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Make sure notifications are enabled in your device settings',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• For geofence alerts to work, location services must be enabled',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Battery optimization may affect notification delivery',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test notification button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _notificationController.showSecurityNotification(
                    title: 'Test Notification',
                    body: 'This is a test notification from FindSafe',
                  );
                },
                icon: const Icon(Iconsax.notification),
                label: const Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
