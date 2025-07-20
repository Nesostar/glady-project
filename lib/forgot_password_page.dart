import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isSending = false;
  String? message;

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    // Basic email validation
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        message = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      isSending = true;
      message = null;
    });

    try {
      print('Attempting to send password reset email to $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        message = '✅ Password reset email sent to $email.';
      });
      print('Password reset email sent successfully.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException code: ${e.code}, message: ${e.message}');
      String errorMsg = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        errorMsg = 'No user found with this email.';
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
      setState(() {
        message = errorMsg;
      });
    } catch (e) {
      print('General exception: $e');
      setState(() {
        message = 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email to receive a password reset link.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSending ? null : sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSending
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text("Send Reset Link"),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: message!.startsWith('✅') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
