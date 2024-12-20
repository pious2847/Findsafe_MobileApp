import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(backgroundImage: AssetImage('assets/images/avatar1.jpg'),)
              ],
            ),
          )
        ],
      ),
    );
  }
}