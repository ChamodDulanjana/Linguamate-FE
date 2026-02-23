class FillInTheBlanks {
  final String sentencePart1;
  final String sentencePart2;
  final List<String> options;
  final int correctOptionIndex;

  FillInTheBlanks({
    required this.sentencePart1,
    required this.sentencePart2,
    required this.options,
    required this.correctOptionIndex,
  });

  factory FillInTheBlanks.fromJson(Map<String, dynamic> json) {
    return FillInTheBlanks(
      sentencePart1: json['sentencePart1'],
      sentencePart2: json['sentencePart2'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
    );
  }
}
