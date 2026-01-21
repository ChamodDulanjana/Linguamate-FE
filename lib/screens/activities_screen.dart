import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildActivityItem(
            context,
            title: "Quizzes",
            subtitle: "Test your grammar knowledge",
            icon: Icons.quiz,
            color: Colors.orange,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            title: "Fill in the Blanks",
            subtitle: "Complete the sentences",
            icon: Icons.edit_note,
            color: Colors.blue,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            title: "Speaking Practice",
            subtitle: "Improve your pronunciation",
            icon: Icons.mic,
            color: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            title: "Vocabulary Builder",
            subtitle: "Learn new words daily",
            icon: Icons.book,
            color: Colors.purple,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Starting $title...")));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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
