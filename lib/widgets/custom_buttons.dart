import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final double elevation;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 50,
    this.iconSize = 22,
    this.elevation = 2,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDarkMode ? AppTheme.darkCardColor : AppTheme.primaryColor);
    final fgColor = iconColor ??
        (isDarkMode ? AppTheme.darkTextPrimaryColor : Colors.white);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha((elevation * 10).toInt()),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: tooltip ?? '',
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Ink(
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              width: size,
              height: size,
              child: Icon(
                icon,
                color: fgColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Legacy support for old name
// ignore: camel_case_types
class Custom_Icon_Buttons extends StatelessWidget {
  final IconData icon;
  final Function onTap;

  const Custom_Icon_Buttons({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      icon: icon,
      onTap: () => onTap(),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isOutlined;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.padding,
    this.isOutlined = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor);
    final fgColor = textColor ??
        (isOutlined
            ? (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
            : Colors.white);

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: fgColor,
            side: BorderSide(color: bgColor),
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: elevation,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: elevation,
          );

    final buttonContent = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonContent,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonContent,
          );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    } else if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    } else {
      return button;
    }
  }
}

class CustomTextButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color? textColor;
  final Color? iconColor;

  const CustomTextButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = textColor ??
        (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor);

    return TextButton.icon(
      icon: Icon(icon, color: iconColor ?? color, size: 20),
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      label: Text(label),
    );
  }
}

class SettingsListTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final bool showDivider;

  const SettingsListTile({
    super.key,
    required this.label,
    this.icon = Iconsax.setting_2,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ??
        (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor);

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor,
            ),
          ),
          onTap: () => onTap(),
          trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 18),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70,
            endIndent: 20,
            color:
                isDarkMode ? AppTheme.darkDividerColor : AppTheme.dividerColor,
          ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Color? textColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = textColor ??
        (isDarkMode
            ? AppTheme.darkTextSecondaryColor
            : AppTheme.textSecondaryColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
