import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconsax/iconsax.dart';

enum PinAuthMode {
  setup,
  verify,
  change,
}

class PinAuthScreen extends StatefulWidget {
  final PinAuthMode mode;
  final String reason;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const PinAuthScreen({
    super.key,
    required this.mode,
    required this.reason,
    this.onSuccess,
    this.onFailure,
  });

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _pinKey = 'app_pin_code';

  final List<String> _pin = ['', '', '', ''];
  final List<String> _confirmPin = ['', '', '', ''];
  String _currentPin = '';

  int _currentStep =
      0; // 0: Enter PIN, 1: Confirm PIN, 2: Enter old PIN (for change mode)
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // If in change mode, start with entering the old PIN
    if (widget.mode == PinAuthMode.change) {
      _currentStep = 2;
    }

    // If in verify mode, load the stored PIN
    if (widget.mode == PinAuthMode.verify) {
      _loadPin();
    }
  }

  Future<void> _loadPin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPin = await _secureStorage.read(key: _pinKey) ?? '';

      if (!mounted) return;

      if (_currentPin.isEmpty && widget.mode == PinAuthMode.verify) {
        // No PIN set, consider it a success for verification mode
        // Add a small delay to prevent navigation conflicts
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;

        // Call the success callback if provided
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          // Fallback to Navigator.pop with result
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      debugPrint('Error loading PIN: $e');

      if (!mounted) return;

      _setError('Failed to load PIN');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePin(String pin) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _secureStorage.write(key: _pinKey, value: pin);

      if (!mounted) return;

      CustomToast.show(
        context: context,
        message: 'PIN set successfully',
        type: ToastType.success,
        position: ToastPosition.top,
      );

      // Add a small delay to prevent navigation conflicts
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // Call the success callback if provided
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        // Fallback to Navigator.pop with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving PIN: $e');

      if (!mounted) return;

      _setError('Failed to save PIN');

      // Don't navigate away on failure, let the user try again
      // Only pop with false if explicitly requested to fail
      if (widget.onFailure != null) {
        // Add a small delay to prevent navigation conflicts
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          Navigator.pop(context, false);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Clear error after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  void _onDigitPressed(String digit) {
    if (_isLoading) return;

    setState(() {
      _errorMessage = '';

      if (_currentStep == 0) {
        // Enter PIN
        for (int i = 0; i < _pin.length; i++) {
          if (_pin[i].isEmpty) {
            _pin[i] = digit;
            break;
          }
        }

        // Check if PIN is complete
        if (!_pin.contains('')) {
          // Move to confirm PIN step if in setup or change mode
          if (widget.mode == PinAuthMode.setup ||
              widget.mode == PinAuthMode.change) {
            _currentStep = 1;
          } else {
            // Use a safer approach to avoid build phase conflicts
            // Exit the setState call before calling async method
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _verifyPin();
            });
          }
        }
      } else if (_currentStep == 1) {
        // Confirm PIN
        for (int i = 0; i < _confirmPin.length; i++) {
          if (_confirmPin[i].isEmpty) {
            _confirmPin[i] = digit;
            break;
          }
        }

        // Check if confirmation PIN is complete
        if (!_confirmPin.contains('')) {
          // Use a safer approach to avoid build phase conflicts
          // Exit the setState call before calling async method
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _verifyConfirmPin();
          });
        }
      } else if (_currentStep == 2) {
        // Enter old PIN (for change mode)
        for (int i = 0; i < _pin.length; i++) {
          if (_pin[i].isEmpty) {
            _pin[i] = digit;
            break;
          }
        }

        // Check if old PIN is complete
        if (!_pin.contains('')) {
          // Use a safer approach to avoid build phase conflicts
          // Exit the setState call before calling async method
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _verifyOldPin();
          });
        }
      }
    });
  }

  void _onDeletePressed() {
    if (_isLoading) return;

    setState(() {
      if (_currentStep == 0) {
        // Remove last digit from PIN
        for (int i = _pin.length - 1; i >= 0; i--) {
          if (_pin[i].isNotEmpty) {
            _pin[i] = '';
            break;
          }
        }
      } else if (_currentStep == 1) {
        // Remove last digit from confirm PIN
        for (int i = _confirmPin.length - 1; i >= 0; i--) {
          if (_confirmPin[i].isNotEmpty) {
            _confirmPin[i] = '';
            break;
          }
        }
      } else if (_currentStep == 2) {
        // Remove last digit from old PIN
        for (int i = _pin.length - 1; i >= 0; i--) {
          if (_pin[i].isNotEmpty) {
            _pin[i] = '';
            break;
          }
        }
      }
    });
  }

  void _resetPin() {
    setState(() {
      for (int i = 0; i < _pin.length; i++) {
        _pin[i] = '';
      }

      for (int i = 0; i < _confirmPin.length; i++) {
        _confirmPin[i] = '';
      }
    });
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pin.join();

    if (enteredPin == _currentPin) {
      // PIN is correct
      _setError('');

      // Add a small delay to prevent navigation conflicts
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        // Call the success callback if provided
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          // Fallback to Navigator.pop with result
          Navigator.pop(context, true);
        }
      }
    } else {
      // PIN is incorrect
      _setError('Incorrect PIN');
      _resetPin();

      // Don't navigate away on failure, let the user try again
      // Only call failure callback if explicitly provided
      if (widget.onFailure != null && mounted) {
        // Add a small delay to prevent navigation conflicts
        await Future.delayed(const Duration(milliseconds: 100));
        widget.onFailure!();
      }
    }
  }

  Future<void> _verifyOldPin() async {
    final enteredPin = _pin.join();

    if (enteredPin == _currentPin) {
      // Old PIN is correct, move to enter new PIN
      if (mounted) {
        setState(() {
          _currentStep = 0;
          _resetPin();
        });
      }
    } else {
      // Old PIN is incorrect
      _setError('Incorrect PIN');
      _resetPin();
    }
  }

  Future<void> _verifyConfirmPin() async {
    if (!mounted) return;

    final pin = _pin.join();
    final confirmPin = _confirmPin.join();

    if (pin == confirmPin) {
      // PINs match, save the PIN
      await _savePin(pin);
    } else {
      // PINs don't match
      _setError('PINs do not match');

      // Add a small delay before resetting
      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted) {
        setState(() {
          _currentStep = 0;
          _resetPin();
        });
      }
    }
  }

  String _getStepTitle() {
    if (_currentStep == 0) {
      return widget.mode == PinAuthMode.verify ? 'Enter PIN' : 'Create PIN';
    } else if (_currentStep == 1) {
      return 'Confirm PIN';
    } else {
      return 'Enter Current PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.mode == PinAuthMode.setup
            ? 'Set PIN'
            : widget.mode == PinAuthMode.change
                ? 'Change PIN'
                : 'Verify PIN',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Title
                  Text(
                    _getStepTitle(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppTheme.darkTextPrimaryColor
                          : AppTheme.textPrimaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.reason,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // PIN display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final pin = _currentStep == 0
                          ? _pin
                          : _currentStep == 1
                              ? _confirmPin
                              : _pin;

                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppTheme.darkCardColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: pin[index].isNotEmpty
                                ? (isDarkMode
                                    ? AppTheme.darkPrimaryColor
                                    : AppTheme.primaryColor)
                                : (isDarkMode
                                    ? AppTheme.darkDividerColor
                                    : AppTheme.dividerColor),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: pin[index].isNotEmpty
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? AppTheme.darkPrimaryColor
                                        : AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  ),

                  // Error message
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // PIN pad
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Digits 1-9
                      for (int i = 1; i <= 9; i++)
                        _buildDigitButton(i.toString()),

                      // Empty space
                      const SizedBox(),

                      // Digit 0
                      _buildDigitButton('0'),

                      // Delete button
                      _buildActionButton(
                        icon: Iconsax.backward,
                        onPressed: _onDeletePressed,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildDigitButton(String digit) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onDigitPressed(digit),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? AppTheme.darkTextPrimaryColor
                    : AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: isDarkMode
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
