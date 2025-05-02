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
    if (!_securityController.biometricAuthEnabled && !_securityController.pinCodeEnabled) {
      setState(() {
        _isAuthenticated = true;
        _isAuthenticating = false;
      });
      return;
    }
    
    // If biometric authentication is enabled and available, try that first
    if (_securityController.biometricAuthEnabled && _biometricController.isBiometricAvailable) {
      _authenticateWithBiometrics();
    } else if (_securityController.pinCodeEnabled) {
      // If PIN authentication is enabled, use that
      _authenticateWithPin();
    } else {
      // If no authentication method is available, skip authentication
      setState(() {
        _isAuthenticated = true;
        _isAuthenticating = false;
      });
    }
  }
  
  void _authenticateWithBiometrics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BiometricAuthScreen(
          reason: widget.reason,
          onSuccess: () {
            Navigator.pop(context);
            setState(() {
              _isAuthenticated = true;
              _isAuthenticating = false;
            });
          },
          onFailure: () {
            // If biometric authentication fails, try PIN authentication if enabled
            if (_securityController.pinCodeEnabled) {
              _authenticateWithPin();
            } else {
              setState(() {
                _isAuthenticated = false;
                _isAuthenticating = false;
              });
            }
          },
        ),
      ),
    );
  }
  
  void _authenticateWithPin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinAuthScreen(
          mode: PinAuthMode.verify,
          reason: widget.reason,
          onSuccess: () {
            Navigator.pop(context);
            setState(() {
              _isAuthenticated = true;
              _isAuthenticating = false;
            });
          },
          onFailure: () {
            setState(() {
              _isAuthenticated = false;
              _isAuthenticating = false;
            });
          },
        ),
      ),
    );
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
