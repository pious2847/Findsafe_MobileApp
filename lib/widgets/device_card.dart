import 'dart:convert';
import 'package:findsafe/models/devices.dart';
import 'package:findsafe/screens/geofence.dart';
import 'package:findsafe/service/websocket.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:findsafe/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DevicesCards extends StatefulWidget {
  final Device phone;
  final Future<void> Function(String) onTap;
  final bool isActive;

  const DevicesCards({
    super.key,
    required this.phone,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<DevicesCards> createState() => _DevicesCardsState();
}

class _DevicesCardsState extends State<DevicesCards> {
  final WebSocketService _webSocketService = WebSocketService();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _webSocketService.connect();
    _isExpanded = widget.isActive;
  }

  Future<void> _sendAlarmCommand(String deviceId) async {
    try {
      final command = jsonEncode({
        'deviceId': deviceId,
        'command': 'play_alarm',
      });
      _webSocketService.sendCommand(command);

      CustomToast.show(
        context: context,
        message: 'Alarm command sent successfully',
        type: ToastType.success,
        position: ToastPosition.top,
      );
    } catch (error) {
      CustomToast.show(
        context: context,
        message: 'Failed to send alarm',
        type: ToastType.error,
        position: ToastPosition.top,
      );
    }
  }

  Future<void> handleAlarmTrigger() async {
    if (widget.phone.id.isNotEmpty) {
      await _sendAlarmCommand(widget.phone.id);
    }
  }

  void _navigateToGeofenceScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeofenceScreen(
          deviceId: widget.phone.id,
          deviceName: widget.phone.devicename,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isActive = widget.phone.mode == 'active';
    final statusColor = isActive ? Colors.green : Colors.redAccent;

    return CustomCard(
      elevation: widget.isActive ? 4 : 2,
      padding: EdgeInsets.zero,
      borderRadius: 16,
      color: widget.isActive
          ? (isDarkMode
              ? AppTheme.darkPrimaryColor.withAlpha(30)
              : AppTheme.primaryColor.withAlpha(30))
          : null,
      child: Column(
        children: [
          // Device info section
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Device image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: NetworkImage(widget.phone.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Device info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.phone.devicename,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode
                                ? AppTheme.darkTextPrimaryColor
                                : AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.phone.mode.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: 20,
                    color: isDarkMode
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Actions section
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _isExpanded
                ? Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton(
                              icon: Iconsax.location,
                              label: 'Locate',
                              onTap: () => widget.onTap(widget.phone.id),
                              color: isDarkMode
                                  ? AppTheme.darkPrimaryColor
                                  : AppTheme.primaryColor,
                            ),
                            _buildActionButton(
                              icon: Iconsax.music_play,
                              label: 'Alarm',
                              onTap: handleAlarmTrigger,
                              color: isDarkMode
                                  ? AppTheme.darkSecondaryColor
                                  : AppTheme.secondaryColor,
                            ),
                            _buildActionButton(
                              icon: Iconsax.radar,
                              label: 'Geofence',
                              onTap: () => _navigateToGeofenceScreen(context),
                              color: isDarkMode
                                  ? AppTheme.darkAccentColor
                                  : AppTheme.accentColor,
                            ),
                            _buildActionButton(
                              icon: Iconsax.security_safe,
                              label: 'Secure',
                              onTap: () {},
                              color: Colors.purple,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Locate button
                        CustomButton(
                          text: 'Locate Device',
                          icon: Iconsax.map,
                          onPressed: () => widget.onTap(widget.phone.id),
                          isFullWidth: true,
                          elevation: 2,
                        ),

                        const SizedBox(height: 12),

                        // Geofence button
                        CustomButton(
                          text: 'Manage Geofences',
                          icon: Iconsax.radar,
                          onPressed: () => _navigateToGeofenceScreen(context),
                          isFullWidth: true,
                          elevation: 2,
                          backgroundColor: isDarkMode
                              ? AppTheme.darkAccentColor
                              : AppTheme.accentColor,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
