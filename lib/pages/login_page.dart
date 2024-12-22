import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(email: emailController.text),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error: ${e.message}';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password for that email.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Replace the 'Welcome Back' text with the logo image
              const SizedBox(height: 50), // Adjust to your preference
              Center(
                child: Image.asset(
                  'assets/logos/costcaterlogo.png', // Path to your logo image
                  height: 200, // Adjust the height as necessary
                  width: 200, // Adjust the width as necessary
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontFamily: 'SFProDisplay',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52ED28),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Login',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign up',
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
          : TextInputType.emailAddress,
    );
  }
}
