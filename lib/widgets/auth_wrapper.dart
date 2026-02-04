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
  final VoidCallback? onAuthenticationComplete;

  const AuthWrapper({
    super.key,
    required this.child,
    required this.reason,
    this.onAuthenticationComplete,
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

    // Use a microtask to ensure we're not in the middle of a build
    await Future.microtask(() async {
      if (!mounted) return;

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
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isAuthenticating = true;
      });

      // Use a safer approach to avoid navigation conflicts
      // Instead of awaiting the navigation result directly, we'll use callbacks
      // to handle the authentication result

      // Define success and failure callbacks
      void onAuthSuccess() {
        if (!mounted) return;

        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });

        // Call the callback if provided
        if (widget.onAuthenticationComplete != null) {
          widget.onAuthenticationComplete!();
        }
      }

      void onAuthFailure() {
        if (!mounted) return;

        // Authentication failed, try PIN if enabled
        if (_securityController.pinCodeEnabled) {
          _authenticateWithPin();
        } else {
          setState(() {
            _isAuthenticated = false;
            _isAuthenticating = false;
          });
        }
      }

      // Use a microtask to ensure we're not in the middle of a build
      await Future.microtask(() async {
        if (!mounted) return;

        try {
          // Navigate to the BiometricAuthScreen
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BiometricAuthScreen(
                reason: widget.reason,
                onSuccess: onAuthSuccess,
                onFailure: onAuthFailure,
              ),
            ),
          );
        } catch (navError) {
          _logger.severe(
              'Navigation error during biometric authentication', navError);
          // If navigation fails, treat it as authentication failure
          onAuthFailure();
        }
      });
    } catch (e, stackTrace) {
      // Handle any other errors
      _logger.severe(
          'Error during biometric authentication process', e, stackTrace);

      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _authenticateWithPin() async {
    if (!mounted) return;

    try {
      setState(() {
        _isAuthenticating = true;
      });

      // Use a safer approach with Future.microtask to avoid build phase conflicts
      await Future.microtask(() async {
        try {
          // Delay navigation slightly to avoid build phase conflicts
          await Future.delayed(const Duration(milliseconds: 50));

          if (!mounted) return;

          // Use a simpler approach without callbacks
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => PinAuthScreen(
                mode: PinAuthMode.verify,
                reason: widget.reason,
                // No callbacks - rely on Navigator.pop with result
              ),
            ),
          );

          // Check if the widget is still mounted before updating state
          if (!mounted) return;

          // Handle the result after navigation is complete
          setState(() {
            _isAuthenticated = result == true;
            _isAuthenticating = false;
          });

          // Call the callback if authentication was successful and callback is provided
          if (result == true && widget.onAuthenticationComplete != null) {
            widget.onAuthenticationComplete!();
          }
        } catch (navError) {
          debugPrint('Navigation error during PIN authentication: $navError');

          // Check if the widget is still mounted before updating state
          if (!mounted) return;

          // Continue with the flow, but mark as not authenticated
          setState(() {
            _isAuthenticated = false;
            _isAuthenticating = false;
          });
        }
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
