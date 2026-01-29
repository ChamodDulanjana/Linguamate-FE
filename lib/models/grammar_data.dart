class GrammarRule {
  final String title;
  final String description;
  final List<GrammarExample> examples;

  GrammarRule({
    required this.title,
    required this.description,
    required this.examples,
  });
}

class GrammarExample {
  final String correct;
  final String incorrect;

  GrammarExample({required this.correct, required this.incorrect});
}
