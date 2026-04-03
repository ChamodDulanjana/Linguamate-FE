import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_history.dart';
import '../screens/settings_screen.dart';
import '../services/chat_service.dart';
import 'login_sheet.dart';
import '../screens/terms_screen.dart';
import '../screens/privacy_screen.dart';

class MenuDrawer extends StatefulWidget {
  final bool isLoggedIn;
  final String? currentChatId;
  final VoidCallback onNewChat;
  final Function(String) onChatSelected;
  final Function(String) onChatDeleted;

  const MenuDrawer({
    super.key, 
    required this.isLoggedIn,
    this.currentChatId,
    required this.onNewChat,
    required this.onChatSelected,
    required this.onChatDeleted,
  });

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: widget.isLoggedIn
                ? _buildUserContent(context)
                : _buildGuestContent(context),
          ),
        ],
      ),
    );
  }

  // If user is not logged in
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onNewChat,
              borderRadius: BorderRadius.circular(8),
              splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
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
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildSimpleMenuItem("Terms", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen()));
          }),
          const SizedBox(height: 8),
          _buildSimpleMenuItem("Privacy", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen()));
          }),
          const SizedBox(height: 8),
          _buildSimpleMenuItem("Settings", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
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

  Widget _buildSimpleMenuItem(String title, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // If user is logged in
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade200,
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
                isSelected: widget.currentChatId == null,
                onTap: widget.onNewChat,
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
                  
                  final allChats = snapshot.data!;
                  final matching = allChats.where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                  final nonMatching = allChats.where((c) => !c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                  final displayChats = [...matching, ...nonMatching];
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 2.0,
                    ),
                    itemCount: displayChats.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final chat = displayChats[index];
                      return _buildHistoryItem(
                        chat.title,
                        chat.id,
                        user?.uid ?? '',
                        context,
                        isPinned: chat.isPinned,
                        isSelected: chat.id == widget.currentChatId,
                        onTap: () => widget.onChatSelected(chat.id),
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

  Widget _buildMenuItem(String path, String title, BuildContext context, {bool isSelected = false, required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDarkMode 
        ? Colors.white.withOpacity(0.1) 
        : Colors.black.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Image.asset(
                  path,
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String chatId,
    String userId,
    BuildContext context, {
    bool isPinned = false,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    Offset tapPosition = Offset.zero;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDarkMode 
        ? Colors.white.withOpacity(0.1) 
        : Colors.black.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          onTapDown: (details) {
            tapPosition = details.globalPosition;
          },
          onTap: onTap,
          onLongPress: () async {
            final action = await showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(
                tapPosition.dx,
                tapPosition.dy,
                tapPosition.dx,
                tapPosition.dy,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              items: [
                PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin, size: 20),
                      const SizedBox(width: 12),
                      Text(isPinned ? 'Unpin' : 'Pin'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      const SizedBox(width: 12),
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );

            if (action == 'pin') {
              if (userId.isNotEmpty) {
                await ChatService().togglePinStatus(userId, chatId, isPinned);
              }
            } else if (action == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Chat'),
                    content: const Text('Are you sure you want to delete this chat? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
              
              if (confirm == true && userId.isNotEmpty) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                await ChatService().deleteChat(userId, chatId);
                
                if (context.mounted) {
                  Navigator.pop(context); // pop loading dialog
                  widget.onChatDeleted(chatId);
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
                    ),
                  ),
                ),
                if (isPinned)
                  const Icon(Icons.push_pin, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
