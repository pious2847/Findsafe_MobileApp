import 'package:findsafe/screens/home.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isMenuOpen = false;
  final GlobalKey _menuKey = GlobalKey(); // Add a GlobalKey

  List<Widget> pages = [
    const Home(),
    const Center(child: Text("Location Page")),
    Container(), // Placeholder
  ];

  @override
  void dispose() {
    _pageController.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: pages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavigationItem(
                    index: 0,
                    icon: Iconsax.home_hashtag,
                    label: 'Home',
                  ),
                  _buildNavigationItem(
                    index: 1,
                    icon: Iconsax.location,
                    label: 'Location',
                  ),
                  _buildMenuNavigationItem(index: 2, key: _menuKey),
                ],
              ),
            ),
          ),
          if (_isMenuOpen) _buildMenuOverlay(context),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
                color:
                    _selectedIndex == index ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(30)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    Icon(
                      icon,
                      color:
                          _selectedIndex == index ? Colors.black : Colors.white,
                      size: 20,
                    ),
                    if (_selectedIndex == index)
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: _selectedIndex == index
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuNavigationItem({
    required int index,
    required GlobalKey key,
  }) {
    return SizedBox(
      height: 53,
      key: key,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(25),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Icon(
            Iconsax.category,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOverlay(BuildContext context) {
    final RenderBox? renderBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset position =
        renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    // 56 for height , 32 for the padding

    final double top =
        position.dy - (168); // the height of the menu + a bit of padding
    final double left = position.dx - (70); // shifts the menu to the left
    return Positioned(
        top: top,
        left: left,
        child: Material(
          color: Colors.transparent, // Ensure the overlay is transparent
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26, // Shadow color
                      blurRadius: 8, // How blurry the shadow is
                      spreadRadius: 2, // How much the shadow expands (optional)
                      offset: Offset(2, 2), // Offset from the box: (x,y)
                    ),
                  ]),
              width: 140,
              height: 150,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Iconsax.user_octagon),
                    title: const Text('Profile'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile')));
                      _toggleMenu();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('settings')));
                      _toggleMenu();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('logout')));
                      _toggleMenu();
                    },
                  ),
                ],
              )),
        ));
  }
}
