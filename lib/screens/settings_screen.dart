import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import '../widgets/appearance_dialog.dart';
import '../widgets/accent_color_dialog.dart';
import '../utils/theme_manager.dart';
import '../services/auth_service.dart';
import 'voice_selection_screen.dart';
import '../services/user_service.dart';
import '../utils/voices_data.dart';
import 'security_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final UserService _userService = UserService();
  String email = "";
  String name = "";
  String initial = "";
  String _userVoice = "";

  @override
  void initState() {
    super.initState();
    email = user?.email ?? 'unknown@example.com';
    name = user?.displayName ?? email.split('@').first;
    initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    _loadUserVoice();
  }

  Future<void> _loadUserVoice() async {
    if (user != null) {
      final voiceId = await _userService.getUserVoice(user!.uid);
      final voiceMap = voiceList.firstWhere(
        (v) => v['id'] == voiceId,
        orElse: () => {"name": voiceId},
      );
      if (mounted) {
        setState(() {
          _userVoice = voiceMap['name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          children: [
            // Profile Section
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFFFD700),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Edit Profile Button
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
                setState(() {}); // Rebuild to fetch updated name
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Theme.of(context).colorScheme.surface
                    : Colors.white,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                side: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
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
            _buildSectionHeader(context, 'Account'),
            _buildSettingsContainer(context, [
              _buildSettingItem(
                context,
                icon: Icons.person_2_outlined,
                title: 'Name',
                subtitle: name,
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingItem(
                context,
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: email,
              ),
            ]),
            const SizedBox(height: 24),

            // Appearance & Accent
            AnimatedBuilder(
              animation: ThemeManager.instance,
              builder: (context, child) {
                return _buildSettingsContainer(context, [
                  _buildSettingItem(
                    context,
                    icon: Icons.wb_sunny_outlined,
                    title: 'Appearance',
                    subtitle: ThemeManager.instance.themeName,
                    onTap: () => _showAppearanceDialog(context),
                    showDropdownIcon: true,
                  ),
                  const Divider(height: 1, indent: 50),
                  _buildSettingItem(
                    context,
                    icon: Icons.brush_outlined,
                    title: 'Accent color',
                    subtitleWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 14,
                          color: ThemeManager.instance.getAccentColorValue(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ThemeManager.instance.accentColorName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    showDropdownIcon: true,
                    onTap: () => _showAccentColorDialog(context),
                  ),
                ]);
              },
            ),
            const SizedBox(height: 24),

            // General Settings
            _buildSettingsContainer(context, [
              _buildSettingItem(
                context,
                icon: Icons.graphic_eq,
                title: 'Voice',
                subtitle: _userVoice.isEmpty ? 'Loading...' : _userVoice,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceSelectionScreen(),
                    ),
                  );
                  _loadUserVoice();
                },
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingItem(
                context,
                icon: Icons.security_outlined,
                title: 'Security',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecurityScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingItem(
                context,
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Log out
            _buildSettingsContainer(context, [
              _buildSettingItem(
                context,
                icon: Icons.logout,
                title: 'Log out',
                textColor: Colors.red,
                iconColor: Colors.red,
                showArrow: false,
                onTap: () async {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildSettingsContainer(BuildContext context, List<Widget> children) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    Color? textColor,
    Color? iconColor,
    bool showArrow = true,
    bool showDropdownIcon = false,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor =
        textColor ?? Theme.of(context).colorScheme.onSurface;
    final effectiveIconColor =
        iconColor ?? Theme.of(context).colorScheme.onSurface;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: effectiveIconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: effectiveTextColor,
        ),
      ),
      subtitle: subtitleWidget ?? (subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            )
          : null),
      trailing: showDropdownIcon
          ? Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurface,
            )
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

  void _showAccentColorDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AccentColorDialog());
  }
}
