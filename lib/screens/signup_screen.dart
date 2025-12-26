import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      // 1. Create Auth User
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Requirement 5.1: Store minimal user data in Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text.trim(),
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Success -> Go Home
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created!")));
        Navigator.of(context).pushAndRemoveUntil(
           MaterialPageRoute(builder: (context) => const HomeScreen()),
           (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Sign Up", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextField(
              key: const Key('signup_email_field'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email Address"),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('signup_pass_field'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                key: const Key('signup_btn'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9775FA)),
                onPressed: _isLoading ? null : _signup,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}