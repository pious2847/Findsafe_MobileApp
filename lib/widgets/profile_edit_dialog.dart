import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

enum ProfileEditType {
  personalInfo,
  address,
  emergencyContact,
  password,
}

class ProfileEditDialog extends StatefulWidget {
  final ProfileEditType editType;
  final Map<String, String> initialValues;
  final Function(Map<String, String>) onSave;

  const ProfileEditDialog({
    super.key,
    required this.editType,
    required this.initialValues,
    required this.onSave,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late Map<String, String> _values;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues);
  }

  String _getTitle() {
    switch (widget.editType) {
      case ProfileEditType.personalInfo:
        return 'Edit Personal Information';
      case ProfileEditType.address:
        return 'Edit Address';
      case ProfileEditType.emergencyContact:
        return 'Edit Emergency Contact';
      case ProfileEditType.password:
        return 'Change Password';
    }
  }

  List<Widget> _buildFields() {
    final List<Widget> fields = [];

    switch (widget.editType) {
      case ProfileEditType.personalInfo:
        fields.addAll([
          _buildTextField(
            label: 'Name',
            key: 'username',
            icon: Iconsax.user,
            validator: (value) => value!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Email',
            key: 'email',
            icon: Iconsax.message,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Phone',
            key: 'phone',
            icon: Iconsax.call,
          ),
        ]);
        break;
      case ProfileEditType.address:
        fields.addAll([
          _buildTextField(
            label: 'Area',
            key: 'area',
            icon: Iconsax.location,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'House Number',
            key: 'houseNo',
            icon: Iconsax.home,
          ),
        ]);
        break;
      case ProfileEditType.emergencyContact:
        fields.addAll([
          _buildTextField(
            label: 'Contact Name',
            key: 'name',
            icon: Iconsax.user_tag,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Contact Phone',
            key: 'phone',
            icon: Iconsax.call,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Relationship',
            key: 'relationship',
            icon: Iconsax.people,
          ),
        ]);
        break;
      case ProfileEditType.password:
        fields.addAll([
          _buildTextField(
            label: 'Current Password',
            key: 'currentPassword',
            icon: Iconsax.lock,
            isPassword: true,
            validator: (value) => value!.isEmpty ? 'Current password is required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'New Password',
            key: 'newPassword',
            icon: Iconsax.lock,
            isPassword: true,
            validator: (value) {
              if (value!.isEmpty) {
                return 'New password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Confirm New Password',
            key: 'confirmPassword',
            icon: Iconsax.lock,
            isPassword: true,
            validator: (value) {
              if (value != _values['newPassword']) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ]);
        break;
    }

    return fields;
  }

  Widget _buildTextField({
    required String label,
    required String key,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: _values[key] ?? '',
      obscureText: isPassword ? _obscureText : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscureText ? Iconsax.eye : Iconsax.eye_slash),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (value) {
        _values[key] = value;
      },
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTitle(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 24),
              ..._buildFields(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(_values);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
