import 'package:findsafe/controllers/biometric_controller.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class BiometricAuthScreen extends StatefulWidget {
  final String reason;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;
  
  const BiometricAuthScreen({
    super.key,
    required this.reason,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> with SingleTickerProviderStateMixin {
  late BiometricController _biometricController;
  late AnimationController _animationController;
  bool _isAuthenticating = false;
  bool _authFailed = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat(reverse: true);
    
    // Initialize biometric controller
    if (!Get.isRegistered<BiometricController>()) {
      Get.put(BiometricController());
    }
    _biometricController = Get.find<BiometricController>();
    
    // Start authentication after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _authFailed = false;
    });
    
    final authenticated = await _biometricController.authenticate(
      reason: widget.reason,
      context: context,
    );
    
    setState(() {
      _isAuthenticating = false;
      _authFailed = !authenticated;
    });
    
    if (authenticated) {
      widget.onSuccess();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Authentication Required',
        showBackButton: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: _authFailed
                    ? Icon(
                        Iconsax.shield_cross,
                        size: 80,
                        color: Colors.red,
                      )
                    : _isAuthenticating
                        ? _buildAuthenticationAnimation(isDarkMode)
                        : Icon(
                            Iconsax.finger_scan,
                            size: 80,
                            color: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                          ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                _authFailed
                    ? 'Authentication Failed'
                    : _isAuthenticating
                        ? 'Authenticating...'
                        : 'Authentication Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _authFailed
                      ? Colors.red
                      : (isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                _authFailed
                    ? 'Please try again or use an alternative method'
                    : widget.reason,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Buttons
              if (_authFailed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: 'Try Again',
                      icon: Iconsax.refresh,
                      onPressed: _authenticate,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      text: 'Cancel',
                      icon: Iconsax.close_circle,
                      onPressed: widget.onFailure,
                      backgroundColor: Colors.grey,
                    ),
                  ],
                ),
              
              if (!_isAuthenticating && !_authFailed)
                CustomButton(
                  text: 'Authenticate',
                  icon: Iconsax.finger_scan,
                  onPressed: _authenticate,
                  isFullWidth: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAuthenticationAnimation(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsating circle
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 150 + (50 * _animationController.value),
              height: 150 + (50 * _animationController.value),
              decoration: BoxDecoration(
                color: (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
                    .withAlpha((50 * (1 - _animationController.value)).toInt()),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
        
        // Fingerprint icon
        Icon(
          Iconsax.finger_scan,
          size: 80,
          color: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
        ),
      ],
    );
  }
}
