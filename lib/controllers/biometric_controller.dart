import 'package:findsafe/service/biometric_auth.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class BiometricController extends GetxController {
  static BiometricController get to => Get.find();

  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final _logger = AppLogger.getLogger('BiometricController');

  final RxBool _isBiometricAvailable = false.obs;
  final RxBool _isBiometricEnabled = false.obs;
  final RxList<BiometricType> _availableBiometrics = <BiometricType>[].obs;
  final RxString _biometricString = ''.obs;

  bool get isBiometricAvailable => _isBiometricAvailable.value;
  bool get isBiometricEnabled => _isBiometricEnabled.value;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  String get biometricString => _biometricString.value;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
  }

  // Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    try {
      _logger.info('Checking biometric availability');

      _isBiometricAvailable.value =
          await _biometricAuthService.isBiometricAvailable();
      _logger.info('Biometric available: ${_isBiometricAvailable.value}');

      _isBiometricEnabled.value =
          await _biometricAuthService.isBiometricEnabled();
      _logger.info('Biometric enabled: ${_isBiometricEnabled.value}');

      _availableBiometrics.value =
          await _biometricAuthService.getAvailableBiometrics();
      _logger.info('Available biometrics: ${_availableBiometrics.toString()}');

      _biometricString.value = await _biometricAuthService.getBiometricString();
      _logger.info('Biometric string: ${_biometricString.value}');
    } catch (e, stackTrace) {
      _logger.severe('Error checking biometric availability', e, stackTrace);
    }
  }

  // Toggle biometric authentication
  Future<bool> toggleBiometric(bool value, BuildContext context) async {
    _logger.info('Toggling biometric authentication to: $value');

    try {
      // If trying to enable biometrics
      if (value) {
        // Check if biometrics are available
        if (!_isBiometricAvailable.value) {
          _logger.warning(
              'Biometric authentication is not available on this device');
          CustomToast.show(
            context: context,
            message: 'Biometric authentication is not available on this device',
            type: ToastType.error,
            position: ToastPosition.top,
          );
          return false;
        }

        // Check if there are any biometrics enrolled
        if (_availableBiometrics.isEmpty) {
          _logger.warning('No biometrics enrolled on this device');
          CustomToast.show(
            context: context,
            message: 'No biometrics enrolled on this device',
            type: ToastType.error,
            position: ToastPosition.top,
          );
          return false;
        }

        // Authenticate to confirm
        _logger.info('Authenticating to enable biometric login');
        final authenticated = await _biometricAuthService.authenticate(
          localizedReason: 'Authenticate to enable biometric login',
        );

        if (!authenticated) {
          _logger
              .warning('Authentication failed when enabling biometric login');
          CustomToast.show(
            context: context,
            message: 'Authentication failed',
            type: ToastType.error,
            position: ToastPosition.top,
          );
          return false;
        }
      }

      // Save the preference
      _logger.info('Saving biometric preference: $value');
      await _biometricAuthService.setBiometricEnabled(value);
      _isBiometricEnabled.value = value;

      // Show success message
      CustomToast.show(
        context: context,
        message: value
            ? 'Biometric authentication enabled'
            : 'Biometric authentication disabled',
        type: ToastType.success,
        position: ToastPosition.top,
      );

      _logger.info('Biometric authentication successfully toggled to: $value');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error toggling biometric authentication', e, stackTrace);
      CustomToast.show(
        context: context,
        message: 'Error toggling biometric authentication: ${e.toString()}',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      return false;
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate({
    required String reason,
    required BuildContext context,
  }) async {
    _logger.info('Starting biometric authentication');

    try {
      // Check if biometrics are enabled in settings
      if (!_isBiometricEnabled.value) {
        _logger.info(
            'Biometric authentication is not enabled in settings, skipping');
        return true; // Skip authentication if not enabled
      }

      // Check if biometrics are available
      if (!_isBiometricAvailable.value) {
        _logger.warning(
            'Biometric authentication is not available on this device');
        CustomToast.show(
          context: context,
          message: 'Biometric authentication is not available on this device',
          type: ToastType.error,
          position: ToastPosition.top,
        );
        return false;
      }

      // Authenticate
      _logger.info(
          'Calling biometric authentication service with reason: $reason');
      final authenticated = await _biometricAuthService.authenticate(
        localizedReason: reason,
      );

      if (authenticated) {
        _logger.info('Biometric authentication successful');
      } else {
        _logger.warning('Biometric authentication failed');
        CustomToast.show(
          context: context,
          message: 'Authentication failed',
          type: ToastType.error,
          position: ToastPosition.top,
        );
      }

      return authenticated;
    } catch (e, stackTrace) {
      _logger.severe('Error during biometric authentication', e, stackTrace);
      CustomToast.show(
        context: context,
        message: 'Authentication error: ${e.toString()}',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      return false;
    }
  }
}
