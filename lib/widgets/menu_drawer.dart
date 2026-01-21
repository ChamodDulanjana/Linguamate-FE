import 'package:flutter/material.dart';
import 'login_sheet.dart';

class MenuDrawer extends StatelessWidget {
  final bool isLoggedIn;

  const MenuDrawer({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: isLoggedIn
                ? _buildUserContent(context)
                : _buildGuestContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 55.0,
        bottom: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/edit_icon.png',
                color: Colors.black,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'New chat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSimpleMenuItem("Terms"),
          const SizedBox(height: 24),
          _buildSimpleMenuItem("Privacy"),
          const SizedBox(height: 24),
          _buildSimpleMenuItem("Settings"),
          const Spacer(),
          const Text(
            "Save your chat history and personalize your experience.",
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(221, 128, 128, 128),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close drawer
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const LoginSheet(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Log in or sign up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMenuItem(String title) {
    return InkWell(
      onTap: () {},
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildUserContent(BuildContext context) {
    return Column(
      children: [
        // Top Section with Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Search', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.edit_square, color: Colors.black),
            ],
          ),
        ),

        // Scrollable Menu Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildMenuItem(Icons.edit_square, "New chat"),
              _buildMenuItem(Icons.image_outlined, "Images"),
              _buildMenuItem(Icons.grid_view, "Apps"),
              _buildMenuItem(Icons.create_new_folder_outlined, "New project"),
              const SizedBox(height: 24),
              // Pinned/Recent Chats
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Recent",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              _buildHistoryItem("Machine building assistance", isPinned: true),
              _buildHistoryItem("Animated Logo Request"),
              _buildHistoryItem("Arduino Expert Assistance"),
              _buildHistoryItem("LINGUAMATE AI Flutter Dev"),
              _buildHistoryItem("Blue Penguin Mascot Design"),
              _buildHistoryItem("AI App Design Guide"),
              _buildHistoryItem("Logo for AI App"),
              _buildHistoryItem("Cryptography Exam Notes"),
            ],
          ),
        ),

        // Bottom Profile Section
        const Divider(height: 1),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFFFD700), // Gold/Yellow color
            child: Text(
              "CD",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: const Text(
            "Chamod Dulanjana",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          trailing: const Icon(Icons.more_horiz, color: Colors.grey),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      onTap: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildHistoryItem(String title, {bool isPinned = false}) {
    return ListTile(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      trailing: isPinned
          ? const Icon(Icons.push_pin, size: 16, color: Colors.grey)
          : null,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      visualDensity: VisualDensity.compact,
      onTap: () {},
    );
  }
}
