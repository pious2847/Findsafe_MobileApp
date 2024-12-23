import 'dart:convert';
import 'package:findsafe/models/devices.dart';
import 'package:findsafe/service/websocket.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
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
  // IOWebSocketChannel? _channel;
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _webSocketService.connect();
  }

  // @override
  // void dispose() {
  //   _webSocketService.disconnect();
  //   _channel?.sink.close();
  //   super.dispose();
  // }

  Future<void> _sendAlarmCommand(String deviceId) async {
    try {
      final command = jsonEncode({
        'deviceId': deviceId,
        'command': 'play_alarm',
      });
      _webSocketService.sendCommand(command);
      // await _ApiServics.sendAlarmCommand(deviceId);
      CustomToast.show(
          context: context,
          message: 'Alarm command sent successfully',
          type: ToastType.success,
          position: ToastPosition.top);
    } catch (error) {
      CustomToast.show(
          context: context,
          message: 'Failed to send alarm',
          type: ToastType.error,
          position: ToastPosition.top);
    }
  }

  Future<void> handleAlarmTrigger() async {
    if (widget.phone.id.isNotEmpty) {
      await _sendAlarmCommand(widget.phone.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image(
          image: NetworkImage(widget.phone.image),
        ),
      ),
      title: Text(
        widget.phone.devicename,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        widget.phone.mode,
        style: TextStyle(
          color:
              widget.phone.mode == 'active' ? Colors.green : Colors.redAccent,
        ),
      ),
      initiallyExpanded: widget.isActive,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTextButton(
                    icon: Iconsax.music_play,
                    onTap: () {
                      handleAlarmTrigger();
                    },
                    label: 'Play Alarm'),
                CustomTextButton(
                    icon: Iconsax.security_safe,
                    onTap: () {},
                    label: 'Secure Device'),
                TextButton.icon(
                  icon: const Icon(Iconsax.map),
                  onPressed: () => widget.onTap(widget.phone.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  label: const Text('Locate Device'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
