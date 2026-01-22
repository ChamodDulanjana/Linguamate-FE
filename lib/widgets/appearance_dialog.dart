import 'package:flutter/material.dart';
import '../utils/theme_manager.dart';

class AppearanceDialog extends StatelessWidget {
  const AppearanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildThemeOption(context, 'System (Default)', ThemeMode.system),
            _buildThemeOption(context, 'Light', ThemeMode.light),
            _buildThemeOption(context, 'Dark', ThemeMode.dark),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode) {
    final isSelected = ThemeManager.instance.themeMode == mode;
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        ThemeManager.instance.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
