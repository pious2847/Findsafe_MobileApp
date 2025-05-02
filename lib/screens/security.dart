import 'package:findsafe/controllers/biometric_controller.dart';
import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/screens/pin_auth.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:findsafe/widgets/settings_card.dart';
import 'package:findsafe/widgets/settings_item.dart';
import 'package:findsafe/widgets/settings_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  late SecurityController _securityController;
  late BiometricController _biometricController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers if they don't exist
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }
    _securityController = Get.find<SecurityController>();

    if (!Get.isRegistered<BiometricController>()) {
      Get.put(BiometricController());
    }
    _biometricController = Get.find<BiometricController>();
  }

  void _showPinSetupDialog() {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor =
            isDarkMode ? AppTheme.darkCardColor : Colors.white;
        final textColor = isDarkMode
            ? AppTheme.darkTextPrimaryColor
            : AppTheme.textPrimaryColor;

        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Set PIN Code',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: 'Enter PIN (4 digits)',
                    prefixIcon: Icon(Iconsax.password_check),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a PIN';
                    }
                    if (value.length != 4) {
                      return 'PIN must be 4 digits';
                    }
                    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                      return 'PIN must contain only digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPinController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm PIN',
                    prefixIcon: Icon(Iconsax.password_check),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your PIN';
                    }
                    if (value != pinController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Save PIN code
                  Navigator.of(context).pop();
                  _securityController.togglePinCode(true);

                  // Show success message
                  CustomToast.show(
                    context: context,
                    message: 'PIN code set successfully',
                    type: ToastType.success,
                    position: ToastPosition.top,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? AppTheme.darkPrimaryColor
                    : AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoteLockDialog() {
    final TextEditingController deviceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor =
            isDarkMode ? AppTheme.darkCardColor : Colors.white;
        final textColor = isDarkMode
            ? AppTheme.darkTextPrimaryColor
            : AppTheme.textPrimaryColor;

        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Lock Device Remotely',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the device ID you want to lock remotely',
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID',
                  prefixIcon: Icon(Iconsax.mobile),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Show success message
                CustomToast.show(
                  context: context,
                  message: 'Remote lock functionality coming soon!',
                  type: ToastType.info,
                  position: ToastPosition.top,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? AppTheme.darkPrimaryColor
                    : AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lock Device'),
            ),
          ],
        );
      },
    );
  }

  void _showDataWipeDialog() {
    final TextEditingController deviceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor =
            isDarkMode ? AppTheme.darkCardColor : Colors.white;
        final textColor = isDarkMode
            ? AppTheme.darkTextPrimaryColor
            : AppTheme.textPrimaryColor;

        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Remote Data Wipe',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This will erase all data on the device. This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the device ID to confirm',
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID',
                  prefixIcon: Icon(Iconsax.mobile),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Show success message
                CustomToast.show(
                  context: context,
                  message: 'Remote data wipe functionality coming soon!',
                  type: ToastType.info,
                  position: ToastPosition.top,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Wipe Data'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Security',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Authentication settings
            SettingsCard(
              title: 'Authentication',
              children: [
                Obx(() => SettingsSwitch(
                      title: 'Biometric Authentication',
                      subtitle: _biometricController.isBiometricAvailable
                          ? 'Use ${_biometricController.biometricString} to unlock the app'
                          : 'Biometric authentication not available on this device',
                      icon: Iconsax.finger_scan,
                      value: _securityController.biometricAuthEnabled,
                      onChanged: (value) {
                        if (!_biometricController.isBiometricAvailable) {
                          CustomToast.show(
                            context: context,
                            message:
                                'Biometric authentication not available on this device',
                            type: ToastType.error,
                            position: ToastPosition.top,
                          );
                          return;
                        }

                        _biometricController
                            .toggleBiometric(value, context)
                            .then((success) {
                          if (success) {
                            _securityController.toggleBiometricAuth(value);
                          }
                        });
                      },
                    )),
                Obx(() => SettingsSwitch(
                      title: 'PIN Code',
                      subtitle: 'Require PIN code to access the app',
                      icon: Iconsax.password_check,
                      value: _securityController.pinCodeEnabled,
                      onChanged: (value) {
                        if (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PinAuthScreen(
                                mode: PinAuthMode.setup,
                                reason: 'Set a PIN code to protect your app',
                                onSuccess: () {
                                  _securityController.togglePinCode(true);
                                },
                              ),
                            ),
                          );
                        } else {
                          _securityController.togglePinCode(value);
                        }
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
                          // In a real app, we would guide the user through 2FA setup
                          _securityController.toggleTwoFactorAuth(value);

                          CustomToast.show(
                            context: context,
                            message: 'Two-factor authentication enabled',
                            type: ToastType.success,
                            position: ToastPosition.top,
                          );
                        } else {
                          _securityController.toggleTwoFactorAuth(value);
                        }
                      },
                    )),
              ],
            ),

            // Remote device control
            SettingsCard(
              title: 'Remote Device Control',
              children: [
                SettingsItem(
                  title: 'Lock Device Remotely',
                  subtitle: 'Lock a device from anywhere',
                  icon: Iconsax.lock_1,
                  onTap: _showRemoteLockDialog,
                ),
                SettingsItem(
                  title: 'Remote Data Wipe',
                  subtitle: 'Erase all data from a device remotely',
                  icon: Iconsax.trash,
                  isDestructive: true,
                  onTap: _showDataWipeDialog,
                ),
              ],
            ),

            // Security tips
            SettingsCard(
              title: 'Security Tips',
              padding: const EdgeInsets.all(16),
              showDividers: false,
              children: [
                _buildSecurityTip(
                  icon: Iconsax.password_check,
                  title: 'Use Strong Passwords',
                  description:
                      'Create unique passwords with a mix of letters, numbers, and symbols.',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildSecurityTip(
                  icon: Iconsax.security_user,
                  title: 'Enable Two-Factor Authentication',
                  description:
                      'Add an extra layer of security to protect your account.',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildSecurityTip(
                  icon: Iconsax.shield_tick,
                  title: 'Keep Your App Updated',
                  description:
                      'Regular updates include important security patches.',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),

            // Security audit button
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Run Security Audit',
                icon: Iconsax.shield_search,
                onPressed: () {
                  // Show a loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Simulate a security audit
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context).pop(); // Close the loading indicator

                    // Show the result
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Security Audit Complete'),
                          content: const Text(
                            'Your account security is good. Consider enabling two-factor authentication for enhanced security.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  });
                },
                isFullWidth: true,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTip({
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
            .withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDarkMode
                      ? AppTheme.darkPrimaryColor
                      : AppTheme.primaryColor)
                  .withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDarkMode
                  ? AppTheme.darkPrimaryColor
                  : AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppTheme.darkTextPrimaryColor
                        : AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
