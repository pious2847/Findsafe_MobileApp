import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:findsafe/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TwoFactorAuthWrapper extends StatefulWidget {
  final Widget child;
  
  const TwoFactorAuthWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  _TwoFactorAuthWrapperState createState() => _TwoFactorAuthWrapperState();
}

class _TwoFactorAuthWrapperState extends State<TwoFactorAuthWrapper> {
  late SecurityController _securityController;
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;
  final _logger = AppLogger.getLogger('TwoFactorAuthWrapper');
  
  @override
  void initState() {
    super.initState();
    _logger.info('Initializing TwoFactorAuthWrapper');
    
    // Initialize controller
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }
    _securityController = Get.find<SecurityController>();
    
    // Check if 2FA is enabled
    _checkTwoFactorAuth();
  }
  
  Future<void> _checkTwoFactorAuth() async {
    _logger.info('Checking if 2FA is enabled');
    
    // If 2FA is not enabled, skip authentication
    if (!_securityController.twoFactorAuthEnabled) {
      _logger.info('2FA is not enabled, skipping authentication');
      setState(() {
        _isAuthenticated = true;
        _isAuthenticating = false;
      });
      return;
    }
    
    // If 2FA is enabled, show the AuthWrapper
    _logger.info('2FA is enabled, showing AuthWrapper');
    setState(() {
      _isAuthenticated = false;
      _isAuthenticating = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // If still authenticating, show a loading indicator
    if (_isAuthenticating) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // If 2FA is not enabled or authentication is complete, show the child
    if (_isAuthenticated || !_securityController.twoFactorAuthEnabled) {
      return widget.child;
    }
    
    // If 2FA is enabled and not authenticated, show the AuthWrapper
    return AuthWrapper(
      reason: 'Authentication required to access the app',
      child: widget.child,
      onAuthenticationComplete: () {
        setState(() {
          _isAuthenticated = true;
        });
      },
    );
  }
}
