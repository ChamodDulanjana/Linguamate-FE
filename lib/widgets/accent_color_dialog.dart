import 'package:flutter/material.dart';
import '../utils/theme_manager.dart';

class AccentColorDialog extends StatelessWidget {
  const AccentColorDialog({super.key});

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
                'Accent color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildColorOption(context, 'Default', AccentColorOption.defaultColor),
            _buildColorOption(context, 'Blue', AccentColorOption.blue),
            _buildColorOption(context, 'Green', AccentColorOption.green),
            _buildColorOption(context, 'Yellow', AccentColorOption.yellow),
            _buildColorOption(context, 'Pink', AccentColorOption.pink),
            _buildColorOption(context, 'Orange', AccentColorOption.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, String title, AccentColorOption color) {
    final isSelected = ThemeManager.instance.accentColor == color;
    final displayColor = ThemeManager.instance.getAccentColorValue(context, option: color);
    
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 16, color: displayColor),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        ThemeManager.instance.setAccentColor(color);
        Navigator.pop(context);
      },
    );
  }
}
