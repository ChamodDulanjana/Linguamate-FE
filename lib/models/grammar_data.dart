class GrammarRule {
  final String title;
  final String description;
  final List<GrammarExample> examples;

  GrammarRule({
    required this.title,
    required this.description,
    required this.examples,
  });

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      title: json['learningConcept'] as String,
      description: json['learningConceptExplanation'] as String,
      examples: (json['learningConceptExamples'] as List)
          .map((e) => GrammarExample.fromJson(e))
          .toList(),
    );
  }
}

class GrammarExample {
  final String correct;
  final String incorrect;

  GrammarExample({required this.correct, required this.incorrect});

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      correct: json['correct'] as String,
      incorrect: json['incorrect'] as String,
    );
  }
}
