import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  const SettingsSwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
    final subtitleColor = isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor;
    final iconBgColor = (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor).withAlpha(30);
    final defaultIconColor = isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon (if provided)
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? defaultIconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Switch or custom trailing widget
          trailing ?? Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
