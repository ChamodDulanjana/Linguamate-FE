import 'package:flutter/material.dart';
import '../models/learning_concept.dart';
import '../services/learning_concept_api_service.dart';
import '../widgets/loading_widget.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late Future<List<LearningConcept>> _learningConceptsFuture;
  late List<String> _learningConcepts;
  late String language;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      if (args['concepts'] != null) {
        _learningConcepts = (args['concepts'] as List<dynamic>).cast<String>();
      }
      language = args['language'] as String;
    }

    // Fetch grammar rules from server
    if (_learningConcepts.isEmpty) {
      _learningConceptsFuture = Future.value([]);
    } else {
      _learningConceptsFuture =
          LearningConceptApiService.fetchLearningConceptsExplanations(
            _learningConcepts,
            language,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Concepts'),
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<List<LearningConcept>>(
        future: _learningConceptsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(type: LoadingType.learning);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No grammar rules found.'));
          }

          final learningConcepts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: learningConcepts.length,
            itemBuilder: (context, index) {
              final learningConcept = learningConcepts[index];
              return _buildRuleItem(context, learningConcept);
            },
          );
        },
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, LearningConcept learningConcept) {
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
                        learningConcept.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  learningConcept.description,
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
        ...learningConcept.examples.map(
          (example) => _buildExampleCard(context, example),
        ),
        const SizedBox(height: 32),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    LearningConceptExample example,
  ) {
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
