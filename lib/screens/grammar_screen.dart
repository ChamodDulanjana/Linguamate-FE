import 'package:flutter/material.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Rule')),

      //Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                        const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Subject-Verb Agreement",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "In English grammar, the subject and verb must agree in number. This means both must be singular or both must be plural.",
                      style: TextStyle(fontSize: 16, height: 1.5),
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
            _buildExampleCard(
              context,
              correct: "She runs every day.",
              incorrect: "She run every day.",
            ),
            const SizedBox(height: 12),
            _buildExampleCard(
              context,
              correct: "They are playing football.",
              incorrect: "They is playing football.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String correct,
    required String incorrect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                  correct,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  incorrect,
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
    );
  }
}
