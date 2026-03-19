import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../../utils/validators.dart';
import '../../services/user_service.dart';

class EmailEntryScreen extends StatefulWidget {
  const EmailEntryScreen({super.key});

  @override
  State<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends State<EmailEntryScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final exists = await UserService().checkEmailExists(email);

        if (!mounted) return;

        if (exists) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(email: email)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupScreen(email: email)),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking email: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              //autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    'Log in or sign up',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Save your chat history and personalize your experience.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Continue'),
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
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement Google Sign In
                    },
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.g_mobiledata), // Fallback
                    ),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(
                        color: isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Extra padding at bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
