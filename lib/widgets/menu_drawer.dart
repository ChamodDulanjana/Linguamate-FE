import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_history.dart';
import '../screens/settings_screen.dart';
import '../services/chat_service.dart';
import 'login_sheet.dart';

class MenuDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onNewChat;
  final Function(String) onChatSelected;

  const MenuDrawer({
    super.key, 
    required this.isLoggedIn,
    required this.onNewChat,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                color: Theme.of(context).colorScheme.onSurface,
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
          Text(
            "Save your chat history and personalize your experience.",
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? Colors.grey[400]
                  : const Color.fromARGB(221, 128, 128, 128),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'User';
    final name = user?.displayName ?? email.split('@').first;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Column(
      children: [
        // Top Section with Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey.withOpacity(0.1)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable Menu Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildMenuItem(
                'assets/images/edit_icon.png',
                "New chat",
                context,
                onNewChat,
              ),
              const SizedBox(height: 24),

              // Pinned/Recent Chats
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Text(
                  "Recent",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),

              StreamBuilder<List<ChatHistory>>(
                stream: user != null ? ChatService().getUserChats(user.uid) : const Stream.empty(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No recent chats",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  
                  final chats = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 2.0,
                    ),
                    itemCount: chats.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return _buildHistoryItem(
                        chat.title,
                        context,
                        isPinned: chat.isPinned,
                        onTap: () => onChatSelected(chat.id),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),

        // Bottom Profile Section
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: 12,
            ),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFD700), // Gold/Yellow color
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.black, // Keep black on Gold
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: const Icon(Icons.more_horiz, color: Colors.grey),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String path, String title, BuildContext context, VoidCallback onTap) {
    return ListTile(
      leading: Image.asset(
        path,
        color: Theme.of(context).colorScheme.onSurface,
        width: 20,
        height: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildHistoryItem(
    String title,
    BuildContext context, {
    bool isPinned = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
        ),
      ),
      trailing: isPinned
          ? const Icon(Icons.push_pin, size: 16, color: Colors.grey)
          : null,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
