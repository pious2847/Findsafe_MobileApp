// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';


class Custom_Elevated_Buttons extends StatelessWidget {
  const Custom_Elevated_Buttons({
    super.key, required this.icon, required this.onTap,
  });
  final IconData icon;
  final Function onTap;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // Slightly rounded corners
        ),
        backgroundColor: Colors.black, // Background color
        fixedSize: const Size(30, 50), // Same width and height
        elevation: 5, // Adds shadow
        padding: EdgeInsets.zero, // Ensures content fits perfectly
      ),
      child:  Icon(
        icon, 
        color: Colors.white, // Icon color
        size: 22, // Icon size
      ),
    );
  }
}
