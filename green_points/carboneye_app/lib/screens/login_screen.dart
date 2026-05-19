import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/constants.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final result = await AuthService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(email: result['user'].email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // NSBM Logo area
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'NSBM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      Text(
                        'Green University Town',
                        style: TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Hero illustration
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryGreen.withOpacity(0.1),
                      lightBlue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.recycling, size: 80, color: primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Recycle & Earn Points',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Turn plastic waste into rewards',
                      style: TextStyle(fontSize: 14, color: textGrey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Title
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with your NSBM student account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textGrey),
              ),
              const SizedBox(height: 40),
              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: textDark,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: primaryGreen)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://developers.google.com/identity/images/g-logo.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Only @students.nsbm.ac.lk accounts are allowed',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textGrey),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}