import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;

  Future<void> signup() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': nameController.text,
        'email': emailController.text,
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup Successful')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error: ${e.message}';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title with modern, clean typography
              Text(
                'Create Account',
                style: TextStyle(
                  fontFamily: 'SFProDisplay',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sign up to get started',
                style: TextStyle(
                  fontFamily: 'SFProDisplay',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Name Input
              _buildTextField(
                controller: nameController,
                labelText: 'Name',
                hintText: 'Enter your name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Email Input
              _buildTextField(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              // Password Input
              _buildTextField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Confirm Password Input
              _buildTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Signup Button
              ElevatedButton(
                onPressed: isLoading ? null : signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52ED28),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Signup',
                        style: TextStyle(
                          fontFamily: 'SFProDisplay',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Login Navigation
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: const Color(0xFF52ED28),
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
    );
  }

  // Custom TextField widget for consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        fontFamily: 'SFProDisplay',
        color: Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          fontFamily: 'SFProDisplay',
          color: Colors.grey[600],
        ),
        hintStyle: TextStyle(
          fontFamily: 'SFProDisplay',
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF52ED28), width: 2),
        ),
      ),
      keyboardType: obscureText
          ? TextInputType.visiblePassword
          : (labelText == 'Email'
              ? TextInputType.emailAddress
              : TextInputType.text),
    );
  }
}
