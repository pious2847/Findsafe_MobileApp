import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onMyLocationPressed;
  final VoidCallback onDeviceLocationPressed;
  final VoidCallback onToggleDeviceSheet;
  final VoidCallback? onToggleGeofences;
  final bool isDeviceSheetOpen;
  final bool hasDeviceLocation;
  final bool isMapTypeHybrid;
  final bool showGeofences;
  final VoidCallback onToggleMapType;

  const MapControls({
    super.key,
    required this.onMyLocationPressed,
    required this.onDeviceLocationPressed,
    required this.onToggleDeviceSheet,
    this.onToggleGeofences,
    required this.isDeviceSheetOpen,
    this.hasDeviceLocation = false,
    required this.isMapTypeHybrid,
    this.showGeofences = false,
    required this.onToggleMapType,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Map type toggle
          CustomIconButton(
            icon: isMapTypeHybrid ? Iconsax.map : Iconsax.map_1,
            onTap: onToggleMapType,
            backgroundColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
            iconColor:
                isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
            tooltip: 'Toggle map type',
          ),

          const SizedBox(height: 16),

          // Geofence toggle button
          if (onToggleGeofences != null)
            CustomIconButton(
              icon: showGeofences ? Iconsax.radar : Iconsax.radar_1,
              onTap: onToggleGeofences!,
              backgroundColor:
                  isDarkMode ? AppTheme.darkCardColor : Colors.white,
              iconColor: showGeofences
                  ? (isDarkMode
                      ? AppTheme.darkAccentColor
                      : AppTheme.accentColor)
                  : (isDarkMode
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor),
              tooltip: showGeofences ? 'Hide geofences' : 'Show geofences',
            ),

          if (onToggleGeofences != null) const SizedBox(height: 16),

          // My location button
          if (!isDeviceSheetOpen)
            CustomIconButton(
              icon: Iconsax.gps,
              onTap: onMyLocationPressed,
              backgroundColor:
                  isDarkMode ? AppTheme.darkCardColor : Colors.white,
              iconColor: isDarkMode
                  ? AppTheme.darkPrimaryColor
                  : AppTheme.primaryColor,
              tooltip: 'My location',
            ),

          if (!isDeviceSheetOpen && hasDeviceLocation)
            const SizedBox(height: 16),

          // Device location button
          if (!isDeviceSheetOpen && hasDeviceLocation)
            CustomIconButton(
              icon: Iconsax.location,
              onTap: onDeviceLocationPressed,
              backgroundColor:
                  isDarkMode ? AppTheme.darkCardColor : Colors.white,
              iconColor: isDarkMode
                  ? AppTheme.darkPrimaryColor
                  : AppTheme.primaryColor,
              tooltip: 'Device location',
            ),

          const SizedBox(height: 16),

          // Toggle device sheet button
          CustomIconButton(
            icon: isDeviceSheetOpen ? Iconsax.arrow_down_2 : Iconsax.arrow_up_3,
            onTap: onToggleDeviceSheet,
            backgroundColor:
                isDarkMode ? AppTheme.darkAccentColor : AppTheme.accentColor,
            iconColor: Colors.white,
            tooltip: isDeviceSheetOpen ? 'Hide devices' : 'Show devices',
          ),
        ],
      ),
    );
  }
}
