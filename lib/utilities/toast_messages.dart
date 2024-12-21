import 'package:flutter/material.dart';

class CustomToast {
  static OverlayEntry? _currentToast;

  /// Shows a custom toast message with extensive customization options
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    ToastType type = ToastType.info,
    Widget? customIcon,
  }) {
    // Remove any existing toast
    _currentToast?.remove();

    // Determine color and icon based on toast type
    Color backgroundColor;
    Color textColor;
    IconData? iconData;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green[600]!;
        textColor = Colors.white;
        iconData = Icons.check_circle_outline;
        break;
      case ToastType.error:
        backgroundColor = Colors.red[600]!;
        textColor = Colors.white;
        iconData = Icons.error_outline;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange[600]!;
        textColor = Colors.white;
        iconData = Icons.warning_amber_outlined;
        break;
      case ToastType.info:
        backgroundColor = Colors.blue[600]!;
        textColor = Colors.white;
        iconData = Icons.info_outline;
        break;
    }

    // Create the overlay entry
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        bottom: position == ToastPosition.bottom ? 50 : null,
        top: position == ToastPosition.top ? 50 : null,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom or default icon
                    customIcon ?? Icon(
                      iconData,
                      color: textColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_currentToast!);

    // Remove the toast after specified duration
    Future.delayed(duration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

  /// Dismiss the current toast if it's visible
  static void dismiss() {
    _currentToast?.remove();
    _currentToast = null;
  }
}

/// Enum to define different types of toasts
enum ToastPosition {
  top,
  bottom,
}

/// Enum to define toast types with predefined styles
enum ToastType {
  success,
  error,
  warning,
  info,
}