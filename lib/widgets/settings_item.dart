import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showArrow;
  final bool isDestructive;

  const SettingsItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.onTap,
    this.trailing,
    this.showArrow = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDestructive 
        ? Colors.red 
        : (isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor);
    final subtitleColor = isDestructive 
        ? Colors.red.withAlpha(200) 
        : (isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor);
    final iconBgColor = isDestructive 
        ? Colors.red.withAlpha(30) 
        : (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor).withAlpha(30);
    final defaultIconColor = isDestructive 
        ? Colors.red 
        : (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            
            // Trailing widget or arrow
            trailing ?? (showArrow 
              ? Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                )
              : const SizedBox.shrink()
            ),
          ],
        ),
      ),
    );
  }
}
