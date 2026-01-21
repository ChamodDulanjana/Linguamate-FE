import 'package:flutter/material.dart';
import '../screens/auth/email_entry_screen.dart';

class LoginSheet extends StatelessWidget {
  const LoginSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // We return the EmailEntryScreen which is a Scaffold.
    // When shown in showModalBottomSheet with isScrollControlled: true,
    // it will take up the full height (or as defined) and look like a page.
    // We might need to wrap it in a SizedBox with height if we want it to be specific,
    // but usually full screen auth flows in sheets want max height.
    return const FractionallySizedBox(
      heightFactor: 0.95, // Occupy most of the screen like a page
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        child: EmailEntryScreen(),
      ),
    );
  }
}
