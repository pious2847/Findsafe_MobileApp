import 'package:findsafe/controllers/theme_controller.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
    this.onBackPressed,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isDarkMode = themeController.isDarkMode;
    
    final Color bgColor = backgroundColor ?? 
        (isDarkMode ? AppTheme.darkCardColor : Colors.white);
    final Color fgColor = foregroundColor ?? 
        (isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor);
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: fgColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: showBackButton && automaticallyImplyLeading
          ? leading ?? IconButton(
              icon: Icon(
                Iconsax.arrow_left,
                color: fgColor,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 8),
            ]
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isDarkMode = themeController.isDarkMode;
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        style: TextStyle(
          color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Iconsax.close_circle,
                    color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) {
                      onClear!();
                    }
                    if (onChanged != null) {
                      onChanged!('');
                    }
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
