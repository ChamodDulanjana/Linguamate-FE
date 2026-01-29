import 'package:flutter/material.dart';
import '../models/grammar_data.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data simulating multiple rules
    final List<GrammarRule> grammarRules = [
      GrammarRule(
        title: "Subject-Verb Agreement",
        description:
            "In English grammar, the subject and verb must agree in number. This means both must be singular or both must be plural.",
        examples: [
          GrammarExample(
            correct: "She runs every day.",
            incorrect: "She run every day.",
          ),
          GrammarExample(
            correct: "They are playing football.",
            incorrect: "They is playing football.",
          ),
        ],
      ),
      GrammarRule(
        title: "Articles (A, An, The)",
        description:
            "Articles are used to define a noun as specific or unspecific. 'The' is the definite article, while 'a' and 'an' are indefinite articles.",
        examples: [
          GrammarExample(
            correct: "I saw an elephant.",
            incorrect: "I saw a elephant.",
          ),
          GrammarExample(
            correct: "The book on the table is mine.",
            incorrect: "Book on the table is mine.",
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Rules'),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: grammarRules.length,
        itemBuilder: (context, index) {
          final rule = grammarRules[index];
          return _buildRuleItem(context, rule);
        },
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, GrammarRule rule) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: isDarkMode
              ? const Color(0xFF1E2A38)
              : const Color.fromARGB(255, 217, 238, 255),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  rule.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        //Examples
        Text(
          "Examples",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...rule.examples.map((example) => _buildExampleCard(context, example)),
        const SizedBox(height: 32),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExampleCard(BuildContext context, GrammarExample example) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color.fromARGB(255, 63, 64, 65)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    example.correct,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 16,
              color: (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
            ),
            Row(
              children: [
                const Icon(Icons.cancel, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    example.incorrect,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
