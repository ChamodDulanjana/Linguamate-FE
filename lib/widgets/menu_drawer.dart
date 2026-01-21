import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Guest User"),
            accountEmail: const Text("Sign in to sync chats"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            decoration: const BoxDecoration(color: Colors.black),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Previous Chats'),
            onTap: () {
              Navigator.pop(context);
              // Placeholder
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Placeholder
            },
          ),
        ],
      ),
    );
  }
}
