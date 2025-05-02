import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

class GeofenceEditor extends StatefulWidget {
  final GeofenceModel? initialGeofence;
  final String deviceId;
  final Function(GeofenceModel) onSave;
  final VoidCallback onCancel;
  
  const GeofenceEditor({
    super.key,
    this.initialGeofence,
    required this.deviceId,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<GeofenceEditor> createState() => _GeofenceEditorState();
}

class _GeofenceEditorState extends State<GeofenceEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _radiusController;
  
  late LatLng _center;
  late double _radius;
  late GeofenceType _type;
  late int _color;
  
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with values from the initial geofence or defaults
    _nameController = TextEditingController(text: widget.initialGeofence?.name ?? 'New Geofence');
    _descriptionController = TextEditingController(text: widget.initialGeofence?.description ?? '');
    _center = widget.initialGeofence?.center ?? const LatLng(0, 0);
    _radius = widget.initialGeofence?.radius ?? 100.0;
    _radiusController = TextEditingController(text: _radius.toStringAsFixed(0));
    _type = widget.initialGeofence?.type ?? GeofenceType.both;
    _color = widget.initialGeofence?.color ?? _colorOptions[0].value;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _radiusController.dispose();
    super.dispose();
  }
  
  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final geofence = GeofenceModel(
        id: widget.initialGeofence?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        center: _center,
        radius: _radius,
        type: _type,
        deviceId: widget.deviceId,
        isActive: widget.initialGeofence?.isActive ?? true,
        createdAt: widget.initialGeofence?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        color: _color,
      );
      
      widget.onSave(geofence);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialGeofence != null ? 'Edit Geofence' : 'New Geofence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: widget.onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Iconsax.edit),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Iconsax.document_text),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Radius field
            TextFormField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: 'Radius (meters)',
                prefixIcon: Icon(Iconsax.ruler),
                suffixText: 'm',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a radius';
                }
                final radius = double.tryParse(value);
                if (radius == null || radius <= 0) {
                  return 'Please enter a valid radius';
                }
                return null;
              },
              onChanged: (value) {
                final radius = double.tryParse(value);
                if (radius != null && radius > 0) {
                  setState(() {
                    _radius = radius;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Geofence type
            Text(
              'Geofence Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Type selection
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip(GeofenceType.entry, 'Entry', Iconsax.login),
                _buildTypeChip(GeofenceType.exit, 'Exit', Iconsax.logout),
                _buildTypeChip(GeofenceType.dwell, 'Dwell', Iconsax.timer_1),
                _buildTypeChip(GeofenceType.both, 'Both', Iconsax.repeat),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Color selection
            Text(
              'Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Color options
            Wrap(
              spacing: 8,
              children: _colorOptions.map((color) => _buildColorChip(color)).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: 'Save',
                  icon: Iconsax.tick_square,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeChip(GeofenceType type, String label, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _type == type;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor),
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _type = type;
          });
        }
      },
      backgroundColor: isDarkMode ? AppTheme.darkCardColor : Colors.grey[200],
      selectedColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor),
      ),
    );
  }
  
  Widget _buildColorChip(Color color) {
    final isSelected = _color == color.value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = color.value;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Iconsax.tick_circle,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}
