import 'dart:async';
import 'package:findsafe/screens/login.dart';
import 'package:findsafe/service/auth.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyAccount extends StatefulWidget {
  final String email;

  const VerifyAccount({super.key, required this.email});

  @override
  VerifyAccountState createState() => VerifyAccountState();
}

class VerifyAccountState extends State<VerifyAccount> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  final _authProvider = AuthProvider();

  // Timer for resend functionality
  Timer? _timer;
  int _resendTime = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Make sure the controller is not used after being disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpController.dispose();
      }
    });
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTime > 0) {
          _resendTime--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authProvider.verifyOtp(
          context,
          widget.email,
          _otpController.text,
        );

        // Navigation to login screen is handled in the auth provider
      } catch (e) {
        CustomToast.show(
          context: context,
          message: 'Verification failed: ${e.toString()}',
          type: ToastType.error,
          position: ToastPosition.top,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the resend OTP endpoint
      await _authProvider.resendVerificationOtp(context, widget.email);

      // Reset the timer
      setState(() {
        _canResend = false;
        _resendTime = 60;
      });
      _startResendTimer();

      CustomToast.show(
        context: context,
        message: 'Verification code resent successfully',
        type: ToastType.success,
        position: ToastPosition.top,
      );
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Failed to resend verification code',
        type: ToastType.error,
        position: ToastPosition.top,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Iconsax.arrow_left, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Verify Your Account",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We've sent a verification code to ${widget.email}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: _otpController,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 50,
                            fieldWidth: 45,
                            activeFillColor:
                                isDarkMode ? theme.cardColor : Colors.white,
                            inactiveFillColor: isDarkMode
                                ? theme.cardColor.withAlpha(180)
                                : Colors.grey[100],
                            selectedFillColor:
                                isDarkMode ? theme.cardColor : Colors.white,
                            activeColor: theme.colorScheme.primary,
                            inactiveColor: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[300],
                            selectedColor: theme.colorScheme.primary,
                          ),
                          cursorColor: textColor,
                          textStyle: TextStyle(color: textColor),
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            // Handle OTP changes
                          },
                          beforeTextPaste: (text) {
                            // Allow only numbers
                            return text != null && text.isNumericOnly;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _verifyOtp,
                          child: Text(
                            'Verify Account',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4.0,
                          children: [
                            Text(
                              "Didn't receive the code?",
                              style: GoogleFonts.poppins(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: _canResend ? _resendOtp : null,
                              child: Text(
                                _canResend
                                    ? 'Resend'
                                    : 'Resend in $_resendTime seconds',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: _canResend
                                      ? theme.colorScheme.primary
                                      : isDarkMode
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            Get.offAll(() => const Signin());
                          },
                          child: Text(
                            'Skip and sign in later',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
