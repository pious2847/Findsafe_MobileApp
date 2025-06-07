import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLifecycleController extends GetxController with WidgetsBindingObserver {
  static AppLifecycleController get to => Get.find();
  
  final _logger = AppLogger.getLogger('AppLifecycleController');
  late SecurityController _securityController;
  
  // Observable variables
  final _isAuthenticated = true.obs;
  final _needsAuthentication = false.obs;
  final _hasBeenPaused = false.obs;
  final _isAppInForeground = true.obs;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  bool get needsAuthentication => _needsAuthentication.value;
  bool get hasBeenPaused => _hasBeenPaused.value;
  bool get isAppInForeground => _isAppInForeground.value;
  
  @override
  void onInit() {
    super.onInit();
    _logger.info('Initializing AppLifecycleController');
    
    // Add this controller as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize security controller
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }
    _securityController = Get.find<SecurityController>();
    
    _logger.info('AppLifecycleController initialized');
  }
  
  @override
  void onClose() {
    _logger.info('Disposing AppLifecycleController');
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _logger.info('App lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }
  
  void _handleAppResumed() {
    _logger.info('App resumed');
    _isAppInForeground.value = true;
    
    // Only require authentication if:
    // 1. 2FA is enabled
    // 2. The app has been paused before (not the initial launch)
    // 3. Either biometric or PIN authentication is enabled
    if (_securityController.twoFactorAuthEnabled && 
        _hasBeenPaused.value &&
        (_securityController.biometricAuthEnabled || _securityController.pinCodeEnabled)) {
      _logger.info('2FA is enabled and app was paused, requiring authentication');
      
      _isAuthenticated.value = false;
      _needsAuthentication.value = true;
    } else {
      _logger.info('No authentication required on resume');
    }
  }
  
  void _handleAppPaused() {
    _logger.info('App paused');
    _isAppInForeground.value = false;
    _hasBeenPaused.value = true;
    
    // Mark as needing authentication when app comes back
    if (_securityController.twoFactorAuthEnabled &&
        (_securityController.biometricAuthEnabled || _securityController.pinCodeEnabled)) {
      _logger.info('App paused with 2FA enabled, will require authentication on resume');
      _isAuthenticated.value = false;
    }
  }
  
  void _handleAppInactive() {
    _logger.info('App inactive');
    _isAppInForeground.value = false;
    // App is inactive but not necessarily in background
    // This happens during transitions, phone calls, etc.
  }
  
  void _handleAppDetached() {
    _logger.info('App detached');
    _isAppInForeground.value = false;
    // App is detached from the Flutter engine
  }
  
  void _handleAppHidden() {
    _logger.info('App hidden');
    _isAppInForeground.value = false;
    _hasBeenPaused.value = true;
  }
  
  void markAsAuthenticated() {
    _logger.info('Marking app as authenticated');
    _isAuthenticated.value = true;
    _needsAuthentication.value = false;
  }
  
  void markAsUnauthenticated() {
    _logger.info('Marking app as unauthenticated');
    _isAuthenticated.value = false;
    _needsAuthentication.value = true;
  }
  
  void resetAuthenticationState() {
    _logger.info('Resetting authentication state');
    _isAuthenticated.value = true;
    _needsAuthentication.value = false;
    _hasBeenPaused.value = false;
  }
  
  bool shouldRequireAuthentication() {
    return _securityController.twoFactorAuthEnabled &&
           _needsAuthentication.value &&
           !_isAuthenticated.value &&
           (_securityController.biometricAuthEnabled || _securityController.pinCodeEnabled);
  }
}
