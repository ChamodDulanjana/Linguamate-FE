import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/theme_manager.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Align(
          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUser
                  ? Color(ThemeManager.instance.getAccentColorValue(context).value).withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser  
                ? const Radius.circular(16)
                : Radius.zero,
            bottomRight: message.isUser
                ? Radius.zero
                : const Radius.circular(16),
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.05),
          //     blurRadius: 5,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: _parseMessage(
                  message.text,
                  TextStyle(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (message.hasActionButtons) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionButton(
                    label: "LEARN",
                    icon: Icons.school_outlined,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/learning',
                        arguments: {
                          'concepts': message.learningConcepts,
                          'language': message.language,
                        },
                      );
                    },
                  ),
                  _ActionButton(
                    label: "ACTIVITIES",
                    icon: Icons
                        .fitness_center_outlined, // 'Activity' icon equivalent
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/activities',
                        arguments: {
                          'concepts': message.learningConcepts,
                          'language': message.language,
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
      },
    );
  }

  //parse message to bold text / Bold the corrected sentence
  List<InlineSpan> _parseMessage(String text, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    // Regex to capture text between ** ... **
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*', dotAll: true);

    int lastIndex = 0;

    for (final Match match in boldRegex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add the bold text
      spans.add(
        TextSpan(
          text: match.group(1), // group 1 is the content inside **
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );

      lastIndex = match.end;
    }

    // Add any remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
