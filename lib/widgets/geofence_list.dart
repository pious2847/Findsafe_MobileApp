import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class GeofenceList extends StatelessWidget {
  final List<GeofenceModel> geofences;
  final Function(GeofenceModel) onGeofenceSelected;
  final Function(String) onGeofenceDeleted;
  
  const GeofenceList({
    super.key,
    required this.geofences,
    required this.onGeofenceSelected,
    required this.onGeofenceDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (geofences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.location_slash,
              size: 64,
              color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No geofences found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create a new geofence',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: geofences.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final geofence = geofences[index];
        return _buildGeofenceItem(context, geofence);
      },
    );
  }
  
  Widget _buildGeofenceItem(BuildContext context, GeofenceModel geofence) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppTheme.darkCardColor : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: InkWell(
        onTap: () => onGeofenceSelected(geofence),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(geofence.color).withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getGeofenceTypeIcon(geofence.type),
                    color: Color(geofence.color),
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Geofence info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      geofence.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (geofence.description != null && geofence.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        geofence.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          '${geofence.radius.toInt()}m',
                          Iconsax.ruler,
                        ),
                        const SizedBox(width: 7),
                        _buildInfoChip(
                          context,
                          _getGeofenceTypeText(geofence.type),
                          _getGeofenceTypeIcon(geofence.type),
                        ),
                        const SizedBox(width: 7),
                        _buildInfoChip(
                          context,
                          geofence.isActive ? 'Active' : 'Inactive',
                          geofence.isActive ? Iconsax.tick_circle : Iconsax.close_circle,
                          color: geofence.isActive ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Delete button
              IconButton(
                icon: const Icon(Iconsax.trash),
                color: Colors.red,
                onPressed: () => _showDeleteConfirmation(context, geofence),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(BuildContext context, String label, IconData icon, {Color? color}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, GeofenceModel geofence) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Geofence'),
        content: Text('Are you sure you want to delete "${geofence.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onGeofenceDeleted(geofence.id!);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getGeofenceTypeText(GeofenceType type) {
    switch (type) {
      case GeofenceType.entry:
        return 'Entry';
      case GeofenceType.exit:
        return 'Exit';
      case GeofenceType.dwell:
        return 'Dwell';
      case GeofenceType.both:
        return 'Both';
    }
  }
  
  IconData _getGeofenceTypeIcon(GeofenceType type) {
    switch (type) {
      case GeofenceType.entry:
        return Iconsax.login;
      case GeofenceType.exit:
        return Iconsax.logout;
      case GeofenceType.dwell:
        return Iconsax.timer_1;
      case GeofenceType.both:
        return Iconsax.repeat;
    }
  }
}
