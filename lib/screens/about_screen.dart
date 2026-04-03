import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final String _version = '1.0.0';
  final String _buildNumber = '1';
  final _isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 100,
                height: 100,
                // decoration: BoxDecoration(
                //   color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                //   borderRadius: BorderRadius.circular(20),
                // ),
                child: isDarkMode
                  ? Image.asset('assets/images/linguamate_light_logo.png', width: 120, height: 120)
                  : Image.asset('assets/images/linguamate_logo.png', width: 120, height: 120),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Linguamate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version $_version ($_buildNumber)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            _buildSettingsContainer([
              if (_isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen()));
                  },
                ),
                const Divider(height: 1, indent: 50),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen()));
                  },
                ),
              ],
              const Divider(height: 1, indent: 50),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Open Source Licenses', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Linguamate',
                    applicationVersion: _version,
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: isDarkMode
                          ? Image.asset('assets/images/linguamate_light_logo.png', width: 80, height: 80)
                          : Image.asset('assets/images/linguamate_logo.png', width: 80, height: 80),
                    ),
                  );
                },
              ),
            ], isDarkMode),

            const SizedBox(height: 40),
            Text(
              '© 2026 Linguamate. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Made with ❤️ by Chamod',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      child: Column(children: children),
    );
  }
}
