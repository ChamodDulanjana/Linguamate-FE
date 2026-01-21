import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: const Color.fromARGB(255, 255, 213, 122),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildActivityItem(
            context,
            bgColor: const Color.fromARGB(255, 252, 236, 213),
            title: "Quizzes",
            subtitle: "Test your grammar knowledge",
            icon: Icons.quiz,
            color: Colors.orange,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            bgColor: const Color.fromARGB(255, 214, 237, 255),
            title: "Fill in the Blanks",
            subtitle: "Complete the sentences",
            icon: Icons.edit_note,
            color: Colors.blue,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            bgColor: const Color.fromARGB(255, 206, 235, 208),
            title: "Speaking Practice",
            subtitle: "Improve your pronunciation",
            icon: Icons.mic,
            color: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            bgColor: const Color.fromARGB(255, 230, 207, 235).withValues(alpha: 9.0),
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
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
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
