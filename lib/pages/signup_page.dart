import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:costcater/components/toast.dart';

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
      context.showToast('Please fill in all fields', type: ToastType.info);

      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      context.showToast('Passwords do not match', type: ToastType.error);
      return;
    }

    if (passwordController.text.length < 6) {
      context.showToast('Password must be at least 6 characters',
          type: ToastType.info);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // First check if a user document already exists with this email
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(emailController.text)
          .get();

      if (userDoc.exists) {
        context.showToast('An account with this email already exists',
            type: ToastType.info);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Create the authentication account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Create the user document with email as document ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(emailController.text)
          .set({
        'name': nameController.text,
        'created_at': FieldValue.serverTimestamp(),
      });

      context.showToast('Signup Successful');

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error: ${e.message}';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      }

      context.showToast(errorMessage, type: ToastType.error);
    } catch (e) {
      context.showToast('Unexpected error: $e', type: ToastType.error);
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
              const SizedBox(height: 100),
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
              _buildTextField(
                controller: nameController,
                labelText: 'Name',
                hintText: 'Enter your name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),
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
