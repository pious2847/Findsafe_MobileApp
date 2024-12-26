import 'dart:ui';

import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingsPage extends StatelessWidget {
final void Function(int) onPageChanged; 
   SettingsPage({super.key, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Image.asset(
                      'assets/images/banner.png',
                      // height: 50,
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.grey.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          flex: 2,
                          child: Text(
                            "Get Unlimited Access to Everything",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              // Go Pro button action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Go Pro",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
            const SectionHeader(title: 'General'),
            const Divider(),
            SettingsListTile(label: 'Security', onTap: (){onPageChanged(5);}, icon: Iconsax.shield_security2,),
            const Divider(),
            SettingsListTile(label: 'Language', onTap: (){}, icon: Iconsax.language_square,),
            const Divider(),
            SettingsListTile(label: 'Theme', onTap: (){}, icon: Iconsax.sun,),
            const Divider(),
            const SectionHeader(title: 'About App'),
            const Divider(),
            SettingsListTile(label: 'Privacy Policy', onTap: (){}, icon: Iconsax.shield_tick,),
            const Divider(),
            SettingsListTile(label: 'Terms of Service', onTap: (){}, icon: Iconsax.information,),
            const Divider(),
            SettingsListTile(label: 'Rate Us', onTap: (){}, icon: Iconsax.star,),
            const Divider(),
            SizedBox(height: MediaQuery.of(context).size.height*0.1,)
      
        ],
      ),
    );
  }
}

