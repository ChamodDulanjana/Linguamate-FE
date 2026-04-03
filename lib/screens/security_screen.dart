import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isTwoFactorEnabled = false;

  void _sendPasswordReset() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset email sent to ${user.email}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and you will lose all your learning progress.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action restricted in this version.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSectionHeader('Authentication'),
            _buildSettingsContainer([
              ListTile(
                leading: const Icon(Icons.password),
                title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Send a password reset link to your email'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: _sendPasswordReset,
              ),
              const Divider(height: 1, indent: 50),
              SwitchListTile(
                secondary: const Icon(Icons.security),
                title: const Text('Two-Factor Authentication', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Add an extra layer of security'),
                value: _isTwoFactorEnabled,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (bool value) {
                  setState(() {
                    _isTwoFactorEnabled = value;
                  });
                },
              ),
            ], isDarkMode),
            
            const SizedBox(height: 30),
            _buildSectionHeader('Device Management'),
            _buildSettingsContainer([
              ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('Active Sessions', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Manage devices logged into your account'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No other active sessions found.')),
                  );
                },
              ),
            ], isDarkMode),
            
            const SizedBox(height: 30),
            _buildSectionHeader('Danger Zone'),
            _buildSettingsContainer([
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                subtitle: const Text('Permanently remove your data'),
                onTap: _confirmDeleteAccount,
              ),
            ], isDarkMode),
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
