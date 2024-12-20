import 'package:findsafe/models/User_model.dart';
import 'package:findsafe/service/auth.dart';
import 'package:findsafe/widgets/userform.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfileModel? user;
  bool isLoading = true;
  String? error;
  final _authProvider = AuthProvider();

  Future<void> _fetchUserProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _authProvider.fetchUser(context);
      if (response == null) {
        setState(() {
          error = 'Failed to load profile. Please try again.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        user = response;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        error = 'Failed to load profile. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!),
            ElevatedButton(
              onPressed: _fetchUserProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              child: Center(
                child: Column(
                  children: [
                    // TODO: Replace with actual user avatar
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/avatar1.jpg'),
                      radius: 100,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user!.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user!.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: user!.verified? Colors.green[400] : Colors.red[400],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child:  Padding(
                        padding: const EdgeInsets.all(3),
                        child: Text(user!.verified ? "Verified" : "Unverified",),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          UserForm(user: user!),
        ],
      ),
    );
  }
}
