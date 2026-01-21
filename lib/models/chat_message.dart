class ChatMessage {
  final String text;
  final bool isUser;
  final bool hasActionButtons; // If true, show "Learn" and "Activities"
  final String? originalText; // For grammar correction visualization if needed

  ChatMessage({
    required this.text,
    required this.isUser,
    this.hasActionButtons = false,
    this.originalText,
  });
}
