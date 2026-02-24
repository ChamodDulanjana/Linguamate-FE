import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'fill_in_blanks_screen.dart';
import 'speaking_practice_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final learningConcepts = args?['concepts'] as List<String>;
    final language = args?['language'] as String;

    final activities = [
      {
        'title': 'Quizzes',
        'subtitle': 'Test your grammar knowledge',
        'icon': Icons.quiz,
        'color': Colors.orange,
        'bgColor': const Color.fromARGB(255, 252, 236, 213),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                learningConcepts: learningConcepts,
                language: language,
              ),
            ),
          );
        },
      },
      {
        'title': 'Fill in the Blanks',
        'subtitle': 'Complete the sentences',
        'icon': Icons.edit_note,
        'color': Colors.blue,
        'bgColor': const Color.fromARGB(255, 214, 237, 255),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FillInBlanksScreen(
                learningConcepts: learningConcepts,
                language: language,
              ),
            ),
          );
        },
      },
      {
        'title': 'Speaking Practice',
        'subtitle': 'Improve your pronunciation',
        'icon': Icons.mic,
        'color': Colors.green,
        'bgColor': const Color.fromARGB(255, 206, 235, 208),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpeakingPracticeScreen(
                learningConcepts: learningConcepts,
                language: language,
              ),
            ),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(
            context,
            title: activity['title'] as String,
            subtitle: activity['subtitle'] as String,
            icon: activity['icon'] as IconData,
            color: activity['color'] as Color,
            bgColor: activity['bgColor'] as Color,
            onTap: activity['onTap'] as VoidCallback,
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDarkMode ? const Color.fromARGB(255, 54, 54, 54) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
