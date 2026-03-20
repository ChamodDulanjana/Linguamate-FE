import 'package:flutter/material.dart';

class ButtonLoadingIndicator extends StatelessWidget {
  final bool isDarkMode;
  final double size;
  final double strokeWidth;
  const ButtonLoadingIndicator({
    super.key,
    required this.isDarkMode,
    this.size = 20,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
}