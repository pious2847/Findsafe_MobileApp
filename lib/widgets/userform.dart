import 'package:findsafe/models/User_model.dart';
import 'package:findsafe/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UserForm extends StatefulWidget {
  final UserProfileModel user; // Pass user data to the form

  const UserForm({super.key, required this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final _authProvider = AuthProvider();
  bool _isLoading = false; // Add this line
  late UserProfileModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authProvider.updateUser(context, user.toJson());

        if (!mounted) return;

      } catch (e) {
        if (!mounted) return;
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Info',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Field
                    TextFormField(
                      initialValue: user.username,
                      onChanged: (value) => user.username = value,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Iconsax.user_octagon),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      initialValue: user.email,
                      onChanged: (value) => user.email = value,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Iconsax.message),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      initialValue: user.phone,
                      onChanged: (value) => user.phone = value,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: const Icon(Iconsax.call),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your phone number'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Address Info Fields
                    TextFormField(
                      initialValue: user.addressInfo?.area,
                      onChanged: (value) {
                        user.addressInfo ??= Address();
                        user.addressInfo!.area = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Area',
                        prefixIcon: const Icon(Iconsax.location),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: user.addressInfo?.houseNo,
                      onChanged: (value) {
                        user.addressInfo ??= Address();
                        user.addressInfo!.houseNo = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'House Number',
                        prefixIcon: const Icon(Iconsax.location),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact Fields
                    TextFormField(
                      initialValue: user.emergencyContact?.name,
                      onChanged: (value) {
                        user.emergencyContact ??= EmergencyContact();
                        user.emergencyContact!.name = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact Name',
                        prefixIcon: const Icon(Iconsax.user_tag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: user.emergencyContact?.contact,
                      onChanged: (value) {
                        user.emergencyContact ??= EmergencyContact();
                        user.emergencyContact!.contact = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact Phone',
                        prefixIcon: const Icon(Iconsax.call),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      initialValue: user.password,
                      onChanged: (value) => user.password = value,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Iconsax.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscureText ? Iconsax.eye : Iconsax.eye_slash),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your password' : null,
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _updateUser,
                      child: Text(
                        'Update',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 70,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
