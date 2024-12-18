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
