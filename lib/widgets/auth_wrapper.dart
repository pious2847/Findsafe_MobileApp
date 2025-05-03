import 'package:findsafe/controllers/biometric_controller.dart';
import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/screens/biometric_auth.dart';
import 'package:findsafe/screens/pin_auth.dart';
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
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }
    _securityController = Get.find<SecurityController>();

    if (!Get.isRegistered<BiometricController>()) {
      Get.put(BiometricController());
    }
    _biometricController = Get.find<BiometricController>();

    // Check authentication requirements
    _checkAuthRequirements();
  }

  Future<void> _checkAuthRequirements() async {
    // If no authentication is required, skip authentication
    if (!_securityController.biometricAuthEnabled &&
        !_securityController.pinCodeEnabled) {
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
        await _authenticateWithBiometrics();
      } else if (_securityController.pinCodeEnabled) {
        // If PIN authentication is enabled, use that
        await _authenticateWithPin();
      } else {
        // If no authentication method is available, skip authentication
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isAuthenticating = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error during authentication: $e');
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
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => BiometricAuthScreen(
            reason: widget.reason,
            onSuccess: () {
              // Use Navigator.pop with a result instead of callbacks
              Navigator.pop(context, true);
            },
            onFailure: () {
              // Use Navigator.pop with a result instead of callbacks
              Navigator.pop(context, false);
            },
          ),
        ),
      );

      // Handle the result after navigation is complete
      if (result == true) {
        // Authentication successful
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isAuthenticating = false;
          });
        }
      } else {
        // Authentication failed, try PIN if enabled
        if (_securityController.pinCodeEnabled) {
          await _authenticateWithPin();
        } else {
          if (mounted) {
            setState(() {
              _isAuthenticated = false;
              _isAuthenticating = false;
            });
          }
        }
      }
    } catch (e) {
      // Handle any navigation errors
      debugPrint('Error during biometric authentication: $e');
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
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PinAuthScreen(
            mode: PinAuthMode.verify,
            reason: widget.reason,
            onSuccess: () {
              // Use Navigator.pop with a result instead of callbacks
              Navigator.pop(context, true);
            },
            onFailure: () {
              // Use Navigator.pop with a result instead of callbacks
              Navigator.pop(context, false);
            },
          ),
        ),
      );

      // Handle the result after navigation is complete
      if (mounted) {
        setState(() {
          _isAuthenticated = result == true;
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      // Handle any navigation errors
      debugPrint('Error during PIN authentication: $e');
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
