import 'package:findsafe/utilities/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _logger = AppLogger.getLogger('BiometricAuthService');

  // Key for storing biometric auth preference
  final String _biometricEnabledKey = 'biometric_auth_enabled';

  // Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      _logger.info('Checking if device supports biometrics');

      // Check if the device supports biometrics
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      _logger.info(
          'Can authenticate with biometrics: $canAuthenticateWithBiometrics');

      final isDeviceSupported = await _localAuth.isDeviceSupported();
      _logger
          .info('Device supports biometric authentication: $isDeviceSupported');

      final canAuthenticate =
          canAuthenticateWithBiometrics || isDeviceSupported;
      _logger
          .info('Can authenticate with biometrics overall: $canAuthenticate');

      return canAuthenticate;
    } on PlatformException catch (e, stackTrace) {
      _logger.severe('Error checking biometric availability', e, stackTrace);
      return false;
    } catch (e, stackTrace) {
      _logger.severe(
          'Unexpected error checking biometric availability', e, stackTrace);
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      _logger.info('Getting available biometric types');
      final biometrics = await _localAuth.getAvailableBiometrics();
      _logger.info('Available biometric types: $biometrics');
      return biometrics;
    } on PlatformException catch (e, stackTrace) {
      _logger.severe('Error getting available biometrics', e, stackTrace);
      return [];
    } catch (e, stackTrace) {
      _logger.severe(
          'Unexpected error getting available biometrics', e, stackTrace);
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      _logger.info(
          'Starting biometric authentication with reason: $localizedReason');
      _logger.info(
          'Options: useErrorDialogs=$useErrorDialogs, stickyAuth=$stickyAuth');

      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          useErrorDialogs: useErrorDialogs,
          biometricOnly: true,
        ),
      );

      if (result) {
        _logger.info('Biometric authentication successful');
      } else {
        _logger.warning('Biometric authentication failed');
      }

      return result;
    } on PlatformException catch (e, stackTrace) {
      _logger.severe('Error authenticating with biometrics', e, stackTrace);

      // Handle specific authentication errors
      if (e.code == auth_error.notAvailable) {
        _logger.warning('Biometric authentication not available');
      } else if (e.code == auth_error.notEnrolled) {
        _logger.warning('No biometrics enrolled on this device');
      } else if (e.code == auth_error.lockedOut) {
        _logger.warning(
            'Biometric authentication locked out due to too many attempts');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        _logger.warning('Biometric authentication permanently locked out');
      }

      return false;
    } catch (e, stackTrace) {
      _logger.severe(
          'Unexpected error during biometric authentication', e, stackTrace);
      return false;
    }
  }

  // Check if biometric authentication is enabled in app settings
  Future<bool> isBiometricEnabled() async {
    try {
      _logger
          .info('Checking if biometric authentication is enabled in settings');
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      final isEnabled = value == 'true';
      _logger.info('Biometric authentication enabled in settings: $isEnabled');
      return isEnabled;
    } catch (e, stackTrace) {
      _logger.severe('Error reading biometric preference', e, stackTrace);
      return false;
    }
  }

  // Set biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      _logger.info('Setting biometric authentication enabled to: $enabled');
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
      _logger.info('Biometric authentication preference saved successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error saving biometric preference', e, stackTrace);
    }
  }

  // Get a user-friendly description of available biometrics
  Future<String> getBiometricString() async {
    try {
      _logger.info('Getting user-friendly description of available biometrics');
      final biometrics = await getAvailableBiometrics();

      if (biometrics.isEmpty) {
        _logger.info('No biometrics available');
        return 'No biometrics available';
      }

      final biometricStrings = <String>[];

      if (biometrics.contains(BiometricType.face)) {
        biometricStrings.add('Face ID');
      }

      if (biometrics.contains(BiometricType.fingerprint)) {
        biometricStrings.add('Fingerprint');
      }

      if (biometrics.contains(BiometricType.iris)) {
        biometricStrings.add('Iris');
      }

      if (biometrics.contains(BiometricType.strong)) {
        biometricStrings.add('Strong biometrics');
      }

      if (biometrics.contains(BiometricType.weak)) {
        biometricStrings.add('Weak biometrics');
      }

      final result = biometricStrings.join(', ');
      _logger.info('Biometric string: $result');
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Error getting biometric string', e, stackTrace);
      return 'Error determining biometrics';
    }
  }
}
