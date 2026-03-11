class ChatMessage {
  final String text;
  final bool isUser;
  final bool hasActionButtons; // If true, show "Learn" and "Activities"
  final List<String>? learningConcepts;
  final String language;

  ChatMessage({
    required this.text,
    this.isUser = false,
    this.hasActionButtons = false,
    this.learningConcepts,
    this.language = "en",
  });
  
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? hasActionButtons,
    List<String>? learningConcepts,
    String? language,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      hasActionButtons: hasActionButtons ?? this.hasActionButtons,
      learningConcepts: learningConcepts ?? this.learningConcepts,
      language: language ?? this.language,
    );
  } 
}
