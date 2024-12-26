// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Custom_Icon_Buttons extends StatelessWidget {
  const Custom_Icon_Buttons({
    super.key,
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        onTap();
      },
      icon: Icon(
        icon,
        color: Colors.white, // Icon color
        size: 22, // Icon size
      ),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Slightly rounded corners
        ),
        backgroundColor: Colors.black, // Background color
        fixedSize: const Size(50, 50), // Same width and height
        elevation: 5, // Adds shadow
        padding: EdgeInsets.zero, // Ensures content fits perfectly
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final IconData icon;
  final Function onTap;
  final String label;

  const CustomTextButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon),
      onPressed: () => onTap(),
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
      label: Text(label),
    );
  }
}

class SettingsListTile extends StatelessWidget {
  String label;
  IconData icon;
  Function onTap;
  SettingsListTile({
    super.key,
    required this.label,
    this.icon = Icons.settings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap(),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
