import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: isDarkMode ? Colors.transparent : const Color.fromARGB(0, 255, 251, 251),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      isDarkMode
                          ? 'assets/images/linguamate_light_logo.png'
                          : 'assets/images/linguamate_logo.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Check your inbox',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the verification code we just sent to ${widget.email}.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // code field
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code',
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Code cannot be empty';
                      }
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Continue button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification Successful!'),
                          ),
                        );

                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),

                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email resent!')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Resend email'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
