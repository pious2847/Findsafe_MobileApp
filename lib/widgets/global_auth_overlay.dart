import 'package:findsafe/controllers/app_lifecycle_controller.dart';
import 'package:findsafe/controllers/biometric_controller.dart';
import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/screens/biometric_auth.dart';
import 'package:findsafe/screens/pin_auth.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalAuthOverlay extends StatefulWidget {
  final Widget child;
  
  const GlobalAuthOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  _GlobalAuthOverlayState createState() => _GlobalAuthOverlayState();
}

class _GlobalAuthOverlayState extends State<GlobalAuthOverlay> {
  final _logger = AppLogger.getLogger('GlobalAuthOverlay');
  late AppLifecycleController _lifecycleController;
  late SecurityController _securityController;
  late BiometricController _biometricController;
  
  bool _isShowingAuthScreen = false;
  
  @override
  void initState() {
    super.initState();
    _logger.info('Initializing GlobalAuthOverlay');
    
    // Initialize controllers
    if (!Get.isRegistered<AppLifecycleController>()) {
      Get.put(AppLifecycleController());
    }
    _lifecycleController = Get.find<AppLifecycleController>();
    
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }
    _securityController = Get.find<SecurityController>();
    
    if (!Get.isRegistered<BiometricController>()) {
      Get.put(BiometricController());
    }
    _biometricController = Get.find<BiometricController>();
  }
  
  Future<void> _showAuthenticationScreen() async {
    if (_isShowingAuthScreen) {
      _logger.info('Authentication screen already showing, skipping');
      return;
    }
    
    _logger.info('Showing authentication screen');
    _isShowingAuthScreen = true;
    
    try {
      bool authSuccess = false;
      
      // Try biometric authentication first if available
      if (_securityController.biometricAuthEnabled && 
          _biometricController.isBiometricAvailable) {
        _logger.info('Attempting biometric authentication');
        authSuccess = await _showBiometricAuth();
      } else if (_securityController.pinCodeEnabled) {
        _logger.info('Attempting PIN authentication');
        authSuccess = await _showPinAuth();
      }
      
      if (authSuccess) {
        _logger.info('Authentication successful');
        _lifecycleController.markAsAuthenticated();
      } else {
        _logger.info('Authentication failed');
        // Keep showing the authentication screen until successful
        if (mounted && _lifecycleController.shouldRequireAuthentication()) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _showAuthenticationScreen();
        }
      }
    } catch (e) {
      _logger.severe('Error during authentication', e);
    } finally {
      _isShowingAuthScreen = false;
    }
  }
  
  Future<bool> _showBiometricAuth() async {
    if (!mounted) return false;
    
    try {
      bool? result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => BiometricAuthScreen(
            reason: 'Authentication required to access the app',
            onSuccess: () {
              Navigator.of(context).pop(true);
            },
            onFailure: () {
              // If biometric fails and PIN is available, try PIN
              if (_securityController.pinCodeEnabled) {
                Navigator.of(context).pop(false);
              } else {
                Navigator.of(context).pop(false);
              }
            },
          ),
        ),
      );
      
      // If biometric failed but PIN is enabled, try PIN
      if (result != true && _securityController.pinCodeEnabled) {
        return await _showPinAuth();
      }
      
      return result == true;
    } catch (e) {
      _logger.severe('Error during biometric authentication', e);
      return false;
    }
  }
  
  Future<bool> _showPinAuth() async {
    if (!mounted) return false;
    
    try {
      bool? result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => PinAuthScreen(
            mode: PinAuthMode.verify,
            reason: 'Authentication required to access the app',
            onSuccess: () {
              Navigator.of(context).pop(true);
            },
            onFailure: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
      );
      
      return result == true;
    } catch (e) {
      _logger.severe('Error during PIN authentication', e);
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Check if authentication is required
      if (_lifecycleController.shouldRequireAuthentication()) {
        _logger.info('Authentication required, showing auth screen');
        
        // Show authentication screen if not already showing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isShowingAuthScreen) {
            _showAuthenticationScreen();
          }
        });
        
        // Show a blocking overlay while authentication is required
        return Scaffold(
          backgroundColor: Colors.black87,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authentication Required',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please authenticate to continue using the app',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      // If no authentication is required, show the child widget
      return widget.child;
    });
  }
}
