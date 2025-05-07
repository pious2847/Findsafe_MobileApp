import 'package:findsafe/controllers/biometric_controller.dart';
import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/screens/biometric_auth.dart';
import 'package:findsafe/screens/pin_auth.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;
  final String reason;

  const AuthWrapper({
    super.key,
    required this.child,
    required this.reason,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late SecurityController _securityController;
  late BiometricController _biometricController;
  final _logger = AppLogger.getLogger('AuthWrapper');
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing AuthWrapper with reason: ${widget.reason}');

    // Initialize controllers
    _logger.info('Setting up security controller');
    if (!Get.isRegistered<SecurityController>()) {
      _logger.info('Registering SecurityController with GetX');
      Get.put(SecurityController());
    }
    _securityController = Get.find<SecurityController>();

    _logger.info('Setting up biometric controller');
    if (!Get.isRegistered<BiometricController>()) {
      _logger.info('Registering BiometricController with GetX');
      Get.put(BiometricController());
    }
    _biometricController = Get.find<BiometricController>();

    // Check authentication requirements
    _logger.info('Checking authentication requirements');
    _checkAuthRequirements();
  }

  Future<void> _checkAuthRequirements() async {
    _logger.info(
        'Biometric auth enabled: ${_securityController.biometricAuthEnabled}');
    _logger.info('PIN code enabled: ${_securityController.pinCodeEnabled}');

    // If no authentication is required, skip authentication
    if (!_securityController.biometricAuthEnabled &&
        !_securityController.pinCodeEnabled) {
      _logger.info('No authentication required, skipping');
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
      return;
    }

    try {
      // If biometric authentication is enabled and available, try that first
      if (_securityController.biometricAuthEnabled &&
          _biometricController.isBiometricAvailable) {
        _logger.info(
            'Biometric authentication is enabled and available, using it');
        await _authenticateWithBiometrics();
      } else if (_securityController.pinCodeEnabled) {
        // If PIN authentication is enabled, use that
        _logger.info('PIN authentication is enabled, using it');
        await _authenticateWithPin();
      } else {
        // If no authentication method is available, skip authentication
        _logger.info('No authentication method available, skipping');
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isAuthenticating = false;
          });
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('Error during authentication', e, stackTrace);
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      // Use a try-catch block to handle any navigation errors
      bool? result;

      try {
        result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => BiometricAuthScreen(
              reason: widget.reason,
              onSuccess: () {
                // Use Navigator.pop with a result instead of callbacks
                Navigator.of(context).pop(true);
              },
              onFailure: () {
                // Use Navigator.pop with a result instead of callbacks
                Navigator.of(context).pop(false);
              },
            ),
          ),
        );
      } catch (navError) {
        debugPrint(
            'Navigation error during biometric authentication: $navError');
        // Continue with the flow, but mark as not authenticated
        result = false;
      }

      // Check if the widget is still mounted before updating state
      if (!mounted) return;

      // Handle the result after navigation is complete
      if (result == true) {
        // Authentication successful
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      } else {
        // Authentication failed, try PIN if enabled
        if (_securityController.pinCodeEnabled) {
          await _authenticateWithPin();
        } else {
          setState(() {
            _isAuthenticated = false;
            _isAuthenticating = false;
          });
        }
      }
    } catch (e, stackTrace) {
      // Handle any other errors
      debugPrint('Error during biometric authentication process: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _authenticateWithPin() async {
    try {
      // Use a try-catch block to handle any navigation errors
      bool? result;

      try {
        result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => PinAuthScreen(
              mode: PinAuthMode.verify,
              reason: widget.reason,
              onSuccess: () {
                // Use Navigator.pop with a result instead of callbacks
                Navigator.of(context).pop(true);
              },
              onFailure: () {
                // Use Navigator.pop with a result instead of callbacks
                Navigator.of(context).pop(false);
              },
            ),
          ),
        );
      } catch (navError) {
        debugPrint('Navigation error during PIN authentication: $navError');
        // Continue with the flow, but mark as not authenticated
        result = false;
      }

      // Check if the widget is still mounted before updating state
      if (!mounted) return;

      // Handle the result after navigation is complete
      setState(() {
        _isAuthenticated = result == true;
        _isAuthenticating = false;
      });
    } catch (e, stackTrace) {
      // Handle any other errors
      debugPrint('Error during PIN authentication process: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return widget.child;
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Authentication Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkAuthRequirements,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
