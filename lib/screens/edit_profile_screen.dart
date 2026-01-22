import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: "chamoddulanjana");
  final _emailController = TextEditingController(
    text: "chamodperera128@gmail.com",
  );
  final _contactController = TextEditingController(text: "+94773810577");

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom Header to replace AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Profile Image with Camera
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFFFD700),
                        child: Text(
                          'CH',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Keep black on Gold
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image picker would open here'),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? Theme.of(context).colorScheme.surface
                                    : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Email (Read Only)
                  _buildEditField("Email", _emailController, readOnly: true),
                  const SizedBox(height: 20),

                  // Name
                  _buildEditField("Name", _nameController),
                  const SizedBox(height: 20),

                  // Contact
                  _buildEditField("Contact", _contactController),
                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile updated!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Save profile",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34), // Add bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly
                ? (isDarkMode ? Colors.grey[400] : Colors.grey[600])
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey.withOpacity(0.1) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
