import 'package:lingolab/auth_screen/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/level_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // theme colours
  static const Color darkBlueBackground = Color(0xFF1A1B3A);
  static const Color redPrimary = Color(0xFFE53E3E);
  static const Color paleYellow = Color(0xFFFFF9C4);
  static const Color cardColor = Color(0xFF2D2E4F);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    // clean up controllers when widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // attempt firebase authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // check if widget is still mounted before navigation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LevelScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // handle Firebase authentication errors
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? 'Sign in failed';
        });
      }
    } finally {
      // reset loading state if widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlueBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // welcome back title
                  const Text(
                    "Welcome back, Linguist!",
                    style: TextStyle(
                      color: paleYellow,
                      fontSize: 28,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to continue your learning journey",
                    style: TextStyle(
                      color: paleYellow.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // email input field
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: paleYellow),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: paleYellow.withOpacity(0.7)),
                      filled: true,
                      fillColor: darkBlueBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: paleYellow.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: paleYellow.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: redPrimary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: paleYellow.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // password input field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: paleYellow),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: paleYellow.withOpacity(0.7)),
                      filled: true,
                      fillColor: darkBlueBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: paleYellow.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: paleYellow.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: redPrimary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: paleYellow.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // error message display
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: redPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: redPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: redPrimary),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // sign in button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redPrimary,
                        foregroundColor: paleYellow,
                        disabledBackgroundColor: redPrimary.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: paleYellow,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // navigate to sign up screen
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: paleYellow.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: redPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
