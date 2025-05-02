import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Key for storing biometric auth preference
  final String _biometricEnabledKey = 'biometric_auth_enabled';
  
  // Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      // Check if the device supports biometrics
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }
  
  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
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
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          useErrorDialogs: useErrorDialogs,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Error authenticating: $e');
      
      // Handle specific authentication errors
      if (e.code == auth_error.notAvailable) {
        debugPrint('Biometric authentication not available');
      } else if (e.code == auth_error.notEnrolled) {
        debugPrint('No biometrics enrolled on this device');
      } else if (e.code == auth_error.lockedOut) {
        debugPrint('Biometric authentication locked out due to too many attempts');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        debugPrint('Biometric authentication permanently locked out');
      }
      
      return false;
    }
  }
  
  // Check if biometric authentication is enabled in app settings
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      debugPrint('Error reading biometric preference: $e');
      return false;
    }
  }
  
  // Set biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      debugPrint('Error saving biometric preference: $e');
    }
  }
  
  // Get a user-friendly description of available biometrics
  Future<String> getBiometricString() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.isEmpty) {
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
    
    return biometricStrings.join(', ');
  }
}
