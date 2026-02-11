class Quiz {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  Quiz({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
    );
  }
}