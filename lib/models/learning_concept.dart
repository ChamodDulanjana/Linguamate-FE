class LearningConcept {
  final String title;
  final String description;
  final List<LearningConceptExample> examples;

  LearningConcept({
    required this.title,
    required this.description,
    required this.examples,
  });

  factory LearningConcept.fromJson(Map<String, dynamic> json) {
    return LearningConcept(
      title: json['learningConcept'] as String,
      description: json['learningConceptExplanation'] as String,
      examples: (json['learningConceptExamples'] as List)
          .map((e) => LearningConceptExample.fromJson(e))
          .toList(),
    );
  }
}

class LearningConceptExample {
  final String correct;
  final String incorrect;

  LearningConceptExample({required this.correct, required this.incorrect});

  factory LearningConceptExample.fromJson(Map<String, dynamic> json) {
    return LearningConceptExample(
      correct: json['correct'] as String,
      incorrect: json['incorrect'] as String,
    );
  }
}
