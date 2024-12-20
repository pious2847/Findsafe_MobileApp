// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';


class Custom_Icon_Buttons extends StatelessWidget {
  const Custom_Icon_Buttons({
    super.key, required this.icon, required this.onTap,
  });
  final IconData icon;
  final Function onTap;
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        onTap();
      },
      icon:  Icon(
        icon, 
        color: Colors.white, // Icon color
        size: 22, // Icon size
      ),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // Slightly rounded corners
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
      label:  Text(label),
    );
  }
}
