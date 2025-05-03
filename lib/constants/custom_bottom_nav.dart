import 'package:findsafe/controllers/security_controller.dart';
import 'package:findsafe/controllers/theme_controller.dart';
import 'package:findsafe/screens/home.dart';
import 'package:findsafe/screens/location.dart';
import 'package:findsafe/screens/profile.dart';
import 'package:findsafe/screens/security.dart';
import 'package:findsafe/screens/settings.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  // Add a method to navigate to a specific tab
  void navigateToTab(int index) {
    // Find the current state and call the _onItemTapped method
    final state = Get.find<_CustomBottomNavState>(tag: 'bottomNavState');
    state._onItemTapped(index);
  }

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isMenuOpen = false;
  final GlobalKey _menuKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // Register this state with Get for navigation
    Get.put(this, tag: 'bottomNavState');

    // Initialize security controller if needed
    if (!Get.isRegistered<SecurityController>()) {
      Get.put(SecurityController());
    }

    pages = [
      const Home(),
      const LocationHistory(),
      Container(), // Placeholder
      const ProfilePage(),
      SettingsPage(onPageChanged: (index) => _onItemTapped(index)),
      const AuthWrapper(
        reason: 'Authentication required to access security settings',
        child: SecurityScreen(),
      ),
    ];

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _toggleMenu();
      return;
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isDarkMode = themeController.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: pages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppTheme.darkCardColor : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51), // 0.2 opacity
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavigationItem(
                      index: 0,
                      icon: Iconsax.home,
                      activeIcon: Iconsax.home_15,
                      label: 'Home',
                      isDarkMode: isDarkMode,
                    ),
                    _buildNavigationItem(
                      index: 1,
                      icon: Iconsax.location,
                      activeIcon: Iconsax.location5,
                      label: 'Location',
                      isDarkMode: isDarkMode,
                    ),
                    _buildCenterButton(isDarkMode),
                    _buildNavigationItem(
                      index: 3,
                      icon: Iconsax.user,
                      activeIcon: Iconsax.user_cirlce_add,
                      label: 'Profile',
                      isDarkMode: isDarkMode,
                    ),
                    _buildNavigationItem(
                      index: 4,
                      icon: Iconsax.setting,
                      activeIcon: Iconsax.setting_3,
                      label: 'Settings',
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isMenuOpen) _buildMenuOverlay(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedIndex == index;
    final Color activeColor = isDarkMode ? Colors.white : Colors.white;
    final Color inactiveColor = isDarkMode ? Colors.white70 : Colors.white70;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                  ? AppTheme.darkPrimaryColor.withAlpha(51) // 0.2 opacity
                  : Colors.white.withAlpha(51)) // 0.2 opacity
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(bool isDarkMode) {
    return Container(
      key: _menuKey,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? AppTheme.darkAccentColor : AppTheme.accentColor,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? AppTheme.darkAccentColor.withAlpha(77) // 0.3 opacity
                : AppTheme.accentColor.withAlpha(77), // 0.3 opacity
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleMenu,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: RotationTransition(
              turns: _rotationAnimation,
              child: const Icon(
                Iconsax.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOverlay(BuildContext context, bool isDarkMode) {
    final RenderBox? renderBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset position =
        renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final Size size = renderBox?.size ?? Size.zero;

    final double centerX = position.dx + (size.width / 2);
    const double menuWidth = 180.0;
    final double left = centerX - (menuWidth / 2);
    final double top = position.dy - 200; // Position above the button

    return Positioned(
      top: top,
      left: left,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: menuWidth,
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51), // 0.2 opacity
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                icon: Iconsax.shield_security,
                title: 'Security',
                onTap: () {
                  _onItemTapped(5);
                  _toggleMenu();
                },
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildMenuItem(
                icon: Iconsax.notification,
                title: 'Notifications',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon')),
                  );
                  _toggleMenu();
                },
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildMenuItem(
                icon: Iconsax.moon,
                title: isDarkMode ? 'Light Mode' : 'Dark Mode',
                onTap: () {
                  Get.find<ThemeController>().toggleTheme();
                  _toggleMenu();
                },
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildMenuItem(
                icon: Iconsax.logout,
                title: 'Logout',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging out...')),
                  );
                  _toggleMenu();
                },
                isDarkMode: isDarkMode,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isDestructive = false,
  }) {
    final Color textColor = isDestructive
        ? Colors.red
        : (isDarkMode ? Colors.white : AppTheme.textPrimaryColor);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
