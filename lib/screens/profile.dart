import 'package:findsafe/constants/custom_bottom_nav.dart';
import 'package:findsafe/models/User_model.dart';
import 'package:findsafe/service/auth.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:findsafe/widgets/profile_edit_dialog.dart';
import 'package:findsafe/widgets/profile_header.dart';
import 'package:findsafe/widgets/profile_info_section.dart';
import 'package:findsafe/widgets/profile_stats.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfileModel? user;
  bool isLoading = true;
  bool isRefreshing = false;
  String? error;
  final _authProvider = AuthProvider();
  final _deviceApiService = DeviceApiService();
  int deviceCount = 0;
  int activeDevices = 0;
  String? avatarUrl;

  Future<void> _fetchUserProfile({bool refresh = false}) async {
    setState(() {
      if (refresh) {
        isRefreshing = true;
      } else {
        isLoading = true;
      }
      error = null;
    });

    try {
      final response = await _authProvider.fetchUser(context);
      if (response == null) {
        setState(() {
          error = 'Failed to load profile. Please try again.';
          isLoading = false;
          isRefreshing = false;
        });
        return;
      }

      // Fetch device count
      if (response.devices != null && response.devices!.isNotEmpty) {
        try {
          final devices = await _deviceApiService.fetchDevices(response.id!);
          deviceCount = devices.length;
          activeDevices =
              devices.where((device) => device.mode == 'active').length;
        } catch (e) {
          debugPrint('Error fetching devices: $e');
        }
      }

      setState(() {
        user = response;
        isLoading = false;
        isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load profile. Please try again.';
        isLoading = false;
        isRefreshing = false;
      });
      debugPrint('Error fetching user profile: $e');
    }
  }

  Future<void> _updateUserProfile(
      Map<String, String> values, ProfileEditType type) async {
    if (user == null) return;

    try {
      // Create a copy of the user to update
      final updatedUser = UserProfileModel(
        id: user!.id,
        username: user!.username,
        email: user!.email,
        password: user!.password,
        phone: user!.phone,
        addressInfo: user!.addressInfo,
        emergencyContact: user!.emergencyContact,
        verified: user!.verified,
        devices: user!.devices,
      );

      // Update the user based on the edit type
      switch (type) {
        case ProfileEditType.personalInfo:
          updatedUser.username = values['username'] ?? updatedUser.username;
          updatedUser.email = values['email'] ?? updatedUser.email;
          updatedUser.phone = values['phone'] ?? updatedUser.phone;
          break;
        case ProfileEditType.address:
          updatedUser.addressInfo ??= Address();
          updatedUser.addressInfo!.area = values['area'];
          updatedUser.addressInfo!.houseNo = values['houseNo'];
          break;
        case ProfileEditType.emergencyContact:
          updatedUser.emergencyContact ??= EmergencyContact();
          updatedUser.emergencyContact!.name = values['name'];
          updatedUser.emergencyContact!.phone = values['phone'];
          updatedUser.emergencyContact!.relationship = values['relationship'];
          break;
        case ProfileEditType.password:
          // For password, we would typically need to verify the current password
          // and then update with the new password
          updatedUser.password = values['newPassword'] ?? updatedUser.password;
          break;
      }

      // Update the user in the backend
      await _authProvider.updateUser(context, updatedUser.toJson());

      // Refresh the user profile
      await _fetchUserProfile(refresh: true);
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Failed to update profile. Please try again.',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error updating user profile: $e');
    }
  }

  void _pickImage() {
    // Show a toast message for now
    CustomToast.show(
      context: context,
      message: 'Profile picture upload functionality coming soon!',
      type: ToastType.info,
      position: ToastPosition.top,
    );
  }

  void _showEditDialog(ProfileEditType type) {
    if (user == null) return;

    Map<String, String> initialValues = {};

    switch (type) {
      case ProfileEditType.personalInfo:
        initialValues = {
          'username': user!.username,
          'email': user!.email,
          'phone': user!.phone ?? '',
        };
        break;
      case ProfileEditType.address:
        initialValues = {
          'area': user!.addressInfo?.area ?? '',
          'houseNo': user!.addressInfo?.houseNo ?? '',
        };
        break;
      case ProfileEditType.emergencyContact:
        initialValues = {
          'name': user!.emergencyContact?.name ?? '',
          'phone': user!.emergencyContact?.phone ?? '',
          'relationship': user!.emergencyContact?.relationship ?? '',
        };
        break;
      case ProfileEditType.password:
        initialValues = {
          'currentPassword': '',
          'newPassword': '',
          'confirmPassword': '',
        };
        break;
    }

    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        editType: type,
        initialValues: initialValues,
        onSave: (values) => _updateUserProfile(values, type),
      ),
    );
  }

  void _handleLogout() async {
    try {
      await _authProvider.logout(context);
      Get.offAll(() => const CustomBottomNav());
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Failed to logout. Please try again.',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error logging out: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
          showBackButton: false,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Profile',
          showBackButton: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error!,
                style: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Retry',
                icon: Iconsax.refresh,
                onPressed: _fetchUserProfile,
              ),
            ],
          ),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Profile',
          showBackButton: false,
        ),
        body: Center(
          child: Text(
            'No user data available',
            style: TextStyle(
              color: isDarkMode
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _fetchUserProfile(refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with avatar and basic info
              ProfileHeader(
                user: user!,
                onEditAvatar: _pickImage,
                avatarUrl: avatarUrl,
              ),

              const SizedBox(height: 16),

              // Device stats
              ProfileStats(
                deviceCount: deviceCount,
                activeDevices: activeDevices,
                onDevicesTap: () {
                  // Navigate to home tab
                  Get.offAll(() => const CustomBottomNav());
                },
              ),

              // Personal information section
              ProfileInfoSection(
                title: 'Personal Information',
                onEdit: () => _showEditDialog(ProfileEditType.personalInfo),
                items: [
                  ProfileInfoItem(
                    icon: Iconsax.user,
                    label: 'Name',
                    value: user!.username,
                  ),
                  ProfileInfoItem(
                    icon: Iconsax.message,
                    label: 'Email',
                    value: user!.email,
                  ),
                  ProfileInfoItem(
                    icon: Iconsax.call,
                    label: 'Phone',
                    value: user!.phone ?? '',
                  ),
                ],
              ),

              // Address section
              ProfileInfoSection(
                title: 'Address',
                onEdit: () => _showEditDialog(ProfileEditType.address),
                items: [
                  ProfileInfoItem(
                    icon: Iconsax.location,
                    label: 'Area',
                    value: user!.addressInfo?.area ?? '',
                  ),
                  ProfileInfoItem(
                    icon: Iconsax.home,
                    label: 'House Number',
                    value: user!.addressInfo?.houseNo ?? '',
                  ),
                ],
              ),

              // Emergency contact section
              ProfileInfoSection(
                title: 'Emergency Contact',
                onEdit: () => _showEditDialog(ProfileEditType.emergencyContact),
                items: [
                  ProfileInfoItem(
                    icon: Iconsax.user_tag,
                    label: 'Name',
                    value: user!.emergencyContact?.name ?? '',
                  ),
                  ProfileInfoItem(
                    icon: Iconsax.call,
                    label: 'Phone',
                    value: user!.emergencyContact?.phone ?? '',
                  ),
                  ProfileInfoItem(
                    icon: Iconsax.people,
                    label: 'Relationship',
                    value: user!.emergencyContact?.relationship ?? '',
                  ),
                ],
              ),

              // Security section
              ProfileInfoSection(
                title: 'Security',
                onEdit: () => _showEditDialog(ProfileEditType.password),
                items: const [
                  ProfileInfoItem(
                    icon: Iconsax.lock,
                    label: 'Password',
                    value: '••••••••',
                  ),
                ],
              ),

              // Logout button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: 'Logout',
                  icon: Iconsax.logout,
                  onPressed: _handleLogout,
                  isFullWidth: true,
                  backgroundColor: isDarkMode ? Colors.red[800] : Colors.red,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
