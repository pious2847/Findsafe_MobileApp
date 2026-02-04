import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool showDividers;

  const SettingsCard({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppTheme.darkCardColor : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
    final dividerColor = isDarkMode ? AppTheme.darkDividerColor : AppTheme.dividerColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // Card with settings
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: cardColor,
            child: Padding(
              padding: padding,
              child: Column(
                children: _buildChildrenWithDividers(children, showDividers, dividerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(List<Widget> children, bool showDividers, Color dividerColor) {
    if (!showDividers || children.length <= 1) {
      return children;
    }

    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Divider(color: dividerColor, height: 1));
      }
    }
    return result;
  }
}
