import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
    final secondaryTextColor = isDarkMode 
        ? AppTheme.darkTextSecondaryColor 
        : AppTheme.textSecondaryColor;
    final cardColor = isDarkMode 
        ? AppTheme.darkCardColor 
        : AppTheme.cardColor;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'About FindSafe',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App logo and version
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FindSafe',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0 (Build 100)',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // App description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'FindSafe is a device tracking application that helps you keep track of your devices and loved ones. With advanced security features and real-time location tracking, FindSafe provides peace of mind in an increasingly connected world.',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        Iconsax.location,
                        'Real-time Location Tracking',
                        'Track your devices with precision in real-time',
                      ),
                      _buildFeatureItem(
                        context,
                        Iconsax.shield_security,
                        'Advanced Security',
                        'Protect your devices with remote lock and wipe',
                      ),
                      _buildFeatureItem(
                        context,
                        Iconsax.notification,
                        'Instant Alerts',
                        'Get notified when your devices enter or leave designated areas',
                      ),
                      _buildFeatureItem(
                        context,
                        Iconsax.chart,
                        'Location History',
                        'View detailed history of your device locations',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Contact and links
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect With Us',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLinkItem(
                        context,
                        Iconsax.global,
                        'Website',
                        'Visit our website',
                        () => _launchURL(context, 'https://findsafe.com'),
                      ),
                      _buildLinkItem(
                        context,
                        Iconsax.message,
                        'Support',
                        'Get help and support',
                        () => _launchURL(context, 'https://findsafe.com/support'),
                      ),
                      _buildLinkItem(
                        context,
                        Iconsax.shield_tick,
                        'Privacy Policy',
                        'Read our privacy policy',
                        () => _launchURL(context, 'https://findsafe.com/privacy-policy'),
                      ),
                      _buildLinkItem(
                        context,
                        Iconsax.document_text,
                        'Terms of Service',
                        'Read our terms of service',
                        () => _launchURL(context, 'https://findsafe.com/terms-of-service'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Copyright
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© 2025 FindSafe. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode 
        ? AppTheme.darkTextPrimaryColor 
        : AppTheme.textPrimaryColor;
    final secondaryTextColor = isDarkMode 
        ? AppTheme.darkTextSecondaryColor 
        : AppTheme.textSecondaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLinkItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode 
        ? AppTheme.darkTextPrimaryColor 
        : AppTheme.textPrimaryColor;
    final secondaryTextColor = isDarkMode 
        ? AppTheme.darkTextSecondaryColor 
        : AppTheme.textSecondaryColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
