import 'package:findsafe/controllers/biometric_controller.dart';
import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/screens/biometric_auth.dart';
import 'package:findsafe/screens/pin_auth.dart';
import 'package:findsafe/screens/security.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SecurityWrapperScreen extends StatefulWidget {
  const SecurityWrapperScreen({super.key});

  @override
  State<SecurityWrapperScreen> createState() => _SecurityWrapperScreenState();
}

class _SecurityWrapperScreenState extends State<SecurityWrapperScreen> {
  final _logger = AppLogger.getLogger('SecurityWrapperScreen');
  late SecurityController _securityController;
  late BiometricController _biometricController;
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing SecurityWrapperScreen');

    // Initialize controllers
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }
    _securityController = Get.find<SecurityController>();

    if (!Get.isRegistered<BiometricController>()) {
      Get.put(BiometricController());
    }
    _biometricController = Get.find<BiometricController>();

    // Check authentication after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthRequirements();
    });
  }

  Future<void> _checkAuthRequirements() async {
    _logger.info('Checking authentication requirements');

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
      if (_securityController.biometricAuthEnabled &&
          _biometricController.isBiometricAvailable) {
        _logger.info('Using biometric authentication');
        await _showBiometricAuth();
      } else if (_securityController.pinCodeEnabled) {
        _logger.info('Using PIN authentication');
        await _showPinAuth();
      } else {
        _logger.info('No authentication method available, skipping');
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isAuthenticating = false;
          });
        }
      }
    } catch (e) {
      _logger.severe('Error during authentication', e);
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _showBiometricAuth() async {
    _logger.info('Showing biometric authentication screen');

    if (!mounted) return;

    // Define success and failure handlers
    void handleSuccess() {
      _logger.info('Biometric authentication successful');
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
    }

    void handleFailure() {
      _logger.info('Biometric authentication failed');
      if (_securityController.pinCodeEnabled) {
        // Use a microtask to avoid navigation during build
        Future.microtask(() async {
          if (mounted) {
            await _showPinAuth();
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _isAuthenticating = false;
          });
        }
      }
    }

    try {
      // Show biometric authentication screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BiometricAuthScreen(
            reason: 'Authenticate to access security settings',
            onSuccess: () {
              // Just update the state, don't navigate here
              handleSuccess();
              // Use a microtask to safely pop after the build phase
              Future.microtask(() {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
            onFailure: () {
              // Just update the state, don't navigate here
              handleFailure();
              // Use a microtask to safely pop after the build phase
              Future.microtask(() {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
          ),
        ),
      );
    } catch (e) {
      _logger.severe('Error during biometric authentication navigation', e);
      handleFailure();
    }
  }

  Future<void> _showPinAuth() async {
    _logger.info('Showing PIN authentication screen');

    if (!mounted) return;

    // Define success and failure handlers
    void handleSuccess() {
      _logger.info('PIN authentication successful');
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
    }

    void handleFailure() {
      _logger.info('PIN authentication failed');
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
      }
    }

    try {
      // Show PIN authentication screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinAuthScreen(
            mode: PinAuthMode.verify,
            reason: 'Authenticate to access security settings',
            onSuccess: () {
              // Just update the state, don't navigate here
              handleSuccess();
              // Use a microtask to safely pop after the build phase
              Future.microtask(() {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
            onFailure: () {
              // Just update the state, don't navigate here
              handleFailure();
              // Use a microtask to safely pop after the build phase
              Future.microtask(() {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
          ),
        ),
      );
    } catch (e) {
      _logger.severe('Error during PIN authentication navigation', e);
      handleFailure();
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
      return const SecurityScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Authentication Failed'),
        ),
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
