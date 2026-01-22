import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../widgets/appearance_dialog.dart';
import '../utils/theme_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB), // Light grey background
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          children: [
            // Profile Section
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFFFD700),
              child: Text(
                'CH',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'chamoddulanjana',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'chamoddulanjana',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    // height removed to fit content
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: const EditProfileScreen(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              child: const Text('Edit profile'),
            ),
            const SizedBox(height: 30),

            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingsContainer([
              _buildSettingItem(
                icon: Icons.person_2_outlined,
                title: 'Name',
                subtitle: 'chamod dulanjana',
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingItem(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'chamodperera128@gmail.com',
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingItem(
                icon: Icons.phone_outlined,
                title: 'Phone number',
                subtitle: '+94773810577',
              ),
            ]),
            const SizedBox(height: 24),

            // Appearance & Accent
            AnimatedBuilder(
              animation: ThemeManager.instance,
              builder: (context, child) {
                return _buildSettingsContainer([
                  _buildSettingItem(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Appearance',
                    subtitle: ThemeManager.instance.themeName,
                    onTap: () => _showAppearanceDialog(context),
                  ),
                  const Divider(height: 1, indent: 50),
                  _buildSettingItem(
                    icon: Icons.brush_outlined,
                    title: 'Accent color',
                    subtitle: 'Default',
                    showDropdownIcon: true,
                  ),
                ]);
              },
            ),
            const SizedBox(height: 24),

            // General Settings
            _buildSettingsContainer([
              _buildSettingItem(icon: Icons.graphic_eq, title: 'Voice'),
              const Divider(height: 1, indent: 50),
              _buildSettingItem(
                icon: Icons.security_outlined,
                title: 'Security',
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingItem(icon: Icons.info_outline, title: 'About'),
            ]),
            const SizedBox(height: 24),

            // Log out
            _buildSettingsContainer([
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Log out',
                textColor: Colors.red,
                iconColor: Colors.red,
                showArrow: false,
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color textColor = Colors.black,
    Color iconColor = Colors.black,
    bool showArrow = true,
    bool showDropdownIcon = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          : null,
      trailing: showDropdownIcon
          ? const Icon(Icons.keyboard_arrow_down, color: Colors.black)
          : (showArrow
                ? const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  )
                : null),
      onTap: onTap ?? () {},
    );
  }

  void _showAppearanceDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => AppearanceDialog());
  }
}
